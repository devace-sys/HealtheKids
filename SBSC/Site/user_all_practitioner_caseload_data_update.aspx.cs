using System;
using MBA;


namespace Spedmon
{

  public class UserAllPractitionerCaseloadDataUpdate : WebUI

  {
    public UserAllPractitionerCaseloadDataUpdate() : base ( Util.createUniqueID()
                                              , PractitionerPatientCaseloadExpectedServices.SEL_LABEL_UPDATE
                                              , @""
                                              , @""
										      , Constants.ROLE_ALL
        ) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {
      var clientIDStr    = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
      var pracIDStr      = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);      
      var ctrlClientID   = findControlRecu (this.Page, Constants.PARM_CLIENT_ID)        as MBA.HiddenInput;
      var ctrlPracID     = findControlRecu (this.Page, Constants.PARM_PRACTITIONER_ID)  as MBA.HiddenInput;
      ctrlClientID.value = clientIDStr;
      ctrlPracID.value   = pracIDStr;      
    }
  }

}
