USE SPEDMON

GO

/*-------------------------------
* Exists/Drop
*------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_SPEDCARE_WEEKLY_REPORT') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_SPEDCARE_WEEKLY_REPORT
GO

CREATE FUNCTION [dbo].[RPT_SPEDCARE_WEEKLY_REPORT]
(

/***************************************************************************
 * RPT_SPEDCARE_WEEKLY_REPORT */
/**
 * Returns a table of report rows
 *
 * @param   reportAsOfDate         report As-Of date
 * @param   spEdCareClientID       filter by spEdCare Client ID
 * @param   repID                  filter by spEdCare district rep ID
 * @param   leaIsActive            filter by LEA Active status.
 * @return                         Table of report rows
 ***************************************************************************/
 

  @reportAsOfDate   DATE
, @clientID         BIGINT
, @repID            BIGINT
, @leaIsActive           BIT

)
RETURNS TABLE

AS RETURN

/*
The CTE was introduced into standard SQL in order to simplify various classes of SQL Queries for which a derived table just wasn't
suitable....  Introduced in SQL Server 2005, the common table expression (CTE) is a temporary named result set that you can reference
within a SELECT, INSERT, UPDATE, or DELETE statement.  https://www.red-gate.com/simple-talk/sql/t-sql-programming/sql-server-cte-basics/

One example, if you need to reference/join the same data set multiple times you can do so by defining a CTE. Therefore, it can be a form
of code re-use.  An example of self referencing is recursion.  https://stackoverflow.com/a/4740800
*/
(
WITH

cte_get_today AS
(
SELECT today = ISNULL(@reportAsOfDate, GETDATE())
--if we specify a date in the query parameters, then time-travel back to that date; otherwise, today is today
),

cte_def_time_intervals AS
(
   SELECT *,
-- specify the fiscal year as a four-digit number
   CASE
   WHEN MONTH(today) < 7
   -- if the current month is before july, then we are still in last year's fiscal year;
   -- otherwise, we are in this year's fiscal year
   THEN DATEADD(YEAR,-1,today)
   ELSE DATEADD(YEAR,0,today) -- lol, this command doesn't actually do anything
   END AS fyyear,
   DATEADD(DAY,-30,today) AS "30daysago"
   FROM
   cte_get_today
),

cte_begin_time_intervals AS
(
  SELECT *, convert(varchar(4),fyyear)+'07'+'01' AS fysTART,
-- the start of the fiscal year is July 1st, of whichever year (this year or last)
   case when datepart(weekday, today) >6 then
 -- if @today is Saturday
 -- (TODO: should be checking if @today is Friday or Saturday, in my opinion)
 DATEADD(DAY, +4, DATEADD(WEEK, DATEDIFF(WEEK, 0, today), 0))
 -- @endlastweek is set to Friday at midnight of this week
else DATEADD(DAY, -3, DATEADD(WEEK, DATEDIFF(WEEK, 0, today), 0)) end AS endlastweek
 -- else @endlastweek is set to Friday at midnight of last week
   FROM cte_def_time_intervals
),

cte_all_time_interval_info AS
( SELECT *,
  DATEADD(day,-7,endlastweek) AS startlastweek
  FROM cte_begin_time_intervals
   -- set @startlastweek to Thursday at midnight of the prior week
),

clientData AS
(
 /* Handle applicable client data for this report */
 SELECT cli.CLIENT_ID
 ,isnull(LEA,0) AS LEA
 ,cli.CLIENT_NAME
 ,cli.LEARecoveryBudget,
 cli.CLIENT_CDS
 , comp.name AS compName
 ,ISNULL(Rep.first_name + ' ' + Rep.last_name, 'No Rep in SpEdCare') AS repNameInfo
 FROM CLIENTS_Client cli
 --/*******************************************************************-- District Rep
LEFT OUTER JOIN CLIENTS_Client_Reps AS Rep
 ON Rep.id = cli.ClientRepIDLEACurrent -- OUTER JOIN populates column with "No Rep in SpEdCare" if rep's name not found
--/*******************************************************************-- Company
LEFT OUTER JOIN COMPANIES AS comp
 ON comp.id = cli.OwnedByCompanyID_LEA
 WHERE cli.CLIENT_ID <> 112
 AND cli.RevenueSharingCategoryLEACurrent <> 'Never an LEA Client'
 --AND cli.LEA = 1
 AND (@clientID IS NULL OR @clientID = cli.CLIENT_ID)
 AND
  (@repid IS NULL OR @repid = Rep.id)
 AND
-- implements @leaIsActive UDF parameter
(@leaIsActive IS NULL OR cli.LEA = @leaIsActive)
)

-- "Number of Services Entered This Year"
,
svc_recs_entered_thisFY_total AS (
 SELECT
   sr.clientID
   ,COUNT(DISTINCT CASE WHEN sr.created >= fyStart THEN sr.id END) AS totalSvcRecThisFY
   ,COUNT(DISTINCT CASE WHEN sr.created >= [30daysago] THEN sr.id END ) AS last30days    
 FROM
  cte_all_time_interval_info
  CROSS JOIN
  SERVICE_RECORDS sr
   INNER JOIN SPEDMON.dbo.CLAIM_Claim AS cc
   ON cc.CLAIM_ID = sr.claimID1
 WHERE sr.created >= CASE WHEN fyStart < [30daysago] THEN fyStart ELSE [30daysago] END
     AND sr.created <= today
     AND cc.PROCEDURE_ID <> 203
     AND cc.IS_PROXY = 0
 GROUP BY sr.clientID
)

,clientInvoiceInfo AS
(
-- returns lastInvoiced date, and "lastWeekInvTotal"

 SELECT
   CLIENT_ID
   ,SUM( case when INVOICE_DATE BETWEEN startlastWeek AND endlastweek AND Revenue_Program IN ('LEA','CRCS') then INVOICE_AMOUNT else 0 end) AS lastWeekInvTotal
   ,MAX(INVOICE_DATE) AS lastInvoiced
 FROM
  cte_all_time_interval_info
  CROSS JOIN
  Client_Invoices
 GROUP BY CLIENT_ID

)

, cte_most_recent_transmission AS (
 SELECT
   client_id
   ,MAX(TRANSMISSION_DATE) AS Transmission_date
 FROM Transmission_Summary_By_Client_837
 GROUP BY CLIENT_ID
)
,

SpEdCareRpt AS
(
SELECT
 [District Rep]                                                                                         = cli.repNameInfo
 ,[SpEdCare Client ID #]                                                                                = CONVERT( VARCHAR(MAX), cli.CLIENT_ID )
 ,[Active ?]                                                                                                    = CASE WHEN cli.LEA = 1 then 'Yes' else 'No' END
 ,[CDS Code]                                                                                                    = cli.CLIENT_CDS

 ,[Client Name]                                                                                         = cli.CLIENT_NAME


 --,"[Budget Target This Year ($500 per Mcal Patient)]" =
 ,"BudgetTargetThisYr" =
   CASE
     WHEN ( ISNULL(cli.LEA ,0) = 0 )
     THEN '0'
     WHEN (cli.LEARecoveryBudget IS NULL)
     THEN CONVERT( VARCHAR(MAX), CAST( ISNULL(ced.num_elig * dbo.CONST_STANDARD_BUDGET_TARGET_PER_PATIENT(),0) AS MONEY ), 1 )
     ELSE CONVERT( VARCHAR(MAX), CAST( cli.LEARecoveryBudget AS MONEY), 1 )
   END

-- ,"[$ Client Got - 3FY Ago - For Current Work]"                               = '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND( permData.[3FYagoClientGotforCurrentWork], 2 ), '0') ) )
   , fydata.[c27(_col_label)]
   , '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND(fydata.[c27], 2 ), '0') ) ) AS [c27]
   
   , fydata.[c24(_col_label)]
   , '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND(fydata.[c24], 2 ), '0') ) ) AS [c24]  

-- ,"[$ Client Got - 2FY Ago - For Current Work]"                               = '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND( permData.[2FYagoClientGotforCurrentWork], 2 ), '0') ) )
   
   , fydata.[c22(_col_label)]
   , '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND(fydata.[c22], 2 ), '0') ) ) AS [c22]
   
   , fydata.[c19(_col_label)]
   , '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND(fydata.[c19], 2 ), '0') ) ) AS [c19]

-- ,"[$ Client Got - 1FY Ago - For Current Work]"                               = '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND( permData.[1FYagoClientGotforCurrentWork], 2 ), '0') ) )

   , fydata.[c17(_col_label)]
   , '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND(fydata.[c17], 2 ), '0') ) ) AS [c17]
   , fydata.[c14(_col_label)]
   , '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND(fydata.[c14], 2 ), '0') ) ) AS [c14]

/*
,"[$ Client Got - Prev FY - For Current Work]"                          = '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ROUND( livecalc_prev_FY.TOTAL_INITIAL_REIMBURSEMENTS,2)))
*/
   , fydata.[c12(_col_label)]
   , '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND(fydata.[c12], 2 ), '0') ) ) AS [c12]
   , fydata.[c9(_col_label)]
   , '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND(fydata.[c9], 2 ), '0') ) )  AS [c9]
   
/*  
--,"[$ Client Got - Current FY - For Current Work]"                             = '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ROUND( crp_cfyb.NotAdjustmentTotalPaid ,2)))
,"[$ Client Got - Current FY - For Current Work]"                               = '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ROUND( livetotals_this_FY.TOTAL_INITIAL_REIMBURSEMENTS ,2)))
*/

   , fydata.[c7(_col_label)]
   , '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND(fydata.[c7], 2 ), '0') ) ) AS [c7]
   , fydata.[c4(_col_label)]
   , '$'+CONVERT( VARCHAR(MAX), CONVERT( MONEY, ISNULL(ROUND(fydata.[c4], 2 ), '0') ) )  AS [c4]

--,"[Number of Services Entered in SpEdCare by Clients Last 30 Days]"
  ,"NumSvcsLast30"
                = CONVERT( VARCHAR(MAX), entTotals.last30days )

--,"[Number of Services Entered This Fiscal Year]"
  ,"NumSvcsThisFY"
                                                                = CONVERT( VARCHAR(MAX), entTotals.totalSvcRecThisFY )

 --,"[Last Date Claims Were Transmitted]"
   ,"LastDateTransmitted"
                                                                = ISNULL( CONVERT(VARCHAR(20),ts.Transmission_date, 10),'')

 --,"[Amount Invoiced to Client This Week]"
   ,"AmtInvoicedThisWk"
                                                                = '$'+CONVERT( VARCHAR(MAX), cii.lastWeekInvTotal )
 --,"[Last Invoice Date For Client]"
   ,"LastInvoiceDate"
                                                                        = ISNULL(CONVERT(VARCHAR(max), cii.lastInvoiced),'')
   ,OK_TO_REPORT_UP_TO_DATE



FROM

dbo.FY_TOTALS_LAST_7_ONTHEFLY(@reportAsOfDate,@clientID,@leaIsActive, 4) fydata

RIGHT OUTER JOIN

clientData cli ON cli.CLIENT_ID = fydata.CLIENT_ID

OUTER APPLY dbo.MEDI_CAL_ELIGIBILITY_DATA(cli.CLIENT_ID,NULL) ced
-- no need to have this function call inside a separate CTE;
-- in fact, the only way to write such a CTE would be to APPLY this function against CLIENTS_Client, which means needlessly querying CLIENTS_Client a second time

LEFT JOIN clientInvoiceInfo cii ON ced.CLIENT_ID = cii.client_id

-- "Number of Services Entered This Year"
LEFT JOIN svc_recs_entered_thisFY_total entTotals
 ON ced.CLIENT_ID = entTotals.clientID

-- last date claims were transmitted
LEFT OUTER JOIN cte_most_recent_transmission ts
 ON ts.CLIENT_ID = ced.CLIENT_ID

)
SELECT top (dbo.CONST_MAX_ROWS()) * FROM SpEdCareRpt
ORDER BY [Client Name]

)


GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  [dbo].[RPT_SPEDCARE_WEEKLY_REPORT] TO [webuser]
GO
  