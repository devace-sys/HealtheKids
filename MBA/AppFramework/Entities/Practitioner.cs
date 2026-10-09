using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


namespace MBA
{

  /***************************************************************************
   * Practitioner */
  /**
   **************************************************************************/ 
  
  // TODO: Refactor so practitioner does not need to be declared here
  
  public class Practitioner:Person
  {
    public string      groupName;
    public int         groupID;
    public string      groupNameRept;
    public int         groupIDRept;
    public bool        submitClaims;
    public DateTime    submitClaimsEffectiveDate;
    public bool        svcRecPracApprovalSystem; 
    public int         supervisesGroupCount;
    public int         supervisedByGroupCount;
    public int         supervisorsAssignedCount;
    public int         supervisedAssignedCount;              /* Note : Requires supervisor be in prac group hierarchy */
    public int         svcsHeldFromAllCount;
    public int         svcsToReviewFromAllCount;
    public int         svcsToReviewFromAssignedCount;
    public int         groupsThatPracCanSuperviseDirectlyCount;
    public int         pracsAssignedToSuperviseDirectlyCount;
    public int         pracsAsDeptHeadAllowedToViewSvcRecsCount;
    public int         serviceAuthorizationRequestsPendingCount;
    public int         serviceAuthorizationRequestsAuthToViewCount;
    public string      clientEmployeeID;
    public string      latestServiceDate;
    public string      earliestServiceDate;
    public string      modifiedOrCreatedOn;
    public bool?       claim_TCM;
    public DateTime    claim_TCMEffectiveDate;
    public long        planWriterGroupID;
    public long        orpGroupServiceClassNameID;
    public string      orpGroupServiceClassName;
    public string      npiNumber;
    public bool?       isValidMcalOrp;
    public DateTime    isValidMcalOrpLastValidated;
    public long        employeeRelationshipID;
    public string      employeeRelationship;    
    public bool        includeInFinRepts;
    public long        stdSvcClassNameID;
    public bool        isAParaProfessional;
    public DateTime    cprCertEffectiveDate;
    public DateTime    cprCertExpirationDate;
    public string      qualificationsJSONData;
    public bool        deptHead;
    public bool        displayPercent;
    public bool        displayMoney;
    public string      activeYN;
    public string      isRMTSPart1;
    public string      isRMTSPart2;
    public string      isRMTSPart3;
    public string      isRMTSPart4;
    public string      isValidMcalOrpYN;
    public string      includeInFinReptsYN;
    public string      submitClaimsYN;
    public string      claim_TCMYN;  
    public string      hasLoginYN;
    public string      isLockedOutYN;
    public string      startDateStr;
    public string      endDateStr;
    public string      submitClaimsEffectiveDateStr;
    public string      claim_TCMEffectiveDateStr;
    public DateTime?   acesCertCompletedOn;
    public bool        isPracSomeoneWhoCanManageDirectSupervisionTracking                     = false;
    public bool        pracIsLimitedToTheirReportingGroupForManagingDirectSupervisionTracking = false;


    public bool        participatesInLEABOP;
    public bool        participatesInLEABOPNonSpEd;
    public bool        participatesInCYBHI;
    public bool        participatesInRUHealth;

    public string      participatesInLEABOP_YN;
    public string      participatesInLEABOPNonSpEd_YN;
    public string      participatesInCYBHI_YN;
    public string      participatesInRUHealth_YN;

    public bool        deptHeadCanSeeEntirePracticeFamilyInDeptReviewReports;

    public DateTime?   dob;
    public string      gender;
    public string      ssn;
    public string      cybhiDegreeCode;
    public string      cybhiSpecialtyCode;

    public bool      currentlyWithClient;
    public string    currentlyWithClient_YN; 
    public bool      cybhiTpaApproved;
    public DateTime? cybhiTpaApprovedOn;
    public string    cybhiTpaApprovedOnStr;
    public string    cybhiTpaID;
    public bool      cybhiSubmitClaims;
    
    public int       pracsAssignedForCybhiOrpSvcRecReview;
    public int       svcRecsWaitingForReviewCybhiOrp;

    public int       pracsAssignedForInternalSvcRecReview;
	public int       svcRecsWaitingForReviewInternal;

    public static string getSaveUrlForUserGroupUserRole (int userGroup, string userRole)    
    { 
      string userAllSaveURL = @"user_all_prac_save.aspx";
      string saveUrl = @"";

      if (userGroup == Constants.USER_GROUP_SBSC)   
      {
        saveUrl = userAllSaveURL;          
      }        
      else if (userGroup == Constants.USER_GROUP_CLIENT) 
      {
        if (userRole == Constants.ROLE_LEA_CORDINATOR)  
        {
          saveUrl = userAllSaveURL;            
        }
        else if (userRole == Constants.ROLE_LEA_INPUT_STAFF) 
        {
          saveUrl = userAllSaveURL;            
        }
        else if (userRole == Constants.ROLE_LEA_PROVIDER)
        {
          saveUrl = userAllSaveURL;            
        }
      }

      return saveUrl;
    }
  } 
}
