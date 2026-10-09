using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Collections.Specialized;
using System.Collections;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * ServiceNotes */
  /**
   * Methods used to work with service notes
   ****************************************************************************/

  public class ServiceNotes
  {

        
    /***************************************************************************
     * GenerateUrlClientProvViewNotesToSave */
    /**
     * 
     ****************************************************************************/
         
    public static string GenerateUrlClientProvViewNotesToSave (string entryExit, int entryTypeVal)
    {
      string entryPage = ServiceRecords.WhatSvcRecPage(Constants.USER_GROUP_CLIENT, Constants.ROLE_LEA_PROVIDER_ID,entryTypeVal, true);                    
      return GenerateUrlViewNotesToSave(ServiceNoteCommon.PAGE_CLIENT_PROV_SVC_NOTES_SAVE, entryExit, entryPage, entryTypeVal);
    }
        
    /***************************************************************************
     * GenerateUrlViewNotesToSave */
    /**
     * 
     ****************************************************************************/
         
    protected static string GenerateUrlViewNotesToSave (string notesPage, string entryExit, string originPage, int entryTypeVal)
    {
      string url = MBA.HttpApplication.createLink (   notesPage
                                                    , true
                                                    , new NameValue(ServiceRecordEntryExitRequest.SVC_REC_ENTRY_EXIT_PARM, entryExit) 
                                                    , new NameValue(ServiceRecordEntryExitRequest.SVC_REC_ENTRY_EXIT_PARM_ENTRY_TYPE, entryTypeVal.ToString())                                                      
                                                    , new NameValue(ServiceNoteCommon.SVC_NOTE_PARM_ORG_PAGE, originPage));
      return url;
    }

    
    
    
    /***************************************************************************
     * load */
    /**
     * 
     ****************************************************************************/
             
    public static ServiceNote load (  SqlConnection        connSpedmon
                                     , DetailsLog          log
                                     , UserInfo            uInfo
                                     , NameValueCollection httpRequestParms)
   {

     string clientIDStr   = httpRequestParms[ServiceNoteCommon.SVC_NOTE_PARM_CLIENT_ID];
     string pracIDStr     = httpRequestParms[ServiceNoteCommon.SVC_NOTE_PARM_PRAC_ID];
     string noteidStr     = httpRequestParms[ServiceNoteCommon.SVC_NOTE_PARM_NOTE_ID];
     string questionIDStr = httpRequestParms[ServiceNoteCommon.SVC_NOTE_PARM_QUESTION_ID];
            
     int    clientIDVal   = Validate.reqClientID (uInfo,clientIDStr);
     int    pracIDVal     = Validate.reqPracID   (uInfo,pracIDStr);
     long   noteidVal     = Validate.reqInteger  (noteidStr, @"Invalid note id", false);
     
     long?  questionIDVal = (long?) Validate.optInteger(questionIDStr, @"Invalid question id", false);
     
     return load(connSpedmon, log, uInfo, clientIDVal, pracIDVal, noteidVal, questionIDVal);
     
   } 
    
    /***************************************************************************
     * load */
    /**
     * 
     ****************************************************************************/

    public static ServiceNote load (   SqlConnection connSpedmon
                                     , DetailsLog    log
                                     , UserInfo      uInfo
                                     , long          clientID
                                     , long          pracID
                                     , long          noteID
                                     , long?         questionID)
    {
      ServiceNote servicenote = new ServiceNote();
      List<ServiceNote> servicenotes = ServiceNotes.view(connSpedmon, log, uInfo, clientID, pracID, noteID, questionID, null,null);
      if (servicenotes.Count == 1) servicenote = servicenotes[0]; 
      return servicenote;
    }

    /***************************************************************************
     * viewIncompleteNotes */
    /**
     * 
     ****************************************************************************/

    public static List<ServiceNote> viewIncompleteNotes (   SqlConnection connSpedmon
                                                          , DetailsLog    log
                                                          , UserInfo      uInfo
                                                          , int           clientID
                                                          , int           pracID
                                                          , out int       numNotes)
    {
          
      numNotes = 0;
      List<ServiceNote> l = view (connSpedmon, log, uInfo,  clientID, pracID, null, null, false, true);
      numNotes = l.Count;
      return l;        
    }
        
    /***************************************************************************
     * view */
    /**
     * 
     ****************************************************************************/

    public static List<ServiceNote> view (   SqlConnection connSpedmon
                                           , DetailsLog log
                                           , UserInfo uInfo
                                           , long clientID
                                           , long pracID
                                           , long? noteID
                                           , long? questionID
                                           , bool? completed
                                           , bool? active)
    {

      string sql = @"SELECT * FROM dbo.SVCNOTES_NOTES_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @noteID, @questionID ,@completed ,@active)";

      List<ServiceNote>  servicenotes = new List<ServiceNote>();
      List<SqlParameter> parms        = new List<SqlParameter>();

      Object vNoteID     = (noteID.HasValue     == true) ? (Object)noteID.Value     : null;
      Object vQuestionID = (questionID.HasValue == true) ? (Object)questionID.Value : null;
      Object vCompleted  = (completed.HasValue  == true) ? (Object)completed.Value  : null;
      Object vActive     = (active.HasValue     == true) ? (Object)active.Value     : null;
            
      parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt, uInfo.userid,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",  SqlDbType.Int,    uInfo.userGroup,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",   SqlDbType.Int,    uInfo.userRank,   ParameterDirection.Input));

      parms.Add(Database.SqlParm("@clientID",   SqlDbType.BigInt, clientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",     SqlDbType.BigInt, pracID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@noteID",     SqlDbType.BigInt, vNoteID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@questionID", SqlDbType.BigInt, vQuestionID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@completed",  SqlDbType.Bit,    vCompleted,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@active",     SqlDbType.Bit,    vActive,     ParameterDirection.Input));
            
      ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      Object[] lo = Database.convertRecords(rd.records, typeof(ServiceNote));

      foreach (Object o in lo)
      {
        ServiceNote n = (ServiceNote)o;
        servicenotes.Add(n);
      }

      return servicenotes;

    }
  }

    
    
    /***************************************************************************
     * ServiceNotesToSaveListRequest */
    /**
     * Request 
     ****************************************************************************/

    public class ServiceNotesSaveRequest : Return
    {
      public bool   needToRedirect = false;
      public string html           = "";
      public string newURL         = "";
      public string homeURL        = Constants.HOME_PRIVATE;
      public string originPage     = "";
      public int    entryType      = 0;
      public string entryExit      = "";
      public int    numNotes       = 0;
        
      public List<ServiceNote> servicenotes = new List<ServiceNote>();


      /***************************************************************************
       * process */
      /**
       * Process page request
       ****************************************************************************/

      public void process ( SqlConnection connSpedmon
                          , DetailsLog log
                          , UserInfo uInfo
                          , NameValueCollection httpRequestParms)
      {
        
        string originPageStr = httpRequestParms[ServiceNoteCommon.SVC_NOTE_PARM_ORG_PAGE];
        string clientIDStr   = httpRequestParms[ServiceNoteCommon.SVC_NOTE_PARM_CLIENT_ID];
        string pracIDStr     = httpRequestParms[ServiceNoteCommon.SVC_NOTE_PARM_PRAC_ID];
        string entryTypeStr  = httpRequestParms[ServiceRecordEntryExitRequest.SVC_REC_ENTRY_EXIT_PARM_ENTRY_TYPE];
        string entryExitStr  = httpRequestParms[ServiceRecordEntryExitRequest.SVC_REC_ENTRY_EXIT_PARM];        

        int    pracIDVal     = Validate.reqPracID   (uInfo, pracIDStr);
        int    clientIDVal   = Validate.reqClientID (uInfo, clientIDStr);
        int    entryType     = Validate.reqInteger (entryTypeStr,  @"Invalid service entry type",true);
        string originPageVal = Validate.reqString  (originPageStr, @"Invalid origin page");
        string entryExitVal  = Validate.reqString  (entryExitStr,  @"Invalid entry exit");
          
        this.originPage = originPageVal;
        this.entryType  = entryType;
        this.entryExit  = entryExitVal;
        
        int numNotes      = 0;          
        this.servicenotes = ServiceNotes.viewIncompleteNotes(connSpedmon, log, uInfo, clientIDVal, pracIDVal, out numNotes);
        this.numNotes     = numNotes;
          
        // No notes redirect
          
        /*if (numNotes == 0)
        {
          this.needToRedirect = true;
          this.newURL = MBA.HttpApplication.createLink(this.originPage, true);
        }*/
        
        // Show notes
          
        html = generateSelectNoteToSaveListView();
          
      }
        
      /***************************************************************************
       * generateSelectNoteToSaveListView */
      /**
       * Generate HTML for 
       ****************************************************************************/

      public string generateSelectNoteToSaveListView ()
      {
        StringBuilder sb = new StringBuilder();
          
        sb.Append(@"<h2 style=""text-align:center"">Select One Of The Remaining Service Records That Require Notes</h2>");          
        sb.Append(@"<ul data-role=""listview"" data-inset=""true"" data-ajax=""false"">");
          
        foreach (ServiceNote servicenote in servicenotes)
        {
          sb.Append(@"<li>");
          sb.Append(servicenote.GenerateLoadLink(originPage, entryExit, entryType));
          sb.Append(@"</li>");
        }
        sb.Append(@"</ul>");
        return sb.ToString();       
      }
    }    

}
