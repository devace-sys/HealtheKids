USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_PARENT_GROUP_ID_HEALTH_AID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_PARENT_GROUP_ID_HEALTH_AID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* GROUP_Group table PARENT_ID value for group ids 11, and 12*/

CREATE FUNCTION [dbo].[CONST_PARENT_GROUP_ID_HEALTH_AID]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 166 END    
GO
