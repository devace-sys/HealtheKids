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
   * StructuredDataImportFilePatientData */
  /**
   *
   ****************************************************************************/

  public class StructuredDataImportFilePatientData
  {
    public const string DEFAULT_PAGING_ORDER = @"patientDataImportID desc";

    public long     id;
    public string   clientName;
    public long     clientID;
    public string   fileProfileName;
    public string   fileName;
    public long     fileSize;
    public string   fileSizeStr;
    public string   fileClass;
    public string   fileSubClass;
    public string   fileMimeType;
    public long     structuredDataImportID;
    public long     patientDataImportID;
    public long     numOfIncomingPatDataRecords;

    public DateTime importedOn;
    public string   importedOnStr;
    public long     importedByUserID;
    public string   importedByUserName;

    public string   currentStatusStr;

    public DateTime currentStatusAsOf;
    public string   currentStatusAsOfStr;

    public bool     fileAccepted;
    public string   fileAcceptedStr;

    public DateTime fileAcceptedOn;
    public string   fileAcceptedOnStr;

    public string   importResultsStatusStr;

    public bool hasPreImportRowExceptions;
    public bool hasPreImportAdditionalBadRowExceptions;
    public bool hasManageSitesData;
    public bool hasImportRowExceptions;
    public bool importRolledBack;


    public bool generateEligibilityMatchFile;
    public bool eligibilityMatchFileGenerated;
    public bool eligibilityMatchReturnFileReceived;
    public bool eligibilityMatchfileGenerationUnscheduled;


    public long numRowsSuccessfullyImported;

    public long numRowsToBeSentInOutgoingElig;

    public bool   okToCommitData;
    public string isTestMode;

    public long numRowsCSISMissing;

    public bool processingCompleted;
    public bool processingError;

    public bool completedNormally;

    public string completedNormallyYN;

    public bool earlyExit;

    public string earlyExitYN;

    public bool rejectedValidateGradeDOBs;

    public string rejectedValidateGradeDOBsYN;

    public bool  unknownProblem;

    public string  unknownProblemYN;

  }

    /***************************************************************************
     * StructuredDataImportFilePatientDataExtended */
    /**
     * TODO: Populate this with a loadN call to
     * dbo.Patient_Data_Imports_Get_Import_Results
     ****************************************************************************/
    public class StructuredDataImportFilePatientDataExtended: StructuredDataImportFilePatientData
  {
    public string importDataJSON;
    public string preImportAdditionalBadRowsJSONData;
    public string manageSitesJSONData;
    public string importResultsJSON;
    public string preImportExpectionRptHTML;
    public string manageSitesResultsRptHTML;
    public string importResultsRptHTML;
    public bool   hasData = false;

  }

  /***************************************************************************
   * StructuredDataImportFilesPatientData */
  /**
   *
   ****************************************************************************/

   public class StructuredDataImportFilesPatientData: Entities
   {

       public const string URL_PAGE_IMPORT_USER_ALL             = @"user_all_patients_data_import.aspx";
       public const string LNK_PAGE_IMPORT_USER_ALL             = @"structureddataimportspatientdataimportlink";
       public const string URL_PAGE_MANAGE_USER_ALL             = @"user_all_patients_data_manage.aspx";
       public const string LNK_PAGE_MANAGE_USER_ALL             = @"structureddataimportspatientdatamanagelink";
       public const string URL_PAGE_GET_IMPORT_RESULTS_USER_ALL = @"user_all_patients_data_get_import_results.aspx";

       public const string SEL_LABEL                  = @"Bulk Patient Data";
       public const string SEL_LABEL_IMPORT           = SEL_LABEL +  @" - Import";
       public const string SEL_LABEL_MANAGE           = SEL_LABEL +  @" - Manage";
       public const string SEL_LABEL_IMPORT_RESULTS   = SEL_LABEL +  @" - Import Results";

       public const string STRUCTURED_DATA_IMPORT_PROFILES_FILE = @"patients-data.json";

       public const string URL_REST_VIEW             = @"api/v1/structureddataimportfilespatientsdata";

      /***************************************************************************
       * URL_IMPORT_USER_ALL_BASE */
      /**
       *
       **************************************************************************/
      public static string URL_IMPORT_USER_ALL_BASE()
      {
         return MBA.HttpApplication.createLink(StructuredDataImportFilesPatientData.URL_PAGE_IMPORT_USER_ALL
                                               , true
                                               , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                               , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW));
      }

      /***************************************************************************
       * URL_IMPORT_RESULTS_USER_ALL_BASE */
      /**
       *
       **************************************************************************/
      public static string URL_IMPORT_RESULTS_USER_ALL_BASE()
      {
         return MBA.HttpApplication.createLink(StructuredDataImportFilesPatientData.URL_PAGE_GET_IMPORT_RESULTS_USER_ALL
                                               , true
                                               , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                               , new NameValue(Constants.PARM_REC_ID,""));
      }

      /***************************************************************************
       * URL_REST_VIEW_BASE */
      /**
       *
       **************************************************************************/
      public static string URL_REST_VIEW_BASE()
      {
         return MBA.HttpApplication.createLink(StructuredDataImportFilesPatientData.URL_REST_VIEW, true);
      }

       /***************************************************************************
        * importData */
       /**
        *
        ****************************************************************************/

       public static ReturnSaveRecordWithJSONData importData (  SqlConnection connSpedmon
                                                                , DetailsLog    log
                                                                , UserInfo      uInfo
                                                                , string        clientID
                                                                , string        dataToImportJSON
                                                                , string        validateGradeDOBs
                                                                , string        validateRec )
       {


         ReturnSaveRecordWithJSONData rd = new ReturnSaveRecordWithJSONData();

         /*----------------------------
          * Validate incoming data
          *----------------------------*/

         long   vClientID     = Validate.reqClientID(uInfo,clientID);


         string vDataToImport = MBA.StructuredDataImportFiles.validate (  StructuredDataImportFilesPatientData.STRUCTURED_DATA_IMPORT_PROFILES_FILE
                                                                        , dataToImportJSON
                                                                        , @"Please select the type of student data file and a file"
                                                                        , @"Please select the type of student data file"
                                                                        , @"Please select a student data file that has records"
                                                                        , @"All of the records in this student data file have data issues"
                                                                        , null
                                                                        , null);


         bool vValidateGradeDOBs = Validate.reqFlag(validateGradeDOBs, "validate DOBs?");

        /*----------------------------
         * Populate db parameters
         *----------------------------*/

        var parms = new List<SqlParameter>();

         parms.Add(Database.SqlParm("@clientID",          SqlDbType.BigInt,  vClientID,      ParameterDirection.Input));
         parms.Add(Database.SqlParm("@validateGradeDOBs",          SqlDbType.Bit, vValidateGradeDOBs,      ParameterDirection.Input));
         parms.Add(Database.SqlParm("@importDataJSON",    SqlDbType.VarChar, vDataToImport,  ParameterDirection.Input,-1));

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

         return Entities.saveAndReturnJSONData (  connSpedmon
                                               , log
                                               , uInfo
                                               , Constants.SAVE_TYPE_NEW.ToString()
                                               , validateRec
                                               , ""
                                               , ""
                                               , "Patient_Data_Imports_Save"
                                               , @"Duplicate file"
                                               , ref parms
                                               , null );


       }

      /***************************************************************************
       * matchData */
      /**
       * Runs match process on data imported
       *
       * @return            ReturnDB
       ***************************************************************************/
      public static ReturnSaveRecordWithJSONData matchData (  SqlConnection  connSpedmon
                                                             , DetailsLog    log
                                                             , UserInfo      uInfo
                                                             , long          clientID
                                                             , long          patientDataImportID)
      {

        ReturnSaveRecordWithJSONData rd = new ReturnSaveRecordWithJSONData();

        /*----------------------------
         * Populate db parameters
         *----------------------------*/

        var parms = new List<SqlParameter>();

        parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,  clientID,            ParameterDirection.Input));
        parms.Add(Database.SqlParm("@patientDataImportID",  SqlDbType.BigInt,  patientDataImportID, ParameterDirection.Input));

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        rd = Entities.saveAndReturnJSONData (  connSpedmon
                                               , log
                                               , uInfo
                                               , Constants.SAVE_TYPE_NEW.ToString()
                                               , @"N"
                                               , ""
                                               , ""
                                               , "Patient_Data_Imports_Match"
                                               , @"Duplicate file"
                                               , ref parms
                                               , null );

        return rd;

      }

      /***************************************************************************
       * view */
      /**
       * General view method
       *
       * @return            ReturnDB
       ***************************************************************************/

      public static ReturnDB view ( SqlConnection connSpedmon
                                   , DetailsLog   log
                                   , UserInfo     uInfo
                                   , int          recViewType
                                   , bool         pagedOrTop
                                   , string       idx
                                   , string       canEdit
                                   , string       active
                                   , string       clientID
                                   , string       waitingForProcessing
                                   , string       currentlyProcessing
                                   , string       processingComplete
                                   , defineCols   dc)
    {

      string viewUDF  = "dbo.Patient_Data_Imports_View (@userID, @userGroup, @userRank, @clientID, @waitingForProcessing, @currentlyProcessing, @processingComplete)";

      /*----------------------------
      * Validate parameters specific
      * to this entity.view
      * and populate their
      * coresponding database
      * parameters
      *----------------------------*/

      Object vClientID             = Validate.optClientID  (uInfo, clientID);
      Object vWaitingForProcessing = Validate.optFlag      (waitingForProcessing, @"Invalid value for waiting for processing");
      Object vCurrentlyProcessing  = Validate.optFlag      (currentlyProcessing,  @"Invalid value for currently processing");
      Object vProcessingComplete   = Validate.optFlag      (processingComplete,   @"Invalid value for processing complete");

      var parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt, vClientID,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@waitingForProcessing", SqlDbType.Bit,    vWaitingForProcessing,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@currentlyProcessing",  SqlDbType.Bit,    vCurrentlyProcessing,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@processingComplete",   SqlDbType.Bit,    vProcessingComplete,    ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }

    /***************************************************************************
     * viewObjects
     *
     * Returns a list of objects
     *
     ***************************************************************************/

     public static ReturnObjects viewObjects (   SqlConnection connSpedmon
                                               , DetailsLog    log
                                               , UserInfo      uInfo
                                               , bool          pageObjectList
                                               , string        pageOrder
                                               , string        idx
                                               , string        active
                                               , string        clientID
     )
     {

         /* Default page order */

         if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = StructuredDataImportFilePatientData.DEFAULT_PAGING_ORDER;

         /* Define columns delegate is used to specify columns and page order
          * We pass in the desired page row order here */

         defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
         {
             pageroworder = pageOrder;
         };

         return Entities.viewObjects(connSpedmon
                                       , log
                                       , uInfo
                                       , typeof(StructuredDataImportFilePatientData)
                                       , pageObjectList
                                       , pageOrder
                                       , delegate
                                       {
                                           return StructuredDataImportFilesPatientData.view (connSpedmon
                                                                                             , log
                                                                                             , uInfo
                                                                                             , Entities.REC_VIEW_OBJECTS
                                                                                             , pageObjectList
                                                                                             , idx
                                                                                             , "" // canEdit
                                                                                             , active
                                                                                             , clientID
                                                                                             , ""
                                                                                             , ""
                                                                                             , ""
                                                                                             , dc);
                                       });


     }

     /***************************************************************************
      * viewList */
     /**
      *
      ***************************************************************************/
     public static List<StructuredDataImportFilePatientData> viewList (  SqlConnection connSpedmon
                                                                        , DetailsLog log
                                                                        , UserInfo uInfo
                                                                        , string   clientID
                                                                        , string   waitingForProcessing
                                                                        , string   currentlyProcessing
                                                                        , string   processingComplete  )
     {
         var recs = new List<StructuredDataImportFilePatientData>();

         var rd = StructuredDataImportFilesPatientData.view (  connSpedmon
                                                             , log
                                                             , uInfo
                                                             , Entities.REC_VIEW_RAW
                                                             , false
                                                             , ""
                                                             , "" // canEdit
                                                             , "Y"
                                                             , clientID
                                                             , waitingForProcessing
                                                             , currentlyProcessing
                                                             , processingComplete
                                                             , null);

         var slo = Database.convertRecordsToList(ref rd.records, typeof(StructuredDataImportFilePatientData));
         foreach (var o in slo) {
            recs.Add((StructuredDataImportFilePatientData)o);
         }
         return recs;
     }

      /***************************************************************************
       *  getImportResults*/
      /**
       *
       ***************************************************************************/

      public static StructuredDataImportFilePatientDataExtended getImportResults (
            SqlConnection connSpedmon
          , DetailsLog   log
          , UserInfo     uInfo
          , string       recID )
      {

           StructuredDataImportFilePatientDataExtended so = new StructuredDataImportFilePatientDataExtended();
           so.hasData = false;

           string sql = "select * from dbo.Patient_Data_Imports_Get_Import_Results (@userID, @userGroup, @userRank, @clientID, @recID, @pcalStaff)";
           var parms = new List<SqlParameter>();

           Object vClientID  = Validate.optClientID  (uInfo, @"");  /* Forces client id to clients id if user is a client */
           long   vRecID     =  Validate.reqInteger  (recID, @"Invalid value for patient data import record");

           Entities.validateAndAddCommonUserInfoParameters(uInfo, ref parms);

           parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt, vClientID,       ParameterDirection.Input));
           parms.Add(Database.SqlParm("@recID",     SqlDbType.BigInt, vRecID,          ParameterDirection.Input));
           parms.Add(Database.SqlParm("@pcalStaff", SqlDbType.Bit,    uInfo.pcalStaff, ParameterDirection.Input));

           var rd = Database.execQuery(connSpedmon,log,sql,false,parms);
           if (rd.hasRecords) {
              so = (StructuredDataImportFilePatientDataExtended) Database.convertRecord(rd.records,typeof(StructuredDataImportFilePatientDataExtended));
              so.hasData = true;
           }

           return so;

      }


      public static ReturnSaveRecord sendFlaggedUnschedule(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo

                                                , string pdiID
                                                //,string uploadedRptType
                                                )
      {

            //long       vClientID        = uInfo.userClientID; //Validate.reqClientID        (uInfo, clientID);

            Object vRmtsReqID = Validate.reqInteger(pdiID, "requires pdiID");

            List<SqlParameter> parms = new List<SqlParameter>();

            return Entities.save(connSpedmon
                                , log
                                , uInfo
                                , "1" // saveType
                                , @"N"
                                , @""
                                , pdiID //recID
                                , "PATIENT_DATA_IMPORT_ELIG_MATCH_FLAG_UNSCHEDULE"
                                , Messages.DUP_SVC_REC
                                , ref parms,
              delegate ()
              { });
      }

      public static ReturnSaveRecord sendFlaggedReprocessLive(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo

                                                , string pdiID
                                                //,string uploadedRptType
                                                )
      {

            //long       vClientID        = uInfo.userClientID; //Validate.reqClientID        (uInfo, clientID);

            Object vRmtsReqID = Validate.reqInteger(pdiID, "requires pdiID");

            List<SqlParameter> parms = new List<SqlParameter>();

            return Entities.save(connSpedmon
                                , log
                                , uInfo
                                , "1" // saveType
                                , @"N"
                                , @""
                                , pdiID //recID
                                , "PATIENT_DATA_IMPORT_FLAG_FOR_LIVE_IMPORT"
                                , Messages.DUP_SVC_REC
                                , ref parms,
              delegate ()
              { });
      }

      public static ReturnSaveRecord sendFlaggedScheduledTonight(
                                                      SqlConnection connSpedmon
                                                    , DetailsLog log
                                                    , UserInfo uInfo

                                                    , string pdiID
                                                    //,string uploadedRptType
                                                    )
      {

            //long       vClientID        = uInfo.userClientID; //Validate.reqClientID        (uInfo, clientID);

            Object vRmtsReqID = Validate.reqInteger(pdiID, "requires pdiID");

            List<SqlParameter> parms = new List<SqlParameter>();

            var r = Entities.save(connSpedmon
                                , log
                                , uInfo
                                , "1" // saveType
                                , @"N"
                                , @""
                                , pdiID //recID
                                , "PATIENT_DATA_IMPORT_ELIG_MATCH_FLAG_SCHEDULE_TONIGHT"
                                , Messages.DUP_SVC_REC
                                , ref parms,
                delegate ()
                { });

            return r;
      }


   }
}
