USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_RESUBMIT_DENIED_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_RESUBMIT_DENIED_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLAIM_RESUBMIT_DENIED_CORE]  (   
    @claimID        bigint  
  , @ignoreClaimAge bit = 0
)
     
AS    

BEGIN     
    
/***************************************************************************    
 * CLAIM_RESUBMIT_DENIED_CORE */    
/**    
 * Reset a denied claim so it can be resubmitted.
 *
 * NOTE: DO NOT CALL THIS ROUTINE BY ITSELF.  IT MUST BE WRAPPED IN A 
 *       TRANSACTION
 * 
 * @param   claimID         Claim ID
 ***************************************************************************/ 
     
SET NOCOUNT ON    
    
BEGIN TRY

LINENO 40 -- make the RAISERROR & CATCH block echo out a line number that corresponds to the .sql file, not the "batch" in SQL server

declare @claimIDtoResub        as bigint
declare @referenceClaimID1     as bigint
declare @today                 as datetime
declare @oldestDos             as date
declare @status                as char(10)
declare @hasProxy              as bit
declare @isProxy               as bit
declare @serviceDate           as date
declare @numChildClaims        as int
declare @numDeniedChildClaims  as int

RAISERROR ('Loading claim', 0, 1) WITH NOWAIT

/*============================================================
 * Load claim
 *============================================================*/  

set @claimIDtoResub = null

select top 1 
  
    @claimIDtoResub    = cc.CLAIM_ID
  , @referenceClaimID1 = cc.REFERENCE_CLAIM_ID_1
  , @status            = trim(cc.STATUS)
  , @serviceDate       = convert(date,cc.SERVICE_DATE)
  , @hasProxy          = cc.HAS_PROXY
  , @isProxy           = cc.IS_PROXY

from dbo.CLAIM_Claim as cc 
where (cc.CLAIM_ID = @claimID)

/*============================================================
 * Claim is not found, get out
 *============================================================*/  

if (@claimIDtoResub is null) 
begin
  RAISERROR ('Claim not found.', 0, 1) WITH NOWAIT  -- TODO: I'd consider making this a higher severity error.  If we are passing in a non-existent or invalid claim ID,
  return (0)                                        -- I think that is a problem.  Maybe the SPROC that did that shouldn't be allowed to run to completion.  -- JM - 03 23 19
end

/*============================================================
 * Check if claim is on the do not resubmit list
 * Note: If we actually need to resubmit then the claim must
 * be REMOVED from the list.
 *============================================================*/  

if exists (
  select top 1 claim_id from dbo.CLAIMS_LIST_DO_NOT_RESUBMIT as t1 where (t1.claim_id = @claimIDtoResub)
)
begin
  RAISERROR ('Claim is on the do not resubmit list.  Remove from list if we need to resubmit.', 0, 1) WITH NOWAIT  
  return (0)                                      
end

/*============================================================
 * Calc dates
 *============================================================*/  

set @today     = GETDATE()
set @oldestDos = convert(date,dbo.CALC_OLDEST_DOS_ALLOWED(convert(date,@today)))

/*============================================================
 * If we are not ignoring claim age then determine if claim 
 * is too old to resubmit.  If aged out, get out.
 *============================================================*/  

if ((@ignoreClaimAge = 0) and (datediff(day,@oldestDOS,@serviceDate) < 0))
begin
  RAISERROR ('Claim has aged out.', 0, 1) WITH NOWAIT
  return (0)
end

/*============================================================
 * Stand alone claim resubmit
 *============================================================*/  

if ((@hasProxy = 0) and (@isProxy  = 0))
   
begin

  RAISERROR ('Stand alone claim', 0, 1) WITH NOWAIT

  /*-------------------------------
   * Claim is not denied, get out
   *-------------------------------*/  
 
  if (@status != dbo.CONST_CLAIM_STATUS_SUB_REJECT()) 
  begin
    RAISERROR ('This claim is not in a stand alone claim denied state.', 0, 1) WITH NOWAIT
    return (0)
  end
  
  /*-------------------------------
   * Reset claim
   *-------------------------------*/  

  update dbo.CLAIM_CLAIM 
  set 
      STATUS       = dbo.CONST_CLAIM_STATUS_NOT_SUB()
    , LAST_UPDATED = @today
  where (CLAIM_ID = @claimIDtoResub)
  
end

/*============================================================
 * Proxy (Aggregate) parent claim resubmit
 *============================================================*/  

else if ((@hasProxy = 0) and (@isProxy  = 1))
begin

  RAISERROR ('Proxy (aggregate) parent claim', 0, 1) WITH NOWAIT

  /*-------------------------------
   * Parent claim is not denied
   * get out
   *-------------------------------*/  
 
  if (@status != dbo.CONST_CLAIM_STATUS_RECV_PROXY_DENIED()) 
  begin
    RAISERROR ('This claim is not in a proxy claim denied state.', 0, 1) WITH NOWAIT
	return (0)
  end
  
  set @numChildClaims = 0

  select 
    @numChildClaims = count(CLAIM_ID) 
  from dbo.CLAIM_Claim
   where (
         (REFERENCE_CLAIM_ID_1 = @claimIDtoResub) 
	 and (HAS_PROXY = 1) 
	 and (IS_PROXY = 0) 	 
   )


  if (@numChildClaims = 0)
  begin
    RAISERROR ('No child claims.', 0, 1) WITH NOWAIT
	return (0)
  end

  set @numDeniedChildClaims = 0
  
  select 
    @numDeniedChildClaims = count(CLAIM_ID) 
  from dbo.CLAIM_Claim
   where (
         (REFERENCE_CLAIM_ID_1 = @claimIDtoResub) 
	 and (HAS_PROXY = 1) 
	 and (IS_PROXY = 0) 
	 and (STATUS = dbo.CONST_CLAIM_STATUS_SUB_REJECT())
   )
  
  if (@numChildClaims != @numDeniedChildClaims)
  begin
    RAISERROR ('Number of denied child claims does not match number of child claims.', 0, 1) WITH NOWAIT
	return (0)
  end

  /*-------------------------------
   * Reset child claims
   *-------------------------------*/  
  
  update dbo.CLAIM_Claim
  set
      STATUS       = dbo.CONST_CLAIM_STATUS_CHILD_OF_SENT_PROXY()
    , LAST_UPDATED = @today
  where ((REFERENCE_CLAIM_ID_1 = @claimIDtoResub) and (HAS_PROXY = 1) and (IS_PROXY = 0))
  
  /*-------------------------------
   * Reset parent claims
   *-------------------------------*/  

  update dbo.CLAIM_CLAIM 
  set 
      STATUS       = dbo.CONST_CLAIM_STATUS_NOT_SUB()
    , LAST_UPDATED = @today
  where (CLAIM_ID = @claimIDtoResub)
  
end

/*============================================================
 * Proxy (Aggregate) child claim resubmit
 *============================================================*/  

else if ((@hasProxy = 1) and (@isProxy = 0))
begin
 
 RAISERROR ('Proxy (aggregate) child claim', 0, 1) WITH NOWAIT
 RAISERROR ('Recalling routine to reset parent claim', 0, 1) WITH NOWAIT
 
 /*-------------------------------------------
   * Recall this, recursively, using parent ID
   *-----------------------------------------*/  
 
 exec dbo.CLAIM_RESUBMIT_DENIED_CORE @referenceClaimID1, @ignoreClaimAge 
 return (0)
end

/*============================================================
 * Track denial resubmit data
 *============================================================*/  

 insert into dbo.CLAIM_DENIALS_RESUBMIT_HISTORY (CLAIM_ID, DATE_RESET, REASON)
 values (@claimIDtoResub, @today, null)
 
/*============================================================
 * Done
 *============================================================*/  

RAISERROR ('Done', 0, 1) WITH NOWAIT
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
 
GRANT EXECUTE ON  [dbo].[CLAIM_RESUBMIT_DENIED_CORE] TO [webuser]
GO
