USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPANTS_EXCLUDED_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RMTS_PARTICIPANTS_EXCLUDED_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RMTS_PARTICIPANTS_EXCLUDED_VIEW] (
    @userID         BIGINT    
  , @userGroup      BIGINT    
  , @userRank       INT
  , @clientID       bigint
  , @rosterID       bigint
)    
RETURNS 
TABLE
AS
RETURN
(
  select top (dbo.CONST_MAX_ROWS())
    rp.* 
  from [dbo].[RMTS_PARTICIPANTS_EXCLUDED_VIEW_CORE] (@clientID, @rosterID) as rp
  order by 
    rp.[name] asc
)
GO

GRANT SELECT ON  [dbo].[RMTS_PARTICIPANTS_EXCLUDED_VIEW] TO [webuser]
GO
