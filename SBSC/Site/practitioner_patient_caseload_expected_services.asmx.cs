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
     * PractitionerPatientCaseloadExpectedServicesSvc */
    /*
     * 
     ***************************************************************************/

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]
    public class PractitionerPatientCaseloadExpectedServicesSvc : MBA.WebSvc
    {
        public PractitionerPatientCaseloadExpectedServicesSvc() : base() { }
        
       /***************************************************************************
        * saveinline */
       /*
        * 
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord saveinline (
             string clientid
           , string pracid         
           , string patid        
           , string svctrackingclass
           , string spedservicecode                  
           , string orpdocid
           , string svcnameslistdatasourceid
           , string viatelehealth           
           , string nameid
           , string startdate                        
           , string enddate                        
           , string spedfreqcode                     
           , string minsperfreq                      
           , string expectedminsind                  
           , string expectedminsgrp                  
           , string hassvcdetails
           , string svcdetailsjson
           , string userprovidedsvcterms
           , string recid
           , string savetype
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PractitionerPatientCaseloadExpectedServices.save (
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , pracid
                , patid
                , svctrackingclass                
                , spedservicecode                
                , orpdocid       
                , svcnameslistdatasourceid
                , viatelehealth          
                , nameid
                , startdate                
                , enddate                
                , spedfreqcode                
                , minsperfreq                
                , expectedminsind                
                , expectedminsgrp                
                , hassvcdetails
                , svcdetailsjson
                , userprovidedsvcterms
                , ""
                , "0"
                , savetype
                , recid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);
        }
       
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
           , string svctrackingclass                       
           , string spedservicecode                  
           , string orpdocid   
           , string svcnameslistdatasourceid
           , string viatelehealth         
           , string nameid
           , string startdate                        
           , string enddate                        
           , string spedfreqcode                     
           , string minsperfreq                      
           , string startdateassigned
           , string minsperfreqassigned
           , string hassvcdetails
           , string svcdetailsjson
           , string userprovidedsvcterms
           , string recid
           , string savetype
           , string validaterec
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PractitionerPatientCaseloadExpectedServices.save (
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , pracid
                , patid
                , svctrackingclass                
                , spedservicecode                
                , orpdocid
                , svcnameslistdatasourceid
                , viatelehealth
                , nameid
                , startdate                
                , enddate                
                , spedfreqcode                
                , minsperfreq                
                , startdateassigned
                , minsperfreqassigned
                , hassvcdetails
                , svcdetailsjson
                , userprovidedsvcterms
                , ""
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
        public ReturnSaveRecord savemultiple (
             string clientid
           , string pracid         
           , string newsvcsjson
           , string validaterec
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
               return Spedmon.PractitionerPatientCaseloadExpectedServices.saveMultiple (
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , pracid
                , "Y"
                , newsvcsjson
                , validaterec );
                
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);
        }
        
        /***************************************************************************
         * viewSel */
        /**
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSel viewSel (string clientid, string pracid, string patid, string term)
        {
          return (ReturnSel) 
          callMethod(typeof(ReturnSel), 
          delegate()
          {
            return Spedmon.PractitionerPatientCaseloadExpectedServices.viewSel (  this.dbConnApp
                                                                                 , this.log
                                                                                 , this.uInfo
                                                                                 , true
                                                                                 , ""
                                                                                 , clientid
                                                                                 , pracid
                                                                                 , patid
                                                                                 , term
                                                                                 , true );
          }, Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }   

        /***************************************************************************
         * viewSelSpEdPlansAndSpEdSvcCodes */
        /**
         * @showCurrentOnly
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSel viewSelSpEdPlansAndSpEdSvcCodes (string clientid, string pracid, string patid, string term, string showcurrentonly)
        {
          return (ReturnSel) 
          callMethod(typeof(ReturnSel), 
          delegate()
          {
            return Spedmon.PractitionerPatientCaseloadExpectedServicesSpEdPlansAndSpEdSvcCodes.viewSel (  this.dbConnApp
                                                                                                        , this.log
                                                                                                        , this.uInfo
                                                                                                        , true
                                                                                                        , ""
                                                                                                        , clientid
                                                                                                        , pracid
                                                                                                        , patid
                                                                                                        , term
                                                                                                        , showcurrentonly );
          }, Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }   


        /***************************************************************************
         * delete */
        /**
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord delete (string clientid, string pracid, string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PractitionerPatientCaseloadExpectedServices.delete(this.dbConnApp,
                                           this.log,
                                           this.uInfo,
                                           clientid,
                                           pracid,
                                           "",
                                           "0",
                                           recid);
            },
              Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * deleteall */
        /**
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord deleteall (string clientid, string pracid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PractitionerPatientCaseloadExpectedServices.deleteAll(this.dbConnApp, this.log, this.uInfo, clientid,pracid,"","0");
            },
            Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC);  // Who can call this method           
        }

        /***************************************************************************
         * deletebatch */
        /**
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord deletebatch (string clientid, string pracid, string recidmulti)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PractitionerPatientCaseloadExpectedServices.deleteBatch (
                      this.dbConnApp
                    , this.log
                    , this.uInfo
                    , clientid
                    , pracid
                    , ""
                    , "0"
                    , recidmulti );
            },
            Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC);  // Who can call this method           
        }

        /***************************************************************************
         * updateplaninfoall */
        /**
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecordWithJSONData updateplaninfoall (string clientid, string pracid)
        {
            return (ReturnSaveRecordWithJSONData)
            callMethod(typeof(ReturnSaveRecordWithJSONData),
            delegate ()
            {
                return Spedmon.PractitionerPatientCaseloadExpectedServices.updatePlanInfoAll (this.dbConnApp, this.log, this.uInfo, clientid,pracid,"","0");
            },
            Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC);  // Who can call this method           
        }

        /***************************************************************************
         * viewEntity */
        /**
         * load one record
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnEntity viewEntity(string clientid, string pracid, string patid, string recid)
        {
            return (ReturnEntity)
            callMethod(typeof(ReturnEntity),
            delegate ()
            {
                return Spedmon.PractitionerPatientCaseloadExpectedServices.viewEntity(
              this.dbConnApp
            , this.log
            , this.uInfo
            , clientid
            , pracid
            , patid
            , recid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }

        /***************************************************************************
         * getexpectedservicestatsforapractitioner */
        /**
         * Returns stats regarding possible updates and expired schedules
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnObject getexpectedservicestatsforapractitioner (string clientid, string pracid)
        {
            return (ReturnObject)
            callMethod(typeof(ReturnObject),
            delegate ()
            {
                return Spedmon.PractitionerPatientCaseloadExpectedServices.getExpectedServiceStatsForAPractitioner(
              this.dbConnApp
            , this.log
            , this.uInfo
            , clientid
            , pracid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }
        

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecordWithJSONData importdata(
          string clientid
        , string pracid
        , string datatoimportjson
        , string validaterec)
        {
            var retval =  (ReturnSaveRecordWithJSONData)

              callMethod(typeof(ReturnSaveRecordWithJSONData),
                delegate ()
                {
            
                 return Spedmon.PractitionerPatientCaseloadExpectedServices.importData(
                   this.dbConnApp
                 , this.log
                 , this.uInfo
                 , clientid
                 , pracid
                 , datatoimportjson
                 , validaterec
                 );
              },
              Constants.ROLE_ALL);  // Who can call this method

            return retval;
        }

 
    }

}
