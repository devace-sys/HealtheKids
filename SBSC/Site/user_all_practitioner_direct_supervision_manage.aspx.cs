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
   * UserAllPractitionerDirectSupervisionManage*/
  /**
   * 
   ***************************************************************************/

  public class UserAllPractitionerDirectSupervisionManage : WebUI
  {
    
    public UserAllPractitionerDirectSupervisionManage() : base (  "supervision_manage"
                                                                , PractitionerDirectSupervisedSupervisors.SEL_LABEL_MANAGE
                                                                , "user_all_practitioner_direct_supervision_manage.css"
                                                                , ""
                                                                , Constants.ROLE_PRAC_DIR_SUP_ADMINS) { }
    protected void Page_Load(object sender, EventArgs e)
    {   
      

      /* Perform additional access verification */

      PractitionerDirectSupervisors.verifyIfUserIsSomeoneWhoCanManageDirectSupervisionTracking(uInfo);
            

      var ctrlSelectReportingGroup =  findControlRecu(this.Page, @"selectReportingGroup") as MBA.DataEntryRowSelectPractitionerReportingGroup;
      var ctrlActive               =  findControlRecu(this.Page, @"active")               as MBA.RadioBox;
      
      /* If the user is a practitioner we need to see if we can show the select reporting group.  Note: If this is a prac that is not allowed
       * to access this screen, they will not get to this point. */
      
      if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID)
      {
        if (rd.wu.pr.pracIsLimitedToTheirReportingGroupForManagingDirectSupervisionTracking == false)
        {
          ctrlSelectReportingGroup.entryAllowed = true;                    
        }
      }

      /* Add options for selecting active/inactive relationships */
      
      ctrlActive.value = @"1";    
      ctrlActive.AddSelection(@"Active Relationships",     "1");
      ctrlActive.AddSelection(@"Inactive Relationships", "0");
    
      
      }
  }
}
