USE USERS
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GENERATE_PASSWORD') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GENERATE_PASSWORD
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

  /***************************************************************************    
   * GENERATE_PASSWORD */    
  /**    
   * Generates random upper lowercase alpha numberic string for temporary
   * password use.
   *   
   * @param  minLength minimum length
   * @return nvarchar(128)
   ***************************************************************************/  

CREATE FUNCTION [dbo].[GENERATE_PASSWORD] (@minLength as smallint) 
RETURNS nvarchar(128)
AS    
BEGIN

  declare @passwordOut as nvarchar(128)
  declare @pwdStr      as varchar(50) = ''
  
  declare @numChars as int = 0
  declare @charCtr  as int = 1
  declare @chars    as varchar(61)  = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789'
  declare @idx      as int = 0

  set @numChars = isnull(@minLength,0)
  if (@numChars <= 0) set @numChars = 32
  if (@numChars > 32) set @numChars = 32

  while (@charCtr <= @numChars)
  begin
    
	select @idx = VALUE_TINYINT % 61 from dbo.GENERATE_RANDOM_NUMBERS    
	set @pwdStr = @pwdStr + substring(@chars,@idx,1)  
    set @charCtr = @charCtr + 1
  end

  set @passwordOut = convert(nvarchar(128),@pwdStr)
  return @passwordOut
END    
GO
