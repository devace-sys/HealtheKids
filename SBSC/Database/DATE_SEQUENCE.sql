USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_SEQUENCE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_SEQUENCE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[DATE_SEQUENCE] 
(@startDate  DATETIME,
 @endDate    DATETIME
 )    

 /***************************************************************************    
  * DATE_SEQUENCE */    
 /**    
  * Generates sequence of dates
  *    
  * @param  startDate       Start date
  * @param  endDate         End date
  * @return                 Table of dates
  ***************************************************************************/     

RETURNS
@dates TABLE
(
  date datetime
)
as
begin
  
  if @startDate is null return  
  if @endDate   is null return
  
  ;with DateTable as
  (
    select @startDate as date
    union all
    select dateadd(day, 1, dt.date) from DateTable as dt where dt.date < @endDate
  )
  insert into @dates(date)
  select date
  from DateTable option (maxrecursion 32767)
  
  return
end

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[DATE_SEQUENCE] TO [webuser]
GO

  