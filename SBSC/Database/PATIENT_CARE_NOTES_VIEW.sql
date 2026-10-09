USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_CARE_NOTES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_CARE_NOTES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_CARE_NOTES_VIEW] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT 
  , @clientID            BIGINT
  , @groupSvcClassNameID BIGINT
  , @patID               BIGINT 
  , @active              BIT 
) 

RETURNS TABLE

/***************************************************************************    
  * PATIENT_CARE_NOTES_VIEW */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
with
 cte_p1
 as
 (
	select top 1
	id
	, clientID = @clientID
	, groupSvcClassNameID = @groupSvcClassNameID
	, patID = @patID
	, note	= n.note
  from dbo.PATIENT_CARE_NOTES   as n
  join dbo.PATIENTS_Client  as pac on pac.CLIENT_ID = n.clientID
  join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pac.PATIENT_ID
  where (
        (n.clientID  = @clientID) 
    and (n.patID = @patID)
	and (n.groupSvcClassNameID = @groupSvcClassNameID)
	and (n.active = @active)
	)
)
select 
  p1.* 
from cte_p1 as p1
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_CARE_NOTES_VIEW] TO [webuser]
GO  
