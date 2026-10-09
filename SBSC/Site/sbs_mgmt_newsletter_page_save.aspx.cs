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
using System.Text;

using MBA;



namespace Spedmon
{
    public class SBSMgmtNewsletterPageSave : WebUI
    {
        public int saveType = 0;

        public SBSMgmtNewsletterPageSave() : base("man_page_save"
                                                , "Create New MultiMedia Newsletter"
                                                 , "sbs_mgmt_man_page_save.css"  // TODO: ????
                                            , ""
                                            , Constants.ROLE_ANNOUNCEMENT_ADMIN)
        { }

        protected void Page_Load(object sender, EventArgs e)
        {
            /*-------------------------------
             * Determine what save type
             * this is
             *------------------------------*/

            string recid = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
            string savetype = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);

            Object vSaveType = MBA.Validate.optInteger(savetype, Messages.INVALID_SAVE_TYPE);

            if (vSaveType == null)
                vSaveType = Constants.SAVE_TYPE_NEW;

            saveType = (int)vSaveType;


            DataEntryRowSaveOrEdit ctrlSaveOrEdit   = findControlRecu(this.Page, "saveOrEdit") as DataEntryRowSaveOrEdit;
            MBA.DateBoxHTML5 ctrlStartDate          = findControlRecu(this.Page, "startdate") as MBA.DateBoxHTML5;
            MBA.ComboBox ctrlForContactsRoleIds     = findControlRecu(this.Page, "forcontactroleids") as MBA.ComboBox;
            MBA.ComboBox ctrlForClientIds           = findControlRecu(this.Page, "forclientids") as MBA.ComboBox;

            MBA.ComboBox ctrlForUserRoleIds      = findControlRecu(this.Page, "foruserroleids") as MBA.ComboBox;
            MBA.TextBox ctrlTitle                = findControlRecu(this.Page, "announcementtitle") as MBA.TextBox;
            MBA.RichTextAreaBox ctrlContent      = findControlRecu(this.Page, "announcementcontent") as MBA.RichTextAreaBox;

            MBA.SelectYesOrNo ctrlReadyToSend         = findControlRecu(this.Page, "readyToSend") as MBA.SelectYesOrNo;

            MBA.SelectYesOrNo ctrlIsResourceLibTopic  = findControlRecu(this.Page, "isresourcelibrarytopic") as MBA.SelectYesOrNo;

            MBA.SelectYesOrNo ctrlSendEmailSelected = findControlRecu(this.Page, "sendEmailSelected") as MBA.SelectYesOrNo;

            MBA.DataEntryBoxTextArea ctrlTags                = findControlRecu(this.Page, "tags") as MBA.DataEntryBoxTextArea;
            MBA.DataEntryBoxTextArea ctrlTooltip             = findControlRecu(this.Page, "tooltip") as MBA.DataEntryBoxTextArea;

            //ctrlReadyToSend.value = "No";
            //looks like if .value is assigned it can't be re-assigned a few lines down in this method???

            if (saveType == Constants.SAVE_TYPE_EDIT)
            {

                //this.subTitle = WebUI.CreatePageSubTitle(ManPages.SEL_LABEL, ManPages.SEL_LABEL_EDIT);

                NewsletterPage rec = NewsletterPages.load(dbConnApp, log, uInfo, recid);


                if ( rec.sentToAll )
                  this.subTitle = "Edit MultiMedia Newsletter For Reissue";
                else
                  this.subTitle = "Edit MultiMedia Newsletter";

                ctrlSaveOrEdit.saveType = saveType;
                ctrlSaveOrEdit.recID = rec.id.ToString();

                ctrlStartDate.value = (rec.startDate == DateTime.MinValue) ?
                                                              "" : rec.startDate.ToString("yyyy-MM-dd");

                //ctrlForContactsRoleIds.multiSelectLoad = true; // Tell control we want to load multi values

                if (rec.forContactRoleIdValsStr != null) {
                  ctrlForContactsRoleIds.multiSelectLoad = true;

                  ctrlForContactsRoleIds.multiSelectNames = rec.forContactRoleNamesStr;
                  ctrlForContactsRoleIds.multiSelectValues = rec.forContactRoleIdValsStr;
                  ctrlForContactsRoleIds.multiSelectContextLabels = "";
                }

                //ctrlForClientIds.multiSelectLoad = true; // Tell control we want to load multi values

                if (rec.forClientIdValsStr != null) { 
                  ctrlForClientIds.multiSelectLoad = true;

                  ctrlForClientIds.multiSelectNames = rec.forClientNamesStr;
                  ctrlForClientIds.multiSelectValues = rec.forClientIdValsStr;
                  ctrlForClientIds.multiSelectContextLabels = "";
                }

                //ctrlForUserRoleIds.multiSelectLoad = true; // Tell control we want to load multi values

                if (rec.forUserRoleIdValsStr != null) {
                  ctrlForUserRoleIds.multiSelectLoad = true;

                  ctrlForUserRoleIds.multiSelectNames = rec.forUserRoleNamesStr;
                  ctrlForUserRoleIds.multiSelectValues = rec.forUserRoleIdValsStr;
                  ctrlForUserRoleIds.multiSelectContextLabels = "";
                }

                ctrlTitle.value = rec.title;

                ctrlContent.value = rec.content;

                ctrlTags.value     = rec.tags;
                ctrlTooltip.value  = rec.tooltip;

                //ctrlReadyToSend.value = Util.boolToYesNo( rec.readyToSend );
                // not working for some reason

                if  (rec.readyToSend)
                  ctrlReadyToSend.value = "Yes";
                else
                  ctrlReadyToSend.value = "No";


                if (rec.sendEmailSelected)
                    ctrlSendEmailSelected.value = "Yes";
                else
                    ctrlSendEmailSelected.value = "No";


                ctrlIsResourceLibTopic.setValue(rec.isResourceLibraryTopic);                

            }
            /* New record */
            else
            { 
                ctrlReadyToSend.value        = "No";
                ctrlIsResourceLibTopic.value = "No";
            }

        }



    }

}
