USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_APPROVAL_CREATE_NEW_FROM_SERVICE_RECORD') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORDS_APPROVAL_CREATE_NEW_FROM_SERVICE_RECORD
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE dbo.SERVICE_RECORDS_APPROVAL_CREATE_NEW_FROM_SERVICE_RECORD
(
  @userID          BIGINT,    
  @userGroup       INT,    
  @userRank        INT,
  @clientID        BIGINT,
  @recordClaim     BIT,
  @svcRecGroupID   BIGINT,  
  @svcRecID        BIGINT,     
  @entryType       INT,  
  @saveType        INT,    
  @validateRec     BIT
)

AS
BEGIN

/***************************************************************************    
 * SERVICE_RECORDS_APPROVAL_CREATE_NEW_FROM_SERVICE_RECORD */ 
/**    
 * Create a new service record approval record
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 *
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete  
 *  
 * @param   svcRecID        Service record to associate with this note
 * @returns recordID        New record id of the note
 ***************************************************************************/     

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userID          IS NULL) RAISERROR ('userID is required',            11, 1)
IF (@userGroup       IS NULL) RAISERROR ('userGroup is required',         11, 1)    
IF (@userRank        IS NULL) RAISERROR ('userRank is required',          11, 1)    
IF (@recordClaim     IS NULL) RAISERROR ('record claim is required',      11, 1)

IF (@validateRec     IS NULL) RAISERROR ('Validate flag required',        11, 1)    
IF (@saveType        IS NULL) RAISERROR ('Save type is required',         11, 1)

IF (@entryType       IS NULL) RAISERROR ('Entry type is required',        11, 1)
IF (@svcRecID        IS NULL) RAISERROR ('Service record id is required', 11, 1)
IF (@svcRecGroupID   IS NULL) RAISERROR ('Service record group id is required', 11, 1)

declare @recordID               as bigint  = null
declare @pracID                 as bigint
declare @groupID                as bigint
declare @createdOn              as datetime
declare @dos                    as date
declare @patAbsent              as bit  
declare @supervisedByGroupCount as bigint  = 0
declare @approvalOptionsID      as bigint  = null
declare @svcTypeID              as int     = null

/*============================================================
 * If this was entered by a non client get out
 * Note: We will need to change this if we use the approval
 * system for service records entered by SBSC staff
 *============================================================*/ 
  
IF (@userGroup != dbo.CONST_USER_GROUP_CLIENT()) RETURN (0)  

/*============================================================
 * If the client has choosen not to use the supervision
 * option for the entry date of the service record
 * or no supervision option has been specified get out
 *============================================================*/ 

set @approvalOptionsID = null

select top 1 
  @approvalOptionsID = sroa.id 
from dbo.SERVICE_RECORD_APPROVAL_OPTIONS_VIEW_CORE() as sroa
where 
  (sroa.clientID = @clientID) and (sroa.approvalSystem = 1)

if (@approvalOptionsID is null) return (0)

/*============================================================
 * If the user is a client user but not a practitioner
 * then the service being entered is on behalf of a practitioner
 * and there should be proper documentation including 
 * supervising practitioner approval... so we can get out
 *============================================================*/ 

declare @pracIDCheck as bigint
set @pracIDCheck = null
select top 1 @pracIDCheck = prp.PRACTITIONER_ID from dbo.PRACTITIONER_Practitioner as prp where (prp.UserID = @userID)
if (@pracIDCheck is null) return 0

/*============================================================
 * If the practitioner group does not require supervisor 
 * approval for rendering LEA services, get out.
 *============================================================*/ 

set @supervisedByGroupCount = 0
select 
  @supervisedByGroupCount = COUNT(GROUP_ID) 
from dbo.GROUPS_SUPERVISING_GROUP_ID_VIEW(@svcRecGroupID)

if (@supervisedByGroupCount = 0) RETURN (0)

/*============================================================
 * Fetch service record 
 *============================================================*/  

select top 1
    @groupID         = sr.groupID
  , @pracID          = sr.pracID
  , @createdOn       = sr.created  
  , @recordID        = sr.id
  , @dos             = convert(date,sr.dos)
  , @svcTypeID       = sr.svcType  
from dbo.SERVICE_RECORDS as sr 
where 
  (sr.id = @SvcRecID)
      
/*============================================================
 * If the service record does not exist get out with an error
 *============================================================*/  

if (@recordID is null) RAISERROR ('Service record does not exist', 11, 1)

/*============================================================
 * Get entry data
 *============================================================*/ 

DECLARE @enteredByName         as varchar(500) = null
DECLARE @enteredByTitle        as varchar(500) = null
DECLARE @enteredByNameRefID    as bigint       = null
DECLARE @enteredByTitleRefID   as bigint       = null
DECLARE @pracUserID            as bigint       = null

set @pracUserID = null

select top 1
    
  @enteredByName             = pp.CONCAT_NAME      /* Entered by or entered for */
, @enteredByNameRefID        = pp.PRACTITIONER_ID  /* Entered by or entered for */
, @enteredByTitle            = gg.GROUP_NAME 
, @enteredByTitleRefID       = gg.GROUP_ID
, @pracUserID                = pp.UserID

from dbo.PRACTITIONER_Practitioner as pp 
join dbo.PRACTITIONER_GROUPS       as pg on pg.PRACTITIONER_ID = pp.PRACTITIONER_ID
join dbo.GROUP_Group               as gg on gg.GROUP_ID        = pg.GROUP_ID
join users.dbo.Users               as uu on uu.userrid         = pp.UserID

where (
      (pp.UserID = @userID)      
  and (gg.GROUP_TYPE in (1,2))
)

if (@pracUserID is null) 
begin
  RAISERROR ('Supervised services can only be entered directly by the practitioner who rendered the service', 11, 1)
end

/*============================================================
 * Check for exceptions by service type for this supervised
 * group.  If one is found then supervision for this type of
 * service is not required and we can get out.
 *============================================================*/  

if exists (
  select top 1 
    srar.ID
  from dbo.GROUP_GROUP_DIRECT_SUPERVISED_SVC_REC_APPROVAL_EXCEPTIONS as srar
  where (
        (srar.SUPERVISED_GROUP_ID   = @groupID)
    and (srar.EXCEPTION_BASED_ON    = 1) /* svc type */
    and (srar.SVC_TYPE_ID           = @svcTypeID)
    and (srar.APPROVAL_NOT_REQUIRED = 1)
    and (@dos between srar.START_DATE and srar.END_DATE)
    and (srar.ACTIVE = 1) 
  )
)
begin
  return(0)
end

/*============================================================
 * If we reach this point create a new approval record
 *============================================================*/  
  
insert into dbo.SERVICE_RECORDS_APPROVAL (
     clientID
   , groupID
   , pracID
   , svcRecCreatedOn
   , svcRecCreatedByUserID
   , svcRecCreatedByUserGroup
   , svcRecCreatedByName 
   , svcRecCreatedByNameRefID
   , svcRecCreatedByTitle
   , svcRecCreatedByTitleRefID
   , svcRecID
   , approvalOptionsIDApplied
   , createdOn
   , reviewed
   , active )
values (
    @clientID
  , @groupID
  , @pracID
  , @createdOn
  , @userID
  , @userGroup
  , @enteredByName
  , @enteredByNameRefID
  , @enteredByTitle
  , @enteredByTitleRefID
  , @recordID
  , @approvalOptionsID
  , GETDATE()
  , 0
  , 1 )
  
return (0)

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_RECORDS_APPROVAL_CREATE_NEW_FROM_SERVICE_RECORD] TO [webuser]
GO

