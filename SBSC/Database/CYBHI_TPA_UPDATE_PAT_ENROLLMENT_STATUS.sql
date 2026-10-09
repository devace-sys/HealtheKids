USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_TPA_UPDATE_PAT_ENROLLMENT_STATUS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CYBHI_TPA_UPDATE_PAT_ENROLLMENT_STATUS
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CYBHI_TPA_UPDATE_PAT_ENROLLMENT_STATUS] (  
  @clientID bigint
)    
AS    
BEGIN     
    
/***************************************************************************    
 * CYBHI_TPA_UPDATE_PAT_ENROLLMENT_STATUS */    
/**    
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
/*============================================================
 * Variables
 *============================================================*/

declare @todayDateOnly    as date         = getdate()
declare @today            as datetime     = @todayDateOnly

/*============================================================
 * Find and Update CYBHI Patients that Need to Be Reregistered
 *============================================================*/

update pap
  set pap.cybhiTpaEnrollmentState = 7  /* Accepted but reinrollment needed */
from dbo.CLIENTS_Client   as clc 
join dbo.PATIENTS_Client  as pac on pac.CLIENT_ID  = clc.CLIENT_ID
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pac.PATIENT_ID
where (
      (1=1)
  and ((@clientID is null) or (clc.CLIENT_ID = @clientID))
  and (clc.cybhiTpaApproved = 1)
  and (pap.cybhiTpaApproved = 1)
  and (pap.cybhiTpaEnrollmentState = 3)
  and (pap.cybhiTpaEnrollmentEndDate < @todayDateOnly)
  and (@today < (dateadd(year,25,pap.DATE_OF_BIRTH)))
)

/* enrollmentState
  1. None
  2. Pended
  3. Accepted
  4. Rejected
  5. Accepted But Update Required
  6. Accepted But Removal Required
  7. Accepted But Reenrollment Required
*/

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CYBHI_TPA_UPDATE_PAT_ENROLLMENT_STATUS] TO [webuser]
GO
