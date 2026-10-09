USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_FORM_COMPLETE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_FORM_COMPLETE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FORM_FORM_COMPLETE ( 
  @userID             bigint,
  @userGroup          int,
  @userRank           int,
  @formRequestID      varchar(1000),
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
 * FORM_FORM_COMPLETE */    
/**    
 ***************************************************************************/     

/*###########################################################################
  # Init 
  ###########################################################################*/  
  
declare @today  as datetime = getdate()
set @recordID = null
set @spDetails  = ''

/*###########################################################################
  # Look for existing
  ###########################################################################*/  

select @recordID = id from FORM_FORM_SUBMITTED where (formRequestID = @formRequestID)

/*###########################################################################
  # If there is no existing record get out
  ###########################################################################*/  

if (@recordID is null) return(0)

/*###########################################################################
  # Otherwise update
  ###########################################################################*/  

update FORM_FORM_SUBMITTED set lastUpdatedOn = @today, completedOn = @today, complete = 1 where id = @recordID
  
/*###########################################################################
  # And mark any associated files as having their data forms complete
  ###########################################################################*/  
 
declare @numFiles  as int = 0
declare @curFile   as int = 1  
declare @uploadIDs as table (  idx              bigint identity(1,1)
                             , uploadID         bigint
                             , formID           bigint                      
                             , formPagePartID   bigint)
                               
insert into @uploadIDs 
select 
   fu.id as uploadID
  ,fpp.formID
  ,fpp.id as formPagePartID
  
from FORM_FORM_SUBMITTED        as ffs
join FORM_PAGES_PARTS_SUBMITTED as fpps on fpps.formRequestID = ffs.formRequestID
join FORM_PAGES_PARTS           as fpp  on fpp.id             = fpps.formPagePartDefinitionID
join FORM_PAGE_PART_TYPES       as fppt on fppt.id            = fpp.formPagePartType
join FILE_UPLOADS               as fu   on fu.id              = fpps.crossRefId
where ffs.id = @recordID and fppt.dataType = 900

select @numFiles = COUNT(idx) from @uploadIDs
  
declare @statusCode           as bigint = dbo.CONST_FILE_UPLOAD_STATUS_FORM_COMPLETE()

declare @uploadID             as bigint = null
declare @formID               as bigint = null
declare @fileUploadFormPartID as bigint = null
declare @statusID             as bigint = null

while (@curFile <= @numFiles)
begin

  set @uploadID             = null
  set @formID               = null
  set @fileUploadFormPartID = null        
  
  select top 1 @uploadID = uploadID, @formID = formID, @fileUploadFormPartID = formPagePartID from @uploadIDs where idx = @curFile
  
  exec dbo.FORM_PAGE_PART_COMPLETE_FILE_UPLOAD 

      @uploadID
    , @formID
    , @fileUploadFormPartID
    , @formRequestID
  
  exec dbo.FILE_UPLOAD_SET_STATUS 

      @uploadID
    , @today
    , @userID
    , @statusCode
    , null
    , null
    , null
    , @statusID output
    
  set @curFile = @curFile + 1

end


/*###########################################################################
  # Done
  ###########################################################################*/       

return (0)  
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].[FORM_FORM_COMPLETE] TO [webuser]

GO