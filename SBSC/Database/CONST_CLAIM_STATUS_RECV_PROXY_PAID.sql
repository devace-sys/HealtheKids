USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_CLAIM_STATUS_RECV_PROXY_PAID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_CLAIM_STATUS_RECV_PROXY_PAID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
  
CREATE FUNCTION [dbo].[CONST_CLAIM_STATUS_RECV_PROXY_PAID]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 13 END    
GO
