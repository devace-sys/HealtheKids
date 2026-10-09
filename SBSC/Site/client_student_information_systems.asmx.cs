using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.ComponentModel;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]

    /***************************************************************************
     * ClientStudentInformationSystemsSvc */
    /**
     **************************************************************************/

    public class ClientStudentInformationSystemsSvc : MBA.WebSvc
    {
        public ClientStudentInformationSystemsSvc() : base()
        {
        }

        /***************************************************************************
         * saveinline */
        /**
         * Save or edit client student information system
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord saveinline (  string clientid
                                            , string studentinfosystemid
                                            , string apiurl
                                            , string apitoken                                                                                        
                                            , string schoolnamestoexclude
                                            , string enabled
                                            , string savetype
                                            , string recid )
        {
            return (ReturnSaveRecord)callMethod(typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.ClientStudentInformationSystems.save (
                          this.dbConnApp
                        , this.log
                        , this.uInfo
                        , clientid
                        , studentinfosystemid
                        , apiurl
                        , apitoken
                        , schoolnamestoexclude
                        , enabled
                        , ""
                        , "N"
                        , savetype
                        , recid );
                },
                Constants.ROLE_SBS_ALL);
        }

        /***************************************************************************
         * deleteinline */
        /**
         * "delete" a record.
         * 
         * @param recid Record id to delete
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord deleteinline (string recid)
        {
            return (ReturnSaveRecord)callMethod(typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.ClientStudentInformationSystems.delete (
                          this.dbConnApp
                        , this.log
                        , this.uInfo
                        , ""
                        , "N"
                        , recid );
                },
                Constants.ROLE_SBS_ALL);
        }
    }
}