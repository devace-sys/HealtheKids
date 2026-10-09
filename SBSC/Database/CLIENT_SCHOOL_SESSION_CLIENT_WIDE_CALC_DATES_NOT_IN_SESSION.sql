USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_SCHOOL_SESSION_CLIENT_WIDE_CALC_DATES_NOT_IN_SESSION') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_SCHOOL_SESSION_CLIENT_WIDE_CALC_DATES_NOT_IN_SESSION
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLIENT_SCHOOL_SESSION_CLIENT_WIDE_CALC_DATES_NOT_IN_SESSION] (
    @clientID    bigint
  , @startDate   datetime
  , @endDate     datetime
)   

returns 
table 
as
return
(

/*============================================================
 * Calculate breaks betwen school years
 *===========================================================*/  

with
cte_breaks_between_school_years_1
as
(
 select    
      breakName  = 'Break between ' 
	             + csa.name 
		   	     + ' and ' 
			     + LEAD(csa.[name],1,'TBD') over (partition by csa.clientID order by csa.startDate, csa.endDate)
    , startDate = dateadd(day,1,csa.endDate)
    , endDate   = dateadd(day,-1,(LEAD(csa.startDate,1,dateadd(year,1,csa.endDate)) over (partition by csa.clientID order by csa.startDate, csa.endDate)))
  from dbo.[CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS] as csa
  where (
        (csa.clientID = @clientID)
    and (csa.active = 1)
  )
)
,

/*============================================================
 * Apply filter to calculated breaks betwen school years
 * (StartA <= EndB) and (EndA >= StartB)
 *===========================================================*/  

cte_breaks_between_school_years_2
as
(
select 
  p1.* 
from cte_breaks_between_school_years_1 as p1
where (
        (1=1)
	and ((@startDate is null) or (@startDate <= p1.endDate))
	and ((@endDate   is null) or (@endDate >= p1.startDate))

  )
)
,
/*============================================================
 * Other breaks
 *===========================================================*/  

cte_other_breaks
as
(

  select 
      breakName = csa.[name] + ' - ' + csb.[name]
    , startDate = csb.startDate
    , endDate   = csb.endDate
  from dbo.[CLIENT_SCHOOL_SESSION_BREAKS]         as csb
  join dbo.[CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS] as csa on csa.id = csb.academicYearID
  where ( 
        (csb.clientID = @clientID)
	and (csb.siteID is null)
	and ((@endDate   is null) or (csb.endDate <= @endDate))
    and ((@startDate is null) or (csb.startDate >= @startDate))
    and (csb.clientWideBreak = 1) 
	and (csb.active = 1)
  )
)

select t1.* from cte_breaks_between_school_years_2 as t1
union all
select t2.* from cte_other_breaks as t2


) 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_SCHOOL_SESSION_CLIENT_WIDE_CALC_DATES_NOT_IN_SESSION] TO [webuser]
GO