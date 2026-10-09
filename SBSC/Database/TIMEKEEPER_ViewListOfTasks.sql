USE [Spedmon]
GO

DROP function IF EXISTS [dbo].[TIMEKEEPER_ViewListOfTasks]
GO


CREATE FUNCTION [dbo].[TIMEKEEPER_ViewListOfTasks] (@empid bigint)
returns table
AS    
return  
(


select
                           id
                          ,name
                     from
                          TimeKeeper.dbo.[ViewListOfTasks] (@empid)

)

GO

GRANT select ON [dbo].[TIMEKEEPER_ViewListOfTasks]  TO [webuser]
GO