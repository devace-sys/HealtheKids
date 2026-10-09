use timekeeper
go


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TIMESHEET_CheckForDelinquentEmployees') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TIMESHEET_CheckForDelinquentEmployees
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TIMESHEET_CheckForDelinquentEmployees] ( @employeeId bigint, @minDaysAgo int, @maxDaysAgo int  )
   
 RETURNS TABLE
 AS 
 return

(
select
te_cuv.*,
p.lastName,
p.firstName,
[email]
FROM

[dbo].[TIMESHEET_CheckForUnverifiedVerification] (@employeeId, @minDaysAgo, @maxDaysAgo ) te_cuv
JOIN Employees      e ON te_cuv.employeeID = e.id
JOIN [dbo].[People] p ON p.id = e.personID


CROSS APPLY (
  select top 1 
    uvc.email 
  from users.dbo.USERS_VIEW_CORE (null,null,null,'spedcare',p.spedMonUserName,null,null,null) as uvc
  where 
    (uvc.pcalStaff = 1)
) as u

)
GO

GRANT SELECT ON [dbo].[TIMESHEET_CheckForDelinquentEmployees] to webuser
GO
