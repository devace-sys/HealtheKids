USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPATION_ROSTER_BY_QUARTERNUM_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RMTS_PARTICIPATION_ROSTER_BY_QUARTERNUM_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RMTS_PARTICIPATION_ROSTER_BY_QUARTERNUM_VIEW] (
    @clientID       BIGINT
  , @active         BIT
  , @recID          BIGINT
  , @quarterNum     int
)    
RETURNS 
TABLE
AS
RETURN
(

  select top (dbo.CONST_MAX_ROWS())
	rpr.*

       , fyq.fy_ID fyID

  from dbo.RMTS_PARTICIPATION_ROSTER as rpr

  join  dbo.COMPANY_FISCAL_QUARTERS   as fyq on fyq.id        = rpr.quarterID

  where ((1=1)
     and (rpr.clientID = @clientID)
	 and (fyq.fy_ID = @recID)
   and (fyq.QTR = @quarterNum)
	 and ((@active is null) or (rpr.active = @active))
  )
)
GO

GRANT SELECT ON  [dbo].[RMTS_PARTICIPATION_ROSTER_BY_QUARTERNUM_VIEW] TO [webuser]
GO
