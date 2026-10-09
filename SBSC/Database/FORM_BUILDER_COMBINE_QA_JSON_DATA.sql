USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop UDF
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_BUILDER_COMBINE_QA_JSON_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_BUILDER_COMBINE_QA_JSON_DATA
GO

/*-------------------------------
 * Create memory optimized
 * types for table variables
 *------------------------------*/
           
USE SPEDMON
GO

DROP TYPE IF EXISTS dbo.FORM_BUILDER_QUESTIONS_MEM;  
CREATE TYPE dbo.FORM_BUILDER_QUESTIONS_MEM
as table (
	  [displayOrder]  bigint identity(1,1) 
	, [type]          varchar(256)
    , subtype         varchar(256)
    , [multiple]      bit
	, label           varchar(max)
	, [name]          varchar(512) 
	, [values]        nvarchar(max)
    , [fieldData]     bit
	INDEX ix1 NONCLUSTERED ([name])
) WITH(MEMORY_OPTIMIZED = ON);

USE SPEDMON
GO
DROP TYPE IF EXISTS dbo.FORM_BUILDER_ANSWERS_MEM;
CREATE TYPE dbo.FORM_BUILDER_ANSWERS_MEM
as table (
    [originalName]         varchar(512) 
   ,[originalValue]        varchar(max)
   ,[name]                 varchar(512)
   ,[value]                varchar(max)
   ,[nameHasMod]           bit
   ,[multipleValues]       bit
  INDEX ix1 NONCLUSTERED ([name])
) WITH(MEMORY_OPTIMIZED = ON);
GO

USE SPEDMON
GO
DROP TYPE IF EXISTS dbo.FORM_BUILDER_ANSWER_SELECTIONS_MEM;
CREATE TYPE dbo.FORM_BUILDER_ANSWER_SELECTIONS_MEM 
as table (
     [name]    varchar(512) 
   , [label]   varchar(max)
   , [value]  varchar(max)
   , [selected] bit
   INDEX ix1 NONCLUSTERED ([name])
) WITH(MEMORY_OPTIMIZED = ON);

USE SPEDMON
GO

DROP TYPE IF EXISTS dbo.FORM_BUILDER_MULTI_ANSWERS_MEM;

CREATE TYPE dbo.FORM_BUILDER_MULTI_ANSWERS_MEM
as table (
   	[name]     varchar(512) 
  , [values]   varchar(max)  
 INDEX ix1 NONCLUSTERED ([name])
) WITH(MEMORY_OPTIMIZED = ON);

GO

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_BUILDER_COMBINE_QA_JSON_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_BUILDER_COMBINE_QA_JSON_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FORM_BUILDER_COMBINE_QA_JSON_DATA] (
   @questionsJSONStr             as nvarchar(max) = null
 , @answersJSONStr               as nvarchar(max) = null
 , @unJSONEscapeQuestions        as bit = 0
 , @unJSONEscapeAnswers          as bit = 0
 , @stripFirstLastCharQuestions  as bit = 0
 , @stripFirstLastCharAnswers    as bit = 0
 , @excludeUnasnweredQuestions   as bit = 0
 , @private                      as bit -- 0: include only non-private fields, 1: include only private fields, null: include all fields
)
           
returns @qa table (
      [type]      varchar(256)
    , subtype     varchar(256)
    , label       varchar(max)
	, [name]      varchar(512)
	, [values]    varchar(max) 
	, [fieldData] bit
	, [private]   bit
)
as           
begin    

declare @questions        as dbo.FORM_BUILDER_QUESTIONS_MEM
declare @answers          as dbo.FORM_BUILDER_ANSWERS_MEM
declare @answerSelections as dbo.FORM_BUILDER_ANSWER_SELECTIONS_MEM
declare @multiAnswers     as dbo.FORM_BUILDER_MULTI_ANSWERS_MEM

/*###########################################################################
  # Exit if we do not have the data we need
  ###########################################################################*/  

if (@questionsJSONStr is null) return
if (@answersJSONStr   is null) return

/*###########################################################################
  # Modify incoming questions and answers JSON if neccessary
  ###########################################################################*/  

set @questionsJSONStr = iif( @unJSONEscapeQuestions = 1
                           , dbo.STRING_UNESCAPE_JSON(@questionsJSONStr,@stripFirstLastCharQuestions)
						   , @questionsJSONStr)

set @answersJSONStr   = iif ( @unJSONEscapeAnswers = 1
                             ,dbo.STRING_UNESCAPE_JSON(@answersJSONStr,@stripFirstLastCharAnswers)
							 ,@answersJsonStr )


/*###########################################################################
  # Parse questions
  ###########################################################################*/  

insert into @questions (
      [type]
    , subtype 
    , [multiple] 
	, label  
	, [name] 
	, [values] 
    , [fieldData])
select 
    qd.*
    /* Identify if this is a question/answer pair */
  , [fieldData] = iif ([type] in ('header', 'barrier', 'paragraph'),0,1)

from OPENJSON(@questionsJSONStr)
WITH (   
               [type]    varchar(256)  '$.type'
              ,subtype   varchar(256)  '$.subtype'
			  ,[multiple] bit          '$.multiple'
              ,label     varchar(max)  '$.label'
			  ,[name]    varchar(512)  '$.name'  
			  ,[values]  NVARCHAR(MAX)  AS JSON
) as qd

/*###########################################################################
  # Parse answers - Initial pass
  ###########################################################################*/  

insert into @answers (

 [originalName]
,[originalValue]
,[name]
,[value]
,[nameHasMod]
,[multipleValues])

select 
  [originalName]  = ad2.[key]
, [originalValue] = ad2.[value]
, [name]          = ad2.[key]   
, [value]         = ad2.[value]
, [nameHasMod]    = 1            /* Guilty until proven innocent */
, [multipleValues] = 0           /* Assume no for now*/
from
(
  select  
    ad1.*
  from OPENJSON(@answersJSONStr) as ad1
) as ad2

/* Identify answers where the name has not been modified by the client side code */

/*###########################################################################
  # Identify answers where the name has NOT been modifed by the client side
  # plugin.  NOTE: The plugin will append a -n to checkbox group answers where
  # n can be any value from 0 to ?
  ###########################################################################*/  

update a
  set a.nameHasMod = 0
from @answers   as a
join @questions as q on q.name = a.name

/*###########################################################################
  # Attempt to normalize names that have been modded by client side
  ###########################################################################*/  

update a
  set a.name = reverse(right(reverse(a.[name]), len(a.[name]) - charindex('-',reverse(a.[name]),1))) 
from @answers as a
where (a.nameHasMod = 1)

/*###########################################################################
  # Identify answers that contain multiple selections and normalize the
  # format of the values (only select right now)
  ###########################################################################*/  

update a
  set 
    a.multipleValues = 1
  , a.value = REPLACE(REPLACE(REPLACE(a.originalValue,'[',''),']',''),'"','')
from @answers as a
join @questions as q on q.name = a.name
where (q.multiple = 1) and (q.type = 'select')

/*###########################################################################
  # Extract answer selections from questions 
  # We will use this later to replace selected id values with labels
  # in select, radio-group, checkbox-group, autocomplete
  ###########################################################################*/  

insert into @answerSelections
select 
   q.name
  ,v2.*
from @questions as q
cross apply (
  select 
    v1.*
  from OPENJSON(q.[values])
  WITH (     		  
	       [label]    nvarchar(max) '$.label'
	      ,[value]    varchar(max) '$.value'
		  ,[selected] bit '$.selected'    
  ) as v1
) as v2
where (q.[values] is not null)


/*###########################################################################
  # Extract and aggregate multiple answers for checkbox-group
  # Approach is unique to checkbox-group
  ###########################################################################*/  

insert into @multiAnswers ([name],[values])
select
   q.[name]
  ,[values] = STRING_AGG(sl.label,',')
from @questions        as q 
join @answers          as a  on a.name = q.name
join @answerSelections as sl on sl.name = a.name 
where ((q.type in ('checkbox-group')) and (a.value = sl.value))
group by 
  q.name

/*###########################################################################
  # Extract and aggregate multiple answers for select
  # (selects that allow multiple)
  # Approach is unique to select
  ###########################################################################*/  

insert into @multiAnswers ([name],[values])
select 
   q.[name]
  ,[values] = STRING_AGG(sl2.label,',')
from @questions        as q  
join @answers          as a  on a.name = q.name
cross apply (
   select 
     sl1.label 
   from STRING_SPLIT(a.value,',') as ss
   join @answerSelections         as sl1 on sl1.name = a.name 
   where (sl1.value = ss.value)
) as sl2
where ((q.type = 'select') and (a.multipleValues = 1))
group by 
  q.name

/*###########################################################################
  # Start building qa result set making sure questions and supporting content
  # (paragraphs, headers, etc) are inserted in order they were presented
  ###########################################################################*/  
  
insert into @qa (
      [type] 
    , subtype 
    , label   
	, [name]  
	, [values] 
	, [fieldData] 
	, [private]
)
select 
     q.[type] 
    ,q.subtype 
    ,q.label   
	,q.[name]  
    ,[values] = ''
	,[fieldData]
	,iif(q.[type] in ('privatetextarea'), 1, 0)
from (select top (dbo.CONST_MAX_ROWS()) * from @questions as q1
order by 
  q1.displayOrder asc ) q

/*###########################################################################
  # Populate answers to questions for cases where there is only ONE answer
  # per question
  ###########################################################################*/  
 
/* Update qa with date,number,text,textarea answers */

update qa
  set qa.[values] = a.value
from @qa      as qa
join @answers as a on a.name = qa.name
where qa.type in ('date','number','text','textarea', 'privatetextarea')

/* Update qa with autocomplete answers. We have to replace the value with the answer selection label. */

update qa
   set qa.[values] = isnull(sl.label, a.value)
from @qa               as qa
join @answers          as a  on a.name = qa.name
left join @answerSelections as sl on ((sl.name = a.name) and (sl.value = a.value))
where ((qa.type = 'autocomplete'))

/* Update qa with radio-group anwers.  We have to replace the value with the answer selection label. */

update qa
  set qa.[values] = sl.label
from @qa               as qa
join @answers          as a  on a.name = qa.name
join @answerSelections as sl on sl.name = a.name and sl.value = a.value
where ((qa.type = 'radio-group') and (a.value = sl.value))

/* Update qa with select anwers that only allow ONE answer */

update qa
   set qa.[values] = qa.[values] + ' ' + sl.label
from @qa               as qa
join @questions        as q  on q.name = qa.name
join @answers          as a  on a.name = qa.name
join @answerSelections as sl on sl.name = a.name
where ((qa.type = 'select') and (q.multiple = 0) and (a.value = sl.value))

/*###########################################################################
  # Populate answers to questions for cases where there can be more than
  # ONE answer per question
  ###########################################################################*/  

/* selects */

update qa
  set qa.[values] = ma.[values]
from @qa               as qa
join @multiAnswers     as ma  on ma.name = qa.name
where (qa.type = 'select')

/* checkbox-group */

update qa
  set qa.[values] = ma.[values]
from @qa               as qa
join @multiAnswers     as ma  on ma.name = qa.name
where (qa.type = 'checkbox-group')

/*###########################################################################
  # Populate answers for Patient Goals
  ###########################################################################*/

update qa
  set qa.[values] = pg.name
from @qa               as qa
join @answers          as a  on a.name = qa.name
join dbo.PATIENT_GOALS as pg on pg.id = a.value
where (qa.type = 'patientgoal')

/*###########################################################################
  # Remove entries with no answers if required
  ###########################################################################*/
if (@excludeUnasnweredQuestions = 1)
begin
	delete from @qa
	where isnull([values], '') = '' 
end


/*###########################################################################
  # Remove entries with respect to @private flag if required
  ###########################################################################*/
if (@private is not null)
begin
	delete from @qa
	where [private] != @private
end

/*###########################################################################
  # Done
  ###########################################################################*/  

return

end    
GO
