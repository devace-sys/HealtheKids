using System;
using System.Threading;
using System.Web;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Net.Mail;


namespace MBA
{
  /***************************************************************************
   * Messages */
  /**
   * System messages returned to the user.
   ***************************************************************************/  

  public class Messages
  {    
    public static readonly string ATTEST_STATEMENT          = @"I hereby attest by saving or proceeding, that the information in this record entry is true, accurate and complete to the best of my knowledge. I am appropriately qualified and trained to provide the services I am recording.";
    public static readonly string ATTEST_STATEMENT_REVIEW   = @"I have reviewed this/these records of service.  I hereby attest by approving that the information in this record entry is accurate and complete to the best of my knowledge.";
    public static readonly string ATTEST_STATEMENT_ENTRY    = @"I hereby attest by saving or proceeding, that the information in this record entry is true, accurate and complete to the best of my knowledge.";
    public static readonly string ATTEST_STATEMENT_FINALIZE = @"I hereby attest by finalizing my records that the information in this record entry is true, accurate and complete to the best of my knowledge.";

    public static readonly string ATTEST_STATEMENT_SVC_RECS_SAVE = @"SpEdCare will remember your note-keeping progress, so we recommend not clicking ""Finalize My Records"" until you are finished documenting services and notes for all services listed above."
                                                                 + @"<br>"  
                                                                 + ATTEST_STATEMENT_FINALIZE;

    public static readonly string ATTEST_STATEMENT_TMGT_RELEASE     = @"I hereby attest by saving or proceeding, that the information in this record entry is true, accurate and complete to the best of my knowledge. Released services will submitted for adjudication and it will be upon your LEA to maintain proof that an approved LEA Billing Option Program service was provided on the date of transportation.";
    //public static readonly string ATTEST_STATEMENT_SVC_AUTH_REQ_ORP = @"I hereby attest by submitting my response that I have proper authority to approve or decline this authorization request .";

    public static readonly string SPED_DATA_CACHED_INFO      = @"Data below is refreshed nightly. Please note that if you do not see any data we are currently receiving insufficient Special Ed data from your district. Please work with your assigned consultant to resolve this.";
    public static readonly string SPED_DATA_REAL_TIME_INFO   = @"Data below is updated on demand. Please note that if you do not see any data we are currently receiving insufficient Special Ed data from your district. Please work with your assigned consultant to resolve this.";

    public static readonly string CONFIDENTIAL             = @"Confidential";
    public static readonly string CONFIDENTIAL_EMAIL       = @"CONFIDENTIALITY: This communication and any documents, files, or previous e-mail messages attached to it constitute an electronic communication within the scope of the Electronic Communication Privacy Act, 18 USCA 2510. This communication may contain non-public, confidential, or legally privileged information intended for the sole use of the designated recipient(s). The unlawful interception, use or disclosure of such information is strictly prohibited under 18 USCA 2511 and any applicable laws. If you are not the intended recipient of this communication, you are hereby notified to destroy all copies of this e-mail message and to contact the sender.";
    public static readonly string DATA_VIEW_NO_FOOTER      = CONFIDENTIAL;
    public static readonly string DATA_VIEW_NO_TITLE       = @"Data View";
    public static readonly string DATA_VIEW_GENERATED_ON   = @" Generated on " + DateTime.Now.ToString();
    
    public static readonly string APP_TITLE                = @"Practi-Cal LEA Billing Option";
 /* public static readonly string APP_LOGO_MKUP            = @"<img alt=""logo"" class=""branding"" src=""web-ui-3/mba/css/app-icons/branding.svg""/>";*/    
    public static readonly string APP_LOGO_MKUP            = @"<picture class=""branding""><source srcset=""web-ui-3/mba/css/app-icons/branding-lg.svg"" media=""(min-width: 600px)""/><source srcset=""web-ui-3/mba/css/app-icons/branding-md.svg"" media=""(min-width: 429px)""/><source srcset=""web-ui-3/mba/css/app-icons/branding-sm.svg"" media=""(min-width: 410px)""/><source srcset=""web-ui-3/mba/css/app-icons/branding-xs.svg"" media=""(min-width: 385px)""/><source srcset=""web-ui-3/mba/css/app-icons/branding-iphones-se.svg"" media=""(min-width: 374px)""/><img alt=""logo"" class=""branding"" src=""web-ui-3/mba/css/app-icons/branding.svg""/></picture>";


    public static readonly string POWERED_BY               = @"Powered by SpEdCare";
    public static readonly string COPYRIGHT_DATE_ORG       = DateTime.Now.Year.ToString() + @" MBA, Inc, All rights reserved.";
    public static readonly string COPYRIGHT                = POWERED_BY + @", Copyright &copy; " + COPYRIGHT_DATE_ORG;
    public static readonly string COPYRIGHT_2              = POWERED_BY + @", Copyright (c) " + COPYRIGHT_DATE_ORG;
    public static readonly string CONTACT_US_LINK          = @"https://app.smartsheet.com/b/form?EQBCT=c51f256dd2994989ad239a7f94726803";
    public static readonly string ABOUT_US_LINK            = @"http://www.practi-cal.com/";    
    public static readonly string PASSWORD_LOCKED          = @"Your account has been locked.  A message has been sent to the email associated with this account with instructions on what to do next.";
    public static readonly string PASSWORD_LOCKED_NO_EMAIL = @"Your account has been locked.  Please contact your account representative.";    
    
    /*----------------------------
     * Email messages (patterns)
     *----------------------------*/

    public static readonly string DO_NOT_REPLY           = @"<p>** This is an automatically generated email please do not reply to it. **</p>";  
    public static readonly string DID_NOT_REQUEST        = @"<p>If you did not request, expect, or cause this action or if you have any questions please contact your account representative.</p>";

    public static readonly string PASSWORD_LOCKED_TITLE  = @"Your {0} account has been locked";
    public static readonly string PASSWORD_LOCKED_BODY   = DO_NOT_REPLY + @"<p>Your {0} account has been locked because the number of login attempts has been exceeded.  To unlock your account you must request a password reset.</p>" +
                                                           @"<p>Please click <a href=""{1}"">here</a> and follow the instructions on the screen to request a password reset.  For security purposes your account will remain locked until you request a new password.</p>" + DID_NOT_REQUEST;
    
    public static readonly string PASSWORD_RESET_TITLE   = @"Your {0} password has been reset";
    public static readonly string PASSWORD_RESET_BODY    = DO_NOT_REPLY + @"<p>Your {0} password has been reset to the temporary password shown below.</p>" + 
                                                           @"<p>{1}</p><p>To complete the password reset request process you must change your password.  We recommend you keep this email open so you can copy/paste the temporary password into the required field.</p>" +
                                                           @"<p>Please click <a href=""{2}"">here</a> and follow the instructions on the screen to complete your password reset request.</p>" + DID_NOT_REQUEST;
    
    public static readonly string NEW_ACCOUNT_TITLE      = @"Your new {0} account has been setup";
    public static readonly string NEW_ACCOUNT_BODY       = DO_NOT_REPLY + @"<p>Your new {0} account has been setup with the username and temporary password shown below.</p>" +
                                                           @"<p>{1}<br/>{2}</p><p>To complete the account setup process you must change your password.  We recommend you keep this email open so you can copy/paste the temporary password into the required field.</p>" +
                                                           @"<p>Please click <a href=""{3}"">here</a> and follow the instructions on the screen to complete your account setup.</p>" + DID_NOT_REQUEST;
    
    public static readonly string FATAL_DB               = "Unable to connect to the database";
    public static readonly string FATAL_RD               = "Request/response logging is not working";
    public static readonly string BAD_UID_PWD            = @"Unknown username or password.  Please try again.";
    public static readonly string MISSING_USER_IP        = @"User ip is missing";
    public static readonly string MISSING_USER_AGENT     = @"User agent is missing";
    public static readonly string ACCOUNT_LOCKED         = @"This account has been disabled.";
    public static readonly string SESSION_EXPIRED        = @"This session has expired.  Please relogin.";
    public static readonly string SUBSCRIPTION_REQUIRED  = @"This application requires a subscription";

   
    public static readonly string DB_TIME_OUT            = @"Your report, search, or record(s) operation timed out.  Please try your request again.";
    public static readonly string DB_DEADLOCK            = @"The server is very busy and was unable to complete your request.  Please try your request again";
    public static readonly string LOGOUT_FAIL            = @"Unable to log your out.  Please retry or close your browser and login again";
    public static readonly string BAD_SESSION            = @"Unable to establish or resume your session.  Please relogin.";
    public static readonly string BAD_EMAIL              = @"Please provide a properly formated email address.";
    public static readonly string BAD_VALIDATE_PARMS     = @"Invalid parameters were passed to this validation function";
    public static readonly string ACCESS_DENIED          = @"Access is denied";
    public static readonly string SECURE_CONNECTION      = @"An attempt was made to access the site over an insecure connection.  For your protection you are now logged out.";
    public static readonly string UNSUPPORTED_BROWSER    = @"Please visit the site using a supported browser.";
    public static readonly string UNKNOWN_CMD            = @"Unknown command";
    public static readonly string BAD_CMD_LOGOUT         = @"Bad logout.  Please provide all required parameters.";
    public static readonly string BAD_CMD_LOGIN          = @"Bad login.  Please provide all required parameters.";
    public static readonly string BAD_REQ_FROM           = @"Unknown request from";

    public static readonly string NO_DEFAULT_VALUE       = @"The control has an attribute that specifies the use of a default value, but a default value has not been provided";
    public static readonly string INVALID_DEFAULT_VALUE  = @"Invalid default value";
    public static readonly string INVALID_BOOL           = @"Value cannot be converted to a boolean";
    public static readonly string INVALID_NUMBER         = @"Value cannot be converted into a number";
    public static readonly string INVALID_TEXT           = @"Value is blank or empty";
    public static readonly string INVALID_SEARCH_TERM    = @"Invalid search term";
    public static readonly string MISSING_SPROC_DEL      = @"Name of delete stored procedure was not provided";
    public static readonly string MISSING_SPROC_OP       = @"Name of op stored procedure was not provided";
    
    public static readonly string MISSING_SPROC_SAVE     = @"Name of save stored procedure was not provided";
    public static readonly string MISSING_DUP_MSG        = @"Duplicate record message not provided";

    public static readonly string MISSING_RD             = @"Unable to retrieve request data.";
    public static readonly string MISSING_REQ_PARMS      = @"Please provide all of the required parameters.";
    public static readonly string INAPPROPRIATE_ROLE     = @"The role you selected is not allowed for this user or you are not allowed to grant this role";
    public static readonly string PERSON_HAS_ACCT        = @"The person you are associating with this account already has an account";
    
    public static readonly string NO_PRACT_ID            = @"Practioner id was not setup.  Account is incomplete";
    public static readonly string INVALID_USER_NAME      = @"Invalid user name";
    public static readonly string INVALID_TOKEN          = @"Invalid token";
    public static readonly string INVALID_ROLE_ID        = @"Invalid role ID";
    public static readonly string INVALID_ROLE           = @"Invalid role";
    public static readonly string INVALID_ENTITY_ID      = @"Invalid entity ID";
    public static readonly string INVALID_EVENT_ID       = @"Invalid event ID";
    public static readonly string INVALID_SVC_REC_REF    = @"Invalid reference document";
    public static readonly string INVALID_FLAG           = @"Invalid flag";
    public static readonly string INVALID_FLAG_ACTIVE    = @"Invalid active flag";
    public static readonly string INVALID_FLAG_APPROVE   = @"Invalid approval flag";
    public static readonly string INVALID_FLAG_PAT_ABSNT = @"Invalid patient absent flag";
    public static readonly string INVALID_FLAG_PAT_PRSNT = @"Invalid patient present flag";
    public static readonly string INVALID_FLAG_PRC_ABSNT = @"Invalid practitioner absent flag";
    public static readonly string INVALID_FLAG_MKUP_SESS = @"Invalid makup session flag";
    public static readonly string INVALID_FLAG_CAN_EDIT  = @"Invalid can edit flag";
    public static readonly string INVALID_FLAG_AUTH_IEP  = @"Invalid aide services auth. in IEP flag";
    public static readonly string INVALID_FLAG_MED_NES   = @"Invalid services are medical nesc flag";
    public static readonly string INVALID_FLAG_ASSIGN    = @"Invalid assign flag";
    public static readonly string INVALID_SITE_ID        = @"Invalid site id";
    public static readonly string INVALID_GROUP_ID       = @"Invalid group id";
    public static readonly string INVALID_GROUP_TYPE     = @"Invalid group type"; 
    public static readonly string INVALID_REPT_GROUP_ID  = @"Invalid reporting group";
    public static readonly string INVALID_GOTO_PAGE      = @"Invalid goto page";
    public static readonly string INVALID_CONDITION_ID   = @"Invalid condition";
    public static readonly string INVALID_PLAN_ID        = @"Invalid plan id";
    public static readonly string INVALID_PLAN_TYPE      = @"Invalid plan type";
    public static readonly string INVALID_PLAN_DATE      = @"Invalid plan date";
    public static readonly string INVALID_SERVICE_TYPE   = @"Invalid service type";
    public static readonly string INVALID_DOB            = @"Date of birth is invalid";
    public static readonly string INVALID_START_DATE     = @"Invalid start date";
    public static readonly string INVALID_END_DATE       = @"Invalid end date";
    public static readonly string INVALID_EFFECTIVE_DATE = @"Invalid effective date";  
    public static readonly string INVALID_ENTRY_DATE     = @"Invalid entry date";
    public static readonly string INVALID_AUTHORIZE_DATE = @"Invalid authorization date";
    public static readonly string INVALID_RUN_DATE       = @"Invalid run date";        
    public static readonly string INVALID_REF_DATE       = @"Invalid reference date";
    public static readonly string INVALID_DOS            = @"Invalid service date";        
    public static readonly string INVALID_DATA_SOURCE    = @"Invalid data source";
    public static readonly string INVALID_CLIENT_ID      = @"Invalid client id";
    public static readonly string INVALID_PERSON_ID      = @"Invalid person id";
    public static readonly string INVALID_PERSON_SOURCE  = @"Invalid person source";
    public static readonly string INVALID_USER_ID        = @"Invalid user id";
    public static readonly string INVALID_PAGE_NUMBER    = @"Invalid page number";
    public static readonly string INVALID_PAGE_SIZE      = @"Invalid page size";
    public static readonly string INVALID_PAGE_ID        = @"Invalid page id";
    public static readonly string INVALID_PAGING_FLAG    = @"Invalid paging flag";
    public static readonly string INVALID_SERVICE        = @"Invalid service name";
    public static readonly string INVALID_CALPADS_CODE   = @"Invalid CALPADS code";
    public static readonly string INVALID_SELPA_CODE     = @"Invalid SELPA code";
    public static readonly string INVALID_RATING_CODE    = @"Invalid rating code";
    public static readonly string INVALID_NAME_ID        = @"Invalid service id";
    public static readonly string INVALID_NAME_DOB       = @"Last name, first name, or date of birth required";
    public static readonly string PATIENT_VIEW_FLNAME    = @"First or last name is required";
    public static readonly string SERVICE_DATE_BAD       = @"Service date is an invalid date";
    public static readonly string PATIENT_ID_BAD         = @"Patient id is invalid";
    public static readonly string IFSP_IEP_FLAG_BAD      = @"IFSP/IEP flag is invalid";
    public static readonly string SERVICE_PLAN_BAD       = @"Service plan is invalid";
    public static readonly string SUB_CLMS_FLAG_BAD      = @"Submit claims flag is invalid";    
    public static readonly string INVALID_SUBMIT_CLAIMS_EFF_DATE = @"Submit claims effective date invalid";
    public static readonly string WARN_NO_SUB_CLAIMS_PAT = @"You have indicated that we should NOT bill for this patient.  YOU SHOULD ONLY SAVE IF YOU ARE SURE!";     
    public static readonly string INVALID_PAT_ID         = @"Invalid patient id";    
    public static readonly string INVALID_RECORD_ID      = @"Invalid record id";
    public static readonly string INVALID_RECORD_IDS     = @"Invalid record ids";
    public static readonly string INVALID_RECORD_INDEX   = @"Invalid record index";
    public static readonly string INVALID_PRAC_ID        = @"Invalid practioner id";
    public static readonly string INVALID_ORP_PRAC_ID    = @"Invalid ORP practioner id";
    public static readonly string INVALID_PWGID          = @"Invalid plan writer group id";
    public static readonly string INVALID_GFID           = @"Invalid group family id";
    public static readonly string INVALID_1_ON_1_TYPE    = @"Invalid 1:1 type";
    public static readonly string INVALID_REPT_PAGE_FLG  = @"Invalid page flag";
    public static readonly string INVALID_REPT_COL_ONLY  = @"Invalid columns only flag";
    public static readonly string INVALID_REPT_FORM      = @"Unknown report format";
    public static readonly string INVALID_REPT_NUMBER    = @"Invalid report number";
    public static readonly string INVALID_REPT_REQ_UID   = @"Invalid report request tracking id";
    public static readonly string INVALID_S_ECHO         = @"Invalid draw count";
    public static readonly string INVALID_EDIT_FLAG      = @"Invalid flag";
    public static readonly string INVALID_SAVE_TYPE      = @"Invalid save type";
    public static readonly string INVALID_NUM_MINS       = @"Number of minutes is invalid";
    public static readonly string INVALID_NUM_TIMES_DAY  = @"Number of times per day is invalid";
    public static readonly string INVALID_NUM_APTS       = @"Number of appointments is wrong";
    public static readonly string INVALID_SVC_REC_DETAIL = @"Invalid service record details";
    public static readonly string INVALID_TRIP_MILES     = @"Invalid number of trip miles";
    public static readonly string INVALID_SEX            = @"The value provided for sex/gender is not supported.";
    public static readonly string INVALID_SSN            = @"Invalid SSN";
    public static readonly string INVALID_BIC            = @"Invalid BIC";
    public static readonly string INVALID_CSIS           = @"Invalid CSIS";
    public static readonly string INVALID_STUDENT_ID     = @"Invalid student id";
    public static readonly string INVALID_GRADE          = @"Invalid grade";
    public static readonly string INVALID_LNAME          = @"Invalid last name";
    public static readonly string INVALID_FNAME          = @"Invalid first name";
    public static readonly string INVALID_MNAME          = @"Invalid middle name";
    public static readonly string INVALID_EMAIL          = @"Invalid email address";
    public static readonly string INVALID_NOTES          = @"Invalid notes";
    public static readonly string INVALID_PHONE_NUMBER   = @"Invalid phone or fax number";
    public static readonly string INVALID_PASSWORD_OLD   = @"Your current password is required";
    public static readonly string INVALID_BATCH_MODE     = @"Invalid batch mode";
    public static readonly string INVALID_NPI            = @"Invalid NPI";
    public static readonly string INVALID_CLIENT_NAME    = @"Invalid Client name";
    public static readonly string INVALID_TAXID          = @"Invalid TAXID";
    public static readonly string INVALID_CDS            = @"Invalid CDS";
    public static readonly string INVALID_EIN            = @"Invalid EIN";
    public static readonly string INVALID_COE_FLAG       = @"COE flag is invalid";
    public static readonly string INVALID_LEA_FLAG       = @"LEA flag is invalid";
    public static readonly string INVALID_MAA_FLAG       = @"MAA flag is invalid";

    public static readonly string INVALID_PERSON_CLASS_ID_1    = @"Invalid person role";
    public static readonly string INVALID_PERSON_CLASS_ID_2    = @"Invalid person relationship";
    public static readonly string INVALID_APPROVED_837_FLAG    = @"Approved_837 flag is invalid";
    public static readonly string INVALID_APPROVED_835_FLAG    = @"Approved_835 flag is invalid";
    public static readonly string INVALID_SVC_REC_APPROVAL_SYS = @"Service record approval system flag invalid";
    public static readonly string INVALID_INCLUDE_IN_REPTS     = @"Invalid include in reports";
    
    public static readonly string INVALID_STREET            = @"Invalid street";
    public static readonly string INVALID_CITY              = @"Invalid city";
    public static readonly string INVALID_STATE             = @"Invalid state";
    public static readonly string INVALID_ADDRESS           = @"Invalid address,city or state";
    public static readonly string INVALID_ATTENDANCE_STATUS = @"Invalid attendance status";

    public static readonly string INVALID_ZIP               = @"Invalid zip or zip plus four";
    public static readonly string INVALID_REP_PUB           = @"Invalid report publication";
    public static readonly string INVALID_SUBSCRIBER_ID     = @"Invalid subscriber id";
    public static readonly string INVALID_EMAIL_LIST        = @"Invalid email list";
    public static readonly string INVALID_PUB_SUB_OPTIONS   = @"Invalid subscription option";
    public static readonly string INVALID_APP_NAME          = @"Invalid app name";
    public static readonly string INVALID_NT_USER           = @"Invalid NT user name";
    public static readonly string NT_USER_NOT_FOUND         = @"NT user name {0} was not found in the users database";
    public static readonly string INVALID_HAS_ORP_DOC_ID    = @"Invalid has ORP document id flag";
    public static readonly string INVALID_ORP_DOC_ID        = @"Invalid ORP document id";    

    public static readonly string OLD_PASSWORD_NOT_FOUND = @"The current password you entered is incorrect.  Please check your entry.";
    public static readonly string INVALID_PASSWORD_NEW       = @"The new password you entered is NOT a STRONG password.  Please refer the notice above Step 1 and edit your entry.";
    public static readonly string INVALID_PASSWORD_NEW_BLANK = @"Your new password cannot be blank";
    
    public static readonly string INVALID_DISP_FAMILY    = @"Invalid practitioner discipline groups family.";
    public static readonly string INVALID_DISP_FAM_SEL   = @"Please select a practitioner group family.";
    public static readonly string INVALID_PASSWORD_SAME  = @"Your new password cannot be the same as your current password.";
    public static readonly string INVALID_PASSWORD_NEQ   = @"New passwords do not match.  Please check your entry.";

    public static readonly string DIFF_PERSON_DATA       = @"The name and/or email for the person associated with this account is different.";
    public static readonly string DATA_ERROR             = @"We cannot save this record at this time due to an unexpected error.  Please try again later.";

    public static readonly string VALIDATION_ISSUES      = @"Please review your record";
    public static readonly string INVALID_VALIDATE_FLAG  = @"Invalid validate flag";
    public static readonly string VAL_SVC_REC_DOS_FUTURE = @"Date of service is a future date";
    public static readonly string VAL_SVC_REC_DOS_PAST   = @"Date of service is over a year old";
    public static readonly string VAL_SVC_REC_DOS_WKND   = @"Date of service is on a weekend";
    public static readonly string VAL_SVC_NUM_MIN_OVER   = @"Number of minutes exceeds 8 hours";
    public static readonly string VAL_PAT_AGE_22         = @"Based on the date of birth this patient 22 or older";
    public static readonly string VAL_PAT_NOT_BORN       = @"Based on the date of birth this patient has not been born yet";

    public static readonly string DUP_SVC_REC            = @"This service MAY have already been recorded";
    public static readonly string DUP_PAT_REC            = @"{1} patient(s) with that name and dob already exist(s).  Please double check the list.";
    public static readonly string DUP_1_ON_1_AIDE_ASSIGN = @"From {1} to {2} this patient already has ({3}) existing aide assignment record(s) for this practitioner that apply";
    public static readonly string DUP_RCR_SVC_ASSIGN     = @"This patient already has a recurring service assignment record for this start and end date";
    
    public static readonly string DUP_PRAC_REC           = @"This practitioner has already been recorded or is inactive.";
    public static readonly string DUP_RPT_SUB_REC        = @"This subscriber already has a subscription for this report.  Continue?";
    public static readonly string DUP_RPT_SBR_REC        = @"This subscriber already exists";
    public static readonly string DUP_CASELOAD_REC       = @"An active caseload record for this patient already exists";
    public static readonly string DUP_CLIENT_REC         = @"This client has already been recorded or is inactive.";
    public static readonly string DUP_USER               = @"This username is already in use by another account.";
    public static readonly string DUP_PATIENT_GROUP      = @"This patient group already exists";
    public static readonly string REC_NOT_ACTIVE         = @"This record is not active";    
    public static readonly string EDIT_REC_NOT_FOUND     = @"Record not found";
    public static readonly string EDIT_REC_NO_EDIT       = @"This record can no longer be edited.";
    public static readonly string EDIT_REC_NO_EDIT_FULL  = @"This record can only be partially edited";
    
    public static readonly string EDIT_REC_NOT_FOUND_PERSON  = @"This person could not be found";
    public static readonly string EDIT_REC_NO_EDIT_PERSON    = @"This person can no longer be edited";
    public static readonly string INVALID_FLAG_INCLUDE_ZEROS = @"Invalid include zeros flag";    
    
    public static readonly string INVALID_PPN_COMBO      = @"This record cannot be saved because of a practioner, patient, service mismatch";
    public static readonly string MIN_REQ                = @"Minutes are required for this service";
    public static readonly string MIN_DEF                = @"You entered less than 7 minutes at least once";
    public static readonly string MIL_REQ                = @"Total miles or start/end miles are required for this service";
    public static readonly string NO_RECORDS_FOUND       = @"No records were found";
    public static readonly string NO_APP_NAME            = @"No app name";
    public static readonly string PAT_ELG                = @"Patient may not be eligible for services (NE)";
    public static readonly string PAT_DOB_GTE_DOS        = @"Date of service is on or before the patients date of birth.";
    public static readonly string PAT_ABSENT_NO_CLAIM    = @"You indicated that the patient was absent at least once.";
    public static readonly string RECORD_NOT_FOUND       = @"Record not found";    
    public static readonly string INVALID_EMPLOYEE_RELATIONSHIP        = @"Invalid employee relationship";
    public static readonly string INVALID_PARENT_CONSENT_MCAL          = @"Invalid parental consent for Medi-Cal flag";
    public static readonly string INVALID_PARENT_CONSENT_MCAL_EFF_DATE = @"Invalid effective date for billing Medi-Cal";
    public static readonly string INVALID_PARENT_CONSENT_OHCI          = @"Invalid parental consent for other health care insurance flag";
    public static readonly string INVALID_PARENT_CONSENT_OHCI_EFF_DATE = @"Invalid effective date for billing other healthcare insurance";
    public static readonly string INVALID_CLAIM_NO_PLAN            = @"Invalid claim for no plan";
    public static readonly string INVALID_CLAIM_NO_PLAN_EFF_DATE   = @"Invalid claim for no plan effective date";
    public static readonly string INVALID_CLAIM_TCM                = @"Invalid claim for TCM";
    public static readonly string INVALID_CLAIM_TCM_EFF_DATE       = @"Invalid claim for TCM effective date";
    public static readonly string INVALID_PARENT_AGREE             = @"Invalid claim for parental consent agreement";
    public static readonly string INVALID_PARENT_AGREE_EFF_DATE    = @"Invalid claim for parental consent agreement effective date";
    public static readonly string INVALID_VIEW_NOTES               = @"Invalid claim for view notes";

    public static readonly string INVALID_REVENUE_SHARING_CATEGORY = @"Invalid revenue sharing category";
    public static readonly string INVALID_REP_ID                   = @"Invalid Client rep ID";
    public static readonly string INVALID_COMPANY_ID               = @"Invalid company ID";
    public static readonly string INVALID_SHORT_NAME               = @"Invalid short name";
    public static readonly string INVALID_NAME_RCG_BY_DHCS_EDS     = @"Invalid name recognised by DHCS,EDS";
    
    public static readonly string INVALID_DOMAIN                   = @"Invalid domain";
    public static readonly string INVALID_SELECTOR                 = @"Invalid selector";  
    public static readonly string INVALID_SELECTOR_TYPE            = @"Invalid selector type";  
      
    public static readonly string INVALID_NOUN                     = @"Invalid noun";
    public static readonly string INVALID_VERB                     = @"Invalid verb";
    public static readonly string INVALID_WHAT_VALUE               = @"Invalid what value";
    public static readonly string INVALID_NVP_NAME                 = @"Invalid name";
    public static readonly string INVALID_NVP_VALUE                = @"Invalid value";
    public static readonly string INVALID_NVP_DESCRIPTION          = @"Invalid description";
    public static readonly string INVALID_ASMT_ANN_DATE            = @"Invalid annual assessment date"; 
    public static readonly string INVALID_ASMT_TRI_ANN_DATE        = @"Invalid triennial assessment date"; 

    public static readonly string INVALID_FISCAL_YEAR_ID           = @"Invalid fiscal year";

    public static readonly string INVALID_FISCAL_QUARTER_ID        = @"Invalid fiscal quarter";

    public static readonly string INVALID_START_TIME               = @"Invalid start time";
    public static readonly string INVALID_END_TIME                 = @"Invalid end time";
    public static readonly string INVALID_DAY_TYPE_ID              = @"Invalid day type";
    public static readonly string INVALID_CALENDAR_ID              = @"Invalid calendar";    
    public static readonly string INVALID_SCHEDULE_ID              = @"Invalid schedule";  
    public static readonly string INVALID_DATES                    = @"Invalid dates";
    public static readonly string INVALID_DATE                     = @"Invalid date";
    public static readonly string INVALID_TRAINING_DATES           = @"One or more training dates are invalid";
    public static readonly string DATES_NOT_ENOUGH                 = @"Not enough dates provided";
    public static readonly string DATES_TOO_MANY                   = @"Too many dates provided";    
    public static readonly string DATES_OUT_OF_RANGE               = @"One or more dates are out of range";             
    public static readonly string DATES_DUP                        = @"One or more dates are duplicates";    
    public static readonly string DATES_OVERLAP                    = @"Dates overlap another record";
    public static readonly string INVALID_DATE_RANGE               = @"Invalid date range";
    public static readonly string INVALID_TIME_RANGE               = @"Invalid time range";
    public static readonly string INVALID_GROUP_NAME               = @"Invalid group name";
    public static readonly string INVALID_GROUP_DESCRIPTION        = @"Invalid group description";
    public static readonly string INVALID_GROUP_FAMILY             = @"Invalid group family";
    public static readonly string PERIODS_OUT_OF_ORDER             = @"Periods in out of order";
    public static readonly string PERIODS_OVERLAPPING              = @"Periods are overlapping";
    public static readonly string INVALID_START_PERIOD             = @"The periods starting neither in period - 0 nor in period - 1";
    public static readonly string INVALID_FILE_CLASS               = @"Invalid file class";
    public static readonly string AUTHORIZATION_STATUS_REQUIRED    = @"Authorization status is required";
    public static readonly string INVALID_FILE_TYPE                 = @"Please select a valid file type";
    public static readonly string DUP_CLIENT_ATTENDANCE_DAY_TYPE         = @"This attendance day type already exists";
    public static readonly string DUP_CLIENT_ATTENDANCE_CALENDAR         = @"A calendar with this name already exists for this fiscal year";    
    public static readonly string DUP_CLIENT_ATTENDANCE_CALENDAR_DATES   = @"This day type has already been defined for this calendar";        
    public static readonly string DUP_CLIENT_ATTENDANCE_SCHEDULE         = @"A schedule with this name already exists for this fiscal year";    
    public static readonly string DUP_CLIENT_ATTENDANCE_SCHEDULE_TIMES   = @"This day type has already been defined for this bell schedule";    
    public static readonly string INVALID_FLAG_DAY_OF_WEEK               = @"Invalid flag for day of week";
    public static readonly string INVALID_RCR_SVC_DETAIL                 = @"Invalid recurring service detail";
    public static readonly string INVALID_PRACTITIONER_PATIENT_GROUP_ID  = @"Invalid patient group id";
    public static readonly string INVALID_EMPLOYEE_ID                    = @"Invalid employee id";
    public static readonly string INVALID_DOLLAR_AMT                     = @"Invalid dollar amount";
    public static readonly string INVALID_LEC_OR_LGA                     = @"Invalid LEC / LGA";
    public static readonly string INVALID_ROSTER_ID                      = @"Invalid roster ID";
    public static readonly string INVALID_QUARTER                        = @"Invalid quarter";
    public static readonly string INVALID_TASK_ID                        = "Invalid Task";
    public static readonly string INVALID_SELECTION_NAME                 = @"Invalid selection name";
    public static readonly string INVALID_FORM_BUILDER_QUESTIONS         = @"Invalid form question data";
    public static readonly string INVALID_FORM_BUILDER_ANSWERS           = @"Invalid form answer data";
    public static readonly string INVALID_PATIENT_GOAL_PROGRESS_DATA     = @"Invalid patient goal progress data";
    public static readonly string QFORM_TITTLE                           = @"Questions or clarifications needed for LEA Medi-Cal billing";
    public static readonly string QFORM_BODY                             = @"<p>Hi {0},</p>" +
                                                                           @"<p>We have attached a form submitted for LEA Medical billing that needs corrections or further clarification.</p>" + 
                                                                           @"<p>Please review the attached form and click <a href=""{1}"">here</a> TO answer the questions.</p>"+
                                                                           @"<p>If you have any questions please contact your district representative. </p>";

    public static readonly string QFORM_BODY_REP                         = @"<p>Hi {0},</p>" +
                                                                           @"<p>We have attached a form submitted for LEA Medical billing that needs corrections or further clarification.</p>" +
                                                                           @"<p>Please review the attached form and click <a href=""{1}"">here</a> TO answer the questions.</p>";

    public static readonly string QFORM_FOLLOWUP_BODY                    = @"<p>Hi {0},</p>" +
                                                                           @"<p>This is a follow-up email for the Question form sent to you.</p>" +
                                                                           @"<p>We have attached a form submitted for LEA Medical billing that needs corrections or further clarification.</p>" +
                                                                           @"<p>Please review the attached form and click <a href=""{1}"">here</a> TO answer the questions.</p>";                                               
                                                                                                                                                        
  
    public static readonly string MSG_NEW_OR_UNREAD_MAN_PAGES_PART = @"There are new announcements or help topics that you have not reviewed yet";
    public static readonly string MSG_NEW_OR_UNREAD_MAN_PAGES       = MSG_NEW_OR_UNREAD_MAN_PAGES_PART + @".";
    
    public static readonly string MSG_PRAC_SELECTION_IS_QUALIFIED_ORP_ONLY = @"The possible selections are limited to only those practitioners recorded in SpEdCare who are qualified to Order, Refer, or Prescribe (ORP).";
    
    public static readonly string MSG_SVC_DESC_RETIREMENT_ORDER = @"NOTE : We are retiring the service description box below. Please use the service details button above.<br>"
                                                                 + @"Once this order is saved, the completed form will replace the service description textbox below (even if the form is not filled out).";

    public static readonly string MSG_SVC_DESC_RETIRMENT_SVC_AUTH_REQUEST = @"NOTE : We are retiring the service description box below.<br>Please complete the form shown immediately below the service description.<br>"
                                                                          + @"The service description box will NOT be sent with your authorization request.<br>"
                                                                          + @"Once this service authorization request is saved, the completed form will replace the service description textbox below (even if the form is not filled out).";
    public static readonly string INVALD_NOTES = @"Invalid Notes";
        
    }
}
