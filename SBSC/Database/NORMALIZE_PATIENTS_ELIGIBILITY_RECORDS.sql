USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NORMALIZE_PATIENTS_ELIGIBILITY_RECORDS') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.NORMALIZE_PATIENTS_ELIGIBILITY_RECORDS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[NORMALIZE_PATIENTS_ELIGIBILITY_RECORDS]    
AS    
BEGIN    
   
/***************************************************************************    
 * NORMALIZE_PATIENTS_ELIGIBILITY_RECORDS */    
/**    
 * Our patient elibility data is sent to us and initially stored in
 * a non-normalized and encoded form.  This procedure decodes the 
 * eligibility records and stores them in normalized form into
 * PATIENTS_ELIGIBILITY_NORMALIZED table
 ***************************************************************************/        
     
SET NOCOUNT ON    	    

BEGIN TRY
    
   /*-------------------------------    
    * Prepare 
    * 
    * PATIENTS_ELIGIBILITY_NORMALIZED
    * 
    * for fresh data by:
    * 
    * - truncating the table
    * - dropping indexes 
    *------------------------------*/     
    
    -- PATIENTS_ELIGIBILITY_NORMALIZED
    
    RAISERROR ('Preparing table', 0, 1) WITH NOWAIT

    RAISERROR ('Preparing table - truncating data', 0, 1) WITH NOWAIT

    truncate table PATIENTS_ELIGIBILITY_NORMALIZED
    
    IF EXISTS (SELECT * 
               FROM sys.indexes 
               WHERE object_id = OBJECT_ID(N'[dbo].[PATIENTS_ELIGIBILITY_NORMALIZED]') 
               AND name = N'PatID_MonYear')
    BEGIN
      RAISERROR ('Preparing table - dropping index', 0, 1) WITH NOWAIT
      DROP INDEX [PatID_MonYear] ON [dbo].[PATIENTS_ELIGIBILITY_NORMALIZED] WITH ( ONLINE = OFF )
    END
    
   /*-------------------------------    
    * Normalize our elibility records
    * by calling
    * NORMALIZE_PATIENT_ELIGIBILITY_RECORD
    * for every row in
    * PATIENTS_Eligibility
    * and storing the rows that
    * the function generates (13 in all)
    * into PATIENTS_ELIGIBILITY_NORMALIZED
    *------------------------------*/     

    DECLARE @today AS DATETIME                      -- Current date/time stamp    
    set     @today = dbo.DATE_START(GETDATE(),3)	 	 

    RAISERROR ('Normalizing data - please wait', 0, 1) WITH NOWAIT
		    	   
	INSERT INTO PATIENTS_ELIGIBILITY_NORMALIZED  
	SELECT 
	  peg.patient_ID,
	  peg.ELIGIBILITY_ID,
	  c.monthDate,
	  IS_ELIG = CASE WHEN c.eFlag = 'E' then 1 else 0 end		        
	FROM  
	  dbo.PATIENTS_Eligibility as peg
	  cross apply (select * 
	               from dbo.NORMALIZE_PATIENT_ELIGIBILITY_RECORD(peg.patient_id,
	                                         1,
	                                         null,
	                                         peg.MEDS_CURRENT, 
	                                         peg.CURRENT_MONTH_ELIGIBILITY, 
	                                         peg.JAN_ELIGIBILITY_INDICATOR,    
	                                         peg.FEB_ELIGIBILITY_INDICATOR, 
	                                         peg.MAR_ELIGIBILITY_INDICATOR, 
	                                         peg.APR_ELIGIBILITY_INDICATOR,    
	                                         peg.MAY_ELIGIBILITY_INDICATOR, 
	                                         peg.JUN_ELIGIBILITY_INDICATOR, 
	                                         peg.JUL_ELIGIBILITY_INDICATOR,    
	                                         peg.AUG_ELIGIBILITY_INDICATOR, 
	                                         peg.SEP_ELIGIBILITY_INDICATOR, 
	                                         peg.OCT_ELIGIBILITY_INDICATOR,    
	                                         peg.NOV_ELIGIBILITY_INDICATOR, 
	                                         peg.DEC_ELIGIBILITY_INDICATOR )) as c 
	where peg.PATIENT_ID = c.patient_id 
	and   peg.MEDS_CURRENT > DATEADD (mm, -14, @today)
		                             	                
   /*-------------------------------    
    * Recreate our index
    * We use a clustered index 
    * The index is patientID and
    * MonthDate
    *------------------------------*/    
  
  RAISERROR ('Creating index', 0, 1) WITH NOWAIT
  
  CREATE CLUSTERED INDEX [PatID_MonYear] ON [dbo].[PATIENTS_ELIGIBILITY_NORMALIZED] 
  (
		[Patient_ID]  ASC,
		[Month_Date]  ASC
  )
  
  RAISERROR ('Done', 0, 1) WITH NOWAIT

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
end 
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[NORMALIZE_PATIENTS_ELIGIBILITY_RECORDS] TO [webuser]
GO
 
