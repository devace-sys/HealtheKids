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
     * PatientInfoRequestsPublicInsuranceFormResponsesSvc  */
    /**
     * 
     *************************************************************************/

    public class PatientInfoRequestsPublicInsuranceFormResponsesSvc : MBA.WebSvc
    {


      public PatientInfoRequestsPublicInsuranceFormResponsesSvc() : base() { }



        /***************************************************************************
         * saveinline */
        /**
         * 
         * Save or edit
         ***************************************************************************/


        [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveRecord saveinline (
                          string ptkn
                          , string studentFirstName
                          , string studentLastName
                          , string studentDOB
                          , string studentID
                          , string insuranceCarrierCode
                          , string insuranceMemberID
                          , string insuranceCarrierOtherName
                          , string responderIsParentGuardian
                          , string responderFirstName
                          , string responderLastName
                          , string responderEmail
                          , string responderPhone
                          , string consent
                          , string responderSigImgData

        , string savetype
        , string recid  )
    {
        return (ReturnSaveRecord) callMethod(
            typeof(ReturnSaveRecord),
            delegate ()
            {
                var so = new ReturnSaveRecord();
				return so;
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // TODO ???
    }

        /***************************************************************************
         * deleteinline */
        /**
         * "delete" a record.
         * 
         * @param  recid         Record id to delete
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord deleteinline(string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                var so = new ReturnSaveRecord();
				return so;
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }
       

    }
}
