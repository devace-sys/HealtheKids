using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;




namespace Spedmon
{


    /***************************************************************************
     * RmtsParticipant */
    /**
     * 
     **************************************************************************/
    public class RmtsParticipant : Entity
    {
        public const string DEFAULT_PAGING_ORDER = "pracTitle asc, pracName asc";

        public long     clientID;
        public long     rosterID;
        public long     fyQuarterID;
        public long     pracID;
        public string   pracName;

        public string   pracEmail;

        public string   pracTitle;
        public string   reportingGroup;

        public string   startDateStrYMD;         
        public string   startDateStr;
        public string   endDateStrYMD;   
        public string   endDateStr;
        public long     reasonForStartDateChangeCode;
        public long     reasonForEndDateChangeCode;
        public bool     hasServiceRecords;
        public bool     hasReimbursement;
        public bool     needsReasonForStartDateChange;
        public bool     needsReasonForEndDateChange;
        public long     employeeRelationshipID;

    }



    /***************************************************************************
     * RmtsParticipants */
    /**
     * 
     **************************************************************************/
    public class RmtsParticipants : Entities
    {
        public const string URL_REST_VIEW = @"api/v1/rmtsparticipants";
        public const string URL_ASHX      = @"rmts_participants.ashx";
        public const string URL_ASMX      = @"rmts_participants.asmx";
        public const string URL_SAVE      = URL_ASMX + @"/save";


        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(RmtsParticipants.URL_REST_VIEW, true);
        }


        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(RmtsParticipants.URL_SAVE, true);
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
                                      , string rosterID
                                      , defineCols dc
                                      )
        {

            string viewUDF = "dbo.RMTS_PARTICIPANTS_VIEW (@userID, @userGroup, @userRank, @clientID, @rosterID, @active, @recID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var vClientID     = Validate.reqClientID(uInfo        , clientID);
            var vRosterID     = Validate.optInteger (rosterID     , Messages.INVALID_ROSTER_ID, true); // in UDF, if roster id is null or 0, no data will be returned

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"    , SqlDbType.BigInt,  vClientID    , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@rosterID"    , SqlDbType.BigInt,  vRosterID    , ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

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
                                                    , string rosterID
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
                                            , typeof(RmtsParticipant)
                                            , pageObjectList
                                            , pageOrder
                                            , delegate
                                            {
                                                return RmtsParticipants.view(
                                                                          connSpedmon
                                                                        , log
                                                                        , uInfo
                                                                        , Entities.REC_VIEW_OBJECTS
                                                                        , pageObjectList
                                                                        , idx
                                                                        , "" // canEdit
                                                                        , active
                                                                        , clientID
                                                                        , rosterID
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
                                             , string clientID
                                             , string pracID 
                                             , string rosterID
                                             , string startDate
                                             , string endDate
                                             , string reasonForStartDateChangeCode
                                             , string reasonForEndDateChangeCode  
                                             , string hasServiceRecords
                                             , string hasReimbursement
                                             , string employeeRelationshipID
                                             , string editDelReason
                                             , string validateRec
                                             , string saveType
                                             , string recID)
        {

            string saveSproc = @"RMTS_PARTICIPANTS_SAVE";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID                      = Validate.reqClientID  (uInfo                       , clientID);
            var vPracID                        = Validate.reqInteger   (pracID                      , Messages.INVALID_PRAC_ID);
            var vRosterID                      = Validate.reqInteger   (rosterID                    , Messages.INVALID_ROSTER_ID);
            var vStartDate                     = Validate.reqDate      (startDate                   , Messages.INVALID_START_DATE);
            var vEndDate                       = Validate.reqDate      (endDate                     , Messages.INVALID_END_DATE);
            var vReasonForStartDateChangeCode  = Validate.optInteger   (reasonForStartDateChangeCode, "Invalid reason for change", true);
            var vReasonForEndDateChangeCode    = Validate.optInteger   (reasonForEndDateChangeCode  , "Invalid reason for change", true);
            var vHasServiceRecords             = Validate.optFlag      (hasServiceRecords           , Messages.INVALID_FLAG      , true);
            var vHasReimbursement              = Validate.optFlag      (hasReimbursement            , Messages.INVALID_FLAG      , true);
            var vEmployeeRelationshipID        = Validate.optInteger   (employeeRelationshipID      , Messages.INVALID_EMPLOYEE_RELATIONSHIP);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"                    , SqlDbType.BigInt   , vClientID                    , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@pracID"                      , SqlDbType.BigInt   , vPracID                      , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@rosterID"                    , SqlDbType.BigInt   , vRosterID                    , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@startDate"                   , SqlDbType.DateTime , vStartDate                   , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@endDate"                     , SqlDbType.DateTime , vEndDate                     , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@reasonForStartDateChangeCode", SqlDbType.BigInt   , vReasonForStartDateChangeCode, ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@reasonForEndDateChangeCode"  , SqlDbType.BigInt   , vReasonForEndDateChangeCode  , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@hasServiceRecords"           , SqlDbType.Bit      , vHasServiceRecords           , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@hasReimbursement"            , SqlDbType.Bit      , vHasReimbursement            , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@employeeRelationshipID"      , SqlDbType.BigInt   , vEmployeeRelationshipID      , ParameterDirection.Input    ));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }


    }
}


