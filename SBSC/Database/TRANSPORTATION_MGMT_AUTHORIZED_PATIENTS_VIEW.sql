USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @transMgmtID            BIGINT
 , @patID                  BIGINT
 , @term                   varchar(255)
 , @active                 BIT    
 , @recID                  BIGINT )

RETURNS TABLE
AS
RETURN
(

with
cte_p1
as
(
  select 
    t1.* 
  from dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW_CORE (   @userID
                                                               , @userGroup
                                                               , @userRank
                                                               , @clientID
                                                               , @transMgmtID
                                                               , @patID
                                                               , @active
                                                               , @recID ) as t1
  where (
        (1=1)
    and ((@term is null) or (t1.name like (isnull(@term,'') + '%')))  
  )
)
,
cte_p2
as
(
 select 
     p1.*
   , assignedRouteCount = isnull(rteCtr.assignedRouteCount,0)
   , rteNames.assignedRouteNames
 from cte_p1 as p1
 outer apply (
    select 
	  assignedRouteCount = count(t1.ID)
	from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS as t1
    join dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES        as t2 on t2.ID = t1.ROUTE_ID
    where (
           (t1.PATIENT_ID = p1.patID)
       and (t1.ACTIVE = 1)
     )
	 group by 
	   t1.PATIENT_ID
 ) as rteCtr

 outer apply (
   select 
     assignedRouteNames = trim(isnull(t3.assignedRouteNames,'** No Routes Assigned **'))
   from 
   (
     select   
       assignedRouteNames = STRING_AGG('*' + t2.[NAME],(char(13)+char(10))) 
     from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS as t1
     join dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES        as t2 on t2.ID = t1.ROUTE_ID
     where (
           (t1.PATIENT_ID = p1.patID)
       and (t1.ACTIVE = 1)
     )
   ) as t3
 ) as rteNames


)
select top (dbo.CONST_MAX_ROWS()) 
  p2.* 
from cte_p2 as p2
order by 
  p2.name                                                       

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW] TO [webuser]
GO