using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{ 
  public class MissingServiceTreatmentForAPatient : Entity
  {
    public const string DEFAULT_PAGING_ORDER = @"patName asc, patID asc, startDate asc";

    public long     clientID;
    public string   clientName;
    public long     groupServiceClassNameID;
    public string   groupServiceClassNames;
    public long     patID;
    public string   patName;
    public DateTime patDOB;
    public string   patDOBStr;
    public string   patCSIS;
    public int      spEdServiceCode;
    public string   spEdServiceCodeStr;
    public string   spEdServiceName;
    public string   spEdServiceCodeName;
    public long     orpDocStandardSelectionNameID;
    public string   orpDocStandardSelectionName;
    public int      svcTrackingClass;
    public string   serviceOrOrderName;
    public string   spEdFreqName;
    public string   datesOfService;
    public int      numMinsExpected;
    public int      numMinsApplicable;
    public int      numMinsDiff;
    public decimal  estReimburse;
    public string   startDateStr;
    public string   endDateStr;
    public string   estReimburseStr;
    public Single   pctExpectedApplicable;
    public string   pctExpectedApplicableStr;

    public string    spEdCaseManagerName;
    public DateTime? spEdExitedSpEdDate;
    public string    spEdExitedSpEdDateStr;
   
    public int    spEdFreqCode;
    public int    minsPerFreq;
    public string planStartDateStr;         
	public string planEndDateStr;
	public string dosStartDateStr;
	public string dosEndDateStr;
    public int    numMinsMissing;
    public bool   deliveryExceptionsSupported;
  
  }  
 
  public class MissingServicesTreatmentsForAPatient : Entities
  {
    
    public const string SEL_LABEL_MANAGE   = MissingServicesTreatmentsCommon.SEL_LABEL + @" - For a Patient";
    public const string MENU_ID_MANAGE     = @"managemissingtreatmentservicesforapatientlink";
    public const string URL_MANAGE         = @"user_all_missing_services_treatment_for_a_patient_manage.aspx";

    public const string URL_REST_VIEW_BASE = @"api/v1/missingservicestreatmentsforapatient";

    public const int REF_SCREEN_MISSING_SVCS_DETAILS                  = 1;
    public const int REF_SCREEN_CASELOAD_GROUP                        = 2;
    public const int REF_PATIENTS_PROMISED_SERVICES_CDE_AUDIT_CURRENT = 3;
    public const int REF_PATIENTS_PROMISED_SERVICES_CDE_AUDIT         = 4;

    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW()
    { 
       return MBA.HttpApplication.createLink(MissingServicesTreatmentsForAPatient.URL_REST_VIEW_BASE, true);
    }

    /***************************************************************************
     * URL_PAGE_MANAGE_BASE */
    /**
     * 
     **************************************************************************/  
 
    public static string URL_PAGE_MANAGE_BASE ()
    { 
       return MBA.HttpApplication.createLink (  MissingServicesTreatmentsForAPatient.URL_MANAGE
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
                                 , string        orpDocID
                                 , string        svcTrackingClass
                                 , string        leaBopOnlyOrAllSped        
                                 , string        patID
                                 , string        startDate
                                 , string        endDate
                                 , defineCols    dc)
    { 
      

      var viewUDF = "dbo.RPT_MISSING_TREATMENTS_FOR_A_PATIENT (@userID, @userGroup, @userRank, @clientID, @patID, @groupSvcClassNameID, @spEdServiceCode, @orpDocID, @svcTrackingClass, @mcalPatients, @leaBopSvc, @missingTmt, @startDate, @endDate, @patAbsentMinsAreSatisfiedMins)"; 
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
          , orpDocID
          , svcTrackingClass
          , leaBopOnlyOrAllSped
          , ref parms);
       
      /*----------------------------
       * Validate and add additional
       * parms
       *----------------------------*/

      var vPatID     = Validate.optInteger (patID,      Messages.INVALID_PAT_ID);
      var vStartDate = Validate.optDate    (startDate,  Messages.INVALID_START_DATE);
      var vEndDate   = Validate.optDate    (endDate,    Messages.INVALID_END_DATE);

      bool vPatAbsentMinsAreSatisfiedMins = true;  /* TODO: If needed in the future continue passing this up the stack */

      parms.Add(Database.SqlParm("@patID",     SqlDbType.BigInt, vPatID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate", SqlDbType.Date,   vStartDate, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",   SqlDbType.Date,   vEndDate,   ParameterDirection.Input));
      
      parms.Add(Database.SqlParm("@patAbsentMinsAreSatisfiedMins", SqlDbType.Bit, vPatAbsentMinsAreSatisfiedMins, ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
        
      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
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
                                           , string orpDocID
                                           , string svcTrackingClass
                                           , string leaBopOnlyOrAllSped        
                                           , string patID
                                           , string startDate
                                           , string endDate )
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
              ss.addDisplayColumn("serviceOrOrderName       as [Service]");              
              ss.addDisplayColumn("spEdCaseManagerName      as [Case Manager]");
              ss.addDisplayColumn("startDateStr             as [Plan\nStart\nDate]");
              ss.addDisplayColumn("endDateStr               as [Plan\nEnd\nDate]");
              ss.addDisplayColumn("spEdExitedSpEdDateStr    as [Exited\nSpEd\nDate]");
              ss.addDisplayColumn("spEdFreqName             as [Promised\nFrequency Of\nDelivery]");
              ss.addDisplayColumn("datesOfService           as [Date(s)\nof Service]");
              ss.addDisplayColumn("numMinsExpected          as [Minutes\nExpected]");
              ss.addDisplayColumn("numMinsApplicable        as [Minutes\nSatisfied]");
              ss.addDisplayColumn("numMinsDiff              as [Minutes\nMissing]");
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
                      MissingServicesTreatmentsForAPatient.view (
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
                        , orpDocID
                        , svcTrackingClass
                        , leaBopOnlyOrAllSped
                        , patID
                        , startDate
                        , endDate
                        , dc);
                                  });

            /*###########################################################################
              # Add a title and footer to ReturnDataTable then return
              ###########################################################################*/

            so.tableName   = MissingServicesTreatmentsForAPatient.SEL_LABEL_MANAGE;
            so.tableFooter = Messages.CONFIDENTIAL;
            return so;
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
                                              , string       orpDocID
                                              , string       svcTrackingClass
                                              , string       leaBopOnlyOrAllSped        
                                              , string       patID
                                              , string       startDate
                                              , string       endDate )
 
    {
 
        /* Default page order */
 
        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = MissingServiceTreatmentForAPatient.DEFAULT_PAGING_ORDER;
 
        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */
 
        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };
 
        return Entities.viewObjects(connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(MissingServiceTreatmentForAPatient)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return MissingServicesTreatmentsForAPatient.view(connSpedmon
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
                                                                       , orpDocID
                                                                       , svcTrackingClass
                                                                       , leaBopOnlyOrAllSped
                                                                       , patID
                                                                       , startDate
                                                                       , endDate
                                                                       , dc);
                                      });
 
 
    }


  }
}