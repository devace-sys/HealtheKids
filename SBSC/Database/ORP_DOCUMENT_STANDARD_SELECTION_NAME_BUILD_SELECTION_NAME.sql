USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAME_BUILD_SELECTION_NAME') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAME_BUILD_SELECTION_NAME
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[ORP_DOCUMENT_STANDARD_SELECTION_NAME_BUILD_SELECTION_NAME](  
    @allowMultipleOrders    bit
  , @orpDocStdName          varchar(255)
  , @orderContextFieldName  varchar(200)
  , @formBuilderAnswersJSON varchar(max)
) 
RETURNS varchar(512)
AS     
BEGIN    
  declare @orderContextFieldNameValue as varchar(256) = '' 
  set @orderContextFieldNameValue = dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAME_EXTRACT_CONTEXT_FIELD_VALUE (  @allowMultipleOrders , @orderContextFieldName, @formBuilderAnswersJSON )
  return iif(isnull(@orderContextFieldNameValue, '') != '', trim(@orpDocStdName + ' - ' + @orderContextFieldNameValue), @orpDocStdName)

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[ORP_DOCUMENT_STANDARD_SELECTION_NAME_BUILD_SELECTION_NAME] TO [webuser]
GO