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
   * UserAllPatInsCarriersDataImport */
  /**
   * 
   ***************************************************************************/


  public class UserAllPatInsCarriersDataImport : WebUI

  {

    public UserAllPatInsCarriersDataImport() : base(  Util.createUniqueID()
                                              , PatientInsuranceCarriersDataImports.SEL_LABEL_IMPORT
                                              , @""
                                              , @""
										      , Constants.ROLE_SBS_ALL) { }
    
    public string structuredDataProfileSet = String.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
      /*###########################################################################
        # Get control references
        ###########################################################################*/
      
      var ctrlClientID          = findControlRecu (this.Page, "selectClient")             as MBA.DataEntryRowSelectClient;


      var ctrlFingerNavGotoManagePatIns = findControlRecu(this.Page, "fingerNavGotoManagePatIns")    as MBA.LinkInternal; 

      var ctrlNavGotoManagePatIns = findControlRecu(this.Page, "gotoManagePatIns")    as MBA.LinkInternal; 

       /*###########################################################################
         # Get structured data profile set
         ###########################################################################*/
     
       structuredDataProfileSet  = MBA.StructuredDataImportFiles.loadProfileSetsFileIntoString(PatientInsuranceCarriersDataImports.STRUCTURED_DATA_IMPORT_PROFILES_FILE);


      /*###########################################################################
        # Get parameter
        ###########################################################################*/
            
      string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
      
      /* preselect clientid if passed */

      if (!String.IsNullOrEmpty(clientIDStr))
      {
        var _clt = Clients.load(dbConnApp,log,uInfo,clientIDStr);
        ctrlClientID.selectName  = _clt.name;
        ctrlClientID.selectValue = clientIDStr;
      }


      /*###########################################################################
         # 
        ###########################################################################*/

        ctrlFingerNavGotoManagePatIns.url = PatientInsuranceCarriers.URL_PAGE_MANAGE;      
        ctrlNavGotoManagePatIns.url = PatientInsuranceCarriers.URL_PAGE_MANAGE;

         ctrlNavGotoManagePatIns.label = PatientInsuranceCarriers.PAGE_MANAGE_SEL_LABEL;



    }
  }
}
