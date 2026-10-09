USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerificationByNameDateRange]    Script Date: 1/25/2020 9:18:56 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerificationByNameDateRange]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerificationByNameDateRange]    Script Date: 1/25/2020 9:18:56 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerificationByNameDateRange]
(
    @employeeId BIGINT
	,@startDate Date
	,@endDate Date
)
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHET_GetEmployeeVerificationByNameDateRange] @employeeId, @startDate, @endDate

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHET_GetEmployeeVerificationByNameDateRange]  TO [webuser]
GO


