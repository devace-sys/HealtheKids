USE [users]
GO


DROP PROCEDURE if exists [dbo].[APP_MAN_PAGES_RESET_AND_REPUBLISH]
GO

CREATE PROCEDURE [dbo].[APP_MAN_PAGES_RESET_AND_REPUBLISH] (
    @userID          BIGINT
  , @userGroup       INT    
  , @userRank        INT 
  , @appName         varchar(50)
  , @validateRec     bit
  , @recID           bigint
  , @editDelReason   VARCHAR(7000)
  , @msgNoRec        VARCHAR(1000)
  , @msgNoEdit       VARCHAR(1000)
  , @spDetails       VARCHAR(8000) OUTPUT
  , @recordID        BIGINT        OUTPUT
)  
AS    
BEGIN
  
  set @spDetails = ''  -- middleware will crash if this return param is left null.  Now you know!
  set @recordID  = null

  declare @tranOpen     as bit           = 0
  declare @errorstr     as varchar(max)  = ''
  declare @jsonvcharmax as varchar(max)  = '{}'
 

  LINENO 26

  
  BEGIN TRY

    /* Find page and make sure its active */

    select top 1 
	  @recordID = t1.id
	from dbo.AppManPages as t1
	where ( 
	      (t1.id      = @recID) 
	  and (t1.appName = @appName)
	  and (t1.active  = 1)
    )

	/* If we don't find the page or its no longer active, exit */

	if (@recordID is null) 
	begin
	  set @recordID = 0
	  return(0)
	end

    BEGIN TRANSACTION
      
	  set @tranOpen = 1
	  
	  /* Archive any responses */
	    
	  select @jsonvcharmax = (select * from AppManPagesUserResponseLog WHERE pageID=@recordID FOR JSON AUTO)

      INSERT INTO dbo.AppManPagesResetAndRepublished
      SELECT @recordID, @jsonvcharmax, GETDATE(), @userID

      /* Clear out responses */

	  DELETE FROM AppManPagesUserResponseLog WHERE (pageID=@recordID)

    COMMIT TRANSACTION
    
	set @tranOpen = 0
    return (0)
  
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
  
END
GO

grant execute on [dbo].[APP_MAN_PAGES_RESET_AND_REPUBLISH] to webuser
GO
