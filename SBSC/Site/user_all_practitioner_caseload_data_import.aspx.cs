using System;
using MBA;


namespace Spedmon
{

  public class UserAllPractitionerCaseloadDataImport : WebUI

  {
    public UserAllPractitionerCaseloadDataImport() : base(  Util.createUniqueID()
                                              , PractitionerPatientCaseloadExpectedServices.SEL_LABEL_IMPORT
                                              , @""
                                              , @""
										      , Constants.ROLE_ALL
        ) { }
    
    public string structuredDataProfileSet = String.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
            var ctrlClientID  = findControlRecu(this.Page, "selectClient")       as MBA.DataEntryRowSelectClient;
            var ctlPracID     = findControlRecu(this.Page, "selectPractitioner") as MBA.DataEntryRowSelectPractitioner;

            string clientIDStr  = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            string pracIDStr    = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);

            int parmClientID;
            var parmClientIDPassed = int.TryParse(clientIDStr, out parmClientID);

            int parmPracID;
            var parmPracIDPassed = int.TryParse(pracIDStr, out parmPracID);

            if (parmClientIDPassed && parmClientID != 0)
            {
                ctrlClientID.selectValue          = parmClientID.ToString();
                ctrlClientID.entryInitiallyHidden = true;
            }

            if (parmPracIDPassed && parmPracID != 0)
            {
                ctlPracID.selectValue = parmPracID.ToString();
                ctlPracID.entryInitiallyHidden = true;
            }

            structuredDataProfileSet = MBA.StructuredDataImportFiles.loadProfileSetsFileIntoString(PractitionerPatientCaseloadExpectedServices.STRUCTURED_DATA_IMPORT_PROFILES_FILE);
            
    }
  }

}
