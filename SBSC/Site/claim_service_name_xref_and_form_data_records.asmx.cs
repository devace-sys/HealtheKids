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
     * ClaimServiceNameXrefAndFormDataRecordsSvc */
    /*
     * Web services end point for Claim Service methods
     *
     * Unless indicated, each of these methods require that the caller is
     * logged in.
     *
     * Each end point method provides a wrapper for a coresponding framework
     * method that is not accessible from the outside.
     *
     * These wrappers handle access control and parameter replacement.
     *
     * The method is restricted to calls for given user groups
     *
     * Parameter replacement is used to enforce additional access control within
     * the user group but this is limited.
     *
     * The final line of defense for access control are the database udfs or
     * sprocs that return or save data
     ***************************************************************************/

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]
    public class ClaimServiceNameXrefAndFormDataRecordsSvc : MBA.WebSvc
    {
        //
        public ClaimServiceNameXrefAndFormDataRecordsSvc() : base() { }

        /***************************************************************************
         * save */
        /**
         *
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord save(
             string clientid
           , string plantypeid
           , string groupid
           , string nameid
           , string formdatajson
           , string haspatientgoaltracking
           , string hassessionratingtracking
           , string spedsvccodevalue
           , string fillablepdfselectionsjson
           , string savetype
           , string recid)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ClaimServiceNameXrefAndFormDataRecords.save(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , plantypeid
                , groupid
                , nameid
                , formdatajson
                , haspatientgoaltracking
                , hassessionratingtracking
                , spedsvccodevalue
                , fillablepdfselectionsjson
                , ""
                , "0"
                , savetype
                , recid);
            },
            Constants.ROLE_CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_ADMIN);  // Who can call this method          
        }

        /***************************************************************************
        * loadN */
        /**
         *
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnEntity loadN(string clientid
                                   , string plantypeid
                                   , string groupid
                                   , string nameid)
        {
            return (ReturnEntity)
            callMethod(typeof(ReturnEntity),
            delegate ()
            {
                ReturnEntity re = new ReturnEntity();
                re.entity = Spedmon.ClaimServiceNameXrefAndFormDataRecords.loadN(
                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , 0
                  , clientid
                  , plantypeid
                  , groupid
                  , nameid);

                return re;
            },
            Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC); // Who can call this method    
        }

        /***************************************************************************
         * deletemultiinline */
        /**
         *        
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord deletemultiinline(   string recids  )
        {
            return (ReturnSaveRecord)callMethod(
                typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.ClaimServiceNameXrefAndFormDataRecords.deleteMulti(
                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , ""
                  , "0"
                  , recids);
                },
                Constants.ROLE_CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_ADMIN);
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord deleteinline ( string recid )
        {
          return (ReturnSaveRecord) 
     
         callMethod(typeof(ReturnSaveRecord),       
         delegate()
         {                     
           return Spedmon.ClaimServiceNameXrefAndFormDataRecords.delete (                        
              this.dbConnApp
            , this.log
            , this.uInfo   
            , ""
            , "N"
            , recid);                                           
        },
        Constants.ROLE_CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_ADMIN);  
      }



        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord multiclone ( string recids, string clientidforclones )  //
        {
            return (ReturnSaveRecord)callMethod(
                typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.ClaimServiceNameXrefAndFormDataRecords.cloneMulti(
                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , ""
                  , "0"
                  , recids
                  , clientidforclones);
                },
                Constants.ROLE_CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_ADMIN);
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord saveformjsonmulti( string recids, string updatedformjson ) { 

            return (ReturnSaveRecord)callMethod(
                typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.ClaimServiceNameXrefAndFormDataRecords.saveFormJsonMulti(
                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , ""
                  , "0"
                  , recids
                  , updatedformjson);
                },
                Constants.ROLE_CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_ADMIN);
        }

    }
}
