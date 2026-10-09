using System;
using MBA;

namespace Spedmon
{
    public class UserAllCdeComplianceCurrentAuditDetailsByPatientManage : WebUI
    {
        public UserAllCdeComplianceCurrentAuditDetailsByPatientManage() : base(
                                              CdeComplianceCommon.BODY_ID_MANAGE_CURRENT_AUDIT
                                            , CdeComplianceCommon.SEL_LABEL_MANGE_FOR_CLIENT_CURRENT_AUDIT
                                            , @""
                                            , @""
                                            , Constants.ROLE_CDE_COMPLIANCE_MANAGE)
        { 
		}
        
		protected void Page_Load(object sender, EventArgs e)
        {
            var ctrlClientID         = findControlRecu(this.Page, Constants.PARM_CLIENT_ID)                as MBA.HiddenInput;
            var ctrlPatID            = findControlRecu(this.Page, Constants.PARM_PATIENT_ID)               as MBA.HiddenInput;            
            var ctrlStartDate        = findControlRecu(this.Page, Constants.PARM_START_DATE)               as MBA.HiddenInput;
            var ctrlEndDate          = findControlRecu(this.Page, Constants.PARM_END_DATE)                 as MBA.HiddenInput;
            var ctrlPpsAuditCurPatID = findControlRecu(this.Page, Constants.PARM_PPS_CDE_AUDIT_CUR_PAT_ID) as MBA.HiddenInput;

            string clientIDStr            = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            string patIDStr               = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);
            string startDateStr           = MBA.HttpApplication.getParameter(Constants.PARM_START_DATE);
            string endDateStr             = MBA.HttpApplication.getParameter(Constants.PARM_END_DATE);
            string ppsCdeAuditCurPatIDStr = MBA.HttpApplication.getParameter(Constants.PARM_PPS_CDE_AUDIT_CUR_PAT_ID);
                        
            ctrlClientID.value         = clientIDStr;
            ctrlPatID.value            = patIDStr;
            ctrlStartDate.value        = startDateStr;
            ctrlEndDate.value          = endDateStr;
            ctrlPpsAuditCurPatID.value = ppsCdeAuditCurPatIDStr;
        }
    }
}