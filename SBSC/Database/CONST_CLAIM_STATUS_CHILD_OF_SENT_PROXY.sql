USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_CLAIM_STATUS_CHILD_OF_SENT_PROXY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_CLAIM_STATUS_CHILD_OF_SENT_PROXY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
  
CREATE FUNCTION [dbo].[CONST_CLAIM_STATUS_CHILD_OF_SENT_PROXY]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 12 END    
GO
