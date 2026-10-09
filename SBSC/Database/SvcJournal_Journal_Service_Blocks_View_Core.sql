USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Service_Blocks_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journal_Service_Blocks_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Service_Blocks_View_Core] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT
  , @journalID         BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Journal_Service_Blocks_View_Core */    
 /**    
  * Returns a list of journal entries
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

/*###########################################################################
  # Get distict list of pracs who entered in journal
  ###########################################################################*/
  
with
cte_pracs
as
(
  select distinct 
    sjee.pracID as pracID
  from dbo.SvcJournals              as sj
  join dbo.SvcJournal_Event_Entries as sjee on sjee.journalID = sj.id
  where 
      (sj.clientID = @clientID)
  and (sj.id       = @journalID)   
  and (sj.active   = 1)
  and (sjee.active = 1)  
)
,

/*###########################################################################
  # Get their service blocks
  ###########################################################################*/

cte_service_blocks
as
(
  select 
    b.* 
  from cte_pracs as p
  cross apply (
    select pvc.* from dbo.SvcJournal_Journal_Service_Blocks_By_Prac_View_Core (@userID,@userGroup,@userRank,@clientID,@journalID,p.pracID) as pvc
  ) as b
)
,
/*###########################################################################
  # Get their user info
  ###########################################################################*/

cte_service_blocks_and_user_info
as
(
  select 
     csb.*
    ,rd.userGroup
    ,rd.rank as userRank
  from cte_service_blocks     as csb
  join users.dbo.Users        as u  on u.userrid = csb.userID
  join users.dbo.UsersInRoles as ur on ur.UserId = u.UserID
  join users.dbo.Roles        as r  on r.RoleId  = ur.RoleId
  join users.dbo.RoleData     as rd on rd.RoleId = r.RoleId
)

select * from cte_service_blocks_and_user_info


)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Service_Blocks_View_Core] TO [webuser]
GO  
