USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPANTS_POSSIBLE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RMTS_PARTICIPANTS_POSSIBLE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RMTS_PARTICIPANTS_POSSIBLE_VIEW] (
     @userID         BIGINT    
   , @userGroup      BIGINT    
   , @userRank       INT
   , @clientID       bigint
   , @term           varchar(256)
)    
 
RETURNS 
TABLE
AS
RETURN
(
  select top (dbo.CONST_MAX_ROWS())
    rp.* 
  from [dbo].[RMTS_PARTICIPANTS_POSSIBLE_VIEW_CORE] (@clientID) as rp
  where 
    (rp.[name] like (((isnull(@term,'')) + '%')))
  order by 
    rp.[name] asc
)

GO

GRANT SELECT ON  [dbo].[RMTS_PARTICIPANTS_POSSIBLE_VIEW] TO [webuser]
GO
