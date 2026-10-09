USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_SITES_VIEW_CURRENT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_SITES_VIEW_CURRENT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENTS_SITES_VIEW_CURRENT] (@clientID INT)    

RETURNS TABLE

 /***************************************************************************    
  * PATIENTS_SITES_VIEW_CURRENT */    
 /**    
  * Returns a table of current patient site assignments
  *    
  * @return                 Table of patient site data
  ***************************************************************************/     
  
AS RETURN(
  
with
cte_p1
as
(
select    
    ps.PATIENT_SCHOOL_ID
  , ps.SITE_ID
  , ps.PATIENT_ID
  , ps.GRADE
  , ps.STUDENT_ID
  , ps.START_DATE
  , ps.END_DATE
  , ss.SITE_NAME
  , ss.SITE_CDS
  , ss.SITE_CLIENT_ID
  , Ranking = RANK() over (PARTITION BY ps.PATIENT_ID ORDER BY ps.PATIENT_ID asc, isnull(ps.[END_DATE], dbo.CONST_MAX_DATETIME()) desc, ps.PATIENT_SCHOOL_ID desc)
from dbo.CLIENTS_Client  as clc
join dbo.SITES_Site      as ss on ((ss.SITE_CLIENT_ID = clc.CLIENT_ID) and (ss.SITE_ID is not null))
join dbo.PATIENTS_School as ps on ((ps.SITE_ID = ss.SITE_ID) and (ps.PATIENT_ID is not null) and (ps.PATIENT_SCHOOL_ID is not null)) /* For index */
where ( 
      (1=1) 
  and ((@clientID is null) or (clc.CLIENT_ID = @clientID))
)
)

select
   p1.PATIENT_SCHOOL_ID
  ,p1.SITE_ID
  ,p1.PATIENT_ID
  ,p1.GRADE
  ,p1.STUDENT_ID
  ,p1.START_DATE
  ,p1.END_DATE
  ,p1.SITE_NAME
  ,p1.SITE_CDS
  ,STE_CLIENTID = p1.SITE_CLIENT_ID 
from cte_p1 as p1
where 
  (p1.Ranking = 1)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENTS_SITES_VIEW_CURRENT] TO [webuser]
GO
