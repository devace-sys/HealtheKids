using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
      
  /***************************************************************************
   * NoteLibraryTemplate */
  /**
   * 
   ***************************************************************************/
  
  public class NoteLibraryTemplate
  {
    public long   id;
    public string name;
    public string notes;
  }
    
  
  /***************************************************************************
   * NoteLibraryTemplates */
  /**
   * 
   ***************************************************************************/

  public class NoteLibraryTemplates: Entities
	{
            
   /***************************************************************************
    * view */
   /**
    * Returns a list of templates
    * 
    ***************************************************************************/   

    public static ReturnDB view (

        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , int           recViewType
      , bool          pagedOrTop
      , string        idx
      , string        canEdit
      , string        active
      , string        notenamespace
      , string        notesource
      , string        clientID
      , string        pracID
      , string        patID
      , string        referenceDate
      , string        term
      , defineCols    dc )

    { 
      
      string viewUDF = "NOTE_LIBRARY_TEMPLATES_VIEW (@userID, @userGroup, @userRank, @noteOwner, @noteNamespace, @noteSource, @clientID, @pracID, @patID, @referenceDate, @term, @active, @recID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/  
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      long     vNoteOwner       = uInfo.userid;
      string   vNoteNamespace   = Validate.reqString   (notenamespace, @"Namespace is required");
      string   vNoteSource      = Validate.reqString   (notesource,    @"Source is required");
      long     vClientID        = Validate.reqClientID (uInfo, clientID);
      long     vPracID          = Validate.reqPracID   (uInfo, pracID);
      Object   vPatID           = Validate.optInteger  (patID,         Messages.PATIENT_ID_BAD);
      DateTime vReferenceDate   = Validate.reqDate     (referenceDate, @"Invalid reference date");      
      string   vTerm            = Validate.optString   (term,          @"Invalid term");    
      
      parms.Add(Database.SqlParm("@noteOwner",     SqlDbType.BigInt,   vNoteOwner,     ParameterDirection.Input));          
      parms.Add(Database.SqlParm("@noteNamespace", SqlDbType.VarChar,  vNoteNamespace, ParameterDirection.Input,500));
      parms.Add(Database.SqlParm("@noteSource",    SqlDbType.VarChar,  vNoteSource,    ParameterDirection.Input,500));
      parms.Add(Database.SqlParm("@clientID",      SqlDbType.BigInt,   vClientID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",        SqlDbType.BigInt,   vPracID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",         SqlDbType.BigInt,   vPatID,         ParameterDirection.Input));           
      parms.Add(Database.SqlParm("@referenceDate", SqlDbType.Date,     vReferenceDate, ParameterDirection.Input));           
      parms.Add(Database.SqlParm("@term",          SqlDbType.VarChar,  vTerm,          ParameterDirection.Input,100));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
      
      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }  

    /***************************************************************************
     * viewSel */
    /**
     * List of templates
     * 
     ****************************************************************************/       

    public static ReturnSel viewSel (
      SqlConnection connSpedmon
    , DetailsLog    log
    , UserInfo      uInfo
    , bool          top
    , string        topSize
    , string        notenamespace
    , string        notesource
    , string        clientID
    , string        pracID
    , string        patID
    , string        referenceDate
    , string        term ) {
             
      /*----------------------------
       * Define our context column
       *----------------------------*/

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){
        ss.addDisplayColumn("notes as notes");
     };
     
     /*----------------------------
      * Call base method which
      * handles the rest and return
      * results
      *----------------------------*/

     return Entities.viewSel(connSpedmon, log, uInfo ,top, topSize, 
     delegate{return NoteLibraryTemplates.view(connSpedmon,log,uInfo,Entities.REC_VIEW_SEL, top, topSize,"","1", notenamespace,notesource,clientID, pracID, patID, referenceDate, term,dc);});

   }                       

 } 
}

