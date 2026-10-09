USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MAN_PAGE_TO_SERVICE_TYPE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.MAN_PAGE_TO_SERVICE_TYPE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[MAN_PAGE_TO_SERVICE_TYPE](@man_page DECIMAL(18,3)) RETURNS int AS    
BEGIN    
  DECLARE @svc_type AS INT    
  SELECT @svc_type =  CASE     
    WHEN @man_page >= 1    AND  @man_page < 11     THEN dbo.CONST_SERVICES_ASSESS()     
    WHEN @man_page >= 11   AND  @man_page <= 15.3  THEN dbo.CONST_SERVICES_TREATMENT()     
    WHEN @man_page >= 15.4 AND  @man_page <= 15.5  THEN dbo.CONST_SERVICES_TRANSPORT()    
    WHEN @man_page >= 16                           THEN dbo.CONST_SERVICES_TCM()    
    END    
  RETURN @svc_type     
END    
GO
