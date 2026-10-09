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

/***************************************************************************
 * PracticeOfficePublicCheckIn */
/**
 * Public page for users to check in to a practice office
 ***************************************************************************/

namespace Spedmon
{
  public class PracticeOfficePublicCheckIn : WebUI3
  {
    public bool   pageInitIsOK            = true;
    public string ptkn                    = @"";    
    public string checkInSvcURL           = @"";
    public string visitReasonsOptionsHTML = @"";

    public PracticeOfficeKioskPublic rec = new PracticeOfficeKioskPublic();
    public PracticeOfficePublicCheckIn() : base("practice_office_public_check_in"
                                                ,""
                                                ,""
                                                ,""){}
    protected void Page_Load(object sender, EventArgs e)
    { 
      this.renderOptionContentOnly = true;
      
      try { 

        string groupSvcClassNameIDStr     = @"";                          
        ptkn = MBA.HttpApplication.getParameter(Constants.PARM_PUBLIC_TOKEN);

        if (String.IsNullOrWhiteSpace(ptkn)) {
          pageInitIsOK = false;
          return;
        }
                   
        rec = PracticeOfficeCommon.getPracticeOfficeKioskByPtkn(dbConnApp,log,ptkn);
        if (rec.recFound == false) {
          pageInitIsOK = false;
          return;
        }
        groupSvcClassNameIDStr = rec.groupSvcClassNameID.ToString();
        uInfo = new UserInfo();      
        visitReasonsOptionsHTML = Spedmon.PracticeOfficeVisitReasons.generateSelectOptionsMarkup(dbConnApp,log,uInfo,groupSvcClassNameIDStr);
        checkInSvcURL           = Spedmon.PracticeOfficeVisits.URL_SVC_CHECK_IN_FROM_PUBLIC_KISOK_BASE();
      } 
      catch {
        pageInitIsOK = false;
        return;
      }
    }
  }
}
