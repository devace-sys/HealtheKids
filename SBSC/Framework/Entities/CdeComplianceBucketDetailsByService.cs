using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Collections.Specialized;
using System.Collections;
using MBA;
using Geo;
using Geo.CDE;

namespace Spedmon
{    
  
  /***************************************************************************
   * CdeComplianceBucketDetailByService */
  /**
   * 
   ****************************************************************************/

  public class CdeComplianceBucketDetailByService: CdeComplianceBucketByServiceBase
  {
    public long     patID;
    public string   patName;
    public string   patDOBStr;
    public string   patSSID;
    public string   patBIC;
    public string   spEdCaseManagerName;
	public DateTime spEdExitedSpEdDate;
	public string   spEdExitedSpEdDateStr;
    public int      spEdFreqCode;
    public string   spEdFreqName;
    public int      minsPerFreq;
    public DateTime planStartDate;
    public DateTime planEndDate;
    public string   planStartDateStr;
    public string   planEndDateStr;
    public int      numPatAbsentTot;
	public int      numPracAbsentTot;
    public int      numSvcRecs;
    public int      numAbsentTot;
    public long     siteID;
    public string   siteName;
    public Single   pctAbsencePat;
    public string   pctAbsencePatStr;
    public Single   pctAbsencePrac;
    public string   pctAbsencePracStr;
    public Single   pctAbsence;
    public string   pctAbsenceStr;
    public string   caseLoadAssignmentsForSpEdSvcSummaryText;
    public bool     hasCaseloadAssignmentsForSpEdSvc;
    public string   hasCaseloadAssignmentsForSpEdSvcStr;
    public string   caseLoadAssignmentsForSpEdSvcSummaryHTML;

    public const string DEFAULT_PAGING_ORDER = @"patName asc";

  }
  
  /***************************************************************************
   * CdeComplianceBucketDetailsByService */
  /**
   * 
   ****************************************************************************/

  public class CdeComplianceBucketDetailsByService: Entities
  {

    public const string SEL_LABEL_MANAGE   = CdeComplianceCommon.SEL_LABEL_MANAGE + @" - Details By Service";
    public const string SEL_LABEL_RPT      = CdeComplianceCommon.SEL_LABEL_MANAGE + @" - Details By Service";
    public const string BODY_ID_MANAGE     = @"cdecompliancemanagedetailsbyservice";
    public const string MENU_ID_MANAGE     = @"cdecompliancemanagedetailsbyservicelnk";

    public const string URL_REST_VIEW_BASE     = @"api/v1/cdecompliancebucketsdetailsbyservice";
    public const string URL_MANAGE             = @"user_all_cde_compliance_details_by_service_manage.aspx";
      
    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW()
    { 
       return MBA.HttpApplication.createLink(CdeComplianceBucketDetailsByService.URL_REST_VIEW_BASE, true);
    }
    
    /***************************************************************************
     * URL_PAGE_MANAGE */
    /**
     * 
     **************************************************************************/  
    public static string URL_PAGE_MANAGE(bool newWindow)
    {
       return MBA.HttpApplication.createLink(CdeComplianceBucketDetailsByService.URL_MANAGE
                                             , true
                                             , (newWindow) ? new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE) : null
                                             );
    }

    /***************************************************************************
     * generateActionURL */
    /**
     * 
     **************************************************************************/  
    public static string generateActionURL (string clientIDStr, string siteIDStr, string patIDStr, string spEdSvcCodeStr, string pcalComplianceRatingCodeStr, string overDeliveryStr)
    { 
       return MBA.HttpApplication.createLink(  CdeComplianceBucketDetailsByService.URL_MANAGE
                                             , true
                                             , new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE)
                                             , new NameValue(Constants.PARM_CLIENT_ID,                      clientIDStr)
                                             , new NameValue(Constants.PARM_SITE_ID,                        siteIDStr)
                                             , new NameValue(Constants.PARM_PATIENT_ID,                     patIDStr)
                                             , new NameValue(Constants.PARM_SPED_SERVICE_CODE,              spEdSvcCodeStr)
                                             , new NameValue(Constants.PARM_PCAL_COMPLIANCE_RATING_FOR_PAT, pcalComplianceRatingCodeStr)
                                             , new NameValue(Constants.PARM_SVC_OVER_DELIVERY,              overDeliveryStr)
                                             );
    }

    /***************************************************************************
     * view */
    /**
     * View base method
     * 
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnDB view (  SqlConnection connSpedmon
                                 , DetailsLog    log
                                 , UserInfo      uInfo
                                 , int           recViewType
                                 , bool          pagedOrTop
                                 , string        idx
                                 , string        canEdit
                                 , string        active
                                 , string        clientID
                                 , string        siteID
                                 , string        patID
                                 , string        spEdServiceCode
                                 , string        pcalComplianceRatingForPat
                                 , string        overDelivery
                                 , defineCols    dc )
    {
      
      string viewUDF = "dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_SERVICE_DETAILS (@userID,@userGroup,@userRank,@clientID,@siteID,@patID,@spEdServiceCode,@pcalComplianceRatingForPat,@overDelivery)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      long   vClientID                   = Validate.reqClientID (uInfo,     clientID);
      Object vSiteID                     = Validate.optInteger  (siteID,                     Messages.INVALID_SITE_ID);
      Object vPatID                      = Validate.optPatID    (uInfo, patID);
      Object vSpEdSvcCode                = Validate.optInteger  (spEdServiceCode,            Messages.INVALID_CALPADS_CODE);
      Object vPcalComplianceRatingForPat = Validate.optInteger  (pcalComplianceRatingForPat, Messages.INVALID_RATING_CODE);
      Object vOverDelivery               = Validate.optFlag     (overDelivery ,@"Invalid value for overdelivery",false);

      var parms = new List<SqlParameter>();   

      parms.Add(Database.SqlParm("@clientID",                    SqlDbType.BigInt,    vClientID,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@siteID",                      SqlDbType.BigInt,    vSiteID,                      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                       SqlDbType.BigInt,    vPatID,                       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@spEdServiceCode",             SqlDbType.Int,       vSpEdSvcCode,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pcalComplianceRatingForPat",  SqlDbType.TinyInt,   vPcalComplianceRatingForPat,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@overDelivery",                SqlDbType.Bit,       vOverDelivery,                ParameterDirection.Input));
      
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
    }

    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of objects
     * 
     ***************************************************************************/
    public static ReturnObjects viewObjects (  SqlConnection connSpedmon
                                              , DetailsLog   log
                                              , UserInfo     uInfo
                                              , bool         pageObjectList
                                              , string       pageOrder
                                              , string       idx
                                              , string       active
                                              , string       clientID 
                                              , string       siteID
                                              , string       patID
                                              , string       spEdServiceCode
                                              , string       pcalComplianceRatingForPat
                                              , string       overDelivery ) 
    {
 
        /* Default page order */
 
        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = CdeComplianceBucketDetailByService.DEFAULT_PAGING_ORDER;
 
        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */
 
        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };
 
        return Entities.viewObjects(connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(CdeComplianceBucketDetailByService)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return CdeComplianceBucketDetailsByService.view(connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" /* Can edit */
                                                                       , active
                                                                       , clientID
                                                                       , siteID
                                                                       , patID
                                                                       , spEdServiceCode
                                                                       , pcalComplianceRatingForPat
                                                                       , overDelivery
                                                                       , dc);
                                      });
 
 
    }
  
    /***************************************************************************
     * viewTbl 
     *
     * Returns ReturnDataTable
     * 
     ***************************************************************************/
 
     public static ReturnDataTable viewTbl ( SqlConnection connSpedmon
                                           , DetailsLog log
                                           , UserInfo uInfo
                                           , bool paged
                                           , string pageNumber
                                           , string canEdit
                                           , string active
                                           , string clientID
                                           , string siteID
                                           , string patID
                                           , string spEdServiceCode
                                           , string pcalComplianceRatingForPat
                                           , string overDelivery )
        {
            ReturnDataTable so = new ReturnDataTable();

            /*###########################################################################
              # Define our display columns and set the page order.  Page order needs to
              # be in the same sort order as the udf called in the view.
              ###########################################################################*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
              
                ss.addDisplayColumn("patName                      as [Student Last, First]", true);
                ss.addDisplayColumn("patSSID                      as [SSID]");
                ss.addDisplayColumn("siteName                     as [Site]");
                ss.addDisplayColumn("spEdCaseManagerName          as [Case Manager]");
                ss.addDisplayColumn("spEdServiceCodeAndName       as [Service]");
                ss.addDisplayColumn("spEdFreqName                 as [Frequency]");
                ss.addDisplayColumn("minsPerFreq                  as [Minutes\nPer\nFrequency]");
                ss.addDisplayColumn("startDateStr                 as [Plan Start\nDate]");
                ss.addDisplayColumn("spEdExitedSpEdDateStr        as [Patient\nExited\nSpEd]");
                ss.addDisplayColumn("endDateStr                   as [Plan End or\nCurrent Date]");
                ss.addDisplayColumn("totMinsExpected              as [Minutes\nExpected\n To Date]");
                ss.addDisplayColumn("totMinsApplicable            as [Minutes\nSatisfied\n To Date]");
                ss.addDisplayColumn("totMinsDiff                  as [Minutes\nMissing\nTo Date]");
                ss.addDisplayColumn("pctExpectedApplicableStr     as [Percentage\nSatisfied\nTo Date]");                
               
                ss.addDisplayColumn("numSvcRecs         as [Sessions\nDocumented]");                
                ss.addDisplayColumn("pctAbsencePatStr   as [Percent\nSessions\nDocumented\nStudent\nAbsent]");
                ss.addDisplayColumn("pctAbsencePracStr  as [Percent\nSessions\nDocumented\nStudent\nAbsent]");
                ss.addDisplayColumn("pctAbsenceStr      as [Percent\nSessions\nDocumented\nAbsent]");

                ss.addDisplayColumn("numPatAbsentTot  as [Sessions\nDocumented\nStudent\nAbsent]");
                ss.addDisplayColumn("numPracAbsentTot as [Sessions\nDocumented\nPractioner\nAbsent]");
                ss.addDisplayColumn("numAbsentTot     as [Sessions\nDocumented\nAbsent]");
                ss.addDisplayColumn("hasCaseloadAssignmentsForSpEdSvcStr as [Has\nCaseload\nAssignments\nFor\nThis\nService\nPlan]");
                ss.addDisplayColumn("caseLoadAssignmentsForSpEdSvcSummaryText as [Caseload Assignments For This Service Plan]");

                ss.addDisplayColumn("patID                        as [SpEdCare\nPatID]");     
                
                pageroworder = ss.pageRowOrder();
            };

            /*###########################################################################
              # Call the base method which handles the rest and returns a ReturnDataTable
              ###########################################################################*/

            so = Entities.viewTbl(connSpedmon
                                  , log
                                  , uInfo
                                  , paged
                                  , pageNumber
                                  , delegate {
                                      return
                                            view ( connSpedmon
                                                   , log
                                                   , uInfo
                                                   , Entities.REC_VIEW_TBL
                                                   , paged
                                                   , pageNumber
                                                   , canEdit
                                                   , active
                                                   , clientID
                                                   , siteID
                                                   , patID
                                                   , spEdServiceCode
                                                   , pcalComplianceRatingForPat
                                                   , overDelivery
                                                   , dc );
                                  });

            /*###########################################################################
              # Add a title and footer to ReturnDataTable then return
              ###########################################################################*/

            so.tableName   = SEL_LABEL_RPT;
            so.tableFooter = Messages.CONFIDENTIAL;

            return so;

        }



  }    
}
