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
   * client_all_plan_svc_comp_one_patient_rpt */
  /**
   * View stats on services rendered for one patient for compliance purposes
   ***************************************************************************/   
  
  public class client_all_plan_svc_comp_one_patient_rpt : WebUI
  {
    public client_all_plan_svc_comp_one_patient_rpt() : base("service_records_view", ServiceRecords.SEL_LABEL_PLAN_SVC_COMP_REPT, "", "", Constants.ROLE_CLIENT_ALL){}
    
    protected void Page_Load(object sender, EventArgs e)
    {
      /* Set date range to current fiscal year */
       
       Steps        ctrlSteps      = findControlRecu(this.Page, "viewexisting") as Steps;
       Step         ctrlStep2      = findControlRecu(this.Page, "step2")        as Step;
       DateBoxRange ctrlDateRange  = findControlRecu(this.Page, "daterange")    as DateBoxRange;
      
       string dateRangeStr = Util.GenerateDateRange(3);
       ctrlStep2.label     = dateRangeStr;
       ctrlDateRange.value = dateRangeStr;       
       ctrlSteps.firstStep = 0;
    
    }
  }
}
