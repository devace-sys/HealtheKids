using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * Claims */
  /**
   * LEA Claims
   ***************************************************************************/

  public class Claims:Entities
  {

    public const string SEL_LABEL                                                             = "Claims";
    
    public const string SEL_LABEL_RPT_POT_LOST_REIMBURSE                                      = "Potential Lost Reimbursement - Details (As of Last Transmission)";
    public const string URL_SBS_ALL_RPT_POT_LOST_REIMBURSE                                    = "sbs_all_rpt_pot_lost_reimburse.aspx";
    
    public const string SEL_LABEL_RPT_POT_LOST_REIMBURSE_OVERVIEW                             = "Potential Lost Reimbursement - Overview (As of Last Transmission)";
    public const string URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_OVERVIEW                           = "sbs_all_rpt_pot_lost_reimburse_overview.aspx";    
     
    public const string SEL_LABEL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS                          = "Potential Lost Reimbursement - ORP Details (As of Last Transmission)";
    public const string URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS                        = "sbs_all_rpt_pot_lost_reimburse_orp_details.aspx";
    
    public const string SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS                        = "Potential Lost Reimbursement - Details (Updated Daily)";
    public const string URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS                      = "sbs_all_rpt_pot_lost_reimburse_daily_details.aspx";

    public const string SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_OVERVIEW                       = "Potential Lost Reimbursement - Overview (Updated Daily)";
    public const string URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_DAILY_OVERVIEW                     = "sbs_all_rpt_pot_lost_reimburse_daily_overview.aspx";

    public const string SEL_LABEL_RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS           = "Missing Assessments Details (with potential reimbursement)";
    public const string URL_SBS_ALL_RPT_MISSING_ASSESSMENTS_WITH_POT_REIMBURSEMENT_DETAILS             = "sbs_all_rpt_missing_assessments_with_pot_reimbursement_details.aspx";
    public const string URL_CLIENT_LEA_COORD_RPT_MISSING_ASSESSMENTS_WITH_POT_REIMBURSEMENT_DETAILS    = "client_lea_coord_rpt_missing_assessments_detail.aspx";
        

    public const string SEL_LABEL_RPT_CLAIM_TRANSMISSION_SUMMARY                              = "Claims Transmitted";
    public const string URL_CLAIM_TRANSMISSION_SUMMARY_REPORT                                 = "rpt_claims_transmission_summary.aspx";

    public const string SEL_LABEL_RPT_CLAIMS_WAITING_FOR_NEXT_TRANSMISSION_SUMMARY            = "Claims Not Transmitted";
    public const string URL_CLAIMS_WAITING_FOR_NEXT_TRANSMISSION_SUMMARY_REPORT               = "rpt_claims_waiting_for_next_transmission_summary.aspx";

    public const string MENU_ID_RPT_POT_LOST_REIM_DAILY_OVERVIEW    = @"rptpotlostreimbursUpdatedeDailyOverviewlnk";
    public const string MENU_ID_RPT_POT_LOST_REIM_DAILY_DETAILS     = @"rptpotlostreimbursedailydetlnk";
    public const string MENU_ID_RPT_POT_LOST_REIM_OVERVIEW          = @"rptpotlostreimburseoverlnk";
    public const string MENU_ID_RPT_POT_LOST_REIM                   = @"rptpotlostreimburselnk";
    public const string MENU_ID_RPT_POT_LOST_REIM_ORP_DETAILS       = @"rptpotlostreimburseorpdetlnk";
    public const string MENU_ID_RPT_POT_LOST_REIM_MIS_ASSMT_DETAILS = @"rptmissingassessmentsdetailslnk";

    
    public const string MENU_ID_RPT_DENIALS_SUMMARY             = @"rptrecentdenialssummary";
    public const string MENU_ID_RPT_DENIALS_DETAILS             = @"rptrecentdenialsdetails";
    public const string SEL_LABEL_RECENT_DENIALS                = @"Claims Recent Denials";
    public const string SEL_LABEL_RPT_RECENT_DENIALS_SUMMARY    = SEL_LABEL_RECENT_DENIALS + @" - Summary (Updated Weekly)";
    public const string SEL_LABEL_RPT_RECENT_DENIALS_DETAILS    = SEL_LABEL_RECENT_DENIALS + @" - Details (Updated Weekly)";
    public const string URL_RPT_RECENT_DENIALS_SUMMARY          = "rpt_claims_recent_denials_summary.aspx";
    public const string URL_RPT_RECENT_DENIALS_DETAILS          = "rpt_claims_recent_denials_details.aspx";
    
    public const string URL_VIEW_REPORT                         = "claims.ashx";

    public static string URL_WEB_REPORT_BASE()
    { 
       return MBA.HttpApplication.createLink(Claims.URL_VIEW_REPORT, true);
    }

    public static string URL_SBS_ALL_RPT_MISSING_ASSESSMENTS_WITH_POT_REIMBURSEMENT_DETAILS_BASE()
    {
        return MBA.HttpApplication.createLink(Claims.URL_SBS_ALL_RPT_MISSING_ASSESSMENTS_WITH_POT_REIMBURSEMENT_DETAILS
                                            , true);
    }

        /***************************************************************************
         * viewTbl */
        /**
         * View claim records
         * 
         * @param  clientID        Client ID
         * @param  pracID          Practitioner ID
         * @param  patID           Patient ID
         * @param  dateRange       Date range
         * @return                 Claim records
         ***************************************************************************/

        public static ReturnDataTable viewTbl (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                           bool paged,
                                           string pageNumber,
                                           string clientID, string pracID, string patID, string dateRange, string canEdit, string active) 
    {
      
      ReturnDataTable dt = new ReturnDataTable();
      
      /*-------------------------------
       * Parse date range (DOS) into
       * start and end dates
       *----------------------------*/

      string startDate = "";
      string endDate   = "";
      Util.parseDateRange(dateRange, out startDate, out endDate);  

      /*----------------------------
       * Define our columns and
       * set the page order for 
       * paging
       *----------------------------*/
     
      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder,  ref List<SqlParameter> parms)
      {     
        ss.addDisplayColumn("id");
         
        ss.addDisplayColumnIfParmValueIsNull ("pracName as [Practitioner]", "@pracID", ref parms);
        ss.addDisplayColumnIfParmValueIsNull ("patName  as [Patient]",       "@patID",  ref parms);

        ss.addPageOrderColumnIfParmValueIsNull("[Practitioner]", "@pracID", ref parms);
        ss.addPageOrderColumnIfParmValueIsNull("[Patient]",      "@patID",  ref parms);
        
        ss.addDisplayColumn("dos                 as [DOS]",true);
        ss.addDisplayColumn("created             as [Created]");
        ss.addDisplayColumn("lastmodified        as [Modified]");
        ss.addDisplayColumn("procName            as [Proc Name]");
        ss.addDisplayColumn("procModComboStr     as [Proc Mod Combo]");
        ss.addDisplayColumn("units               as [Units]");
        ss.addDisplayColumn("patBIC              as [BIC]");         
        ss.addDisplayColumn("patElgFlag          as [Elg]");                 
        ss.addDisplayColumn("statusStr           as [Status]");
        ss.addDisplayColumn("comments            as [Comments]");
        ss.addDisplayColumn("svcRecID            as [Service Record ID]");
        ss.addDisplayColumn("id                  as [Claim ID]");
        ss.addDisplayColumn("clientID            as [Client ID]");
        ss.addDisplayColumn("pracID              as [Practitioner ID]");
        ss.addDisplayColumn("patID               as [Patient ID]");
        
        pageroworder = ss.pageRowOrder();
       
       };
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
     
      dt = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate{return Claims.view(connSpedmon,log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, clientID, pracID, patID, startDate, endDate, dc);});

      Client clt  = Clients.load(connSpedmon,log,uInfo,clientID);
      
      string tableName   = @"Claims - " + clt.name;
      string tableFooter = Messages.CONFIDENTIAL;
            
      if (!Util.IsNullOrEmpty (pracID) )
      {
        Practitioner prac = Practitioners.load ( connSpedmon, log, uInfo, pracID );
        tableName = tableName + " - " + prac.name;
      }
      
      if (!Util.IsNullOrEmpty (patID) )
      {
        Patient pat = Patients.load ( connSpedmon, log, uInfo, patID );
        tableName = tableName + " - " + pat.name;
      } 

      dt.tableName   = tableName;
      dt.tableFooter = tableFooter;

      return dt;
    }

    /***************************************************************************
     * view */
    /**
     * View claim records
     * 
     * @param  clientID        Client ID
     * @param  pracID          Practitioner ID
     * @param  patID           Patient ID
     * @param  startDate       Start date
     * @param  endDate         End date
     * @return                 Claim records
     ***************************************************************************/

     public static ReturnDB view (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                        int    recViewType,
                                        bool   pagedOrTop,
                                        string idx,
                                        string canEdit,
                                        string active,
                                        string clientID,
                                        string pracID, 
                                        string patID, 
                                        string startDate, 
                                        string endDate,
                                        defineCols dc) 
    {


      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

       List<SqlParameter> parms = new List<SqlParameter>();
        
       string  viewUDF    = "dbo.CLAIM_RECORDS_VIEW (null,null,null,@clientID,@pracID,@patID,@startDate,@endDate)";
    
       int       vClientID  = Validate.reqClientID (uInfo,     clientID);
       Object    vPracID    = Validate.optPracID   (uInfo,     pracID);
       Object    vPatID     = Validate.optInteger  (patID,     Messages.INVALID_PAT_ID);
       DateTime  vStartDate = Validate.reqDate     (startDate, Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
       DateTime  vEndDate   = Validate.reqDate     (endDate,   Messages.INVALID_END_DATE);

       parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,      vClientID,  ParameterDirection.Input));
       parms.Add(Database.SqlParm("@pracID",    SqlDbType.Int,      vPracID,    ParameterDirection.Input));
       parms.Add(Database.SqlParm("@patID",     SqlDbType.Int,      vPatID,     ParameterDirection.Input));
       parms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
       parms.Add(Database.SqlParm("@endDate",   SqlDbType.DateTime, vEndDate,   ParameterDirection.Input));

       /*----------------------------
        * Call base method which
        * handles the rest and return
        * results
        *----------------------------*/

       return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }

    /***************************************************************************
     * rptCRCsClaims */
    /**
     * 
     * @param  clientID        Client ID
     * @param  dateRange       Date range (start - end or start) 
     * @param  startDate       Start date
     * @param  endDate         End date
     * @param  procMod1        Procedure Modifier - 1
     * @param  procMod2        Procedure Modifier - 2
     * @param  procMod3        Procedure Modifier - 3
     * @return                 Claim records
     ***************************************************************************/

    public static ReturnDataTable rptCRCsClaims ( SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                 bool   paged,
                                                 string pageNumber,
                                                 string clientID,
                                                 string dateRange,
                                                 string procCode,
                                                 string procMod1,
                                                 string procMod2,
                                                 string procMod3,
                                                 string canEdit,
                                                 string active)
    {

        string viewUDF = "dbo.RPT_CRCS_Claims(@clientID,@startDate,@endDate,@procCode,@procMod1,@procMod2,@procMod3)";
            
        /*-------------------------------
         * Parse date range into start
         * and end dates
         *----------------------------*/

        string startDate = "";
        string endDate = "";
        Util.parseDateRange(dateRange, out startDate, out endDate);

        /*----------------------------
         * Validate parameters specific
         * to this entity.view
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/

        List<SqlParameter> prms = new List<SqlParameter>();

        int    vClientID  = Validate.reqClientID (uInfo, clientID);
        Object vStartDate = Validate.optDate     (startDate,    Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
        Object vEndDate   = Validate.optDate     (endDate,      Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NO_FUTURE);
        string vProcCode  = Validate.optString   (procCode,     Messages.INVALID_LNAME);
        string vProcMod1  = Validate.optString   (procMod1,     Messages.INVALID_LNAME);
        string vProcMod2  = Validate.optString   (procMod2,     Messages.INVALID_LNAME);
        string vProcMod3  = Validate.optString   (procMod3,     Messages.INVALID_LNAME);

        prms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,      vClientID,  ParameterDirection.Input));
        prms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
        prms.Add(Database.SqlParm("@endDate",   SqlDbType.DateTime, vEndDate,   ParameterDirection.Input));
        prms.Add(Database.SqlParm("@procCode",  SqlDbType.NVarChar, vProcCode,  ParameterDirection.Input));
        prms.Add(Database.SqlParm("@procMod1",  SqlDbType.NVarChar, vProcMod1,  ParameterDirection.Input));
        prms.Add(Database.SqlParm("@procMod2",  SqlDbType.NVarChar, vProcMod2,  ParameterDirection.Input));
        prms.Add(Database.SqlParm("@procMod3",  SqlDbType.NVarChar, vProcMod3,  ParameterDirection.Input)); 

        /*----------------------------
          * Define our columns and
          * set the page order for 
          * paging
          *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            ss.addDisplayColumn("PROC_CODE_MOD_COMBO as [Procedure Code & MODS]");           
            ss.addDisplayColumn("DOCUMENT_REFERENCE as [Document Reference]");
            ss.addDisplayColumn("AMOUNT_ALLOWED as [Amount Allowed (Paid)]");
            ss.addDisplayColumn("NUMBER_OF_UNITS as [Number Of Units]");
            ss.addDisplayColumn("[space space] as [---]");
            ss.addDisplayColumn("PATIENT");
            ss.addDisplayColumn("PRACTITIONER", true);
            ss.addDisplayColumn("PRACTITIONER_ID as [Practitioner ID]");
            ss.addDisplayColumn("GROUP_NAME as [Group Name]");
            ss.addDisplayColumn("CERTIFICATION_TYPE as [Certification Type]");
            ss.addDisplayColumn("SERVICE_DATE as [Service Date]");
            pageroworder = ss.pageRowOrder();
        };

        /*----------------------------
         * Load client record so we can
         * get the client name and add it
         * to the report title
         *----------------------------*/

        var clc = Clients.load(connSpedmon,log,uInfo,vClientID.ToString());
          
        /*----------------------------
         * Create report title
         *----------------------------*/

        string viewTitle = String.Format( @"{0} - {1}"
                                        , clc.name
                                        , CrcsCommon.SEL_LABEL_CLAIMS_REPORT);

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, active, viewUDF, prms, null, dc, viewTitle, Messages.CONFIDENTIAL);
    }   
    
    /***************************************************************************
     * rptPotentialLostReimbursement*/
    /**
     * 
     * @param  clientID        Client ID
     * @param  dateRange       Date range (start - end or start) 
     * @param  startDate       Start date
     * @param  endDate         End date
     * @return                 Claim records
     ***************************************************************************/

    public static ReturnDataTable rptPotentialLostReimbursement (   SqlConnection  connSpedmon
	                                                                , DetailsLog     log
	                                                                , UserInfo       uInfo
                                                                    , bool           paged
                                                                    , string         pageNumber
                                                                    , string         clientID
                                                                    , string         repID
                                                                    , string         canEdit
                                                                    , string         active )
    {

        string viewUDF = "dbo.RPT_POTENTIAL_LOST_REIMBURSEMENT (@clientID, @repID)";


        /*----------------------------
         * Validate parameters specific
         * to this entity.view
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/

        List<SqlParameter> prms = new List<SqlParameter>();

        Object  vClientID    = Validate.optClientID (uInfo, clientID);
        Object  vRepID       = Validate.optInteger  (repID, Messages.INVALID_REP_ID);
                
        prms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,   vClientID,  ParameterDirection.Input));
        prms.Add(Database.SqlParm("@repID",     SqlDbType.BigInt,   vRepID,     ParameterDirection.Input));

        /*----------------------------
          * Define our columns and
          * set the page order for 
          * paging
          *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          ss.addDisplayColumn("repName as [Rep Name]",   true);
          ss.addDisplayColumn("repEmail as [Rep Email]"); 
          ss.addDisplayColumn("clientName as [Client]");
          ss.addDisplayColumn("dosMonthYear as [Service\nMonth Year]");
          ss.addDisplayColumn("dosUseOrLose as [Claim(s)\nExpiring\nThis\nMonth]");          
          ss.addDisplayColumn("patName as [Patient]");
          ss.addDisplayColumn("patBIC  as [BIC]");
          ss.addDisplayColumn("groupName as [Discipline\nGroup]");
          ss.addDisplayColumn("pracName  as [Practitioner]");
          ss.addDisplayColumn("svcName   as [Service\nRendered]");
          ss.addDisplayColumn("numSvcs   as [Number\nof\nServices]");
          ss.addDisplayColumn("numMins   as [Total\nMinutes]");
          ss.addDisplayColumn("numTrips  as [Total\nTrips]");
          ss.addDisplayColumn("numMiles  as [Total\nMiles]");
          ss.addDisplayColumn("totReimburseEst  as [Total\nEstimated\nReimbursement]");
          ss.addDisplayColumn("lastTransmissionAttemptOn as [Last Transmission\nAttempt On]");
          ss.addDisplayColumn("holdReason as [Hold Reason]");

          pageroworder = ss.pageRowOrder();
        };

        ReturnDataTable rd = new ReturnDataTable();
                
        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewRpt(  connSpedmon
                                  , log
                                  , uInfo
                                  , paged
                                  , pageNumber
                                  , active
                                  , viewUDF
                                  , prms
                                  , null
                                  , dc
                                  , WebUI.CreatePageSubTitle ( 
                                                                 Claims.SEL_LABEL
	                                                             , Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE
                                                             )
	                                , Messages.CONFIDENTIAL);
    
    }   

    /***************************************************************************
     * rptPotentialLostReimbursementOverview */
    /**
     * 
     * @param  clientID        Client ID
     * @param  dateRange       Date range (start - end or start) 
     * @param  startDate       Start date
     * @param  endDate         End date
     * @return                 Claim records
     ***************************************************************************/

    public static ReturnDataTable rptPotentialLostReimbursementOverview (   SqlConnection  connSpedmon
	                                                                        , DetailsLog     log
	                                                                        , UserInfo       uInfo
                                                                          , bool           paged
                                                                          , string         pageNumber
                                                                          , string         clientID
                                                                          , string         repID
                                                                          , string         canEdit
                                                                          , string         active )
    {

        string viewUDF = "dbo.RPT_POTENTIAL_LOST_REIMBURSEMENT_OVERVIEW (@clientID, @repID)";


        /*----------------------------
         * Validate parameters specific
         * to this entity.view
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/

        List<SqlParameter> prms = new List<SqlParameter>();

        Object  vClientID    = Validate.optClientID (uInfo, clientID);
        Object  vRepID       = Validate.optInteger  (repID, Messages.INVALID_REP_ID);
                
        prms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,   vClientID,  ParameterDirection.Input));
        prms.Add(Database.SqlParm("@repID",     SqlDbType.BigInt,   vRepID,     ParameterDirection.Input));

        /*----------------------------
          * Define our columns and
          * set the page order for 
          * paging
          *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          ss.addDisplayColumn("repName as [Rep Name]",   true);
          ss.addDisplayColumn("repEmail as [Rep Email]"); 
          ss.addDisplayColumn("clientName as [Client]");
          ss.addDisplayColumn("estReimb  as [Total\nEstimated\nReimbursement]");
          ss.addDisplayColumn("numSvcs  as [Total\nNumber\nof Services]");
          ss.addDisplayColumn("holdReason as [Hold Reason]");

          pageroworder = ss.pageRowOrder();
        };

        ReturnDataTable rd = new ReturnDataTable();
                
        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewRpt(  connSpedmon
                                  , log
                                  , uInfo
                                  , paged
                                  , pageNumber
                                  , active
                                  , viewUDF
                                  , prms
                                  , null
                                  , dc
                                  , WebUI.CreatePageSubTitle ( 
                                                                 Claims.SEL_LABEL
	                                                             , Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE
                                                             )
	                                , Messages.CONFIDENTIAL);
    
    }   


    /***************************************************************************
     * rptPotentialLostReimbursementORPDetails */
    /**
     * 
     * @param  clientID        Client ID
     * @param  repID           Consultant ID
     * @return                 Details
     ***************************************************************************/

    public static ReturnDataTable rptPotentialLostReimbursementORPDetails (   SqlConnection  connSpedmon
	                                                                          , DetailsLog     log
	                                                                          , UserInfo       uInfo
                                                                            , bool           paged
                                                                            , string         pageNumber
                                                                            , string         clientID
                                                                            , string         repID
                                                                            , string         canEdit
                                                                            , string         active )
    {

        string viewUDF = "dbo.RPT_POTENTIAL_LOST_REIMBURSEMENT_MISSING_ORP_DETAIL (@clientID, @repID)";


        /*----------------------------
         * Validate parameters specific
         * to this entity.view
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/

        List<SqlParameter> prms = new List<SqlParameter>();

        Object  vClientID    = Validate.optClientID (uInfo, clientID);
        Object  vRepID       = Validate.optInteger  (repID, Messages.INVALID_REP_ID);
                
        prms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,   vClientID,  ParameterDirection.Input));
        prms.Add(Database.SqlParm("@repID",     SqlDbType.BigInt,   vRepID,     ParameterDirection.Input));

        /*----------------------------
          * Define our columns and
          * set the page order for 
          * paging
          *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          ss.addDisplayColumn("repName as [Rep Name]",   true);
          ss.addDisplayColumn("repEmail as [Rep Email]"); 
          ss.addDisplayColumn("clientName as [Client]");
	        ss.addDisplayColumn("patName as [Patient\nName]");
	        ss.addDisplayColumn("patID as [Patient\nID]");
	        ss.addDisplayColumn("patBIC as [Patient\nBIC]");
	        ss.addDisplayColumn("patCSIS as [Patient\nCSIS]");
	        ss.addDisplayColumn("patDOB as [Patient\nDOB]");
	        ss.addDisplayColumn("patActive as [Patient\nActive]");
          ss.addDisplayColumn("renderedBy as [Services\nRendered By]");
	        ss.addDisplayColumn("enteredUsing as [Services\nEntered\nUsing]");
	        ss.addDisplayColumn("numSvcs as [Services\nEntered]");
	        ss.addDisplayColumn("renderedBetween as [Services\nDates]");
	        ss.addDisplayColumn("totReimburseEst as [Total\nEstimated\nReimbursement]");	 
          ss.addDisplayColumn("canAutoMatchTheseSvcs as [Can\nAuto\nMatch]");
	        ss.addDisplayColumn("numPossibleAutoMatches as [Possible\nAuto\nMatches]");
	        ss.addDisplayColumn("recommendedAction  as [Recommended\nAction]");
          ss.addDisplayColumn("docsInSpEdCare as [ORP Documents in SpEdCare]");

          pageroworder = ss.pageRowOrder();
        };

        ReturnDataTable rd = new ReturnDataTable();
                
        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewRpt(  connSpedmon
                                  , log
                                  , uInfo
                                  , paged
                                  , pageNumber
                                  , active
                                  , viewUDF
                                  , prms
                                  , null
                                  , dc
                                  , WebUI.CreatePageSubTitle ( 
                                                                 Claims.SEL_LABEL
	                                                             , Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS
                                                             )
	                                , Messages.CONFIDENTIAL);
    
    }   

    /***************************************************************************
     * rptPotentialLostReimbursementDailyDetails */
    /**
     * 
     * @param  clientID        Client ID
     * @param  repID           Consultant ID
     * @return                 Details
     ***************************************************************************/

    public static ReturnDataTable rptPotentialLostReimbursementDailyDetails ( SqlConnection  connSpedmon
	                                                                          , DetailsLog     log
	                                                                          , UserInfo       uInfo
                                                                            , bool           paged
                                                                            , string         pageNumber
                                                                            , string         clientID
                                                                            , string         repID
                                                                            , string         canEdit
                                                                            , string         active )
    {

        string viewUDF = "dbo.RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT (@clientID)";


        /*----------------------------
         * Validate parameters specific
         * to this entity.view
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/

        List<SqlParameter> prms = new List<SqlParameter>();

        long  vClientID    = Validate.reqClientID (uInfo, clientID);                
        prms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,   vClientID,  ParameterDirection.Input));

        /*----------------------------
          * Define our columns and
          * set the page order for 
          * paging
          *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          ss.addDisplayColumn("REP_NAME as [Rep Name]",   true);
          ss.addDisplayColumn("REP_EMAIL as [Rep Email]"); 
          ss.addDisplayColumn("CLIENT_NAME as [Client]");
          ss.addDisplayColumn("SVC_DOS_MONTH_YEAR as [Service\nMonth Year]");
          ss.addDisplayColumn("SVC_DOS_USE_OR_LOSE as [Claim(s)\nExpiring\nThis\nMonth]");          
          ss.addDisplayColumn("PAT_NAME as [Patient]");
          ss.addDisplayColumn("PAT_CSIS as [CSIS]");
          ss.addDisplayColumn("PAT_BIC  as [BIC]");
          ss.addDisplayColumn("PAT_DOB  as [DOB]");
          ss.addDisplayColumn("PRAC_GROUP_FAMILY_NAME as [Practitioner\nGroup\nFamily]");
          ss.addDisplayColumn("PRAC_NAME  as [Practitioner]");
          ss.addDisplayColumn("PRAC_GROUP_NAME as [Discipline\nGroup]");
          ss.addDisplayColumn("SVC_TYPE_NAME   as [Service\nType]");
          ss.addDisplayColumn("CURRENT_HOLD_REASON   as [Hold\nReason]");
          ss.addDisplayColumn("RECOMMENDED_ACTION   as [Recommended\nAction]");
          ss.addDisplayColumn("ADDITIONAL_INFORMATION   as [Additional\nInformation]");
          ss.addDisplayColumn("NUM_CLAIMS   as [Number\nof\nClaims]");
          ss.addDisplayColumn("TOT_EST_AMT  as [Total\nEstimated\nReimbursement]");
          ss.addDisplayColumn("LAST_UPDATED as [Last\nUpdated\nOn]");
          pageroworder = ss.pageRowOrder();
        };

        ReturnDataTable rd = new ReturnDataTable();
                
        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewRpt(  connSpedmon
                                  , log
                                  , uInfo
                                  , paged
                                  , pageNumber
                                  , active
                                  , viewUDF
                                  , prms
                                  , null
                                  , dc
                                  , WebUI.CreatePageSubTitle ( 
                                                                 Claims.SEL_LABEL
	                                                             , Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS 
                                                             )
	                                , Messages.CONFIDENTIAL);
    
    }


        /***************************************************************************
         * rptPotentialLostReimbursementUpdatedDailyOverview */
        /**
         * 
         * @param  clientID        Client ID
         * @param   repID          ID of the consultant who has been assigned that client.
         * @return                 Table of report rows       
         ***************************************************************************/

        public static ReturnDataTable rptPotentialLostReimbursementUpdatedDailyOverview(SqlConnection connSpedmon
                                                                                , DetailsLog log
                                                                                , UserInfo uInfo
                                                                              , bool paged
                                                                              , string pageNumber
                                                                              , string clientID
                                                                              , string repID
                                                                              , string canEdit
                                                                              , string active)
        {

            string viewUDF = "RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW (@clientID, @repID)";


            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> prms = new List<SqlParameter>();

            Object vClientID = Validate.optClientID(uInfo, clientID);
            Object vRepID = Validate.optInteger(repID, Messages.INVALID_REP_ID);

            prms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@repID", SqlDbType.BigInt, vRepID, ParameterDirection.Input));

            /*----------------------------
              * Define our columns and
              * set the page order for 
              * paging
              *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("REP_NAME as [Rep Name]", true);
                ss.addDisplayColumn("REP_EMAIL as [Rep Email]");
                ss.addDisplayColumn("CLIENT_NAME as [Client]",true);
                ss.addDisplayColumn("hold_Reason as [Hold Reason]");
                /*ss.addDisplayColumn("recAction as [Recommended Action]");*/
                ss.addDisplayColumn("numClaims  as [Total\nNumber\nof Claims]");
                ss.addDisplayColumn("estReimb  as [Total\nEstimated\nReimbursement]");
               

                pageroworder = ss.pageRowOrder();
            };

            ReturnDataTable rd = new ReturnDataTable();

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewRpt(connSpedmon
                                      , log
                                      , uInfo
                                      , paged
                                      , pageNumber
                                      , active
                                      , viewUDF
                                      , prms
                                      , null
                                      , dc
                                      , WebUI.CreatePageSubTitle(
                                                                     Claims.SEL_LABEL
                                                                     , Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_OVERVIEW
                                                                 )
                                        , Messages.CONFIDENTIAL);

        }


        public static string computeDefaultDateRangeForRptClaimsTransmissionSummary()
        {
          return Util.calculatePrevOrCurrWeekDateRangeStr(DayOfWeek.Thursday);
        }




        /***************************************************************************
         * rptMissingAssessmentsWithPotReimbursementDetails */
        /**
         * 
         * @param  clientID        Client ID
         * @param  repID           Consultant ID
         * @return                 Details
         ***************************************************************************/

        public static ReturnDataTable rptMissingAssessmentsWithPotReimbursementDetails(SqlConnection connSpedmon
                                                                                  , DetailsLog log
                                                                                  , UserInfo uInfo
                                                                                  , bool paged
                                                                                  , string pageNumber
                                                                                  , string clientID
                                                                                  , string repID
                                                                                  , string canEdit
                                                                                  , string active)
        {

            string viewUDF = "dbo.RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS(@userID,@userGroup,@userRank,@clientID,@repID)";
                                                                                             

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> prms = new List<SqlParameter>();

            object vClientID = Validate.optClientID (uInfo,clientID);
            object vRepID    = Validate.optInteger(repID, Messages.INVALID_REP_ID);

            prms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID,    ParameterDirection.Input));           
            prms.Add(Database.SqlParm("@repID",    SqlDbType.BigInt, vRepID,       ParameterDirection.Input));

            /*----------------------------
             * Define our columns and
             * set the page order for 
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
                {
                  ss.addDisplayColumn("Client as [Client]", true);
                  ss.addDisplayColumn("Rep as [Rep]",       true);
                }

                ss.addDisplayColumn("Patient as [Patient\nName]", true);
                ss.addDisplayColumn("CurrentSite as [Current\nSite]");
                ss.addDisplayColumn("DOB as [DOB]");
                ss.addDisplayColumn("Active as [Active]");
                ss.addDisplayColumn("PractitionerGrouping  as [Practitioner\nGrouping]");
                ss.addDisplayColumn("[Number Of Treatments] as [Number Of\nTreatments]");
                ss.addDisplayColumn("[Potential Reimbursement] as [Potential\nReimbursement]");
                ss.addDisplayColumn("[LastAssmtDetails] as [Last IEP/IFSP Assessment Details]");
                ss.addDisplayColumn("[PlanTypes] as [Plan Type]");
                ss.addDisplayColumn("[PracNames] as [Caseload Practitioner]");
                pageroworder = ss.pageRowOrder();
            };

            ReturnDataTable rd = new ReturnDataTable();

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewRpt(connSpedmon
                                      , log
                                      , uInfo
                                      , paged
                                      , pageNumber
                                      , active
                                      , viewUDF
                                      , prms
                                      , null
                                      , dc
                                      , WebUI.CreatePageSubTitle(
                                                                     Claims.SEL_LABEL
                                                                     , Claims.SEL_LABEL_RPT_MISSING_ASSESSMENTS_POT_REIMBURSEMENT_DETAILS
                                                                 )
                                        , Messages.CONFIDENTIAL);

        }


        /***************************************************************************
         * rptClaimsTransmissionSummary */
        /**
         
         * @param   client ID             filter by Client ID to get one client or all Clients.
         * @param   repID                 filter by Practical Consultant ID to get one or all Consultants,
         * @param   startDate             filter by Start Date.
         * @param   endDate               filter by End Date.
         * @return                        Table of report rows with Claim Records.
         ***************************************************************************/

        public static ReturnDataTable rptClaimsTransmissionSummary(SqlConnection connSpedmon
                                                                              , DetailsLog log
                                                                              , UserInfo uInfo
                                                                              , bool paged
                                                                              , string pageNumber
                                                                              , string clientID
                                                                              , string repID
                                                                              , string dateRange
                                                                              , string canEdit
                                                                              , string active)
        {

            string viewUDF = "dbo.RPT_Claims_Transmissions_Summary (@clientID, @repID, @startDate, @endDate)";


            /*-------------------------------
             * Use default date range for
             * this particular report if
             * date range is not supplied 
             * and parse date range into
             * start and end dates
             *----------------------------*/

           if (Util.IsNullOrEmpty(dateRange)) dateRange = computeDefaultDateRangeForRptClaimsTransmissionSummary();

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

            List<SqlParameter> prms = new List<SqlParameter>();

            Object   vClientID  = Validate.optClientID(uInfo, clientID);
            Object   vRepID     = Validate.optInteger(repID,  Messages.INVALID_REP_ID);
            DateTime vStartDate = Validate.reqDate(startDate, Messages.INVALID_START_DATE);
            DateTime vEndDate   = Validate.reqDate(endDate,   Messages.INVALID_END_DATE);


            prms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,   vClientID,  ParameterDirection.Input));
            prms.Add(Database.SqlParm("@repID",     SqlDbType.BigInt,   vRepID,     ParameterDirection.Input));
            prms.Add(Database.SqlParm("@startDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@endDate",   SqlDbType.DateTime, vEndDate,   ParameterDirection.Input));

            /*----------------------------
              * Define our columns and
              * set the page order for 
              * paging
              *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("DatesTransmitted  as [Transmission\nDate]");
                ss.addDisplayColumn("CLIENT_NAME as [Client Name]", true);
                ss.addDisplayColumn("REP_NAME    as [Consultant]");
                ss.addDisplayColumn("FilesTransmitted   as [File Name]");
                ss.addDisplayColumn("TotalClaimsSubmitted  as [# Claims]");
                ss.addDisplayColumn("TotalServiceUnits  as [# Units]");
                ss.addDisplayColumn("TotalAmountSubmitted as [Amount]");
                ss.addDisplayColumn("WhenToInvoice as [When To\nInvoice]");
                ss.addDisplayColumn("InvoiceRate as [Invoice\nRate]");
                ss.addDisplayColumn("RevenueSharingCategoryLEA as [Revenue\nSharing\nCategory]");
                ss.addDisplayColumn("start_date as [Start Date]");
                ss.addDisplayColumn("end_date as [End Date]");
                pageroworder = ss.pageRowOrder();
            };

            //ReturnDataTable rd = new ReturnDataTable();

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/


            ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, 
                paged, pageNumber, null, viewUDF, prms, null, dc);


            rd.tableName = DateTime.Today.ToYYYYMMDDString()
                           + " "
                           + SEL_LABEL_RPT_CLAIM_TRANSMISSION_SUMMARY;

            rd.tableFooter = Messages.CONFIDENTIAL;
            rd.useTemplates = true;
            rd.excelTemplate = new ExcelFileTempateInfo();


            rd.excelTemplate.useTemplate = true;
            rd.excelTemplate.templateFileName = @"ClaimsTransmissionSummary.xls";
            rd.excelTemplate.sheetNum = 0;
            rd.excelTemplate.setDataCellRegion(6, 900, @"A", @"L");
            rd.excelTemplate.forceFormulaRecalculate = true;
            rd.excelTemplate.collapseRowGroups = false;
            rd.excelTemplate.collapseColGroups = false;

            return rd;
        }

        /***************************************************************************
         * rptClaimsWaitingForNextTransmissionSummary */
        /**
         * @param   client ID             filter by Client ID to get one client or all Clients.
         * @param   repID                 filter by Practical Consultant ID to get one or all Consultants,
         * @return                        Table of report rows
         * @return                        Claim records
         ***************************************************************************/
        public static ReturnDataTable rptClaimsWaitingForNextTransmissionSummary (  SqlConnection connSpedmon
                                                                                  , DetailsLog log
                                                                                  , UserInfo uInfo
                                                                                  , bool paged
                                                                                  , string pageNumber
                                                                                  , string canEdit
                                                                                  , string active)
        {

            string viewUDF = "dbo.RPT_Claims_Waiting_For_Next_Transmission_Summary ()";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> prms = new List<SqlParameter>();

            /*----------------------------
              * Define our columns and
              * set the page order for 
              * paging
              *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("AS_OF_DATE  as [As Of\nDate]", true);
                ss.addDisplayColumn("CLIENT_NAME as [Client Name]", true);
                ss.addDisplayColumn("REP_NAME    as [Consultant]",  true);
                ss.addDisplayColumn("NUM_CLAIMS  as [# Claims]");
                ss.addDisplayColumn("TOTAL_AMT   as [Amount]");
                pageroworder = ss.pageRowOrder();
            };


            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/


            ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, viewUDF, prms, null, dc);

            rd.tableName = DateTime.Today.ToYYYYMMDDString()
                           + " "
                           + SEL_LABEL_RPT_CLAIMS_WAITING_FOR_NEXT_TRANSMISSION_SUMMARY;

            rd.tableFooter = Messages.CONFIDENTIAL;
            return rd;
        }

        /***************************************************************************
         * rptClaimsRecentDenialsSummary */
        /**
         * 
         * @return  ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable rptClaimsRecentDenialsSummary ( SqlConnection connSpedmon
                                                                     , DetailsLog   log
                                                                     , UserInfo     uInfo
                                                                     , bool         paged
                                                                     , string       pageNumber
                                                                     , string       canEdit
                                                                     , string       active )
        {

            string viewUDF = "dbo.RPT_CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_SUMMARY ()";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> prms = new List<SqlParameter>();

            /*----------------------------
             * Define our columns and
             * set the page order for 
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

                ss.addDisplayColumn("REASON as [Denial Reason]", true);
                ss.addDisplayColumn("W1_TO_W8_DATES as [W1 - W8\nCheck Dates]");
                ss.addDisplayColumn("W1_TO_W8_SUM   as [W1 - W8\nSum]");
                ss.addDisplayColumn("W1_TO_W8_AVG   as [W1 - W8\nAverage\n(Rounded)]");
                ss.addDisplayColumn("W1_TO_W8_STDEV as [W1 - W8\nStandard\nDeviation\n(Rounded)]");

                ss.addDisplayColumn("W1 as [W1\n(Latest)]");
                ss.addDisplayColumn("W2");
                ss.addDisplayColumn("W3");
                ss.addDisplayColumn("W4");

                ss.addDisplayColumn("W5");
                ss.addDisplayColumn("W6");
                ss.addDisplayColumn("W7");
                ss.addDisplayColumn("W8");

                pageroworder = ss.pageRowOrder();
            };

            ReturnDataTable rd = new ReturnDataTable();

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            rd = Entities.viewRpt(connSpedmon
                                      , log
                                      , uInfo
                                      , paged
                                      , pageNumber
                                      , active
                                      , viewUDF
                                      , prms
                                      , null
                                      , dc
                                      , Claims.SEL_LABEL_RPT_RECENT_DENIALS_SUMMARY
                                      , Messages.CONFIDENTIAL);

            return rd;
        }


        /***************************************************************************
         * rptClaimsRecentDenialsDetails */
        /**
         * 
         * @return  ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable rptClaimsRecentDenialsDetails (  SqlConnection connSpedmon
                                                                     , DetailsLog log
                                                                     , UserInfo uInfo
                                                                     , bool paged
                                                                     , string pageNumber
                                                                     , string canEdit
                                                                     , string active)
        {

            string viewUDF = "dbo.RPT_CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DETAILS ()";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> prms = new List<SqlParameter>();

            /*----------------------------
             * Define our columns and
             * set the page order for 
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

                ss.addDisplayColumn("REASON as [Denial Reason]"                              , true);
                ss.addDisplayColumn("CLAIM_AGES_OUT_IN_DAYS as [Claim\nAges\nOut\nIn\nDays]" , true);
                ss.addDisplayColumn("CLAIM_ID as [Claim ID]"                                 , true);
                ss.addDisplayColumn("W as [W]"                                               , true);
                ss.addDisplayColumn("dbo.RPT_DATE_FMT(W_DATE) as [Check\nDate]"              , true);
                ss.addDisplayColumn("CCN as [CCN]"                                           , true);

                ss.addDisplayColumn("CURRENT_CLAIM_STATUS as [Current\nStatus]");
                ss.addDisplayColumn("PATIENT as [Patient]");
                ss.addDisplayColumn("[DOB]");
                ss.addDisplayColumn("BIC");
                ss.addDisplayColumn("PATIENT_ELIGIBLE as [Eligible\nFor\nDOS]");
                ss.addDisplayColumn("[DOS]");

                ss.addDisplayColumn("[SERVICE_RENDERED] as [Service\nRendered]");
                ss.addDisplayColumn("PROC_MOD_COMBO as [Procedure\nCode\nModifiers]");
                ss.addDisplayColumn("SERVICE_UNITS  as [Units]");

                ss.addDisplayColumn("[RENDERED_BY_A] as [Service\nRendered By]");
                ss.addDisplayColumn("Client");

                
                pageroworder = ss.pageRowOrder();
            };

            ReturnDataTable rd = new ReturnDataTable();

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            rd = Entities.viewRpt(connSpedmon
                                      , log
                                      , uInfo
                                      , paged
                                      , pageNumber
                                      , active
                                      , viewUDF
                                      , prms
                                      , null
                                      , dc
                                      , Claims.SEL_LABEL_RPT_RECENT_DENIALS_DETAILS                                        
                                      , Messages.CONFIDENTIAL);

        
            return rd;
        }

    }
}

