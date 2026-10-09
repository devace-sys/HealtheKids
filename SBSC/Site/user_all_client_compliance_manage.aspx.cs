using System;

namespace Spedmon
{


  public class userAllClientComplianceManage : WebUI
  {

    public bool isPcalStaff = false;

    public string wrapDataEntryRowsSpanClass;
    public string divDataManagementRowsClass;


    public string isRestviewPreview = "0";


    public userAllClientComplianceManage() : base(ClientComplianceCommon.MENU_ID_MANAGE
                                                , ClientComplianceCommon.SEL_LABEL_MANAGE
                                                , "user_all_client_compliance_manage.css"
                                                , @"user_all_client_compliance_manage.js"
                                                , Constants.ROLE_SBS_ALL_LEA_COORD_AND_ASSIST) {}

    
    protected void Page_Load(object sender, EventArgs e)
    {
      /* Get references to controls */

      var ctrlClientID    = findControlRecu (this.Page, @"selectClient")      as MBA.DataEntryRowSelectClient;
      var ctrlItemStatus  = findControlRecu (this.Page, @"itemstatus")        as MBA.RadioBox;
      var ctrlFyID        = findControlRecu (this.Page, @"selectFiscalYear" ) as MBA.DataEntryRowSelectFiscalYear;

      /* preselect clientid if passed */

      string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

      if (!String.IsNullOrEmpty(clientIDStr))
      {
        var _clt = Clients.load(dbConnApp,log,uInfo,clientIDStr);
        ctrlClientID.selectName  = _clt.name;
        ctrlClientID.selectValue = clientIDStr;
      }

      isRestviewPreview = "0";

      isPcalStaff = this.uInfo.pcalStaff;

      if (!( isPcalStaff )) { 
          divDataManagementRowsClass = "d-none";
          wrapDataEntryRowsSpanClass = "d-none";
      }
      else { 
          divDataManagementRowsClass = "col-auto";
          wrapDataEntryRowsSpanClass = "";
      }
      
      /* Add filter options */

      ClientComplianceCommon.addStatusFilterSelections(ref ctrlItemStatus);

      /* Set default fiscal year */

      var fiscalYear = CompanyFiscalYears.loadCurrent(this.dbConnApp, this.log, this.uInfo );

      ctrlFyID.selectValue = fiscalYear.ID.ToString();
      ctrlFyID.selectName  = fiscalYear.name;

    }
  }
}
