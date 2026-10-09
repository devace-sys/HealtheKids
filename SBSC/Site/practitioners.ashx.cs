using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * practitioners.ashx */
  /*
   ***************************************************************************/
 
  public class PractitionersRpt : WebReportDocument
  {
  
    public const int REPT_NUM_VIEW                = 1;
    public const int REPT_NUM_REVIEW              = 2;
    public const int REPT_NUM_LEA_MAA_XREF_ISSUES = 3;
    public const int RPT_TATTLETALE               = 109;
    public const int RPT_TATTLETALE_CUST          = 110;
    public const int RPT_PRAC_TATTLE              = 111;
    public const int RPT_CYBHI_PRACS_TPA_EXPORT   = 200;
    public const int RPT_CYBHI_PRACS_AUDIT        = Constants.RPT_CYBHI_PRACS_AUDIT;
    public const int RPT_QUALS_MISSING_OR_EXPIRED = 50;

    public PractitionersRpt()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/
       
       this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
       this.cbReportData = delegate()
       {
         
         if (this._reportNumber == RPT_CYBHI_PRACS_TPA_EXPORT)
         {
           this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL_LEA_COORD;
           return Spedmon.Practitioners.rptCybhiPracsTPAExport(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid);
         }

         if (this._reportNumber == RPT_CYBHI_PRACS_AUDIT)
         {
           this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL_LEA_COORD_CYBHI_COORD;
           return Spedmon.Practitioners.rptCybhiPracsAudit(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid);
         }

         if (this._reportNumber == RPT_QUALS_MISSING_OR_EXPIRED) {
           this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
           return Spedmon.Practitioners.rptQualificationsMissingOrExpired (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid); 
         }

         if (this._reportNumber == REPT_NUM_REVIEW)
         {
           return Spedmon.Practitioners.rptReview(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, groupid, _lastName, _firstName, _reportEditView, active);
         }
         
         if (this._reportNumber == REPT_NUM_LEA_MAA_XREF_ISSUES)
         {
           this._permittedRoles = Spedmon.Constants.ROLE_SBS_MGMT_ANI;
           return Spedmon.Practitioners.rpt_Practitioner_XREF_LEA_MAA_Issues(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid);
         }
         
         /* Old tattle report */
         if (this._reportNumber == RPT_TATTLETALE)
         {
             return Spedmon.Practitioners.rptTattle(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber
                 , clientid // if a customer end-user is running this report, the clientid will come in null.
                            // even if it doesn't, it will be replaced with the end-user's own clientID in the practitioners entity method for this report.
                            // we are protected from browser hacks.
                 ,MBA.HttpApplication.getParameter("as-of-date")
                 ,_reportEditView
                 , pracid
                 , groupid
                 );
         }

         return Spedmon.Practitioners.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, groupid, _lastName, _firstName, MBA.HttpApplication.getParameter( Constants.PARM_CURRENTLY_W_CLIENT ) ,  _reportEditView , active);

       };
    }
  }
}