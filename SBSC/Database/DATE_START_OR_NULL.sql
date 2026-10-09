USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_START_OR_NULL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_START_OR_NULL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[DATE_START_OR_NULL](@datein DATETIME, @starton SMALLINT) RETURNS DATETIME AS     
BEGIN    
  IF @datein IS NULL RETURN NULL
  RETURN dbo.DATE_START(@datein, @starton)
END    
    
GO
