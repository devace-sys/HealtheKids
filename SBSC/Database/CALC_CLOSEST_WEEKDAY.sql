USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_CLOSEST_WEEKDAY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_CLOSEST_WEEKDAY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[CALC_CLOSEST_WEEKDAY] ( 
    @value datetime 
  , @direction int  
)
RETURNS datetime
AS     
BEGIN        

  
  declare @dow as int = dbo.CALC_SERVER_INDEPENDENT_DAY_OF_WEEK_NUMBER(@value)
  declare @offset as int = 0

  /* Value is a weekday so its the date we need */

  if (@dow between 0 and 4) 
  begin    
    return @value
  end

  /* Saturday */

  else if (@dow = 5) 
  begin

    /* We need previous Friday */
	if (@direction = -1) set @offset = -1 

	/* We need next Monday*/
	else if (@direction =  1) set @offset = 2 

    else set @offset = 0
  end

  /* Sunday */
  
  else if (@dow = 6) 
  begin
    
	/* We need previous Friday*/
    if (@direction = -1) set @offset = -2
	
	/* We need next Monday*/
	else if (@direction = 1)  set @offset = 1
	
	else set @offset = 0
  end

  return dateadd(day,@offset,@value)
END				
				   
GO  