
using System;
using System.Collections.Generic;
using System.Web;
using MBA;


namespace Spedmon
{
    /***************************************************************************
     * CybhiHealthDetailedServicesDocumentedRptView */
    /* nb
     ***************************************************************************/

    public class CybhiHealthDetailedServicesDocumentedRptView : WebReportDocument
  {
        public const int REPT_NUM_VIEW = 1;
        public CybhiHealthDetailedServicesDocumentedRptView()
        {
            /*-------------------------------
             * Define permitted roles 
             * Call framework method
             * _reportEditView;
             * _reportPageView;
             * _reportPageNumber;
             *------------------------------*/

            this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.cbReportData = delegate ()
            {
                return Spedmon.CYBHIProgramHealthDetailedServicesDocumented.viewTbl(
                    dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, active

                                                , this.clientid //  string clientID
                                                , this.groupid  //  string groupID
                                                , this.pracid   //  string pracID
                                                , this.patid    //  string patID
                                                , MBA.HttpApplication.getParameter(Constants.PARM_NAME_ID) // this.nameid   // string nameID
                                                , MBA.HttpApplication.getParameter( Constants.PARM_START_DATE) // this.startdate   // string startDOS
                                                , MBA.HttpApplication.getParameter(Constants.PARM_END_DATE) // enddate // string endDOS
                                                , MBA.HttpApplication.getParameter("ispaid")
                );
            };
        }
  }
}