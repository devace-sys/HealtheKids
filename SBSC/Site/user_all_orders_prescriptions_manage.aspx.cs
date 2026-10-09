using System;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * UserAllOrdersPrescriptionsManage */
  /**
   * 
   ***************************************************************************/

  public class UserAllOrdersPrescriptionsManage : WebUI
  {
    
    public UserAllOrdersPrescriptionsManage() : base ( "user_all_orders_prescriptions_manage"
                                                       , ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE
                                                       , @""
                                                       , @"orders-or-prescriptions.js"
                                                       , Constants.ROLE_SVC_SUP_PRAC) { }
    public bool   showActive          = true;
    public string showActiveJSBoolStr = "";
    public bool   hasCarePlanAccess;
    public string newSubTitle          = @"";
    public string referenceDataDisplay = @"";
    
    protected void Page_Load(object sender, EventArgs e)
    {

      string orpGrpNameDisplay = @" "; /* Keep whitespace */
      string patNameDisplay    = @" "; /* Keep whitespace */
         
     /*###########################################################################
       # Get optional passed in parameters
       ###########################################################################*/
  
      var clientID  = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
      var pracID    = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);
      var patID     = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);
       
     /*###########################################################################
       # Get control references
       ###########################################################################*/
  
     var ctrlSelectClient     = findControlRecu(this.Page, @"selectClient")     as MBA.DataEntryRowSelectClient;
     var ctrlSelectPatient    = findControlRecu(this.Page, @"selectPatient")    as MBA.DataEntryRowSelectPatient;
     var ctrlSelectDispFam    = findControlRecu(this.Page, @"selectDispFamily") as MBA.DataEntryRowSelectPractitionerDisciplineFamily;
     var ctrlSelectActive     = findControlRecu(this.Page, @"selectActive")     as MBA.DataEntryRow;
     var ctrlActive           = findControlRecu(this.Page, @"active")           as MBA.RadioBox;
     var ctrlOrpApprovalState = findControlRecu(this.Page, @"orpapprovalstate") as MBA.RadioBox;

     /*###########################################################################
       # Set default values for radio boxes 
       # Note: We have to do this before adding selections
       ###########################################################################*/

     ctrlOrpApprovalState.value = ""; 
           
    /* Add selections for ORP approval state*/

     ctrlOrpApprovalState.AddSelection(@"Any Status",     "");
     ctrlOrpApprovalState.AddSelection(@"Not Authorized", "0");
     ctrlOrpApprovalState.AddSelection(@"Current",        "1");
     ctrlOrpApprovalState.AddSelection(@"Expiring Soon",  "2");
     ctrlOrpApprovalState.AddSelection(@"Expired",        "3");
     ctrlOrpApprovalState.AddSelection(@"Denied",         "4");

     /*###########################################################################
       # Hide active from non Practi-Cal staff.  All other controls on this screen
       # are already setup to hide for users who should not see them by default.
       ###########################################################################*/

     if (rd.wu.usr.userGroupID != Constants.USER_GROUP_SBSC) showActive = false; else showActive = true;
     ctrlSelectActive.entryInitiallyHidden = !showActive;
    
     /*###########################################################################
       # If client id is passed in, validate then preset and hide select client
       ###########################################################################*/

     if (!String.IsNullOrWhiteSpace(clientID)) {
        clientID = Spedmon.Validate.reqClientID(uInfo,clientID).ToString();
        ctrlSelectClient.selectValue = clientID;
        ctrlSelectClient.entryInitiallyHidden = true;
     }

     /*###########################################################################
       # If prac id is passed in, validate then load prac data so we can get 
       # associated group family, then preset and hide select groupfamily
       ###########################################################################*/

     if (!String.IsNullOrWhiteSpace(pracID)) {
       pracID = Spedmon.Validate.reqPracID(uInfo,pracID).ToString();
       var prac = Practitioners.load(dbConnApp,log,uInfo,pracID);       
       orpGrpNameDisplay = " " + prac.orpGroupServiceClassName + " ";
       referenceDataDisplay = orpGrpNameDisplay + ServiceJournals.SEL_LABEL_MANAGE_ORDERS;
       ctrlSelectDispFam.selectValue = prac.orpGroupServiceClassNameID.ToString();
       ctrlSelectDispFam.entryInitiallyHidden = true;
     }

     /*###########################################################################
       # If pat id is passed in, validate then load pat data so we can get 
       # patient name to show user, then preset and hide select patient
       ###########################################################################*/

     if (!String.IsNullOrWhiteSpace(patID)) {
       patID = Spedmon.Validate.reqInteger(patID,Messages.INVALID_PAT_ID).ToString();
       var pat = Patients.load(dbConnApp,log,uInfo,patID);
       patNameDisplay = " for " + pat.name;
       referenceDataDisplay = referenceDataDisplay + patNameDisplay;
       ctrlSelectPatient.selectValue = patID;
       ctrlSelectPatient.entryInitiallyHidden = true;
     }

     /*###########################################################################
       # Build subtitle and reference data display
       ###########################################################################*/

     newSubTitle = String.Format(ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE_WITH_PLACEHOLDERS, orpGrpNameDisplay, patNameDisplay).Trim();
     this.subTitle = newSubTitle;
     referenceDataDisplay = referenceDataDisplay.Trim();

     /*###########################################################################
       # Determine careplan access
       ###########################################################################*/

     hasCarePlanAccess = (uInfo.userClientID == 0) ? true : Spedmon.PlanWriterRecords.clientHasAccess(this.dbConnApp, this.log, this.uInfo, uInfo.userClientIDStr);
     
     /*###########################################################################
       # Pass flag values
       ###########################################################################*/

     showActiveJSBoolStr = Util.netBoolToJSBool(showActive);

     }
  }
}
