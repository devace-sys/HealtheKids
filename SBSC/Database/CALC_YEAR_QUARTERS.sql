USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_YEAR_QUARTERS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_YEAR_QUARTERS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_YEAR_QUARTERS] (
    @startCentury  as int
  , @startMonth    as int 
) 

RETURNS 

@quarters table (
    centuryLabel  varchar(9)
  , qtr           int
  , startDate     date
  , endDate       date
)

AS     
BEGIN

/*============================================================
 * Check for bad parameters
 *============================================================*/  

if (isnull(@startCentury, -1) < 0)    return
if (isnull(@startMonth,0) = 0)        return
if (@startMonth not between 1 and 12) return
 
/*============================================================
 * Calculate our reference points
 *============================================================*/  

declare @yrStartDate  as date = DATEFROMPARTS(@startCentury,@startMonth,1)
declare @yrEndDate    as date = DATEADD(day,-1,(DATEADD(year,1,@yrStartDate)))
declare @endCentury   as int  = DATEPART(year,@yrEndDate)

/*============================================================
 * Generate century label
 *============================================================*/  

declare @centurylabel as varchar(12) = iif( (@startCentury != @endCentury)
                                           , convert(varchar,@startCentury) + '-' + convert(varchar,@endCentury)
							  		       , convert(varchar,@startCentury))

/*============================================================
 * Init working vars
 *============================================================*/  

declare @qtrStartDate as date = null
declare @qtrEndDate   as date = null
declare @qtr          as int  = null
declare @monthCtr     as int  = 0

/*============================================================
 * Generate quarters and insert into output table
 * 
 * Quarter number (@qtr) calculation is a modifed version of 
 * Granger's calculation https://stackoverflow.com/a/40096562
 *============================================================*/  

while (@monthCtr < 12)
begin
  set @qtrStartDate = DATEADD(month,@monthCtr,@yrStartDate)
  set @qtrEndDate   = DATEADD(day,-1,(DATEADD(month,3,@qtrStartDate)))
  set @qtr          = (FLOOR(((12 + MONTH(@qtrStartDate) - @startMonth) % 12) / 3 ) + 1)
  insert into @quarters select @centuryLabel, @qtr, @qtrStartDate, @qtrEndDate
  set @monthCtr = @monthCtr + 3
end

/*============================================================
 * All done - Exit
 *============================================================*/  
 
return
end 

GO


/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CALC_YEAR_QUARTERS] TO [webuser]
GO 
