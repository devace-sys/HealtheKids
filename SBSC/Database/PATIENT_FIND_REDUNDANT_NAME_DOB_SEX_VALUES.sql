USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_FIND_REDUNDANT_NAME_DOB_SEX_VALUES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_FIND_REDUNDANT_NAME_DOB_SEX_VALUES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_FIND_REDUNDANT_NAME_DOB_SEX_VALUES] (
   @clientID  bigint
)    

RETURNS TABLE
 
 /***************************************************************************    
  * PATIENT_FIND_REDUNDANT_NAME_DOB_SEX_VALUES */    
 /**    
  * Returns redundant name,dob,sex combinations for patients associated 
  * with @clientID
  *    
  * @param  clientID      Client id
  * @return               Table 
  ***************************************************************************/                         

WITH SCHEMABINDING 
AS 
RETURN
(
select 
    pap.LAST_NAME
  , pap.FIRST_NAME
  , pap.DATE_OF_BIRTH
  , pap.SEX
  , NUM_OF_INSTANCES = count(pap.PATIENT_ID)
from dbo.PATIENTS_Patient as pap 
join dbo.PATIENTS_Client  as pac on ((pac.CLIENT_ID = @clientID) and (pac.PATIENT_ID = pap.PATIENT_ID))

where 
  (pap.ACTIVE = N'y')

/* Uses [LAST_FIRST_DOB_SEX_ID] index on PATIENTS_Patient and [CLIENT_ID_PAT_ID_IDX] on PATIENTS_Clients */
group by
    pap.LAST_NAME
  , pap.FIRST_NAME
  , pap.DATE_OF_BIRTH
  , pap.SEX
having
  count(pap.PATIENT_ID) > 1

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].PATIENT_FIND_REDUNDANT_NAME_DOB_SEX_VALUES TO [webuser]
GO   
