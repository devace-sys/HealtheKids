USE [SPEDMON]
GO
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SPED_ACCOMMODATION_LOOKUP_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SPED_ACCOMMODATION_LOOKUP_VIEW
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[SPED_ACCOMMODATION_LOOKUP_VIEW] (
       @userID      BIGINT
     , @userGroup   INT
     , @userRank    INT
     , @lookupType  VARCHAR(50)
     , @domainCode  VARCHAR(50)
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
           x.[id]
         , x.[name]
         , x.[class]
    FROM (
            SELECT id, [name], [class], 'CATEGORY'   AS lookupType, displayOrder FROM dbo.sped_accommodation_categories    WHERE active = 1
      UNION ALL
            SELECT id, [name], NULL,    'APPLIESTO'  AS lookupType, displayOrder FROM dbo.sped_accommodation_applies_to    WHERE active = 1
      UNION ALL
            SELECT id, [name], NULL,    'FREQUENCY'  AS lookupType, displayOrder FROM dbo.sped_accommodation_frequencies   WHERE active = 1
      UNION ALL
            SELECT id, [name], NULL,    'LOCATION'   AS lookupType, displayOrder FROM dbo.sped_accommodation_locations     WHERE active = 1
      UNION ALL
            SELECT id, [name], NULL,    'AREAOFNEED' AS lookupType, displayOrder FROM dbo.sped_accommodation_areas_of_need WHERE active = 1
      UNION ALL
            SELECT id, [name], NULL,    'STAFFROLE'  AS lookupType, displayOrder FROM dbo.sped_accommodation_staff_roles   WHERE active = 1
    ) AS x
    WHERE (x.lookupType = @lookupType
        AND ((@domainCode IS NULL) OR (x.[class] IS NULL) OR (x.[class] = @domainCode))
        AND ((@term       IS NULL) OR (x.[name]  LIKE (('%' + @term + '%'))))
    )
    ORDER BY x.displayOrder ASC
)
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT SELECT ON [dbo].[SPED_ACCOMMODATION_LOOKUP_VIEW] TO [webuser]
GO