USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_MINS_BY_PRAC_RPT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_MINS_BY_PRAC_RPT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SERVICE_MINS_BY_PRAC_RPT] (
    @userID                BIGINT
  , @userGroup             INT
  , @userRank              INT
  , @clientID              bigint
  , @rptGroupID			   bigint
  , @groupSvcClassNameID   bigint
  , @pracID                bigint
  , @endDate               DATE
)

returns table
as

return
(
	-- month calculation queries are copied from dbo.RPT_TATTLETALE
    with date_groupings as ( 
		SELECT
		    id
		  , startDate
		  , endDate
		  , monthYear
		  , yy = DATEPART(year, startDate) 
		  , mm = DATEPART(mm, startDate)
		FROM (select * from dbo.DATE_RANGE_SPLIT(dateadd(month,-11, @endDate), @endDate)) as drs
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
			dpiv.[12] AS "c12(_col_label)"
		FROM
		( 
			SELECT id, monthYear FROM date_groupings
		) dsrc
		PIVOT( 
			MAX(monthYear) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
		) dpiv
	)
	,
	cte_pracs_in_reporting_group
	as
	(
	  select 
		  CLIENT_ID       = rpvc.clientID
		, PRACTITIONER_ID = rpvc.pracID
		, CONCAT_NAME     = rpvc.pracName
		, GROUP_NAME      = rpvc.reptGroupName
      from dbo.RPT_PRACTITIONERS_REVIEW_CORE (@userID, @userGroup, @userRank,@clientID,@pracID,null,@rptGroupID,@groupSvcClassNameID,null,null,null) as rpvc
	  where ( 
	  /* Currently active prac */
	  (rpvc.active = 1)
	    or 
      /* Inactive prac but with services recorded in date range for report */
	  ((rpvc.active = 0) and (exists (select top 1 sr.id
										   from date_groupings as tc_date
										   join dbo.SERVICE_RECORDS as sr
										   on  (
										          (sr.clientID = rpvc.clientID)
											  and (sr.pracID = rpvc.pracID)
											  and (sr.patID is not null)
											  and (sr.dos between CONVERT(date,tc_date.startDate) and CONVERT(DATE,tc_date.endDate))											  
											  and (sr.[state] not in (99,199))
										   )
									  )
									))
		  )
	)
	
	,
	cte_prac_date_periods as
    (    
		select      
			CONVERT(date,tc_date.startDate) as [start_date],   
			CONVERT(DATE,tc_date.endDate) as [end_date],     
			'c' + CONVERT(VARCHAR,tc_date.id) as mo_id,
			prg.*
		from date_groupings tc_date  
		cross join cte_pracs_in_reporting_group  prg			 
	)
	,
	cte_service_record_details
	as
	(
	  select 
		   sr.id
		 , sr.clientID
		 , sr.pracID
		 , pracName = pdp.CONCAT_NAME
		 , rptGrp = pdp.GROUP_NAME
		 , sr.dos
		 , sr.svcType
		 , sr.svcSubType1
		 , sr.numMins
		 , pdp.mo_id
		 , svcTypeName  = st2.SERVICE_TYPE_NAME
		 , svcTypeName1 = st1.SERVICE_TYPE_NAME
		 , svcName      = dbo.BUILD_FULL_SERVICE_NAME_STRING (snlds.id, cip.NAME, cnp.NAME, ccy.NAME, cru.NAME, null, null, null, null, sr.svcType, gg.GROUP_BASE, sr.hasSvcDetFlags, sr.svcDetFlag1, sr.svcDetFlag2, sr.svcDetFlag3 , sr.svcDetFlag4 )	
	  from cte_prac_date_periods as pdp
	  /* Uses index: CLIENT_PRAC_PAT_DOS_CREATED_ID_W_EXTRA_COLS*/
	  join dbo.SERVICE_RECORDS          as sr on  ((sr.clientID = pdp.CLIENT_ID)
											  and (sr.pracID = pdp.PRACTITIONER_ID)
											  and (sr.patID is not null)
											  and (sr.dos between pdp.start_date and pdp.end_date)
											  )

	  join dbo.CLAIM_Svc_Names_List_Data_Sources as snlds on ((snlds.isIEPOrIFSP = sr.isIFSPorIEP) and (snlds.billingProgramID = sr.billingProgramID))

	  join      dbo.CLAIM_Procedures_Service_Types as st1 on st1.SERVICE_TYPE_ID = sr.svcType
	  left join dbo.CLAIM_Procedures_Service_Types as st2 on st2.SERVICE_TYPE_ID = sr.svcSubType1		  
	  left join dbo.GROUP_Group            as gg  on gg.GROUP_ID           = sr.groupID  
	  left join dbo.CLAIM_IEPandIFSPNames  as cip on cip.IEP_IFSP_NAME_ID  = sr.nameID
	  left join dbo.CLAIM_NoPlanNames      as cnp on cnp.NO_PLAN_NAME_ID   = sr.nameID
	  left join dbo.CLAIM_CYBHI_Names      as ccy on ccy.CYBHI_NAME_ID     = sr.nameID
      left join dbo.CLAIM_RU_HEALTH_NAMES  as cru on cru.RU_HEALTH_NAME_ID = sr.nameID

	  where 
		  --(sr.[svcType] in (1,2,3,4))
	  (sr.[state] not in (99,199))
	)	
	,
	cte_service_record_summary
	as
	(
	  select 
		 srd.clientID
	   , srd.pracID
	   , srd.rptGrp
	   , srd.svcType
	   , srd.svcSubType1
	   , srd.svcTypeName 
	   , srd.svcTypeName1
	   , srd.mo_id
	   , srd.pracName	 
	   , srd.svcName  
	   , numMins = Sum(numMins)
	  from cte_service_record_details as srd
	  group by
		 srd.clientID
	   , srd.pracID
	   , srd.rptGrp
	   , srd.svcType
	   , srd.svcSubType1
	   , srd.svcTypeName 
	   , srd.svcTypeName1
	   , srd.mo_id
	   , srd.pracName
	   , srd.svcName
	)
	,
	cte_output_rows_1
	as
	(
	  select 
		   srs.pracName 
		 , srs.rptGrp
		 , serviceEntered = srs.svcName
		 , numMins  = isnull(srs.numMins , 0)
		 , srs.mo_id
	  from      cte_service_record_summary         as srs
	)	
	,
	pivot_table_output as 
	(
		SELECT
			*
	  			
		from 
		(
			select     
				*
			FROM cte_output_rows_1
			
		) tpb
		PIVOT
		( 
			Sum(numMins) 
			for mo_id in 
			( 
				[c12],[c11],[c10],[c9],[c8],[c7],[c6],[c5],[c4],[c3],[c2],[c1]
			)
		) as PivotTattleOutput
	)
			
	select top (dbo.CONST_MAX_ROWS())		
		pto.pracName       as [Practitioner Name],
		pto.rptGrp		   as [Reporting Group],
		pto.serviceEntered as [Service Entered],
		
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
				
	from date_groupings_piv as dgp
	cross apply pivot_table_output as pto
	order by 
	  pto.pracName       asc
	, pto.serviceEntered asc	

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICE_MINS_BY_PRAC_RPT] TO [webuser]
GO
