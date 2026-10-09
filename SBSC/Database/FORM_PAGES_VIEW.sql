USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_PAGES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_PAGES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FORM_PAGES_VIEW]
(@userID      BIGINT,    
 @userGroup   INT,    
 @userRank    INT,
 @formRequestID         varchar(1000),
 @formDefinitionID      bigint,
 @formPageDefinitionID  bigint
)
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
    ff.id        as formID
  , fp.id        as formPageID
  , fpt.pageType 
  , ff.formTitle 
  , fp.pageTitle   
  , fp.pageInstructions
from dbo.FORM_FORM                      as ff
join dbo.FORM_PAGES                     as fp  on fp.formID = ff.id
join dbo.FORM_PAGE_TYPES                as fpt on fpt.id    = fp.formPageType
where 
((ff.id = @formDefinitionID) and (fp.id = @formPageDefinitionID))


)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FORM_PAGES_VIEW] TO [webuser]
GO
