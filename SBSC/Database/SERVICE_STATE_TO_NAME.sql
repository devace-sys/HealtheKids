USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_STATE_TO_NAME') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_STATE_TO_NAME
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[SERVICE_STATE_TO_NAME](@state INT) 
RETURNS nvarchar(100) 
AS    
BEGIN    
  DECLARE @state_name AS NVARCHAR(50)    
  SET @state_name = dbo.CONST_SVC_REC_STATE_UNDEF()    
  SELECT @state_name = CASE     
    WHEN @state = dbo.CONST_SVC_REC_STATE_NEW()       THEN 'New'    
    WHEN @state = dbo.CONST_SVC_REC_STATE_MOD()       THEN 'Modified'    
    WHEN @state = dbo.CONST_SVC_REC_STATE_SUB()       THEN 'Submitted for Payment'     
    WHEN @state = dbo.CONST_SVC_REC_STATE_PORT_HEBS() THEN 'Ported from HEBS'     
    WHEN @state = dbo.CONST_SVC_REC_STATE_DEL()       THEN 'Deleted'     
  END    
  RETURN @state_name     
END    
GO
