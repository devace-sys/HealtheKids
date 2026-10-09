USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_CLAIM_STATUS_RECV_PROXY_DENIED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_CLAIM_STATUS_RECV_PROXY_DENIED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
  
CREATE FUNCTION [dbo].[CONST_CLAIM_STATUS_RECV_PROXY_DENIED]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 14 END    
GO
