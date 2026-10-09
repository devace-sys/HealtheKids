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
     * PatientInfoRequestsPublicInsuranceFormsSvc  */
    /**
     * 
     *************************************************************************/

    public class PatientInfoRequestsPublicInsuranceFormsSvc : MBA.WebSvc
    {


      public PatientInfoRequestsPublicInsuranceFormsSvc() : base() { }
        
        /***************************************************************************
         * getFormUrlByClientID */
        /**
         * "delete" a record.
         * 
         * @param  recid         Record id to delete
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnPatientInfoRequestsPublicInsuranceForm getformbyclientid(string clientid)
        {
            return (ReturnPatientInfoRequestsPublicInsuranceForm)
            callMethod(typeof(ReturnPatientInfoRequestsPublicInsuranceForm),
            delegate ()
            {
                return Spedmon.PatientInfoRequestsPublicInsuranceForms.getFormByClientID(this.dbConnApp,
                                             this.log,
                                             this.uInfo,
                                             clientid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

    }
}
