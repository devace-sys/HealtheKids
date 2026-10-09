USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_BUILDER_JSON_QA_DATA_TO_HTML') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_BUILDER_JSON_QA_DATA_TO_HTML
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

 CREATE FUNCTION [dbo].[FORM_BUILDER_JSON_QA_DATA_TO_HTML]( 
   @questionsJSONStr             as nvarchar(max) = null
 , @answersJSONStr               as nvarchar(max) = null
 , @unJSONEscapeQuestions        as bit = 0
 , @unJSONEscapeAnswers          as bit = 0
 , @stripFirstLastCharQuestions  as bit = 0
 , @stripFirstLastCharAnswers    as bit = 0
 , @excludeUnasnweredQuestions   as bit = 0
 , @private						 as bit
)

/* TODO: Modify so this works like the plugin for generating the correct markup */

RETURNS nvarchar(max) 
AS    
BEGIN    

declare @htmlOut as nvarchar(max) = ''
--  @htmlOut = STRING_AGG(  '<u>' + isnull(qa2.label,'') + '</u>' + '<br>' + qa2.[value],'<br><br>')

declare @parts as table (
    [type]       varchar(256)
  , [subtype]    varchar(256)
  , [labelText]  nvarchar(max)
  , [valueText]  nvarchar(max)
  , [htmlPart]   nvarchar(max)
) 

insert into @parts
select 
      qa1.[type]
	, qa1.subtype
	, [labelText] = dbo.STRING_STRIP_HTML ( isnull(qa1.label   ,N'')) 
    , [valueText] = dbo.STRING_STRIP_HTML ( isnull(qa1.[values] ,N'')) 
    , [htmlPart]  = N''
from dbo.FORM_BUILDER_COMBINE_QA_JSON_DATA (@questionsJSONStr
                                           , @answersJSONStr
						   			       , @unJSONEscapeQuestions
										   , @unJSONEscapeAnswers
										   , @stripFirstLastCharQuestions
										   , @stripFirstLastCharAnswers
										   , @excludeUnasnweredQuestions
										   , @private) as qa1     

update @parts
set [htmlPart] =
 case [type] 
	    when 'header'         then N'<' + subtype + N'>' + labelText + N'</' + subtype + N'>'
	    when 'barrier'        then N'<hr>'
		when 'paragraph'      then N'<p>' + labelText + N'</p>'
		when 'text'           then N'<div><strong>' + labelText + N'</strong><span>'  + valueText + N'</span></div>'
		when 'number'         then N'<div><strong>' + labelText + N'</strong><span>'  + valueText + N'</span></div>'
		when 'date'           then N'<div><strong>' + labelText + N'</strong><span>'  + valueText + N'</span></div>'
		when 'autocomplete'   then N'<div><strong>' + labelText + N'</strong><br><p>' + valueText + N'</p></div>'
		when 'select'         then N'<div><strong>' + labelText + N'</strong><br><p>' + valueText + N'</p></div>'
		when 'checkbox-group' then N'<div><strong>' + labelText + N'</strong><br><p>' + valueText + N'</p></div>'
		when 'radio-group'    then N'<div><strong>' + labelText + N'</strong><br><p>' + valueText + N'</p></div>'
        when 'textarea'       then N'<div><strong>' + labelText + N'</strong><br><p>' + valueText + N'</p></div>'
		when 'privatetextarea' then N'<div><strong>' + labelText + N'</strong><br><p>' + valueText + N'</p></div>'
		else  N'<div>'+ labelText + N'<br>' + valueText + N'</div>'
	  end
  
select 
  @htmlOut = STRING_AGG(p.htmlPart,'')
from @parts as p

return @htmlOut

END    
GO


