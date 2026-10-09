USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_SPLIT_TO_PART_BY_IDX') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_SPLIT_TO_PART_BY_IDX
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[STRING_SPLIT_TO_PART_BY_IDX] (
    @string     as varchar(8000)
  , @delimiter  as char(1)
  , @idx        as int
)    

returns varchar(255) 
--WITH SCHEMABINDING
    
/***************************************************************************    
 * STRING_SPLIT_TO_PART_BY_IDX */    
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
  if (@string is null) return @part
  declare @stringIn as varchar(8000) = ltrim(rtrim(@string))
  if (len(@stringIn) = 0) return @part
  select @part = part from dbo.STRING_SPLIT (@stringIn, @delimiter, 1) where id = @idx option (recompile)
  return @part
end    
GO
