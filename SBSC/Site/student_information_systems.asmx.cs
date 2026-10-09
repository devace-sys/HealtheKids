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
     * StudentInformationSystemsSvc */
    /**
     **************************************************************************/

    public class StudentInformationSystemsSvc : MBA.WebSvc
    {
        public StudentInformationSystemsSvc() : base()
        {
        }

        /***************************************************************************
         * viewsel */
        /**         
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSel viewsel (string term)
        {
            return (ReturnSel)callMethod(typeof(ReturnSel),
                delegate ()
                {
                    return Spedmon.StudentInformationSystems.viewSel(
                          this.dbConnApp
                        , this.log
                        , this.uInfo
                        , true
                        , "");
                },
                Constants.ROLE_ALL_PCAL_AND_CLIENT);
        }
    }
}