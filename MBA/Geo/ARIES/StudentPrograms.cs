using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Script.Serialization;
using Newtonsoft.Json;
using System.Collections.Specialized;

namespace Geo.ARIES
{
  /***************************************************************************
   * StudentProgram */
  /**
   * ARIES Student Program class
   * See : https://support.aeries.com/support/solutions/articles/14000113683-aeries-api-student-related-end-points#Student-Information
   ***************************************************************************/  
   public class StudentProgram
   {
     public string StudentID              { get; set; } 
	 public Object ExtendedProperties     { get; set; }  /* Contextual JSON based on program code */
	 public string ProgramCode            { get; set; }   /*  "144x" = Eval for SpeD "144" = SpED */
	 public string ProgramDescription     { get; set; } 
	 public string EligibilityEndDate     { get; set; } 
	 public string EligibilityStartDate   { get; set; } 
	 public string ParticipationEndDate   { get; set; } 
	 public string ParticipationStartDate { get; set; } 	 
   }

    /***************************************************************************
     * Students */
    /**
     * Methods for working with ARIES Students
     * 
     ***************************************************************************/  

    public class StudentPrograms 
    {

   	  /***************************************************************************
       * getList */
      /**
       * Returns list of StudentProgram
       ***************************************************************************/  
	
      public static List<StudentProgram> getList (string server, string apiToken, int schoolCode, string studentID, out bool requestSuccessful)
      {
        requestSuccessful = false;
        var studentPrograms = new List<StudentProgram>();
        string method = String.Format(@"schools/{0}/students/{1}/programs/",schoolCode,studentID);
        string responseJSON = "";
        
        if (Geo.ARIES.Common.RequestDataGet(server,apiToken,method,out responseJSON)) {
          try { 
            studentPrograms   = (List<StudentProgram>) JsonConvert.DeserializeObject <List<StudentProgram>> (responseJSON);
            requestSuccessful = true;
          } 
          catch {
            requestSuccessful = false;
            studentPrograms   = new List<StudentProgram>();
          }          
        }
        return studentPrograms;
      }
   }
}
