USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_REMOVE_NON_ASCII') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_REMOVE_NON_ASCII
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * STRING_REMOVE_NON_ASCII */    
/**    
 * Removes all non ASCII characters from value
 * Based on solution shared on 
 * https://www.sqlservercentral.com/forums/topic/remove-non-ascii-characters-from-column
 *
 * @param  value         string in
 *
 * @return               string
 ***************************************************************************/   

CREATE FUNCTION [dbo].[STRING_REMOVE_NON_ASCII] (    
  @value nvarchar(max)
) 
RETURNS varchar(max)
WITH SCHEMABINDING
AS     
BEGIN    

declare @valueOut   as varchar(max)
declare @nchar      as nvarchar(1)
declare @position   as int
declare @lenOfValue as int

set @valueOut   = ''
set @position = 1
set @lenOfValue = len(@value)

while (@position <= @lenOfValue)
begin

  set @nchar = SUBSTRING(@value, @position, 1)

  /* Unicode & ASCII are the same from 1 to 255.
   * Only Unicode goes beyond 255
   * 0 to 31 are non-printable characters
   */
  
  if (UNICODE(@nchar) between 32 and 255) set @valueOut = @valueOut + @nchar
  set @position = @position + 1
end

return @valueOut

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[STRING_REMOVE_NON_ASCII] TO [webuser]
GO