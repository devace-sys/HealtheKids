USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_User_Provided_Delivery_Compliance_Stats_Save_Or_Replace') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_User_Provided_Delivery_Compliance_Stats_Save_Or_Replace
GO
 
CREATE PROCEDURE dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_User_Provided_Delivery_Compliance_Stats_Save_Or_Replace (
    @userID                                             bigint
  , @userGroup                                          int
  , @userRank                                           int
  , @clientID                                           bigint
  , @patientsPromisedServicesCDEAuditsCurrentPatientsID bigint
  , @spEdServiceCode                                    int  
  , @planStartDate                                      date 
  , @spEdFreqCode                                       int  
  , @minsPerFreq                                        int    
  , @minsExpected                                       int 
  , @minsSatisfied                                      int 
  , @pctExpectedApplicable                              real    
  , @notes                                              varchar(max)
  , @remove                                             bit
  , @validate                                           bit
  , @saveType                                           smallint       output
  , @spDetails                                          varchar (8000) output    
  , @recordID                                           bigint         output)   
AS    
BEGIN    
     
SET NOCOUNT ON    
   
DECLARE @today          as datetime     
declare @patID          as bigint = null
declare @auditStartDate as date
declare @auditEndDate   as date

BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @recordID   = 0    
SET @spDetails  = '' 
SET @today     = GETDATE()   
SET @saveType  = 0
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/ 
    
IF (@userGroup        is null) RAISERROR ('userGroup is required',       11, 1)
IF (@userID           is null) RAISERROR ('user id is required',         11, 1)    
IF (@userRank         is null) RAISERROR ('userRank is required',        11, 1)      
IF (@validate         is null) RAISERROR ('validate flag is required',   11, 1)
if (@clientID         is null) RAISERROR ('Client id is required',       11, 1)
if (@spEdServiceCode  is null) RAISERROR ('SpEd service code required',  11, 1)
if (@planStartDate    is null) RAISERROR ('Start date required',         11, 1)
if (@spEdFreqCode     is null) RAISERROR ('SpEd freq code required',     11, 1)
if (@minsPerFreq      is null) RAISERROR ('Mins per freq required',      11, 1)

if (@patientsPromisedServicesCDEAuditsCurrentPatientsID is null) RAISERROR ('Patient audit id is required',  11, 1)

/*============================================================
 * Make sure user can access patient in audit table
 * and also get the spEdCare patient id
 *============================================================*/  

set @patID = null

select top 1 
    @patID          = t1.patID
  , @auditStartDate = t2.startDate
  , @auditEndDate   = t2.endDate
from dbo.Patients_Promised_Services_CDE_Audits_Current_Patients as t1
join dbo.Patients_Promised_Services_CDE_Audits_Current          as t2 on t2.id = t1.patientsPromisedServicesCDEAuditsCurrentID
where (
        (t1.id       = @patientsPromisedServicesCDEAuditsCurrentPatientsID)
    and (t1.active   = 1)
	and (t2.clientID = @clientID)
	and (t2.active   = 1)
)
option (recompile)

if (@patID is null)
begin
  RAISERROR ('There is no current record of this patient being part of this audit in SpEdCare', 11, 1)
end

/*============================================================
 * Get plan data and current calculations
 *============================================================*/  

declare @auditEndDateOrCurrent as date   = dbo.DATE_VALUE_OR_REPLACEMENT_IF_GT_LT(@auditEndDate,@today,1)
declare @ourMinsExpected       as int    = 0
declare @ourMinsSatisfied      as int    = 0
declare @ourFreqCode           as int    = 0
declare @ourPlanStartDate      as date   = null
declare @ourPlanEndDate        as date   = null
declare @ourBillableSvc        as bit    = null
declare @pdIdx                 as bigint = null 
declare @checkPlanData         as bit    = 1

if (@checkPlanData = 1)
begin

select top 1 

      @pdIdx            = psvdc.idx
	, @ourMinsExpected  = psvdc.totalMinutesExpected
	, @ourMinsSatisfied = psvdc.totalMinutesSatisfied
    , @ourPlanStartDate = psvdc.planStartDate
	, @ourPlanEndDate   = psvdc.planEndDate
	, @ourFreqCode      = psvdc.spEdFreqCode    
	, @ourBillableSvc   = psvdc.billableSvc

from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE (
      @clientID
    , @patID
	, null -- prac	
    , @spEdServiceCode
    , @planStartDate
	, null
	, @spEdFreqCode
	, @minsPerFreq
	, null 
	, @auditStartDate
    , @auditEndDateOrCurrent
    , null   /*@patHasBIC*/
    , null   /*@patHasSSID*/
    , null   /*@billableSvcs*/
    , 1      /*@limitCalcToEndDate*/ 
    , 0 
    , 0      /*@calcPotLostReimbursement */
	, 1      /*@limitDosToStartEndDate*/
	, 1     /*@reqPatSvcCode*/
	, 0     /*@usePpsSvcTermsProvided*/
	, 0     /* Pat absent counts as mins satisfied */
	, 0     /* Exit without calc */
) as psvdc
option (recompile)

/*============================================================
 * Prevent entry if service/plan not found
 *============================================================*/  

if (@pdIdx is null)
begin
  RAISERROR ('There is no current record of this plan/service in SpEdCare', 11, 1)
end

/*============================================================
 * Prevent entry if delivery was satisfied
 *============================================================*/  

if (@ourMinsSatisfied >= @ourMinsExpected)
begin
  RAISERROR ('According to our records this plan/service has all expected minutes satisfied.  Therefore it is not neccessary to enter delivery compliance stats', 11, 1)	
end

/*============================================================
 * Validation only
 *============================================================*/  

if (@validate = 1)
begin
  /*============================================================
   * Prevent entry if mins entered in SpEdCare
   *============================================================*/  

  if (@ourMinsSatisfied > 0)
  begin
    RAISERROR ('According to our records this plan/service has services recorded in SpEdCare.  Please complete the recording of all services rendered during audit period.', 11, 1)
  end

  /*============================================================
   * Prevent entry if service is billable
   *============================================================*/  

  if (@ourBillableSvc = 1)
  begin
    RAISERROR ('According to our records this plan/service should be tracked in SpEdCare via our service records screens.  Please complete the recording of all services rendered during audit period.', 11, 1)	
  end
end /* Validate*/
 
/*============================================================
 * If frequency code is yearly or other
 *============================================================*/  

if (@ourFreqCode in (40,90))
begin
  
  /*============================================================
   * If the plan ends during the audit period
   *============================================================*/  

  if (@ourPlanEndDate between @auditStartDate and @auditEndDate)
  begin
	
	/*============================================================
     * And if the user provided a different mins expected
     *============================================================*/  

	if (@minsExpected != @ourMinsExpected)
	begin
      RAISERROR ('According to our records this plan with a frequency of yearly or other ended during the audit period.  Therefore you cannot change the minutes expected for this plan/service because the period for satisifying all expected minutes for this plan is in the past.', 11, 1)
	end
	
  end
  
  /*============================================================
   * If user provides a 0 for mins expected but provides
   * > 0 for mins satisfied, change the mins satisfied to 0
   *============================================================*/  

  if ((@minsExpected = 0) and (@minsSatisfied > 0))
  begin
    set @minsSatisfied = 0
  end

end

/*============================================================
 * If frequency code is not yearly or other
 *============================================================*/  

else

begin
  
  if (@minsExpected = 0)
  begin
    RAISERROR ('Mins expected cannot be 0', 11, 1)
  end

  /*============================================================
   * User is not allowed to change mins expected
   *============================================================*/  

  if (@minsExpected != @ourMinsExpected)
  begin
    RAISERROR ('You cannot provide minutes expected for this plan/service', 11, 1)
  end
end

end

/*============================================================
 * Find existing record and set save type
 *============================================================*/  

set @recordID  = 0
set @saveType  = 0

select top 1
  @recordID = isnull(t1.id,0) 
from dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_User_Provided_Delivery_Compliance_Stats as t1
where ( 
       (t1.patientsPromisedServicesCDEAuditsCurrentPatientsID = @patientsPromisedServicesCDEAuditsCurrentPatientsID)
   and (t1.spEdServiceCode = @spEdServiceCode )
   and (t1.planStartDate   = @planStartDate   )
   and (t1.spEdFreqCode    = @spEdFreqCode    )
   and (t1.minsPerFreq     = @minsPerFreq     )
   and (t1.active          = 1                )
)
option (recompile)

if      (@recordId = 0) set @saveType = dbo.CONST_SAVE_TYPE_NEW()
else if (@recordID > 0) set @saveType = dbo.CONST_SAVE_TYPE_EDIT()
else                    set @saveType = 0

/*============================================================
 * Calculate active
 * If the save type is edit and the remove flag is set to 1
 * then active should be 0
 * This is to allow users to "delete" entries not needed
 *============================================================*/  

declare @active as bit = 1
if ((@remove = 1) and (@saveType = dbo.CONST_SAVE_TYPE_EDIT()))
begin
  set @active = 0
end

/*============================================================
 * If we are validating, exit
 *============================================================*/  

if (@validate = 1) 
begin
  return
end

/*============================================================
 * Save data
 *============================================================*/  
       
IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN        
    
  INSERT INTO [dbo].[Patients_Promised_Services_CDE_Audits_Current_Patients_User_Provided_Delivery_Compliance_Stats]
  (                   
        patientsPromisedServicesCDEAuditsCurrentPatientsID 
	  , spEdServiceCode                                    
	  , planStartDate
	  , spEdFreqCode                                       
	  , minsPerFreq  
	  , minsExpected 
	  , minsSatisfied 
	  , pctExpectedApplicable 
	  , notes
	  , created
	  , createdBy
      , active
	)    
  VALUES    
  (  
        @patientsPromisedServicesCDEAuditsCurrentPatientsID 
	  , @spEdServiceCode                                    
	  , @planStartDate
	  , @spEdFreqCode                                       
	  , @minsPerFreq  
	  , @minsExpected 
	  , @minsSatisfied 
	  , @pctExpectedApplicable 
	  , @notes
	  , @today 
	  , @userID
	  , @active    
  )      
    
  SET @recordID = SCOPE_IDENTITY()    
END         
  
ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
BEGIN    
      
    update [dbo].[Patients_Promised_Services_CDE_Audits_Current_Patients_User_Provided_Delivery_Compliance_Stats]
    set                  
        minsExpected          = @minsExpected 
	  , minsSatisfied         = @minsSatisfied 
	  , pctExpectedApplicable = @pctExpectedApplicable 
	  , notes                 = @notes  
	  , lastModified          = @today
	  , lastModifiedBy        = @userID
      , active                = @active
	where (id = @recordID)        
  END    
ELSE    
BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
END    
             
/*-------------------------------    
 * If we reach this point    
 * everything is OK exit    
 *------------------------------*/    
   
RETURN(0)    
END TRY 

BEGIN CATCH    
   
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
     
     
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
     
  --SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ''    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END      
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_User_Provided_Delivery_Compliance_Stats_Save_Or_Replace TO webuser
GO