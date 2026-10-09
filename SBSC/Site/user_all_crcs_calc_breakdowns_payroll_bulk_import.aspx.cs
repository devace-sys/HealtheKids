using System;
using MBA;
 
 
namespace Spedmon
{
 
  public class UserAllCrcsCalcBreakdownsPayrollBulkImport : WebUI
 
  {
 
    public UserAllCrcsCalcBreakdownsPayrollBulkImport() : base( 
          Util.createUniqueID()
        , "" // PatientsPromisedServicesCDEAuditsCurrentPatients.SEL_LABEL_UPL_SUMMARY_DATA
        , Constants.ROLE_CDE_COMPLIANCE_MANAGE

        ) { }
    
    public string structuredDataProfileSet = String.Empty;
 
    protected void Page_Load(object sender, EventArgs e)
    {

        var ctrlClientID           = findControlRecu(this.Page, "selectClient")       as MBA.DataEntryRowSelectClient;
        var ctrlfFiscalYear        = findControlRecu(this.Page, "selectFiscalYear")   as MBA.DataEntryRowSelectFiscalYear;
        var ctrlFiscalQtrSelection = findControlRecu(this.Page, "fiscalquarterselection") as MBA.RadioBox;

        string clientIDStr   =  MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
        string fYearIDStr    =  MBA.HttpApplication.getParameter(Constants.PARM_FISCAL_YEAR_ID);
        string fQuarterStr   =  MBA.HttpApplication.getParameter(Constants.PARM_QUARTER_NUMBER);
 
        int parmClientID;
        var parmClientIDPassed = int.TryParse(clientIDStr, out parmClientID);

        int parmFyID;
        var parmFyIDPassed =  int.TryParse(fYearIDStr, out parmFyID);
 
        int parmQuarterNum;
        var parmQuarterNumPassed =  int.TryParse(fQuarterStr, out parmQuarterNum);

        // TODO: create an intelligible error message if the client ID isn't passed in
 
        if (parmClientIDPassed && parmClientID > 0)
        {
            ctrlClientID.selectValue          = parmClientID.ToString();
            ctrlClientID.entryInitiallyHidden = true;
        }

        if (parmFyIDPassed && parmFyID > 0)
        {
            ctrlfFiscalYear.selectValue = parmFyID.ToString();
            ctrlfFiscalYear.selectName = CompanyFiscalYears.load(this.dbConnApp, this.log, this.uInfo, parmFyID.ToString()).name ;
            //ctrlClientID.selectValue = parmClientID.ToString();
            //ctrlClientID.entryInitiallyHidden = true;
        }

        
        if ( !parmQuarterNumPassed )
          ctrlFiscalQtrSelection.AddSelection(@"Q1", "1",  true );
        else
          ctrlFiscalQtrSelection.AddSelection(@"Q1", "1", (parmQuarterNumPassed && parmQuarterNum == 1));


        ctrlFiscalQtrSelection.AddSelection(@"Q2", "2", (parmQuarterNumPassed && parmQuarterNum == 2));
        ctrlFiscalQtrSelection.AddSelection(@"Q3", "3", (parmQuarterNumPassed && parmQuarterNum == 3));
        ctrlFiscalQtrSelection.AddSelection(@"Q4", "4", (parmQuarterNumPassed && parmQuarterNum == 4));


        structuredDataProfileSet =
            MBA.StructuredDataImportFiles.loadProfileSetsFileIntoString( CrcsCommon.STRUCTURED_DATA_IMPORT_PROFILES_FILE_PAYROLL_IMPORT);
            
    }
  }
 
}