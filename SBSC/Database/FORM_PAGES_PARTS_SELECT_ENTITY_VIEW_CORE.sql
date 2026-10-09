USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_PAGES_PARTS_SELECT_ENTITY_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_PAGES_PARTS_SELECT_ENTITY_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[FORM_PAGES_PARTS_SELECT_ENTITY_VIEW_CORE] (
    @selectWhat    as int
  , @active        as bit  
  , @reqEntityVal1 as varchar(8000)
  , @reqEntityVal2 as varchar(8000)
  , @term1         as varchar(255)
  , @term2         as varchar(255) 
  , @name          as varchar(8000)
  , @value         as varchar(8000)
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SPEDMON_ENTITIES_VIEW_CORE */    
 /**    
  * Returns a list of entities
  * 
  * @parm    whatEntity     What to return
  * @parm    active      
  * @param   reqEntityVal1  Use based on @selectWhat.  Used for optional filtering
  * @param   reqEntityVal2  Use based on @selectWhat.  Used for optional filtering
  * @parm    term1          Argument to like conditional for NAME, LAST_NAME
  * @parm    term2          Argument to like conditional for FIRST_NAME
  * @parm    name           Literal name
  * @parm    value          Literal unique value
  ***************************************************************************/                         
     
AS RETURN
(

/*###########################################################################
  # CDE Public School Data
  ###########################################################################*/   

with

/*============================================================
 * cte_entity_public_counties
 *
 *============================================================*/
 
cte_entity_cde_public_counties
as
(
select value, name, cdscode as detail, 1 as active, null as created, null as modified 
from dbo.CDE_SCHOOLS_PUBLIC_COUNTIES_VIEW (@value,@term1)
)
,

/*============================================================
 * cte_entity_public_districts
 *
 *============================================================*/

cte_entity_cde_public_districts
as
(
select value, name, cdscode as detail, 1 as active, null as created, null as modified 
from dbo.CDE_SCHOOLS_PUBLIC_DISTRICTS_VIEW (@reqEntityVal1,@value,@term1)
)
,

/*============================================================
 * cte_entity_public_schools
 *
 *============================================================*/

cte_entity_cde_public_schools
as
(
select value, name, cdscode as detail, 1 as active, null as created, null as modified 
from dbo.CDE_SCHOOLS_PUBLIC_SCHOOLS_VIEW (@reqEntityVal1,@reqEntityVal2,@value,@term1)
)
,

/*###########################################################################
  # Clients 
  ###########################################################################*/   

/*============================================================
 * cte_entity_clients_build_base_pass_1
 *
 * Column cleanup and filter out clientID
 *============================================================*/

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
  where ((1=1) and ((@reqEntityVal1 is null) or (cc.CLIENT_ID = convert(int,@reqEntityVal1))))
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
  , GROUP_BASE
  , PARENT_GROUP_ID
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
select 
    gg.value
  , gg.name
  , gg.detail
  , gg.active
  , gg.created
  , gg.modified 
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
and ((@reqEntityVal1 is null) or (gg.CLIENT_ID = convert(int,@reqEntityVal1)))
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

cte_entity_practitioner_group_group_base_base
as
(
select distinct 
   GROUP_BASE as value
  ,GROUP_BASE as name
  ,''         as detail
  , 1         as active
  , null      as created
  , null      as modified 
from GROUP_Group  
where ((GROUP_BASE is not null) and ((@active is null) or (ACTIVE = @active)))
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
select * from cte_entity_practitioner_group_group_base_base
)
,

/*###########################################################################
  # Practitioners
  ###########################################################################*/   

/*============================================================
 * cte_entity_practitioner_base
 * 
 *============================================================*/

cte_entity_practitioners_base
as
(
select 
   ppr.PRACTITIONER_ID   as value
  ,ppr.CONCAT_NAME       as name
  ,case when(@reqEntityVal1 is null) then cc.name + ' - ' + ggd.name else ggd.name end as detail
  ,ppr.ACTIVE                                  as active
  ,ppr.DATE_CREATED                            as created
  ,isnull(ppr.DATE_MODIFIED, ppr.DATE_CREATED) as modified
  ,pg.GROUP_ID
  ,ggd.PARENT_GROUP_ID
  ,ggd.GROUP_BASE
from cte_entity_clients_base                  as cc
join PRACTITIONER_Client                      as prc on prc.CLIENT_ID       = cc.value
join PRACTITIONER_Practitioner                as ppr on ppr.PRACTITIONER_ID = prc.PRACTITIONER_ID
join PRACTITIONER_GROUPS                      as pg  on pg.PRACTITIONER_ID  = ppr.PRACTITIONER_ID
join cte_entity_practitioner_groups_disp_base as ggd on ggd.value           = pg.GROUP_ID
where ((1=1)
and ((@active is null) or (ppr.ACTIVE = @active))
and ((@term1  is null) or (ppr.LAST_NAME  like @term1 ))
and ((@term2  is null) or (ppr.FIRST_NAME like @term2 )))
)
,

/*============================================================
 * cte_entity_practitioners
 * 
 *============================================================*/

cte_entity_practitioners
as
(
  select value,name,detail,active,created,modified 
  from cte_entity_practitioners_base
)
,

/*============================================================
 * cte_entity_practitioners_by_group_base
 * 
 * Note: This is not a "base" cte
 *============================================================*/

cte_entity_practitioners_by_group_base
as
(
  select pb.value,pb.name,pb.detail,pb.active,pb.created,pb.modified 
  from cte_entity_practitioners_base                  as pb
  join cte_entity_practitioner_group_group_base_base  as pgb on pgb.value = pb.GROUP_BASE
  where (1=1) and ((@reqEntityVal2 is null) or (pb.GROUP_BASE = @reqEntityVal2)) 
)
,

/*============================================================
 * cte_entity_practitioners_by_super_group
 * 
 *============================================================*/

cte_entity_practitioners_by_super_group
as
(
  select pb.value,pb.name,pb.detail,pb.active,pb.created,pb.modified 
  from cte_entity_practitioners_base              as pb
  join cte_entity_practitioner_groups_super_base  as pgsb on pgsb.value = pb.PARENT_GROUP_ID
  where (1=1) and ((@reqEntityVal2 is null) or (pb.PARENT_GROUP_ID = convert(int,@reqEntityVal2))) 
)
,

/*============================================================
 * cte_entity_practitioners_rn
 * 
 *============================================================*/

cte_entity_practitioners_rn
as
(
  select value,name,detail,active,created,modified 
  from cte_entity_practitioners_base 
  where group_id in (15,16,19,20)
)
,

/*============================================================
 * cte_entity_practitioners_lic_speech
 * 
 *============================================================*/

cte_entity_practitioners_lic_speech
as
(
  select value,name,detail,active,created,modified 
  from cte_entity_practitioners_base 
  where group_id in (47,48)
)
,

/*============================================================
 * cte_entity_practitioners_lic_aud
 * 
 *============================================================*/

cte_entity_practitioners_lic_aud
as
(
  select value,name,detail,active,created,modified 
  from cte_entity_practitioners_base 
  where group_id in (1,2)
)
,
/*###########################################################################
  # Patients
  ###########################################################################*/   

cte_entity_patients
as
(

select  
  vc.id               as value
 ,vc.name             as name

 ,detail = vc.dob_str   
     + ' | ' + case when(@reqEntityVal1 is null) then cc.name + '|' + vc.siteName else vc.siteName end
     + ' | ' + vc.siteRank
     + ' | ' + vc.siteRefID                   
     + ' | ' + vc.gender


,vc.active        as active
,vc.lastPopulated as created
,vc.lastModifed   as modified

from cte_entity_clients_base as cc
join dbo.PATIENTS_VIEW_CORE (0,convert(bigint,@reqEntityVal1),null,@term1,@term2,null,'Y',null,null,null,null) as vc on vc.clientID = cc.value
)
,

/*###########################################################################
  # File Classes
  ###########################################################################*/   

cte_entity_file_class_base
as
(
  select 
      [id]            as [value]
    , [name]          as [name]
    , ''              as [detail]
    , active          as [active]
    , null            as [created]
    , null            as [modified]
  from FILE_CLASSES
  where ((upload_allowed_from_public = 1) or (upload_allowed_from_private = 1))
)
,  

cte_entity_file_classes
as
( 
  select * from cte_entity_file_class_base
)
,

/*###########################################################################
  # File Types
  ###########################################################################*/  

cte_entity_file_type_work_batches
as
( 
 select   
      fileTypeValue   as [value]     
    , fileTypeName    as [name]    
    , ''              as [detail]
    , 1               as [active]
    , null            as [created]
    , null            as [modified]
 from dbo.[FILE_UPLOAD_TYPE_VIEW] (null, null , @term1, null, 1, 1, 1)
 
)
,  

cte_entity_file_type_student_data
as
( 
 select   
      fileTypeValue   as [value]     
    , fileTypeName    as [name]    
    , ''              as [detail]
    , 1               as [active]
    , null            as [created]
    , null            as [modified]
 from dbo.[FILE_UPLOAD_TYPE_VIEW] (null, null , @term1, null, 2, 1, 1)
 
)
,

/*###########################################################################
  # Practi-Cal - LEA Business Reps
  ###########################################################################*/  

cte_entity_lea_reps 
as
(
select

 value
,name
,detail = (case when (isRep = 1) then 'Rep ' else '' end) + contactInfo
,active
,created
,modified
from
(
  select 
     [value]       = u.userrid
   , [name]        = m.FirstName + ' ' + m.LastName
   , [contactInfo] = isnull((m.Email + ' ' + m.PhoneNumber),'')
   , [isRep]       = case when (ccr.id is null) then 0 else 1 end
   , [active]      = case when (rd.id = 8) then 0 else 1 end
   , [created]     = m.CreateDate
   , [modified]    = m.LastLoginDate
  from users.dbo.Users             as u  
  join users.dbo.Membership        as m  on m.UserId  = u.UserId
  join users.dbo.UsersInRoles      as ur on ur.UserId = u.UserId
  join users.dbo.Roles             as r  on r.RoleId  = ur.RoleId
  join users.dbo.RoleData          as rd on rd.RoleId = r.RoleId
  left join CLIENTS_Client_Reps    as ccr on ccr.user_id = u.userrid
  where (rd.id = 9) /* Limit to A&I */
) as q1
where (value != 5393) /* Exclude quit quit */
)
,

/*###########################################################################
  # Daily Service Journal - Event Selections
  ###########################################################################*/   

cte_svc_journal_event_selection
as
(
  select 
      [id]            as [value]
    , [eventLabel]    as [name]
    , ''              as [detail]
    , 1               as [active]
    , null            as [created]
    , null            as [modified]
  from dbo.SvcJournal_Event_Types
  where (display = 1)
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
          select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_cde_public_counties           where (@selectWhat = 100)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_cde_public_districts          where (@selectWhat = 125)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_cde_public_schools            where (@selectWhat = 150)

union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_clients                       where (@selectWhat = 200)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_sites                         where (@selectWhat = 300)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_practitioner_groups_disp      where (@selectWhat = 400)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_practitioner_groups_rept      where (@selectWhat = 425)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_practitioner_groups_super     where (@selectWhat = 450)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_practitioner_groups_proc      where (@selectWhat = 475)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_practitioner_group_group_base where (@selectWhat = 485)

union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_practitioners                 where (@selectWhat = 500)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_practitioners_by_group_base   where (@selectWhat = 502)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_practitioners_by_super_group  where (@selectWhat = 504)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_practitioners_rn              where (@selectWhat = 510)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_practitioners_lic_speech      where (@selectWhat = 520)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_practitioners_lic_aud         where (@selectWhat = 530)

union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_patients                      where (@selectWhat = 600)

union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_file_classes                  where (@selectWhat = 700)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_file_type_work_batches        where (@selectWhat = 800)
union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_file_type_student_data        where (@selectWhat = 810)

union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_svc_journal_event_selection          where (@selectWhat = 900)

union all select name, convert(varchar(max), value) as value, detail , active, created , modified from cte_entity_lea_reps                      where (@selectWhat = 2000)
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
      convert(varchar(8000), name)   as name
    , value
    , convert(varchar(8000), detail) as detail 
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
 
GRANT SELECT ON  [dbo].[FORM_PAGES_PARTS_SELECT_ENTITY_VIEW_CORE] TO [webuser]

GO   
