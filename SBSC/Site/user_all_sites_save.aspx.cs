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
    /***************************************************************************
     * SitesSave */
    /***************************************************************************/

    public class UserAllSitesSave : WebUI
    {
        public int saveType = 0;

        public UserAllSitesSave() : base("Sites_save", WebUI.CreatePageSubTitle(Sites.SEL_LABEL, Sites.SEL_LABEL_ADD), "user_all_sites_save.css", "", Constants.ROLE_ALL_PCAL_AND_CLIENT) { }

        protected void Page_Load(object sender, EventArgs e)
        {
            /*-------------------------------
             * Determine what save type
             * this is 
             *------------------------------*/

            string recid     = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
            string savetype  = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);

            Object vSaveType = MBA.Validate.optInteger(savetype, Messages.INVALID_SAVE_TYPE);

            if (vSaveType == null)
                vSaveType = Constants.SAVE_TYPE_NEW;

            saveType = (int)vSaveType;

            var ctrlSaveOrEdit       = findControlRecu(this.Page, "saveOrEdit")       as MBA.DataEntryRowSaveOrEdit;
            var ctrlCybhiTpaApproved = findControlRecu(this.Page, "cybhitpaapproved") as SelectYesOrNo;
            
            ctrlSaveOrEdit.saveType = saveType;

            if (saveType == Constants.SAVE_TYPE_NEW) { 
              ctrlCybhiTpaApproved.setValue(false); /* Default value for new */
            }

            else if (saveType == Constants.SAVE_TYPE_EDIT) 
            {
                //locate record and if not found get out

                Site site = Sites.load(dbConnApp, log, uInfo, recid);

                //locate data controls
                
                DataEntryRowSelectClient ctrlClientID = findControlRecu(this.Page, "selectClient") as DataEntryRowSelectClient;
                WebUIControlDataField ctrlName = findControlRecu(this.Page, "name") as WebUIControlDataField;
                WebUIControlDataField ctrlCds7 = findControlRecu(this.Page, "cds7") as WebUIControlDataField;
                FieldSetUSPSAddress ctrlAddress = findControlRecu(this.Page, "selectAddress") as FieldSetUSPSAddress;
                WebUIControlDataField ctrlClientprovidedsiteuid = findControlRecu(this.Page, "client_provided_site_uid") as WebUIControlDataField;
                DataEntryRow ctrlClientprovidedsiteuidRow = findControlRecu(this.Page, "selectClientProvidedSiteUID") as DataEntryRow;
                var ctrlPhoneNumber = findControlRecu(this.Page,"phonenumber") as MBA.DataEntryBoxText;
            
                DataEntryBoxDate ctrlCybhiTpaApprovedOn = findControlRecu(this.Page, "cybhitpaapprovedon") as DataEntryBoxDate;

                //populate data values

                ctrlSaveOrEdit.recID = site.id.ToString();
                ctrlCds7.value = site.cds7;
                ctrlName.value = site.name;
                ctrlAddress.parmValueStreet1 = site.address1;
                ctrlAddress.parmValueStreet2 = site.address2;
                ctrlAddress.parmValueCity    = site.city;
                ctrlAddress.parmValueState   = site.state;
                ctrlAddress.parmValueZip5    = site.zip5;
                ctrlAddress.parmValueZip4    = site.zip4;

                ctrlPhoneNumber.value = site.phoneNumber;
                ctrlClientprovidedsiteuid.value   = site.clientProvidedSiteUID;
                ctrlClientprovidedsiteuidRow.entryAllowed = false;
                ctrlClientID.entryNotAllowedUseReplacementValue = false;

                ctrlCybhiTpaApproved.setValue(site.cybhiTpaApproved);
                ctrlCybhiTpaApprovedOn.value = site.cybhiTpaApprovedOn;

                /*------------------------------------*/
                /*  Handle client selection           */
                /*------------------------------------*/

                if (!String.IsNullOrWhiteSpace(site.clientID.ToString()))
                {
                    Client c = Clients.load(dbConnApp, log, uInfo, site.clientID.ToString());
                    ctrlClientID.selectValue = c.id.ToString();
                    ctrlClientID.selectName = c.name;
                    ctrlClientID.entryAllowed = false;
                    ctrlClientID.entryNotAllowedUseReplacementValue = false;
                }

                // Set title

                this.subTitle = WebUI.CreatePageSubTitle(Sites.SEL_LABEL, Sites.SEL_LABEL_EDIT);
            } 
           
        }
    }

}


