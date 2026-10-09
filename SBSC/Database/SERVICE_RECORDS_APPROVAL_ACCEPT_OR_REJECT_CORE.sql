USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_CORE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 

CREATE PROCEDURE dbo.SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_CORE
( @userID             BIGINT,    
  @userGroup          INT,    
  @userRank           INT,    
  @editDelReason      VARCHAR(7000),    
  @validateRec        BIT,
  @clientID           BIGINT,
  @recID              BIGINT, 
  @approved           BIT,
  @today              DATETIME,
  @MsgNoRec           VARCHAR(1000),    
  @MsgNoEdit          VARCHAR(1000),
  @svcRecID           BIGINT        OUTPUT,    
  @journalID          BIGINT        OUTPUT,
  @spDetails          VARCHAR(8000) OUTPUT,    
  @recordID           BIGINT        OUTPUT)   

AS
BEGIN

/***************************************************************************    
 * SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_CORE */ 
/**    
 * Marks service as accepted or rejected
 *
 * Note: No validation is performed on required values.  Caller must validate.
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 ***************************************************************************/     

SET NOCOUNT ON    
   
declare @createdByNameRefID     as bigint       = null
declare @createdByUserID        as bigint       = null
declare @active                 as bit          = null
DECLARE @reviewedByName         as varchar(500) = null
DECLARE @reviewedByTitle        as varchar(500) = null
DECLARE @reviewedByNameRefID    as bigint       = null
DECLARE @reviewedByTitleRefID   as bigint       = null
declare @patID                  as bigint       = null
declare @pracID                 as bigint       = null

BEGIN TRY    

/*============================================================
 * Init
 *============================================================*/     
   
SET @recordID    = 0    
SET @spDetails   = ''    

/*============================================================
 * Look for service record approval record
 *============================================================*/  

set @svcRecID = null

select top 1
 
    @svcRecID            = svcRecID
  , @createdByUserID     = svcRecCreatedByUserID
  , @createdByNameRefID  = svcRecCreatedByNameRefID
  , @active              = active
from dbo.SERVICE_RECORDS_APPROVAL as sra
where 
      sra.clientID = @clientID 
  and sra.id       = @recID

/*============================================================
 * If it is not found, get out
 *============================================================*/  

IF (@svcRecID IS NULL) 
  RAISERROR (@MsgNoRec, 11, 1)    

/*============================================================
 * If it is not active get out
 *============================================================*/  

IF (@active = 0)
  RAISERROR (@MsgNoEdit, 11, 1)    

/*============================================================
 * Get service record data
 *============================================================*/  

set @pracID = null
set @patID  = null

select top 1 
   @pracID = pracID
  ,@patID  = patID 
from dbo.SERVICE_RECORDS as sr 
where (sr.id = @svcRecID) and (sr.clientID = @clientID)

/*============================================================
 * See if the service record is associated with a journal
 *============================================================*/  

set @journalID = null

select top 1  
  @journalID = journalID
from dbo.SvcJournal_Related_Svc_Records_Data_Core (
    @userID            
  , @userGroup
  , @userRank
  , null
  , null
  , @svcRecID
  , null
)

/*============================================================
 * If the user is a client retrieve info about who is 
 * reviewing the service and see if they can review the service
 *============================================================*/  

if (@userGroup = dbo.CONST_USER_GROUP_CLIENT())
begin

  /*============================================================
   * Get info about reviewer
   *============================================================*/  
  
  set @reviewedByNameRefID = null
  
  select top 1
  
    @reviewedByName             = pp.CONCAT_NAME
  , @reviewedByNameRefID        = pp.PRACTITIONER_ID
  , @reviewedByTitle            = gg.GROUP_NAME
  , @reviewedByTitleRefID       = gg.GROUP_ID

  from dbo.PRACTITIONER_Practitioner as pp 
  join dbo.PRACTITIONER_GROUPS       as pg on pg.PRACTITIONER_ID = pp.PRACTITIONER_ID
  join dbo.GROUP_Group               as gg on gg.GROUP_ID        = pg.GROUP_ID
  where 
        pp.UserID = @userID
    and gg.GROUP_TYPE in (1,2)

  /*============================================================
   * If reviewer not found get out
   *============================================================*/  
  
  if (@reviewedByNameRefID is null)
    RAISERROR ('Reviewer not found', 11, 1)

  /*============================================================
   * If reviewer is found make sure they are qualified to review
   * the record.
   *============================================================*/  
  
  declare @supervisedPracID as bigint = null

  select top 1 
    @supervisedPracID = PRACTITIONER_ID 
  from dbo.PRACTITIONERS_SUPERVISED_BY_GROUP_ID_VIEW (@clientID, @reviewedByTitleRefID)
  where 
    (PRACTITIONER_ID = @createdByNameRefID)

  /*============================================================
   * If not get out
   *============================================================*/  

  if (@supervisedPracID  is null)
    RAISERROR ('You are not qualified to review this record', 11, 1)

end

/*============================================================
 * Other user groups exit
 *============================================================*/  

else
begin
  RETURN (0)
end

/*============================================================
 * If we are validating get out
 *============================================================*/  

if (@validateRec = 1) RETURN(0)    

/*============================================================
 * Otherwise update approval record with data
 *============================================================*/  
  
update dbo.SERVICE_RECORDS_APPROVAL 
set 
  reviewed             = 1, 
  reviewedOn           = @today, 
  reviewedByUserGroup  = @userGroup, 
  reviewedByUserID     = @userID, 
  reviewedByName       = @reviewedByName,
  reviewedByNameRefID  = @reviewedByNameRefID,
  reviewedByTitle      = @reviewedByTitle,
  reviewedByTitleRefID = @reviewedByTitleRefID,
  approved             = @approved,
  reviewNotes          = @editDelReason
where 
  ((id = @recID) and (clientID = @clientID) and (active = 1))

SET @recordID = @recID

/*============================================================
 * If the service record is not approved
 *============================================================*/  

if (@approved = 0)
begin
    
  /*============================================================
   * If the service record is associated with a journal 
   * reopen the journal
   *============================================================*/  

  if (@journalID is not null)
  begin
    
    declare @saveType as int = dbo.CONST_SAVE_TYPE_NEW()

    exec dbo.SVCJOURNAL_JOURNAL_REOPEN_CORE

        @userID        
      , @userGroup    
      , @userRank     
      , @clientID     
      , @pracID       
      , @patID        
      , ''    
      , @editDelReason
      , @validateRec 
      , @saveType        
      , @journalID        
      , @MsgNoRec          
      , @MsgNoEdit         
      ,''        
      ,''
      ,''
      ,''
      ,''
      ,''
      ,''
      ,''
      ,''
      ,''
      ,''
      ,@spDetails OUTPUT 
      ,@recordID  OUTPUT       
  end
 
end

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
   
  --SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_CORE] TO [webuser]
GO

