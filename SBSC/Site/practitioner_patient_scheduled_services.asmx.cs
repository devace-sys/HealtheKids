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
using System.IO;

namespace Spedmon
{
    /***************************************************************************
     * PractitionerPatientScheduledServicesSvc */
    /*
     * 
     ***************************************************************************/

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]
    public class PractitionerPatientScheduledServicesSvc : MBA.WebSvc
    {
        public PractitionerPatientScheduledServicesSvc() : base() { }
        
        /***************************************************************************
         * save */
        /*
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord save (
             string clientid
           , string pracid
           , string patid
           , string caseloadgrpid
           , string svcnameslistdatasourceid
           , string viatelehealth
           , string nameid
           , string recurring
           , string practitionerpatientcaseloadexpectedserviceid
           , string startdate
           , string enddate           
           , string starttime
           , string nummins
           , string mon
	       , string monstarttime	 
           , string tue
	       , string tuestarttime
           , string wed
	       , string wedstarttime
           , string thu
	       , string thustarttime
           , string fri
	       , string fristarttime
           , string notes
           , string editDelReason
           , string validaterec 
           , string savetype
           , string recid           
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PractitionerPatientScheduledServices.save (
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , pracid
                , patid
                , caseloadgrpid
                , svcnameslistdatasourceid           
                , viatelehealth
                , nameid
                , recurring
                , practitionerpatientcaseloadexpectedserviceid
                , startdate
                , enddate
                , starttime
                , nummins
                , mon
	            , monstarttime	 
                , tue
	            , tuestarttime
                , wed
	            , wedstarttime
                , thu
	            , thustarttime
                , fri
	            , fristarttime             
                , notes
                , editDelReason
                , validaterec
                , savetype
                , recid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);
        }

        /***************************************************************************
         * savemultiple */
        /*
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord savemultiple(
             string clientid
           , string pracid
           , string caseloadgrpid
           , string patselectedjson
           , string svcnameslistdatasourceid
           , string viatelehealth
           , string nameid
           , string recurring
           , string startdate
           , string enddate
           , string starttime
           , string nummins
           , string mon
           , string monstarttime
           , string tue
           , string tuestarttime
           , string wed
           , string wedstarttime
           , string thu
           , string thustarttime
           , string fri
           , string fristarttime
           , string notes
           , string savetype
           , string recid
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PractitionerPatientScheduledServices.savemultiple(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , pracid
                , caseloadgrpid
                , patselectedjson
                , svcnameslistdatasourceid
                , viatelehealth
                , nameid
                , recurring
                , startdate
                , enddate
                , starttime
                , nummins
                , mon
                , monstarttime
                , tue
                , tuestarttime
                , wed
                , wedstarttime
                , thu
                , thustarttime
                , fri
                , fristarttime
                , notes
                , ""
                , "N"
                , savetype
                , recid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);
        }

        /***************************************************************************
         * deleteinline */
        /**
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord deleteinline (string clientid, string pracid, string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PractitionerPatientScheduledServices.delete(
                                             this.dbConnApp
                                           , this.log
                                           , this.uInfo
                                           , clientid
                                           , pracid                                          
                                           , ""
                                           , "N"                                           
                                           , recid);
            },
              Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }
 
    }

}
