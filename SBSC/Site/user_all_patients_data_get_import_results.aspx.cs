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
   * UserAllPatientsDataGetImportResults */
  /**
   * 
   ***************************************************************************/


  public class UserAllPatientsDataGetImportResults : WebUI

  {

    public UserAllPatientsDataGetImportResults() : base(  Util.createUniqueID()
                                              , StructuredDataImportFilesPatientData.SEL_LABEL_IMPORT_RESULTS
                                              , @"user_all_patients_data_get_import_results.css"
                                              , @""
										      , Constants.ROLE_BULK_PATIENT_IMPORT) { }
    
    public StructuredDataImportFilePatientDataExtended structuredDataImportFilePatient;
    protected void Page_Load(object sender, EventArgs e)
    {
       string recID = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
       structuredDataImportFilePatient = StructuredDataImportFilesPatientData.getImportResults (dbConnApp,log,uInfo,recID);
    }
  }

}
