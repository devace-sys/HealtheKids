USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Related_Svc_Records_Data_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SvcJournal_Related_Svc_Records_Data_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Related_Svc_Records_Data_Core] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT      
  , @journalID         BIGINT
  , @svcRecID          BIGINT
  , @pracID            BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Related_Svc_Records_Data_Core */    
 /**    
  * Returns a list of related service data
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
with

/*============================================================
 * Journal service records and service records revisions 
 * combined
 *============================================================*/  

cte_jrsr
as
(

  select 
      journalID
    , svcRecID 
  from dbo.SvcJournal_Service_Records
  where ( 
        (1=1) 
    and ((@journalID is null) or (journalID = @journalID))
    and ((@svcRecID  is null) or (svcRecID  = @svcRecID))
  )
  
  union
  
  select 
      journalID
    , svcRecID 
  from dbo.SvcJournal_Service_Records_Revisions 
  where ( 
       (1=1) 
    and ((@journalID is null) or (journalID = @journalID))
    and ((@svcRecID  is null) or (svcRecID  = @svcRecID))
  )
)
,

/*============================================================
 * Journal service records and service records revisions combined
 * with journal and service record data
 *============================================================*/  

cte_jrsr_sr
as
(
  select   
      jrsr.*
    , jr.clientID
    , jr.dos
    , jr.patID
    , jr.patAbsent  
    , sr.userID
    , rd.userGroup
    , rd.rank as userRank  
    , m.Email as userEmail
    , sr.pracID
    , sr.numMins
    , sr.claimID1
    , sr.claimID2
    , sr.state
    , canStillEditSvc = dbo.SERVICE_STATE_TO_CAN_STILL_EDIT_FLAG(sr.state)
  from cte_jrsr               as jrsr
  join dbo.SvcJournals        as jr   on jr.id     = jrsr.journalID
  join dbo.SERVICE_RECORDS    as sr   on sr.id     = jrsr.svcRecID
  join users.dbo.Users        as u    on u.userrid = sr.userID
  join users.dbo.Membership   as m    on m.UserId  = u.UserId
  join users.dbo.UsersInRoles as ur   on ur.UserId = u.UserID
  join users.dbo.Roles        as r    on r.RoleId  = ur.RoleId
  join users.dbo.RoleData     as rd   on rd.RoleId = r.RoleId

  where (   
        (1=1)
    and ((@journalID is null) or (jr.id     = @journalID))
    and ((@svcRecID  is null) or (sr.id     = @svcRecID))
    and ((@pracID    is null) or (sr.pracID = @pracID))
)
  
)
,

/*============================================================
 * Output
 *============================================================*/  

cte_output
as
(
  select * 
  from cte_jrsr_sr 
  where ((1=1) and ((@clientID is null) or (clientID = @clientID)))
)

select * from cte_output


)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Related_Svc_Records_Data_Core] TO [webuser]
GO  
