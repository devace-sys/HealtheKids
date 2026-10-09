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
     * ImportFromPatientGoalRecord */
    /**
     * 
     **************************************************************************/

    public class ImportFromPatientGoalRecord : Entity
    {
        public long clientID;
        public long patID;
        public string ssid;
        public string startDateStrYMD;
        public string endDateStrYMD;
        public string schoolCDSCode;
        public string seisID;
        public string districtID;
        public string lastName;
        public string firstName;
        public DateTime birthdate;
        public string grade;
        public string schoolOfAttendance;
        public string districtOfService;
        public string caseManager;
        public DateTime iepDate;
        public string eligibilityStatus;
        public string areaOfNeed;
        public string goalNumber;
        public string baseline;
        public string goalText;
        public string purposeOfGoal;
        public string standard;
        public string personResponsible;
        public string objective1;
        public string objective1Met;
        public DateTime objective1DateMet;
        public string objective1MetOnStrYMD;
        public string objective2;
        public string objective2Met;
        public DateTime objective2DateMet;
        public string objective2MetOnStrYMD;
        public string objective3;
        public string objective3Met;
        public DateTime objective3DateMet;
        public string objective3MetOnStrYMD;
        public DateTime annualReview;
        public string comments;
        public bool goalMet;
        public DateTime addedOn;
        public string addedBy;
        public string updatedBy;
        public DateTime updatedOn;
        public DateTime lastAffirmedPR;
        public DateTime created;
        public long createdBy;
        public DateTime lastModified;
        public long lastModifiedBy;
    }

    /***************************************************************************
     * ImportFromPatientGoalRecords */
    /**
     *
     ****************************************************************************/

    public class ImportFromPatientGoalRecords : Entities
    {

        public const string URL_PAGE_IMPORT                         = @"user_all_import_from_patient_goal_records.aspx";
        public const string MENU_ID_IMPORT                          = @"importfrompatientgoalrecordslnk";
        public const string SEL_LABEL_IMPORT                        = @"Import Patient Goal Data";
        public const string STRUCTURED_DATA_IMPORT_PROFILES_FILE    = @"import-from-patient-goal-records.json";
        public const string URL_WEB_SERVICE                         = @"import_from_patient_goal_records.asmx";
        public const string URL_PATIENT_GOAL_IMPORT                 = URL_WEB_SERVICE + "/importdata";
        public const string URL_VIEW_SEL                            = URL_WEB_SERVICE + "/viewSel";

        /***************************************************************************
         * URL_PATIENT_GOAL_IMPORT_BASE */
        /**
        *
        **************************************************************************/

        public static string URL_PATIENT_GOAL_IMPORT_BASE()
        {
            return MBA.HttpApplication.createLink(ImportFromPatientGoalRecords.URL_PATIENT_GOAL_IMPORT, true);
        }


        /***************************************************************************
         * URL_IMPORT_PATIENT_GOAL_ALL_BASE */
        /**
        *
        **************************************************************************/

        public static string URL_IMPORT_PATIENT_GOAL_ALL_BASE()
        {
            return MBA.HttpApplication.createLink(ImportFromPatientGoalRecords.URL_PAGE_IMPORT,
                                                      true
                                                    , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                    , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)
            );
        }

        /***************************************************************************
         * URL_VIEW_SEL_BASE */
        /**
        *
        **************************************************************************/

        public static string URL_VIEW_SEL_BASE()
        {
            return MBA.HttpApplication.createLink(ImportFromPatientGoalRecords.URL_VIEW_SEL, true);
        }

        /***************************************************************************
         * view */
        /**
         *
         **************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , int recViewType
                                      , bool pagedOrTop
                                      , string idx
                                      , string canEdit
                                      , string active
                                      , string clientID
                                      , string patID
                                      , string dos
                                      , string term
                                      , defineCols dc)
        {

            string viewUDF = @"dbo.Import_From_Patient_Goal_Records_View (@userID, @userGroup, @userRank, @clientID, @patID, @dos, @term, @active, @recID)";
            
            List<SqlParameter> parms = new List<SqlParameter>();

            long vClientID  = Validate.reqClientID(uInfo, clientID);
            var vPatID      = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);
            var vDos        = Validate.reqDate(dos, Messages.INVALID_DOS);
            Object vTerm    = Validate.optString(term, @"Invalid search term");

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt,   vClientID,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",    SqlDbType.BigInt,   vPatID,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dos",      SqlDbType.Date,     vDos,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@term",     SqlDbType.VarChar,  vTerm,      ParameterDirection.Input, 256));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon
                                  , log
                                  , uInfo
                                  , recViewType
                                  , pagedOrTop
                                  , idx
                                  , canEdit
                                  , active
                                  , viewUDF
                                  , ref parms
                                  , null
                                  , dc);
        }

        /***************************************************************************
        * viewSel */
        /**
        * Returns a data table of records for preview or record selection.
        *
        * @return                 ReturnSel
        ***************************************************************************/

        public static ReturnSel viewSel(SqlConnection connSpedmon
                                            , DetailsLog log
                                            , UserInfo uInfo
                                            , bool top
                                            , string clientID
                                            , string patientID
                                            , string dos)
        {

            /*----------------------------
            * Define our context column
            *----------------------------*/
            const long GOAL_TYPE_ID_GOAL_PROGRESS = 100;

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("convert(varchar(50), " + GOAL_TYPE_ID_GOAL_PROGRESS + ") as recData1");
                ss.addDisplayColumn("[startDateStrYMD] as recData2");
                ss.addDisplayColumn("[endDateStrYMD] as recData3");
                ss.addDisplayColumn("dbo.BIT_TO_YN(goalMet) as recData4");
                ss.addDisplayColumn("areaOfNeed as recData5");
                ss.addDisplayColumn("goalNumber as recData6");

                ss.addDisplayColumn("convert(varchar(10), null) as recData7");
                ss.addDisplayColumn("baseline as recData8");
                ss.addDisplayColumn("comments as recData9");

                ss.addDisplayColumn("objective1 as recData10");
                ss.addDisplayColumn("objective1Met as recData11");
                ss.addDisplayColumn("[objective1MetOnStrYMD] as recData12");

                ss.addDisplayColumn("objective2 as recData13");
                ss.addDisplayColumn("objective2Met as recData14");
                ss.addDisplayColumn("[objective2MetOnStrYMD] as recData15");

                ss.addDisplayColumn("objective3 as recData16");
                ss.addDisplayColumn("objective3Met as recData17");
                ss.addDisplayColumn("[objective3MetOnStrYMD] as recData18");
            };

            return Entities.viewSel(connSpedmon
                                    , log
                                    , uInfo
                                    , top
                                    , ""
                                    , delegate
                                    {
                                        return ImportFromPatientGoalRecords.view(connSpedmon
                                                                                    , log
                                                                                    , uInfo
                                                                                    , Entities.REC_VIEW_SEL
                                                                                    , top
                                                                                    , ""
                                                                                    , ""
                                                                                    , "Y"
                                                                                    , clientID
                                                                                    , patientID
                                                                                    , dos
                                                                                    , ""
                                                                                    , dc);


                                    });
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
                                                                 , string dataToImportJSON
                                                                 , string validateRec)
        {

            /*----------------------------
             * Validate incoming data
             *----------------------------*/

            long vClientID = Validate.reqClientID(uInfo, clientID);

            string vDataToImport = MBA.StructuredDataImportFiles.validate(ImportFromPatientGoalRecords.STRUCTURED_DATA_IMPORT_PROFILES_FILE
                                                                           , dataToImportJSON
                                                                           , @"Please select the patient goal data file type and a file"
                                                                           , @"Please select the patient goal data file type"
                                                                           , @"Please select a patient goal data file that has records"
                                                                           , @"All of the records in the patient goal data file have data issues"
                                                                           , null
                                                                           , null);

            /*----------------------------
             * Populate db parameters
             *----------------------------*/

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@importDataJSON", SqlDbType.VarChar, vDataToImport, ParameterDirection.Input, -1));

            return Entities.saveAndReturnJSONData(connSpedmon
                                                  , log
                                                  , uInfo
                                                  , Constants.SAVE_TYPE_NEW.ToString() /* Always new */
                                                  , validateRec
                                                  , ""
                                                  , ""
                                                  , "Import_From_Patient_Goal_Records_Save"
                                                  , @"Duplicate patient goal record"
                                                  , ref parms
                                                  , null);


        }

    }
}
