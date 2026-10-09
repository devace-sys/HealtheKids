USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_OTHER_COSTS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_OTHER_COSTS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_OTHER_COSTS_VIEW_CORE] ( 
	   @clientID          BigInt    
	 , @fiscalYearID      BigInt
	 , @recID             Bigint
)
     
RETURNS TABLE  

AS RETURN(

	with groupIDs as (
		select
			  gg.GROUP_SERVICE_CLASS_NAME_ID
			, gg.GROUP_SERVICE_CLASS_NAME
		from dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as gg
		where ( 
		   exists (select top 1 GROUP_SERVICE_CLASS_NAME_ID from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS
				  where GROUP_SERVICE_CLASS_PARTITION_ID = 600
					and GROUP_SERVICE_CLASS_NAME_ID = gg.GROUP_SERVICE_CLASS_NAME_ID)
		)
	)
	,
	union_cte as (		
		select 
				  grpSvcClassNameID		  = cp.grpSvcClassNameID
				, grpSvcClassName         = cp.grpSvcClassName
		from dbo.CRCS_PRAC_SALARIES_VIEW_CORE(@clientID,@fiscalYearID,null,null) as cp
		where cp.pracCanHaveCostsEntered = 1				
		union
		(
			select 
				  grpSvcClassNameID		  = cc.grpSvcClassNameID
				, grpSvcClassName         = cc.grpSvcClassName  
			from dbo.CRCS_CONTRACTOR_COSTS_VIEW_CORE(@clientID, @fiscalYearID, null) as cc       
		)
		union
		(
			select 
				  grpSvcClassNameID		  = co.grpSvcClassNameID
				, grpSvcClassName         = ggsvc.GROUP_SERVICE_CLASS_NAME
			from dbo.CRCS_OTHER_COSTS as co
			join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as ggsvc on ggsvc.GROUP_SERVICE_CLASS_NAME_ID = co.grpSvcClassNameID
			where (
				co.clientID     = @clientID
			and co.fiscalYearID = @fiscalYearID 
			)
		)
	)

	select 
		  clientID = @clientID               
		, uc.grpSvcClassNameID		
		, uc.grpSvcClassName        
		, coc.materialsAndSupplies
		, coc.nonCapitalizedEquipment
		, coc.travelAndConference
		, coc.duesAndMembership
		, coc.communications
		, coc.otherFederalCosts
		, coc.federalResourceCodes
		, coc.deferred
		, fiscalYearID = @fiscalYearID	         
	from union_cte as uc
	left join dbo.CRCS_OTHER_COSTS as coc on coc.grpSvcClassNameID = uc.grpSvcClassNameID and coc.clientID = @clientID and coc.fiscalYearID = @fiscalYearID
     
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_OTHER_COSTS_VIEW_CORE] TO [webuser]
GO