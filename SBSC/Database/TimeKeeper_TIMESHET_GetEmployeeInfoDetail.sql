USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHET_GetEmployeeInfoDetail]    Script Date: 1/25/2020 9:05:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHET_GetEmployeeInfoDetail]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHET_GetEmployeeInfoDetail]    Script Date: 1/25/2020 9:05:15 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHET_GetEmployeeInfoDetail]
	@Id BIGINT
AS    
BEGIN    
SET NOCOUNT ON;
	
    exec [TimeKeeper].[dbo].[TIMESHET_GetEmployeeInfoDetail] @Id

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHET_GetEmployeeInfoDetail] TO [webuser]
GO

