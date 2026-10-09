USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PRAC_SALARIES_REACTIVATE_VALID_RECORDS_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CRCS_PRAC_SALARIES_REACTIVATE_VALID_RECORDS_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[CRCS_PRAC_SALARIES_REACTIVATE_VALID_RECORDS_CORE] (
    @clientID      BigInt
  , @fiscalYearID  BigInt
  , @quarterNumber Int
)    
AS    
BEGIN     
 
/***************************************************************************    
 * CRCS_PRAC_SALARIES_REACTIVATE_VALID_RECORDS_CORE */    
/**    
 * Reactivates CRCS salary records for practitioners who have new service records
 * if 1. records were entered for them in the past and 2. they have no active
 * current CRCS salary records
 *
 * the reason we had to do this was because of rapid changes in DHCS' 
 * CRCS requirements   
 ***************************************************************************/         
 
SET NOCOUNT ON    
 
BEGIN TRY

	update cps
	  set cps.active = 1
	from dbo.CRCS_PRAC_SALARIES        as cps
	join dbo.COMPANY_FISCAL_QUARTERS   as fq on fq.QTR = cps.quarterNumber and fq.FY_ID = cps.fiscalYearID
	join dbo.RMTS_PARTICIPATION_ROSTER as rpr
		 on ((rpr.clientID = cps.clientID) and (rpr.quarterID = fq.ID) and (rpr.active    = 1))
	cross apply dbo.RMTS_PARTICIPANTS_VIEW_CORE (cps.clientID, rpr.id, 1, cps.pracID) as rpv
	where (
			(1 = 1)
		and ((@clientID      is null ) or (cps.clientID       = @clientID     ))
		and ((@fiscalYearID  is null ) or (cps.fiscalYearID   = @fiscalYearID ))
		and ((@quarterNumber is null)  or (cps.quarterNumber  = @quarterNumber))	
		and (isnull(rpv.hasServiceRecords, 0) = 1)
		and (cps.active = 0)
		and (not exists -- if an active record already exists, don't do anything
				(
					select top 1 pracID
					from dbo.CRCS_PRAC_SALARIES as cps2 
					where cps2.clientID      = cps.clientID
					  and cps2.fiscalYearID  = cps.fiscalYearID
					  and cps2.quarterNumber = cps.quarterNumber
					  and cps2.pracID        = cps.pracID
					  and cps2.active        = 1
				)			
			)
	)

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
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH     
END    
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CRCS_PRAC_SALARIES_REACTIVATE_VALID_RECORDS_CORE] TO [webuser]
GO