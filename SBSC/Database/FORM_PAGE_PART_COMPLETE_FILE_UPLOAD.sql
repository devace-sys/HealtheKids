USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_PAGE_PART_COMPLETE_FILE_UPLOAD') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_PAGE_PART_COMPLETE_FILE_UPLOAD
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[FORM_PAGE_PART_COMPLETE_FILE_UPLOAD] (  
    @uploadID               BIGINT
   ,@formID                 BIGINT
   ,@fileUploadFormPartID   BIGINT
   ,@formRequestID          VARCHAR(1000)
 )    
AS    
BEGIN     
    
/***************************************************************************    
 * FORM_PAGE_PART_COMPLETE_FILE_UPLOAD */    
/**    
 *
 * Completes basic file upload data
 ***************************************************************************/         

declare @clientID       as bigint         = null
declare @fileClass      as bigint         = null
declare @fileSubClass   as varchar(1000)  = null
declare @pracID         as bigint         = null
declare @patID          as bigint         = null
declare @groupIDDisp    as bigint         = null
declare @refDate1       as datetime       = null
declare @refDate2       as datetime       = null
declare @refTitle1      as varchar(2000)  = null
declare @refTitle2      as varchar(2000)  = null

begin try

  select @clientID      = convert(bigint,  isnull(columnValue,'0')) from dbo.FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP (@formID,@fileUploadFormPartID, 'CLIENT_ID',     @formRequestID)
  select @fileClass     = convert(bigint,  isnull(columnValue,'0')) from dbo.FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP (@formID,@fileUploadFormPartID, 'FILE_CLASS',    @formRequestID)
  select @pracID        = convert(bigint,  isnull(columnValue,'0')) from dbo.FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP (@formID,@fileUploadFormPartID, 'PRAC_ID',       @formRequestID)
  select @patID         = convert(bigint,  isnull(columnValue,'0')) from dbo.FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP (@formID,@fileUploadFormPartID, 'PAT_ID',        @formRequestID)
  select @groupIDDisp   = convert(bigint,  isnull(columnValue,'0')) from dbo.FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP (@formID,@fileUploadFormPartID, 'GROUP_ID_DISP', @formRequestID)
  
  select @fileSubClass  = isnull (columnValue,'') from dbo.FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP (@formID,@fileUploadFormPartID, 'FILE_SUB_CLASS', @formRequestID)
  select @refDate1      = isnull (columnValue,'') from dbo.FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP (@formID,@fileUploadFormPartID, 'REF_DATE_1',     @formRequestID)
  select @refDate2      = isnull (columnValue,'') from dbo.FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP (@formID,@fileUploadFormPartID, 'REF_DATE_2',     @formRequestID)  
  select @refTitle1     = isnull (columnValue,'') from dbo.FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP (@formID,@fileUploadFormPartID, 'REF_TITLE_1',    @formRequestID)
  select @refTitle2     = isnull (columnValue,'') from dbo.FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP (@formID,@fileUploadFormPartID, 'REF_TITLE_2',    @formRequestID)

end try

begin catch

  return (1)

end catch

update FILE_UPLOADS 
set 
    clientID        = @clientID
  , fileClass       = @fileClass
  , fileSubClass    = @fileSubClass
  , groupIDDisp     = @groupIDDisp
  , pracID          = @pracID
  , patID           = @patID
  , ReferenceDate1  = @refDate1
  , ReferenceDate2  = @refDate2
  , ReferenceTitle1 = @refTitle1
  , ReferenceTitle2 = @refTitle2
where id = @uploadID

return (0)

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[FORM_PAGE_PART_COMPLETE_FILE_UPLOAD] TO [webuser]
GO
