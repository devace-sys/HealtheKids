using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

/*
 * THIS ROUTINE CONTAINS EXPANSION HOOKS FOR E-AUTHORIZE
 * Add additional code if needed to support new request types
 */

namespace Spedmon
{
  /***************************************************************************
   * ServiceAuthorizationRequestMessage */
  /**
   * 
   **************************************************************************/  
  public class ServiceAuthorizationRequestMessage : NotificationMessage
  { 

  }
  
  /***************************************************************************
   * ServiceAuthorizationRequestMessages */
  /**
   * 
   **************************************************************************/  
  public class ServiceAuthorizationRequestMessages
  {
    public List<NewUserAccount>      accounts;  
    public List<NotificationMessage> messages;

  }
    /**************************************************************************
     * ServiceAuthorizationRequestTypes */
    /**
     ****************************************************************************/

    public enum ServiceAuthorizationRequestTypes
    {
        ORDER_OR_PRESCRIPTION        = 1
      , PATIENT_PROFILE              = 2
      , PARENT_CONSENT_MCAL_BILLING  = 3
      , PARENT_CONSENT_CARE_PLAN     = 4
      /* Expansion hook:  Add request types here if needed */
    }

    /***************************************************************************
     * ServiceAuthorizationRequest */
    /**
     * 
     **************************************************************************/
    public class ServiceAuthorizationRequest: Entity
  {

    public string   requestDateStr;
    public long     clientID;
    public string   clientName;
    
    public long     pracID;
    public string   pracName;  
    public string   pracTitle;
    public string   pracEmail;
    public string   pracPhone;

    public long     districtContactUserID;
    public string   districtContactName;
    public string   districtContactEmail;
	public string   districtContactPhone;

    public long     patID;
	public string   patName;
    public string   patDOBStr;
	public string   patCSIS;
    
    public long     groupSvcClassNameID;

    /* File data to use for creating permanent records for this request and what supporting files to include */
    
    public long     fileClass;
	public string   fileNameSpace;
	public string   fileSource;

    /* File data to use for associated included files */
    
    public bool     hasFileIncludes;
    public long     fileClassInclude;
    public string   fileNameSpaceInclude;
    public string   fileSourceInclude;
    public bool     filesToIncludeUseClientIdDataParameter;
    public bool     filesToIncludeUsePracIdDataParameter;
    public bool     filesToIncludeUsePatIdDataParameter;
    public string   filesToIncludeUploadIds;
    public string   filesToIncludeUploadNames;

    public long     svcAuthorizationRequestTypeID;
	public long     referencedEntityID;
	public long     svcSelectionTypeID;
	public long     svcSelectionNameID;
	public string   svcName;
	public string   svcDescription;    
    public string   svcStartDateStr;
    public long     reqSvcAuthFromSelectionID;
	public string   reqSvcAuthFromSelectionName;
    public long     reqSvcAuthMethodSelectionID;
	public string   reqSvcAuthMethodSelectionName;

	public long     prtGrd1PersonID;
	public string   prtGrd1Name;
	public string   prtGrd1RelationshipWithPatientLabel;
	public string   prtGrd1Email;
	public string   prtGrd1Phone;
	public string   prtGrd1PlaceAddress;

	  /*
    public long     prtGrd2PersonID;
	  public string   prtGrd2Name;
	  public string   prtGrd2RelationshipWithPatientLabel;
	  public string   prtGrd2Email;
    public string   prtGrd2Phone;
	  public string   prtGrd2PlaceAddress;
	  */

    public long     orpPracID;
	  public string   orpPracName;
    public string   orpPracTitle;
    public string   orpPracEmail;
	  public string   orpPracPhone;   
	  public string   orpPracPlaceAddress;
    public string   orpPracNPI;

    public DateTime created;
    public long     createdBy;
    public DateTime lastModfied;
    public long     lastModifiedBy;
        
    public long     currentStatusCode;
    public string   currentStatusName;
    public long     currentResponseCode;
    public string   currentResponseName; 
	    
    public string   productKey;
    public bool     closed;
    
    public bool     viewingUserCanAccessSupportingFiles;
	public bool     viewingUserCanCurrentlyAccessResponseForm;                    
    public bool     responseRequiredFromViewingUser;
    public bool     viewingUserCanCurrentlyDeleteAndSaveNew;
    public bool     viewingUserCanCurrentlyCloseAndSaveNew;    
    public bool     viewingUserCanCurrentlyEditServiceDescription;

    public bool     showPrevResponseInChain;    
    public long     prevChainRequestEntryPurposeID;
    public string   prevChainRequestEntryPurposeName;
    public long     prevChainReqSvcAuthFromSelectionID;
    public string   prevChainReqSvcAuthFromSelectionName;
	  public long     prevChainReqSvcAuthMethodSelectionID;
	  public string   prevChainReqSvcAuthMethodSelectionName;
    public long     prevChainResponseFromUserID;
	  public string   prevChainResponseFromUserName;
	  public string   prevChainRespondantName;
    public string   prevChainRespondantTitle;
    public string   prevChainRespondantSignature;
    public string   prevChainRespondantEmail;
    public string   prevChainRespondantPhone;
    public string   prevChainRespondantNPI;
    public bool     prevChainShowRespondantNPI;
	  public DateTime prevChainResponseRecordedOn;
	  public string   prevChainResponseRecordedOnStr;
	  public DateTime prevChainResponseEffectiveDate;
	  public string   prevChainResponseEffectiveDateStr;
	  public string   prevChainResponseNotes;
    public string   prevChainResponseSectionTitle;
	  public string   prevChainResponseAttestStatement;
	  public long     prevChainResponsePersonRoleCode;
    public string   prevChainResponsePersonRoleName;
	  public long     prevChainResponseCode;
    public string   prevChainResponseName;
    public string   prevChainResponseSummary;
    public bool     prevChainShowResponseNotes;

    public bool     showCurrResponseInChain;    
    public long     currChainRequestEntryPurposeID;
    public string   currChainRequestEntryPurposeName;
    public long     currChainReqSvcAuthFromSelectionID;
    public string   currChainReqSvcAuthFromSelectionName;
	  public long     currChainReqSvcAuthMethodSelectionID;
	  public string   currChainReqSvcAuthMethodSelectionName;
    public long     currChainResponseFromUserID;
	  public string   currChainResponseFromUserName;
	  public string   currChainRespondantName;
    public string   currChainRespondantTitle;
    public string   currChainRespondantSignature;
    public string   currChainRespondantEmail;
    public string   currChainRespondantPhone;
    public string   currChainRespondantNPI;
    public bool     currChainShowRespondantNPI;
	  public DateTime currChainResponseRecordedOn;
	  public string   currChainResponseRecordedOnStr;
	  public DateTime currChainResponseEffectiveDate;
	  public string   currChainResponseEffectiveDateStr;
	  public string   currChainResponseNotes;
    public string   currChainResponseSectionTitle;
	  public string   currChainResponseAttestStatement;
	  public long     currChainResponsePersonRoleCode;
    public string   currChainResponsePersonRoleName;
	  public long     currChainResponseCode;
    public string   currChainResponseName;
    public string   currChainResponseSummary;
    public bool     currChainShowResponseNotes;

    public bool     showNextResponseInChain;    
    public long     nextChainRequestEntryPurposeID;
    public string   nextChainRequestEntryPurposeName;
    public long     nextChainReqSvcAuthFromSelectionID;
    public string   nextChainReqSvcAuthFromSelectionName;
	  public long     nextChainReqSvcAuthMethodSelectionID;
	  public string   nextChainReqSvcAuthMethodSelectionName;
    public long     nextChainResponseFromUserID;
	  public string   nextChainResponseFromUserName;
	  public string   nextChainRespondantName;
    public string   nextChainRespondantTitle;   
    public string   nextChainRespondantSignature;
    public string   nextChainRespondantEmail;
    public string   nextChainRespondantPhone;
    public string   nextChainRespondantNPI;
    public bool     nextChainShowRespondantNPI;
	  public DateTime nextChainResponseRecordedOn;
	  public string   nextChainResponseRecordedOnStr;
	  public DateTime nextChainResponseEffectiveDate;
	  public string   nextChainResponseEffectiveDateStr;
	  public string   nextChainResponseNotes;
    public string   nextChainResponseSectionTitle;
	  public string   nextChainResponseAttestStatement;
	  public long     nextChainResponsePersonRoleCode;
    public string   nextChainResponsePersonRoleName;
	  public long     nextChainResponseCode;
    public string   nextChainResponseName;    	      
    public string   nextChainResponseSummary;
    public bool     nextChainShowResponseNotes;

    public string formBuilderQuestionsJSON;
    public string formBuilderAnswersJSON;

    /* Display rules for request screen */

    public bool   dspRuleReqShowRequestFromSelection     = false;
    public bool   dspRuleReqShowParentGuardianSelection  = false;
    public bool   dspRuleReqShowORPSelection             = false;

    public bool   dspRuleRspShowSupportingFilesSection     = false;
    public bool   dspRuleRspShowDownloadReturnForm         = false;
    public bool   dspRuleReplaceServiceDescriptionWithForm = false;
    public string replaceServiceDescriptionWithFormNotice = @"";
    public string requestOrResponseScreenSubTitle = @"";

  }

    /***************************************************************************
     * ServiceAuthorizationRequests */
    /**
     * 
     **************************************************************************/
    public class ServiceAuthorizationRequests : Entities
    {

        /***************************************************************************
          * SEL_LABEL */
        /**
         * Selection labels for menus and screens
         ***************************************************************************/

        public const string SEL_LABEL = @"Service Authorization Requests";
        public const string SEL_LABEL_NEW = @"Add New";
        public const string SEL_LABEL_EDIT = @"Edit";
        public const string SEL_LABEL_EDIT_DELETE = @"Edit or Delete Existing";
        public const string SEL_LABEL_VIEW = @"View";
        public const string SEL_LABEL_RESPOND = @"Service Authorization Requests";


        /***************************************************************************
         * URL_* */
        /**
         * Urls 
         ***************************************************************************/

        public const string URL_SVC_BASE                 = @"service_authorization_requests.asmx";
        public const string URL_SVC_SAVE                 = URL_SVC_BASE + @"/save";
        public const string URL_SVC_DEL_AND_SAVE_NEW     = URL_SVC_BASE + @"/deleteandsavenew";
        public const string URL_SVC_CLOSE_AND_SAVE_NEW   = URL_SVC_BASE + @"/closeandsavenew";
        public const string URL_DELETE                   = URL_SVC_BASE + @"/delete";
        public const string URL_SAVE                     = @"user_all_service_authorization_request_save.aspx";
        public const string PARM_NAME_AUTH_REQUEST_TYPE  = @"svcAuthorizationRequestTypeID";
        public const string PARM_NAME_REFD_ENTITY_ID     = @"referencedEntityID";
        
        /***************************************************************************
         * loadInitialData */
        /**
         * Prefills as much as possible based on the request type
         *
         ***************************************************************************/
        public static ServiceAuthorizationRequest loadInitialData  (  SqlConnection connSpedmon
                                                                    , DetailsLog log
                                                                    , UserInfo uInfo
                                                                    , string clientID
                                                                    , string svcAuthorizationRequestTypeID
                                                                    , string referencedEntityID)
        {

            ServiceAuthorizationRequest so = null;

            Object vClientID                       = Validate.optClientID (uInfo, clientID);  /* Note: This takes care of making sure clients can only access their own data */
            long   vSvcAuthorizationRequestTypeID  = Validate.reqInteger  (svcAuthorizationRequestTypeID, @"Invalid authorization request type");
            long   vReferencedEntityID             = Validate.reqInteger  (referencedEntityID,            @"Invalid document id");

            var parms = new List<SqlParameter>();

            validateAndAddCommonUserInfoParameters(uInfo, ref parms);

            parms.Add(Database.SqlParm("@clientID",                      SqlDbType.BigInt, vClientID,                      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcAuthorizationRequestTypeID", SqlDbType.BigInt, vSvcAuthorizationRequestTypeID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@referencedEntityID",            SqlDbType.BigInt, vReferencedEntityID,            ParameterDirection.Input));

            string sql = @"select top 1 * from dbo.SERVICE_AUTHORIZATION_REQUEST_GET_INITIAL_DATA (@userID, @userGroup, @userRank, @clientID, @svcAuthorizationRequestTypeID, @referencedEntityID)";
            ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);

            if (rd.hasRecords)
            {
              so = (ServiceAuthorizationRequest) Database.convertRecord (rd.records, typeof(ServiceAuthorizationRequest));
            }

            /*             
             *  Set either "hard coded" or default value for WHO is BEING asked for authorization 
             *  TODO: Move this to the database so we can make this data driven
             */

            switch (vSvcAuthorizationRequestTypeID)
            {
                case (int) ServiceAuthorizationRequestTypes.PARENT_CONSENT_MCAL_BILLING:
                case (int)ServiceAuthorizationRequestTypes.PARENT_CONSENT_CARE_PLAN:
                /* Expansion hook:  Add request types here if needed */
                    so.reqSvcAuthFromSelectionID = (int) RequestServiceAuthorizationFrom.PARENTS;
                    break;
                case (int) ServiceAuthorizationRequestTypes.ORDER_OR_PRESCRIPTION:
                case (int) ServiceAuthorizationRequestTypes.PATIENT_PROFILE:
                /* Expansion hook:  Add request types here if needed */
                default:
                  so.reqSvcAuthFromSelectionID = (int) RequestServiceAuthorizationFrom.ORP_PROFESSIONAL;
                  break;
            }
            return so;
        }

        /***************************************************************************
         * setDisplayRules */
        /**
         * 
         *
         ***************************************************************************/

        public static void setDisplayRules (ref ServiceAuthorizationRequest sar)
        {
          if (sar == null) return;

          if (     (sar.svcAuthorizationRequestTypeID == (int) ServiceAuthorizationRequestTypes.ORDER_OR_PRESCRIPTION)
                || (sar.svcAuthorizationRequestTypeID == (int) ServiceAuthorizationRequestTypes.PATIENT_PROFILE)
                
             )
            {

            sar.dspRuleReqShowRequestFromSelection       = true;
            sar.dspRuleReqShowParentGuardianSelection    = true;
            sar.dspRuleReqShowORPSelection               = true;
            sar.dspRuleReplaceServiceDescriptionWithForm = true;
            sar.replaceServiceDescriptionWithFormNotice  = Messages.MSG_SVC_DESC_RETIRMENT_SVC_AUTH_REQUEST;

            if (sar.reqSvcAuthFromSelectionID == (int) RequestServiceAuthorizationFrom.ORP_PROFESSIONAL) sar.dspRuleReqShowParentGuardianSelection = false;

            sar.requestOrResponseScreenSubTitle = String.Format(@"Request authorization to provide {0} for {1}", sar.svcName, sar.patName);            
            return;
          }

          if (sar.svcAuthorizationRequestTypeID == (int) ServiceAuthorizationRequestTypes.PARENT_CONSENT_MCAL_BILLING)
          {
            sar.dspRuleReqShowRequestFromSelection        = false;
            sar.dspRuleReqShowParentGuardianSelection     = true;
            sar.dspRuleReqShowORPSelection                = false;
            sar.dspRuleReplaceServiceDescriptionWithForm  = false;
       
            sar.requestOrResponseScreenSubTitle = String.Format(@"Request authorization to bill Medi-Cal for professional treatment or therapy services provided to {0}", sar.patName);

            return;
          }

          if (sar.svcAuthorizationRequestTypeID == (int) ServiceAuthorizationRequestTypes.PARENT_CONSENT_CARE_PLAN)
          {
             sar.dspRuleReqShowRequestFromSelection           = false;
             sar.dspRuleReqShowParentGuardianSelection        = true;
             sar.dspRuleReqShowORPSelection                   = false;
             sar.dspRuleReplaceServiceDescriptionWithForm     = false;
             sar.requestOrResponseScreenSubTitle = String.Format(@"Request authorization for the care plan prepared for {0}", sar.patName);

             return;
          }

          /*if () { return }*/
          /* Expansion hook:  Add request types here if needed */
          return;

        }

        /***************************************************************************
         * save */
        /**
         * Save new or update existing record
         *
         ***************************************************************************/
        protected static ReturnSaveRecord _saveCore (  SqlConnection connSpedmon
                                              , SqlConnection connUser
                                              , DetailsLog    log
                                              , UserInfo      uInfo
                                              , string        saveSproc  
                                              , string        dupRecMsg  
                                              , string        clientID
                                              , string        districtContactUserID
                                              , string        patID
                                              , string        svcAuthorizationRequestTypeID
                                              , string        referencedEntityID
                                              , string        svcDescription
                                              , string        formBuilderQuestionsJSON
                                              , string        formBuilderAnswersJSON
                                              , string        reqSvcAuthFromSelectionID
                                              , string        reqSvcAuthMethodSelectionID
                                              , string        prtGrd1PersonID
                                              , string        prtGrd2PersonID
                                              , string        orpPracID
                                              , string        selectedFileList
                                              , string        editDelReason
                                              , string        validateRec
                                              , string        saveType
                                              , string        recID )
    {                              
      
       /*###########################################################################
         # Validate parameters specific to this entity save and create their 
         # database parameters
         ###########################################################################*/  
                 
       long    vClientID                          = Validate.reqClientID (uInfo,clientID);
       Object  vDistrictContactUserID             = Validate.optInteger  (districtContactUserID,         Messages.INVALID_USER_ID);
       long    vPatID                             = Validate.reqInteger  (patID,                         Messages.INVALID_PAT_ID);
       long    vSvcAuthorizationRequestTypeID     = Validate.reqInteger  (svcAuthorizationRequestTypeID, @"Invalid authorization request type");
       long    vReferencedEntityID                = Validate.reqInteger  (referencedEntityID,            @"Invalid document id");      
       string  vSvcDescription                    = Validate.optString   (svcDescription,                @"Invalid service description");
       string  vFormBuilderQuestionsJSON          = Validate.optString   (formBuilderQuestionsJSON,        @"Invalid questions");

       string  vFormBuilderAnswersJSON = (String.IsNullOrEmpty(vSvcDescription)) ?
                                          Validate.reqString   (formBuilderAnswersJSON, @"Invalid form data or service description") :
                                          Validate.optString(formBuilderAnswersJSON   , @"Invalid form answers");

       long    vReqSvcAuthFromSelectionID         = Validate.reqInteger  (reqSvcAuthFromSelectionID,     @"Invalid authorization request from selection");
       long    vReqSvcAuthMethodSelectionID       = Validate.reqInteger  (reqSvcAuthMethodSelectionID,   @"Invalid request method");      
       Object  vPrtGrd1PersonID                   = Validate.optInteger  (prtGrd1PersonID,               @"Invalid parent or guardian ID");
       Object  vPrtGrd2PersonID                   = Validate.optInteger  (prtGrd2PersonID,               @"Invalid parent or guardian ID");
       Object  vOrpPracID                         = Validate.optInteger  (orpPracID,                     @"Invalid ORP Professional");

       // Note: Validate flag and save type are needed to determine if we are possibly creating user account(s) and
       // emailing them

       bool vValidateRec  = Validate.reqFlag    (validateRec,  Messages.INVALID_VALIDATE_FLAG);
       int   vSaveType    = Validate.reqInteger (saveType,     Messages.INVALID_SAVE_TYPE);

       var parms = new List<SqlParameter>();
        
       parms.Add(Database.SqlParm("@clientID",                          SqlDbType.BigInt,  vClientID,                        ParameterDirection.Input));
       parms.Add(Database.SqlParm("@patID",                             SqlDbType.BigInt,  vPatID,                           ParameterDirection.Input));
       parms.Add(Database.SqlParm("@districtContactUserID",             SqlDbType.BigInt,  vDistrictContactUserID,           ParameterDirection.Input));
       parms.Add(Database.SqlParm("@svcAuthorizationRequestTypeID",     SqlDbType.BigInt,  vSvcAuthorizationRequestTypeID,   ParameterDirection.Input));
       parms.Add(Database.SqlParm("@referencedEntityID",                SqlDbType.BigInt,  vReferencedEntityID,              ParameterDirection.Input));
       parms.Add(Database.SqlParm("@svcDescription",                    SqlDbType.VarChar, vSvcDescription,                  ParameterDirection.Input, 8000));
       parms.Add(Database.SqlParm("@formBuilderQuestionsJSON",          SqlDbType.VarChar, vFormBuilderQuestionsJSON,        ParameterDirection.Input, -1));
       parms.Add(Database.SqlParm("@formBuilderAnswersJSON",            SqlDbType.VarChar, vFormBuilderAnswersJSON,          ParameterDirection.Input, -1));
       parms.Add(Database.SqlParm("@reqSvcAuthFromSelectionID",         SqlDbType.BigInt,  vReqSvcAuthFromSelectionID,       ParameterDirection.Input));      
       parms.Add(Database.SqlParm("@reqSvcAuthMethodSelectionID",       SqlDbType.BigInt,  vReqSvcAuthMethodSelectionID,     ParameterDirection.Input));
       parms.Add(Database.SqlParm("@prtGrd1PersonID",                   SqlDbType.BigInt,  vPrtGrd1PersonID,                 ParameterDirection.Input));
       parms.Add(Database.SqlParm("@prtGrd2PersonID",                   SqlDbType.BigInt,  vPrtGrd2PersonID,                 ParameterDirection.Input));
       parms.Add(Database.SqlParm("@orpPracID",                         SqlDbType.BigInt,  vOrpPracID,                       ParameterDirection.Input));
       parms.Add(Database.SqlParm("@selectedFileList",                  SqlDbType.VarChar, selectedFileList,                 ParameterDirection.Input, -1));
       parms.Add(Database.SqlParm("@pwdMinLen",                         SqlDbType.Int,     Rules.PWD_MIN_LENGTH,             ParameterDirection.Input));

       parms.Add(Database.SqlParm("@svcAuthRequestMsgUrlBase",          SqlDbType.VarChar, MBA.Credential.generateDirectLoginLink(@""), ParameterDirection.Input, 512));
       parms.Add(Database.SqlParm("@svcAuthRequestPaperUploadUrlBase",  SqlDbType.VarChar, ServiceAuthorizationCommon.URL_UPLOAD_COMPLETED_REQUEST_FORM, ParameterDirection.Input, 512));
              
       /*###########################################################################
         # Call base method which handles the rest and returns the results
         ###########################################################################*/  

       var so = Entities.saveAndReturnJSONData (   connSpedmon
                                                 , log
                                                 , uInfo
                                                 , saveType
                                                 , validateRec
                                                 , editDelReason
                                                 , recID
                                                 , saveSproc
                                                 , dupRecMsg
                                                 , ref parms
                                                 , null );      
            

       return ServiceAuthorizationCommon.ExtractAndProcessReturnData (ref so, vValidateRec);       
     }      

    /***************************************************************************
     * save */
    /**
     ***************************************************************************/     
    public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                          , SqlConnection connUser
                                          , DetailsLog    log
                                          , UserInfo      uInfo
                                          , string        clientID
                                          , string        districtContactUserID
                                          , string        patID
                                          , string        svcAuthorizationRequestTypeID
                                          , string        referencedEntityID
                                          , string        svcDescription
                                          , string        formBuilderQuestionsJSON
                                          , string        formBuilderAnswersJSONForOrder
                                          , string        reqSvcAuthFromSelectionID
                                          , string        reqSvcAuthMethodSelectionID
                                          , string        prtGrd1PersonID
                                          , string        prtGrd2PersonID
                                          , string        orpPracID
                                          , string        selectedFileList
                                          , string        editDelReason
                                          , string        validateRec
                                          , string        saveType
                                          , string        recID )
    {           
                                     
       return _saveCore (   connSpedmon
                          , connUser
                          , log
                          , uInfo
                          , @"SERVICE_AUTHORIZATION_REQUEST_SAVE"
                          , @"Active request already exists"                          
                          , clientID
                          , districtContactUserID
                          , patID
                          , svcAuthorizationRequestTypeID
                          , referencedEntityID
                          , svcDescription
                          , formBuilderQuestionsJSON
                          , formBuilderAnswersJSONForOrder
                          , reqSvcAuthFromSelectionID
                          , reqSvcAuthMethodSelectionID
                          , prtGrd1PersonID
                          , prtGrd2PersonID
                          , orpPracID
                          , selectedFileList
                          , editDelReason
                          , validateRec
                          , saveType
                          , recID );
     } 

    /***************************************************************************
     * closeAndSaveNew */
    /**
     * Note: This requires the same signature/parameters as the save method
     *
     ***************************************************************************/     
    public static ReturnSaveRecord closeAndSaveNew (    SqlConnection connSpedmon
                                                       , SqlConnection connUser
                                                       , DetailsLog    log
                                                       , UserInfo      uInfo
                                                       , string        clientID
                                                       , string        districtContactUserID
                                                       , string        patID
                                                       , string        svcAuthorizationRequestTypeID
                                                       , string        referencedEntityID
                                                       , string        svcDescription
                                                       , string        formBuilderQuestionsJSON
                                                       , string        formBuilderAnswersJSONForOrder
                                                       , string        reqSvcAuthFromSelectionID
                                                       , string        reqSvcAuthMethodSelectionID
                                                       , string        prtGrd1PersonID
                                                       , string        prtGrd2PersonID
                                                       , string        orpPracID
                                                       , string        selectedFileList
                                                       , string        editDelReason
                                                       , string        validateRec
                                                       , string        saveType
                                                       , string        recID )
    {           
                                     
       return _saveCore (   connSpedmon
                          , connUser
                          , log
                          , uInfo
                          , @"SERVICE_AUTHORIZATION_REQUEST_CLOSE_AND_SAVE_NEW"
                          , @"This request has been closed and resent already today"
                          , clientID
                          , districtContactUserID
                          , patID
                          , svcAuthorizationRequestTypeID
                          , referencedEntityID
                          , svcDescription
                          , formBuilderQuestionsJSON
                          , formBuilderAnswersJSONForOrder
                          , reqSvcAuthFromSelectionID
                          , reqSvcAuthMethodSelectionID
                          , prtGrd1PersonID
                          , prtGrd2PersonID
                          , orpPracID
                          , selectedFileList
                          , editDelReason
                          , validateRec
                          , saveType
                          , recID );

    } 


    /***************************************************************************
     * deleteAndSaveNew */
    /**
     * Note: This requires the same signature/parameters as the save method
     *
     ***************************************************************************/     
    public static ReturnSaveRecord deleteAndSaveNew (    SqlConnection connSpedmon
                                                       , SqlConnection connUser
                                                       , DetailsLog    log
                                                       , UserInfo      uInfo
                                                       , string        clientID
                                                       , string        districtContactUserID
                                                       , string        patID
                                                       , string        svcAuthorizationRequestTypeID
                                                       , string        referencedEntityID
                                                       , string        svcDescription
                                                       , string        formBuilderQuestionsJSON
                                                       , string        formBuilderAnswersJSONForOrder
                                                       , string        reqSvcAuthFromSelectionID
                                                       , string        reqSvcAuthMethodSelectionID
                                                       , string        prtGrd1PersonID
                                                       , string        prtGrd2PersonID
                                                       , string        orpPracID
                                                       , string        selectedFileList
                                                       , string        editDelReason
                                                       , string        validateRec
                                                       , string        saveType
                                                       , string        recID )
    {           
                                     
       return _saveCore (   connSpedmon
                          , connUser
                          , log
                          , uInfo
                          , @"SERVICE_AUTHORIZATION_REQUEST_DELETE_AND_SAVE_NEW"
                          , @"This request has been deleted and resent already today"
                          , clientID
                          , districtContactUserID
                          , patID
                          , svcAuthorizationRequestTypeID
                          , referencedEntityID
                          , svcDescription
                          , formBuilderQuestionsJSON
                          , formBuilderAnswersJSONForOrder
                          , reqSvcAuthFromSelectionID
                          , reqSvcAuthMethodSelectionID
                          , prtGrd1PersonID
                          , prtGrd2PersonID
                          , orpPracID
                          , selectedFileList
                          , editDelReason
                          , validateRec
                          , saveType
                          , recID );

    } 


    /***************************************************************************
     * delete */
    /**
     * 
     *
     ***************************************************************************/     
    public static ReturnSaveRecord delete (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                           string editDelReason, string validateRec, string recID)
    {

          /*----------------------------
           * Collect all of the parameters
           * that are specific to this
           * delete method.
           *----------------------------*/

          List<SqlParameter> parms = new List<SqlParameter>();

          /*----------------------------
           * Call base method 
           *----------------------------*/

          return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "SERVICE_AUTHORIZATION_REQUEST_DELETE", ref parms);

    } 

    /***************************************************************************
     * view */
    /**
     * Note: Only shows records that userID has access to
     * Access control is provided at the database level
     **************************************************************************/  
    
    public static ReturnDB view (   SqlConnection connSpedmon
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , int           recViewType
                                  , bool          pagedOrTop
                                  , string        idx
                                  , string        canEdit
                                  , string        active
                                  , string        clientID
                                  , string        startDate
                                  , string        endDate
                                  , string        currentResponseCode
				                  , string        closed
                                  , string        requestID
                                  , defineCols    dc )
    {
    
      string viewUDF = "dbo.SERVICE_AUTHORIZATION_REQUESTS_VIEW (@userID, @userGroup, @userRank, @clientID, @startDate, @endDate, @currentResponseCode, @closed, @requestID, @active, @recID)";
      
      /*###########################################################################
        # Validate parameters specific to this entity view 
        ###########################################################################*/         	          
            
      Object  vRequestID           = Validate.optInteger   (requestID, @"Invalid request id");
      Object  vClientID            = Validate.optClientID  (uInfo, clientID);     
      Object  vClosed              = null;
      Object  vCurrentResponseCode = null;
      
      Object[] vDates              = new Object[2];
      vDates[0] = null;
      vDates[1] = null;

      /* If the request id is not provided then we need to check all other filter values otherwise we bypass all other filters */
      
      if (vRequestID == null) 
      {      
        vClosed              = Validate.optFlag      (closed,                           @"Invalid value for closed");
        vCurrentResponseCode = Validate.optInteger   (currentResponseCode,              @"Invalid response code");
        vDates               = Validate.optStartAndEndDate(startDate,endDate,@"Invalid dates");      
	  }

      /*###########################################################################
        # Create database parameters
        ###########################################################################*/         	          

      var parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID",                SqlDbType.BigInt,  vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate",               SqlDbType.Date,    vDates[0],            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",                 SqlDbType.Date,    vDates[1],            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@currentResponseCode",     SqlDbType.BigInt,  vCurrentResponseCode, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@closed",                  SqlDbType.Bit,     vClosed,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@requestID",               SqlDbType.BigInt,  vRequestID,           ParameterDirection.Input));

      /*###########################################################################
        # Call base method which handles the rest and return the results
        ###########################################################################*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
            
    }
        
    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl (  SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , bool          paged
                                           , string        pageNumber
                                           , string        canEdit
                                           , string        active                                           
                                           , string        clientID
                                           , string        startDate
                                           , string        endDate
                                           , string        currentResponseCode
				                				           , string        closed
                                           , string        requestID
                                          )
   {
     ReturnDataTable so        = new ReturnDataTable();
     string          tableName = ServiceAuthorizationRequests.SEL_LABEL;
     
     /*###########################################################################
       # Define our display columns and set the page order.  Page order needs to
       # be in the same sort order as the udf called in the view.
       ###########################################################################*/  

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
     {       
       ss.addDisplayColumn("id");       
       ss.addDisplayColumn("clientName      as [District]",  true);       
       ss.addDisplayColumn("patName         as [Patient]",   true);
       ss.addDisplayColumn("svcName         as [Service]");
       ss.addDisplayColumn("requestDateStr  as [Requested On]");
       ss.addDisplayColumn("id              as [Request ID]");
       pageroworder = ss.pageRowOrder();
     };

     /*###########################################################################
       # Call the base method which handles the rest and returns a ReturnDataTable
       ###########################################################################*/  

     so = Entities.viewTbl(  connSpedmon
                           , log
                           , uInfo
                           , paged
                           , pageNumber
                           , delegate { return                            
                             ServiceAuthorizationRequests.view (   connSpedmon
                                                                 , log
                                                                 , uInfo                                                                
                                                                 , Entities.REC_VIEW_TBL
                                                                 , paged
                                                                 , pageNumber
                                                                 , canEdit
                                                                 , active
                                                                 , clientID
                                                                 , startDate
                                                                 , endDate
                                                                 , currentResponseCode
                                                                 , closed
                                                                 , requestID
                                                                 , dc); 
                             });
   
     /*###########################################################################
       # Add a title and footer to ReturnDataTable then return
       ###########################################################################*/  
               
     so.tableName   = tableName;
     so.tableFooter = Messages.CONFIDENTIAL;
         
     return so;
     
    }            

    /***************************************************************************
     * load */
    /**
     * Loads single record
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing access control
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @return                 ReturnEntity
     ***************************************************************************/
    public static ServiceAuthorizationRequest load (   SqlConnection connSpedmon
                                                     , DetailsLog    log
                                                     , UserInfo      uInfo                                                     
                                                     , string        recID )
    {      
      /*###########################################################################
        # Call the base method which handles everything and return
        ###########################################################################*/  

      return (ServiceAuthorizationRequest) Entities.load(connSpedmon, log, uInfo, recID, typeof(ServiceAuthorizationRequest),
      delegate { return ServiceAuthorizationRequests.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "","","","", "", "", "", "", null); });
    } 
             
  }
}
