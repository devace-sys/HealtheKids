USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Patient_Scheduled_Service_Occurs_On_RefDate') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Practitioner_Patient_Scheduled_Service_Occurs_On_RefDate
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.Practitioner_Patient_Scheduled_Service_Occurs_On_RefDate ( 
    @refDate    date
  , @dow        int 
  , @recurring  bit
  , @startDate  date
  , @endDate    date
  , @mon        bit
  , @tue        bit
  , @wed        bit
  , @thu        bit
  , @fri        bit
)
 
RETURNS bit
AS     
BEGIN        

if @endDate is null set @endDate = convert(date,dbo.CONST_MAX_DATETIME())

/* If ref date is between start and end date */

if (@refDate between @startDate and @endDate)
begin

  /* Not recurring */

  if (@recurring = 0)
  begin
    return 1
  end /* Not Recurring */
  
  /* Recurring*/

  else
  begin    
    if (@dow in (0,6)) return 0  /*  No weekend days */
    return case 
      when @dow = 1 then @mon
      when @dow = 2 then @tue
	  when @dow = 3 then @wed
      when @dow = 4 then @thu
      when @dow = 5 then @fri
      else 0
    end
  end /* Recurrimg*/ 
end /* Ref date is between start and end date*/

/* Ref date is not between start and end */
else
begin
  return 0
end /* Ref date is not between start and end date*/

/* Should never get here but have to provide a return*/
return 0

END				
				   
GO  
