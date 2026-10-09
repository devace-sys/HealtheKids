USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_DIRECT_SUPERVISED_FOR_DEPARTMENT_HEAD_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION PRACTITIONER_DIRECT_SUPERVISED_FOR_DEPARTMENT_HEAD_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PRACTITIONER_DIRECT_SUPERVISED_FOR_DEPARTMENT_HEAD_VIEW_CORE] (
    @clientID            BIGINT
  , @deptHeadPracID      BIGINT
  , @supervisedPracID    BIGINT  
)    
RETURNS 
TABLE
AS
RETURN
(

/*============================================================
 * Get department head practitioner data and practice family
 * specific rules.  If prac is not a dept head then no recs
 *============================================================*/  

with
cte_p1
as
(
  select top 1
	
	  DEPT_HEAD_DISP_GROUP_ID               = ggd.GROUP_ID
	, DEPT_HEAD_DISP_GROUP_NAME             = ggd.GROUP_NAME
	, DEPT_HEAD_REPT_GROUP_ID               = ggr.GROUP_ID
	, DEPT_HEAD_REPT_GROUP_NAME             = ggr.GROUP_NAME
    , DEPT_HEAD_GROUP_SERVICE_CLASS_NAME_ID = png.GROUP_SERVICE_CLASS_NAME_ID
	, DEPT_HEAD_PRAC_ID                     = prp.PRACTITIONER_ID
	, DEPT_HEAD_PRAC_NAME                   = prp.CONCAT_NAME
	
	, psr.departmentHeadsCanViewSupervisedPracsSvcRecs
	, psr.departmentHeadsCanViewSupervisedPracsPrivateNotes
	, psr.departmentHeadsCanViewSupervisedPracsStoredFiles
	, psr.departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup
	, psr.departmentHeadsCanViewAllPracDataInTheirReportingGroup

  from dbo.PRACTITIONER_Client                               as prc 
  join dbo.PRACTITIONER_Practitioner                         as prp  on prp.PRACTITIONER_ID  = prc.PRACTITIONER_ID

  join dbo.PRACTITIONER_GROUPS                               as pgd  on  ((pgd.PRACTITIONER_ID   = prp.PRACTITIONER_ID)
                                                                     and (pgd.GROUP_TYPE in (1,2))
																	 and (pgd.ACTIVE = 1))
  join dbo.GROUP_Group                                       as ggd  on ((ggd.GROUP_ID = pgd.GROUP_ID)
                                                                     and (ggd.GROUP_TYPE in (1,2))
																	 and (ggd.ACTIVE = 1))

  join dbo.PRACTITIONER_GROUPS                               as pgr  on  ((pgr.PRACTITIONER_ID   = prp.PRACTITIONER_ID)
                                                                     and (pgr.GROUP_TYPE in (3,5))
																	 and (pgr.ACTIVE = 1))  

  join dbo.GROUP_Group                                       as ggr  on ((ggr.GROUP_ID = pgr.GROUP_ID)
                                                                     and (ggr.GROUP_TYPE in (3,5))
																	 and (ggr.ACTIVE = 1))

  join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS       as png on ((png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
                                                                          and (png.GROUP_ID = ggd.GROUP_ID))
  
  join dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES as psr on  ((psr.clientID = prc.CLIENT_ID)
                                                                          and (psr.groupServiceClassNameID = png.GROUP_SERVICE_CLASS_NAME_ID))
  where (
        (prc.CLIENT_ID       = @clientID)
    and (prc.PRACTITIONER_ID = @deptHeadPracID )
    and (prp.deptHead        = 1)
	and ( 
	     (psr.departmentHeadsCanViewSupervisedPracsPrivateNotes      = 1)
	  or (psr.departmentHeadsCanViewSupervisedPracsSvcRecs           = 1)
	  or (psr.departmentHeadsCanViewSupervisedPracsPrivateNotes      = 1)
	  or (psr.departmentHeadsCanViewAllPracDataInTheirReportingGroup = 1)	
	)
  )  
)
,

/*============================================================
 * Get supervised groups in department head group family
 * that the department head is qualified to supervise
 *============================================================*/  

cte_p2
as
(
  select distinct 
    p1.*
  , SUPERVISED_DISP_GROUP_ID               = ggd.GROUP_ID
  , SUPERVISED_DISP_GROUP_NAME             = ggd.GROUP_NAME
  , SUPERVISED_GROUP_SERVICE_CLASS_NAME_ID = png.GROUP_SERVICE_CLASS_NAME_ID

  from cte_p1 as p1
  join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png   on ((png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
                                                                      and (png.GROUP_ID  is not null)
																	  and (png.GROUP_SERVICE_CLASS_NAME_ID = p1.DEPT_HEAD_GROUP_SERVICE_CLASS_NAME_ID))
  join dbo.GROUP_Group                                       as ggd   on (ggd.GROUP_ID = png.GROUP_ID)
  
  where 
    (p1.departmentHeadsCanViewAllPracDataInTheirReportingGroup = 1) /* All pracs */
  
  union 

  select distinct      

    p1.*
  , SUPERVISED_DISP_GROUP_ID               = ggd.GROUP_ID
  , SUPERVISED_DISP_GROUP_NAME             = ggd.GROUP_NAME
  , SUPERVISED_GROUP_SERVICE_CLASS_NAME_ID = png.GROUP_SERVICE_CLASS_NAME_ID

  from cte_p1                                                as p1
  join dbo.GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR          as ggdss on ((ggdss.GROUP_SERVICE_CLASS_NAME_ID = p1.DEPT_HEAD_GROUP_SERVICE_CLASS_NAME_ID) and (ggdss.SUPERVISING_GROUP_ID = p1.DEPT_HEAD_DISP_GROUP_ID))
  join dbo.GROUP_Group                                       as ggd   on (ggd.GROUP_ID = ggdss.SUPERVISED_GROUP_ID)
  join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png   on ((png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
                                                                      and (png.GROUP_ID = ggd.GROUP_ID))
  where ( 
        (ggdss.SUPERVISING_GROUP_ID is not null) 
	and (
	     (p1.departmentHeadsCanViewSupervisedPracsPrivateNotes      = 1)
	  or (p1.departmentHeadsCanViewSupervisedPracsSvcRecs           = 1)
	  or (p1.departmentHeadsCanViewSupervisedPracsPrivateNotes      = 1))
   and (p1.departmentHeadsCanViewAllPracDataInTheirReportingGroup = 0)  /* Limited to just supervised pracs */
  )
  
)
,

/*============================================================
 * Get pracs (or a prac) data in those groups.  Disp group
 * is already determined so we just need prac id, name, and
 * reporting group
 *============================================================*/  

cte_p3
as
(

select 
     p2.* 
   , SUPERVISED_PRAC_ID                               = prp.PRACTITIONER_ID
   , SUPERVISED_PRAC_NAME                             = prp.CONCAT_NAME
   , SUPERVISED_REPT_GROUP_ID                         = ggr.GROUP_ID
   , SUPERVISED_REPT_GROUP_NAME                       = ggr.GROUP_NAME
   , DEPT_HEAD_AND_SUPERVISED_PRAC_IN_SAME_REPT_GROUP = convert(bit,(iif ((p2.DEPT_HEAD_REPT_GROUP_ID = ggr.GROUP_ID),1,0)))
   , LIMITED_TO_REPT_GROUP                            = convert(bit,(iif (((p2.departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup = 1) or (p2.departmentHeadsCanViewAllPracDataInTheirReportingGroup = 1)),1,0)))

from cte_p2 as p2
join dbo.PRACTITIONER_GROUPS                               as pgd on  (pgd.GROUP_ID = p2.SUPERVISED_DISP_GROUP_ID)                                                                  
join dbo.PRACTITIONER_Client                               as prc on ((prc.PRACTITIONER_ID = pgd.PRACTITIONER_ID)
	                                                              and (prc.CLIENT_ID = @clientID))
join dbo.PRACTITIONER_Practitioner                         as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID	                                                                  

join dbo.PRACTITIONER_GROUPS                               as pgr on  ((pgr.PRACTITIONER_ID = prp.PRACTITIONER_ID)
                                                                  and (pgr.GROUP_TYPE in (3,5))
                                                                  and (pgr.ACTIVE = 1))

join dbo.GROUP_Group                                       as ggr on ((ggr.GROUP_ID = pgr.GROUP_ID)
                                                                  and (ggr.GROUP_TYPE in (3,5))
																  and (ggr.ACTIVE = 1))

where (
      (1=1)
  and ((@supervisedPracID is null) or (prp.PRACTITIONER_ID = @supervisedPracID))
)
)
,

/*============================================================
 * Determine if we can include these pracs based on
 * department head + group family + reporting group rules
 *============================================================*/  

cte_p4
as
(
select 	
      p3.*
    , okToIncludeThisPrac = convert(bit,iif ( (p3.LIMITED_TO_REPT_GROUP = 1)
                                              , iif((p3.DEPT_HEAD_AND_SUPERVISED_PRAC_IN_SAME_REPT_GROUP = 1),1,0)  
                                              , 1))
from cte_p3 as p3  
)

/*============================================================
 * Output pracs 
 *
 * Note: The calling routines will further include/exclude pracs
 * based on the values (returned) of :
 *
 * - departmentHeadsCanViewSupervisedPracsSvcRecs
 * - departmentHeadsCanViewSupervisedPracsPrivateNotes
 * - departmentHeadsCanViewSupervisedPracsStoredFiles
 *============================================================*/  

select 
      p4.DEPT_HEAD_DISP_GROUP_ID 
	, p4.DEPT_HEAD_DISP_GROUP_NAME 
	, p4.DEPT_HEAD_REPT_GROUP_ID 
	, p4.DEPT_HEAD_REPT_GROUP_NAME 
    , p4.DEPT_HEAD_GROUP_SERVICE_CLASS_NAME_ID 
	, p4.DEPT_HEAD_PRAC_ID  
	, p4.DEPT_HEAD_PRAC_NAME
    , p4.SUPERVISED_DISP_GROUP_ID
    , p4.SUPERVISED_DISP_GROUP_NAME
    , p4.SUPERVISED_GROUP_SERVICE_CLASS_NAME_ID
    , p4.SUPERVISED_PRAC_ID
    , p4.SUPERVISED_PRAC_NAME
    , p4.SUPERVISED_REPT_GROUP_ID 
    , p4.SUPERVISED_REPT_GROUP_NAME	
	, p4.departmentHeadsCanViewSupervisedPracsSvcRecs
	, p4.departmentHeadsCanViewSupervisedPracsPrivateNotes
	, p4.departmentHeadsCanViewSupervisedPracsStoredFiles
    , p4.departmentHeadsCanViewAllPracDataInTheirReportingGroup

from cte_p4 as p4
where 
  (p4.okToIncludeThisPrac = 1)
)
GO

GRANT SELECT ON  [dbo].[PRACTITIONER_DIRECT_SUPERVISED_FOR_DEPARTMENT_HEAD_VIEW_CORE] TO [webuser]
GO
