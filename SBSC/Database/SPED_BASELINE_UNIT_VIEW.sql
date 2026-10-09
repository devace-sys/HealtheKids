USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SPED_BASELINE_UNITS_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SPED_BASELINE_UNITS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SPED_BASELINE_UNITS_VIEW] (
       @userID      BIGINT
     , @userGroup   INT
     , @userRank    INT
     , @domain      VARCHAR(50)
     , @term        VARCHAR(256)
)
RETURNS TABLE
AS

RETURN
(
    /*-------------------------------
     * Retrieve records
     *------------------------------*/

    SELECT TOP (dbo.CONST_MAX_ROWS())
           id
         , [name]
    FROM dbo.sped_baseline_units
    WHERE (active = 1
        AND ((@domain IS NULL) OR (@domain = '') OR ([class] IS NULL) OR ([class] = '') OR ([class] = @domain))
        AND ((@term IS NULL) OR ([name] LIKE (('%' + @term + '%'))))
    )
    ORDER BY displayOrder ASC
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[SPED_BASELINE_UNITS_VIEW] TO [webuser]
GO
