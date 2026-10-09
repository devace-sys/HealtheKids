USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICES_VIEW_BY_PLAN_TYPE_GROUP_ID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICES_VIEW_BY_PLAN_TYPE_GROUP_ID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/    
    
CREATE FUNCTION [dbo].[SERVICES_VIEW_BY_PLAN_TYPE_GROUP_ID] ( 
    @userID      BIGINT    
  , @userGroup   INT    
  , @userRank    INT
  , @planType    INT
  , @groupID     INT
  , @term        VARCHAR(256)
) 

RETURNS TABLE 

/***************************************************************************    
 * SERVICES_VIEW_BY_PLAN_TYPE_GROUP_ID */    
/**    
 ***************************************************************************/     

AS RETURN
(      
with 
cte_p1
as
(
  select 
      sva.SERVICE_NAME_ID
    , sva.SERVICE_PLAN_TYPE_ID
	, sva.SERVICE_PLAN_TYPE
	, sva.SERVICE_NAME     -- used for the name ID dropdown widget, DataEntryRowSelectServiceName
	, sva.SERVICE_TYPE
	, sva.SERVICE_TYPE_ID
	, SERVICE_SUB_TYPE_1 = isnull(sva.SERVICE_SUB_TYPE_1,'')
	, sva.SERVICE_SUB_TYPE_1_ID
	, sva.GROUP_ID
	, sva.GROUP_NAME
	, sva.CALPADS_SPED_SVC_CODE_NAME
	, sva.CALPADS_SPED_SVC_CODE_VALUE
	
  from dbo.SERVICES_VIEW_ALL_CORE (null, @groupID,@planType,null,null,1,1,null,1) as sva
  
  where (
        (sva.GROUP_IS_ACTIVE = 1)
    and ((@term is null) or (sva.SERVICE_NAME like (@term + '%')))
  )
)
, 
cte_p2
as
(
  select distinct p1.* from cte_p1 as p1
)
select top (dbo.CONST_MAX_ROWS()) 
  p2.* 
from cte_p2 as p2
order by 
   p2.SERVICE_TYPE_ID
 , isnull(p2.SERVICE_SUB_TYPE_1_ID,0)
 , p2.SERVICE_NAME
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICES_VIEW_BY_PLAN_TYPE_GROUP_ID] TO [webuser]
GO