using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Collections.Specialized;
using System.Collections;
using System.IO;
using MBA;



namespace Spedmon
{

    /***************************************************************************
     * StructuredDataImportFileRmtsParticipantData */
    /**
     *
     ****************************************************************************/

    public class StructuredDataImportFileRmtsParticipantsData
    {
        public const string DEFAULT_PAGING_ORDER = @"clientName";

        public long id;
        public string clientName;
        public string fileProfileName;
        public string fileName;
        public long fileSize;
        public string fileSizeStr;
        public long numOfIncomingPatDataRecords;

        public DateTime importedOn;
        public string importedOnStr;
        public long importedByUserID;
        public string importedByUserName;

        public string currentStatusStr;

        public DateTime currentStatusAsOf;
        public string currentStatusAsOfStr;

        public bool fileAccepted;
        public string fileAcceptedStr;

        public DateTime fileAcceptedOn;
        public string fileAcceptedOnStr;

    }

    /***************************************************************************
     * StructuredDataImportFilesRmtsParticipantsData */
    /**
     *
     ****************************************************************************/

    public class StructuredDataImportFilesRmtsParticipantsData : Entities
    {

        public const string URL_PAGE_IMPORT_USER_ALL = @"user_all_rmts_participants_data_import.aspx";
        public const string LNK_PAGE_IMPORT_USER_ALL = @"structureddataimportsrmtsparticipantsdataimportlink";
        public const string SEL_LABEL        = @"RMTS Participants Data";
        public const string SEL_LABEL_IMPORT = @"TSP Documentation";
        public const string SEL_LABEL_MANAGE = SEL_LABEL + @" - Manage";

        public const string STRUCTURED_DATA_IMPORT_PROFILES_FILE = @"rmts-participants-data.json";

        public const string URL_REST_VIEW = @"api/v1/structureddataimportfilesrmtsparticipantsdata";

        /***************************************************************************
         * URL_IMPORT_USER_ALL_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_IMPORT_USER_ALL_BASE()
        {
            return MBA.HttpApplication.createLink(StructuredDataImportFilesRmtsParticipantsData.URL_PAGE_IMPORT_USER_ALL
                                                  , true
                                                  , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                  , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)
   );
        }

        /***************************************************************************
         * URL_REST_VIEW_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(StructuredDataImportFilesRmtsParticipantsData.URL_REST_VIEW, true);
        }

        /***************************************************************************
         * URL_SAVE_NEW_SUB_PAGE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SAVE_NEW_SUB_PAGE_BASE()
        {
            return MBA.HttpApplication.createLink(StructuredDataImportFilesRmtsParticipantsData.URL_PAGE_IMPORT_USER_ALL
                                                                           , true
                                                                           , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                           , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW));
        }

        /***************************************************************************
         * importData */
        /**
         *
         ****************************************************************************/

        public static ReturnSaveRecordWithJSONData importData(SqlConnection connSpedmon
                                                                 , DetailsLog log
                                                                 , UserInfo uInfo
                                                                 , string clientID
                                                                 , string fyQuarterID
                                                                 , string dataToImportJSON
                                                                 , string validateRec)
        {
            // if roster doesn't exist, create it
            long rosterID = RmtsParticipationRosters.loadOrCreateRoster(connSpedmon, log, uInfo, clientID, fyQuarterID);

            // in case of error
            if (rosterID == 0)
            {
                throw new Warning("Something went wrong when creating RMTS roster!");
            }

            ReturnSaveRecordWithJSONData rd = new ReturnSaveRecordWithJSONData();

            /*----------------------------
             * Validate incoming data
             *----------------------------*/

            long   vClientID     = Validate.reqClientID(uInfo, clientID);
            long   vFyQuarterID  = Validate.reqInteger (fyQuarterID, Messages.INVALID_QUARTER);

            MBA.StructuredDataRowDataFieldsManipulation _fnManipulateRow = delegate (ref Dictionary<string,string> dataFieldsForDataRow) 
            {                          
                /* Replace name/value with whatever you want in dataFieldsForDataRow. */
                return;
            };
         
            MBA.StructuredDataFieldAdditionalValidation _fnAdditionalFieldValidation = delegate (int rowNum, StructuredDataField field, string valueIn)
            {                        
               /* Perform any additional validation needed and return either the original or a sanitized version of valueIn */
               /* Throw exceptions if there are any issues */
               return valueIn;
            };

            string vDataToImport = MBA.StructuredDataImportFiles.validate (  StructuredDataImportFilesRmtsParticipantsData.STRUCTURED_DATA_IMPORT_PROFILES_FILE
                                                                           , dataToImportJSON
                                                                           , @"Please select the type of TSP data file and a file"
                                                                           , @"Please select the type of TSP data file"
                                                                           , @"Please select a TSP data file that has records"
                                                                           , @"All of the records in this TSP data file have data issues"
                                                                           , _fnManipulateRow
                                                                           , _fnAdditionalFieldValidation);
            /*----------------------------
             * Populate db parameters
             *----------------------------*/

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"      , SqlDbType.BigInt,  vClientID    , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fyQuarterID"   , SqlDbType.BigInt,  vFyQuarterID , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@importDataJSON", SqlDbType.VarChar, vDataToImport, ParameterDirection.Input, -1));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.saveAndReturnJSONData(connSpedmon
                                                   , log
                                                   , uInfo
                                                   , Constants.SAVE_TYPE_NEW.ToString()
                                                   , validateRec
                                                   , ""
                                                   , ""
                                                   , "Rmts_Participants_Data_Imports_Save"
                                                   , @"Duplicate file"
                                                   , ref parms
                                                   , null);


        }

        /***************************************************************************
         * view */
        /**
         * General view method
         * 
         * @return            ReturnDB
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
                                     , defineCols dc)
        {

            string viewUDF = "dbo.Rmts_Participants_Data_Imports_View (@userID, @userGroup, @userRank, @clientID)";

            /*----------------------------
            * Validate parameters specific
            * to this entity.view
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, clientID);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

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
        )
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = StructuredDataImportFileRmtsParticipantsData.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(StructuredDataImportFileRmtsParticipantsData)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return StructuredDataImportFilesRmtsParticipantsData.view(connSpedmon
                                                                                                , log
                                                                                                , uInfo
                                                                                                , Entities.REC_VIEW_OBJECTS
                                                                                                , pageObjectList
                                                                                                , idx
                                                                                                , "" // canEdit
                                                                                                , active
                                                                                                , clientID
                                                                                                , dc);
                                          });


        }




    }
}

