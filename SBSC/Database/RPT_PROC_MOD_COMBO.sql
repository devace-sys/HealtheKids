USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_PROC_MOD_COMBO') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_PROC_MOD_COMBO
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_PROC_MOD_COMBO] 
  (@proc AS nchar(10),
   @mod1 AS nchar(10),
   @mod2 AS nchar(10),
   @mod3 AS nchar(10),
   @mod4 AS nchar(10))
    
RETURNS VARCHAR(50) 
WITH SCHEMABINDING
AS     
BEGIN    
  
  declare @prm1m2m3 as varchar(50)
  
  declare @pr as varchar(10)
  declare @m1 as varchar(10)
  declare @m2 as varchar(10)
  declare @m3 as varchar(10)
  declare @m4 as varchar(10)
  
  if (@proc is null) set @proc = '' 
  if (@mod1 is null) set @mod1 = '' 
  if (@mod2 is null) set @mod2 = '' 
  if (@mod3 is null) set @mod3 = '' 
  if (@mod4 is null) set @mod4 = ''
  
  set @pr = @proc
  set @m1 = @mod1
  set @m2 = @mod2
  set @m3 = @mod3
  set @m4 = @mod4
  
  set @pr = ltrim(rtrim(@pr))
  set @m1 = ltrim(rtrim(@m1))
  set @m2 = ltrim(rtrim(@m2))
  set @m3 = ltrim(rtrim(@m3))
  set @m4 = ltrim(rtrim(@m4))
  
  set @prm1m2m3 = @pr + ' ' + @m1 + ' ' + @m2 + ' ' + @m3 + ' ' + @m4
  set @prm1m2m3 = ltrim(rtrim(@prm1m2m3))
  
  return @prm1m2m3
END  

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RPT_PROC_MOD_COMBO] TO [webuser]
GO
