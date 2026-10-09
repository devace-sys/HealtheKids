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
   * NoteLibrarySavedNoteSvc */
  /*
   * Web services end point for note helper saved note methods
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
  
  public class NoteLibrarySavedNoteSvc : MBA.WebSvc
  {
    /***************************************************************************
     * delete */
    /**
     * "delete" a saved note
     * 
     * @param  validaterec   Required, True=Yes, False=No
     * @param  editDelReason Reason for delete
     * @param  recid         Record id to delete
     ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete (
      string editDelReason,
      string validaterec,
      string recid )
    {
    return (ReturnSaveRecord)
    callMethod(typeof(ReturnSaveRecord),    
    delegate()
    {    
      return Spedmon.NoteLibrarySavedNotes.delete(
        this.dbConnApp,
        this.log,
        this.uInfo,
        editDelReason,
        validaterec,
        recid);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }

  
   /***************************************************************************
    * save */
    /**
    * Save saved note
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (
      string notenamespace,
      string notesource,
      string clientid,
      string pracid,
      string patid,
      string notetext,
      string editDelReason,
      string validaterec,
      string savetype,
      string recid )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.NoteLibrarySavedNotes.save
         (this.dbConnApp,
          this.log,
          this.uInfo,
          notenamespace,
          notesource,
          clientid,
          pracid,
          patid,
          notetext,
          editDelReason,
          validaterec,
          savetype,
          recid);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }
    
    /***************************************************************************
     * viewSel */
    /**
     * Selection view of saved notes
     * 
     * @param  term         Required, search term string (last, first)
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel (
        string notenamespace
      , string notesource
      , string clientid
      , string pracid
      , string patid
      , string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.NoteLibrarySavedNotes.viewSel(this.dbConnApp, this.log, this.uInfo,true,"",notenamespace,notesource,clientid,pracid,patid,term);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }
  }
}
