GO
USE SPEDMON
--*************To get today
DECLARE @Today DATE
	SET @Today = GETDATE()
--*************To get 90 days before today
DECLARE @Aging90Date DATE
	SET @Aging90Date = DATEADD(DAY,-90, GETDATE())
--*************To get 180 days before today
DECLARE @Aging180Date DATE
	SET @Aging180Date = DATEADD(DAY,-180, GETDATE())

/******
08 Query - Active Practitioner Review.sql
This query lists all the active practitioner records associated with active LEA Billing Option clients
Run the query and paste the results into cell A2 of the template "08 Template for Active Practitioner Review.xls"
It tells us:
	Consultant name
	Client name
	Date the practitioner record was created and last modified 
		(if never modified, the modified date = the creation date)
	Latest Service Record Date Of Service associated with the practitioner
	What allied discipline group the practitioner is in
	Practitioner notes from SpEdCare
It's intended use is to identify practitioners who haven't had a service record recently
******/
SELECT 
	   CASE
			WHEN cc.ClientRepIDLEACurrent = 0
			THEN 'No Consultant Assigned'
			ELSE rep.first_name + ' ' + rep.last_name	
			END														AS 'Consultant Name'
	  ,cc.CLIENT_NAME												AS 'Client Name'
      ,pp.LAST_NAME													AS 'Practitioner Last Name'
      ,pp.FIRST_NAME												AS 'Practitioner First Name'
	  ,ISNULL(CONVERT(VARCHAR(10),MAX(clm.service_date),101),'')	AS 'Latest Service'
	  ,CASE
			WHEN 
				MAX(clm.service_date) > @Aging90Date
				AND MAX(clm.service_date) IS NOT NULL
			THEN 1 
			ELSE 0
			END														AS '0-89 Days'
	  ,CASE
			WHEN MAX(clm.service_date)
				> @Aging180Date AND
				MAX(clm.service_date)
				<= @Aging90Date
			THEN 1
			ELSE 0
			END														AS '90-179 Days'
	  ,CASE
			WHEN MAX(clm.service_date)
				<= @Aging180Date
			THEN 1
			ELSE 0
			END														AS '180+ Days'
	  ,CASE
			WHEN CONVERT(DATE, MAX(clm.service_date))
				IS NULL
			THEN 1
			ELSE 0
			END														AS 'Never'
      ,LOWER(pp.EMAIL)												AS 'Practitioner email'
      ,gg.GROUP_NAME												AS 'Group Name'
      ,gt.DESCRIPTION												AS 'Group Description'
      ,pn.NOTE														AS 'Practitioner Notes'
	  ,pp.PRACTITIONER_ID											AS 'PracID'
      ,pp.UserID													AS 'Prac User ID'
	  ,CONVERT(VARCHAR(10),pp.DATE_CREATED,101)						AS 'Practitioner Created'
	  ,CONVERT(VARCHAR(10),pp.DATE_MODIFIED,101)					AS 'Practitioner Modified'
      ,pg.GROUP_ID													AS 'Group ID'
      ,LOWER(um.Email)												AS 'User email'
      ,LOWER(uu.UserName)											AS 'User Name'

FROM [SPEDMON].[dbo].[PRACTITIONER_Practitioner]		AS pp
  JOIN dbo.PRACTITIONER_GROUPS							AS pg	ON pg.PRACTITIONER_ID = pp.PRACTITIONER_ID
  JOIN dbo.GROUP_Group_Types							AS gt	ON gt.GROUP_TYPE = pg.GROUP_TYPE
  JOIN dbo.GROUP_Group									AS gg	ON gg.GROUP_ID = pg.GROUP_ID
  LEFT OUTER JOIN dbo.PRACTITIONER_Note					AS pn	ON pn.NOTE_PRACTITIONER_ID = pp.PRACTITIONER_ID
  LEFT OUTER JOIN dbo.PRACTITIONER_Client				AS pc	ON pp.PRACTITIONER_ID = pc.PRACTITIONER_ID
  LEFT OUTER JOIN dbo.CLIENTS_Client					AS cc	ON cc.CLIENT_ID = pc.CLIENT_ID
  LEFT OUTER JOIN dbo.CLAIM_Claim						AS clm	ON clm.PRACTITIONER_ID = pp.PRACTITIONER_ID
  LEFT OUTER JOIN dbo.CLIENTS_Client_Reps				AS rep	ON rep.id = cc.ClientRepIDLEACurrent
  LEFT OUTER JOIN users.dbo.Users						AS uu	ON uu.UserrId = pp.UserID
  LEFT OUTER JOIN users.dbo.Membership					AS um	ON um.UserId = uu.UserId
  
WHERE 1=1
	AND gg.GROUP_TYPE IN (1,2)
	AND pp.ACTIVE = 1
	AND cc.LEA = 1
	AND cc.CLIENT_ID <> 112

GROUP BY
	   cc.ClientRepIDLEACurrent
	  ,rep.first_name
	  ,rep.last_name
	  ,cc.CLIENT_NAME
	  ,pp.PRACTITIONER_ID
	  ,CONVERT(VARCHAR(10),pp.DATE_CREATED,101)
	  ,CONVERT(VARCHAR(10),pp.DATE_MODIFIED,101)
      ,pp.LAST_NAME
      ,pp.FIRST_NAME
      ,gt.DESCRIPTION
      ,pg.GROUP_ID
      ,gg.GROUP_NAME
      ,pn.NOTE
      ,pp.EMAIL
      ,pp.UserID
      ,um.email
      ,uu.UserName
      	
ORDER BY rep.first_name,
	rep.last_name,
	cc.CLIENT_NAME,
	pp.LAST_NAME,
	pp.FIRST_NAME
GO