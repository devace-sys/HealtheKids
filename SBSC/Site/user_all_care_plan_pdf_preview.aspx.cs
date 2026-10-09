using System;
using System.Collections.Generic;
using MBA;
using System.Text;

namespace Spedmon
{
    /***************************************************************************
     * UserAllCarePlanPdfPreview */
    /**
     * 
     ***************************************************************************/


    public class UserAllCarePlanPdfPreview : WebUI

    {

        public UserAllCarePlanPdfPreview() : base(Util.createUniqueID()
                                                  , @""
                                                  , @"care_plan_pdf.css"
                                                  , @""
                                                  , Constants.ROLE_CARE_PLAN_WRITER)
        { 
          this.useCssReset = false;    
        }
        // front end access variables
        public PlanWriterPlan plan { get; set; }
        public Client client { get; set; }
        public Patient patient { get; set; }
        public Site site { get; set; }
        public PlanWriterPlanDiagnosis diagnosis { get; set; }
        
        public string servicesHTML = @"";
        public int    servicesCtr  = 0;
        public string signaturesHTML = @"";

        public List<PlanWriterPlansPrescribedOrder> orders { get; set; }
        public List<PlanWriterPlansServiceDescription> services { get; set; }
        public List<PlanWriterPlansPatientPerson> participants { get; set; }
        private void throwParmNotPassedError()
        {
            throw new Exception("Invalid client or record id!");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            /*******************************************
             * Gather required input parameters
             * *****************************************/

            string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID)
                 , recIDStr = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);

            int parmClientID, ParmRecID;

            var parmClientIDPassed = int.TryParse(clientIDStr, out parmClientID);
            var parmRecIDPassed = int.TryParse(recIDStr, out ParmRecID);

            // if values provided, hide controls
            if (!parmClientIDPassed || parmClientID == 0 || !parmRecIDPassed || ParmRecID == 0)
            {
                throwParmNotPassedError();
            }


            /* Verify access */

            PlanWriterRecords.validateClientAccessForMethodOrHandler(dbConnApp
                                                                       , log
                                                                       , uInfo
                                                                       , clientIDStr);

            /* Get global plan data */

            // get plan

            try
            {
                plan = PlanWriterPlans.load(dbConnApp, log, uInfo, clientIDStr, null, recIDStr);
            }
            catch (Exception ex)
            {
                throwParmNotPassedError();
                return;
            }

            // get client, patient and site info.  Also clean up patient.name and client.name to guard against
            // characters that might cause issues with how we are creating arguments to pass to our front end
            // pdf generation code.  

            client      = Clients.load(dbConnApp, log, uInfo, clientIDStr);
            client.name = MBA.Util.webSafeString(client.name);

            String patientID = plan.patientID.ToString();
            patient          = Patients.load(dbConnApp, log, uInfo, patientID);
            patient.name     = MBA.Util.webSafeString(patient.name);

            String siteID    = patient.siteID.ToString();
            site             = Sites.load(dbConnApp, log, uInfo, siteID);
            site.name        = MBA.Util.webSafeString(site.name);

            // get diagnosis

            diagnosis = PlanWriterDiagnoses.loadPlanDiag(dbConnApp
                                                        , log
                                                        , uInfo
                                                        , clientIDStr
                                                        , recIDStr);

            StringBuilder sbServices = new StringBuilder();

            // get orders
            orders = PlanWriterPlansPrescribedOrders.loadAllRecords(dbConnApp
                                                                , log
                                                                , uInfo
                                                                , clientIDStr
                                                                , null
                                                                , recIDStr);            
            servicesCtr = 0;            
            foreach (var order in orders) {                 
                servicesCtr++;
                bool _firstSvc = false;
                if (servicesCtr == 1) _firstSvc = true;
                
                sbServices.Append(PlanWriterRecords.generateOrderOrServiceSectionHTML(patient.name, patient.dobStr, order.name,order.formBuilderQuestionsJSON,order.formBuilderAnswersJSON,order.svcDesc,order.lastApprovalExpirationMessage,order.lastApprovalOrpName,order.lastApprovalEffectiveDateStr,order.lastApprovalExpirationState,_firstSvc));
            }
            
            // get profiles/services
            services = PlanWriterPlansServiceDescriptions.loadAllRecords(
                                                                      dbConnApp
                                                                    , log
                                                                    , uInfo
                                                                    , clientIDStr
                                                                    , null
                                                                    , recIDStr);

            foreach (var order in services) { 
                servicesCtr++;
                bool _firstSvc = false;
                if (servicesCtr == 1) _firstSvc = true;
                sbServices.Append(PlanWriterRecords.generateOrderOrServiceSectionHTML(patient.name, patient.dobStr,order.name,order.formBuilderQuestionsJSON,order.formBuilderAnswersJSON,order.serviceDescription,order.lastApprovalExpirationMessage,order.lastApprovalOrpName,order.lastApprovalEffectiveDateStr, order.lastApprovalExpirationState,  _firstSvc));
            }

            servicesHTML = sbServices.ToString();

            // get participants
            participants = PlanWriterPlansPatientPersons.loadAllRecords(dbConnApp
                                                                    , log
                                                                    , uInfo
                                                                    , clientIDStr
                                                                    , null
                                                                    , patientID
                                                                    , recIDStr);



           signaturesHTML = PlanWriterRecords.generateSignaturesSectionHTML(plan,participants);
        }
    }

}
