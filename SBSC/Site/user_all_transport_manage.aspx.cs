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
     * userAllTransportManage */
    /**
     ***************************************************************************/

    public class userAllTransportManage : WebUI
    {
        public userAllTransportManage() : base(@"user_all_transport_manage"
                                      , TransportationMgmtRecords.SEL_LABEL
                                      , @""
                                      , @""
                                      , Constants.ROLE_SBS_ALL)
        { }

        protected void Page_Load(object sender, EventArgs e)

        {
            /*-------------------------------
             * Locate data controls
             *------------------------------*/

            DataEntryRowIframeContentEntitySaveOrView ctrlIframeContent = findControlRecu(this.Page, "transportationIframeContent") as DataEntryRowIframeContentEntitySaveOrView;

            /*-------------------------------
             * Set URL parameters for 
             * DataEntryRowIframeContentEntitySaveOrView
             *------------------------------*/            
            ctrlIframeContent.urlEdit   = MBA.HttpApplication.createLink(Spedmon.TransportationMgmtRecords.URL_USER_ALL_MANAGE_PATIENTS_AND_ROUTES
                                                                        , true
                                                                        , new NameValue(Constants.PARM_CONTENT_ONLY, 1));
        }
    }
}