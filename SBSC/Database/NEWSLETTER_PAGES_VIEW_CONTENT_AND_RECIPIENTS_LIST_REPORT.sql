USE spedmon
GO



/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT](
    @userID              BIGINT
  , @userGroup           INT
  , @userRank            INT
  , @appName             varchar(50)

  , @term               varchar(256)
  , @pageID               bigint
    -- filter the downloadable report for a specific newsletter

  , @clientID            bigint
)

RETURNS @ReturnTable TABLE(

  --rowOrder bigint,
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

  currRevisionNum          bigint       ,

  mmc_cliID                bigint       ,

  mm_ur_ccr_contactRoleID  nvarchar(270) ,
  mm_ur_ccr_userRoleID	   nvarchar(270) ,

  v_cliID	           bigint   ,
  notifiedByEmailFirstTime datetime ,
  notifiedByEmailLastTime  datetime ,
  notifiedByEmailNumTimes  bigint   ,

  sentRevisionNum          bigint   ,
    -- improve the readability of the report; the version sent may not equal the current version

  userNotifiedByEmail      bit      ,

  contactName              nvarchar(270) ,
  contactRoleName          nvarchar(270) ,
  email                    nvarchar(270) ,

  contactRoleID            bigint       ,
  contactID                bigint       ,
  recipUserID              bigint       ,
  recipientClientID        bigint       ,
  len_Email                bigint       ,
  emailQuit                bit          --,

  --is_last_iter_per_batch   bit

)

AS BEGIN


  INSERT INTO  @ReturnTable

  SELECT * FROM

  ( select



  *
  ,
  LEN( "email" )                                         "len_Email"
  ,

  CASE WHEN "email" LIKE N'@QUIT@%' then 1 else 0 end    "emailQuit"


  from [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST](

     @userID
   , @userGroup
   , @userRank
   , @appName

   , null -- @sendEmailSelected

   , @clientID

   , 1  -- @querySentLogPerEmailAddy
        -- TODO: query the sent-log, per email address, in a later version;
        --       the idea is that we must not send multiple-repeat copies of the same to the same email address,
        --       if we fail to complete, and then resume, a bulk email batch

   , 0  --  @exclEmailRecipsAlreadyInSentLog

   , 0  --  @exclPastRevisions

   , null  /*  @togglReadyToSend  */
   , null  /*   @mustSendOrResend */
   , null  /* @startdateReadyOrBlank  */

   , @term
   , @pageID
  )

  ) s1

  where

    (
      ( "len_Email" != 0  ) AND ( "emailQuit" = 0 )

    )

  ORDER BY
          id DESC,
          sentRevisionNum DESC,
          v_cliID_neverZero ASC,
          email   ASC

   return

end
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT] TO [webuser]
GO
