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
   * Student */
  /**
   * ARIES Student class
   * See : https://support.aeries.com/support/solutions/articles/14000113683-aeries-api-student-related-end-points#Student-Information
   ***************************************************************************/  

   public class Student
   {
      public string 	AddressVerified	{ get; set; }
      public string 	AttendanceProgramCodeAdditional1	{ get; set; }
      public string 	AttendanceProgramCodeAdditional2	{ get; set; }
      public string 	AttendanceProgramCodePrimary	{ get; set; }
      public DateTime? 	Birthdate	{ get; set; }
      public string 	CorrespondenceLanguageCode	{ get; set; }
      public string 	CounselorNumber	{ get; set; }
      public string 	StudentPersonalEmailAddress	{ get; set; }
      public string 	DistrictEnterDate	{ get; set; }
      public string 	EarlyWarningPoints	{ get; set; }
      public string 	EthnicityCode	{ get; set; }
      public string 	FamilyKey	{ get; set; }
      public string 	FirstName	{ get; set; }
      public string 	FirstNameAlias	{ get; set; }
      public string 	Grade	{ get; set; }
      public string 	HighSchedulingPeriod	{ get; set; }
      public string 	HomeLanguageCode	{ get; set; }
      public string 	HomePhone	{ get; set; }
      public string 	HomeRoomTeacherNumber	{ get; set; }
      public string 	InactiveStatusCode	{ get; set; }
      public string 	LanguageFluencyCode	{ get; set; }
      public string 	LastName	{ get; set; }
      public string 	LastNameAlias	{ get; set; }
      public string 	LockerNumber	{ get; set; }
      public string 	LowSchedulingPeriod	{ get; set; }
      public string 	MailingAddress	{ get; set; }
      public string 	MailingAddressCity	{ get; set; }
      public string 	MailingAddressState	{ get; set; }
      public string 	MailingAddressZipCode	{ get; set; }
      public string 	MailingAddressZipExt	{ get; set; }
      public string 	MiddleName	{ get; set; }
      public string 	MiddleNameAlias	{ get; set; } 
      public string 	NetworkLoginID	{ get; set; }
      public string 	NotificationPreferenceCode	{ get; set; }
      public string 	OldStudentID	{ get; set; }
      public string 	ParentEdLevelCode	{ get; set; }
      public string 	ParentEmailAddress	{ get; set; }
      public string 	ParentGuardianName	{ get; set; }
      public string 	StudentID	{ get; set; }
      public string 	RaceCode1	{ get; set; }
      public string 	RaceCode2	{ get; set; }
      public string 	RaceCode3	{ get; set; }
      public string 	RaceCode4	{ get; set; }
      public string 	RaceCode5	{ get; set; }
      public string 	ResidenceAddress	{ get; set; }
      public string 	ResidenceAddressCity	{ get; set; }
      public string 	ResidenceAddressState	{ get; set; }
      public string 	ResidenceAddressZipCode	{ get; set; }
      public string 	ResidenceAddressZipExt	{ get; set; }
      public int 	    SchoolCode	{ get; set; }
      public string 	SchoolEnterDate	{ get; set; }
      public string 	SchoolLeaveDate	{ get; set; }
      public string 	Gender	{ get; set; }
      public string 	StateStudentID	{ get; set; }
      public string 	StudentEmailAddress	{ get; set; }
      public string 	StudentMobilePhone	{ get; set; }
      public string 	StudentNumber	{ get; set; }
      public string 	Track	{ get; set; }
      public string 	UserCode1	{ get; set; }
      public string 	UserCode10	{ get; set; }
      public string 	UserCode11	{ get; set; }
      public string 	UserCode12	{ get; set; }
      public string 	UserCode13	{ get; set; }
      public string 	UserCode2	{ get; set; }
      public string 	UserCode3	{ get; set; }
      public string 	UserCode4	{ get; set; }
      public string 	UserCode5	{ get; set; }
      public string 	UserCode6	{ get; set; }
      public string 	UserCode7	{ get; set; }
      public string 	UserCode8	{ get; set; }
      public string 	UserCode9	{ get; set; }       
    }

    /***************************************************************************
     * Students */
    /**
     * Methods for working with ARIES Students
     * 
     ***************************************************************************/  

    public class Students 
    {
      /***************************************************************************
       * getList */
      /**
       * Returns list of Student
       ***************************************************************************/  
	  public static List<Student> getList (  string server
                                           , string apiToken
                                           , int   schoolCode
                                           , out bool requestSuccessful)
      {
        return getList(server,apiToken,schoolCode,"",null,null,out requestSuccessful);
      }
                                           
	  public static List<Student> getList (  string server
                                           , string apiToken
                                           , int   schoolCode
                                           , string studentID
                                           , out bool requestSuccessful)
      {
        return getList(server,apiToken,schoolCode,studentID,null,null,out requestSuccessful);
      }

      public static List<Student> getList (  string server
                                           , string apiToken
                                           , int    schoolCode                                           
                                           , int?   startingRecord
                                           , int?   endingRecord                                           
                                           , out bool requestSuccessful)
      {
        return getList(server,apiToken,schoolCode,"",startingRecord,endingRecord,out requestSuccessful);
      }
      
      private static List<Student> getList (   string server
                                             , string apiToken
                                             , int    schoolCode
                                             , string studentID 
                                             , int?   startingRecord
                                             , int?   endingRecord                                           
                                             , out bool requestSuccessful)
      {
        var students        = new List<Student>();
        requestSuccessful   = false;
        string method       = String.Format(@"schools/{0}/students/{1}",schoolCode,studentID);
        string responseJSON = "";
        if (Geo.ARIES.Common.RequestDataGet(server,apiToken,method,startingRecord,endingRecord,out responseJSON)) {
          try {
            students          = (List<Student>) JsonConvert.DeserializeObject <List<Student>> (responseJSON);
            requestSuccessful = true;
          } 
          catch {
            students          = new List<Student>();
            requestSuccessful = false;
          } 
        }         
        return students;
      }
   }
}
