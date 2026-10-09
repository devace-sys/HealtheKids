using System;
using MBA;

namespace Spedmon
{

  public class UserAllViewPatientPersons : WebUI                      
  {




    public UserAllViewPatientPersons() : base(
		                                ""
                                        , PatientPersons.SEL_LABEL_USER_ALL_VIEW
                                        , @""
                                        , @"patient-persons.js"
                                        , Constants.ROLE_SBS_ALL) {}

    
    public bool   isPcalStaff             = false;        
    public string isPcalStaffJSBoolStr    = "";
    public string urlEditPatient          = "";
	protected void Page_Load(object sender, EventArgs e)
    {
    
        isPcalStaff           = uInfo.pcalStaff;
        isPcalStaffJSBoolStr  = Util.netBoolToJSBool(isPcalStaff);
        urlEditPatient        = Patients.URL_USER_ALL_EDIT_EXISTING_BASE(true,"");

        var ctrlTerm   = findControlRecu (this.Page, Constants.PARM_SEARCH_TERM)  as MBA.DataEntryBoxSearch;
        ctrlTerm.value = MBA.HttpApplication.getParameter(Constants.PARM_SEARCH_TERM);       
    }
  }
}