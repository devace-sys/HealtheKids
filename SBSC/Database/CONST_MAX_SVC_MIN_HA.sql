USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MAX_SVC_MIN_HA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MAX_SVC_MIN_HA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* The daily number of minutes of services given to a patient by a health aid should not exceed 8 hours */    

CREATE FUNCTION [dbo].[CONST_MAX_SVC_MIN_HA]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 480 END    
GO
