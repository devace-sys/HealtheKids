using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Script.Serialization;
using System.Collections.Specialized;

namespace Geo.ARIES
{
   /***************************************************************************
    * StudentProfile */
   /**
    * Composite class to work with ARIES data       
    ***************************************************************************/  
    public class StudentProfile
    {  
        public Student student                       { get; set; }
        public List<StudentProgram> studentPrograms  { get; set; }
        public List<StudentContact> studentContacts  { get; set; }
        public bool requestSuccessfulStudentPrograms { get; set; }
        public bool requestSuccessfulStudentContacts { get; set; }
        public int  firstIdxOfSpEdProgram            { get; set; }
        public int  firstIdxOfPrimaryContact         { get; set; }
        public string studentIsSpEd           { get; set; }
        public string primaryContactFirstName { get; set; }
        public string primaryContactLastName  { get; set; }
        public string primaryContactEmail     { get; set; }
        public string primaryContactPhone     { get; set; }
    
    }

	
   /***************************************************************************
    * StudentProfiles */
   /**
    * Methods for working with the StudentProfile composite class.
    ***************************************************************************/  
	
    public class StudentProfiles
    {
      
        /***************************************************************************
         * determineIfStudentIsInSpEd */
        /**
         * 
         *************************************************************************/ 
        private static void determineIfStudentIsInSpEd (
            bool requestSuccessfulStudentPrograms
          , int  firstIdxOfSpEdProgram 
          , out string studentIsSpEd  )
        {
          /* Determine if the student is in SpEd (they will have a program with code "144" */
         
          studentIsSpEd = "N";
          if (requestSuccessfulStudentPrograms == false) return;
          if (firstIdxOfSpEdProgram == -1)               return;
          studentIsSpEd = "Y";
          return;
        }

       /***************************************************************************
        * determinePrimaryContactValues */
       /**
        * 
        *************************************************************************/ 
        private static void determinePrimaryContactValues (
               string               parentGuardianName
             , string               parentEmailAddress            
             , bool                 requestSuccessfulStudentContacts
             , int                  firstIdxOfPrimaryContact
             , List<StudentContact> studentContacts
             
             , out string primaryContactFirstName
             , out string primaryContactLastName
             , out string primaryContactEmail
             , out string primaryContactPhone )
        {
          primaryContactFirstName = "";
          primaryContactLastName  = "";
          primaryContactEmail     = "";
          primaryContactPhone     = "";
          
          bool useFallBack = false;
              
          /* If we have access to the student contacts end point */  
          
          if (requestSuccessfulStudentContacts == true) 
          {
                
            /* And a primary contact is listed */

            if (firstIdxOfPrimaryContact != -1) 
            {
              
              primaryContactFirstName = studentContacts[firstIdxOfPrimaryContact].FirstName;
              primaryContactLastName  = studentContacts[firstIdxOfPrimaryContact].LastName;
              primaryContactEmail     = studentContacts[firstIdxOfPrimaryContact].EmailAddress;
              primaryContactPhone     = studentContacts[firstIdxOfPrimaryContact].CellPhone;
              
              /* If no cell try home phone */
              
              if (String.IsNullOrWhiteSpace(primaryContactPhone)) {
                primaryContactPhone = studentContacts[firstIdxOfPrimaryContact].HomePhone;
              }

            }
            
            /* No primary contact listed, fall back  */
            
            else 
            {
              useFallBack = true;
            }
          
          }  /* We have access to student contacts */
          
          else
          {
            useFallBack = true;
          } /* No access to student contacts*/

          /* If we have to use the fall back values */

          if (useFallBack == true)
          {
            /* Parse fall back values */

            string[] pgNameParts = parentGuardianName.Split(new char[]{' '});

            string pgFirstName = @"";
            string pgLastName  = @"";

            if (pgNameParts.Length == 1) {
              pgFirstName = pgNameParts[0];
              pgLastName  = "";
            }
            else if (pgNameParts.Length == 2) {
              pgFirstName = pgNameParts[0];
              pgLastName  = pgNameParts[1];
            }
            else {
              pgFirstName = @"";
              pgLastName  = @"";
            }      

            primaryContactFirstName = pgFirstName;
            primaryContactLastName  = pgLastName;
            primaryContactEmail     = parentEmailAddress;
            primaryContactPhone     = "";

          } /* Using fallback*/
          return;
       }

      /***************************************************************************
       * populate */
      /**
       * Uses schoolCode and student to populate profile data and returns StudentProfile
       ***************************************************************************/  
	
      public static StudentProfile populate (string server, string apiToken, int schoolCode, Student student)
      {
            
          var so = new StudentProfile();
          so.student = student;

          bool _requestSuccessfulStudentPrograms = false;
          int  _firstIdxOfSpEdProgram            = -1;
            
          /* Get student programs */

          so.studentPrograms = StudentPrograms.getList(server,apiToken,schoolCode,student.StudentID, out _requestSuccessfulStudentPrograms);
          so.requestSuccessfulStudentPrograms = _requestSuccessfulStudentPrograms;          
         
          /* Find first spEd program */
          
          if (_requestSuccessfulStudentPrograms) { 
            _firstIdxOfSpEdProgram = so.studentPrograms.FindIndex(x => String.Equals(x.ProgramCode.Trim().ToLower(),"144"));
          }         
          so.firstIdxOfSpEdProgram = _firstIdxOfSpEdProgram;

          /* Determine if student is SpEd */

          string _studentIsSpEd = "N";
          determineIfStudentIsInSpEd(_requestSuccessfulStudentPrograms, _firstIdxOfSpEdProgram, out _studentIsSpEd);          
          so.studentIsSpEd = _studentIsSpEd;
            
          /* Get student contacts */

          bool _requestSuccessfulStudentContacts = false;
          int  _firstIdxOfPrimaryContact         = -1;
          so.studentContacts = StudentContacts.getList(server,apiToken,schoolCode,student.StudentID, out _requestSuccessfulStudentContacts);
          so.requestSuccessfulStudentContacts = _requestSuccessfulStudentContacts;

          /* Find first primary contact using ARIES dedicated field */                                

          if (_requestSuccessfulStudentContacts) {
            _firstIdxOfPrimaryContact = so.studentContacts.FindIndex(x => ( x.identifiedAsPrimaryContact == true ));
          }            
          so.firstIdxOfPrimaryContact = _firstIdxOfPrimaryContact;
            
          /* Since not all districts use the dedicated field we need to peform additional tests to determine
           * the primary contact.
           */

          string _primaryContactFirstName = "";
          string _primaryContactLastName  = "";
          string _primaryContactEmail     = "";
          string _primaryContactPhone     = "";

          determinePrimaryContactValues (
                student.ParentGuardianName
              , student.ParentEmailAddress
              , _requestSuccessfulStudentContacts
              , _firstIdxOfPrimaryContact
              , so.studentContacts
              , out _primaryContactFirstName
              , out _primaryContactLastName
              , out _primaryContactEmail
              , out _primaryContactPhone
          );

          so.primaryContactFirstName = _primaryContactFirstName;
          so.primaryContactLastName  = _primaryContactLastName;
          so.primaryContactEmail     = _primaryContactEmail;
          so.primaryContactPhone     = _primaryContactPhone;
            
          return so;
      }
      
   }
}
