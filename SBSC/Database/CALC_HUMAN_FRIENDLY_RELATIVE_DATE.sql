USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_HUMAN_FRIENDLY_RELATIVE_DATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_HUMAN_FRIENDLY_RELATIVE_DATE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_HUMAN_FRIENDLY_RELATIVE_DATE] (
    @value   datetime
  , @refDate datetime
) 

RETURNS VARCHAR (100)
WITH SCHEMABINDING
AS     
BEGIN    
    if @value   is null return ''
	if @refDate is null set @refDate = getdate()
	
	if (@refDate < @value) return 'in the future'

	declare @diff as int = 0
	
	set @diff = datediff(year, @value,@refDate)
	if (@diff > 0) return convert(varchar(50),@diff) + ' year(s) ago'
	
	set @diff = datediff(month,@value,@refDate)
	if (@diff > 0) return convert(varchar(50),@diff) + ' month(s) ago'
	
    set @diff = datediff(week,@value,@refDate)
	if (@diff > 0) return convert(varchar(50),@diff) + ' week(s) ago'
	
	set @diff = datediff(day,@value,@refDate)
	if (@diff > 0) return convert(varchar(50),@diff) + ' day(s) ago'
	
	set @diff = datediff(HOUR,@value,@refDate)
	if (@diff > 0) return convert(varchar(50),@diff) + ' hour(s) ago'

    set @diff = datediff(MINUTE,@value,@refDate)
	if (@diff > 0) return convert(varchar(50),@diff) + ' minute(s) ago'

	set @diff = datediff(SECOND,@value,@refDate)
	if (@diff > 0) return convert(varchar(50),@diff) + ' second(s) ago'

	return 'less than 1 second'
   
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_HUMAN_FRIENDLY_RELATIVE_DATE] TO [webuser]
GO