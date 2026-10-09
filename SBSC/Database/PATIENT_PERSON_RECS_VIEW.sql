USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PERSON_RECS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PERSON_RECS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_PERSON_RECS_VIEW] ( @userIDIntAssociation BIGINT)    
RETURNS TABLE 
AS RETURN (     
  select 
     ppvc.* 
   , serviceAuthorizationRequestsPendingCount = isnull(sarRspReq.serviceAuthorizationRequestsPendingCount,0)
  from dbo.PATIENT_PERSONS_VIEW_CORE (null, null, null, null, null, null, null, 1, null, @userIDIntAssociation) as ppvc
  
  /* Get pending service authorization count for given patient */

  outer apply (
     select 
	   serviceAuthorizationRequestsPendingCount = count (sar.id)
     from dbo.SERVICE_AUTHORIZATION_REQUEST_AUTHORIZED_USERS        as sarau 
	 join dbo.SERVICE_AUTHORIZATION_REQUESTS                        as sar on sar.id = sarau.requestID

	 where (
	       (sarau.userID           = ppvc.userIDInt)
	   and (sarau.responseRequired = 1)
	   and (sar.currentResponseCode = 2000) /* Pending */
	   and (sar.closed = 0)
	   and (sar.active = 1)
	 )
   ) as sarRspReq

   /* Get goal count for given patient */


)   
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[PATIENT_PERSON_RECS_VIEW] TO [webuser]
GO
