USE SPEDMON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @today DATETIME, @oldestDOS datetime, @clientID bigint, @clientidarg varchar(30)
	SET @clientidarg = %s
	
	SET @clientID =
		CASE WHEN @clientidarg = '' THEN NULL
		ELSE CAST(@clientidarg AS bigint)
		END

IF @today IS NULL SET @today = GETDATE()
	--SET @today     = dbo.DATE_ONLY(@today)
	SET @today     = DATEADD(dd, 0, DATEDIFF(dd, 0, @today))
	--SET @oldestDOS = dbo.CALC_OLDEST_DOS_ALLOWED(@today)
	SET @oldestDOS = DATEADD(day, (-1*(DAY(@today)-1)), DATEADD(year,-1, @today))

SELECT
	--[Section]										= '1-Held Claims'
	[Consultant]									= CONVERT(VARCHAR(MAX), ccr.first_name +' ' +ccr.last_name)
	,[Comma]										= ','
	,[Date of Service]								= CONVERT(VARCHAR(MAX), dos, 10)
	,[created]										= CONVERT(VARCHAR(MAX), created, 10)
	,[clientID]										= CONVERT(VARCHAR(MAX), clientID)
	,[District Name]								= CONVERT(VARCHAR(MAX), cc.CLIENT_NAME)
	,[patID]										= CONVERT(VARCHAR(MAX), patid)
	,[PATIENT_NAME]									= CONVERT(VARCHAR(MAX), PATIENT_NAME)
	,[ValidBIC]										= CONVERT(VARCHAR(MAX), ValidBIC)
	,[SubmitClaims]									= CONVERT(VARCHAR(MAX), SubmitClaims)
	,[svcType]										= CONVERT(VARCHAR(MAX), svcType)
	,[procID]										= CONVERT(VARCHAR(MAX), procid1)
	,[procid1]										= CONVERT(VARCHAR(MAX), procid1)
	,[procid2]										= CONVERT(VARCHAR(MAX), procid2)
	,[Projected Daily Minutes]						= CONVERT(VARCHAR(MAX), numMinsExpected)
	,[Number of Minutes Submitted to Practi-Cal]	= CONVERT(VARCHAR(MAX), numMins)
	,[claimUnits1]									= CONVERT(VARCHAR(MAX), claimUnits1)
	,[min_units_1]									= CONVERT(VARCHAR(MAX), min_units_1)
	,[max_units_1]									= CONVERT(VARCHAR(MAX), max_units_1)
	,[max_svc_units_1]								= CONVERT(VARCHAR(MAX), max_svc_units_1)
	,[claimUnits2]									= CONVERT(VARCHAR(MAX), claimUnits2)
	,[min_units_2]									= CONVERT(VARCHAR(MAX), min_units_2)
	,[max_units_2]									= CONVERT(VARCHAR(MAX), max_units_2)
	,[max_svc_units_2]								= CONVERT(VARCHAR(MAX), max_svc_units_2)
	,[claimID1]										= CONVERT(VARCHAR(MAX), claimID1)
	,[claimID2]										= CONVERT(VARCHAR(MAX), claimID2)
	,[svcRecID]										= CONVERT(VARCHAR(MAX), svcRecID)
	,[claimID1Str]									= CONVERT(VARCHAR(MAX), claimID1Str)
	,[claimID2Str]									= CONVERT(VARCHAR(MAX), claimID2Str)
	,[svcRecIDStr]									= CONVERT(VARCHAR(MAX), svcRecIDStr)
	
FROM dbo.CLAIMS_TO_HOLD_VIEW_CORE (@clientID, @oldestDOS) AS core
	JOIN dbo.CLIENTS_Client AS cc ON cc.CLIENT_ID = core.clientID
	JOIN dbo.CLIENTS_Client_Reps AS ccr ON ccr.id = cc.ClientRepIDLEACurrent 
WHERE numMins < numMinsExpected
	AND minBased = 1 /* this report does not include transportation */

ORDER by (ccr.first_name +' ' +ccr.last_name), cc.CLIENT_NAME, PATIENT_NAME, dos