USE SPEDMON
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_LaunchAutoMatch') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_LaunchAutoMatch
GO

CREATE PROCEDURE [dbo].[RMTS_LaunchAutoMatch] (
    @userID        BIGINT    
  , @userGroup     INT    
  , @userRank      INT

  , @clientID      INT
  , @quarterID     int

  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @saveType      INT  
  , @recID         BIGINT    
  , @msgDupRec          VARCHAR(1000)    

  , @MsgNoRec           VARCHAR(1000)     
  , @MsgNoEdit          VARCHAR(1000)     
  , @MsgDataError       VARCHAR(1000)    

  , @MsgNotActive       VARCHAR(1000)

  , @spDetails          VARCHAR(8000) OUTPUT
  , @recordID           BIGINT        OUTPUT)    
AS    
BEGIN     
     
SET NOCOUNT ON    

declare @today             as datetime
set @today                     = getdate()
set @spDetails                 = ''
set @recordID                  = 0

declare @quarterStartDate date;
declare @quarterEndDate   date;

declare @TranOpen bit = 0


--IF (@clientID   IS NULL) RAISERROR ('clientID is required',   11, 1)
--IF (@quarterID   IS NULL) RAISERROR ('FY quarter is required',   11, 1)

BEGIN TRY

BEGIN TRANSACTION

SET @TranOpen = 1;

select @recordID = @clientID

declare @relevant_clients as table (
     IDX        bigint identity(1,1)
   , clientID  bigint
)
  --delete from @relevant_clients
  INSERT INTO @relevant_clients
  SELECT distinct 
    [clientID]
  from [dbo].[RMTS_Moments_Data_Imports]
  WHERE (
   (1=1)
   and ((@clientID is null) or ([clientID] = @clientID))
  )

  declare @relevant_quarters as table (
     IDX        bigint identity(1,1)
   , quarterID  bigint
)
  --delete from @relevant_quarters
  INSERT INTO @relevant_quarters
  SELECT 
    quarterID = t1.id 
  from [dbo].[COMPANY_FISCAL_QUARTERS] as t1
  WHERE ( 
        (1=1)
    and ((@quarterID is null) or (t1.id = @quarterID))
  )

  --declare @relevant_client bigint

  --declare @minIdx_i    as int = 1
  declare @maxIdx_i    as bigint
  SELECT @maxIdx_i=MAX(IDX) FROM @relevant_clients
  declare @curIdx_i    as bigint -- = 1
  SELECT @curIdx_i=MIN(IDX) FROM @relevant_clients

  declare @relevant_client bigint

  while (@curIdx_i <= @maxIdx_i)
  begin

  declare @relevant_quarter bigint

  SELECT
    @relevant_client=clientID
  FROM @relevant_clients
  where IDX = @curIdx_i

 --declare @minIdx_j    as int = 1
  declare @maxIdx_j    as bigint
  SELECT @maxIdx_j=MAX(IDX) FROM @relevant_quarters
  declare @curIdx_j    as bigint = 1
  SELECT @curIdx_j=MIN(IDX) FROM @relevant_quarters

  while (@curIdx_j <= @maxIdx_j)
  begin

--if (@quarterID > 0)
--begin
  SELECT
    @quarterStartDate=QTR_START,
    @quarterEndDate=QTR_END,
    @relevant_quarter = f_q.ID -- quarterID
  FROM @relevant_quarters r_q
  JOIN [dbo].[COMPANY_FISCAL_QUARTERS] f_q ON f_q.ID = r_q.quarterID
  AND r_q.IDX = @curIdx_j
--end

  set @curIdx_j = @curIdx_j + 1

  exec [dbo].[RMTS_SERVICE_RECORD_AUTOMATCH_HEURISTIC] @relevant_client, @relevant_quarter, null, null

  end -- while (@curIdx_j <= @maxIdx_j)

  set @curIdx_i = @curIdx_i + 1

  end -- while (@curIdx_i <= @maxIdx_i)

IF (@TranOpen  = 1) COMMIT TRANSACTION 


/*-------------------------------    
 * And we are done
 *------------------------------*/  

SET @TranOpen = 0    
RETURN(0)    

END TRY    

/*-------------------------------    
 * If we end up here something    
 * went wrong
 *------------------------------*/    

BEGIN CATCH    
  
  -- Error or raise error with severity 11 to 19 will be caught here    
    
  /*-------------------------------    
   * Cancel any pending    
   * transactions  
   *------------------------------*/    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    

  drop table if exists ##RMTS_Moment_Req

  /*-------------------------------    
   * Identify error
   *------------------------------*/    
  
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage 
      
 /*-------------------------------    
   * Return the error message to
   * the caller. 
   *------------------------------*/    
 
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    

END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[RMTS_LaunchAutoMatch] TO [webuser]
GO