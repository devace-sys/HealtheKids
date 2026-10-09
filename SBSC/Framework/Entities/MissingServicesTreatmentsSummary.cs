using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{    
 
  public class MissingServicesTreatmentSummary
  {
    public const string DEFAULT_PAGING_ORDER = @"serviceOrOrderName asc";
    public string   id;
    public long     clientID;
    public string   clientName;
    public long     repID;
    public string   repName;
    public int      svcTrackingClass;
    public int      spEdServiceCode;
    public long     groupServiceClassNameID;
    public string   serviceOrOrderName;
    public int      totMinsExpected;
    public int      totMinsApplicable;
    public int      totMinsMissing;
    public Decimal  totEstReimburse;
    public string   startDateStr;
    public string   endDateStr;
    public DateTime startDate;
    public DateTime endDate;
    public string   totEstReimburseStr;
    public Single   pctExpectedApplicable;
    public string   pctExpectedApplicableStr;
    
  }  
 
  public class ReturnMissingServicesTreatmentsSummary : Return
  {
    public ReturnMissingServicesTreatmentsSummary ()            : base(){}
    public ReturnMissingServicesTreatmentsSummary (string msg)  : base(msg){}
    public ReturnMissingServicesTreatmentsSummary (Exception e) : base(e){}
    public ReturnMissingServicesTreatmentsSummary (Warning e)   : base(e){}
    public ReturnMissingServicesTreatmentsSummary (Critical e)  : base(e){}
    public ReturnMissingServicesTreatmentsSummary (SessionExpired e) : base(e){}
    
    public Decimal totEstReimburse    = 0m;
    public string  totEstReimburseStr = @"";
    public MissingServicesTreatmentSummary[] missingServicesTreatmentsSummary;
  }

  public class MissingServicesTreatmentsSummary: Entities
  {

    public const string SEL_LABEL_MANAGE   = MissingServicesTreatmentsCommon.SEL_LABEL + @" - Summary";
    public const string MENU_ID_MANAGE     = @"managemissingtreatmentservicessummarylink";
    public const string BODY_ID_MANAGE     = @"managemissingtreatmentservicessummary";
    public const string URL_MANAGE         = @"user_all_missing_services_treatment_summary_manage.aspx";
    public const string URL_REST_VIEW_BASE = @"api/v1/missingservicestreatmentssummary";

    public static string URL_WEB_SVC_BASE                                 = @"missing_services_treatment_summary.asmx";
    public static string URL_WEB_SVC_GET_MISSING_TREATMENTS_SUMMARY_BASE  = URL_WEB_SVC_BASE + @"/getmissingtmtssummary";
   
    
    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  
	 
    public static string URL_REST_VIEW()
    { 
       return MBA.HttpApplication.createLink(MissingServicesTreatmentsSummary.URL_REST_VIEW_BASE, true);
    }

    public static string URL_WEB_SVC_GET_MISSING_TREATMENTS_SUMMARY()
    { 
       return MBA.HttpApplication.createLink(MissingServicesTreatmentsSummary.URL_WEB_SVC_GET_MISSING_TREATMENTS_SUMMARY_BASE, true);
    }

    
        /***************************************************************************
         * view */
        /**
         * 
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
                                     , string        groupServiceClassNameID
                                     , string        spEdServiceCode
                                     , string        svcTrackingClass
                                     , string        leaBopOnlyOrAllSped                                       
                                     , defineCols    dc)
    { 
      
      var viewUDF = "dbo.RPT_MISSING_TREATMENTS_SUMMARY(@userID, @userGroup, @userRank, @clientID, null, @groupSvcClassNameID, @spEdServiceCode, @mcalPatients, @leaBopSvc, @missingTmt, @svcTrackingClass)";
      var parms   = new List<SqlParameter>();      

      /*----------------------------
       * Validate and add common
       * parms for this family
       * of views
       *----------------------------*/
                                                

      MissingServicesTreatmentsCommon.addAndSetCommonUdfParms(
            uInfo
          , clientID
          , groupServiceClassNameID
          , spEdServiceCode
          , ""
          , svcTrackingClass
          , leaBopOnlyOrAllSped
          , ref parms);

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
     * Returns a list of service record objects
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
                                              , string       groupServiceClassNameID
                                              , string       spEdServiceCode
                                              , string       svcTrackingClass
                                              , string       leaBopOnlyOrAllSped        
                                              , string       dateRange )
 
    {
 
        /* Default page order */
 
        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = MissingServicesTreatmentSummary.DEFAULT_PAGING_ORDER;
 
        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */
 
        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };
 
        return Entities.viewObjects(connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(MissingServicesTreatmentSummary)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return MissingServicesTreatmentsSummary.view(connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" /* Can edit */
                                                                       , active
                                                                       , clientID
                                                                       , groupServiceClassNameID
                                                                       , spEdServiceCode
                                                                       , svcTrackingClass
                                                                       , leaBopOnlyOrAllSped                                                                                                                                    
                                                                       , dc);
                                      });
 
 
    }

    /***************************************************************************
     * viewTbl 
     *
     * Returns data table for report export
     * 
     ***************************************************************************/

    public static ReturnDataTable viewTbl (  SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , bool   paged
                                           , string pageNumber
                                           , string canEdit
                                           , string active
                                           , string clientID
                                           , string groupServiceClassNameID
                                           , string spEdServiceCode
                                           , string svcTrackingClass
                                           , string leaBopOnlyOrAllSped )
        {

            ReturnDataTable so = new ReturnDataTable();

            /*###########################################################################
              # Define our display columns and set the page order.  Page order needs to
              # be in the same sort order as the udf called in the view.
              ###########################################################################*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
              ss.addDisplayColumn("serviceOrOrderName       as [Service]", true);
              ss.addDisplayColumn("startDateStr             as [From Date of Service]");
              ss.addDisplayColumn("endDateStr               as [To Date of Service]");
              ss.addDisplayColumn("totMinsExpected          as [Minutes\nExpected]");
              ss.addDisplayColumn("totMinsApplicable        as [Minutes\nSatisfied]");
              ss.addDisplayColumn("totMinsMissing           as [Minutes\nMissing]");

              /* Only show potential lost reimbursement to certain roles */
              if (MissingServicesTreatmentsCommon.showPotentialLostReimburseAmountToUser(uInfo))
              {
                 ss.addDisplayColumn("totEstReimburseStr     as [Potential\nReimbursement]");
              }
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
                      MissingServicesTreatmentsSummary.view (
                          connSpedmon
                        , log
                        , uInfo
                        , Entities.REC_VIEW_TBL
                        , paged
                        , pageNumber
                        , canEdit
                        , active
                        , clientID
                        , groupServiceClassNameID
                        , spEdServiceCode
                        , svcTrackingClass
                        , leaBopOnlyOrAllSped                        
                        , dc);
                                  });

            /*###########################################################################
              # Fetch client info
              ###########################################################################*/

            //var client = Clients.load(connSpedmon, log, uInfo, clientID);

            /*###########################################################################
              # Add a title and footer to ReturnDataTable then return
              ###########################################################################*/
            
            so.tableName   = MissingServicesTreatmentsSummary.SEL_LABEL_MANAGE;
            so.tableFooter = Messages.CONFIDENTIAL;
            return so;
        }

        /***************************************************************************
         * viewList 
         *
         * 
         * 
         ***************************************************************************/

        public static List<MissingServicesTreatmentSummary> viewList(SqlConnection connSpedmon
                                                           , DetailsLog log
                                                           , UserInfo uInfo
                                                           , string clientID                                                           
                                                           , string active )

        {
            var recs = new List<MissingServicesTreatmentSummary>();
            ReturnDB rd = MissingServicesTreatmentsSummary.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, clientID, null, null, null, null, null);
            List<Object> slo = Database.convertRecordsToList(ref rd.records, typeof(MissingServicesTreatmentSummary));
            foreach (var o in slo)
            {
                recs.Add((MissingServicesTreatmentSummary)o);
            }
            return recs;
        }
        
        /***************************************************************************
         * getMissingTmtsSummary
         *
         * 
         * 
         ***************************************************************************/
        public static ReturnMissingServicesTreatmentsSummary getMissingTmtsSummary(SqlConnection connSpedmon
                                                           , DetailsLog log
                                                           , UserInfo uInfo
                                                           , string clientID
                                                           , string active)

        {
            ReturnMissingServicesTreatmentsSummary rd = new ReturnMissingServicesTreatmentsSummary();
            List<MissingServicesTreatmentSummary> recs = MissingServicesTreatmentsSummary.viewList(connSpedmon, log, uInfo, clientID, active);
            rd.missingServicesTreatmentsSummary = recs.ToArray();
            
            /* Generate total */
            
            rd.totEstReimburse    = 0m;
            rd.totEstReimburseStr = @"";
            
            foreach (var missingServicesTreatmentSummary in rd.missingServicesTreatmentsSummary) {
              rd.totEstReimburse = rd.totEstReimburse + missingServicesTreatmentSummary.totEstReimburse;
            }
            rd.totEstReimburseStr = string.Format("{0:0,0}", rd.totEstReimburse);
            return rd;
        }
    }
}