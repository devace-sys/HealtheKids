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
     * userAllPatManage */
    /**
     ***************************************************************************/

    public class userAllPatManage : WebUI
    {
        public userAllPatManage() : base(@"user_all_pat_manage"
                                      , Patients.SEL_LABEL_MANAGE
                                      , @""
                                      , @""
                                      , Constants.ROLE_ALL_PCAL_AND_CLIENT)
        { }
        
        public bool showCybhiOptions = false;
        protected void Page_Load(object sender, EventArgs e)
        {
            /*-------------------------------
             * Determine if we show or hide
             * CYBHI export options
             * Currently only PCAL staff
             * can see these options.
             *------------------------------*/
         
            if (uInfo.pcalStaff == true)
            {
              showCybhiOptions = true;
            }


            /*-------------------------------
             * Locate data controls
             *------------------------------*/

            DataEntryRowIframeContentEntitySaveOrView ctrlIframeContent = findControlRecu(this.Page, "patIframeContent") as DataEntryRowIframeContentEntitySaveOrView;

            /*-------------------------------
             * Set URL parameters for 
             * DataEntryRowIframeContentEntitySaveOrView
             *------------------------------*/
            
            ctrlIframeContent.urlAddNew = MBA.HttpApplication.createLink(Spedmon.Patients.URL_USER_ALL_SAVE
                                                                        , true
                                                                        , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)
                                                                        , new NameValue(Constants.PARM_CONTENT_ONLY, 1));

            ctrlIframeContent.urlEdit   = MBA.HttpApplication.createLink(Spedmon.Patients.URL_USER_ALL_SAVE
                                                                        , true
                                                                        , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                                                        , new NameValue(Constants.PARM_CONTENT_ONLY, 1));

            ctrlIframeContent.urlView   = MBA.HttpApplication.createLink(Spedmon.Patients.URL_USER_ALL_VIEW
                                                                        , true
                                                                        , new NameValue(Constants.PARM_CONTENT_ONLY, 1));
        }
    }
}