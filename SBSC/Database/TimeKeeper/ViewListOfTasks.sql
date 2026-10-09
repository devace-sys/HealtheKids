USE [TimeKeeper]
GO

DROP function IF EXISTS [dbo].[ViewListOfTasks]
GO


CREATE FUNCTION [dbo].[ViewListOfTasks] (@empid bigint)
returns table
AS    
return  
(


select
                     TET.id
                    ,TET.name
                     from
                          TimeKeeper.dbo.TimeEntry_Tasks TET
                     left join [dbo].[Employee_TimeEntry_Tasks_Favorites] ef
                     ON (@empid IS NOT NULL AND ef.taskID = TET.id)
                     WHERE (@empid IS NULL OR ef.EmployeeID = @empid)

)

GO

GRANT select ON [dbo].[ViewListOfTasks]  TO [webuser]
GO