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
     * SbsMgmtNewslettersManage */
    /**
     * 
     ***************************************************************************/


    public partial class SbsMgmtNewslettersManage : WebUI
    {

        public string pagenav_load_url = MBA.HttpApplication.createLink(
          NewsletterPages.URL_PAGEVIEW_BASE ,
          true //,
          //new NameValue("amd" , "uidbssub" )
         );

        public SbsMgmtNewslettersManage() : base("sbs_mgmt_newsletters_manage"
                                        , NewsletterPages.SEL_LABEL_MANAGE
                                        , @""
                                        , @""
                                        , Constants.ROLE_ANNOUNCEMENT_ADMIN) { }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}