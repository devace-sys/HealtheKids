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
   * ServiceRecordsDataImports */
  /**
   *
   ****************************************************************************/

   public class ServiceRecordsDataImports: Entities
   {

       public const string URL_PAGE_IMPORT                      = @"user_all_service_records_data_import.aspx";
       public const string MENU_ID_IMPORT                       = @"servicerecordsdataimportlnk";
       public const string SEL_LABEL_IMPORT                     = @"Import Service Record Data";
       public const string STRUCTURED_DATA_IMPORT_PROFILES_FILE = @"service-records-data.json";
       public const string URL_SVC_IMPORT                       = @"service_records_data_imports.asmx/importdata";

      /***************************************************************************
       * URL_SVC_IMPORT_BASE */
      /**
       *
       **************************************************************************/
      public static string URL_SVC_IMPORT_BASE()
      {
         return MBA.HttpApplication.createLink(ServiceRecordsDataImports.URL_SVC_IMPORT, true);
      }

      /***************************************************************************
       * URL_IMPORT_USER_ALL_BASE */
      /**
       *
       **************************************************************************/
  
      public static string URL_IMPORT_USER_ALL_BASE()
      {
         return MBA.HttpApplication.createLink(ServiceRecordsDataImports.URL_PAGE_IMPORT
                                               , true
                                               , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                               , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW));
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
                                                                , string        svcNamesListDataSourceID                                                             
                                                                , string        generateClaims
                                                                , string        dataToImportJSON                                                               
                                                                , string        validateRec )
       {


         ReturnSaveRecordWithJSONData rd = new ReturnSaveRecordWithJSONData();

         /*----------------------------
          * Validate incoming data
          *----------------------------*/

         long   vClientID                 = Validate.reqClientID (uInfo, clientID);
         int    vSvcNamesListDataSourceID = Validate.reqInteger  (svcNamesListDataSourceID, Messages.INVALID_PLAN_TYPE);
         bool   vGenerateClaims           = Validate.reqFlag     (generateClaims,@"Generate claims must be yes or no", false);
            
         string vDataToImport = MBA.StructuredDataImportFiles.validate (  ServiceRecordsDataImports.STRUCTURED_DATA_IMPORT_PROFILES_FILE
                                                                        , dataToImportJSON
                                                                        , @"Please select the type of service record data file and a file"
                                                                        , @"Please select the type of service record data file"
                                                                        , @"Please select a service record data file that has records"
                                                                        , @"All of the records in service record data file have data issues"
                                                                        , null
                                                                        , null);

        /*----------------------------
         * Populate db parameters
         *----------------------------*/

        var parms = new List<SqlParameter>();

        parms.Add(Database.SqlParm("@clientID",                    SqlDbType.BigInt,   vClientID,                       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@svcNamesListDataSourceID",    SqlDbType.SmallInt, vSvcNamesListDataSourceID,       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@generateClaims",              SqlDbType.Bit,      vGenerateClaims,                 ParameterDirection.Input));
        parms.Add(Database.SqlParm("@importDataJSON",              SqlDbType.VarChar,  vDataToImport,                   ParameterDirection.Input,-1));
        
        parms.Add(Database.SqlParm("@MsgInvCombo",                 SqlDbType.VarChar,  Messages.INVALID_PPN_COMBO,      ParameterDirection.Input, 1000));
        parms.Add(Database.SqlParm("@MsgMinReq",                   SqlDbType.VarChar,  Messages.MIN_REQ,                ParameterDirection.Input, 1000));
        parms.Add(Database.SqlParm("@MsgMinDef",                   SqlDbType.VarChar,  Messages.MIN_DEF,                ParameterDirection.Input, 1000));
        parms.Add(Database.SqlParm("@MsgMilReq",                   SqlDbType.VarChar,  Messages.MIL_REQ,                ParameterDirection.Input, 1000));
        parms.Add(Database.SqlParm("@MsgPatElg",                   SqlDbType.VarChar,  Messages.PAT_ELG,                ParameterDirection.Input, 1000));
        parms.Add(Database.SqlParm("@MsgPatDOBGteDOS",             SqlDbType.VarChar,  Messages.PAT_DOB_GTE_DOS,        ParameterDirection.Input, 1000));
        parms.Add(Database.SqlParm("@MsgPatAbsent",                SqlDbType.VarChar,  Messages.PAT_ABSENT_NO_CLAIM,    ParameterDirection.Input, 1000));
        parms.Add(Database.SqlParm("@MsgFutureDOS",                SqlDbType.VarChar,  Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

         return Entities.saveAndReturnJSONData (  connSpedmon
                                               , log
                                               , uInfo
                                               , Constants.SAVE_TYPE_NEW.ToString() /* Always new */
                                               , validateRec
                                               , ""
                                               , ""
                                               , "Service_Records_Data_Imports_Save"
                                               , @"Duplicate file"
                                               , ref parms
                                               , null );


       }

   }
}
