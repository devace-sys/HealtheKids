using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MBA;


namespace Spedmon
{
  
  /***************************************************************************
   * UserAllPractitionerPatientScheduledServicesManage */
  /**
   * 
   ***************************************************************************/   

  public class UserAllPractitionerPatientScheduledServicesManage : WebUI
  {

    public UserAllPractitionerPatientScheduledServicesManage() : base( @"user_all_practitioner_patient_scheduled_services_manage"
                                                                       , PractitionerPatientScheduledServices.SEL_LABEL_MANAGE
                                                                       , @""
                                                                       , @"practitioner-patient-scheduled-services-manage.js"
                                                                       , Constants.ROLE_ALL_PCAL_AND_CLIENT)
    {
    }
    
    public bool lockPractitionerSelection = false;
    public bool lockPatientSelection      = false;

    protected void Page_Load(object sender, EventArgs e)
    {
      /*###########################################################################
        # Get incoming parameter values 
        ###########################################################################*/
    
       var clientID                     = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
	   var pracID                       = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);
       var patID                        = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);       
       var pracPatCaseloadExpectedSvcID = MBA.HttpApplication.getParameter(Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID);

       /*###########################################################################
         # Get control references 
         ###########################################################################*/
       
       var ctrlSelectClient                 = findControlRecu (this.Page, @"selectClient")                                  as MBA.DataEntryRowSelectClient;
       var ctrlSelectPractitioner           = findControlRecu (this.Page, @"selectPractitioner")                            as MBA.DataEntryRowSelectPractitioner;
       var ctrlSelectPatient                = findControlRecu (this.Page, @"selectPatient")                                 as MBA.DataEntryRowSelectPatient;       
       var ctrlPracPatCaseloadExpectedSvcID = findControlRecu (this.Page, Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID) as MBA.HiddenInput;

      /*###########################################################################
        # Load data for entity references passed in 
        ###########################################################################*/
     
      /*---- Client ----*/
      
      if (!String.IsNullOrWhiteSpace(clientID))
      {        
        clientID = Spedmon.Validate.optClientID(uInfo,clientID).ToString();
        var client = Clients.load(dbConnApp,log,uInfo,clientID);
        ctrlSelectClient.selectValue = clientID;
        ctrlSelectClient.selectName  = client.name;
      }

      /*---- Practitioner ----*/
      
      if (!String.IsNullOrWhiteSpace(pracID))
      {
        pracID = Spedmon.Validate.optPracID(uInfo,pracID).ToString();
        var prac = Practitioners.load(dbConnApp,log,uInfo,pracID);
        ctrlSelectPractitioner.selectValue        = pracID;
        ctrlSelectPractitioner.selectName         = prac.name;
        ctrlSelectPractitioner.showClearSelection = false;
        lockPractitionerSelection                 = true;
      }
      else
      {
        ctrlSelectPractitioner.showClearSelection = true;
        lockPractitionerSelection                 = false;
      }
      
      /*---- Patient ----*/
      
      if (!String.IsNullOrWhiteSpace(patID))
      {
         patID = Spedmon.Validate.reqPatID(uInfo,patID).ToString();
         var pat = Patients.load(dbConnApp,log,uInfo,patID);
         ctrlSelectPatient.selectValue = patID;
         ctrlSelectPatient.selectName   = pat.name;  
         ctrlSelectPatient.showClearSelection = false;
         lockPatientSelection                 = true;
      }
      else
      {
          ctrlSelectPatient.showClearSelection = true;
          lockPatientSelection                 = false;
      }
      
      /*---- Expected Service ID ----*/
      
      if (!String.IsNullOrEmpty(pracPatCaseloadExpectedSvcID)) { 
        ctrlPracPatCaseloadExpectedSvcID.value = pracPatCaseloadExpectedSvcID;
      }

    }
  }
}