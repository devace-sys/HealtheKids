using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /**************************************************************************
     * PatientInfoRequestResponse */
    /**
     **************************************************************************/
    public class PatientInfoRequestResponse : PatientInfoRequestResponsePublic
    {
        public static string DEFAULT_PAGING_ORDER = "patName asc";

        
        public long    patID;
        public string  insuranceCarrierName;
        public string  insuranceCarrierOtherName;
        public bool    consent;                
        public bool    responseReceived;
        public string  responderUserIP;
        public string  responderUserAgent;
        public bool    responseApproved;
        public bool    hasResponderSignatureImgData;
        public string  responderSignatureImgData;
        public string  consentStr;
        public string  responseReceivedOnStr;
        public string  siteName;
        public string  studentID;
        public string  grade;
        public string  ssid;
    }

    /***************************************************************************
     * PatientInfoRequestsResponses */
    /**
     *
     **************************************************************************/
    public class PatientInfoRequestsResponses : Entities
    {
        public const string URL_REST_VIEW = @"api/v1/patientinforequestsresponses";
        public const string URL_WEB_SVC   = @"patient_info_requests_responses.asmx";
        public const string URL_WEB_RPT   = @"patient_info_requests_responses.ashx";

        public const string URL_SVC_SAVE_NEW_REQUEST_INLINE            = URL_WEB_SVC + @"/savenewrequestinline";
        public const string URL_SVC_SAVE_NEW_MASS_REQUEST_INLINE       = URL_WEB_SVC + @"/savenewmassrequestinline";
        public const string URL_SVC_COMPLETE_REVIEW_RESPONSE_INLINE    = URL_WEB_SVC + @"/completereviewresponseinline";
        public const string URL_SVC_SEND_REQUEST_INLINE                = URL_WEB_SVC + @"/sendrequestinline";
        public const string URL_SVC_CANCEL_REQUEST_INLINE              = URL_WEB_SVC + @"/cancelrequestinline";
        public const string URL_SVC_CANCEL_ALL_REQUESTS_INLINE         = URL_WEB_SVC + @"/cancelallrequestsinline";

        /***************************************************************************
         * URL_SVC_SAVE_NEW_REQUEST_INLINE_BASE */
        /**
         **************************************************************************/
        public static string URL_SVC_SAVE_NEW_REQUEST_INLINE_BASE()
        {
          return MBA.HttpApplication.createLink(PatientInfoRequestsResponses.URL_SVC_SAVE_NEW_REQUEST_INLINE, true);
        }

        /***************************************************************************
         * URL_SVC_SAVE_NEW_MASS_REQUEST_INLINE_BASE */
        /**
         **************************************************************************/
        public static string URL_SVC_SAVE_NEW_MASS_REQUEST_INLINE_BASE()
        {
          return MBA.HttpApplication.createLink(PatientInfoRequestsResponses.URL_SVC_SAVE_NEW_MASS_REQUEST_INLINE, true);
        }

        /***************************************************************************
         * URL_SVC_COMPLETE_REVIEW_RESPONSE_INLINE_BASE */
        /**
         **************************************************************************/
        public static string URL_SVC_COMPLETE_REVIEW_RESPONSE_INLINE_BASE()
        {
          return MBA.HttpApplication.createLink(PatientInfoRequestsResponses.URL_SVC_COMPLETE_REVIEW_RESPONSE_INLINE, true);
        }

        /***************************************************************************
         * URL_SVC_CANCEL_REQUEST_INLINE_BASE */
        /**
         **************************************************************************/
        public static string URL_SVC_CANCEL_REQUEST_INLINE_BASE()
        {
          return MBA.HttpApplication.createLink(PatientInfoRequestsResponses.URL_SVC_CANCEL_REQUEST_INLINE, true);
        }

        /***************************************************************************
         * URL_SVC_CANCEL_ALL_REQUESTS_INLINE_BASE */
        /**
         **************************************************************************/
        public static string URL_SVC_CANCEL_ALL_REQUESTS_INLINE_BASE()
        {
          return MBA.HttpApplication.createLink(PatientInfoRequestsResponses.URL_SVC_CANCEL_ALL_REQUESTS_INLINE, true);
        }

        /***************************************************************************
         * URL_REST_VIEW_BASE */
        /**
         **************************************************************************/
        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(PatientInfoRequestsResponses.URL_REST_VIEW, true);
        }

        /***************************************************************************
         * URL_WEB_RPT_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_WEB_RPT_BASE()
        {
            return MBA.HttpApplication.createLink(PatientInfoRequestsResponses.URL_WEB_RPT, true);
        }
        
        /***************************************************************************
         * userHasAccess */
        /**
         **************************************************************************/
        public static bool userHasAccess (   SqlConnection   connSpedmon
                                           , DetailsLog      log
                                           , UserInfo        uInfo )
        {
          if (uInfo.pcalStaff == true) return true;              
          bool accessGranted = false;  
          if (uInfo.userGroup == Constants.USER_GROUP_CLIENT) { 
            Client c = Clients.load(connSpedmon,log,uInfo,uInfo.userClientIDStr);            
            accessGranted = c.cybhiAddOnMissingInfoRequestsToPatientPersons;
          }
          return accessGranted;
        }
        
        
        /***************************************************************************
         * responseAccessCheck */
        /**
         **************************************************************************/
        public static bool responseAccessCheck (  SqlConnection    connSpedmon
                                                 , DetailsLog       log 
                                                 , RequestResponse  rr                                                                         
                                                 , string           ptkn) 

        {

          bool accessGranted = false;          

          try
          { 
            string actionRequestSproc = "PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_ACCESS_CHECK";
          
            var vPtkn       = Validate.reqString (ptkn, @"Invalid token");   
            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@userIP",        SqlDbType.VarChar,  rr.userIP,      ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@userAgent",     SqlDbType.VarChar,  rr.userAgent,   ParameterDirection.Input, 8000));
            parms.Add(Database.SqlParm("@ptkn",          SqlDbType.VarChar,  vPtkn,          ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@accessGranted",  SqlDbType.Bit,     null,           ParameterDirection.Output));

            ReturnDB rd = Database.execSproc(connSpedmon, log, actionRequestSproc, parms);     
            var accessGrantedParm = Database.findParameter("@accessGranted", ref parms);
            var accessGrantedVal  = accessGrantedParm.Value;
            accessGranted = (bool) accessGrantedVal;
          } 
          catch (Exception e) {
            accessGranted = false;
          }

          return accessGranted;           
        }

        /***************************************************************************
         * saveResponse */
        /**
         **************************************************************************/
        public static ReturnActionRequest saveResponse (   SqlConnection    connSpedmon
                                                         , DetailsLog       log 
                                                         , RequestResponse  rr
                                                         , string           ptkn
                                                         , string insuranceCarrierID
                                                         , string insuranceCarrierPolicyHolderFirstName
                                                         , string insuranceCarrierPolicyHolderLastName
                                                         , string policyNumber
                                                         , string insuranceGroupNumberID
                                                         , string insuranceCarrierOtherName
                                                         , string consent                                                                                                                  
                                                         , string responderSignatureImgData
                                                         , string patPerID ) 

        {
            ReturnActionRequest so = new ReturnActionRequest();

            string actionRequestSproc = "PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_SAVE";
            
            var vPtkn = Validate.reqString (ptkn, @"Invalid token");                                    

            var vInsuranceCarrierPolicyHolderFirstName = Validate.optString(insuranceCarrierPolicyHolderFirstName, "Invalid policyholder");
            var vInsuranceCarrierPolicyHolderLastName  = Validate.optString(insuranceCarrierPolicyHolderLastName, "Invalid policyholder");
            var vInsuranceCarrierID                    = Validate.reqInteger (insuranceCarrierID, "Invalid insurance company selection");
            var vPolicyNumber                          = Validate.optString  (policyNumber, "Invalid policy number");
            var vInsuranceGroupNumberID                = Validate.optString  (insuranceGroupNumberID, "Invalid insuranceGroupNumberID");
            var vInsuranceCarrierOtherName             = Validate.optString  (insuranceCarrierOtherName, "Invalid carrier name");
            var vConsent                               = Validate.reqFlag    (consent,  @"Invalid consent value", true);
            var vPatPerID                              = Validate.reqInteger (patPerID, @"Invalid patient person ID");
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

              vInsuranceCarrierPolicyHolderFirstName = System.Net.WebUtility.HtmlEncode(vInsuranceCarrierPolicyHolderFirstName);
              vInsuranceCarrierPolicyHolderLastName  = System.Net.WebUtility.HtmlEncode(vInsuranceCarrierPolicyHolderLastName);            
              vPolicyNumber                          = System.Net.WebUtility.HtmlEncode(vPolicyNumber);
              vInsuranceGroupNumberID                = System.Net.WebUtility.HtmlEncode(vInsuranceGroupNumberID);
              vInsuranceCarrierOtherName             = System.Net.WebUtility.HtmlEncode(vInsuranceCarrierOtherName);

              var parms = new List<SqlParameter>();

              parms.Add(Database.SqlParm("@userIP",                                SqlDbType.VarChar,  rr.userIP,    ParameterDirection.Input, 500));
              parms.Add(Database.SqlParm("@userAgent",                             SqlDbType.VarChar,  rr.userAgent, ParameterDirection.Input, 8000));
              parms.Add(Database.SqlParm("@ptkn",                                  SqlDbType.VarChar,  vPtkn,        ParameterDirection.Input, 500));
              parms.Add(Database.SqlParm("@insuranceCarrierPolicyHolderFirstName", SqlDbType.VarChar,  vInsuranceCarrierPolicyHolderFirstName, ParameterDirection.Input,  255));
              parms.Add(Database.SqlParm("@insuranceCarrierPolicyHolderLastName",  SqlDbType.VarChar,  vInsuranceCarrierPolicyHolderLastName,  ParameterDirection.Input,  255));
              parms.Add(Database.SqlParm("@insuranceCarrierID",                    SqlDbType.BigInt,   vInsuranceCarrierID,           ParameterDirection.Input));
              parms.Add(Database.SqlParm("@policyNumber",                          SqlDbType.VarChar,  vPolicyNumber,                 ParameterDirection.Input, 80));
              parms.Add(Database.SqlParm("@insuranceCarrierOtherName",             SqlDbType.VarChar,  vInsuranceCarrierOtherName,    ParameterDirection.Input, 256));
              parms.Add(Database.SqlParm("@insuranceGroupNumberID",                SqlDbType.VarChar,  vInsuranceGroupNumberID,       ParameterDirection.Input, 256));
              parms.Add(Database.SqlParm("@consent",                               SqlDbType.Bit,      vConsent,                      ParameterDirection.Input));          
              parms.Add(Database.SqlParm("@patPerID",                              SqlDbType.BigInt,   vPatPerID,                     ParameterDirection.Input));
              parms.Add(Database.SqlParm("@responderSignatureImgData",             SqlDbType.VarChar,  vResponderSignatureImgData,    ParameterDirection.Input, -1));
              parms.Add(Database.SqlParm("@noInsuranceOptionSelected",             SqlDbType.Bit,      vNoInsuranceOptionSelected,    ParameterDirection.Input));
              parms.Add(Database.SqlParm("@otherInsuranceOptionSelected",          SqlDbType.Bit,      vOtherInsuranceOptionSelected, ParameterDirection.Input));
              
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
         * cancelRequest */
        /**
         **************************************************************************/
        public static ReturnSaveRecord cancelRequest ( 
            SqlConnection connSpedmon
          , DetailsLog    log
          , UserInfo      uInfo
          , string        clientID          
          , string        recID )
        {
            ReturnSaveRecord so = new ReturnSaveRecord();

            string saveSproc = "PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_CANCEL";

            var vClientID  = Validate.reqClientID (uInfo,clientID);
            
            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            
            return Entities.save (   connSpedmon
                                   , log
                                   , uInfo
                                   , "2" /*saveType*/
                                   , "N" /* validateRec */
                                   , "" /* editDelReason */
                                   , recID
                                   , saveSproc
                                   , @"Request already sent cant cancel"
                                , ref parms
                                , delegate () { });            
        }

        /***************************************************************************
         * cancellAllRequests */
        /**
         * Note: ageInDays = Number of days since request was created.  
         * Its recommended you set this to 7 or higher to give people time to 
         * respond before you cancel
         ***************************************************************************/

        public static ReturnSaveRecord cancellAllRequests (  SqlConnection connSpedmon
                                                           , DetailsLog log
                                                           , UserInfo uInfo
                                                           , string clientID   
                                                           , string ageInDays )
        {

            string deleteAllSproc = @"PATIENT_INFO_REQUESTS_RESPONSES_MASS_REQUEST_CANCEL";

            /*###########################################################################
              # Validate parameters specific to this entity delete and create their 
              # database parameters.
              ###########################################################################*/

            var vClientID  = Validate.reqClientID (uInfo,     clientID);
            var vAgeInDays = Validate.reqInteger  (ageInDays, @"Invalid age in days",true);
            
            var parms = new List<SqlParameter>();
            
            parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt, vClientID,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@ageInDays", SqlDbType.Int,    vAgeInDays, ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.deleteAll (connSpedmon, log, uInfo, @"", @"N", deleteAllSproc, ref parms);
        }
       

        /***************************************************************************
         * completeReviewOfResponse */
        /**
         **************************************************************************/
        public static ReturnSaveRecord completeReviewOfResponse ( 
            SqlConnection connSpedmon
          , DetailsLog    log
          , UserInfo      uInfo
          , string        clientID          
          , string        recID )
        {
            ReturnSaveRecord so = new ReturnSaveRecord();

            string saveSproc = "PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_COMPLETE_REVIEW";

            var vClientID  = Validate.reqClientID (uInfo,clientID);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",     SqlDbType.BigInt, vClientID, ParameterDirection.Input));

            return Entities.save (   connSpedmon
                                   , log
                                   , uInfo
                                   , "2" /*saveType*/
                                   , "N" /* validateRec */
                                   , "" /* editDelReason */
                                   , recID
                                   , saveSproc
                                   , @"Response already reviewed"
                                   , ref parms
                                   , delegate () { });            
        }
 
        /***************************************************************************
         * emailRequest */
        /**
         **************************************************************************/
        protected static PatientInfoRequestToPerson _emailRequest  (  long   requestID 
                                                                    , string requesterName
                                                                    , string requesterEmail
                                                                    , string requesterPhone
                                                                    , PatientInfoRequestToPerson personIn)
        {
            PatientInfoRequestToPerson personOut = personIn;
            
            /* If we are not emailing exit.  We might be texting instead. */

            if (personIn.sendEmail == false) return personOut;
            if (personIn.sentEmail == true)  return personOut;
                                           
            string titleEn      = @"Please Update Your Student`s Insurance Information.";
            string titleEs      = @"Por favor actualice la información del seguro de su estudiante.";
            string clientName   = personIn.clientName;
            string title        = clientName + @" - " + titleEn + @" | " + titleEs;
            string onBehalfOfClientEn = "On Behalf Of " + clientName;                                                               
            string onBehalfOfClientEs = "En Representación De " + clientName;

            string msgEn = String.Format(   @"<p>Dear {0},</p>"
                                          + @"<p>We hope you are doing well.  To ensure your student receives the best possible care, we kindly request that you provide us with updated insurance information. Please take a moment to complete our secure online form by clicking the unique link below:</p>"
                                          + @"<p><a href=""{1}"">Click Here To Update Insurance Information</a></p>"
                                          + @"<p>Completing this form is quick and ensures that we have the correct details on file.  If you have any questions or need assistance with the process, please feel free to email me at <a href=""mailto:{3}"">{3}</a>.</p>"
                                          + @"<p>For faster service please provide the following request ID in any correspondence : {6}</p>"                                          
                                          + @"<p>Thank you for your prompt attention to this matter.</p>"
                                          + @"<p>Sincerely<br/>"
                                          + @"{2}<br/>"
                                          + @"{5}</p>"
                                          , personIn.name
                                          , Util.appendParmToLink(personIn.requestURL,Constants.PARM_LANGUAGE,Constants.LANG_ENGLISH,true)
                                          , requesterName
                                          , requesterEmail
                                          , requesterPhone
                                          , onBehalfOfClientEn
                                          , requestID);

            string msgEs = String.Format(   @"<p>Estimado/a {0},</p>"
                                          + @"<p>Esperamos que se encuentre bien. Para garantizar que su estudiante reciba la mejor atención posible, le solicitamos amablemente que nos proporcione información actualizada de su seguro médico. Por favor, tómese un momento para completar nuestro formulario en línea seguro, haciendo clic en el enlace único a continuación:</p>"
                                          + @"<p><a href=""{1}"">Haga clic aquí para actualizar la información del seguro</a></p>"
                                          + @"<p>Completar este formulario es rápido y garantiza que tengamos la información correcta en nuestros archivos. Si tiene alguna pregunta o necesita ayuda con el proceso, no dude en contactarme por correo electrónico a <a href=""mailto:{3}"">{3}</a>.</p>"
                                          + @"<p>Para un servicio más rápido, proporcione el siguiente ID de solicitud en cualquier correspondencia: {6}</p>"
                                          + @"<p>Gracias por su pronta atención a este asunto.</p>"
                                          + @"<p>Sinceramente,<br/>"
                                          + @"{2}<br/>"
                                          + @"{5}</p>"                                         

                                          , personIn.name
                                          , Util.appendParmToLink(personIn.requestURL,Constants.PARM_LANGUAGE,Constants.LANG_SPANISH,true)
                                          , requesterName
                                          , requesterEmail
                                          , requesterPhone
                                          , onBehalfOfClientEs
                                          , requestID);

            string msg = @"<p>" + title + @"</p>"
                       + @"<hr/>" 
                       + msgEn 
                       + @"<hr/>" 
                       + msgEs;

            string retStatus = "";
            bool retState = false;
            retState = Email.sendMail (personIn.email, title ,msg, true, out retStatus);
            personOut.sentEmail = retState;
            personOut.sentEmailStatus = retStatus;
            return personOut;             
        }
 
       /***************************************************************************
        * emailRequests */
       /**
        **************************************************************************/
       protected static List<PatientInfoRequestToPerson> _emailRequests  (  long   requestID 
                                                                          , string requesterName
                                                                          , string requesterEmail
                                                                          , string requesterPhone
                                                                          , List<PatientInfoRequestToPerson> personsIn)
        {
          List<PatientInfoRequestToPerson> personsOut = new List<PatientInfoRequestToPerson>();
                      
          foreach (PatientInfoRequestToPerson personIn in personsIn) {                       
            var personOut = _emailRequest(requestID, requesterName, requesterEmail, requesterPhone, personIn);
            personsOut.Add(personOut);
          }          
          return personsOut;
        }
        
        /***************************************************************************
         * updateSentStatus */
        /**
         **************************************************************************/
        protected static ReturnSaveRecord _updateSentStatus ( 
            SqlConnection connSpedmon
          , DetailsLog    log
          , UserInfo      uInfo
          , string        clientID
          , string        sentToPersonsJSON
          , string        recID )
        {
            ReturnSaveRecord so = new ReturnSaveRecord();

            string saveSproc = "PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_UPDATE_REQUEST_SENT";

            var vClientID          = Validate.reqClientID (uInfo,clientID);
            var vSentToPersonsJSON = Validate.reqString(sentToPersonsJSON,@"Sent to persons data is required");
            
            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",          SqlDbType.BigInt,  vClientID,          ParameterDirection.Input));
            parms.Add(Database.SqlParm("@sentToPersonsJSON", SqlDbType.VarChar, vSentToPersonsJSON, ParameterDirection.Input,-1));

            return Entities.save (   connSpedmon
                                   , log
                                   , uInfo
                                   , "2" /*saveType*/
                                   , "N" /* validateRec */
                                   , "" /* editDelReason */
                                   , recID
                                   , saveSproc
                                   , @"Request sent data already updated"
                                   , ref parms
                                   , delegate () { });            
        }
        
        /***************************************************************************
         * saveNewRequest */
        /**
         **************************************************************************/
        protected static ReturnSaveRecordWithJSONData _saveNewRequest (
            SqlConnection connSpedmon          
          , DetailsLog    log
          , UserInfo      uInfo          
          , string        clientID
          , string        patID
          , string        msgTxt
          , string        patPerIDs
          , string        sendEmail
          , string        sendText          
          , string        requesterName
          , string        requesterEmail
          , string        requesterPhone          
          , bool          individualRequest
          , bool          requestFromAuthor
          , string        requestBaseUrl
          , long?         massUpdateRowID )          
        {
         
          string saveSproc = "PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_SAVE";
          
          var vClientID     = Validate.reqClientID      (uInfo, clientID);
          var vPatID        = Validate.reqPatID         (uInfo, patID);
          var vMsgTxt       = Validate.optString        (msgTxt, 5000,   @"Invalid message text");
          var vPatPerIDs    = Validate.reqRecIDMultiStr (patPerIDs,      @"You must select at least one parent/guardian");
          var vSendEmail    = Validate.reqFlag          (sendEmail,      @"Invalid value for send email",true);
          var vSendText     = Validate.reqFlag          (sendText,       @"Invalid value for send text",true);  
          
          Object vMassRowUpdateID = null;
          
          if (individualRequest == false) {
              if (massUpdateRowID.HasValue) { 
                vMassRowUpdateID = massUpdateRowID.Value;
              }
          }

          var parms = new List<SqlParameter>();

          parms.Add(Database.SqlParm("@clientID",              SqlDbType.BigInt,   vClientID,                    ParameterDirection.Input));
          parms.Add(Database.SqlParm("@patID",                 SqlDbType.BigInt,   vPatID,                       ParameterDirection.Input));
          parms.Add(Database.SqlParm("@patPerIDs",             SqlDbType.VarChar,  vPatPerIDs,                   ParameterDirection.Input, -1));                    
          parms.Add(Database.SqlParm("@requestBaseUrl",        SqlDbType.VarChar,  requestBaseUrl,               ParameterDirection.Input, 1000));
          parms.Add(Database.SqlParm("@parmNamePtkn",          SqlDbType.VarChar,  Constants.PARM_PUBLIC_TOKEN,  ParameterDirection.Input, 256));
          parms.Add(Database.SqlParm("@parmNamePatPerID",      SqlDbType.VarChar,  Constants.PARM_PAT_PER_ID,    ParameterDirection.Input, 256));
          parms.Add(Database.SqlParm("@requestingWhatInfo",    SqlDbType.TinyInt,  1,                            ParameterDirection.Input));
          parms.Add(Database.SqlParm("@individualRequest",     SqlDbType.Bit,      individualRequest,            ParameterDirection.Input));
          parms.Add(Database.SqlParm("@requestFromAuthor",     SqlDbType.Bit,      requestFromAuthor,            ParameterDirection.Input));
          parms.Add(Database.SqlParm("@massUpdateRowID",       SqlDbType.BigInt,   vMassRowUpdateID,             ParameterDirection.Input));
            
          var so = Entities.saveAndReturnJSONData (  connSpedmon
                                                   , log
                                                   , uInfo
                                                   , "1" /*saveType*/
                                                   , "N" /* validateRec */
                                                   , "" /* editDelReason */
                                                   , "" /* recID*/
                                                   , saveSproc
                                                   , @"An active request already exists"
                                                   , ref parms
                                                   , delegate () { });
          
          if (so.status == Return.RET_SUCCESS) {                             
            var personsIn = PatientInfoRequestsResponsesCommon.parsePatientInfoRequestToPersonsJSONToList(so.jsonData);
            /* Process all email requests */
            var personsOut = _emailRequests ( so.recordID, requesterName, requesterEmail, requesterPhone, personsIn);
            /* Take result of email requests and put in JSON for updating sent status */
            var sentToPersonsJSON  = PatientInfoRequestsResponsesCommon.parsePatientInfoRequestToPersonsListToJSON(personsOut);
            /* Update sent status */
            _updateSentStatus(connSpedmon,log,uInfo,clientID,sentToPersonsJSON,so.recordID.ToString());              
            /* Pass back updated stats on what got sent */
            so.jsonData = sentToPersonsJSON; 
          }          
          return so;
        }

        /***************************************************************************
         * saveNewIndividualRequest */
        /**
         **************************************************************************/
        public static ReturnSaveRecordWithJSONData saveNewIndividualRequest (
            SqlConnection connSpedmon
          , SqlConnection connUsers
          , DetailsLog    log
          , UserInfo      uInfo
          , string        clientID
          , string        patID
          , string        msgTxt
          , string        patPerIDs
          , string        sendEmail
          , string        sendText ) 
        {          
          var u              = Users.load (connUsers,log,uInfo,uInfo.useridStr);  /* Get calling user data (TODO: We can remove this once we include this in the persons list JSON) */                  
          var requestBaseUrl = MBA.HttpApplication.createLink (PatientInfoRequestsResponsesCommon.URL_REQUEST_FORM_PUBLIC_BASE);
          return _saveNewRequest(connSpedmon,log,uInfo,clientID,patID,msgTxt,patPerIDs,sendEmail,sendText, u.name, u.email, u.phone,true,true,requestBaseUrl,null);
        }

        /***************************************************************************
         * saveNewRequestFromMassUpdateRow */
        /**
         * Note: Called indirectly from background service
         **************************************************************************/
        public static ReturnSaveRecordWithJSONData saveNewRequestFromMassUpdateRow (
            SqlConnection connSpedmon          
          , DetailsLog    log
          , UserInfo      uInfo
          , string        clientID
          , string        patID
          , string        msgTxt
          , string        patPerIDs
          , string        sendEmail
          , string        sendText
          , string        requesterName
          , string        requesterEmail
          , string        requesterPhone
          , string        requestBaseUrl
          , long?         massUpdateRowID  ) 
        {          
          return _saveNewRequest( connSpedmon
                                , log
                                , uInfo
                                , clientID
                                , patID
                                , msgTxt
                                , patPerIDs
                                , sendEmail
                                , sendText
                                , requesterName
                                , requesterEmail
                                , requesterPhone
                                , false
                                , false
                                , requestBaseUrl                                
                                , massUpdateRowID );
        }

        /***************************************************************************
         * saveNewMassRequest */
        /**
         * This is the call that initiates the mass request
         **************************************************************************/
        public static ReturnSaveRecord saveNewMassRequest (
            SqlConnection connSpedmon          
          , DetailsLog    log
          , UserInfo      uInfo
          , string        clientID
          , string        dataSource
          , string        requesterName
          , string        requesterEmail
          , string        requesterPhone )
        {
          
          string saveSproc = "PATIENT_INFO_REQUESTS_RESPONSES_MASS_REQUEST_SAVE";
         
          var vClientID       = Validate.reqClientID    (uInfo,          clientID);
          var vDataSource     = Validate.reqInteger     (dataSource,     Messages.INVALID_DATA_SOURCE, true);
          var vRequesterName  = Validate.reqString      (requesterName,  @"Name is required");
          var vRequesterEmail = Validate.reqEmail       (requesterEmail, Messages.INVALID_EMAIL);
          var vRequesterPhone = Validate.optPhoneNumber (requesterPhone, Messages.INVALID_PHONE_NUMBER);
    
          var vRequestBaseUrl = MBA.HttpApplication.createLink (PatientInfoRequestsResponsesCommon.URL_REQUEST_FORM_PUBLIC_BASE);
            
          var parms = new List<SqlParameter>();

          parms.Add(Database.SqlParm("@clientID",          SqlDbType.BigInt,   vClientID,          ParameterDirection.Input));
          parms.Add(Database.SqlParm("@source",            SqlDbType.TinyInt,  vDataSource,        ParameterDirection.Input));                   
          parms.Add(Database.SqlParm("@requesterName",     SqlDbType.VarChar,  vRequesterName,     ParameterDirection.Input, 500));
          parms.Add(Database.SqlParm("@requesterEmail",    SqlDbType.VarChar,  vRequesterEmail,    ParameterDirection.Input, 256));
          parms.Add(Database.SqlParm("@requesterPhone",    SqlDbType.VarChar,  vRequesterPhone,    ParameterDirection.Input, 256));
          parms.Add(Database.SqlParm("@requestBaseUrl",    SqlDbType.VarChar,  vRequestBaseUrl,    ParameterDirection.Input, 1000));
            
          var so = Entities.save (  connSpedmon
                                   , log
                                   , uInfo
                                   , "1" /*saveType*/
                                   , "N" /* validateRec */
                                   , "" /* editDelReason */
                                   , "" /* recID*/
                                   , saveSproc
                                   , @"An active request already exists"
                                   , ref parms
                                   , delegate () { });
       
         return so;
        
        }
        
        /***************************************************************************
         * view */
        /**
         **************************************************************************/
        protected static ReturnDB view (
            SqlConnection connSpedmon
          , DetailsLog    log
          , UserInfo      uInfo
          , string        clientID
          , string        active
          , string        recID
          , int           recViewType
          , bool          pagedOrTop
          , string        idx
          , string        canEdit
          , defineCols    dc )
        {
            string viewUDF = "PATIENT_INFO_REQUESTS_RESPONSES_VIEW (@userID, @userGroup, @userRank, @clientID, @active, @recID)";

            long vClientID = Validate.reqClientID(uInfo, clientID);

            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

            return Entities.view (
                  connSpedmon
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
                , dc
            );
        }

        /***************************************************************************
         * viewObjects */
        /**
         **************************************************************************/
        public static ReturnObjects viewObjects(
              SqlConnection connSpedmon
            , DetailsLog    log
            , UserInfo      uInfo
            , bool          pageObjectList
            , string        pageOrder
            , string        idx
            , string        clientID
            , string        active
            , string        recID )
        {
            if (String.IsNullOrWhiteSpace(pageOrder))
            {
                pageOrder = PatientInfoRequestResponse.DEFAULT_PAGING_ORDER;
            }

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects (
                  connSpedmon
                , log
                , uInfo
                , typeof(PatientInfoRequestResponse)
                , pageObjectList
                , pageOrder
                , delegate
                {
                    return PatientInfoRequestsResponses.view (
                          connSpedmon
                        , log
                        , uInfo
                        , clientID
                        , active
                        , recID
                        , Entities.REC_VIEW_OBJECTS
                        , pageObjectList
                        , idx
                        , null
                        , dc
                    );
                }
            );
        }
    
        /***************************************************************************
         * viewTbl */
        /**
         * View patient info requests data table
         * 
         * @return ReturnDataTable
         ***************************************************************************/
        public static ReturnDataTable viewTbl (
              SqlConnection connSpedmon
            , DetailsLog    log
            , UserInfo      uInfo
            , bool          paged
            , string        pageNumber
            , string        clientID
            , string        active )
        {
            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("currentInfoRequestID as [Request ID]");
                ss.addDisplayColumn("patName as [Patient Name]", true);
                ss.addDisplayColumn("dobStr as [Date of Birth]");
                ss.addDisplayColumn("studentID as [Student ID]");
                ss.addDisplayColumn("currentInfoRequestSentOnStr as [Request Sent]");
                ss.addDisplayColumn("currentInfoRequestResponseReceivedOnStr as [Response Received]");
                ss.addDisplayColumn("insuranceCarrierName as [Insurance Carrier]");
                ss.addDisplayColumn("policyNumber as [Policy Number]");
                ss.addDisplayColumn("consentStr as [Consent Given]");
                ss.addDisplayColumn("responseApprovedStr as [Response Approved]");

                pageroworder = ss.pageRowOrder();
            };

            return Entities.viewTbl(
                connSpedmon,
                log,
                uInfo,
                paged,
                pageNumber,
                delegate
                {
                    return PatientInfoRequestsResponses.view (
                        connSpedmon,
                        log,
                        uInfo,
                        clientID,
                        active,
                        "", // recID
                        Entities.REC_VIEW_TBL,
                        paged,
                        pageNumber,
                        "N", // canEdit
                        dc);
                },
                "Patient Information Requests",
                Messages.CONFIDENTIAL);
        }
        
    }
}
