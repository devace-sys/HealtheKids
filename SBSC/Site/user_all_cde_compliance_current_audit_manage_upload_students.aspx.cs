using System;
using MBA;


namespace Spedmon
{

  public class UserAllCdeComplianceCurrentAuditManageUploadStudents : WebUI

  {

    public UserAllCdeComplianceCurrentAuditManageUploadStudents() : base(  Util.createUniqueID()
                                              , PatientsPromisedServicesCDEAuditsCurrentPatients.SEL_LABEL
                                              , @""
                                              , @""
										      , Constants.ROLE_CDE_COMPLIANCE_MANAGE
        ) { }
    
    public string structuredDataProfileSet = String.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        var ctrlClientID  = findControlRecu(this.Page, "selectClient")       as MBA.DataEntryRowSelectClient;

        string clientIDStr  = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

        int parmClientID;
        var parmClientIDPassed = int.TryParse(clientIDStr, out parmClientID);

        // TODO: create an intelligible error message if the client ID isn't passed in

        if (parmClientIDPassed && parmClientID != 0)
        {
            ctrlClientID.selectValue          = parmClientID.ToString();
            ctrlClientID.entryInitiallyHidden = true;
        }

        structuredDataProfileSet =
            MBA.StructuredDataImportFiles.loadProfileSetsFileIntoString(PatientsPromisedServicesCDEAuditsCurrentPatients.STRUCTURED_DATA_IMPORT_PROFILES_FILE );
            
    }
  }

}
