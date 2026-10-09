USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_MISSING_TREATMENTS_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_MISSING_TREATMENTS_DATA_CORE
GO


CREATE FUNCTION [dbo].[RPT_MISSING_TREATMENTS_DATA_CORE] (
   @clientID             bigint  = null
 , @groupSvcClassNameID  bigint  = null
 , @spEdServiceCode      int     = null
 , @patHasBIC            bit     = null
 , @leaBopSvc            bit     = null
 , @missingTmt           bit     = null
 , @svcTrackingClass     int     = null
)
returns
table
as
return
(
with
cte_p1
as
(
select 
  t1.* 
from dbo.RPT_MISSING_TREATMENTS_SPED_DATA_CORE (
    @clientID
  , @groupSvcClassNameID
  , @spEdServiceCode
  , @patHasBIC
  , @leaBopSvc
  , @missingTmt) as t1

union all

select 
  t2.* 
from dbo.RPT_MISSING_TREATMENTS_NON_SPED_DATA_CORE (
    @clientID
  , @groupSvcClassNameID
  , @patHasBIC
  , @leaBopSvc
  , @missingTmt) as t2
)

select 
  p1.*
from cte_p1 as p1
where (
       (1=1)
  and ((@svcTrackingClass is null) or (p1.svcTrackingClass = @svcTrackingClass))
)

)

GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.RPT_MISSING_TREATMENTS_DATA_CORE TO [webuser]
GO