using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{    
 
  public class MissingServicesTreatmentDetail : Entity
  {
    public const string DEFAULT_PAGING_ORDER = @"patName asc";

    public long     clientID;
    public string   clientName;
    public long     patID;
    public string   patName;
    public DateTime patDOB;
    public string   patCSIS;
    public string   patDOBStr;
    public long     groupServiceClassNameID;
    public string   groupServiceClassNames;
    public int      spEdServiceCode;
    public string   spEdServiceCodeStr;
    public string   spEdServiceName;
    public string   spEdServiceCodeName;
    public long     orpDocStandardSelectionNameID;
    public string   orpDocStandardSelectionName;
    public long     orpDocID;
    public int      svcTrackingClass;
    public string   serviceOrOrderName;

    public int      totMinsExpected;
    public int      totMinsApplicable;
    public int      totMinsDiff;
    public Decimal  estReimburse;
    public string   startDateStr;
    public string   endDateStr;
    public string   estReimburseStr;
    public Single   pctExpectedApplicable;
    public string   pctExpectedApplicableStr;

    public string    spEdCaseManagerName;
    public DateTime? spEdExitedSpEdDate;
    public string    spEdExitedSpEdDateStr;
  
    public int      spEdFreqCode;
    public string   spEdFreqName;
    public int      minsPerFreq;
    public DateTime planStartDate;
    public DateTime planEndDate;
    public string   planStartDateStr;
    public string   planEndDateStr;

  }  
 
  public class MissingServicesTreatmentDetails : Entities
  {

    public const string SEL_LABEL_MANAGE              = MissingServicesTreatmentsCommon.SEL_LABEL              + @" - Details";
    public const string SEL_LABEL_MANAGE_IEP_IFSP     = MissingServicesTreatmentsCommon.SEL_LABEL_IEP_IFSP     + @" - Details";
    public const string SEL_LABEL_MANAGE_NON_IEP_IFSP = MissingServicesTreatmentsCommon.SEL_LABEL_NON_IEP_IFSP + @" - Details";

    public const string MENU_ID_MANAGE     = @"managemissingtreatmentservicesdetailslink";
    public const string URL_MANAGE         = @"user_all_missing_services_treatment_details_manage.aspx";
    public const string URL_REST_VIEW_BASE = @"api/v1/missingservicestreatmentsdetails";

    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW()
    { 
       return MBA.HttpApplication.createLink(MissingServicesTreatmentDetails.URL_REST_VIEW_BASE, true);
    }
    
    /***************************************************************************
     * URL_PAGE_MANAGE_BASE */
    /**
     * 
     **************************************************************************/  
 
    public static string URL_PAGE_MANAGE_BASE ()
    { 
       return MBA.HttpApplication.createLink ( MissingServicesTreatmentDetails.URL_MANAGE
                                              , true
                                              , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));
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
      

      var viewUDF = "dbo.RPT_MISSING_TREATMENTS_DETAILS (@userID, @userGroup, @userRank, @clientID, null, @groupSvcClassNameID, @spEdServiceCode, @mcalPatients, @leaBopSvc, @missingTmt, @svcTrackingClass)";
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
                                              , string       leaBopOnlyOrAllSped   )
 
    {
 
        /* Default page order */
 
        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = MissingServicesTreatmentDetail.DEFAULT_PAGING_ORDER;
 
        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */
 
        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };
 
        return Entities.viewObjects (   connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(MissingServicesTreatmentDetail)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return MissingServicesTreatmentDetails.view(connSpedmon
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
                                           , RequestResponse rd
                                           , bool   paged
                                           , string pageNumber
                                           , string canEdit
                                           , string active
                                           , string clientID
                                           , string groupServiceClassNameID
                                           , string spEdServiceCode
                                           , string svcTrackingClass
                                           , string leaBopOnlyOrAllSped  )
    {

            ReturnDataTable so = new ReturnDataTable();

            /*###########################################################################
              # Define our display columns and set the page order.  Page order needs to
              # be in the same sort order as the udf called in the view.
              ###########################################################################*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
              
              ss.addDisplayColumn("patName                  as [Patient]", true);
              ss.addDisplayColumn("patDOBStr                as [DOB]",     true);                    
              ss.addDisplayColumn("serviceOrOrderName       as [Service]", true);     
              ss.addDisplayColumn("spEdCaseManagerName      as [Case Manager]");
              ss.addDisplayColumn("startDateStr             as [Plan\nStart\nDate]");
              ss.addDisplayColumn("endDateStr               as [Plan\nEnd\nDate]");
              ss.addDisplayColumn("spEdExitedSpEdDateStr    as [Exited\nSpEd\nDate]");
              ss.addDisplayColumn("spEdFreqName             as [Frequency]");
              ss.addDisplayColumn("minsPerFreq              as [Minutes\nPer\nFrequency]");                
              ss.addDisplayColumn("totMinsExpected          as [Minutes\nExpected]");
              ss.addDisplayColumn("totMinsApplicable        as [Minutes\nSatisfied]");
              ss.addDisplayColumn("totMinsDiff              as [Minutes\nMissing]");
              ss.addDisplayColumn("pctExpectedApplicableStr as [Percentage\nSatisfied]");

              /* Only show potential lost reimbursement to certain roles for a given context */

              if (leaBopOnlyOrAllSped == Constants.SPED_LEA_BOP_ONLY)
              { 
                if (MissingServicesTreatmentsCommon.showPotentialLostReimburseAmountToUser(uInfo))
                {
                  ss.addDisplayColumn("estReimburseStr        as [Potential\nReimbursement]");
                }
                else 
                {
                  if (rd.wu.pr != null) {
                    if (rd.wu.pr.displayMoney) { 
                      ss.addDisplayColumn("estReimburseStr    as [Potential\nReimbursement]");
                    }
                  }
                }
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
                      MissingServicesTreatmentDetails.view (
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
              # Add a title and footer to ReturnDataTable then return
              ###########################################################################*/

            so.tableName   = MissingServicesTreatmentDetails.SEL_LABEL_MANAGE;
            so.tableFooter = Messages.CONFIDENTIAL;
            return so;
        }
  }
}