USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points_Save
GO
 
CREATE PROCEDURE dbo.Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points_Save (
    @userID                   bigint
  , @userGroup                int
  , @userRank                 int
  , @clientID                 bigint
  , @minMinsPerFreqDaily      int
  , @minMinsPerFreqWeekly     int
  , @minMinsPerFreqMonthly    int
  , @notes                    varchar(max)  
  , @saveType                 smallint       output
  , @spDetails                varchar (8000) output    
  , @recordID                 bigint         output)   
AS    
BEGIN    

/***************************************************************************
 * Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points_Save    */
/**
 * Saves new or replaces existing record based on clientID.
 * 
 * @parm minMinsPerFreqDaily   The min num of minutes for daily plans
 * @parm minMinsPerFreqWeekly  The min num of minutes for weekly plans
 * @parm minMinsPerFreqMonthly The min num of minutes for monthly plans
 *
 * TODO: Convert this from a saveOrReplace style procedure to a normal 
 * save procedure once we are able to expand the management of this data.
 ***************************************************************************/
     
SET NOCOUNT ON    

declare @tranOpen as bit = 0   
declare @today    as datetime     
declare @state    as smallint

BEGIN TRY    
   
/*============================================================
 * Init
 *============================================================*/  

set @recordID   = 0    
set @spDetails  = '' 
set @today     = GETDATE()   
set @saveType  = 0
set @tranOpen  = 0
set @state     = 0

/*============================================================
 * Verify required parameters 
 *============================================================*/  
    
IF (@userGroup is null) RAISERROR ('userGroup is required',       11, 1)
IF (@userID    is null) RAISERROR ('user id is required',         11, 1)    
IF (@userRank  is null) RAISERROR ('userRank is required',        11, 1)      
if (@clientID  is null) RAISERROR ('Client id is required',       11, 1)

/*============================================================
 * Set defaults
 *============================================================*/  

if (@minMinsPerFreqDaily   is null) set @minMinsPerFreqDaily   = 0
if (@minMinsPerFreqWeekly  is null) set @minMinsPerFreqWeekly  = 0
if (@minMinsPerFreqMonthly is null) set @minMinsPerFreqMonthly = 0
if (@notes                 is null) set @notes = ''

/*============================================================
 * Exit if any of the mins per freq values are less than 0 
 *============================================================*/  

if (@minMinsPerFreqDaily   < 0) RAISERROR ('Mins per frequency daily cannot be less than 0',   11, 1)
if (@minMinsPerFreqWeekly  < 0) RAISERROR ('Mins per frequency weekly cannot be less than 0',  11, 1)
if (@minMinsPerFreqMonthly < 0) RAISERROR ('Mins per frequency monthly cannot be less than 0', 11, 1)

/*============================================================
 * Exit if any of the mins per freq values exceed reasonable
 * values.
 *============================================================*/  

if (@minMinsPerFreqDaily   > dbo.CONST_MAX_MINS_DAILY())   RAISERROR ('Mins per frequency daily exceeds the number of minutes in a day',     11, 1)
if (@minMinsPerFreqWeekly  > dbo.CONST_MAX_MINS_WEEKLY())  RAISERROR ('Mins per frequency weekly exceeds the number of minutes in a week',   11, 1)
if (@minMinsPerFreqMonthly > dbo.CONST_MAX_MINS_MONTHLY()) RAISERROR ('Mins per frequency monthly exceeds the number of minutes in a month', 11, 1)

/*============================================================
 * Find existing record (if any)
 *============================================================*/  

set @recordID  = 0
set @saveType  = 0

select top 1
  @recordID = isnull(t1.id,0) 
from dbo.Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points as t1
where ( 
       (t1.clientID = @clientID)
   and (t1.active   = 1)
)
option (recompile)

/*============================================================
 * Determine save type
 *============================================================*/  

if      (@recordId = 0) set @saveType = dbo.CONST_SAVE_TYPE_NEW()
else if (@recordID > 0) set @saveType = dbo.CONST_SAVE_TYPE_EDIT()
else                    set @saveType = 0

/*============================================================
 * Exit if save type is unknown
 *============================================================*/  

if (@saveType = 0) RAISERROR ('Unknown save type', 11, 1)    

/*============================================================
 * Save data
 *============================================================*/  

begin transaction
set @tranOpen = 1

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN        
  
  set @state = dbo.CONST_REC_STATE_NEW()
    
  INSERT INTO [dbo].[Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points]
  (                   
      clientID    
    , minMinsPerFreqDaily
    , minMinsPerFreqWeekly
	, minMinsPerFreqMonthly 
    , notes
	, created
	, createdBy
	, active
  )    
  VALUES    
  (  
        @clientID
	  , @minMinsPerFreqDaily
	  , @minMinsPerFreqWeekly
	  , @minMinsPerFreqMonthly                               
	  , @notes
	  , @today 
	  , @userID
	  , 1
  )      
     
  set @recordID = SCOPE_IDENTITY()    

END         
  
ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
BEGIN    
  
  set @state = dbo.CONST_REC_STATE_MOD()
  
  update [dbo].[Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points]
  set  
      minMinsPerFreqDaily   = @minMinsPerFreqDaily
    , minMinsPerFreqWeekly  = @minMinsPerFreqWeekly
	, minMinsPerFreqMonthly = @minMinsPerFreqMonthly
    , notes                 = @notes
	, lastModified          = @today
	, lastModifiedBy        = @userID
  where 
    (id = @recordID)	

END    
ELSE    
BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
END    
             
/*============================================================
 * Save audit data
 *
 * TODO: Move this logic to a dedicated audit sproc once this
 * save sproc is converted from a saveOrReplace to a save.
 *============================================================*/  

INSERT INTO [dbo].[Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points_Audit_Log]
(                   
      recID
	, loggedOn
	, userID
    , saveType
	, [state]
    , reason
	, minMinsPerFreqDaily
    , minMinsPerFreqWeekly
	, minMinsPerFreqMonthly 
    , notes
	, active
  )    
  values 
  (
    @recordID
  , @today
  , @userID
  , @saveType
  , @state 
  , ''
  , @minMinsPerFreqDaily
  , @minMinsPerFreqWeekly
  , @minMinsPerFreqMonthly
  , @notes
  , 1
)

commit transaction
set @tranOpen = 0

/*============================================================
 * Done
 *============================================================*/  
   
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
       
  if (@tranOpen = 1) rollback transaction

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
 
GRANT EXECUTE ON  dbo.Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points_Save TO webuser
GO