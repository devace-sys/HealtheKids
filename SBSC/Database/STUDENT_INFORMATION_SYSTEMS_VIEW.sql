USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STUDENT_INFORMATION_SYSTEMS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION STUDENT_INFORMATION_SYSTEMS_VIEW
GO 

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[STUDENT_INFORMATION_SYSTEMS_VIEW] 
(
    @userID        BIGINT
  , @userGroup     INT  
  , @userRank      INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (dbo.CONST_MAX_ROWS())
          sis.id
        , sis.[name]
	    , sis.additionalDataJSON
        , sis.created
        , sis.createdBy
        , sis.lastModified
        , sis.lastModifiedBy
        , sis.active
        , createdStr       = dbo.RPT_DATE_FMT(sis.created)
        , lastModifiedStr  = dbo.RPT_DATE_FMT(sis.lastModified)
    FROM dbo.STUDENT_INFORMATION_SYSTEMS AS sis
    WHERE (sis.active = 1)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[STUDENT_INFORMATION_SYSTEMS_VIEW] TO [webuser]
GO