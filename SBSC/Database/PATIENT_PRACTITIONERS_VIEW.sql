USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PRACTITIONERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PRACTITIONERS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[PATIENT_PRACTITIONERS_VIEW] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @patID				   BIGINT
 , @term				   VARCHAR(256)
 , @active                 BIT
 , @recID                  BIGINT 
)

RETURNS TABLE
AS
RETURN
(  
  
 with
 
/* Get all practitioners who have recorded a service for this patient */
 
cte_sr
as
(
  select 
    sr.pracID
  from  dbo.SERVICE_RECORDS as sr
 
  where ( 
    /* Using index [CLIENT_ID_PAT_ID_DOS] */
    ((sr.clientID = @clientID) and (sr.patID = @patID) and (sr.dos > dbo.CONST_MIN_DATETIME()) and (sr.groupID > 0) and (sr.planType > 0) and (sr.id > 0))
  )
)
,
 
/* Get all practitioners who have this patient on their caseload */
 
cte_caseload
as
(
  select 
    ppc.pracID 
  from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc 
  where (
      /* Using index [CLIENT_ID_PAT_ID_IDX] */
      ((ppc.clientID = @clientID) and (ppc.patID = @patID) and (ppc.id > 0))
  )
  group by 
    ppc.pracID
)
,
 
/* Combine lists of practitioners into one unified list */
 
cte_sr_cl
as
(
  select t1.pracID from cte_sr       as t1
  union
  select t2.pracID from cte_caseload as t2
)
 
/* Take the unified list and filter out any inactive practitioners who do not have a user account  */
 
select 
    id = prp.UserID, /* In the prac table the UserID column is the userID of the related user record for the prac */
	name = prp.CONCAT_NAME,
	email = prp.EMAIL,
	role = ua.roleName
from cte_sr_cl                     as srcl
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = srcl.pracID
join users.dbo.Users               as u   on u.userrid           = prp.UserID
join users.dbo.users_all		   as ua  on ua.id				 = u.userrid 
where 
  ((prp.ACTIVE = 1) and (prp.currentlyWithClient = 1))
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PRACTITIONERS_VIEW] TO [webuser]
GO