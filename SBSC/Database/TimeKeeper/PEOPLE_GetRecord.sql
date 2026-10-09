USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[PEOPLE_GetRecord]    Script Date: 1/26/2020 11:57:41 AM ******/
DROP PROCEDURE IF EXISTS [dbo].[PEOPLE_GetRecord]
GO

/****** Object:  StoredProcedure [dbo].[PEOPLE_GetRecord]    Script Date: 1/26/2020 11:57:41 AM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PEOPLE_GetRecord]
  @SpedMonUserName                NVARCHAR(256)
AS
BEGIN
SET NOCOUNT ON;

	SELECT top 1
		P.id,
		P.roleID,
		P.lastName,
		P.firstName,
		TSR.roleName,
		E.id as 'employeeid',
    isDelinquentDTKUser

	FROM
		dbo.People P
		INNER JOIN dbo.Employees E
			ON E.personID = P.id
		INNER JOIN dbo.TimeSystemRole TSR
			ON TSR.roleID = P.roleID
    OUTER APPLY
    ( SELECT 1 isDelinquentDTKUser FROM
      [TIMESHEET_CheckForUnverifiedVerification] (
        E.id,
        
        -- we're only interested in "delinquent" users with notices a day old or older, unless it's Saturday
        (CASE WHEN DATEPART(weekday, GETDATE()) = 7 THEN 0 ELSE 1 END),

        null  ) un_verif
    ) un_verif
	WHERE
		p.spedMonUserName = @SpedMonUserName

END


GO

GRANT EXECUTE ON [dbo].[PEOPLE_GetRecord] TO [webuser] AS [dbo]
GO
