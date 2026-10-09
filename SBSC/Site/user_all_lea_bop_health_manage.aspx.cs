using System;
using MBA;

namespace Spedmon
{

    public class UserAllLeaBopHealthManage : WebUI
    {
        public bool previewOnly = false;
        public string dateToday;
        public string dateRangeLastFY;


        public UserAllLeaBopHealthManage() : base(
                                              LeaBopHealthCommon.BODY_ID_MANAGE
                                            , LeaBopHealthCommon.SEL_LABEL_MANAGE
                                            , "user_all_lea_bop_health_manage.css"

                                            , @"user_all_client_compliance_manage.js"

                                            , Constants.ROLE_LEA_BOP_HEALTH_MANAGE)
        { 
	}

        
	protected void Page_Load(object sender, EventArgs e)
    {
      this.includeBackgroundLayer = true;

      var ctrlClientID                    = findControlRecu(this.Page, "selectClient")                    as MBA.DataEntryRowSelectClient;
      var ctrlDaterange                   = findControlRecu(this.Page, "daterange")                       as MBA.HiddenInput;

      // leaving this here, as it affects the potential lost reimbursement dashboard (and possibly others)
          
      var ctrlFyID                        = findControlRecu(this.Page, "selectFiscalYear" )                  as MBA.DataEntryRowSelectFiscalYear;
      var ctrlManageClientComplianceTasks = findControlRecu(this.Page, "gotomanageclientcompliancetasks")    as MBA.LinkInternal;
      var ctrlItemStatus                  = findControlRecu(this.Page, "clientcompliancetasksitemstatus")    as MBA.RadioBox;

      /* Add filter selections for compliance task status selection */

      ClientComplianceCommon.addStatusFilterSelections(ref ctrlItemStatus);

      /* Preset and then hide the fiscal year */

      var fiscalYear                = CompanyFiscalYears.loadCurrent(this.dbConnApp, this.log, this.uInfo );
      ctrlFyID.selectValue          = fiscalYear.ID.ToString();
      ctrlFyID.selectName           = fiscalYear.name;
      ctrlFyID.entryInitiallyHidden = true;
      ctrlFyID.entryAllowed         = false;

      /* preselect clientid if passed */

      string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

      if (!String.IsNullOrEmpty(clientIDStr))
      {
        ctrlClientID.selectValue = clientIDStr;
        ctrlClientID.entryInitiallyHidden = true;
        ctrlClientID.entryAllowed = false;
      }

      /* default date and date range range values */

      ctrlDaterange.value = Util.GenerateDateRange(3);    /* 3 - Fiscal year to date */
      dateRangeLastFY     = Util.GenerateDateRange(4);    /* 4 - Last fiscal year */
      dateToday           = Util.generateStartDateStr(1);

      /* Get preview only flag */

      previewOnly = false;
      string previewOnlyStr = MBA.HttpApplication.getParameter(Constants.PARM_PREVIEW_ONLY);
      if (String.IsNullOrWhiteSpace(previewOnlyStr))
      { 
        previewOnly = false;
      }
      else
      {
        previewOnly = true;
      }

      /* Set url for manage compliance tasks link */
      
      ctrlManageClientComplianceTasks.url = ClientComplianceCommon.URL_MANAGE;
                        

        }
    }
}