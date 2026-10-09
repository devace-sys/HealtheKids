USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_IN_WHAT_FY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_IN_WHAT_FY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[DATE_IN_WHAT_FY] (@dateIn DATETIME, @fyStartMonth INT) 

RETURNS @recs TABLE (number int, 
                     [month] int, 
                     [year] int, 
                     [quarter] int, 
                     [year1] int, 
                     [year2] int,
                     [year12] varchar(9))
AS     
BEGIN
    
/*-------------------------------
 * Setup defaults
 *------------------------------*/

if (@dateIn is null) set @dateIn = GETDATE()
if (@fyStartMonth is null) set @fyStartMonth = 7

/*-------------------------------
 * Setup working variables
 *------------------------------*/

declare @year as int
declare @year_p1 as int
declare @year_m1 as int
declare @month   as int

set @year  = datepart(year,  @dateIn)
set @month = datepart(month, @dateIn)

set @year_m1 = @year - 1
set @year_p1 = @year + 1

insert into @recs 
select *
from dbo.CALC_12_MONTH_TABLE(@fyStartMonth,@year_m1)
where [year] = @year and [month] = @month
union
select * from dbo.CALC_12_MONTH_TABLE(@fyStartMonth,@year)
where [year] = @year and [month] = @month
union
select * from dbo.CALC_12_MONTH_TABLE(@fyStartMonth,@year_p1)
where [year] = @year  and [month] = @month

 /*-------------------------------
  * All done, exit
  *------------------------------*/
  
return
end

GO

GRANT SELECT ON SPEDMON.dbo.DATE_IN_WHAT_FY TO webuser;

GO
