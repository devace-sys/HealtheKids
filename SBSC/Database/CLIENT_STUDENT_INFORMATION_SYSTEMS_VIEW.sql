USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_STUDENT_INFORMATION_SYSTEMS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION CLIENT_STUDENT_INFORMATION_SYSTEMS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLIENT_STUDENT_INFORMATION_SYSTEMS_VIEW] (
    @userID                  bigint
  , @userGroup               int  
  , @userRank                int
  , @clientID                bigint
  , @studentInfoSystemID     bigint
  , @enabled                 bit
  , @active                  bit
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (dbo.CONST_MAX_ROWS())
          csis.id
        , csis.clientID
		, clientName = clc.CLIENT_NAME
        , csis.studentInfoSystemID
        , studentInfoSystemName = sis.[name]
		, csis.apiUrl
        , csis.apiToken
		, csis.schoolNamesToExclude
	    , csis.additionalDataJSON
		, csis.[enabled]
        , csis.created
        , csis.createdBy
        , csis.lastModified
        , csis.lastModifiedBy
        , csis.active        
        , createdStr       = dbo.RPT_DATE_FMT(csis.created)
        , lastModifiedStr  = dbo.RPT_DATE_FMT(csis.lastModified)

    from dbo.CLIENT_STUDENT_INFORMATION_SYSTEMS as csis
    join dbo.CLIENTS_Client                     as clc on clc.CLIENT_ID = csis.clientID
	join dbo.STUDENT_INFORMATION_SYSTEMS        as sis on sis.id        = csis.studentInfoSystemID
	
    where (
            (1=1)
		and	((@clientID is null)             or (csis.clientID            = @clientID))
        and ((@studentInfoSystemID is null)  or (csis.studentInfoSystemID = @studentInfoSystemID))
		and ((@enabled is null)              or (csis.studentInfoSystemID = @enabled))
        and ((@active  is null)              or (csis.active              = @active))
    )
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[CLIENT_STUDENT_INFORMATION_SYSTEMS_VIEW] TO [webuser]
GO