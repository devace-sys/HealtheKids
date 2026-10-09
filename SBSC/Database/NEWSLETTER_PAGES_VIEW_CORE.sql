USE spedmon
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_VIEW_CORE
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NEWSLETTER_PAGES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.NEWSLETTER_PAGES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[NEWSLETTER_PAGES_VIEW_CORE](

  @userID      BIGINT
 , @userGroup   INT
 , @userRank    INT

 , @appName     varchar(50)

 , @wIncluJoinsFromDropDownSelections bit

 
 , @active      bit

 , @sendEmailSelected bit

 , @includeContent bit

 , @togglReadyToSend       bit
 , @mustSendOrResend       bit
 , @startdateReadyOrBlank  bit

 , @term               varchar(256)

 , @recID                  bigint
)

RETURNS TABLE
AS

RETURN
(


select


   mp.*

 , startDateStr       = dbo.RPT_DATE_FMT  (mp.startDate)
 , endDateStr         = dbo.RPT_DATE_FMT  (mp.endDate)
 , readyToSendStr     = dbo.RPT_BIT_TO_YN(readyToSend)
 , sentToAllStr       = dbo.RPT_BIT_TO_YN(sentToAll)
  , forClientIdValsStr 
  , forClientNamesStr

  , forContactRoleIdValsStr
  , forContactRoleNamesStr


  , forUserRoleIdValsStr
  , forUserRoleNamesStr

     -- just now noticed that, when pre-filling the multi select controller,
     -- numeric IDs are comma separated, and strings are pipe separated.
     -- Fourth time was a charm


from dbo.NEWSLETTER_PAGES_DATA_CORE (

   @appName

 , @active

 , @sendEmailSelected

 , @includeContent

 , @togglReadyToSend
 , @mustSendOrResend
 , @startdateReadyOrBlank

 , @term

 , @recID) as mp


   OUTER APPLY (
    SELECT
      pageID,
      STRING_AGG( CAST ( clientID as varchar(max) ) , ',')  forClientIdValsStr,
      STRING_AGG( CAST ( CLIENT_NAME as varchar(max) ) , '|') forClientNamesStr
    FROM
      (
       SELECT
        top 200000 mmc_inner.* , cc_inner.CLIENT_NAME
        FROM [dbo].[NewsletterPagesForClients] mmc_inner
          JOIN dbo.CLIENTS_Client cc_inner ON cc_inner.CLIENT_ID = mmc_inner.clientID
        WHERE  mmc_inner.pageID = mp.id

               AND

              @wIncluJoinsFromDropDownSelections = 1
        ORDER BY id desc
      ) mm_c
    GROUP BY pageID
   )  mm_c  -- ON  mm_c.pageID = mp.id

   OUTER APPLY (
    SELECT
      pageID,
      STRING_AGG( CAST ( contactRoleID as varchar(max) ) , ',')  forContactRoleIdValsStr,
      STRING_AGG( CAST ( roleName as varchar(max) ) , '|') forContactRoleNamesStr
    FROM
      (
       SELECT
        top 200000 mmcr_inner.* , ccr_inner.[name] roleName
        FROM [dbo].[NewsletterPagesForContactRoles] mmcr_inner
          JOIN [dbo].[CLIENT_CONTACT_ROLES] as ccr_inner ON ccr_inner.id = mmcr_inner.contactRoleID
        WHERE  mmcr_inner.pageID = mp.id

               AND

              @wIncluJoinsFromDropDownSelections = 1

        ORDER BY id desc
      ) mm_cr
    GROUP BY pageID
   )  mm_cr  -- ON  mm_c.pageID = mp.id

   OUTER APPLY (
    SELECT
      pageID,
      STRING_AGG( CAST ( "userRoleID" as varchar(max) ) , ',')  forUserRoleIdValsStr,
      STRING_AGG( CAST ( "roleName" as varchar(max) ) , '|')    forUserRoleNamesStr
    FROM
      (
       SELECT
        top 200000 mmur_inner.* , ur_inner.[name] roleName
        FROM [dbo].[NewsletterPagesForUserRoles] mmur_inner
          JOIN users.[dbo].[APP_MAN_PAGES_USER_ROLES_VIEW_CORE]( @appName ) as ur_inner
          ON ur_inner.id = mmur_inner.userRoleID
        WHERE  mmur_inner.pageID = mp.id

               AND

              @wIncluJoinsFromDropDownSelections = 1

        ORDER BY id desc
      ) mm_ur
    GROUP BY pageID
   )  mm_ur  -- ON  mm_c.pageID = mp.id

)

GO

grant select on NEWSLETTER_PAGES_VIEW_CORE to webuser
GO
