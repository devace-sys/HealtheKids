using System;
using System.Collections;
using MBA;

namespace Spedmon
{
    public class SBSAllManageServiceNameFormDataFillablePdfFiles : WebUI
    {
        public SBSAllManageServiceNameFormDataFillablePdfFiles() : base(
                                              "sbs_all_manage_service_name_form_data_fillable_pdf_files"
                                            , "Manage Fillable PDF Files"
                                            , ""
                                            , "stored-files.js"
                                            , Constants.ROLE_ANNOUNCEMENT_ADMIN)
        { 
		}
		
        public bool   pageParmsOK              = false;
        public bool   isPCalStaff              = false;
        public string isPcalStaffJSBoolStr     = "";

        protected void Page_Load(object sender, EventArgs e)
        {     
          isPCalStaff          = uInfo.pcalStaff;
          isPcalStaffJSBoolStr = Util.netBoolToJSBool(isPCalStaff);
          var ctrlClientID     = findControlRecu (this.Page, "selectClient") as MBA.DataEntryRowSelectClient;
          string clientIDStr   = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

          if (!String.IsNullOrWhiteSpace(clientIDStr))
          {
            var _clt = Clients.load(dbConnApp,log,uInfo,clientIDStr);
            ctrlClientID.selectName  = _clt.name;
            ctrlClientID.selectValue = clientIDStr;
            pageParmsOK = true;
          }
          else
          { 
            pageParmsOK = false;
          }
        }
    }
}