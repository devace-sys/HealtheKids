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
   * CdeComplianceBucketDetailsByPcalComplianceRatingAndPatient */
  /**
   * 
   ****************************************************************************/

  public class CdeComplianceBucketDetailsByPcalComplianceRatingAndPatient
  {  
    public const string DEFAULT_PAGING_ORDER = @"patName asc";

    public long     clientID;
    public long     siteID;
    public long     patID;
    public int      numSvcs;
    public Single   iepCompliancePctForPat;
	public int      pcalComplianceRatingForPatCode;
    public string   pcalComplianceRatingForPatName; 
    public string   clientName;
	public string   siteName;
	public string   patName;
    public string   patSSID;
	public string   patDOBStr;	
    public string   spEdCaseManagerName;
    public DateTime spEdExitedSpEdDate;
    public string   spEdExitedSpEdDateStr;
    public string   caseLoadAssignmentsSummaryText;
    public bool     hasCaseloadAssignments;
    public string   hasCaseloadAssignmentsStr;
    public string   caseLoadAssignmentsSummaryHTML;
  }
  
  /***************************************************************************
   * CdeComplianceBucketDetailsByPcalComplianceRatingAndPatients */
  /**
   * 
   ****************************************************************************/

  public class CdeComplianceBucketDetailsByPcalComplianceRatingAndPatients: Entities
  {
    public const string BODY_ID_MANAGE     = @"cdecompliancbucketdetailsbypcalcompliantratingandpatients";
    public const string MENU_ID_MANAGE     = @"cdecompliancbucketdetailsbypcalcompliantratingandpatientslnk";

    public const string SEL_LABEL_MANAGE = CdeComplianceCommon.SEL_LABEL_MANAGE + @" - Details By Patient";
    public const string SEL_LABEL_RPT    = CdeComplianceCommon.SEL_LABEL_MANAGE + @" - Details By Patient";
    
    public const string URL_REST_VIEW_BASE     = @"api/v1/cdecompliancebucketsdetailsbypcalcomplianceratingandpatients";
    public const string URL_MANAGE             = @"user_all_cde_compliance_details_by_pcal_compliance_rating_and_patients_manage.aspx";

    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  

    public static string URL_REST_VIEW() {
      return MBA.HttpApplication.createLink(URL_REST_VIEW_BASE, true);
    }
    
    /***************************************************************************
     * generateActionURL */
    /**
     * 
     **************************************************************************/  
    public static string generateActionURL (string clientIDStr, string siteIDStr, string pcalComplianceRatingCodeStr)
    { 
       return MBA.HttpApplication.createLink(  CdeComplianceBucketDetailsByPcalComplianceRatingAndPatients.URL_MANAGE
                                             , true
                                             , new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE)
                                             , new NameValue(Constants.PARM_CLIENT_ID,                      clientIDStr)
                                             , new NameValue(Constants.PARM_SITE_ID,                        siteIDStr)
                                             , new NameValue(Constants.PARM_PCAL_COMPLIANCE_RATING_FOR_PAT, pcalComplianceRatingCodeStr)
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
								 , string        pcalComplianceRatingForPat
                                 , defineCols    dc )
    {
      
      string viewUDF = "dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PCAL_COMPLIANCE_RATING_DETAILS (@userID, @userGroup, @userRank, @clientID, @siteID, @pcalComplianceRatingForPat)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      long  vClientID  = Validate.reqClientID (uInfo, clientID);
      var  vSiteID     = Validate.optInteger (siteID, "invalid siteID");
    
      var vPcalComplianceRatingForPat = Validate.optInteger  (pcalComplianceRatingForPat, Messages.INVALID_RATING_CODE);
      
      var parms = new List<SqlParameter>();   

      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,    vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@siteID",    SqlDbType.BigInt,    vSiteID,      ParameterDirection.Input));
      
      parms.Add(Database.SqlParm("@pcalComplianceRatingForPat",  SqlDbType.TinyInt,   vPcalComplianceRatingForPat,  ParameterDirection.Input));
	  
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
                                              , string       pcalComplianceRatingForPat ) 
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
                                      , typeof(CdeComplianceBucketDetailsByPcalComplianceRatingAndPatient)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return CdeComplianceBucketDetailsByPcalComplianceRatingAndPatients.view(connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" /* Can edit */
                                                                       , active
                                                                       , clientID
                                                                       , siteID
                                                                       , pcalComplianceRatingForPat
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
                                           , string pcalComplianceRatingForPat )
        {
            ReturnDataTable so = new ReturnDataTable();

            /*###########################################################################
              # Define our display columns and set the page order.  Page order needs to
              # be in the same sort order as the udf called in the view.
              ###########################################################################*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
              
                ss.addDisplayColumn("patName   as [Student Last, First]", true);
                ss.addDisplayColumn("patSSID   as [SSID]");
                ss.addDisplayColumn("pcalComplianceRatingForPatName  as [Plan Implementation\nCompliance Range]");
                ss.addDisplayColumn("siteName  as [Site]");
                ss.addDisplayColumn("numSvcs   as [Number\nOf\nPromised\nServices]");
                ss.addDisplayColumn("iepCompliancePctForPat as [Plan\nImplementation\nCompliance]");
                ss.addDisplayColumn("hasCaseloadAssignmentsStr as [Has\nCaseload\nAssignments]");
                ss.addDisplayColumn("spEdCaseManagerName as [Case Manager]");
                ss.addDisplayColumn("spEdExitedSpEdDateStr as [Exited\nSpEd\nDate]");
                ss.addDisplayColumn("caseLoadAssignmentsSummaryText as [Caseload Assignments]");
                
                ss.addDisplayColumn("patID     as [SpEdCare\nPatID]");
                
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
                                          CdeComplianceBucketDetailsByPcalComplianceRatingAndPatients.view ( 
                                              connSpedmon
                                              , log
                                              , uInfo
                                              , Entities.REC_VIEW_TBL
                                              , paged
                                              , pageNumber
                                              , canEdit
                                              , active
                                              , clientID
                                              , siteID
                                              , pcalComplianceRatingForPat
                                              , dc );
                                  });

            /*###########################################################################
              # Add a title and footer to ReturnDataTable then return
              ###########################################################################*/

            so.tableName   = CdeComplianceBucketDetailsByPcalComplianceRatingAndPatients.SEL_LABEL_RPT;
            so.tableFooter = Messages.CONFIDENTIAL;

            return so;

        }
  
  }    
}
