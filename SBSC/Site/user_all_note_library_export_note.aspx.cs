using System;
using System.Collections.Generic;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * UserAllNoteLibraryExportNote */
    /**
     * 
     ***************************************************************************/

    public class UserAllNoteLibraryExportNote : WebUI

    {

        public UserAllNoteLibraryExportNote() : base(  "user_all_note_library_export_note"
                                                      , @""
                                                      , @""
                                                      , @"user_all_patient_goal_progress_reporting.js"
                                                      , Constants.ROLE_ALL_PCAL_AND_CLIENT )
        { 
          this.useCssReset = false;     
        }

        public bool            loadedOK        { get; set; }        
        public Client          client          { get; set; }
        public Practitioner    prac            { get; set; }
		public Patient         pat               { get; set; }
        public string          clientIDStr       { get; set; }
        public string          groupSvcClassName { get; set;}
        public string          pracIDStr         { get; set; }
	    public string          patIDStr          { get; set; }
        public string          refDateStr        { get; set; }
        public string          svcNameStr        { get; set; }
        public string          notesStr          { get; set; }
        public string          groupSvcClassNameIDStr   { get; set; }
        public string          formBuilderQuestionsJSON { get; set; }
        public string          formBuilderAnswersJSON   { get; set; }        
        public bool            hasPatientGoalTracking   { get; set; }
        public bool            hasPatientGoalProgress   { get; set; }
        public string          patientGoalProgressJSON  { get; set; }

        public DateTime srStartDate;
        public DateTime srEndDate;
        public string   srStartDateStr;
        public string   srEndDateStr;

        public List<PatientGoalProgressMeasurement> patientGoalProgressMeasurements { get; set; }
        public List<PatientGoalsProgressViewItem>   progressItems                   { get; set; }         
        public List<ServiceRecord>                  serviceRecords                  { get; set; }
        protected void Page_Load(object sender, EventArgs e)
        {
            loadedOK = false;

            try 
            {
              DateTime refDateVal;

              clientIDStr = Spedmon.Validate.reqClientID (uInfo, HttpApplication.getParameter(Constants.PARM_CLIENT_ID)).ToString();
              pracIDStr   = Spedmon.Validate.reqPracID   (uInfo, HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID)).ToString();
              patIDStr    = Spedmon.Validate.reqPatID    (uInfo, HttpApplication.getParameter(Constants.PARM_PATIENT_ID)).ToString();
              refDateVal  = Spedmon.Validate.reqDate     (HttpApplication.getParameter(Constants.PARM_REF_DATE),Messages.INVALID_REF_DATE);
              refDateStr  = refDateVal.ToShortDateString();
              svcNameStr  = Spedmon.Validate.reqString   (HttpApplication.getParameter(Constants.PARM_SVC_NAME),Messages.INVALID_SERVICE);
              notesStr    = Spedmon.Validate.optString   (HttpApplication.getParameter(Constants.PARM_NOTES),   Messages.INVALID_NOTES);            

              formBuilderQuestionsJSON = Spedmon.Validate.optString(HttpApplication.getParameter(Constants.PARM_SVC_NOTES_FB_QUESTIONS), Messages.INVALID_FORM_BUILDER_QUESTIONS);     
              formBuilderAnswersJSON   = Spedmon.Validate.optString(HttpApplication.getParameter(Constants.PARM_SVC_NOTES_FB_ANSWERS),   Messages.INVALID_FORM_BUILDER_ANSWERS);              
              hasPatientGoalTracking   = Spedmon.Validate.reqFlag(HttpApplication.getParameter(Constants.PARM_HAS_PAT_GOAL_TRACKING_DATA),   Messages.INVALID_PATIENT_GOAL_PROGRESS_DATA);
              patientGoalProgressJSON  = Spedmon.Validate.optString(HttpApplication.getParameter(Constants.PARM_PAT_GOAL_PROGRESS),      Messages.INVALID_PATIENT_GOAL_PROGRESS_DATA);
              
              client      = Clients.load(dbConnApp, log, uInfo, clientIDStr);                        
              client.name = MBA.Util.webSafeString(client.name);
              clientIDStr = client.id.ToString();

              prac         = Practitioners.load(dbConnApp,log,uInfo,pracIDStr);
              prac.name    = MBA.Util.webSafeString(prac.name);
              pracIDStr    = prac.id.ToString();
                              
              groupSvcClassNameIDStr = prac.stdSvcClassNameID.ToString();
              groupSvcClassName      = GroupsServiceClasses.load(dbConnApp,log,uInfo,"100",groupSvcClassNameIDStr).name;
              pat          = Patients.load(dbConnApp, log, uInfo, patIDStr);
              pat.name     = MBA.Util.webSafeString(pat.name);
              patIDStr     = pat.id.ToString();

              if (hasPatientGoalTracking) { 
                patientGoalProgressMeasurements = Spedmon.PatientGoalsProgressMeasurements.parseGoalMeasurementsJSONIntoList (dbConnApp, log, uInfo, clientIDStr,patIDStr,groupSvcClassNameIDStr,patientGoalProgressJSON, refDateStr);
              }
              else
              {
                patientGoalProgressMeasurements = new List<PatientGoalProgressMeasurement>();
              }
              
              hasPatientGoalProgress = false;
              progressItems = new List<PatientGoalsProgressViewItem>();
              progressItems = Spedmon.PatientGoalsProgressIndividualGoals.viewItems ( dbConnApp
                                                                                     , log
                                                                                     , uInfo
                                                                                     , clientIDStr
                                                                                     , patIDStr
                                                                                     , groupSvcClassNameIDStr
                                                                                     , refDateStr);
              if (progressItems.Count > 0) hasPatientGoalProgress = true;
              Util.computeClaimingYear(refDateVal,out srStartDate, out srEndDate);
              srStartDateStr = srStartDate.ToShortDateString();
              srEndDateStr   = srEndDate.ToShortDateString();
              serviceRecords = ServiceRecords.viewList( dbConnApp
                                                        , log
                                                        , uInfo
                                                        , clientIDStr
                                                        , groupSvcClassNameIDStr
                                                        , ""
                                                        , patIDStr
                                                        , ""
                                                        , srStartDateStr
                                                        , srEndDateStr);
              
              loadedOK = true;
            } 
            catch {
                loadedOK = false;
            }
        }
  }
}
