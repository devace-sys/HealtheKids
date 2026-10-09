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
   * Term */
  /**
   * ARIES Term class
   * See : https://support.aeries.com/support/solutions/articles/14000113682-aeries-api-school-related-end-points#School-Terms 
   ***************************************************************************/  
	
   public class Term
   {
     public string TermCode { get; set; }
     public string TermDescription { get; set; }
     public DateTime StartDate { get; set; }
     public DateTime EndDate { get; set; }
   }

   /***************************************************************************
    * School*/
   /**
    * ARIES School Class
    * See : https://support.aeries.com/support/solutions/articles/14000113682-aeries-api-school-related-end-points#School-Information
    ***************************************************************************/  

   public class School
   {
        public int SchoolCode { get; set; }
        public string Name { get; set; }
        public string InactiveStatusCode { get; set; }
        public string Address { get; set; }
        public string AddressCity { get; set; }
        public string AddressState { get; set; }
        public string AddressZipCode { get; set; }
        public string AddressZipExt { get; set; }
        public bool DoNotReport { get; set; }
        public string StateCountyID { get; set; }
        public string StateDistrictID { get; set; }
        public string StateSchoolID { get; set; }
        public int LowGradeLevel { get; set; }
        public int HighGradeLevel { get; set; }
        public Term[] Terms { get; set; }
        public string PrincipalName { get; set; }
        public string PrincipalEmailAddress { get; set; }
        public int AttendancePeriod { get; set; }
        public int Tracks { get; set; }
        public string ScheduleType { get; set; }
        public string SessionType { get; set; }
        public string AttendanceType { get; set; }
        public string AttendanceReporting { get; set; }
        public string ScheduleBasis { get; set; }
    }

  /***************************************************************************
   * Schools */
  /**
   * Methods for getting ARIES schools
   *
   ***************************************************************************/  
  
    public class Schools 
    {
      
      /***************************************************************************
       * getList */
      /**
       * Returns list of School
       ***************************************************************************/  

      public static List<School> getList (string server, string apiToken, out bool requestSuccessful)
      {
        var schools         = new List<School>();
        requestSuccessful   = false;
        string method       = @"schools";

        string responseJSON = "";

        if (Geo.ARIES.Common.RequestDataGet(server,apiToken,method,out responseJSON)) {
          try { 
            schools           = (List<School>) JsonConvert.DeserializeObject <List<School>> (responseJSON);
            requestSuccessful = true;
          } 
          catch {
            schools           = new List<School>();
            requestSuccessful = false;
          }
        }
        return schools;
      }
   }
}
