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
using System.Text;

using MBA;

namespace Spedmon
{     
     
  /***************************************************************************
   * PracWhoNeedsToApproveServiceRecord */
  /**
   * Practitoner who needs to approve a service record
   ***************************************************************************/

  public class PracWhoNeedsToApproveServiceRecord
  {
    public long   clientID;
    public long   pracID;
    public string lastName;
    public string firstName;
    public string email;
    public int    numSvcsToReview;
  }

  /***************************************************************************
   * ServiceRecordsApproval */
  /**
   * General methods to work with service record approval
   ***************************************************************************/

  public class ServiceRecordsApproval:Entities
  {

    /***************************************************************************
     * PAGE_? */
    /**
     * Various pages
     ***************************************************************************/       

    public static string PAGE_CLIENT_PROV_SVC_REC_APPROVAL_SUMMARY           = "client_prov_svcrec_batch_approve_summary.aspx";
    public static string PAGE_CLIENT_PROV_SVC_REC_APPROVAL_DETAILS           = "client_prov_svcrec_batch_approve_details.aspx";   

    public static string MENU_ID_APPROVE_SUMMARY                             = "supervisesvcreclink";
    public static string MENU_ID_APPROVE_SUMMARY_HS                          = "supervisesvcrecshealthserviceslnk";
    public static string PAGE_USER_ALL_SVC_REC_APPROVAL_SUMMARY              = "user_all_health_services_approve_summary.aspx";
    public static string PAGE_USER_ALL_SVC_REC_APPROVAL_DETAILS              = "user_all_health_services_approve_details.aspx";        
     
    public static string PAGE_USER_ALL_SVC_REC_APPROVAL                       = "user_all_approve_service_records_summary.aspx";
    public static string PAGE_USER_ALL_SVC_REC_APPROVAL_DETAILS_BY_SVC_REC_ID = "user_all_approve_service_records_details.aspx";

    public static string PAGE_CLIENT_PROV_SVC_REC_SUPERVISED_SUPERVISOR_PREF = "client_prov_svcrec_supervised_supervisor_preference.aspx";
    public static string PAGE_CLIENT_PROV_SVC_REC_HELD_FOR_CHANGE_DETAILS    = "client_prov_svcrec_held_for_change_details.aspx";
        
    public static string PAGE_RPT_SVC_REC_PENDING_APPROVAL_OR_HELD           = "rpt_services_pending_prac_approval_or_held.aspx";
    public static string PAGE_RPT_CLIENT_PROV_SVC_REC_REVIEW_FOR_DIRECT_SUP  = "client_prov_rpt_svc_rec_review_for_direct_sup.aspx";

    public const string URL_ASMX                           = @"servicerecordsapproval.asmx";
    public const string URL_ASMX_APPROVE_SVCREC            = URL_ASMX + @"/opacceptbatchbysvcrecappid";  
    public const string URL_ASMX_APPROVE_SVCREC_WITH_NOTES = URL_ASMX + @"/opacceptbatchbysvcrecappidwithnotesandnotification";
    public const string URL_ASMX_REJECT_SVCREC             = URL_ASMX + @"/oprejectbatchbysvcrecappid";
    public const string URL_ASMX_APPROVE_JOURNAL           = URL_ASMX + @"/opacceptbatchbysvcjournalid";
    public const string URL_ASMX_APPROVE_BY_PRAC_ID        = URL_ASMX + @"/opacceptbatchbypracid";
    public const string URL_ASMX_APPROVE_BY_PAT_ID         = URL_ASMX + @"/opacceptbatchbypatid";
    
    /***************************************************************************
     * SEL_LABEL_? */
    /**
     * Selection labels for menus and screens
     ***************************************************************************/       
    
    public const string SEL_LABEL                                       = "Supervision Review of Service Records";
    public const string SEL_LABEL_PRAC_SUPERVISED_SEL_SUP               = "Select Who Can Supervise Services I Enter In SpEdCare";
    public const string SEL_LABEL_PRAC_SUPERVISOR_REV_SVC               = "Program Compliance Service Records Review";
    public const string SEL_LABEL_PRAC_SUPERVISOR_REV_SVC_HEALTH        = "Program Compliance Service Records Review for Health Services";
    public const string SEL_LABEL_PRAC_SUPERVISOR_REV_SVC_NON_HEALTH    = "Program Compliance Service Records Review for Non-Health Services";
    public const string SEL_LABEL_PRAC_SVC_REC_PENDING_APPROVAL_OR_HELD = "Service Records Not Yet Reviewed Or Approved By Supervisor";
    public const string SEL_LABEL_PRAC_SUPERVISED_REV_SVC_HELD          = "Correct My Records";
    public const string SEL_LABEL_RPT_SVC_REC_REVIEW_FOR_DIRECT_SUP     = "View Service Records Entered In SpEdCare";
        
    /***************************************************************************
     * PARM_? */
    /**
     * Various parameters
     ***************************************************************************/       
        
    public static string SVC_REC_APPROVAL_PARM_PRAC_ID  = "svcrecaprpracid";    	

    /***************************************************************************
     * REST VIEW */
    /**
     * 
     ***************************************************************************/
    public const string URL_REST_VIEW_SUMMARY_BY_JOURNAL = @"api/v1/servicerecordsapprovalsummarybyjournal";

    public static string URL_REST_VIEW_BASE_SUMMARY_BY_JOURNAL()
    { 
       return MBA.HttpApplication.createLink(ServiceRecordsApproval.URL_REST_VIEW_SUMMARY_BY_JOURNAL, true);
    }


    /***************************************************************************
     * isPracWithClientThatUsesApprovalSystem */
    /**
     * 
     * @param  rd              Current request response object
     * @return                 bool
     ***************************************************************************/
    
    public static bool isPracWithClientThatUsesApprovalSystem (ref RequestResponse rd)
    {
      if (rd.wu.pr != null) 
        if (rd.wu.pr.svcRecPracApprovalSystem == true)
          return true;
      return false;
    }
    
    /***************************************************************************
     * isSupervisedPrac  */
    /**
     * 
     * @param  rd              Current request response object
     * @return                 bool
     ***************************************************************************/

    public static bool isSupervisedPrac (ref RequestResponse rd)
    {
      if (isPracWithClientThatUsesApprovalSystem(ref rd))
        if (rd.wu.pr.supervisedByGroupCount > 0) return true;
      return false;    
    }
        
    /***************************************************************************
     * isSupervisorPrac  */
    /**
     * 
     * @param  rd              Current request response object
     * @return                 bool
     ***************************************************************************/

    public static bool isSupervisorPrac (ref RequestResponse rd) {
      if (isPracWithClientThatUsesApprovalSystem(ref rd))
        if (rd.wu.pr.supervisesGroupCount    > 0) return true;
      return false;
    }
    
    
    /***************************************************************************
     * isSupervisedPracWithNoAssignedSupervisor  */
    /**
     * 
     * @param  rd              Current request response object
     * @return                 bool
     ***************************************************************************/

    public static bool isSupervisedPracWithNoAssignedSupervisor (ref RequestResponse rd) {
      if (isSupervisedPrac(ref rd))
        if (rd.wu.pr.supervisorsAssignedCount == 0) return true;
      return false;
    }
    
    /***************************************************************************
     * isSupervisedPracWithHeldServices */
    /**
     * 
     * @param  rd              Current request response object
     * @return                 bool
     ***************************************************************************/

    public static bool isSupervisedPracWithHeldServices (ref RequestResponse rd) {
      if (isSupervisedPrac(ref rd)) 
        if (rd.wu.pr.svcsHeldFromAllCount == 0) 
          return false; 
        else 
          return true;
      return false;
    }

    /***************************************************************************
     * isSupervisorPracWithServicesToReviewFromAssigned */
    /**
     * 
     * @param  rd              Current request response object
     * @return                 bool
     ***************************************************************************/

    public static bool isSupervisorPracWithServicesToReviewFromAssigned (ref RequestResponse rd) {

      /* If this prac is a supervising prac */

      if (isSupervisorPrac(ref rd))
      {
        /* No direct assigned pracs */
        if (rd.wu.pr.supervisedAssignedCount == 0)
        {          
          /* If the supervising prac is in the health services group family then we will want them to know  */
          if (rd.wu.pr.stdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) {
            if (rd.wu.pr.svcsToReviewFromAllCount > 0) return true; else return false;
          }
          /* Otherwise no*/
          return false;
        }
        /* Has direct assigned pracs */
        else
        {
          /* Look for unreviewed from pracs assigned to this supervisor prac only */
          if (rd.wu.pr.svcsToReviewFromAssignedCount > 0) return true; else return false;
        }
      }
      /* Prac is not a supervising prac, exit*/
      return false;
    }

    /***************************************************************************
     * isSupervisorPracAllowedToOptOutOfServicesToReviewNotifications */
    /**
     * 
     ***************************************************************************/

     public static bool isSupervisorPracAllowedToOptOutOfServicesToReviewNotifications (ref RequestResponse rd) {
      
       /* If this prac is a supervising prac */
       if (isSupervisorPrac(ref rd))
       {
         /* And they are not in health services then they can opt out */ 
         if (rd.wu.pr.stdSvcClassNameID != Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) return true;
         return false;
       }
       return true;
     }

     /***************************************************************************
      * isSupervisorPracAllowedToReviewUnassignedPracsServices */
     /**
      * 
      ***************************************************************************/

     public static bool isSupervisorPracAllowedToReviewUnassignedPracsServices (ref RequestResponse rd) {
      
      /* If this prac is a supervising prac */
      if (isSupervisorPrac(ref rd))
      {
        
        /* If the prac is in the mental health group family then the rule is you have to have assigned pracs*/

        if (rd.wu.pr.stdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_MENTAL_HEALTH_SERVICES) return false;

        /* Otherwise its ok*/
        return true;
      }
      /* Prac is not a supervising prac, exit*/
      return false;
    }

    /***************************************************************************
     * userHasAccess */
    /**
     * 
     ***************************************************************************/

    public static bool userHasAccess (RequestResponse rd) {
       
       /* PCAL staff have access */
       if (rd.wu.usr.pcalStaff == true) return true;

       /* All other roles except prac do not have access */
       if (rd.wu.usr.roleID != Constants.ROLE_LEA_PROVIDER_ID) {
         return false;
       }
       
       /* Practitioner data must exist*/

       if (rd.wu.pr != null) {
         
           /* If this prac is a supervising prac they can access */
           if (isSupervisorPrac(ref rd))
           {
             return true;
           }
           /* Otherwise not */
           else
           {
             return false;
           }
       }       
       else
       { 
         return false;
       }
       return false;
    }

    /***************************************************************************
     * opAcceptOrRejectBatchBySvcRecApprovalID */
    /**
     * 
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @return                 ReturnEntity
     ***************************************************************************/
    
    public static ReturnSaveRecord opAcceptOrRejectBatchBySvcRecApprovalID ( 
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        editDelReason
      , string        validateRec
      , string        recIDMulti
      , string        approved)
    {
      return opAcceptOrRejectBatchBySvcRecApprovalIDWithNotesAndNotification(connSpedmon,log,uInfo,editDelReason,validateRec,recIDMulti,approved,@"N");            
    }
  
    /***************************************************************************
     * opAcceptOrRejectBatchBySvcRecApprovalIDWithNotesAndNotification */
    /**
     * 
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @return                 ReturnEntity
     ***************************************************************************/
    
    public static ReturnSaveRecord opAcceptOrRejectBatchBySvcRecApprovalIDWithNotesAndNotification ( 
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        editDelReason
      , string        validateRec
      , string        recIDMulti
      , string        approved
      , string        sendReviewNotesToRenderingPrac)
    {
      
      /*----------------------------
       * Validate and enforce
       *----------------------------*/

      Object    vClientID                       = Validate.optClientID (uInfo,    "");
	  bool      vApproved                       = Validate.reqFlag     (approved, Messages.INVALID_FLAG_APPROVE, true);   
      bool      vSendReviewNotesToRenderingPrac = Validate.reqFlag     (sendReviewNotesToRenderingPrac,Messages.INVALID_FLAG,true);

      /*----------------------------
       * If rejecting and no notes
       * provided dont allow
       *----------------------------*/

      if ((vApproved == false) && (String.IsNullOrWhiteSpace(editDelReason) == true)) {
        throw new Warning(@"If you are returning for correction, review notes are required");
      }

      /*----------------------------
       * If approving and sending
       * notes and no notes provided
       * dont allow
       *----------------------------*/

      if ((vApproved == true) && (vSendReviewNotesToRenderingPrac == true) && (String.IsNullOrWhiteSpace(editDelReason) == true)) {
        throw new Warning(@"If you are approving with review notes and sending notes to rendering practitioner, review notes are required");
      }

      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm ("@clientID",                        SqlDbType.Int,   vClientID,                        ParameterDirection.Input));
      parms.Add(Database.SqlParm ("@approved",                        SqlDbType.Bit,   vApproved,                        ParameterDirection.Input));
      parms.Add(Database.SqlParm ("@sendReviewNotesToRenderingPrac",  SqlDbType.Bit,   vSendReviewNotesToRenderingPrac,  ParameterDirection.Input));
             
      /*----------------------------
       * Call base method 
       *----------------------------*/

      return Entities.recordOpMulti (connSpedmon, log, uInfo, editDelReason, validateRec, recIDMulti, "SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_SVC_REC_APPROVAL_ID", true, ref parms);

    }
 
    /***************************************************************************
     * opAcceptOrRejectBatchByPracID */
    /**
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @return                 ReturnEntity
     ***************************************************************************/
    
    public static ReturnSaveRecord opAcceptOrRejectBatchByPracID ( 
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        editDelReason
      , string        validateRec
      , string        recID            
      , string        approved
      , string        siteID  
      , string        entryDateRange )
    {
      
      Object    vClientID           = Validate.optClientID (uInfo, "");
      Object    vSiteID             = Validate.optInteger  (siteID,    Messages.INVALID_SITE_ID);
      Object    vApprovingPracID    = Validate.optPracID   (uInfo, "");
	  Object    vApproved           = Validate.optFlag     (approved, Messages.INVALID_FLAG_APPROVE);   

	  string startEntryDate = "";
      string endEntryDate   = "";
      Util.parseDateRange(entryDateRange, out startEntryDate, out endEntryDate);
      var vEntryDateRange = Validate.optStartAndEndDate(startEntryDate,endEntryDate,Messages.INVALID_DATE_RANGE);
   
     
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      var parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@clientID",         SqlDbType.Int,      vClientID,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@siteID",           SqlDbType.Int,      vSiteID,            ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@startEntryDate",   SqlDbType.DateTime, vEntryDateRange[0], ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endEntryDate",     SqlDbType.DateTime, vEntryDateRange[1], ParameterDirection.Input));   
      parms.Add(Database.SqlParm("@approved",         SqlDbType.Bit,      vApproved,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@approvingPracID",  SqlDbType.Int,      vApprovingPracID,   ParameterDirection.Input));

      /*----------------------------
       * Call base method 
       *----------------------------*/

      return Entities.recordOp(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_PRAC_ID", ref parms);            

    }

    /***************************************************************************
     * opAcceptOrRejectBatchByPatID */
    /**
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @return                 ReturnEntity
     ***************************************************************************/
    
    public static ReturnSaveRecord opAcceptOrRejectBatchByPatID ( 
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        editDelReason
      , string        validateRec
      , string        recID      
      , string        approved
      , string        siteID
      , string        entryDateRange )
    {
      
      Object    vClientID  = Validate.optClientID (uInfo, "");
      Object    vSiteID    = Validate.optInteger  (siteID,    Messages.INVALID_SITE_ID);	
      Object    vpracID    = Validate.optPracID   (uInfo, "");
	  Object    vApproved  = Validate.optFlag     (approved, Messages.INVALID_FLAG_APPROVE);   
      
	  string startEntryDate = "";
      string endEntryDate   = "";
      Util.parseDateRange(entryDateRange, out startEntryDate, out endEntryDate);
      var vEntryDateRange = Validate.optStartAndEndDate(startEntryDate,endEntryDate,Messages.INVALID_DATE_RANGE);
  
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@clientID",         SqlDbType.Int,      vClientID,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@siteID",           SqlDbType.Int,      vSiteID,            ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@startEntryDate",   SqlDbType.DateTime, vEntryDateRange[0], ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endEntryDate",     SqlDbType.DateTime, vEntryDateRange[1], ParameterDirection.Input));       
      parms.Add(Database.SqlParm("@approved",         SqlDbType.Bit,      vApproved,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@approvingPracID",  SqlDbType.Int,      vpracID  ,          ParameterDirection.Input));

      /*----------------------------
       * Call base method 
       *----------------------------*/

      return Entities.recordOp(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_PAT_ID", ref parms);            

    }

    /***************************************************************************
     * opAcceptBatchBySvcJournalID */
    /**
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @return                 ReturnEntity
     ***************************************************************************/
    public static ReturnSaveRecord opAcceptBatchBySvcJournalID (SqlConnection connSpedmon
                                                              , DetailsLog log
                                                              , UserInfo uInfo
                                                              , string editDelReason
                                                              , string validateRec
                                                              , string recID
                                                              , string approved
                                                              , string siteID 
                                                              , string entryDateRange )
    {
        Object vClientID  = Validate.optClientID(uInfo, "");
        Object vSiteID    = Validate.optInteger  (siteID,    Messages.INVALID_SITE_ID);	
        Object vpracID    = Validate.optPracID(uInfo, "");
        Object vApproved  = Validate.optFlag(approved, Messages.INVALID_FLAG_APPROVE);

        string startEntryDate = "";
        string endEntryDate   = "";
        Util.parseDateRange(entryDateRange, out startEntryDate, out endEntryDate);
        var vEntryDateRange = Validate.optStartAndEndDate(startEntryDate,endEntryDate,Messages.INVALID_DATE_RANGE);
   
        /*----------------------------
         * Collect all of the parameters
         * that are specific to this
         * delete method.
         *----------------------------*/

        var parms = new List<SqlParameter>();

        parms.Add(Database.SqlParm("@clientID"       ,  SqlDbType.Int,      vClientID, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@approved"       ,  SqlDbType.Bit,      vApproved, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@approvingPracID",  SqlDbType.Int,      vpracID,   ParameterDirection.Input));
        parms.Add(Database.SqlParm("@siteID",           SqlDbType.Int,      vSiteID,   ParameterDirection.Input));
	    parms.Add(Database.SqlParm("@startEntryDate",   SqlDbType.DateTime, vEntryDateRange[0], ParameterDirection.Input));
        parms.Add(Database.SqlParm("@endEntryDate",     SqlDbType.DateTime, vEntryDateRange[1], ParameterDirection.Input));       
    
        /*----------------------------
         * Call base method 
         *----------------------------*/

        return Entities.recordOp(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "SERVICE_RECORDS_APPROVAL_ACCEPT_OR_REJECT_BATCH_BY_JOURNAL_ID", ref parms);
    }

    /***************************************************************************
     * viewUnreviewedOrPracHeldServiceRecords */
    /**
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @return                 ReturnEntity
     ***************************************************************************/
      
    public static ReturnDB viewUnreviewedOrPracHeldServiceRecords (    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , int           recViewType
      , bool          pagedOrTop
      , string        idx
      , string        canEdit
      , string        active
      , string        clientID
      , defineCols    dc) 
    {              
      string viewUDF = "dbo.SERVICE_RECORDS_REQ_APPROVAL_BY_PRAC_SUPERVISORS_VIEW_DETAIL_CORE (@userID, @userGroup, @userRank, @clientID)";    

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      Object vClientID = Validate.optClientID (uInfo, clientID);
	        
      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    
      
    }

    /***************************************************************************
     * viewTblUnreviewedOrPracHeldServiceRecords */
    /**
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @return                 ReturnEntity
     ***************************************************************************/
      
    public static ReturnDataTable viewTblUnreviewedOrPracHeldServiceRecords (    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo 
      , bool          paged
      , string        pageNumber
      , string        canEdit
      , string        active
      , string        clientID     
    ) 
      
    {              
       ReturnDataTable so = new ReturnDataTable();
               
      /*----------------------------
       * Define our columns and
       * set the page order for
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
      //Client	Practitioner	ServiceDate	Patient	ServiceProvided	Minutes	EnteredOn	EnteredByUserName	EnteredByUserEmail	EnteredByName	EnteredByTitle	Reviewed	ReviewedByUserName	ReviewedByUserEmail	ReviewedByName	ReviewedByTitle	ReviewedOn	Approved
      
        ss.addDisplayColumn("id");
        ss.addDisplayColumn("Client",       true);        
        ss.addDisplayColumn("Practitioner", true);
        ss.addDisplayColumn("Patient",      true);
        ss.addDisplayColumn("ServiceDate as [Service Date]");
        ss.addDisplayColumn("ServiceProvided as [Service Provided]");
        ss.addDisplayColumn("Minutes");
        ss.addDisplayColumn("Reviewed");
        ss.addDisplayColumn("Approved");
        ss.addDisplayColumn("ReviewedByName as [Reviewed By Name]");
        ss.addDisplayColumn("ReviewedByTitle as [Reviewed By Title]");
 
		    pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return ServiceRecordsApproval.viewUnreviewedOrPracHeldServiceRecords (connSpedmon,log,uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", "", clientID, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Service Records Waiting for Review or Held By Practitioner";
      so.tableFooter = Messages.CONFIDENTIAL;
     
      return so;      
    }
                                      
    /***************************************************************************
     * viewServiceRecordsReviewForAssignedSupervisingPracs */
    /**
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @return                 ReturnEntity
     ***************************************************************************/
      
    public static ReturnDB viewServiceRecordsReviewForDirectAssignedPracs (    
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , int           recViewType
      , bool          pagedOrTop
      , string        idx
      , string        canEdit
      , string        active
      , string        clientID
      , string        supervisingPracID
	  , string        supervisedPracID
	  , string        patID
	  , string        dateRange
      , defineCols    dc) 
    {              
         
	    string viewUDF = "dbo.SERVICE_RECORDS_REVIEW_FOR_DIRECT_ASSIGNED_SUPERVISING_PRACS (@userID, @userGroup, @userRank, @clientID, @supervisingPracID, @supervisedPracID, @patID, @startDate, @endDate)";    

      /*-------------------------------
       * Parse date range into start
       * and end dates
       *----------------------------*/

      string startDate = "";
      string endDate   = "";
      Util.parseDateRange(dateRange, out startDate, out endDate);

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      long     vClientID          = Validate.reqClientID (uInfo, clientID);
	  long     vSupervisingPracID = Validate.reqPracID   (uInfo, supervisingPracID);
      Object   vSupervisedPracID  = Validate.optInteger  (supervisedPracID, Messages.INVALID_PRAC_ID);
      Object   vPatID             = Validate.optInteger  (patID,            Messages.INVALID_PAT_ID);
      Object   vStartDate         = Validate.optDate     (startDate,        Messages.INVALID_START_DATE);
      Object   vEndDate           = Validate.optDate     (endDate,          Messages.INVALID_END_DATE);

	  List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID",          SqlDbType.BigInt,   vClientID,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@supervisingPracID", SqlDbType.BigInt,   vSupervisingPracID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@supervisedPracID",  SqlDbType.BigInt,   vSupervisedPracID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",             SqlDbType.BigInt,   vPatID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate",         SqlDbType.DateTime, vStartDate,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",           SqlDbType.DateTime, vEndDate,           ParameterDirection.Input));
    
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    
      
    }
    
    /***************************************************************************
     * viewTblServiceRecordsReviewForAssignedSupervisingPracs */
    /**
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @return                 ReturnEntity
     ***************************************************************************/
      
    public static ReturnDataTable viewTblServiceRecordsReviewForDirectAssignedPracs (    
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo 
      , bool          paged
      , string        pageNumber
      , string        canEdit
      , string        active
      , string        clientID
      , string        supervisingPracID
	  , string        supervisedPracID
	  , string        patID
	  , string        dateRange
  
    ) 
      
    {              
       ReturnDataTable so = new ReturnDataTable();
               
      /*----------------------------
       * Define our columns and
       * set the page order for
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
      
        ss.addDisplayColumn("id");
        
        ss.addDisplayColumnIfParmValueIsNull("clientName                  as [Client]",                    "@clientID",          true, ref parms);
        ss.addDisplayColumnIfParmValueIsNull("supervisingPracName         as [Supervising\nPractitioner]", "@supervisingPracID", true, ref parms);
        
        ss.addDisplayColumn("supervisedPracNameAndGroup as [Rendering\nPractitioner]",  true);       
        ss.addDisplayColumn("patName                       as [Patient\nName]",         true);        
        ss.addDisplayColumn("patDobStr                     as [Patient\nDOB]");
        ss.addDisplayColumn("patSSID                       as [Patient\nSSID]");
        ss.addDisplayColumn("patCurrentSiteName            as [Patient\nCurrent School]");
        ss.addDisplayColumn("svcDateStr                    as [Service\nDate]");
        ss.addDisplayColumn("attendanceStatusSelectionName as [Attendance\nStatus]");       
        ss.addDisplayColumn("svcMins                       as [Service\nMinutes]");
        ss.addDisplayColumn("svcProvided                   as [Service\nRendered]");        
        ss.addDisplayColumn("renderingPracSig              as [Signed By]");
        ss.addDisplayColumn("reviewingPracSig              as [Reviewed By]");
        ss.addDisplayColumn("svcNotes                      as [Service\nNotes]");
        ss.addDisplayColumn("privateSvcNotes               as [Private\nService\nNotes]");
        
		pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest
       *----------------------------*/

      so = Entities.viewTbl(  connSpedmon
                            , log
                            , uInfo
                            , paged
                            , pageNumber
                            , delegate { 
                              return ServiceRecordsApproval.viewServiceRecordsReviewForDirectAssignedPracs (
                                  connSpedmon
                                , log
                                , uInfo
                                , Entities.REC_VIEW_TBL
                                , paged
                                , pageNumber
                                , ""
                                , ""
                                , clientID
                                , supervisingPracID
                                , supervisedPracID
                                , patID
                                , dateRange
                                , dc); 
                            });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Service Records To Review";
      so.tableFooter = Messages.CONFIDENTIAL;
      
      
     if ( !Util.IsNullOrEmpty (clientID) )
     {
       Client c = Clients.load(connSpedmon,log,uInfo,clientID);
       so.tableName = so.tableName + " - " + c.name;
     }
     
     if ( !Util.IsNullOrEmpty (supervisingPracID) )
     {
        Practitioner prac = Practitioners.load ( connSpedmon, log, uInfo, supervisingPracID );
        so.tableName = so.tableName + " - Supervising Practitioner : " + prac.name;
     }
     
     if ( !Util.IsNullOrEmpty (supervisedPracID) )
     {
        Practitioner prac = Practitioners.load ( connSpedmon, log, uInfo, supervisedPracID );
        so.tableName = so.tableName + @" - Rendering Practitioner : " + prac.name + @" (" + prac.groupName + @")";
     }
      
     if ( !Util.IsNullOrEmpty (patID) )
     {
       Patient pat = Patients.load ( connSpedmon, log, uInfo, patID );
       so.tableName = so.tableName + " - Patient : " + pat.name;
     }
     
      return so;      
    }
    

    /***************************************************************************
     * viewUnreviewedOrPracHeldServiceRecords */
    /**
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @return                 ReturnEntity
     * 
     * Entry point for summary manage for health services
     ***************************************************************************/
      
    public static ReturnDB viewUnreviewedServicesByJournal (    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , int           recViewType
      , bool          pagedOrTop
      , string        idx
      , string        canEdit
      , string        active
      , string        clientID
      , string        siteID
      , string        pracID
      , string        approvingPracID
      , string        assigned
      , string        journalID
      , string        entryDateRange
      , defineCols    dc) 
    {              

      string viewUDF = "dbo.SERVICE_RECORDS_TO_APPROVE_BY_JOURNAL_ID_VIEW_SUMMARY (@userID, @userGroup, @userRank, @clientID, @siteID, @pracID, @approvingPracID, @startEntryDate, @endEntryDate, @assigned, @journalID, 0)";    

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      Object    vClientID           = Validate.optClientID (uInfo,     clientID);
      Object    vSiteID             = Validate.optInteger  (siteID,    Messages.INVALID_SITE_ID);
      Object    vPracID             = Validate.optInteger  (pracID,    @"Invalid prac");
      Object    vApprovingPracID    = Validate.optPracID   (uInfo,     approvingPracID);
      Object    vJournalID          = Validate.optInteger  (journalID, Messages.INVALID_RECORD_ID);
      Object    vAssigned           = Validate.optFlag     (assigned, @"Invalid value for assigned", false);
      
      string startEntryDate = "";
      string endEntryDate   = "";
      Util.parseDateRange(entryDateRange, out startEntryDate, out endEntryDate);
      var vEntryDateRange = Validate.optStartAndEndDate(startEntryDate,endEntryDate,Messages.INVALID_DATE_RANGE);
      
      var parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID",         SqlDbType.Int,      vClientID,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@siteID",           SqlDbType.Int,      vSiteID,            ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@pracID",           SqlDbType.Int,      vPracID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@approvingPracID",  SqlDbType.Int,      vApprovingPracID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startEntryDate",   SqlDbType.DateTime, vEntryDateRange[0], ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endEntryDate",     SqlDbType.DateTime, vEntryDateRange[1], ParameterDirection.Input));
      parms.Add(Database.SqlParm("@assigned",         SqlDbType.Bit,      vAssigned,          ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@journalID",        SqlDbType.Int,      vJournalID,         ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    
      
    }

      
    /***************************************************************************
     * viewObjectsUnreviewedServicesByJournal */
    /**
     * Entry point for summary manage for health services
     ***************************************************************************/
    public static ReturnObjects viewObjectsUnreviewedServicesByJournal (   SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , bool   pageObjectList
                                              , string pageOrder
                                              , string idx
                                              , string active
                                              , string clientID
                                              , string siteID
                                              , string pracID
                                              , string approvingPracID
                                              , string assigned
                                              , string journalID 
                                              , string entryDateRange )

    {

      /* Default page order */

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ServiceRecord.DEFAULT_PAGING_ORDER;

      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      return Entities.viewObjects (   connSpedmon
                                    , log
                                    , uInfo
                                    , typeof(ServiceRecordsApprovalDetail)
                                    , pageObjectList
                                    , pageOrder
                                    , delegate {
                                        return ServiceRecordsApproval.viewUnreviewedServicesByJournal(
                                                                                   connSpedmon
                                                                                 , log
                                                                                 , uInfo
                                                                                 , Entities.REC_VIEW_OBJECTS
                                                                                 , pageObjectList
                                                                                 , idx
                                                                                 , ""
                                                                                 , active
                                                                                 , clientID
                                                                                 , siteID
                                                                                 , pracID
                                                                                 , approvingPracID
                                                                                 , assigned
                                                                                 , journalID
                                                                                 , entryDateRange
                                                                                 , dc);
                                    });


    }


   
        
  }


} 

