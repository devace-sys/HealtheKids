
use spedmon
go


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TimeKeeper_TIMESHEET_CheckForUnverifiedVerification') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TimeKeeper_TIMESHEET_CheckForUnverifiedVerification
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TimeKeeper_TIMESHEET_CheckForUnverifiedVerification] ( @employeeId bigint, @minDaysAgo int, @maxDaysAgo int  )
   
 RETURNS TABLE
 AS 
 return
 (
   SELECT * FROM [TimeKeeper].[dbo].[TIMESHEET_CheckForUnverifiedVerification] ( @employeeId, @minDaysAgo, @maxDaysAgo )
 )

GO

GRANT SELECT ON [dbo].[TimeKeeper_TIMESHEET_CheckForUnverifiedVerification] to webuser
GO
