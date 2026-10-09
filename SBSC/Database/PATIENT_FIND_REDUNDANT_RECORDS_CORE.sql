USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_FIND_REDUNDANT_RECORDS_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_FIND_REDUNDANT_RECORDS_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENT_FIND_REDUNDANT_RECORDS_CORE] (
  @clientID  BIGINT
)    

RETURNS @recs TABLE (
    RECORD_SET     int
  , FOUND_IN_PASS  smallint
  , CSIS           nvarchar(50) 
  , BIC            nvarchar(14) 
  , STUDENT_ID     nvarchar(50) default(N'')
  , LAST_NAME      nvarchar(50) 
  , FIRST_NAME     nvarchar(50) 
  , DATE_OF_BIRTH  datetime     
  , SEX            nvarchar(1)  
  , ACTIVE         nchar(1)
  , PATIENT_ID     bigint 
)     
     
AS    
BEGIN    

declare @redundantRecs as table (
    PATIENT_ID     bigint
  , FOUND_IN_PASS  smallint
unique clustered(PATIENT_ID)
)

/* Pass 1 */

insert into @redundantRecs (
    PATIENT_ID
  , FOUND_IN_PASS
)
select 
    pap.PATIENT_ID 
  , FOUND_IN_PASS = 1
from dbo.[PATIENT_FIND_REDUNDANT_CSIS_VALUES] (@clientID) as t1
join dbo.PATIENTS_Patient                                 as pap on pap.CSIS = t1.CSIS
join dbo.PATIENTS_Client                                  as pac on ((pac.CLIENT_ID = @clientID) and (pac.PATIENT_ID = pap.PATIENT_ID))

/* Pass 2 */

insert into @redundantRecs (
    PATIENT_ID
  , FOUND_IN_PASS
)
select 
    pap.PATIENT_ID 
  , FOUND_IN_PASS = 2
from dbo.[PATIENT_FIND_REDUNDANT_BIC_VALUES](@clientID)  as t2
join dbo.PATIENTS_Patient                                as pap on pap.BIC = t2.BIC
join dbo.PATIENTS_Client                                 as pac on ((pac.CLIENT_ID = @clientID) and (pac.PATIENT_ID = pap.PATIENT_ID))
where 
  (pap.PATIENT_ID not in (select top 1 r.PATIENT_ID from @redundantRecs as r where (r.PATIENT_ID = pap.PATIENT_ID)))
   
/* Pass 3 */

insert into @redundantRecs (
    PATIENT_ID
  , FOUND_IN_PASS

)
select distinct
    ps.PATIENT_ID /* Distict is needed to deal with multiple grades, etc */
  , FOUND_IN_PASS = 3

from dbo.[PATIENT_FIND_REDUNDANT_STUDENT_ID_VALUES] (@clientID) as t3
join dbo.PATIENTS_School                                        as ps  on ps.STUDENT_ID = t3.STUDENT_ID
join dbo.PATIENTS_Client                                        as pac on ((pac.CLIENT_ID = @clientID) and (pac.PATIENT_ID = ps.PATIENT_ID))
where 
  (ps.PATIENT_ID not in (select top 1 r.PATIENT_ID from @redundantRecs as r where (r.PATIENT_ID = ps.PATIENT_ID)))
   
/* Pass 4 */

insert into @redundantRecs (
    PATIENT_ID
  , FOUND_IN_PASS
)
select 
    pap.PATIENT_ID 
  , FOUND_IN_PASS = 4
from dbo.[PATIENT_FIND_REDUNDANT_NAME_DOB_SEX_VALUES] (@clientID) as t4

join dbo.PATIENTS_Patient  as pap on  (    (pap.LAST_NAME     = t4.LAST_NAME)
                                       and (pap.FIRST_NAME    = t4.FIRST_NAME)
                                       and (pap.DATE_OF_BIRTH = t4.DATE_OF_BIRTH)
                                       and (pap.SEX           = t4.SEX))

join dbo.PATIENTS_Client   as pac on ((pac.CLIENT_ID = @clientID) and (pac.PATIENT_ID = pap.PATIENT_ID))
where 
  (pap.PATIENT_ID not in (select top 1 r.PATIENT_ID from @redundantRecs as r where (r.PATIENT_ID = pap.PATIENT_ID)))

 ;with
 cte_p1
 as
 (
 select
    r.PATIENT_ID
  , r.FOUND_IN_PASS
  , RECORD_SET_INSIDE_PASS = case 
      when r.FOUND_IN_PASS = 1 then (DENSE_RANK() OVER(ORDER BY pap.CSIS)) 
	  when r.FOUND_IN_PASS = 2 then (DENSE_RANK() OVER(ORDER BY pap.BIC))
	  when r.FOUND_IN_PASS = 3 then (DENSE_RANK() OVER(ORDER BY ps2.STUDENT_ID))
	  when r.FOUND_IN_PASS = 4 then (DENSE_RANK() OVER(ORDER BY pap.LAST_NAME, pap.FIRST_NAME, pap.DATE_OF_BIRTH, pap.SEX))
    end
  , CSIS          = trim(isnull(pap.CSIS,N''))
  , BIC           = trim(isnull(pap.BIC,N''))
  , STUDENT_ID    = trim(isnull(ps2.STUDENT_ID,N''))
  , pap.LAST_NAME
  , pap.FIRST_NAME
  , pap.DATE_OF_BIRTH
  , pap.SEX
  , pap.ACTIVE
from @redundantRecs       as r
join dbo.PATIENTS_PATIENT as pap on pap.PATIENT_ID = r.PATIENT_ID
outer apply (
  select top 1 
    ps1.STUDENT_ID 
  from dbo.PATIENTS_School as ps1  
  where ( 
        (ps1.PATIENT_ID  = r.PATIENT_ID)
    and (len(trim(isnull(ps1.STUDENT_ID,N''))) > 0)
  ) 
  order by 
    ps1.PATIENT_SCHOOL_ID desc
) as ps2
)
insert into @recs (
    RECORD_SET
  , FOUND_IN_PASS
  , CSIS
  , BIC 
  , STUDENT_ID
  , LAST_NAME 
  , FIRST_NAME 
  , DATE_OF_BIRTH 
  , SEX  
  , ACTIVE
  , PATIENT_ID
)
select  
    RECORD_SET = (DENSE_RANK() OVER ( ORDER BY p1.FOUND_IN_PASS, p1.RECORD_SET_INSIDE_PASS ) )
  , p1.FOUND_IN_PASS
  , p1.CSIS
  , p1.BIC 
  , p1.STUDENT_ID
  , p1.LAST_NAME 
  , p1.FIRST_NAME 
  , p1.DATE_OF_BIRTH 
  , p1.SEX  
  , p1.ACTIVE
  , p1.PATIENT_ID
from cte_p1 as p1

RETURN    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].PATIENT_FIND_REDUNDANT_RECORDS_CORE TO [webuser]
GO   

