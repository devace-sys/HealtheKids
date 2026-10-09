USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_GOALS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_GOALS_SAVE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PATIENT_GOALS_SAVE] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT      
  , @clientID            BIGINT
  , @groupSvcClassNameID BIGINT
  , @patID               BIGINT
  , @name                VARCHAR(max)
  , @goalTypeID          bigint
  , @baseLineValue       int
  , @startDate           DATE
  , @endDate             DATE
  , @goalMet             BIT
  , @goalMetOn			 DATE
  , @backgroundText      VARCHAR(MAX)
  , @notes               VARCHAR(MAX) 
  , @objective1Text      VARCHAR(MAX)
  , @objective1Met       BIT
  , @objective1MetOn     DATE 
  , @objective2Text		 VARCHAR(MAX)
  , @objective2Met       BIT
  , @objective2MetOn     DATE
  , @objective3Text      VARCHAR(MAX)
  , @objective3Met       BIT
  , @objective3MetOn     DATE
  , @editDelReason       VARCHAR(7000)
  , @validateRec         BIT
  , @saveType            INT
  , @recID               BIGINT
  , @MsgNoRec            VARCHAR(1000)
  , @MsgNoEdit           VARCHAR(1000)
  , @MsgDupRec           VARCHAR(1000)
  , @MsgDataError        VARCHAR(1000)
  , @MsgNotActive        VARCHAR(1000)
  , @spDetails           VARCHAR(8000) OUTPUT
  , @recordID            BIGINT        OUTPUT )    
AS    
BEGIN     
    
/***************************************************************************    
 * PATIENT_GOALS_SAVE */    
/**    
 * Creates new or edits existing
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   editDelReason   Reason for record edit or delete    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete    
 * @param   recID           Record id of existing patient record to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message if a recID is not found    
 * @param   MsgNoEdit       Desired error message if a record cannot be edited    
 * @param   MsgDupRec       Desired error message for duplicate detection    
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/

DECLARE @today              AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen           AS BIT            -- Is a transaction open

declare @userDefinedGoal               as bit    = 1
declare @savedGoalTypeID               as bigint = -1
declare @okToEditUserDefinedGoalTypeID as bit    = 0
declare @goalTypeRecID                 as bigint = 0
declare @measureValueMin               as decimal(38,4) = 0
declare @measureValueMax               as decimal(38,4) = 0
declare @baseLineValueAsDcml           as decimal(38,4) = 0
declare @hasObjectives  			   as bit = 0
declare @hasObjective1				   as bit = 0
declare @hasObjective2				   as bit = 0
declare @hasObjective3				   as bit = 0

BEGIN TRY

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
SET @recordID  = 0    
SET @spDetails = ''    
SET @today     = GETDATE()    

/*============================================================
 * Clean incoming parms
 *============================================================*/  

set @baseLineValue = isnull(@baseLineValue,0)

set @backgroundText = trim(isnull(@backgroundText,''))
set @notes          = trim(isnull(@notes,''))
set @objective1Text = trim(isnull(@objective1Text,''))
set @objective2Text = trim(isnull(@objective2Text,''))
set @objective3Text = trim(isnull(@objective3Text,''))
set @goalMet        = isnull(@goalMet,0)
set @objective1Met  = isnull(@objective1Met,0)
set @objective2Met  = isnull(@objective2Met,0)
set @objective3Met  = isnull(@objective3Met,0)

set @hasObjective1 =
  case
    when len(@objective1Text) > 0 then 1
    else 0
  end

set @hasObjective2 =
  case
    when len(@objective2Text) > 0 then 1
    else 0
  end

set @hasObjective3 =
  case
    when len(@objective3Text) > 0 then 1
    else 0
  end

set @hasObjectives =
  case
    when (
         (@hasObjective1 = 1)
      or (@hasObjective2 = 1)
      or (@hasObjective3 = 1)
    )
    then 1
    else 0
  end

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
if (@goalTypeID    is null) RAISERROR ('Goal type is required',   11, 1)    

/*============================================================
 * See if the clientID and patID combo is valid
 *============================================================*/  

if not exists (
  select top 1 
    numOf = 1 
  from dbo.CLIENTS_Client   as cc 
  join dbo.PATIENTS_Client  as pc on pc.CLIENT_ID  = cc.CLIENT_ID
  join dbo.PATIENTS_Patient as pp on pp.PATIENT_ID = pc.PATIENT_ID
  where (
        (cc.CLIENT_ID  = @clientID) 
    and (pp.PATIENT_ID = @patID)
  )
)
begin
  RAISERROR ('Invalid client or patient id', 11, 1)
end

/*============================================================
 * See if the group family is valid
 *============================================================*/  

if not exists (
  select top 1 
    numOf = 1 
  from dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as scn
  where scn.GROUP_SERVICE_CLASS_NAME_ID = @groupSvcClassNameID
)
begin
  RAISERROR ('Invalid practitioner discipline group family', 11, 1)
end

/*============================================================
 * Lookup goal type
 *============================================================*/  

select top 1 
      @goalTypeRecID       = isnull(pgt.id,0)
    , @measureValueMin     = pgt.measureValueMin
	, @measureValueMax     = pgt.measureValueMax    
from dbo.PATIENT_GOAL_TYPES as pgt
where 
  (pgt.id = @goalTypeID)

/*============================================================
 * If its not found get out
 *============================================================*/  

if @goalTypeRecID = 0
begin
  RAISERROR ('Invalid goal type', 11, 1)
end

if (@baseLineValue != 0)
begin
  set @baseLineValueAsDcml = convert(decimal(38,4),@baseLineValue)
  if (@baseLineValueAsDcml not between @measureValueMin and @measureValueMax)
  begin
    RAISERROR ('Baseline value is invalid', 11, 1)
  end
end

/*============================================================
 * Check to see if user can edit
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  set @recordID = 0 

  select top 1 
      @recordID        = isnull(pg.id,0)
	, @savedGoalTypeID = pgt.id
	, @userDefinedGoal = pgt.userDefinedGoal
  from dbo.PATIENT_GOALS      as pg
  join dbo.PATIENT_GOAL_TYPES as pgt on pgt.id = pg.goalTypeID
  where (
	      (pg.id       = @recID)
	  and (pg.clientID = @clientID) 
	  and (pg.active   = 1)
  )

  if (@recordID = 0)
  begin
    RAISERROR ('Goal not found', 11, 1)
  end
  
  set @okToEditUserDefinedGoalTypeID = 0
  
  if (@userDefinedGoal = 1)
  begin
    if (@savedGoalTypeID != @goalTypeID)
    begin
	  /* Has any goal progress been saved */
	  if exists (
        select top 1 pgp.id 
        from dbo.PATIENT_GOALS_PROGRESS as pgp
        where (
              ((pgp.goalID = @recordID) and (pgp.measuredOn is not null) and (pgp.id is not null))
          and (pgp.active = 1)
        )
      )
	  /* Goal progress has been saved so its not ok to change the type*/
	  begin
	    set @okToEditUserDefinedGoalTypeID = 0
	  end /* Goal progress has been saved*/
	  else
	  /* Goal progress has not been saved so the type can be changed */
	  begin
	    set @okToEditUserDefinedGoalTypeID = 1	 
	  end /* No goal progress has been saved*/
    end
  end /* Is user defined goal */
  else
  begin
    set @okToEditUserDefinedGoalTypeID = 0
  end /* Is not user defined goal*/
end /* isEdit */

/*============================================================
 * Duplicate check
 *===========================================================*/   

if exists (
  select top 1 
    pg.id
  from dbo.PATIENT_GOALS as pg
  where (
    (pg.clientID = @clientID)
  and (pg.patID = @patID)
  and (pg.groupSvcClassNameID = @groupSvcClassNameID)
  and (pg.name   = @name)  
  and (pg.active = 1)
  and (pg.startDate = @startDate)
  and (pg.endDate   = @endDate)
  and (pg.goalMet   = @goalMet)
  and ((@recID is null) or (pg.id != @recID)) /* Skips record being edited*/
  )
)
begin
  RAISERROR (@MsgDupRec, 11, 1)
end

/*============================================================
 * Start and end date validations
 *===========================================================*/

if (@startDate is null)
begin
 
  select top 1
    @startDate = coalesce( svcDates.svcCurrStartDate
                          , pap.spEdLastAnnualIEPDate
	                      , pap.spEdLastEvalDate
                          , pap.spEdNextAnnualIEPDate
	                      , @today )
  
   from dbo.PATIENTS_Patient as pap 

   outer apply (
     select top 1     
        svcCurrStartDate = pps.startDate	  
     from dbo.PATIENTS_PROMISED_SERVICES                 as pps  
     join dbo.SpEd_Service_Xref_Group_Service_Class_Name as cscn on cscn.spEdServiceCodeValue = pps.spEdServiceCode
     where (
           (pps.patID = pap.PATIENT_ID)
	   and (cscn.active = 1)
	   and (cscn.groupServiceClassNameID = @groupSvcClassNameID)
       and (pps.active = 1)
	   and (cscn.active = 1)
     )
     order by 
       pps.startDate desc
    ) as svcDates  
    where 
      (pap.PATIENT_ID = @patID) 
 end /* Start date */

 if (@endDate is null)
 begin
	set @endDate = dateadd(year, 1, @startDate)
 end

 /* NOTE: at this point, neither start nor end date should be null */ 

 if (@startDate >= @endDate)
 begin
 	RAISERROR ('End date cannot be before or the same as the start date',   11, 1)
 end


/*============================================================
 * Validation Exit
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END        

BEGIN TRANSACTION
SET @TranOpen = 1
  
if (@saveType = dbo.CONST_SAVE_TYPE_NEW())

/*============================================================
 * Create new
 *===========================================================*/   

begin
  
  insert into dbo.PATIENT_GOALS (  
      clientID
    , groupSvcClassNameID
	, patID
	, [name]
	, goalTypeID
	, baseLineValue
	, startDate
	, endDate
	, goalMet

	, goalMetOn
    , backgroundText
    , notes
    , hasObjectives

    , hasObjective1
    , objective1Text
    , objective1Met
    , objective1MetOn

    , hasObjective2
    , objective2Text
    , objective2Met
    , objective2MetOn

    , hasObjective3
    , objective3Text
    , objective3Met
    , objective3MetOn
    , created 
    , createdBy
    , active     
  ) 
  values (
      @clientID
	, @groupSvcClassNameID
	, @patID
	, @name
	, @goalTypeID
	, @baseLineValue
	, @startDate
	, @endDate
	, @goalMet

	, @goalMetOn
    , @backgroundText
    , @notes
    , @hasObjectives

    , @hasObjective1
    , @objective1Text
    , @objective1Met
    , @objective1MetOn

    , @hasObjective2
    , @objective2Text
    , @objective2Met
    , @objective2MetOn

    , @hasObjective3
    , @objective3Text
    , @objective3Met
    , @objective3MetOn
    , @today
    , @userID
	, 1    
  )
  
  set @recordID = SCOPE_IDENTITY()

end

/*============================================================
 * Edit existing
 *===========================================================*/   

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  
  /* If this is a user defined goal */
  if (@userDefinedGoal = 1)
  begin
    update dbo.PATIENT_GOALS
    set        
	    groupSvcClassNameID = @groupSvcClassNameID
	  , name                = @name
	  
	  , goalTypeID          = iif ( (@okToEditUserDefinedGoalTypeID = 1)
	                               , @goalTypeID
								   , @savedGoalTypeID )

	  , baseLineValue       = @baseLineValue
	  , startDate           = @startDate
	  , endDate             = @endDate
	  , goalMet             = @goalMet

	  , goalMetOn			= @goalMetOn
	  , backgroundText		= @backgroundText
	  , notes				= @notes
	  , hasObjectives		= @hasObjectives

	  , hasObjective1		= @hasObjective1
	  , objective1Text		= @objective1Text
	  , objective1Met		= @objective1Met
	  , objective1MetOn		= @objective1MetOn

	  , hasObjective2		= @hasObjective2
	  , objective2Text		= @objective2Text
	  , objective2Met		= @objective2Met
	  , objective2MetOn		= @objective2MetOn

	  , hasObjective3		= @hasObjective3
	  , objective3Text		= @objective3Text
	  , objective3Met		= @objective3Met
	  , objective3MetOn		= @objective3MetOn

      , lastModified        = @today
      , lastModifiedBy      = @userID
    where (id = @recordID)
  end
  
  /* If it is not a user defined goal then baseline, goal status,
	* background, notes and objective tracking values can be modified,
	* but nothing else */

  else
  begin
    update dbo.PATIENT_GOALS
    set        
	    baseLineValue       = @baseLineValue
	  , goalMet             = @goalMet

	  , goalMetOn           = @goalMetOn
	  , backgroundText      = @backgroundText
	  , notes               = @notes
	  , hasObjectives       = @hasObjectives

	  , hasObjective1       = @hasObjective1
	  , objective1Text      = @objective1Text
	  , objective1Met       = @objective1Met
	  , objective1MetOn     = @objective1MetOn

	  , hasObjective2       = @hasObjective2
	  , objective2Text      = @objective2Text
	  , objective2Met       = @objective2Met
	  , objective2MetOn     = @objective2MetOn

	  , hasObjective3       = @hasObjective3
	  , objective3Text      = @objective3Text
	  , objective3Met       = @objective3Met
	  , objective3MetOn     = @objective3MetOn

      , lastModified        = @today
      , lastModifiedBy      = @userID
    where (id = @recordID)
  end

  set @recordID = @recID

end

/*============================================================
 * All done, commit changes and get out
 *============================================================*/  
    
COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
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

GRANT EXECUTE ON  [dbo].[PATIENT_GOALS_SAVE] TO [webuser]
GO
