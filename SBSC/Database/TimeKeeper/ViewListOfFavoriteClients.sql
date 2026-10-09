USE [TimeKeeper]
GO

DROP function IF EXISTS [dbo].[ViewListOfFavoriteClients]
GO


CREATE FUNCTION [dbo].[ViewListOfFavoriteClients] (@empid bigint)
returns table
AS    
return  
(


select distinct -- todo: are there dups in this table??
                     cc."id"
                    ,cc."name"
                     from
                          
                          [dbo].[Organizations] cc
                     left join [dbo].Employee_Organization_Favorites ef
                     ON (@empid IS NOT NULL AND cc.id = ef.clientOrganizationID)
                     WHERE (@empid IS NULL OR ef.EmployeeID = @empid)

)

GO

GRANT select ON [dbo].[ViewListOfFavoriteClients]  TO [webuser]
GO