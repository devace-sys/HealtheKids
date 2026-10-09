USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICES_TMT_TCM_TRAN_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICES_TMT_TCM_TRAN_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/    
    
CREATE FUNCTION [dbo].[SERVICES_TMT_TCM_TRAN_VIEW] ( 
    @userID                   BIGINT
  , @userGroup                INT  
  , @userRank                 INT
  , @clientID                 BIGINT    
  , @pracID                   BIGINT
  , @svcNamesListDataSourceID smallint
  , @dos                      DATETIME
  , @term                     VARCHAR(100)
) 

RETURNS TABLE 

/***************************************************************************    
 * SERVICES_TMT_TCM_TRAN_VIEW */    
/**    
 * Returns a table of services that match the given parameters
 * 
 * 
 * @param  clientID        ID of client    
 * @param  pracID          ID of practitioner
 * @param  dos             Date of service
 * @param  term            All or part of services name
 * @return                 Table of services data
 ***************************************************************************/     

AS RETURN(      

with
cte_prac_group
as
(
  select top 1 

      prc.CLIENT_ID
    , prp.PRACTITIONER_ID
    , pg.GROUP_ID 
 
  from dbo.CLIENTS_Client            as cc 
  join dbo.PRACTITIONER_Client       as prc on prc.CLIENT_ID       = cc.CLIENT_ID 
  join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
  join dbo.PRACTITIONER_GROUPS       as pg  on pg.PRACTITIONER_ID  = prp.PRACTITIONER_ID

  where (
        ( cc.CLIENT_ID        = @clientID)
    and ( prp.PRACTITIONER_ID = @pracID )
    and ( pg.GROUP_TYPE in (1,2) )
  )
)
,
cte_prac_group_svcs
as
(
  select distinct     
      svac2.SERVICE_NAME_ID
    , svac2.PROCEDURE_CODE
    , svac2.SERVICE_NAME
    , svac2.SERVICE_TYPE_ID    
    , svac2.SERVICE_IS_IND_OR_GRP
    , svac2.SERVICE_ENTRY_SVC_SELECTION_SHOW_OPTIONS_3
    , svac2.SERVICE_RENDERED_VIA
  from cte_prac_group as pg
  
  cross apply (
    select 
	  svac1.* 
    from dbo.SERVICES_VIEW_ALL_CORE (   pg.CLIENT_ID
                                      , pg.GROUP_ID
                                      , null
                                      , null
                                      , null
                                      , 1
                                      , 1
                                      , @dos
                                      , 1) as svac1
    where ( 
	      (svac1.SERVICE_NAME_LIST_DATA_SOURCE_ID = @svcNamesListDataSourceID)      
      and (svac1.SERVICE_TYPE_ID in (   dbo.CONST_SERVICES_TREATMENT()
                                      , dbo.CONST_SERVICES_TCM()
                                      , dbo.CONST_SERVICES_NON_BILL()))  
    )
  ) as svac2
)
,
cte_svc_sel
as
(
  select 
      [id] = ROW_NUMBER () over (order by SERVICE_NAME, SERVICE_TYPE_ID, SERVICE_IS_IND_OR_GRP) 
    , SERVICE_NAME_ID
    , SERVICE_NAME
    , PROCEDURE_CODE
    , SERVICE_TYPE_ID
    , SERVICE_IS_IND_OR_GRP
	, showOptions3 = SERVICE_ENTRY_SVC_SELECTION_SHOW_OPTIONS_3
	, SERVICE_RENDERED_VIA
  from cte_prac_group_svcs
)
select 
  tout.* 
from cte_svc_sel as tout
where
      (1=1) 
  and ((@term is null) or ((tout.[SERVICE_NAME] like ( '%' + @term + '%'))))
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICES_TMT_TCM_TRAN_VIEW] TO [webuser]
GO