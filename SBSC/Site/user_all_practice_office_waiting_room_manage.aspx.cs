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
   * UserAllPracticeOfficeWaitingRoomManage */
  /**
   * 
   ***************************************************************************/

  public class UserAllPracticeOfficeWaitingRoomManage : WebUI
  {

    public UserAllPracticeOfficeWaitingRoomManage() : base (  Util.createUniqueID()
                                                           , @"Waiting Room"
                                                           , @"practice-office-visits.css"
                                                           , @"practice-office-visits.js"
										                   , Constants.ROLE_ALL_PCAL_AND_CLIENT) { }
    public bool   pageInitIsOK           = false;
    public long   groupSvcClassNameID    = -1;
    public bool   isPrac                 = false;
    public string pracIDStr              = "";
    protected void Page_Load(object sender, EventArgs e)
    {

      /***************************************************************************
       * Determine if user is practitioner
       ***************************************************************************/     

      isPrac    = false;
      pracIDStr = "";
      if (uInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID)
      {                 
         pracIDStr = uInfo.userPracIDStr;
         isPrac = true;
      }

      /***************************************************************************
       * Set content options
       ***************************************************************************/      

      //this.renderOptionContentOnly = true; /* Render content only */

      /***************************************************************************
       * Get control references
       ***************************************************************************/
      
      var ctrlGroupSvcClassNameID       = findControlRecu (this.Page, Constants.PARM_GRP_SVC_CLS_NME_ID) as MBA.HiddenInput;
      var ctrlLinkReviewCompletedVisits = findControlRecu (this.Page, @"gotomanagecompletedvisits")      as MBA.LinkInternal;

      /***************************************************************************
       * Get parameters passed
       ***************************************************************************/

      /* Get practice family */

      string groupSvcClassNameIDStr = MBA.HttpApplication.getParameter(Constants.PARM_GRP_SVC_CLS_NME_ID);
               
      /* If practice family is passed set the page title and label*/

      if (long.TryParse(groupSvcClassNameIDStr,out groupSvcClassNameID)) { 

        pageInitIsOK = true;
        ctrlGroupSvcClassNameID.value = groupSvcClassNameIDStr;
        this.subTitle = PracticeOfficeCommon.SEL_LABEL_WAITING_ROOM(groupSvcClassNameID, true);
        ctrlLinkReviewCompletedVisits.url = PracticeOfficeCommon.URL_COMPLETED_VISITS_MANAGE_BASE;     
        ctrlLinkReviewCompletedVisits.addParameter(new NameValue(Constants.PARM_GRP_SVC_CLS_NME_ID,groupSvcClassNameIDStr));
      }
      else {
        pageInitIsOK = false;
      }

      
    }
  }
}
