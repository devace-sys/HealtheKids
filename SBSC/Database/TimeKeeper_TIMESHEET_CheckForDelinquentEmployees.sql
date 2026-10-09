use spedmon
go


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TimeKeeper_TIMESHEET_CheckForDelinquentEmployees') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TimeKeeper_TIMESHEET_CheckForDelinquentEmployees
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* NOTE:
   MBA.Security.BitteTimePeople.returnCheckForDelinquentEmployees() gets passed a db connection, sometimes the TimeKeeper connection,
   sometimes the Spedmon connection.  If we make the original UDF and the pass-through use the same function name, then the SELECT query
   transparently works with either connection.
*/
 
CREATE FUNCTION [dbo].[TimeKeeper_TIMESHEET_CheckForDelinquentEmployees] ( @employeeId bigint, @minDaysAgo int, @maxDaysAgo int )
   
 RETURNS TABLE
 AS 
 return

(
select * FROM
  TimeKeeper.[dbo].[TIMESHEET_CheckForDelinquentEmployees] (@employeeId, @minDaysAgo, @maxDaysAgo) te_cuv
)
GO

GRANT SELECT ON TimeKeeper_TIMESHEET_CheckForDelinquentEmployees to webuser
GO

