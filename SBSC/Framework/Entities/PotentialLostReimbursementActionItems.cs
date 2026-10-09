using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;


namespace Spedmon
{

  /***************************************************************************
   * PotentialLostReimbursementActionItemSelection */
  /**
   * Note: The enum name completely spelled out was TOOOO LONG for code
   * readability
   **************************************************************************/

  public enum PotLstRbrActItmSel
  {
      ServiceAuthorization                    = 10
    , RmtsParticipation                       = 15
    , ParentConsent                           = 20
    , PractitionerSupervision                 = 25
    , MissingAssessments                      = 30
    , MissingSpEdTreatments                   = 35
    , ReimbursementHistoryByDOSThisYear       = 40
    , ReimbursementHistoryByDOSLastYear       = 50
    , ReimbursementHistoryByCheckDateThisYear = 60
    , ReimbursementHistoryByCheckDateLastYear = 70
    , ReimbursementHistoryAnnGoalAmt          = 80
    , MissingOrders                           = 90
    , NPIorORPValidation                      = 100
    , Certification                           = 110
  }

  /***************************************************************************
   * PotentialLostReimbursementActionItem */
  /**
   *
   **************************************************************************/

  /***************************************************************************
   * PotentialLostReimbursementActionItems */
  /**
   ***************************************************************************/   
  
  public class PotentialLostReimbursementActionItems
  {
    public static long   DATA_SOURCE_DAILY_PLR_DATA                           = 1;
    public static long   DATA_SOURCE_MISSING_ASSMTS_DATA_ALL                  = 2;
    public static long   DATA_SOURCE_MISSING_ASSMTS_DATA_GROUP_FAMILY         = 3; // for future prac group leader role
    public static long   DATA_SOURCE_MISSING_ASSMTS_DATA_PRAC_CASELOAD_ONLY   = 4;
    public static long   DATA_SOURCE_PATIENT_MCAL_CONSENT_REPORT              = 5;
    public static long   DATA_SOURCE_CLAIMS_PAID_BY_DATE_REPORT_BY_DOS        = 6;
    public static long   DATA_SOURCE_CLAIMS_PAID_BY_DATE_REPORT_BY_CHECK_DATE = 7;
    public static long   DATA_SOURCE_CLIENTS_CLIENT_TABLE                     = 8;
    public static long   DATA_SOURCE_MISSING_SPED_TREATMENTS                  = 9;

    public static string URL_WEB_SVC_BASE                           = @"lea_bop_health.asmx.cs";
    public static string URL_WEB_SVC_AMTS_BY_DOS_FOR_THIS_YEAR_BASE = URL_WEB_SVC_BASE + @"/getreimbursementamtbydosforthisyear";

    public static string URL_WEB_SVC_AMTS_BY_DOS_FOR_THIS_YEAR() 
    {
       return MBA.HttpApplication.createLink(URL_WEB_SVC_AMTS_BY_DOS_FOR_THIS_YEAR_BASE, true);
    }

    /***************************************************************************
     * getTotalNumAmtObj */
    /**
     * 
     ***************************************************************************/

     private static TotalNumAmt getTotalNumAmtObj(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , string clientID
                                                , string repID
                                                , PotLstRbrActItmSel selection)
     {
         var objOut = new TotalNumAmt();

         long _dataSource = 0;
         string _holdCodes = null;
         DateTime refDate = DateTime.Now;

         string _label = @"";
         string _actionURL = @"";
         string _actionTabID = @"";
         bool   _isReportDownload = false;

         /* Identify source of data and any additional filtering specific to source */

         if (selection == PotLstRbrActItmSel.RmtsParticipation)
         {
             _dataSource = DATA_SOURCE_DAILY_PLR_DATA;
             _holdCodes = "910";
             _label = @"No RMTS Participation";
             _actionURL = PotentialLostReimbursements.URL_MANAGE_HOLDS_BASE();
             _actionTabID = @"400";
         }
         else if (selection == PotLstRbrActItmSel.PractitionerSupervision)
         {
             _dataSource  = DATA_SOURCE_DAILY_PLR_DATA;
             _holdCodes   = "920";
             _label       = @"Missing Supervision";
             _actionURL   = PotentialLostReimbursements.URL_MANAGE_HOLDS_BASE();
             _actionTabID = @"300";
         }
         else if (selection == PotLstRbrActItmSel.ServiceAuthorization)
         {
             _dataSource = DATA_SOURCE_DAILY_PLR_DATA;
             _holdCodes = "1200, 1300, 1400, 1500, 1600, 1700";
         }
         else if (selection == PotLstRbrActItmSel.MissingAssessments)
         {
             // role based filtering
             if (uInfo.pcalStaff || uInfo.userRoleID == Constants.ROLE_LEA_COORDINATOR_ID)
             {
                 _dataSource = DATA_SOURCE_MISSING_ASSMTS_DATA_ALL;
                 _holdCodes = "";
             }
             else if (uInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID)
             {
                 _dataSource = DATA_SOURCE_MISSING_ASSMTS_DATA_PRAC_CASELOAD_ONLY;
                 _holdCodes = "";
             }
             else
             {
                 _dataSource = DATA_SOURCE_MISSING_ASSMTS_DATA_ALL;
                 _holdCodes = "";
             }

             _label = @"Missing Assessments";

             if (String.IsNullOrEmpty(repID)) {
               _actionURL = Claims.URL_WEB_REPORT_BASE();
               _isReportDownload = true; 
             }
             else { 
               _actionURL = Claims.URL_SBS_ALL_RPT_MISSING_ASSESSMENTS_WITH_POT_REIMBURSEMENT_DETAILS_BASE();
             }

         }
         else if (selection == PotLstRbrActItmSel.MissingSpEdTreatments)
         {
             _dataSource = DATA_SOURCE_MISSING_SPED_TREATMENTS;
             _holdCodes = "";
         }
         else if (selection == PotLstRbrActItmSel.ParentConsent)
         {
             _dataSource  = DATA_SOURCE_PATIENT_MCAL_CONSENT_REPORT;
             _holdCodes   = "";
             _label       = @"No Medi-Cal Consent";
             _actionURL   = PatientParentMcalConsents.URL_USER_ALL_MANAGE_BASE();
             _actionTabID = @"2";
         }
         else if (selection == PotLstRbrActItmSel.ReimbursementHistoryByDOSThisYear)
         {
             _dataSource = DATA_SOURCE_CLAIMS_PAID_BY_DATE_REPORT_BY_DOS;
             _holdCodes  = "";
             refDate     = DateTime.Now;
         }
         else if (selection == PotLstRbrActItmSel.ReimbursementHistoryByDOSLastYear)
         {
             _dataSource = DATA_SOURCE_CLAIMS_PAID_BY_DATE_REPORT_BY_DOS;
             _holdCodes  = "";
             refDate     = DateTime.Now.AddYears(-1);
         }
         else if (selection == PotLstRbrActItmSel.ReimbursementHistoryByCheckDateThisYear)
         {
             _dataSource = DATA_SOURCE_CLAIMS_PAID_BY_DATE_REPORT_BY_CHECK_DATE;
             _holdCodes  = "";
             refDate     = DateTime.Now;
         }
         else if (selection == PotLstRbrActItmSel.ReimbursementHistoryByCheckDateLastYear)
         {
             _dataSource = DATA_SOURCE_CLAIMS_PAID_BY_DATE_REPORT_BY_CHECK_DATE;
             _holdCodes  = "";
             refDate     = DateTime.Now.AddYears(-1);
         }
         else if (selection == PotLstRbrActItmSel.ReimbursementHistoryAnnGoalAmt)
         {
             _dataSource = DATA_SOURCE_CLIENTS_CLIENT_TABLE;
             _holdCodes = "";
         }
         else if (selection == PotLstRbrActItmSel.MissingOrders)
         {
             _dataSource  = DATA_SOURCE_DAILY_PLR_DATA;
             _holdCodes   = "1300, 1400, 1500, 1510, 1520, 1530, 1540";
             _label       = @"Missing Orders";
             _actionURL   = PotentialLostReimbursements.URL_MANAGE_HOLDS_BASE();
             _actionTabID = @"100";
         }
         else if (selection == PotLstRbrActItmSel.NPIorORPValidation)
         {
             _dataSource  = DATA_SOURCE_DAILY_PLR_DATA;
             _holdCodes   = "1600, 1700";
             _label       = @"NPI or ORP Validation";
             _actionURL   = PotentialLostReimbursements.URL_MANAGE_HOLDS_BASE();
             _actionTabID = @"200";
         }
         else if (selection == PotLstRbrActItmSel.Certification)
         {
             _dataSource  = DATA_SOURCE_DAILY_PLR_DATA;
             _holdCodes   = "930";
             _label       = @"CPR or Other Certification";
             _actionURL   = PotentialLostReimbursements.URL_MANAGE_HOLDS_BASE();
             _actionTabID = @"500";
         }
         else
         {

         }

         /* Identify who is calling the view (from uInfo) and set the scope of records we are going to aggregate */

         Object vClientID               = Validate.optClientID(uInfo, clientID);
         Object vPracID                 = Validate.optPracID(uInfo, @"");
         Object vSvcGroupSvcClassNameID = Validate.optStdGroupSvcClassNameID(uInfo, @"");
         Object vRefDate                = Validate.optDate   (refDate.ToString(), Messages.INVALID_REF_DATE);
         var    vRepID                  = Validate.optInteger(repID             , Messages.INVALID_REP_ID);

         string sql = "select top 1 * from dbo.POTENTIAL_LOST_REIMBURSEMENT_ACTION_ITEM_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @repID, @groupSvcClassNameID, @refDate, @dataSource, @holdCodes)";

         var parms = new List<SqlParameter>();

         Entities.validateAndAddCommonUserInfoParameters(uInfo, ref parms);

         parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,  vClientID, ParameterDirection.Input));
         parms.Add(Database.SqlParm("@pracID",              SqlDbType.BigInt,  vPracID,   ParameterDirection.Input));
         parms.Add(Database.SqlParm("@repID",               SqlDbType.BigInt,  vRepID,    ParameterDirection.Input));
         parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt,  vSvcGroupSvcClassNameID, ParameterDirection.Input));
         parms.Add(Database.SqlParm("@dataSource",          SqlDbType.BigInt,  _dataSource, ParameterDirection.Input));
         parms.Add(Database.SqlParm("@holdCodes",           SqlDbType.VarChar, _holdCodes,  ParameterDirection.Input, -1));
         parms.Add(Database.SqlParm("@refDate",             SqlDbType.Date,    vRefDate,    ParameterDirection.Input));

         var rd = Database.execQuery(connSpedmon, log, sql, false, parms);

         if (rd.hasRecords)
         {
             objOut = (TotalNumAmt)Database.convertRecord(rd.records, typeof(TotalNumAmt));
             objOut.label = _label;
             objOut.actionURL = _actionURL;
             objOut.actionTabID = _actionTabID;
             objOut.isReportDownload = _isReportDownload;
         }

         return objOut;
     }
    
    /***************************************************************************
     * getTotalNumAmt */
    /**
     * Get total count and amount for given selection
     * 
     * @return ReturnTotalNumAmt
     ***************************************************************************/
    public static ReturnTotalNumAmt getTotalNumAmt ( SqlConnection connSpedmon
                                                     , DetailsLog log
                                                     , UserInfo uInfo
                                                     , PotLstRbrActItmSel selection )
    {
       return getTotalNumAmt(connSpedmon, log, uInfo, "", "", selection);
    }

    public static ReturnTotalNumAmt getTotalNumAmt (   SqlConnection connSpedmon
                                                     , DetailsLog log
                                                     , UserInfo uInfo
                                                     , string clientID
                                                     , string repID
                                                     , PotLstRbrActItmSel selection )
    {

       ReturnTotalNumAmt so = new ReturnTotalNumAmt();
       var objOut = getTotalNumAmtObj (  connSpedmon
                                       , log
                                       , uInfo
                                       , clientID
                                       , repID
                                       , selection );
      so.totalNumAmt = objOut;
      return so;  

     }

    /***************************************************************************
     * getTotalNumAmts */
    /**
     * 
     ***************************************************************************/

     public static ReturnTotalNumAmts getTotalNumAmts ( SqlConnection connSpedmon
                                                      , DetailsLog log
                                                      , UserInfo uInfo
                                                      , string clientID
                                                      , string repID )             
     {
       ReturnTotalNumAmts so = new ReturnTotalNumAmts();
       List<TotalNumAmt> amts = new List<TotalNumAmt>();
       amts.Add(getTotalNumAmtObj ( connSpedmon, log, uInfo, clientID, repID, PotLstRbrActItmSel.ParentConsent));
       amts.Add(getTotalNumAmtObj ( connSpedmon, log, uInfo, clientID, repID, PotLstRbrActItmSel.MissingOrders));
       amts.Add(getTotalNumAmtObj ( connSpedmon, log, uInfo, clientID, repID, PotLstRbrActItmSel.NPIorORPValidation));
       amts.Add(getTotalNumAmtObj ( connSpedmon, log, uInfo, clientID, repID, PotLstRbrActItmSel.PractitionerSupervision));
       amts.Add(getTotalNumAmtObj ( connSpedmon, log, uInfo, clientID, repID, PotLstRbrActItmSel.RmtsParticipation));
       amts.Add(getTotalNumAmtObj ( connSpedmon, log, uInfo, clientID, repID, PotLstRbrActItmSel.MissingAssessments));
       amts.Add(getTotalNumAmtObj ( connSpedmon, log, uInfo, clientID, repID, PotLstRbrActItmSel.Certification));

       so.totalNumAmts = amts.ToArray();
       return so;
     }

    /***************************************************************************
     * getClaimsPaid2P */
    /**
     * 
     ***************************************************************************/

     public static ReturnDB getClaimsPaid2P(SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , int recViewType
                                     , bool pagedOrTop
                                     , string idx
                                     , string canEdit
                                     , string active
                                     , string clientID
                                     , string repID
                                     , defineCols dc)
        {

         string viewUDF = "dbo.CLAIMS_PAID_CURR_AND_PREVIOUS_FY (@userID, @userGroup, @userRank, @clientID, @repID)";

         /*----------------------------
         * Validate parameters specific
         * to this entity.view
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/

         var vClientID = Validate.optClientID(uInfo, clientID);
         var vRepID    = Validate.optInteger (repID, Messages.INVALID_REP_ID);

         List<SqlParameter> parms = new List<SqlParameter>();

         parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
         parms.Add(Database.SqlParm("@repID"   , SqlDbType.BigInt, vRepID   , ParameterDirection.Input));

         /*----------------------------
          * Call base method which 
          * handles the rest and return
          * results
          *----------------------------*/

         return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

     }

     /*************************************************************************
      * getClaimsPaid2PList */
     /**
      * 
      * 
      ***************************************************************************/

      public static List<ClaimPaid2P> getClaimsPaid2PList( SqlConnection connSpedmon
                                                           , DetailsLog    log
                                                           , UserInfo      uInfo
                                                           , string        clientID
                                                           , string        repID
                                                           , string        active)
        
       {
          var recs = new List<ClaimPaid2P>();
          ReturnDB rd = PotentialLostReimbursementActionItems.getClaimsPaid2P(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, clientID, repID, null);       
          List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(ClaimPaid2P));
          foreach (var o in slo) {
              recs.Add((ClaimPaid2P) o);
          }
          return recs;
      }
      public static ReturnClaimsPaid2P getClaimsPaid2PAll( SqlConnection connSpedmon
                                                           , DetailsLog    log
                                                           , UserInfo      uInfo
                                                           , string        clientID
                                                           , string        repID
                                                           , string        active)
        
       {
          // get list of records
          List<ClaimPaid2P> recs = PotentialLostReimbursementActionItems.getClaimsPaid2PList(connSpedmon, log, uInfo, clientID, repID, active);
          
          ReturnClaimsPaid2P rd = new ReturnClaimsPaid2P();

          rd.claimsPaid2P = recs.ToArray();
          
          return rd;

      }

    }
}
