USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_PROCEDURES_GROUPS_SERVICE_CLASS_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_PROCEDURES_GROUPS_SERVICE_CLASS_DATA
GO


CREATE FUNCTION [dbo].[CLAIM_PROCEDURES_GROUPS_SERVICE_CLASS_DATA] ()
RETURNS TABLE AS 
RETURN

/***************************************************************************    
 * CLAIM_PROCEDURES_GROUPS_SERVICE_CLASS_DATA */    
/**    
 * 
 *
 * @return table
 ***************************************************************************/     

with

/******************************************************************************
 *
 * Create all POSSIBLE service plan type + service type combinations
 *
 * Note: Since a cross join is used, when you look at the execution plan
 *       SQL Server will warn you that you are joining without a predicate
 *       which would normally be bad... but that is exactly WHAT we want to
 *       do here, so ignore the warning.
 *
 ******************************************************************************/

cte_p1
as
(
  select 
   t3.*
  from
  (
    select 
        t1.*   
      , t2.*
    from       dbo.CLAIM_PROCEDURES_SERVICE_PLAN_TYPES_SERVICE_TYPES        as t1 
    cross join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA   as t2
  ) as t3

  cross apply (
    select 
      * 
    from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_SERVICE_TYPES as t4
    where (
          (t4.GROUP_SERVICE_CLASS_PARTITION_ID = t3.GROUP_SERVICE_CLASS_PARTITION_ID)
      and (t4.GROUP_SERVICE_CLASS_NAME_ID      = t3.GROUP_SERVICE_CLASS_NAME_ID)
      and (    
            ( 
                   (t4.SERVICE_TYPE_ID        = t3.SERVICE_TYPE_ID)
               and (t4.SERVICE_SUB_TYPE_1_ID  = t3.SERVICE_SUB_TYPE_1_ID)
            )
            or  
            (
                   (t4.SERVICE_TYPE_ID               = t3.SERVICE_TYPE_ID)
               and (t4.SERVICE_SUB_TYPE_1_ID is null)
            )
          )
    )
  ) as t5
)
,

/******************************************************************************
 *
 * Create ACTUAL service plan type + service type combinations
 * We only want to show combinations that the practitioner group can actually
 * render.
 *
 ******************************************************************************/

cte_p2
as
(
  select 
  
      gdpd.*
    , sd.SERVICE_NAME_ID
    , sd.PROCEDURE_HAS_GT
    , sd.PROCEDURE_START_DATE
    , sd.PROCEDURE_END_DATE
    
  from cte_p1 as gdpd

  cross apply (

    select 
    
        svac.SERVICE_NAME_ID
      , svac.PROCEDURE_HAS_GT
      , svac.PROCEDURE_START_DATE
      , svac.PROCEDURE_END_DATE

    from dbo.SERVICES_VIEW_ALL_CORE (  null
                                     , null
                                     , gdpd.SERVICE_PLAN_TYPE_ID
                                     , gdpd.SERVICE_TYPE_ID
                                     , null
                                     , null
                                     , null
                                     , null
                                     , null) as svac
  
    where ( 
          (svac.PROCEDURE_IS_SERVICE_SELECTION = 1)
      and (svac.GROUP_ID                       = gdpd.GROUP_ID)
      and ((svac.SERVICE_SUB_TYPE_1_ID is null) or (svac.SERVICE_SUB_TYPE_1_ID = gdpd.SERVICE_SUB_TYPE_1_ID))
    )
  ) as sd
)
,
cte_p3
as
(
  select 
    GENERAL_SERVICE_PLAN_GROUP_NAME = 
              t2.GENERAL_SERVICE_PLAN_NAME
    + ' - ' + t1.GROUP_SERVICE_CLASS_NAME 
    + ' - ' + t3.GENERAL_SERVICE_NAME 
    + case when (t1.SERVICE_SUB_TYPE_1_NAME is not null) then (' - ' + t1.SERVICE_SUB_TYPE_1_NAME) else '' end

  , t1.GROUP_SERVICE_CLASS_PARTITION_ID
  , t1.GROUP_SERVICE_CLASS_PARTITION_NAME
  , t1.GROUP_SERVICE_CLASS_NAME_ID
  , t1.GROUP_SERVICE_CLASS_NAME
  , t1.PARENT_GROUP_ID
  , t1.GROUP_BASE
  , t1.GROUP_ID
  , t1.SERVICE_PLAN_TYPE_ID
  , t1.SERVICE_TYPE_ID
  , t1.SERVICE_SUB_TYPE_1_ID
  , t1.SERVICE_NAME_ID
  , t1.PROCEDURE_START_DATE
  , t1.PROCEDURE_END_DATE
  , t1.PROCEDURE_HAS_GT 
  , GENERAL_SERVICE_PLAN  = t2.GENERAL_SERVICE_PLAN_NAME  
  , GENERAL_SERVICE_GROUP = t1.GROUP_SERVICE_CLASS_NAME
  , t3.GENERAL_SERVICE_NAME         
  , t2.IEP_OR_IFSP
  
  from cte_p2                                     as t1
  join dbo.CLAIM_PROCEDURES_GENERAL_SERVICE_PLANS as t2 on t2.PLAN_TYPE_ID    = t1.SERVICE_PLAN_TYPE_ID
  join dbo.CLAIM_PROCEDURES_GENERAL_SERVICE_NAMES as t3 on t3.SERVICE_TYPE_ID = t1.SERVICE_TYPE_ID
)

select distinct 
* 
from cte_p3
 
GO


