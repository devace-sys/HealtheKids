
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;


namespace Spedmon
{


    /***************************************************************************
     * ClientsNotesTopics */
    /**
     * Entities class for Client Notes Topics; contains webmethod handler and
     * utility functions pertaining to the topic selection dropdown for Clients Notes.
     ***************************************************************************/

    public class ClientsNotesTopics : Entities
    {


        public static string URL_ASMX = "clients_notes_topics.asmx";

        public static string URL_VIEWSEL_BASE = URL_ASMX + "/viewSel";

        public static string URL_VIEWSEL()
        {
            return MBA.HttpApplication.createLink(URL_VIEWSEL_BASE, true);
        }


        /***************************************************************************
         * viewSel */
        /**
         * Simple wrapper method for view(); populates a drop-down widget 
         *
         * @param connSpedmon   SqlConnection object to Spedmon database, where client note entries are stored
         * @param log           DetailsLog object
         * @param uInfo         UserInfo object pertaining to logged-in user (found from URL token)
         * 
         * @return             serializable ReturnSel object to be rendered as data in a drop-down widget
         ***************************************************************************/

        public static ReturnSel viewSel (  SqlConnection  connSpedmon
                                          , DetailsLog    log
                                          , UserInfo      uInfo
                                          , bool          top
                                          , string        topSize
                                          , string        term )                                    
        {


            defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("'' as context1"); 
                //pageroworder = "[nameInTbl] asc";
            };

            return Entities.viewSel(connSpedmon, log, uInfo, false /* top */, "" /* topSize */,
            delegate { return ClientsNotesTopics.view (
                connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, false /* top */, "" /* topSize */, "", "1", term, dc);
            });
        }

         /***************************************************************************
          * view */
         /**
          * Retrieves one or more client notetopics options, from the database
          *
          * @param connSpedmon   SqlConnection object to Spedmon database, where client note topics are stored
          * @param log           DetailsLog object
          * @param uInfo         UserInfo object pertaining to logged-in user (found from URL token)
          * 
          * @param recViewType   Record view types: MBA.Entities.REC_VIEW_RAW, MBA.Entities.REC_VIEW_LOAD, and 9 other options
          * @param pagedOrTop    get a limited subset of results; pagedOrTop = false will attempt to fetch the entire result set from the database
          * @param idx           page number (for paginated result set) or unique numeric ID of client note topic, depending on recViewType
          * 
          *
          * @param canEdit       NOT IMPLEMENTED for this view method; no effect
          * @param active        "1" to filter for active (non-deleted) records; "0" to find records maarked as deleted; "" for both/all
          * @param dc           callback method to create columns for a viewTbl method (not yet implemented for ClientsNotes).  dc is also used to specify the SQL ORDER BY clause.
          *
          * @return             serializable ReturnSaveRecord object containing exception from database call, if any
          ***************************************************************************/

        public static ReturnDB view (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , int           recViewType
                                      , bool          pagedOrTop
                                      , string        idx
                                      , string        canEdit
                                      , string        active
                                      , string        term
                                      , defineCols    dc )
        {
            string vTerm = Validate.optString(term,Messages.INVALID_SEARCH_TERM);            
            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, vTerm, ParameterDirection.Input, 256));
            string viewUDF = "dbo.CLIENTS_NOTES_TOPICS_VIEW (@userID, @userGroup, @userRank, @active, @recID, @term)";
            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
        }
    }
}