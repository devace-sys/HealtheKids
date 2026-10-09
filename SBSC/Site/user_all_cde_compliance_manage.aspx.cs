using System;
using MBA;

namespace Spedmon
{
    public class UserAllCdeComplianceManage : WebUI
    {
        public UserAllCdeComplianceManage() : base(
                                              CdeComplianceCommon.BODY_ID_MANAGE
                                            , CdeComplianceCommon.SEL_LABEL_MANAGE
                                            , @"user_all_cde_compliance_manage.css"
                                            , @""
                                            , Constants.ROLE_CDE_COMPLIANCE_MANAGE)
        { 
		}
        
        public string currentWindowStartDateStr            = @"";
        public string currentWindowEndDateStr              = @"";
        public string currentWindowStartAndEndDateRangeStr = @"";
        public bool   showSelpaExportOptions               = false;        
        public bool   showSvcThresholds                    = false;
		protected void Page_Load(object sender, EventArgs e)
        {
            this.includeBackgroundLayerMirrored = true;


            var ctrlClientID       = findControlRecu (this.Page, "selectClient")            as MBA.DataEntryRowSelectClient;
            var ctrlDosRange       = findControlRecu (this.Page, Constants.PARM_DATE_RANGE) as MBA.DateBoxRange;

            var ctrlLinkCurrAudit                       = findControlRecu (this.Page, "gotomanagecurrentaudit")                as MBA.LinkInternal;
            var ctrlLinkManageServiceDeliveryExceptions = findControlRecu (this.Page, "gotomanageservicedeliveryexceptions")   as MBA.LinkInternal;
            var ctrlLinkViewServiceOverDeliver          = findControlRecu (this.Page, "gotoreviewpossibleserviceoverdelivery") as MBA.LinkInternal;

            showSelpaExportOptions               = rd.wu.usr.pcalStaff;
            currentWindowStartDateStr            = Spedmon.CdeComplianceCommon.getCurrentWindowStartDateStr(dbConnUser,log,uInfo);
            currentWindowEndDateStr              = Spedmon.CdeComplianceCommon.getCurrentWindowEndDateStr  (dbConnUser,log,uInfo);
            currentWindowStartAndEndDateRangeStr = Util.startAndEndDateStrToDateRangeStr(currentWindowStartDateStr,currentWindowEndDateStr);

            ctrlDosRange.value                          = currentWindowStartAndEndDateRangeStr;
            ctrlLinkCurrAudit.url                       = Spedmon.CdeComplianceCommon.URL_MANAGE_CURRENT_AUDIT;
            ctrlLinkManageServiceDeliveryExceptions.url = Spedmon.PatientPromisedServicesDeliveryExceptions.URL_MANAGE;
            ctrlLinkManageServiceDeliveryExceptions.addParameter(new NameValue(Constants.PARM_DATA_SOURCE,PatientPromisedServicesDeliveryExceptions.DATA_SOURCE_ALL));

            ctrlLinkViewServiceOverDeliver.url = CdeComplianceBucketDetailsByService.URL_MANAGE;
            ctrlLinkViewServiceOverDeliver.addParameter(new NameValue(Constants.PARM_SVC_OVER_DELIVERY,"1"));

            /* preselect clientid if passed */

            string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

            if (!String.IsNullOrEmpty(clientIDStr))
            {
                var _clt = Clients.load(dbConnApp,log,uInfo,clientIDStr);
                ctrlClientID.selectName  = _clt.name;
                ctrlClientID.selectValue = clientIDStr;
            }

            /* Determine if user can see service thresholds section and related client side code */

            if (
                   (rd.wu.usr.roleID == Constants.ROLE_LEA_COORDINATOR_ID)
                || (rd.wu.usr.pcalStaff)
            )
            { 
              showSvcThresholds  = true;
            }
            else
            {
              showSvcThresholds  = false;
            }
        }
    }
}