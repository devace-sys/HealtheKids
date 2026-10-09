GO

DECLARE @repID BIGINT
DECLARE @clientID BIGINT
DECLARE @today DATE	= GETDATE()
DECLARE @fyyear VARCHAR(4) =
	CASE
		WHEN MONTH(@today) < 7
		THEN DATEADD(YEAR,-1,@today)
		ELSE DATEADD(YEAR,0,@today)
	END
DECLARE @fysTART DATE = @fyyear+'07'+'01'

declare @endlastweek date
declare @startlastweek date

SELECT @endlastweek = case when datepart(weekday, @today) >6 then
 DATEADD(DAY, +4, DATEADD(WEEK, DATEDIFF(WEEK, 0, @today), 0)) 
else DATEADD(DAY, -3, DATEADD(WEEK, DATEDIFF(WEEK, 0, @today), 0)) end

select @startlastweek = DATEADD(day,-7,@endlastweek)

--select @today , @startlastweek as Startwk, @endlastweek as EndWk, @fysTART


USE SPEDMON

;

/* Claim Record CTEs */

with claim_recs_cte_core as
(
	select cc.* from CLAIM_Claim cc
)
, claim_recs_entered_thisFY as
(
	select crcc.* from claim_recs_cte_core crcc
	where crcc.ENTRY_DATE >= @fystart
	and crcc.ENTRY_DATE <= @endlastweek
)

,claim_recs_entered_thisFY_counts as
(
	select 
		cli.CLIENT_ID
		,COUNT(DISTINCT cretfy.CLAIM_ID) as totalThisFY
		,COUNT(distinct case when cretfy.entry_date BETWEEN @startlastWeek and @endlastweek then cretfy.CLAIM_ID else null END) as totalThisWeek
	
	from CLIENTS_Client cli
	 left outer join claim_recs_entered_thisFY cretfy
		on cli.CLIENT_ID = cretfy.CLIENT_ID
		and cretfy.PROCEDURE_ID <> 203 /* state adjustment */
	group by cli.CLIENT_ID
)


,paid_claim_recs_cte as
(
	select 
		cc.*
		,cca.ADJUDICATION_ID
		,cca.AMOUNT_PAID
		,cca.EDSPERCENT
		,cca.DATE_ADJUDICATED
	from CLAIM_Claim cc
	inner join CLAIM_Claim_Adjudication cca
		on cc.CLAIM_ID = cca.CLAIM_ID
)

, claim_recs_paid_thisFY_cte AS (
	SELECT 
		cc.client_id
		,PROCEDURE_ID
		,IS_PROXY
		,SERVICE_DATE
		,AMOUNT_PAID
		,EDSPERCENT
		,DATE_ADJUDICATED 
	FROM CLAIM_Claim cc
	INNER JOIN CLAIM_Claim_Adjudication cca
		ON cc.CLAIM_ID = cca.CLAIM_ID
	WHERE cca.DATE_ADJUDICATED >= @fyStart
		AND DATE_ADJUDICATED <= @endlastweek
)

, claim_recs_paid_thisFY_noproxies_cte AS (
	SELECT 
		client_id
		,PROCEDURE_ID
		,SERVICE_DATE
		,AMOUNT_PAID
		,EDSPERCENT
		,DATE_ADJUDICATED 
	FROM claim_recs_paid_thisFY_cte crtf
		where crtf.IS_PROXY = 0	
)

, claim_recs_paid_thisFY_noproxies_cte_totals AS (
	SELECT 
		cli.client_id
		
		,SUM( CASE when PROCEDURE_ID <> 203 then (AMOUNT_PAID*EDSPERCENT) else 0 END) as NotAdjustmentTotalPaid
		,SUM( CASE when PROCEDURE_ID = 203 then (AMOUNT_PAID*EDSPERCENT) else 0 END) as AdjustmentTotalPaid
		
		/* NotAdjustmentTotalPaid - AdjustmentTotalPaid */
		,SUM( CASE when PROCEDURE_ID <> 203 then (AMOUNT_PAID*EDSPERCENT) else 0 END) 
		 - SUM( CASE when PROCEDURE_ID = 203 then (AMOUNT_PAID*EDSPERCENT) else 0 END) as NAmAdj
	FROM 
		CLIENTS_Client cli
		left outer join claim_recs_paid_thisFY_cte crtf
			on crtf.CLIENT_ID = cli.CLIENT_ID
			and crtf.IS_PROXY = 0
	group by cli.CLIENT_ID
)

, svc_recs_entered_thisFY_cte as (
	SELECT
		sr.clientID
		,sr.created
		,sr.id
		,cc.PROCEDURE_ID
		,um.SBSC_Employee
	FROM SERVICE_RECORDS sr
	INNER JOIN SPEDMON.dbo.CLAIM_Claim AS cc
		ON cc.CLAIM_ID = sr.claimID1
		
	inner join Users.dbo.Users uu 
		on sr.userID = uu.userrid
	inner join Users.dbo.Membership um
		on uu.UserId = um.UserId
	WHERE sr.created >= @fyStart 
			AND sr.created <= @endlastweek 
			AND cc.PROCEDURE_ID <> 203 
			AND cc.IS_PROXY = 0
)

,svc_recs_entered_last_30_cte as (
	select sr.*
	from svc_recs_entered_thisFY_cte sr
	where sr.created >= dateadd(day, -30, @endlastweek)
)

,svc_recs_entered_thisFY_cte_totals as(
select
	cli.CLIENT_ID
	,COUNT(distinct sref.id) as totalSvcRecThisFY
	,COUNT(distinct CASE when sref.SBSC_Employee = 0 then sref.id else null end) as totalSvcRecByPracThisFY
	,COUNT(distinct CASE when sref.SBSC_Employee = 1 then sref.id else null end) as totalSvcRecBySBSCThisFY
	
	,COUNT(distinct CASE when sref.created BETWEEN @startLastWeek and @endlastweek then sref.id else null end) as totalSvcRecThisWeek

from 
	CLIENTS_Client cli
	left outer join svc_recs_entered_thisFY_cte sref
		on sref.clientID = cli.CLIENT_ID
		group by cli.CLIENT_ID
)

,svc_recs_entered_last_30_cte_totals as
(
select
	cli.CLIENT_ID
	,COUNT(distinct srel.id) as totalSvcRecLast30
	,COUNT(distinct CASE when srel.SBSC_Employee = 0 then srel.id else null end) as totalSvcRecByPracLast30
	,COUNT(distinct CASE when srel.SBSC_Employee = 1 then srel.id else null end) as totalSvcRecBySBSCLast30

from 
	CLIENTS_Client cli
	left outer join svc_recs_entered_last_30_cte srel
		on srel.clientID = cli.CLIENT_ID
		group by cli.CLIENT_ID

)

, clientBatchInfo as
(
	select 
		cli.CLIENT_ID 	
		/* To compute if paper or scanned work has been received within the past 30 days */
		,CASE 
			when EXISTS 
				(
				select 1 from INPUT_BATCHES ib
				WHERE 
					Date_Recieved BETWEEN DATEADD(dd,-30,@endlastweek) AND @endlastweek
					and ib.ClientID = cli.CLIENT_ID
				) THEN 1 ELSE 0 END 
			as recWorkInLast30
		,ISNULL(hoh.HoursOnHand,0) as HoursOnHand
		,hoh.OldestDateOfService
		,hoh.OldestRecievedDate
		
	from CLIENTS_Client cli
     
	/* To compute number of hours of batched work on hand */
	LEFT OUTER JOIN HOURS_ON_HAND(@clientID,@endlastweek) hoh
		ON hoh.Client_ID = cli.CLIENT_ID
)

,clientInvoiceInfo as
(
	select cli.CLIENT_ID
		,SUM( case when INVOICE_DATE BETWEEN @startlastWeek and @endlastweek AND Revenue_Program IN ('LEA','CRCS') then INVOICE_AMOUNT else 0 end) as thisWeekInvTotal
		,MAX(INVOICE_DATE) as lastInvoiced
	from CLIENTS_Client cli
	left outer join Client_Invoices inv on cli.CLIENT_ID = inv.CLIENT_ID
	group by cli.CLIENT_ID
	
)

,clientData as 
(
	/* Handle applicable client data for this report */
	select cli.CLIENT_ID
	,isnull(LEA,0) as LEA 
	,cli.CLIENT_NAME
	,cli.LEARecoveryBudget,
	cli.CLIENT_CDS
	, comp.name as compName
	,ISNULL(Rep.first_name + ' ' + Rep.last_name, 'No Rep in SpEdCare') as repNameInfo
	
	from CLIENTS_Client cli
	
	--/*******************************************************************-- District Rep
LEFT OUTER JOIN CLIENTS_Client_Reps AS Rep
	ON Rep.id = cli.ClientRepIDLEACurrent
     
--/*******************************************************************-- Company
LEFT OUTER JOIN COMPANIES AS comp
	ON comp.id = cli.OwnedByCompanyID_LEA
	
	WHERE cli.CLIENT_ID <> 112
	AND cli.RevenueSharingCategoryLEACurrent <> 'Never an LEA Client'
	--AND cli.LEA = 1
	and (@clientID is null or @clientID = cli.CLIENT_ID)
)
,clientEligData as
(
	select 
		cli.CLIENT_ID
		,ISNULL(client_elig_rprt.numpats,0) as numPatients
		,ISNULL(client_elig_rprt.num_elig,0) as numEligible
		
	 from
	CLIENTS_Client cli
	OUTER APPLY
(
	SELECT *
	FROM dbo.MEDI_CAL_ELIGIBILITY_DATA(cli.Client_ID,null)
) client_elig_rprt 
)


, SpEdCareRpt as
(
select 
	[District Rep]												= cli.repNameInfo
	,[SpEdCare Client ID #]										= CONVERT( VARCHAR(MAX), cli.CLIENT_ID )
	,[Active ?]													= CASE WHEN cli.LEA = 1 then 'Yes' else 'No' END 
	,[CDS Code]													= cli.CLIENT_CDS

	,[Client Name]												= cli.CLIENT_NAME
 
	,[Number of Special Education Patients from Last File]		= CONVERT( VARCHAR(MAX), ced.numPatients )
	,[Number of Special Education Medi-Cal Recipient Patients]		= CONVERT( VARCHAR(MAX), ced.numEligible )
	,[Percent of Special Education Patients who are Medi-Cal Recipients] =
		CASE
			WHEN (ced.numPatients = 0)
			THEN ''
			WHEN (ced.numEligible = 0)
			THEN ''
			ELSE CONVERT( VARCHAR(MAX), CONVERT( INT, ROUND( ( CONVERT( DECIMAL(18,2), ced.numEligible ) / CONVERT( DECIMAL(18,2), ced.numPatients ) * CONVERT( DECIMAL(6,2), 100 ) ), 0 ) ) ) + '%'
		END
	,[Budget Target This Year ($500 per Mcal Patient)] =
		CASE
			WHEN ( ISNULL(LEA ,0) = 0 )
			THEN '0'
			WHEN (cli.LEARecoveryBudget IS NULL)
			THEN CONVERT( VARCHAR(MAX), CAST( ISNULL(ced.numEligible * dbo.CONST_STANDARD_BUDGET_TARGET_PER_PATIENT(),0) AS MONEY ), 1 )
			ELSE CONVERT( VARCHAR(MAX), CAST( cli.LEARecoveryBudget AS MONEY), 1 )
		END	
	,[$ Client Got Per Medi-Cal Patient This Year] =
		CASE
			WHEN (ced.numEligible = 0)
			THEN '0'
			WHEN (crp_cfyb.NotAdjustmentTotalPaid = 0)
			THEN '0'
			ELSE '$' + CONVERT( VARCHAR(MAX), CONVERT( MONEY, ROUND( (crp_cfyb.NotAdjustmentTotalPaid / ced.numEligible), 2 ) ) )
		END
		
	
	,[$ Client Got - 5FY Ago - For Current Work]				= '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND( permData.[5FYagoClientGotforCurrentWork], 2 ), '0') ) )
	
	,[$ Client Got - 4FY Ago - For Current Work]				= '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND( permData.[4FYagoClientGotforCurrentWork], 2 ), '0') ) )
	
	,[$ Client Got - 3FY Ago - For Current Work]				= '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND( permData.[3FYagoClientGotforCurrentWork], 2 ), '0') ) )
	
	,[$ Client Got - 2FY Ago - For Current Work]				= '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND( permData.[2FYagoClientGotforCurrentWork], 2 ), '0') ) )

	,[$ Client Got - 1FY Ago - For Current Work]				= '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND( permData.[1FYagoClientGotforCurrentWork], 2 ), '0') ) )
	

	,[$ Client Got - Current FY - For Current Work]				= '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ROUND( crp_cfyb.NotAdjustmentTotalPaid ,2)))
	,[WORK ALERT] =
		CASE 
			when (cbi.recWorkInLast30 = 0 AND ent30Totals.totalSvcRecByPracLast30 = 0)
			then 'No Paper Claims nor Client-Entered Services in Past 30 Days'

			ELSE '' 
		END

	,[Number of Services Entered in SpEdCare by Clients This Month]		= CONVERT( VARCHAR(MAX), ent30Totals.totalSvcRecByPracLast30 )
	,[Number of Hours of Work on Hand as of Friday]						= CONVERT( VARCHAR(MAX), cbi.HoursOnHand )
	,[Number of Services Entered This Week]								= CONVERT( VARCHAR(MAX), entTotals.totalSvcRecThisWeek )
	,[Number of Services Entered This Year]								= CONVERT( VARCHAR(MAX), entTotals.totalSvcRecThisFY )
	
	,[Last Date Claims Were Transmitted] 								= ISNULL( CONVERT(VARCHAR(20),ts.Transmission_date, 10),'')
	
	,[Amount Invoiced to Client This Week]								= '$'+CONVERT( VARCHAR(MAX), cii.thisWeekInvTotal )
	, [Last Invoice Date For Client]									= ISNULL(CONVERT(VARCHAR(max), cii.lastInvoiced),'')
	


		
FROM clientData cli

inner join clientBatchInfo cbi on cli.CLIENT_ID = cbi.CLIENT_ID

inner join claim_recs_paid_thisFY_noproxies_cte_totals crp_cfyb
	on cli.CLIENT_ID = crp_cfyb.CLIENT_ID
 
inner join svc_recs_entered_thisFY_cte_totals entTotals
	on cli.CLIENT_ID = entTotals.CLIENT_ID

inner join svc_recs_entered_last_30_cte_totals ent30Totals
	on cli.CLIENT_ID = ent30Totals.CLIENT_ID
	
inner join claim_recs_entered_thisFY_counts crefyc
	on cli.CLIENT_ID = crefyc.CLIENT_ID

LEFT OUTER JOIN
(
	SELECT
		client_id
		,MAX(TRANSMISSION_DATE) AS Transmission_date
	FROM Transmission_Summary_By_Client_837
	GROUP BY CLIENT_ID
) ts
	ON ts.CLIENT_ID = cli.CLIENT_ID
       
inner JOIN
clientInvoiceInfo cii on cli.CLIENT_ID = cii.CLIENT_ID
     
----/*******************************************************************-- To get the permanent data for past fiscal years
LEFT OUTER JOIN LEA_FY_DATA permData
	ON permData.Client_ID = cli.CLIENT_ID
           
inner join clientEligData ced
	on cli.CLIENT_ID = ced.CLIENT_ID
)

select * from SpEdCareRpt


order by CONVERT(bigint, [SpEdCare Client ID #])

--select * from dbo.RPT_AnI_WEEKLY(null, null,@startlastweek, @endlastweek, @fysTART)

GO