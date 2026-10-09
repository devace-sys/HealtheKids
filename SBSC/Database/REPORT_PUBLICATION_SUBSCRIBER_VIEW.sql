USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_SUBSCRIBER_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.REPORT_PUBLICATION_SUBSCRIBER_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[REPORT_PUBLICATION_SUBSCRIBER_VIEW]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,
 @clientID       BIGINT,
 @active         BIT,
 @internalOnly   BIT, /* too bad NOT NULL won't compile here.  NOT NULL won't work with inline TVFs, with or without NATIVE_COMPILATION */
 @recID          BIGINT
)

RETURNS TABLE

 
/***************************************************************************    
 * REPORT_PUBLICATION_SUBSCRIBER_VIEW */ 
/**    
 * Returns subscription list
 * @return               Table 
 ***************************************************************************/                         
     
AS RETURN
(


/*-------------------------------
 * Return rows
 *------------------------------*/
with all_rsr as (
  SELECT
  rsr.id          as id,
  rsr.clientID    as clientID,
  cc.CLIENT_NAME  as clientName,
  rsr.FirstName   as firstName,
  rsr.LastName    as lastName,
  rsr.LastName + ', ' + rsr.FirstName as "name",
  rsr.Email       as email,
  rsr.Active      as active,
  rsr.is_internal as "Internal?",
  rsr.is_internal as isInternal  

from dbo.REPORT_PUBLICATION_SUBSCRIBERS      as rsr 
left join dbo.CLIENTS_CLIENT                 as cc on cc.CLIENT_ID = rsr.ClientID
),
  non_user_rsr as ( -- get the subscribers that have been entered normally through the subscriber save screen, for a given client, or all clients
  SELECT
    *
  FROM all_rsr
  where 
       ((@clientID is null)  or (clientID = @clientID))    
  and  ((@active   is null)  or (active   = @active))  
  and  ((@internalOnly is null)  or (@internalOnly = 0)  or  ("Internal?" = 1))
  and  ((@recID    is null)  or (all_rsr.id = @recID))
),
  users_as_rsr as ( -- query the "subscriber" objects that have the same email addresses as client rep spedcare users, for a given client, or all clients...
  SELECT DISTINCT   -- that way, client reps don't need to have a whole bunch of duplicate "subscriber" entries, one for each client
    all_rsr.*
  FROM dbo.CLIENTS_Client cc
    JOIN CLIENTS_Client_Reps rep
      ON @recID is null AND (@clientID is null or cc.CLIENT_ID = @clientID) AND (@clientID is not null or cc.LEA = 1)
        AND cc.ClientRepIDLEACurrent = rep.id
    JOIN [users].[dbo].[USERS_ALL] mbr
      ON mbr.id = rep."user_id"
        AND mbr.pcalStaff = 1 AND mbr.accountIsLockedOut = 0 AND mbr.sendUserEmailNotifications = 1
    JOIN all_rsr ON mbr.email = all_rsr.email
      and (@active is null or all_rsr.active = @active) -- not sure this is needed; a client rep's "subscriber" entry should never be inactive
)
select top (dbo.CONST_MAX_ROWS()) * FROM (
  SELECT * FROM non_user_rsr u1 UNION SELECT * FROM users_as_rsr u2 ) u

order by 
  clientName,
  "Internal?" DESC, 
  lastName,
  firstName  
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[REPORT_PUBLICATION_SUBSCRIBER_VIEW] TO [webuser]
GO   
