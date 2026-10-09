USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHET_GetEmployeeTaskFavorites]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHET_GetEmployeeTaskFavorites]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHET_GetEmployeeTaskFavorites]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHET_GetEmployeeTaskFavorites]
	@EmployeeID BIGINT
AS    
BEGIN    
SET NOCOUNT ON;

select
	TETasks.*
	,TETTypes.name as 'TaskType'
from 
	Employee_TimeEntry_Tasks_Favorites ETTF
	INNER JOIN TimeEntry_Tasks TETasks
		ON TETasks.id = ETTF.taskID
	INNER JOIN TimeEntry_Types TETTypes
		ON TETasks.taskType = TETTypes.id
where
	ETTF.EmployeeID = @EmployeeID
order by 
   TETasks.id

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHET_GetEmployeeTaskFavorites]  TO [webuser]
GO


