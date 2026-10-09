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
   * StudentContact */
  /**
   * ARIES Student Contact class
   * See : https://support.aeries.com/support/solutions/articles/14000113683-aeries-api-student-related-end-points#Contacts-%E2%86%91
   ***************************************************************************/  
   
   public class StudentContact
   {
        public string   AccessToPortal                          { get; set; }
        public string   AdditionalCommunicationTypeCode1        { get; set; }
        public string   AdditionalCommunicationTypeCode2        { get; set; }
        public string   AdditionalCommunicationTypeCode3        { get; set; }
        public string   AdditionalCommunicationTypeCode4        { get; set; }
        public string   AdditionalCommunicationDetail1          { get; set; }
        public string   AdditionalCommunicationDetail2          { get; set; }
        public string   AdditionalCommunicationDetail3          { get; set; }
        public string   AdditionalCommunicationDetail4          { get; set; }
        public string   Address                                 { get; set; }
        public string   AddressCity                             { get; set; }
        public string   AddressState                            { get; set; }
        public string   AddressZipCode                          { get; set; }
        public string   AddressZipExt                           { get; set; }
        public string   AddressTypeCode                         { get; set; }
        public string   AddressVerificationDate  { get; set; }
        public string   AdministrativeLockCode   { get; set; }
        public string   AttendanceNotification   { get; set; }
        public string   Birthdate    { get; set; }
        public string   CellPhone    { get; set; }
        public string   Comments     { get; set; }
        public string   ContactOrder                    { get; set; }
        public string   CorrespondenceLanguageCode      { get; set; }
        public string   EducationalRightsHolder         { get; set; }
        public string   EmailAddress                    { get; set; }
        public string   EmployerLocation                { get; set; }
        public string   EmployerName                    { get; set; }
        public string   EnrolledTheStudentIndicator     { get; set; }
        public string   FingerprintStatusCode           { get; set; }
        public string   FingerprintDate                 { get; set; }
        public string   FirstName                       { get; set; }
        public string   HomePhone                       { get; set; }
        public string   LastName                        { get; set; }
        public string   LivesWithStudentIndicator       { get; set; }
        public string   MailingName  { get; set; }
        public string   MailTagCode  { get; set; }
        public string   MiddleName   { get; set; }
        public string   MilitaryBranchCode   { get; set; }
        public string   MilitaryRankCode     { get; set; }
        public string   MilitaryStatusCode   { get; set; }
        public string   MilitarySupervisorName   { get; set; }
        public string   MilitarySupervisorPhone  { get; set; }
        public string   MilitaryUserFieldCode1   { get; set; }
        public string   MilitaryUserFieldCode2   { get; set; }
        public string   MilitaryUserFieldCode3   { get; set; }
        public string   MilitaryUserFieldCode4   { get; set; }
        public string   MilitaryUserFieldCode5   { get; set; }
        public string   MiscCode                        { get; set; }
        public string   NamePrefix                      { get; set; }
        public string   NameSuffix                      { get; set; }
        public string   NotificationPreferenceCode      { get; set; }
        public string   Occupation                      { get; set; }
        public string   Pager                           { get; set; }
        public string   PortalAccountID                 { get; set; }
        public string   PrimaryContact                  { get; set; }
        public string   PrimaryContact1Field            { get; set; }
        public string   PrimaryContact2Field            { get; set; }
        public string   PrimaryContact1Description      { get; set; }
        public string   PrimaryContact2Description      { get; set; }
        public bool     RedFlag                         { get; set; }
        public string   RelationshipToStudentCode       { get; set; }
        public string   RecordAddedDate                 { get; set; }
        public string   RecordType                      { get; set; }
        public string   SchoolCode                      { get; set; }
        public string   SequenceNumber                  { get; set; }
        public string   StudentID                       { get; set; }
        public string   WorkPhone                       { get; set; }
        public string   WorkPhoneExt                    { get; set; }
        public string   TuberculosisTestStatusCode      { get; set; }
        public string   TuberculosisTestExpirationDate  { get; set; }
        public string   UserCode1    { get; set; }
        public string   UserCode2    { get; set; }
        public string   UserCode3    { get; set; }
        public string   UserCode4    { get; set; }
        public string   UserCode5    { get; set; }
        public string   UserCode6    { get; set; }
        public string   UserCode7    { get; set; }
        public string   UserCode8    { get; set; }

        /* Used for identifying primary contact */

        public bool hasPrimaryContactFlag             = false;
        public bool hasRelationshipTypeParentGuardian = false;
        public bool hasNotificationPreferenceGenOrEme = false;
        public bool hasRecordTypeParentGuardian1      = false;
        //public bool hasRecordTypeParentGuardian2      = false;

        public bool identifiedAsPrimaryContact        = false;
        
   }

    /***************************************************************************
     * StudentContacts */
    /**
     * Methods for working with ARIES Student Contacts
     * 
     ***************************************************************************/  

    public class StudentContacts
    {

      public static string TABLE_NAME = @"Contacts";      

      /***************************************************************************
       * getCodeSetListRecordTypes */
      /**
       * Returns list of Aries Codes for Contacts.Misc (record types)
       * The name/values for this code set appear to be defined by client and they 
       * are not Aries standard code values.  Therefore we are attempting to find 
       * the codes that match to the description.
       ***************************************************************************/  
           
      public static List<AriesCode> getCodeSetListRecordTypes (string server, string apiToken, out bool requestSuccessful, out bool hasData)
      { 
        return ARIES.Common.GetCodeSetList(server,apiToken,TABLE_NAME,"MiscCode",out requestSuccessful, out hasData);
      }

      /***************************************************************************
       * getList */
      /**
       * Returns list of StudentContact
       *  Note: {SchoolCode} is ignored when {StudentID} is provided. 
       *  Any value can be used such as {000}
       ***************************************************************************/  
      public static List<StudentContact> getList (string server, string apiToken, int schoolCode, string studentID, out bool requestSuccessful)
      {        
        var studentContacts = new List<StudentContact>();
        requestSuccessful = false;
        string method = String.Format(@"schools/{0}/contacts/{1}/",schoolCode,studentID);
        string responseJSON = "";
        
        if (Geo.ARIES.Common.RequestDataGet(server,apiToken,method,out responseJSON)) {
          try { 

            studentContacts   = (List<StudentContact>) JsonConvert.DeserializeObject <List<StudentContact>> (responseJSON);            
            requestSuccessful = true;
          }
          catch {
            requestSuccessful = false;
            studentContacts   = new List<StudentContact>();
          }
          
          /* If the request was succesful we need to identify key elements that will help in determining the primary contact  */

          if (requestSuccessful == true) {
              
              int _studentContactIdx = 0;

              foreach (var studentContact in studentContacts) {
              
                /* Has ARIES flag for primary contact */

                if (studentContact.PrimaryContact.ToLower().Trim().Equals("y") == true) { 
                  studentContacts[_studentContactIdx].hasPrimaryContactFlag = true;
                }

                /* Has ARIES code for relationship to student parent/guardian */

                if ((studentContact.RelationshipToStudentCode  == "10") || (studentContact.RelationshipToStudentCode  == "11") || (studentContact.RelationshipToStudentCode  == "21")) {
                  studentContacts[_studentContactIdx].hasRelationshipTypeParentGuardian = true;
                }
              
                /* Has ARIES code for general and emergency announcements */

                if (studentContact.NotificationPreferenceCode == "1") {
                  studentContacts[_studentContactIdx].hasNotificationPreferenceGenOrEme = true;
                }
              
                /* Has Aries defined record type for parent or guardian 1 */

                if (studentContact.MiscCode == "P1") {
                  studentContacts[_studentContactIdx].hasRecordTypeParentGuardian1 = true;
                }              

                /* Has Aries defined record type for parent or guardian 2 */

                /*if (studentContact.MiscCode == "P2") {
                  studentContacts[_studentContactIdx].hasRecordTypeParentGuardian2 = true;
                }              
                */

                _studentContactIdx++;

                
            } /* foreach*/

            /* Now attempt to identify the primary contact */
            
            int _idxOfPrimaryContact = -1;

            /* Start with Aries primary contact flag */

            _idxOfPrimaryContact = studentContacts.FindIndex(x => x.hasPrimaryContactFlag == true);
            
            if (_idxOfPrimaryContact == -1) {

              /* If not found then try parent guardian record type 1 */

              _idxOfPrimaryContact = studentContacts.FindIndex(x => (x.hasRecordTypeParentGuardian1 == true));
              
              /* If not found then try parent guardian relationship type combined with notification preference */

              if (_idxOfPrimaryContact == -1) {                                           
             
                _idxOfPrimaryContact = studentContacts.FindIndex(x => ((x.hasRelationshipTypeParentGuardian == true) && (x.hasNotificationPreferenceGenOrEme = true)));

                 /* Finally if not found and there is a single record use it */ 
                 
                 if ((_idxOfPrimaryContact == -1) && (studentContacts.Count == 1)) {
                   _idxOfPrimaryContact = 0;
                 } /* Could not find by parent guardian relationship type */     
              }  /* Could not found by record type*/
            } /* Count not find primary contact by flag*/            
           
            if(_idxOfPrimaryContact != -1) {
              studentContacts[_idxOfPrimaryContact].identifiedAsPrimaryContact = true;
            }
          } /* Request successful */
        }
        return studentContacts;
      }
   }
}
