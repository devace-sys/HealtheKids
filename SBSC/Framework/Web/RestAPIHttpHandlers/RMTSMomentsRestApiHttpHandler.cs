using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{



    /***************************************************************************
     * RMTSMomentSvcRecsRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class RMTSMomentsRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public RMTSMomentsRestApiHttpHandler() : this(null, false)
        {
        }

        public RMTSMomentsRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_ALL_PCAL_AND_CLIENT;

            if (!String.IsNullOrWhiteSpace(this.daterange))
            {
                var sDate = @"";
                var eDate = @"";
                Util.parseDateRange(this.daterange, out sDate, out eDate);
                this.startdate = sDate;
                this.enddate = eDate;
            }



              this.viewMethodCb = delegate ()
              {

                  var dblfilter_deferred_complete  // tad of a missnomer; 2 = complete, 3 = deferred
                    = MBA.HttpApplication.getParameter("deferredcomplete");

                  string parsed_deferred , parsed_complete ;

                  RmtsMoments.triStateToBoolStrs(dblfilter_deferred_complete, out parsed_deferred, out parsed_complete);

                  return RmtsMoments.viewObjects(this.dbConnApp
                                                       , this.log
                                                       , this.uInfo
                                                       , this.pageObjectList
                                                       , this.pageorder
                                                       , this.idx
                                                       , this.pagesize
                                                       , this.active
                                                       //, MBA.HttpApplication.getParameter("importID")
                                                       , this.clientid

                                                       , this.pracid

                                                       , MBA.HttpApplication.getParameter(MBA.Constants.PARM_FISCAL_QUARTER_ID)

                                                       , MBA.HttpApplication.getParameter(Constants.PARM_FISCAL_YEAR_ID)
                                                       , MBA.HttpApplication.getParameter(Constants.PARM_QUARTER_NUMBER)

                                                       , this.rmtsActivityCode


                                                       , MBA.HttpApplication.getParameter("matched")

                                                       , (!Util.IsNullOrEmpty( dblfilter_deferred_complete ) ?
                                                             parsed_complete :
                                                             MBA.HttpApplication.getParameter("isComplete")
                                                          ) // a tadbit of backwards-compatibility, I'm leaving here for no particular reason
                                                            // NOTE: still not sure if isComplete is used someplace where deferredcomplete is not.
                                                            // On screens that pass in neither, e.g., user_all_rmts_moment_pcal_review.aspx, an empty
                                                            // string is passed in to the viewObjects() method, from the RestApiHttpHandler level.


                                                       , MBA.HttpApplication.getParameter("review_status_code")

                                                       , parsed_deferred 
                                                       );
              };

        }

    }


}


