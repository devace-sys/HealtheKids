USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_FORM_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_FORM_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FORM_FORM_VIEW]
(@userID             BIGINT,    
 @userGroup          INT,    
 @userRank           INT,
 @formRequestID      varchar(1000),
 @formDefinitionID   bigint)

RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * FORM_FORM_VIEW */
/**
 * Displays user data
 *
 * @param  clientID        ID of client or null for all clients
 * @param  roleID          user's username or null
 * @param  appName         user's email or null 
 * @return                 Table of user data
 ***************************************************************************/ 

select 
    ff.id              as formID
  , ff.formTitle       as formTitle
  , ff.formInstructions
  , ff.openInNewWindow
  , ff.startFormPageID
  , ff.endFormPageID
  , ff.active
from FORM_FORM                as ff
where 
  ((ff.id = @formDefinitionID))
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FORM_FORM_VIEW] TO [webuser]
GO
