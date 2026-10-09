USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_WRITER_PLANS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PLAN_WRITER_PLANS_VIEW_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PLAN_WRITER_PLANS_VIEW_CORE] (
 @userID              BIGINT,    
 @userGroup           INT,    
 @userRank            INT,
 @clientID            BIGINT, 
 @patientID           BIGINT,
 @groupSvcClassNameID bigint,
 @active              BIT,
 @recID               INT)    
 
RETURNS TABLE
 
 /***************************************************************************    
  * PLAN_WRITER_PLANS_VIEW_CORE */    
 /**    
  * Returns a table of entities
  *    
  * @param   userID         The userid of who is requesting the operation
  * @param   userGroup      Users group    
  * @param   userRank       User rank      
  * @param   active         Active 0 = No 1 = Yes
  * @param   recID          Entity record id
  * @return                 Table of patient data    
  ***************************************************************************/     
 
AS RETURN
(
 
with 
cte_p1
as
(
select 

   pwp.*
 , PLAN_DATE_STR   = dbo.RPT_DATE_FMT(pwp.PLAN_DATE)
 , PATIENT_NAME    = ltrim(rtrim(isnull(pap.LAST_NAME,''))) 
                   + ', ' 
                   + ltrim(rtrim(isnull(pap.FIRST_NAME,'')))
 , PATIENT_DOB_VAL = pap.DATE_OF_BIRTH
 , PATIENT_DOB_STR = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
 , clc.CLIENT_NAME


from dbo.PLAN_WRITER_PLANS      as pwp
join dbo.PATIENTS_Patient       as pap  on pap.PATIENT_ID = pwp.PATIENT_ID
join dbo.CLIENTS_Client         as clc  on clc.CLIENT_ID  = pwp.CLIENT_ID

where (
       (1=1)      
   and (pwp.CLIENT_ID                        = @clientID)
   and ((@patientID  is null)  or (pwp.PATIENT_ID = @patientID))
   and ((@active     is null)  or (pwp.ACTIVE     = @active))
   and ((@recID      is null)  or (pwp.ID         = @recID))
)
)
,
cte_p2
as
(
select 
  t2.*
, PLAN_NAME = t2.PATIENT_NAME 
            + ' (' 
            + t2.PATIENT_DOB_STR 
            + ') ' 
            + ' ( ' 
            + t2.PLAN_DATE_STR 
            + ')' 
, PATIENT_GRADE        = t3.GRADE
, PATIENT_STUDENT_ID   = t3.STUDENT_ID
, PATIENT_SITE_NAME    = t3.SITE_NAME
from cte_p1  as t2
join dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID) as t3 on t3.PATIENT_ID = t2.PATIENT_ID


)

select * from cte_p2

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PLAN_WRITER_PLANS_VIEW_CORE] TO [webuser]
GO