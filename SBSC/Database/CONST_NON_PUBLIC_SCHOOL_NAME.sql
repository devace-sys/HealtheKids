USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_NON_PUBLIC_SCHOOL_NAME') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_NON_PUBLIC_SCHOOL_NAME
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_NON_PUBLIC_SCHOOL_NAME]() RETURNS nvarchar(50) WITH SCHEMABINDING 
AS 
BEGIN 
  RETURN N'Non-Public School'
END    
GO
