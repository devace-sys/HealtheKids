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
   * UserAllPatientsDataImport */
  /**
   * 
   ***************************************************************************/


  public class UserAllPatientsDataImport : WebUI

  {

    public UserAllPatientsDataImport() : base(  Util.createUniqueID()
                                              , StructuredDataImportFilesPatientData.SEL_LABEL_IMPORT
                                              , @""
                                              , @""
										      , Constants.ROLE_BULK_PATIENT_IMPORT) { }
    
    public string structuredDataProfileSet = String.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
      structuredDataProfileSet  = MBA.StructuredDataImportFiles.loadProfileSetsFileIntoString(StructuredDataImportFilesPatientData.STRUCTURED_DATA_IMPORT_PROFILES_FILE);

      var ctrlClientID   = findControlRecu (this.Page, "selectClient") as MBA.DataEntryRowSelectClient;
      string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
      
      /* preselect clientid if passed */


      if (!String.IsNullOrEmpty(clientIDStr))
      {
        var _clt = Clients.load(dbConnApp,log,uInfo,clientIDStr);
        ctrlClientID.selectName  = _clt.name;
        ctrlClientID.selectValue = clientIDStr;
      }


      var ctrlValidateAgeYesNo   = findControlRecu (this.Page, "validateGradeDOBs") as MBA.SelectYesOrNo;
      ctrlValidateAgeYesNo.setValue( true );

    }
  }
}
