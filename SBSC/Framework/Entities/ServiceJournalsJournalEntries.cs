using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

  /***************************************************************************
   * ServiceJournalJournalEntry */
  /**
   * Service Journal Journal Entry
   **************************************************************************/

  public class ServiceJournalJournalEntry
  {
    public long     id;    
    public string   entryName;  
    public long     journalID;      
    public long     clientID;
    public string   clientName;
    public long     pracID;
    public string   pracName;
    public long     patID;
    public string   patName;    
    public bool     iep;
    public long     eventID;
    public string   eventLabel;
    public string   dos;
    public string   startTime;
    public string   endTime;
    public TimeSpan startTimeVal;
    public TimeSpan endTimeVal;    
    public string   startTimeEndTimeLabel;
    public long     orpDocID;
    public string   orpDocName;
    public bool     reqORPDoc;
    public bool     reqStartTime;
    public bool     reqEndTime;
    public string   notes;
    public bool     canEdit;
    public bool     active;
    public string   dosStr;

    public string   entryNotesFormBuilderQuestionsJSON;
    public string   entryNotesFormBuilderAnswersJSON;
    public string   entryNotesFormBuilderText;

    public string   noteCriteriaQuestionsJSON;
    public string   noteCriteriaAnswersJSON;
    public string   noteCriteriaText;

    public string   entryNotesFormBuilderTextAndNoteCritTextAndNotes;
  }
  
  /***************************************************************************
   * ServiceJournalsJournalEntries */
  /**
   * Methods to work with service journal journal entries
   **************************************************************************/

  public class ServiceJournalsJournalEntries:Entities
  {          
    public static string URL_SVC           = @"servicejournalsjournalentries.asmx";
    public static string URL_SVC_SAVE_INLINE    = URL_SVC + @"/saveinline";

    /***************************************************************************
     * URL_SVC_SAVE_JOURNAL_AND_JOURNAL_ENTRY_INLINE_BASE */
    /**
     * 
     **************************************************************************/  

    public static string URL_SVC_SAVE_INLINE_BASE()
    {
      return MBA.HttpApplication.createLink(ServiceJournalsJournalEntries.URL_SVC_SAVE_INLINE, true);     
    }

    /***************************************************************************
     * save */
    /**
     * Save a service journal journal entry
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Client id
     * @param  pracID          Practitioner id
     * @param  patID           Patient id
     * @param  DOS             Date of service
     * @param  SvcType         Type of service
     * @param  editDelReason   Reason for record edit or delete
     * @param  validateRec     1 = Performs data integrity validation tasks
     *                             Perform advisory validation tasks that can
     *                             only be conducted by referencing data from the
     *                             database and then exits WITHOUT saving the record
     *                         0 = Peform data integrity validation tasks and
     *                             if these tasks succeed peforms the desired
     *                             operation (saveType) on the record and exits
     * @param  saveType        Type of operation to perform
     *                         1 = New, 2 = Edit, 3 = Delete
     * @param  recID           Record id of existing patient record to edit or
     *                         delete.
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord save (    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        requestIP
      , string        requestUserAgent
      , string        clientID
      , string        pracID
      , string        patID
      , string        iep
      , string        journalID       
      , string        eventType
      , string        startTime
      , string        endTime
      , string        orpDocID
      , string        notes
      , string        svcNotesFormBuilderQuestionsJSON
      , string        svcNotesFormBuilderAnswersJSON
      , string        noteCriteriaQuestionsJSON
      , string        noteCriteriaAnswersJSON
      , string        editDelReason
      , string        validateRec
      , string        saveType
      , string        recID )
    {           
                
      List<SqlParameter> parms  = new List<SqlParameter>();

      /*----------------------------
       * Validate required values
       * for entry
       *----------------------------*/      
      
      int       vClientID       = Validate.reqClientID  (uInfo, clientID);
      int       vPracID         = Validate.reqPracID    (uInfo,  pracID);
      int       vPatID          = Validate.reqInteger   (patID,       Messages.INVALID_PAT_ID);            
      bool      vIEP            = Validate.reqFlag      (iep,         Messages.IFSP_IEP_FLAG_BAD);
      int       vJournalID      = Validate.reqInteger   (journalID,   @"Invalid journal id");
      int       vEventType      = Validate.reqInteger   (eventType,   @"Invalid event type");
      string    vNotes          = Validate.optString    (notes,       @"Notes are required");
      string    vSvcNotesFormBuilderQuestionsJSON = Validate.optString (svcNotesFormBuilderQuestionsJSON, @"Invalid form questions JSON");
      string    vSvcNotesFormBuilderAnswersJSON   = Validate.optString (svcNotesFormBuilderAnswersJSON,   @"Invalid form answers JSON");
      string    vNoteCriteriaQuestionsJSON        = Validate.optString (noteCriteriaQuestionsJSON,        @"Invalid note crit JSON");
      string    vNoteCriteriaAnswersJSON          = Validate.optString (noteCriteriaAnswersJSON,          @"Invalid note crit JSON");
      
      /*----------------------------
       * Get event selection data
       *----------------------------*/      

      ServiceJournalEventSelection eventSelection = ServiceJournalsJournalEventSelections.getEventSelectionData(connSpedmon,log,uInfo,eventType,journalID,pracID);
      
      /*----------------------------
       * Determine if start time
       * and end time are
       * required
       *----------------------------*/      

      TimeSpan vStartTime = TimeSpan.MinValue;
      TimeSpan vEndTime   = TimeSpan.MaxValue;
      
      if (eventSelection.reqStartTime)  vStartTime  = Validate.reqTime  (startTime, @"Missing or invalid start time");           
      if (eventSelection.reqEndTime)    vEndTime    = Validate.reqTime  (endTime,   @"Missing or invalid end time");
      
      if (!eventSelection.reqStartTime) vStartTime  = vEndTime;
      if (!eventSelection.reqEndTime)   vEndTime    = vStartTime;
                       
      // TODO: Conditionlly validate ORP doc ID when time is right
      Object  vOrpDocID = Validate.optInteger (orpDocID, Messages.INVALID_ORP_DOC_ID, true);
      
      /*----------------------------
       * Check start and end time
       *----------------------------*/      

      if ((eventSelection.reqStartTime) && (eventSelection.reqEndTime))
      {
        int compareResult = TimeSpan.Compare(vStartTime,vEndTime);
        if (compareResult == 0) throw new Critical(@"Start and end time cannot be the same");
        if (compareResult == 1) throw new Critical(@"Start time is greater than end time");        
      }           
      
      /*----------------------------
       * Check if notes OR form answers
       * are filled
       *----------------------------*/

      if (String.IsNullOrEmpty(vNotes) && vSvcNotesFormBuilderAnswersJSON == "{}" && vNoteCriteriaAnswersJSON == "{}")
      { 
        throw new Critical(@"Notes are required (unless the form is filled out)");
      }
      
      parms.Add(Database.SqlParm("@clientID",     SqlDbType.Int,      vClientID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",       SqlDbType.Int,      vPracID,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",        SqlDbType.Int,      vPatID,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@iep",          SqlDbType.Bit,      vIEP,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@journalID",    SqlDbType.Int,      vJournalID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@eventType",    SqlDbType.Int,      vEventType,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startTime",    SqlDbType.Time,     vStartTime,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endTime",      SqlDbType.Time,     vEndTime,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@orpDocID",     SqlDbType.BigInt,   vOrpDocID,        ParameterDirection.Input));                
      parms.Add(Database.SqlParm("@notes",        SqlDbType.VarChar,  vNotes,           ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@svcNotesFormBuilderQuestionsJSON", SqlDbType.VarChar, vSvcNotesFormBuilderQuestionsJSON, ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@svcNotesFormBuilderAnswersJSON",   SqlDbType.VarChar, vSvcNotesFormBuilderAnswersJSON,   ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@noteCriteriaQuestionsJSON",        SqlDbType.VarChar, vNoteCriteriaQuestionsJSON,        ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@noteCriteriaAnswersJSON",          SqlDbType.VarChar, vNoteCriteriaAnswersJSON,          ParameterDirection.Input, -1));
     
      parms.Add(Database.SqlParm("@requestIP",          SqlDbType.VarChar,  requestIP,        ParameterDirection.Input,1000));
      parms.Add(Database.SqlParm("@requestUserAgent",   SqlDbType.VarChar,  requestUserAgent, ParameterDirection.Input,8000));
      
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "SVCJOURNAL_JOURNAL_ENTRY_SAVE", @"Service journal entry for this date time already exists", ref parms,null);

    }     

    /***************************************************************************
     * view */
    /**
     * 
     **************************************************************************/  
    
    public static ReturnDB view (SqlConnection connSpedmon, 
                                 DetailsLog    log, 
                                 UserInfo      uInfo,
                                 int           recViewType,
                                 bool          pagedOrTop,
                                 string        idx,
                                 string        canEdit,
                                 string        active,
                                 string        clientID,
                                 string        pracID,
                                 string        journalID,
                                 defineCols dc) 
    {
    
      string viewUDF = "dbo.SvcJournal_Journal_Entries_View (@userID, @userGroup, @userRank, @clientID, @pracID, @journalID, @recID)";    

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      Object    vClientID     = Validate.optClientID (uInfo,     clientID);
      Object    vPracID       = Validate.optPracID   (uInfo,     pracID);
      int       vJournalID    = Validate.reqInteger  (journalID, @"Invalid journal id");

      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,      vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",    SqlDbType.Int,      vPracID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@journalID", SqlDbType.BigInt,   vJournalID,   ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }
  
    /***************************************************************************
     * load */
    /**
     * Outputs data for a single journal entry
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id.
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @param  patID           PatID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static ServiceJournalJournalEntry load (   SqlConnection connSpedmon
                                                    , DetailsLog    log
                                                    , UserInfo      uInfo
                                                    , string        clientID
                                                    , string        journalID
                                                    , string        recID)
    {
      return (ServiceJournalJournalEntry) Entities.load(connSpedmon, log, uInfo, recID, typeof(ServiceJournalJournalEntry),
      delegate { return ServiceJournalsJournalEntries.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", clientID, "", journalID, null); });
    } 

    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl (  SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , bool          paged
                                           , string        pageNumber
                                           , string        canEdit
                                           , string        active
                                           , string        clientID
                                           , string        pracID
                                           , string        journalID)
    {
      ReturnDataTable so = new ReturnDataTable();
               
      /*----------------------------
       * Define our columns and
       * set the page order for 
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("id");       
        ss.addDisplayColumn("rowOrder", true);
        ss.addDisplayColumn("startTime        as [Start Time]");
        ss.addDisplayColumn("endTime          as [End Time]");
        ss.addDisplayColumn("eventLabel       as [Event]");
        ss.addDisplayColumn("notes            as [Notes]");
        ss.addDisplayColumn("pracName         as [Practitioner]");
        ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(canEdit) as [canEdit]");
        
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest 
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return ServiceJournalsJournalEntries.view (connSpedmon,log,uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", "", clientID, pracID, journalID, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Service Journal Entries";
      so.tableFooter = Messages.CONFIDENTIAL;
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
    }    
        
    /***************************************************************************
     * generateStaticHTMLTable */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * @return                 string
     ***************************************************************************/

    
    public static string generateStaticHTMLTable(  SqlConnection connSpedmon
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , string        clientID
                                                 , string        pracID
                                                 , string        journalID
                                                 , bool          showChange)
    {                                           

      ServiceJournalJournal sj = ServiceJournalsJournals.load(connSpedmon, log, uInfo, clientID, journalID);     
      ReturnDataTable       rd = viewTbl(connSpedmon, log, uInfo,false,"1",null,null,clientID,pracID,journalID);
      
      rd.tableName   = sj.name;      
      rd.tableFooter = String.Format ("{0} events recorded", rd.iTotalRecords);
      
      
      string editOrDeleteURL = MBA.HttpApplication.createLink( ServiceJournals.URL_USER_ALL_GO_TO_JOURNAL
                                                               , true
                                                               , new NameValue("journalid",journalID)
                                                               , new NameValue("savetype",Constants.SAVE_TYPE_EDIT.ToString())
                                                               , new NameValue("recid",""));


      /*###########################################################################
        # Generate table
        ###########################################################################*/ 

      StringBuilder sb             = new StringBuilder();
      int           numVisibleCols = 0;

      sb.Append(@"<div class=""svc-journal-journal-entries-container"">");

      if (rd.hasRecords == false)
      {
        sb.Append(@"<div class=""svc-journal-journal-entries-none"">");
        sb.AppendFormat(@"<p>{0}</p>",rd.tableName);
        sb.Append(@"<p>No records</p>");
        sb.Append(@"</div>");
        sb.Append(@"</div>"); /* Container*/
        return sb.ToString();
      }
      
      sb.Append(@"<table class=""svc-journal-journal-entries"">");

      /*###########################################################################
        # Caption
        ###########################################################################*/ 

      sb.Append(@"<caption>");
      sb.Append(rd.tableName);
      sb.Append(@"</caption>");
      
      /*###########################################################################
        # Header
        ###########################################################################*/ 

      sb.Append(@"<thead>");
      sb.Append(@"<tr>");
      
      /*============================================================
       * Include all visible columns
       *============================================================*/
     
      string editDeleteColHdr = "";
      
      var headerColumns = new StringBuilder();
      
      foreach (aoColumn col in rd.aoColumns)
      {
        /* Visible column */
        
        if (col.bVisible)
        {
          /* Skip rendering header for canEdit. */

          if (col.sTitle == "canEdit") {
            continue;
          }
          
          /* Otherwise render column */

          headerColumns.AppendFormat(@"<th class=""{0} ui-state-default"">",col.sClass);
          headerColumns.Append(col.sTitle);
          headerColumns.Append (@"</th>");
          numVisibleCols++;
        }

        /* Hiddden column */
        
        else
        {
          if (col.sTitle == "id") {
          
            if (showChange)
            {
              editDeleteColHdr = @"<th class=""ui-state-default svc-journal-journal-entries-change-entry-col""></th>";
              numVisibleCols++;
            }
          }
          else {
            headerColumns.Append(@"<th class=""svc-journal-journal-entries-hidden-col"">");
            headerColumns.Append(col.sTitle);
            headerColumns.Append (@"</th>");
          }
        }
      }

      /* Change column (if it will be displayed as a possible option) is the first column */
      
      if (showChange) {
        sb.Append(editDeleteColHdr);
      }
      
      /* Append rest of columns in header*/

      sb.Append(headerColumns.ToString());      

      sb.Append(@"</tr>");
      sb.Append(@"</thead>");

      /*###########################################################################
        # Footer
        ###########################################################################*/ 

      sb.Append(@"<tfoot>");
      sb.Append(@"<tr>");
      sb.AppendFormat(@"<th class=""ui-state-default"" colspan=""{0}"">",numVisibleCols);
      sb.Append(rd.tableFooter);
      sb.Append(@"</th>");
      sb.Append(@"</tr>");
      sb.Append(@"</tfoot>");
      
      /*###########################################################################
        # Body
        ###########################################################################*/ 
      
      int curRow = 1;

      sb.Append(@"<tbody>");
                
      foreach(Object[] row in rd.aaData)
      {
        string evenodd = ((curRow % 2) == 0) ? "even":"odd";
        
        sb.AppendFormat (@"<tr class=""{0}"">",evenodd);
        
        int curCol = 0;
        string editDelCol = "";
        bool canEdit = true;

        var rowColumns = new StringBuilder();

        foreach (Object cell in row)
        {
          aoColumn curaoCol = rd.aoColumns[curCol];          

          /* Visible column */

          if (curaoCol.bVisible)
          {

            /* If column holds the canEdit status then save the status as a flag BUT don't render the column */

            if (curaoCol.sTitle == "canEdit") {
              bool? cEdit = Util.evaluateFlag(cell,true);
              if (cEdit.HasValue) canEdit = cEdit.Value;
              continue;
            }
                       
            /* Append column as normal*/ 

            rowColumns.AppendFormat(@"<td class=""{0}""><span data-col-title=""{2}"">{1}</span></td>",curaoCol.sClass, cell, curaoCol.sTitle);
            
          }
          
          /* Hiddden column */
          
          else
          {
          
            /* If the column is the id column generate a change link instead of a hidden column */
          
            if (curaoCol.sTitle == "id") {
              editDelCol = String.Format(@"<td class=""svc-journal-journal-entries-change-entry-col svc-journal-journal-entries-change-entry-col-can-change""><a href=""{0}{1}"">Change</a></td>",editOrDeleteURL,cell);
            }
            /* Otherwise generate the hidden column */
            else { 
              rowColumns.AppendFormat(@"<td class=""svc-journal-journal-entries-hidden-col"">{0}</td>",cell);
            }
            
          }
          curCol++;
        }
        
        /* If user cannot edit then remove the link from editDelCol*/
        if (canEdit == false) editDelCol = @"<td class=""svc-journal-journal-entries-change-entry-col svc-journal-journal-entries-change-entry-col-no-change""></td>";
        
        /* If we are showing the change option then put it as the first column*/
        if (showChange) sb.Append(editDelCol);

        /* Then append the rest of the columns for the row */
        sb.Append(rowColumns.ToString());

        sb.Append(@"</tr>");
        curRow++;
      }
      
      sb.Append(@"</tbody>");
      sb.Append(@"</table>");
      sb.Append(@"</div>"); /* Container*/
      return sb.ToString();

    }


/***********************************************************************************************************************
 * **************************************** Service Journal Refactor ***************************************************
 * *********************************************************************************************************************/
            
    /*************************************************************************
     * viewJSON */
    /**
     * Return a list of Service Journals entries
     * 
     ***************************************************************************/             
    public static ReturnDB viewJSON(SqlConnection connSpedmon, 
                                 DetailsLog    log, 
                                 UserInfo      uInfo,
                                 int           recViewType,
                                 bool          pagedOrTop,
                                 string        idx,
                                 string        canEdit,
                                 string        active,
                                 string        clientID,
                                 string        journalID,
                                 defineCols dc) 
    {
    
      string viewUDF = "dbo.SVCJOURNAL_JOURNAL_ENTRIES_JSON_VIEW (@userID, @userGroup, @userRank, @clientID, @journalID, @recID)";    

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      Object    vClientID     = Validate.optClientID (uInfo,     clientID);
      long      vJournalID    = Validate.reqInteger  (journalID, Messages.INVALID_RECORD_ID);

      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID",   SqlDbType.Int,      vClientID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@journalID",  SqlDbType.Int,      vJournalID,    ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }          
    /*************************************************************************
     * journalEntriesListJSON */
    /**
     * Return a list of Service Journals records
     * 
     ***************************************************************************/

    public static List<ServiceJournalJournalEntry> viewList (  SqlConnection connSpedmon
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , string clientID
                                                 , string journalID
                                                 , string active)
     {
        var recs = new List<ServiceJournalJournalEntry>();
        ReturnDB rd = ServiceJournalsJournalEntries.viewJSON(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, clientID, journalID, null);       
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(ServiceJournalJournalEntry));
        foreach (var o in slo) {
            recs.Add((ServiceJournalJournalEntry) o);
        }
        return recs;
    }

    /***************************************************************************
     * delete */
    /**    
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/

    public static ReturnSaveRecord delete (   SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , string        editDelReason
                                            , string        validateRec
                                            , string        journalid                                       
                                            , string        pracid
                                            , string        recID )
    {

       /*----------------------------
        * Check for required and
        * optional parameters
        * and validate data integrity
        * of all supplied parameters
        *----------------------------*/

       long vJournalID = Validate.reqInteger (journalid, @"Invalid journal id");
       long vPracID    = Validate.reqPracID  (uInfo,  pracid);  	  
               
        /*----------------------------
         * Collect all of the parameters
         * that are specific to this
         * delete method.
         *----------------------------*/

        List<SqlParameter> parms = new List<SqlParameter>();
  
        parms.Add(Database.SqlParm("@journalID", SqlDbType.Int, vJournalID, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@pracID",    SqlDbType.Int, vPracID,    ParameterDirection.Input));
        /*----------------------------
         * Call base method
         *----------------------------*/

        return Entities.delete (   connSpedmon
                                 , log
                                 , uInfo
                                 , editDelReason
                                 , validateRec
                                 , recID
                                 , "SVCJOURNAL_JOURNAL_ENTRY_DELETE"
                                 , ref parms);
    }

  }
}
