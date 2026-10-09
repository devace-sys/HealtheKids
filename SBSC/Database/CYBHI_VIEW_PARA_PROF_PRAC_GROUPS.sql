
use SPEDMON 
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_VIEW_PARA_PROF_PRAC_GROUPS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_VIEW_PARA_PROF_PRAC_GROUPS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CYBHI_VIEW_PARA_PROF_PRAC_GROUPS (
)
RETURNS 
TABLE
WITH SCHEMABINDING
AS
RETURN
(
with
cte_p1
as
(
  select 
     GROUP_ID = convert(int,q1.[value]) 
   , SPI_ROSTER_PROVIDER_TYPE_ID = 'P' 
   , REQUIRES_SUPERVISION        = 0
   , IS_CLAIMING_PRAC_IN_837     = 0
   , SPI_ROSTER_INCLUDE_LIC_DATA = 1
  from
  (
    select 
      t1.[value] 
    from STRING_SPLIT('280', ',') as t1 
	--280   AOD
  ) as q1
)
,
cte_p2
as
(
  select 
     GROUP_ID = convert(int,q1.[value]) 
   , SPI_ROSTER_PROVIDER_TYPE_ID = 'I'
   , REQUIRES_SUPERVISION        = 0
   , IS_CLAIMING_PRAC_IN_837     = 1
   , SPI_ROSTER_INCLUDE_LIC_DATA = 0
  from
  (
    select 
      t1.[value] 
    from STRING_SPLIT('282, 289' , ',') as t1
    --282	Community Health Worker
    --289	Certified Wellness Coach

  ) as q1
)
,
cte_p3
as
(
  select 
      p1.GROUP_ID
    , p1.SPI_ROSTER_PROVIDER_TYPE_ID
    , p1.REQUIRES_SUPERVISION
    , p1.IS_CLAIMING_PRAC_IN_837
	, p1.SPI_ROSTER_INCLUDE_LIC_DATA
  from cte_p1 as p1
  
  union all
  
  select 
      p2.GROUP_ID
    , p2.SPI_ROSTER_PROVIDER_TYPE_ID
    , p2.REQUIRES_SUPERVISION
    , p2.IS_CLAIMING_PRAC_IN_837 
    , p2.SPI_ROSTER_INCLUDE_LIC_DATA
  from cte_p2 as p2
)

select 
    p3.GROUP_ID
  , p3.SPI_ROSTER_PROVIDER_TYPE_ID
  , p3.REQUIRES_SUPERVISION
  , p3.IS_CLAIMING_PRAC_IN_837
  , p3.SPI_ROSTER_INCLUDE_LIC_DATA
from cte_p3 as p3

)
GO
