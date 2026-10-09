using System;
using MBA;


namespace Spedmon
{


    public class sbsMgmtPartnerRetentioniDistrManage : WebUI
    {

        public sbsMgmtPartnerRetentioniDistrManage() : base("sbs_mgmt_partnerdist_retention_manage"
                                            , @"Client Retention Partner Distributions Manage" //ClientInvoices.SEL_LABEL_MANAGE
                                            , "sbs_mgmt_partner_distributions_manage.css"  //
                                            , "client-invoices.js"      
                                            , Constants.ROLE_MANAGE_PARTNER_SHARES)
        { }
        
        public bool   isPCalStaff                    = false;
        public string isPcalStaffJSBoolStr           = "";
        public bool   userCanSeePartnerData          = false;
        public string userCanSeePartnerDataJSBoolStr = "";

        public bool   isManageInvoiceScreen          = false;  // IS FALSE
        public string manageInvoiceScreenBoolStr     = "";

        protected void Page_Load(object sender, EventArgs e)
        {

            isPCalStaff          =  uInfo.pcalStaff;
            isPcalStaffJSBoolStr = Util.netBoolToJSBool(isPCalStaff);

            userCanSeePartnerData = ClientInvoices.userCanSeePartnerData(uInfo);
            userCanSeePartnerDataJSBoolStr = Util.netBoolToJSBool(userCanSeePartnerData);


            manageInvoiceScreenBoolStr = Util.netBoolToJSBool(isManageInvoiceScreen);


            //  var ctrlDistbpaiddaterange           =   findControlRecu(this.Page, @"distbpaiddaterange")          as DateBoxRange;
            //  var ctrlInvoicepaid                  =   findControlRecu(this.Page, @"invoicepaid")        as MBA.RadioBox;

            // ctrlDistbpaiddaterange.value = Util.GenerateDateRange(3);


            var ctrlInvCollDaterange              =   findControlRecu(this.Page, @"invcolldaterange")          as  DateBoxRange;

            var ctrlInvoicepaid                   =   findControlRecu(this.Page, @"invoicepaid")                 as  MBA.RadioBox;


            ctrlInvCollDaterange.value = Util.GenerateDateRange(3);


            var ctrlDistbpaid         = findControlRecu(this.Page, @"distbpaid")        as MBA.RadioBox;


            // set up radio box for paid filter
            ctrlInvoicepaid.value = "";   /* Default */
            ctrlDistbpaid.value = "";     /* Default */


            ctrlDistbpaid.AddSelection(@"Distributions Paid"       , "true");
            ctrlDistbpaid.AddSelection(@"Distributions Unpaid", "false");
            ctrlDistbpaid.AddSelection(@"All"        , "");


            ctrlInvoicepaid.AddSelection(@"All"        , "");
            ctrlInvoicepaid.AddSelection(@"Invoices Uncollected", "false");
            ctrlInvoicepaid.AddSelection(@"Invoices Paid"       , "true", true);

        }
    }
}