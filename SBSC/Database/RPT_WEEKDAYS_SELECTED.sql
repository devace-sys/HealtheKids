USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_WEEKDAYS_SELECTED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_WEEKDAYS_SELECTED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RPT_WEEKDAYS_SELECTED](
  @mon BIT,
  @tue BIT,
  @wed BIT,
  @thu BIT,
  @fri BIT
)     

RETURNS VARCHAR(1000)
AS     
BEGIN    
  
  declare @tempout as varchar(1000)
  
  set @tempout = ''

  if @mon is null set @mon = 0
  if @tue is null set @tue = 0
  if @wed is null set @wed = 0
  if @thu is null set @thu = 0
  if @fri is null set @fri = 0
  
  if @mon = 1 set @tempout = @tempout + '[Mon] '
  if @tue = 1 set @tempout = @tempout + '[Tue] '
  if @wed = 1 set @tempout = @tempout + '[Wed] '
  if @thu = 1 set @tempout = @tempout + '[Thu] '
  if @fri = 1 set @tempout = @tempout + '[Fri] '
  
  set @tempout = ltrim(rtrim(@tempout))  
  
  RETURN @tempout
  
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RPT_WEEKDAYS_SELECTED] TO [webuser]
GO
