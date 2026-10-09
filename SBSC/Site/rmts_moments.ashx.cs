using System;
using System.Collections.Generic;
using System.Web;
using MBA;


namespace Spedmon
{
    /***************************************************************************
     * RmtsMomentsViw */
    /*
     ***************************************************************************/

    public class RmtsMomentsViw : WebReportDocument
    {

        // public const int REPT_NUM_VIEW  =  1;
        // TODO:  this constant is not used.  Hardcoded 1 in javscript, in 
        //        user_all_rmts_moment_service_records_manage.aspx
        //        and user_all_rpt_rmts_moment_service_records.aspx

        //        Consider uncommenting and using const next time we work on those pages

        public RmtsMomentsViw()
        {


            /*-------------------------------
             * Define permitted roles 
             * Call framework method
             * _reportEditView;
             * _reportPageView;
             * _reportPageNumber;
             *------------------------------*/

            this._permittedRoles = Constants.ROLE_RMTS_ADMINS;
            // NOTE: same for both / same for all.
            // commenting the _permittedRoles code inside of the forks of the IF-ELSE.

            //if  (  this.reportNumber == RmtsMoments.REPT_NUM_REVIEWS  )  {

                    // NOTE: we are hitting the first IF, only from
                    // user_all_rmts_moment_pcal_review.aspx.  On that page,
                    // we are searching by fiscal quarternum 1-4, not with quarterID.
                    // code is commented and can be removed in code review.

            // this._permittedRoles = Constants.ROLE_RMTS_ADMINS;

            if ( this.reportNumber == RmtsMoments.REPT_NUM_REVIEWS_FOR_MATCH)
              this.cbReportData = delegate ()
              {

                  var dblfilter_deferred_complete  // tad of a missnomer; 2 = complete, 3 = deferred
                    = MBA.HttpApplication.getParameter("deferredcomplete");

                  string parsed_deferred , parsed_complete;
                  RmtsMoments.triStateToBoolStrs(dblfilter_deferred_complete, out parsed_deferred, out parsed_complete);

                  return Spedmon.RmtsMoments.viewTblReportForMatchScreen(dbConnApp
                                            , log
                                            , uInfo
                                            , _reportPaging
                                            , _reportPageNumber
                                            , clientid


                                            , MBA.HttpApplication.getParameter(Constants.PARM_FISCAL_QUARTER_ID)

                                            , MBA.HttpApplication.getParameter(Constants.PARM_FISCAL_YEAR_ID)
                                            , MBA.HttpApplication.getParameter(Constants.PARM_QUARTER_NUMBER)

                                            , MBA.HttpApplication.getParameter("activity_code")

                                            , "" // matched
                                            , parsed_complete 

                                            , MBA.HttpApplication.getParameter("review_status_code")
                                            , _reportEditView
                                            , "Y"
                                            , parsed_deferred );
              };

            else
              this.cbReportData = delegate ()
              {

                return Spedmon.RmtsMoments.viewTbl(dbConnApp
                                            , log
                                            , uInfo
                                            , _reportPaging
                                            , _reportPageNumber
                                            , clientid

                                            , this.pracid 

                                            , MBA.HttpApplication.getParameter(Constants.PARM_FISCAL_QUARTER_ID)

                                            , MBA.HttpApplication.getParameter(Constants.PARM_FISCAL_YEAR_ID)
                                            , MBA.HttpApplication.getParameter(Constants.PARM_QUARTER_NUMBER)

                                            , MBA.HttpApplication.getParameter("activity_code")

                                            , "" // matched
                                            , "" // isComplete

                                            , MBA.HttpApplication.getParameter("review_status_code")
                                            , _reportEditView
                                            , "Y");
              };

            /*
            else { 

              //this._permittedRoles = Spedmon.Constants.ROLE_RMTS_ADMINS;  

              this.cbReportData = delegate() { 

              // NOTE: the removed code was querying by quarterID not quarterNum.
              //       However, it is passing in blank values for quarterID, review status, and everything
              //       except clientID.

              //       we can pass in blank values for quarterNum and FYID for the same result.
              //       The access permissions are the same, and the displayed columns are exactly the same.
              //       That is why we can remove this code.


*/

        }
    }
}