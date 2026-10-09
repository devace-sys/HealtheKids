using System;
using MBA;

namespace Spedmon
{

  public class UserAllCYBHIProgramHealthDetailsServicesDocumentedManage : WebUI                      //
  {

    public string _divSelectClientDisp = "";


    public UserAllCYBHIProgramHealthDetailsServicesDocumentedManage() : base(
		                                CYBHIProgramHealthStats.BODY_ID_MANAGE
                                              , CYBHIProgramHealthStats.SEL_LABEL_MANAGE
                                              , @""
                                              , @""
                                              , Constants.ROLE_ALL){}

    // public bool isPcalStaff = false;

	protected void Page_Load(object sender, EventArgs e)
    {
    
      // isPcalStaff = rd.wu.usr.pcalStaff;
 
  	   var ctrlClientID  = findControlRecu(this.Page, "selectClient")         as MBA.DataEntryRowSelectClient;
  
  	   var ctrlPracID    = findControlRecu(this.Page, "selectPractitioner")   as MBA.DataEntryRowSelectPractitioner;

       var ctrlDispGroup  = findControlRecu(this.Page, "selectDispGroup")      as MBA.DataEntryRowSelectPractitionerDisciplineGroup;

       var ctrlSvcName    = findControlRecu(this.Page, "nameid")    as MBA.DataEntryBoxSelect;


       var ctrlIsPaid    = findControlRecu(this.Page, "ispaid")    as MBA.SelectYesOrNoOrAny;

  	   var ctrlPatID    = findControlRecu(this.Page,  "selectPatient")   as MBA.DataEntryRowSelectPatient;
      
	  /* preselect clientid if passed */
	  

        string   clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

        string   pracidStr = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);

        string   groupIDStr = MBA.HttpApplication.getParameter(Constants.PARM_GROUP_ID);

        string svcNameIDStr = MBA.HttpApplication.getParameter(Constants.PARM_NAME_ID);

        string isPaidStr    = MBA.HttpApplication.getParameter("ispaid");

        string patIDStr = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);

        //ctrlSvcName

      /*###########################################################################
        # Populate CYBHI Service Name Selections
        ###########################################################################*/  
      
      var cybhiServiceSelections = Spedmon.CYBHIServiceSelections.viewList(dbConnApp,log,uInfo);
      foreach(var selection in cybhiServiceSelections) { 
        ctrlSvcName.addSelection(new NameValue(selection.name,selection.id,""));
      }

        if (!String.IsNullOrEmpty(clientIDStr))
        {
            ctrlClientID.selectValue          = clientIDStr;
            //ctrlClientID.entryInitiallyHidden = true;
            _divSelectClientDisp = "d-none";
            ctrlClientID.entryAllowed         = false;
        }

        if (!String.IsNullOrEmpty(pracidStr))
        {
                ctrlPracID.selectValue = pracidStr;

                var prac = Practitioners.load(this.dbConnApp,log,uInfo,pracidStr);
                ctrlPracID.selectName = prac.name;
        }

        if (!String.IsNullOrEmpty(groupIDStr))
        {
                ctrlDispGroup.selectValue = groupIDStr;
                var dispg = Groups.loadDisciplineGroup(this.dbConnApp, this.log, this.uInfo, groupIDStr);
                ctrlDispGroup.selectName = dispg.name;

        }

        if (!String.IsNullOrEmpty(svcNameIDStr))
        {
           ctrlSvcName.value = svcNameIDStr;                
        }

        
        if (!String.IsNullOrEmpty(patIDStr))
        {
                ctrlPatID.selectValue = patIDStr;
                //ctrlPracID.entryInitiallyHidden = true;
                //ctrlPracID.entryAllowed = false;
                var pat = Patients.load(this.dbConnApp,log,uInfo,patIDStr);
                ctrlPatID.selectName = pat.name;
        }

        ctrlIsPaid.anyLabel = @"All";
        //if (!(Util.IsNullOrEmpty(isPaidStr)))
        //{
                ctrlIsPaid.setValueFromFlag(isPaidStr);

        //}
        



    }
  }
}