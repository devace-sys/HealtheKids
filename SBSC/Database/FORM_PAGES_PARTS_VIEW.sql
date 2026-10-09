USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_PAGES_PARTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_PAGES_PARTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FORM_PAGES_PARTS_VIEW]
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
 * FORM_PAGES_PARTS_VIEW */
/**
 * Displays user data
 *
 * @param  formRequestID         Unique ID for form request
 * @param  formDefinitionID      Form Form ID
 * @param  formPageDefinitionID  Form Page ID 
 * @return                       Table of form page parts
 ***************************************************************************/ 

select top (dbo.CONST_MAX_ROWS())
    ff.id                                as formID
  , fp.id                                as formPageID
  , fpp.id                               as formPagePartID
  , fppt.partType                        as partType
  , fpptdt.dataType                      as dataType
  , convert(varchar,fpp.id)              as id
  , fpp.label
  , fpp.placeholder
  , convert(varchar,fpp.id)              as name
  , coalesce (fpps.value,fpp.value)      as value
  , coalesce (fpps.selectedCount,'')     as selectedCount
  , coalesce (fpps.selectedNames,'')     as selectedNames
  , fpp.value                            as defaultValue
  , fpp.required
  , fpp.min
  , fpp.max
  , fpp.step
  , isnull(fpp.multiple, 0) as multiple
  , fpp.selectFrom
  , fpp.selectWhat
  , fpp.selectAuto
  , fpp.selectSourceURL
  , convert(varchar,isnull(fpp.selectReqEntId1,''))  as selectReqEntId1 
  , convert(varchar,isnull(fpp.selectReqEntId2,''))  as selectReqEntId2
  , isnull(fppssfw.replaceValue,    0)               as selectReplaceValue
  , isnull(fppssfw.replaceWhoName,  '')              as selectReplaceWhoName
  , isnull(fppssfw.replaceWhoValue, '')              as selectReplaceWhoValue
  , isnull(fppssfw.replaceWithValue,'')              as selectReplaceWithValue
  , fpp.active
  
from      FORM_FORM                              as ff       
join      FORM_PAGES                             as fp       on fp.formID      = ff.id
join      FORM_PAGES_PARTS                       as fpp      on fpp.formPageID = fp.id
join      FORM_PAGE_PART_TYPES                   as fppt     on fppt.id        = fpp.formPagePartType
join      FORM_PAGE_PART_DATA_TYPES              as fpptdt   on fpptdt.id                     = fppt.dataType
left join FORM_PAGE_PART_SELECT_SEARCH_FROM_WHAT as fppssfw  on  fppssfw.selectFrom           = fpp.selectFrom 
                                                             and fppssfw.selectWhat           = fpp.selectWhat
left join FORM_PAGES_PARTS_SUBMITTED             as fpps     on  fpps.formPagePartDefinitionID = fpp.id 
                                                             and fpps.formRequestID            = @formRequestID
where 
((ff.id = @formDefinitionID) and (fp.id = @formPageDefinitionID))

    
order by fpp.displayOrder
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FORM_PAGES_PARTS_VIEW] TO [webuser]
GO
