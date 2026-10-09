using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * StructuredDataImportFilesPatientDataRestApiHttpHandler */
    /**
     *    
     ***************************************************************************/

    public class StructuredDataImportFilesPatientDataRestApiHttpHandler : EntitiesRestApiHttpHandler
    {

        public StructuredDataImportFilesPatientDataRestApiHttpHandler() : this(null, false)
        {
        }

        public StructuredDataImportFilesPatientDataRestApiHttpHandler(RouteData routedata, bool localnetworkaccessonly)
        {
            this.routeData = routedata;
            this.localNetworkAccessOnly = localnetworkaccessonly;

            /* Wire up view method */

            this.viewMethodPermittedRoles = Spedmon.Constants.ROLE_BULK_PATIENT_IMPORT;
            this.viewMethodCb = delegate ()
            {

                return StructuredDataImportFilesPatientData.viewObjects (    
                                                     this.dbConnApp
                                                   , this.log
                                                   , this.uInfo
                                                   , this.pageObjectList
                                                   , this.pageorder
                                                   , this.idx
                                                   , this.active
                                                   , this.clientid );
            };
        }

    }


}


