USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPATION_ROSTER_BY_QUARTER_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RMTS_PARTICIPATION_ROSTER_BY_QUARTER_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RMTS_PARTICIPATION_ROSTER_BY_QUARTER_VIEW] (
    @clientID       BIGINT
  , @active         BIT
  , @recID          BIGINT
)    
RETURNS 
TABLE
AS
RETURN
(
  select

  top (dbo.CONST_MAX_ROWS())

	rpr.*, cfq.FY_ID, cfq.QTR quarterNum

  from dbo.RMTS_PARTICIPATION_ROSTER as rpr
  JOIN dbo.COMPANY_FISCAL_QUARTERS   as cfq
    ON cfq.ID = rpr.quarterID
  where ((1=1)
     and (rpr.clientID = @clientID)
	 and (rpr.quarterID = @recID)
	 and ((@active is null) or (rpr.active = @active))
  )
)
GO

GRANT SELECT ON  [dbo].[RMTS_PARTICIPATION_ROSTER_BY_QUARTER_VIEW] TO [webuser]
GO
