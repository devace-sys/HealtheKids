USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetTaskInformation]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetTaskInformation]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetTaskInformation]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetTaskInformation]
	@Id BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
	  
        SELECT TOP 1
			*
          FROM 
                [TimeKeeper].[dbo].[TimeEntry_Tasks]
            WHERE
                [id] = @Id				     
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetTaskInformation]  TO [webuser]
GO


