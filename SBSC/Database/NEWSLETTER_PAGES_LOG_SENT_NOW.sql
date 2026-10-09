USE [spedmon]
GO


DROP PROCEDURE if exists [dbo].[MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_LOG_SENT_NOW]
GO


DROP PROCEDURE if exists [dbo].[NEWSLETTER_PAGES_LOG_SENT_NOW]
GO



CREATE PROCEDURE [dbo].[NEWSLETTER_PAGES_LOG_SENT_NOW] (
    @userID          BIGINT
  , @userGroup       INT    
  , @userRank        INT

  , @appName         varchar(50)

  , @validateRec     bit
  , @saveType        int

  , @recID           bigint
  , @emailAddy       varchar(100)

  , @clientID        bigint
  , @contactID       bigint
  , @recipUserID          bigint

  , @revisionNum     bigint

  , @taskComplete    bit  -- end of the loop; this is the last email address to be emailed

  , @editDelReason   VARCHAR(7000)
  , @msgNoRec        VARCHAR(1000)
  , @msgNoEdit       VARCHAR(1000)

  , @msgNotActive    VARCHAR(1000)
  , @msgDupRec       VARCHAR(1000)
  , @msgDataError    VARCHAR(1000)

  , @spDetails       VARCHAR(8000) OUTPUT
  , @recordID        BIGINT        OUTPUT
)  
AS    
BEGIN
  
  set @spDetails = ''      -- middleware will crash if this return param is left null.  Now you know!
  set @recordID  = @recID  -- ditto

  declare @tranOpen     as bit           = 0

  declare @errorstr     as varchar(max)  = ''
  
  BEGIN TRY

    BEGIN TRANSACTION
    
	  set @tranOpen = 1
	  
	  INSERT INTO [dbo].[NewsletterPageMessagesSentLog]
            ( [pageID], [clientID], [contactID], [userID], [emailAddy], [revisionNum], [sentAt])

           SELECT
            @recID, @clientID, @contactID, @recipUserID, @emailAddy, @revisionNum, GETDATE()

      --INSERT INTO dbo.AppManPagesResetAndRepublished
      --SELECT @recordID, @jsonvcharmax, GETDATE(), @userID


    COMMIT TRANSACTION
    
	set @tranOpen = 0
    --return (0)
  
  END TRY
  BEGIN CATCH

    if (@tranOpen = 1) 
    begin  
      rollback transaction
    end

    DECLARE @ErrorMessage  AS NVARCHAR(4000)    
    DECLARE @ErrorSeverity AS INT    
    DECLARE @ErrorState    AS INT    
     
    SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
            @ErrorSeverity = ERROR_SEVERITY(),    
            @ErrorState    = ERROR_STATE()    

    SET @errorstr += ' - Ooops; ' + ERROR_MESSAGE() + ' ' + ERROR_PROCEDURE() + ' line ' + CAST(ERROR_LINE() AS VARCHAR)

    --SET @spDetails = @errorstr  -- This should output the error to the browser.  Comment on production, uncomment on dev for diagnostics as needed.

    RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState);

  END CATCH

  if ( @taskComplete = 0 ) -- this is not the last email of the email batch
    return (0)

  BEGIN TRY

    BEGIN TRANSACTION
    
	  set @tranOpen = 1
	  
          -- find existing timestamps (if any) and append in JSON array

          declare @existingStrDatesSent varchar(99), @newStrDatesSent varchar(99), @hasExistingDatetimes bit = 0;

          SELECT @existingStrDatesSent = JSONdatetimesSentOn
          FROM   [dbo].[NewsletterPages]
          WHERE id = @recID

          BEGIN TRY

             IF (
              ( SELECT COUNT(*) FROM OPENJSON( @existingStrDatesSent )
                WHERE LEN( value ) > 0  -- not null, not empty string
              ) >  0
             )
             BEGIN

              SET @hasExistingDatetimes = 1
            
              SET @newStrDatesSent
                =  REPLACE(
                     @existingStrDatesSent  ,
                     ']'                    ,
                     ', "' + CAST( GETDATE() as varchar(max) ) + '"]'
                   )

             END

          END TRY
          BEGIN CATCH

            SET @hasExistingDatetimes = 0

          END CATCH


           IF (  @hasExistingDatetimes = 0  )
             SET @newStrDatesSent = '["' + CAST( GETDATE() as varchar(max) ) + '"]'

           UPDATE  [dbo].[NewsletterPages]
             SET
                 [sentToAll]            =  1  ,
                 [mustResend]           =  0  ,
                 [JSONdatetimesSentOn]  =  @newStrDatesSent
             WHERE id = @recID


    COMMIT TRANSACTION
    
	set @tranOpen = 0

    return (0)
  
  END TRY
  BEGIN CATCH

    if (@tranOpen = 1) 
    begin  
      rollback transaction
    end
     
    SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
            @ErrorSeverity = ERROR_SEVERITY(),    
            @ErrorState    = ERROR_STATE()    

    SET @errorstr += ' - Ooops; ' + ERROR_MESSAGE() + ' ' + ERROR_PROCEDURE() + ' line ' + CAST(ERROR_LINE() AS VARCHAR)

    --SET @spDetails = @errorstr  -- This should output the error to the browser.  Comment on production, uncomment on dev for diagnostics as needed.

    RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState);

  END CATCH


  
END
GO

grant execute on [dbo].[NEWSLETTER_PAGES_LOG_SENT_NOW] to webuser
GO
