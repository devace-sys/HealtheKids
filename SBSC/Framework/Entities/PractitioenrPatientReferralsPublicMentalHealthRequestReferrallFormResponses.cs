using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /**************************************************************************
     * PractitioenrPatientReferralsPublicMentalHealthRequestReferrallFormResponse */
    /**
     **************************************************************************/
    
	public class PractitioenrPatientReferralsPublicMentalHealthRequestReferrallFormResponse : Entity

    {
        
	   public long          clientID;
       public string        clientName;
       
       public long          patID;
       public string        patName;
  
       public string        patientFirstName;
       public string        patientLastName;
	   public DateTime      patientDOB;
	   public string        patientDOBStr;

       public string        studentID;
       public string        teacherName;
	   public long          referralPriority;
	   public string        referralDetailNote;
	   
	   public bool		    responderIsParentGuardian;

	   public string 	    responderFirstName;
	   public string	    responderLastName;
	   public string 	    responderEmail;
	   public string	    responderPhone;
          
       public string        responderUserIP;
       public string        responderUserAgent;
     
    }

    /***************************************************************************
     * PractitioenrPatientReferralsPublicMentalHealthRequestReferrallFormResponses */
    /**
     *
     **************************************************************************/
	 
    public class PractitioenrPatientReferralsPublicMentalHealthRequestReferrallFormResponses : Entities
    {       
        
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
                                                         , string teacherName
                                                         , string referralPriority
                                                         , string referralDetailNote
                                                         , string responderIsParentGuardian
                                                         , string responderRelationship
                                                         , string responderFirstName
                                                         , string responderLastName
                                                         , string responderEmail
                                                         , string responderPhone) 

        {
            ReturnActionRequest so = new ReturnActionRequest();

            string actionRequestSproc = "PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORM_RESPONSES_SAVE_FROM_PUBLIC_FORM";
            
            var vPtkn                           = Validate.reqString (ptkn, @"Invalid token");                                    

            var vStudentFirstName               = Validate.optString(studentFirstName, "Invalid name");
            var vStudentLastName                = Validate.optString(studentLastName, "Invalid name");
            var vStudentDOB                     = Validate.optDate(studentDOB,"Invalid DOB");
            var vStudentID                      = Validate.optString(studentID, "Invalid ID");
            var vTeacherName                    = Validate.optString (teacherName, "Invalid teacher name");
            var vReferralPriority               = Validate.reqInteger (referralPriority, "Invalid referral priority");
            var vReferralDetailNote             = Validate.optString  (referralDetailNote, "Invalid detail note");
            var vResponderIsParentGuardian      = Validate.reqFlag    (responderIsParentGuardian, @"Invalid responderIsParentGuardian value", true);
            var vResponderRelationship          = Validate.optString  (responderRelationship, "Invalid relationship");
            var vResponderFirstName             = Validate.optString  (responderFirstName, "Invalid name");
            var vResponderLastName              = Validate.optString  (responderLastName, "Invalid name");
            var vResponderEmail                 = Validate.optEmail   (responderEmail, "Invalid Email");
            var vResponderPhone                 = Validate.optPhoneNumber(responderPhone, "Invalid Phone Number");

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
              vTeacherName               = System.Net.WebUtility.HtmlEncode(vTeacherName);
              vReferralDetailNote        = System.Net.WebUtility.HtmlEncode(vReferralDetailNote);
              vResponderRelationship     = System.Net.WebUtility.HtmlEncode(vResponderRelationship);
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
              parms.Add(Database.SqlParm("@teacherName",                           SqlDbType.VarChar,  vTeacherName,        ParameterDirection.Input, 80));      

              parms.Add(Database.SqlParm("@referralPriority",                      SqlDbType.TinyInt,  vReferralPriority,   ParameterDirection.Input));
              parms.Add(Database.SqlParm("@referralDetailNote",                    SqlDbType.VarChar,  vReferralDetailNote, ParameterDirection.Input, 8000));
              
              parms.Add(Database.SqlParm("@responderIsParentGuardian",               SqlDbType.Bit,      vResponderIsParentGuardian,                ParameterDirection.Input));
              parms.Add(Database.SqlParm("@responderRelationship",                   SqlDbType.NVarChar, vResponderRelationship,ParameterDirection.Input, 20));
              parms.Add(Database.SqlParm("@responderFirstName",                      SqlDbType.NVarChar, vResponderFirstName,   ParameterDirection.Input, 50));
              parms.Add(Database.SqlParm("@responderLastName",                       SqlDbType.NVarChar, vResponderLastName,    ParameterDirection.Input, 50));
              parms.Add(Database.SqlParm("@responderEmail",                          SqlDbType.VarChar,  vResponderEmail,       ParameterDirection.Input, 255));
              parms.Add(Database.SqlParm("@responderPhone",                          SqlDbType.VarChar,  vResponderPhone,       ParameterDirection.Input, 255));

              ReturnDB rd = Database.execSproc(connSpedmon, log, actionRequestSproc, parms);     
            }

            /* We dont want non users seeing internal details so return a very generic message */

            catch
            {
                so.message = @"A problem has occurred please try your request again";
                so.status = Return.RET_WARNING;
            }

            return so;
        }

    }
}
