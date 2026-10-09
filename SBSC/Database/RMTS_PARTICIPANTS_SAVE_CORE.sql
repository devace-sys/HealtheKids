USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPANTS_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_PARTICIPANTS_SAVE_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[RMTS_PARTICIPANTS_SAVE_CORE] (
    @userID                       Bigint
  , @userGroup                    Int
  , @userRank                     Int 
  , @clientID                     Bigint 
  , @pracID                       Bigint
  , @rosterID					  Bigint
  , @startDate					  DateTime
  ,	@endDate					  DateTime
  , @reasonForStartDateChangeCode bigint
  , @reasonForEndDateChangeCode   bigint
  , @hasServiceRecords			  bit
  , @hasReimbursement             bit
  , @employeeRelationshipID       bigint -- if null, nothing will happen. value is only used if passed
  , @editDelReason                Varchar(7000)    
  , @validateRec                  Bit     -- this parameter is actually used so, see references to it in this file before using this SPROC
  , @saveType                     Int    
  , @recID                        Int    
  , @MsgNoRec                     Varchar(1000)    
  , @MsgNoEdit                    Varchar(1000) 
  , @MsgDupRec                    Varchar(1000)     
  , @MsgDataError                 Varchar(1000)
  , @MsgNotActive                 Varchar(1000)     
  , @spDetails                    Varchar(8000) OUTPUT   
  , @recordID                     BigInt        OUTPUT)    
AS    
BEGIN            
 
SET NOCOUNT ON    
 
DECLARE @today               as DATETIME = GETDATE()
DECLARE @fyQuarterID		 as BIGINT
DECLARE @quarterStartDate    as Datetime
DECLARE @quarterEndDate      as Datetime

/*-------------------------------    
 * Init 
 *------------------------------*/    
 
SET @spDetails  = ''    
SET @recordID   = 0 
SET @today      = GETDATE()

BEGIN TRY    
 

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
 
IF (@userID					 IS NULL) RAISERROR ('userID is required',           11, 1)      
IF (@userGroup				 IS NULL) RAISERROR ('userGroup is required',        11, 1)    
IF (@userRank				 IS NULL) RAISERROR ('userRank is required',         11, 1)    
IF (@validateRec			 IS NULL) RAISERROR ('Validate flag required',       11, 1) 
IF (@clientID				 IS NULL) RAISERROR ('Invalid Client ID',            11, 1)    
IF (@pracID					 IS NULL) RAISERROR ('Prac ID required',             11, 1)
IF (@saveType				 IS NULL) RAISERROR ('Save type is required',        11, 1)  
IF (@rosterID     			 IS NULL) RAISERROR ('Roster selection is required', 11, 1)   


/*-------------------------------    
 * Validate prac and client
 *------------------------------*/    

IF not exists (
	select top 1 
		  clc.CLIENT_ID
		, prp.PRACTITIONER_ID 
	from dbo.CLIENTS_CLIENT            as clc
	join dbo.PRACTITIONER_Client       as prc on prc.CLIENT_ID       = clc.CLIENT_ID
	join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
	where ( 
		  (clc.CLIENT_ID       = @clientID)
	  and (prp.PRACTITIONER_ID = @pracID)
	)
)
begin
	RAISERROR('Invalid client or practitioner ID', 11, 1)
end


/*-------------------------------    
 * Make sure roster exists
 *------------------------------*/    

select top 1 
  @fyQuarterID = t1.quarterID 
from dbo.RMTS_PARTICIPATION_ROSTER as t1 
where ( 
  (t1.id = @rosterID) and (t1.active = 1)
)

if (isnull(@fyQuarterID, 0) = 0)
begin
	RAISERROR('Selected roster does not exist', 11, 1)
end

/*-------------------------------    
 * Enforce start and end date
 * between quarter start and end
 *------------------------------*/    

select top 1
	@quarterStartDate = fyq.QTR_START
  , @quarterEndDate   = fyq.QTR_END
from dbo.COMPANY_FISCAL_QUARTERS as fyq
where (fyq.ID = @fyQuarterID)

if (
	(@startDate not between @quarterStartDate and @quarterEndDate)
 or (@endDate   not between @quarterStartDate and @quarterEndDate)
)
begin
	RAISERROR('Start and end dates must be within the quarter', 11, 1)
end

/*-------------------------------    
 * If start date is after end date
 * exit
 *------------------------------*/    

if (@startDate > @endDate)
begin
	RAISERROR('Start date cannot be after end date', 11, 1)
end

/*-------------------------------    
 * If relationship id is passed
 * verify it
 *------------------------------*/    

if (@employeeRelationshipID is not null)
begin
  if (@employeeRelationshipID not in (
    select top 1 er.[TYPE_ID] from dbo.EMPLOYMENT_RELATIONSHIPS as er where (er.TYPE_ID = @employeeRelationshipID))
  ) 
  RAISERROR('Invalid Employee relationship id', 11, 1)
end

/*-------------------------------    
 * Check if practitioner is on
 * roster already
 *------------------------------*/    

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin
	
  if exists (select top 1 t1.pracID from dbo.RMTS_PARTICIPANTS as t1 where t1.rosterID = @rosterID and t1.pracID = @pracID)
  begin
    declare @alreadyOnRosterErr varchar(100) = 'Selected practitioner is already on the roster' ;
	SET @alreadyOnRosterErr = @alreadyOnRosterErr + ', prac #'
        + CAST( @pracID AS VARCHAR(MAX))
    RAISERROR( @alreadyOnRosterErr , 11, 1)
  end
end
else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin	
    if (isnull(@recID, 0) = 0) RAISERROR(@MsgNoRec, 11, 1)
	
	declare @pracHasChanged            as bit = 0
	declare @prevHasServiceRecordsFlag as bit = 0

	select 
		@pracHasChanged            = convert(bit, iif(t1.pracID = @pracID, 0, 1))
	  , @prevHasServiceRecordsFlag = t1.hasServiceRecords
	from dbo.RMTS_PARTICIPANTS as t1
	where 
	  (id = @recID)

	if (@pracHasChanged = 1) 
	  RAISERROR('Cannot change practitioner', 11, 1)
	 
	if ((@hasServiceRecords = 0) and (@prevHasServiceRecordsFlag = 1)) 
      RAISERROR('Cannot change "Has Service Records" from "Yes" to "No"', 11, 1)

end

/* 
 * Note: The functionality of validate rec is not standard in this sproc
 * The validate rec block is not returning as validateRec has been repurposed in this routine to toggle 
 * an extra set of checks on or off
 *
 */

if (@validateRec = 1)
begin
	if (convert(date, @startDate) >  convert(date, @quarterStartDate))
	begin
		if (isnull(@reasonForStartDateChangeCode, 0) = 0) RAISERROR ('Please select reason for start date change', 11, 1)
	end

	if (convert(date, @endDate) <  convert(date, @quarterEndDate))
	begin
		if (isnull(@reasonForEndDateChangeCode, 0) = 0) RAISERROR ('Please select reason for end date change', 11, 1)
	end
end       
 
/*============================================================
 * Write data
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

	-- insert prac into roster

	insert into dbo.RMTS_PARTICIPANTS (
		  rosterID
		, pracID
		, startDate
		, endDate
		, reasonForStartDateChangeCode
		, reasonForEndDateChangeCode
		, hasServiceRecords
		--, hasReimbursement
		, created
		, createdBy
	) values (
		  @rosterID
		, @pracID
		, @startDate
		, @endDate
		, @reasonForStartDateChangeCode
		, @reasonForEndDateChangeCode
		, @hasServiceRecords
		--, @hasReimbursement
		, @today
		, @userID
	)
	
	Set @recordID = SCOPE_IDENTITY()
	
  end

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin	

  	Update dbo.RMTS_PARTICIPANTS Set
		  startDate					   = @startDate
		, endDate		               = @endDate 
		, reasonForStartDateChangeCode = @reasonForStartDateChangeCode
		, reasonForEndDateChangeCode   = @reasonForEndDateChangeCode
		, hasServiceRecords            = @hasServiceRecords 
		--, hasReimbursement             = @hasReimbursement                
		, lastModified                 = @today                
		, lastModifiedBy			   = @userID
	Where (id = @recID)
	
	Set @recordID = @recID /* Was set to 1 */
  end
  else
  begin
     RAISERROR ('Unsupported save type', 11, 1)  
  end

  -- sync up json columns in roster table with the participants tables

  exec dbo.RMTS_SYNC_PARTICIPANTS_JSON_WITH_RELEVANT_TABLES_CORE @clientID, @rosterID

  insert into dbo.[RMTS_PARTICIPATION_ROSTER_REVISIONS] (
		[rosterID]
	  , [participantRosterJSON] 
	  , [participantRosterChangesJSON]
	  , [recordedOn]   
	  , [recordedBy] 
  )
  values (
  	  @rosterID
    , (select participantRosterJSON		   from dbo.RMTS_PARTICIPATION_ROSTER where id = @rosterID)
    , (select participantRosterChangesJSON from dbo.RMTS_PARTICIPATION_ROSTER where id = @rosterID)
    , @today
    , @userID
  )

  -- re-activate archived CRCS records that will now be valid entries
  -- this was due to DHCS changing their requirements

  if (@hasServiceRecords = 1)
  begin
	  update TOP (1) cps
		set cps.active = 1
	  from dbo.RMTS_PARTICIPATION_ROSTER as rpr
	  join dbo.COMPANY_FISCAL_QUARTERS   as fq on fq.ID = rpr.quarterID
	  join dbo.CRCS_PRAC_SALARIES	     as cps on cps.clientID      = @clientID
											   and cps.fiscalYearID  = fq.FY_ID
											   and cps.quarterNumber = fq.QTR
											   and cps.pracID        = @pracID
											   and cps.active        = 0
	  where (
		    rpr.id = @rosterID
		and not exists ( -- if an active record already exists, don't do anything
			select top 1 pracID
			from dbo.CRCS_PRAC_SALARIES as cps 
			where cps.clientID      = @clientID
			  and cps.fiscalYearID  = fq.FY_ID
			  and cps.quarterNumber = fq.QTR
			  and cps.pracID        = @pracID
			  and cps.active        = 1
		)
	  )
  end

  -- update practitioner employee relationship id in the actual prac table
  
  if (@employeeRelationshipID is not null)
  begin

	  update dbo.PRACTITIONER_Practitioner
	    set employeeRelationshipID = @employeeRelationshipID
	  where PRACTITIONER_ID = @pracID

	  declare @auditRecID as bigint = 0
	  declare @updateState as smallint = 0 
	  set @updateState = dbo.CONST_REC_STATE_MOD()
	  
	  EXEC dbo.PRACTITIONERS_Audit @pracID, @today, @userID, 2, @updateState, 'Changed employment relationship in RMTS roster', @auditRecID OUTPUT	   

  end

/*-------------------------------    
 * If we reach this point    
 * everything is OK    
 *------------------------------*/    
 
RETURN(0)    
END TRY    
BEGIN CATCH    
 
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Return any error 
   * messages to the caller    
   *------------------------------*/    
 
  -- Error or raise error with severity 11 to 19 will be caught here    
  
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
 
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
 
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
 
GRANT EXECUTE ON  [dbo].[RMTS_PARTICIPANTS_SAVE_CORE] TO [webuser]
GO