/*########################################################
 *#  Used for reviewing service records                  #
 *########################################################*/

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONERS_SUPERVISED_BY_PRAC_ID_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONERS_SUPERVISED_BY_PRAC_ID_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
	 
CREATE FUNCTION [dbo].[PRACTITIONERS_SUPERVISED_BY_PRAC_ID_VIEW] (
     @userID        BIGINT    
   , @userGroup     INT
   , @userRank      INT
   , @clientID      bigint
   , @pracID        bigint
)
RETURNS TABLE 
AS 
RETURN (
 
/***************************************************************************    
 * PRACTITIONERS_SUPERVISED_BY_PRAC_ID_VIEW */    
/**    
 * Returns list of active practitioners supervised by a pracID within clientID
 * who have user accounts
 *
 * @param clientID  Client ID
 * @param pracID    Supervising practitioners prac id
 * 
 ***************************************************************************/      

with 
cte_pass_1
as
(

/* Start with the groups*/

select 
  psg2.* 
from dbo.PRACTITIONER_GROUPS_ASSOCIATED_WITH_PRAC_ID_VIEW (@clientID, @pracID) as sug 

cross apply (
  select 
    psg1.* 
  from dbo.PRACTITIONERS_SUPERVISED_BY_GROUP_ID_VIEW (@clientID, sug.GROUP_ID) as psg1
) as psg2

where (
      (sug.GROUP_TYPE in (1,2)) 
  and (psg2.PRAC_ASP_ID is not null)
)
)
,
cte_pass_2
as
(

/* Identify assigned if any */

select 
    p1.*
  , startDate = isnull(ppdss.START_DATE, dbo.CONST_MIN_DATETIME_1900_01_01())
  , endDate   = isnull(ppdss.END_DATE,   dbo.CONST_MAX_DATETIME())
  , Assigned  = isnull(ppdss.ACTIVE,0)
from cte_pass_1 as p1
left join dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as ppdss on ppdss.SUPERVISING_PRAC_ID = @pracID  and ppdss.SUPERVISED_PRAC_ID = p1.PRACTITIONER_ID and ppdss.ACTIVE = 1 and ppdss.relationshipTypeID = 10

)
,
cte_pass_3
as
(

/* Gatekeep for approval system (TODO: Refactor to move this to top and use cross apply technique */

select 
  p2.* 
from cte_pass_2                           as p2
join dbo.PRACTITIONER_Client              as pc   on pc.PRACTITIONER_ID = p2.PRACTITIONER_ID
join dbo.SERVICE_RECORDS_APPROVAL_OPTIONS as srao on srao.clientID = pc.CLIENT_ID
where 
  (srao.approvalSystem = 1)
)
select 
  p3.* 
from cte_pass_3 as p3
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONERS_SUPERVISED_BY_PRAC_ID_VIEW] TO [webuser]
GO
