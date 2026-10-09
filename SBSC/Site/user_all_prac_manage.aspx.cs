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
     * userAllPracManage */
    /**
     *
     ***************************************************************************/

    public class userAllPracManage : WebUI
    {
        public userAllPracManage() : base(@"user_all_prac_manage"
                                      , Practitioners.SEL_LABEL_MANAGE
                                      , @""
                                      , @""
                                      , Constants.ROLE_SVC_SUP_PRAC)
        { }

        public bool showCybhiOptions                     = false;
        public bool showDownloadMissingOrExpiredQualsRpt = false;

        // allow hotlinking to a specific pracID, from other pages and restview cells
        public string iframePrefill = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            /*-------------------------------
             * Determine if we show or hide
             * CYBHI export options or show or
             * hide missing/expired quals rept
             * Currently only PCAL staff
             * can see these options.
             *------------------------------*/

            if (uInfo.pcalStaff == true)
            {             
                showCybhiOptions                     = true;
                showDownloadMissingOrExpiredQualsRpt = true;
            }

            /*-------------------------------
             * Locate data controls
             *------------------------------*/

            DataEntryRowIframeContentEntitySaveOrView ctrlIframeContent = findControlRecu(this.Page, "pracIframeContent") as DataEntryRowIframeContentEntitySaveOrView;

            /*-------------------------------
             * Set URL parameters for 
             * DataEntryRowIframeContentEntitySaveOrView
             *------------------------------*/
            
            ctrlIframeContent.urlAddNew = MBA.HttpApplication.createLink(Spedmon.Practitioners.URL_USER_ALL_SAVE
                                                                      , true
                                                                      , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)
                                                                      , new NameValue(Constants.PARM_CONTENT_ONLY, 1));
            
            ctrlIframeContent.urlEdit = MBA.HttpApplication.createLink(Spedmon.Practitioners.URL_USER_ALL_SAVE
                                                                      , true
                                                                      , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                                                      , new NameValue(Constants.PARM_CONTENT_ONLY, 1));
            
            ctrlIframeContent.urlView = MBA.HttpApplication.createLink(Spedmon.Practitioners.URL_USER_ALL_VIEW
                                                        , true
                                                        , new NameValue(Constants.PARM_CONTENT_ONLY, 1));



            if (!(Util.IsNullOrEmpty(MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID)))
                     &&
                     !(Util.IsNullOrEmpty(MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID)))
                     )
            {

                iframePrefill = MBA.HttpApplication.createLink(Spedmon.Practitioners.URL_USER_ALL_SAVE
                                                                , true
                                                                , new NameValue(Constants.PARM_CLIENT_ID,
                                                                    MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID)
                                                                  )
                                                                , new NameValue(Constants.PARM_REC_ID,
                                                                    MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID)
                                                                  )
                                                                , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                                                , new NameValue(Constants.PARM_CONTENT_ONLY, 1));

            }
        }

    }
}