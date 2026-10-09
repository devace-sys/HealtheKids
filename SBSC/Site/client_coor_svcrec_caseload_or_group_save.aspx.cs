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
     * ClientCoorServiceRecordCaseloadOrGroupSave */
    /**
     * Saves a service record
     ***************************************************************************/

    public class ClientCoorServiceRecordCaseloadOrGroupSave: WebUI
    {
      public int saveType = Constants.SAVE_TYPE_NEW;      
      public Practitioner pracObj = null; 


      public ClientCoorServiceRecordCaseloadOrGroupSave() : base("service_record_caseload_or_group_save", ServiceRecords.SEL_LABEL_SVREC_NON_PRAC, "", "", Constants.ROLE_CLIENT_BO) { }
     
        
        protected void Page_Load(object sender, EventArgs e)
      {
        /* If user is logged in get client and prac id */
      
           
        if (rd.loggedIn) 
        {
            String clientID = Spedmon.Validate.optClientID(uInfo, "").ToString();
            String pracID   = Spedmon.Validate.reqPracID(uInfo, MBA.HttpApplication.getParameter(@"pracid")).ToString();
            
            pracObj = Practitioners.load(dbConnApp, log, uInfo, pracID);
            
            Steps ctrlSteps = findControlRecu(this.Page, "save") as Steps;
            Step  ctrlStep1 = findControlRecu(this.Page, "step1") as Step;

            WebUIControlDataField ctrlIsIEP          = findControlRecu(this.Page, "isiep") as WebUIControlDataField;
            WebUIControlDataField ctrlClientID       = findControlRecu(this.Page, "clientid") as WebUIControlDataField;
            WebUIControlDataField ctrlPracID         = findControlRecu(this.Page, "pracid") as WebUIControlDataField;
            WebUIControlDataField ctrlOrganizationID = findControlRecu(this.Page, "organizationID") as WebUIControlDataField;
            WebUIControlDataField ctrlOwnerID        = findControlRecu(this.Page, "ownerID") as WebUIControlDataField;

            ctrlStep1.label = Util.boolToYesNo(true);
            ctrlIsIEP.value = Util.boolToYesNo(true);
            ctrlClientID.value = clientID;
            ctrlPracID.value = pracID;
            ctrlOrganizationID.value = ctrlClientID.value;
            ctrlOwnerID.value = ctrlPracID.value;

            ctrlSteps.firstStep = 1;
           
        }
      
      }
    }
}