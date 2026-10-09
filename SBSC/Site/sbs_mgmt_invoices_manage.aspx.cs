using System;
using MBA;


namespace Spedmon
{

    public class sbsMgmtInvoicesManage : WebUI
    {
        public sbsMgmtInvoicesManage() : base("sbs_mgmt_invoices_manage"
                                            , ClientInvoices.SEL_LABEL_MANAGE
                                            , "sbs_mgmt_invoices_manage.css"
                                            , "client-invoices.js"
                                            , Constants.ROLE_MANAGE_INVOICES  )
        { }
        
        public bool   isPCalStaff                    = false;
        public string isPcalStaffJSBoolStr           = "";
        public bool   userCanSeePartnerData          = false;
        public string userCanSeePartnerDataJSBoolStr = "";
        public bool   isManageInvoiceScreen          = true;
        public string manageInvoiceScreenBoolStr     = "";


        protected void Page_Load(object sender, EventArgs e)
        {

            isPCalStaff          = uInfo.pcalStaff;
            isPcalStaffJSBoolStr = Util.netBoolToJSBool(isPCalStaff);

            userCanSeePartnerData = ClientInvoices.userCanSeePartnerData(uInfo);

            userCanSeePartnerDataJSBoolStr = Util.netBoolToJSBool(userCanSeePartnerData);

            manageInvoiceScreenBoolStr = Util.netBoolToJSBool(isManageInvoiceScreen);


            var ctrlDateRange           = findControlRecu(this.Page, @"daterange")          as DateBoxRange;
            var ctrlInvoicepaid         = findControlRecu(this.Page, @"invoicepaid")        as MBA.RadioBox;
            var ctrlManageInvoiceIndex  = findControlRecu(this.Page, @"manageinvoiceindex") as MBA.TextBox;

            ctrlDateRange.value = Util.GenerateDateRange(3);
            ctrlManageInvoiceIndex.value = "1";

            // set up radio box for paid filter
            ctrlInvoicepaid.value = ""; /* Default */

            ctrlInvoicepaid.AddSelection(@"All"        , "");
            ctrlInvoicepaid.AddSelection(@"Paid"       , "true");
            ctrlInvoicepaid.AddSelection(@"Uncollected", "false");
        }
    }
}