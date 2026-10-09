using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;

namespace Spedmon
{

  /***************************************************************************
   * PatientParentMcalConsent */
  /** 
   ***************************************************************************/
  public class PatientParentMcalConsent {
    public long        ID;
    public long        CLIENT_ID;
    public long        PATIENT_ID;
    public string      PATIENT_NAME;
    public DateTime    DATE_OF_BIRTH_VAL;
    public string      DATE_OF_BIRTH_STR;
    public string      PATIENT_SITE_NAME;
    public string      PATIENT_STUDENT_ID;
    public string      PATIENT_CSIS;
    public string      CURRENT_CONSENT_STATUS_STR;
    public bool?       CURRENT_CONSENT_STATUS_VAL;
    public string      CURRENT_CONSENT_STATUS_EFF_DATE_STR;
    public string      CURRENT_CONSENT_STATUS_EFF_DATE_STR_YYYY_MM_DD;
    public DateTime    CURRENT_CONSENT_STATUS_EFF_DATE_VAL;
    public string      CURRENT_CONSENT_STATUS_NOTES;
    public Decimal     HELD_CLAIMS_TOTAL_EST_REIMBURSE_AMOUNT_VAL;
    public string      HELD_CLAIMS_TOTAL_EST_REIMBURSE_AMOUNT_STR;
    public bool        HAS_UNKNOWN_CONSENT;
    public bool        HAS_HELD_CLAIMS;
    public string      CASE_MANAGER;

    }

    /***************************************************************************
     * PatientParentMcalConsents */
    /** 
     ***************************************************************************/
    public class PatientParentMcalConsents : Entities
    {
      public const string SEL_LABEL_MANAGE         = @"Manage Medi-Cal Billing Consent";
      public const string URL_USER_ALL_MANAGE      = @"user_all_manage_patient_parent_mcal_consent.aspx";
      public const string MENU_LNK_USER_ALL_MANAGE = @"managepatientparentmcalconsentlnk";
      public const string DEFAULT_PAGING_ORDER     = @"PATIENT_NAME asc";
      public const string URL_REST_VIEW_BASE       = @"api/v1/patientparentsmcalconsents";
      public const string URL_SVC_BASE             = @"patient_parent_mcal_consents.asmx/";
      public const string URL_WEB_REPORT           = @"patient_parent_mcal_consents.ashx";
      
     /***************************************************************************
      * URL_WEB_REPORT_BASE */
     /**
      * 
      **************************************************************************/
      public static string URL_WEB_REPORT_BASE()
      {
        return MBA.HttpApplication.createLink(URL_WEB_REPORT, true);
      }
        public static string URL_SVC_UPDATE_PATIENT_PARENT_CONSENT_BASE()
      {
        return MBA.HttpApplication.createLink(URL_SVC_BASE + @"updatepatientparentmcalconsent", true);
      }

      public static string URL_REST_VIEW_PATIENT_PARENT_CONSENTS_BASE()
      { 
        return MBA.HttpApplication.createLink( PatientParentMcalConsents.URL_REST_VIEW_BASE, true);
      }

      public static string URL_SVC_CLIENT_CONSENT_TEXT_GET_BASE()
      {
        return MBA.HttpApplication.createLink(URL_SVC_BASE + @"getclientmcalbillingdefaultconsentmsgtext", true, new NameValue(Constants.PARM_CLIENT_ID, @""));
      } 

      public static string URL_SVC_CLIENT_CONSENT_TEXT_SET_BASE()
      {
        return MBA.HttpApplication.createLink(URL_SVC_BASE + @"setclientmcalbillingdefaultconsentmsgtext", true, new NameValue(Constants.PARM_CLIENT_ID, @""));
      } 

      public static string URL_REQUEST_PARENT_SVC_AUTH_BASE()
      {
        return MBA.HttpApplication.createLink(ServiceAuthorizationRequests.URL_SAVE, true, new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE), new NameValue(ServiceAuthorizationRequests.PARM_NAME_AUTH_REQUEST_TYPE, (int)ServiceAuthorizationRequestTypes.PARENT_CONSENT_MCAL_BILLING), new NameValue(ServiceAuthorizationRequests.PARM_NAME_REFD_ENTITY_ID, ""));
      } 

      public static string URL_USER_ALL_MANAGE_BASE()
      {
        return MBA.HttpApplication.createLink( PatientParentMcalConsents.URL_USER_ALL_MANAGE, true);
      } 

   /***************************************************************************
    * updatePatientParentMcalConsent */
   /** 
    ***************************************************************************/
   public static ReturnSaveRecord updatePatientParentMcalConsent (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        clientID
      , string        patID
      , string        consentFlag
      , string        consentEffectiveDate
      , string        notes
      , string        caseManager)
    
    {

      var parms = new List<SqlParameter>();

      int      vClientID             = Validate.reqClientID      (uInfo, clientID);
      int      vPatID                = Validate.reqInteger       (patID,                Messages.INVALID_PAT_ID, false);
      Object   vConsentFlag          = Validate.reqFlagOrUnknown (consentFlag,          Messages.INVALID_PARENT_CONSENT_MCAL);
      DateTime vConsentEffectiveDate = Validate.reqDate          (consentEffectiveDate, Messages.INVALID_PARENT_CONSENT_MCAL_EFF_DATE);
      Object   vNotes                = Validate.optString        (notes, @"Invalid notes");
      Object   vcaseManager          = Validate.optString        (caseManager, @"Invalid case manager");
      
      parms.Add(MBA.Database.SqlParm("@clientID",      SqlDbType.BigInt,  vClientID,             ParameterDirection.Input));
      parms.Add(MBA.Database.SqlParm("@consentFlag",   SqlDbType.Bit,     vConsentFlag,          ParameterDirection.Input));
      parms.Add(MBA.Database.SqlParm("@effectiveDate", SqlDbType.Date,    vConsentEffectiveDate, ParameterDirection.Input));
      parms.Add(MBA.Database.SqlParm("@notes",         SqlDbType.VarChar, vNotes,                ParameterDirection.Input, -1));
      parms.Add(MBA.Database.SqlParm("@caseManager",   SqlDbType.VarChar, vcaseManager,          ParameterDirection.Input,256));
            
      return recordOp (  connSpedmon
                       , log
                       , uInfo
                       , ""
                       , "0"
                       , vPatID.ToString()
                       , "[dbo].[PATIENT_PARENT_MCAL_CONSENT_SAVE]"
                       , ref parms);

    }
    
    /***************************************************************************
     * setClientMCALBillingDefaultConsentMsgText */
    /** 
     ***************************************************************************/
    public static ReturnSaveRecord setClientMCALBillingDefaultConsentMsgText (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        clientID
      , string        msgText )
    {
      int    vClientID =  Validate.reqClientID (uInfo, clientID);
      string vMsgText  =  Validate.reqString   (msgText, @"Please provide text");

      var parms = new List<SqlParameter>();

      parms.Add(MBA.Database.SqlParm("@msgText", SqlDbType.VarChar, vMsgText, ParameterDirection.Input, -1));

      return recordOp (  connSpedmon
                        , log
                        , uInfo
                        , ""
                        , "0"
                        , vClientID.ToString()
                        , "[dbo].[PATIENT_PARENT_MCAL_CONSENT_CLIENT_DEFAULT_BILLING_MESSAGE_SAVE]"
                        , ref parms);
 
    }

    /***************************************************************************
     * getClientMCALBillingDefaultConsentMsgText */
    /** 
      ***************************************************************************/
     public static ReturnValue getClientMCALBillingDefaultConsentMsgText (
          SqlConnection connSpedmon
        , DetailsLog   log
        , UserInfo     uInfo
        , string       clientID ) 
     {  
       var so = new ReturnValue();

       int vClientID = Validate.reqClientID(uInfo, clientID);
       var sql       = "select top 1 @value = clc.defaultMCALBillingConsentMsgText from dbo.CLIENTS_Client as clc where (clc.CLIENT_ID = @clientID)";
       var vValue    = "";

       var parms = new List<SqlParameter>();
       parms.Add(Database.SqlParm("@clientID", SqlDbType.Int,     vClientID,  ParameterDirection.Input));   
       parms.Add(Database.SqlParm("@value",    SqlDbType.VarChar, vValue,     ParameterDirection.Output, -1));
       
       var rd = Database.execQuery(connSpedmon, log, sql, false, parms);
       vValue = (String) Database.getParameterValue("@value", ref parms);
       so.value = vValue;
       return so;
     }
     
     /***************************************************************************
      * view */
     /** 
      ***************************************************************************/
     protected static ReturnDB view (
          SqlConnection connSpedmon
        , DetailsLog    log
        , UserInfo      uInfo
        , int           recViewType
        , bool          pagedOrTop
        , string        idx
        , string        canEdit
        , string        active
        , string        clientID
        , string        patID
        , string        parentConsent
        , string        hasUnknownConsent
        , string        hasHeldClaims
        , defineCols    dc )
    {
      string viewUDF = "dbo.PATIENT_PARENT_MCAL_CONSENT_VIEW (@clientID, @patid, @parentConsent, @hasUnknownConsent, @hasHeldClaims)";

      var parms = new List<SqlParameter>();

      long   vClientID           = Validate.reqClientID (uInfo, clientID);
      Object vPatID              = Validate.optInteger  (patID, Messages.INVALID_PAT_ID);
      Object vParentConsent      = Validate.optFlag     (parentConsent,     @"Invalid parent consent flag");
      Object vHasUnknownConsent  = Validate.optFlag     (hasUnknownConsent, @"Invalid unknown consent flag");
      Object vHasHeldClaims      = Validate.optFlag     (hasHeldClaims,     @"Invalid held claims flag");

      parms.Add(Database.SqlParm("@clientID",           SqlDbType.BigInt,  vClientID,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",              SqlDbType.BigInt,  vPatID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@parentConsent",      SqlDbType.Bit,     vParentConsent,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@hasUnknownConsent",  SqlDbType.Bit,     vHasUnknownConsent, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@hasHeldClaims",      SqlDbType.Bit,     vHasHeldClaims,     ParameterDirection.Input));

      var rd = Entities.view (  connSpedmon
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
      return rd;
    }
     
     /***************************************************************************
      * viewTbl */
     /**
      * Returns a data table of records for preview or record selection.
      *
      * @return                 ReturnDataTable
      ***************************************************************************/

     public static ReturnDataTable viewTbl ( SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , bool paged
                                                , string pageNumber
                                                , string canEdit
                                                , string active                                              
                                                , string clientID
                                                , string patID
                                                , string parentConsent
                                                , string hasUnknownConsent
                                                , string hasHeldClaims)
        {
            ReturnDataTable so = new ReturnDataTable();

            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("PATIENT_NAME                         as [Patient]", true);
                ss.addDisplayColumn("DATE_OF_BIRTH_STR                    as [Date\nOf\nBirth]");
                ss.addDisplayColumn("PATIENT_STUDENT_ID                   as [Student ID]");
                ss.addDisplayColumn("PATIENT_CSIS                         as [CSIS]");
                ss.addDisplayColumn("PATIENT_SITE_NAME                    as [School\nSite]");

                ss.addDisplayColumn("CURRENT_CONSENT_STATUS_STR           as [Parental\nConsent]");
                ss.addDisplayColumn("CURRENT_CONSENT_STATUS_EFF_DATE_STR  as [Effective\nDate]");
                ss.addDisplayColumn("CURRENT_CONSENT_STATUS_NOTES         as [Notes]");
                ss.addDisplayColumn("CASE_MANAGER                         as [Case Manager]");
                ss.addDisplayColumn("HELD_CLAIMS_TOTAL_EST_REIMBURSE_AMOUNT_STR  as [Potential\nLost\nReimbursement]");
                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * Call base method which
             * handles the rest
             *----------------------------*/

            so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
              delegate {
                  return PatientParentMcalConsents.view(connSpedmon
                                                                             , log
                                                                             , uInfo
                                                                             , Entities.REC_VIEW_TBL
                                                                             , paged
                                                                             , pageNumber
                                                                             , canEdit
                                                                             , active
                                                                             , clientID
                                                                             , patID
                                                                             , parentConsent
                                                                             , hasUnknownConsent
                                                                             , hasHeldClaims
                                                                             , dc);
              });

            /*----------------------------
             * Add a title and footer
             *----------------------------*/

            so.tableName = SEL_LABEL_MANAGE;
            so.tableFooter = Messages.CONFIDENTIAL;

            /*----------------------------
             * Done
             *----------------------------*/

            return so;
        }

        /***************************************************************************
         * viewObjects 
         *
         * Returns a list of patients objects
         * 
         ***************************************************************************/

        public static ReturnObjects viewObjects(   SqlConnection connSpedmon
                                              , DetailsLog   log
                                              , UserInfo     uInfo
                                              , bool         pageObjectList
                                              , string       pageOrder
                                              , string       idx
                                              , string       active
                                              , string       clientID
                                              , string       patID
                                              , string       parentConsent
                                              , string       hasUnknownConsent
                                              , string       hasHeldClaims )

    {           
      /* Default page order */  

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientParentMcalConsents.DEFAULT_PAGING_ORDER;
     
      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      var rd =  Entities.viewObjects(  connSpedmon
                                   , log
                                   , uInfo
                                   , typeof(PatientParentMcalConsent)
                                   , pageObjectList
                                   , pageOrder
                                   , delegate {                                      
                                       return PatientParentMcalConsents.view (  connSpedmon
                                                                              , log
                                                                              , uInfo
                                                                              , Entities.REC_VIEW_OBJECTS
                                                                              , pageObjectList
                                                                              , idx
                                                                              , "" /* Can edit */
                                                                              , active                                                             
                                                                              , clientID
                                                                              , patID
                                                                              , parentConsent
                                                                              , hasUnknownConsent
                                                                              , hasHeldClaims
                                                                              , dc );
                                    });

      return rd;
    }
    

  }
}
