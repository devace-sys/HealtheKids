USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetClient]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetClient]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetClient]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetClient]
AS    
BEGIN    
SET NOCOUNT ON;
	
    select
        O.id
        ,O.name
    from
        TimeKeeper.dbo.Organizations O
    where
        O.name != 'All Clients'
        and O.active = 1
    order by
        O.name

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetClient]  TO [webuser]
GO


