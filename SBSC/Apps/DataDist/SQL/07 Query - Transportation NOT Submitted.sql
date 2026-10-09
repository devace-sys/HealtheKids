GO
USE SPEDMON
SELECT 
	sr.claimID1
	,sr.claimID2
	,sr.id
	,pp.PATIENT_ID
	,ccr.first_name + ' ' + ccr.last_name
	,cc.CLIENT_NAME
	,pp.CONCAT_NAME
	,convert(date,pp.DATE_OF_BIRTH)
	,isnull(pp.CSIS,'')
	,DATENAME(weekday,sr.dos)
	,convert(date,sr.dos)
	,claimData.UnitClaimOne
	,claimData.UnitClaimTwo
	,claimData.totalunitmath
FROM [SPEDMON].[dbo].[SERVICE_RECORDS] AS sr
	JOIN
	(
		SELECT
			svcRecID
			,SUM(unitSumOne)	AS UnitClaimOne
			,SUM(feeOne) 		AS FeeClaimOne
			,SUM(unitSumTwo)	AS UnitClaimTwo
			,SUM(feetwo)		AS FeeClaimTwo
			,convert(varchar(max),convert(decimal(18,2),SUM(unitSumOne) * SUM(feeOne) * .5 + SUM(unitSumTwo) * SUM(feetwo) *.5)) AS totalunitmath
		FROM
		(
			SELECT
				src.svcRecID
				,CASE WHEN src.purpose = 1 THEN cc.SERVICE_UNITS ELSE 0 END	AS unitSumOne
				,CASE WHEN src.purpose = 1 THEN cp.SERVICE_FEE ELSE 0 END	AS FeeOne
				,CASE WHEN src.purpose = 2 THEN cc.SERVICE_UNITS ELSE 0 END	AS unitSumtwo
				,CASE WHEN src.purpose = 2 THEN cp.SERVICE_FEE ELSE 0 END	AS FeeTwo
			FROM service_record_claims				AS src
				INNER JOIN CLAIM_Claim				AS cc
					ON src.claimID = cc.CLAIM_ID
				INNER JOIN CLAIM_Procedures			AS cp
					ON cc.PROCEDURE_ID = cp.PROCEDURE_ID
					AND cp.IEP_IFSP_NAME IN (32,64)
				INNER JOIN CLIENTS_Client			AS clients
					ON cc.CLIENT_ID = clients.CLIENT_ID
					AND clients.LEA = 1
				WHERE cc.STATUS < 2
				AND cc.SERVICE_DATE >= DATEADD(month, DATEDIFF(month, 0, DATEADD(year,-1, GETDATE())), 0)	-- The first day of this month last year
		) AS pivotedClaimUnits
		GROUP BY svcRecID
	) AS claimData ON claimData.svcRecID = sr.id
	JOIN dbo.CLIENTS_Client							AS cc
		ON cc.CLIENT_ID = sr.clientID
	JOIN dbo.CLIENTS_Client_Reps					AS ccr
		ON ccr.id = cc.ClientRepIDLEACurrent
	JOIN dbo.PATIENTS_Patient						AS pp
		ON pp.PATIENT_ID = sr.patID
	LEFT JOIN dbo.PATIENTS_ELIGIBILITY_NORMALIZED	AS pen
		ON pen.PATIENT_ID = sr.patID
			AND sr.dos >= pen.MONTH_DATE
			AND sr.dos < DATEADD(MONTH,1,pen.MONTH_DATE)
WHERE 1=1
	AND sr.nameID in (32,64)
	AND cc.LEA = 1
	AND sr.dos >= DATEADD(month, DATEDIFF(month, 0, DATEADD(year,-1, GETDATE())), 0)	-- The first day of this month last year
	AND (pen.IS_ELIG = 1 or pen.IS_ELIG is null)
GO