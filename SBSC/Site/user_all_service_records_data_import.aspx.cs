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
   * UserAllServiceRecordsDataImport */
  /**
   * 
   ***************************************************************************/


  public class UserAllServiceRecordsDataImport : WebUI

  {

    public UserAllServiceRecordsDataImport() : base(  Util.createUniqueID()
                                              , ServiceRecordsDataImports.SEL_LABEL_IMPORT
                                              , @""
                                              , @""
										      , Constants.ROLE_SVC_REC_IMPORT) { }
    
    public string structuredDataProfileSet = String.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
      /*###########################################################################
        # Get control references
        ###########################################################################*/
      
      var ctrlClientID          = findControlRecu (this.Page, "selectClient")             as MBA.DataEntryRowSelectClient;
      var ctrlSelectSvcNameDS   = findControlRecu (this.Page, "svcnameslistdatasourceid") as MBA.DataEntryBoxSelect;

       /*###########################################################################
         # Get structured data profile set
         ###########################################################################*/
     
       structuredDataProfileSet  = MBA.StructuredDataImportFiles.loadProfileSetsFileIntoString(ServiceRecordsDataImports.STRUCTURED_DATA_IMPORT_PROFILES_FILE);

      /*###########################################################################
        # Get service name list data sources 
        ###########################################################################*/
            
      var svcNameDataSources = Services.viewListOfSvcNameListDataSources (
                  false /*showSvcsForLeaBop*/
                , true  /*showSvcsForLeaBopNonSpEd*/
                , true  /*showSvcsForCYBHI*/
                , false /*showSvcsForRUHealth*/ );

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
        # Add options for service name list data source using this list
        ###########################################################################*/
            
      ctrlSelectSvcNameDS.addSelectOneSelection = true;
       
      foreach(var svcNameDataSource in svcNameDataSources) {             
        var newSelection      = svcNameDataSource;
        newSelection.typename = @"";              
        ctrlSelectSvcNameDS.addSelection(newSelection);              
      }


    }
  }
}
