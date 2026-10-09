USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PARSE_PLACE_ID_STRING') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PARSE_PLACE_ID_STRING
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PARSE_PLACE_ID_STRING]
(   @placeID    varchar(255) 
) 
RETURNS TABLE 
AS RETURN
(
  select * from MULTI_RECORD_ID_PARSE(@placeID,'-')
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PARSE_PLACE_ID_STRING] TO [webuser]
GO