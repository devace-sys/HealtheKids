using System;
using MBA;


namespace Spedmon
{
  /***************************************************************************
   * UserAllRmtsMomentsDataImport */
  /**
   * 
   ***************************************************************************/


  public class UserAllRmtsMomentsDataImport : WebUI

  {

    public UserAllRmtsMomentsDataImport() : base(  Util.createUniqueID()
                                              , StructuredDataImportFilesRmtsMomentsData.SEL_LABEL_IMPORT
                                              , @""
                                              , @""
										      , Constants.ROLE_SBS_ALL_LEA_COORD) { }
    
    public string structuredDataProfileSet = String.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
            // allow clientID and quarter ID to be passed in from URL
            var ctrlClientID  = findControlRecu(this.Page, "selectClient")  as MBA.DataEntryRowSelectClient;
            var ctrlQuarterID = findControlRecu(this.Page, "selectQuarter") as MBA.DataEntryRowSelectRmtsFiscalQuarter;

            string clientIDStr    = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID)
                 , fiscalQtrIDStr = MBA.HttpApplication.getParameter(Constants.PARM_FY_QUARTER_ID);

            int parmClientID, ParmFiscalQtrID;

            var parmClientIDPassed    = int.TryParse(clientIDStr, out parmClientID);
            var parmFiscalQtrIDPassed = int.TryParse(fiscalQtrIDStr, out ParmFiscalQtrID);

            // if values provided, hide controls
            if (parmClientIDPassed && parmClientID != 0)
            {
                ctrlClientID.selectValue          = parmClientID.ToString();
                ctrlClientID.entryInitiallyHidden = true;
                ctrlClientID.entryAllowed         = false;
            }

            if (parmFiscalQtrIDPassed && ParmFiscalQtrID != 0)
            {
                ctrlQuarterID.selectValue          = ParmFiscalQtrID.ToString();
                ctrlQuarterID.entryInitiallyHidden = true;
                ctrlQuarterID.entryAllowed         = false;
            }

            // set RMTS moment specific settings for file upload
            structuredDataProfileSet = MBA.StructuredDataImportFiles.loadProfileSetsFileIntoString(StructuredDataImportFilesRmtsMomentsData.STRUCTURED_DATA_IMPORT_PROFILES_FILE);     

    }
  }

}
