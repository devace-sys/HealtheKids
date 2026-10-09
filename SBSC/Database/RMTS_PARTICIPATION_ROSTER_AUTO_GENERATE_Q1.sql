USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPATION_ROSTER_AUTO_GENERATE_Q1') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_PARTICIPATION_ROSTER_AUTO_GENERATE_Q1
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[RMTS_PARTICIPATION_ROSTER_AUTO_GENERATE_Q1] (
    @refDate datetime
)    
AS    
BEGIN            
 
SET NOCOUNT ON    
 
DECLARE @clientsWithQ4Data as table (
	idx         BIGINT primary key identity(1,1) not null,
    clientID    BIGINT,
	Q4RosterID	BIGINT
)


DECLARE @TranOpen AS BIT  
DECLARE @curQ1ID  AS BIGINT
DECLARE @prevQ4ID AS BIGINT

-- loop variables
declare @curIdx as bigint = 1
declare @maxIdx as bigint = 0


IF (@refDate is null)
BEGIN
	SET @refDate = getdate()
END


BEGIN TRY     
BEGIN TRANSACTION

/*-------------------------------    
 * get the current and previous
 * fiscal years & quarters
 * with respect to @refDate  
 *------------------------------*/ 

select top 1
	@curQ1ID = cfq.ID
from dbo.COMPANY_FISCAL_YEARS as cfy
join dbo.COMPANY_FISCAL_QUARTERS  as cfq on cfq.FY_ID = cfy.ID and cfq.QTR = 1
where ((Convert(Date, @refDate) between cfy.FY_START and cfy.FY_END))


select top 1
	@prevQ4ID = cfq.ID
from dbo.COMPANY_FISCAL_YEARS as cfy
join dbo.COMPANY_FISCAL_QUARTERS  as cfq on cfq.FY_ID = cfy.id and cfq.QTR = 4
where ((Convert(Date, DATEADD(year,-1,@refDate)) between cfy.FY_START and cfy.FY_END))


/*-------------------------------    
 * get active lea clients who had
 * Q4 data but don't have Q1 data
 *------------------------------*/ 

insert into @clientsWithQ4Data (clientID, Q4RosterID)
select 
	  rprQ4.clientID
	, rprQ4.id
from dbo.RMTS_PARTICIPATION_ROSTER as rprQ4
join dbo.CLIENTS_Client_Active_LEA as cc on cc.CLIENT_ID = rprQ4.clientID
left join dbo.RMTS_PARTICIPATION_ROSTER as rprQ1 on rprQ1.clientID = rprQ4.clientID and rprQ1.quarterID = @curQ1ID and rprQ1.active = 1
where ((1 = 1)
  and (rprQ4.quarterID = @prevQ4ID)
  and (rprQ4.active = 1)
  and (rprQ1.id is null)
)

/*-------------------------------    
 * create Q1 rosters for selected clients
 *------------------------------*/ 
select @maxIdx = max(idx) from @clientsWithQ4Data

while (@curIdx <= @maxIdx)
BEGIN

	Declare @processingClientID bigint
		  , @processingParticipantRosterJSON as varchar(max)
		  , @processingParticipantRosterChangesJSON as varchar(max)
		  , @processingSaveType as bit

	Select
		
		  @processingClientID                     = cwqd.clientID
		, @processingParticipantRosterJSON        = rpr.participantRosterJSON
		, @processingParticipantRosterChangesJSON = rpr.participantRosterChangesJSON
		, @processingSaveType                     = (dbo.CONST_SAVE_TYPE_NEW())

	from @clientsWithQ4Data as cwqd
	join dbo.RMTS_PARTICIPATION_ROSTER as rpr on rpr.id = cwqd.Q4RosterID
	where ((1=1)
	  and (cwqd.idx = @curIdx)
	)

	exec dbo.RMTS_PARTICIPATION_ROSTER_SAVE
		-1 -- @userID                           
	  , -1 -- @userGroup                        
	  , -1 -- @userRank                         
	  , @processingClientID -- @clientID                         
	  , @curQ1ID -- @fyQuarterID                      
	  , @processingParticipantRosterJSON -- @participantRosterJSON            
	  , @processingParticipantRosterChangesJSON -- @participantRosterChangesJSON     
	  , ''   -- @editDelReason         
	  , 0    -- @validateRec           
	  , @processingSaveType -- @saveType              
	  , null -- @recID                 
	  , null -- @MsgNoRec              
	  , null -- @MsgNoEdit             
	  , null -- @MsgDupRec             
	  , null -- @MsgDataError          
	  , null -- @MsgNotActive          
	  , null -- @recordID              
	  , null -- @spDetails             
  
	set @curIdx = @curIdx + 1

END

/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
 
COMMIT TRANSACTION    
SET @TranOpen = 0    
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
 
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
 
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
 
GRANT EXECUTE ON  [dbo].[RMTS_PARTICIPATION_ROSTER_AUTO_GENERATE_Q1] TO [webuser]
GO