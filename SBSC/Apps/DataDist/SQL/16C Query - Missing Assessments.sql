GO
USE SPEDMON
DECLARE @ClientID BIGINT = NULL
DECLARE @ConsultantID BIGINT = NULL
DECLARE @Today DATE = GETDATE()
DECLARE @YearAgoToday DATE = DATEADD(YEAR,-1,@Today)

;WITH eligiblePatients AS (
	SELECT *
	FROM PATIENTS_Patient
	WHERE PATIENT_ID IN
	(
		SELECT pen.PATIENT_ID
		FROM PATIENTS_ELIGIBILITY_NORMALIZED	AS pen
		WHERE pen.MONTH_DATE >= @YearAgoToday
			AND pen.IS_ELIG = 1
	)
), assessmentServiceRecords AS (
	SELECT * FROM SERVICE_RECORDS sr
	WHERE sr.dos >= @YearAgoToday
		AND sr.svcType = 1
		AND sr.state <> 99
		AND sr.claimID1 IS NOT NULL
		AND (sr.clientID = @ClientID OR @ClientID IS NULL)
), PatientsWithIEPMarkerorAssessments AS (
	SELECT pat.PATIENT_ID
	FROM eligiblePatients							AS pat
	JOIN PATIENTS_IEP								AS patiep
		ON patiep.PATIENT_ID = pat.PATIENT_ID
	--***--
	JOIN PATIENTS_Client							AS pc
		ON pc.PATIENT_ID = pat.PATIENT_ID
	--***--
	WHERE 1=1
		AND patiep.IEP_IFSP_NONE IN ('IEP','IFSP')
		AND pat.ACTIVE <> 'N'

	UNION

	SELECT sr.patID									AS Patient_ID      
	FROM assessmentServiceRecords					AS sr
	JOIN CLIENTS_Client								AS cc
		ON cc.CLIENT_ID	= sr.clientID
	JOIN PRACTITIONER_Practitioner					AS prac
		ON prac.PRACTITIONER_ID	= sr.pracID
	JOIN PRACTITIONER_GROUPS						AS pg
		ON pg.PRACTITIONER_ID = prac.PRACTITIONER_ID
	JOIN GROUP_Group								AS gg
		ON gg.GROUP_ID = pg.GROUP_ID
	JOIN eligiblePatients							AS pat
		ON pat.PATIENT_ID = sr.patID
	LEFT OUTER JOIN CLAIM_Claim						AS clm
		ON clm.CLAIM_ID	= sr.claimID1
	LEFT OUTER JOIN CLAIM_Claim_Adjudication		AS cca
		ON cca.CLAIM_ID	= clm.CLAIM_ID
	WHERE 1=1
		AND cc.LEA = 1
		AND gg.GROUP_TYPE < 3
		AND pat.ACTIVE <> 'N'	
) 

SELECT
	baseInfo.[Client Name]					AS [Client Name]
	,'$'+CONVERT(VARCHAR(20),
		SUM(baseInfo.[Assessment Value]))	AS [Missing Assessment Projection]
FROM (
	SELECT
		cc.CLIENT_NAME							AS [Client Name]
		,pat.CONCAT_NAME						AS [Patient Name]
		,CONVERT(DATE,pat.DATE_OF_BIRTH)		AS [DOB]
		,ccr.first_name +' '+ ccr.last_name		AS [Consultant Name]
		,ISNULL(CASE
			WHEN sr.nameIDAliasID IS NULL
			THEN iepname.NAME
			ELSE alias.NAME
		END, 'No Assessment Recorded')			AS [Assessment Name]
		,CAST('$118.00' AS MONEY)				AS [Assessment Value]
	FROM PatientsWithIEPMarkerorAssessments			AS list
	JOIN eligiblePatients							AS pat
		ON pat.PATIENT_ID = list.PATIENT_ID
	JOIN PATIENTS_Client							AS pc
		ON pc.PATIENT_ID = list.PATIENT_ID
	JOIN CLIENTS_Client								AS cc
		ON cc.CLIENT_ID = pc.CLIENT_ID	
	JOIN CLIENTS_Client_Reps						AS ccr
		ON ccr.id = cc.ClientRepIDLEACurrent
	LEFT OUTER JOIN assessmentServiceRecords		AS sr
		ON sr.patID	= list.PATIENT_ID
		AND sr.clientID = pc.CLIENT_ID
	LEFT OUTER JOIN CLAIM_IEPandIFSPNames			AS iepname
		ON iepname.IEP_IFSP_NAME_ID	= sr.nameID
	LEFT OUTER JOIN CLAIM_IEPandIFSPNames_ALIAS		AS alias
		ON alias.ID = sr.nameIDAliasID
	LEFT OUTER JOIN CLAIM_Claim						AS clm
		ON clm.CLAIM_ID = sr.claimID1
	WHERE 1=1
		AND cc.LEA = 1
		AND (cc.CLIENT_ID = @ClientID or @ClientID IS NULL)
		AND pat.ACTIVE <> 'N'
		AND (ccr.id = @ConsultantID or @ConsultantID IS NULL)
		--***--
		AND (sr.nameIDAliasID IS NULL AND iepname.NAME IS NULL AND alias.NAME IS NULL)
		--***--
	GROUP BY
		cc.CLIENT_NAME
		,pat.CONCAT_NAME
		,pat.DATE_OF_BIRTH
		,ccr.first_name +' '+ ccr.last_name
		,CASE
			WHEN sr.nameIDAliasID IS NULL
			THEN iepname.NAME
			ELSE alias.NAME
		END
) baseInfo
GROUP BY baseInfo.[Client Name]
GO