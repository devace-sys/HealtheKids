USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Patients_Promised_Services_CDE_Audits_Current_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Patients_Promised_Services_CDE_Audits_Current_Save] (
    @userID               BIGINT    
  , @userGroup            INT  
  , @userRank             INT 
  , @clientID             bigint
  , @startDate            datetime
  , @endDate              datetime
  , @recordID             BIGINT        OUTPUT
  , @spDetails            VARCHAR(8000) OUTPUT
  , @saveType             INT           OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * Patients_Promised_Services_CDE_Audits_Current_Save */    
/**    
 * 
 ***************************************************************************/        

/*============================================================
 * Variables and init
 *============================================================*/  


declare @today       as datetime
declare @tranOpen    as bit = 0

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
IF (@startDate   is null) RAISERROR ('start date is required',        11, 1) 
IF (@endDate     is null) RAISERROR ('end date is required',        11, 1) 

/*============================================================
 * Verify client exists
 *============================================================*/  

if not exists (
  select top 1 
    clc.CLIENT_ID
  from dbo.CLIENTS_Client as clc
  where (
     (clc.CLIENT_ID = @clientID)
  )
)
begin
  RAISERROR ('Client not found', 11, 1) 
end

/*============================================================
 * Verify Dates
 *============================================================*/  

if (dbo.DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL(@startDate,2000,2050) is null)
begin
  RAISERROR ('Start date may be unrealistic', 11, 1) 
end

if (dbo.DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL(@endDate,2000,2050) is null)
begin
  RAISERROR ('End date may be unrealistic', 11, 1) 
end

if (@startDate > @endDate)
begin
  RAISERROR ('Start date is after end date', 11, 1) 
end


/*============================================================
 * Assume this is a new record to start
 *============================================================*/  

set @saveType = dbo.CONST_SAVE_TYPE_NEW()

/*============================================================
 * See if a record exists for this selection
 *
 * If a record does exist the save type will be changed to
 * edit
 *============================================================*/  

select top 1
   @recordID = t1.id 
,  @saveType = dbo.CONST_SAVE_TYPE_EDIT()
from dbo.Patients_Promised_Services_CDE_Audits_Current as t1

where (
      (t1.clientID = @clientID)
  and (t1.active = 1)
)

begin transaction
set @tranOpen = 1

/*============================================================
 * Record does not exist, create a new one
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  insert into dbo.Patients_Promised_Services_CDE_Audits_Current (
      clientID
	, startDate
    , endDate
    , created 
    , createdBy
  )

  values ( 
      @clientID
    , @startDate 
    , @endDate
    , @today
    , @userID
  )

  set @recordID = SCOPE_IDENTITY()

end

/*============================================================
 * Record does exist, edit the response
 *============================================================*/  

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  update dbo.Patients_Promised_Services_CDE_Audits_Current 
  set 
     startDate      = @startDate
   , endDate        = @endDate
   , lastModified   = @today
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

GRANT EXECUTE ON  [dbo].[Patients_Promised_Services_CDE_Audits_Current_Save] TO [webuser]
GO
