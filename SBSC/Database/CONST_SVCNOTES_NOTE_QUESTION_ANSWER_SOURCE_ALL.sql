USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_SVCNOTES_NOTE_QUESTION_ANSWER_SOURCE_ALL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_SVCNOTES_NOTE_QUESTION_ANSWER_SOURCE_ALL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_SVCNOTES_NOTE_QUESTION_ANSWER_SOURCE_ALL]() RETURNS VARCHAR(50) WITH SCHEMABINDING 
AS BEGIN RETURN 'all' END    
GO
