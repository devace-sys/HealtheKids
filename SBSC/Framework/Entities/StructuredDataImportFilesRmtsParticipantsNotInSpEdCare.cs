using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using MBA;

namespace Spedmon
{


    /***************************************************************************
     * RmtsParticipant */
    /**
     * 
     **************************************************************************/
    public class StructuredDataImportFilesRmtsParticipantNotInSpEdCare : Entity
    {
        public const string DEFAULT_PAGING_ORDER = "clientName asc, lastName asc, firstName asc";

        public long    clientID;
        public string  clientName;
        public long    fyQuarterID;
        public long    pracID;
        public string  firstName;
        public string  lastName;
        public string  title;
        public string  email;
        public string  startDateStrYMD;
        public string  startDateStr;
        public string  endDateStrYMD;
        public string  endDateStr;
    }

    public class ReturnRmtsParticipantNotInSpEdCare : Return
    {
        public ReturnRmtsParticipantNotInSpEdCare() : base() { }
        public ReturnRmtsParticipantNotInSpEdCare(string msg) : base(msg) { }
        public ReturnRmtsParticipantNotInSpEdCare(Exception e) : base(e) { }
        public ReturnRmtsParticipantNotInSpEdCare(Warning e) : base(e) { }
        public ReturnRmtsParticipantNotInSpEdCare(Critical e) : base(e) { }
        public ReturnRmtsParticipantNotInSpEdCare(SessionExpired e) : base(e) { }
        public bool hasRecord = false;
        public List<StructuredDataImportFilesRmtsParticipantNotInSpEdCare> pracs;
        public string pracsListCommaSeperated;
    }


    /***************************************************************************
     * StructuredDataImportFilesRmtsParticipantsNotInSpEdCare */
    /**
     * 
     **************************************************************************/
    public class StructuredDataImportFilesRmtsParticipantsNotInSpEdCare : Entities
    {
        public const string MENU_ID_MANAGE = @"managermtspracsnotinspedcare";
        public const string SEL_LABEL_MANAGE = @"RMTS participants not in SpEdCare - Manage";
        public const string URL_PAGE_MANAGE_USER_ALL = @"user_all_rmts_participants_not_in_spedcare_manage.aspx";
        public const string URL_REST_VIEW = @"api/v1/structureddataimportfilesrmtsparticipantsnotinspedcare";
        public const string URL_ASMX = @"rmts_participants_not_in_spedcare.asmx";
        public const string URL_SAVE = URL_ASMX + @"/save";
        public const string URL_VIEW_ALL = URL_ASMX + @"/viewAll";
        public const string URL_DELETE = URL_ASMX + @"/delete";

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.URL_REST_VIEW, true);
        }

        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.URL_SAVE, true);
        }
        
        public static string URL_VIEW_ALL_BASE()
        {
            return MBA.HttpApplication.createLink(StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.URL_VIEW_ALL, true);
        }
                
        public static string URL_DELETE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_DELETE, true);
        }


        /*************************************************************************
         * view */
        /**
         * View RMTS participants
         * 
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , int recViewType
                                      , bool pagedOrTop
                                      , string idx
                                      , string canEdit
                                      , string active
                                      , string clientID
                                      , string fyQuarterID
                                      , string rmtsDataImportID
                                      , defineCols dc)
        {

            string viewUDF = "dbo.Rmts_Participants_Data_Imports_Not_In_SpEdCare_View (@userID, @userGroup, @userRank, @clientID, @fyQuarterID, @rmtsDataImportID, @recID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var vClientID         = Validate.optClientID(uInfo          , clientID);
            var vFyQuarterID      = Validate.optInteger(fyQuarterID     , Messages.INVALID_QUARTER, true); 
            var vRmtsDataImportID = Validate.optInteger(rmtsDataImportID, Messages.INVALID_NUMBER , true);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"        , SqlDbType.BigInt, vClientID        , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fyQuarterID"     , SqlDbType.BigInt, vFyQuarterID     , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@rmtsDataImportID", SqlDbType.BigInt, vRmtsDataImportID, ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }
        
        /*************************************************************************
         * viewAll */
        /**
         * 
         ***************************************************************************/

        public static ReturnRmtsParticipantNotInSpEdCare viewAll(SqlConnection connSpedmon
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , string clientID
                                      , string fyQuarterID
                                      , string rmtsDataImportID
        )
        {
            var recs = new List<StructuredDataImportFilesRmtsParticipantNotInSpEdCare>();
            ReturnDB rd = StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, "1", clientID, fyQuarterID, rmtsDataImportID, null);
            List<Object> slo = Database.convertRecordsToList(ref rd.records, typeof(StructuredDataImportFilesRmtsParticipantNotInSpEdCare));
            foreach (var o in slo)
            {
                recs.Add((StructuredDataImportFilesRmtsParticipantNotInSpEdCare)o);
            }

            ReturnRmtsParticipantNotInSpEdCare so = new ReturnRmtsParticipantNotInSpEdCare();

            so.pracs = recs;

            // get comma seperated list
            IEnumerable<string> pracNames = recs
                .Select(p => String.Join(",", p.lastName, p.firstName));

            so.pracsListCommaSeperated = String.Join(" - ", pracNames);

            so.hasRecord = (recs.Count > 0); // double check this

            return so;
        }        

        /***************************************************************************
         * viewObjects 
         *
         * Returns a list of objects
         * 
         ***************************************************************************/
        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                    , DetailsLog log
                                                    , UserInfo uInfo
                                                    , bool pageObjectList
                                                    , string pageOrder
                                                    , string idx
                                                    , string active
                                                    , string clientID
                                                    , string fyQuarterID
                                                    , string rmtsDataImportID
        )
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = RmtsParticipant.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
                * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                            , log
                                            , uInfo
                                            , typeof(StructuredDataImportFilesRmtsParticipantNotInSpEdCare)
                                            , pageObjectList
                                            , pageOrder
                                            , delegate
                                            {
                                                return StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.view(
                                                                          connSpedmon
                                                                        , log
                                                                        , uInfo
                                                                        , Entities.REC_VIEW_OBJECTS
                                                                        , pageObjectList
                                                                        , idx
                                                                        , "" // canEdit
                                                                        , active
                                                                        , clientID
                                                                        , fyQuarterID
                                                                        , rmtsDataImportID
                                                                        , dc
                                                );
                                            });
        }

        /***************************************************************************
        * save */
        /**
         * Save new or update existing record
         *
         * @param  userID          User id of who is recording service
         * @param  userGroup       1 = Client, 2 = SBSC (from users db)
         * @param  userRank        Users role ranking
         * @param  clientID        Client id
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
        public static ReturnSaveRecord save(SqlConnection connSpedmon
                                             , DetailsLog log
                                             , UserInfo uInfo
                                             , string pracID
                                             , string editDelReason
                                             , string validateRec
                                             , string saveType
                                             , string recID)
        {

            string saveSproc = @"Rmts_Participants_Data_Imports_Assign_Prac";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vPracID = Validate.reqInteger(pracID, Messages.INVALID_PRAC_ID);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@pracID", SqlDbType.BigInt, vPracID, ParameterDirection.Input));            

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }

        public static ReturnSaveRecord delete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                           string editDelReason, string validateRec, string recID)
        {            

            List<SqlParameter> parms = new List<SqlParameter>();

            /*----------------------------
             * Call base method
             *----------------------------*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "Rmts_Participants_Data_Imports_Not_In_SpEdCare_Delete", ref parms);
        }
    }
}
