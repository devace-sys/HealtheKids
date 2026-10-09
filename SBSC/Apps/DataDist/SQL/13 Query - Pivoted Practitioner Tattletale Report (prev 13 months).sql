GO
USE SPEDMON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    
DECLARE @clientID bigint,
		@groupid bigint,
		@pracid bigint,
		@startdate datetime,
		@enddate datetime
		
SET @startdate = dateadd(month,-12,DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0))
SET @enddate = GETDATE()
		
DECLARE @columns varchar(max)

SELECT @columns = COALESCE(@columns + ',','') + QUOTENAME(col) 
FROM
(	
	SELECT DISTINCT [Month/Year] AS col FROM
	(	
		SELECT 
			TOP (dbo.CONST_MAX_ROWS()) * 
			FROM dbo.RPT_SERVICE_RECORD_TATTLE_COMBINE_RESULTS(@clientID,@groupID,@pracID, @startDate, @endDate) q 
			ORDER BY CONVERT(DATE,q.[Start Date]) 
	) sq
) cols
ORDER BY CONVERT(date, col) desc /* <- witchcraft O_O */

  DECLARE @sql nvarchar(max)
  
  SET @sql = 
  '
    declare @clientID bigint,    @groupid bigint,    @pracid bigint,    
    @startdate datetime,    @enddate datetime 
		
	set @startdate = ''' + CONVERT(VARCHAR(max),@startdate) +'''
	set @enddate = ''' + CONVERT(VARCHAR(max),@enddate) +'''
	set @clientid = NULL
  
    
      ;with TattleCore as
	(    
		select * 
		from dbo.RPT_SERVICE_RECORD_TATTLE_COMBINE_RESULTS(@clientID,@groupID,@pracID,@startDate,@endDate)
	),
	
	pracCore as
	(
	select
					pp.PRACTITIONER_ID as [Practitioner ID],
					cc.CLIENT_NAME as [Client],
					pp.LAST_NAME as [Last Name],
					pp.FIRST_NAME as [First Name],
					gg_ad.GROUP_NAME as [Practitioner Type],
					gg_rp.GROUP_NAME as [Reporting Group],
					isnull(pc.date_start, '''')	as [Added to SpEdCare]
					 
				from 
					practitioner_practitioner pp
					inner join practitioner_client pc on pp.practitioner_id = pc.practitioner_id
					inner join clients_client cc on pc.client_id = cc.client_id
					inner join PRACTITIONER_GROUPS pg_ad on pp.PRACTITIONER_ID = pg_ad.PRACTITIONER_ID and pg_ad.GROUP_TYPE in (1,2)
					inner join GROUP_Group gg_ad on pg_ad.GROUP_ID = gg_ad.GROUP_ID
					
					left outer join PRACTITIONER_GROUPS pg_rp on pp.PRACTITIONER_ID = pg_rp.PRACTITIONER_ID and pg_rp.GROUP_TYPE in (3,5)
					left outer join GROUP_Group gg_rp on pg_rp.GROUP_ID = gg_rp.GROUP_ID
				where pp.ACTIVE = 1
				and cc.lea = 1
				and cc.client_id <> 112
	),
	pracRptCore as
	(
	select distinct [Practitioner ID], Client, [Last Name], [First Name], [Practitioner Type], [Reporting Group] from TattleCore
	),
	
	PracDatePeriods as
    (    
		select      
			CONVERT(date,tc_date.[Start Date]) as [Start Date],      
			CONVERT(DATE,tc_date.[End Date]) as [End Date],      
			tc_date.[Month/Year],      
			tc_prac.[Practitioner ID],     
			tc_prac.Client,     
			tc_prac.[Last Name],     
			tc_prac.[First Name],     
			tc_prac.[Practitioner Type],     
			tc_prac.[Reporting Group],
			tc_prac.[Added to SpEdCare]              
		
		from    
			(select distinct [Start Date], [End Date], [Month/Year] from TattleCore) tc_date    
			/*  cross join pracRptCore  tc_prac */
			 cross join pracCore  tc_prac 
			 
	),  
	TattlePivotBase as      
	(      
		select    
			pdp.[Client],           
			pdp.[Month/Year],      
			pdp.[Start Date],      
			pdp.[End Date],           
			pdp.[Last Name],           
			pdp.[First Name],           
			pdp.[Practitioner Type],           
			pdp.[Reporting Group],           
			pdp.[Practitioner ID],    
			pdp.[Added to SpEdCare],
			COUNT(sr.id) as [Total Services]
			           
		from PracDatePeriods pdp
		left outer join SERVICE_RECORDS sr   
		on
			sr.dos >= @startdate
			and sr.dos >= pdp.[Start Date]       
			and sr.dos <=pdp.[End Date]       
			and sr.pracID = pdp.[Practitioner ID]
			and sr.state not in (99)     
			
		group by pdp.[Client],           
			pdp.[Month/Year],      
			pdp.[Start Date],      
			pdp.[End Date],           
			pdp.[Last Name],           
			pdp.[First Name],           
			pdp.[Practitioner Type],           
			pdp.[Reporting Group],           
			pdp.[Practitioner ID],
			pdp.[Added to SpEdCare] 
	),
	
	TattlePivotClientConsultantBase as
	(
		select
			ccr.first_name + '' '' + ccr.last_name as [Consultant],
			tpb.[Client],           
			tpb.[Month/Year],      
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
			inner join clients_client cc on tpb.[Client] = cc.CLIENT_NAME
			left outer join dbo.CLIENTS_Client_Reps ccr on cc.ClientRepIDLEACurrent = ccr.id
	
	) 
	
	
	select * from 
		(
			select     
				[Practitioner ID], 
				--[Practitioner Type],
				[Consultant],
				[Client],        
				[Last Name],    
				[First Name],    
				[Reporting Group],    
				CASE
					WHEN [Added to SpEdCare] < @StartDate
					THEN ''''
					ELSE convert(varchar(10),[Added to SpEdCare],101)
					END	 as [Added to SpEdCare],

				[Month/Year], 
				[Total Services]
			from TattlePivotClientConsultantBase
		) tpb
    PIVOT
    ( 
		SUM([Total Services]) 
		for [Month/Year] in 
			(' + @columns +')
	) as PivotTattleOutput
	ORDER BY 
				[Consultant],
				[Client],
				[Reporting Group],        
				[Last Name],    
				[First Name]    
    OPTION (recompile)
    
  '
  
 -- select @columns

	--select @nulledColumns
  
  --select @sql
  
  
EXEC sp_executesql @sql
  
  
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO
  