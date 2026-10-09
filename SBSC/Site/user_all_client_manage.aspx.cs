using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Text;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * userAllClientManage */
    /**
     *
     ***************************************************************************/

    public class userAllClientManage : WebUI
    {
        public userAllClientManage() : base(Clients.SCREEN_TITLE_MANAGE
                                      , Clients.SEL_LABEL_MANAGE
                                      , @""
                                      , @""
                                      , Constants.ROLE_SBS_ALL)
        { }

        protected void Page_Load(object sender, EventArgs e)
        {
            /*-------------------------------
             * Locate data controls
             *------------------------------*/

            DataEntryRowIframeContentEntitySaveOrView ctrlIframeContent = findControlRecu(this.Page, "clientIframeContent") as DataEntryRowIframeContentEntitySaveOrView;

            /*-------------------------------
             * Set URL parameters for 
             * DataEntryRowIframeContentEntitySaveOrView
             *------------------------------*/
            ctrlIframeContent.urlAddNew = MBA.HttpApplication.createLink(Spedmon.Clients.URL_USER_ALL_SAVE
                                                                      , true
                                                                      , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)
                                                                      , new NameValue(Constants.PARM_CONTENT_ONLY, 1));
            ctrlIframeContent.urlEdit   = MBA.HttpApplication.createLink(Spedmon.Clients.URL_USER_ALL_SAVE
                                                                      , true
                                                                      , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                                                      , new NameValue(Constants.PARM_CONTENT_ONLY, 1));
            ctrlIframeContent.urlView = MBA.HttpApplication.createLink(Spedmon.Clients.URL_USER_ALL_VIEW
                                                          , true
                                                          , new NameValue(Constants.PARM_CONTENT_ONLY, 1));
        }
    }
}