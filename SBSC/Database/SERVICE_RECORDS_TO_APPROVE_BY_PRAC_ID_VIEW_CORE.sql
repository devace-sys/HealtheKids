USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_VIEW_CORE] (
    @userID          BIGINT
  , @userGroup       INT  
  , @userRank        INT
  , @clientID        bigint
  , @siteID          bigint
  , @approvingPracID bigint
  , @pracID          bigint
  , @patID           bigint
  , @startEntryDate  datetime
  , @endEntryDate    datetime
  , @reviewed        bit
  , @approved        bit
  , @assigned        bit )
      
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_VIEW_CORE */    
/**    
 *     
 * @param  userID          User ID (Required)    
 * @param  userGroup       User group (Required)    
 * @param  userRank        User rank (Required)    
 * @param  clientID
 * @param  pracID
 * @param  approvingPracID
 * @param  pracID
 * @return                 Service records and svc notes
 ***************************************************************************/     
    
return (    

with
cte_p1
as
(

/* Gets practioners who can be supervised by the supervising prac and
 * flags those who are or were currently under direct supervision 
 * by this prac */

select 

    sra.* 
  , psbu.assigned  
  , held = dbo.RPT_BIT_TO_YN(reviewed)
  , dosStr = FORMAT (sra.dos, 'MM/dd/yyyy')
  , svcJournalID = sra.journalID

from dbo.PRACTITIONERS_SUPERVISED_BY_PRAC_ID_VIEW (  @userID
                                                   , @userGroup
                                                   , @userRank
                                                   , @clientID
                                                   , @approvingPracID) as psbu

/* Get service records for approval/review/rereview, etc. 
 * Limit to supervision date ranges if appropriate.
 */

cross apply ( 
  select 
    avc.* 
  from dbo.SERVICE_RECORDS_APPROVAL_VIEW_CORE (   @userID
												, @clientID                                                
												, psbu.[GROUP_ID]        /* Supervised prac group */
                                                , @approvingPracID       /* Supervising prac */
												, psbu.startDate         /* Supervised start dos */
												, psbu.endDate           /* Supervised end dos */
												, psbu.[PRACTITIONER_ID] /* Supervised prac */
                                                , @patID                 /* Patient */
												, @startEntryDate
												, @endEntryDate
												, @reviewed              /* null, 0 */
												, null                   /* Approved */
                                                , 1) as avc
  where
  (	
	     (1=1) 

	/* Note: Slighly different logic that the built in approved filter (hence why we pass a null). 
     * We have to use a combo of approved and reviewed by */

	and ((@approved is null) or ((avc.approved = @approved) and (avc.reviewedByNameRefID = @approvingPracID)))
  ) 
) as sra

where ( 
      (1=1)
  and ((@pracID   is null) or (psbu.PRACTITIONER_ID = @pracID)) /* Optimization */
  and ((@assigned is null) or (psbu.Assigned = @assigned))
)
)
select 
   p1.* 
 , siteName = ps.SITE_NAME
 , siteID   = ps.SITE_ID
from cte_p1 as p1
join dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID)  as ps on ps.PATIENT_ID = p1.patID
where ( 
      (1=1)
  /* Site filter */
  and ((@siteID is null) or (ps.SITE_ID = @siteID))
)
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_VIEW_CORE] TO [webuser]
GO