USE [TimeKeeper]
GO

DROP function IF EXISTS [dbo].[TIMESHEET_ViewEmployeeList]
GO


CREATE FUNCTION [dbo].[TIMESHEET_ViewEmployeeList] ()
returns table
AS    
return  
(
	  
            select
	            E.id
	            ,P.lastName + ', ' + P.firstName AS [Name]
	            ,E.autoPopulateSchedule
	            ,E.autoPopulateSdheduleTemplateId
            from
	            TimeKeeper.dbo.People P
	            inner join TimeKeeper.dbo.Employees E
		            ON E.personID = P.id
	            inner join TimeKeeper.dbo.Organizations O
		            ON O.id = E.organizationID
                        and O.active = 1
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

GRANT select ON [dbo].[TIMESHEET_ViewEmployeeList]  TO [webuser]
GO


