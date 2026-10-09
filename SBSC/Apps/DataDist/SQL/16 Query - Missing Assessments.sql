GO
/*
This query lists all ACTIVE patients with EITHER an IEP or IFSP marker OR a previous assessment
	It lists all the assessment records in this school year plus the three most recent school years
	It also lists a single row for any patient with an IEP/IFSP marker but who has no assessments recorded
	
	It IS set to run for all clients
	If you want to run it for only one client, change the "Set" below from NULL to the Client ID
*/
DECLARE @ClientID	bigint
	SET @ClientID = %d
/*
	It IS also set to run for all the consultants
	If you want to run it for only one, change the "Set" below from NULL to the ConsultanT ID
		David Webb = 12
		Sandy Holbrook = 1
		Eileen Whitlock = 3
		Melanie Papke = 14
*/
DECLARE @ConsultantID bigint
	SET @ConsultantID = %d

--*************To get today
DECLARE @Today DATE
	SET @Today = GETDATE()
--*************To get the most recent past January 1
DECLARE @Year VARCHAR (10)
DECLARE @LatestJanuary DATE
	SET @Year=(DATEPART (YYYY, GETDATE()))
	SET @LatestJanuary = ('01/01/'+@Year)
--*************To get the most recent past July 1
DECLARE @LatestJuly DATE
	SET @LatestJuly = 
		CASE WHEN @Today >= ('07/01/' + @Year)
			THEN ('07/01/' + @Year)
			ELSE DATEADD (Year,-1,('07/01/' + @Year))
		END
--*************To get the July 1 three years before the most recent past July 1
DECLARE @ThreeFYagoJuly DATE
	SET @ThreeFYagoJuly = DATEADD(year,-3, @LatestJuly)
--select @ThreeFYagoJuly

USE SPEDMON

;WITH assessmentServiceRecords AS
(
	SELECT * FROM SERVICE_RECORDS sr
	WHERE sr.dos >= @ThreeFYagoJuly
		AND sr.svcType = 1
		AND sr.state <> 99
		AND sr.claimID1 IS NOT NULL
		AND (sr.clientID = @ClientID OR @ClientID IS NULL)
), 

PatientsWithIEPMarkerorAssessments AS
(
SELECT
	pat.PATIENT_ID
	
FROM dbo.PATIENTS_Patient						AS pat
JOIN dbo.PATIENTS_IEP							AS patiep
	ON patiep.PATIENT_ID = pat.PATIENT_ID
JOIN dbo.PATIENTS_Client						AS pc
	ON pc.PATIENT_ID = pat.PATIENT_ID

WHERE 1=1
	AND patiep.IEP_IFSP_NONE IN ('IEP','IFSP')
	AND pat.ACTIVE <> 'N'

UNION SELECT sr.patID AS Patient_ID
      
FROM assessmentServiceRecords					AS sr
JOIN dbo.CLIENTS_Client							AS cc
	ON cc.CLIENT_ID	= sr.clientID
JOIN dbo.PRACTITIONER_Practitioner				AS prac
	ON prac.PRACTITIONER_ID	= sr.pracID
JOIN dbo.PRACTITIONER_GROUPS					AS pg
	ON pg.PRACTITIONER_ID = prac.PRACTITIONER_ID
JOIN dbo.GROUP_Group							AS gg
	ON gg.GROUP_ID = pg.GROUP_ID
JOIN dbo.PATIENTS_Patient						AS pat
	ON pat.PATIENT_ID = sr.patID
JOIN dbo.CLAIM_IEPandIFSPNames					AS iepname
	ON iepname.IEP_IFSP_NAME_ID	= sr.nameID
LEFT OUTER JOIN dbo.CLAIM_IEPandIFSPNames_ALIAS	AS alias
	ON alias.ID	= sr.nameIDAliasID
JOIN dbo.CLIENTS_Client_Reps					AS ccr
	ON ccr.id = cc.ClientRepIDLEACurrent
LEFT OUTER JOIN dbo.CLAIM_Claim					AS clm
	ON clm.CLAIM_ID	= sr.claimID1
LEFT OUTER JOIN dbo.CLAIM_Claim_Adjudication	AS cca
	ON cca.CLAIM_ID	= clm.CLAIM_ID

WHERE 1=1
	AND sr.dos >= @ThreeFYagoJuly
	AND cc.LEA = 1
	AND sr.svcType = 1
	AND sr.state <> 99
	AND gg.GROUP_TYPE < 3
	AND pat.ACTIVE <> 'N'
	
) 

SELECT
	   ccr.first_name +' '+ ccr.last_name							AS 'Consultant'
      ,cc.CLIENT_NAME												AS 'Client Name'
      ,pat.CONCAT_NAME												AS 'Patient'
      ,ISNULL(CONVERT(VARCHAR(10),CONVERT(date,sr.dos)),'')			AS 'Assessment Date'
      ,ISNULL(CASE
		WHEN sr.nameIDAliasID IS NULL
		THEN iepname.NAME
		ELSE alias.NAME
		END, 'No Assessment Recorded')								AS 'Assessment Name'
      ,ISNULL(prac.CONCAT_NAME, '')									AS 'Practitioner'
      ,ISNULL(CONVERT(VARCHAR(20),sr.id),'')						AS 'SR ID'
      ,ISNULL(sr.reference,'')										AS 'Input Reference'	
      ,ISNULL(CONVERT(VARCHAR(20),sr.claimID1),'')					AS 'SR Claim ID'
      ,CASE
			WHEN clm.STATUS = 1
			THEN 'Not Yet Sent'
			WHEN clm.status = 2
			THEN 'Pending'
			WHEN clm.STATUS = 3
			THEN 'Paid'
			WHEN clm.STATUS =4
			THEN 'Denied'
			ELSE ''
			END														AS 'Claim Status'
      ,CASE
			WHEN ISNULL(SUM(cca.amount_paid),0) = 0
			THEN ''
			ELSE CONVERT(VARCHAR(20),SUM(cca.AMOUNT_PAID))
			END														AS 'Amount'
      ,ISNULL(CONVERT(VARCHAR(20),sr.state),'')						AS 'SR State'
      ,CASE
			WHEN SUBSTRING(pat.BIC,9,1) > 'a'
			THEN 'Yes'
			ELSE ''
			END														AS 'Has BIC?'
      
FROM PatientsWithIEPMarkerorAssessments				AS list
	JOIN dbo.PATIENTS_Patient						AS pat		ON pat.PATIENT_ID			= list.PATIENT_ID
	JOIN dbo.PATIENTS_Client						AS pc		ON pc.PATIENT_ID			= list.PATIENT_ID
	JOIN dbo.CLIENTS_Client							AS cc		ON cc.CLIENT_ID				= pc.CLIENT_ID	
	JOIN dbo.CLIENTS_Client_Reps					AS ccr		ON ccr.id					= cc.ClientRepIDLEACurrent
																								--and (ccr.id = @ConsultantID or @ConsultantID IS NULL)
	LEFT OUTER JOIN assessmentServiceRecords		AS sr		ON sr.patID					= list.PATIENT_ID
																								and sr.clientID = pc.CLIENT_ID
	LEFT OUTER JOIN dbo.PRACTITIONER_Practitioner	AS prac		ON prac.PRACTITIONER_ID		= sr.pracID
	LEFT OUTER JOIN dbo.PRACTITIONER_GROUPS			AS pg		ON pg.PRACTITIONER_ID		= prac.PRACTITIONER_ID
	LEFT OUTER JOIN dbo.GROUP_Group					AS gg		ON gg.GROUP_ID				= pg.GROUP_ID
																								and gg.GROUP_TYPE < 3
	LEFT OUTER JOIN dbo.CLAIM_IEPandIFSPNames		AS iepname	ON iepname.IEP_IFSP_NAME_ID	= sr.nameID
	LEFT OUTER JOIN dbo.CLAIM_IEPandIFSPNames_ALIAS	AS alias	ON alias.ID					= sr.nameIDAliasID
	LEFT OUTER JOIN dbo.CLAIM_Claim					AS clm		ON clm.CLAIM_ID				= sr.claimID1
																								--and clm.STATUS in (2,3)
	LEFT OUTER JOIN dbo.CLAIM_Claim_Adjudication	AS cca		ON cca.CLAIM_ID				= clm.CLAIM_ID

WHERE 1=1
	and cc.LEA = 1
	and (cc.CLIENT_ID = @ClientID or @ClientID IS NULL)
	and pat.ACTIVE <> 'N'
	and (ccr.id = @ConsultantID or @ConsultantID IS NULL)

GROUP BY
	   ccr.first_name +' '+ ccr.last_name
      ,cc.CLIENT_NAME
      ,pat.CONCAT_NAME
      ,CONVERT(date,sr.dos)
      ,CASE
		WHEN sr.nameIDAliasID IS NULL
		THEN iepname.NAME
		ELSE alias.NAME
		END
      ,prac.CONCAT_NAME
      ,sr.claimID1
      ,clm.STATUS
      ,sr.state
      ,ISNULL(pat.bic,'')
      ,sr.id
      ,ISNULL(sr.reference,'')
      ,SUBSTRING(pat.BIC,9,1)
      ,pat.PATIENT_ID
      ,pat.BIC

ORDER BY  cc.CLIENT_NAME, pat.CONCAT_NAME, CONVERT(date,sr.dos)
GO