using MBA;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;

namespace Spedmon
{
    /**************************************************************************
     * PractitionerPatientReferral */
    /**
     **************************************************************************/
    public class PractitionerPatientReferral : Entity
    {
        public long     clientID;
        public long     pracID;
        public long     referringByUserID;
        public long     patID;
        public string   patName;
        public byte     priority;
        public string   publicToken;
        public string   pinParent;
        public string   pinPract;
        public string   referredToPracName;
        public string   referredToOrgName;
        public string   referredToPracEmail;
        public string   referredToPracPhone;
        public string   parentGuardianName;
        public string   parentGuardianRelationship;
        public string   parentGuardianEmail;
        public string   parentGuardianPhone;
        public byte     parentGuardianConsent;
        public byte     referralType;
        public bool     includeDiagnoses;
        public bool     includeOrdersOrPrescriptions;
        public bool     includeServiceRecordsTreatments;
        public bool     includeServiceRecordsAssessementsOrScreenings;
        public bool     includeServiceNotesNonConfidential;
        public bool     includeServiceNotesConfidential;
        public DateTime approvalRejectionDate;
        public string   approvalRejectionDateStr;
        public string   approvalRejectionDateStrYMD;
        public TimeSpan approvalRejectionTime;
        public string   approvalRejectionTimeStr;
        public string   approvalRejectionTimeHMS;
        public DateTime startDate;
        public string   startDateStr;
        public string   startDateStrYMD;
        public TimeSpan startTime;
        public string   startTimeStr;
        public string   startTimeHMS;
        public DateTime expirationDate;
        public string   expirationDateStr;
        public string   expirationDateYMD;
        public TimeSpan expirationTime;
        public string   expirationTimeStr;
        public string   expirationTimeYMD;
        public bool     isUsed;
        public string   notes;
        public string   refFileID;

        /*New Enhancements*/
        public long referredToPracID;
        public string referralSourceName;
        public string referralSourceRole;
        public string referralSourceEmail;
        public string referralSourcePhone;
        public bool behavioralIsssuesConcerns;
        public bool academicConcerns;
        public bool anxietyOrDepressionConcerns;
        public bool familyStressConcerns;
        public bool bullyingConcerns;
        public string otherConcerns;

        public bool referalIsFromPublicForm;
        public long publicFormID;
        public string publicFormCreatedOnStr;
        public string publicFormPatientDOBStr;
        public string publicFormPatientFirstName;
        public string publicFormPatientLastName;
        public string publicFormStudentID;
        public string publicFormTeacherName;
        public string publicFormResponderRelationship;
        public string publicFormResponderFirstName;
        public string publicFormResponderLastName;
        public string publicFormResponderEmail;
        public string publicFormResponderPhone;
        public string publicFormReferralDetailNote;

        public string referredByPrivatePersonFirstLastName;
        public string referredByPublicPersonFirstLastName;
        public string referredByPersonFirstLastName;
        public string isUsedStr;


        public const string DEFAULT_PAGING_ORDER = @"id desc";
    }

    /**************************************************************************
     * PractitionerPatientReferrals */
    /**
     **************************************************************************/
    public class PractitionerPatientReferrals: Entities
    {
        public enum EmailType
        {
            sendPin,
            sendParent,
            sendAuthorization,
            sendDecline,
            sendtoPractitioner,
            sendUpdated
        }

        
        public const string MENU_ID_MANAGE              = @"practitionerpatientreferralslnk";
        public const string SEL_LABEL                   = "Patient Referrals";
        public const string SEL_LABEL_MANAGE            = SEL_LABEL + @" - Manage";
        public const string SEL_OUT_LABEL_SAVE          = SEL_LABEL + @" - Outgoing Referral";
        public const string SEL_IN_LABEL_SAVE           = SEL_LABEL + @" - Incoming Referral";
        public const string SEL_LABEL_EXPORT            = SEL_LABEL + @" - Referral Report";
        public const string SEL_LABEL_OPTION_MANAGE     = SEL_LABEL + @" - Option Manage";
        
        public const string URL_WEB_SVC                 = @"practitioner_patient_referrals.asmx";
        public const string URL_WEB_REPORT              = @"practitioner_patient_referals.ashx";

        public const string URL_USER_REF_ALL_MANAGE     = @"user_all_practitioner_patient_referrals_manage.aspx";
        public const string URL_USER_REF_OPTION_MANAGE  = @"user_all_practitioner_patient_referral_options_manage.aspx";
        public const string URL_USER_REF_ALL_SAVE       = @"user_all_practitioner_patient_referral_save.aspx";
        public const string URL_USER_REF_ALL_NEW_SAVE   = @"user_all_practitioner_patient_referral_save_new_client.aspx";
        public const string URL_REQ_PUBLIC_REF          = @"student_referral_share.aspx";

        public const string URL_SVC_REF_SAVE                = URL_WEB_SVC + @"/save";
        public const string URL_SVC_REF_DELETE              = URL_WEB_SVC + @"/delete";
        public const string URL_SVC_PROCESS_REF_RESPONSE    = URL_WEB_SVC + @"/processreferralresponse";
        public const string URL_REST_VIEW                   = @"api/v1/practitionerpatientreferrals";
        

        /***************************************************************************
        * URL_SAVE_NEW_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SAVE_NEW_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerPatientReferrals.URL_USER_REF_ALL_SAVE
                                                                           , true
                                                                           , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                           , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW));
        }

        /***************************************************************************
         * URL_EDIT_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_EDIT_BASE()
        {

            return MBA.HttpApplication.createLink(PractitionerPatientReferrals.URL_USER_REF_ALL_SAVE
                                                    , true
                                                    , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                    , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                                    , new NameValue(Constants.PARM_REC_ID, @""));
        }

        /***************************************************************************
         * URL_SAVE_NEW_CLIENT_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_EDIT_NEW_CLIENT_BASE()
        {

            return MBA.HttpApplication.createLink(PractitionerPatientReferrals.URL_USER_REF_ALL_NEW_SAVE
                                                    , true
                                                    , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                    , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT));
        }

        /***************************************************************************
         * URL_SAVE_NEW_CLIENT_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SAVE_NEW_CLIENT_BASE()
        {

            return MBA.HttpApplication.createLink(PractitionerPatientReferrals.URL_USER_REF_ALL_NEW_SAVE
                                                    , true
                                                    , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                    , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW));
        }


        /***************************************************************************
         * URL_SVC_REF_SAVE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_REF_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerPatientReferrals.URL_SVC_REF_SAVE, true);
        }

        /***************************************************************************
         * URL_SVC_REF_DELETE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_REF_DELETE_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerPatientReferrals.URL_SVC_REF_DELETE, true);
        }

        /***************************************************************************
        * URL_REST_VIEW_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerPatientReferrals.URL_REST_VIEW, true);
        }

        /***************************************************************************
         * URL_SVC_PROCESS_REF_RESPONSE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_PROCESS_REF_RESPONSE_BASE()
        {
            return MBA.HttpApplication.createLink(PractitionerPatientReferrals.URL_SVC_PROCESS_REF_RESPONSE, false);
        }

        /***************************************************************************
        * URL_MANAGE_REFERRALL */
        /**
         * 
         **************************************************************************/
        public static string URL_MANAGE_REFERRALL(string clienID, string patID)
        {
            return MBA.HttpApplication.createLink(PractitionerPatientReferrals.URL_USER_REF_ALL_MANAGE
                                                    , true
                                                    , new NameValue(Constants.PARM_CLIENT_ID, clienID)
                                                    , new NameValue(Constants.PARM_PATIENT_ID, patID));
        }

        /***************************************************************************
         * userCanAccessManageScreen */
        /**
         **************************************************************************/

        public static bool userCanAccessManageScreen (RequestResponse rd)
        {
            if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID) {
                if (rd.wu.pr.isAParaProfessional == true) return false;          
                if (rd.wu.pr.clientID != 112) return false;
                return true;
            }
            return false;
        }
        
        /***************************************************************************
         * userCanAccessSaveScreen */
        /**
         **************************************************************************/

        public static bool userCanAccessSaveScreen (RequestResponse rd, int saveType)
        {
            bool canAccess = userCanAccessManageScreen(rd);
            if (saveType == Constants.SAVE_TYPE_NEW) return false;
            return canAccess;
        }

        /***************************************************************************
         * processreferralresponse */
        /**
         **************************************************************************/
        public static ReturnActionRequest processreferralresponse(SqlConnection connSpedmon
                                                                    , DetailsLog log
                                                                    , RequestResponse reqresp
                                                                    , string ptkn
                                                                    , string parentGuardianConsent
                                                                    , string refpracname
                                                                    , string refpracemail
                                                                    , string pracName
                                                                    , string pracEmail
                                                                    , string recID)
        {
            ReturnActionRequest so = new ReturnActionRequest();
            string saveRespSproc = "STUDENT_REFERRAL_REQUEST_RESPONSE_SAVE";

            var vRequestPublicUrl           = MBA.HttpApplication.createLink(PractitionerPatientReferrals.URL_REQ_PUBLIC_REF);
            var vParentGuardianConsent      = Validate.reqTinyInt(parentGuardianConsent,            @"Invalid Parent Guardian Consent value");
            var vRecID                      = Validate.reqInteger(recID,                            @"Invalid referral ID");
            var vPtkn                       = Validate.reqString(ptkn,                              @"Invalid public token");

            var parms = new List<SqlParameter>();

            try
            {
                parms.Add(Database.SqlParm("@userIP",                   SqlDbType.VarChar,  reqresp.userIP,                 ParameterDirection.Input, 500));
                parms.Add(Database.SqlParm("@userAgent",                SqlDbType.VarChar,  reqresp.userAgent,              ParameterDirection.Input, 8000));
                parms.Add(Database.SqlParm("@parentGuardianConsent",    SqlDbType.TinyInt,  vParentGuardianConsent,         ParameterDirection.Input));
                parms.Add(Database.SqlParm("@isUsed",                   SqlDbType.Bit,      true,                           ParameterDirection.Input));
                parms.Add(Database.SqlParm("@requestPublicUrl",         SqlDbType.VarChar,  vRequestPublicUrl,              ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@ptkn",                     SqlDbType.VarChar,  vPtkn,                          ParameterDirection.Input, 1000));
                parms.Add(Database.SqlParm("@recID",                    SqlDbType.BigInt,   vRecID,                         ParameterDirection.Input));
                parms.Add(Database.SqlParm("@parmNamePtkn",             SqlDbType.VarChar,  Constants.PARM_PUBLIC_TOKEN,    ParameterDirection.Input, 256));
                parms.Add(Database.SqlParm("@parmNametoPrac",           SqlDbType.VarChar,  Constants.PARM_REF_TO_PRAC,     ParameterDirection.Input, 256));
                parms.Add(Database.SqlParm("@requestURL",               SqlDbType.VarChar,  string.Empty,                   ParameterDirection.Output, -1));
                parms.Add(Database.SqlParm("@pinPract",                 SqlDbType.VarChar,  string.Empty,                   ParameterDirection.Output, 10));

                ReturnDB rd = Database.execSproc(connSpedmon, log, saveRespSproc, parms);
                so = (ReturnActionRequest)Database.convertParameters(rd, typeof(ReturnActionRequest));

                if (parentGuardianConsent == "1")
                {
                    string url = parms.First(p => p.ParameterName == "@requestURL").Value?.ToString();
                    string pin = parms.First(p => p.ParameterName == "@pinPract").Value?.ToString();

                    if (!string.IsNullOrEmpty(refpracemail))
                    {
                        // Send the email to the referred practitioner with the PIN
                        beforeSendEmail(EmailType.sendPin, int.Parse(recID), refpracname, refpracemail, pin: pin);

                        // Send the email to the referred practitioner with the URL
                        beforeSendEmail(EmailType.sendAuthorization, int.Parse(recID), refpracname, refpracemail, url: url, pracName: pracName);
                    }
                }
                else if (parentGuardianConsent == "2")
                {
                    if (!string.IsNullOrEmpty(pracEmail))
                    {
                        // Send the email to the referred practitioner with the URL
                        beforeSendEmail(EmailType.sendDecline, int.Parse(recID), pracName, pracEmail);
                    }
                }
            }
            catch (Exception e)
            {
                so.message = @"A problem has occurred please try your request again";
                so.status = Return.RET_WARNING;
            }
            return so;
        }

        /***************************************************************************
         * sendEmail */
        /**
         **************************************************************************/
        private static void sendEmail( string to
                                        , string subject
                                        , string body )
        {
                
            string retStatus = "";            
            Email.sendMail(to, subject, body, true, out retStatus);
        }

        /***************************************************************************
         * beforeSendEmail */
        /**
         **************************************************************************/

        private static void beforeSendEmail(EmailType emailType
                                            , long referralID
                                            , string toName
                                            , string toEmail
                                            , string pin = ""
                                            , string url = ""
                                            , string pracName = "")
        {
            string title = string.Empty;
            string msg = string.Empty;
            
            switch (emailType)
            {
                case EmailType.sendPin:
                    title = "Your PIN Code";
                    msg = String.Format(
                        @"<p>Dear {0},</p>" +
                        @"<p>Your PIN code is: <strong>{1}</strong></p>" +
                        @"<p>Please use this code to complete your request.</p>" +
                        @"<p>Sincerely,<br/>Customer Service</p>",
                        toName,  // {0} - Parent/Guardian or Practitioner's name
                        pin);    // {1} - PIN   
                    
                    break;

                case EmailType.sendParent:                    
                    title = @"Parent/Guardian Authorization Request";
                    msg = String.Format(@"<p>Dear {0},</p>" +
                                @"<p>We hope this message finds you well. To ensure your child continues to receive the best possible care, we kindly request your authorization to share their health information with another provider.</p>" +
                                @"<p>Please review the referral details and choose whether to authorize or reject this request by clicking the secure link below:</p>" +
                                @"<p>Please note: The PIN required to access the patient's information was sent to you in a previous email. Kindly use that PIN along with the secure link below to review the referral details.</p>" +
                                @"<p><a href=""{1}"">Click Here to Review and Respond</a></p>" +
                                @"<p>For quicker service, please reference the following Request ID in any correspondence:</p>" +
                                @"<p><strong>Referral ID:</strong> {2}</p>" +
                                @"<p>Thank you for your prompt attention to this important matter.</p>" +
                                @"<p>Sincerely, {3}<br/>",
                                toName,       // {0} – Parent/guardian name
                                url,          // {1} – Secure link
                                referralID,   // {2} – Request ID
                                pracName      // {3} – Pracs Name
                                );
                    
                    break;

                case EmailType.sendAuthorization:
                    title = "New Patient Referral: Access Details with Link";
                    msg = String.Format(
                            @"<p>Dear Dr. {0},</p>" +
                            @"<p>Please review the attached referral details for further action.</p>" +
                            @"<p>Please note: The PIN required to access the patient's information was sent to you in a previous email. Kindly use that PIN along with the secure link below to review the referral details.</p>" +
                            @"<p><strong>Request ID:</strong> {1}</p>" +
                            @"<p><a href=""{2}"">Click Here to Review the Patient Information</a></p>" +
                            @"<p>Sincerely,<br/>Your Medical Team</p>",
                            toName,      // {0} - Referred Name
                            referralID,  // {1} - Referral ID
                            url);        // {2} - Secure link
                    
                    break;

                case EmailType.sendDecline:
                    title = "Patient Referral Update: Parent/Guardian Rejected the Request";
                    msg = String.Format(
                            @"<p>Dear Dr. {0},</p>" +
                            @"<p>We would like to inform you that the Parent/Guardian has declined the patient referral.</p>" +
                            @"<p>Please update your records accordingly.</p>" +
                            @"<p><strong>Request ID:</strong> {1}</p>" +
                            @"<p>Sincerely,<br/>Your Medical Team</p>",
                            pracName,       // {0} - Pracs Name
                            referralID);    // {1} - Referral ID
                    
                    break;

                case EmailType.sendtoPractitioner:
                    title = "New Patient Referral: You have been assigned a new patient referral";
                    msg = String.Format(
                            @"<p>Dear Dr. {0},</p>" +
                            @"<p>We would like to inform you that you have been assigned as the receiving practitioner for a new patient referral. You will be able to see it on the Referrals Management screen.</p>" +
                            @"<p>Please Sign In to SpEdCare to Review</p>" +
                            @"<p><strong>Request ID:</strong> {1}</p>",
                            toName,         // {0} - Referred Name
                            referralID);    // {1} - Referral ID

                    break;

                case EmailType.sendUpdated:
                    title = "Referral has been updated";
                    msg = String.Format(
                            @"<p>Dear Dr. {0},</p>" +
                            @"<p>The patient referral with ID: {1} has been updated</p>" +
                            @"<p>Please logg in into SpEdCare to review.</p>",
                            toName,         // {0} - Referred Name
                            referralID);    // {1} - Referral ID

                    break;

                default:
                    throw new ArgumentException("Invalid email type specified");
            }

            sendEmail(toEmail, title, msg);
        }


        /***************************************************************************
         * save        
         *
         ***************************************************************************/

        public static ReturnSaveRecord save(
            SqlConnection connSpedmon
          , DetailsLog log
          , UserInfo uInfo
          , string clientID
          , string pracID
          , string referringByUserID
          , string patID
          , string priority
          , string referredToPracName
          , string referredToOrgName
          , string referredToPracEmail
          , string referredToPracPhone
          , string parentGuardianName
          , string parentGuardianRelationship
          , string parentGuardianEmail
          , string parentGuardianPhone
          , string parentGuardianConsent
          , string referralType
          , string notes
          , string refFileID  
          , string includeDiagnoses                              
          , string includeOrdersOrPrescriptions
          , string includeServiceRecordsTreatments
          , string includeServiceRecordsAssessementsOrScreenings
          , string includeServiceNotesNonConfidential
          , string includeServiceNotesConfidential
          , string isUsed
          , string referredToPracID
          , string referralSourceName
          , string referralSourceRole
          , string referralSourceEmail
          , string referralSourcePhone
          , string behavioralIsssuesConcerns
          , string academicConcerns
          , string anxietyOrDepressionConcerns
          , string familyStressConcerns
          , string bullyingConcerns
          , string otherConcerns
          , string editDelReason
          , string validateRec
          , string savetype
          , string recID)

        {
            string spSave = "PRACTITIONER_PATIENT_REFERRALS_SAVE";

            if (referralType == "2" && !string.IsNullOrWhiteSpace(referredToPracID) && referredToPracID != "0")
            {
                Practitioner prac = Practitioners.load(connSpedmon, log, uInfo, referredToPracID);
                referredToPracName = prac.name;
                referredToOrgName = prac.clientName;
                referredToPracPhone = prac.phone;
                referredToPracEmail = prac.email;
            }

            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var parms = new List<SqlParameter>();

            long vClientID                                          = Validate.reqClientID(uInfo, clientID);
            Object vPracID                                          = Validate.optPracID(uInfo, pracID);
            Object vReferringByUserID                               = Validate.optInteger(referringByUserID,                             @"Invalid referring user ID");
            Object vPatID                                           = Validate.optPatID(uInfo, patID);
            Object vRefFileID                                       = Validate.optString(refFileID,                                      @"Invalid file ID");
            Object vPriority                                        = Validate.reqTinyInt(priority,                                      @"Invalid priority value");
            string vReferredToPracName                              = Validate.optString(referredToPracName,                             @"Invalid practitioner name");
            string vReferredToOrgName                               = Validate.optString(referredToOrgName,                              @"Invalid agency name");
            var    vReferredToPracEmail                             = Validate.optEmail(referredToPracEmail,                             @"Invalid practitioner email");
            string vReferredToPracPhone                             = Validate.optString(referredToPracPhone,                            @"Invalid practitioner phone");
            string vParentGuardianName                              = Validate.optString(parentGuardianName,                             @"Invalid Parent/Guardian name");
            string vParentGuardianRelationship                      = Validate.optString(parentGuardianRelationship,                     @"Invalid Parent/Guardian relationship");
            var    vParentGuardianEmail                             = Validate.optEmail(parentGuardianEmail,                             @"Invalid Parent/Guardian email");
            string vParentGuardianPhone                             = Validate.optString(parentGuardianPhone,                            @"Invalid Parent/Guardian phone");
            Object vParentGuardianConsent                           = Validate.reqTinyInt(parentGuardianConsent,                         @"Parent Authorization data must be complete");
            Object vReferralType                                    = Validate.reqTinyInt(referralType,                                  @"Invalid Referral Type");
            Object vNotes                                           = Validate.optString(notes,                                          Messages.INVALID_NOTES);
            Object vincludeDiagnoses                                = Validate.optFlag  (includeDiagnoses,                               @"Invalid Diagnoses Flag");
            Object vIncludeOrdersOrPrescriptions                    = Validate.optFlag  (includeOrdersOrPrescriptions,                   @"Invalid OrderOrPrescription Flag");
            Object vIncludeServiceRecordsTreatments                 = Validate.optFlag  (includeServiceRecordsTreatments,                @"Invalid Service Record Flag");
            Object vIncludeServiceRecordsAssessementsOrScreenings   = Validate.optFlag  (includeServiceRecordsAssessementsOrScreenings,  @"Invalid AssessementsOrScreenings Flag");
            Object vIncludeServiceNotesNonConfidential              = Validate.optFlag  (includeServiceNotesNonConfidential,             @"Invalid NotesNonConfidential Flag");
            Object vIncludeServiceNotesConfidential                 = Validate.optFlag  (includeServiceNotesConfidential,                @"Invalid NotesConfidential Flag");
            Object vIsUsed                                          = Validate.optFlag  (isUsed,                                         @"Invalid isUsed Flag");
            Object vReferredToPracID                                = Validate.optInteger(referredToPracID,                              @"Ivalid Referred Practitioner ID", true);
            string vReferralSourceName                              = Validate.optString(referralSourceName,                             @"Invalid practitioner name");
            string vReferralSourceRole                              = Validate.optString(referralSourceRole,                             @"Invalid practitioner role");
            string vReferralSourceEmail                             = Validate.optString(referralSourceEmail,                            @"Invalid practitioner email");
            string vReferralSourcePhone                             = Validate.optString(referralSourcePhone,                            @"Invalid practitioner phone");
            Object vBehavioralIsssuesConcerns                       = Validate.optFlag  (behavioralIsssuesConcerns,                      @"Invalid Behavioral Issues Flag");
            Object vAcademicConcerns                                = Validate.optFlag  (academicConcerns,                               @"Invalid Behavioral Issues Flag");
            Object vAnxietyOrDepressionConcerns                     = Validate.optFlag  (anxietyOrDepressionConcerns,                    @"Invalid Behavioral Issues Flag");
            Object vFamilyStressConcerns                            = Validate.optFlag  (familyStressConcerns,                           @"Invalid Behavioral Issues Flag");
            Object vBullyingConcerns                                = Validate.optFlag  (bullyingConcerns,                               @"Invalid Behavioral Issues Flag");
            Object vOtherConcerns                                   = Validate.optString(otherConcerns,                                  @"Invalid Behavioral Issues Flag");

            var vRequestPublicUrl = MBA.HttpApplication.createLink(PractitionerPatientReferrals.URL_REQ_PUBLIC_REF);
            
            parms.Add(Database.SqlParm("@clientID",                                         SqlDbType.BigInt,   vClientID,                                       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",                                           SqlDbType.BigInt,   vPracID,                                         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@referringByUserID",                                SqlDbType.BigInt,   vReferringByUserID,                              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",                                            SqlDbType.BigInt,   vPatID,                                          ParameterDirection.Input));            
            parms.Add(Database.SqlParm("@priority",                                         SqlDbType.TinyInt,  vPriority,                                       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@referredToPracName",                               SqlDbType.VarChar,  vReferredToPracName,                             ParameterDirection.Input));
            parms.Add(Database.SqlParm("@referredToOrgName",                                SqlDbType.VarChar,  vReferredToOrgName,                              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@referredToPracEmail",                              SqlDbType.VarChar,  vReferredToPracEmail,                            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@referredToPracPhone",                              SqlDbType.VarChar,  vReferredToPracPhone,                            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@parentGuardianName",                               SqlDbType.VarChar,  vParentGuardianName,                             ParameterDirection.Input));
            parms.Add(Database.SqlParm("@parentGuardianRelationship",                       SqlDbType.VarChar,  vParentGuardianRelationship,                     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@parentGuardianEmail",                              SqlDbType.VarChar,  vParentGuardianEmail,                            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@parentGuardianPhone",                              SqlDbType.VarChar,  vParentGuardianPhone,                            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@parentGuardianConsent",                            SqlDbType.TinyInt,  vParentGuardianConsent,                          ParameterDirection.Input));
            parms.Add(Database.SqlParm("@referralType",                                     SqlDbType.TinyInt,  vReferralType,                                   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@notes",                                            SqlDbType.VarChar,  vNotes,                                          ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@refFileID",                                        SqlDbType.VarChar,  vRefFileID,                                      ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@includeDiagnoses",                                 SqlDbType.Bit,      vincludeDiagnoses,                               ParameterDirection.Input));
            parms.Add(Database.SqlParm("@includeOrdersOrPrescriptions",                     SqlDbType.Bit,      vIncludeOrdersOrPrescriptions,                   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@includeServiceRecordsTreatments",                  SqlDbType.Bit,      vIncludeServiceRecordsTreatments,                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@includeServiceRecordsAssessementsOrScreenings",    SqlDbType.Bit,      vIncludeServiceRecordsAssessementsOrScreenings,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@includeServiceNotesNonConfidential",               SqlDbType.Bit,      vIncludeServiceNotesNonConfidential,             ParameterDirection.Input));
            parms.Add(Database.SqlParm("@includeServiceNotesConfidential",                  SqlDbType.Bit,      vIncludeServiceNotesConfidential,                ParameterDirection.Input));
            parms.Add(Database.SqlParm("@isUsed",                                           SqlDbType.Bit,      vIsUsed,                                         ParameterDirection.Input));

            parms.Add(Database.SqlParm("@referredToPracID",                                 SqlDbType.BigInt,   vReferredToPracID,                               ParameterDirection.Input));
            parms.Add(Database.SqlParm("@referralSourceName",                               SqlDbType.VarChar,  vReferralSourceName,                             ParameterDirection.Input));
            parms.Add(Database.SqlParm("@referralSourceRole",                               SqlDbType.VarChar,  vReferralSourceRole,                             ParameterDirection.Input));
            parms.Add(Database.SqlParm("@referralSourceEmail",                              SqlDbType.VarChar,  vReferralSourceEmail,                            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@referralSourcePhone",                              SqlDbType.VarChar,  vReferralSourcePhone,                            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@behavioralIsssuesConcerns",                        SqlDbType.Bit,      vBehavioralIsssuesConcerns,                      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@academicConcerns",                                 SqlDbType.Bit,      vAcademicConcerns,                               ParameterDirection.Input));
            parms.Add(Database.SqlParm("@anxietyOrDepressionConcerns",                      SqlDbType.Bit,      vAnxietyOrDepressionConcerns,                    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@familyStressConcerns",                             SqlDbType.Bit,      vFamilyStressConcerns,                           ParameterDirection.Input));
            parms.Add(Database.SqlParm("@bullyingConcerns",                                 SqlDbType.Bit,      vBullyingConcerns,                               ParameterDirection.Input));
            parms.Add(Database.SqlParm("@otherConcerns",                                    SqlDbType.VarChar,  vOtherConcerns,                                  ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@requestPublicUrl",                                 SqlDbType.VarChar,  vRequestPublicUrl,                               ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@parmNamePtkn",                                     SqlDbType.VarChar,  Constants.PARM_PUBLIC_TOKEN,                     ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@parmNametoParent",                                 SqlDbType.VarChar,  Constants.PARM_REF_TO_PARENT,                    ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@requestURL",                                       SqlDbType.VarChar,  string.Empty,                                    ParameterDirection.Output, -1));
            parms.Add(Database.SqlParm("@pinParent",                                        SqlDbType.VarChar,  string.Empty,                                    ParameterDirection.Output, 10));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            ReturnSaveRecord so = Entities.save(connSpedmon, log, uInfo, savetype, validateRec, editDelReason, recID, spSave, @"An active referral request already exists", ref parms, null);           

            if (so.status == Return.RET_SUCCESS && int.Parse(savetype) == Constants.SAVE_TYPE_NEW)
            {
                if (referralType == "1")
                {
                    string url = parms.First(p => p.ParameterName == "@requestURL").Value?.ToString();
                    string pin = parms.First(p => p.ParameterName == "@pinParent").Value?.ToString();

                    if (!string.IsNullOrEmpty(parentGuardianEmail))
                    {
                        // Send the email to the parent/guardian with the PIN
                        beforeSendEmail(EmailType.sendPin, so.recordID, parentGuardianName, parentGuardianEmail, pin: pin);

                        //Send the email to the parent/guardian with the URL
                        beforeSendEmail(EmailType.sendParent, so.recordID, parentGuardianName, parentGuardianEmail, url: url);
                    }
                }
                else
                {
                    // Send the email to the practitioner informing about a new client referral
                    if (!string.IsNullOrEmpty(referredToPracEmail))
                    {
                        beforeSendEmail(EmailType.sendtoPractitioner, so.recordID, referredToPracName, referredToPracEmail);
                    }
                }

            }
            else if(int.Parse(savetype) == Constants.SAVE_TYPE_EDIT)
            {
                if (!string.IsNullOrEmpty(referredToPracEmail))
                {
                    beforeSendEmail(EmailType.sendUpdated, so.recordID, referredToPracName, referredToPracEmail);
                }
            }
            return so;
        }

        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , int recViewType
                                     , bool pagedOrTop
                                     , string idx
                                     , string canEdit
                                     , string active
                                     , string clientID
                                     , string pracID
                                     , string referringByUserID
                                     , string patID
                                     , string filterAsComplete
                                     , defineCols dc)
        {

            string viewUDF = "PRACTITIONER_PATIENT_REFERRALS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @referringByUserID, @patID, @filterAsComplete, @active, @recID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var parms = new List<SqlParameter>();

            long vClientID              = Validate.reqClientID  (uInfo, clientID);
            object vPracID              = Validate.optPracID    (uInfo, pracID);
            Object vReferringUserID     = Validate.optInteger   (referringByUserID, @"Invalid referring user ID");
            Object vPatID               = Validate.optInteger   (patID, Messages.INVALID_PAT_ID);
            Object vFilterAsComplete    = Validate.optFlag      (filterAsComplete, "Referral Complete Filter?");

            parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,   vClientID,          ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",               SqlDbType.BigInt,   vPracID,            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@referringByUserID",    SqlDbType.BigInt,   vReferringUserID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",                SqlDbType.BigInt,   vPatID,             ParameterDirection.Input));
            parms.Add(Database.SqlParm("@filterAsComplete",     SqlDbType.Bit,      vFilterAsComplete,  ParameterDirection.Input));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
        * delete */
        /**
         * 
         ***************************************************************************/

        public static ReturnSaveRecord delete(
            SqlConnection connSpedmon
          , DetailsLog log
          , UserInfo uInfo
          , string editDelReason
          , string validateRec
          , string recID)
        {

            var parms = new List<SqlParameter>();

            /*----------------------------
             * Call base method 
             *----------------------------*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "Practitioner_Patient_Referrals_Delete", ref parms);
        }

        /***************************************************************************
         * load */
        /**
         * Loads single record
         * 
         * Note: This calls the view method and the view method takes care of
         * enforcing client specific data
         * 
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @param  clientID        Client ID
         * @return                 ReturnEntity
         ***************************************************************************/

        public static PractitionerPatientReferral load(SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , string clientID
                                         , string recID)
        {
            /*###########################################################################
              # Call the base method which handles everything and return
              ###########################################################################*/

            return (PractitionerPatientReferral)Entities.load(connSpedmon, log, uInfo, recID, typeof(PractitionerPatientReferral),
            delegate { return PractitionerPatientReferrals.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "Y", clientID, null, null, null, null, null); });
        }

        /***************************************************************************
         * viewObjects */
        /**
         *
         ***************************************************************************/
        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string active
                                                  , string clientID
                                                  , string pracID
                                                  , string referringByUserID
                                                  , string patID
                                                  , string filterAsComplete)

        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PractitionerPatientReferral.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(PractitionerPatientReferral)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate {
                                              return PractitionerPatientReferrals.view(
                                                                                         connSpedmon
                                                                                       , log
                                                                                       , uInfo
                                                                                       , Entities.REC_VIEW_OBJECTS
                                                                                       , pageObjectList
                                                                                       , idx
                                                                                       , ""
                                                                                       , active
                                                                                       , clientID
                                                                                       , pracID
                                                                                       , referringByUserID
                                                                                       , patID
                                                                                       , filterAsComplete
                                                                                       , dc);
                                          });


        }
    }
}
