USE [Spedmon]
GO

DROP function IF EXISTS [dbo].[TIMEKEEPER_ViewListOfFavoriteClients]
GO


CREATE FUNCTION [dbo].[TIMEKEEPER_ViewListOfFavoriteClients] (@empid bigint)
returns table
AS    
return  
(


select
                           id
                          ,name
                     from
                          TimeKeeper.dbo.[ViewListOfFavoriteClients] (@empid)

)

GO

GRANT select ON [dbo].[TIMEKEEPER_ViewListOfFavoriteClients]  TO [webuser]
GO