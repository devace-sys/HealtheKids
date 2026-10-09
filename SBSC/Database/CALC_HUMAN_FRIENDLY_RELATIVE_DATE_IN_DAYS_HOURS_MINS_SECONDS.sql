USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_HUMAN_FRIENDLY_RELATIVE_DATE_IN_DAYS_HOURS_MINS_SECONDS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_HUMAN_FRIENDLY_RELATIVE_DATE_IN_DAYS_HOURS_MINS_SECONDS
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_HUMAN_FRIENDLY_RELATIVE_DATE_IN_DAYS_HOURS_MINS_SECONDS] (
    @value          datetime
  , @refDate        datetime
  , @includeSeconds bit = 0
) 

/* Based on code from Alan https://stackoverflow.com/a/23630671 */

RETURNS VARCHAR (100)
WITH SCHEMABINDING
AS     
BEGIN    
    
    if @value   is null return ''
	if @refDate is null set @refDate = getdate()

	/* Note: 

	 * 86400 is number of seconds per day
	 * 3600  is number of seconds per hour
	 * 60    is number of minutes per hour or number of seconds per minute
     *
	 * Original logic from Alan :
	 *
	 *     SET @x = DATEDIFF(s, @start, @end);
     *     return CONVERT(VARCHAR(10), ( @x / 86400 ))                      + ' Days '
     *           + CONVERT(VARCHAR(10), ( ( @x % 86400 ) / 3600 ))          + ' Hours '
     *           + CONVERT(VARCHAR(10), ( ( ( @x % 86400 ) % 3600 ) / 60 )) + ' Minutes ' 
	 *	         + CONVERT(VARCHAR(10), ( ( ( @x % 86400 ) % 3600 ) % 60 )) + ' Seconds';
	 */

	 /* Common calculations */
	
	declare @baseDiff                            as int = datediff(s, @value, @refDate)
	declare @baseDiffModSecsPerDay               as int = ( @baseDiff % 86400 )
	declare @baseDiffModSecsPerDayModSecsPerHour as int = (( @baseDiffModSecsPerDay ) % 3600)

    /* Break down our difference parts. */

	declare @diffInDays  as int = ( @baseDiff / 86400 )	 	     
	declare @diffInHours as int = ((@baseDiffModSecsPerDay ) / 3600 )			
    declare @diffInMins  as int = ((@baseDiffModSecsPerDayModSecsPerHour) / 60 )
	declare @diffInSecs  as int = ((@baseDiffModSecsPerDayModSecsPerHour) % 60 )

	/* Construct return string ommitting sections that do not apply and return */
    
	return trim (
				 '' 
				 + iif( (@diffInDays  != 0), convert(varchar(10),@diffInDays)  + ' Days '  ,'')
 	             + iif( (@diffInHours != 0), convert(varchar(10),@diffInHours) + ' Hours ' ,'')
				 + convert(varchar(10),@diffInMins)  + ' Mins '
				 + iif((@includeSeconds = 1),convert(varchar(10),@diffInSecs)  + ' Secs ', '')
			    )	
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_HUMAN_FRIENDLY_RELATIVE_DATE_IN_DAYS_HOURS_MINS_SECONDS] TO [webuser]
GO