using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

/*
 *THIS ROUTINE CONTAINS EXPANSION HOOKS FOR E-AUTHORIZE
 * Add additional code if needed to support new request types
 */

namespace Spedmon
{
  
  /***************************************************************************
   * ServiceAuthorizationRequestResponse */
  /**
   * 
   **************************************************************************/
  public class ServiceAuthorizationRequestResponse: Entity
  {
    public long     requestID;
    public long     userID;    
	  public DateTime createdOn;    
  }
          
  /***************************************************************************
   * ServiceAuthorizationRequestResponses */
  /**
   * 
   **************************************************************************/
  public class ServiceAuthorizationRequestResponses:Entities
  {          
    
   /***************************************************************************
     * SEL_LABEL */
    /**
     * Selection labels for menus and screens
     ***************************************************************************/       

    public const string SEL_LABEL               = @"Service Authorization Request Responses";
    public const string SEL_LABEL_NEW           = @"Add New";
    public const string SEL_LABEL_EDIT          = @"Edit";
    public const string SEL_LABEL_EDIT_DELETE   = @"Edit or Delete Existing";
    public const string SEL_LABEL_VIEW          = @"View";
    public const string SEL_LABEL_RESPOND       = @"Service Authorization Requests";
    public const string SEL_LABEL_REQUESTS_VIEW = SEL_LABEL + " - " + SEL_LABEL_VIEW;

    /***************************************************************************
     * MENU_ID_* */
    /**
     * Menu id
     ***************************************************************************/       

    public const string MENU_ID_URL_RESPOND             = @"svcauthreqrsplink";
    public const string IFRAME_RESPONSE_SAVE_ID         = @"sarr";
    public const string MENU_ID_URL_VIEW                = @"svcauthreqviewlink";

    /***************************************************************************
     * URL_* */
    /**
     * Urls 
     ***************************************************************************/       
    
    public const string URL_SVC_BASE                      = @"service_authorization_request_responses.asmx";
    public const string URL_SVC_SAVE                      = URL_SVC_BASE + @"/save";
    public const string URL_MANAGE_RESPONSES              = @"user_all_service_authorization_request_responses_manage.aspx";
    public const string URL_SAVE_RESPONSE                 = @"user_all_service_authorization_request_response_save.aspx";    
    public const string URL_SBSC_ALL_VIEW                 = @"sbs_all_service_authorization_requests_view.aspx";

    /***************************************************************************
     * setDisplayRules */
    /**
     * 
     *
     ***************************************************************************/

    public static void setDisplayRules (ref ServiceAuthorizationRequest sar)
    {
    
      if (sar == null) return;

      sar.dspRuleRspShowSupportingFilesSection       = false;
      sar.dspRuleRspShowDownloadReturnForm = false;

     /*###########################################################################
       # Common for all types of requests
       ###########################################################################*/
      
      /*------------------------------------*/
      /*   Show Download Return Form        */ 
      /*------------------------------------*/         

      if (sar.currentResponseCode == (int) RequestServiceAuthorizationResponse.PENDING)
        sar.dspRuleRspShowDownloadReturnForm = false;
      else if (sar.currentResponseCode == (int) RequestServiceAuthorizationResponse.DECLINED)
        sar.dspRuleRspShowDownloadReturnForm = true;
      else if (sar.currentResponseCode == (int) RequestServiceAuthorizationResponse.APPROVED)
        sar.dspRuleRspShowDownloadReturnForm = true;       
      else
        sar.dspRuleRspShowDownloadReturnForm = false;

      /*------------------------------------*/
      /*   Show Files                       */ 
      /*------------------------------------*/         

     sar.dspRuleRspShowSupportingFilesSection = sar.viewingUserCanAccessSupportingFiles;     
     
     /*###########################################################################
       # Order or Prescription and Patient Profile Specific Overrides
       ###########################################################################*/

     if (
           (sar.svcAuthorizationRequestTypeID == (int) ServiceAuthorizationRequestTypes.ORDER_OR_PRESCRIPTION)
        || (sar.svcAuthorizationRequestTypeID == (int) ServiceAuthorizationRequestTypes.PATIENT_PROFILE)
     )
     {
        /*------------------------------------*/
        /*          Show Files                */ 
        /*------------------------------------*/         
        
        sar.dspRuleRspShowSupportingFilesSection = false;
        if (
             (sar.viewingUserCanAccessSupportingFiles == true) 
          && (sar.currChainReqSvcAuthFromSelectionID != (int)RequestServiceAuthorizationFrom.PARENTS)
        )
        {
          sar.dspRuleRspShowSupportingFilesSection = true;
        }
      }
      /* Expansion hook:  Add request types here if needed */

      } /* function */

        /***************************************************************************
         * save */
        /**
         * Save new or update existing record
         *
         ***************************************************************************/

        public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                        , SqlConnection connUser
                                        , DetailsLog    log
                                        , UserInfo      uInfo
                                        , string        requestID
                                        , string        responseCode
                                        , string        effectiveDate
                                        , string        editDelReason
                                        , string        validateRec
                                        , string        saveType
                                        , string        recID )
      {           
                               
      string saveSproc  = @"SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE";
      string dupRecMsg  = @"Active response already exists";
      
    /*###########################################################################
      # Validate parameters specific to this entity save and create their 
      # database parameters
      ###########################################################################*/  
                 
    Object  vClientID       = Validate.optClientID (uInfo,@"");  /* Force client id if neccessary */
    long    vRequestID      = Validate.reqInteger  (requestID,        @"Invalid authorization request");
    long    vResponseCode   = Validate.reqInteger  (responseCode,     @"Invalid response code");      
    Object  vEffectiveDate  = Validate.optDate     (effectiveDate,    Messages.INVALID_EFFECTIVE_DATE);
      
    List<SqlParameter> parms = new List<SqlParameter>();

    parms.Add(Database.SqlParm("@clientID",                  SqlDbType.BigInt,  vClientID,              ParameterDirection.Input));
    parms.Add(Database.SqlParm("@requestID",                 SqlDbType.BigInt,  vRequestID,             ParameterDirection.Input));
    parms.Add(Database.SqlParm("@responseCode",              SqlDbType.BigInt,  vResponseCode,          ParameterDirection.Input));
    parms.Add(Database.SqlParm("@effectiveDate",             SqlDbType.Date,    vEffectiveDate,         ParameterDirection.Input));
    parms.Add(Database.SqlParm("@pwdMinLen",                 SqlDbType.Int,     Rules.PWD_MIN_LENGTH,   ParameterDirection.Input));       

    parms.Add(Database.SqlParm("@svcAuthRequestMsgUrlBase",          SqlDbType.VarChar, MBA.Credential.generateDirectLoginLink(@""), ParameterDirection.Input, 512));
    parms.Add(Database.SqlParm("@svcAuthRequestPaperUploadUrlBase",  SqlDbType.VarChar, ServiceAuthorizationCommon.URL_UPLOAD_COMPLETED_REQUEST_FORM, ParameterDirection.Input, 512));

    /*###########################################################################
      # Call base method which handles the rest and returns the results
      ###########################################################################*/  

    ReturnSaveRecordWithJSONData so = Entities.saveAndReturnJSONData (   connSpedmon
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

    /*###########################################################################
      # Load the updated requested data
      ###########################################################################*/
 
    var sar = ServiceAuthorizationRequests.load(connSpedmon, log, uInfo, requestID);

   /*###########################################################################
     # Perform any request type specific processing that HAS to take place in 
     # the middleware (like file upload generation, etc).
     ###########################################################################*/
 
    if (sar.svcAuthorizationRequestTypeID == (long)ServiceAuthorizationRequestTypes.PARENT_CONSENT_CARE_PLAN)
    {
      if (sar.currentResponseCode == (long) MBA.RequestServiceAuthorizationResponse.APPROVED)
      {
        /*###########################################################################
          # Generate new file for care plan (signed by parent) for permanent record
          # purposes.
          ###########################################################################*/
      
        string selectedFileList;
      
        var sfs = PlanWriterPlans.generateStoredFile (  connSpedmon
                                                      , connUser
                                                      , log
                                                      , uInfo
                                                      , sar.clientID.ToString()
                                                      , sar.patID.ToString()
                                                      , sar.referencedEntityID.ToString());
        selectedFileList = sfs.recordID.ToString();
                    
        /*###########################################################################
          # Update file includes for service auth request
          ###########################################################################*/

        ServiceAuthorizationRequestFilesToInclude.updateList (   connSpedmon
                                                               , log
                                                               , uInfo
                                                               , requestID
                                                               , selectedFileList );
            
      } /* Parent approved */
    } /* Plan writer */

    /*###########################################################################
      # Done
      ###########################################################################*/

    return ServiceAuthorizationCommon.ExtractAndProcessReturnData (ref so, false);
     
    } 
                                  
  }
}
