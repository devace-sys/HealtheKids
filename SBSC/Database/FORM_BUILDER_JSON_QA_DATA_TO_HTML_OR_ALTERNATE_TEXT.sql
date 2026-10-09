USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_BUILDER_JSON_QA_DATA_TO_HTML_OR_ALTERNATE_TEXT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_BUILDER_JSON_QA_DATA_TO_HTML_OR_ALTERNATE_TEXT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

 CREATE FUNCTION [dbo].[FORM_BUILDER_JSON_QA_DATA_TO_HTML_OR_ALTERNATE_TEXT]( 
   @questionsJSONStr             as nvarchar(max) = null
 , @answersJSONStr               as nvarchar(max) = null
 , @unJSONEscapeQuestions        as bit = 0
 , @unJSONEscapeAnswers          as bit = 0
 , @stripFirstLastCharQuestions  as bit = 0
 , @stripFirstLastCharAnswers    as bit = 0
 , @excludeUnasnweredQuestions   as bit = 0
 , @private						 as bit
 , @alternateText                as nvarchar(max)
)

RETURNS nvarchar(max) 
AS    
BEGIN    
  return isnull(dbo.FORM_BUILDER_JSON_QA_DATA_TO_HTML (@questionsJSONStr, @answersJSONStr, @unJSONEscapeQuestions, @unJSONEscapeAnswers, @stripFirstLastCharQuestions, @stripFirstLastCharAnswers, @excludeUnasnweredQuestions, @private), @alternateText)
END    
GO


