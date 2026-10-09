USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_TYPE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_UPLOAD_TYPE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[FILE_UPLOAD_TYPE_VIEW] (
    @fileClassUploadAllowedFromPublic  as bit
  , @fileClassUploadAllowedFromPrivate as bit
  , @term                              as varchar(1000)
  , @fileTypeValue                     as varchar(100)
  , @fileClassValue                    as bigint
  , @fileClassActive                   as bit
  , @fileTypeActive                    as bit
)    

RETURNS TABLE
 
 /***************************************************************************    
  * FILE_UPLOAD_TYPE_VIEW */    
 /**    
  * Returns a list of file types for uploads
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

with 
cte_file_type_pass_1 
as
(
select distinct 
    fileClassName
  , fileClassValue
 -- , fileClassSaveAsNamePattern
  , fileClassUploadAllowedFromPublic
  , fileClassUploadAllowedFromPrivate
  , fileTypeName
  , fileTypeValue
  , fileTypeActive
  , fileTypeUseInUploadList
from dbo.FILE_CLASS_AND_TYPE_CORE_VIEW (  @fileClassUploadAllowedFromPublic
                                        , @fileClassUploadAllowedFromPrivate
                                        , 1
                                        , null
                                        , @term
                                        , @fileClassValue
                                        , @fileTypeValue
                                        , @fileClassActive
                                        , @fileTypeActive)
)
,
cte_output_1
as
(
  select 
      name  = [fileClassName] + ' - ' + [fileTypeName]
    , value = [fileTypeValue]
    , * 
   from cte_file_type_pass_1
)
select top (dbo.CONST_MAX_ROWS()) * from cte_output_1 order by [name]

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[FILE_UPLOAD_TYPE_VIEW] TO [webuser]
GO   
