USE spedmon
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_DATA_CORE
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NEWSLETTER_PAGES_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.NEWSLETTER_PAGES_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[NEWSLETTER_PAGES_DATA_CORE] (
   @appName        varchar(50)



 , @active              bit

 , @sendEmailSelected   bit

 , @includeContent bit

 , @togglReadyToSend   bit
   -- TODO: the existing bit column underlying readyToSend should be renamed as readyToPublish or isPublished


 , @mustSendOrResend   bit
 , @startdateReadyOrBlank  bit

 , @term               varchar(256)

 , @recID              bigint
)

RETURNS TABLE
AS
RETURN
(


  select
   * from (
   select 
       [id]
      ,[appName]
      ,[startDate]
      ,[endDate]
      ,[title]

      , CASE WHEN @includeContent = 1 THEN [content] ELSE null END content


      ,[created]
      ,[createdBy]
      ,[lastModified]
      ,[lastModifiedBy]
      ,[active]
      ,[JSONdatetimesSentOn]
      ,[readyToSend]
      ,[sentToAll]
      ,[mustResend]
      ,[revisionNum]

      , isResourceLibraryTopic
      , [tags]
      , [tooltip]
      , [sendEmailSelected]
   ,
   CAST(startDate AS DATE)                                "startdate_as_date"
   ,
   LEN ( JSONdatetimesSentOn )                            "len_JsonDatetimesSentOn"

   from dbo.NewsletterPages  as mp

  )  mp

  where
          (mp.appName = @appName)

      
      and ((@active      is null) or (mp.active      = @active     ))

      and ((@togglReadyToSend is null) or (mp.readyToSend = @togglReadyToSend))

      -- TODO: the existing bit column underlying readyToSend should be renamed as readyToPublish or isPublished

      and (
        @mustSendOrResend  IS NULL
        OR
        (
          @mustSendOrResend = 1 AND
          (
            len_JsonDatetimesSentOn <= 2  OR  mustResend = 1

            -- TODO: idk why we're checking the sent timestamps instead
            -- of the sentToAll bit field;
            -- we'll figure this out later

          )
        )
        OR
        (
          @mustSendOrResend = 0 AND
          (
            len_JsonDatetimesSentOn > 2  AND  mustResend = 0

            -- TODO: idk why we're checking the sent timestamps instead
            -- of the sentToAll bit field;
            -- we'll figure this out later

            -- TODO: we never did figure this out, oh well
          )
        )
      )

      and (
        @startdateReadyOrBlank IS NULL
        OR
        ( @startdateReadyOrBlank = 1
          AND (
           "startdate_as_date" <= CAST(GETDATE() AS DATE)
           OR  startDate IS NULL
         )
        )
        OR
        ( @startdateReadyOrBlank = 0
          AND (
           "startdate_as_date" > CAST(GETDATE() AS DATE)
          )
        )
      )


	  and (    (@term is null)             
	        or (dbo.IS_TERM_IN_TAGS(@term,mp.tags,1) = 1)
	  )

    and (
      ( @sendEmailSelected = sendEmailSelected ) OR ( @sendEmailSelected IS NULL )
    )

    and ((@recID       is null) or (mp.id          = @recID      ))
 
)
GO


GRANT SELECT ON  dbo.[NEWSLETTER_PAGES_DATA_CORE]  TO [webuser]
GO

