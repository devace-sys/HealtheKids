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
   *  ORPDocumentsStandardSelectionNamesSvc  */
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
  
  public class ORPDocumentsStandardSelectionNamesSvc : MBA.WebSvc
  {

    /***************************************************************************
     * delete */
    /**
     * "Deletes" record
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
          return Spedmon.ORPDocumentsStandardSelectionNames.delete(  dbConnApp
                                                                   , log
                                                                   , uInfo
                                                                   , ""
                                                                   , "0"
                                                                   , recid);
        },
        Constants.ROLE_SBS_ALL);  // Who can call this method           
    }
    
    /***************************************************************************
     * save */
    /**
     * Save new or edit existing record
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (
         string clientid
       , string name
       , string groupserviceclassnameid
       , string notes
       , string svcdesctemplatetext   
       , string notecrit1templatetext
       , string notecrit2templatetext
       , string notecrit3templatetext
       , string notecrit4templatetext
       , string notecrit5templatetext
       , string notecrit6templatetext
       , string notecrit7templatetext
       , string notecrit8templatetext
       , string notecrit9templatetext
       , string notecrit10templatetext
       , string allowmultipleorders
       , string ordercontextfieldname
       , string formBuilderContentJSON
       , string formBuilderContentForServiceJournalEntryNotesJSON
       , string serviceJournalAssociatedEventTypeID
       , string editDelReason
       , string validaterec
       , string savetype
       , string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {                     
        return Spedmon.ORPDocumentsStandardSelectionNames.save (                        
            this.dbConnApp
          , this.log
          , this.uInfo   
          , clientid
          , name
          , groupserviceclassnameid
          , notes
          , svcdesctemplatetext   
          , notecrit1templatetext
          , notecrit2templatetext
          , notecrit3templatetext
          , notecrit4templatetext
          , notecrit5templatetext
          , notecrit6templatetext
          , notecrit7templatetext
          , notecrit8templatetext
          , notecrit9templatetext
          , notecrit10templatetext
          , allowmultipleorders
          , ordercontextfieldname
          , formBuilderContentJSON  /* For orders */
          , formBuilderContentForServiceJournalEntryNotesJSON
          , serviceJournalAssociatedEventTypeID
          , editDelReason
          , validaterec
          , savetype
          , recid);                                           
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
    }        		           

    /***************************************************************************
     * viewSel */
    /**
     * Selection view 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSel (   string  groupserviceclassnameid
				               , string  pracid
                               , string  term )
    {
      return (ReturnSel) 
      callMethod (  typeof(ReturnSel)
                  , delegate() { return 
                      Spedmon.ORPDocumentsStandardSelectionNames.viewSel (  this.dbConnApp
                                                                     , this.log
                                                                     , this.uInfo
                                                                     , true
                                                                     , ""
                                                                     , null
                                                                     , groupserviceclassnameid
                                                                     , ""
                                                                     , pracid
                                                                     , term );
      }
      , Constants.ROLE_ALL_PCAL_AND_CLIENT ); // Who can call this method
    } 
    
    /***************************************************************************
     * viewSelForPracID */
    /**
     * Selection view 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSelForPracID (   string  pracid
                                        , string  term )
    {
      return (ReturnSel) 
      callMethod (  typeof(ReturnSel)
                  , delegate() { return 
                      Spedmon.ORPDocumentsStandardSelectionNames.viewSel (  this.dbConnApp
                                                                     , this.log
                                                                     , this.uInfo
                                                                     , true
                                                                     , ""
                                                                     , null
                                                                     , ""
                                                                     , ""
                                                                     , pracid
                                                                     , term );
      }
      , Constants.ROLE_ALL_PCAL_AND_CLIENT ); // Who can call this method
    }
    
    /***************************************************************************
     * viewSelForGroupServiceClassNameID */
    /**
     * Selection view 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSelForGroupServiceClassNameID (   string  groupserviceclassnameid
                                                         , string  clientid
                                                         , string  term )
    {
      return (ReturnSel) 
      callMethod (  typeof(ReturnSel)
                  , delegate() { return 
                      Spedmon.ORPDocumentsStandardSelectionNames.viewSel (  this.dbConnApp
                                                                     , this.log
                                                                     , this.uInfo
                                                                     , true
                                                                     , ""
                                                                     , clientid
                                                                     , groupserviceclassnameid
                                                                     , ""
                                                                     , ""
                                                                     , term );
      }
      , Constants.ROLE_ALL_PCAL_AND_CLIENT ); // Who can call this method
    }
 
  }
}