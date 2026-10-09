
using System;
using System.Collections;
using System.ComponentModel;
using System.Web;
using System.Web.SessionState;
using System.Web.Routing;
using cn = System.Convert;
using MBA;
using Spedmon;

namespace Spedmon
{
	public class Global : MBA.HttpApplication
	{
		private System.ComponentModel.IContainer components = null;

		public Global()
		{
			InitializeComponent();
        }

        protected void Application_Start(Object sender, EventArgs e)
        {
            /* Add end points for RESTful API v1 */

            addRestApiRoute(RouteTable.Routes, false, "v1", "patients", typeof(PatientsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "practitioners", typeof(PractitionersRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "patientpersons", typeof(PatientPersonsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "users", typeof(UsersRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "servicerecords", typeof(ServiceRecordsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "storedfiles", typeof(StoredFilesRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "patientparentsmcalconsents", typeof(PatientParentMcalConsentsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "claimservicenamexrefandformdatarecords", typeof(ClaimServiceNameXrefAndFormDataRecordsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "orpdocumentsordersandprofiles", typeof(OrpDocumentsOrdersAndProfilesRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "orpdocumentsstandardselectionnames", typeof(OrpDocumentsStandardSelectionNamesRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "rmtsmomentsreq", typeof(RMTSMomentsRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "servicerecordsapprovaldetails", typeof(ServiceRecordsApprovalDetailsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "servicerecordsapprovaldetailsbysvcrecid", typeof(ServiceRecordsApprovalDetailsBySvcRecIDRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "servicerecordsapprovalsummarybyjournal", typeof(ServiceRecordsApprovalSummaryByJournalRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "servicerecordsapprovalsummarybyprac", typeof(ServiceRecordsApprovalSummaryByPracRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "practitionerdirectsupervision", typeof(PracDirectSupervisionRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "claimsretroactiveforspapossibleselections", typeof(ClaimsRetroactiveForSpaRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "openservicejournals", typeof(OpenServiceJournalsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "patientgoals", typeof(PatientGoalsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "practitionercaseloadmembers", typeof(PractitionerCaseloadMembersRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "practitionerpatientgroupmembers", typeof(PractitionerPatientGroupMembersRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "potentiallostreimbursements", typeof(PotentialLostReimbursementsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "patientpromisedservices", typeof(PatientPromisedServicesRestHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "patientgoalsprogressindividualgoal", typeof(PatientGoalsProgressIndividualGoalsRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "crcspracsalaries", typeof(CRCSPracSalariesRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "crcspracsalariesraterebasing", typeof(CRCSPracSalariesRateRebasingRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "crcspracsalariesbefore1920fy", typeof(CRCSPracSalariesBefore1920FYRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "crcsothercosts", typeof(CRCSOtherCostsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "crcscontractorcosts", typeof(CRCSContractorCostsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "crcsmedequipmentdepreciationcosts", typeof(CRCSMedEquipmentDepreciationCostsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "crcstransportationpersonnelcosts", typeof(CRCSTransportationPersonnelCostsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "crcstransportationothercosts", typeof(CRCSTransportationOtherCostsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "crcspracsalariesreport", typeof(CRCSPracSalariesReportRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "crcsothercostsreport", typeof(CRCSOtherCostsReportRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "crcscontractorcostsreport", typeof(CRCSContractorCostsReportRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "crcstransportationequipmentdepreciationcosts", typeof(CRCSTransportationEquipmentDepreciationCostsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "crcstransportationreimbursements", typeof(CRCSTransportationReimbursementsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "missingservicestreatmentssummary", typeof(MissingServicesTreatmentsSummaryRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "missingservicestreatmentsdetails", typeof(MissingServicesTreatmentsDetailsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "missingservicestreatmentsforapatient", typeof(MissingServicesTreatmentsDetailsForAPatientRestApiHttpHandler));


            addRestApiRoute(RouteTable.Routes, false, "v1", "clients", typeof(ClientsRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "clientsnotes", typeof(ClientNotesRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "rmtsparticipantrosters", typeof(RmtsParticipantRostersRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "rmtsparticipants", typeof(RmtsParticipantsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "structureddataimportfilespatientsdata", typeof(StructuredDataImportFilesPatientDataRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "structureddataimportfilesrmtsparticipantsnotinspedcare", typeof(StructuredDataImportFilesRmtsParticipantsNotInSpEdCareRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "inputbatchesinprocess", typeof(InputBatchesInProcessRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "teleiepsessions", typeof(TeleIepSessionsRestApiHttpHander));
            addRestApiRoute(RouteTable.Routes, false, "v1", "telehealthsessions", typeof(TeleHealthSessionsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "planwriterplans", typeof(PlanWriterPlansRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "patientinsurancecarriers", typeof(PatientInsuranceCarriersRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "clientschoolsessionacademicyears", typeof(ClientSchoolSessionsAcademicYearsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "clientschoolsessionbreaks", typeof(ClientSchoolSessionBreaksRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "patientscurrentmcalbenefits", typeof(PatientsCurrentMcalBenefitsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "clientcomplianceclientitems", typeof(ClientComplianceClientItemsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "clientinvoices", typeof(ClientInvoicesRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "servicerecordsdataincomplete", typeof(ServiceRecordsDataIncompleteRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "cdecompliancebucketsdetailsbyservice", typeof(CdeComplianceBucketsDetailsByServiceRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "practitionerpatientcaseloadexpectedservices", typeof(PractitionerPatientCaseloadExpectedServicesRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "clientdomains", typeof(ClientDomainsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "transportationmgmtauthorizedroutemembers", typeof(TransportationMgmtAuthorizedRouteMembersRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "rmtsactivitycodechangereasons", typeof(RMTSActivityCodeChangeReasonsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "speddocumenttemplates", typeof(SpEdDocumentTemplatesRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "patientspromisedservicescdeauditscurrentpatientsexpectedservices", typeof(PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedServicesRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "patientspromisedservicescdeauditscurrentpatients", typeof(PatientsPromisedServicesCDEAuditsCurrentPatientsRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "practitionersefficiency", typeof(PractitionersEfficiencyRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "patientpromisedservicesdeliveryexceptions", typeof(PatientPromisedServicesDeliveryExceptionsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "practitioneremploymentrelationships", typeof(PractitionerEmploymentRelationshipsRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "clientgroupserviceclassnamespecificpracticerulesets", typeof(ClientGroupServiceClassNameSpecificPracticeRuleSetsRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "practitionerpreferencespedservices", typeof(PractitionerPreferenceSpedServicesRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "sites", typeof(SitesRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "newsletters", typeof(NewslettersRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "manpages", typeof(ManPagesRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "practitionerpatientscheduledservices", typeof(PractitionerPatientScheduledServicesRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "timekeeperservicerecordspermin", typeof(TimeKeeperServiceRecordsPerMinuteRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "practiceofficevisits", typeof(PracticeOfficeVisitsRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "patientknownhealthproblems", typeof(PatientKnownHealthProblemsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "patientallergies", typeof(PatientAlleriesRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "patientdiagnoses", typeof(PatientDiagnosesRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "patientvitals", typeof(PatientVitalsMeasurmentsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "practiceofficevisitreasons", typeof(PracticeOfficeVisitReasonsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "practiceofficekiosks", typeof(PracticeOfficeKiosksRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "knownhealthproblems", typeof(KnownHealthProblemsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "allergies", typeof(AllergiesRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "practiceofficevisitresolutions", typeof(PracticeOfficeVisitResolutionsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "insurancecarriers", typeof(InsuranceCarriersRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "servicejournalrecentprocedureentries", typeof(ServiceJournalRecentProcedureEntriesRestApiHttpHandler));


            addRestApiRoute(RouteTable.Routes, false, "v1", "cybhiholdsmissinginfopats", typeof(CYBHIHoldsMissingInfoPatsRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "cybhiprogramhealthdetailedservicesdocumented", typeof(CYBHIProgramHealthDetailedServiceDocumentedRestHttpApiHandler));


            addRestApiRoute(RouteTable.Routes, false, "v1", "patientinforequestsresponses", typeof(PatientInfoRequestsResponsesRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "cdecompliancebucketsdetailsbypcalcomplianceratingandpatients", typeof(CdeComplianceBucketDetailsByPcalComplianceRatingAndPatientsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "practitionersites", typeof(PractitionerSitesRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "patientswithmissinginfo", typeof(PatientsWithMissingInfoRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "practitionerpatientreferrals", typeof(PractitionerPatientReferralRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "rmtsparticipantswosvcrecs", typeof(RmtsParticipantsWoSvcRecsRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "patientinforequestspublicinsuranceformresponses", typeof(PatientInfoRequestsPublicInsuranceFormResponsesRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "clientstudentinformationsystems", typeof(ClientStudentInformationSystemsRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "userpersonalnotes", typeof(UserPersonalNotesRestApiHttpHandler));
            addRestApiRoute(RouteTable.Routes, false, "v1", "servicerecordsinternalreviews", typeof(ServiceRecordsInternalReviewsRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "cybhiservicerecordsorpreviews", typeof(CybhiServiceRecordsOrpReviewsRestApiHttpHandler));

            addRestApiRoute(RouteTable.Routes, false, "v1", "cybhiconsortiummembers", typeof(CYBHIConsortiumMembersRestApiHttpHandler));

        }

        protected void Session_Start(Object sender, EventArgs e){}
		protected void Application_Disposed(Object sender, EventArgs e){}
		protected void Application_BeginRequest(Object sender, EventArgs e){}
		protected void Application_EndRequest(Object sender, EventArgs e){}
		protected void Application_AuthenticateRequest(Object sender, EventArgs e){}
		//protected void Application_Error(Object sender, EventArgs e){}
		protected void Session_End(Object sender, EventArgs e){}
		protected void Application_End(Object sender, EventArgs e){}
			
		#region Web Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.components = new System.ComponentModel.Container();
		}
		#endregion
	}
}

