USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION  [dbo].[RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS]
(
   @userID    bigint
 , @userGroup bigint
 , @userRank  bigint
 , @clientID  bigint
 , @repID     bigint
)

RETURNS TABLE
 
 /***************************************************************************
 * RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS */
/**
 * Returns a table of report rows
 *
 * @param   client ID             filter by Client ID to get one client or all Clients.
 * @param   repID                 filter by Practical Consultant ID to get one or all Consultants,
 * @return                        Table of report rows
 ***************************************************************************/
 
AS RETURN 
(
SELECT top (dbo.CONST_MAX_ROWS())
	ma.Client
   ,ma.Rep
   ,ma.Patient
   ,ma.CurrentSite
   ,ma.DOB
   ,ma.Active
   ,ma.PractitionerGrouping
   ,ma.NumberOfTreatments as "Number Of Treatments"
   ,ma.AssessementRate as "Potential Reimbursement"
   ,ma.[LastAssmtDetails]
   ,PlanTypes = ppc.PLAN_TYPES				   					   				
   ,PracNames = ppc.PRACTITIONER_NAMES

FROM [dbo].[RPT_MISSING_ASSESSMENTS_CORE] (@clientID,@repID,1,1) ma
outer apply (select
				PLAN_TYPES    = STRING_AGG(
									Case When (caseload_data.planType = 1)     then 'IEP/IFSP'
  											When (caseload_data.planType is null) then ''
  											Else 'Not IEP/IFSP'
  									END
									, ' ; ')
			  , PRACTITIONER_NAMES = STRING_AGG(isnull(caseload_data.PRAC_NAME, ''), ' ; ')
			 from (
				 select distinct 
				   ppc.planType
				 , pp.CONCAT_NAME as PRAC_NAME
				 from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc
				 
				 -- get user info
				 outer apply (select
								  gg.GROUP_SERVICE_CLASS_NAME_ID
								, ua.roleID
								, isPrac = iif((ua.pracID is not null), 1, 0)
							  from users.dbo.users_all as ua
				 			  left join dbo.PRACTITIONER_GROUPS       as pg on pg.PRACTITIONER_ID = ua.pracID
							  left join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as gg on gg.GROUP_ID = pg.GROUP_ID
							  where ua.id = @userID
				 ) as upp
				 ---------------------------------------------------------------------------
				 
				 left join dbo.PRACTITIONER_Practitioner as pp on pp.PRACTITIONER_ID = ppc.pracID
				 left join dbo.PRACTITIONER_GROUPS       as pg on pg.PRACTITIONER_ID = pp.PRACTITIONER_ID
				 left join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as gg on gg.GROUP_ID = pg.GROUP_ID
				 where  ppc.patID = ma.PatID
					and ((upp.isPrac = 0) or (gg.GROUP_SERVICE_CLASS_NAME_ID = upp.GROUP_SERVICE_CLASS_NAME_ID)) -- filter by group for pracs
			 ) as caseload_data
) as ppc
order by ma.Client,ma.Rep,ma.Patient
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS] TO [webuser]
GO   
