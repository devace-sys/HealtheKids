USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_PAGES_PARTS_REQ_ENT_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_PAGES_PARTS_REQ_ENT_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FORM_PAGES_PARTS_REQ_ENT_VIEW]
(@userID                BIGINT,    
 @userGroup             INT,    
 @userRank              INT,
 @formRequestID         varchar(1000),
 @formDefinitionID      bigint,
 @formPageDefinitionID  bigint
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * FORM_PAGES_PARTS_REQ_ENT_VIEW */
/**
 * Displays user data
 *
 * @param  formRequestID         Unique ID for form request
 * @param  formDefinitionID      Form Form ID
 * @param  formPageDefinitionID  Form Page ID 
 * @return                       Table of form page parts
 ***************************************************************************/ 

with
/*###########################################################################
  # Form fields base
  ###########################################################################*/    
cte_fields_base
as
(
  select 
    fpp.*
  from FORM_FORM        as ff 
  join FORM_PAGES       as fp  on fp.formID      = ff.id
  join FORM_PAGES_PARTS as fpp on fpp.formPageID = fp.id
)
,

/*###########################################################################
  # Form Fields on Page With Req Entities
  ###########################################################################*/  
    
cte_fields_on_page_with_req_ent
as
(
select 
  fpp.*
from cte_fields_base as fpp
where 
((fpp.formID = @formDefinitionID) and (fpp.formPageID = @formPageDefinitionID) and ((selectReqEntId1 is not null) or (selectReqEntId2 is not null)))
)
,

/*###########################################################################
  # Form Fields on Page With Req Entities Ids
  ###########################################################################*/  
  
cte_fields_on_page_req_ent_ids
as
(
  select distinct id from
  (
    select selectReqEntId1 as [id] from cte_fields_on_page_with_req_ent
    union
    select selectReqEntId2 as [id] from cte_fields_on_page_with_req_ent
  ) as q1
  where id is not null
)
,

/*###########################################################################
  # Form Fields on Page 
  ###########################################################################*/  

cte_fields_on_page_ids
as
(
  select 
    fpp.id as id
  from cte_fields_base as fpp
  where 
  ((fpp.formID = @formDefinitionID) and (fpp.formPageID = @formPageDefinitionID))
)
,

/*###########################################################################
  # Required Entity Ids To Use (excludes form fields on page with same id)
  ###########################################################################*/
    
cte_fields_req_ent_ids_to_use
as
(
  select id 
  from cte_fields_on_page_req_ent_ids
  where id not in (
    select id from cte_fields_on_page_ids)
)
,

/*###########################################################################
  # Required Entity Parts We Are Going to Use
  ###########################################################################*/

cte_fields_on_page_req_ent_page_parts
as
(
select fpp.* 
from FORM_PAGES_PARTS as fpp
join cte_fields_req_ent_ids_to_use as f3 on f3.id = fpp.id
)
,

/*###########################################################################
  # Output
  ###########################################################################*/
  
cte_fields_output
as
(
select 

    convert(varchar,fpp.id)              as id
  , convert(varchar,fpp.id)              as name
  , coalesce (fpps.value,fpp.value)      as value
from cte_fields_on_page_req_ent_page_parts as fpp
left join FORM_PAGES_PARTS_SUBMITTED as fpps on fpps.formPagePartDefinitionID = fpp.id
                                                and fpps.formRequestID = @formRequestID
)



select * from cte_fields_output
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FORM_PAGES_PARTS_REQ_ENT_VIEW] TO [webuser]
GO
