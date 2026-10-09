/*-------------------------------
 * Clean up old objects that
 * are no longer used
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_SERVICE_RECORD_TATTLE_PAGES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_SERVICE_RECORD_TATTLE_PAGES
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GROUP_DISP_BY_CLIENT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GROUP_DISP_BY_CLIENT
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_PRAC_PROC_NOTE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_PRAC_PROC_NOTE
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITONERS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITONERS_VIEW_CORE
GO

-- TODO: QUESTION - what is clean_up.sql used for and why is dbo.PRACTITONERS_VIEW_CORE dropped here?
--                  dbo.PRACTITONERS_VIEW_CORE is a very vital UDF we will not be retiring anytime soon, no?

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_VIEW_SEL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_VIEW_SEL
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_VIEW_PAGES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_VIEW_PAGES
GO

/*-------------------------------
 * Clean up old claim report
 * udfs (replaced with newer ones)
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLAIM_RECORDS_PAID_BY_PRAC') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CLAIM_RECORDS_PAID_BY_PRAC
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLAIM_RECORDS_PAID_BY_PRAC_BY_DOS') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CLAIM_RECORDS_PAID_BY_PRAC_BY_DOS
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLAIM_RECORDS_PAID_BY_PRAC_BY_DOS_COMPARED') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CLAIM_RECORDS_PAID_BY_PRAC_BY_DOS_COMPARED
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLAIM_RECORDS_PAID_BY_PRAC_COMPARED') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CLAIM_RECORDS_PAID_BY_PRAC_COMPARED
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLAIMS_PAID') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CLAIMS_PAID
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLAIMS_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CLAIMS_VIEW
GO


/*-------------------------------
 * Report publication objects
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_CLASS_OK_TO_PUBLISH_DATE_UPDATE_TO_LATEST_CHECK_DATE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.REPORT_PUBLICATION_CLASS_OK_TO_PUBLISH_DATE_UPDATE_TO_LATEST_CHECK_DATE
GO

/*-------------------------------
 * Cal and bell schedule
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_ATTENDANCE_CALENDAR_DATES_ALREADY_IN_USE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_ATTENDANCE_CALENDAR_DATES_ALREADY_IN_USE
GO
