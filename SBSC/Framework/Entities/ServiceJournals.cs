using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
  /***************************************************************************
   * ServiceJournalPractitionerTrainingDetail */
  /**
   * 
   **************************************************************************/
   
  public class ServiceJournalPractitionerTrainingDetail
  {
        
    [IsDataGridCol(1)]
    [DataGridColTitle("ID")]
    [DataGridColIsInputLabel(true)]
    [DataGridColIsInputKey(true)]
    [DataGridColIsHidden(true)]
    [DataGridColWidth(1)]    
    public int pracID;
        
    [IsDataGridCol(2)]
    [DataGridColTitle("Name")]
    [DataGridColIsInputLabel(true)]
    [DataGridColWidth(200)]    
    public string pracName;
    
    [IsDataGridCol(3)]
    [DataGridColTitle("Title")]
    [DataGridColIsInputLabel(true)]
    [DataGridColWidth(200)]    
    public string pracTitle;
   
    [IsDataGridCol(4)]
    [DataGridColTitle("Training<br/>Date")]
    [DataGridColWidth(100)]  
    [DataGridColCtrlCopy(true)]
    public string trainingDate;
  
  }
  
  /***************************************************************************
   * ServiceJournalPractitionerTrainingDetail */
  /**
   * List of training details
   **************************************************************************/   
  
  public class ServiceJournalPractitionerTrainingDetails
  {
    public List<ServiceJournalPractitionerTrainingDetail> details_pracs_training;
  }
  
  /***************************************************************************
   * ServiceJournals */
  /**
   * 
   **************************************************************************/

  public class ServiceJournals:Entities
  {          


    /***************************************************************************
     * SEL_LABEL */
    /**
     * Selection labels for menus and screens
     ***************************************************************************/       

    public const string SEL_LABEL                   = "Service Journals";
    public const string SEL_LABEL_RECORD_PROC       = "Record a Procedure";
    public const string SEL_LABEL_RECORD_TRANS      = "Record Bus/Trans Aide Monitoring";
    public const string SEL_LABEL_BEGIN_AM          = "Begin 1:1 Accompanying & Monitoring";
    public const string SEL_LABEL_END_AM            = "End 1:1 Accompanying & Monitoring";
    public const string SEL_LABEL_LEFT_CARE         = "Record That Patient Temporarily Left My Care";
    public const string SEL_LABEL_DAILY_LIVING      = @"Activities of Daily Living";
    public const string SEL_LABEL_MON_MULTI_PATS    = @"Monitoring Multiple Patients";
    public const string SEL_LABEL_ADDITIONAL_NOTES  = @"Additional Notes";
    public const string SEL_LABEL_TCM               = @"Targeted Case Management";
    public const string SEL_LABEL_RMTS_MOMENT       = @"RMTS Moment";

    public const string SEL_LABEL_OPEN_NEW          = "Open New Journal";
    public const string SEL_LABEL_EDIT              = "Change Date of Service or Patient";
    public const string SEL_LABEL_CLOSE             = "Close Journal";
    public const string SEL_LABEL_REOPEN            = "Reopen Closed Journal";
   
    public const string SEL_LABEL_ENTRY_ADD         = "Add New Entry";

    public const string SEL_LABEL_MANAGE_SERVICE_DESCRIPTION                 = @"Patient Profiles (For 1:1 Accompany & Monitoring)";
    public const string SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT = @"Add New or Edit";
    public const string SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW         = @"Add New";
    public const string SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT            = @"Edit";
    
    public const string SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_NEW             = @"Add New";
    public const string SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW            = @"View";
    public const string SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE     = @"Delete";
    public const string SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE          = @"Manage 1:1 Accompany & Monitoring";
    
    public const string SEL_LABEL_MANAGE_ORDERS                              = @"Orders & Prescriptions";
    public const string SEL_LABEL_MANAGE_ORDERS_NEW                          = @"Add New";
    public const string SEL_LABEL_MANAGE_ORDERS_EDIT                         = @"Edit Existing";    
    public const string SEL_LABEL_MANAGE_ORDERS_VIEW                         = @"View";
    public const string SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE                  = @"Edit or Delete";
    public const string SEL_LABEL_MANAGE_ORDERS_MANAGE                       = @"Manage Orders & Prescriptions";
    public const string SEL_LABEL_MANAGE_ORDERS_MANAGE_WITH_PLACEHOLDERS     = @"Manage{0}Orders & Prescriptions{1}";
    public const string SEL_LABEL_MANAGE_PATIENT_SERVICES                    = @"Patient Services";
    
    /***************************************************************************
     * URL_*   */
    /**
     * Various urls for various roles
     ***************************************************************************/       
    
    public const string URL_USER_ALL_OPEN_NEW         = @"user_all_service_journals_journal_save.aspx";
    public const string URL_USER_ALL_GO_TO_JOURNAL    = @"user_all_service_journals_journal_entry_save.aspx";
    public const string URL_SVC_JOURNAL_ASMX          = @"servicejournalsjournals.asmx";
    public const string URL_SVC_JOURNAL_CLOSE         = @"servicejournalsjournals.asmx/close";
    public const string URL_SVC_JOURNAL_REOPEN        = @"servicejournalsjournals.asmx/reopen";
    public const string URL_SVC_JOURNAL_REOPEN_INLINE = @"servicejournalsjournals.asmx/reopeninline";
    public const string URL_SVC_JOURNAL_CLOSE_INLINE  = @"servicejournalsjournals.asmx/closeinline";

    public const string URL_PROV_GET_EVENT_SEL_DATA   = @"servicejournalseventselections.asmx/getEventSelectionData";
    public const string URL_PROV_CLOSE                = @"client_prov_service_journals_journal_close.aspx";
    
    public const string URL_PROV_SAVE_SERVICE_DESCRIPTION               = @"user_all_patient_profile_save.aspx";
    public const string URL_PROV_MANAGE_ORDERS_NOTE_TEMPATE_NEW         = @"user_all_order_prescription_save.aspx";
    public const string URL_PROV_MANAGE_ORDERS_NOTE_TEMPATE_VIEW        = @"client_prov_service_journals_prescribed_orders_view.aspx";
    public const string URL_PROV_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE = @"client_prov_service_journals_prescribed_orders_edit_delete.aspx";
        
    public const string URL_COOR_SAVE_SERVICE_DESCRIPTION               = @"user_all_patient_profile_save.aspx";
    
    public const string URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_NEW         = @"user_all_order_prescription_save.aspx";
    public const string URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_VIEW        = @"client_coor_service_journals_prescribed_orders_view.aspx";
    public const string URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE = @"client_coor_service_journals_prescribed_orders_edit_delete.aspx";
    public const string URL_COOR_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE     = @"client_coor_service_journals_prescribed_orders_manage.aspx";
    public const string URL_PROV_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE     = @"client_prov_service_journals_prescribed_orders_manage.aspx";

    public const string URL_SBS_SAVE_SERVICE_DESCRIPTION                = @"user_all_patient_profile_save.aspx";
    public const string URL_SBS_EDIT_DEL_SERVICE_DESCRIPTION            = @"sbs_all_service_journals_service_descriptions_edit_delete.aspx";
    
    public const string URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_NEW          = @"user_all_order_prescription_save.aspx";
    
    public const string URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_VIEW         = @"sbs_all_service_journals_prescribed_orders_view.aspx";
    public const string URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE  = @"sbs_all_service_journals_prescribed_orders_edit_delete.aspx";
    public const string URL_SBS_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE      = @"sbs_all_service_journals_prescribed_orders_manage.aspx";

    public const string URL_SVC_GET_SERVICE_DESCRIPTION                 = @"servicejournalsservicedescriptions.asmx/load";
    
    public const string URL_SBS_SERVICE_DESCRIPTIONS_VIEW               = @"sbs_all_service_journals_service_descriptions_view.aspx";
    public const string URL_COOR_SERVICE_DESCRIPTIONS_VIEW              = @"client_coor_service_journals_service_descriptions_view.aspx";
    public const string URL_PROV_SERVICE_DESCRIPTIONS_VIEW              = @"client_prov_service_journals_service_descriptions_view.aspx";
   
    
    public const string URL_COOR_EDIT_DEL_SERVICE_DESCRIPTION           = @"client_coor_service_journals_service_descriptions_edit_delete.aspx";
    public const string URL_PROV_EDIT_DEL_SERVICE_DESCRIPTION           = @"client_prov_service_journals_service_descriptions_edit_delete.aspx";
    
    public const string URL_SBS_MANAGE_SERVICE_DESCRIPTIONS_MANAGE      = @"sbs_all_service_journals_service_descriptions_manage.aspx";
    public const string URL_COOR_MANAGE_SERVICE_DESCRIPTIONS_MANAGE     = @"client_coor_service_journals_service_descriptions_manage.aspx";    
    public const string URL_PROV_MANAGE_SERVICE_DESCRIPTIONS_MANAGE     = @"client_prov_service_journals_service_descriptions_manage.aspx";
    public const string URL_SVC_JOURNAL_RPT                             = @"rpt_custom_service_journal_view_html.aspx";

    /***************************************************************************
     * PARAM_* */
    /**
     * Common parameters
     ***************************************************************************/

    public static string PARAM_LOOKUP_JOURNAL_ENTRY = "lookupjournalentry";
    public static string PARAM_LOOKUP_JOURNAL       = "lookupjournal";
    public static string PARAM_JOURNAL_ID           = Constants.PARM_JOURNAL_ID;
    public static string PARAM_JOURNAL_ENTRY_ID     = "journalentryid";
    public static string PARAM_CLIENT_ID            = Constants.PARM_CLIENT_ID;
    public static string PARAM_PRAC_ID              = Constants.PARM_PRACTITIONER_ID;
    public static string PARAM_EVENT_TYPE_ID        = "eventtypeid";
        
    /***************************************************************************
     * VAL_* */
    /**
     * Common values
     ***************************************************************************/       
    
    public static string VAL_EVENT_TYPE_BEGIN_AM         = "2";
    public static string VAL_EVENT_TYPE_END_AM           = "3";
    public static string VAL_EVENT_TYPE_LEFT_CARE        = "4";
    public static string VAL_EVENT_TYPE_REC_PROC         = "5";
    public static string VAL_EVENT_TYPE_REC_TRAN_AIDE    = "8";
    
    public static string VAL_EVENT_TYPE_DAILY_LIVING     = "6";
    public static string VAL_EVENT_TYPE_MON_MULTI_PATS   = "10";
    public static string VAL_EVENT_TYPE_ADDITIONAL_NOTES = "7";
    public static string VAL_EVENT_TYPE_TCM              = "9";
    public static string VAL_EVENT_TYPE_RMTS_MOMENT      = "11";

    public static string VAL_FILE_CLASS_MD_ORDERS        = MBA.StoredFiles.FILE_CLASS_MD_ORDERS;
    public static string VAL_FILE_CLASS_PRESCRIPTIONS    = MBA.StoredFiles.FILE_CLASS_PRESCRIPTIONS;
    public static string VAL_FILE_NAMESPACE              = "daily_journal";
    public static string VAL_FILE_SOURCE_MD_ORDERS       = "md_orders";
    public static string VAL_FILE_SOURCE_PRESCRIPTIONS   = "prescriptions";

    /***************************************************************************
     * URL_SVC_JOURNAL_RPT_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_SVC_JOURNAL_RPT_BASE()
    { 
       return MBA.HttpApplication.createLink(ServiceJournals.URL_SVC_JOURNAL_RPT, true);
    }

    /***************************************************************************
     * URL_USER_ALL_GO_TO_JOURNAL_BASE_NEW_WIN */
    /**
     * 
     **************************************************************************/  
    public static string URL_USER_ALL_GO_TO_JOURNAL_BASE_NEW_WIN()
    { 
       return MBA.HttpApplication.createLink(
             ServiceJournals.URL_USER_ALL_GO_TO_JOURNAL
           , true
           , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
       );
    }

    /***************************************************************************
     * URL_SVC_JOURNAL_RE_OPEN_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_SVC_JOURNAL_SVC_REOPEN_INLINE_BASE()
    {
        return MBA.HttpApplication.createLink(ServiceJournals.URL_SVC_JOURNAL_REOPEN_INLINE, true);
    }

    /***************************************************************************
     * URL_USER_ALL_GO_TO_JOURNAL_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_USER_ALL_GO_TO_JOURNAL_BASE()
    {
        return MBA.HttpApplication.createLink(ServiceJournals.URL_USER_ALL_GO_TO_JOURNAL, true);
    }

    /***************************************************************************
     * URL_USER_ALL_OPEN_NEW_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_USER_ALL_OPEN_NEW_BASE()
    {
        return MBA.HttpApplication.createLink(ServiceJournals.URL_USER_ALL_OPEN_NEW, true);
    }

    public static string URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_NEW_BASE()
    {
        return MBA.HttpApplication.createLink(URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true);
    }

    /***************************************************************************
     * validatePracTrainingDetails */
    /**
     * 
     **************************************************************************/  
    public static void validatePracTrainingDetails (  ref string  pracIDsIn
                                                    , ref string  detailsIn
                                                    , out string                                    pracIDsOut
                                                    , out ServiceJournalPractitionerTrainingDetails detailsOut)
    {
            
      pracIDsOut  = @"";
      detailsOut  = new ServiceJournalPractitionerTrainingDetails();
      
      if (!String.IsNullOrEmpty(pracIDsIn))
      {
        int[]     vPracIDsArr  = Validate.reqRecIDMulti (pracIDsIn, Messages.INVALID_PRAC_ID);
        List<int> vPracIDsLst  = new List<int> (vPracIDsArr);
        
        AdditionalValidation av = delegate(Object o) {
         
         ServiceJournalPractitionerTrainingDetails vDetails = (ServiceJournalPractitionerTrainingDetails) o;
         foreach (ServiceJournalPractitionerTrainingDetail vDetail in vDetails.details_pracs_training) {
         
           if (!String.IsNullOrEmpty(vDetail.trainingDate)) {
             DateTime vTrainingDate;
             if (!DateTime.TryParse(vDetail.trainingDate, out vTrainingDate)) {
               throw new Warning(Messages.INVALID_TRAINING_DATES);
             }
             else
             {
               
             }
           }          
         } 
        
        };                


        pracIDsOut = Parse.createMultiInt (vPracIDsArr);
        detailsOut = (ServiceJournalPractitionerTrainingDetails) Validate.reqObject (  detailsIn
                                                                                     , @"Invalid training details" 
                                                                                     , "Spedmon"
                                                                                     , "Spedmon.ServiceJournalPractitionerTrainingDetails"
                                                                                     , av);
      }
      else
      {
        pracIDsOut         = @"";
        detailsOut.details_pracs_training = new List<ServiceJournalPractitionerTrainingDetail>();
      }

    }
    
    /***************************************************************************
     * isPracSomeoneWhoWouldUseJournal */
    /**
     * 
     **************************************************************************/      
    public static bool isPracSomeoneWhoWouldUseJournal (ref RequestResponse rd)
    {
      /* Only health services practitioners */

      if (rd.wu.pr != null) {
        if (rd.wu.pr.stdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) {
            return true;
      }
      }
      return false;
    }
   
    /***************************************************************************
     * isPracSomeoneWhoCanRecordServiceRecords */
    /**
     * 
     **************************************************************************/     
    public static bool isPracSomeoneWhoCanRecordServiceRecords (ref RequestResponse rd) {
          if (rd.wu.pr != null) {
         /* If this is health services */
         if (rd.wu.pr.stdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) {
           /* Health aides and LVNS cannot create service records */
           if (rd.wu.pr.isAParaProfessional == true) return false;
           return true;
        }
      return true;
    }
       return false;
    }

    /***************************************************************************
     * isPracSomeoneWhoCanManageSvcDescr */
    /**
     * 
     **************************************************************************/     
    public static bool isPracSomeoneWhoCanManageSvcDescr(ref RequestResponse rd)
    {              
      /* Only health services practitioners */
      
      if (rd.wu.pr != null)
      {
        if (rd.wu.pr.stdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES){
          return true;          
        }
      }
      return false;
    }

    /***************************************************************************
     * isPracSomeoneWhoCanManageOrders */
    /**
     * 
     **************************************************************************/     
    public static bool isPracSomeoneWhoCanManageOrders (ref RequestResponse rd)
    {
      if (rd.wu.pr != null)
        if (rd.wu.pr.orpGroupServiceClassNameID != 0) return true;
      return false;            
    }

    /***************************************************************************
     * isPracSomeoneWhoCanManagePatientServices */
    /**
     * 
     **************************************************************************/  
    public static bool isPracSomeoneWhoCanManagePatientServices (ref RequestResponse rd)
    {
      if (isPracSomeoneWhoCanManageOrders (ref rd))        return true;
      if (isPracSomeoneWhoCanManageSvcDescr(ref rd))       return true;
      if (ServiceRecordsApproval.isSupervisorPrac(ref rd)) return true;
      return false;
    }
    
    /***************************************************************************
     * view */
    /**
     * 
     **************************************************************************/      
    public static ReturnDB view (SqlConnection connSpedmon, 
                                 DetailsLog    log, 
                                 UserInfo      uInfo,
                                 int           recViewType,
                                 bool          pagedOrTop,
                                 string        idx,
                                 string        canEdit,
                                 string        active,
                                 string        clientID,
                                 string        pracID,
                                 string        patID,
                                 string        startDate,
                                 string        endDate,
                                 string        completed,
                                 defineCols    dc) 
    {
    
      string viewUDF = "dbo.SvcJournal_View (@userID, @userGroup, @userRank, @clientID , @patID, @startDate, @endDate, @completed, @recID)";

      Object    vClientID       = Validate.optClientID (uInfo,       clientID);
      Object    vPracID         = Validate.optPracID   (uInfo,       pracID);
      Object    vPatID          = Validate.optInteger  (patID,       Messages.INVALID_PAT_ID);
      Object    vCompleted      = Validate.optFlag     (completed,   Messages.INVALID_FLAG_ACTIVE);
      Object    vStartDate      = Validate.reqDate     (startDate,   Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
      Object    vEndDate        = Validate.reqDate     (endDate,     Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NO_FUTURE);

      List<SqlParameter> parms = new List<SqlParameter>();
                   
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,      vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",    SqlDbType.Int,      vPracID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",     SqlDbType.Int,      vPatID,       ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",   SqlDbType.DateTime, vEndDate,     ParameterDirection.Input));     
      parms.Add(Database.SqlParm("@completed", SqlDbType.Bit,      vCompleted,   ParameterDirection.Input));
              
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }    

    /***************************************************************************
     * viewWarningsProblems */
    /**
     * 
     **************************************************************************/  
    
    public static ReturnDB viewWarningsProblems (

        SqlConnection connSpedmon
      , DetailsLog    log 
      , UserInfo      uInfo
      , int           recViewType
      , bool          pagedOrTop
      , string        idx
      , string        canEdit
      , string        active
      , string        clientID
      , string        journalID                           
      , defineCols    dc) 
    {
    
      string viewUDF = "dbo.SvcJournal_Journal_Validate (@userID, @userGroup, @userRank, @clientID, @journalID)";

      Object    vClientID       = Validate.optClientID (uInfo,       clientID);
      long      vJournalID      = Validate.reqInteger  (journalID, @"Invalid journal id");

      List<SqlParameter> parms = new List<SqlParameter>();
                   
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,      vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@journalID", SqlDbType.BigInt,   vJournalID,   ParameterDirection.Input));
              
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }    

    /***************************************************************************
     * viewReportPartEntriesEvery15 */
    /**
     * 
     **************************************************************************/  
    public static ReturnDB viewReportPartEntriesEvery15 (

        SqlConnection connSpedmon
      , DetailsLog    log 
      , UserInfo      uInfo
      , int           recViewType
      , bool          pagedOrTop
      , string        idx
      , string        canEdit
      , string        active
      , string        clientID
      , string        journalID                           
      , defineCols    dc) 
    {
    
      string viewUDF = "dbo.SvcJournal_Journal_Report_Part_Entries_Every_15_View (@userID, @userGroup, @userRank, @clientID, @journalID)";

      long      vClientID       = Validate.reqClientID (uInfo,       clientID);
      long      vJournalID      = Validate.reqInteger  (journalID,   @"Invalid journal id");

      List<SqlParameter> parms = new List<SqlParameter>();
                   
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,      vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@journalID", SqlDbType.BigInt,   vJournalID,   ParameterDirection.Input));
              
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }    
    
    /***************************************************************************
     * viewReportPartPracsRenderingSigs */
    /**
     * 
     **************************************************************************/      
    public static ReturnDB viewReportPartPracsRenderingSigs (

        SqlConnection connSpedmon
      , DetailsLog    log 
      , UserInfo      uInfo
      , int           recViewType
      , bool          pagedOrTop
      , string        idx
      , string        canEdit
      , string        active
      , string        clientID
      , string        journalID                           
      , defineCols    dc) 
    {
    
      string viewUDF = "dbo.SvcJournal_Journal_Report_Part_Prac_Rendering_Sigs_View (@userID, @userGroup, @userRank, @clientID, @journalID)";

      long      vClientID       = Validate.reqClientID (uInfo,       clientID);
      long      vJournalID      = Validate.reqInteger  (journalID,   @"Invalid journal id");

      List<SqlParameter> parms = new List<SqlParameter>();
                   
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,      vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@journalID", SqlDbType.BigInt,   vJournalID,   ParameterDirection.Input));
              
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }    

    /***************************************************************************
     * viewReportPartPracsSupervisingSigs */
    /**
     * 
     **************************************************************************/      
    public static ReturnDB viewReportPartPracsSupervisingSigs (

        SqlConnection connSpedmon
      , DetailsLog    log 
      , UserInfo      uInfo
      , int           recViewType
      , bool          pagedOrTop
      , string        idx
      , string        canEdit
      , string        active
      , string        clientID
      , string        journalID                           
      , defineCols    dc) 
    {
    
      string viewUDF = "dbo.SvcJournal_Journal_Report_Part_Prac_Supervisor_Sigs_View (@userID, @userGroup, @userRank, @clientID, @journalID)";

      long      vClientID       = Validate.reqClientID (uInfo,       clientID);
      long      vJournalID      = Validate.reqInteger  (journalID,   @"Invalid journal id");

      List<SqlParameter> parms = new List<SqlParameter>();
                   
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,      vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@journalID", SqlDbType.BigInt,   vJournalID,   ParameterDirection.Input));
              
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }    
    
    /***************************************************************************
     * viewReportPartPracsSupervisingNotes */
    /**
     * 
     **************************************************************************/      
    public static ReturnDB viewReportPartPracsSupervisingNotes (

        SqlConnection connSpedmon
      , DetailsLog    log 
      , UserInfo      uInfo
      , int           recViewType
      , bool          pagedOrTop
      , string        idx
      , string        canEdit
      , string        active
      , string        clientID
      , string        journalID                           
      , defineCols    dc) 
    {
    
      string viewUDF = "dbo.SvcJournal_Journal_Report_Part_Prac_Supervisor_Notes_View (@userID, @userGroup, @userRank, @clientID, @journalID)";

      long      vClientID       = Validate.reqClientID (uInfo,       clientID);
      long      vJournalID      = Validate.reqInteger  (journalID,   @"Invalid journal id");

      List<SqlParameter> parms = new List<SqlParameter>();
                   
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,      vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@journalID", SqlDbType.BigInt,   vJournalID,   ParameterDirection.Input));
              
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }    
    

    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id and the pracid
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl (  SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , bool          paged
                                           , string        pageNumber
                                           , string        canEdit
                                           , string        active
                                           , string        clientID
                                           , string        pracID
                                           , string        patID
                                           , string        dateRange 
                                           , string        completed)
    {
      ReturnDataTable so = new ReturnDataTable();
     
     
      /*-------------------------------
       * Parse date range into start
       * and end dates
       *----------------------------*/

      string startDate = "";
      string endDate = "";
      Util.parseDateRange(dateRange, out startDate, out endDate);
      
      /*----------------------------
       * Define our columns and
       * set the page order for 
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("recNumber  as [Rec #]", true);
        ss.addDisplayColumn("recLine    as [Line]",  true);
//        ss.addDisplayColumn("detailLine as [Part]",  true);
        
        ss.addDisplayColumn("[Service]");       
        ss.addDisplayColumn("[Event]");        
        ss.addDisplayColumn("[Notes]");
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest 
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return ServiceJournals.view (connSpedmon,log,uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", "", clientID, pracID, patID, startDate, endDate, completed, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Service Journals";
      so.tableFooter = Messages.CONFIDENTIAL;
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
    } 


                                   
    /***************************************************************************
     * viewWarningsProblemsTbl */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id and the pracid
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewWarningsProblemsTbl (  SqlConnection connSpedmon
                                                           , DetailsLog    log
                                                           , UserInfo      uInfo
                                                           , bool          paged
                                                           , string        pageNumber
                                                           , string        canEdit
                                                           , string        active
                                                           , string        clientID
                                                           , string        journalID )
    {
      ReturnDataTable so = new ReturnDataTable();
     
      
      /*----------------------------
       * Define our columns and
       * set the page order for 
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("pracName  as [Practioner]",true);
        ss.addDisplayColumn("retStatus as [Status]",true);
        ss.addDisplayColumn("problem   as [Warning or Problem]");        
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest 
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return ServiceJournals.viewWarningsProblems (connSpedmon,log,uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", "", clientID, journalID, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Warnings or Problems";
      so.tableFooter = "Warnings or Problems";
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
    } 

    /***************************************************************************
     * viewReportPartEntriesEvery15Tbl */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id and the pracid
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewReportPartEntriesEvery15Tbl (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , bool          paged
      , string        pageNumber
      , string        canEdit
      , string        active
      , string        clientID
      , string        journalID )
    {
      ReturnDataTable so = new ReturnDataTable();
     
      
      /*----------------------------
       * Define our columns and
       * set the page order for 
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("rowNum                 as [#]",  true);
        ss.addDisplayColumn("startTimeStr           as [Start]");
        ss.addDisplayColumn("endTimeStr             as [End]");
        ss.addDisplayColumn("isnull(eventLabel,'')  as [Service]");
        ss.addDisplayColumn("isnull(eventNotes,'')  as [Notes]");
        ss.addDisplayColumn("isnull(pracName,'')    as [Practitioner]");
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest 
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return ServiceJournals.viewReportPartEntriesEvery15 (connSpedmon,log,uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", "", clientID, journalID, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Services Rendered";
      so.tableFooter = "";
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
    } 

    /***************************************************************************
     * viewReportPartPracsRenderingSigsTable */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id and the pracid
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewReportPartPracsRenderingSigsTbl (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , bool          paged
      , string        pageNumber
      , string        canEdit
      , string        active
      , string        clientID
      , string        journalID )
    {
      ReturnDataTable so = new ReturnDataTable();
     
      
      /*----------------------------
       * Define our columns and
       * set the page order for 
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("pracName           as [Rendering Practitioner]",  true);
        ss.addDisplayColumn("pracType           as [Practitioner Type]");
        ss.addDisplayColumn("pracSig            as [Signature]");
        ss.addDisplayColumn("dateSignedStr      as [Date]");
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest 
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return ServiceJournals.viewReportPartPracsRenderingSigs (connSpedmon,log,uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", "", clientID, journalID, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Rendering Practitioners";
      so.tableFooter = "";
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
    } 

    /***************************************************************************
     * viewReportPartPracsSupervisingSigsTable */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id and the pracid
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewReportPartPracsSupervisingSigsTbl (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , bool          paged
      , string        pageNumber
      , string        canEdit
      , string        active
      , string        clientID
      , string        journalID )
    {
      ReturnDataTable so = new ReturnDataTable();
          
      /*----------------------------
       * Define our columns and
       * set the page order for 
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("pracName           as [Supervising Practitioner]",  true);
        ss.addDisplayColumn("pracType           as [Practitioner Type]");
        ss.addDisplayColumn("approvedStr        as [Approved]");
        ss.addDisplayColumn("pracSig            as [Signature]");
        ss.addDisplayColumn("dateSignedStr      as [Date]");
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest 
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return ServiceJournals.viewReportPartPracsSupervisingSigs (connSpedmon,log,uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", "", clientID, journalID, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Supervising Practitioners";
      so.tableFooter = "";
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
    } 

    /***************************************************************************
     * viewReportPartPracsSupervisingNotesTbl  */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id and the pracid
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewReportPartPracsSupervisingNotesTbl (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , bool          paged
      , string        pageNumber
      , string        canEdit
      , string        active
      , string        clientID
      , string        journalID )
    {
      ReturnDataTable so = new ReturnDataTable();
          
      /*----------------------------
       * Define our columns and
       * set the page order for 
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("supervisingPrac    as [Supervising Practitioner]",  true);
        ss.addDisplayColumn("renderingPrac      as [Rendering Practitioner]",    true);
        ss.addDisplayColumn("reviewNotes        as [Notes]");
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest 
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return ServiceJournals.viewReportPartPracsSupervisingNotes (connSpedmon,log,uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", "", clientID, journalID, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Supervising Practitioners Notes";
      so.tableFooter = "";
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
    } 

  }
}
