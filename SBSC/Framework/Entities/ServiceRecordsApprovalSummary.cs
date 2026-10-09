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
   * ServiceRecordsApprovalSummaryDetail */
  /**
   ***************************************************************************/

  public class ServiceRecordsApprovalSummaryDetail : ServiceRecord
  {
        new public const string DEFAULT_PAGING_ORDER = @"pracName, pracGroup"; 
        //public const string DEFAULT_PAGING_ORDER_FOR_SUMMARY = @"pracName asc, patName asc, dos desc";
        
        public string pracGroup;
        public bool   assigned;        
        //public int    numNew;        
        //public int    numHeld;        
        //public int    numRecords;
        public long   pracUserID;
        public string pracNameForMessages;
        public string siteName;
        public bool   pracIsSupervisedByApprovingPracID;
        public long   latestPracSupervisionByApprovingPracRecID;
        public long   svcRecID;
        public string renderingPractitionerSignature;
        public string reviewingPractitionerSignature;
        public string privateNotes;
        public string SvcReviewNotes;
  }

   
  /***************************************************************************
   * ServiceRecordsApprovalSummary */
  /**
   * Records of services rendered by practitioners for patients.  These
   * records can be entered either by the client or internal staff.
   ***************************************************************************/

  public class ServiceRecordsApprovalSummary:Entities
  {
    /***************************************************************************
     * REST VIEW */
    /**
     * 
     ***************************************************************************/

    public const string URL_REST_VIEW_SUMMARY_BY_PRAC      = @"api/v1/servicerecordsapprovalsummarybyprac";
    public const string URL_WEB_REPORT_SUMMARY_BY_PRAC     = @"servicerecordsapproval.ashx";

    public static string URL_REST_VIEW_BASE_SUMMARY_BY_PRAC()
    { 
       return MBA.HttpApplication.createLink(ServiceRecordsApprovalSummary.URL_REST_VIEW_SUMMARY_BY_PRAC, true);
    }

    public static string URL_WEB_REPORT_SUMMARY_BY_PRAC_BASE()
    {
        return MBA.HttpApplication.createLink(ServiceRecordsApprovalSummary.URL_WEB_REPORT_SUMMARY_BY_PRAC, true);
    }

    /***************************************************************************
     * view */
    /**
     * Entry point for summary for non health services review
     **************************************************************************/  
   
    public static ReturnDB view (  SqlConnection connSpedmon
                                 , DetailsLog    log
                                 , UserInfo      uInfo
                                 , int           recViewType
                                 , bool          pagedOrTop
                                 , string        idx
                                 , string        canEdit
                                 , string        active
                                 , string        clientID
								 , string        approvingPracID
								 , string        assigned
								 , string        reviewed
								 , string        approved
                                 , string        siteID
                                 , string        pracID
                                 , string        entryDateRange
                                 , defineCols dc )
    {
   
      string viewUDF = "dbo.SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_VIEW_SUMMARY (@userID, @userGroup, @userRank, @clientID, @approvingPracID, @assigned, @reviewed, @approved, @siteID, null, @startEntryDate, @endEntryDate)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      Object    vClientID        = Validate.optClientID (uInfo,   clientID);
	  Object    vApprovingPracID = Validate.optPracID   (uInfo,   approvingPracID);
      var       vAssigned        = Validate.optFlag     (assigned, @"Invalid value for assigned", false);
      var       vReviewed        = Validate.optFlag     (reviewed, @"Invalid value for reviewed", false);
      var       vApproved        = Validate.optFlag     (approved, @"Invalid value for approved", false);
	  Object    vSiteID          = Validate.optInteger  (siteID,   Messages.INVALID_SITE_ID);

      string startEntryDate = "";
      string endEntryDate   = "";
      Util.parseDateRange(entryDateRange, out startEntryDate, out endEntryDate);
      var vEntryDateRange = Validate.optStartAndEndDate(startEntryDate,endEntryDate,Messages.INVALID_DATE_RANGE);

      var parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID",           SqlDbType.Int,      vClientID,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@approvingPracID",    SqlDbType.Int,      vApprovingPracID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@assigned",           SqlDbType.Bit,      vAssigned,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@reviewed",           SqlDbType.Bit,      vReviewed,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@approved",           SqlDbType.Bit,      vApproved,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@siteID",             SqlDbType.Int,      vSiteID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startEntryDate",     SqlDbType.DateTime, vEntryDateRange[0], ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endEntryDate",       SqlDbType.DateTime, vEntryDateRange[1], ParameterDirection.Input));
      
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
								           , string        approvingPracID
                                           , string        assigned
								           , string        reviewed
								           , string        approved
                                           , string        siteID
                                           , string        entryDateRange
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
        ss.addDisplayColumn("pracID   as [id]");
        ss.addDisplayColumn("pracName as [Practitioner]");

        if (reviewed == "1") { 
            ss.addDisplayColumn("reviewingPractitionerSignature as [Reviewing\nPractitioner\nSignature]");
            ss.addDisplayColumn("SvcReviewNotes as [Review\nNotes]");       
        }

        ss.addDisplayColumn("dosStr         as [Date of Service]");
        ss.addDisplayColumn("patName        as [Patient]");
        ss.addDisplayColumn("pracGroup      as [Practitioner Type]");
        ss.addDisplayColumn("siteName       as [Site]");
        ss.addDisplayColumn("notes          as [Notes]");
        ss.addDisplayColumn("privateNotes   as [Private\nNotes]");

        
		pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return ServiceRecordsApprovalSummary.view (connSpedmon,log,uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", "", clientID, approvingPracID, assigned, reviewed, approved, siteID, "", entryDateRange, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Service Records to Approve";
      so.tableFooter = Messages.CONFIDENTIAL;
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
    }
    
    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of objects
     * 
     ***************************************************************************/

    public static ReturnObjects viewObjects (  SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , bool pageObjectList
                                              , string pageOrder
                                              , string idx
                                              , string active
                                              , string clientID
                                              , string approvingPracID
                                              , string assigned
                                              , string reviewed
                                              , string approved
                                              , string siteID
                                              , string entryDateRange
    )
    {

        /* Default page order */

        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ServiceRecordsApprovalSummaryDetail.DEFAULT_PAGING_ORDER;

        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };

        return Entities.viewObjects(connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(ServiceRecordsApprovalSummaryDetail)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate
                                      {
                                          return ServiceRecordsApprovalSummary.view(
                                                                     connSpedmon
                                                                   , log
                                                                   , uInfo
                                                                   , Entities.REC_VIEW_OBJECTS
                                                                   , pageObjectList
                                                                   , idx
                                                                   , "" // canEdit
                                                                   , active
                                                                   , clientID
                                                                   , approvingPracID
                                                                   , assigned
                                                                   , reviewed
                                                                   , approved
                                                                   , siteID
                                                                   , ""
                                                                   , entryDateRange
                                                                   , dc
                                           );
                                      });
    }	
	
  }
} 

