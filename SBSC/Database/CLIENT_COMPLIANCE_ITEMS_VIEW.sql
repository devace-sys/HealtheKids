USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_COMPLIANCE_ITEMS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_COMPLIANCE_ITEMS_VIEW
GO




/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLIENT_COMPLIANCE_ITEMS_VIEW] (
    @userID               BIGINT
  , @userGroup            INT  
  , @userRank             INT 
  , @taskID			      BIGINT
  , @active			      BIT
  , @recID                BIGINT
)    

RETURNS TABLE
   
AS RETURN

select 
  cct.* 
from dbo.CLIENT_COMPLIANCE_ITEMS_VIEW_CORE (
	  @taskID
	, @active
	, @recID

) as cct

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_COMPLIANCE_ITEMS_VIEW] TO [webuser]
GO  