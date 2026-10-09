using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{   
  
  /***************************************************************************
   * PatientsPromisedServicesCDEAuditsCurrentPatient */
  /**
   * 
   **************************************************************************/
  
  public class PatientsPromisedServicesCDEAuditsCurrentPatient : Entity
  {    
    public long     clientID;
	public long     patID;
    public string   ssid;
    public int      totMinsExpected;
    public int      totMinsApplicable;
	public int      numPlans; 
    public Double   pctExpectedApplicable;
    public string   pctExpectedApplicableStr;
    public bool     inCDEBucketC;
    public bool     inCDEBucketB;
    public bool     inCDEBucketA;
    public string   inCdeBucket;
    public long     siteID;
    public string   siteName;
    public string   spEdCaseManagerName;
    public int      totMoreThanExpectedCtr;
    public int      numPatAbsentTot;
    public int      numPracAbsentTot;
    public int      numSvcRecs;

    public const string DEFAULT_PAGING_ORDER = @"name asc";
    
  }
  
  /***************************************************************************
   * PatientsPromisedServicesCDEAuditsCurrentPatients */
  /**
   * 
   **************************************************************************/

  public class PatientsPromisedServicesCDEAuditsCurrentPatients:Entities
  {            
    public const string SEL_LABEL                                                 = CdeComplianceCommon.SEL_LABEL_CURRENT_AUDIT + @" Upload Students";
    public const string SEL_LABEL_UPLOAD_USER_ENTERED_STATS                       = CdeComplianceCommon.SEL_LABEL_CURRENT_AUDIT + @" Upload Minutes Satisfied Summary Data";

    public const string URL_REST_VIEW_BASE                                        = @"api/v1/patientspromisedservicescdeauditscurrentpatients";
    public const string STRUCTURED_DATA_IMPORT_PROFILES_FILE                      = @"cde-swd-plan-compliance.json";
    public const string STRUCTURED_DATA_IMPORT_PROFILES_FILE_FOR_COMPLIANCE_STATS = @"cde-swd-plan-compliance-delivery-stats.json";
    public const string URL_PAGE_IMPORT_USER_ALL                                  = @"user_all_cde_compliance_current_audit_manage_upload_students.aspx";
    public const string URL_PAGE_IMPORT_USER_PROVIDED_DELIVERY_COMPLIANCE_STATS   = @"user_all_cde_compliance_current_audit_manage_upload_user_provided_delivery_compliance_stats.aspx";

    public static string URL_SAVE_NEW_IMPORT_USER_PROVIDED_DELIVERY_COMPLIANCE_STATS_SUB_PAGE_BASE()
    {
        return MBA.HttpApplication.createLink(URL_PAGE_IMPORT_USER_PROVIDED_DELIVERY_COMPLIANCE_STATS
                    , true
                    , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                    , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW));
    }

    public static string URL_SAVE_NEW_IMPORT_SUB_PAGE_BASE()
    {
      return MBA.HttpApplication.createLink(URL_PAGE_IMPORT_USER_ALL
               , true
               , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
               , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW));
    }


    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW()
    { 
       return MBA.HttpApplication.createLink(PatientsPromisedServicesCDEAuditsCurrentPatients.URL_REST_VIEW_BASE, true);
    }

    /***************************************************************************
     * view */
    /**
     * View base method
     * 
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnDB view (  SqlConnection connSpedmon
                                 , DetailsLog    log
                                 , UserInfo      uInfo
                                 , int           recViewType
                                 , bool          pagedOrTop
                                 , string        pageSize
                                 , string        idx
                                 , string        canEdit
                                 , string        active
                                 , string        clientID
                                 , string        patID
                                 , defineCols    dc )
    {
      
      string viewUDF = "dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_View (@userID,@userGroup,@userRank,@clientID,@patID,@patAbsentMinsAreSatisfiedMins)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      long  vClientID  = Validate.reqClientID (uInfo, clientID);
      Object vPatID    = Validate.optPatID    (uInfo, patID);
      bool vPatAbsentMinsAreSatisfiedMins = true; /* TODO: If needed in the future continue passing this up the stack */

      var parms = new List<SqlParameter>();   

      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,    vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",     SqlDbType.BigInt,    vPatID,       ParameterDirection.Input));

      parms.Add(Database.SqlParm("@patAbsentMinsAreSatisfiedMins", SqlDbType.Bit, vPatAbsentMinsAreSatisfiedMins, ParameterDirection.Input));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, pageSize, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
    }

    /***************************************************************************
     * viewTbl 
     *
     * Returns ReturnDataTable
     * 
     ***************************************************************************/
 
     public static ReturnDataTable viewTbl ( SqlConnection connSpedmon
                                           , DetailsLog log
                                           , UserInfo uInfo
                                           , bool paged
                                           , string pageNumber
                                           , string canEdit
                                           , string active
                                           , string clientID
                                           , string patID )
     {
            ReturnDataTable so = new ReturnDataTable();

            /*###########################################################################
              # Define our display columns and set the page order.  Page order needs to
              # be in the same sort order as the udf called in the view.
              ###########################################################################*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
              
                ss.addDisplayColumn("name                         as [Student Last, First]", true);
                ss.addDisplayColumn("ssid                         as [SSID]");
                ss.addDisplayColumn("siteName                     as [Site Name]");
                ss.addDisplayColumn("spEdCaseManagerName          as [Case Manager]");
                ss.addDisplayColumn("numPlans                     as [Number\nOf\nServices]");
                ss.addDisplayColumn("totMinsExpected              as [Minutes\nExpected\nTo Date]");
                ss.addDisplayColumn("totMinsApplicable            as [Minutes\nSatisfied\nTo Date\n(Capped at Expected)]");
                ss.addDisplayColumn("pctExpectedApplicableStr     as [Percentage\nSatisfied\nTo Date]");
                ss.addDisplayColumn("totMoreThanExpectedCtr       as [Number\nOf\nServices\nOver\nDelivered]");
                
                /*ss.addDisplayColumn("numSvcRecs       as [Sessions\nDocumented]");*/                
                ss.addDisplayColumn("numPatAbsentTot  as [Sessions\nDocumented\nStudent\nAbsent]");
                /*ss.addDisplayColumn("numPracAbsentTot as [Sessions\nDocumented\nPractioner\nAbsent]");*/

                ss.addDisplayColumn("inCdeBucket                  as [Current\nCDE\nBucket]");                
                                        
                pageroworder = ss.pageRowOrder();
            };

            /*###########################################################################
              # Call the base method which handles the rest and returns a ReturnDataTable
              ###########################################################################*/

            so = Entities.viewTbl(connSpedmon
                                  , log
                                  , uInfo
                                  , paged
                                  , pageNumber
                                  , delegate {
                                      return
                                            view(connSpedmon
                                                   , log
                                                   , uInfo
                                                   , Entities.REC_VIEW_TBL
                                                   , paged
                                                   , Rules.MAX_PAGE_SIZE.ToString()
                                                   , pageNumber
                                                   , canEdit
                                                   , active
                                                   , clientID
                                                   , patID
                                                   , dc );
                                  });

            /*###########################################################################
              # Add a title and footer to ReturnDataTable then return
              ###########################################################################*/

            so.tableName   = CdeComplianceCommon.SEL_LABEL_MANGE_FOR_CLIENT_CURRENT_AUDIT;
            so.tableFooter = Messages.CONFIDENTIAL;

            return so;

     }

    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of objects
     * 
     ***************************************************************************/
    public static ReturnObjects viewObjects (  SqlConnection connSpedmon
                                              , DetailsLog   log
                                              , UserInfo     uInfo
                                              , bool         pageObjectList
                                              , string       pageOrder
                                              , string       idx
                                              , string       active
                                              , string       clientID
                                              , string       patID ) 
    {
 
        /* Default page order */
 
        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientsPromisedServicesCDEAuditsCurrentPatient.DEFAULT_PAGING_ORDER;
 
        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */
 
        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };
 
        return Entities.viewObjects(connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(PatientsPromisedServicesCDEAuditsCurrentPatient)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return PatientsPromisedServicesCDEAuditsCurrentPatients.view(connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , @"500"
                                                                       , idx
                                                                       , "" /* Can edit */
                                                                       , active
                                                                       , clientID 
                                                                       , patID
                                                                       , dc);
                                      });
 
 
    }


     /***************************************************************************
      * save */
     /**
      * Save 
      * 
      ***************************************************************************/   
  
      public static ReturnSaveOrReplaceRecord save  (   SqlConnection connSpedmon
                                                      , DetailsLog    log
                                                      , UserInfo      uInfo
                                                      , string        clientID
                                                      , string        patID
                                                      , string        validateRec )
      {           
    
        
       string saveOrReplaceSproc = "Patients_Promised_Services_CDE_Audits_Current_Patients_Save";                


       /*-------------------------------
        * Validate parameters
        *----------------------------*/
		   
       long     vClientID    = Validate.reqClientID (uInfo, clientID);
       long     vPatID       = Validate.reqPatID    (uInfo, patID);

       /*----------------------------
        * Pass parm values to sp
        *----------------------------*/  

       var parms = new List<SqlParameter>();  


 	   parms.Add(Database.SqlParm ("@clientID",     SqlDbType.BigInt,   vClientID,   ParameterDirection.Input));
       parms.Add(Database.SqlParm ("@patID",        SqlDbType.BigInt,   vPatID,      ParameterDirection.Input));

       parms.Add(Database.SqlParm ("@validateRec",  SqlDbType.BigInt,   "0",         ParameterDirection.Input));
                
       /*----------------------------
        * Call base method which 
        * handles the rest and return
        * results
        *----------------------------*/  

       ReturnSaveOrReplaceRecord so = Entities.saveOrReplaceRecord ( connSpedmon
                                             , log
                                             , uInfo
                                             , validateRec
                                             , saveOrReplaceSproc
                                             , ref parms
                                             , delegate(){});
                                                                                              
       return so;

    }

     /***************************************************************************
      * deleteInline */
     /**
      * Save 
      * 
      ***************************************************************************/   
  
      public static ReturnSaveRecord deleteInline  (   SqlConnection connSpedmon
                                                     , DetailsLog    log
                                                     , UserInfo      uInfo
                                                     , string        clientID
                                                     , string        recID
                                                     , string        validateRec )
      {           
   
       string deleteSproc = "Patients_Promised_Services_CDE_Audits_Current_Patients_Delete_Inline";                

       /*-------------------------------
        * Validate parameters
        *----------------------------*/
		   
       long vClientID = Validate.reqClientID (uInfo, clientID);
     
       /*----------------------------
        * Pass parm values to sp
        *----------------------------*/  

       var parms = new List<SqlParameter>();  

 	   parms.Add(Database.SqlParm ("@clientID",  SqlDbType.BigInt,  vClientID, ParameterDirection.Input));
                
       /*----------------------------
        * Call base method which 
        * handles the rest and return
        * results
        *----------------------------*/  

       ReturnSaveRecord so = Entities.delete ( connSpedmon
                                             , log
                                             , uInfo
                                             , ""                                             
                                             , validateRec
                                             , recID
                                             , deleteSproc
                                             , ref parms );
                                                                                              
       return so;

    }

    /***************************************************************************
     * importData */
    /**
     *
     ***************************************************************************/
    public static ReturnSaveRecordWithJSONData importData(SqlConnection connSpedmon
                                                            , DetailsLog log
                                                            , UserInfo uInfo
                                                            , string clientID
                                                            , string dataToImportJSON
                                                            , string validateRec
                                                            )
    {

        ReturnSaveRecordWithJSONData rd = new ReturnSaveRecordWithJSONData();

        /*----------------------------
            * Validate incoming data
            *----------------------------*/

        long vClientID = Validate.reqClientID(uInfo, clientID);

        MBA.StructuredDataFieldAdditionalValidation _fnAdditionalFieldValidation = delegate (int rowNum, StructuredDataField field, string valueIn)
        {
            string valueOut = valueIn;
            return valueOut;
        };

        string vDataToImport = MBA.StructuredDataImportFiles.validate(STRUCTURED_DATA_IMPORT_PROFILES_FILE
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

        parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@importDataJSON", SqlDbType.VarChar, vDataToImport, ParameterDirection.Input, -1));

        /*----------------------------
            * Call base method which
            * handles the rest and return
            * results
            *----------------------------*/

        rd = Entities.saveAndReturnJSONData(connSpedmon
                                                , log
                                                , uInfo
                                                , Constants.SAVE_TYPE_NEW.ToString()
                                                , validateRec
                                                , ""
                                                , ""
                                                , "Patients_Promised_Services_CDE_Audits_Current_Patients_Data_Imports_Save"
                                                , @"Duplicate file"
                                                , ref parms
                                                , null);

        return rd;

    }

    /***************************************************************************
     * reprocessImportedData */
    /**
     *
     ***************************************************************************/
    public static ReturnSaveRecordWithJSONData reprocessImportedData (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string clientID, string validateRec)
    {

        ReturnSaveRecordWithJSONData rd = new ReturnSaveRecordWithJSONData();

        /*----------------------------
         * Validate incoming data
         *----------------------------*/

        long vClientID = Validate.reqClientID(uInfo, clientID);

        /*----------------------------
         * Populate db parameters
         *----------------------------*/

        var parms = new List<SqlParameter>();

        parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        rd = Entities.saveAndReturnJSONData(connSpedmon
                                                , log
                                                , uInfo
                                                , Constants.SAVE_TYPE_NEW.ToString()
                                                , validateRec
                                                , ""
                                                , ""
                                                , "Patients_Promised_Services_CDE_Audits_Current_Patients_Data_Imports_Reprocess"
                                                , @"Duplicate file"
                                                , ref parms
                                                , null);

        return rd;

    }

        

     /***************************************************************************
      * saveOrReplaceUserProvidedDeliveryComplianceStats */
     /**
      * TODO: 
      * Move to PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedServices.cs
      * 
      ***************************************************************************/   
  
      public static ReturnSaveOrReplaceRecord saveOrReplaceUserProvidedDeliveryComplianceStats  (   
	                                                    SqlConnection connSpedmon
                                                      , DetailsLog    log
                                                      , UserInfo      uInfo
                                                      , string        clientID
                                                      , string patientsPromisedServicesCDEAuditsCurrentPatientsID
                                                      , string spEdServiceCode
                                                      , string planStartDate
                                                      , string spEdFreqCode
                                                      , string minsPerFreq
                                                      , string minsExpected
                                                      , string minsSatisfied
                                                      , string pctExpectedApplicable
                                                      , string notes
                                                      , string remove
                                                      , string validateRec )
      {           
            
       string saveOrReplaceSproc = "Patients_Promised_Services_CDE_Audits_Current_Patients_User_Provided_Delivery_Compliance_Stats_Save_Or_Replace";                

       /*-------------------------------
        * Validate parameters
        *----------------------------*/
		   
       long       vPatientsPromisedServicesCDEAuditsCurrentPatientsID = Validate.reqInteger (patientsPromisedServicesCDEAuditsCurrentPatientsID,  @"Invalid patid");
       
       long      vClientID              = Validate.reqClientID (uInfo, clientID);
	   long      vSpEdServiceCode       = Validate.reqInteger  (spEdServiceCode,        @"Invalid service");
       DateTime  vPlanStartDate         = Validate.reqDate     (planStartDate,          Messages.INVALID_START_DATE);
       int       vSpEdFreqCode          = Validate.reqInteger  (spEdFreqCode,           @"Invalid service frequency");
       int       vMinsPerFreq           = Validate.reqInteger  (minsPerFreq,            @"Invalid minutes per frequency");
       
       /* If frequency is yearly or other, allow for zero mins expected.  Note: The sproc will sanity check this against our internal data
        * so this is just a data integrity check. */

       bool vAllowZeroForMinsExpected = false;
       
       if ((vSpEdFreqCode == 40) || (vSpEdFreqCode == 90)) {
         vAllowZeroForMinsExpected = true;
       }

       int       vMinsExpected          = Validate.reqInteger  (minsExpected,           @"Invalid minutes expected",  vAllowZeroForMinsExpected);
       int       vMinsSatisfied         = Validate.reqInteger  (minsSatisfied,          @"Invalid minutes satisfied", true);
       int       vPctExpectedApplicable = Validate.reqInteger  (pctExpectedApplicable,  @"Invalid percent satisfied", true);
       string    vNotes                 = Validate.reqString   (notes,                  @"Notes are required");
       bool      vRemove                = Validate.reqFlag     (remove,                 @"Invalid value for remove flag", true);
       
       /* TODO: Temporarily adding validate flag here until Entities.saveOrReplaceRecord can have validate fully implemented */
       bool      vValidate              = Validate.reqFlag     (validateRec,            Messages.INVALID_VALIDATE_FLAG);

       if (vMinsExpected < 0)          throw new Warning (@"Minutes expected cannot be negative");
       if (vMinsSatisfied < 0)         throw new Warning (@"Minutes satisfied cannot be negative");
       if (vPctExpectedApplicable < 0) throw new Warning (@"Percent satisfied cannot be negative");
       
       /*----------------------------
        * Pass parm values to sp
        *----------------------------*/  

       var parms = new List<SqlParameter>();  

  	   parms.Add(Database.SqlParm("@patientsPromisedServicesCDEAuditsCurrentPatientsID",  SqlDbType.BigInt,   vPatientsPromisedServicesCDEAuditsCurrentPatientsID,   ParameterDirection.Input) );

  	   parms.Add(Database.SqlParm("@clientID",                       SqlDbType.BigInt,   vClientID,                       ParameterDirection.Input));
       parms.Add(Database.SqlParm("@spEdServiceCode",                SqlDbType.Int,      vSpEdServiceCode,                ParameterDirection.Input));
       parms.Add(Database.SqlParm("@planStartDate",                  SqlDbType.Date,     vPlanStartDate,                  ParameterDirection.Input));
       parms.Add(Database.SqlParm("@spEdFreqCode",                   SqlDbType.Int,      vSpEdFreqCode,                   ParameterDirection.Input));
       parms.Add(Database.SqlParm("@minsPerFreq",                    SqlDbType.Int,      vMinsPerFreq,                    ParameterDirection.Input));
       parms.Add(Database.SqlParm("@minsExpected",                   SqlDbType.Int,      vMinsExpected,                   ParameterDirection.Input));
       parms.Add(Database.SqlParm("@minsSatisfied",                  SqlDbType.Int,      vMinsSatisfied,                  ParameterDirection.Input));
       parms.Add(Database.SqlParm("@pctExpectedApplicable",          SqlDbType.Int,      vPctExpectedApplicable,          ParameterDirection.Input));
       parms.Add(Database.SqlParm("@notes",                          SqlDbType.VarChar,  vNotes,                          ParameterDirection.Input, 1000));
       parms.Add(Database.SqlParm("@remove",                         SqlDbType.Bit,      vRemove,                         ParameterDirection.Input));

       /* TODO: Temporarily adding validate flag here until Entities.saveOrReplaceRecord can have validate fully implemented */
       parms.Add(Database.SqlParm("@validate",                       SqlDbType.Bit,      vValidate,                       ParameterDirection.Input));
                
       /*----------------------------
        * Call base method which 
        * handles the rest and return
        * results
        *----------------------------*/  

       ReturnSaveOrReplaceRecord so = Entities.saveOrReplaceRecord ( connSpedmon
                                             , log
                                             , uInfo
                                             , validateRec
                                             , saveOrReplaceSproc
                                             , ref parms
                                             , delegate(){});
                                                                                       
       
       return so;

    }

    /***************************************************************************
      * importDataUserProvidedDeliveryComplianceStats */
     /**
      * 
      * 
      ***************************************************************************/   
  
    public static ReturnSaveRecordWithJSONData importDataUserProvidedDeliveryComplianceStats (
                                                              SqlConnection connSpedmon
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

        long vClientID = Validate.reqClientID(uInfo, clientID);

        MBA.StructuredDataFieldAdditionalValidation _fnAdditionalFieldValidation = delegate (int rowNum, StructuredDataField field, string valueIn)
        {
            string valueOut = valueIn;
            return valueOut;
        };

        string vDataToImport = MBA.StructuredDataImportFiles.validate(    STRUCTURED_DATA_IMPORT_PROFILES_FILE_FOR_COMPLIANCE_STATS
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

        parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@importDataJSON", SqlDbType.VarChar, vDataToImport, ParameterDirection.Input, -1));

        /*----------------------------
            * Call base method which
            * handles the rest and return
            * results
            *----------------------------*/

        rd = Entities.saveAndReturnJSONData(
                          connSpedmon
                        , log
                        , uInfo
                        , Constants.SAVE_TYPE_NEW.ToString()
                        , validateRec
                        , ""
                        , ""
                        , "Patients_Promised_Services_CDE_Audits_Current_User_Provided_Delivery_Compliance_Stats_Data_Imports_Save"
                        , @"Duplicate file"
                        , ref parms
                        , null
                        );

        return rd;

    }

  }
}
