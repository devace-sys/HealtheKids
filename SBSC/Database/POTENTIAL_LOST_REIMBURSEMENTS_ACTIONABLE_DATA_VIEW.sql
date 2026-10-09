USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.POTENTIAL_LOST_REIMBURSEMENTS_ACTIONABLE_DATA_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.POTENTIAL_LOST_REIMBURSEMENTS_ACTIONABLE_DATA_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[POTENTIAL_LOST_REIMBURSEMENTS_ACTIONABLE_DATA_VIEW] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT 
  , @clientID            BIGINT
  , @pracID              BIGINT 
  , @repID               BIGINT 
  , @groupSvcClassNameID BIGINT
  , @patID               BIGINT
  , @plrClassCode        INT
  , @deferred            BIT
)    
returns table
as
return
(


 /***************************************************************************    
  * POTENTIAL_LOST_REIMBURSEMENTS_ACTIONABLE_DATA_VIEW */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     

with
cte_client_info
as
(
	select 
		clc.CLIENT_ID 
	from dbo.CLIENTS_Client_Active_LEA as clc
	where (
		(1=1) 
	and ((@clientID is null) or (clc.CLIENT_ID = @clientID))
	and ((@repID is null)    or (clc.REP_ID = @repID))
	)
)
,
cte_plr_data
as
(
	select 
		  patID                     = chcr.PAT_ID
		, pracGroupID               = chcr.PRAC_GROUP_ID
		, pracGroupName             = chcr.PRAC_GROUP_NAME
		, pracGrpSvcClassNameID     = chcr.PRAC_GROUP_FAMILY_ID
		, potentialReimbursementAmt = isnull(chcr.TOT_EST_AMT, 0)
		, clientID                  = chcr.CLIENT_ID
		, pracID                    = chcr.PRAC_ID
		, pracName                  = chcr.PRAC_NAME
		, earliestDOS               = chcr.SVC_DOS_START
		, latestDOS                 = chcr.SVC_DOS_END
		, refID                     = chcr.REFERENCED_ENTITY_ID
		, holdCode                  = chcr.HOLD_CODE
		, holdReason     			= chcr.HOLD_REASON
		, instructions              = chcr.INSTRUCTIONS + iif(chcr.Additional_information is null, '', '<br/>' + chcr.ADDITIONAL_INFORMATION)
		, deferred                  = chcr.DEFER
		, notes                     = chcr.NOTES
		, plrIDString               = chcr.PLR_ID_STRING
	from cte_client_info as p1 
	cross apply dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DATA_AND_RESPONSES_VIEW_CORE(
				@userID
			  , @userGroup
			  , @userRank
			  , p1.CLIENT_id			 
			  ,	@pracID			 
			  ,	@groupSvcClassNameID
			  ,	@patID              
			  ,	@plrClassCode  
			  , @deferred     
	 ) as chcr	
)

select 
	  patID                          = plr.patID                 
	, patName                        = pp.CONCAT_NAME                 
	, dob                            = pp.DATE_OF_BIRTH                 
	, dobStr                         = FORMAT (pp.DATE_OF_BIRTH, 'MM/dd/yyyy')                
	, pracGroupID                    = plr.pracGroupID   
	, pracGroupName               	 = plr.pracGroupName
	, pracGrpSvcClassNameID          = plr.pracGrpSvcClassNameID             
	, earliestDOS                 	 = plr.earliestDOS
	, earliestDOSStr              	 = FORMAT (plr.earliestDOS, 'MM/dd/yyyy')   
	, latestDOS                   	 = plr.latestDOS
	, latestDOSStr                	 = FORMAT (plr.latestDOS, 'MM/dd/yyyy')   
	, notes                       	 = plr.notes
	, potentialReimbursementAmt   	 = plr.potentialReimbursementAmt
	, potentialReimbursementAmtStr 	 = format(round(isnull(plr.potentialReimbursementAmt, 0), 0), 'N0')
	, instructions                   = plr.instructions
	, siteID                         = ps.SITE_ID
	, siteName                       = ps.SITE_NAME
	, clientID                       = plr.clientID
	, pracID                         = plr.pracID
	, pracName                       = plr.pracName
	, holdCode                       = plr.holdCode
	, holdReason                     = plr.holdReason
	, refID                          = plr.refID
	, deferred                       = plr.deferred
	, plrIDString					 = plr.plrIDString
from cte_plr_data as plr
join dbo.PATIENTS_Patient as pp on pp.PATIENT_ID = plr.patID
left join dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID)  as ps on ps.PATIENT_ID = plr.patID
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[POTENTIAL_LOST_REIMBURSEMENTS_ACTIONABLE_DATA_VIEW] TO [webuser]
GO  
