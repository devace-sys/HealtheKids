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
  * ServiceRecordEditDelete*/
  /**
  * Selects a service record for editing/deleting
  ***************************************************************************/   

  public class ClientProvServiceRecordsEditDelete: WebUI
  {
    public ClientProvServiceRecordsEditDelete() : base("service_records_edit_delete",ServiceRecords.SEL_LABEL_EDIT_SVCREC,"","",Constants.ROLE_CLIENT_ALL){}
    protected void Page_Load(object sender, EventArgs e)
    {
       /* Go straight to view with date range set in constants */
       
       Steps        ctrlSteps      = findControlRecu(this.Page, "editdelete")   as Steps;
       Step         ctrlStep2      = findControlRecu(this.Page, "step2")        as Step;
       DateBoxRange ctrlDateRange  = findControlRecu(this.Page, "entrydaterange")    as DateBoxRange;
      
       string dateRangeStr = Util.GenerateDateRange(Constants.SVC_REC_EDIT_DATE_RANGE_CONST);
       ctrlStep2.label     = dateRangeStr;
       ctrlDateRange.value = dateRangeStr;       
       ctrlSteps.firstStep = 2;
    }
  }
}
