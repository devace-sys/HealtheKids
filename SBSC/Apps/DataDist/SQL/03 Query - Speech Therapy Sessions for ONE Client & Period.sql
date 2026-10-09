GO
USE SPEDMON

DECLARE @startDate VARCHAR(10)	= CONVERT(VARCHAR(10), GETDATE(), 111)
DECLARE @endDate VARCHAR(10)	= CONVERT(VARCHAR(10), DATEADD(MONTH,-6,GETDATE()), 111)

SELECT
	  pp.LAST_NAME + ', ' + pp.FIRST_NAME		as 'Patient'
      ,prac.LAST_NAME + ', ' + prac.FIRST_NAME	as 'Practitioner'
      ,convert(date,dos)						as 'Date of Service'
      ,sr.clientID								as 'Client ID'
      ,iep.NAME									as 'Service Type'
      ,numMins									as 'Minutes'
			,CASE
				WHEN sr.patAbsent = 1
				THEN 'Absent'
				ELSE ''
			 END								as 'Absent'
      ,isnull(notes, '')						as 'Notes'
      ,pi.IEP_IFSP_NONE							as 'Plan Type'
      ,sr.reference								as 'IP Address or Document Number'

FROM [SPEDMON].[dbo].[SERVICE_RECORDS]			as sr
	JOIN dbo.PATIENTS_Patient					as pp		on pp.PATIENT_ID = sr.patID
	JOIN dbo.PATIENTS_IEP						as pi		on pi.PATIENT_ID = sr.patID
	JOIN dbo.PRACTITIONER_Practitioner			as prac		on prac.PRACTITIONER_ID = sr.pracID
	JOIN dbo.PRACTITIONER_GROUPS				as pg		on pg.PRACTITIONER_ID = sr.pracID
																and pg.GROUP_TYPE < 3
	JOIN dbo.GROUP_Group						as gg		on gg.GROUP_ID = pg.GROUP_ID
	LEFT JOIN CLAIM_Claim						as cc		on cc.CLAIM_ID = sr.claimID1
	LEFT JOIN dbo.CLAIM_Procedures				as cp		on cp.PROCEDURE_ID = cc.PROCEDURE_ID
	LEFT JOIN dbo.CLAIM_IEPandIFSPNames			as iep		on iep.IEP_IFSP_NAME_ID = cp.IEP_IFSP_NAME
	LEFT JOIN dbo.CLAIM_NoPlanNames				as NoPlan	ON NoPlan.NO_PLAN_NAME_ID = cp.NO_PLAN_NAME

WHERE 1=1
	--and sr.clientID = NULL
	and sr.dos between @endDate and @startDate
	and gg.GROUP_NAME like '%Speech%'
	and sr.svcType = 2
ORDER BY [Patient], sr.dos
GO
