using System;
using MBA;

namespace Spedmon
{
    public class UserAllCdeComplianceCurrentAuditManage : WebUI
    {
        public UserAllCdeComplianceCurrentAuditManage() : base(
                                              CdeComplianceCommon.BODY_ID_MANAGE_CURRENT_AUDIT
                                            , CdeComplianceCommon.SEL_LABEL_MANGE_FOR_CLIENT_CURRENT_AUDIT
                                            , @""
                                            , @""
                                            , Constants.ROLE_CDE_COMPLIANCE_MANAGE)
        { 
		}

        public bool   userIsPcalStaff                      = false;
        public string currentWindowStartDateStr            = @"";
        public string currentWindowEndDateStr              = @"";
        public string currentWindowStartAndEndDateRangeStr = @"";

		protected void Page_Load(object sender, EventArgs e)
        {
            var ctrlClientID          = findControlRecu (this.Page, "selectClient")            as MBA.DataEntryRowSelectClient;
            var ctrlStartDate         = findControlRecu (this.Page, Constants.PARM_START_DATE) as MBA.DataEntryBoxDate;
            var ctrlEndDate           = findControlRecu (this.Page, Constants.PARM_END_DATE)   as MBA.DataEntryBoxDate;
            var ctrlLinkManageOverall = findControlRecu (this.Page, "gotomanageoverall")       as MBA.LinkInternal;
            
            var ctrlLinkManageServiceDeliveryExceptions = findControlRecu (this.Page, "gotomanageservicedeliveryexceptions")             as MBA.LinkInternal;            
            var ctrlPatAbsMinsAreSatMins                = findControlRecu (this.Page, Constants.PARM_PAT_ABSENT_MINS_ARE_SATISFIED_MINS) as MBA.SelectYesIsNoOrNoIsYes;

            currentWindowStartDateStr = Spedmon.CdeComplianceCommon.getCurrentAuditPatientGroupStartDateStr (dbConnUser,log,uInfo);
            currentWindowEndDateStr   = Spedmon.CdeComplianceCommon.getCurrentAuditPatientGroupEndDateStr   (dbConnUser,log,uInfo);

            ctrlLinkManageOverall.url                   = Spedmon.CdeComplianceCommon.URL_MANAGE;
            ctrlLinkManageServiceDeliveryExceptions.url = Spedmon.PatientPromisedServicesDeliveryExceptions.URL_MANAGE;
            ctrlLinkManageServiceDeliveryExceptions.addParameter(new NameValue(Constants.PARM_DATA_SOURCE,PatientPromisedServicesDeliveryExceptions.DATA_SOURCE_CURRENT_CDE_AUDIT));

            ctrlStartDate.setValue(currentWindowStartDateStr);
            ctrlEndDate.setValue(currentWindowEndDateStr);
            ctrlPatAbsMinsAreSatMins.setValue(true); /* Patient absent minutes are considered satisfied is default */

            /* preselect clientid if passed */

            string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

            if (!String.IsNullOrEmpty(clientIDStr))
            {
                var _clt = Clients.load(dbConnApp,log,uInfo,clientIDStr);
                ctrlClientID.selectName  = _clt.name;
                ctrlClientID.selectValue = clientIDStr;
            }
            userIsPcalStaff = uInfo.pcalStaff;         
        }
    }
}