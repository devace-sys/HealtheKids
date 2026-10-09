USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_RESUBMIT_FOR_PATIENTS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIMS_RESUBMIT_FOR_PATIENTS
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[CLAIMS_RESUBMIT_FOR_PATIENTS] ( 
    @clientID            bigint
  , @patIDs              BIGINT_TableType READONLY  -- I don't want to call this SPROC from inside a loop... because my typing fingers are lazy
)

AS    
BEGIN

LINENO 24

declare @today     as datetime
declare @oldestDOS as datetime

declare @minIdx    as bigint
declare @maxIdx    as bigint
declare @curIdx    as bigint
declare @claimID   as bigint = null

set @today      = getdate()

declare @claims as table (
     IDX       bigint identity(1,1)
   , CLAIM_ID  bigint
)

BEGIN TRY
BEGIN TRANSACTION
set @oldestDOS  = convert(date,dbo.CALC_OLDEST_DOS_ALLOWED(convert(date,@today)))

select distinct -- why DISTINCT?  Is there a possibility of dups in this UDF query?  If so, why?
  CLAIM_ID 
from dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_BASE_DATA_VIEW_CORE (@clientID,@oldestDOS,@today,null) as t1
  -- TODO: since we are only getting CLAIM_ID from the UDF, it might be worthwhile to see if the UDF is querying columns it doesn't necessarily need.
  -- Could performance be optimized?  Or could we possibly create a more scaled-down version?  idk
JOIN
@patIDs p
ON t1.PATIENT_ID = p.id

SELECT @minIdx=MIN(IDX) FROM @claims
SELECT @maxIdx=MAX(IDX) FROM @claims
SET @curIdx = @minIdx

while (@curIdx <= @maxIdx)
begin
  select top 1 @claimID = CLAIM_ID from @claims where IDX = @curIdx
  exec dbo.CLAIM_RESUBMIT_DENIED_CORE  @claimID, 0 /* Do not ignore claim age*/
  set @curIdx = @curIdx + 1
end

COMMIT TRANSACTION

END TRY
BEGIN CATCH

  if @@TRANCOUNT > 0 rollback transaction

  -- Error or raise error with severity 11 to 19 will be caught here
      
  DECLARE @ErrorMessage  NVARCHAR(4000) = ERROR_MESSAGE() + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE())
  DECLARE @ErrorSeverity INT = ERROR_SEVERITY()   
  DECLARE @ErrorState    INT = ERROR_STATE()   
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)  -- TODO: SQL Server 2012 introduces the THROW command to re-raise the same exception from the CATCH block.
                                                       -- More readable, and easier to code.  Consider ?
                                                       -- https://stackoverflow.com/a/15627263

END CATCH                                              -- On the other hand, appending the ERROR_PROCEDURE() and ERROR_LINE() in each CATCH block
RETURN (0)                                             -- might make it easier to decipher the call stack.
END                                                    -- Does SQL Server have a better, off-the-shelf way to output the entire call stack when we encounter an error?

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CLAIMS_RESUBMIT_FOR_PATIENTS] TO [webuser]
GO 