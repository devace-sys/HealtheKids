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
   * ServiceNote */
  /**
   * Formatted service note base record
   ****************************************************************************/

  public class ServiceNote
  {
    public long     noteID;
    public long     clientID;
    public long     pracID;
    public long     patID;
    public DateTime noteForDos;
    public string   noteFromClient;
    public string   noteFromPractitioner;
    public string   noteForPatient;
    public long     noteTypeID;
    public string   noteTypeName;
    public long     questionID;
    public long     dfltQuestionID;
    public long     prevQuestionID;
    public long     currQuestionID;
    public long     nextQuestionID;
    public long     lastQuestionID;
    public DateTime noteCreatedOn;
    public bool     noteCompleted;
    public DateTime noteCompletedOn;
    public bool     noteActive;
    public string   noteText;
    public string   noteStatusText;
    public Guid     noteRefKey;
    public long     svcRecID;
    public bool     canDeleteNoteAndSvcRec;
    
    public ServiceNote()
    {
    }  

    /***************************************************************************
     * GenerateLoadLink */
    /**
     * Generate a link to note
     ****************************************************************************/

    public string GenerateLoadLink (string originUrl, string entryExit, int entryType)
    {
      string url = GenerateSaveUrl (entryExit, entryType, originUrl);
        
      StringBuilder sb = new StringBuilder();

      sb.Append(@"<a href=""" + url + @""">");
      sb.Append(@"<h3>");
      sb.Append(this.noteText);
      sb.Append(@"</h3>");
      sb.Append(@"<p>");           
      sb.Append(this.noteStatusText);      
      sb.Append(@"</p>");
      sb.Append(@"</a>");
      return sb.ToString();
    }

    /***************************************************************************
     * GenerateBackURL */
    /**
     * Generate URL to note
     ****************************************************************************/
    
    public string GenerateBackUrl(string entryExit, int entryType, string originUrl)
    {
      if (prevQuestionID != 0)
      {
        return GenerateSaveUrl(ServiceNoteCommon.NoteRequestMode.LOAD, entryExit, prevQuestionID, entryType, originUrl);
      }
      else
        return "";
    }
    
    /***************************************************************************
     * GenerateForwardURL */
    /**
     * Generate URL to note
     ****************************************************************************/
     
    public string GenerateForwardUrl(string entryExit, int entryType, string originUrl)
    {
      if (nextQuestionID != 0)      
        return GenerateSaveUrl(ServiceNoteCommon.NoteRequestMode.LOAD, entryExit, nextQuestionID, entryType, originUrl);
      else
        return "";
    }

    /***************************************************************************
     * GenerateSaveURL */
    /**
     * Generate URL to note
     ****************************************************************************/

    public string GenerateSaveUrl(string entryExit, int entryType, string originUrl)
    {
      return GenerateSaveUrl(ServiceNoteCommon.NoteRequestMode.LOAD, entryExit, questionID, entryType, originUrl);
    }
    
   
    public string GenerateSaveUrl(ServiceNoteCommon.NoteRequestMode mode, string entryExit, long questionID, int entryType, string originUrl)
    {                 
      string url = MBA.HttpApplication.createLink (  ServiceNoteCommon.PAGE_CLIENT_PROV_SVC_NOTE_SAVE
                                                   , true
                                                   , new NameValue(ServiceNoteCommon.SVC_NOTE_PARM_NOTE_ID, noteID.ToString())
                                                   , new NameValue(ServiceNoteCommon.SVC_NOTE_PARM_QUESTION_ID, questionID.ToString())
                                                   , new NameValue(ServiceNoteCommon.SVC_NOTE_PARM_MODE, mode.GetHashCode().ToString())
                                                   , new NameValue(ServiceRecordEntryExitRequest.SVC_REC_ENTRY_EXIT_PARM, entryExit)
                                                   , new NameValue(ServiceRecordEntryExitRequest.SVC_REC_ENTRY_EXIT_PARM_ENTRY_TYPE, entryType.ToString())
                                                   , new NameValue(ServiceNoteCommon.SVC_NOTE_PARM_ORG_PAGE, originUrl));
      return url;
    }
  }    
}
