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
   * ClientCoorrptPractitionersReview */
  /**
  * 
  ***************************************************************************/

  public class ClientProvRptSvcRecReviewForDirectSup : WebUI
  {
    public ClientProvRptSvcRecReviewForDirectSup() : base("rpt_prac_review", ServiceRecordsApproval.SEL_LABEL_RPT_SVC_REC_REVIEW_FOR_DIRECT_SUP, "", "", Constants.ROLE_LEA_PROVIDER) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    
       Steps        ctrlSteps      = findControlRecu(this.Page, "viewexisting") as Steps;
       Step         ctrlStep3      = findControlRecu(this.Page, "step3")        as Step;
       DateBoxRange ctrlDateRange  = findControlRecu(this.Page, "daterange")    as DateBoxRange;
      
       string dateRangeStr = Util.GenerateDateRange(3);
       ctrlStep3.label     = dateRangeStr;
       ctrlDateRange.value = dateRangeStr;       

    }
  }
}
