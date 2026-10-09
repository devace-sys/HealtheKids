using System;
using MBA;
namespace Spedmon
{
    public class UserAllPatientPromisedServiceDeliveryExceptionsManage : WebUI
    {
        public UserAllPatientPromisedServiceDeliveryExceptionsManage() : base(
                                              PatientPromisedServicesDeliveryExceptions.BODY_ID_MANAGE
                                            , PatientPromisedServicesDeliveryExceptions.SEL_LABEL_MANAGE
                                            , ""
                                            , ""
                                            , Constants.ROLE_CDE_COMPLIANCE_MANAGE)
        { }

        public string dataSource = @"";
        protected void Page_Load(object sender, EventArgs e)
        {
          
          string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
          dataSource = HttpApplication.getParameter(Constants.PARM_DATA_SOURCE);
          if (String.IsNullOrWhiteSpace(dataSource)) dataSource = Spedmon.PatientPromisedServicesDeliveryExceptions.DATA_SOURCE_ALL.ToString();
          
          var ctrlClientID                             = findControlRecu (this.Page, "selectClient")                            as MBA.DataEntryRowSelectClient;
          var ctrlExceptionRemoveReasonPromisedService = findControlRecu (this.Page, "exceptionremovereasonpromisedserviceid")  as MBA.DataEntryBoxSelect;

          var removedReasons = PatientPromisedServicesDeliveryExceptionRemovedReasons.viewList(dbConnApp,log,uInfo);

          foreach (var removedReason in removedReasons) { 
            ctrlExceptionRemoveReasonPromisedService.addSelection(new NameValue(removedReason.name,removedReason.id,@""));
          }
              
          /* preselect clientid if passed */

          
          if (!String.IsNullOrEmpty(clientIDStr))
          {
                var _clt = Clients.load(dbConnApp,log,uInfo,clientIDStr);
                ctrlClientID.selectName  = _clt.name;
                ctrlClientID.selectValue = clientIDStr;
          }

        } /* Page Load */
    }
}