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

  /***************************************************************************
   * ORPDocumentsSvc */
  /*
   * Web services end point.
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
  
  public class ORPDocumentsSvc : MBA.WebSvc
  {

    /***************************************************************************
     * viewSel */
    /**
     * Selection view 
     * Returns patient orders that cover a date of service
     * Used on multi pat multi svc service records entry screen for selection if
     * applicable
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSel viewSel (string clientid, string pracid, string patid, string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel)
      , delegate() { return 
        Spedmon.ORPDocuments.viewSel (   this.dbConnApp
                                       , this.log
                                       , this.uInfo
                                       , true
                                       , ""
                                       , clientid
                                       , pracid
                                       , patid   
                                       , null
                                       , term
                                       , false);}
      , Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }


    /***************************************************************************
     * viewSelOnlyOrdersAndProfiles */
    /**
     * Selection view 
     * Returns patient orders that cover a date of service
     * Used on multi pat multi svc service records entry screen for selection if
     * applicable
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSel viewSelOnlyOrdersAndProfiles (string clientid, string pracid, string patid, string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel)
      , delegate() { return 
        Spedmon.ORPDocuments.viewSel (   this.dbConnApp
                                       , this.log
                                       , this.uInfo
                                       , true
                                       , ""
                                       , clientid
                                       , pracid
                                       , patid   
                                       , "2,3"
                                       , term
                                       , true);}
      , Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }


    /***************************************************************************
     * viewselordersandprofilesforclientgroupSvcclasspatsvc */
    /**
     * Selection view 
    ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSel viewselordersandprofilesforclientgroupSvcclasspatsvc (
              string clientid
            , string groupserviceclassnameid
            , string patid
            , string orpdocstdnameselid )
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel)
            , delegate () {
                return
                    Spedmon.ORPDocuments.viewSelOrdersAndProfilesForClientGroupSvcClassPatSvc(
                              this.dbConnApp
                            , this.log
                            , this.uInfo
                            , true
                            , ""
                            , clientid
                            , groupserviceclassnameid
                            , patid
                            , orpdocstdnameselid);
                           
            }
            , Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }

        /***************************************************************************
         * viewSelForJournalEntry */
        /**
         * Selection view 
         * TODO: This may not be used anymore.  Check and remove if so.
         ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSel viewSelForJournalEntry (string clientid, string pracid, string patid, string term, string orpdoctypeid)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel)
      , delegate() { return 
        Spedmon.ORPDocuments.viewSelForJournalEntry (  this.dbConnApp
                                                     , this.log
                                                     , this.uInfo
                                                     , true
                                                     , ""
                                                     , clientid
                                                     , pracid
                                                     , patid
                                                     , term
                                                     , orpdoctypeid );}
      , Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * deleteOrderOrProfile */
    /**
     * "Deletes" order
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/  

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord deleteOrderOrProfile (string editDelReason,
                                    string recid)
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),    
        delegate() {    
          return Spedmon.ORPDocuments.deleteOrderOrProfile(       dbConnApp
                                                                , log
                                                                , uInfo
                                                                , editDelReason
                                                                , "0"
                                                                , recid);
        },
        Constants.ROLE_SVC_SUP_PRAC);  // Who can call this method           
    }

    /***************************************************************************
     * delete */
    /**
     * "Deletes" order
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/  

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete (string recid)
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),    
        delegate() {    
          return Spedmon.ORPDocuments.deleteOrderOrProfile(       dbConnApp
                                                                , log
                                                                , uInfo
                                                                , ""
                                                                , "0"
                                                                , recid);
        },
        Constants.ROLE_SVC_SUP_PRAC);  // Who can call this method           
    }

    /***************************************************************************
     * viewSelPatOrdersForDos */
    /**
     * Returns patient orders that cover a date of service
     * Used on multi pat multi svc service records entry screen for pracs to 
     * check for expiring orders
     ***************************************************************************/  

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSelPatOrdersForDos (string recid
                                                  , string clientid
                                                  , string pracid
                                                  , string patid
                                                  , string dos)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel),    
        delegate() {    
          return Spedmon.ORPDocuments.viewSelPatOrdersForDos(     dbConnApp
                                                                , log
                                                                , uInfo
                                                                , clientid
                                                                , pracid
                                                                , patid
                                                                , dos
                                                                , recid);
        },
        Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }
  }
}
