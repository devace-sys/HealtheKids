USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_BUILDER_JSON_QA_DATA_TO_TEXT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_BUILDER_JSON_QA_DATA_TO_TEXT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

 CREATE FUNCTION [dbo].[FORM_BUILDER_JSON_QA_DATA_TO_TEXT]( 
   @questionsJSONStr             as nvarchar(max) = null
 , @answersJSONStr               as nvarchar(max) = null
 , @unJSONEscapeQuestions        as bit = 0
 , @unJSONEscapeAnswers          as bit = 0
 , @stripFirstLastCharQuestions  as bit = 0
 , @stripFirstLastCharAnswers    as bit = 0
 , @excludeUnasnweredQuestions   as bit = 0
 , @private						 as bit
)


RETURNS nvarchar(max) 
AS    
BEGIN   
  declare @textOut as nvarchar(max) 
  
  select
    @textOut = isnull( 
	   STRING_AGG( 
	   case when (t1.fieldData = 1) 
	     then '* ' + dbo.STRING_STRIP_HTML(isnull(t1.label,'')) + ': ' + isnull(t1.[values],'')
	     else dbo.STRING_STRIP_HTML(isnull(t1.label,'')) 
		 end
	 , char(13)),'')
  from dbo.FORM_BUILDER_COMBINE_QA_JSON_DATA (@questionsJSONStr,@answersJSONStr, @unJSONEscapeQuestions, @unJSONEscapeAnswers, @stripFirstLastCharQuestions, @stripFirstLastCharAnswers, @excludeUnasnweredQuestions, @private) as t1

  return @textOut

END    
GO


