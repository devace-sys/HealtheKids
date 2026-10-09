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
   * PatientInsuranceCarriersDataImports */
  /**
   *
   ****************************************************************************/

   public class PatientInsuranceCarriersDataImports: Entities
   {

       public const string URL_PAGE_IMPORT                      = @"user_all_patients_insurance_data_import.aspx";

       public const string SEL_LABEL_IMPORT                     = @"Import Insurance Record Data";

       public const string STRUCTURED_DATA_IMPORT_PROFILES_FILE = @"patient-insurance-carriers.json";

       public const string URL_SVC_IMPORT                       = @"patients_insurance_data_imports.asmx/importdata";

      /***************************************************************************
       * URL_SVC_IMPORT_BASE */
      /**
       *
       **************************************************************************/
      public static string URL_SVC_IMPORT_BASE()
      {
         return MBA.HttpApplication.createLink(PatientInsuranceCarriersDataImports.URL_SVC_IMPORT, true);
      }

      /***************************************************************************
       * URL_IMPORT_USER_ALL_BASE */
      /**
       *
       **************************************************************************/
  
      public static string URL_IMPORT_USER_ALL_BASE()
      {
         return MBA.HttpApplication.createLink(PatientInsuranceCarriersDataImports.URL_PAGE_IMPORT
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
                                                                , string        dataToImportJSON                                                               
                                                                , string        validateRec )
       {


         ReturnSaveRecordWithJSONData rd = new ReturnSaveRecordWithJSONData();

         /*----------------------------
          * Validate incoming data
          *----------------------------*/

         long   vClientID                 = Validate.reqClientID (uInfo, clientID);
    
         string vDataToImport = MBA.StructuredDataImportFiles.validate (  PatientInsuranceCarriersDataImports.STRUCTURED_DATA_IMPORT_PROFILES_FILE
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

        parms.Add(Database.SqlParm("@importDataJSON",              SqlDbType.VarChar,  vDataToImport,                   ParameterDirection.Input,-1));
        
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
                                               , "Patients_Insurance_Carriers_Data_Imports_Save"
                                               , @"Duplicate file"
                                               , ref parms
                                               , null );


       }

   }
}
