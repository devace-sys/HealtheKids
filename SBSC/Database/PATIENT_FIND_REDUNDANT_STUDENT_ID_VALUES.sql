USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_FIND_REDUNDANT_STUDENT_ID_VALUES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_FIND_REDUNDANT_STUDENT_ID_VALUES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_FIND_REDUNDANT_STUDENT_ID_VALUES] (
   @clientID  bigint
)    

RETURNS TABLE
 
 /***************************************************************************    
  * PATIENT_FIND_REDUNDANT_STUDENT_ID_VALUES */    
 /**    
  * Returns redundant student id values for patients associated with @clientID
  *    
  * @param  clientID      Client id
  * @return               Table 
  ***************************************************************************/                         

WITH SCHEMABINDING 
AS 
RETURN
(

with
cte_p1
as
(
  select
     ps.PATIENT_ID
   , ps.STUDENT_ID 
  from dbo.PATIENTS_School  as ps 
  join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = ps.PATIENT_ID 
  join dbo.PATIENTS_Client  as pac on ((pac.CLIENT_ID = @clientID) and (pac.PATIENT_ID = pap.PATIENT_ID))

 /* Uses [STUDENT_ID_PAT_ID_IDX] index on PATIENTS_School and [CLIENT_ID_PAT_ID_IDX] on PATIENTS_Clients */

  where (
         (len(trim(isnull(ps.STUDENT_ID,N'')))  > 0) 
	 and (pap.ACTIVE = N'y')
  )
   /* Initial grouping is needed for dealing with cases where patients have different grade entries, etc */
  group by
     ps.PATIENT_ID
	,ps.STUDENT_ID
)
select 
    STUDENT_ID = trim(isnull(p1.STUDENT_ID,N''))
  , NUM_OF_INSTANCES = count(p1.PATIENT_ID)
from cte_p1 as p1
group by 
  p1.STUDENT_ID
having 
  count(p1.PATIENT_ID) > 1

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].PATIENT_FIND_REDUNDANT_STUDENT_ID_VALUES TO [webuser]
GO   
