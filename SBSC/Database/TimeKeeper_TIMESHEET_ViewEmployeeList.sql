USE [SPEDMON]
GO

DROP function IF EXISTS [dbo].[TimeKeeper_TIMESHEET_ViewEmployeeList]
GO


CREATE FUNCTION [dbo].[TimeKeeper_TIMESHEET_ViewEmployeeList] ()
returns table
AS    
return  
(
            select
	            *
            from
	            [TimeKeeper].[dbo].[TIMESHEET_ViewEmployeeList] ()
            /*
            order by
	            P.lastName
	            ,P.firstName
            */

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT select ON [dbo].[TimeKeeper_TIMESHEET_ViewEmployeeList]  TO [webuser]
GO


