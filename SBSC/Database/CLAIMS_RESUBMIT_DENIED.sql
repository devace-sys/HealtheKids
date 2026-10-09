USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_RESUBMIT_DENIED') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIMS_RESUBMIT_DENIED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLAIMS_RESUBMIT_DENIED] (
    @clientID       bigint = null
  , @useOrLose      bit    = 1
  , @ignoreClaimAge bit    = 0
  , @validate       bit    = 1
)
AS    
BEGIN     
    
/***************************************************************************    
 * CLAIMS_RESUBMIT_DENIED */    
/**    
 * Resubmits
 * 
 * @param   validate        0 = Save mode
 *                          1 = Validation mode
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
declare @tranOpen  as bit = 0
declare @today     as datetime
declare @oldestDOS as datetime
declare @minIdx    as bigint
declare @maxIdx    as bigint
declare @curIdx    as bigint 
declare @claimID   as bigint
declare @cid       as bigint
declare @msg       as varchar(255)

declare @clients as table (
     IDX       bigint identity(1,1)
   , CLIENT_ID bigint
)

declare @claims as table (
     IDX       bigint identity(1,1)
   , CLIENT_ID bigint
   , CLAIM_ID  bigint
)


BEGIN TRY    

RAISERROR ('Resubmitting denied claims', 0, 1) WITH NOWAIT

set @tranOpen   = 0
set @today      = getdate()
set @oldestDOS  = convert(date,dbo.CALC_OLDEST_DOS_ALLOWED(convert(date,@today)))

if (@validate = 0) 
begin
  RAISERROR ('**** Live mode.  Changes will be committed.****', 0, 1) WITH NOWAIT
end
else
begin
  RAISERROR ('Validation mode.  Changes will be rolled back.', 0, 1) WITH NOWAIT
end

RAISERROR ('Loading claims', 0, 1) WITH NOWAIT

insert into @claims

select distinct 
   CLIENT_ID
 , CLAIM_ID
from dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_BASE_DATA_VIEW_CORE ( @clientID , @oldestDOS , @today, @useOrLose) 
where (
      (CLASS_PAT_UNKNOWN  = 0) 
   or (CLASS_PAT_NOT_ELIG = 0)
)
  
insert into @clients
select distinct CLIENT_ID from @claims
order by CLIENT_ID

set @maxIdx = 0

select @minIdx = min(idx) from @claims
select @maxIdx = max(idx) from @claims
select @curIdx = @minIdx

set @msg = 'Claims to resubmit : ' + convert(varchar(50),@maxIdx)
RAISERROR (@msg, 0, 1) WITH NOWAIT

if (@maxIdx != 0)
begin


RAISERROR ('Resubmitting claims', 0, 1) WITH NOWAIT

begin transaction   

set @tranOpen = 1  

while (@curIdx <= @maxIdx)
begin
  select top 1 @claimID = CLAIM_ID from @claims where IDX = @curIdx
  set @msg = 'Resubmitting ' + convert(varchar(50), @curIdx) + ' of ' + convert(varchar(50),@maxIdx) + ' : ' + convert(varchar(50),@claimID)
  RAISERROR (@msg, 0, 1) WITH NOWAIT
  exec dbo.CLAIM_RESUBMIT_DENIED_CORE  @claimID, @ignoreClaimAge
  set @curIdx = @curIdx + 1
end

if (@validate = 0)
begin
  commit transaction
end
else 
begin
  rollback transaction
end

set @tranOpen = 0
RAISERROR ('Resubmission complete', 0, 1) WITH NOWAIT

RAISERROR ('Clients that need to be transmitted', 0, 1) WITH NOWAIT

select @minIdx = min(idx) from @clients
select @maxIdx = max(idx) from @clients
select @curIdx = @minIdx

while (@curIdx <= @maxIdx)
begin  
  select top 1 @cid = CLIENT_ID from @clients where IDX = @curIdx  
  set @msg = ', ' + convert(varchar(50),@cid)  
  RAISERROR (@msg, 0, 1) WITH NOWAIT
  set @curIdx = @curIdx + 1
end

end

RAISERROR ('Done', 0, 1) WITH NOWAIT

RETURN(0)    
END TRY    
BEGIN CATCH    
    
  if (@tranOpen = 1) rollback transaction

  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CLAIMS_RESUBMIT_DENIED] TO [webuser]
GO
