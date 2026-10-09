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
   * UserAllPracticeOfficeCompletedVisitsManage */
  /**
   * 
   ***************************************************************************/

  public class UserAllPracticeOfficeCompletedVisitsManage : WebUI

  {

    public UserAllPracticeOfficeCompletedVisitsManage() : base(  Util.createUniqueID()
                                                              , @"Completed Visits"
                                                              , @"practice-office-visits.css"
                                                              , @"form-builder-patient-goal.js|user_all_patient_goal_progress_reporting.js|practice-office-visits.js"
                                                              , Constants.ROLE_ALL_PCAL_AND_CLIENT) { }
    public bool   pageInitIsOK           = false;
    public long   groupSvcClassNameID    = -1;
    
	protected void Page_Load(object sender, EventArgs e)
    {


      /***************************************************************************
       * Set content options
       ***************************************************************************/      

      //this.renderOptionContentOnly = true; /* Render content only */

      /***************************************************************************
       * Get control references
       ***************************************************************************/
      
      var ctrlGroupSvcClassNameID = findControlRecu (this.Page, Constants.PARM_GRP_SVC_CLS_NME_ID) as MBA.HiddenInput;

      /***************************************************************************
       * Get parameters passed
       ***************************************************************************/

      /* Get practice family */

      string groupSvcClassNameIDStr = MBA.HttpApplication.getParameter(Constants.PARM_GRP_SVC_CLS_NME_ID);
               
      /* If practice family is passed set the page title and label*/

      if (long.TryParse(groupSvcClassNameIDStr,out groupSvcClassNameID)) { 

        pageInitIsOK = true;
        ctrlGroupSvcClassNameID.value = groupSvcClassNameIDStr;
        this.subTitle = PracticeOfficeCommon.SEL_LABEL_COMPLETED_VISITS(groupSvcClassNameID, true);
      }
      else {
        pageInitIsOK = false;
      }

      
    }
  }
}
