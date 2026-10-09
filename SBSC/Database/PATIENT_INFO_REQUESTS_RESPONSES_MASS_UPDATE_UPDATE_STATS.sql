USE SPEDMON
GO

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_UPDATE_STATS') 
      AND type IN (N'P', N'PC')
)
begin
  DROP PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_UPDATE_STATS
end
GO

CREATE PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_UPDATE_STATS (
      @userID             BIGINT
    , @userGroup          INT
    , @userRank           INT
	, @clientID           bigint
	, @editDelReason	  VARCHAR(7000)
    , @validateRec        BIT
	, @saveType           SMALLINT  
    , @recID              BIGINT
    , @MsgNoRec           VARCHAR(1000)
    , @MsgDupRec          VARCHAR(1000)
    , @MsgNoEdit          VARCHAR(1000)
    , @MsgNotActive       VARCHAR(1000)
    , @MsgDataError       VARCHAR(1000)
    , @spDetails          VARCHAR(8000) OUTPUT
    , @recordID           BIGINT        OUTPUT
)
AS
BEGIN
   
set nocount on

declare @tranOpen                  as bit     
declare @today                     as datetime
declare @numOfPats                 as int
declare @numOfPatsProcessed        as int
declare @numOfPatPersons           as int
declare @massUpdateCreatedByUserID as bigint

/*============================================================
 * Init
 *============================================================*/
     
set @recordID           = 0
set @spDetails          = ''
set @tranOpen           = 0
set @today              = getdate()
set @numOfPats          = 0
set @numOfPatsProcessed = 0

BEGIN TRY

/*============================================================
 * Get campaign (ifs its active and not complete)
 *============================================================*/

select 
    @recordID                  = isnull(mu.id,0)
  , @numOfPats                 = mu.numOfPats
  , @numOfPatPersons           = mu.numOfPatPers
  , @massUpdateCreatedByUserID = mu.createdBy
  
from dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES as mu
where ( 
      (mu.clientID  = @clientID)
  and (mu.id        = @recID)
  and (mu.completed = 0)
  and (mu.active    = 1)
)

/*============================================================
 * If its not found exit silently
 *============================================================*/

if (@recordID = 0) return 0

/*============================================================
 * Determine how many rows have been processed so far
 *============================================================*/

select 
  @numOfPatsProcessed = count(mur1.id)
from dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS as mur1
where (
      (mur1.pirrMassUpdateID = @recordID)
  and (mur1.processed = 1)
)
group by 
  mur1.pirrMassUpdateID

/*============================================================
 * If rows proc equals rows expected then flag
 * campaign distribution as complete
 *============================================================*/

if (@numOfPatsProcessed = @numOfPats)
begin
  begin transaction
    set @tranOpen = 1

	update dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES
    set 
	    completed      = 1
	  , completedOn    = @today
	  , lastModified   = @today
	  , lastModifiedBy = @userID
    where 
      (id = @recordID)
  
  commit transaction
  set @tranOpen = 0

 /*============================================================
  * Send message to user who created request letting them know
  * that the email distribution is complete
  *============================================================*/
 
 declare @msgForUserIdStr as varchar(max) = ''
 declare @msgBody         as varchar(max)  = ''
 declare @msgSpDetails    as varchar(8000) = ''
 declare @msgID           as bigint        = 0

 set @msgForUserIdStr = convert(varchar(1000),@massUpdateCreatedByUserID)

 set @msgBody = 'Requests for ' 
              + convert(varchar(256),@numOfPats) 
			  + ' students have been emailed to their parent/guardians.'

 exec users.dbo.USERS_MESSAGES_SAVE_GENERATED
     0
   , 0
   , 0
   , 'spedcare'
   , @msgForUserIdStr
   , 'Students With Missing Information - Bulk Request For Information Completed'
   , @msgBody
   , 1     /* Send email */
   , null  /* @respPromptOptionsBitwise*/
   , null  /* @respPromptOptionsJSON*/
   , 0     /* @promptUserToGotoURL */
   , ''    /* @goto url*/
   , null  /* @gotoURLAdditionalParams */
   , 1     /* save type*/
   , 0     /* Rec id */
   , @msgSpDetails output
   , @msgID        output

end

/*============================================================
 * Done
 *============================================================*/

RETURN(0)

END TRY
BEGIN CATCH

/*-------------------------------
 * If we end up here something went 
 * wrong. Cancel any pending 
 * transactions and return any error
 * messages to the caller
 *------------------------------*/
 
IF @tranOpen = 1 ROLLBACK TRANSACTION
		
DECLARE @ErrorMessage  NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState    INT

SELECT  @ErrorMessage  = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState    = ERROR_STATE()

RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
END
GO

GRANT EXECUTE ON dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_UPDATE_STATS TO webuser
GO

