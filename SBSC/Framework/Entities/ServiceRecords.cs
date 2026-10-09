using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Collections.ObjectModel;
using System.Web.UI.WebControls;
using System.Collections;
using System.Collections.Specialized;
using System.Web.Script.Serialization;

using MBA;

namespace Spedmon
{

    /***************************************************************************
     * SvcDetail */
    /**
     * Service record details (for batch entry)
     **************************************************************************/

    public class SvcDetail
    {
        public SvcDetail() { }

        public DateTime dos;
        public string starttime;
        public string endtime;
        public int? nummins;
        public Decimal? trip1start;
        public Decimal? trip1end;
        public Decimal? trip2start;
        public Decimal? trip2end;
        public Decimal? trip3start;
        public Decimal? trip3end;
        public Decimal? trip4start;
        public Decimal? trip4end;
        public bool? patAbsent;
        public string notes;
    }

    /***************************************************************************
     * SvcDetailSBSC */
    /**
     * Service record details (for batch entry) for SBSC record entry
     **************************************************************************/

    public class SvcDetailSBSC : SvcDetail
    {

        /*----------------------------
         * Overrides base class to
         * redefine the fields (using new)
         * used in the datagrid for
         * PCAL staff
         *----------------------------*/

        [IsDataGridCol(1)]
        [DataGridColTitle("Date of Service")]
        [DataGridColIsInputLabel(true)]
        [DataGridColIsInputKey(true)]

        new public DateTime dos;

        [IsDataGridCol(2)]
        [DataGridColTitle("Start<br/>Time")]
        [DataGridColWidth(80)]
        [DataGridColSection("minutes")]
        [DataGridColCtrlCopy(true)]

        new public string starttime;

        [IsDataGridCol(3)]
        [DataGridColTitle("End<br/>Time")]
        [DataGridColWidth(80)]
        [DataGridColSection("minutes")]
        [DataGridColCtrlCopy(true)]

        new public string endtime;

        [IsDataGridCol(4)]
        [DataGridColTitle("Minutes")]
        [DataGridColWidth(80)]
        [DataGridColSection("minutes")]
        [DataGridColCtrlCopy(true)]

        new public int? nummins;

        [IsDataGridCol(5)]
        [DataGridColGroup("Trip 1<br/>AM Miles<br/>Home to School")]
        [DataGridColTitle("Start")]
        // [DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip1start;

        [IsDataGridCol(6)]
        [DataGridColGroup("Trip 1<br/>AM Miles<br/>Home to School")]
        [DataGridColTitle("End")]
        //[DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip1end;

        [IsDataGridCol(7)]
        [DataGridColGroup("Trip 2<br/>PM Miles<br/>School to Home")]
        [DataGridColTitle("Start")]
        //[DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip2start;

        [IsDataGridCol(8)]
        [DataGridColGroup("Trip 2<br/>PM Miles<br/>School to Home")]
        [DataGridColTitle("End")]
        //[DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip2end;

        [IsDataGridCol(9)]
        [DataGridColGroup("Trip 3<br/>School to<br/>Offsite Service")]
        [DataGridColTitle("Start")]
        //[DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip3start;

        [IsDataGridCol(10)]
        [DataGridColGroup("Trip 3<br/>School to<br/>Offsite Service")]
        [DataGridColTitle("End")]
        //[DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip3end;

        [IsDataGridCol(11)]
        [DataGridColGroup("Trip 4<br/>Back from<br/>Offsite Service")]
        [DataGridColTitle("Start")]
        //[DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip4start;

        [IsDataGridCol(12)]
        [DataGridColGroup("Trip 4<br/>Back from<br/>Offsite Service")]
        [DataGridColTitle("End")]
        //[DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip4end;

    }

    /***************************************************************************
     * SvcDetailClient */
    /**
     * Service record details (for batch entry) for client record entry
     **************************************************************************/

    public class SvcDetailClient : SvcDetail
    {
        /*----------------------------
         * Overrides base class to
         * redefine the fields (using new)
         * used in the datagrid for
         * clients
         *----------------------------*/

        [IsDataGridCol(1)]
        [DataGridColTitle("Date of Service")]
        [DataGridColIsInputLabel(true)]
        [DataGridColIsInputKey(true)]

        new public DateTime dos;

        [IsDataGridCol(2)]
        [DataGridColTitle("Start<br/>Time")]
        [DataGridColWidth(60)]
        [DataGridColSection("minutes")]
        [DataGridColCtrlCopy(true)]

        new public string starttime;

        [IsDataGridCol(3)]
        [DataGridColTitle("Minutes")]
        [DataGridColWidth(60)]
        [DataGridColSection("minutes")]
        [DataGridColCtrlCopy(true)]

        new public int? nummins;

        [IsDataGridCol(4)]
        [DataGridColGroup("Trip 1<br/>AM Miles<br/>Home to School")]
        [DataGridColTitle("Start")]
        // [DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip1start;

        [IsDataGridCol(5)]
        [DataGridColGroup("Trip 1<br/>AM Miles<br/>Home to School")]
        [DataGridColTitle("End")]
        //[DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip1end;

        [IsDataGridCol(6)]
        [DataGridColGroup("Trip 2<br/>PM Miles<br/>School to Home")]
        [DataGridColTitle("Start")]
        //[DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip2start;

        [IsDataGridCol(7)]
        [DataGridColGroup("Trip 2<br/>PM Miles<br/>School to Home")]
        [DataGridColTitle("End")]
        //[DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip2end;

        [IsDataGridCol(8)]
        [DataGridColGroup("Trip 3<br/>School to<br/>Offsite Service")]
        [DataGridColTitle("Start")]
        //[DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip3start;

        [IsDataGridCol(9)]
        [DataGridColGroup("Trip 3<br/>School to<br/>Offsite Service")]
        [DataGridColTitle("End")]
        //[DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip3end;

        [IsDataGridCol(10)]
        [DataGridColGroup("Trip 4<br/>Back from<br/>Offsite Service")]
        [DataGridColTitle("Start")]
        //[DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip4start;

        [IsDataGridCol(11)]
        [DataGridColGroup("Trip 4<br/>Back from<br/>Offsite Service")]
        [DataGridColTitle("End")]
        //[DataGridColWidth(30)]
        [DataGridColSection("miles")]
        [DataGridColCtrlCopy(true)]

        new public Decimal? trip4end;

        [IsDataGridCol(12)]
        [DataGridColWidth(50)]
        [DataGridColTitle("Patient<br/>Absent")]
        [DataGridColGroup("Additional<br/>Details")]

        new public bool? patAbsent;

        [IsDataGridCol(13)]
        [DataGridColWidth(350)]
        [DataGridColTitle("Notes")]
        [DataGridColGroup("Additional<br/>Details")]
        [DataGridColIsMultiLine(true)]
        [DataGridColCtrlCopy(true)]

        new public string notes;

    }

    /***************************************************************************
     * SvcDetails */
    /**
     * List of service record(s) details (for batch entry)
     **************************************************************************/

    public class SvcDetails
    {
        public List<SvcDetail> details;
    }

    /***************************************************************************
     * SvcDetailPatientCaseloadOrGroup */
    /**
     * Service record details for patient group entry
     **************************************************************************/

    public class SvcDetailPatientCaseloadOrGroup
    {
        public SvcDetailPatientCaseloadOrGroup() { }

        [IsDataGridCol(1)]
        [DataGridColTitle("Patient SpEdCare ID")]
        [DataGridColIsInputLabel(true)]
        [DataGridColIsInputKey(true)]
        [DataGridColIsHidden(true)]
        [DataGridColWidth(1)]
        public int patID;

        [IsDataGridCol(2)]
        [DataGridColTitle("Patient Name")]
        [DataGridColIsInputLabel(true)]
        [DataGridColWidth(200)]
        public string patName;

        [IsDataGridCol(3)]
        [DataGridColTitle("Start<br/>Time")]
        [DataGridColWidth(50)]
        [DataGridColCtrlCopy(true)]
        public string startTime;

        [IsDataGridCol(4)]
        [DataGridColTitle("Scheduled<br/>Minutes")]
        [DataGridColWidth(50)]
        [DataGridColCtrlCopy(true)]
        public int numMins;

        [IsDataGridCol(5)]
        [DataGridColTitle("Present")]
        [DataGridColWidth(50)]
        //[DataGridColCtrlCopy(true)]
        public bool? patPresent;

        [IsDataGridCol(6)]
        [DataGridColTitle("Absent")]
        [DataGridColWidth(50)]
        public bool? patAbsent;

        [IsDataGridCol(7)]
        [DataGridColTitle("Notes")]
        [DataGridColWidth(200)]
        [DataGridColIsMultiLine(true)]
        [DataGridColCtrlCopy(true)]
        public string notes;

    }

    /***************************************************************************
     * SvcDetailsPatientCaseloadOrGroup */
    /**
     * List of service record(s) details for patient group service entry
     **************************************************************************/

    public class SvcDetailsPatientCaseloadOrGroup
    {
        public List<SvcDetailPatientCaseloadOrGroup> details;
    }

    /***************************************************************************
     * SvcDetailMultiEncounter */
    /**
     * Service record multi encounter details
     **************************************************************************/

    public class SvcDetailMultiEncounter
    {
        public SvcDetailMultiEncounter() { }

        [IsDataGridCol(1)]
        [DataGridColTitle("Date of Service")]
        [DataGridColIsInputLabel(true)]
        [DataGridColIsInputKey(true)]
        public DateTime dos;

        [IsDataGridCol(2)]
        [DataGridColGroup("Minutes Per Encounter (E)")]
        [DataGridColTitle("E1")]
        [DataGridColCtrlCopy(true)]
        public int? nummins1;

        [IsDataGridCol(3)]
        [DataGridColGroup("Minutes Per Encounter (E)")]
        [DataGridColTitle("E2")]
        [DataGridColCtrlCopy(true)]
        public int? nummins2;

        [IsDataGridCol(4)]
        [DataGridColGroup("Minutes Per Encounter (E)")]
        [DataGridColTitle("E3")]
        [DataGridColCtrlCopy(true)]
        public int? nummins3;

        [IsDataGridCol(5)]
        [DataGridColGroup("Minutes Per Encounter (E)")]
        [DataGridColTitle("E4")]
        [DataGridColCtrlCopy(true)]
        public int? nummins4;

        [IsDataGridCol(6)]
        [DataGridColGroup("Minutes Per Encounter (E)")]
        [DataGridColTitle("E5")]
        [DataGridColCtrlCopy(true)]
        public int? nummins5;

        [IsDataGridCol(7)]
        [DataGridColGroup("Minutes Per Encounter (E)")]
        [DataGridColTitle("E6")]
        [DataGridColCtrlCopy(true)]
        public int? nummins6;

        [IsDataGridCol(8)]
        [DataGridColGroup("Minutes Per Encounter (E)")]
        [DataGridColTitle("E7")]
        [DataGridColCtrlCopy(true)]
        public int? nummins7;

        [IsDataGridCol(9)]
        [DataGridColGroup("Minutes Per Encounter (E)")]
        [DataGridColTitle("E8")]
        [DataGridColCtrlCopy(true)]
        public int? nummins8;

        [IsDataGridCol(10)]
        [DataGridColGroup("Minutes Per Encounter (E)")]
        [DataGridColTitle("E9")]
        [DataGridColCtrlCopy(true)]
        public int? nummins9;

        [IsDataGridCol(11)]
        [DataGridColGroup("Minutes Per Encounter (E)")]
        [DataGridColTitle("E10")]
        [DataGridColCtrlCopy(true)]
        public int? nummins10;
    }

    /***************************************************************************
     * SvcDetailsMultiEncounter */
    /**
     * List of service record(s) details for multi encounter entry
     **************************************************************************/

    public class SvcDetailsMultiEncounter
    {
        public List<SvcDetailMultiEncounter> details;
    }

    /***************************************************************************
     * ServiceRecordForParentOrPatientPortal */
    /**
     * Do not use this as a sub class.  Do not use entity as a sub class for this.
     * Keep seperate.  This is for security and privacy reasons.
     **************************************************************************/

    public class ServiceRecordForParentOrPatientPortal 
    {
        public long   id;
        public string clientName;
        public string patName;
        public DateTime dos;
        public string dosStr;
        public string startTimeStr;
        public string endTimeStr;
        public string svcName;
        public string pracName;
        public string numMins_tripsMiles;
        public string isIFSPorIEPStr;
        public string attendanceStatusSelectionName;
    }

    /***************************************************************************
     * ServiceRecord */
    /**
     **************************************************************************/

    public class ServiceRecord : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"clientName asc, dos desc, id desc";

        public bool srFound;
        public int svcType;
        public string reference;
        public string clientName;
        public string pracName;
        public string patName;
        public DateTime patDOBVal;
        public string patDOBStr;
        public string patCSIS;
        public string svcName;
        public DateTime dos;
        public bool isIFSPorIEP;
        public string startTimeStr;
        public TimeSpan startTimeVal;
        public int numMins;
        public string tripsMiles;
        public decimal trip1Start;
        public decimal trip1End;
        public decimal trip2Start;
        public decimal trip2End;
        public decimal trip3Start;
        public decimal trip3End;
        public decimal trip4Start;
        public decimal trip4End;

        public bool orpRequired;
        public bool hasOrpDocID;
        public long orpDocID;
        public string orpDocLabel;

        public bool hasSvcDetFlags;
        public bool svcDetFlag1;
        public bool svcDetFlag2;
        public bool svcDetFlag3;
        public bool svcDetFlag4;

        public bool patAbsent;
        public bool pracAbsent;
        public bool makeupSession;
        public long clientID;
        public long pracID;
        public long patID;
        public long nameID;

        public int attendanceStatusSelectionID;
        public string attendanceStatusSelectionName;
        public string dosStrYMD;
        public string dosStr;
        public string numMins_tripsMiles;
        public string endTimeStr;
        public TimeSpan endTimeVal;
        public string isIFSPorIEPStr;
        public string startTimeStrHHMM;
        public string endTimeStrHHMM;
        public string planTypeSelectionName;
        public bool viaTelehealth;
        public string viaTelehealthStr;
        public long groupID;
        public string groupName;
        public long pracGrpSvcClsNameID;
        public string pracGrpSvcClsName;
        public long entryType;
        public string entryTypeName;
        public bool rmtsMomentVal;
        public string rmtsMomentStr;
        public string svcNotesFormBuilderQuestionsJSON;
        public string svcNotesFormBuilderAnswersJSON;
        public string svcNotesFormBuilderText;
        public string svcNotesFormBuilderTextAndNotes;
        public string patientGoalProgressJSON;
        public bool hasPatientGoalTrackingData;

        public bool svcJournalRelated;
        public long svcJournalID;

        public string quarter;            /* TODO: Needs to be renamed to quarterName in entire call stack */

        public long RmtsAuditReqID;      /* TODO: needs to be renamed to rmtsAuditReqID in entire call stack  */
        public bool svcrecIsAutoMatched; /* TODO: Needs to be renamed to rmtsSvcRecIsAutoMatched in entire call stack */
        public string WhoWereYouWith;      /* TODO: Needs to be renamed to rmtsWhoWereYouWith in entire call stack */
        public string WhatWereYouDoing;    /* TODO: Needs to be renamed to rmtsWhatWereYouDoing in entire call stack */

        public string calPadsCodeValueStr;
        public int minsSatisfied;
        public string renderingPracSig;
        public string reviewingPracSig;

        public string enteredByUserLastFirst;
        public bool enteredByPcalStaff;
        public bool enteredByPrac;
        public bool enteredByDistStaff;

        public long nameIDAltModality;
        public string svcNameWithoutInPersonOrTelehealthText;

        public bool entryTypeIsSvcJournal;
        public bool entryTypeIsSvcJournalPatAbsent;

        public int svcNameListDataSourceID;
        public string svcNameListDataSourceName;

        public bool hasFillablePdfSelections;
        public string fillablePdfSelectionsJSON;
        public string fillablePdfAnswersJSON;

        public bool canUserEdit;            /* For future use */
        public bool canUserDelete;          /* For future use */
        public bool canUserFlagRMTS;        /* For future use */

    }


    /***************************************************************************
     * ServiceRecords */
    /**
     * Records of services rendered by practitioners for patients.  These
     * records can be entered either by the client or internal staff.
     ***************************************************************************/

    public class ServiceRecords : Entities
    {
        public static string SEL_LABEL_PLAN_SVC_COMP_REPT = @"Plan Service Compliance";
        //public static string PAGE_CLIENT_ALL_SVC_COMP_REPT                         = @"client_all_plan_svc_comp_one_patient_rpt.aspx";
        public static string PAGE_CLIENT_ALL_SVC_COMP_REPT = @"user_all_missing_services_treatment_summary_manage.aspx";
        public static string PAGE_SBSC_ALL_SVC_COMP_REPT = @"rpt_plan_svc_comp_one_patient.aspx";
        public static string PAGE_CLIENT_PROV_SVC_REC_SAVE_SINGLE_W_NOTES = "client_prov_svcrec_save_single.aspx";
        public static string PAGE_CLIENT_PROV_SVC_REC_SAVE_BATCH_W_NOTES = "client_prov_svcrec_save_batch.aspx";
        public static string PAGE_CLIENT_PROV_SVC_REC_SAVE_TMT_GRP_W_NOTES = "client_prov_svcrec_pat_tmt_grp_save.aspx";

        public static string PAGE_CLIENT_PROV_SVC_REC_SAVE_SINGLE = "client_prov_svcrec_save.aspx";
        public static string PAGE_CLIENT_PROV_SVC_REC_SAVE_BATCH = "client_prov_svcrec_batch_save.aspx";
        public static string PAGE_CLIENT_PROV_SVC_REC_SAVE_TMT_GRP = "client_prov_svcrec_pat_tmt_group_save.aspx";
        public const string SEL_LABEL_SVREC_NON_PRAC = @"Record Services for Practitioner's Caseload or Groups";
        public const string URL_CLIENT_COOR_SVCREC_CSLD_OR_GRP_SEL_PRAC = @"client_coor_svcrec_caseload_or_group_sel_prac.aspx";
        public const string URL_CLIENT_COOR_SVCREC_CSLD_OR_GRP_SAVE = @"client_coor_svcrec_caseload_or_group_save.aspx";

        public const string MENU_LINK_SVC_REC_SAVE_NEW_ALL = @"svcrecsavenewalllink";
        public const string MENU_LINK_SVC_REC_SAVE_NEW_ALL_NON_PRAC = @"svcrecsavenewalllinknonprac";

        public const string SEL_LABEL = @"Service Records";
        public static string SEL_LABEL_SVC_REC_SAVE_NEW_ALL = @"Record New Service Records";

        public static string SEL_LABEL_SVC_REC_SAVE_FOR_DOS_ALL = @"Record My Scheduled Services";
        public static string SEL_LABEL_SVC_REC_REVIEW_ASSESSEMENTS = @"Record Assessments for Upcoming IEP(s) and Missing Assessments)";
        public static string SEL_LABEL_SVC_REC_REVIEW_ASSESSMENTS_ALL = SEL_LABEL_SVC_REC_REVIEW_ASSESSEMENTS + @" - All Students";
        public static string SEL_LABEL_SVC_REC_REVIEW_ASSESSMENTS_CASELOAD_ONLY = SEL_LABEL_SVC_REC_REVIEW_ASSESSEMENTS + @" - Caseload Only";

        public static string SEL_LABEL_SVC_REC_MISSING_TMTS_FOR_PATIENT = @"Record Missing Treatments for a Patient";
        public static string SEL_LABEL_SVC_REC_MISSING_TMTS_FOR = @"Record Missing Treatments for ";
        public static string URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC = @"user_all_svcrec_save_batch_multi_pat_multi_svc.aspx";

        public static string URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC = @"user_all_svcrec_save_batch_multi_prac_pat_dos_svc.aspx";
        public static string URL_SBS_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC = @"sbs_all_svcrec_save_batch_multi_prac_pat_dos_svc.aspx";
        public static string MENU_ID_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC = @"lnksavebatchmultipracpatdossvc";
        public static string SEL_LABEL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC = @"Record New - Multi Practitioner & Patient";

        public static string URL_USER_ALL_RMTS_MOMENT_MATCH_AND_SVC_REC_SAVE = @"user_all_rmts_moment_match_and_service_record_save.aspx";

        public const string SEL_LABEL_EDIT_SVCREC = "Edit/Delete Service Records";

        public const string MENU_LINK_VISION_HEARING_SCREEN = @"svcrecvisionhearscreenlink";
        public const string SEL_LABEL_VISION_HEARING_SCREEN = @"Vision and Hearing Screenings";
        public const string URL_USER_ALL_VISION_AND_HEARING_SCREEN = @"user_all_svc_rec_vision_hearing_screen.aspx";

        public const string MENU_ID_MANAGE = @"manageservicerecordslink";
        public const string URL_USER_ALL_SVC_RECS_MANAGE = @"user_all_service_records_manage.aspx";
        public const string SEL_LABEL_MANAGE = @"Manage Service Records";
        public const string URL_REST_VIEW = @"api/v1/servicerecords";
        public const string URL_WEB_REPORT = @"servicerecords.ashx";
        public const string URL_SVC_BASE = @"servicerecords.asmx";
        public const string URL_SVC_DELETE_INLINE = URL_SVC_BASE + @"/deleteinline";
        public const string URL_SVC_FLAG_EXISTING_AS_RMTS = URL_SVC_BASE + @"/flagexistingasrmtsmoment";
        public const string URL_SVC_SAVE_INLINE = URL_SVC_BASE + @"/saveinline";
        public const string URL_STORED_FILE_WORK_BATCH = @"storedfileworkbatch.ashx";
        public const string URL_STORED_FILE_WORK_FLOW = @"storedfileworkflow.ashx";
        public const string URL_SBS_ALL_WORKFLOW_FILE_VIEWER = @"sbs_all_workflow_file_viewer.aspx";
        public const string URL_GET_STORED_FILE_WORK_FLOW_BASE = URL_SVC_BASE + @"/getStoredFileWorkFlowURL";
        public const string URL_SVCREC_FILLABLE_PDF_SAVE_BASE = @"user_all_svcrec_fillable_pdf_save.aspx";

        /***************************************************************************
         * URL_REST_VIEW */
        /**
         *
         **************************************************************************/
        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(ServiceRecords.URL_REST_VIEW, true);
        }

        /***************************************************************************
         * URL_WEB_REPORT_BASE */
        /**
         *
         **************************************************************************/
        public static string URL_WEB_REPORT_BASE()
        {
            return MBA.HttpApplication.createLink(ServiceRecords.URL_WEB_REPORT, true);
        }

        /***************************************************************************
         * URL_USER_ALL_SVC_RECS_MANAGE_IN_WINDOW_BASE */
        /**
         *
         **************************************************************************/

        public static string URL_USER_ALL_SVC_RECS_MANAGE_IN_WINDOW_BASE()
        {
            return MBA.HttpApplication.createLink(ServiceRecords.URL_USER_ALL_SVC_RECS_MANAGE
                                                    , true
                                                    , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                  );
        }

        /***************************************************************************
         * URL_SVC_ADD_NEW_INLINE_BASE */
        /**
         *
         **************************************************************************/

        public static string URL_SVC_ADD_NEW_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(ServiceRecords.URL_SVC_SAVE_INLINE, true);
        }

        /***************************************************************************
         * URL_SVC_EDIT_INLINE_BASE */
        /**
         *
         **************************************************************************/
        public static string URL_SVC_EDIT_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(ServiceRecords.URL_SVC_SAVE_INLINE, true);
        }

        /***************************************************************************
         * URL_SVC_DELETE_INLINE_BASE */
        /**
         *
         **************************************************************************/
        public static string URL_SVC_DELETE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(ServiceRecords.URL_SVC_DELETE_INLINE, true);
        }

        public static string URL_FLAG_EXISTING_AS_RMTS_MOMENT_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(ServiceRecords.URL_SVC_FLAG_EXISTING_AS_RMTS, true);
        }

        /***************************************************************************
         * URL_GET_STORED_FILE_WORK_BATCH */
        /**
         *
         **************************************************************************/

        public static string URL_GET_STORED_FILE_WORK_FLOW()
        {
            return MBA.HttpApplication.createLink(ServiceRecords.URL_GET_STORED_FILE_WORK_FLOW_BASE, true);
        }
        
        /***************************************************************************
         * URL_SBS_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC_BASE */
        /**
         *
         **************************************************************************/

        public static string URL_SBS_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC_BASE() 
        {
            return MBA.HttpApplication.createLink(ServiceRecords.URL_SBS_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC, true);
        }

        /***************************************************************************
         * generateUrlViewSvcsEnteredForAPat */
        /**
         *
         **************************************************************************/
        public static string generateUrlViewSvcsEnteredForAPat(string clientID
                                                                , string patID
                                                                , string startDate
                                                                , string endDate)
        {
            var dateRange = MBA.Util.startAndEndDateStrToDateRangeStr(startDate, endDate);
            return generateUrlViewSvcsEnteredForAPat(clientID, patID, dateRange);
        }

        public static string generateUrlViewSvcsEnteredForAPat(string clientID
                                                                , string patID
                                                                , string dateRange)
        {
            return MBA.HttpApplication.createLink(ServiceRecords.URL_USER_ALL_SVC_RECS_MANAGE
                                                    , true
                                                    , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                    , new NameValue(Constants.PARM_CLIENT_ID, clientID)
                                                    , new NameValue(Constants.PARM_PATIENT_ID, patID)
                                                    , new NameValue(Constants.PARM_DATE_RANGE, dateRange) /* Keep this nvp last */
                                                  );
        }


        /***************************************************************************
         * generateUrlRmtsMomentMatchAndSvcRecSave */
        /**
         *
         **************************************************************************/
        public static string generateUrlRmtsMomentMatchAndSvcRecSave()
        {
            return generateUrlRmtsMomentMatchAndSvcRecSave("");
        }

        public static string generateUrlRmtsMomentMatchAndSvcRecSave(string rmtsMomentRecordID)
        {
            return MBA.HttpApplication.createLink(ServiceRecords.URL_USER_ALL_RMTS_MOMENT_MATCH_AND_SVC_REC_SAVE
                                                   , true
                                                   , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                   , new NameValue(Constants.PARM_RMTS_MOMENT_ID, rmtsMomentRecordID));
        }

        public static string generateSharebleUrlRmtsMomentMatchAndSvcRecSave()
        {
            // used in notification generation.
            // NOTE!!  This existing functionality seems to be generating broken links (prompting for login)
            // for some user messages.
            //         Needs more testing?  Possibly a bugfix project for another time.

            return MBA.HttpApplication.createLink(ServiceRecords.URL_USER_ALL_RMTS_MOMENT_MATCH_AND_SVC_REC_SAVE
                                                   , false
                                                   // NOTE: We cannot save the LEAcoor's login token as part of the message
                                                   //       to the practitioner.
                                                   , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));
        }

        /***************************************************************************
         * WhatSvcRecPage */
        /**
         * Returns page
         ***************************************************************************/

        public static string WhatSvcRecPage(int userGroup, int userRole, int entryTypeVal, bool fmtNotes)
        {

            string entryPage = Constants.HOME_PRIVATE;

            if (userGroup == Constants.USER_GROUP_CLIENT)
            {
                if (userRole == Constants.ROLE_LEA_PROVIDER_ID)
                {
                    if (fmtNotes == true)
                    {
                        if (entryTypeVal == 0) entryPage = PAGE_CLIENT_PROV_SVC_REC_SAVE_SINGLE_W_NOTES;
                        if (entryTypeVal == 1) entryPage = PAGE_CLIENT_PROV_SVC_REC_SAVE_BATCH_W_NOTES;
                        if (entryTypeVal == 2) entryPage = PAGE_CLIENT_PROV_SVC_REC_SAVE_TMT_GRP_W_NOTES;
                    }
                    else
                    {
                        if (entryTypeVal == 0) entryPage = PAGE_CLIENT_PROV_SVC_REC_SAVE_SINGLE;
                        if (entryTypeVal == 1) entryPage = PAGE_CLIENT_PROV_SVC_REC_SAVE_BATCH;
                        if (entryTypeVal == 2) entryPage = PAGE_CLIENT_PROV_SVC_REC_SAVE_TMT_GRP;
                    }
                }
            }
            return entryPage;
        }

        public static string GenerateUrlClientProv(int entryTypeVal, bool fmtNotes)
        {
            string entryPage = WhatSvcRecPage(Constants.USER_GROUP_CLIENT, Constants.ROLE_LEA_PROVIDER_ID, entryTypeVal, fmtNotes);
            return GenerateUrl(entryPage);
        }

        /***************************************************************************
         * GenerateUrlViewNotesToSave */
        /**
         *
         ****************************************************************************/

        protected static string GenerateUrl(string entryPage)
        {
            string url = MBA.HttpApplication.createLink(entryPage
                                                           , true);
            return url;
        }


        /***************************************************************************
         * delete */
        /**
        * "Deletes" a service record
        *
        * @param  editDelReason   Reason for edit/delete
        * @param  validateRec     Perform validation for this record?
        * @param  recID           Record id reference for edit and delete
        * @return                 ReturnSaveNewRecord
        ***************************************************************************/

        public static ReturnSaveRecord delete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                               string editDelReason, string validateRec, string recID)
        {

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * delete method.
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, "");

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * delete method.
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*----------------------------
             * Call base method
             *----------------------------*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "SERVICE_RECORD_Delete", ref parms);
        }

        /***************************************************************************
         * deleteBatch */
        /**
        * "Deletes" one or more service records
        *
        * @param  editDelReason   Reason for edit/delete
        * @param  validateRec     Perform validation for this record?
        * @param  recIDMulti      One or more record ids to delete
        * @return                 ReturnSaveNewRecord
        ***************************************************************************/

        public static ReturnSaveRecord deleteBatch(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                    string editDelReason, string validateRec, string recIDMulti)
        {

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * delete method.
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, "");
            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            /*----------------------------
             * Call base method
             *----------------------------*/

            return Entities.deleteBatch(connSpedmon, log, uInfo, editDelReason, validateRec, recIDMulti, "SERVICE_RECORD_Delete_Batch", ref parms);
        }

        /***************************************************************************
         * save */
        /**
         * Save a service record
         *
         * @param  reference       Reference file
         * @param  batchNum        Claim batch (if service record was entered by input staff)
         * @param  papClmNum       Paper claim number
         * @param  isMultiDos      This is a service record with multiple dos (but all other parms are the same)
         * @param  dos             Date of service
         * @param  dosMulti        Multiple dos
         * @param  clientID        Client id
         * @param  pracID          Practioner id
         * @param  patID           Patient id
         * @param  isIEP           Is service part of an IFSP/IEP
         * @param  nameID          Friendly service name ID
         * @param  numMin          Number of minutes (if service is time based)
         * @param  trip1Miles      Number of miles for trip 1 (if service is transport)
         * @param  trip2Miles      Number of miles for trip 2 (if service is transport)
         * @param  trip3Miles      Number of miles for trip 3 (if service is transport)
         * @param  trip4Miles      Number of miles for trip 4 (if service is transport)
         * @param  notes           Service notes (freeform text)
         * @param  editDelReason   Reason for edit/delete
         * @param  validateRec     Perform validation for this record?
         * @param  saveType        Type of save (1=new, 2=edit, 3=delete)
         * @param  recID           Record id reference for edit and delete
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord save(SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , string reference
                                              , string batchNum
                                              , string papClmNum
                                              , string isMultiDos
                                              , string dos
                                              , string dosMulti
                                              , string clientID
                                              , string pracID
                                              , string patID
                                              , string isIEP
                                              , string nameID
                                              , string hasOrpDocID
                                              , string orpDocID
                                              , string hasSvcDetFlags
                                              , string svcDetFlag1
                                              , string svcDetFlag2
                                              , string svcDetFlag3
                                              , string svcDetFlag4
                                              , string startTime
                                              , string numMin
                                              , string trip1Start
                                              , string trip1End
                                              , string trip2Start
                                              , string trip2End
                                              , string trip3Start
                                              , string trip3End
                                              , string trip4Start
                                              , string trip4End
                                              , string attendancestatus
                                              , string notes
                                              , string editDelReason
                                              , string validateRec
                                              , string saveType
                                              , string recID)
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            string vReference = Validate.reqSvcRecReference(uInfo, reference);
            int vClientID = Validate.reqClientID(uInfo, clientID);
            int vPracID = Validate.reqPracID(uInfo, pracID);

            /*----------------------------
             * Date of service
             * can be single or multi
             *
             * Note: We use an array of
             * datetime values to hold
             * our dos values for pre
             * database call validation
             *----------------------------*/

            bool vIsMultiDos = Validate.reqFlag(isMultiDos, Messages.INVALID_BOOL);
            DateTime vDos = Validate.reqDate(dos, Messages.SERVICE_DATE_BAD, Constants.VAL_OPT_DATE_NO_FUTURE);

            string vDosMultiStr = "";
            DateTime[] vDosMultiVal;

            if (vIsMultiDos)
            {
                vDosMultiVal = Validate.reqDateMulti(dosMulti, Messages.SERVICE_DATE_BAD, Constants.VAL_OPT_DATE_NO_FUTURE, Constants.CONV_OPT_DATE_NONE);
                vDosMultiStr = Validate.reqString(dosMulti, Messages.SERVICE_DATE_BAD);
            }
            else
            {
                vDosMultiVal = new DateTime[1];
                vDosMultiVal[0] = vDos;
                vDosMultiStr = null;
            }

            /*----------------------------
             * ORP Document
             *----------------------------*/

            bool vHasOrpDocID = Validate.reqFlag(hasOrpDocID, Messages.INVALID_HAS_ORP_DOC_ID, true);
            Object vOrpDocID = Validate.optInteger(orpDocID, Messages.INVALID_ORP_DOC_ID);

            /*----------------------------
             * Service detail flags
             *----------------------------*/

            bool vHasSvcDetFlags = Validate.reqFlag(hasSvcDetFlags, @"Invalid service details flag", true);
            Object vSvcDetFlag1 = Validate.optFlag(svcDetFlag1, @"Invalid service detail flag");
            Object vSvcDetFlag2 = Validate.optFlag(svcDetFlag2, @"Invalid service detail flag");
            Object vSvcDetFlag3 = Validate.optFlag(svcDetFlag3, @"Invalid service detail flag");
            Object vSvcDetFlag4 = Validate.optFlag(svcDetFlag4, @"Invalid service detail flag");

            /*----------------------------
             * Rest of the parms
             *----------------------------*/

            int vPatID = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);
            bool vIsIEP = Validate.reqFlag(isIEP, Messages.IFSP_IEP_FLAG_BAD);
            int vNameID = Validate.reqInteger(nameID, Messages.INVALID_SERVICE);

            Object vStartTime = Validate.optTimeStr(startTime, Messages.INVALID_START_TIME);
            Object vNumMins = Validate.optInteger(numMin, Messages.INVALID_NUM_MINS);

            Object vTrip1Start = Validate.optFixed(trip1Start, Messages.INVALID_TRIP_MILES);
            Object vTrip1End = Validate.optFixed(trip1End, Messages.INVALID_TRIP_MILES);
            Object vTrip2Start = Validate.optFixed(trip2Start, Messages.INVALID_TRIP_MILES);
            Object vTrip2End = Validate.optFixed(trip2End, Messages.INVALID_TRIP_MILES);
            Object vTrip3Start = Validate.optFixed(trip3Start, Messages.INVALID_TRIP_MILES);
            Object vTrip3End = Validate.optFixed(trip3End, Messages.INVALID_TRIP_MILES);
            Object vTrip4Start = Validate.optFixed(trip4Start, Messages.INVALID_TRIP_MILES);
            Object vTrip4End = Validate.optFixed(trip4End, Messages.INVALID_TRIP_MILES);

            int vAttendanceStatus = Validate.reqInteger(attendancestatus, Messages.INVALID_ATTENDANCE_STATUS, true);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@reference", SqlDbType.VarChar, vReference, ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@batchNum", SqlDbType.NChar, batchNum, ParameterDirection.Input, 10));
            parms.Add(Database.SqlParm("@papClmNum", SqlDbType.NChar, papClmNum, ParameterDirection.Input, 35));
            parms.Add(Database.SqlParm("@isMultiDos", SqlDbType.Bit, vIsMultiDos, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dos", SqlDbType.DateTime, vDos, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dosMulti", SqlDbType.VarChar, vDosMultiStr, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.Int, vPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID", SqlDbType.Int, vPatID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@isIFSPorIEP", SqlDbType.Bit, vIsIEP, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@nameID", SqlDbType.Int, vNameID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@hasOrpDocID", SqlDbType.Bit, vHasOrpDocID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@orpDocID", SqlDbType.BigInt, vOrpDocID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@hasSvcDetailFlags", SqlDbType.Bit, vHasSvcDetFlags, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag1", SqlDbType.Bit, vSvcDetFlag1, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag2", SqlDbType.Bit, vSvcDetFlag2, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag3", SqlDbType.Bit, vSvcDetFlag3, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag4", SqlDbType.Bit, vSvcDetFlag4, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@startTime", SqlDbType.VarChar, vStartTime, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@numMin", SqlDbType.Int, vNumMins, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@trip1Start", SqlDbType.Decimal, vTrip1Start, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@trip1End", SqlDbType.Decimal, vTrip1End, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@trip2Start", SqlDbType.Decimal, vTrip2Start, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@trip2End", SqlDbType.Decimal, vTrip2End, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@trip3Start", SqlDbType.Decimal, vTrip3Start, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@trip3End", SqlDbType.Decimal, vTrip3End, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@trip4Start", SqlDbType.Decimal, vTrip4Start, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@trip4End", SqlDbType.Decimal, vTrip4End, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@attendanceStatus", SqlDbType.Int, vAttendanceStatus, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@notes", SqlDbType.VarChar, notes, ParameterDirection.Input, 7000));

            parms.Add(Database.SqlParm("@MsgInvCombo", SqlDbType.VarChar, Messages.INVALID_PPN_COMBO, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinReq", SqlDbType.VarChar, Messages.MIN_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinDef", SqlDbType.VarChar, Messages.MIN_DEF, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMilReq", SqlDbType.VarChar, Messages.MIL_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatElg", SqlDbType.VarChar, Messages.PAT_ELG, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar, Messages.PAT_DOB_GTE_DOS, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatAbsent", SqlDbType.VarChar, Messages.PAT_ABSENT_NO_CLAIM, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgFutureDOS", SqlDbType.VarChar, Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));


            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "SERVICE_RECORD_Save", Messages.DUP_SVC_REC, ref parms,
              delegate ()
              {
            /*-------------------------------
             * Perform range checks on
             * dates and minutes
             *-------------------------------*/

                  DateTime dr = DateTime.Now;
                  int rowNum = 1;

                  foreach (DateTime dosVal in vDosMultiVal)
                  {
                      serviceRecordRangeChecksDates(rowNum, uInfo, dosVal, dr, ref log);
                      rowNum++;
                  }

                  serviceRecordRangeChecksMinutes(0, uInfo, (int?)vNumMins, ref log);

              });
        }

        /***************************************************************************
         * saveInline */
        /**
         * Companion method for the rest view inline service records manage screen
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord saveInline(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
                                                   , string reference
                                                   , string dos
                                                   , string clientID
                                                   , string groupID
                                                   , string pracID
                                                   , string patID
                                                   , string svcNamesListDataSourceID
                                                   , string nameID
                                                   //, string hasOrpDocID
                                                   // , string orpDocID
                                                   , string hasSvcDetFlags
                                                   , string svcDetFlag1
                                                   , string svcDetFlag2
                                                   , string svcDetFlag3
                                                   , string svcDetFlag4
                                                   , string startTime
                                                   , string numMin
                                                   //, string trip1Start
                                                   //, string trip1End
                                                   //, string trip2Start
                                                   //, string trip2End
                                                   //, string trip3Start
                                                   //, string trip3End
                                                   //, string trip4Start
                                                   //, string trip4End
                                                   , string attendancestatus
                                                   , string notes
                                                   , string svcNotesFormBuilderQuestionsJSON
                                                   , string svcNotesFormBuilderAnswersJSON
                                                   , string patientGoalProgressJSON
                                                   , string hasPatientGoalTrackingData
                                                   , string hasFillablePdfSelections
                                                   , string fillablePdfSelectionsJSON
                                                   , string fillablePdfAnswersJSON
                                                   , string saveType
                                                   , string recID)
        {

            string vReference = Validate.reqSvcRecReference(uInfo, reference);
            int vClientID = Validate.reqClientID(uInfo, clientID);
            int vPracID = Validate.reqPracID(uInfo, pracID);
            DateTime vDos = Validate.reqDate(dos, Messages.SERVICE_DATE_BAD, Constants.VAL_OPT_DATE_NO_FUTURE);
            //bool      vHasOrpDocID     = Validate.reqFlag    (hasOrpDocID,   Messages.INVALID_HAS_ORP_DOC_ID, true);
            //Object    vOrpDocID        = Validate.optInteger (orpDocID,      Messages.INVALID_ORP_DOC_ID);
            bool vHasSvcDetFlags = Validate.reqFlag(hasSvcDetFlags, @"Invalid service details flag", true);
            Object vSvcDetFlag1 = Validate.optFlag(svcDetFlag1, @"Invalid service detail flag");
            Object vSvcDetFlag2 = Validate.optFlag(svcDetFlag2, @"Invalid service detail flag");
            Object vSvcDetFlag3 = Validate.optFlag(svcDetFlag3, @"Invalid service detail flag");
            Object vSvcDetFlag4 = Validate.optFlag(svcDetFlag4, @"Invalid service detail flag");
            int vPatID = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);
            //bool      vIsIEP           = Validate.reqFlag    (isIEP,       Messages.IFSP_IEP_FLAG_BAD);
            int vSvcNamesListDataSourceID = Validate.reqInteger(svcNamesListDataSourceID, @"Invalid plan type", false);
            int vNameID = Validate.reqInteger(nameID, Messages.INVALID_SERVICE);
            Object vStartTime = Validate.optTimeStr(startTime, Messages.INVALID_START_TIME);
            Object vNumMins = Validate.optInteger(numMin, Messages.INVALID_NUM_MINS, true);
            //Object    vTrip1Start      = Validate.optFixed   (trip1Start,  Messages.INVALID_TRIP_MILES);
            //Object    vTrip1End        = Validate.optFixed   (trip1End,    Messages.INVALID_TRIP_MILES);
            //Object    vTrip2Start      = Validate.optFixed   (trip2Start,  Messages.INVALID_TRIP_MILES);
            //Object    vTrip2End        = Validate.optFixed   (trip2End,    Messages.INVALID_TRIP_MILES);
            //Object    vTrip3Start      = Validate.optFixed   (trip3Start,  Messages.INVALID_TRIP_MILES);
            //Object    vTrip3End        = Validate.optFixed   (trip3End,    Messages.INVALID_TRIP_MILES);
            //Object    vTrip4Start      = Validate.optFixed   (trip4Start,  Messages.INVALID_TRIP_MILES);
            //Object    vTrip4End        = Validate.optFixed   (trip4End,    Messages.INVALID_TRIP_MILES);

            int vAttendanceStatus = Validate.reqInteger(attendancestatus, Messages.INVALID_ATTENDANCE_STATUS, true);
            string vNotes = Validate.optString(notes);
            string vSvcNotesFormBuilderQuestionsJSON = Validate.optString(svcNotesFormBuilderQuestionsJSON, @"Invalid notes questions data");
            string vSvcNotesFormBuilderAnswersJSON = Validate.optString(svcNotesFormBuilderAnswersJSON, @"Invalid notes answers data");
            string vPatientGoalProgressJSON = Validate.optString(patientGoalProgressJSON, @"Invalid goal tracking data");
            bool vHasPatientGoalTrackingData = Validate.reqFlag(hasPatientGoalTrackingData, @"Invalid has goal tracking data flag");
            bool vHasFillablePdfSelections = Validate.reqFlag(hasFillablePdfSelections, @"Invalid has fillable PDF selections flag");
            string vFillablePdfSelectionsJSON = Validate.optString(fillablePdfSelectionsJSON, @"Invalid fillable pdf data");
            string vFillablePdfAnswersJSON = Validate.optString(fillablePdfAnswersJSON, @"Invalid fillable pdf data");

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@reference", SqlDbType.VarChar, vReference, ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@dos", SqlDbType.DateTime, vDos, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.Int, vPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID", SqlDbType.Int, vPatID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcNamesListDataSourceID", SqlDbType.SmallInt, vSvcNamesListDataSourceID, ParameterDirection.Input));


            parms.Add(Database.SqlParm("@nameID", SqlDbType.Int, vNameID, ParameterDirection.Input));
            //parms.Add(Database.SqlParm("@hasOrpDocID",       SqlDbType.Bit,      vHasOrpDocID,      ParameterDirecvtion.Input));
            //parms.Add(Database.SqlParm("@orpDocID",          SqlDbType.BigInt,   vOrpDocID,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@hasSvcDetailFlags", SqlDbType.Bit, vHasSvcDetFlags, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag1", SqlDbType.Bit, vSvcDetFlag1, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag2", SqlDbType.Bit, vSvcDetFlag2, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag3", SqlDbType.Bit, vSvcDetFlag3, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag4", SqlDbType.Bit, vSvcDetFlag4, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@startTime", SqlDbType.VarChar, vStartTime, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@numMin", SqlDbType.Int, vNumMins, ParameterDirection.Input));
            //parms.Add(Database.SqlParm("@trip1Start",        SqlDbType.Decimal,  vTrip1Start,       ParameterDirection.Input));
            //parms.Add(Database.SqlParm("@trip1End",          SqlDbType.Decimal,  vTrip1End,         ParameterDirection.Input));
            //parms.Add(Database.SqlParm("@trip2Start",        SqlDbType.Decimal,  vTrip2Start,       ParameterDirection.Input));
            //parms.Add(Database.SqlParm("@trip2End",          SqlDbType.Decimal,  vTrip2End,         ParameterDirection.Input));
            //parms.Add(Database.SqlParm("@trip3Start",        SqlDbType.Decimal,  vTrip3Start,       ParameterDirection.Input));
            //parms.Add(Database.SqlParm("@trip3End",          SqlDbType.Decimal,  vTrip3End,         ParameterDirection.Input));
            //parms.Add(Database.SqlParm("@trip4Start",        SqlDbType.Decimal,  vTrip4Start,       ParameterDirection.Input));
            //parms.Add(Database.SqlParm("@trip4End",          SqlDbType.Decimal,  vTrip4End,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@attendanceStatus", SqlDbType.Int, vAttendanceStatus, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@notes", SqlDbType.VarChar, vNotes, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@MsgInvCombo", SqlDbType.VarChar, Messages.INVALID_PPN_COMBO, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinReq", SqlDbType.VarChar, Messages.MIN_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinDef", SqlDbType.VarChar, Messages.MIN_DEF, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMilReq", SqlDbType.VarChar, Messages.MIL_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatElg", SqlDbType.VarChar, Messages.PAT_ELG, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar, Messages.PAT_DOB_GTE_DOS, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatAbsent", SqlDbType.VarChar, Messages.PAT_ABSENT_NO_CLAIM, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgFutureDOS", SqlDbType.VarChar, Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

            parms.Add(Database.SqlParm("@svcNotesFormBuilderQuestionsJSON", SqlDbType.VarChar, vSvcNotesFormBuilderQuestionsJSON, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@svcNotesFormBuilderAnswersJSON", SqlDbType.VarChar, vSvcNotesFormBuilderAnswersJSON, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@patientGoalProgressJSON", SqlDbType.VarChar, vPatientGoalProgressJSON, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@hasPatientGoalTrackingData", SqlDbType.Bit, vHasPatientGoalTrackingData, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@hasFillablePdfSelections", SqlDbType.Bit, vHasFillablePdfSelections, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fillablePdfSelectionsJSON", SqlDbType.VarChar, vFillablePdfSelectionsJSON, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@fillablePdfAnswersJSON", SqlDbType.VarChar, vFillablePdfAnswersJSON, ParameterDirection.Input, -1));

            return Entities.save(connSpedmon
                                , log
                                , uInfo
                                , saveType
                                , @"N"
                                , @""
                                , recID
                                , "SERVICE_RECORD_Save_Inline"
                                , Messages.DUP_SVC_REC
                                , ref parms,
              delegate ()
              { });
        }
        /***************************************************************************
         * saveAndRmtsMomentMatch */
        /**
         * Specialized method for saving a new service record and then matching it
         * with an RMTS moment
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord saveAndRmtsMomentMatch(SqlConnection connSpedmon
                                                               , DetailsLog log
                                                               , UserInfo uInfo
                                                               , string reference
                                                               , string dos
                                                               , string clientID
                                                               , string pracID
                                                               , string patID
                                                               , string svcNamesListDataSourceID
                                                               , string nameID
                                                               , string hasOrpDocID
                                                               , string orpDocID
                                                               , string hasSvcDetFlags
                                                               , string svcDetFlag1
                                                               , string svcDetFlag2
                                                               , string svcDetFlag3
                                                               , string svcDetFlag4
                                                               , string startTime
                                                               , string numMin
                                                               , string attendancestatus
                                                               , string notes
                                                               , string svcNotesFormBuilderQuestionsJSON
                                                               , string svcNotesFormBuilderAnswersJSON
                                                               , string patientGoalProgressJSON
                                                               , string hasPatientGoalTrackingData
                                                               , string hasFillablePdfSelections
                                                               , string fillablePdfSelectionsJSON
                                                               , string fillablePdfAnswersJSON
                                                               , string rmtsMomentID
                                                               , string validateRec)
        {

            string vReference = Validate.reqSvcRecReference(uInfo, reference);
            int vClientID = Validate.reqClientID(uInfo, clientID);
            int vPracID = Validate.reqPracID(uInfo, pracID);
            DateTime vDos = Validate.reqDate(dos, Messages.SERVICE_DATE_BAD, Constants.VAL_OPT_DATE_NO_FUTURE);
            bool vHasOrpDocID = Validate.reqFlag(hasOrpDocID, Messages.INVALID_HAS_ORP_DOC_ID, true);
            Object vOrpDocID = Validate.optInteger(orpDocID, Messages.INVALID_ORP_DOC_ID);
            bool vHasSvcDetFlags = Validate.reqFlag(hasSvcDetFlags, @"Invalid service details flag", true);
            Object vSvcDetFlag1 = Validate.optFlag(svcDetFlag1, @"Invalid service detail flag");
            Object vSvcDetFlag2 = Validate.optFlag(svcDetFlag2, @"Invalid service detail flag");
            Object vSvcDetFlag3 = Validate.optFlag(svcDetFlag3, @"Invalid service detail flag");
            Object vSvcDetFlag4 = Validate.optFlag(svcDetFlag4, @"Invalid service detail flag");
            int vPatID = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);
            //bool      vIsIEP                            = Validate.reqFlag     (isIEP, Messages.IFSP_IEP_FLAG_BAD);
            int vSvcNamesListDataSourceID = Validate.reqInteger(svcNamesListDataSourceID, Messages.INVALID_PLAN_TYPE);
            int vNameID = Validate.reqInteger(nameID, Messages.INVALID_SERVICE);
            Object vStartTime = Validate.reqTimeStr(startTime, Messages.INVALID_START_TIME);
            Object vNumMins = Validate.optInteger(numMin, Messages.INVALID_NUM_MINS, true);
            int vAttendanceStatus = Validate.reqInteger(attendancestatus, Messages.INVALID_ATTENDANCE_STATUS, true);
            string vNotes = Validate.optString(notes);
            string vSvcNotesFormBuilderQuestionsJSON = Validate.optString(svcNotesFormBuilderQuestionsJSON, @"Invalid notes questions data");
            string vSvcNotesFormBuilderAnswersJSON = Validate.optString(svcNotesFormBuilderAnswersJSON, @"Invalid notes answers data");
            string vPatientGoalProgressJSON = Validate.optString(patientGoalProgressJSON, @"Invalid goal tracking data");
            bool vHasPatientGoalTrackingData = Validate.reqFlag(hasPatientGoalTrackingData, @"Invalid has goal tracking data flag");

            bool vHasFillablePdfSelections = Validate.reqFlag(hasFillablePdfSelections, @"Invalid has fillable pdf selections flag");
            string vFillablePdfSelectionsJSON = Validate.optString(fillablePdfSelectionsJSON, @"Invalid fillable pdf selections data");
            string vFillablePdfAnswersJSON = Validate.optString(fillablePdfAnswersJSON, @"Invalid fillable pdf answers data");

            long vRmtsMomentID = Validate.reqInteger(rmtsMomentID, @"A valid RMTS moment ID is required");

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@reference", SqlDbType.VarChar, vReference, ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@dos", SqlDbType.DateTime, vDos, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.BigInt, vPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID", SqlDbType.BigInt, vPatID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcNamesListDataSourceID", SqlDbType.Int, vSvcNamesListDataSourceID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@nameID", SqlDbType.Int, vNameID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@hasOrpDocID", SqlDbType.Bit, vHasOrpDocID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@orpDocID", SqlDbType.BigInt, vOrpDocID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@hasSvcDetailFlags", SqlDbType.Bit, vHasSvcDetFlags, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag1", SqlDbType.Bit, vSvcDetFlag1, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag2", SqlDbType.Bit, vSvcDetFlag2, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag3", SqlDbType.Bit, vSvcDetFlag3, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag4", SqlDbType.Bit, vSvcDetFlag4, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@startTime", SqlDbType.VarChar, vStartTime, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@numMin", SqlDbType.Int, vNumMins, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@attendanceStatus", SqlDbType.Int, vAttendanceStatus, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@notes", SqlDbType.VarChar, vNotes, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@svcNotesFormBuilderQuestionsJSON", SqlDbType.VarChar, vSvcNotesFormBuilderQuestionsJSON, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@svcNotesFormBuilderAnswersJSON", SqlDbType.VarChar, vSvcNotesFormBuilderAnswersJSON, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@patientGoalProgressJSON", SqlDbType.VarChar, vPatientGoalProgressJSON, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@hasPatientGoalTrackingData", SqlDbType.Bit, vHasPatientGoalTrackingData, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@hasFillablePdfSelections", SqlDbType.Bit, vHasFillablePdfSelections, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fillablePdfSelectionsJSON", SqlDbType.VarChar, vFillablePdfSelectionsJSON, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@fillablePdfAnswersJSON", SqlDbType.VarChar, vFillablePdfAnswersJSON, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@rmtsMomentID", SqlDbType.BigInt, vRmtsMomentID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@MsgInvCombo", SqlDbType.VarChar, Messages.INVALID_PPN_COMBO, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinReq", SqlDbType.VarChar, Messages.MIN_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinDef", SqlDbType.VarChar, Messages.MIN_DEF, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMilReq", SqlDbType.VarChar, Messages.MIL_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatElg", SqlDbType.VarChar, Messages.PAT_ELG, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar, Messages.PAT_DOB_GTE_DOS, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatAbsent", SqlDbType.VarChar, Messages.PAT_ABSENT_NO_CLAIM, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgFutureDOS", SqlDbType.VarChar, Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

            return Entities.save(connSpedmon
                                  , log
                                  , uInfo
                                  , Constants.SAVE_TYPE_NEW.ToString() /* New records only */
                                  , validateRec
                                  , @"" /* No edits so no editDel reason */
                                  , @"" /* No edits so no recid */
                                  , "SERVICE_RECORD_Save_And_RMTS_Moment_Match"
                                  , Messages.DUP_SVC_REC
                                  , ref parms
                                  , delegate () { }
                                 );

        }


        /***************************************************************************
          * flagExistingAsRMTSMoment */
        /**
         * Companion method for the rest view inline service records manage screen
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord flagExistingAsRMTSMoment(SqlConnection connSpedmon
                                                              , DetailsLog log
                                                              , UserInfo uInfo
                                                              , string clientID
                                                              , string pracID
                                                              , string isRMTSMoment
                                                              , string recID)
        {

            int vClientID = Validate.reqClientID(uInfo, clientID);
            int vPracID = Validate.reqPracID(uInfo, pracID);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.Int, vPracID, ParameterDirection.Input));

            return Entities.activateDeactivate(connSpedmon
                                                , log
                                                , uInfo
                                                , @""
                                                , "N"
                                                , recID
                                                , isRMTSMoment
                                                , DateTime.Now.ToShortDateString()
                                                , @"SERVICE_RECORD_Flag_Existing_As_RMTS_Moment"
                                                , ref parms);

        }

        /***************************************************************************
         * deleteInline */
        /**
         * Companion method for the rest view inline service records manage screen
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord deleteInline(SqlConnection connSpedmon
                                                       , DetailsLog log
                                                       , UserInfo uInfo
                                                       , string recID)
        {
            Object vClientID = Validate.optClientID(uInfo, @""); /* Make sure clients can only delete their own recs */
            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            return Entities.delete(connSpedmon, log, uInfo, @"", "N", recID, @"SERVICE_RECORD_Delete_Inline", ref parms);
        }

        /***************************************************************************
         * saveBatch */
        /**
         * Save multiple service records
         *
         * @param  reference       Reference file
         * @param  clientID        Client id
         * @param  pracID          Practioner id
         * @param  patID           Patient id
         * @param  isIEP           Is service part of an IFSP/IEP
         * @param  nameID          Friendly service name ID
         * @param  details         Required, JSON string containing dos,
         *                         minutes or miles, and notes for each service
         * @param  validateRec     Perform validation for this record?
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord saveBatch(SqlConnection connSpedmon,
                                                  DetailsLog log,
                                                  UserInfo uInfo,
                                                  string reference,
                                                  string clientID,
                                                  string pracID,
                                                  string dossvcs,
                                                  string patID,
                                                  string isIEP,
                                                  string nameID,
                                                  string hasOrpDocID,
                                                  string orpDocID,
                                                  string hasSvcDetFlags,
                                                  string svcDetFlag1,
                                                  string svcDetFlag2,
                                                  string svcDetFlag3,
                                                  string svcDetFlag4,
                                                  string details,
                                                  string validateRec)
        {

            /*----------------------------
             * Batch save is for new records
             * only so we provide the required
             * values for save here
             *----------------------------*/

            string editDelReason = "";
            string saveType = Constants.SAVE_TYPE_NEW.ToString();
            string recID = "";

            /*----------------------------
             * Create additional validation
             * steps for the following
             * reqObject validation check.
             *----------------------------*/

            AdditionalValidation av = delegate (Object o) {

                /*-------------------------------
                 * Cast o to SvcDetails
                 *-------------------------------*/

                SvcDetails vDetails = (SvcDetails)o;

                /*-------------------------------
                 * Perform range checks on
                 * dates and minutes and check
                 * patient absent flag
                 *-------------------------------*/

                DateTime dr = DateTime.Now;
                int rowNum = 1;

                foreach (SvcDetail vDetail in vDetails.details)
                {
                    serviceRecordRangeChecksDates(rowNum, uInfo, vDetail.dos, dr, ref log);
                    serviceRecordRangeChecksMinutes(rowNum, uInfo, vDetail.nummins, ref log);
                    serviceRecordRangeChecksStartTime(rowNum, uInfo, vDetail.starttime, ref log);

                    bool? vPatAbsent = Util.evaluateFlag(vDetail.patAbsent, true);
                    if (!vPatAbsent.HasValue) throw new Warning(Messages.INVALID_FLAG_PAT_ABSNT);

                    rowNum++;
                }
            };

            /*----------------------------
             * Parse and convert details
             * string (JSON) to object
             *
             * Note: The parsing will
             * peform datatype validation
             *----------------------------*/

            SvcDetails vSvcDetails = (SvcDetails)Validate.reqObject(details, Messages.INVALID_SVC_REC_DETAIL, "Spedmon", "Spedmon.SvcDetails", av);

            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            string vReference = Validate.reqSvcRecReference(uInfo, reference);
            int vClientID = Validate.reqClientID(uInfo, clientID);
            int vPracID = Validate.reqPracID(uInfo, pracID);

            string vDosMultiStr = Validate.reqString(dossvcs, Messages.SERVICE_DATE_BAD);
            DateTime[] vDosMultiVal = Validate.reqDateMulti(dossvcs, Messages.SERVICE_DATE_BAD, Constants.VAL_OPT_DATE_NO_FUTURE, Constants.CONV_OPT_DATE_NONE);

            int vPatID = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);
            bool vIsIEP = Validate.reqFlag(isIEP, Messages.IFSP_IEP_FLAG_BAD);
            int vNameID = Validate.reqInteger(nameID, Messages.INVALID_SERVICE);

            /*----------------------------
             * ORP Document
             *----------------------------*/

            bool vHasOrpDocID = Validate.reqFlag(hasOrpDocID, Messages.INVALID_HAS_ORP_DOC_ID, true);
            Object vOrpDocID = Validate.optInteger(orpDocID, Messages.INVALID_ORP_DOC_ID);

            /*----------------------------
             * Service details
             *----------------------------*/

            bool vHasSvcDetFlags = Validate.reqFlag(hasSvcDetFlags, @"Invalid service details flag", true);
            Object vSvcDetFlag1 = Validate.optFlag(svcDetFlag1, @"Invalid service detail flag");
            Object vSvcDetFlag2 = Validate.optFlag(svcDetFlag2, @"Invalid service detail flag");
            Object vSvcDetFlag3 = Validate.optFlag(svcDetFlag3, @"Invalid service detail flag");
            Object vSvcDetFlag4 = Validate.optFlag(svcDetFlag4, @"Invalid service detail flag");


            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@reference", SqlDbType.VarChar, vReference, ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.Int, vPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dosMulti", SqlDbType.VarChar, vDosMultiStr, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@patID", SqlDbType.Int, vPatID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@isIFSPorIEP", SqlDbType.Bit, vIsIEP, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@nameID", SqlDbType.Int, vNameID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@hasOrpDocID", SqlDbType.Bit, vHasOrpDocID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@orpDocID", SqlDbType.BigInt, vOrpDocID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@hasSvcDetailFlags", SqlDbType.Bit, vHasSvcDetFlags, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag1", SqlDbType.Bit, vSvcDetFlag1, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag2", SqlDbType.Bit, vSvcDetFlag2, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag3", SqlDbType.Bit, vSvcDetFlag3, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag4", SqlDbType.Bit, vSvcDetFlag4, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@MsgInvCombo", SqlDbType.VarChar, Messages.INVALID_PPN_COMBO, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinReq", SqlDbType.VarChar, Messages.MIN_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinDef", SqlDbType.VarChar, Messages.MIN_DEF, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMilReq", SqlDbType.VarChar, Messages.MIL_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatElg", SqlDbType.VarChar, Messages.PAT_ELG, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar, Messages.PAT_DOB_GTE_DOS, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatAbsent", SqlDbType.VarChar, Messages.PAT_ABSENT_NO_CLAIM, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgFutureDOS", SqlDbType.VarChar, Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

            /*----------------------------
             * Parse and convert details
             * object to table variable
             * parameter and add it.
             *----------------------------*/

            parms.Add(Database.SqlParmDataTable<SvcDetail>("@svcdetails", vSvcDetails.details, "SvcDetails"));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "SERVICE_RECORD_Save_Batch", Messages.DUP_SVC_REC, ref parms,
              delegate ()
              {
            // Note: No additional validation steps needed
        });
        }

        /***************************************************************************
         * saveBatchCaseloadOrGroupService */
        /**
         * Save multiple service records for a treatment group
         *
         * @param  reference       Reference file
         * @param  clientID        Client id
         * @param  pracID          Practioner id
         * @param  patID           Patient id
         * @param  isIEP           Is service part of an IFSP/IEP
         * @param  nameID          Friendly service name ID
         * @param  details         Required, JSON string containing dos,
         *                         minutes or miles, and notes for each service
         * @param  validateRec     Perform validation for this record?
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord saveBatchCaseloadOrGroupService(SqlConnection connSpedmon,
                                                                        DetailsLog log,
                                                                        UserInfo uInfo,
                                                                        string reference,
                                                                        string clientID,
                                                                        string pracID,
                                                                        string groupID,
                                                                        string entireCaseload,
                                                                        string serviceTypeID,
                                                                        string serviceProcCode,
                                                                        string serviceNameID,
                                                                        string isIEP,
                                                                        string dos,
                                                                        string details,
                                                                        string validateRec)
        {

            /*----------------------------
             * Batch save is for new records
             * only so we provide the required
             * values for save here
             *----------------------------*/

            string editDelReason = "";
            string saveType = Constants.SAVE_TYPE_NEW.ToString();
            string recID = "";

            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            string vReference = Validate.reqSvcRecReference(uInfo, reference);
            int vClientID = Validate.reqClientID(uInfo, clientID);
            int vPracID = Validate.reqPracID(uInfo, pracID);
            DateTime vDos = Validate.reqDate(dos, Messages.INVALID_DATES);
            bool vIsIEP = Validate.reqFlag(isIEP, Messages.IFSP_IEP_FLAG_BAD);
            bool vEntireCaseload = Validate.reqFlag(entireCaseload, @"Invalid caseload flag", true);
            Object vGroupID = null;

            if (vEntireCaseload == false)
                vGroupID = Validate.reqInteger(groupID, Messages.INVALID_GROUP_ID);

            int vServiceTypeID = Validate.reqInteger(serviceTypeID, @"Invalid service type");
            string vServiceProcCode = Validate.reqString(serviceProcCode, @"Invalid service procedure code");
            int vServiceNameID = Validate.reqInteger(serviceNameID, @"Invalid service name id");

            /*----------------------------
             * Create additional validation
             * steps for the following
             * reqObject validation check.
             *----------------------------*/

            AdditionalValidation av = delegate (Object o) {

                /*-------------------------------
                 * Cast o to SvcDetails
                 *-------------------------------*/

                SvcDetailsPatientCaseloadOrGroup vDetails = (SvcDetailsPatientCaseloadOrGroup)o;

                /*-------------------------------
                 * Perform range checks on
                 * dates and minutes and check
                 * patient absent flag
                 *-------------------------------*/

                DateTime dr = DateTime.Now;
                int rowNum = 1;

                foreach (SvcDetailPatientCaseloadOrGroup vDetail in vDetails.details)
                {

                    serviceRecordRangeChecksMinutes(rowNum, uInfo, vDetail.numMins, ref log);
                    serviceRecordRangeChecksStartTime(rowNum, uInfo, vDetail.startTime, ref log);

                    bool? vPatPresent = Util.evaluateFlag(vDetail.patPresent, true);
                    bool? vPatAbsent = Util.evaluateFlag(vDetail.patAbsent, true);

                    if (!vPatPresent.HasValue) throw new Warning(Messages.INVALID_FLAG_PAT_PRSNT);
                    if (!vPatAbsent.HasValue) throw new Warning(Messages.INVALID_FLAG_PAT_ABSNT);

                    rowNum++;
                }
            };

            /*----------------------------
             * Parse and convert details
             * string (JSON) to object
             *
             * Note: The parsing will
             * peform datatype validation
             *----------------------------*/

            SvcDetailsPatientCaseloadOrGroup vSvcDetails = (SvcDetailsPatientCaseloadOrGroup)Validate.reqObject(details, Messages.INVALID_SVC_REC_DETAIL, "Spedmon", "Spedmon.SvcDetailsPatientCaseloadOrGroup", av);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@reference", SqlDbType.VarChar, vReference, ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.BigInt, vPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@entireCaseload", SqlDbType.Bit, vEntireCaseload, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@groupID", SqlDbType.BigInt, vGroupID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@isIFSPorIEP", SqlDbType.Bit, vIsIEP, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@dos", SqlDbType.DateTime, vDos, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@serviceTypeID", SqlDbType.Int, vServiceTypeID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@serviceProcCode", SqlDbType.VarChar, vServiceProcCode, ParameterDirection.Input, 100));
            parms.Add(Database.SqlParm("@serviceNameID", SqlDbType.Int, vServiceNameID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@MsgInvCombo", SqlDbType.VarChar, Messages.INVALID_PPN_COMBO, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinReq", SqlDbType.VarChar, Messages.MIN_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinDef", SqlDbType.VarChar, Messages.MIN_DEF, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMilReq", SqlDbType.VarChar, Messages.MIL_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatElg", SqlDbType.VarChar, Messages.PAT_ELG, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar, Messages.PAT_DOB_GTE_DOS, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatAbsent", SqlDbType.VarChar, Messages.PAT_ABSENT_NO_CLAIM, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgFutureDOS", SqlDbType.VarChar, Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

            /*----------------------------
             * Parse and convert details
             * object to table variable
             * parameter and add it.
             *----------------------------*/

            parms.Add(Database.SqlParmDataTable<SvcDetailPatientCaseloadOrGroup>("@svcdetails", vSvcDetails.details, "SvcDetailsPatientCaseloadOrGroup"));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "SERVICE_RECORD_Save_Batch_Caseload_Or_Group_Service", Messages.DUP_SVC_REC, ref parms,
              delegate ()
              {
            // Note: No additional validation steps needed
        });
        }

        /***************************************************************************
         * saveBatchMultiEncounter */
        /**
         * Save multiple dates multiple encounters
         *
         * @param  reference       Reference file
         * @param  clientID        Client id
         * @param  pracID          Practioner id
         * @param  patID           Patient id
         * @param  isIEP           Is service part of an IFSP/IEP
         * @param  nameID          Friendly service name ID
         * @param  details         Required, JSON string containing dos,
         *                         minutes or miles, and notes for each service
         * @param  validateRec     Perform validation for this record?
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord saveBatchMultiEncounter(SqlConnection connSpedmon,
                                                                 DetailsLog log,
                                                                 UserInfo uInfo,
                                                                 string reference,
                                                                 string clientID,
                                                                 string pracID,
                                                                 string dossvcs,
                                                                 string patID,
                                                                 string isIEP,
                                                                 string nameID,
                                                                 string hasOrpDocID,
                                                                 string orpDocID,
                                                                 string hasSvcDetFlags,
                                                                 string svcDetFlag1,
                                                                 string svcDetFlag2,
                                                                 string svcDetFlag3,
                                                                 string svcDetFlag4,
                                                                 string details,
                                                                 string validateRec)
        {

            /*----------------------------
             * Batch save is for new records
             * only so we provide the required
             * values for save here
             *----------------------------*/

            string editDelReason = "";
            string saveType = Constants.SAVE_TYPE_NEW.ToString();
            string recID = "";

            /*----------------------------
             * Create additional validation
             * steps for the following
             * reqObject validation check.
             *----------------------------*/

            AdditionalValidation av = delegate (Object o) {

                /*-------------------------------
                 * Cast o to details object
                 *-------------------------------*/

                SvcDetailsMultiEncounter vDetails = (SvcDetailsMultiEncounter)o;

                /*-------------------------------
                 * Perform range checks on
                 * dates and minutes and check
                 * patient absent flag
                 *-------------------------------*/

                DateTime dr = DateTime.Now;
                int rowNum = 1;

                foreach (SvcDetailMultiEncounter vDetail in vDetails.details)
                {
                    serviceRecordRangeChecksDates(rowNum, uInfo, vDetail.dos, dr, ref log);
                    serviceRecordRangeChecksMinutes(rowNum, uInfo, vDetail.nummins1, ref log);
                    serviceRecordRangeChecksMinutes(rowNum, uInfo, vDetail.nummins2, ref log);
                    serviceRecordRangeChecksMinutes(rowNum, uInfo, vDetail.nummins3, ref log);
                    serviceRecordRangeChecksMinutes(rowNum, uInfo, vDetail.nummins4, ref log);
                    serviceRecordRangeChecksMinutes(rowNum, uInfo, vDetail.nummins5, ref log);
                    serviceRecordRangeChecksMinutes(rowNum, uInfo, vDetail.nummins6, ref log);
                    serviceRecordRangeChecksMinutes(rowNum, uInfo, vDetail.nummins7, ref log);
                    serviceRecordRangeChecksMinutes(rowNum, uInfo, vDetail.nummins8, ref log);
                    serviceRecordRangeChecksMinutes(rowNum, uInfo, vDetail.nummins9, ref log);
                    serviceRecordRangeChecksMinutes(rowNum, uInfo, vDetail.nummins10, ref log);
                    rowNum++;
                }
            };

            /*----------------------------
             * Parse and convert details
             * string (JSON) to object
             *
             * Note: The parsing will
             * peform datatype validation
             *----------------------------*/

            SvcDetailsMultiEncounter vSvcDetails = (SvcDetailsMultiEncounter)Validate.reqObject(details, Messages.INVALID_SVC_REC_DETAIL, "Spedmon", "Spedmon.SvcDetailsMultiEncounter", av);

            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            string vReference = Validate.reqSvcRecReference(uInfo, reference);
            int vClientID = Validate.reqClientID(uInfo, clientID);
            int vPracID = Validate.reqPracID(uInfo, pracID);

            string vDosMultiStr = Validate.reqString(dossvcs, Messages.SERVICE_DATE_BAD);
            DateTime[] vDosMultiVal = Validate.reqDateMulti(dossvcs, Messages.SERVICE_DATE_BAD, Constants.VAL_OPT_DATE_NO_FUTURE, Constants.CONV_OPT_DATE_NONE);

            int vPatID = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);
            bool vIsIEP = Validate.reqFlag(isIEP, Messages.IFSP_IEP_FLAG_BAD);
            int vNameID = Validate.reqInteger(nameID, Messages.INVALID_SERVICE);

            /*----------------------------
             * ORP Document
             *----------------------------*/

            bool vHasOrpDocID = Validate.reqFlag(hasOrpDocID, Messages.INVALID_HAS_ORP_DOC_ID, true);
            Object vOrpDocID = Validate.optInteger(orpDocID, Messages.INVALID_ORP_DOC_ID);

            /*----------------------------
             * Svc details
             *----------------------------*/

            bool vHasSvcDetFlags = Validate.reqFlag(hasSvcDetFlags, @"Invalid service details flag", true);
            Object vSvcDetFlag1 = Validate.optFlag(svcDetFlag1, @"Invalid service detail flag");
            Object vSvcDetFlag2 = Validate.optFlag(svcDetFlag2, @"Invalid service detail flag");
            Object vSvcDetFlag3 = Validate.optFlag(svcDetFlag3, @"Invalid service detail flag");
            Object vSvcDetFlag4 = Validate.optFlag(svcDetFlag4, @"Invalid service detail flag");

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@reference", SqlDbType.VarChar, vReference, ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.Int, vPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dosMulti", SqlDbType.VarChar, vDosMultiStr, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@patID", SqlDbType.Int, vPatID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@isIFSPorIEP", SqlDbType.Bit, vIsIEP, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@nameID", SqlDbType.Int, vNameID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@hasOrpDocID", SqlDbType.Bit, vHasOrpDocID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@orpDocID", SqlDbType.BigInt, vOrpDocID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@hasSvcDetailFlags", SqlDbType.Bit, vHasSvcDetFlags, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag1", SqlDbType.Bit, vSvcDetFlag1, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag2", SqlDbType.Bit, vSvcDetFlag2, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag3", SqlDbType.Bit, vSvcDetFlag3, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag4", SqlDbType.Bit, vSvcDetFlag4, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@MsgInvCombo", SqlDbType.VarChar, Messages.INVALID_PPN_COMBO, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinReq", SqlDbType.VarChar, Messages.MIN_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinDef", SqlDbType.VarChar, Messages.MIN_DEF, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMilReq", SqlDbType.VarChar, Messages.MIL_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatElg", SqlDbType.VarChar, Messages.PAT_ELG, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar, Messages.PAT_DOB_GTE_DOS, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatAbsent", SqlDbType.VarChar, Messages.PAT_ABSENT_NO_CLAIM, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgFutureDOS", SqlDbType.VarChar, Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

            /*----------------------------
             * Parse and convert details
             * object to table variable
             * parameter and add it.
             *----------------------------*/

            parms.Add(Database.SqlParmDataTable<SvcDetailMultiEncounter>("@svcdetails", vSvcDetails.details, "SvcDetailsMultiEncounter"));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "SERVICE_RECORD_Save_Batch_Multi_Encounter", Messages.DUP_SVC_REC, ref parms,
            delegate ()
            {
          // Note: No additional validation steps needed
      });
        }

        /***************************************************************************
         * saveVisionAndHearingService */
        /**
         * Save multiple service records
         *
         * @param  reference       Reference file
         * @param  clientID        Client id
         * @param  pracID          Practioner id
         * @param  patID           Patient id
         * @param  isIEP           Is service part of an IFSP/IEP
         * @param  nameID          Friendly service name ID
         * @param  details         Required, JSON string containing dos,
         *                         minutes or miles, and notes for each service
         * @param  validateRec     Perform validation for this record?
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord saveVisionAndHearingService(
              SqlConnection connSpedmon
            , DetailsLog log
            , UserInfo uInfo
            , string reference
            , string clientID
            , string visionPracID
            , string hearingPracID
            , string patID
            , string dos
            , string serviceTypesJSON
            , string notes
            , string validateRec)
        {

            /*----------------------------
             * Batch save is for new records
             * only so we provide the required
             * values for save here
             *----------------------------*/

            string editDelReason = "";
            string saveType = Constants.SAVE_TYPE_NEW.ToString();
            string recID = "";

            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            string vReference = Validate.reqSvcRecReference(uInfo, reference);
            long vClientID = Validate.reqClientID(uInfo, clientID);
            Object vVisionPracID = Validate.optInteger(visionPracID, Messages.INVALID_PRAC_ID);
            Object vHearingPracID = Validate.optInteger(hearingPracID, Messages.INVALID_PRAC_ID);
            DateTime vDos = Validate.reqDate(dos, Messages.SERVICE_DATE_BAD);
            long vPatID = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);
            string vNotes = Validate.optString(notes, Messages.INVALID_NOTES);
            string vServiceTypesJSON = Validate.reqString(serviceTypesJSON, Messages.INVALID_SERVICE);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@reference", SqlDbType.VarChar, vReference, ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@visionPracID", SqlDbType.BigInt, vVisionPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@hearingPracID", SqlDbType.BigInt, vHearingPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dos", SqlDbType.DateTime, vDos, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID", SqlDbType.BigInt, vPatID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@notes", SqlDbType.VarChar, vNotes, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@serviceTypesJSON", SqlDbType.VarChar, vServiceTypesJSON, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@MsgInvCombo", SqlDbType.VarChar, Messages.INVALID_PPN_COMBO, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinReq", SqlDbType.VarChar, Messages.MIN_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinDef", SqlDbType.VarChar, Messages.MIN_DEF, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMilReq", SqlDbType.VarChar, Messages.MIL_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatElg", SqlDbType.VarChar, Messages.PAT_ELG, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar, Messages.PAT_DOB_GTE_DOS, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatAbsent", SqlDbType.VarChar, Messages.PAT_ABSENT_NO_CLAIM, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgFutureDOS", SqlDbType.VarChar, Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "SERVICE_RECORD_Save_Vision_Hearing_Screening", Messages.DUP_SVC_REC, ref parms,
              delegate ()
              {
            // Note: No additional validation steps needed
        });
        }

        /***************************************************************************
         * saveSvcRecsOnDOS */
        /**
         * Save multiple service records for dos
         *
         * @param  clientID        Client id
         * @param  caseloadSvcRecsJSON         Required, JSON string containing array of objs
         * @param  dos             date of service
         * @param  validateRec     Perform validation for this record?
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord saveSvcRecsOnDOS(
                SqlConnection connSpedmon
              , DetailsLog log
              , UserInfo uInfo
              , string clientID
              , string pracID
              , string svcrecForDOSJSON
              , string validateRec
              , string svcetrmde)
        {

            /*----------------------------
             * Batch save is for new records
             * only so we provide the required
             * values for save here
             *----------------------------*/

            string saveType = Constants.SAVE_TYPE_NEW.ToString();
            string recID = "";

            /*----------------------------
             * Validate parameters specific
             * to this entity.save
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            long vClientID = Validate.reqClientID(uInfo, clientID);
            long vPracID = Validate.reqPracID(uInfo, pracID);
            string vReference = Validate.reqSvcRecReference(uInfo, null);
            string vSvcrecForDOSJSON = Validate.reqString(svcrecForDOSJSON, Messages.INVALID_SERVICE);
            int vSvcetrmde = Validate.reqInteger(svcetrmde, Messages.INVALID_NUMBER);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.BigInt, vPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@reference", SqlDbType.VarChar, vReference, ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@svcRecsJSON", SqlDbType.VarChar, vSvcrecForDOSJSON, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@svcetrmde", SqlDbType.Int, vSvcetrmde, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@MsgInvCombo", SqlDbType.VarChar, Messages.INVALID_PPN_COMBO, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinReq", SqlDbType.VarChar, Messages.MIN_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinDef", SqlDbType.VarChar, Messages.MIN_DEF, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMilReq", SqlDbType.VarChar, Messages.MIL_REQ, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatElg", SqlDbType.VarChar, Messages.PAT_ELG, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar, Messages.PAT_DOB_GTE_DOS, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatAbsent", SqlDbType.VarChar, Messages.PAT_ABSENT_NO_CLAIM, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgFutureDOS", SqlDbType.VarChar, Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, null, recID, "SERVICE_RECORD_Save_Batch_Same_Prac_Muti_Pat_Multi_Svc", Messages.DUP_SVC_REC, ref parms,
              delegate ()
              {
              // Note: No additional validation steps needed
          });
        }

        /***************************************************************************
         * serviceRecordRangeChecksDates */
        /**
         * Helper function to check date ranges
         *
         * @param  dos        Date of Service
         * @param  dr         Reference date (should be today)
         * @param  log        Details log
         ***************************************************************************/

        protected static void serviceRecordRangeChecksDates(int rowNum, UserInfo uInfo, DateTime dos, DateTime dr, ref DetailsLog log)
        {
            /*-------------------------------
             * Check date of service.
             *
             * Warn user if:
             *
             * - Date is a year or more in
             *   the past
             * - Date is a weekend
             *----------------------------*/

            if (DateTime.Compare(dos, dr) == 1) log.addDetail(Messages.VAL_SVC_REC_DOS_FUTURE, Return.RET_ERROR);
            if (Util.calculateAge(dos, dr) >= 1) log.addDetail(Messages.VAL_SVC_REC_DOS_PAST, Return.RET_WARNING);
            if (Util.isWeekend(dos)) log.addDetail(Messages.VAL_SVC_REC_DOS_WKND, Return.RET_WARNING);

        }

        /***************************************************************************
         * serviceRecordRangeChecksMinutes */
        /**
         * Helper function to check minutes
         *
         * @param  nummins    Number of minutes
         * @param  log        Details log
         ***************************************************************************/

        protected static void serviceRecordRangeChecksMinutes(int rowNum, UserInfo uInfo, int? nummins, ref DetailsLog log)
        {
            /*-------------------------------
             * Check minutes if minutes are
             * provided
             *
             * Warn user if:
             *
             * - # is < 0
             *
             * Note:
             *
             * We handle upper limits
             * > 2 hours, > 8 hours at
             * the database level
             *
             * Minutes do not apply
             * to transporation records so
             * and we don't know if this is
             * a transportation record yet
             * so we validate the NEED for
             * minutes at the database level
             *----------------------------*/

            if (nummins.HasValue)
                if (nummins < 0) throw new Critical(Messages.INVALID_NUM_MINS, log.details);

        }

        /***************************************************************************
         * serviceRecordRangeChecksStartTime */
        /**
         * Helper function to check start time
         *
         ***************************************************************************/

        protected static void serviceRecordRangeChecksStartTime(int rowNum, UserInfo uInfo, string starttime, ref DetailsLog log)
        {
            Object vStartTime = Validate.optTime(starttime, Messages.INVALID_START_TIME);
        }

        /***************************************************************************
         * isOKForUserToSeeOtherUsersServiceRecordsOrNotes */
        /**
         *
         *
         ***************************************************************************/

        public static bool isOKForUserToSeeOtherUsersServiceRecordsOrNotes(UserInfo uInfo)
        {

            if (uInfo.pcalStaff == true) return true;
            if (uInfo.userRoleID == Constants.ROLE_LEA_COORDINATOR_ID) return true;
            if (uInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID)
            {

                /* If user is a health services paraprofessional then no sharing otherwise its probably OK */

                if (uInfo.userPracStdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES)
                {
                    if (uInfo.userPracIsAParaProfessional == true)
                    {
                        return false;
                    }
                    return true;
                }

                /* If user is mental health professional then no sharing */

                else if (uInfo.userPracStdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_MENTAL_HEALTH_SERVICES)
                {
                    return false;
                }

                /* Its probably OK */

                else
                {
                    return true;
                }
            }
            return false;
        }

        /***************************************************************************
         * view */
        /**
         * Returns a list of service records for a given clientID
         *
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , int recViewType
                                      , bool pagedOrTop
                                      , string idx
                                      , string canEdit
                                      , string active
                                      , string clientID
                                      , string groupSvcClassNameID
                                      , string pracID
                                      , string patID
                                      , string svcTypeID
                                      , string reference
                                      , string startDate
                                      , string endDate
                                      , string startEntryDate
                                      , string endEntryDate
                                      , defineCols dc)
        {

            var viewUDF = "SERVICE_RECORDS_VIEW (@userID, @userGroup, @userRank, @recID, @clientID, @groupSvcClassNameID, @pracID, @patID, @svcTypeID, @reference, @startDate, @endDate, @startEntryDate, @endEntryDate, @active, @canEdit, 1)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view that
             * will be used in all cases
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, clientID);
            Object vGroupSvcClassNameID = Validate.optStdGroupSvcClassNameID(uInfo, groupSvcClassNameID);
            Object vPracID = Validate.optPracID(uInfo, pracID);
            Object vPatID = Validate.optPatID (uInfo, patID);
            Object vSvcTypeID = Validate.optInteger(svcTypeID, Messages.INVALID_SERVICE_TYPE);
            Object vReference = Validate.optString(reference, Messages.INVALID_SVC_REC_REF);
            Object vStartDate = Validate.optDate(startDate, Messages.INVALID_START_DATE);
            Object vEndDate = Validate.optDate(endDate, Messages.INVALID_END_DATE);
            Object vStartEntryDate = Validate.optDate(startEntryDate, Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
            Object vEndEntryDate = Validate.optDate(endEntryDate, Messages.INVALID_END_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
            Object vCanEdit = Validate.optFlag(canEdit, Messages.INVALID_EDIT_FLAG);

            /*--------------------------
             * Preset our control flags
             *----------------------------*/

            bool isEditDelete = false;
            bool isPrac = false;
            bool useOptPracIDValidate = true;
            bool useOptOrpGroupSvcClassNameID = true;

            /*--------------------------
             * Determine if user is a 
             * practitioner
             *----------------------------*/

            isPrac = (uInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID) ? true : false;

            /*--------------------------
             * Determine if this is an
             * edit/delete view
             *----------------------------*/

            if (vCanEdit != null) isEditDelete = Validate.optFlagToBool(vCanEdit, false);

            /*--------------------------
             * If user is a practitioner 
             * then preset our control flags
             * to the most common values
             * for practitioners
             *----------------------------*/

            if (isPrac == true)
            {
                useOptPracIDValidate = true;
                useOptOrpGroupSvcClassNameID = false;
            }

            /*--------------------------
             * Otherwise we will assume
             *----------------------------*/

            else
            {
                useOptPracIDValidate = true;
                useOptOrpGroupSvcClassNameID = true;
            }

            /*--------------------------
             * If this is a table view or
             * objects view or list view
             *----------------------------*/

            if ((recViewType == REC_VIEW_TBL) || (recViewType == REC_VIEW_OBJECTS || recViewType == REC_VIEW_RAW))
            {

                /* Client or reference must be passed */

                Validate.optParameterGroupOneOrMore(Messages.MISSING_REQ_PARMS, vClientID, vReference);

                /* If this NOT an edit/delete table view */

                if (isEditDelete == false)
                {
                    /* And user is a practitioner */

                    if (isPrac == true)
                    {
                        /* And patient ID is NOT selected, no shared view for practitioners */

                        if (vPatID == null)
                        {
                            useOptPracIDValidate = true; /* Enable pracID filter */
                            useOptOrpGroupSvcClassNameID = false; /* Disable group svc class name id*/
                        }

                        /* Otherwise shared view MIGHT be allowed for practitioners */

                        else
                        {
                            if (isOKForUserToSeeOtherUsersServiceRecordsOrNotes(uInfo) == true)
                            {
                                useOptPracIDValidate = false; /* Disable pracID filter*/
                                useOptOrpGroupSvcClassNameID = true;  /* Enable group svc class name id*/
                            }
                            else
                            {
                                useOptPracIDValidate = true; /* Enable pracID filter */
                                useOptOrpGroupSvcClassNameID = false; /* Disable group svc class name id*/
                            }
                        } /* Pat ID not provided */
                    } /* User is a practioner */
                } /* Non Edit View */
            } /* Table View */

            /*----------------------------
             * Start or end dates must both
             * be provided or not
             *----------------------------*/

            Validate.optParameterGroupAllOrNone(Messages.MISSING_REQ_PARMS, vStartDate, vEndDate);
            Validate.optParameterGroupAllOrNone(Messages.MISSING_REQ_PARMS, vStartEntryDate, vEndEntryDate);

            /*----------------------------
             * Use control flags to 
             * override prac and grpsvcclass
             * values if neccessary
             *----------------------------*/

            if (useOptPracIDValidate == false) vPracID = null;
            if (useOptOrpGroupSvcClassNameID == false) vGroupSvcClassNameID = null;

            /*----------------------------
             * Populate database parameters
             *----------------------------*/

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt, vGroupSvcClassNameID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.BigInt, vPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID", SqlDbType.BigInt, vPatID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcTypeID", SqlDbType.BigInt, vSvcTypeID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@reference", SqlDbType.VarChar, vReference, ParameterDirection.Input, 500));
            parms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@endDate", SqlDbType.DateTime, vEndDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@startEntryDate", SqlDbType.DateTime, vStartEntryDate, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@endEntryDate", SqlDbType.DateTime, vEndEntryDate, ParameterDirection.Input));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }


        /***************************************************************************
        * load */
        /**
         * Retrieves individual service record.  Used for internal loading.
         *
         * @param  recID           Service record, record id (will only return one record)
         * @param  canEdit         true = Limit to editable records only
         * @return                 ServiceRecord
         ***************************************************************************/

        public static ServiceRecord load(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string recID)
        {
            return (ServiceRecord)Entities.load(connSpedmon, log, uInfo, recID, typeof(ServiceRecord),
            delegate { return ServiceRecords.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", "", "", "", "", "", "", "", "", "", null); });
        }

        /***************************************************************************
         * viewTbl */
        /**
         * Returns a data table of records for preview or record selection.
         *
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable viewTbl(SqlConnection connSpedmon
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , bool paged
                                               , string pageNumber
                                               , string clientID
                                               , string groupSvcClassNameID
                                               , string pracID
                                               , string patID
                                               , string svcTypeID
                                               , string reference
                                               , string dateRange
                                               , string entryDateRange
                                               , string canEdit
                                               , string active)
        {

            /*-------------------------------
             * Parse date range (DOS) into
             * start and end dates
             *----------------------------*/

            string startDate = "";
            string endDate = "";
            Util.parseDateRange(dateRange, out startDate, out endDate);

            /*-------------------------------
             * Parse entry date range into
             * start and end dates
             *----------------------------*/

            string startEntryDate = "";
            string endEntryDate = "";
            Util.parseDateRange(entryDateRange, out startEntryDate, out endEntryDate);

            /*----------------------------
             * Determine if edit/delete
             * flag was passed as true
             *----------------------------*/

            bool isEditDelete = false;
            Object vCanEdit = Validate.optFlag(canEdit, Messages.INVALID_EDIT_FLAG);
            if (vCanEdit != null)
                isEditDelete = Validate.optFlagToBool(vCanEdit, false);

            /*----------------------------
             * Get clientID of user if
             * user is a client
             * We need this for the
             * dataview title
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, clientID);
            if (vClientID != null) clientID = vClientID.ToString();


            /*----------------------------
             * Define
             *   - our columns
             *   - page row order
             *   - sort order
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

                /*----------------------------
                 * Regular view
                 *----------------------------*/

                if (!isEditDelete)
                {

                    ss.addDisplayColumn("id as [id]");

                    /*----------------------------
                     * SBSC sees reference
                     *----------------------------*/

                    if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
                        ss.addDisplayColumn("reference as [File Reference]");

                    /*----------------------------
                     * Optionally display if parms
                     * are not passed
                     *----------------------------*/

                    ss.addDisplayColumnIfParmValueIsNull("clientName as [Client Name Entered]", "@clientID", ref parms);

                    /*----------------------------
                     * Always display
                     *----------------------------*/

                    ss.addDisplayColumn("pracName        as [Practitioner\nLast, First]");
                    ss.addDisplayColumn("patName         as [Patient\nLast, First]");
                    ss.addDisplayColumn("patCSIS         as [Patient\nSSID]");
                    ss.addDisplayColumn("dos as [Date of Service]");

                    /*----------------------------
                     * Clients see absent fields
                     * HERE.  SBSC sees it later
                     *----------------------------*/

                    if (uInfo.userGroup == Constants.USER_GROUP_CLIENT)
                    {
                        ss.addDisplayColumn("attendanceStatusSelectionName as [Attendance\nStatus]");
                    }

                    ss.addDisplayColumn("svcName as [Name of Service Provided]");
                    ss.addDisplayColumn("calPadsCodeValueStr as [CALPADS\nService\nCode]");
                    ss.addDisplayColumn("minsSatisfied       as [Service\nMinutes\nSatisfied]");
                    ss.addDisplayColumn("startTimeStr                   as [Start Time]");
                    ss.addDisplayColumn("minutesStartEndMiles           as [Minutes\nor\nTrips/Miles]");
                    ss.addDisplayColumn("isIFSPorIEPStr                 as [Part of\nIFSP/IEP]");
                    ss.addDisplayColumn("planTypeSelectionName as [Plan\nType]");

                    /*----------------------------
                     * SBSC see absent fields
                     * HERE.  Clients see it earlier
                     *----------------------------*/

                    if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
                    {
                        ss.addDisplayColumn("attendanceStatusSelectionName as [Attendance\nStatus]");
                    }

                    ss.addDisplayColumn("svcNotesFormBuilderTextAndNotes as [Notes]");
                    ss.addDisplayColumn("svcNotesPrivateFormBuilderText  as [Private Notes]");
                    ss.addDisplayColumn("renderingPracSig                as [Signed By]");
                    ss.addDisplayColumn("reviewingPracSig                as [Reviewed By]");
                    ss.addDisplayColumn("enteredByUserLastFirst          as [Entered By]");

                    ss.addDisplayColumn("id as [recID]");
                    ss.addDisplayColumn("orpDocID as [orpDocID]");

                    /*----------------------------
                     * If this is paged output
                     * add define the page row
                     * order
                     *----------------------------*/

                    if (paged)
                    {
                        ss.addPageOrderColumnIfParmValueIsNull("[Client Name Entered]", "@clientID", ref parms);
                        ss.addPageOrderColumn("[Date of Service]");
                    }

                    /*----------------------------
                     * Otherwise define the sort
                     * order
                     *----------------------------*/

                    else
                    {
                        ss.addSortColumnIfParmValueIsNull("clientName asc", "@clientID", ref parms);
                        ss.addSortColumn("dos asc");
                    }
                }

                /*----------------------------
                 * Edit View
                 *----------------------------*/

                else
                {

                    ss.addDisplayColumn("id as [id]");

                    /*----------------------------
                     * Clients see created date
                     * SBSC sees reference
                     *----------------------------*/

                    if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
                        ss.addDisplayColumnIfParmValueIsNull("reference as [File Reference]", "@reference", ref parms);
                    else
                        ss.addDisplayColumn("created as [Date Entered]");

                    /*----------------------------
                     * Optionally display if parms
                     * are not passed
                     *----------------------------*/

                    ss.addDisplayColumnIfParmValueIsNull("clientName as [Client Name Entered]", "@clientID", ref parms);

                    /*----------------------------
                     * Always display
                     *----------------------------*/

                    ss.addDisplayColumn("pracName as [Practitioner\nLast, First]");
                    ss.addDisplayColumn("patName as [Patient\nLast, First]");
                    ss.addDisplayColumn("dos as [Date of Service]");

                    /*----------------------------
                     * Clients see attendance status
                     *----------------------------*/

                    if (uInfo.userGroup == Constants.USER_GROUP_CLIENT)
                    {
                        ss.addDisplayColumn("attendanceStatusSelectionName as [Attendance\nStatus]");
                    }

                    ss.addDisplayColumn("svcName                        as [Name of Service Provided]");
                    ss.addDisplayColumn("calPadsCodeValueStr            as [CALPADS\nService\nCode]");
                    ss.addDisplayColumn("minsSatisfied                  as [Service\nMinutes\nSatisfied]");
                    ss.addDisplayColumn("startTimeStr                   as [Start\nTime]");
                    ss.addDisplayColumn("minutesStartEndMiles           as [Minutes\nor\nTrips/Miles]");
                    ss.addDisplayColumn("isIFSPorIEPStr                 as [Part of\nIFSP/IEP]");
                    ss.addDisplayColumn("planTypeSelectionName          as [Plan\nType]");
                    ss.addDisplayColumn("renderingPracSig               as [Signed By]");
                    ss.addDisplayColumn("reviewingPracSig               as [Reviewed By]");
                    ss.addDisplayColumn("enteredByUserLastFirst         as [Entered By]");
                    ss.addDisplayColumn("id as [recID]");

                    /*----------------------------
                     * If this is paged output
                     * define the page row order
                     *----------------------------*/

                    if (paged)
                    {

                        /*----------------------------
                         * SBSC is ordered by
                         *   - File reference asc
                         *   - First record entered
                         *     first on the list
                         * This is determined using
                         *   - reference asc
                         *   - id asc
                         *----------------------------*/

                        if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
                        {
                            ss.addPageOrderColumnIfParmValueIsNull("[File Reference] asc", "@reference", ref parms);
                            ss.addPageOrderColumn("[id] asc");
                        }

                        /*----------------------------
                         * Client is ordered by
                         *   - Creation date earliest
                         *     first
                         *   - First record entered
                         *     first on the list
                         * This is determined using
                         *   - create date
                         *   - id
                         *----------------------------*/

                        else
                        {
                            ss.addPageOrderColumn("[Date Entered] asc");
                            ss.addPageOrderColumn("[id] asc");
                        }

                        /*----------------------------
                         * Optionally sort by other
                         * columns if their parms are
                         * not provided
                         *----------------------------*/

                        ss.addPageOrderColumnIfParmValueIsNull("[Client Name Entered]", "@clientID", ref parms);

                    }

                    /*----------------------------
                     * Otherwise define the sort
                     * order
                     *
                     * Note: Not used
                     *----------------------------*/

                    else
                    {
                    }

                }

                pageroworder = ss.pageRowOrder();

            };

            string tableName = @"Service Records";
            string tableFooter = Messages.CONFIDENTIAL;

            if (!Util.IsNullOrEmpty(clientID))
            {
                Client c = Clients.load(connSpedmon, log, uInfo, clientID);
                tableName = tableName + " - " + c.name;
            }

            // if ( !Util.IsNullOrEmpty (pracID) )
            // {
            //    Practitioner prac = Practitioners.load ( connSpedmon, log, uInfo, pracID );
            //    tableName = tableName + " - " + prac.name;
            // }

            //if ( !Util.IsNullOrEmpty (patID) )
            //{
            //  Patient pat = Patients.load ( connSpedmon, log, uInfo, patID );
            //  tableName = tableName + " - " + pat.name;
            // }

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return ServiceRecords.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, clientID, groupSvcClassNameID, pracID, patID, svcTypeID, reference, startDate, endDate, startEntryDate, endEntryDate, dc); },
              tableName,
              tableFooter);

        }

        /***************************************************************************
         * viewTblSvcrecsForRmtsMatchScreen */
        /**
         * This is the service records downloadable report from the thumbs-up RMTS
         * matching screen.  It has slightly different columns and column order
         * than the other service records downloadable reports, but it is still
         * identical in all other respects.
         *
         * @return                 ReturnDataTable
         ***************************************************************************/
        public static ReturnDataTable viewTblSvcrecsForRmtsMatchScreen(
              SqlConnection connSpedmon
            , DetailsLog log
            , UserInfo uInfo
            , bool paged
            , string pageNumber
            , string clientID
            , string pracID
            , string dateRange
            , string canEdit
            , string active)
        {

            /*-------------------------------
             * Parse date range (DOS) into
             * start and end dates
             *----------------------------*/

            string startDate = "";
            string endDate = "";
            Util.parseDateRange(dateRange, out startDate, out endDate);

            /*----------------------------
             * Determine if edit/delete
             * flag was passed as true
             *----------------------------*/

            bool isEditDelete = false;
            Object vCanEdit = Validate.optFlag(canEdit, Messages.INVALID_EDIT_FLAG);
            if (vCanEdit != null) isEditDelete = Validate.optFlagToBool(vCanEdit, false);

            /*----------------------------
             * Get clientID of user if
             * user is a client
             * We need this for the
             * dataview title
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, clientID);
            if (vClientID != null) clientID = vClientID.ToString();


            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

                ss.addDisplayColumn("quarter as Quarter");
                ss.addDisplayColumn("pracName        as [Practitioner\nLast, First]");
                ss.addDisplayColumn("patName         as [Patient\nLast, First]");
                ss.addDisplayColumn("dos as [Date of Service]");

                ss.addDisplayColumn("svcName as [Name of Service Provided]");
                ss.addDisplayColumn("startTimeStr                   as [Start Time]");
                ss.addDisplayColumn("minsSatisfied       as [Service\nMinutes\nSatisfied]");

                pageroworder = ss.pageRowOrder();

            };

            string tableName = @"Service Records";
            string tableFooter = Messages.CONFIDENTIAL;

            if (!Util.IsNullOrEmpty(clientID))
            {
                Client c = Clients.load(connSpedmon, log, uInfo, clientID);
                tableName = tableName + " - " + c.name;
            }

            if (!Util.IsNullOrEmpty(pracID))
            {
                Practitioner p = Practitioners.load(connSpedmon, log, uInfo, pracID);
                tableName = tableName + " - " + p.name;
            }

            if (!Util.IsNullOrEmpty(dateRange))
            {
                tableName = tableName + " - " + dateRange;
            }

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
              delegate {
                  return ServiceRecords.view(
                       connSpedmon
                      , log
                      , uInfo
                      , Entities.REC_VIEW_TBL
                      , paged
                      , pageNumber
                      , canEdit
                      , active
                      , clientID
                      , ""
                      , pracID
                      , ""
                      , ""
                      , ""
                      , startDate
                      , endDate
                      , ""
                      , ""
                      , dc);
              }
              , tableName
              , tableFooter);

        }

        /***************************************************************************
         * getStoredFileWorkFlowURL */
        /**
         * Returns url that can be put in a link to access the file
         * FOR PCAL USE ONLY!!
         *
         * @return ReturnValue
         ***************************************************************************/
        public static ReturnValue getStoredFileWorkFlowURL(string batchID = @"", string fileReference = @"")
        {
            ReturnValue rd = new ReturnValue();
            /* sbs_all_workflow_file_viewer.aspx */

            string viewerURL = HttpApplication.createLink(URL_SBS_ALL_WORKFLOW_FILE_VIEWER
                                                            , true
                                                            , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                            , new NameValue(Constants.PARM_BATCH_ID, batchID)
                                                            , new NameValue(Constants.PARM_BATCH_FILE_REFERENCE, fileReference));

            rd.value = viewerURL;

            return rd;
        }


        /***************************************************************************
         * viewInfoTblNoORPDocAscPCALOnly */
        /**
         * Temp method for orp doc association
         *
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnInfoTable viewInfoTblNoORPDocAscPCALOnly
        (
            SqlConnection connSpedmon
          , DetailsLog log
          , UserInfo uInfo
        )

        {

            string viewUDF = @"dbo.SERVICE_RECORDS_THAT_REQUIRE_ORP_DOC_ASSOCIATION_PCAL_ONLY (@userID,@userGroup,@userRank)";
            List<SqlParameter> parms = new List<SqlParameter>();

            /* Lookup records and return as an info table */

            ReturnInfoTable rd = Entities.viewInfoTbl(connSpedmon, log, uInfo, viewUDF, parms);

            for (int rowIdx = 0; rowIdx < rd.numRows; rowIdx++)
            {

                /* Build link for file reference and replace the file reference string with this link */

                string fileRefID = rd.rowvalues[rowIdx].values[0];
                string fileRefUrl = MBA.StoredFileViewOrDownloadHandler.GenerateURL(URL_STORED_FILE_WORK_BATCH, EAW.MediaFile.DistributionModes.DISPLAY, fileRefID);
                string fileRefLnk = String.Format(@"<a title=""Click here to open"" target=""_blank"" href=""{0}"">Open {1}</a>", fileRefUrl, fileRefID);

                rd.rowvalues[rowIdx].values[0] = fileRefLnk;

                /* Build link for editing servie record and replace the service record id string with this link */

                string svcRecID = rd.rowvalues[rowIdx].values[5];
                string svcRecEditUrl = MBA.HttpApplication.createLink(@"sbs_all_svcrec_save.aspx"
                                                                       , true
                                                                       , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                       , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT.ToString())
                                                                       , new NameValue(Constants.PARM_REC_ID, svcRecID)
                                                                      );

                string svcRecEditLnk = String.Format(@"<a title=""Click here to edit"" target=""_blank"" href=""{0}"">Edit {1}</a>", svcRecEditUrl, svcRecID);

                rd.rowvalues[rowIdx].values[5] = svcRecEditLnk;

            }

            return rd;

        }

        /***************************************************************************
         * rptTattle */
        /**
         * Displays all active practitioners who have not entered or submitted work
         * for each month in the given date range.
         *
         * If practitioners do not provide us with service records for a given month
         * then the client could miss the oppurtunity to be reimbursed for eligible
         * services and thus lose revenue.
         *
         * This report provides a management tool for clients by "tattling" on those
         * practitioners who have not provides us with service records.
         *
         * @param  clientID        Client ID
         * @param  dateRange       Date range (start - end or start)
         * @param  startDate       Start date
         * @param  endDate         End date
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable rptTattle(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                bool paged,
                                                string pageNumber,
                                                string clientID,
                                                string groupID,
                                                string pracID,
                                                string dateRange,
                                                string canEdit,
                                                string active)
        {

            /*-------------------------------
             * Parse date range into start
             * and end dates
             *----------------------------*/

            string startDate = "";
            string endDate = "";
            Util.parseDateRange(dateRange, out startDate, out endDate);

            /*----------------------------
             * Check for required
             * parameters and validate
             * data integrity of all
             * supplied parameters
             * Note: We ignore if the end
             * date is in the future
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo, clientID);
            Object vGroupID = Validate.optInteger(groupID, Messages.INVALID_CLIENT_ID);
            Object vPracID = Validate.optPracID(uInfo, pracID);
            DateTime vStartDate = Validate.reqDate(startDate, Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
            DateTime vEndDate = Validate.reqDate(endDate, Messages.INVALID_END_DATE);

            /*----------------------------
             * Setup database call
             *----------------------------*/

            List<SqlParameter> prms = new List<SqlParameter>();


            prms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@groupID", SqlDbType.Int, vGroupID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@pracID", SqlDbType.Int, vPracID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@endDate", SqlDbType.DateTime, vEndDate, ParameterDirection.Input));

            /*----------------------------
             * Generate sql
             *---------------------------*/

            string viewUDF = "dbo.RPT_SERVICE_RECORD_TATTLE(@clientID,@groupID,@pracID, @startDate, @endDate)";

            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                //TODO: Come up with a default page row order if no order is defined
                /* Note: DO NOT REMOVE Client from the paging right now*/
                ss.addDisplayColumn("Client", true);
                ss.addDisplayColumn("[Month/Year]");
                ss.addDisplayColumn("[Last Name]");
                ss.addDisplayColumn("[First Name]");
                ss.addDisplayColumnIfParmValueIsNull("[Practitioner Type]", "@groupID", ref parms);
                ss.addDisplayColumn("[Reporting Group]");
                ss.addDisplayColumnIfParmValueIsNull("[Practitioner ID]", "@pracID", ref parms);
                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, active, viewUDF, prms, null, dc);

        }

        /***************************************************************************
         * rptWorkNotSub */
        /**
         * Displays number of active practitioners and the number of active
         * practitioners who have not entered or submitted work
         * for each client in the given date range.
         *
         * If practitioners do not provide us with service records for a given date range
         * then the client could miss the oppurtunity to be reimbursed for eligible
         * services and thus lose revenue.
         *
         * This report provides a management tool for clients by "tattling" on those
         * practitioners who have not provided us with service records.
         *
         * @param  dateRange       Date range (start - end or start)
         * @param  startDate       Start date
         * @param  endDate         End date
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable rptWorkNotSub(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                    bool paged,
                                                    string pageNumber,
                                                    string date)

        {

            /*----------------------------
             * Check for required
             * parameters and validate
             * data integrity of all
             * supplied parameters
             * Note: We ignore if the end
             * date is in the future
             *----------------------------*/

            Object vDate = Validate.optDate(date, Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);


            /*----------------------------
             * Setup database call
             *----------------------------*/

            List<SqlParameter> prms = new List<SqlParameter>();

            prms.Add(Database.SqlParm("@date", SqlDbType.DateTime, vDate, ParameterDirection.Input));

            /*----------------------------
             * Generate sql
             *---------------------------*/

            string viewUDF = "dbo.RPT_CLIENT_WORK_NOT_RECIEVED(@date)";
            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("Client_Name as [Client Name]", true);
                ss.addDisplayColumn("District_Rep as [District Rep]", true);
                ss.addDisplayColumn("[MonthYear]");
                ss.addDisplayColumn("[%Submitted]");
                ss.addDisplayColumn("dbo.RPT_ROUND_FMT(Revenue) as [Revenue]");
                ss.addDisplayColumn("[%notSubmitted] as [%Not Submitted] ");
                ss.addDisplayColumn("dbo.RPT_ROUND_FMT(LostRevenue) as [Lost Revenue]");

                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, viewUDF, prms, null, dc);

        }

        /***************************************************************************
         * rptCombined1on1ByPmtDate */
        /**
         * Report for patients claims for 1:1 Aide by Payment date.
         *
         * @param  clientID        Client ID
         * @param  dateRange       Date range (start - end or start)
         * @param  startDate       Start date
         * @param  endDate         End date
         * @return                 ReturnDataTable
         ***************************************************************************/


        public static ReturnDataTable rptCombined1on1ByPmtDate(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                               bool paged,
                                                               string pageNumber,
                                                               string clientID,
                                                               string pracID,
                                                               string dateRange)

        {

            /*-------------------------------
             * Parse date range into start
             * and end dates
             *----------------------------*/

            string startDate = "";
            string endDate = "";
            Util.parseDateRange(dateRange, out startDate, out endDate);

            /*----------------------------
             * Check for required
             * parameters and validate
             * data integrity of all
             * supplied parameters
             * Note: We ignore if the end
             * date is in the future
             *----------------------------*/
            Object vClientID = Validate.optClientID(uInfo, clientID);
            Object vPracID = Validate.reqInteger(pracID, Messages.INVALID_PRAC_ID);
            DateTime vStartDate = Validate.reqDate(startDate, Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
            DateTime vEndDate = Validate.reqDate(endDate, Messages.INVALID_END_DATE);
            /*----------------------------
             * Setup database call
             *----------------------------*/

            List<SqlParameter> prms = new List<SqlParameter>();

            prms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@pracID", SqlDbType.Int, vPracID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@endDate", SqlDbType.DateTime, vEndDate, ParameterDirection.Input));

            /*----------------------------
             * Generate sql
             *---------------------------*/

            string viewUDF = "dbo.RPT_COMBINED_1on1_BY_PAYMENT_DATE(@clientID,@pracID,@startDate, @endDate)";
            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("Patient_Name as [Patient Name]", true);
                ss.addDisplayColumn("PRAC_NAME as [Practitioner Name]");
                ss.addDisplayColumn("dbo.RPT_ROUND_FMT(Amount) as [Amount]");
                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, viewUDF, prms, null, dc);

        }

        /***************************************************************************
         * rptCombined1on1BySvcDate */
        /**
         * Report for patients claims for 1:1 Aide by Service date.
         *
         * @param  clientID        Client ID
         * @param  dateRange       Date range (start - end or start)
         * @param  startDate       Start date
         * @param  endDate         End date
         * @return                 ReturnDataTable
         ***************************************************************************/


        public static ReturnDataTable rptCombined1on1BySvcDate(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                               bool paged,
                                                               string pageNumber,
                                                               string clientID,
                                                               string pracID,
                                                               string dateRange)
        {

            /*-------------------------------
             * Parse date range into start
             * and end dates
             *----------------------------*/

            string startDate = "";
            string endDate = "";
            Util.parseDateRange(dateRange, out startDate, out endDate);

            /*----------------------------
             * Check for required
             * parameters and validate
             * data integrity of all
             * supplied parameters
             * Note: We ignore if the end
             * date is in the future
             *----------------------------*/
            Object vClientID = Validate.optClientID(uInfo, clientID);
            Object vPracID = Validate.reqInteger(pracID, Messages.INVALID_GROUP_ID);
            DateTime vStartDate = Validate.reqDate(startDate, Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
            DateTime vEndDate = Validate.reqDate(endDate, Messages.INVALID_END_DATE);

            /*----------------------------
             * Setup database call
             *----------------------------*/

            List<SqlParameter> prms = new List<SqlParameter>();

            prms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@pracID", SqlDbType.Int, vPracID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@endDate", SqlDbType.DateTime, vEndDate, ParameterDirection.Input));

            /*----------------------------
             * Generate sql
             *---------------------------*/

            string viewUDF = "dbo.RPT_COMBINED_1on1_BY_SERVICE_DATE(@clientID,@pracID,@startDate, @endDate)";
            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("Patient_Name as [Patient Name]", true);
                ss.addDisplayColumn("PRAC_NAME as [Practitioner Name]"); ;
                ss.addDisplayColumn("dbo.RPT_ROUND_FMT(Amount) as [Amount]");
                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, viewUDF, prms, null, dc);

        }

        /***************************************************************************
         * rptSvcRecordsSvcNotes */
        /**
         * Displays service record and assosciated service note data (if any)
         *
         *  @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable rptSvcRecordsSvcNotes(
            SqlConnection connSpedmon
          , DetailsLog log
          , UserInfo uInfo
          , bool paged
          , string pageNumber
          , string clientID
          , string dateRange
          , string pracID
          , string patID
          , string canEdit
          , string active)
        {

            /*-------------------------------
             * Parse date range into start
             * and end dates
             *----------------------------*/

            string startDate = "";
            string endDate = "";
            Util.parseDateRange(dateRange, out startDate, out endDate);

            /*----------------------------
             * Check for required
             * parameters and validate
             * data integrity of all
             * supplied parameters
             * Note: We ignore if the end
             * date is in the future
             *----------------------------*/

            long vClientID = Validate.reqClientID(uInfo, clientID);
            DateTime vStartDate = Validate.reqDate(startDate, Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
            DateTime vEndDate = Validate.reqDate(endDate, Messages.INVALID_END_DATE);
            Object vPracID = Validate.optPracID(uInfo, pracID);
            Object vPatID = Validate.optInteger(patID, Messages.INVALID_PAT_ID);

            /*----------------------------
             * Setup database call
             *----------------------------*/

            List<SqlParameter> prms = new List<SqlParameter>();


            prms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@pracID", SqlDbType.Int, vPracID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@patID", SqlDbType.Int, vPatID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@endDate", SqlDbType.DateTime, vEndDate, ParameterDirection.Input));

            /*----------------------------
             * Generate sql
             *---------------------------*/

            string viewUDF = "dbo.SERVICE_RECORDS_VIEW_SVC_NOTES(@userID, @userGroup, @userRank, @clientID, @startDate, @endDate, @pracID, @patID, null)";

            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("RecNumber as [Rec #]", true);
                ss.addDisplayColumn("RecLine   as [Line]", true);
                ss.addDisplayColumnIfParmValueIsNull("[Practitioner]", "@pracID", ref parms);
                ss.addDisplayColumnIfParmValueIsNull("[Patient]", "@patID", ref parms);
                ss.addDisplayColumn("[DOS]");
                ss.addDisplayColumn("[Patient Absent] as [Patient\nAbsent]");
                ss.addDisplayColumn("[Service]");
                ss.addDisplayColumn("[Mins]");
                ss.addDisplayColumn("[Start Time] as [Start Time]");
                ss.addDisplayColumn("[Unformatted Notes]");
                ss.addDisplayColumn("[Formatted Note Question]");
                ss.addDisplayColumn("[Formatted Note Answers]");
                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            ReturnDataTable rd = Entities.viewRpt(connSpedmon
                                                   , log
                                                   , uInfo
                                                   , paged
                                                   , pageNumber
                                                   , active
                                                   , viewUDF
                                                   , prms
                                                   , null
                                                   , dc
                                                   , "Service Records and Progress Notes"
                                                   , Messages.CONFIDENTIAL);

            return rd;
        }

        /***************************************************************************
         * viewRecordsToApproveByPracUserID */
        /**
         * Displays service records that need approval
         *
         *  @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable viewSvcRecordsToApproveByPracID(
              SqlConnection connSpedmon
            , DetailsLog log
            , UserInfo uInfo
            , bool paged
            , string pageNumber
            , string clientID
            , string pracID
            , string approvingPracID
            , string canEdit
            , string active)
        {


            long vClientID = Validate.reqClientID(uInfo, clientID);
            Object vPracID = Validate.optInteger(pracID, Messages.INVALID_PRAC_ID);
            long vApprovingPracID = Validate.reqPracID(uInfo, approvingPracID);

            /*----------------------------
             * Setup database call
             *----------------------------*/

            List<SqlParameter> prms = new List<SqlParameter>();

            prms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@pracID", SqlDbType.Int, vPracID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@approvingPracID", SqlDbType.Int, vApprovingPracID, ParameterDirection.Input));

            /*----------------------------
             * Generate sql
             *---------------------------*/

            string viewUDF = "dbo.SERVICE_RECORDS_TO_APPROVE_BY_PRAC_USER_ID_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @approvingPracID)";

            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("id", true);
                ss.addDisplayColumn("pracName as [Practitioner]");
                ss.addDisplayColumn("patName  as [Patient]");
                ss.addDisplayColumn("dos      as [DOS]");
                ss.addDisplayColumn("svcName  as [Service]");
                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            ReturnDataTable rd = Entities.viewRpt(connSpedmon
                                                   , log
                                                   , uInfo
                                                   , paged
                                                   , pageNumber
                                                   , active
                                                   , viewUDF
                                                   , prms
                                                   , null
                                                   , dc
                                                   , "Service Records That Require Approval"
                                                   , Messages.CONFIDENTIAL);

            return rd;

        }

        /***************************************************************************
         * rptSvcsRenderedComplianceStatsByPracGroupForPat */
        /**
         * Displays compliance stats
         *
         *  @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable rptSvcsRenderedComplianceStatsByPracGroupForPat(
              SqlConnection connSpedmon
            , DetailsLog log
            , UserInfo uInfo
            , bool paged
            , string pageNumber
            , string clientID
            , string patID
            , string dateRange
            , string svcClass
            , string pracID
            , string canEdit
            , string active)
        {
            /*-------------------------------
             * Parse date range into start
             * and end dates
             *----------------------------*/

            string startDate = "";
            string endDate = "";
            Util.parseDateRange(dateRange, out startDate, out endDate);

            /*-------------------------------
             * Validate
             *----------------------------*/

            long vClientID = Validate.reqClientID(uInfo, clientID);
            long vPatID = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);
            Object vPracID = Validate.optPracID(uInfo, pracID);
            Object vSvcClass = Validate.optInteger(svcClass, @"Invalid service class");
            Object vStartDate = Validate.optDate(startDate, Messages.INVALID_START_DATE);
            Object vEndDate = Validate.optDate(endDate, Messages.INVALID_END_DATE);

            /*----------------------------
             * Setup database call
             *----------------------------*/

            List<SqlParameter> prms = new List<SqlParameter>();

            prms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@patID", SqlDbType.BigInt, vPatID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@endDate", SqlDbType.DateTime, vEndDate, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@pracGroupServiceClassNameID", SqlDbType.BigInt, vSvcClass, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@pracID", SqlDbType.BigInt, vPracID, ParameterDirection.Input));


            /*----------------------------
             * Generate sql
             *---------------------------*/

            string viewUDF = "dbo.SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT (@userID,@userGroup,@userRank,@clientID,@patID,@startDate,@endDate,@pracGroupServiceClassNameID,@pracID)";

            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("GENERAL_SERVICE_PLAN_GROUP_NAME as [Service Rendered]", true);
                ss.addDisplayColumn("FROM_DATE as [From\nPeriod\nStarting]");
                ss.addDisplayColumn("TO_DATE as [To\nPeriod\nEnding]");
                ss.addDisplayColumn("NUM_PRACS as [Number of\nRendering\nPractitioners]");
                ss.addDisplayColumn("MIN_DOS as [First\nDOS]");
                ss.addDisplayColumn("MAX_DOS as [Last\nDOS]");
                ss.addDisplayColumn("NUM_SVCS_PRESENT as [Total\nSessions \nPresent]");
                ss.addDisplayColumn("TOT_MINS_PRESENT as [Total\nMinutes\nPresent]");
                ss.addDisplayColumn("NUM_SVCS_ABSENT  as [Total\nSessions \nAbsent]");
                ss.addDisplayColumn("TOT_MINS_ABSENT  as [Total\nMinutes\nAbsent]");
                pageroworder = ss.pageRowOrder();
            };

            string tableName = SEL_LABEL_PLAN_SVC_COMP_REPT;

            Client c = Clients.load(connSpedmon, log, uInfo, vClientID.ToString());
            tableName = tableName + " - " + c.name;

            Patient pat = Patients.load(connSpedmon, log, uInfo, patID);
            tableName = tableName + " - " + pat.name + " (" + pat.dob.ToShortDateString() + ")";

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            ReturnDataTable rd = Entities.viewRpt(connSpedmon
                                                   , log
                                                   , uInfo
                                                   , paged
                                                   , pageNumber
                                                   , active
                                                   , viewUDF
                                                   , prms
                                                   , null
                                                   , dc
                                                   , tableName
                                                   , Messages.CONFIDENTIAL);

            return rd;

        }

        /***************************************************************************
         * viewLastSvcNotesAsOfRefDateInfoTable */
        /**
         * Outputs top 100 notes as of refDate for clientID, pracID, patID
         *
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @param  clientID        Client ID
         * @param  pracID          Practitioner ID
         * @return                 ReturnInfoTable
         ***************************************************************************/

        public static ReturnInfoTable viewLastSvcNotesAsOfRefDateInfoTable(SqlConnection connSpedmon
                                                          , DetailsLog log
                                                          , UserInfo uInfo
                                                          , string clientID
                                                          , string pracID
                                                          , string patID
                                                                             , string refDate)
        {

            ReturnInfoTable so = new ReturnInfoTable();

            /* Note: This method is only called by pracs */

            Object vGroupSvcClassNameID = null;  /* Note: The value for groupSvcClassNameID is determined in this method ONLY.  It is not passed in. */
            Object vPracID = null;  /* Note: Prac is redetermined in this method.  pracID passed in is ignored now. */

            /*----------------------------
              * Validate parameters specific
              * to this entity.view
              * and populate their
              * coresponding database
              * parameters
              *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            string viewUDF = "SERVICE_RECORDS_NOTES_VIEW_LAST_AS_OF_REF_DATE (null,null,null,@clientID,@groupSvcClassNameID,@pracID,@patID,@refDate)";

            int vClientID = Validate.reqClientID(uInfo, clientID);
            int vPatID = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);
            Object vRefDate = Validate.optDate(refDate, Messages.INVALID_DOS);

            if (isOKForUserToSeeOtherUsersServiceRecordsOrNotes(uInfo) == true)
            {
                vPracID = null;
                vGroupSvcClassNameID = Validate.optOrpGroupSvcClassNameID(uInfo, "");
            }
            else
            {
                vPracID = Validate.optPracID(uInfo, "");
                vGroupSvcClassNameID = null;
            }

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt, vGroupSvcClassNameID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.Int, vPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID", SqlDbType.Int, vPatID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@refDate", SqlDbType.Date, vRefDate, ParameterDirection.Input));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            so = Entities.viewInfoTbl(connSpedmon, log, uInfo, viewUDF, parms);

            /*----------------------------
             * Retrieve patient record
             *----------------------------*/

            Patient p = Patients.load(connSpedmon, log, uInfo, vPatID.ToString());

            if (!Util.IsNullOrEmpty(refDate))
            {
                so.caption = "Latest Notes as of " + refDate + " for " + p.name;
            }
            else
            {
                so.caption = "Latest Notes for " + p.name;
            }

            return so;

        }

        /***************************************************************************
          * rptSpEdServicesForSelpaExportSynch */
        /**
         * 
         **************************************************************************/
        public static ReturnDataTable rptSpEdServicesForSelpaExportSynch(

              SqlConnection connSpedmon
            , SqlConnection connUsers
            , DetailsLog log
            , UserInfo uInfo
            , bool paged
            , string pageNumber
            , string clientID
            , string entryDateRange)
        {

            string reportUDF = "RPT_SPED_SERVICES_FOR_SELPA_EXPORT_SYNCH (null, null, null, @clientID, @startDate, @endDate, @startEntryDate, @endEntryDate)";

            /*-------------------------------
             * Parse date range (DOS) into
             * start and end dates
             *----------------------------*/

            string dateRange = CdeComplianceCommon.getCurrentWindowStartDateStr(connUsers, log, uInfo) + @" - " + CdeComplianceCommon.getCurrentWindowEndDateStr(connUsers, log, uInfo);
            string startDate = "";
            string endDate = "";
            Util.parseDateRange(dateRange, out startDate, out endDate);

            /*-------------------------------
             * Parse entry date range into
             * start and end dates
             *----------------------------*/

            string startEntryDate = "";
            string endEntryDate = "";
            Util.parseDateRange(entryDateRange, out startEntryDate, out endEntryDate);


            /*-------------------------------
             * Validate
             *-------------------------------*/

            int vClientID = Validate.reqClientID(uInfo, clientID);
            DateTime vStartDate = Validate.reqDate(startDate, Messages.INVALID_DOS);
            DateTime vEndDate = Validate.reqDate(endDate, Messages.INVALID_DOS);
            DateTime vStartEntryDate = Validate.reqDate(startEntryDate, Messages.INVALID_ENTRY_DATE);
            DateTime vEndEntryDate = Validate.reqDate(endEntryDate, Messages.INVALID_ENTRY_DATE);

            var c = Clients.load(connSpedmon, log, uInfo, vClientID.ToString());
            string tblName = "SELPA Export " + c.name + " DOS " + dateRange + " DOE " + entryDateRange;

            /*-------------------------------
             * Define columns
             *-------------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("clientName as [District Name]", true);
                ss.addDisplayColumn("patSSID as [Student SSID]", true);
                ss.addDisplayColumn("patNameLast as [Student Last]", true);
                ss.addDisplayColumn("patNameFirst as [Student First]", true);
                ss.addDisplayColumn("dos as [Date of Service]", true);
                ss.addDisplayColumn("pracNameLast as [Provider Last]");
                ss.addDisplayColumn("pracNameFirst as [Provider First]");
                ss.addDisplayColumn("svcName  as [Name of Service Provided]");
                ss.addDisplayColumn("calpadsCode as [CALPADS]");
                ss.addDisplayColumn("minsSatisfied as [Minutes Satisfied]");
                ss.addDisplayColumn("attendanceStatus as [Attendance Status]");
                ss.addDisplayColumn("svcRecID as [Service Record ID]");
                ss.addDisplayColumn("svcRecStatus as [Service Record Status]");
                pageroworder = ss.pageRowOrder();
            };

            /*-------------------------------
             * Pass parameters
             *-------------------------------*/

            var prms = new List<SqlParameter>();

            prms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@endDate", SqlDbType.DateTime, vEndDate, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@startEntryDate", SqlDbType.DateTime, vStartEntryDate, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@endEntryDate", SqlDbType.DateTime, vEndEntryDate, ParameterDirection.Input));

            ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc);
            rd.tableName = tblName;
            return rd;

        }

        private static void defineColsForSelpaExport(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            ss.addDisplayColumn("clientName as [District Name]", true);
            ss.addDisplayColumn("patSSID as [Student SSID]", true);
            ss.addDisplayColumn("patNameLast as [Student Last]", true);
            ss.addDisplayColumn("patNameFirst as [Student First]", true);
            ss.addDisplayColumn("dos as [Date of Service]", true);
            ss.addDisplayColumn("pracNameLast as [Provider Last]");
            ss.addDisplayColumn("pracNameFirst as [Provider First]");
            ss.addDisplayColumn("svcName  as [Name of Service Provided]");
            ss.addDisplayColumn("calpadsCode as [CALPADS]");
            ss.addDisplayColumn("minsSatisfied as [Minutes Satisfied]");
            ss.addDisplayColumn("attendanceStatus as [Attendance Status]");
            ss.addDisplayColumn("svcRecID as [Service Record ID]");
            pageroworder = ss.pageRowOrder();
        }

        /***************************************************************************
          * rptSpEdServicesForSelpaExport */
        /**
         * 
         **************************************************************************/
        public static ReturnDataTable rptSpEdServicesForSelpaExport(

              SqlConnection connSpedmon
            , SqlConnection connUsers
            , DetailsLog log
            , UserInfo uInfo
            , bool paged
            , string pageNumber
            , string clientID
            , string dateRange)
        {

            string reportUDF = "RPT_SPED_SERVICES_FOR_SELPA_EXPORT (null, null, null, @clientID, @startDate, @endDate)";

            /*-------------------------------
             * Parse date range (DOS) into
             * start and end dates
             *----------------------------*/

            string startDate = "";
            string endDate = "";
            Util.parseDateRange(dateRange, out startDate, out endDate);


            /*-------------------------------
             * Validate
             *-------------------------------*/

            int vClientID = Validate.reqClientID(uInfo, clientID);
            DateTime vStartDate = Validate.reqDate(startDate, Messages.INVALID_DOS);
            DateTime vEndDate = Validate.reqDate(endDate, Messages.INVALID_DOS);

            var c = Clients.load(connSpedmon, log, uInfo, vClientID.ToString());
            string tblName = "SELPA Export " + c.name + " DOS " + dateRange;

            /*-------------------------------
             * Define columns
             *-------------------------------*/

            defineCols dc = defineColsForSelpaExport;

            /*-------------------------------
             * Pass parameters
             *-------------------------------*/

            var prms = new List<SqlParameter>();

            prms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@endDate", SqlDbType.DateTime, vEndDate, ParameterDirection.Input));

            ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc);
            rd.tableName = tblName;
            return rd;

        }

        /***************************************************************************
          * rptSpEdServicesForSelpaExportAllRelatedClients */
        /**
         * 
         **************************************************************************/
        public static ReturnDataTable rptSpEdServicesForSelpaExportAllRelatedClients(

               SqlConnection connSpedmon
             , SqlConnection connUsers
             , DetailsLog log
             , UserInfo uInfo
             , bool paged
             , string pageNumber
             , string selpaCode
             , string dateRange)
        {

            string reportUDF = "RPT_SPED_SERVICES_FOR_SELPA_EXPORT_ALL_RELATED_CLIENTS (null, null, null, @selpaCode, @startDate, @endDate)";

            /*-------------------------------
             * Parse date range (DOS) into
             * start and end dates
             *----------------------------*/

            string startDate = "";
            string endDate = "";
            Util.parseDateRange(dateRange, out startDate, out endDate);

            /*-------------------------------
             * Validate
             *-------------------------------*/

            int vSelpaCode = Validate.reqSelpaCode(uInfo, selpaCode);
            DateTime vStartDate = Validate.reqDate(startDate, Messages.INVALID_DOS);
            DateTime vEndDate = Validate.reqDate(endDate, Messages.INVALID_DOS);

            string tblName = "SELPA Export DOS " + dateRange;

            /*-------------------------------
             * Define columns
             *-------------------------------*/

            defineCols dc = defineColsForSelpaExport;

            /*-------------------------------
             * Pass parameters
             *-------------------------------*/

            var prms = new List<SqlParameter>();

            prms.Add(Database.SqlParm("@selpaCode", SqlDbType.Int, vSelpaCode, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@endDate", SqlDbType.DateTime, vEndDate, ParameterDirection.Input));

            ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc);
            rd.tableName = tblName;
            return rd;
        }

        /***************************************************************************
         * viewObjects
         *
         * Returns a list of service record objects
         *
         ***************************************************************************/

        public static ReturnObjects viewObjects (   SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string active
                                                  , string clientID
                                                  , string groupSvcClassNameID
                                                  , string pracID
                                                  , string patID
                                                  , string svcTypeID
                                                  , string startDOS
                                                  , string endDOS)

        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ServiceRecord.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            bool parentOrPatientPortal = false;

            if (     (uInfo.userRoleID == Constants.ROLE_PARENT_GUARDIAN_ID)
                  || (uInfo.userRoleID == Constants.ROLE_PATIENT_ID)
            )
            {
              parentOrPatientPortal = true;
            }

            return Entities.viewObjects (  connSpedmon
                                          , log
                                          , uInfo
                                          , parentOrPatientPortal ? typeof (ServiceRecordForParentOrPatientPortal) : typeof (ServiceRecord)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate {
                                              return ServiceRecords.view (  connSpedmon
                                                                           , log
                                                                           , uInfo
                                                                           , Entities.REC_VIEW_OBJECTS
                                                                           , pageObjectList
                                                                           , idx
                                                                           , "" /* Can edit */
                                                                           , active
                                                                           , clientID
                                                                           , groupSvcClassNameID
                                                                           , pracID
                                                                           , patID
                                                                           , svcTypeID
                                                                           , ""       /* Referece */
                                                                           , startDOS /* Start DOS*/
                                                                           , endDOS   /* End DOS */
                                                                           , ""      /* Start DOE*/
                                                                           , ""     /* End DOE */
                                                                           , dc);
                                          });


        }

        /***************************************************************************
         * viewList
         *
         * Returns a list of service record objects
         * Note: It is recommended that this only be used for SMALL result sets.
         ***************************************************************************/

        public static List<ServiceRecord> viewList (   SqlConnection connSpedmon
                                                     , DetailsLog log
                                                     , UserInfo uInfo
                                                     , string clientID
                                                     , string groupSvcClassNameID
                                                     , string pracID
                                                     , string patID
                                                     , string svcTypeID
                                                     , string startDOS
                                                     , string endDOS)
        {
            var recs = new List<ServiceRecord>();

            var rd = ServiceRecords.view(connSpedmon
                                           , log
                                           , uInfo
                                           , Entities.REC_VIEW_RAW
                                           , false
                                           , ""
                                           , ""
                                           , "Y"
                                           , clientID
                                           , groupSvcClassNameID
                                           , pracID
                                           , patID
                                           , svcTypeID
                                           , ""
                                           , startDOS
                                           , endDOS
                                           , ""
                                           , ""
                                           , null);

            var slo = Database.convertRecordsToList(ref rd.records, typeof(ServiceRecord));
            foreach (var o in slo)
            {
                recs.Add((ServiceRecord)o);
            }
            recs.Sort((x, y) => x.dos.CompareTo(y.dos));
            return recs;
        }

        private static Return saveSvcRecsBatchMultiPracPatDosSvcCore (
                                   SqlConnection dbConnUsers
                                 , SqlConnection dbConnSpedmon
                                 , DetailsLog log
                                 , UserInfo uInfo
                                 , string reference
                                 , string svcrecForDOSJSON
                                 , string svcetrmde
                                 , string validateRec 
                                 , bool   wipEnabled
                                 , string wipRequestResource)
        {
            Return so = new Return();

            /*----------------------------
             * Batch save is for new records
             * only so we provide the required
             * values for save here
             *----------------------------*/

            string saveType = Constants.SAVE_TYPE_NEW.ToString();
            string recID = "";

            string saveSproc = @"SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vReference        = Validate.reqSvcRecReference(uInfo, reference);
            var vSvcrecForDOSJSON = Validate.reqString(svcrecForDOSJSON, @"Invalid records");
            var vSvcetrmde        = Validate.optInteger(svcetrmde, @"Invalid mode");

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@reference",       SqlDbType.VarChar, vReference,                 ParameterDirection.Input, 7000));
            parms.Add(Database.SqlParm("@svcRecsJSON",     SqlDbType.VarChar, vSvcrecForDOSJSON,          ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@svcetrmde",       SqlDbType.Int,     vSvcetrmde,                 ParameterDirection.Input));
            parms.Add(Database.SqlParm("@MsgInvCombo",     SqlDbType.VarChar, Messages.INVALID_PPN_COMBO, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinReq",       SqlDbType.VarChar, Messages.MIN_REQ,           ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinDef",       SqlDbType.VarChar, Messages.MIN_DEF,           ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMilReq",       SqlDbType.VarChar, Messages.MIL_REQ,           ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatElg",       SqlDbType.VarChar, Messages.PAT_ELG,           ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar, Messages.PAT_DOB_GTE_DOS,   ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatAbsent",    SqlDbType.VarChar, Messages.PAT_ABSENT_NO_CLAIM,    ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgFutureDOS",    SqlDbType.VarChar, Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            so = Entities.save(dbConnSpedmon, log, uInfo, saveType, validateRec, null, recID, saveSproc, dupRecMsg, ref parms, null);

            /*###########################################################################
              # Delete wip save point if applicable
              ###########################################################################*/

            if (wipEnabled) 
            { 
            
              Spedmon.WorkInProgressSavePoints.delete ( dbConnUsers
                                                       , log
                                                       , uInfo
                                                       , @""
                                                       , validateRec
                                                       , wipRequestResource
                                                       , Constants.PARM_SAVE_FORM);
            }
            
            return so;

        }

        /***************************************************************************
         * saveSvcRecsBatchMultiPracPatDosSvc 
         *
         * 
         * 
         ***************************************************************************/

        public static Return saveSvcRecsBatchMultiPracPatDosSvc(
                                   SqlConnection dbConnUsers
                                 , SqlConnection dbConnSpedmon
                                 , DetailsLog log
                                 , UserInfo uInfo
                                 , string reference
                                 , string svcrecForDOSJSON
                                 , string svcetrmde
                                 , string validateRec )
        {
            Return so = new Return();

            /*----------------------------
             * Batch save is for new records
             * only so we provide the required
             * values for save here
             *----------------------------*/

            string saveType = Constants.SAVE_TYPE_NEW.ToString();
            string recID = "";

            string saveSproc = @"SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vReference        = Validate.reqSvcRecReference(uInfo, reference);
            var vSvcrecForDOSJSON = Validate.reqString(svcrecForDOSJSON, @"Invalid records");
            var vSvcetrmde        = Validate.optInteger(svcetrmde, @"Invalid mode");

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@reference",       SqlDbType.VarChar, vReference,                 ParameterDirection.Input, 7000));
            parms.Add(Database.SqlParm("@svcRecsJSON",     SqlDbType.VarChar, vSvcrecForDOSJSON,          ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@svcetrmde",       SqlDbType.Int,     vSvcetrmde,                 ParameterDirection.Input));
            parms.Add(Database.SqlParm("@MsgInvCombo",     SqlDbType.VarChar, Messages.INVALID_PPN_COMBO, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinReq",       SqlDbType.VarChar, Messages.MIN_REQ,           ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinDef",       SqlDbType.VarChar, Messages.MIN_DEF,           ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMilReq",       SqlDbType.VarChar, Messages.MIL_REQ,           ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatElg",       SqlDbType.VarChar, Messages.PAT_ELG,           ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar, Messages.PAT_DOB_GTE_DOS,   ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatAbsent",    SqlDbType.VarChar, Messages.PAT_ABSENT_NO_CLAIM,    ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgFutureDOS",    SqlDbType.VarChar, Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            so = Entities.save(dbConnSpedmon, log, uInfo, saveType, validateRec, null, recID, saveSproc, dupRecMsg, ref parms, null);

            /*###########################################################################
              # Delete wip save point 
              ###########################################################################*/
                                    
            Spedmon.WorkInProgressSavePoints.delete ( dbConnUsers
                                                     , log
                                                     , uInfo
                                                     , @""
                                                     , validateRec
                                                     , URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC
                                                     , Constants.PARM_SAVE_FORM);
         
            return so;
         }

        /***************************************************************************
         * saveSvcRecsBatchPcalNonTransport 
         *
         * 
         * 
         ***************************************************************************/

        public static Return saveSvcRecsBatchPcalNonTransport (                                   
                                   SqlConnection dbConnUsers
                                 , SqlConnection dbConnSpedmon
                                 , DetailsLog log
                                 , UserInfo uInfo
                                 , string reference
                                 , string svcrecForDOSJSON
                                 , string svcetrmde
                                 , string validateRec )
        {

             Return so = new Return();

            /*----------------------------
             * Batch save is for new records
             * only so we provide the required
             * values for save here
             *----------------------------*/

            string saveType = Constants.SAVE_TYPE_NEW.ToString();
            string recID = "";

            string saveSproc = @"SERVICE_RECORD_Save_Batch_Muti_Prac_Pat_Dos_Svc_And_Doc_Stats_Or_QForm";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vReference        = Validate.reqSvcRecReference(uInfo, reference);
            var vSvcrecForDOSJSON = Validate.reqString(svcrecForDOSJSON, @"Invalid records");
            var vSvcetrmde        = Validate.optInteger(svcetrmde, @"Invalid mode");

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@reference",       SqlDbType.VarChar, vReference,                 ParameterDirection.Input, 7000));
            parms.Add(Database.SqlParm("@svcRecsJSON",     SqlDbType.VarChar, vSvcrecForDOSJSON,          ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@svcetrmde",       SqlDbType.Int,     vSvcetrmde,                 ParameterDirection.Input));
            parms.Add(Database.SqlParm("@MsgInvCombo",     SqlDbType.VarChar, Messages.INVALID_PPN_COMBO, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinReq",       SqlDbType.VarChar, Messages.MIN_REQ,           ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinDef",       SqlDbType.VarChar, Messages.MIN_DEF,           ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMilReq",       SqlDbType.VarChar, Messages.MIL_REQ,           ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatElg",       SqlDbType.VarChar, Messages.PAT_ELG,           ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar, Messages.PAT_DOB_GTE_DOS,   ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatAbsent",    SqlDbType.VarChar, Messages.PAT_ABSENT_NO_CLAIM,    ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgFutureDOS",    SqlDbType.VarChar, Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            so = Entities.save(dbConnSpedmon, log, uInfo, saveType, validateRec, null, recID, saveSproc, dupRecMsg, ref parms, null);

            return so;
        }

    }
}
