using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /**************************************************************************
     * PatientInfoRequestsPublicInsuranceFormResponse */
    /**
     **************************************************************************/
    
	public class PatientInfoRequestsPublicInsuranceFormResponse  : Entity

    {
       public const string DEFAULT_PAGING_ORDER = "patientFirstName asc, patID desc";	
        
	   public long          clientID;
       public string        clientName;
       
       public long          patID;
       public string        patName;
  
       public string        patientFirstName;
       public string        patientLastName;
	   public DateTime      patientDOB;
	   public string        patientDOBStr;

       public string        studentID;
       public long 		    insuranceCarrierID;
	   public string        insuranceCarrierName;
	   public string	    memberID;
	   
	   public bool 	 	    noInsuranceOptionSelected;
       public string        noInsuranceOptionSelectedStr;

	   public bool		    otherInsuranceOptionSelected;
	   public string        otherInsuranceOptionSelectedStr;

       public string	    insuranceCarrierOtherName;
	   
	   public bool		    responderIsParentGuardian;

	   public string 	    responderFirstName;
	   public string	    responderLastName;
	   public string 	    responderEmail;
	   public string	    responderPhone;

       public bool          ferpaConsent;                
       public string        ferpaConsentStr;
    
       public bool          hasResponderSignatureImgData;
       public string        responderSignatureImgData;
          
       public string        responderUserIP;
       public string        responderUserAgent;

       public DateTime      responseReceivedOn;
	   public string        responseReceivedOnStr;   
     
    }

    /***************************************************************************
     * PatientInfoRequestsPublicInsuranceFormResponses */
    /**
     *
     **************************************************************************/
	 
    public class PatientInfoRequestsPublicInsuranceFormResponses : Entities
    {
        public const string SEL_LABEL_MANAGE         = @"Student Insurance Information Requests";        
        public const string URL_WEB_SVC              = @"patient_info_request_public_insurance_forms_responses.asmx";
        public const string URL_SVC_DELETE_INLINE    = URL_WEB_SVC + @"/deleteinline";
        public const string URL_SVC_SAVE_INLINE      = URL_WEB_SVC + @"/saveinline";
        public const string URL_SVC_ACCEPT_RESPONSE  = URL_WEB_SVC + @"/acceptresponse";
        public const string URL_SVC_REJECT_RESPONSE  = URL_WEB_SVC + @"/rejectresponse";
        public const string URL_SVC_GET_PTKN         = URL_WEB_SVC + @"/getformbyclientid";
        public const string URL_SVC_SAVE_RESPONSE    = URL_WEB_SVC + @"/saveresponsefromportal";
        public const string URL_REST_VIEW            = @"api/v1/patientinforequestspublicinsuranceformresponses";
        public const string URL_WEB_REPORT           = @"practice_office_visits.ashx";
        public const string MENU_ID_MANAGE           = @"userallpatientinforequestpublicinsuranceformresponsesmanagelnk";
        public const string URL_MANAGE               = @"user_all_patient_info_requests_public_insurance_form_responses_manage.aspx";

        /***************************************************************************
         * URL_SVC_GET_PTKN */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_GET_PTKN_BASE()
        {
            return MBA.HttpApplication.createLink(PatientInfoRequestsPublicInsuranceFormResponses.URL_SVC_GET_PTKN, true);
        }

        /***************************************************************************
         * URL_SVC_DELETE_INLINE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_DELETE_INLINE_BASE()
         {
           return MBA.HttpApplication.createLink(PatientInfoRequestsPublicInsuranceFormResponses.URL_SVC_DELETE_INLINE, true);
         }


		 /***************************************************************************
          * URL_SVC_SAVE_INLINE_BASE */
         /**
          * 
          **************************************************************************/

		 public static string URL_SVC_SAVE_INLINE_BASE()
         {
           return MBA.HttpApplication.createLink(PatientInfoRequestsPublicInsuranceFormResponses.URL_SVC_SAVE_INLINE, true);
         }

        /***************************************************************************
          * URL_SVC_ACCEPT_RESPONSE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_SVC_ACCEPT_RESPONSE_BASE()
        {
            return MBA.HttpApplication.createLink(PatientInfoRequestsPublicInsuranceFormResponses.URL_SVC_ACCEPT_RESPONSE, true);
        }

        /***************************************************************************
          * URL_SVC_REJECT_RESPONSE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_SVC_REJECT_RESPONSE_BASE()
        {
            return MBA.HttpApplication.createLink(PatientInfoRequestsPublicInsuranceFormResponses.URL_SVC_REJECT_RESPONSE, true);
        }

        /***************************************************************************
         * URL_REST_VIEW_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(PatientInfoRequestsPublicInsuranceFormResponses.URL_REST_VIEW, true);
        }


        /***************************************************************************
        * URL_SAVE_RESPONSE_CONSENT_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_SAVE_RESPONSE_CONSENT_BASE()
        {
            return MBA.HttpApplication.createLink(PatientInfoRequestsPublicInsuranceFormResponses.URL_SVC_SAVE_RESPONSE, true);
        }

        /***************************************************************************
         * saveresponsefromportal */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord saveresponsefromportal( SqlConnection connSpedmon
                                                                , DetailsLog log
                                                                , UserInfo uInfo
                                                                , string clientID
                                                                , string patID
                                                                , string patPerID
                                                                , string ferpaConsent
                                                                , string responderSignatureImgData

                                                                , string primaryInsuranceCarrierID
                                                                , string primaryMemberID
                                                                , string primaryPolicyGroupID
                                                                , string primaryPolicyHolderName
                                                                , string primaryInsuranceCarrierOtherName
                                                                , string primaryBeneficiaryFirstName
                                                                , string primaryBeneficiaryLastName

                                                                , string secondaryInsuranceCarrierID
                                                                , string secondaryMemberID
                                                                , string secondaryPolicyGroupID
                                                                , string secondaryPolicyHolderName
                                                                , string secondaryInsuranceCarrierOtherName
                                                                , string secondaryBeneficiaryFirstName
                                                                , string secondaryBeneficiaryLastName

                                                                , string editDelReason
                                                                , string validateRec
                                                                , string saveType
                                                                , string recID )
        {
            string saveSproc = @"PATIENT_INFO_PARENT_GUARDIAN_PORTAL_RESPONSES_SAVE";
            string dupRecMsg = @"Entry already exists";

            var vClientID                       = Validate.reqClientID(uInfo, clientID);
            var vPatID                          = Validate.reqPatID(uInfo, patID);
            var vPatPerID                       = Validate.optInteger(patPerID,                         @"Please select a valid patient person");
            var vFerpaConsent                   = Validate.reqFlag(ferpaConsent,                        @"Invalid consent value", false);            
            var vResponderSignatureImgData      = Validate.optBase64String(responderSignatureImgData,   @"Please provide a valid signature image", true);

            // Primary
            var vPrimaryInsuranceCarrierID          = Validate.optInteger(primaryInsuranceCarrierID,            @"Please select a valid primary insurance carrier");
            var vPrimaryMemberID                    = Validate.optString(primaryMemberID,                       @"Please enter a valid primary member id");
            var vPrimaryPolicyGroupID               = Validate.optString(primaryPolicyGroupID,                  @"Please enter a valid primary policy group id");
            var vPrimaryPolicyHolderName            = Validate.optString(primaryPolicyHolderName,               @"Please enter a valid primary policy holder name");
            var vPrimaryInsuranceCarrierOtherName   = Validate.optString(primaryInsuranceCarrierOtherName,      @"Please enter a valid primary other carrier name");
            var vPrimaryBeneficiaryFirstName        = Validate.optString(primaryBeneficiaryFirstName,           @"Please enter a valid primary beneficiary first name");
            var vPrimaryBeneficiaryLastName         = Validate.optString(primaryBeneficiaryLastName,            @"Please enter a valid primary beneficiary last name");

            // Secondary
            var vSecondaryInsuranceCarrierID        = Validate.optInteger(secondaryInsuranceCarrierID,          @"Please select a valid secondary insurance carrier");
            var vSecondaryMemberID                  = Validate.optString(secondaryMemberID,                     @"Please enter a valid secondary member id");
            var vSecondaryPolicyGroupID             = Validate.optString(secondaryPolicyGroupID,                @"Please enter a valid secondary policy group id");
            var vSecondaryPolicyHolderName          = Validate.optString(secondaryPolicyHolderName,             @"Please enter a valid secondary policy holder name");
            var vSecondaryInsuranceCarrierOtherName = Validate.optString(secondaryInsuranceCarrierOtherName,    @"Please enter a valid secondary other carrier name");
            var vSecondaryBeneficiaryFirstName      = Validate.optString(secondaryBeneficiaryFirstName,         @"Please enter a valid secondary beneficiary first name");
            var vSecondaryBeneficiaryLastName       = Validate.optString(secondaryBeneficiaryLastName,          @"Please enter a valid secondary beneficiary last name");

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",         SqlDbType.BigInt, vClientID,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",            SqlDbType.BigInt, vPatID,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patPerID",         SqlDbType.BigInt, vPatPerID,    ParameterDirection.Input));

            parms.Add(Database.SqlParm("@ferpaConsent",     SqlDbType.Bit,              vFerpaConsent,              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@responderSignatureImgData", SqlDbType.VarChar, vResponderSignatureImgData, ParameterDirection.Input, -1));

            // Primary
            parms.Add(Database.SqlParm("@primaryInsuranceCarrierID",    SqlDbType.BigInt,           vPrimaryInsuranceCarrierID,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@primaryMemberID",              SqlDbType.VarChar,          vPrimaryMemberID,                   ParameterDirection.Input, 80));
            parms.Add(Database.SqlParm("@primaryPolicyGroupID",         SqlDbType.VarChar,          vPrimaryPolicyGroupID,              ParameterDirection.Input, 80));
            parms.Add(Database.SqlParm("@primaryPolicyHolderName",      SqlDbType.NVarChar,         vPrimaryPolicyHolderName,           ParameterDirection.Input, 255));
            parms.Add(Database.SqlParm("@primaryInsuranceCarrierOtherName", SqlDbType.VarChar,      vPrimaryInsuranceCarrierOtherName,  ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@primaryBeneficiaryFirstName",      SqlDbType.NVarChar,     vPrimaryBeneficiaryFirstName,       ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@primaryBeneficiaryLastName",       SqlDbType.NVarChar,     vPrimaryBeneficiaryLastName,        ParameterDirection.Input, 50));

            // Secondary
            parms.Add(Database.SqlParm("@secondaryInsuranceCarrierID",          SqlDbType.BigInt,   vSecondaryInsuranceCarrierID,           ParameterDirection.Input));
            parms.Add(Database.SqlParm("@secondaryMemberID",                    SqlDbType.VarChar,  vSecondaryMemberID,                     ParameterDirection.Input, 80));
            parms.Add(Database.SqlParm("@secondaryPolicyGroupID",               SqlDbType.VarChar,  vSecondaryPolicyGroupID,                ParameterDirection.Input, 80));
            parms.Add(Database.SqlParm("@secondaryPolicyHolderName",            SqlDbType.NVarChar, vSecondaryPolicyHolderName,             ParameterDirection.Input, 255));
            parms.Add(Database.SqlParm("@secondaryInsuranceCarrierOtherName",   SqlDbType.VarChar,  vSecondaryInsuranceCarrierOtherName,    ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@secondaryBeneficiaryFirstName",        SqlDbType.NVarChar, vSecondaryBeneficiaryFirstName,         ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@secondaryBeneficiaryLastName",         SqlDbType.NVarChar, vSecondaryBeneficiaryLastName,          ParameterDirection.Input, 50));

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }

        /***************************************************************************
         * saveResponse */
        /**
         **************************************************************************/

        public static ReturnActionRequest saveResponse (  SqlConnection    connSpedmon
                                                         , DetailsLog       log 
                                                         , RequestResponse  rr
                                                         , string           ptkn
                                                         , string studentFirstName
                                                         , string studentLastName
                                                         , string studentDOB
                                                         , string studentID                                                         
                                                         , string insuranceCarrierID
                                                         , string insuranceMemberID
                                                         , string insuranceCarrierOtherName
                                                         , string responderIsParentGuardian
                                                         , string responderFirstName
                                                         , string responderLastName
                                                         , string responderEmail
                                                         , string responderPhone
                                                         , string consent      
                                                         /* Add other fields needed */
                                                         , string responderSignatureImgData ) 

        {
            ReturnActionRequest so = new ReturnActionRequest();

            string actionRequestSproc = "PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_SAVE_FROM_PUBLIC_FORM";
            
            var vPtkn = Validate.reqString (ptkn, @"Invalid token");                                    

            var vStudentFirstName  = Validate.optString(studentFirstName, "Invalid name");
            var vStudentLastName   = Validate.optString(studentLastName, "Invalid name");
            var vStudentDOB        = Validate.optDate(studentDOB,"Invalid DOB");
            var vStudentID         = Validate.optString(studentID, "Invalid ID");
            var vInsuranceMemberID             = Validate.optString (insuranceMemberID,"Invalid ID");
            var vInsuranceCarrierID            = Validate.reqInteger (insuranceCarrierID, "Invalid insurance company selection");
            var vInsuranceCarrierOtherName     = Validate.optString  (insuranceCarrierOtherName, "Invalid carrier name");
            var vConsent                       = Validate.reqFlag    (consent,  @"Invalid consent value", true);
            var vResponderIsParentGuardian     = Validate.reqFlag    (responderIsParentGuardian, @"Invalid responderIsParentGuardian value", true);
            var vResponderFirstName            = Validate.optString  (responderFirstName, "Invalid name");
            var vResponderLastName             = Validate.optString  (responderLastName, "Invalid name");
            var vResponderEmail                = Validate.optEmail   (responderEmail, "Invalid Email");
            var vResponderPhone                = Validate.optPhoneNumber(responderPhone, "Invalid Phone Number");

            var vResponderSignatureImgData             = Validate.optBase64String(responderSignatureImgData,@"Invalid signature data",true);
            bool vNoInsuranceOptionSelected            = false;
            bool vOtherInsuranceOptionSelected         = false;

            if ((vInsuranceCarrierID) < 0)
            {
                if (vInsuranceCarrierID == InsuranceCarriers.OPTION_VALUE_OTHER)
                {                  
                  vOtherInsuranceOptionSelected = true;
                }
                else if (vInsuranceCarrierID == InsuranceCarriers.OPTION_VALUE_NO_INSURANCE)
                {
                  vNoInsuranceOptionSelected = true;
                }
                else
                {
                    new Warning(@"Invalid insurance company selection");
                }
            }
            try
            { 

              /* Since this is a public facing method we want to take the extra step of additional sanitization 
               * of certain fields.   The req and opt String methods already remove <script> tags
               * 
               * See : https://learn.microsoft.com/en-us/archive/msdn-magazine/2012/january/asp-net-security-securing-your-asp-net-applications
               * Note: HtmlEncoding will not prevent the scripting or markup SOURCE from being shown BUT it will prevent
               * it from being executed or rendered. 
               */

              vStudentFirstName          = System.Net.WebUtility.HtmlEncode(vStudentFirstName);
              vStudentLastName           = System.Net.WebUtility.HtmlEncode(vStudentLastName);                                        
              vStudentID                 = System.Net.WebUtility.HtmlEncode(vStudentID);
              vInsuranceMemberID         = System.Net.WebUtility.HtmlEncode(vInsuranceMemberID);
              vInsuranceCarrierOtherName = System.Net.WebUtility.HtmlEncode(vInsuranceCarrierOtherName);
              vResponderFirstName        = System.Net.WebUtility.HtmlEncode(vResponderFirstName);
              vResponderLastName         = System.Net.WebUtility.HtmlEncode(vResponderLastName);

              var parms = new List<SqlParameter>();

              parms.Add(Database.SqlParm("@userIP",                                SqlDbType.VarChar,  rr.userIP,           ParameterDirection.Input, 500));
              parms.Add(Database.SqlParm("@userAgent",                             SqlDbType.VarChar,  rr.userAgent,        ParameterDirection.Input, 8000));
              parms.Add(Database.SqlParm("@ptkn",                                  SqlDbType.VarChar,  vPtkn,               ParameterDirection.Input, 500));
              parms.Add(Database.SqlParm("@patientFirstName",                      SqlDbType.NVarChar, vStudentFirstName,   ParameterDirection.Input, 50));
              parms.Add(Database.SqlParm("@patientLastName",                       SqlDbType.NVarChar, vStudentLastName,    ParameterDirection.Input, 50));   
              parms.Add(Database.SqlParm("@patientDOB",                            SqlDbType.Date,     vStudentDOB,         ParameterDirection.Input, 50));  
              parms.Add(Database.SqlParm("@studentID",                             SqlDbType.NVarChar, vStudentID,          ParameterDirection.Input, 50)); 
              parms.Add(Database.SqlParm("@memberID",                              SqlDbType.VarChar,  vInsuranceMemberID,          ParameterDirection.Input, 80));      

              parms.Add(Database.SqlParm("@insuranceCarrierID",                    SqlDbType.BigInt,   vInsuranceCarrierID,           ParameterDirection.Input));
              parms.Add(Database.SqlParm("@insuranceCarrierOtherName",             SqlDbType.VarChar,  vInsuranceCarrierOtherName,    ParameterDirection.Input, 256));

              parms.Add(Database.SqlParm("@consentToReleaseOfChildHealthRecsAndOrBenefitInfo",   SqlDbType.Bit,      vConsent,                      ParameterDirection.Input));                        
              parms.Add(Database.SqlParm("@responderSignatureImgData",                           SqlDbType.VarChar,  vResponderSignatureImgData,    ParameterDirection.Input, -1));
              parms.Add(Database.SqlParm("@noInsuranceOptionSelected",                           SqlDbType.Bit,      vNoInsuranceOptionSelected,    ParameterDirection.Input));
              parms.Add(Database.SqlParm("@otherInsuranceOptionSelected",                        SqlDbType.Bit,      vOtherInsuranceOptionSelected, ParameterDirection.Input));
              
              parms.Add(Database.SqlParm("@responderIsParentGuardian",               SqlDbType.Bit,      vResponderIsParentGuardian,                ParameterDirection.Input));
              parms.Add(Database.SqlParm("@responderFirstName",                      SqlDbType.NVarChar, vResponderFirstName,   ParameterDirection.Input, 50));
              parms.Add(Database.SqlParm("@responderLastName",                       SqlDbType.NVarChar, vResponderLastName,    ParameterDirection.Input, 50));
              parms.Add(Database.SqlParm("@responderEmail",                          SqlDbType.VarChar,  vResponderEmail,       ParameterDirection.Input, 255));
              parms.Add(Database.SqlParm("@responderPhone",                          SqlDbType.VarChar,  vResponderPhone,       ParameterDirection.Input, 255));

              ReturnDB rd = Database.execSproc(connSpedmon, log, actionRequestSproc, parms);     
              so = (ReturnActionRequest) Database.convertParameters(rd,typeof(ReturnActionRequest));
              so.confirmValue = vInsuranceCarrierID.ToString(); /* Pass back selected carrier for later use */
            }

            /* We dont want non users seeing internal details so return a very generic message */

            catch
            {
                so.message = @"A problem has occurred please try your request again";
                so.status = Return.RET_WARNING;
            }

            return so;
        }


        /***************************************************************************
         * view */
        /**
         * 
         **************************************************************************/
		 
        protected static ReturnDB view (  SqlConnection connSpedmon
                                        , DetailsLog    log
                                        , UserInfo      uInfo                                        
                                        , string        clientID                                   
                                        , string        reviewed                                       
                                        , int           recViewType
                                        , bool          pagedOrTop
                                        , string        idx
                                        , string        canEdit
                                        , string        active                                        
                                        , defineCols    dc)
        {
            
            long  vClientID  = Validate.reqClientID   (uInfo, clientID);           
            var   vReviewed  = Validate.optFlag       (reviewed,@"Invalid value for reviewed", true);
             
            string viewUDF = "PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_VIEW (@userID, @userGroup, @userRank, @clientID, @reviewed, @active)";

            var parms = new List<SqlParameter>();
            
            parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,  vClientID,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@reviewed",  SqlDbType.Bit,     vReviewed,  ParameterDirection.Input)); 
                                        
            var so = Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

            return so;

        }


        /***************************************************************************
         * viewObjects */
        /**
         ***************************************************************************/
        
        public static ReturnObjects viewObjects (   SqlConnection connSpedmon
                                                   , DetailsLog   log
                                                   , UserInfo     uInfo
                                                   , bool         pageObjectList
                                                   , string       pageOrder
                                                   , string       idx
                                                   , string       clientID                                                                                                                                                                                                             
                                                   , string       reviewed )
        {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientInfoRequestsPublicInsuranceFormResponse.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            var rd = Entities.viewObjects ( connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(PatientInfoRequestsPublicInsuranceFormResponse)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return PatientInfoRequestsPublicInsuranceFormResponses.view (  connSpedmon
                                                                              , log
                                                                              , uInfo
                                                                              , clientID                                   
                                                                              , reviewed
                                                                              , Entities.REC_VIEW_OBJECTS
                                                                              , pageObjectList
                                                                              , idx
                                                                              , null
                                                                              , "Y" /* Active */                                                                              
                                                                              , dc);
                                          });

            return rd;
        }
        
        
		/***************************************************************************
         * delete */
        /**
         * 
         **************************************************************************/

		public static ReturnSaveRecord delete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                          string editDelReason, string validateRec, string recID)
        {

            /*----------------------------
             * Check for required and 
             * optional parameters
             * and validate data integrity
             * of all supplied parameters
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, "");

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * delete method.
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*----------------------------
             * Call base method 
             *----------------------------*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "PATIENT_INSURANCE_INFO_PUBLIC_REQUESTS_DELETE", ref parms);
        }

        /***************************************************************************
         * save */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord save (   SqlConnection connSpedmon
                                              , DetailsLog    log
                                              , UserInfo      uInfo
                                              , string        clientID
                                              , string        patID
                                              , string        insuranceCarrierID
                                              , string        memberID
                                              , string        ferpaConsent
                                              , string        editDelReason
                                              , string        validateRec
                                              , string        saveType
                                              , string        recID )
        {

            string saveSproc = @"PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_SAVE";

            string dupRecMsg = @"Entry already exists";

            var vClientID     = Validate.reqClientID (uInfo, clientID);
            var vPatID        = Validate.optPatID    (uInfo, patID);
            var vInsuranceID  = Validate.optInteger  (insuranceCarrierID, @"Please select a valid insurance carrier");
            var vMemberID     = Validate.optString   (memberID,           @"Please select a valid member id");
            var vFerpaConsent = Validate.reqFlag     (ferpaConsent,       @"FERPA consent must be yes or no",false);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",           SqlDbType.BigInt,  vClientID,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",              SqlDbType.BigInt,  vPatID,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@insuranceCarrierID", SqlDbType.BigInt,  vInsuranceID,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@memberID",           SqlDbType.VarChar, vMemberID,     ParameterDirection.Input, 80));
            parms.Add(Database.SqlParm("@ferpaConsent",       SqlDbType.Bit,     vFerpaConsent, ParameterDirection.Input));

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);

        }

        /***************************************************************************
         * acceptresponse */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord acceptResponse (
              SqlConnection connSpedmon
            , DetailsLog    log
            , UserInfo      uInfo
            , string        clientID
            , string        editDelReason
            , string        validateRec                                             
            , string        recID )
        {

            string opSproc = @"PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_ACCEPT";           
            var vClientID = Validate.reqClientID(uInfo, clientID);
            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            return Entities.recordOp (connSpedmon, log, uInfo, editDelReason, validateRec, recID, opSproc, ref parms);
        }

        /***************************************************************************
         * rejectResponse */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord rejectResponse (
              SqlConnection connSpedmon
            , DetailsLog    log
            , UserInfo      uInfo
            , string        clientID
            , string        editDelReason
            , string        validateRec            
            , string        recID )
        {
            string opSproc = @"PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_REJECT";
            var vClientID = Validate.reqClientID(uInfo, clientID);
            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            return Entities.recordOp(connSpedmon,log,uInfo,editDelReason,validateRec,recID, opSproc,ref parms);
        }
    }
}
