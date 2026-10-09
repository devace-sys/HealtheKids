USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.BUILD_NOTE_CRITERIA_FORM_QUESTIONS_JSON') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.BUILD_NOTE_CRITERIA_FORM_QUESTIONS_JSON
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[BUILD_NOTE_CRITERIA_FORM_QUESTIONS_JSON]
(
    @noteCrit1                 varchar(8000)
  , @noteCrit2                 varchar(8000)
  , @noteCrit3                 varchar(8000)
  , @noteCrit4                 varchar(8000)
  , @noteCrit5                 varchar(8000)
  , @noteCrit6                 varchar(8000)
  , @noteCrit7                 varchar(8000)
  , @noteCrit8                 varchar(8000)
  , @noteCrit9                 varchar(8000)
  , @noteCrit10                varchar(8000)
) 
RETURNS varchar(max)
AS     
BEGIN    

   declare @formFieldObjsStr as varchar(max) 
   declare @noteCritTable table
	(formFieldTemplate varchar(max))

   if (@noteCrit1 is not null) insert into @noteCritTable
							   values ('{\"type\":\"text\",\"required\":false,\"label\":\"' + @noteCrit1 + '\",\"className\":\"form-control\",\"name\":\"text-1\",\"subtype\":\"text\"}')
   if (@noteCrit2 is not null) insert into @noteCritTable
							   values ('{\"type\":\"text\",\"required\":false,\"label\":\"' + @noteCrit2 + '\",\"className\":\"form-control\",\"name\":\"text-2\",\"subtype\":\"text\"}')
   if (@noteCrit3 is not null) insert into @noteCritTable
							   values ('{\"type\":\"text\",\"required\":false,\"label\":\"' + @noteCrit3 + '\",\"className\":\"form-control\",\"name\":\"text-3\",\"subtype\":\"text\"}')
   if (@noteCrit4 is not null) insert into @noteCritTable
							   values ('{\"type\":\"text\",\"required\":false,\"label\":\"' + @noteCrit4 + '\",\"className\":\"form-control\",\"name\":\"text-4\",\"subtype\":\"text\"}')

   if (@noteCrit5 is not null) insert into @noteCritTable
							   values ('{\"type\":\"radio-group\",\"required\":false,\"label\":\"' + @noteCrit5 + '\",\"inline\":false,\"name\":\"radio-group-1\",\"values\":[{\"label\":\"Yes\",\"value\":\"1\",\"selected\":false},{\"label\":\"No\",\"value\":\"0\",\"selected\":false}]}')
   if (@noteCrit6 is not null) insert into @noteCritTable
							   values ('{\"type\":\"radio-group\",\"required\":false,\"label\":\"' + @noteCrit6 + '\",\"inline\":false,\"name\":\"radio-group-2\",\"values\":[{\"label\":\"Yes\",\"value\":\"1\",\"selected\":false},{\"label\":\"No\",\"value\":\"0\",\"selected\":false}]}')
   if (@noteCrit7 is not null) insert into @noteCritTable
							   values ('{\"type\":\"radio-group\",\"required\":false,\"label\":\"' + @noteCrit7 + '\",\"inline\":false,\"name\":\"radio-group-3\",\"values\":[{\"label\":\"Yes\",\"value\":\"1\",\"selected\":false},{\"label\":\"No\",\"value\":\"0\",\"selected\":false}]}')

   if (@noteCrit8 is not null) insert into @noteCritTable
							   values ('{\"type\":\"number\",\"required\":false,\"label\":\"' + @noteCrit8 + '\",\"className\":\"form-control\",\"name\":\"number-1\"}')
   if (@noteCrit9 is not null) insert into @noteCritTable
							   values ('{\"type\":\"number\",\"required\":false,\"label\":\"' + @noteCrit9 + '\",\"className\":\"form-control\",\"name\":\"number-2\"}')
   if (@noteCrit10 is not null) insert into @noteCritTable
							   values ('{\"type\":\"number\",\"required\":false,\"label\":\"' + @noteCrit10 + '\",\"className\":\"form-control\",\"name\":\"number-3\"}')

   set @formFieldObjsStr = null
   select @formFieldObjsStr = COALESCE(@formFieldObjsStr + ',', '') + formFieldTemplate
   from @noteCritTable
   return              
      + '"['
		+ @formFieldObjsStr
	  + ']"'
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[BUILD_NOTE_CRITERIA_FORM_QUESTIONS_JSON] TO [webuser]
GO