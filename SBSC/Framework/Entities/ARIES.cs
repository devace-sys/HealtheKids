using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;
using Geo.ARIES;

namespace Spedmon
{
    	
   /***************************************************************************
    * ARIES */
   /**
    * Static methods to work with ARIES api using stored client api data
    ***************************************************************************/
    
   public class ARIES
   {
      /***************************************************************************
        * Tool Page URLS */
       /**
        * 
        *************************************************************************/
       
      public static string URL_CODE_SET_LOOKUP (string amd, string clientID, string server, string apiToken)
      {
        return MBA.HttpApplication.createLink (@"user_all_aries_api_code_set_lookup.aspx"
                                               , true
                                               , new NameValue (Spedmon.Constants.PARM_APP_MODE,  amd)
                                               , new NameValue (Spedmon.Constants.PARM_CLIENT_ID, clientID)
                                               , new NameValue (Spedmon.Constants.PARM_API_URL,   server)
                                               , new NameValue (Spedmon.Constants.PARM_API_TOKEN, apiToken));
      }

      public static string URL_SCHOOLS (string amd, string clientID, string server, string apiToken, string schoolCode)
      {
        return MBA.HttpApplication.createLink (@"user_all_aries_api_site_lookup.aspx"
                                               , true
                                               , new NameValue (Spedmon.Constants.PARM_APP_MODE,  amd)
                                               , new NameValue (Spedmon.Constants.PARM_CLIENT_ID, clientID)
                                               , new NameValue (Spedmon.Constants.PARM_API_URL,   server)
                                               , new NameValue (Spedmon.Constants.PARM_API_TOKEN, apiToken)
                                               , new NameValue (Geo.ARIES.Common.PARM_NAME_ARIES_SCHOOL_CODE, schoolCode)
                                               );
      }

      public static string URL_STUDENT_STUDENTS_AT_SCHOOL  (string amd, string clientID, string server, string apiToken, string schoolCode)
      {
        return MBA.HttpApplication.createLink ( @"user_all_aries_api_student_students_lookup.aspx"
                                               , true
                                               , new NameValue(Spedmon.Constants.PARM_APP_MODE,              amd)
                                               , new NameValue(Spedmon.Constants.PARM_CLIENT_ID,             clientID)
                                               , new NameValue(Spedmon.Constants.PARM_API_URL,               server)
                                               , new NameValue(Spedmon.Constants.PARM_API_TOKEN,             apiToken)                                              
                                               , new NameValue(Geo.ARIES.Common.PARM_NAME_ARIES_SCHOOL_CODE, schoolCode)
                                              );
      
      }
      
      public static string URL_STUDENT_PROGRAMS = @"user_all_aries_api_student_programs_lookup.aspx";

      public static string URL_STUDENT_PROGRAMS_AT_SCHOOL  (string amd, string clientID, string server, string apiToken, string schoolCode)
      {
        return MBA.HttpApplication.createLink ( URL_STUDENT_PROGRAMS
                                               , true
                                               , new NameValue(Spedmon.Constants.PARM_APP_MODE,              amd)
                                               , new NameValue(Spedmon.Constants.PARM_CLIENT_ID,             clientID)
                                               , new NameValue(Spedmon.Constants.PARM_API_URL,               server)
                                               , new NameValue(Spedmon.Constants.PARM_API_TOKEN,             apiToken)                                              
                                               , new NameValue(Geo.ARIES.Common.PARM_NAME_ARIES_SCHOOL_CODE, schoolCode)
                                              );
      
      }
      public static string URL_STUDENT_PROGRAMS_FOR_STUDENT  (string amd, string clientID, string server, string apiToken, string studentID)
      {
        return MBA.HttpApplication.createLink ( @"user_all_aries_api_student_programs_lookup.aspx"
                                               , true
                                               , new NameValue(Spedmon.Constants.PARM_APP_MODE,              amd)
                                               , new NameValue(Spedmon.Constants.PARM_CLIENT_ID,             clientID)
                                               , new NameValue(Spedmon.Constants.PARM_API_URL,               server)
                                               , new NameValue(Spedmon.Constants.PARM_API_TOKEN,             apiToken)                                              
                                               , new NameValue(Geo.ARIES.Common.PARM_NAME_ARIES_STUDENT_ID,  studentID)
                                              );
      
      }
      public static string URL_STUDENT_CONTACTS = @"user_all_aries_api_student_contacts_lookup.aspx";

      public static string URL_STUDENT_CONTACTS_AT_SCHOOL  (string amd, string clientID, string server, string apiToken, string schoolCode)
      {
        return MBA.HttpApplication.createLink ( URL_STUDENT_CONTACTS
                                               , true
                                               , new NameValue(Spedmon.Constants.PARM_APP_MODE,              amd)
                                               , new NameValue(Spedmon.Constants.PARM_CLIENT_ID,             clientID)
                                               , new NameValue(Spedmon.Constants.PARM_API_URL,               server)
                                               , new NameValue(Spedmon.Constants.PARM_API_TOKEN,             apiToken)                                              
                                               , new NameValue(Geo.ARIES.Common.PARM_NAME_ARIES_SCHOOL_CODE, schoolCode)
                                              );
      
      }
      public static string URL_STUDENT_CONTACTS_FOR_STUDENT  (string amd, string clientID, string server, string apiToken, string studentID)
      {
        return MBA.HttpApplication.createLink ( URL_STUDENT_CONTACTS
                                               , true
                                               , new NameValue(Spedmon.Constants.PARM_APP_MODE,              amd)
                                               , new NameValue(Spedmon.Constants.PARM_CLIENT_ID,             clientID)
                                               , new NameValue(Spedmon.Constants.PARM_API_URL,               server)
                                               , new NameValue(Spedmon.Constants.PARM_API_TOKEN,             apiToken)                                              
                                               , new NameValue(Geo.ARIES.Common.PARM_NAME_ARIES_STUDENT_ID,  studentID)
                                              );
      
      }

      public static string URL_STUDENT_PROFILES_LOOKUP (string amd, string clientID, string server, string apiToken, string schoolCode)
      {
            return MBA.HttpApplication.createLink ( @"user_all_aries_api_student_lookup.aspx"
                                                    , true
                                                    , new NameValue(Spedmon.Constants.PARM_APP_MODE,              amd)
                                                    , new NameValue(Spedmon.Constants.PARM_CLIENT_ID,             clientID)
                                                    , new NameValue(Spedmon.Constants.PARM_API_URL,               server)
                                                    , new NameValue(Spedmon.Constants.PARM_API_TOKEN,             apiToken)                                                    
                                                    , new NameValue(Geo.ARIES.Common.PARM_NAME_ARIES_SCHOOL_CODE, schoolCode)
                                                  );
       }

       /***************************************************************************
        * viewSchoolsAndStudents */
       /**
        * Entry point for generating export
        *************************************************************************/
 
        public static List<Geo.ARIES.SchoolAndStudents> viewSchoolsAndStudents (ClientStudentInformationSystem sis, bool excludeSchoolsInSchoolNamesToExclude = false)
        {          
          List<Geo.ARIES.SchoolAndStudents> schoolsAndStudents;                 
          try {                   
            if (sis.enabled == true) { 
              schoolsAndStudents = Geo.ARIES.SchoolsAndStudents.getList(sis.apiUrl, sis.apiToken, "", excludeSchoolsInSchoolNamesToExclude, sis.schoolNamesToExclude);
            } 
            else {
              schoolsAndStudents = new List<Geo.ARIES.SchoolAndStudents>();
            }
          } 
          catch {
            schoolsAndStudents = new List<Geo.ARIES.SchoolAndStudents>();
          }
          return schoolsAndStudents;
        } 

       /***************************************************************************
        * viewClients */
       /**
        * 
        *************************************************************************/ 
        public static List<ClientStudentInformationSystem> viewClients (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string clientID = "", string enabled = "Y")
        {          
          return ClientStudentInformationSystems.viewList(connSpedmon,log,uInfo,"Y",clientID,StudentInformationSystems.ARIES,enabled);
        }

       /***************************************************************************
        * generateExportFileContentLine */
       /**
        * 
        *************************************************************************/ 
        
        protected static string generateExportFileContentLine (           
           string lastName
         , string firstName
         , string middleName                    
         , string preferredNickname
         , string studentID
         , string grade
         , string attendanceTrackName
         , string ssid
         , string cdsCode
         , string schoolName
         , string studentStreetAddress1
         , string studentStreetAddress2
         , string studentCity
         , string studentZip5
         , string dateOfBirth
         , string gender
         , string isSpecialEd
         , string primaryContactFirstName
         , string primaryContactLastName
         , string primaryContactEmail
         , string primaryContactPhone
         , string teacherCounselorName
         , string DELIMETER )       
        {      
            /* Return empty string if fields that we expect to have values
             * are not provided.
             */

            if (String.IsNullOrWhiteSpace(lastName))  return String.Empty;
            if (String.IsNullOrWhiteSpace(firstName)) return String.Empty;
            if (String.IsNullOrEmpty(dateOfBirth))    return String.Empty;

            /* Otherwise build line */

            StringBuilder sb = new StringBuilder();

            sb.Append(CSV.createCell(DELIMETER,lastName));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,firstName));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,middleName));                    
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,preferredNickname));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,studentID));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,grade));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,attendanceTrackName));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,ssid));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,cdsCode));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,schoolName));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,studentStreetAddress1));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,studentStreetAddress2));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,studentCity));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,studentZip5));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,dateOfBirth));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,gender));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,isSpecialEd));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,primaryContactFirstName));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,primaryContactLastName));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,primaryContactEmail));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,primaryContactPhone));
            sb.Append(DELIMETER);
            sb.Append(CSV.createCell(DELIMETER,teacherCounselorName));

            sb.AppendLine();
            
            return sb.ToString();            
        }
       

        /***************************************************************************
         * generateExportFileContent */
        /**
         * 
         *************************************************************************/ 

        public static bool generateExportFileContent (
              ref List<Geo.ARIES.SchoolAndStudents> schoolsAndStudents
            , out string        statusMsg
            , out StringBuilder sb            
            , string DELIMETER = CSV.DELIMITER_COMMA)
        {            
          
          statusMsg      = @"OK"; 
          sb             = new StringBuilder();
          bool retStatus = true;
          
          try 
          { 
          
            /* Generate header row */

            sb.Append( generateExportFileContentLine (
               "lastName"
             , "firstName"
             , "middleName"
             , "preferredNickname"
             , "studentID"
             , "grade"
             , "attendanceTrackName"
             , "ssid"
             , "cdsCode"
             , "schoolName"
             , "studentStreetAddress1"
             , "studentStreetAddress2"
             , "studentCity"
             , "studentZip5"
             , "dateOfBirth"
             , "gender"
             , "isSpecialEd"
             , "primaryContactFirstName"
             , "primaryContactLastName"
             , "primaryContactEmail"
             , "primaryContactPhone"
             , "teacherCounselorName"
             , DELIMETER)
          );

          /* For each school */

          foreach (var schoolAndStudents in schoolsAndStudents) {

            /* Create complete CDS code */

            string cdsCode = schoolAndStudents.school.StateCountyID 
                           + schoolAndStudents.school.StateDistrictID 
                           + schoolAndStudents.school.StateSchoolID; 

            /* Get school name */

            string schoolName = schoolAndStudents.school.Name;

            /* For each student at the school */

            foreach(var studentProfile in schoolAndStudents.studentProfiles) {                               
                            
              /* If the student is inactive (blank is active) then continue to next */
              
              if (studentProfile.student.InactiveStatusCode != "") continue;
                            
              /* If the DOB is provided format it */

              string studentDOB = @"";
                    
              if (studentProfile.student.Birthdate.HasValue) {
                studentDOB = studentProfile.student.Birthdate.Value.ToShortDateString();
              }
              
              /* Generate line */

              sb.Append ( generateExportFileContentLine (
                           studentProfile.student.LastName
                          , studentProfile.student.FirstName
                          , studentProfile.student.MiddleName
                          , studentProfile.student.FirstNameAlias
                          , studentProfile.student.StudentID
                          , studentProfile.student.Grade
                          , studentProfile.student.Track
                          , studentProfile.student.StateStudentID
                          , cdsCode
                          , schoolName
                          , studentProfile.student.ResidenceAddress
                          , ""
                          , studentProfile.student.ResidenceAddressCity
                          , studentProfile.student.ResidenceAddressZipCode
                          , studentDOB
                          , studentProfile.student.Gender                         
                          , studentProfile.studentIsSpEd
                          , studentProfile.primaryContactFirstName
                          , studentProfile.primaryContactLastName
                          , studentProfile.primaryContactEmail
                          , studentProfile.primaryContactPhone
                          , ""
                          , DELIMETER));
                } /* Students */
            } /* School*/
          
            retStatus = true;
            statusMsg = @"OK";
          }
          catch (Exception e)
          {
             retStatus = false;
             statusMsg = e.Message;
          }
          return retStatus;
        }        

    }
}
