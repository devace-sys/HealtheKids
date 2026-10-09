/* No longer used.  Replaced with dedicated sprocs for check in, start visit, end visit */

USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISITS_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTICE_OFFICE_VISITS_SAVE
GO

