GO

use SPEDMON

;    
with
cte_pass_1
as
(
  select 
     cc.CLIENT_NAME   as [Client]
   , pap.CONCAT_NAME  as [Patient]
   , sj.id            as [journalID]
   , sj.dos 
   , patAge = dbo.CALC_AGE(pap.DATE_OF_BIRTH,sj.dos)
   , sj.patAbsent     
   , sj.completed     
   , sjd.Practitioner 
   , sjd.groupID
   , sjd.groupName
   , sjd.iep   
   , sjd.nameID 
   , sjd.numActualMins    
   , sjd.numClaimableMins 
   , sjd.numMins          
   , sjd.notes            

  from dbo.SvcJournals        as sj
  join dbo.CLIENTS_Client     as cc  on  cc.CLIENT_ID     = sj.clientID
  join dbo.PATIENTS_Patient   as pap on  pap.PATIENT_ID   = sj.patID 
  join users.dbo.Users        as u   on  u.userrid        = sj.createdBy
  join users.dbo.UsersInRoles as ur  on  ur.UserId        = u.UserId
  join users.dbo.Roles        as r   on  r.RoleId         = ur.RoleId
  join users.dbo.RoleData     as rd  on  rd.RoleId        = r.RoleId

  outer apply (
    select 
       prp.CONCAT_NAME       as [Practitioner]
      ,gg.GROUP_ID           as [groupID]
      ,gg.GROUP_NAME         as [groupName]
      ,sjsb.*

    from dbo.SvcJournal_Journal_Service_Blocks_And_Procedure_Data_Combined_View_Core (  sj.createdBy                                                                                   
                                                                                      , rd.userGroup
                                                                                      , rd.rank
                                                                                      , sj.clientID
                                                                                      , sj.id
                                                                                      , '' ) as sjsb
    join dbo.PRACTITIONER_Practitioner as prp on  prp.PRACTITIONER_ID = sjsb.pracID
    join dbo.PRACTITIONER_GROUPS       as pg  on  pg.PRACTITIONER_ID  = sjsb.pracID
                                              and pg.GROUP_TYPE in (1,2)
    join dbo.GROUP_Group               as gg  on  gg.GROUP_ID         = pg.GROUP_ID
                                              and gg.GROUP_TYPE in (1,2)  
  ) as sjd

  where ((sj.clientID != 112) and (sj.active = 1))  
)
,
cte_pass_2
as
(
  select *, planType = dbo.AGE_IEP_TO_PLAN_TYPE(patAge,iep) from cte_pass_1 
)
,
cte_pass_3
as
(
  select
     [Client]         as [Client]
   , [Patient]        as [Patient]
   , CONVERT(VARCHAR(10),[DOS],101)            as [DOS]
   , journalID        as [Journal ID]
   , CAST(patAbsent AS INT)        as [Patient Absent]
   , CAST(completed AS INT)        as [Journal Completed] 
   , isnull(Practitioner,     '')  as [Practitioner]
   , isnull(groupName,        '')  as [Group]
   , isnull(sva.svc_name,     '')  as [Service]
   , isnull(numActualMins,    '')  as [Num Mins - Actual]
   , isnull(numClaimableMins, '')  as [Num Mins - Claimable]
   , isnull(numMins,          '')  as [Num Mins - Service Record]
   , isnull(notes,            '')  as [Notes]
  from cte_pass_2     as p2
  outer apply (
    select top 1 *
    from dbo.SERVICES_VIEW_ALL()
    where (
          (name_id       = p2.nameID)
      and (prac_group_id = p2.groupID)
      and (plan_type     = p2.planType)
      and (is22          = 0)
    )
  ) as sva
)
select * from cte_pass_3
order by
 [Client]
,[Patient]
,[DOS]
,[Journal ID]

GO