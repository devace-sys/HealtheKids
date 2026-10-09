USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.YEAR_RANGE_SEQUENCE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.YEAR_RANGE_SEQUENCE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[YEAR_RANGE_SEQUENCE] 
(@startYear  INT,
 @endYear    INT 
 )    

 /***************************************************************************    
  * YEAR_RANGE_SEQUENCE */    
 /**    
  * Generates sequence of year ranges.  You are limited to 100
  *    
  * @param  startYear       Start date
  * @param  endYear         End date
  * @return                 Table of years (ints)
  ***************************************************************************/     

RETURNS TABLE
AS
RETURN
(     
with

/*============================================================
 * Recursive generation loop
 *============================================================*/  

cte_year_vals as
(
  /* Init */

  select   
    @startYear          as [startYearVal], 
    @startYear + 1      as [endYearVal]
  union all  

  /* Recursive execution */

  select 
    yv.startYearVal + 1 as [startYearVal], 
    yv.endYearVal   + 1 as [endYearVal] 
  from cte_year_vals as yv
  where yv.endYearVal < @endYear  
)
,

/*============================================================
 * Generates string values of year values and limits output
 * to 100.  Note: The 100 limit is to avoid a recursion limit.
 *============================================================*/  
 
cte_year_vals_strs
as
(
select top 100 
  *,
  convert(varchar(4),[startYearVal]) as [startYearStr],
  convert(varchar(4),[endYearVal])   as [endYearStr]
from cte_year_vals
)
,

/*============================================================
 * Generates range values 
 *============================================================*/  

cte_year_ranges
as
(
  select
    *,
    [startYearStr] + '-' + [endYearStr] as [yearRange]
  from cte_year_vals_strs
)

/*============================================================
 * Output
 *============================================================*/  

select * from cte_year_ranges
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[YEAR_RANGE_SEQUENCE] TO [webuser]
GO

  