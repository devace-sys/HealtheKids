/* TODO: Remove once we have verified that all boxes that need to run this have run this. 
 * This code is not referenced in install.sql so most likely its just production 
 * (we installed it for comparison runs but its isolated)
 */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Summary_Rows_Into_Promised_Services_Core_New') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Summary_Rows_Into_Promised_Services_Core_New
GO

