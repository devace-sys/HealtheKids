USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_TYPE_TO_NAME') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_TYPE_TO_NAME
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[SERVICE_TYPE_TO_NAME](@svc_type INT) RETURNS nvarchar(50) AS    
BEGIN    
  DECLARE @svc_name AS NVARCHAR(50)    
  SELECT @svc_name = CASE     
    WHEN @svc_type = dbo.CONST_SERVICES_ASSESS()    THEN 'Assessement'    
    WHEN @svc_type = dbo.CONST_SERVICES_TREATMENT() THEN 'Treatment'    
    WHEN @svc_type = dbo.CONST_SERVICES_TRANSPORT() THEN 'Transport'     
    WHEN @svc_type = dbo.CONST_SERVICES_TCM()       THEN 'Targeted Case Mgmt'     
  END    
  RETURN @svc_name     
END    
GO
