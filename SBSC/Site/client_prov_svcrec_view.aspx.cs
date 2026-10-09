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
  * ServiceRecordView */
  /**
  * Record new service record
  ***************************************************************************/   

  public class ClientProvServiceRecordsView : WebUI
  {
    public bool showServiceRecordSharingNotice = false;
    public ClientProvServiceRecordsView() : base("service_records_view","Service Records - View","","",Constants.ROLE_LEA_PROVIDER){}
    protected void Page_Load(object sender, EventArgs e)
    {
       /* Go straight to view with date range of current fiscal year */
       
       Steps        ctrlSteps      = findControlRecu(this.Page, "viewexisting") as Steps;
       Step         ctrlStep2      = findControlRecu(this.Page, "step2")        as Step;
       DateBoxRange ctrlDateRange  = findControlRecu(this.Page, "daterange")    as DateBoxRange;
      
       string dateRangeStr = Util.GenerateDateRange(3);
       ctrlStep2.label     = dateRangeStr;
       ctrlDateRange.value = dateRangeStr;       
       ctrlSteps.firstStep = 2;

       /* Determine whether or not to show service record sharing notice */

       showServiceRecordSharingNotice = ServiceRecords.isOKForUserToSeeOtherUsersServiceRecordsOrNotes(uInfo);
       
     }
    
  }
}