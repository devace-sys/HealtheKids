use SPEDMON
go


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TimeKeeper_TIMESHEET_GetCurrentMissingTimePeriodConfirmationsSummary') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TimeKeeper_TIMESHEET_GetCurrentMissingTimePeriodConfirmationsSummary
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TimeKeeper_TIMESHEET_GetCurrentMissingTimePeriodConfirmationsSummary] (  )
RETURNS TABLE
AS 
RETURN
(
  select * from TimeKeeper.dbo.TIMESHEET_GetCurrentMissingTimePeriodConfirmationsSummary()

)

GO

GRANT SELECT ON [dbo].[TimeKeeper_TIMESHEET_GetCurrentMissingTimePeriodConfirmationsSummary] to webuser
GO
