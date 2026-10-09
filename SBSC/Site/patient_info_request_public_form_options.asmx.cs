using MBA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;

namespace Spedmon
{
    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]
    public class PatientInfoRequestsPublicFormOptionsSvc : MBA.WebSvc
    {

        public PatientInfoRequestsPublicFormOptionsSvc() : base() { }

        /***************************************************************************
           * save */
        /**
        * Save practitioner patient infor request form option
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveOrReplaceRecord save(string clientid
                                            , string insuranceInfoRequestMessageBodyContentEN
                                            , string insuranceInfoRequestMessageBodyContentES
                                            , string savetype
                                            )
        {
            return (ReturnSaveOrReplaceRecord)

            callMethod(typeof(ReturnSaveOrReplaceRecord),
            delegate ()
            {
                return Spedmon.PatientInfoRequestsPublicFormOptions.save(this.dbConnApp
                                                            , this.log
                                                            , this.uInfo
                                                            , clientid
                                                            , insuranceInfoRequestMessageBodyContentEN
                                                            , insuranceInfoRequestMessageBodyContentES
                                                            , "1"
                                                            , ""
                                                            , "0"
                                                            , savetype
            );
            },
            Constants.ROLE_MANAGE_PATIENT_INFO_REQUEST_OPTIONS);  // Who can call this method           
        }
    }
}
