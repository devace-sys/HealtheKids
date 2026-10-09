using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * reports_fin.ashx */
  /*
   ***************************************************************************/

  public class ReportsFin : WebDataDocument
  {    
    
    
    public ReportsFin()
    {
      /*-------------------------------
       * Define permitted roles 
       * Refine access
       * Call framework method
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;

      this.cbReportData = delegate()
      {             
        if (this._reportNumber == Spedmon.Constants.REPT_NUM_CLAIMS_PAID_BY_DOW_1P)
        {
          this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
          return Spedmon.Reports.Fianancial.rptClaimsPaidByCheckDate1P(dbConnApp, log, uInfo, clientid, dateRange, includeZeros);        
        }
        else if (this._reportNumber == Spedmon.Constants.REPT_NUM_CLAIMS_PAID_BY_DOW_2P)
        {
          this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
          return Spedmon.Reports.Fianancial.rptClaimsPaidByCheckDate2P(dbConnApp, log, uInfo, clientid, dateRange, dateRange2, includeZeros);        
        }
        else if (this._reportNumber == Spedmon.Constants.REPT_NUM_CLAIMS_PAID_BY_DOS_1P)
        {
          this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
          return Spedmon.Reports.Fianancial.rptClaimsPaidByServiceDate1P(dbConnApp, log, uInfo, clientid, dateRange, includeZeros);        
        }
        else if (this._reportNumber == Spedmon.Constants.REPT_NUM_CLAIMS_PAID_BY_DOS_2P)
        {
          this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
          return Spedmon.Reports.Fianancial.rptClaimsPaidByServiceDate2P(dbConnApp, log, uInfo, clientid, dateRange, dateRange2, includeZeros);        
        }        
        else if (this._reportNumber == Spedmon.Constants.REPT_NUM_CLAIMS_PAID_BY_DOS_BY_ELIG_PAT_2P)
        {
            this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
            return Spedmon.Reports.Fianancial.rptClaimsPaidByDOSByEligPat2P(dbConnApp, log, uInfo, clientid, siteid, groupid, pracid, patid, dateRange);
        }
        else
        {
          return null;
        }
      };
    }
  }
}