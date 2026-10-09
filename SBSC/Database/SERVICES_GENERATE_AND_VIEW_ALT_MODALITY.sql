USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICES_GENERATE_AND_VIEW_ALT_MODALITY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICES_GENERATE_AND_VIEW_ALT_MODALITY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
    
CREATE FUNCTION [dbo].[SERVICES_GENERATE_AND_VIEW_ALT_MODALITY] ()
RETURNS 
@serviceSelections table (
    GROUP_ID                                          int
  , SERVICE_PLAN_TYPE_ID                              int
  , SERVICE_NAME_WITHOUT_IN_PERSON_OR_TELEHEALTH_TEXT nvarchar(100)
  , SERVICE_IS_IN_IFSP_IEP                            bit
  , SERVICE_IS_IN_NO_PLAN                             bit
  , SERVICE_IS_IN_CYBHI                               bit
  , SERVICE_IS_IN_RU_HEALTH                           bit
  , SELECTION_FOR_MODALITY_FLAGS                      int
  , SERVICE_NAME_ID                                   int
  , SERVICE_NAME_ID_ALT_MODALITY                      int
  , SERVICE_HAS_NO_ALT_OR_COMMON_MODALITY             bit default(0)
  
  unique clustered (
    GROUP_ID
  , SERVICE_PLAN_TYPE_ID
  , SERVICE_NAME_WITHOUT_IN_PERSON_OR_TELEHEALTH_TEXT
  , SERVICE_IS_IN_IFSP_IEP 
  , SERVICE_IS_IN_NO_PLAN
  , SERVICE_IS_IN_CYBHI 
  , SERVICE_IS_IN_RU_HEALTH
  , SELECTION_FOR_MODALITY_FLAGS
  , SERVICE_NAME_ID

  ) 
)
AS
BEGIN      

insert into @serviceSelections (
    GROUP_ID
  , SERVICE_PLAN_TYPE_ID
  , SERVICE_NAME_WITHOUT_IN_PERSON_OR_TELEHEALTH_TEXT 
  , SERVICE_IS_IN_IFSP_IEP 
  , SERVICE_IS_IN_NO_PLAN
  , SERVICE_IS_IN_CYBHI 
  , SERVICE_IS_IN_RU_HEALTH
  , SELECTION_FOR_MODALITY_FLAGS 
  , SERVICE_NAME_ID 
  , SERVICE_NAME_ID_ALT_MODALITY
)
select 
    gg.GROUP_ID
  , sva2.*
from dbo.GROUP_Group as gg
cross apply (
  select distinct 
      svac.SERVICE_PLAN_TYPE_ID
    , svac.SERVICE_NAME_WITHOUT_IN_PERSON_OR_TELEHEALTH_TEXT 
    , svac.SERVICE_IS_IN_IFSP_IEP 
    , svac.SERVICE_IS_IN_NO_PLAN 
    , svac.SERVICE_IS_IN_CYBHI
	, svac.SERVICE_IS_IN_RU_HEALTH
	, svac.SELECTION_FOR_MODALITY_FLAGS 
    , svac.SERVICE_NAME_ID 
	, SERVICE_NAME_ID_ALT_MODALITY = iif(svac.SELECTION_FOR_MODALITY_FLAGS = 3,svac.SERVICE_NAME_ID,null) 
  from dbo.SERVICES_VIEW_ALL_CORE(null,gg.GROUP_ID,null,null,null,1,1,null,1) as svac
  where 
        (svac.SERVICE_NAME_ID is not null)
    and (svac.PROCEDURE_ACTIVE = 1)
) as sva2

where ((gg.GROUP_TYPE in (1,2)) and (gg.ACTIVE = 1))


update t1 
  set t1.SERVICE_NAME_ID_ALT_MODALITY = t2.SERVICE_NAME_ID
from @serviceSelections as t1
join @serviceSelections as t2 on  ((t2.GROUP_ID                                          = t1.GROUP_ID)
                              and (t2.SERVICE_PLAN_TYPE_ID                               = t1.SERVICE_PLAN_TYPE_ID)
					          and (t2.SERVICE_NAME_WITHOUT_IN_PERSON_OR_TELEHEALTH_TEXT  = t1.SERVICE_NAME_WITHOUT_IN_PERSON_OR_TELEHEALTH_TEXT))
                              	
where ((t1.SELECTION_FOR_MODALITY_FLAGS = 1) and (t2.SELECTION_FOR_MODALITY_FLAGS = 2))

update t1 
  set t1.SERVICE_NAME_ID_ALT_MODALITY = t2.SERVICE_NAME_ID
from @serviceSelections as t1
join @serviceSelections as t2 on  ((t2.GROUP_ID                                          = t1.GROUP_ID)
                              and (t2.SERVICE_PLAN_TYPE_ID                               = t1.SERVICE_PLAN_TYPE_ID)
					          and (t2.SERVICE_NAME_WITHOUT_IN_PERSON_OR_TELEHEALTH_TEXT  = t1.SERVICE_NAME_WITHOUT_IN_PERSON_OR_TELEHEALTH_TEXT))
                              	
where ((t1.SELECTION_FOR_MODALITY_FLAGS = 2) and (t2.SELECTION_FOR_MODALITY_FLAGS = 1))

update @serviceSelections
  set SERVICE_HAS_NO_ALT_OR_COMMON_MODALITY = 1
where (SERVICE_NAME_ID_ALT_MODALITY is null)

RETURN    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICES_GENERATE_AND_VIEW_ALT_MODALITY] TO [webuser]
GO
