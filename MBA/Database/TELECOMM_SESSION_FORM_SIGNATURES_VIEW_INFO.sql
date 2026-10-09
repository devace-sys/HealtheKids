USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_FORM_SIGNATURES_VIEW_INFO') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TELECOMM_SESSION_FORM_SIGNATURES_VIEW_INFO
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[TELECOMM_SESSION_FORM_SIGNATURES_VIEW_INFO] ( 
    @sessionID    bigint
  , @sigClassName varchar(512)
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * TELECOMM_SESSION_FORM_SIGNATURES_VIEW_INFO */
/**
 * Displays data
 *
 * @return                 Table
 ***************************************************************************/ 

select top 100
    [Participant] = avc.[name]
  , [Title]       = avc.[title]
  , [Signature]   = avc.[signature]
  , [Date Signed] = avc.dateSignedStr
from dbo.TELECOMM_SESSION_FORM_SIGNATURES_VIEW_CORE(@sessionID, @sigClassName) as avc
order by 
  avc.idx asc
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[TELECOMM_SESSION_FORM_SIGNATURES_VIEW_INFO] TO [webuser]
GO


