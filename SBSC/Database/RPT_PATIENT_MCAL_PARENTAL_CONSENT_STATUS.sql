USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_PATIENT_MCAL_PARENTAL_CONSENT_STATUS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_PATIENT_MCAL_PARENTAL_CONSENT_STATUS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************
 * RPT_PATIENT_MCAL_PARENTAL_CONSENT_STATUS */
/**
 * Custom report function.  
 *
 * Displays human friendly MCAL parental consent status based on clients
 * preference for implied consent and if the client created the patient record
 * or we did.
 * 
 * @param  clientRecParentalConsentMCAL    Implied consent flag for client.
 *                                         Posible values 1, 0.
 * @param  patientRecParentalConsentMCAL   Parental consent flag for patient.
 *                                         Possible values 1, 0, null.
 * @param  patientRecCreatedByPCAL         Was this record created by us?
 *                                         Possible values  1, 0.
 * @return varchar(7)                      Yes, No, Unknown
 ***************************************************************************/  
 
CREATE FUNCTION [dbo].[RPT_PATIENT_MCAL_PARENTAL_CONSENT_STATUS] (
    @clientRecParentalConsentMCAL  bit
  , @patientRecParentalConsentMCAL bit
  , @patientRecCreatedByPCAL       bit
) 

RETURNS VARCHAR(7) 
AS     
BEGIN    
  
  declare @yn   as varchar(7) = ''   
  declare @flag as bit        = null
  
  /*-------------------------------
   * 1 means Yes
   *------------------------------*/

  if (@patientRecParentalConsentMCAL = 1) 
  begin
    set @flag = 1
  end 

  /*-------------------------------
   * 0 means No
   *------------------------------*/

  else if (@patientRecParentalConsentMCAL = 0)
  begin
    set @flag = 0
  end

  /*-------------------------------
   * Unnown means we need to
   * check futher
   *------------------------------*/

  else if (@patientRecParentalConsentMCAL is null)
  begin

    /*-------------------------------
     * If the patient record was not
     * created by the client then 
     * null means Unknown
     *------------------------------*/

    if (@patientRecCreatedbyPCAL = 0) 
      begin
       set @flag = null
      end
    
    /*-------------------------------
     * If the patient record was
     * created by US then the 
     * interpretation of the parental
     * consent flag is based on 
     * if the client has told us
     * implicit consent is OK
     *------------------------------*/

      else
      begin
        
        /*-------------------------------
         * Implicit consent rule applies
         * null means Yes
         *------------------------------*/

        if (@clientRecParentalConsentMCAL = 1)
        begin
          set @flag = 1
        end
        
        /*-------------------------------
         * Implicit consent rule does not
         * apply
         *------------------------------*/
        
        else
        begin
          set @flag = 0
        end  /* Client implied consent flag */    
      end /* Patient record created by PCAL */ 
    end /* Patient record MCAL consent */
  
  /*-------------------------------
   * We should never get here
   * This is for completion state
   *------------------------------*/
  
  else 

  begin
    return null
  end
  
  /*-------------------------------
   * Using our inteprepreted value
   * set the status and return it
   *------------------------------*/
  
  set @yn = dbo.RPT_BIT_TO_YNU(@flag)
  return @yn    

END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RPT_PATIENT_MCAL_PARENTAL_CONSENT_STATUS] TO [webuser]
GO
