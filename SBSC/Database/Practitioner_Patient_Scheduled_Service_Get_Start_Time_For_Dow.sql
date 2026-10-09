USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Patient_Scheduled_Service_Get_Start_Time_For_Dow') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Practitioner_Patient_Scheduled_Service_Get_Start_Time_For_Dow
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.Practitioner_Patient_Scheduled_Service_Get_Start_Time_For_Dow (   
    @dow              int 
  , @recurring        bit  
  , @startTime        time(0)
  , @monStartTime     time(0)
  , @tueStartTime     time(0)
  , @wedStartTime     time(0)
  , @thuStartTime     time(0)
  , @friStartTime     time(0)
)
 
RETURNS time(0)
AS     
BEGIN        

  /* Not recurring */

  if (@recurring = 0)
  begin
    return @startTime
  end /* Not Recurring */
  
  /* Recurring*/

  else
  begin    
    return case 
      when @dow = 1 then @monStartTime
      when @dow = 2 then @tueStartTime
	  when @dow = 3 then @wedStartTime
      when @dow = 4 then @thuStartTime
      when @dow = 5 then @friStartTime
      else @startTime
    end
  end /* Recurring*/ 
  /* If we reach this point then return default*/
  return @startTime
END				
				   
GO  
