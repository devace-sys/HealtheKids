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
   * UserAllRMTSMomentsServiceRecords */
  /**
   * 
   ***************************************************************************/


  public class UserAllRptRMTSMomentServiceRecords : WebUI

  {

    public UserAllRptRMTSMomentServiceRecords() : base(RmtsMoments.MENU_LINK_RPT_RMTS_MOMENT_SERVICE_RECORDS + "page"
                                                 , RmtsMoments.SEL_LABEL_MANAGE
                                                 , @"user_all_service_records_manage.css"
                                                 , @""
										         , Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD) { }

    protected void Page_Load(object sender, EventArgs e)
    {

      //var ctrlActivityCodeSelection = findControlRecu(this.Page, "activitycodeselection") as MBA.RadioBox;
      //var ctrlDateRange             = findControlRecu(this.Page, "daterange")             as DateBoxRange;
     
      //ctrlActivityCodeSelection.AddSelection(@"All Codes", "");
      //ctrlActivityCodeSelection.AddSelection(@"2A", "2A",true);
      //ctrlActivityCodeSelection.AddSelection("2Z", "2Z");
      //ctrlActivityCodeSelection.AddSelection("8", "8");
            
      //ctrlActivityCodeSelection.value = "2A";

      //// initial value for date range

      //string dateRangeStr = Util.GenerateDateRange(Constants.SVC_REC_EDIT_DATE_RANGE_CONST);
      //ctrlDateRange.value = dateRangeStr;
      
    }
  }

}
