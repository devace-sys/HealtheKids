GO
USE SPEDMON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @today DATETIME, @oldestDOS datetime, @clientID bigint, @clientidarg varchar(30)
	SET @clientidarg = NULL
	
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
	'1-Held Claims'							as 'Section'
	,ccr.first_name +' ' +ccr.last_name		as 'Consultant'
	,CONVERT(VARCHAR(10),dos,101)
	,CONVERT(VARCHAR(10),created,101)
	,clientID
	,cc.CLIENT_NAME
	,patid
	,PATIENT_NAME
	,ValidBIC
	,SubmitClaims
	,svcType
	,procid1 as procid
	,procid1
	,procid2
	,numMinsExpected
	,numMins
	,claimUnits1
	,min_units_1
	,max_units_1
	,max_svc_units_1
	,claimUnits2
	,min_units_2
	,max_units_2
	,max_svc_units_2
	,claimID1
	,claimID2
	,svcRecID
	,claimID1Str
	,claimID2Str
	,svcRecIDStr
	
FROM dbo.CLAIMS_TO_HOLD_VIEW_CORE (@clientID, @oldestDOS) as core
	JOIN dbo.CLIENTS_Client as cc on cc.CLIENT_ID = core.clientID
	JOIN dbo.CLIENTS_Client_Reps as ccr on ccr.id = cc.ClientRepIDLEACurrent
WHERE numMins < numMinsExpected
and minBased = 1 /* this report does not include transportation */

ORDER by (ccr.first_name +' ' +ccr.last_name), cc.CLIENT_NAME, PATIENT_NAME, dos
GO