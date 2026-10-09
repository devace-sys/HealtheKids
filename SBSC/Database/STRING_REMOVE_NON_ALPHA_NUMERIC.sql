USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_REMOVE_NON_ALPHA_NUMERIC') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_REMOVE_NON_ALPHA_NUMERIC
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * STRING_REMOVE_NON_ALPHA_NUMERIC */    
/**    
 * Removes all character from value except (when specified) spaces, numbers
 * or letters.  Also limits number of output characters to maxlen.
 * Output value is also trimmed.
 *
 * @param  value         string in
 *
 * @parm   allowSpaces   1 = spaces in value are retained.  
 *                       0 = spaces in value are removed.
 *
 * @parm   allowNumbers  1 = numbers in the value are retained.  
 *                       0 = numbers in the value are removed.
 *
 * @parm   allowLetters  1 = letters in the value are retained
 *                       0 = letters in the value are removed
 *
 * @parm   allowDashes   1 = dashes in the value are retained
 *         allowDashes   0 = dashes in the value are removed.
 *
 * @parm   maxLen        truncates the return value by this 
 * @return               string
 ***************************************************************************/   

CREATE FUNCTION [dbo].[STRING_REMOVE_NON_ALPHA_NUMERIC] (    
    @value         nvarchar(512) = null
  , @allowSpaces   bit           = 0
  , @allowNumbers  bit           = 1
  , @allowLetters  bit           = 1
  , @allowDashes   bit           = 0
  , @maxLen        int           = null
) 
RETURNS varchar(512)
/*WITH SCHEMABINDING*/
AS     
BEGIN    
    declare @valueOut as varchar(512) = convert(varchar(512),(trim(isnull(@value,N''))))
    declare @valueLen as int          = len(@valueOut)
	if (@valueLen = 0) return @valueOut
    set @valueOut = dbo.STRING_REMOVE_NON_ASCII(@valueOut)
	declare @ptrn as varchar(25) = ''	
	set @ptrn = '%[^'
	          + iif((@allowSpaces  = 1),' '      ,'')
	          + iif((@allowNumbers = 1),'0-9'    ,'')
	          + iif((@allowLetters = 1),'A-Za-z' ,'')
			  + iif((@allowDashes  = 1),'[-]'    ,'')			  			  
              + ']%'
	set @maxLen = isnull(@maxlen,@valueLen)	
	if (@maxLen < 1) set @maxLen = @valueLen	
	while patindex(@ptrn, @valueOut) > 0
    begin
	  set @valueOut = stuff(@valueOut, patindex(@ptrn, @valueOut), 1, '')
	end
    return trim(left(@valueOut,@maxLen))
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[STRING_REMOVE_NON_ALPHA_NUMERIC] TO [webuser]
GO