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
   * UserAllPracticeOfficeKiosk */
  /**
   * 
   ***************************************************************************/

  public class UserAllPracticeOfficeKiosk : WebUI

  {

    public UserAllPracticeOfficeKiosk() : base (  PracticeOfficeCommon.BODY_ID_KIOSK
                                                , "Check In Kiosk"
                                                , @"user_all_practice_office_kiosk.css"
                                                , @"user_all_practice_office_kiosk.js"
										        , Constants.ROLE_ALL_PCAL_AND_CLIENT) { }
    public bool pageInitIsOK       = false;

    public long groupSvcClassNameID = -1;
    protected void Page_Load(object sender, EventArgs e)
    {
     
      /***************************************************************************
       * Set content options
       ***************************************************************************/      
    
      this.renderOptionContentOnly = true; /* Render content only */

      /***************************************************************************
       * Get parameters
       ***************************************************************************/      
       
      string groupSvcClassNameIDStr = MBA.HttpApplication.getParameter(Constants.PARM_GRP_SVC_CLS_NME_ID);   /* Get practice family */

      /***************************************************************************
       * Get control references
       ***************************************************************************/      

      var ctrlGroupSvcClassNameID        = findControlRecu (this.Page, Constants.PARM_GRP_SVC_CLS_NME_ID)                as MBA.HiddenInput;
      var ctrlPracticeOfficeVisitReasons = findControlRecu (this.Page, Constants.PARM_PRACTICE_OFFICE_VISIT_REASON_ID)   as MBA.DataEntryBoxSelect;
      
      /* If practice family is passed */

      if (long.TryParse(groupSvcClassNameIDStr,out groupSvcClassNameID)) { 

          pageInitIsOK = true;

          /* Set page title and label */

          this.subTitle = "Kiosk";

          /* Set practice family */
          
          ctrlGroupSvcClassNameID.value = groupSvcClassNameIDStr;

          /* Get practice family reasons */

          var practiceOfficeVisitReasons = PracticeOfficeVisitReasons.viewList(dbConnApp,log,uInfo,groupSvcClassNameIDStr,"Y");

          /* Add these as selections */

          foreach (var practiceOfficeVisitReason in practiceOfficeVisitReasons) { 
            ctrlPracticeOfficeVisitReasons.addSelection(new NameValue(practiceOfficeVisitReason.name,practiceOfficeVisitReason.id,@""));
          }

      } 
      else {        
        pageInitIsOK = false;
      }

    }
  }
}
