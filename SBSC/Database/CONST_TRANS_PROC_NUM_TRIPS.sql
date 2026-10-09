USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_TRANS_PROC_NUM_TRIPS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_TRANS_PROC_NUM_TRIPS
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CONST_TRANS_PROC_NUM_TRIPS]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 1 END    
    
GO
