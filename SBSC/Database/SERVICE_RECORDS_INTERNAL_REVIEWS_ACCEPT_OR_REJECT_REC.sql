USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_INTERNAL_REVIEWS_ACCEPT_OR_REJECT_REC') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORDS_INTERNAL_REVIEWS_ACCEPT_OR_REJECT_REC
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 

CREATE PROCEDURE dbo.SERVICE_RECORDS_INTERNAL_REVIEWS_ACCEPT_OR_REJECT_REC( 
    @userID                     bigint
  , @userGroup                  int  
  , @userRank                   int
  , @clientID                   bigint
  , @reviewingPracID            bigint
  , @recID                      bigint
  , @approved                   bit
  , @notes                      varchar(max)
  , @sendMessageToRenderingPrac bit
  , @editDelReason              varchar(8000)
  , @validateRec                bit 
  , @MsgNoRec                   varchar(1000)
  , @MsgNoEdit                  varchar(1000)    
  , @spDetails                  varchar(8000) output
  , @recordID                   bigint        output )   

AS
BEGIN

/***************************************************************************    
 * SERVICE_RECORDS_INTERNAL_REVIEWS_ACCEPT_OR_REJECT_REC */ 
/**    
 ***************************************************************************/     

/*============================================================
 * Init
 *============================================================*/     

set nocount on

set @recordID  = 0    
set @spDetails = ''    
set @notes     = trim(isnull(@notes,''))

declare @tranOpen               as bit         = 0
declare @today                  as datetime    = getdate()
declare @reviewingPracFound     as bit         = 0
declare @reviewingPracUserID    as bigint      = -1
declare @reviewingPracUserGroup as int         = -1
declare @reviewingPracUserRank  as int         = -1
declare @reviewingPracName      as varchar(50) = ''
declare @reviewingPracTitle     as varchar(50) = ''

declare @renderingPracID        as bigint      = -1
declare @renderingPracUserID    as bigint      = -1
declare @svcRecId               as bigint      = -1

BEGIN TRY    

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
if (@userID          is null) raiserror ('userID is required',             11, 1)
if (@userGroup       is null) raiserror ('userGroup is required',          11, 1)    
if (@userRank        is null) raiserror ('userRank is required',           11, 1)    
if (@clientID        is null) raiserror ('Client id is required',          11, 1)
if (@reviewingPracID is null) raiserror ('Reviewing prac id is required',  11, 1)
if (@approved        is null) raiserror ('Approved flag is required',      11, 1)
if (@validateRec     is null) raiserror ('Validate flag required',         11, 1)    
if (@recID           is null) raiserror ('Rec id required',                11, 1)    

/*============================================================
 * Verify reviewing prac
 *============================================================*/  

set @reviewingPracUserID = -1
set @reviewingPracFound  = 0

select top 1

    @reviewingPracFound  = 1
  , @reviewingPracUserID = isnull(prp.UserID,-1)
  , @reviewingPracName   = left(trim(prp.CONCAT_NAME),500)
  , @reviewingPracTitle  = left(trim(ggd.GROUP_NAME),500)

from dbo.PRACTITIONER_Practitioner as prp
join dbo.PRACTITIONER_Client       as prc on prc.PRACTITIONER_ID = prp.PRACTITIONER_ID
join dbo.PRACTITIONER_GROUPS       as pgd on  ((pgd.PRACTITIONER_ID = prp.PRACTITIONER_ID) 
                                          and (pgd.GROUP_TYPE in (1,2)) 
										  and (pgd.ACTIVE = 1))
join dbo.GROUP_Group               as ggd on ggd.GROUP_ID = pgd.GROUP_ID
where (
      ((prp.PRACTITIONER_ID = @reviewingPracID))
  and (prp.ACTIVE = 1)
  and (prc.CLIENT_ID = @clientID)
)

/*============================================================
 * Not found exit
 *============================================================*/  

if (@reviewingPracFound = 0)
begin
  raiserror ('Reviewing practitioner not found', 11, 1)   
end

if (@reviewingPracUserID = -1)
begin
  raiserror ('Reviewing practitioner must have an active SpEdCare user account', 11, 1)   
end

/*============================================================
 * Get reviewing prac user info
 *============================================================*/  

set @reviewingPracFound = 0

select top 1 
    @reviewingPracFound     = 1
  , @reviewingPracUserGroup = t1.userGroupID 
  , @reviewingPracUserRank  = t1.userGroupRank
from users.dbo.USERS_ALL as t1
where 
  (t1.userIDInt = @reviewingPracUserID)

/*============================================================
 * Not found exit
 *============================================================*/  

if (@reviewingPracFound = 0)
begin
  raiserror ('Reviewing practitioner must have an active SpEdCare user account', 11, 1)  
end

/*============================================================
 * Verify review record
 *============================================================*/  

set @recordID = 0


select top 1 

    @recordID            = isnull(t1.id,               0)
  , @renderingPracID     = isnull(t1.renderingPracID, -1)
  , @renderingPracUserID = isnull(t1.createdBy,       -1)
  , @svcRecID            = isnull(t1.svcRecID,        -1)
    
from dbo.SERVICE_RECORDS_INTERNAL_REVIEWS as t1
join dbo.SERVICE_RECORDS                  as t2 on t2.id = t1.svcRecID
where 
    ((t1.id = @recID))
and (
      (t1.clientID         = @clientID)
  and (t1.assignedToPracID = @reviewingPracID)
  and (t1.active           = 1)
)

/*============================================================
 * Not found exit
 *============================================================*/  

if (@recordID = 0)
begin
  raiserror ('Review record not found', 11, 1) 
end

/*============================================================
 * If we are validating exit
 *============================================================*/  

if (@validateRec = 1)
begin
  return
end

/*============================================================
 * Save the review data
 *============================================================*/  

set @tranOpen = 1
begin transaction

  update dbo.SERVICE_RECORDS_INTERNAL_REVIEWS
  set 
      reviewed         = 1
    , reviewedByPracID = @reviewingPracID
    , reviewedByName   = @reviewingPracName
	, reviewedByTitle  = @reviewingPracTitle
	, reviewedOn       = @today
    , approved         = @approved
    , notes            = @notes
    , lastModified     = @today
    , lastModifiedBy   = @userID

  where (id = @recordID)

commit transaction
set @tranOpen = 0

/*============================================================
 * Send message if applicable
 *============================================================*/  

if (@sendMessageToRenderingPrac = 1)
begin

  declare @spDetailsSaveMsg       as varchar(8000) = ''
  declare @msgID                  as bigint        = 0
  declare @renderingPracUserIDStr as varchar(256)  = convert(varchar(256),@renderingPracUserID)
  declare @msgTitle               as varchar(256)  = 'Internal Service Record Review - ' 
  declare @msgBody                as varchar(max)  = 'Review Notes : ' + @notes
  declare @gotoUrl                as varchar(256)  = 'user_all_service_records_manage.aspx'
  declare @gotoUrlParms           as varchar(140)  = 'recid=' + convert(varchar(50),@svcRecID)

  if (@approved = 1) 
  begin
    set @msgTitle = @msgTitle + 'Approved With Notes'
  end
  else
  begin
    set @msgTitle = @msgTitle + 'Returned For Correction'
  end

  set @msgBody = 'Please click on the finger pointer to access the service record that was reviewed.' 
               + '<br><br>'
			   + 'Review Notes :'
			   + '<br><br>'
			   + @notes

  /*============================================================
   * Send message
   *============================================================*/  
  
  exec users.dbo.USERS_MESSAGES_SAVE_SIMPLE_W_NAV 
      @reviewingPracUserID      
    , @reviewingPracUserGroup
    , @reviewingPracUserRank
    , 'spedcare'
    , @renderingPracUserIDStr
    , @msgTitle
    , @msgBody
    , 0    /*@sendEmail                */
    , null /*@respPromptOptionsBitwise */
    , null /*@respPromptOptionsJSON    */
    , 1             /*@promptUserToGotoURL      */
    , @gotoUrl      /*@gotoURL*/
    , @gotoUrlParms /*@gotoURLAdditionalParams */
    , 1  /* Save type */
	, 0  /* Rec ID */
	, @spDetailsSaveMsg output
    , @msgID            output
   
end

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
   
  -- Error or raise error with severity 11 to 19 will be caught here    
   
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
   
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  --SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_RECORDS_INTERNAL_REVIEWS_ACCEPT_OR_REJECT_REC] TO [webuser]
GO

