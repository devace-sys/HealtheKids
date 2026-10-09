using System;
using MBA;


namespace Spedmon
{
  /***************************************************************************
   * UserAllRmtsParticipantsDataImport */
  /**
   * 
   ***************************************************************************/


  public class UserAllRmtsParticipantsDataImport : WebUI

  {

    public UserAllRmtsParticipantsDataImport() : base(  Util.createUniqueID()
                                              , StructuredDataImportFilesRmtsParticipantsData.SEL_LABEL_IMPORT
                                              , @""
                                              , @""
										      , Constants.ROLE_SBS_ALL_LEA_COORD) { }
    
    public string structuredDataProfileSet = String.Empty;
    public bool rosterExists               = false;
    public bool parmFiscalQtrIDPassed      = false;
    protected void Page_Load(object sender, EventArgs e)
    {
            // allow clientID and quarter ID to be passed in from URL
            var ctrlClientID  = findControlRecu(this.Page, "selectClient")  as MBA.DataEntryRowSelectClient;
            var ctrlQuarterID = findControlRecu(this.Page, "selectQuarter") as MBA.DataEntryRowSelectRmtsFiscalQuarter;

            string clientIDStr    = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID)
                 , fiscalQtrIDStr = MBA.HttpApplication.getParameter(Constants.PARM_FY_QUARTER_ID);

            int parmClientID, ParmFiscalQtrID;

            var parmClientIDPassed    = int.TryParse(clientIDStr, out parmClientID);
                parmFiscalQtrIDPassed = int.TryParse(fiscalQtrIDStr, out ParmFiscalQtrID);

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

                try
                {
                    var retRoster = RmtsParticipationRosters.loadByQuarter(dbConnApp, log, uInfo, "1", parmClientID.ToString(), ParmFiscalQtrID.ToString());
                    if (retRoster.hasRecord) rosterExists = true;
                } catch(Exception err)
                {

                }

            }

            // set RMTS specific settings for file upload
            structuredDataProfileSet = MBA.StructuredDataImportFiles.loadProfileSetsFileIntoString(StructuredDataImportFilesRmtsParticipantsData.STRUCTURED_DATA_IMPORT_PROFILES_FILE);     

    }
  }

}
