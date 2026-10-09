USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_NAME_REMOVE_IN_PERSON_AND_TELE_HEALTH_TEXT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_NAME_REMOVE_IN_PERSON_AND_TELE_HEALTH_TEXT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SERVICE_NAME_REMOVE_IN_PERSON_AND_TELE_HEALTH_TEXT] (
  @svcName nvarchar(255)
) 
RETURNS nvarchar(255) 
WITH SCHEMABINDING 
AS    
BEGIN    
  if (@svcName is null) return null
  return trim(replace((replace(@svcName,N'(via telehealth)',N'')),N'(in person)',N''))       
END    
GO
