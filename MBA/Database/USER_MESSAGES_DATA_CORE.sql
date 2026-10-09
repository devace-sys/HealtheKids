USE users
GO



/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USER_MESSAGES_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.USER_MESSAGES_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[USER_MESSAGES_DATA_CORE] (
   @appName             VARCHAR(50)
 , @senderUserID        BIGINT
 , @receiverUserID      BIGINT
 , @okToShow            BIT
 , @hasRead             BIT
 , @sendEmail           BIT
 , @emailSent           BIT
 , @active              BIT
 , @recID               BIGINT)

RETURNS TABLE

 /***************************************************************************
  * USER_MESSAGES_DATA_CORE */
 /**
  ***************************************************************************/

AS RETURN
(


  select
	  m.id
	, userMessageID = um.id
	, m.created
	, m.systemGenerated
	, m.senderUserID
	, m.senderUID
	, senderName        = iif((m.systemGenerated = 1),a.appTitle,isnull(uas1.name, N''))
	, senderEmail       = isnull(uas1.email,N'')

  , senderClientName      = uas1_CC.CLIENT_NAME
  , senderClientID        = uas1_CC.CLIENT_ID

	, um.recipientUserID
	, um.recipientUID
	, recipientName      = uar1.name
	, recipientEmail     = uar1.email
	, recipientUserGroup = uar1.userGroupID
	, recipientUserRank  = uar1.roleRank

  , recipientUserName = uar1.userName

  , recipientClientName      = uar1_CC.CLIENT_NAME
  , recipientClientID        = uar1_CC.CLIENT_ID

  , promptUserToGotoURL
  , gotoURL
  , gotoURLAdditionalParams

	, m.subject
	, m.body
    , m.respPromptOptionsBitwise
    , m.respPromptOptionsJSON
	, m.allowReply
	, um.okToShow
	, um.hasRead
    , um.sendEmail
	, um.emailSent
	, um.active

        , uar1.pcalStaff  recipIsPcalStaff

from dbo.USERS_MESSAGES  as um
join dbo.MESSAGES        as m   on m.id      = um.messageID
join dbo.APPS            as a   on a.appName = m.appName



outer apply (
  select top 1
    uas1.*
  from dbo.users_all as uas1
  where (uas1.uid  = m.senderUID )
        and (uas1.appName = @appName)
) as uas1
     -- the outer subquery can be aliased the same as the inner table it queries,
     -- for readability.

LEFT JOIN spedmon.dbo.CLIENTS_Client uas1_CC
          ON  uas1.appName        = 'spedcare'
              AND
              uas1_CC.CLIENT_ID   = uas1.clientID

outer apply (
  select top 1
    uar1.*
  from dbo.users_all as uar1
  where (uar1.uid  = um.recipientUID )
        and (uar1.appName = @appName)
) as uar1

LEFT JOIN spedmon.dbo.CLIENTS_Client uar1_CC
          ON  uar1.appName        = 'spedcare'
              AND
              uar1_CC.CLIENT_ID   = uar1.clientID

where (
			(1=1)
		and ((@recID          is null) or (m.id               = @recID            ))
		and ((@senderUserID   is null) or (m.senderUserID     = @senderUserID     ))
		and ((@receiverUserID is null) or (um.recipientUserID = @receiverUserID   ))
        and ((@okToShow       is null) or (um.okToShow        = @okToShow         ))
		and ((@hasRead        is null) or (um.hasRead         = @hasRead          ))
		and ((@sendEmail      is null) or (um.sendEmail       = @sendEmail))
		and ((@emailSent      is null) or (um.emailSent       = @emailSent))
		and ((@active         is null) or (um.active          = @active           ))
		and (m.appName = @appName)
)


)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[USER_MESSAGES_DATA_CORE] TO [webuser]
GO
