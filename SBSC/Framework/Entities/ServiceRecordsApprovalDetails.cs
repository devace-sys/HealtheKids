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
   * ServiceRecordsApprovalDetail */
  /**
   ***************************************************************************/  
  public class ServiceRecordsApprovalDetail : ServiceRecord
  {
        new public const string DEFAULT_PAGING_ORDER = @"pracName, patName";                
        public const string DEFAULT_PAGING_ORDER_FOR_SUMMARY = @"pracName asc, patName asc, dos desc";
        public const string DEFAULT_PAGING_ORDER_FOR_DETAIL  = @"pracName, patName, dos desc, startTimeVal asc";
        public string pracGroup;
        public string held;
        public long   svcJournalID;
        public long   pracUserID;
        public string pracNameForMessages;
        public string siteName;
        public bool   pracIsSupervisedByApprovingPracID;
        public long   latestPracSupervisionByApprovingPracRecID;
        public string privateNotes;
        public bool   svcFromJournal;
        public string SvcReviewNotes;
   }

   
  /***************************************************************************
   * ServiceRecordsApprovalDetail */
  /**
   * Records of services rendered by practitioners for patients.  These
   * records can be entered either by the client or internal staff.
   ***************************************************************************/

  public class ServiceRecordsApprovalDetails:Entities
  {
    public const string URL_REST_VIEW                   = @"api/v1/servicerecordsapprovaldetails";
    public const string URL_REST_VIEW_BY_SVC_REC_ID     = @"api/v1/servicerecordsapprovaldetailsbysvcrecid";


    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/
    public static string URL_REST_VIEW_BASE()
    { 
       return MBA.HttpApplication.createLink(ServiceRecordsApprovalDetails.URL_REST_VIEW, true);
    }

    public static string URL_REST_VIEW_BY_SVC_REC_ID_BASE()
    { 
       return MBA.HttpApplication.createLink(ServiceRecordsApprovalDetails.URL_REST_VIEW_BY_SVC_REC_ID, true);
    }

    /***************************************************************************
     * view */
    /**
     * Entry point for health services review detail
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
								 string        approvingPracID,
                                 string        pracID,
                                 string        patID,
                                 string        journalID,
                                 defineCols dc)
    {
   
      string viewUDF = "dbo.SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_VIEW_DETAIL (@userID, @userGroup, @userRank, @clientID, null, @approvingPracID, @pracID, null, null, @patID, @journalID, 0)";    

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      Object    vClientID          = Validate.optClientID (uInfo,     clientID);
	  Object    vApprovingPracID   = Validate.optPracID   (uInfo,     approvingPracID);
      Object    vPracID            = Validate.optInteger  (pracID,    Messages.INVALID_PRAC_ID);
      Object    vPatID             = Validate.optInteger  (patID,     Messages.INVALID_PAT_ID);
      Object    vJournalID         = Validate.optInteger  (journalID, Messages.INVALID_RECORD_ID);
	        
      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID",           SqlDbType.BigInt,      vClientID,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@approvingPracID",    SqlDbType.BigInt,      vApprovingPracID,  ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@pracID",             SqlDbType.BigInt,      vPracID,           ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@patID",              SqlDbType.BigInt,      vPatID,            ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@journalID",          SqlDbType.BigInt,      vJournalID,        ParameterDirection.Input));

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
								           , string        pracID
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
        ss.addDisplayColumn("id");              
        ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(reviewed) as [Held]", true);
        ss.addDisplayColumn("patName     as [Patient]", true);
        ss.addDisplayColumn("dos         as [DOS]",     true);               
        ss.addDisplayColumn("svcRecID    as [referenceID1]");       
        
        //ss.addPageOrderColumn("Held asc");
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return ServiceRecordsApprovalDetails.view (connSpedmon,log,uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", "", clientID, approvingPracID, pracID, null, journalID, dc); });
   
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
     * viewObjects */
    /**
     * Returns an object set of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnObjects viewObjects (   SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , bool   pageObjectList
                                              , string pageOrder
                                              , string idx
                                              , string active
                                              , string clientID
                                              , string pracID
                                              , string approvingPracID
                                              , string patID
                                              , string journalID)

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
                                        return ServiceRecordsApprovalDetails.view (connSpedmon
                                                                                 , log
                                                                                 , uInfo
                                                                                 , Entities.REC_VIEW_OBJECTS
                                                                                 , pageObjectList
                                                                                 , idx
                                                                                 , ""
                                                                                 , active
                                                                                 , clientID
                                                                                 , approvingPracID
                                                                                 , pracID
                                                                                 , patID
                                                                                 , journalID
                                                                                 , dc);
                                    });


    }

    /***************************************************************************
     * viewBySvcRecID */
    /**
     * Entry point for non health services details review
     **************************************************************************/  
   
    public static ReturnDB viewBySvcRecID ( SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , int           recViewType
                                           , bool          pagedOrTop
                                           , string        idx
                                           , string        canEdit
                                           , string        active
                                           , string        clientID
								           , string        siteID
                                           , string        approvingPracID
                                           , string        pracID
                                           , string        entryDateRange
                                           , string        patID
                                           , string        svcRecID
                                           , defineCols dc)
    {
   
      string viewUDF = "dbo.SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_AND_SVC_REC_ID_VIEW_DETAIL (@userID, @userGroup, @userRank, @clientID, @siteID, @approvingPracID, @pracID, @startEntryDate, @endEntryDate, @patID, @svcRecID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      var vClientID          = Validate.optClientID (uInfo,     clientID);
	  var vSiteID            = Validate.optInteger  (siteID,    Messages.INVALID_SITE_ID);
      var vApprovingPracID   = Validate.optPracID   (uInfo,     approvingPracID);
      var vPracID            = Validate.optInteger  (pracID,    Messages.INVALID_PRAC_ID);
      var vPatID             = Validate.optInteger  (patID,     Messages.INVALID_PAT_ID);
      var vSvcRecID          = Validate.optInteger  (svcRecID,  Messages.INVALID_RECORD_ID);
	  
      string startEntryDate = "";
      string endEntryDate   = "";
      Util.parseDateRange(entryDateRange, out startEntryDate, out endEntryDate);
      var vEntryDateRange = Validate.optStartAndEndDate(startEntryDate,endEntryDate,Messages.INVALID_DATE_RANGE);

      var parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID",           SqlDbType.BigInt,      vClientID,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@siteID",             SqlDbType.BigInt,      vSiteID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@approvingPracID",    SqlDbType.BigInt,      vApprovingPracID,   ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@pracID",             SqlDbType.BigInt,      vPracID,            ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@startEntryDate",     SqlDbType.DateTime,    vEntryDateRange[0], ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endEntryDate",       SqlDbType.DateTime,    vEntryDateRange[1], ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",              SqlDbType.BigInt,      vPatID,             ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@svcRecID",           SqlDbType.BigInt,      vSvcRecID,          ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }

    /***************************************************************************
     * viewObjectsBySvcRecID */
    /**
     * Returns an object set of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnObjects viewObjectsBySvcRecID(   SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , bool   pageObjectList
                                              , string pageOrder
                                              , string idx
                                              , string active
                                              , string clientID
                                              , string siteID
                                              , string pracID
                                              , string entryDateRange
                                              , string approvingPracID
                                              , string patID
                                              , string svcRecID)

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
                                        return ServiceRecordsApprovalDetails.viewBySvcRecID (connSpedmon
                                                                                 , log
                                                                                 , uInfo
                                                                                 , Entities.REC_VIEW_OBJECTS
                                                                                 , pageObjectList
                                                                                 , idx
                                                                                 , ""
                                                                                 , active
                                                                                 , clientID
                                                                                 , siteID
                                                                                 , approvingPracID
                                                                                 , pracID
                                                                                 , entryDateRange
                                                                                 , patID
                                                                                 , svcRecID
                                                                                 , dc);
                                    });


    }
  }
} 

