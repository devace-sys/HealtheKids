USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_FORM_COPY_SUBMITTED_INTO_NEW') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_FORM_COPY_SUBMITTED_INTO_NEW
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FORM_FORM_COPY_SUBMITTED_INTO_NEW ( 
  @userID             bigint,
  @userGroup          int,
  @userRank           int,

  @subFormRequestID   varchar(1000),
  @newFormRequestID   varchar(1000),  
  @requestIP          varchar(1000),
  @requestUserAgent   varchar(8000),
  
  @editDelReason      VARCHAR(7000),    
  @validateRec        BIT,    
  @saveType           INT,    
  @recID              BIGINT,  
  @MsgNoRec           VARCHAR(1000),    
  @MsgNoEdit          VARCHAR(1000), 
  @MsgDupRec          VARCHAR(1000),   
  @MsgDataError       VARCHAR(1000),
  @MsgNotActive       VARCHAR(1000),       
  @spDetails         VARCHAR(8000) OUTPUT,    
  @recordID          BIGINT        OUTPUT
)
AS
BEGIN

/***************************************************************************    
 * FORM_FORM_COPY_SUBMITTED_INTO_NEW */    
/**    
 ***************************************************************************/     

/*###########################################################################
  # Init 
  ###########################################################################*/  
  
declare @today  as datetime = getdate()
set @recordID = null
set @spDetails  = ''

declare @subRecordID         as bigint = null
declare @newRecordID         as bigint = null
declare @subFormDefinitionID as bigint = null

/*###########################################################################
  # Look for submitted form we are copying data from
  # If it does not exist get out
  ###########################################################################*/  

select 
    @subRecordID         = id   
  , @subFormDefinitionID = formDefinitionID    
from dbo.FORM_FORM_SUBMITTED where ((formRequestID = @subFormRequestID) and (userID = @userID))

if (@subRecordID is null) return(0)

/*###########################################################################
  # Now check to see if the new request id is already in use
  # If it does exist get out
  ###########################################################################*/  

select @newRecordID = id from dbo.FORM_FORM_SUBMITTED where (formRequestID = @newFormRequestID)

if (@newRecordID is not null) return(0)

/*###########################################################################
  # Otherwise copy
  ###########################################################################*/  

/*============================================================
 * Form 
 * Note: One one record so we just use a simple insert
 *============================================================*/
 
insert into dbo.FORM_FORM_SUBMITTED (  
    formRequestID
  , formDefinitionID
  , userID
  , userGroup
  , userRank
  , requestIP
  , requestUserAgent
  , createdOn
  , complete
  , active 
)
values (
    @newFormRequestID
  , @subFormDefinitionID
  , @userID        
  , @userGroup
  , @userRank
  , @requestIP
  , @requestUserAgent
  , @today
  , 0             
  , 1)

set @recordID = SCOPE_IDENTITY()
  
/*============================================================
 * Form Pages
 *============================================================*/

insert into dbo.FORM_PAGES_SUBMITTED (
    formRequestID
  , formPageDefinitionID
  , createdOn
)
select 
    @newFormRequestID    as formRequestID
  , fps.formPageDefinitionID
  , @today               as createdOn
from dbo.FORM_PAGES_SUBMITTED as fps 
where (fps.formRequestID = @subFormRequestID)

/*============================================================
 * Form Page Parts
 * Copy everything except files
 *============================================================*/

insert into dbo.FORM_PAGES_PARTS_SUBMITTED (
    formRequestID
  , formPagePartDefinitionID
  , createdOn
  , value
  , selectedCount
  , selectedNames
  , crossRefId
)
select
    @newFormRequestID         as formRequestID
  , fpps.formPagePartDefinitionID
  , @today                    as createdOn
  , fpps.value
  , fpps.selectedCount
  , fpps.selectedNames
  , fpps.crossRefId
from dbo.FORM_PAGES_PARTS_SUBMITTED as fpps
join dbo.FORM_PAGES_PARTS           as fpp   on fpp.id   = fpps.formPagePartDefinitionID
join dbo.FORM_PAGE_PART_TYPES       as fppt  on fppt.id  = fpp.formPagePartType
join dbo.FORM_PAGE_PART_DATA_TYPES  as fppdt on fppdt.id = fppt.dataType

where ((fpps.formRequestID = @subFormRequestID) and (fppdt.dataType != 'file'))

/*###########################################################################
  # Done
  ###########################################################################*/       

return (0)  
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].[FORM_FORM_COPY_SUBMITTED_INTO_NEW] TO [webuser]

GO