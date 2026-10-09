using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    public class NoteLibrarySavedNote
    {
        public long id;
        public string name;
        public string value;

        public const string DEFAULT_PAGING_ORDER = @"id desc";
    }

    public class NoteLibrarySavedNotePortal
    {
        public long id;
        public string noteText;
        public DateTime? createdOn;
        public DateTime? lastModify;

        public string dateStr
        {
            get
            {
                var dt = createdOn ?? lastModify;
                return dt.HasValue
                    ? dt.Value.ToString("MM/dd/yyyy hh:mm tt")
                    : string.Empty;
            }
        }
    }

    /***************************************************************************
     * NoteHelperSavedNotes */
    /**
     * 
     ***************************************************************************/

    public class NoteLibrarySavedNotes : Entities
    {
        public const string URL_REST_VIEW = @"api/v1/userpersonalnotes";
        public const string URL_SERVICE_BASE = @"note_library_saved_notes.asmx";
        public const string URL_SAVE = URL_SERVICE_BASE + @"/save";

        public const string URL_EXPORT_NOTE = @"user_all_note_library_export_note.aspx";

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(NoteLibrarySavedNotes.URL_REST_VIEW, true);
        }

        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(NoteLibrarySavedNotes.URL_SAVE, true);
        }

        /***************************************************************************
         * URL_EXPORT_NOTE_BASE */
        /**
        ***************************************************************************/
        public static string URL_EXPORT_NOTE_BASE()
        {
            return MBA.HttpApplication.createLink(
                  URL_EXPORT_NOTE
                , true
                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
              );
        }

        /***************************************************************************
         * delete */
        /**
        * "Deletes" a saved note
        * 
        * @param  editDelReason   Reason for edit/delete 
        * @param  validateRec     Perform validation for this record?
        * @param  recID           Record id reference for edit and delete
        * @return                 ReturnSaveNewRecord
        ***************************************************************************/

        public static ReturnSaveRecord delete(
            SqlConnection connSpedmon
          , DetailsLog log
          , UserInfo uInfo
          , string editDelReason
          , string validateRec
          , string recID)
        {

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * delete method.
             *----------------------------*/

            long vNoteOwner = uInfo.userid;

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@noteOwner", SqlDbType.BigInt, vNoteOwner, ParameterDirection.Input));

            /*----------------------------
             * Call base method 
             *----------------------------*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "NOTE_LIBRARY_SAVED_NOTE_DELETE", ref parms);
        }

        /***************************************************************************
         * save */
        /**
        * Save a note
        *
        * @param  userID          User id of who is recording service
        * @param  userGroup       1 = Client, 2 = SBSC (from users db)
        * @param  userRank        Users role ranking
        * @param  noteText        Text of note
        *
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
        * @param  recID           Record id of existing record to edit or delete.
        * @return                 ReturnSaveNewRecord
        ***************************************************************************/

        public static ReturnSaveRecord save(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                             string noteNamespace,
                                             string noteSource,
                                             string clientID,
                                             string pracID,
                                             string patID,
                                             string noteText,
                                             string editDelReason,
                                             string validateRec,
                                             string saveType,
                                             string recID)
        {


            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            long vNoteOwner = uInfo.userid;
            string vNoteNamespace = Validate.reqString(noteNamespace, @"Namespace is required");
            string vNoteSource = Validate.reqString(noteSource, @"Source is required");
            long vClientID = Validate.reqClientID(uInfo, clientID);
            Object vPracID = Validate.optPracID(uInfo, pracID);
            long vPatID = Validate.reqInteger(patID, Messages.PATIENT_ID_BAD);
            string vNoteText = Validate.reqString(noteText, @"Note is required");


            parms.Add(Database.SqlParm("@noteOwner", SqlDbType.BigInt, vNoteOwner, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@noteNamespace", SqlDbType.VarChar, vNoteNamespace, ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@noteSource", SqlDbType.VarChar, vNoteSource, ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.BigInt, vPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID", SqlDbType.BigInt, vPatID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@noteText", SqlDbType.VarChar, vNoteText, ParameterDirection.Input, 8000));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "NOTE_LIBRARY_SAVED_NOTE_SAVE", @"You have already saved this note", ref parms, null);

        }


        /***************************************************************************
         * view */
        /**
         * Returns a list of saved notes
         * 
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                     int recViewType,
                                     bool pagedOrTop,
                                     string idx,
                                     string canEdit,
                                     string active,
                                     string notenamespace,
                                     string notesource,
                                     string clientID,
                                     string pracID,
                                     string patID,
                                     string term,
                                     defineCols dc)
        {

            string viewUDF = "NOTE_LIBRARY_SAVED_NOTES_VIEW (@userID, @userGroup, @userRank, @noteOwner, @noteNamespace, @noteSource, @clientID, @pracID, @patID, @term, @active, @recID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            long vNoteOwner = uInfo.userid;
            string vNoteNamespace = Validate.reqString(notenamespace, @"Namespace is required");
            string vNoteSource = Validate.reqString(notesource, @"Source is required");
            long vClientID = Validate.reqClientID(uInfo, clientID);
            Object vPracID = Validate.optPracID(uInfo, pracID);
            Object vPatID = Validate.optInteger(patID, Messages.PATIENT_ID_BAD);
            string vTerm = Validate.optString(term, @"Invalid term");

            parms.Add(Database.SqlParm("@noteOwner", SqlDbType.BigInt, vNoteOwner, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@noteNamespace", SqlDbType.VarChar, vNoteNamespace, ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@noteSource", SqlDbType.VarChar, vNoteSource, ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.BigInt, vPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID", SqlDbType.BigInt, vPatID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, vTerm, ParameterDirection.Input, 100));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * viewSel */
        /**
         * Sel of saved notes
         * 
         ****************************************************************************/

        public static ReturnSel viewSel(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize, string notenamespace, string notesource, string clientID, string pracID, string patID, string term)
        {

            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
                ss.addDisplayColumn("notes as notes");
                ss.addDisplayColumn("canDelete as flag1");
                ss.addDisplayColumn("context1");
            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return NoteLibrarySavedNotes.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "1", notenamespace, notesource, clientID, pracID, patID, term, dc); });

        }

        /***************************************************************************
         * viewObjects 
         *
         * Returns a list of patients objects
         * 
         ***************************************************************************/

        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                    , DetailsLog log
                                                    , UserInfo uInfo
                                                    , bool pageObjectList
                                                    , string pageOrder
                                                    , string idx
                                                    , string notenamespace
                                                    , string notesource
                                                    , string clientID
                                                    , string pracID
                                                    , string patID
                                                    , string active
                                                    , string term)

        {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = NoteLibrarySavedNote.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
                * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                            , log
                                            , uInfo
                                            , typeof(NoteLibrarySavedNotePortal)
                                            , pageObjectList
                                            , pageOrder
                                            , delegate
                                            {
                                                return NoteLibrarySavedNotes.view(connSpedmon
                                                                                    , log
                                                                                    , uInfo
                                                                                    , Entities.REC_VIEW_OBJECTS
                                                                                    , pageObjectList
                                                                                    , idx
                                                                                    , "" /* Can edit */
                                                                                    , active
                                                                                    , notenamespace
                                                                                    , notesource
                                                                                    , clientID
                                                                                    , pracID
                                                                                    , patID
                                                                                    , term
                                                                                    , dc);
                                            });


        }

    }
}

