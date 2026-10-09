using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Script.Serialization;
using System.Collections.Specialized;

namespace Geo.ARIES
{
  
   /***************************************************************************
    * SchoolAndStudents */
   /**
    * Composite class for working with ARIES School and Student classes.
    * Since the student classes are dependent on the school classes and 
    * you can only get a list of students if a school code is passed we created
    * this composite class to work with the ARIES data.
    ***************************************************************************/  

    public class SchoolAndStudents
    {
      public School                school;
      public List<StudentProfile>  students;    
    }

   /***************************************************************************
    * SchoolsAndStudents */
   /**
    * Methods for working with the SchoolAndStudents composite class.
    * 
    ***************************************************************************/  
	
    public class SchoolsAndStudents 
    {      
     
      /***************************************************************************
       * getList */
      /**
       * Returns list of SchoolAndStudents
       * Use this methods for retrieving a single student
       ***************************************************************************/  
	
      public static List<SchoolAndStudents> getList (string server, string apiToken, string studentID)
      {
        List<SchoolAndStudents> schoolsAndStudents = new List<SchoolAndStudents>();
        
        /* No student id, get out */
        
        if (String.IsNullOrWhiteSpace(studentID)) return schoolsAndStudents;

        /* Clean up student id */

        studentID = studentID.Trim();

        /* Get schools */

        bool _requestSuccessfulSchools = false;
        var schools = Schools.getList(server,apiToken,out _requestSuccessfulSchools);
        
        /* If not successful return */

        if (!_requestSuccessfulSchools) return schoolsAndStudents;
                 
        /* For each school */

        foreach(var school in schools) {
                  
          /* Get all students at school that have studentID.  Should only be 1 per school that student is or was enrolled at. */

          var students = new List<Student>();
          bool _requestSuccessfulStudents = false;                   
          students = Students.getList(server,apiToken,school.SchoolCode, studentID, out _requestSuccessfulStudents);
        
          /* If the request failed continue*/

          if (!_requestSuccessfulStudents) continue;

          /* If none found continue*/

          if (students.Count == 0) continue;

          /* Otherwise */

          var schoolAndStudents      = new SchoolAndStudents();
          schoolAndStudents.school   = school;
          schoolAndStudents.students = new List<StudentProfile>();
                
          foreach (var student in students) {            
            var studentWithSupportingData = StudentProfiles.populate(server,apiToken,school.SchoolCode,student);
            schoolAndStudents.students.Add(studentWithSupportingData);
          }
          schoolsAndStudents.Add(schoolAndStudents);
        }
        return schoolsAndStudents;
      }

      /***************************************************************************
       * getList */
      /**
       * Returns list of SchoolAndStudents
       * Use this method for retrieving an entire student population
       ***************************************************************************/  
	
      public static List<SchoolAndStudents> getList (string server, string apiToken, bool excludeSchools = false, string schoolNamesToExclude = "", bool preview = false)
      {
        List<SchoolAndStudents> schoolsAndStudents = new List<SchoolAndStudents>();
        
        /* Get schools */

        bool _requestSuccessfulSchools = false;
        var schools = Schools.getList(server,apiToken,out _requestSuccessfulSchools);
        
        /* If not successful return */

        if (!_requestSuccessfulSchools) return schoolsAndStudents;
        
        /* Remove schools if applicable */

        if ((excludeSchools == true) && (!String.IsNullOrWhiteSpace(schoolNamesToExclude)))
        {
           var excludeSchoolNames = schoolNamesToExclude.Split(new char[]{'|'},StringSplitOptions.RemoveEmptyEntries);
           foreach (var excludeSchoolName in excludeSchoolNames) {
             schools.RemoveAll(x => String.Equals(x.Name.Trim().ToLower(),excludeSchoolName.Trim().ToLower()));           
           };
        }
         
        /* For each school */

        foreach(var school in schools) {
        
          var schoolAndStudents      = new SchoolAndStudents();
          schoolAndStudents.school   = school;
          schoolAndStudents.students = new List<StudentProfile>();
          
          var students = new List<Student>();

          bool _requestSuccessfulStudents = false;
          
          /* If this is not a preview then get all students at school */
          
          if (preview == false) { 
            students = Students.getList(server,apiToken,school.SchoolCode, out _requestSuccessfulStudents);
          }

          /* If this is a preview then get just the first 10 students at each school */
          
          else {
            students = Students.getList(server,apiToken,school.SchoolCode,1,10, out _requestSuccessfulStudents);
          }

          if (!_requestSuccessfulStudents) continue;

          foreach (var student in students) {
            
            var studentWithSupportingData = StudentProfiles.populate(server,apiToken,school.SchoolCode,student);
            schoolAndStudents.students.Add(studentWithSupportingData);
          }
          schoolsAndStudents.Add(schoolAndStudents);
        }
        return schoolsAndStudents;
      }
   }
}
