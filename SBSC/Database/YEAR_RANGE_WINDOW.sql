USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.YEAR_RANGE_WINDOW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.YEAR_RANGE_WINDOW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[YEAR_RANGE_WINDOW] 
(@today       DATETIME,
 @windowStart INT,
 @windowEnd   INT
 )    

 /***************************************************************************    
  * YEAR_RANGE_WINDOW */    
 /**    
  * Generates sequence of year ranges around today.  
  * You are limited to 100.
  *    
  * @param  today           Todays date
  * @param  windowStart     Number of years before today
  * @param  windowEnd       Number of years after today         
  * @return                 Table of years (ints)
  ***************************************************************************/     

RETURNS TABLE
AS
RETURN
(     
select * 
from 
dbo.YEAR_RANGE_SEQUENCE(DATEPART(year,(DATEADD(YEAR, @windowStart, @today))),
                        DATEPART(year,(DATEADD(YEAR, @windowEnd,   @today))))
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[YEAR_RANGE_WINDOW] TO [webuser]
GO

  