USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PARSE_SEARCH_TERM') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PARSE_SEARCH_TERM
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PARSE_SEARCH_TERM] (
    @term       as varchar(1000)
  , @delimiter  as char(1)
  , @idx        as int
)    
returns varchar(255)
--WITH SCHEMABINDING
    
/***************************************************************************    
 * PARSE_SEARCH_TERM */    
/**    
 * Returns individual part of string split (idx starts at 1)
 * 
 *    
 * @param   name            Name to look for   
 * @return  string or null
 ***************************************************************************/            
as           
begin 
  declare @part as varchar(255) = null

  if (@term is null) return @part
 
  declare @termIn as varchar(1000) = ltrim(rtrim(@term))
  if (len(@termIn)=0) return @part
  if (@termIn = ',')  return @part  
  select @part = dbo.STRING_SPLIT_TO_PART_BY_IDX(@term,@delimiter,@idx) + '%' where (1=1) option(recompile)
  return @part
end    
GO
