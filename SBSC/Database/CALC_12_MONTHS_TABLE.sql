USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_12_MONTH_TABLE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_12_MONTH_TABLE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_12_MONTH_TABLE] (@startMonth INT, @startYear INT) 

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
 * Setup our working variables 
 *------------------------------*/

DECLARE @month  as int
DECLARE @year   as int
DECLARE @year1  as int
DECLARE @year2  as int
DECLARE @year12 as varchar(9)
DECLARE @ctr    as int
DECLARE @qtr    as int

/*-------------------------------
 * If the user does not pass in
 * the start month or year
 * get out
 *------------------------------*/

if (@startMonth is null) return
if (@startYear  is null) return

/*-------------------------------
 * If the user passes in garbage
 * for the start month or year
 * get out.
 *------------------------------*/

if ((@startMonth <= 0) or (@startMonth > 12))   return
if ((@startyear  <= 0) or (@startYear  > 9999)) return

/*-------------------------------
 * Init working variables
 *------------------------------*/

set @month = @startMonth
set @year  = @startYear
set @ctr   = 1
set @qtr   = 1

/*-------------------------------
 * If the month passed in is
 * > 1 then this table will span
 * more than one year.
 *------------------------------*/

if (@month > 1)
begin
  set @year1 = @year
  set @year2 = @year + 1
  set @year12 = convert(varchar(4),@year1) + '-' + convert(varchar(4),@year2)
end
else
begin
  set @year1  = @year
  set @year2  = null
  set @year12 = null
end

/*-------------------------------
 * Iterate 12 times
 *------------------------------*/

while (@ctr < 13)
begin   
   
   /*-------------------------------
    * Save row
    *------------------------------*/

   insert into @recs values (@ctr, @month, @year, @qtr, @year1, @year2, @year12)
   
   /*-------------------------------
    * Update month counter
    * If the month exceeds 12 then
    * we are in a new year
    * so reset count to 1
    *------------------------------*/
   
   set @month = @month + 1
   if (@month > 12)
   begin 
     set @month = 1
     set @year  = @year + 1 
   end
   
   /*-------------------------------
    * Update row ctr
    * Compute quarter.  We have a 
    * new quarter every 3 rows.
    *------------------------------*/

   set @ctr = @ctr + 1
   set @qtr = ((@ctr + 2) / 3)

end

 /*-------------------------------
  * All done, exit
  *------------------------------*/
  
return
end 

GO
