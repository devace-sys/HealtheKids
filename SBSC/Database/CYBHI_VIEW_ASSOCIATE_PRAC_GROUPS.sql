
use SPEDMON 
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_VIEW_ASSOCIATE_PRAC_GROUPS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_VIEW_ASSOCIATE_PRAC_GROUPS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CYBHI_VIEW_ASSOCIATE_PRAC_GROUPS (
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
    t1.[value] 
  from STRING_SPLIT('247,248,281,288', ',') as t1
)

select 
    GROUP_ID = convert(int,p1.[value]) 
  , SPI_ROSTER_PROVIDER_TYPE_ID = 'P'
  , REQUIRES_SUPERVISION        = 1
  , IS_CLAIMING_PRAC_IN_837     = 0
  , SPI_ROSTER_INCLUDE_LIC_DATA = 1
from cte_p1 as p1

)
GO
