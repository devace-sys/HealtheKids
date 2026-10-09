using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * StructuredDataImportFilesRmtsParticipantsNotInSpEdCareRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class StructuredDataImportFilesRmtsParticipantsNotInSpEdCareRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public StructuredDataImportFilesRmtsParticipantsNotInSpEdCareRestApiHttpHandler() : this(null, false)
        {
        }
        public StructuredDataImportFilesRmtsParticipantsNotInSpEdCareRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Constants.ROLE_ANNOUNCEMENT_ADMIN;
            this.viewMethodCb = delegate ()
            {

                return Spedmon.StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.viewObjects(
                                                                        this.dbConnApp
                                                                      , this.log
                                                                      , this.uInfo
                                                                      , this.pageObjectList
                                                                      , this.pageorder
                                                                      , this.idx
                                                                      , this.active
                                                                      , clientid
                                                                      , MBA.HttpApplication.getParameter(Constants.PARM_FY_QUARTER_ID)
                                                                      , MBA.HttpApplication.getParameter(Constants.PARM_RMTS_DATA_IMPORT_ID)
                                                                     );
            };
        }

    }

}
