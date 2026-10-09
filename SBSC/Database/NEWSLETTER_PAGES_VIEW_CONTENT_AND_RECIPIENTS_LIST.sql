USE spedmon
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST](

     @userID              BIGINT
   , @userGroup           INT
   , @userRank            INT

   , @appName             varchar(50)

   , @sendEmailSelected  bit

   , @clientID           bigint

      -- BUG:
      -- this udf doesn't find the necessary result set, for newsletters sent to All Client Users,
      -- when a particular @clientID (for a particular client) is passed in as a param.
      -- This has never been a problem because the bulk mailer passes in the @clientID as NULL
      -- or 0, instead of the numeric ID for a particular client.

   , @querySentLogPerEmailAddy bit

   , @exclEmailRecipsAlreadyInSentLog bit

   , @exclPastRevisions               bit


   , @togglReadyToSend    bit
     -- NOTE: in this UDF we need to be able to filter out un-ready emails (during the batch task)
     --       but also view the un-ready emails paired w/ email addresses, for when we eventually
     --       have report-out screens for this

   , @mustSendOrResend    bit
     -- ditto
   , @startdateReadyOrBlank bit
     -- ditto


   , @term               varchar(256)
   , @pageID              bigint
)

RETURNS TABLE
AS
RETURN
(

/***************************************************************************
 * NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST */
/**
 * Displays user data
 *
 * @param  clientID        ID of client or null for all clients
 * @param  roleID          user's username or null
 * @param  appName         user's email or null
 * @return                 Table of user data
 ***************************************************************************/

with
cte1_recs_w_cli_and_recip_selections
as
(

  select



    mp.*                                              ,
    mp.revisionNum                          currRevisionNum ,
    mm_c.clientID                           mmc_cliID_neverNull_if_selections_exist       ,
    mm_ur_ccr.contactRoleID   mm_ur_ccr_contactRoleID       ,
    mm_ur_ccr.userRoleID         mm_ur_ccr_userRoleID



  from
  (
    select  -- top 1
    *
    from

      -- VIEW_CORE used here and in _VIEW; no other usages of VIEW_CORE.
      -- this udf _RECIPIENTS_LIST is called from up the call stack for sending out emails
      -- and reporting emails sent

    dbo.NEWSLETTER_PAGES_VIEW_CORE (
         @userID,@userGroup,@userRank,
         @appName, 0 /*@wIncluJoinsFromDropDownSelections */,
         1,

         @sendEmailSelected ,

         0, --@includeContent

        @togglReadyToSend ,
        @mustSendOrResend ,
        @startdateReadyOrBlank ,

        @term ,

        @pageID
       )
  ) as mp

        -- NOTE: pretty sure this would work if we queried the table instead of the VIEW_CORE.
        --       we're basically querying the join tables a second time for no reason


  -- LEFT JOIN
  JOIN
       (
         SELECT
           pageID, contactRoleID, null userRoleID
           FROM dbo.NewsletterPagesForContactRoles  as mm_ccr

         UNION
         -- UNIONs are important, because they perform addition, and not multiplication,
         -- unlike APPLYs and JOINs

             -- that being the case, I almost should have made two separate queries for this.
             -- but that would have been too difficult because as I was building this I didn't know what all columns I would need.
             -- Building out two queries simultaneously would have been impossible.
             -- Good idea for a refactor though.

         SELECT
           pageID, null contactRoleID, userRoleID
           FROM [dbo].[NewsletterPagesForUserRoles]  as mm_ur
       ) mm_ur_ccr

       on mp.id  = mm_ur_ccr.pageID


  left JOIN NewsletterPagesForClients mm_c
  ON   mm_c.pageID = mp.id

  where
      (  @pageID is null              or mp.id  = @pageID )

),
cte2_recs_w_all_relevant_clients as (

  SELECT
    *

  FROM
  cte1_recs_w_cli_and_recip_selections cte1

  LEFT JOIN (
    select
        CLIENT_ID   as v_cliID_neverZero
    --  , CLIENT_NAME as clientName
    from SPEDMON.dbo.CLIENTS_Client as t1
    where (
         (t1.LEA                         = 1)
     and (t1.sendUsersEmailNotifications = 1)

     AND

         ( @clientID  > 0          OR  @clientID  IS NULL)
     -- DO NOT QUERY this table at all if @clientID = 0; @clientID = 0 is a known quantity...

    )
  ) valid_clients
     ON

     ( mmc_cliID_neverNull_if_selections_exist = v_cliID_neverZero     OR  mmc_cliID_neverNull_if_selections_exist  IS NULL)
     -- IF a client is specified from the dropdown, then find only that relevant client;
     -- OTHERWISE find all relevant clients

  WHERE

     ( v_cliID_neverZero IS NOT NULL     OR  @clientID            = 0  )
     -- IF @clientID is not 0, then we MUST find at least one match in the CLIENTS_Client table;
     -- OTHERWISE we must do nothing in the subsequent CTEs

     AND (
       ( mmc_cliID_neverNull_if_selections_exist  IS NULL
                                 )
       OR
       mmc_cliID_neverNull_if_selections_exist  = v_cliID_neverZero

       OR
       @clientID            = 0
       --IF @client is a value > 0, then
       -- either the valid matching client matches the client selected via dropdown...
       -- or there must be none selected on the dropdown
     )

     AND (
       mmc_cliID_neverNull_if_selections_exist =  @clientID  OR  ISNULL(@clientID, 0) = 0
       -- IF @clientID > 0, then the dropdown client MUST match the @clientID
     )

     -- In short:
     --
     --   - @clientID may be NULL, 0, or a value > 0
     --   - mmc_cliID_neverNull_if_selections_exist (the selected clients via dropdown) may be NULL or a value > 0
     --   - v_cliID_neverZero (the clientID validated against the SELECT query with WHERE conditions)
     --     must not be NULL, except when @clientID = 0

     --     Clear as mud?

),
cte3_recs_w_all_valid_recipients as (

  select

    --mp.*
      cte2_recs_w_all_relevant_clients.*

    , NotifiedByEmail.firstTime  as notifiedByEmailFirstTime
    , NotifiedByEmail.lastTime   as notifiedByEmailLastTime
    , NotifiedByEmail.numOfTimes as notifiedByEmailNumTimes

    , NotifiedByEmail.sentRevisionNum

    , userNotifiedByEmail = convert(bit,case when NotifiedByEmail.numOfTimes > 0 then 1 else 0 end)

    , con_u1.contactName
    , con_u1.contactRoleName
    , con_u1.email

    , con_u1.contactRoleID
    , con_u1.contactID
    , con_u1.recipUserID

    , con_u1.recipientClientID
  from

  cte2_recs_w_all_relevant_clients

  -- OUTER APPLY  (
  JOIN (

               select

                 ccv.contactName
               , ccv.contactRoleName
               , ccv.email

               , ccv.contactRoleID
               , ccv.id contactID
               , null recipUserID

               , ccv.clientID recipientClientID

               , null   urv_id
               , null   uav_cliID

               --, null apuru_id

                from

            [dbo].[CLIENT_CONTACTS_VIEW] (  -- NOTE: this UDF doesn't accept NULL clientIDs.
              @userID                       -- regrettably I have to do this as an APPLY rather than a JOIN,
            , @userGroup                    -- because this UDF is intended to query multiple clients
            , @userRank
                                            -- (earlier I was trying to force this outer UDF definition to work with NULL @clientID
                                            --  instead of passing in each clientID, including zero, one at a time)

            , null -- ISNULL( mm_c.clientID, @clientID )

            , 1 -- @active BIT
            , null
            , null
            ) ccv
              WHERE  -- ( ccv.contactRoleID  =  mm_ur_ccr.contactRoleID  OR  mm_ur_ccr.contactRoleID  IS NULL )

                        (  @clientID != 0  OR  @clientID IS NULL )

                        --AND

                        --mm_ur_ccr.contactRoleID  IS NOT NULL
                        -- preemptively skip this entire half of the UNION if not necessary

                        --AND

                        --( ccv.contactRoleID  =  mm_ur_ccr.contactRoleID  AND  mm_ur_ccr.userRoleID  IS NULL )



            UNION


            select

                 ua_v.[name]                   contactName
               , null                          contactRoleName
               , ua_v.email

               ,  null      contactRoleID
               ,  null      contactID  -- cli_con.id contactID
               ,  ua_v.id   recipUserID

               ,  ua_v.clientID recipientClientID

               , ap_ur_u.id          urv_id  -- rename
               , ua_v.clientID   uav_cliID

               --, ap_ur_u.id      apuru_id

            from

              [users].[dbo].[USERS_ALL] ua_v
              -- gets a list of all users in the system


            JOIN users.dbo.Membership mem
              ON   mem.UserId = ua_v."uid"
              AND  mem.IsApproved  = 1
              AND  mem.IsLockedOut = 0

              AND  mem.sendUserEmailNotifications = 1

                   -- these "security" fields aren't visible in USERS_ALL; I have to JOIN just for this

            CROSS APPLY  users.[dbo].[APP_MAN_PAGES_USER_ROLES_FOR_USER_ID_VIEW_CORE](
                @appName
              , ua_v.UserIdInt
            )  ap_ur_u

                -- some actual logic here;
                -- ap_ur_u gets a list of recipient groups for each given user

                -- TODO: I wish I was possible to do this with a JOIN instead of a CROSS APPLY
                --       but regrettably this inner UDF has a lot of procedural logic that makes
                --       the @userID param required.



  ) con_u1
    ON
    (

      (

           mm_ur_ccr_contactRoleID  IS NOT NULL
           -- preemptively skip this entire half of the UNION if not necessary

           AND

           ( @clientID IS NULL   OR   @clientID != 0  )

           AND

           ( ISNULL( recipientClientID, 0) = COALESCE( mmc_cliID_neverNull_if_selections_exist, v_cliID_neverZero, 0 )  )

           AND

           ( con_u1.contactRoleID  =  mm_ur_ccr_contactRoleID  AND  mm_ur_ccr_userRoleID  IS NULL )


      )


      OR


      (

           mm_ur_ccr_userRoleID  IS NOT NULL
           -- preemptively skip this entire half of the UNION if not necessary
           AND  mm_ur_ccr_contactRoleID  IS NULL

           --AND
           --ua_v.appName = @appname

           AND
           (
             urv_id =  mm_ur_ccr_userRoleID

           )

           AND
           (


             (
                 ( @clientID IS NULL OR @clientID != 0)

                 AND

                 ISNULL( mmc_cliID_neverNull_if_selections_exist, v_cliID_neverZero )  = uav_cliID

                 -- the clientID from [users].[dbo].[USERS_ALL] must match the client we are looking for...
                 -- except when @clientID = 0.  Then we can pull rows from [users].[dbo].[USERS_ALL] that don't have a clientID

             )

             OR

             ( @clientID = 0  AND  ISNULL(uav_cliID, 0) = 0)

                    -- I almost think that I should have written two different UDFs, to find reciptents per-client
                    -- and another to find recipents for all clients, client not specified
           )
      )

    )


  left join (

    select --top 1
        pageID    ,
        clientID  ,
        contactID ,
        userID    ,
        MAX(emailAddy) emailAddy , -- expecting 1...
                                   -- ignoring the very-rare edge cases where the contact has changed her email addy
                                   -- since the message was sent, etc.  Undefined behavior
        MIN(sentAt)    firstTime ,
        Max(sentAt)    lastTime  ,
        COUNT( sentlog.id )       numOfTimes,

        /* MAX(revisionNum) */
        revisionNum sentRevisionNum

    from NewsletterPageMessagesSentLog sentlog


    WHERE @querySentLogPerEmailAddy = 1
          OR
          @exclEmailRecipsAlreadyInSentLog = 1

    -- GROUP BY pageID, clientID, contactID, userID
       GROUP BY pageID, clientID, contactID, userID, revisionNum


  ) as NotifiedByEmail
    ON      --( NotifiedByEmail.clientID  = ISNULL( mmc_cliID_neverNull_if_selections_exist, @clientID)    OR  COALESCE(mmc_cliID_neverNull_if_selections_exist, @clientID, 0) = 0 )

       --AND
              NotifiedByEmail.pageID    = id -- mp.id

              AND
                  (
                    NotifiedByEmail.sentRevisionNum    = cte2_recs_w_all_relevant_clients.revisionNum
                    OR
                    @exclPastRevisions  =  0
                  )
       AND  (
                 ISNULL( NotifiedByEmail.clientID, 0)  =  ISNULL( v_cliID_neverZero, 0)
       )

       AND  (    NotifiedByEmail.contactID = con_u1.contactID
                 OR
                 NotifiedByEmail."userID"  = con_u1.recipUserID

                                                   --)
            )

      AND (
            NotifiedByEmail.emailAddy  =  con_u1.email
      )

  WHERE
  (
      ISNULL( @exclEmailRecipsAlreadyInSentLog, 0) = 0
      OR
      ISNULL( NotifiedByEmail.numOfTimes, 0)       = 0

      OR

      cte2_recs_w_all_relevant_clients.mustResend = 1

  )


)
,
cte_last
as
(
  select
     *
  from cte3_recs_w_all_valid_recipients

)

select * from cte_last


)

GO
