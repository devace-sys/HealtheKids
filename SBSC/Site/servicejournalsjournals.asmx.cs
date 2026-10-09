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
   * ServiceJournalsJournalsSvc */
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
  
  public class ServiceJournalsJournalsSvc : MBA.WebSvc
  {

    /***************************************************************************
     * delete */
    /**
     * Delete open journal 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete (
        string editDelReason
      , string validaterec
      , string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.ServiceJournalsJournals.delete (
            this.dbConnApp
          , this.log
          , this.uInfo          
          , editDelReason
          , validaterec
          , recid);                                           
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }                   

    /***************************************************************************
     * saveinline */
    /**
     * Save inline (open new journal or edit header info about existing)
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord saveinline (
         string clientid
       , string pracid
       , string patid
       , string dos
       , string patabsent
       , string savetype
       , string recid )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.ServiceJournalsJournals.save (
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientid
          , pracid
          , patid
          , dos
          , patabsent
          , "" /*editDelReason*/
          , "N" /*validaterec*/
          , savetype
          , recid);                                           
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }

    /***************************************************************************
     * save */
    /**
     * Save journal (open new journal or edit header info about existing)
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (
         string clientid
       , string pracid
       , string patid
       , string dos
       , string patabsent
       , string editDelReason
       , string validaterec
       , string savetype
       , string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.ServiceJournalsJournals.save (
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientid
          , pracid
          , patid
          , dos
          , patabsent
          , editDelReason
          , validaterec
          , savetype
          , recid);                                           
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }
        
    /***************************************************************************
     * close */
    /**
     * Close open journal
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord close (
         string clientid
       , string pracid
       , string patid
       , string editDelReason
       , string validaterec
       , string savetype
       , string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.ServiceJournalsJournals.close (
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientid
          , pracid
          , patid
          , editDelReason
          , validaterec
          , savetype
          , recid);                                           
      },
      Constants.ROLE_SVC_JOURNALS);  // Who can call this method           
    }

    /***************************************************************************
     * reopen */
    /**
     * Reopen closed journal
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord reopen (
         string clientid
       , string pracid
       , string patid
       , string editDelReason
       , string validaterec
       , string savetype
       , string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.ServiceJournalsJournals.reopen (
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientid
          , pracid
          , patid
          , editDelReason
          , validaterec
          , savetype
          , recid);                                           
      },
      Constants.ROLE_SVC_JOURNALS);  // Who can call this method           
    }

    /***************************************************************************
     * reopeninline */
    /**
     * Reopen closed journal
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord reopeninline (
         string clientid
       , string pracid
       , string patid
       , string journalid )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.ServiceJournalsJournals.reopen (
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientid
          , pracid
          , patid
          , @"" /*editDelReason*/
          , "N" /* validaterec */
          , "1" /*savetype*/
          , journalid);                                           
      },
      Constants.ROLE_SVC_JOURNALS);  // Who can call this method           
    }

    /***************************************************************************
     * viewSel */
    /**
     * Selection view of incomplete journals
     * 
     * @param  term         Required, search term string (last, first)
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel (string clientid, string pracid, string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.ServiceJournalsJournals.viewSel(this.dbConnApp, this.log, this.uInfo,true,"",term,clientid,pracid,null,null,"0");
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }         
     
    /***************************************************************************
     * viewUserOpenJournalsList */
    /**
     * Selection view of open journals by prac
     * 
     * @param  term         Required, search term string (last, first)
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnObjects viewUserOpenJournalsList(string clientid, string pracid, string patid, string dos, string getallclientjournalsifpracallowed)
    {
      return (ReturnObjects) 
      callMethod(typeof(ReturnObjects), 
      delegate()
      {
        ReturnObjects ro = new ReturnObjects();
        ro.data = Spedmon.ServiceJournalsJournals.viewUserOpenJournalsList(this.dbConnApp, this.log, this.uInfo,clientid,pracid,patid,dos, getallclientjournalsifpracallowed, "1").ToArray();
        return ro;
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }         
           
  }
}
