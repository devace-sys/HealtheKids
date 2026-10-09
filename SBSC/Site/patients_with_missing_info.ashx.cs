using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
    /***************************************************************************
      * PatientsWithMissingInfoViw */
    /*
     ***************************************************************************/
    public class PatientsWithMissingInfoViw : WebReportDocument
    {        
        public const int REPT_NUM_VIEW_DEFAULT                        = 1;
        public const int REPT_NUM_VIEW_PATS_NEEDING_POSSIBLE_FOLLOWUP = 2;
        public PatientsWithMissingInfoViw ()
        {
            /***********************************************************************
             * Define permitted roles
             * Call framework method
             * _reportEditView
             * _reportPageName
             * _reportPageNumber
             ************************************************************************/

            this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.cbReportData = delegate ()
            {                
                if (_reportNumber == REPT_NUM_VIEW_DEFAULT)
                {                 
                  return Spedmon.PatientsWithMissingInfo.viewTbl ( dbConnApp
                                                                , log
                                                                , uInfo
                                                                , _reportPaging
                                                                , _reportPageNumber
                                                                , active
                                                                , clientid
                                                                , patid
                                                                , datasource
                                                                , MBA.HttpApplication.getParameter(Constants.PARM_MISSING_INSURANCE_INFO)
                                                                , MBA.HttpApplication.getParameter(Constants.PARM_MISSING_ADDRESS_INFO)
                                                                , MBA.HttpApplication.getParameter(Constants.PARM_MISSING_FERPA_CONSENT)
                                                                , MBA.HttpApplication.getParameter(Constants.PARM_MISSING_PG_EMAILS)
                                                                , MBA.HttpApplication.getParameter(Constants.PARM_MISSING_PG_MCAL_CONSENT)
                                                                , MBA.HttpApplication.getParameter(Constants.PARM_HAS_CURR_INFO_REQUEST)
                                                                , MBA.HttpApplication.getParameter(Constants.PARM_HAS_CURR_INFO_REQUEST_THAT_REQUIRES_REVIEW)
                                                                , MBA.HttpApplication.getParameter(Constants.PARM_HAS_PREV_INFO_REQUEST_THAT_REQUIRED_REVIEW) );
                }
                else if (_reportNumber == REPT_NUM_VIEW_PATS_NEEDING_POSSIBLE_FOLLOWUP)
                {                 
                  return Spedmon.PatientsWithMissingInfo.rptPatsNeedingPossibleFollowup ( 
                                                                  dbConnApp
                                                                , log
                                                                , uInfo
                                                                , _reportPaging
                                                                , _reportPageNumber
                                                                , active
                                                                , clientid
                                                                , patid
                                                                , datasource );
                }
                /* No report number, exit */
                return new ReturnDataTable();

            };
        }
    }
}