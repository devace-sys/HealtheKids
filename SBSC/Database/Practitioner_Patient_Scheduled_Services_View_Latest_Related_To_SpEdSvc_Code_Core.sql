USE SPEDMON
GO

/* TODO: Remove when this has been dropped from all applicable systems.*/ 

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Patient_Scheduled_Services_View_Latest_Related_To_SpEdSvc_Code_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Practitioner_Patient_Scheduled_Services_View_Latest_Related_To_SpEdSvc_Code_Core
GO
 
