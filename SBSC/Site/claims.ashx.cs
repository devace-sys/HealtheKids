using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * claims.ashx */
  /*
   ***************************************************************************/

  public class ClaimsRpt : WebReportDocument
  {    
    
    public const int REPT_NUM_VIEW                                      = 1;
    public const int REPT_CRC_CLAIMS                                    = 6;
    public const int REPT_AnI_Weekly                                    = 7;
    public const int REPT_POT_LOST_REIMBURSE                            = 10;
    public const int REPT_POT_LOST_REIMBURSE_OVERVIEW                   = 20;
    public const int REPT_POT_LOST_REIMBURSE_ORP_DETAILS                = 40;
    public const int REPT_POT_LOST_REIMBURSE_DAILY_DETAILS              = 50;
    public const int REPT_POT_LOST_REIMBURSE_UPDATED_DAILY_OVERVIEW     = 51;
    public const int REPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS = 52;
    public const int REPT_CLAIMS_TRANSMISSION_SUMMARY                   = 21;
    public const int REPT_CLAIMS_WAITING_FOR_TRANSMISSION_SUMMARY       = 22;
    
    public const int REPT_CLAIMS_RECENT_DENIALS_SUMMARY                 = 75;
    public const int REPT_CLAIMS_RECENT_DENIALS_DETAILS                 = 76;

    public ClaimsRpt()
    {

      /*-------------------------------
       * Define permitted roles 
       * Refine access
       * Call framework method based
       * on report number
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;

      this.cbReportData = delegate()
      {
              
        if (this._reportNumber == REPT_NUM_VIEW)
        {
          
          /* Only work leads, a%i and admins can see claims */
          
          this._permittedRoles = Spedmon.Constants.ROLE_SBS_MGMT_ANI;
          return Spedmon.Claims.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, pracid, patid, dateRange, "", "");
        }
        
        else if (this._reportNumber == REPT_CRC_CLAIMS)
        {  
          return Spedmon.Claims.rptCRCsClaims(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, dateRange,proccode,procmod1,procmod2,procmod3, _reportEditView, active);                               
        }
        
        else if (this._reportNumber == REPT_POT_LOST_REIMBURSE)
        {
          /* Only pcal staff can see this report */
          this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
          return Spedmon.Claims.rptPotentialLostReimbursement(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, clrepidLEA, reportEditView, active);
        }
        else if (this._reportNumber == REPT_POT_LOST_REIMBURSE_OVERVIEW)
        {
          /* Only pcal staff can see this report */
          this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
          return Spedmon.Claims.rptPotentialLostReimbursementOverview (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, clrepidLEA, reportEditView, active);
        }
        else if (this._reportNumber == REPT_POT_LOST_REIMBURSE_ORP_DETAILS)
        {
          /* Only pcal staff can see this report */
          this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
          return Spedmon.Claims.rptPotentialLostReimbursementORPDetails  (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, clrepidLEA, reportEditView, active);
        }
        else if (this._reportNumber == REPT_POT_LOST_REIMBURSE_DAILY_DETAILS)
        {
          /* Only pcal staff can see this report */
          this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
          return Spedmon.Claims.rptPotentialLostReimbursementDailyDetails  (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, clrepidLEA, reportEditView, active);
        }
          else if (this._reportNumber == REPT_POT_LOST_REIMBURSE_UPDATED_DAILY_OVERVIEW)
          {
              /* Only pcal staff can see this report */
              this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
              return Spedmon.Claims.rptPotentialLostReimbursementUpdatedDailyOverview(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, clrepidLEA, reportEditView, active);
          }

          else if (this._reportNumber == REPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS)
          {
              /* Only pcal staff and LEA coordinators can see this  */
              this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL_LEA_COORD_AND_ASSIST;
              return Spedmon.Claims.rptMissingAssessmentsWithPotReimbursementDetails(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, clrepidLEA, reportEditView, active);
            
          }

          else if (this._reportNumber == REPT_CLAIMS_TRANSMISSION_SUMMARY)
          {
          //All PCAL staff can see this
              this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
          return Spedmon.Claims.rptClaimsTransmissionSummary(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, clrepidLEA, dateRange, reportEditView, active);
      }
      else if (this._reportNumber == REPT_CLAIMS_WAITING_FOR_TRANSMISSION_SUMMARY)
      {
              /* All PCAL staff can see this */
              this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
            return Spedmon.Claims.rptClaimsWaitingForNextTransmissionSummary(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, reportEditView, active);
      }
      else if (this._reportNumber == REPT_CLAIMS_RECENT_DENIALS_SUMMARY)
      {
          /* All PCAL staff can see this */
          this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
          return Spedmon.Claims.rptClaimsRecentDenialsSummary (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, reportEditView, active);
      }
      else if (this._reportNumber == REPT_CLAIMS_RECENT_DENIALS_DETAILS)
      {
              /* All PCAL staff can see this */
              this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
              return Spedmon.Claims.rptClaimsRecentDenialsDetails(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, reportEditView, active);
      }

          else
          {
          return null;
     }
    };
    }
  }
}