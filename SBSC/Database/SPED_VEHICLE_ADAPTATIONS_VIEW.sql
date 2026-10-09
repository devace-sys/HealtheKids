USE [SPEDMON]
GO
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SPED_VEHICLE_ADAPTATIONS_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SPED_VEHICLE_ADAPTATIONS_VIEW
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[SPED_VEHICLE_ADAPTATIONS_VIEW] (
       @userID      BIGINT
     , @userGroup   INT
     , @userRank    INT
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
    FROM dbo.sped_vehicle_adaptations
    WHERE (active = 1
        AND ((@term IS NULL) OR ([name] LIKE (('%' + @term + '%'))))
    )
    ORDER BY displayOrder ASC
)
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT SELECT ON [dbo].[SPED_VEHICLE_ADAPTATIONS_VIEW] TO [webuser]
GO