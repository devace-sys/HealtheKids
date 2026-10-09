USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GENERATE_RANDOM_ALPHA_NUMERIC_STRING') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GENERATE_RANDOM_ALPHA_NUMERIC_STRING
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

  /***************************************************************************    
   * GENERATE_RANDOM_ALPHA_NUMERIC_STRING */    
  /**    
   * Generates random upper lowercase alpha numberic string
   *   
   * @param  minLength minimum length
   * @return varchar(256)
   ***************************************************************************/  

CREATE FUNCTION [dbo].[GENERATE_RANDOM_ALPHA_NUMERIC_STRING] (@minLength as smallint, @alphaOnly bit) 
RETURNS varchar(256)
AS    
BEGIN

  declare @randomStr as varchar(256) = ''
  declare @numChars  as int = 0
  declare @charCtr   as int = 1
  declare @chars     as varchar(61)  = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789'
  declare @idx       as int = 0
  declare @modDivison as tinyint = 61


  set @alphaOnly = isnull(@alphaOnly,0)
  if (@alphaOnly = 1) set @modDivison = 52
  
  set @numChars = isnull(@minLength,0)
  if (@numChars <= 0)  set @numChars = 256
  if (@numChars > 256) set @numChars = 256

  while (@charCtr <= @numChars)
  begin    
	select @idx = VALUE_TINYINT % @modDivison from dbo.GENERATE_RANDOM_NUMBERS    
	set @randomStr = @randomStr + substring(@chars,@idx,1)  
    set @charCtr = @charCtr + 1
  end

  return @randomStr
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[GENERATE_RANDOM_ALPHA_NUMERIC_STRING] TO [webuser]
GO
