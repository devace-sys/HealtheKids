USE users
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
(@userID      BIGINT,    
 @userGroup   INT,    
 @userRank    INT,
 @clientID    int,
 @roleID      int,
 @appName     varchar(50),
 @formID      bigint,
 @formPageID  bigint)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * FORM_PAGES_VIEW */
/**
 * Displays user data
 *
 * @param  clientID        ID of client or null for all clients
 * @param  roleID          user's username or null
 * @param  appName         user's email or null 
 * @return                 Table of user data
 ***************************************************************************/ 

select 
    ff.id                                                           as formID
  , fp.id                                                           as formPageID
  , fpp.id                                                          as formPagePartID
  , fppt.fieldType
  , convert(varchar,ff.id) + '-' + convert(varchar,fp.id) + '-' + convert(varchar,fpp.id) as id
  , fpp.label
  , fpp.placeholder
  , fpp.name
  , fpp.value
  , fpp.required
  , fpp.min
  , fpp.max
  , fpp.step
  , fpp.active
from      FORM_FORM                      as ff       
join      FORM_PAGES                     as fp       on fp.formID      = ff.id
join      FORM_PAGES_PARTS               as fpp      on fpp.formPageID = fp.id
join      FORM_PAGE_PART_TYPES           as fppt     on fppt.id        = fpp.formPagePartType


where 

((ff.id = @formID) and (fp.id = @formPageID))
    
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FORM_PAGES_PARTS_VIEW] TO [webuser]
GO
