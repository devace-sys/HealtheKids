USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAME_EXTRACT_CONTEXT_FIELD_VALUE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAME_EXTRACT_CONTEXT_FIELD_VALUE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[ORP_DOCUMENT_STANDARD_SELECTION_NAME_EXTRACT_CONTEXT_FIELD_VALUE] (  
    @allowMultipleOrders    bit
  , @orderContextFieldName  varchar(200)
  , @formBuilderAnswersJSON varchar(max)
) 
RETURNS varchar(256)
AS     
BEGIN    
  declare @orderContextFieldNameValue as varchar(256) = ''
  
  set @orderContextFieldNameValue = IIF(
										 (@allowMultipleOrders = 1
								     and isnull(@orderContextFieldName, '') != ''
								     and isnull(@formBuilderAnswersJSON, '') != ''
									 and isnull(@formBuilderAnswersJSON, '') != '[]'
									 and isnull(@formBuilderAnswersJSON, '') != '{}')
								  ,  isnull(convert(varchar(200), JSON_VALUE(@formBuilderAnswersJSON, CONCAT('$."', @orderContextFieldName, '"'))), '')
								  , '')         
  return @orderContextFieldNameValue
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[ORP_DOCUMENT_STANDARD_SELECTION_NAME_EXTRACT_CONTEXT_FIELD_VALUE] TO [webuser]
GO