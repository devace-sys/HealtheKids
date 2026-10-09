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

    public class ICD10CMCodesSvc : MBA.WebSvc
    {
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSel viewSel(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.ICD10CMCodes.viewSel(dbConnApp
                                                            , log
                                                            , uInfo
                                                            , true
                                                            , ""
                                                            , "Y"
                                                            , term
                                                            );
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }


    }
}
