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
   * rpt_plan_svc_comp_one_patient */
  /**
   * View stats on services rendered for one patient for compliance purposes
   ***************************************************************************/   
  
  public class rpt_plan_svc_comp_one_patient : WebUI
  {
    public rpt_plan_svc_comp_one_patient() : base("service_records_view", ServiceRecords.SEL_LABEL_PLAN_SVC_COMP_REPT, "", "", Constants.ROLE_SBS_ALL){}
    
    protected void Page_Load(object sender, EventArgs e)
    {
      /* Set date range to current fiscal year */
       
       Steps        ctrlSteps      = findControlRecu(this.Page, "viewexisting") as Steps;
       Step         ctrlStep3      = findControlRecu(this.Page, "step3")        as Step;
       DateBoxRange ctrlDateRange  = findControlRecu(this.Page, "daterange")    as DateBoxRange;
      
       string dateRangeStr = Util.GenerateDateRange(3);
       ctrlStep3.label     = dateRangeStr;
       ctrlDateRange.value = dateRangeStr;       
       ctrlSteps.firstStep = 0;
    
    }
  }
}
