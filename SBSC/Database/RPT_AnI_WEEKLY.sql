USE [SPEDMON]

GO
/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('RPT_AnI_WEEKLY') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_AnI_WEEKLY]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_AnI_WEEKLY]
(@repID              BIGINT,
 @clientID           BIGINT,
 @startWeek          DATE,
 @endWeek            DATE, 
 @fyStart            DATE
)
RETURNS TABLE

AS
/***************************************************************************
 * RPT_AnI_WEEKLY */
/**
 * Generates A&I weekly report
 * 
 * @param  clientID      Patients client id
 * @param  repID         District rep id
 * @param  @startWeek    START DATE,
 * @param  @endWeek      END DATE, 
 * @param  @fyStart      START DATE OF CURRENT FISCAL YEAR
 *
 * @return Table
 ***************************************************************************/
 
RETURN(

    with claim_recs_cte as
       (select cc.client_id,PROCEDURE_ID,SERVICE_DATE,AMOUNT_PAID,EDSPERCENT,DATE_ADJUDICATED from CLAIM_Claim cc
		inner join CLAIM_Claim_Adjudication cca on cc.CLAIM_ID = cca.CLAIM_ID
		where cca.DATE_ADJUDICATED >= @fyStart 
			and DATE_ADJUDICATED <= @endWeek
		    and CLIENT_ID not in (18, 87, 112)
		    and cc.IS_PROXY = 0
		)
		
   ,svc_recs_cte as
         (select sr.clientID,sr.created,sr.id ,cc.PROCEDURE_ID from SERVICE_RECORDS sr
		  inner join SPEDMON.dbo.CLAIM_Claim as cc on cc.CLAIM_ID =sr.claimID1
		  where sr.created >= @fyStart and sr.created <= @endWeek and cc.PROCEDURE_ID <> 203 
			and CLIENT_ID not in (18, 87, 112) and cc.IS_PROXY = 0)	
			
   --,rpt_data_cte as
   --(	  	  		
   SELECT top (dbo.CONST_MAX_ROWS())	
        ISNULL (Rep.first_name + ' ' + Rep.last_name, 'No Rep in SpEdCare')  as 'District Rep'
		,cli.CLIENT_ID                                                       as 'Client ID'
		,convert(int, LEA)                                                   as 'Active'
		,cli.CLIENT_CDS                                                      as 'CDS Code'
		,comp.name                                                           as 'Company'
		,cli.CLIENT_NAME                                                     as 'Client Name'
        ,ISNULL(client_elig_rprt.numpats,0)                                  as 'Number of Special Education Patients from Last File'
		,ISNULL(client_elig_rprt.num_elig,0)                                 as 'Number of Special Education Medi-Cal Recipient Patients'
		,
		CASE when (client_elig_rprt.numpats is null)
		then null
		when (client_elig_rprt.num_elig is null)
		then null
		else (CONVERT(DECIMAL(12,2),client_elig_rprt.num_elig)/client_elig_rprt.numpats) end
		                                                                     as 'Percent of Special Education Patients who are Medi-Cal Recipients'	
	    ,CASE
	     when (isnull(LEA ,0) = 0) then 0
	     when (cli.LEARecoveryBudget is null) 
	     then ISNULL(client_elig_rprt.num_elig * dbo.CONST_STANDARD_BUDGET_TARGET_PER_PATIENT(),0)
	     else cli.LEARecoveryBudget End                                      as 'Budget Target This Year ($500 per Mcal Patient)'
        ,CASE when (isnull(client_elig_rprt.num_elig ,0) = 0)
		 then 0
		 when (isnull(Current_FY_TOTAL ,0) = 0)
		 then 0
         else (CONVERT(DECIMAL(12,2),Current_FY_TOTAL)/client_elig_rprt.num_elig) end 
                                                                             as '$ Client Got Per Medi-Cal Patient This Year'
        ,permData.[5FYagoTotalClientGot]
		,permData.[5FYagoStateAdjustment]
		,permData.[5FYagoClientGotforCurrentWork]
		,permData.[4FYagoTotalClientGot]
		,permData.[4FYagoStateAdjustment]
		,permData.[4FYagoClientGotforCurrentWork]
		,permData.[3FYagoTotalClientGot]
		,permData.[3FYagoStateAdjustment]
		,permData.[3FYagoClientGotforCurrentWork]
		,permData.[2FYagoTotalClientGot]
		,permData.[2FYagoStateAdjustment]
		,permData.[2FYagoClientGotforCurrentWork]
		,permData.[1FYagoTotalClientGot]
		,permData.[1FYagoStateAdjustment]
		,permData.[1FYagoClientGotforCurrentWork]                                                                                
        ,ISNULL(Current_FY_TOTAL,0)                                          as 'Current Year - Total'
		,ISNULL(Current_FY_Adjustments,0)                                    as 'Current Year - State Adjustments'
		,ISNULL(Current_FY_TOTAL,0) - ISNULL(Current_FY_Adjustments,0)       as '$Client got for Current Year - For Current Work'
		,CASE when LEA = 0 then '0'
		      when (ISNULL(Current_FY_TOTAL,0) - ISNULL(Current_FY_Adjustments,0) = 0 )
		      then 'NONE This Year'
		      when (isnull(permData.[1FYagoClientGotforCurrentWork],0) = 0) 
		      then 'None LAST Year'
		      else cast(round(((ISNULL(Current_FY_TOTAL,0) - ISNULL(Current_FY_Adjustments,0))/
		           (permData.[1FYagoClientGotforCurrentWork])),2) as varchar(max)) end
		                                                                     as 'This Year amount for current work COMPARED to Last Year amount for current work'
		,CASE when ISNULL(ib.clientID,0) = 0
		      then 'Nope !!'
		      else '' end	                                                 as 'Was Work Received Within the Past 30 Days ?'	
		,ISNULL(Record_Count_Client,0)                                       as 'Number of Services Entered in SpEdCare by Clients Within the Past 30 Days'     
		,CASE when (ISNULL(ib.clientID,0) = 0 and 
		            ISNULL(Record_Count_Client,0) = 0)
		      then 'Neither !!'
		      else '' end	                                                 as 'WORK ALERT - "Neither" means the client failed to submit work in a timely manner'
		,isnull(hoh.HoursOnHand,0)                                           as 'Number of Hours of Work on Hand as of Friday'
		,ISNULL(Record_Count_Anyone_This_Week,0)                             as 'Number of Services Entered This Week'
		,ISNULL(Record_Count_Anyone_This_Year,0)                             as 'Number of Services Entered This Year'
		,ts.TRANSMISSION_DATE                                                as 'Last Date Claims Were Transmitted'
		,isnull(cv.INVOICE_AMOUNT,0)                                         as 'Amount Invoiced to Client This Week'
						
     from CLIENTS_Client cli
--/*******************************************************************-- To compute FY12/13 Total Amount		
	left outer join
	(	select client_id, SUM(AMOUNT_PAID * EDSPERCENT) as Current_FY_TOTAL from claim_recs_cte
		group by CLIENT_ID) 
	FY1213 on FY1213.CLIENT_ID = cli.client_id

--/*******************************************************************-- To compute FY12/13 Amount from State Adjustments
	left outer join
	(	select client_id, SUM(AMOUNT_PAID * EDSPERCENT) as Current_FY_Adjustments from claim_recs_cte
	    where PROCEDURE_ID = 203
		group by CLIENT_ID) 
	FY1213Adjustments on FY1213Adjustments.CLIENT_ID = cli.client_id

--/*******************************************************************-- To compute the TOTAL number of claims entered this year************************
left outer join
	(	select CLIENT_ID, ISNULL(SVC_count,0) as Record_Count_Anyone_This_Year from 
		(	select sr.clientID, ISNULL(count(sr.id),0) as SVC_count from svc_recs_cte sr		  
		    group by sr.clientID) 
	as HazSvcRcrd
	right outer join CLIENTS_Client cc on HazSvcRcrd.clientID = cc.CLIENT_ID
	where CLIENT_ID not in (18, 87, 112)	)
AnyoneEnteredServicesThisYear on AnyoneEnteredServicesThisYear.CLIENT_ID = cli.CLIENT_ID
--/*******************************************************************-- To compute the TOTAL number of claims entered this week*********************
left outer join
	(	select CLIENT_ID, ISNULL(SVC_count,0) as Record_Count_Anyone_This_Week from 
		(	select sr.clientID, ISNULL(count(sr.id),0) as SVC_count from svc_recs_cte sr
		    where sr.created >= @startweek 
			and sr.created <= @EndWeek 
		    group by sr.clientID) 
	as HazSvcRcrd
	right outer join CLIENTS_Client cc on HazSvcRcrd.clientID = cc.CLIENT_ID
	where CLIENT_ID not in (18, 87, 112)	)
AnyoneEnteredServicesThisWeek on AnyoneEnteredServicesThisWeek.CLIENT_ID = cli.CLIENT_ID

--/*******************************************************************-- To compute latest date claims were transmitted
left outer join 
    (select client_id,max(TRANSMISSION_DATE) as Transmission_date
       from Transmission_Summary_By_Client_837
       group by CLIENT_ID) ts on ts.CLIENT_ID = cli.CLIENT_ID                                                      
--/*******************************************************************-- To compute Practi-Cal invoice amount for this week
left outer join
   (select client_id, sum(INVOICE_AMOUNT) as INVOICE_AMOUNT from Client_Invoices 
    where (INVOICE_DATE between @StartWeek and @EndWeek) and Revenue_Program in ('LEA','CRCS')
    group by client_id) cv on cv.CLIENT_ID = cli.CLIENT_ID                                    
--/*******************************************************************-- To compute the number of services entered by client personnel in the past 30 days
left outer join
	(	select CLIENT_ID, ISNULL(SVC_count,0) as Record_Count_Client from 
		(	select sr.clientID, ISNULL(count(sr.id),0) as SVC_count from SERVICE_RECORDS sr
		  inner join Users.dbo.Users uu on sr.userID = uu.userrid
		  inner join Users.dbo.Membership um on um.UserId = uu.UserId
		  where SBSC_Employee <> 1 
			and sr.created >= DATEADD(day, -30, @EndWeek) and sr.created <= @EndWeek
			and sr.clientID not in (18, 87, 112)
		  group by sr.clientID) 
	as HazSvcRcrd
	right outer join CLIENTS_Client cc on HazSvcRcrd.clientID = cc.CLIENT_ID
	where CLIENT_ID not in (18, 87, 112)	)
ClientEnteredServicesLast30Days on ClientEnteredServicesLast30Days.CLIENT_ID = cli.CLIENT_ID

--/*******************************************************************-- District Rep	
	left outer join CLIENTS_Client_Reps as Rep on Rep.id = cli.ClientRepIDLEACurrent
--/*******************************************************************-- Company
	left outer join COMPANIES as comp on comp.id = cli.OwnedByCompanyID_LEA
--/*******************************************************************-- To compute if paper or scanned work has been received within the past 30 days
	left outer join
	(select distinct ClientID from INPUT_BATCHES
	where Date_Recieved between DATEADD(dd,-30,@endWeek) and @endWeek) ib on ib.ClientID = cli.CLIENT_ID
	                                
--/*******************************************************************-- To compute number of hours work on hand
	left outer join HOURS_ON_HAND(@clientID,@endWeek) hoh on hoh.Client_ID = cli.CLIENT_ID  

----/*******************************************************************-- To get the permanent data for past fiscal years
     left outer join LEA_FY_DATA permData on permData.Client_ID = cli.CLIENT_ID         	                               		

/******************************************/-- Medi-Cal eligibility data		
 outer apply
 ( select * from dbo.MEDI_CAL_ELIGIBILITY_DATA(cli.Client_ID,null)) client_elig_rprt 

/* This block computes I (YTD Claim Count) */
 outer apply
(
 select ISNULL(count(distinct claims.CLAIM_ID),0) I_tot from CLAIM_Claim claims
	where claims.CLIENT_ID = cli.CLIENT_ID
	and claims.PROCEDURE_ID <> 203 /* State Adjustment */
	and claims.ENTRY_DATE <= @EndWeek
	and claims.ENTRY_DATE >= @fyStart
	and claims.IS_PROXY = 0
) I

/* This block computes J (This Week Claim Count) */
outer apply
(
 select ISNULL(count(distinct claims.CLAIM_ID),0) J_tot from CLAIM_Claim claims
	where claims.CLIENT_ID = cli.CLIENT_ID
	and claims.PROCEDURE_ID <> 203 /* State Adjustment */
	and claims.ENTRY_DATE >= @StartWeek
	and claims.ENTRY_DATE <= @EndWeek
    and claims.IS_PROXY = 0
) J

where cli.CLIENT_ID <> 112 and 
      cli.RevenueSharingCategoryLEACurrent <> 'Never an LEA Client' and
   --   cli.LEA = 1 and
      (cast(@clientID as varchar(5)) is null or cli.Client_ID             = cast(@clientID as varchar(5))) and 
      (cast(@repID    as varchar(5)) is null or cli.ClientRepIDLEACurrent = cast(@repID    as varchar(5)))
order by cli.LEA desc, [Client Name])

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[RPT_AnI_WEEKLY] TO [webuser]

GO

 

