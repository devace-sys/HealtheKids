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
   * ServiceJournalsJournalEntriesSvc */
  /*
   * Web services end point for Publication methods.
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
  
  public class ServiceJournalsJournalEntriesSvc : MBA.WebSvc
  {

    /***************************************************************************
     * save */
    /**
     * Save journal entry
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (
         string clientid
       , string pracid
       , string patid
       , string iep
       , string journalid
       , string eventid
       , string starttime
       , string endtime
       , string orpDocID
       , string notes
       , string svcNotesFormBuilderQuestionsJSON
       , string svcNotesFormBuilderAnswersJSON
       , string noteCriteriaQuestionsJSON
       , string noteCriteriaAnswersJSON
       , string editDelReason
       , string validaterec
       , string savetype
       , string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {          
        return Spedmon.ServiceJournalsJournalEntries.save (
            this.dbConnApp
          , this.log
          , this.uInfo
          , rd.userIP
          , rd.userAgent
          , clientid
          , pracid
          , patid
          , iep
          , journalid
          , eventid
          , starttime
          , endtime
          , orpDocID
          , notes
          , svcNotesFormBuilderQuestionsJSON
          , svcNotesFormBuilderAnswersJSON
          , noteCriteriaQuestionsJSON
          , noteCriteriaAnswersJSON
          , editDelReason
          , validaterec
          , savetype
          , recid);                                           
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }
     
    /***************************************************************************
     * saveinline */
    /**
     * Save journal entry inline
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord saveinline (
         string clientid
       , string pracid
       , string patid
       , string iep
       , string journalid
       , string eventid
       , string starttime
       , string endtime
       , string orpDocID
       , string notes
       , string svcNotesFormBuilderQuestionsJSON
       , string svcNotesFormBuilderAnswersJSON
       , string noteCriteriaQuestionsJSON
       , string noteCriteriaAnswersJSON
       , string savetype
       , string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {          
        return Spedmon.ServiceJournalsJournalEntries.save (
            this.dbConnApp
          , this.log
          , this.uInfo
          , rd.userIP
          , rd.userAgent
          , clientid
          , pracid
          , patid
          , iep
          , journalid
          , eventid
          , starttime
          , endtime
          , orpDocID
          , notes
          , svcNotesFormBuilderQuestionsJSON
          , svcNotesFormBuilderAnswersJSON
          , noteCriteriaQuestionsJSON
          , noteCriteriaAnswersJSON
          , "" /*editDelReason*/
          , "N" /*validaterec*/
          , savetype
          , recid);                                           
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }
        
   /***************************************************************************
    * delete */
   /**
    * "delete" a record.
    * 
    * @param  recid         Record id to delete
    ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete ( string journalid,
                                     string pracid,
                                     string recid)
    {
    return (ReturnSaveRecord)
    callMethod(typeof(ReturnSaveRecord),    
    delegate()
    {    
      return Spedmon.ServiceJournalsJournalEntries.delete(this.dbConnApp,
                                         this.log,
                                         this.uInfo,
                                         "",
                                         "0",
                                         journalid,
                                         pracid,
                                         recid);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }
  }
}
