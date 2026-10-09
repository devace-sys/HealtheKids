USE SPEDMON
GO
 

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONTACT_METHODS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONTACT_METHODS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CONTACT_METHODS_VIEW] (
      @userID    BIGINT
    , @userGroup BIGINT    
    , @userRank  INT     
    , @term      VARCHAR(256)
    , @active    BIT
)
    
RETURNS TABLE
AS
RETURN
(
    SELECT
          id = cm.code,
		  name = cm.name
    FROM dbo.CONTACT_METHODS AS cm
    WHERE
        (cm.active = 1 OR @active IS NULL)
)
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CONTACT_METHODS_VIEW] TO [webuser]
GO