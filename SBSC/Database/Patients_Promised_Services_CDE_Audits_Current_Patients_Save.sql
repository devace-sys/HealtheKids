USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_Save
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Patients_Promised_Services_CDE_Audits_Current_Patients_Save] (
    @userID               BIGINT    
  , @userGroup            INT  
  , @userRank             INT 
  , @clientID             bigint
  , @patID                bigint
  , @validateRec          bit
  , @recordID             BIGINT        OUTPUT
  , @spDetails            VARCHAR(8000) OUTPUT
  , @saveType             INT           OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * Patients_Promised_Services_CDE_Audits_Current_Patients_Save */    
/**    
 *  One patID per current audit period record
 ***************************************************************************/        

/*============================================================
 * Variables and init
 *============================================================*/  

declare @today                                      as datetime
declare @tranOpen                                   as bit      = 0
declare @patientsPromisedServicesCDEAuditsCurrentID as bigint   = null
declare @auditStartDate                             as date     = null
declare @auditEndDate                               as date     = null

set @today     = getdate()
set @recordID  = 0
set @spDetails = ''
set @saveType  = 0
set @tranOpen  = 0

BEGIN TRY

/*============================================================
 * Check required parameters
 *============================================================*/  

IF (@userID      IS NULL) RAISERROR ('userID is required',          11, 1)      
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',       11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',        11, 1) 
IF (@clientID    is null) RAISERROR ('clientID is required',        11, 1) 
IF (@patID       is null) RAISERROR ('patID is required',           11, 1) 

/*============================================================
 * Get current audit header record for this client
 * If none found get out
 *============================================================*/  

set @patientsPromisedServicesCDEAuditsCurrentID = null

select top 1
    @patientsPromisedServicesCDEAuditsCurrentID = t1.id 
  , @auditStartDate                             = t1.startDate
  , @auditEndDate                               = t1.endDate
from dbo.Patients_Promised_Services_CDE_Audits_Current as t1
where (
      (t1.clientID = @clientID)
  and (t1.active = 1)
)

if (@patientsPromisedServicesCDEAuditsCurrentID is null)
begin
  RAISERROR ('No audit period record found.  Please save the audit period.', 11, 1) 
end

/*============================================================
 * Verify patient exists
 *============================================================*/  

if not exists (
  select top 1 
    pap.PATIENT_ID 
  from dbo.PATIENTS_Client  as pac
  join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pac.PATIENT_ID
  where (
        (pac.CLIENT_ID = @clientID)
    and (pac.PATIENT_ID = @patID)
  )
)
begin
  RAISERROR ('No patient record found for this client.', 11, 1) 
end

/*============================================================
 * Verify patient has promised services entered
 *============================================================*/  

if not exists (
  select top 1 
    pps.id
  from dbo.PATIENTS_Promised_Services as pps
  where (
      (pps.patID = @patID)
  )
)
begin
  RAISERROR ('This student does not have ANY SpEd plans recorded.', 11, 1) 
end

/*============================================================
 * Verify patient has promised services that apply to the
 * audit date range
 *============================================================*/  

if not exists (
  select top 1 
    lpps.spEdServiceCode
  from dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA (
    @clientID
  , @patID
  , null
  , null
  , null
  , null
  , null
  , @auditStartDate
  , @auditEndDate
  , null
  , null) as lpps
  where (
    (lpps.startDate <= lpps.endDate)
  )
)
begin
  RAISERROR ('This student does not have SpEd plans that are in effect for the audit date range recorded.', 11, 1) 
end

/*============================================================
 * Assume this is a new record to start
 *============================================================*/  

set @saveType = dbo.CONST_SAVE_TYPE_NEW()

/*============================================================
 * See if a record exists
 *
 * If a record does exist the save type will be changed to
 * edit
 *============================================================*/  

select top 1
    @recordID = t1.id 
  , @saveType = dbo.CONST_SAVE_TYPE_EDIT()
from dbo.Patients_Promised_Services_CDE_Audits_Current_Patients as t1
where (
      (t1.patientsPromisedServicesCDEAuditsCurrentID = @patientsPromisedServicesCDEAuditsCurrentID)
  and (t1.patID = @patID)
)


IF ( @validateRec = 1 )
  RETURN (0)


begin transaction
set @tranOpen = 1

/*============================================================
 * Record does not exist, create a new one
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  insert into dbo.Patients_Promised_Services_CDE_Audits_Current_Patients (
      patientsPromisedServicesCDEAuditsCurrentID
	, patID
    , created 
    , createdBy
  )

  values ( 
     @patientsPromisedServicesCDEAuditsCurrentID
    , @patID 
    , @today
    , @userID
  )

  set @recordID = SCOPE_IDENTITY()

end

/*============================================================
 * Record does exist, edit the record
 *============================================================*/  

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  update dbo.Patients_Promised_Services_CDE_Audits_Current_Patients
  set 
     lastModified   = @today
   , lastModifiedBy = @userID
  where (id = @recordID)
end
else
begin
    RAISERROR ('save type not valid', 11, 1)   
end

commit transaction
set @tranOpen = 0

/*============================================================
 * All done
 *============================================================*/  

RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Return any
   * error error messages to    
   * the caller    
   *------------------------------*/    
       
 if (@tranOpen = 1) 
 begin
   rollback transaction
   set @tranOpen = 0
 end
 
  -- Error or raise error with severity 11 to 19 will be caught here    
            
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Patients_Promised_Services_CDE_Audits_Current_Patients_Save] TO [webuser]
GO
