USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_RET_DUP_RECORD') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_RET_DUP_RECORD
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
/************************** Dup Record *******************************/     
    
    
CREATE FUNCTION [dbo].[CONST_RET_DUP_RECORD]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 20 END    
    
GO
