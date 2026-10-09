USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENTS_DATA_CORE] (
    @source     INT
  , @clientID   INT    
  , @pracID     INT
  , @refDate    DATETIME
  , @recID      INT
)  

RETURNS TABLE

 /***************************************************************************    
  * PATIENTS_DATA_CORE */    
 /**    
  * Returns core set of patient ids    
  *    
  * @param  source          Required.  Source of data
  * @param  clientID        Required.  Client ID
  * @param  pracID          Optional.  Practitioner ID. 
  * @param  refDate         Optional.  Reference date 
  * @return                 Table of patient ids
  ***************************************************************************/     

AS RETURN (

with 

/*###########################################################################
  # Query base
  # Controls if cross apply is applied
  ###########################################################################*/  

cte_base 
as
(
  select top 1 
    [source] = @source
  where 
    (@source in (0,1,2,3,4,5,6,7,8))
)
,

/*###########################################################################
  # Patient base data
  # Used in all sources
  # Handles filtering of client and patient id (recid)
  ###########################################################################*/  

cte_pat_base
as
(
  select       
	pc.* 
  from dbo.PATIENTS_CLIENT as pc
  
  where (    
         (1=1)
    and  (((@clientID is null) or (pc.CLIENT_ID  = @clientID))
	and   ((@recID    is null) or (pc.PATIENT_ID = @recID))
	and   (pc.PATIENT_CLIENT_ID is not null))		
  )
)
,

/*###########################################################################
  # 0 - All Patients
  ###########################################################################*/  

cte_from_0
as
(    
  select      
    s0.*
  from cte_base as b
  cross apply (
    select 
      pc.* 
    from cte_pat_base as pc     
  ) as s0
  where 
    (b.[source] = 0)
)
,

/*###########################################################################
  # 1 - Service History
  ###########################################################################*/  

cte_from_1
as
(    
  select      
    s1.*
  from cte_base as b
  cross apply (
    select 
	  pc.*     
    from cte_pat_base as pc 
    cross apply (   
      select top 1 
        sr.patID 
      from dbo.SERVICE_RECORDS as sr 
      where (	        
			((sr.clientID = pc.CLIENT_ID) and (sr.patID = pc.PATIENT_ID))
        and ((@pracID   is null) or (sr.pracID = @pracID))
        and (sr.state not in (99,199))        
      )
      order by 
        sr.id asc
    ) as sr
  ) as s1  
  where 
    (b.[source] = 1)
) 
,

/*###########################################################################
  # 2 - Practitioner Caseloads
  ###########################################################################*/  

cte_from_2
as
(      
  select      
    s2.*
  from cte_base as b
  cross apply (
    select 
      pc.* 
    from cte_pat_base                       as pc 
    join dbo.PRACTITIONER_PATIENT_CASELOAD  as ppc on (    (ppc.clientID = pc.CLIENT_ID)
                                                       and (ppc.pracID   = @pracID)
                                                       and (ppc.patID    = pc.PATIENT_ID))
  ) as s2
  where 
    (b.[source] = 2)    
)
,

/*###########################################################################
  # 3 - One on One Aide Assignments
  ###########################################################################*/  

cte_1_on_1
as
(
  select distinct
    aa.PATIENT_ID
  from dbo.ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_BY_DATE (  @clientID 
                                                    , @pracID
                                                    , @recID
                                                    , @refDate ) as aa                                               
)
,
cte_from_3
as
(   
  select      
    s3.*
  from cte_base as b
  cross apply (
    select 
      pc.* 
    from cte_pat_base     as pc 
    join cte_1_on_1       as aa on (aa.PATIENT_ID = pc.PATIENT_ID)
  ) as s3
  where 
    (b.[source] = 3)                             
)
,

/*###########################################################################
  # 4 - All Patients - Inactive
  # Note: We apply active flag = 0 in middleware
  ###########################################################################*/  

cte_most_recent_inactive_with_a_site_assignment
as
(  
  select         
        
    max(pc.PATIENT_ID) as PATIENT_ID        
  
  from cte_pat_base         as pc
  join dbo.PATIENTS_Patient as pp on (pp.PATIENT_ID = pc.PATIENT_ID)
  join dbo.PATIENTS_School  as ps on (ps.PATIENT_ID = pp.PATIENT_ID)  
  
  where (            
        ((pp.LAST_NAME    is not null)
	and (pp.FIRST_NAME    is not null)
	and (pp.DATE_OF_BIRTH is not null)
	and (pp.ACTIVE        = 'N')
	and (pp.PATIENT_ID    is not null))
  )  
  group by       
       pp.LAST_NAME
     , pp.FIRST_NAME
     , pp.DATE_OF_BIRTH
	 , pp.ACTIVE
     , ps.STUDENT_ID
)
,
cte_from_4
as
(
  select      
    s4.*
  from cte_base as b
  cross apply (
    select 
      pc.* 
    from cte_pat_base                                    as pc    join cte_most_recent_inactive_with_a_site_assignment as ip on (ip.PATIENT_ID = pc.PATIENT_ID)
  ) as s4
  where 
    (b.[source] = 4)        
)
,

/*###########################################################################
  # 5 - Special Ed Patients Only
  ###########################################################################*/  

cte_from_5
as
( 
  select      
    s5.*
  from cte_base as b
  cross apply (
    select 
      pc.* 
    from cte_pat_base         as pc
    join dbo.PATIENTS_IEP     as pip on (pip.PATIENT_ID = pc.PATIENT_ID) 
    where 
	  (pip.IEP_IFSP_NONE != 'NONE')    
  ) as s5
  where 
    (b.[source] = 5)
)
,

/*###########################################################################
  # 6 - Received Transportation Svcs Only
  ###########################################################################*/  

cte_trans_svcs
as
( 
  select distinct
    patID
  from dbo.SERVICE_RECORDS as sr
  where /* Uses [CLIENT_PAT_GRP_FAM_SVCTYPE_IDX_W_ADD_COLS] index */
        (1=1)
    and ((@clientID is null) or (sr.clientID = @clientID))
	and (sr.patID               is not null)    
    and (sr.svcType = 3 /* Transportation */)
    and (sr.state not in (99,199))     
)
,
cte_from_6
as
(    
  select      
    s6.*
  from cte_base as b
  cross apply (
    select 
     pc.*
   from cte_pat_base as pc 
   join cte_trans_svcs as sr on sr.patID = pc.PATIENT_ID   
  ) as s6
  where 
    (b.[source] = 6)       
)
,

/*###########################################################################
  # 7 - Service Journal - Only
  ###########################################################################*/  

cte_svc_journals
as
(
  select distinct   
    patID   
  from dbo.SvcJournals as sj
  where (
        (1=1)
    and ((@clientID is null) or (sj.clientID = @clientID))
    and (sj.active = 1))
)
,
cte_from_7
as
( 
  select      
    s7.*
  from cte_base as b
  cross apply (
    select 
      pc.*
    from cte_pat_base     as pc 
    join cte_svc_journals as sj on sj.patID = pc.PATIENT_ID
  ) as s7
  where 
    (b.[source] = 7)     
)
,

/*###########################################################################
  # 8 - Service Descriptions - Only
  ###########################################################################*/  

cte_svc_descriptions
as
(
  select distinct   
    patID   
  from dbo.SvcJournal_Service_Descriptions as sjsd
  where (
        (1=1)
    and ((@clientID is null) or (sjsd.clientID = @clientID))
  )
)
,
cte_from_8
as
( 
  select      
    s8.*
  from cte_base as b
  cross apply (  
    select 
      pc.*
    from cte_pat_base as pc 
	join cte_svc_descriptions as sjsd on sjsd.patID = pc.PATIENT_ID
  ) as s8
  where 
    (b.[source] = 8)    
)
,

/*###########################################################################
  # Combine
  ###########################################################################*/  
cte_combine
as
(
      select * from cte_from_0 where @source = 0
union select * from cte_from_1 where @source = 1
union select * from cte_from_2 where @source = 2
union select * from cte_from_3 where @source = 3
union select * from cte_from_4 where @source = 4
union select * from cte_from_5 where @source = 5
union select * from cte_from_6 where @source = 6
union select * from cte_from_7 where @source = 7
union select * from cte_from_8 where @source = 8 
)
select [SOURCE] = @source, t1.* from cte_combine as t1 

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENTS_DATA_CORE] TO [webuser]
GO

  