USE users
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USER_MESSAGES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.USER_MESSAGES_VIEW_CORE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[USER_MESSAGES_VIEW_CORE] (
   @userID              BIGINT
 , @userGroup           INT
 , @userRank            INT
 , @appName             VARCHAR(50)
 , @viewSentOnly        BIT
 , @okToShow            BIT
 , @hasRead             BIT
 , @sendEmail           BIT
 , @emailSent           BIT
 , @active              BIT
 , @recID               BIGINT)

RETURNS TABLE

 /***************************************************************************
  * USER_MESSAGES_VIEW_CORE */
 /**
  * Returns a table of entities
  *
  * @param   userID         The userid of who is requesting the operation
  * @param   userGroup      Users group
  * @param   userRank       User rank
  * @param   active         Active 0 = No 1 = Yes
  * @param   recID          Entity record id
  * @return                 Table of patient data
  ***************************************************************************/


AS RETURN
(

 with received_cte as (
	select
		  umdc1.id
		, umdc1.subject
		, umdc1.body
		, umdc1.senderUserID
		, umdc1.senderName
		, umdc1.active
		, umdc1.created
		, umdc1.okToShow
		, umdc1.hasRead
		, umdc1.recipientUserID
		, umdc1.recipientUserGroup
		, umdc1.recipientUserRank
		, umdc1.recipientName
		, umdc1.recipientEmail

    , recipientUserName
    , promptUserToGotoURL
    , gotoURL
    , gotoURLAdditionalParams

		, recipientsJSON  = ''
        , umdc1.respPromptOptionsBitwise
        , umdc1.respPromptOptionsJSON
		, umdc1.systemGenerated
		, umdc1.allowReply
		, umdc1.sendEmail
		, umdc1.emailSent

    , umdc1.senderClientName 
   ,  umdc1.senderClientID

   , umdc1.recipientClientName 
   , umdc1.recipientClientID


   , umdc1.senderEmail

   , umdc1.recipIsPcalStaff

	from dbo.USER_MESSAGES_DATA_CORE (@appName,null,@userID,@okToShow,@hasRead,@sendEmail,@emailSent,@active,@recID) as umdc1

	where (
			(1=1)
		and (isnull(@viewSentOnly, 0) = 0)
	)
)
,
sent_cte as (
	select
		  id              = max(umdc2.id)
		, subject         = max(umdc2.subject)
		, body            = max(umdc2.body)
		, senderUserID    = max(umdc2.senderUserID)
		, senderName      = max(umdc2.senderName)
		, active          = ''
		, created         = min(umdc2.created)
		, okToShow           = ''
		, hasRead            = ''
		, recipientUserID    = ''
		, recipientUserGroup = ''
		, recipientUserRank  = ''
		, recipientName      = ''
		, recipientEmail     = ''

    , recipientUserName = ''
    , promptUserToGotoURL = ''
    , '' gotoURL
    , '' gotoURLAdditionalParams

	    , recipientsJSON  = (
								select id = max(umdc3.recipientUserID)
									 , name = max(umdc3.recipientName)
									 , hasRead = max(Convert(tinyint, umdc3.hasRead))
									 , okToShow = max(Convert(tinyint, umdc3.okToShow))
								from dbo.USER_MESSAGES_DATA_CORE (@appName,@userID,null,null,null,null,null,null,umdc2.id) as umdc3
								group by umdc3.recipientUserID
								for json auto
							)
              -- NOTE: I've legit never seen this syntax before.
              --       Didn't know you could put an entire subquery inside of the column
              --       definitions before you even get to the FROM clause.

	    , respPromptOptionsBitwise = null
        , respPromptOptionsJSON = null
	    , systemGenerated = ''
		, allowReply      = ''
		, sendEmail       = ''
		, emailSent       = ''

    ,  null null1
    ,  null null2
    ,  null null3
    ,  null null4
    ,  null null5

    , null null6


	from dbo.USER_MESSAGES_DATA_CORE (@appName,@userID,null,@okToShow,@hasRead,null,null,@active,@recID) as umdc2

	where (
			(1=1)
		and (@viewSentOnly = 1)
	)
	group by
	  umdc2.id
)
,
cte_combine
as
(

      select t1.* from received_cte as t1
union select t2.* from sent_cte     as t2
                        -- TODO: not sure why we're UNIONing these two subsqueries,
                        --       where the second one is mostly filled in with blank,
                        --       placeholder values.  Consider significantly simplifying this
                        --       if we ever do a deep refactor here
)

select
  cc.*
, createdStr = FORMAT(cc.created, 'MM/dd/yyyy hh:mm tt')
from cte_combine as cc




)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[USER_MESSAGES_VIEW_CORE] TO [webuser]
GO
