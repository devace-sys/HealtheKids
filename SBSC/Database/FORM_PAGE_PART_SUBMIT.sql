USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_PAGE_PART_SUBMIT') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_PAGE_PART_SUBMIT
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FORM_PAGE_PART_SUBMIT ( 
  @userID                               bigint,
  @userGroup                            int,
  @userRank                             int,
  @formRequestID                        varchar(1000),
  @formPagePartDefinitionID             bigint,
  @originalValue                        varchar(8000),
  @value                                varchar(8000),
  @selectedCount     varchar(8000),
  @selectedNames     varchar(8000),
  @fileSize          bigint,
  @fileMimeType      varchar(8000),
  @editDelReason     VARCHAR(7000),    
  @validateRec       BIT,    
  @saveType          INT,    
  @recID             BIGINT,
  
  @MsgNoRec          VARCHAR(1000),    
  @MsgNoEdit         VARCHAR(1000), 
  @MsgDupRec         VARCHAR(1000),   
  @MsgDataError      VARCHAR(1000),
  @MsgNotActive      VARCHAR(1000),     
  
  @spDetails         VARCHAR(8000) OUTPUT,    
  @recordID          BIGINT        OUTPUT
)
AS
BEGIN

/***************************************************************************    
 * FORM_PAGE_PART_SUBMIT */    
/**    
 *    
 * @param   userID                       The userid of who saved the record    
 * @param   userGroup                    Users group    
 * @param   userRank                     User rank
 * @param   formRequestID                Unique identifier for form request
 * @parm    formPagePartDefinitionID     Record id for form page part definition
 * @param   value                        Value submitted
 ***************************************************************************/     

/*###########################################################################
  # Init 
  ###########################################################################*/  
  
declare @today                as datetime         = getdate()
declare @dataType             as varchar(max)     = null
declare @fileUploadFromSource as bigint = null
declare @crossRefId           as bigint           = null

set @recordID = null
set @spDetails  = ''

/*###########################################################################
  # Look for existing
  ###########################################################################*/  

select 
     @recordID = id
  ,  @crossRefId = crossRefId 
from FORM_PAGES_PARTS_SUBMITTED 
where ((formRequestID = @formRequestID) and (formPagePartDefinitionID = @formPagePartDefinitionID))

/*###########################################################################
  # Determine datatype, uploadSource
  ###########################################################################*/  

select 

   @dataType              = fppdt.dataType 
  ,@fileUploadFromSource  = ff.fileUploadFromSource
from dbo.FORM_PAGES_PARTS          as fpp
join dbo.FORM_PAGE_PART_TYPES      as fppt  on fppt.id  = fpp.formPagePartType
join dbo.FORM_PAGE_PART_DATA_TYPES as fppdt on fppdt.id = fppt.dataType
join dbo.FORM_FORM                 as ff    on ff.id    = fpp.formID

where (fpp.id = @formPagePartDefinitionID)


/*###########################################################################
  # If there is no existing record create new
  ###########################################################################*/  

if (@recordID is null)
begin

  /*============================================================
   * If the datatype is a file insert records into our central
   * file uploads table and file uploads status table
   *============================================================*/

  if (@dataType = 'file')
  begin
           
    exec FILE_UPLOAD_SAVE   @userID
                          , @userGroup
                          , @userRank
                          , null
                          , null
                          , null
                          , null
                          , @originalValue
                          , @value 
                          , @userID
                          , null
                          , @fileUploadFromSource
                          , null
                          , null
                          , @fileSize
                          , @fileMimeType
                          , @crossRefId output
    
  end
  
  /*============================================================
   * Then go ahead and insert the form page part
   *============================================================*/
  
  insert into FORM_PAGES_PARTS_SUBMITTED (
     formRequestID
    ,formPagePartDefinitionID
    ,createdOn
    ,value
    ,selectedCount
    ,selectedNames
    ,crossRefId
  )  
  values (
     @formRequestID
    ,@formPagePartDefinitionID    
    ,@today
    ,@value
    ,@selectedCount
    ,@selectedNames
    ,@crossRefId
  )
  
  set @recordID = SCOPE_IDENTITY()
      
end

/*###########################################################################
  # Otherwise update
  ###########################################################################*/  

else
begin

  /*============================================================
   * If the datatype is a file update our central
   * file uploads table and file uploads status table
   *============================================================*/
   
  if (@dataType = 'file')
  begin
  
   exec FILE_UPLOAD_CANCEL_OR_RESET @crossRefId, @userID, @today
    
   exec FILE_UPLOAD_SAVE   @userID
                         , @userGroup
                         , @userRank
                         , null
                         , null
                         , null
                         , null
                         , @originalValue
                         , @value 
                         , @userID
                         , null
                         , @fileUploadFromSource
                         , null
                         , null
                         , @fileSize
                         , @fileMimeType
                         , @crossRefId output
  
  end
  
  /*============================================================
   * Then update form pages parts
   *============================================================*/

  update FORM_PAGES_PARTS_SUBMITTED set 
     lastUpdatedOn = @today
   , value         = @value 
   , selectedCount = @selectedCount
   , selectedNames = @selectedNames 
   , crossRefId    = @crossRefId   
  where id = @recordID 
  
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
                         
GRANT EXECUTE ON  [dbo].[FORM_PAGE_PART_SUBMIT] TO [webuser]

GO