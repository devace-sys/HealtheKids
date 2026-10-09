
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;


namespace Spedmon
{

    /***************************************************************************
     * ClientNote */
    /**
     * This class contains data that represents communication on a particular
     * topic between a client and our staff.
     ***************************************************************************/

    public class ClientNote : Entity
   {

     public long topicID ;
     public string topicName ;

     public string noteText ;
     public string subject;

     public DateTime created ;
     public long     createdBy ; 

     public DateTime lastModified ;
     public long     lastModifiedBy;

     public bool sharedWithClient ;

     public long   clientID;
     public string clientName;

     public string createdByUserName;
     public string createdOnYMD;
     public string createdOnStr;

   }

    /***************************************************************************
     * ClientsNotes */
    /**
     * Entities class for Client Notes; contains webmethod handlers and
     * utility functions pertaining to communication on a particular
     * topic between a client and our staff.
     ***************************************************************************/

    public class ClientsNotes : Entities
    {


        public const string SEL_LABEL           = @"Client Conversations";
        public const string SEL_LABEL_MANAGE    = SEL_LABEL + " - Manage";
        public const string URL_USER_ALL_MANAGE = @"user_all_client_notes_manage.aspx";
        public const string MENU_LINK_ID_USER_ALL_MANAGE = @"clientnotesmanagelnk"; /* For possible future use */

        public const  string URL_REST_VIEW    = @"api/v1/clientsnotes";
        public static string URL_ASMX         = "clients_notes.asmx";

        public static string URL_ASMX_SAVE    = URL_ASMX + "/saveinline";

        public static string URL_ASMX_DELETE  = URL_ASMX + "/deleteinline";

        public static string URL_ASMX_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_ASMX_SAVE, true);
        }

        public static string URL_ASMX_DELETE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_ASMX_DELETE, true);
        }

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(ClientsNotes.URL_REST_VIEW, true);
        }


        /***************************************************************************
        * viewObjects */
        /**
        * Retrieves paginated or full result set of ClientsNotes
        *
        * @param connSpedmon SqlConnection object to Spedmon database, where client note entries are stored
        * @param log DetailsLog object
        * @param uInfo UserInfo object pertaining to logged-in user (found from URL token)
        * @param pageObjectList get a paginated result set; pageObjectList = 0 will attempt to fetch the entire result set
        * @param pageOrder SQL ORDER BY clause; sorts the result set. Customizable from front-end via sortable RestView columns
        * @param idx page number for paginated result set or record id for single row
        *
        * @param clientID filter result(s) by numeric clientID; optional for PCAL staff
        * @param topicID filter results(s) by topic ID; optional
        * @param clientsFilteredForConsultant if clientID is blank, filter client(s) to the specific workload for a given client consultant
        *                                     (indicated by the uInfo)
        *
        * @return Instance of ReturnObjects
        ***************************************************************************/

        public static ReturnObjects viewObjects (  SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string clientID
                                                  , string topicID
                                                  , string clientsFilteredForConsultant)
                                                   

        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = "id desc"; // Client.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(

                // NOTE: Entities.viewObjects() is used both for fetching 1 item and fetching a result set of multiple records;
                //       Entities.viewObject() is rarely used for any purpose.

                                           connSpedmon
                                         , log
                                         , uInfo
                                         , typeof(ClientNote)
                                         , pageObjectList
                                         , pageOrder
                                         , delegate {

                                             return ClientsNotes.view(
                                               connSpedmon,
                                               log,
                                               uInfo,

                                               Entities.REC_VIEW_OBJECTS,
                                               // REC_VIEW_OBJECTS is used for all api calls, fetching 1 or fetching a paginated result set;
                                               // Entities.REC_VIEW_OBJECT is not used for anything as of yet

                                               pageObjectList,
                                               idx,
                                               clientID ,
                                               topicID ,
                                               clientsFilteredForConsultant ,
                                               ""  , //string canEdit,
                                               "1" , //string active,
                                              dc
                                             );
                                             
                                         });


        }


        /***************************************************************************
         * save */
        /**
         * Calls SQL procedure to save new or edit existing client note entry in the database.
         *
         * @param connSpedmon   SqlConnection object to Spedmon database, where client note entries are stored
         * @param log           DetailsLog object
         * @param uInfo         UserInfo object pertaining to logged-in user (found from URL token)
         *
         * @param topicID     numeric ID of topic, from topics drop-down
         * @param subject     freeform text, indicating the subject of the client note
         * @param noteText    freeform text, indicating the body of the client note
         * @param clientID    numeric ID of client, from clients drop-down
         *
         * @param saveType       "1" if saving new object; "2" if edit existing
         * @param validateRec    "1" or "Y" to run the save routine in the database, to preview any possible error messages, without committing changes to the database.  "0" or "N" to commit changes to the database.
         * @param editDelReason  NOT IMPLEMENTED for this save procedure; no effect
         * @param recID          unique numeric ID for an existing record, if edit (with saveType="2").  Otherwise leave null or empty string
         *
         * @return              serializable ReturnSaveRecord object containing record ID from database, and/or any SQL errors
         ***************************************************************************/

        public static ReturnSaveRecord save (   SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , string topicID
                                              , string subject
                                              , string noteText
                                              , string sharedWithClient
                                              , string clientID
                                              , string editDelReason
                                              , string validateRec
                                              , string saveType
                                              , string recID )
        {

           /*###########################################################################
             # Validate parameters specific to this entity save and create their 
             # database parameters.
             ###########################################################################*/

            /* Pre validation substitutions */

            if (uInfo.userGroup == Constants.USER_GROUP_CLIENT) sharedWithClient = "1"; /* Client users have no choice on if their note is shared with the client.*/                                              
            
            /* Validate */

            long    vTopicID        = Validate.reqInteger  (topicID,          @"Invalid topic selection");
            string  vSubject        = Validate.optString   (subject,          @"Invalid subject");            
            string  vNoteText       = Validate.reqString   (noteText,         @"Conversation text required");
            bool    vSharedWClient  = Validate.reqFlag     (sharedWithClient, @"Invalid value for Shared With Client?",true);      
            long    vClientID       = Validate.reqClientID (uInfo, clientID);

            /* Post validation substitutions */

            if (String.IsNullOrWhiteSpace(vSubject)) vSubject = @"";
   
            /* Populate database parameters */

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@topicID",          SqlDbType.BigInt,   vTopicID,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@subject",          SqlDbType.VarChar,  vSubject,       ParameterDirection.Input, 115));
            parms.Add(Database.SqlParm("@noteText",         SqlDbType.VarChar,  vNoteText,      ParameterDirection.Input,-1)); /* Size of -1 for varchar(max) */
            parms.Add(Database.SqlParm("@sharedWithClient", SqlDbType.Bit,      vSharedWClient, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@clientID",         SqlDbType.BigInt,   vClientID,      ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results.
              ###########################################################################*/
  
            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "CLIENTS_Notes_SAVE", Messages.DUP_CLIENT_REC, ref parms, null);
        }

         /***************************************************************************
          * view */
         /**
          * Retrieves one or more client note entries, from the database
          *
          * @param connSpedmon   SqlConnection object to Spedmon database, where client note entries are stored
          * @param log           DetailsLog object
          * @param uInfo         UserInfo object pertaining to logged-in user (found from URL token)
          * 
          * @param recViewType   Record view types: MBA.Entities.REC_VIEW_RAW, MBA.Entities.REC_VIEW_LOAD, and 9 other options
          * @param pagedOrTop    get a limited subset of results; pagedOrTop = false will attempt to fetch the entire result set from the database
          * @param idx           page number (for paginated result set) or unique numeric ID of clientNote, depending on recViewType
          * 
          * @param clientID      filter result(s) by numeric clientID; optional
          * @param topicID       filter results(s) by topic ID; optional
          *
          * @param canEdit       NOT IMPLEMENTED for this view method; no effect
          * @param active        "1" to filter for active (non-deleted) records; "0" to find records maarked as deleted; "" for both/all
          * @param dc           callback method to create columns for a viewTbl method (not yet implemented for ClientsNotes).  dc is also used to specify the SQL ORDER BY clause.
          *
          * @return                serializable ReturnSaveRecord object containing exception from database call, if any
          ***************************************************************************/

        public static ReturnDB view (  SqlConnection connSpedmon
                                     , DetailsLog    log
                                     , UserInfo      uInfo
                                     , int           recViewType
                                     , bool          pagedOrTop
                                     , string        idx
                                     , string        clientID 
                                     , string        topicID
                                     , string        clientsFilteredForConsultant
                                     , string        canEdit
                                     , string        active
                                     , defineCols    dc )
        {

            string viewUDF = "dbo.CLIENTS_Notes_VIEW (@userID, @userGroup, @userRank, @active, @recID, @clientID, @sharedWithClient, @topicID, @clientsFilteredForConsultant)";

            
           /*###########################################################################
             # Validate parameters specific to this entity view and create their 
             # database parameters.
             ###########################################################################*/
            
            Object  vClientID  = Validate.optClientID (uInfo, clientID);                       /* Limits clients to their own client id */
            Object  vTopicID   = Validate.optInteger  (topicID, "double-check valid topic");

            Object vFilterClients = Validate.reqFlag(clientsFilteredForConsultant, "filter clients?");

            /* If this is a client then we only want to show the client conversations that we share with them
             * or the conversations that they have authored for their related client.
             * The following logic implements that restriction.
             */

            bool? vIsSharedWClient = null;

            if      (uInfo.pcalStaff)                                vIsSharedWClient = null;
            else if (uInfo.userGroup == Constants.USER_GROUP_CLIENT) vIsSharedWClient = true;
            else                                                     vIsSharedWClient = null;
            
            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",         SqlDbType.BigInt, vClientID,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@sharedWithClient", SqlDbType.Bit,    vIsSharedWClient, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@topicID",          SqlDbType.BigInt, vTopicID,         ParameterDirection.Input));

            parms.Add(Database.SqlParm("@clientsFilteredForConsultant", SqlDbType.Bit, vFilterClients, ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }


        /***************************************************************************
         * delete */
        /**
         * Deletes (marks as inactive) a client note entry, in the database
         *
         * @param connSpedmon   SqlConnection object to Spedmon database, where newsletter entries are stored
         * @param log           DetailsLog object
         * @param uInfo         UserInfo object pertaining to logged-in user (found from URL token)
         *
         * @param editDelReason   NOT IMPLEMENTED for this delete procedure; no effect
         * @param validateRec     required parameter; "0" or "N" or commit the change to the database.  "1" or "Y" does nothing, as there are not logical validation checks in this particular save sproc
         * @param recID           unique numeric ID for an existing record, if edit (with saveType="2").  Otherwise leave null or empty string
         *
         * @return                serializable ReturnSaveRecord object containing exception from database call, if any
         ***************************************************************************/

        public static ReturnSaveRecord delete(  SqlConnection connSpedmon
                                              , DetailsLog    log 
                                              , UserInfo      uInfo
                                              , string        editDelReason
                                              , string        validateRec
                                              , string        recID )
        {

            string deleteSproc = @"CLIENTS_Notes_DELETE";

            /*###########################################################################
              # Validate parameters specific to this entity delete and create their 
              # database parameters.
              ###########################################################################*/

            Object vClientID = Validate.optClientID(uInfo, "");
              
            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, deleteSproc, ref parms);
        }


    }
}

