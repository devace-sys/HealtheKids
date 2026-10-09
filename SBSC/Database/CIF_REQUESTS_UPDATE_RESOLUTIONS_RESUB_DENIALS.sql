USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS_RESUB_DENIALS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS_RESUB_DENIALS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CIF_REQUESTS_UPDATE_RESOLUTIONS_RESUB_DENIALS]  
AS    

BEGIN     
    
/***************************************************************************    
 * CIF_REQUESTS_UPDATE_RESOLUTIONS_RESUB_DENIALS */    
/**    
 * 
 ***************************************************************************/         

SET NOCOUNT ON        

BEGIN TRY

declare @baseClaims as table (
    CLAIM_ID             bigint
  , REFERENCE_CLAIM_ID_1 bigint
  , HAS_PROXY            bit
  , IS_PROXY             bit
  , STATUS_VALUE         int
)

declare @claimsToResub as table (
    IDX      int identity(1,1)
  , CLAIM_ID bigint
  unique clustered (IDX)
)

declare @tranCount           as int
declare @today               as datetime
declare @oldestDos           as datetime
declare @curIdx              as int = 0
declare @maxIdx              as int = 0

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Resub Denials - Starting'

set @today     = GETDATE()
set @oldestDos = dbo.CALC_OLDEST_DOS_ALLOWED(convert(date,@today))

/*###################################################################################################*/
/*#                                                                                                 #*/
/*#                                 Get claims to resubmit (if any)                                 #*/
/*#                                                                                                 #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Resub Denials - Finding all claims to resubmit'

insert into @baseClaims (
    CLAIM_ID
  , REFERENCE_CLAIM_ID_1
  , HAS_PROXY
  , IS_PROXY
  , STATUS_VALUE
)
select 
    clm.CLAIM_ID
  , clm.REFERENCE_CLAIM_ID_1
  , clm.HAS_PROXY
  , clm.IS_PROXY
  , STATUS_VALUE = convert(int,clm.STATUS)
from dbo.CIF_REQUESTS          as cr
join dbo.SERVICE_RECORD_CLAIMS as src on src.svcRecID  = cr.replacementSvcRecID
join dbo.CLAIM_Claim           as clm on clm.CLAIM_ID  = src.claimID
where ( 
      (cr.resolved   = 1)
  and (cr.saveTypeID = 2)
  and (cr.replacementSvcRecID is not null)
  and (cr.cifSubmissionRequired = 1)         /* Claims would have to have been paid */
  and (
      (cr.numOfClaimsChanged = 1)
   or (cr.numOfUnitsChanged  = 1)
   or (cr.siblingServiceWasChangedOrDeleted = 1)
  )
  and (clm.SERVICE_DATE >= @oldestDos)
  and (clm.SERVICE_UNITS > 0)
)

/*###################################################################################################*/
/*#                                         Stand Alone                                             #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Resub Denials - Getting claim ids for stand alone claims'

insert into @claimsToResub (
  CLAIM_ID
)

select 
  cb.CLAIM_ID 
from @baseClaims as cb 
where (
      (cb.HAS_PROXY    = 0)
  and (cb.IS_PROXY     = 0)
  and (cb.STATUS_VALUE = dbo.CONST_CLAIM_STATUS_SUB_REJECT())
)

/*###################################################################################################*/
/*#                                         Proxy                                                   #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Resub Denials - Getting claim ids for proxy claims'

insert into @claimsToResub (
  CLAIM_ID
)

select distinct
    CLAIM_ID = cb.REFERENCE_CLAIM_ID_1
from @baseClaims as cb 
where (
      (cb.HAS_PROXY    = 1)
  and (cb.IS_PROXY     = 0)
  and (cb.STATUS_VALUE = dbo.CONST_CLAIM_STATUS_SUB_REJECT())
)

/*###################################################################################################*/
/*#                                         Resubmit                                                #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Resub Denials - Resubmitting claims'

select @curIdx = min(ctr.IDX), @maxIdx = max(ctr.IDX) from @claimsToResub as ctr

while (@curIdx <= @maxIdx)
begin

  exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Resub Denials - Resubmitting claim'

  declare @claimID as bigint = null
  set @tranCount = 0
  
  select top 1 
    @claimID = ctr.CLAIM_ID 
  from @claimsToResub as ctr 
  where 
    (ctr.IDX = @curIdx)
  
  begin try
    begin transaction
	  set @tranCount = 1
      exec dbo.CLAIM_RESUBMIT_DENIED_CORE @claimID,0
    commit transaction
	set @tranCount = 0
  end try
  begin catch
    if (@tranCount = 1)
	begin
      rollback transaction
      set @tranCount = 0
	end
  end catch

  set @curIdx = @curIdx + 1
end

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Resub Denials - Done'

RETURN(0)    
END TRY    
BEGIN CATCH    
    
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
 
GRANT EXECUTE ON  [dbo].[CIF_REQUESTS_UPDATE_RESOLUTIONS_RESUB_DENIALS] TO [webuser]
GO
