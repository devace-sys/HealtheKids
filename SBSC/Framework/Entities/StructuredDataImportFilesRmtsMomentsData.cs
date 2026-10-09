using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * StructuredDataImportFileRmtsMomentsData */
    /**
     *
     ****************************************************************************/

    public class StructuredDataImportFileRmtsMomentsData : Entity
    {
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
     * StructuredDataImportFilesRmtsMomentsData */
    /**
     *
     ****************************************************************************/

    public class StructuredDataImportFilesRmtsMomentsData : Entities
    {

        public const string URL_PAGE_IMPORT_USER_ALL = @"user_all_rmts_moments_data_import.aspx";
        public const string SEL_LABEL        = @"RMTS Moments Data";
        public const string SEL_LABEL_IMPORT = SEL_LABEL + @" - Import";
        public const string SEL_LABEL_MANAGE = SEL_LABEL + @" - Manage";

        public const string STRUCTURED_DATA_IMPORT_PROFILES_FILE = @"rmts-moments-data.json";

        /***************************************************************************
         * URL_IMPORT_USER_ALL_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_IMPORT_USER_ALL_BASE()
        {
            return MBA.HttpApplication.createLink(URL_PAGE_IMPORT_USER_ALL
                                                  , true
                                                  , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                  , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)
        );
        }

        /***************************************************************************
         * URL_SAVE_NEW_SUB_PAGE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SAVE_NEW_SUB_PAGE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_PAGE_IMPORT_USER_ALL
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

            ReturnSaveRecordWithJSONData rd = new ReturnSaveRecordWithJSONData();

            /*----------------------------
             * Validate incoming data
             *----------------------------*/

            long   vClientID     = Validate.reqClientID(uInfo, clientID);
            long   vFyQuarterID  = Validate.reqInteger (fyQuarterID, Messages.INVALID_QUARTER);

            MBA.StructuredDataFieldAdditionalValidation _fnAdditionalFieldValidation = delegate (int rowNum, StructuredDataField field, string valueIn)
            {
                string valueOut = valueIn;

                // make sure the time portion of the RMTS moment is passed in
                if (field.name == "Sampled Moment")
                {
                    var sampledMoment = DateTime.Parse(valueIn);
                    if (sampledMoment.TimeOfDay == TimeSpan.Zero)
                    {
                        throw new Exception("Invalid Time for RMTS moment");
                    }
                    
                } 
                // filter out records where costPool is passed, but the value does not contain "direct"
                else if (field.name == "CostPool.Name")
                {
                    if (!String.IsNullOrEmpty(valueIn) && !valueIn.ToLower().Contains("direct") && !valueIn.ToLower().Contains("cost pool 1"))
                    {
                        throw new Exception("Costpool is not \"direct\"");
                    }
                    
                }
                // check if Activity Code is a proper code! It should be in the format of 2A, 2Z, etc. but sometimes it comes as
                // something like "2Z.  Direct Medical Services (Non-Billable)". We filter out everything after the "."
                else if (field.name == "Activity Code")
                {
                    if (valueIn.ToLower().Contains("."))
                    {
                        valueOut = valueIn.Substring(0, valueIn.IndexOf("."));
                    }
                }

                return valueOut;
            };

            string vDataToImport = MBA.StructuredDataImportFiles.validate (  STRUCTURED_DATA_IMPORT_PROFILES_FILE
                                                                           , dataToImportJSON
                                                                           , @"Please select the type of file and a file"
                                                                           , @"Please select the type of file"
                                                                           , @"Please select a file that has records"
                                                                           , @"All of the records in this data file have data issues"
                                                                           , null
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
                                                   , "Rmts_Moment_Data_Imports_Save"
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
                                              return view(connSpedmon
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

