USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_FIND_REDUNDANT_CSIS_VALUES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_FIND_REDUNDANT_CSIS_VALUES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_FIND_REDUNDANT_CSIS_VALUES] (
   @clientID  bigint
)    

RETURNS TABLE
 
 /***************************************************************************    
  * PATIENT_FIND_REDUNDANT_CSIS_VALUES */    
 /**    
  * Returns redundant CSIS values for patients associated with @clientID
  *    
  * @param  clientID      Client id
  * @return               Table 
  ***************************************************************************/                         

WITH SCHEMABINDING 
AS 
RETURN
(
select top (9999999999) 
    CSIS = trim(isnull(pap.CSIS,N''))
  , NUM_OF_INSTANCES = count(pap.PATIENT_ID)
from dbo.PATIENTS_Patient as pap 
join dbo.PATIENTS_Client  as pac on ((pac.CLIENT_ID = @clientID) and (pac.PATIENT_ID = pap.PATIENT_ID))

/* Uses [onCSIS] index on PATIENTS_Patient and [CLIENT_ID_PAT_ID_IDX] on PATIENTS_Clients */

where ( 
      (len(trim(isnull(pap.CSIS,N''))) != 0)
  and (pap.ACTIVE = N'y')
)
group by
   pap.CSIS
having
  count(pap.PATIENT_ID) > 1
order by 
  CSIS
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].PATIENT_FIND_REDUNDANT_CSIS_VALUES TO [webuser]
GO   
