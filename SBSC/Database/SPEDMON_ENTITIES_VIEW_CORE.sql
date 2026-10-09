USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SPEDMON_ENTITIES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SPEDMON_ENTITIES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SPEDMON_ENTITIES_VIEW_CORE] (
    @whatEntity   as int
  , @active       as bit  
  , @clientID     as bigint
  , @term1        as varchar(255)
  , @term2        as varchar(255) 
  , @name         as varchar(8000)
  , @value        as varchar(8000)

)    

RETURNS TABLE
 
 /***************************************************************************    
  * SPEDMON_ENTITIES_VIEW_CORE */    
 /**    
  * Returns a list of entities
  * 
  * @parm whatEntity  200 = Clients
  *                   300 = Sites
  *                   400 = Practitioner Groups - Discipline
  *                   425 = Practitioner Groups - Report
  *                   450 = Practitioner Groups - Super
  *                   475 = Practitioner Groups - Processing
  *                   500 = Practitioners
  *                   600 = Patients
  *
  * @parm clientID    Client ID to limit results to 
  * @parm term1       Argument to like conditional for NAME, LAST_NAME
  * @parm term2       Argument to like conditional for FIRST_NAME
  * @parm name        Literal name
  * @parm value       Literal unique value
  ***************************************************************************/                         
     
AS RETURN
(

/*###########################################################################
  # Clients 
  ###########################################################################*/   

/*============================================================
 * cte_entity_clients_build_base_pass_1
 *
 * Column cleanup and filter out clientID
 *============================================================*/

with
cte_entity_clients_build_base_pass_1
as
(
  select
    cc.CLIENT_ID      as value
  , cc.CLIENT_NAME    as name
  , cc.CLIENT_CDS     as detail
  , isnull(cc.LEA,0)  as lea
  , isnull(cc.MAA,0)  as maa
  , cc.DATE_CREATED   as created
  , isnull(cc.DATE_MODIFIED,cc.DATE_CREATED) as modified
  from CLIENTS_Client as cc  
  where ((1=1) and ((@clientID is null) or (cc.CLIENT_ID = @clientID)))
) 
,

/*============================================================
 * cte_entity_clients_build_base_pass_2
 *
 * Create active column, and filter active
 *============================================================*/

cte_entity_clients_build_base_pass_2
as
(
  select value, name, detail, created, modified
  , active = case when lea = 0 and maa = 0 then 1 
                  when lea = 0 and maa = 1 then 1
                  when lea = 1 and maa = 0 then 1
                  when lea = 1 and maa = 1 then 1
             end
  from cte_entity_clients_build_base_pass_1 as cc
  where ((1=1) and ((@active is null) or ((lea = @active) or (maa = @active))))
) 
,

/*============================================================
 * cte_entity_clients_base
 * 
 * Clients data used by other parts of this cte
 * Client id and active are used to limit rows
 *============================================================*/

cte_entity_clients_base
as
(
  select * from cte_entity_clients_build_base_pass_2
) 
,

/*============================================================
 * cte_entity_clients
 * 
 * Clients data output.  Filter on term1
 *============================================================*/

cte_entity_clients
as
(
  select value, name, detail, active, created, modified from cte_entity_clients_base where (1=1) and ((@term1 is null) or (name like @term1))
)
,

/*###########################################################################
  # Sites
  ###########################################################################*/   

/*============================================================
 * cte_entity_sites
 * 
 *
 *============================================================*/
 
cte_entity_sites
as
(
select 
    ss.SITE_ID    as value
  , ss.SITE_NAME  as name
  , cc.name + ' - ' + cc.detail + ' - ' + ss.SITE_CDS as detail 
  , ss.ACTIVE                                as active
  , ss.DATE_CREATED                          as created
  , isnull(ss.DATE_MODIFIED,ss.DATE_CREATED) as modified
from cte_entity_clients_base as cc
join SITES_Site              as ss on ss.SITE_CLIENT_ID = cc.value
where 
      ((1=1) 
  and ((@active is null) or (ss.ACTIVE = @active)) 
  and ((@term1  is null) or (ss.SITE_NAME like @term1)))
)
,

/*###########################################################################
  # Practitoner Groups 
  ###########################################################################*/   
  
/*============================================================
 * cte_entity_practitioner_groups_base
 * 
 * Not directly output.
 *============================================================*/

cte_entity_practitioner_groups_base
as
(
  select * from GROUP_Group where ((1=1) and ((@active is null) or (Active = @active)))
)
,

/*============================================================
 * cte_entity_practitioner_groups_super_base
 * 
 * Not directly output
 *============================================================*/

cte_entity_practitioner_groups_super_base
as
(
  select 
    gg.GROUP_ID   as value
  , gg.GROUP_NAME as name
  , 'Super Group' as detail
  , gg.ACTIVE     as active
  , null          as created
  , null          as modified

  from cte_entity_practitioner_groups_base as gg
  where (gg.GROUP_TYPE = 5)
)
,

/*============================================================
 * cte_entity_practitioner_groups_super
 * 
 * 
 *============================================================*/

cte_entity_practitioner_groups_super
as
(
  select * from cte_entity_practitioner_groups_super_base where ((1=1) and ((@term1 is null) or (name like @term1)))
)
,

/*============================================================
 * cte_entity_practitioner_groups_disp_base
 * 
 * Not used in output directly
 *============================================================*/
 
cte_entity_practitioner_groups_disp_base
as
(
select 
    gg.GROUP_ID   as value
  , gg.GROUP_NAME as name
  , 'Discipline Group - ' + sg.name as detail
  , gg.ACTIVE     as active
  , null          as created
  , null          as modified
from cte_entity_practitioner_groups_base as gg
join cte_entity_practitioner_groups_super_base as sg on sg.value = gg.PARENT_GROUP_ID
where (gg.GROUP_TYPE in (1,2)) 
)
,

/*============================================================
 * cte_entity_practitioner_groups_disp
 * 
 * 
 *============================================================*/

cte_entity_practitioner_groups_disp
as
(
select * 
from cte_entity_practitioner_groups_disp_base as gg
where ((1=1) and ((@term1 is null) or (gg.name like @term1)))
)
,

/*============================================================
 * cte_entity_practitioner_groups_rept_base
 * 
 * Not used in output directly
 *============================================================*/

cte_entity_practitioner_groups_rept_base
as
(
  select * from cte_entity_practitioner_groups_base as gg 
  where ((gg.GROUP_TYPE = 3) and ((@term1 is null) or (gg.GROUP_NAME like @term1)))
)
,
  
/*============================================================
 * cte_entity_practitioner_groups_rept_client
 * 
 * Not used in output directly
 *============================================================*/

cte_entity_practitioner_groups_rept_client
as
(
select 
    gg.GROUP_ID   as value
  , gg.GROUP_NAME as name
  , 'Reporting Group - ' + cc.name as detail
  , gg.ACTIVE     as active
  , null          as created
  , null          as modified
from cte_entity_clients_base                  as cc
join cte_entity_practitioner_groups_rept_base as gg on gg.CLIENT_ID = cc.value
where
(1=1) 
and ((@clientID is null) or (gg.CLIENT_ID = @clientID))
)
,

/*============================================================
 * cte_entity_practitioner_groups_rept_generic
 * 
 * Not used in output directly
 *============================================================*/

cte_entity_practitioner_groups_rept_generic
as
(
select 
    gg.GROUP_ID   as value
  , gg.GROUP_NAME as name
  , 'Reporting Group - All Clients' as detail
  , gg.ACTIVE     as active 
  , null          as created
  , null          as modified
from cte_entity_practitioner_groups_rept_base as gg
where (gg.CLIENT_ID is null)
)
,


/*============================================================
 * cte_entity_practitioner_groups_rept
 * 
 * 
 *============================================================*/

cte_entity_practitioner_groups_rept
as
(
select * from cte_entity_practitioner_groups_rept_client
union all
select * from cte_entity_practitioner_groups_rept_generic
)
,

/*============================================================
 * cte_entity_practitioner_groups_proc
 * 
 * 
 *============================================================*/

cte_entity_practitioner_groups_proc
as
(
  select 
      gg.GROUP_ID        as value
    , gg.GROUP_NAME      as name
    , 'Processing Group' as detail
    , gg.ACTIVE          as active
    , null               as created
    , null               as modified
  from cte_entity_practitioner_groups_base as gg 
  where ((gg.GROUP_TYPE = 4) and ((@term1 is null) or (gg.GROUP_NAME like @term1)))
)
,

/*============================================================
 * cte_entity_practitioner_group_group_base
 * 
 * 
 *============================================================*/

cte_entity_practitioner_group_group_base
as
(
select distinct 
   0 as value
  ,GROUP_BASE as name
  ,''         as description
  , 1         as active
  , null      as created
  , null      as modified 
from GROUP_Group  
where ((GROUP_BASE is not null) and ((@active is null) or (ACTIVE = @active)))
)
,

/*###########################################################################
  # Practitioners
  ###########################################################################*/   

cte_entity_practitioners
as
(
select 
   ppr.PRACTITIONER_ID   as value
  ,ppr.CONCAT_NAME       as name
  ,case when(@clientID is null) then cc.name + ' - ' + ggd.name else ggd.name end as detail
  ,ppr.ACTIVE                                  as active
  ,ppr.DATE_CREATED                            as created
  ,isnull(ppr.DATE_MODIFIED, ppr.DATE_CREATED) as modified
from cte_entity_clients_base                  as cc
join PRACTITIONER_Client                      as prc on prc.CLIENT_ID       = cc.value
join PRACTITIONER_Practitioner                as ppr on ppr.PRACTITIONER_ID = prc.PRACTITIONER_ID
join PRACTITIONER_GROUPS                      as pg  on pg.PRACTITIONER_ID  = ppr.PRACTITIONER_ID
join cte_entity_practitioner_groups_disp_base as ggd on ggd.value = pg.GROUP_ID
where ((1=1)
and ((@active is null) or (ppr.ACTIVE = @active))
and ((@term1  is null) or (ppr.LAST_NAME  like @term1 ))
and ((@term2  is null) or (ppr.FIRST_NAME like @term2 )))
)
,

/*###########################################################################
  # Patients
  ###########################################################################*/   

cte_entity_patients
as
(
select
   value
  ,name
  ,case when(@clientID is null) then CLIENT_NAME + ' - ' + dob else dob end as detail
  ,active
  ,created
  ,modified
from
(
  select 
     cc.name                             as CLIENT_NAME
    ,ppa.PATIENT_ID                      as value    
    ,ppa.CONCAT_NAME                     as name
    ,dbo.RPT_DATE_FMT(ppa.DATE_OF_BIRTH) as dob  
    ,dbo.YN_TO_BIT(ppa.ACTIVE)           as active
    ,ppa.DATE_CREATED                                               as created
    ,isnull(isnull(ppa.LAST_UPDATED, ppa.LASTPOP),ppa.DATE_CREATED) as modified
  from cte_entity_clients_base    as cc
  join PATIENTS_Client            as pac on pac.CLIENT_ID  = cc.value                                  
  join PATIENTS_PATIENT           as ppa on ppa.PATIENT_ID = pac.PATIENT_ID                                                                      
  where ((1=1)
  and ((@term1  is null) or (ppa.LAST_NAME  like @term1))
  and ((@term2  is null) or (ppa.FIRST_NAME like @term2)))
) as q1
where ((1=1) and ((@active is null) or (active = @active))) 

)
,

/*###########################################################################
  # File Classes
  ###########################################################################*/   

cte_entity_file_class_base
as
(
select 
    id            as [value]
  , name          as [name]          
  , [description] as [detail]
  , active        as [active]
  , null          as [created]
  , null          as [modified]
from FILE_CLASSES 
)
,  
  
/*###########################################################################
  # Combine and Output
  ###########################################################################*/  

/*============================================================
 * cte_combine
 * 
 * 
 *============================================================*/

cte_combine
as
(
          select * from cte_entity_clients                       where (@whatEntity = 200)
union all select * from cte_entity_sites                         where (@whatEntity = 300)
union all select * from cte_entity_practitioner_groups_disp      where (@whatEntity = 400)
union all select * from cte_entity_practitioner_groups_rept      where (@whatEntity = 425)
union all select * from cte_entity_practitioner_groups_super     where (@whatEntity = 450)
union all select * from cte_entity_practitioner_groups_proc      where (@whatEntity = 475)
union all select * from cte_entity_practitioner_group_group_base where (@whatEntity = 485)
union all select * from cte_entity_practitioners                 where (@whatEntity = 500)
union all select * from cte_entity_patients                      where (@whatEntity = 600)
)
,

/*============================================================
 * cte_output
 * 
 * Convert columns to varchar and final filtering 
 *============================================================*/

cte_output
as
(
  select 
      convert(varchar(max), name)   as name
    , convert(varchar(max), value)  as value
    , convert(varchar(max), detail) as detail 
    , active
    , created
    , modified
  from cte_combine
  where 
        ((1=1) 
    and ((@name  is null) or (name  = @name))
    and ((@value is null) or (value = @value)))
)

/*###########################################################################
  # Return 
  ###########################################################################*/   


select * from cte_output
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SPEDMON_ENTITIES_VIEW_CORE] TO [webuser]
GO   
