USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_SelectSpedmonUsers]    Script Date: 1/25/2020 8:05:08 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_SelectSpedmonUsers]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_SelectSpedmonUsers]    Script Date: 1/25/2020 8:05:08 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_SelectSpedmonUsers]
AS    
BEGIN    
SET NOCOUNT ON;
	  
	select 
		uv.uid
		,uv.firstName + ' ' + uv.lastName + ' (' + uv.userName + ')' as 'UserInfo' 
		,uv.firstName
		,uv.lastName
		,uv.userName
	from 
		users.dbo.USERS_VIEW (null,null,null,null,null,null,null,null,null,null,null,null,1,null) as uv
	where 
		(uv.userGroupID = 2) 
		and uv.userName not in
		(
			select
				spedMonUserName
			from
				TimeKeeper.dbo.People
			where
				spedMonUserName is NOT NULL
		)
	order by
		uv.userName

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_SelectSpedmonUsers] TO [webuser]
GO



