USE [spedmon]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RPT_TATTLETALE]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_TATTLETALE]
GO

USE [spedmon]
GO




CREATE FUNCTION [dbo].[RPT_TATTLETALE](@clientID bigint, @pracID int, @groupID int, @asofdate datetime)
RETURNS TABLE
 AS RETURN
(

      with rpt_req_up_till_date as (
      SELECT rpt_end_date=GETDATE()
      ),
      rpt_req_date_range as (
      SELECT
      rpt_end_date, rpt_start_date FROM
      rpt_req_up_till_date CROSS APPLY 
      (SELECT rpt_start_date=dateadd(month,-12,DATEADD(MONTH, DATEDIFF(MONTH, 0, rpt_end_date), 0))) as rpt_start_date
      ),
      date_groupings as ( 
      SELECT rpt_start_date, id, startDate, endDate, monthYear
      FROM rpt_req_date_range cross apply dbo.DATE_RANGE_SPLIT( rpt_start_date, rpt_end_date)
      ),
      date_groupings_piv as (
      SELECT 
      dpiv.[1] AS "c1(_col_label)",
 dpiv.[2] AS "c2(_col_label)",
 dpiv.[3] AS "c3(_col_label)",
 dpiv.[4] AS "c4(_col_label)",
 dpiv.[5] AS "c5(_col_label)",
 dpiv.[6] AS "c6(_col_label)",
 dpiv.[7] AS "c7(_col_label)",
 dpiv.[8] AS "c8(_col_label)",
 dpiv.[9] AS "c9(_col_label)",
 dpiv.[10] AS "c10(_col_label)",
 dpiv.[11] AS "c11(_col_label)",
 dpiv.[12] AS "c12(_col_label)",
 dpiv.[13] AS "c13(_col_label)"
 FROM
 ( 
	 SELECT id, monthYear  FROM date_groupings
  ) dsrc
	 PIVOT( 
	   MAX(monthYear) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13])
	 ) dpiv
      ),
      	pracCore as
	(
	select
					pp.PRACTITIONER_ID as [Practitioner ID],
					cc.CLIENT_NAME as [Client],
					cc.CLIENT_ID AS CliID,
					pp.LAST_NAME as [Last Name],
					pp.FIRST_NAME as [First Name],
					gg_ad.GROUP_NAME as [Practitioner Type],
					gg_rp.GROUP_NAME as [Reporting Group],
					isnull(pc.date_start, '')	as [Added to SpEdCare] 
					 
				from 
					practitioner_practitioner pp 
					inner join practitioner_client pc on pp.practitioner_id = pc.practitioner_id AND (pp.practitioner_id = @pracID or @pracID IS NULL) -- requested filter option
					inner join clients_client cc on pc.client_id = cc.client_id AND (cc.client_id = @clientID OR @clientID IS NULL) -- requested filter option
					inner join PRACTITIONER_GROUPS pg_ad on pp.PRACTITIONER_ID = pg_ad.PRACTITIONER_ID and pg_ad.GROUP_TYPE in (1,2) AND (pg_ad.GROUP_ID = @groupid OR @groupid IS NULL)
					-- TODO: we need to clarify why PRACTITIONER_GROUPS and GROUP_Group are both joined in this query, twice.
					inner join GROUP_Group gg_ad on pg_ad.GROUP_ID = gg_ad.GROUP_ID
					-- TODO: clarify why the first join is INNER and the second join it LEFT OUTER
					left outer join PRACTITIONER_GROUPS pg_rp on pp.PRACTITIONER_ID = pg_rp.PRACTITIONER_ID and pg_rp.GROUP_TYPE in (3,5)
					left outer join GROUP_Group gg_rp on pg_rp.GROUP_ID = gg_rp.GROUP_ID
				where pp.ACTIVE = 1
				and (isnull(pp.includeInFinRepts,0)= 1)
				and cc.lea = 1				
				and cc.client_id <> 112
				and cc.ClientRepIDLEACurrent IS NOT NULL -- original iteration of this report inner joined on Client Rep;
				                                         -- although we are not doing that anymore, I still want to make sure we generate the same number of rows as before,
				                                         -- so as to inspire confidence in the quality of my code refactor.
	),
	PracDatePeriods as
    (    
		select      
			CONVERT(date,tc_date.startDate) as [Start Date],   
			CONVERT(DATE,tc_date.endDate) as [End Date],     
			'c' + CONVERT(VARCHAR,tc_date.id) as mo_id,
			tc_prac.*,
			tc_date.rpt_start_date                  
		
		from    
			date_groupings tc_date  /* ta - dah! */     
			/*  cross join pracRptCore  tc_prac */
			 cross join pracCore  tc_prac 
			 
	),
	-- cross join, above.
	TattlePivotBase as      
	(      
		select    
			pdp.[Client],
			pdp.CliID,          
			pdp.mo_id,      
			pdp.[Start Date],      
			pdp.[End Date],           
			pdp.[Last Name],           
			pdp.[First Name],           
			pdp.[Practitioner Type],           
			pdp.[Reporting Group],           
			pdp.[Practitioner ID],    
			pdp.[Added to SpEdCare],
			COUNT(sr.id) as [Total Services],
			rpt_start_date
			           
		from PracDatePeriods pdp
		left outer join SERVICE_RECORDS sr
		
		on
			sr.dos >= rpt_start_date
			and sr.dos >= pdp.[Start Date]
			and sr.dos <=pdp.[End Date]
			and sr.pracID = pdp.[Practitioner ID]
			and sr.state not in (99)     
			
		group by pdp.[Client],
		    pdp.CliID,           
			pdp.mo_id,      
			pdp.[Start Date],      
			pdp.[End Date],           
			pdp.[Last Name],           
			pdp.[First Name],           
			pdp.[Practitioner Type],           
			pdp.[Reporting Group],           
			pdp.[Practitioner ID],
			pdp.[Added to SpEdCare] ,
			rpt_start_date
	),/*	
	TattlePivotClientConsultantBase as
	(
		select
			ccr.first_name + ' ' + ccr.last_name as [Consultant],
			tpb.[Client],           
			tpb.mo_id,      
			tpb.[Start Date],      
			tpb.[End Date],           
			tpb.[Last Name],           
			tpb.[First Name],           
			tpb.[Practitioner Type],           
			tpb.[Reporting Group],           
			tpb.[Practitioner ID],
			tpb.[Added to SpEdCare]
			,[Total Services] 
		from
			TattlePivotBase tpb
			inner join clients_client cc on tpb.[CliID] = cc.CLIENT_ID -- TODO: maybe figure out how to get the cc/ccrep info above, so we don't have to join this table a second time
			 left outer join dbo.CLIENTS_Client_Reps ccr on cc.ClientRepIDLEACurrent = ccr.id
	),*/
	pivot_table_output as 
	(
		SELECT  *
	  			
	 from 
		(
			select     
				[Practitioner ID],
				[Practitioner Type],
				--[Consultant],
				[Client],        
				[Last Name],    
				[First Name],    
				[Reporting Group],
				CASE
					WHEN [Added to SpEdCare] < rpt_start_date
					THEN ''
			        ELSE convert(varchar(10),convert(date,[Added to SpEdCare])) -- w t f?
					END	 as [Added to SpEdCare],

				mo_id,
				[Total Services]
			--from TattlePivotClientConsultantBase //we are not including Consultant in the report, as per Chuck's request
			FROM TattlePivotBase
			
		) tpb
    PIVOT
    ( 
		SUM([Total Services]) 
		for [mo_id] in 
			( 
			[c13],[c12],[c11],[c10],[c9],[c8],[c7],[c6],[c5],[c4],[c3],[c2],[c1]
			)
	) as PivotTattleOutput
	),
	pivot_tattle_output_labeled as (
	
	  SELECT 	-- pto.[Practitioner ID],
	            pto."Last Name" AS "Last Name (Practitioner)",    
				pto."First Name",
				pto."Practitioner Type",    
				pto.[Reporting Group],
				pto.[Added to SpEdCare],
				dgp.[c13(_col_label)],
				CASE WHEN pto.[c13] = 0 THEN '' ELSE CONVERT(VARCHAR(11),pto.[c13]) END AS c13,

				dgp.[c12(_col_label)],
				CASE WHEN pto.[c12] = 0 THEN '' ELSE CONVERT(VARCHAR(11),pto.[c12]) END AS c12,
				
				dgp.[c11(_col_label)],
				CASE WHEN pto.[c11] = 0 THEN '' ELSE CONVERT(VARCHAR(11),pto.[c11]) END AS c11,
				
				dgp.[c10(_col_label)],
				CASE WHEN pto.[c10] = 0 THEN '' ELSE CONVERT(VARCHAR(11),pto.[c10]) END AS c10,
				
				dgp.[c9(_col_label)],
				CASE WHEN pto.[c9] = 0 THEN '' ELSE CONVERT(VARCHAR(11),pto.[c9]) END AS c9,
				
				dgp.[c8(_col_label)],
				CASE WHEN pto.[c8] = 0 THEN '' ELSE CONVERT(VARCHAR(11),pto.[c8]) END AS c8,

				dgp.[c7(_col_label)],
				CASE WHEN pto.[c7] = 0 THEN '' ELSE CONVERT(VARCHAR(11),pto.[c7]) END AS c7,

				dgp.[c6(_col_label)],
				CASE WHEN pto.[c6] = 0 THEN '' ELSE CONVERT(VARCHAR(11),pto.[c6]) END AS c6,

				dgp.[c5(_col_label)],
				CASE WHEN pto.[c5] = 0 THEN '' ELSE CONVERT(VARCHAR(11),pto.[c5]) END AS c5,

				dgp.[c4(_col_label)],
				CASE WHEN pto.[c4] = 0 THEN '' ELSE CONVERT(VARCHAR(11),pto.[c4]) END AS c4,
				
				dgp.[c3(_col_label)],
				CASE WHEN pto.[c3] = 0 THEN '' ELSE CONVERT(VARCHAR(11),pto.[c3]) END AS c3,

				dgp.[c2(_col_label)],
				CASE WHEN pto.[c2] = 0 THEN '' ELSE CONVERT(VARCHAR(11),pto.[c2]) END AS c2,
				
				dgp.[c1(_col_label)],
				CASE WHEN pto.[c1] = 0 THEN '' ELSE CONVERT(VARCHAR(11),pto.[c1]) END AS c1
				
				FROM date_groupings_piv dgp
				cross apply
				pivot_table_output pto
	) 
	
	SELECT TOP (dbo.CONST_MAX_ROWS())
	  			*
	FROM pivot_tattle_output_labeled
		
	ORDER BY 
				--[Practitioner ID],
				--[monthYear],
				[Reporting Group],        
				[Last Name (Practitioner)],    
				[First Name]
				--[Consultant]
				--[Client]
);
      

GO
  
  GRANT SELECT ON  [dbo].[RPT_TATTLETALE] TO [webuser]
GO
  
 --SELECT * FROM [dbo].[RPT_TATTLETALE](null,null,null,null)