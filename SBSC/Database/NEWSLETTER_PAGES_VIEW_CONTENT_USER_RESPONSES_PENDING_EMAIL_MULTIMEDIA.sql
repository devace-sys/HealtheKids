USE spedmon
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NEWSLETTER_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.NEWSLETTER_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA](
    @userID              BIGINT
  , @userGroup           INT
  , @userRank            INT

  , @pageID               BIGINT

  , @appName             varchar(50)

  , @clientID            bigint
)

RETURNS @ReturnTable TABLE(

  rowOrder bigint,
  -- TODO: consider renaming this col


  id	     bigint,
  appName  varchar(60),
  startDate	 datetime ,
  endDate	   datetime ,
  title     nvarchar(2000),
  content   nvarchar(max),
  created   datetime ,
  createdBy	bigint   ,
  lastModified   datetime ,
  lastModifiedBy bigint   ,
  active         bit      ,
  JSONdatetimesSentOn  nvarchar(270),
  readyToSend    bit ,
  sentToAll	     bit ,
  mustResend     bit ,
  revisionNum    bigint ,

  isResourceLibraryTopic  bit            ,
  [tags]                  varchar(512)  ,
  [tooltip]               varchar(1000)  ,

  sendEmailSelected        bit ,

  startdate_as_date   date ,
  len_JsonDatetimesSentOn  bigint,

  startDateStr             nvarchar(270) ,
  endDateStr               nvarchar(270) ,
  readyToSendStr           varchar(3),
  sentToAllStr             varchar(3),

  forClientIdValsStr       nvarchar(270) ,
  forClientNamesStr        nvarchar(270) ,
  forContactRoleIdValsStr  nvarchar(270) ,
  forContactRoleNamesStr   nvarchar(270) ,
  forUserRoleIdValsStr     nvarchar(270) ,
  forUserRoleNamesStr      nvarchar(270) ,

  mmc_cliID                bigint       ,

  currRevisionNum          bigint       ,

  mm_ur_ccr_contactRoleID  nvarchar(270) ,
  mm_ur_ccr_userRoleID	   nvarchar(270) ,

  v_cliID	           bigint   ,
  notifiedByEmailFirstTime datetime ,
  notifiedByEmailLastTime  datetime ,
  notifiedByEmailNumTimes  bigint   ,

  sentRevisionNum          bigint   ,

  userNotifiedByEmail      bit      ,

  contactName              nvarchar(270) ,
  contactRoleName          nvarchar(270) ,
  email                    nvarchar(270) ,

  contactRoleID            bigint       ,
  contactID                bigint       ,
  recipUserID              bigint       ,
  recipientClientID        bigint       ,
  len_Email                bigint       ,
  emailQuit                bit          ,

  is_last_iter_per_batch   bit
)
AS BEGIN


  INSERT INTO  @ReturnTable

  SELECT * FROM

  ( select

  --distinct

   rowOrder = dense_rank ( ) over (
    partition by
      id

    order by
      email
    )

  ,

  *
  ,
  LEN( "email" )                                         "len_Email"
  ,

  CASE WHEN "email" LIKE N'@QUIT@%' then 1 else 0 end    "emailQuit"

  ,

  0  is_last_iter_per_batch

  from [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST](

     @userID
   , @userGroup
   , @userRank
   , @appName

   , 1 -- @sendEmailSelected

   , @clientID

   , 0  -- @querySentLogPerEmailAddy
        -- TODO: query the sent-log, per email address, in a later version;
        --       the idea is that we must not send multiple-repeat copies of the same to the same email address,
        --       if we fail to complete, and then resume, a bulk email batch

        -- TODO: we still haven't handled this edge case, being able to resume a bulk send if we fail halfway

   , 1  --  @exclEmailRecipsAlreadyInSentLog

   , 1  --  @exclPastRevisions

   , 1  /*  @togglReadyToSend  */
   , 1  /*   @mustSendOrResend */
   , 1  /* @startdateReadyOrBlank  */

   , null  -- search term
   , @pageID
  )

  ) s1

  where

    (
      ( "len_Email" != 0  ) AND ( "emailQuit" = 0 )

    )

  ORDER BY
          id ASC


   ; with num_email_recips_per_batch as (
       SELECT
         MAX( rowOrder ) max_i,
         id              msg_id
       FROM @ReturnTable
       GROUP BY id
   )
   UPDATE  r_t
     SET r_t.is_last_iter_per_batch
         = 1
   FROM  @ReturnTable r_t
   JOIN  num_email_recips_per_batch n_e
     ON  n_e.msg_id = r_t.id
         AND
         n_e.max_i  = r_t.rowOrder

   return

end
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA] TO [webuser]
GO
