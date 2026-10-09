USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_ONLY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_ONLY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[DATE_ONLY] (@datein DATETIME) 
RETURNS DATETIME 
WITH SCHEMABINDING 

/***************************************************************************    
 * DATE_ONLY */    
/**    
 * Sets the time component of a date time to 00:00:00, effectively striping
 * out the time component and leaving just the date.
 *
 * This is useful for date comparisons.
 * 
 * Technique courtesey of Anatoly?
 * Technique reference courtesey of Greg Duncan.
 *
 * http://coolthingoftheday.blogspot.com/2006/02/get-only-date-from-datetime-in-t-sql.html   
 *
 * @param   @datein            Datetime to strip time portion of, or null for
 *                             todays date
 * @return  datetime with time portion set to 00:00:00
 ***************************************************************************/            
     
AS     
BEGIN    
  IF @datein IS NULL return null   
  RETURN DATEADD(dd, 0, DATEDIFF(dd, 0, @datein))   
END    
    
GO
