USE [spedmon]
GO

DROP PROCEDURE if exists [dbo].[CLAIM_Denied_Resubmit_Disposition_Save]
GO

CREATE PROCEDURE [dbo].[CLAIM_Denied_Resubmit_Disposition_Save]    
 (
  @userID          BIGINT,    
  @userGroup       INT,    
  @userRank        INT,            /* TODO: userGroup and userRank aren't being used in this SPROC.  I think we have to accept these params because the middleware
                                      usually or always passes them in?  */
  @recID           int, -- NOT USED
  @claimIDs        varchar(8000),
  @flaggedForResubmit bit,
  @flaggedDismissed bit,
  @saveType        INT,
  @editDelReason   VARCHAR(7000),  /* TODO: This is usually passed in by middleware into save SPROCs.  It's not actually being used right now in here */
  @msgNoRec   VARCHAR(100),
  @msgDupRec       VARCHAR(1000), /* TODO: the middleware passes this arg into save sprocs but we're not implementing any dup-checking here */
  @msgNotActive    VARCHAR(1000), /* TODO: the middleware passes this arg into save sprocs but we haven't implemented an "active" flag for this type yet */
  @msgNoEdit       VARCHAR(1000), /* TODO: the middleware passes this arg into save sprocs but we haven't implemented editable/non-editable permissions on this record type, yet */
  @msgDataError    VARCHAR(1000), /* TODO: the middleware passes this arg into save sprocs but we done anything with it, yet */
  @validateRec     bit, /* TODO: the middleware passes this arg into save sprocs but we're not implementing any save validation here */
  @spDetails       VARCHAR(8000) OUTPUT,
  @recordID        BIGINT OUTPUT
)  
AS    
BEGIN

  declare @errorstr varchar(max)  = ''

  declare @timestamp_now        as datetime = GETDATE()
  declare @denialResubDispRecID as bigint = null
  declare @tranOpen             as BIT    = 0        -- Is a transaction open    
  
  set @spDetails = ''  -- middleware will crash if this return param is left null.  Now you know!
  set @recordID = 0

  declare @recIDsTbl  as table (
    idx [int] IDENTITY(1,1) NOT NULL,
    id bigint
  )

  LINENO 35

  BEGIN TRY


    insert into @recIDsTbl
    select recid as id from dbo.MULTI_RECORD_ID_PARSE (@claimIDs,',')

    declare @iter_i   int = 1;
    declare @iter_max int;
    declare @claimID bigint
    declare @clientID bigint;
    
	SELECT 
	    @iter_i   = min(idx)
	  , @iter_max = max(idx)
	FROM @recIDsTbl

   BEGIN TRANSACTION
    set @tranOpen = 1
    while (@iter_i <= @iter_max)
    BEGIN

	  set @denialResubDispRecID = null
      set @claimID              = null
	  set @clientID             = null

      select top 1 @claimID = id from @recIDsTbl where (idx = @iter_i)
      select top 1 @clientID = cc.CLIENT_ID from dbo.CLAIM_Claim as cc where (cc.CLAIM_ID = @claimID)
	  if (@clientID is null) 
	  begin
	    RAISERROR ('Invalid claim data', 11, 1)    
	  end

	  select top 1 @denialResubDispRecID = t1.id from dbo.CLAIM_Denied_Resubmit_Disposition as t1
	  where (
	        (t1.CLIENT_ID = @clientID)
	    and (t1.CLAIM_ID  = @claimID)
      )

	IF (@denialResubDispRecID is null)

    BEGIN

       INSERT INTO [dbo].CLAIM_Denied_Resubmit_Disposition
       (  
	        [CLAIM_ID],
            [CLIENT_ID],
            [FLAGGED_FOR_RESUBMIT],
            [FLAGGED_DISMISSED],
		    [CREATED],
            [CREATED_BY]
        )    
        VALUES    
        (  
            @claimID,
            @clientID,
            @flaggedForResubmit,
            @flaggedDismissed,
		    @timestamp_now,
		    @userID
        )

        SET @recordID = scope_identity()
      
      END

	  ELSE
      BEGIN


        UPDATE [dbo].CLAIM_Denied_Resubmit_Disposition
        SET  
	      [FLAGGED_FOR_RESUBMIT] = @flaggedForResubmit,
          [FLAGGED_DISMISSED]    = @flaggedDismissed,
          [LAST_MODIFIED]        = @timestamp_now,
          [LAST_MODIFIED_BY]     = @userID
        WHERE (ID = @denialResubDispRecID)

        SET @recordID = 1


      END
      
	  SET @iter_i = @iter_i + 1
   
  END
     
  COMMIT TRANSACTION
  set @tranOpen = 0

  RETURN (0)

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

grant execute on [CLAIM_Denied_Resubmit_Disposition_Save] to webuser
GO
