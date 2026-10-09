using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;


namespace Spedmon
{   
  

  /***************************************************************************
   * RmtsParticipantSelection */
  /**
   * 
   **************************************************************************/

  public class RmtsParticipantSelection 
  {
    public long   id;
    public string name;
    public string title;
    public string submitClaimsStr;
  }
  

  /***************************************************************************
   * RmtsParticipantsSelectionChange */
  /**
   * 
   **************************************************************************/
  public class RmtsParticipantSelectionChange : RmtsParticipantSelection 
  {
    public string effectiveDateStr;
  }

  /***************************************************************************
   * RmtsParticipationRoster */
  /**
   * 
   *
   * 
   **************************************************************************/
  public class RmtsParticipationRoster : Entity
  {    
    public const string DEFAULT_PAGING_ORDER = "quarterName asc";

    public long     clientID;
    public string   clientName;
    public long     quarterID;
    public string   quarterName;

    //public long     FY_ID;
    //public int      quarterNum;
    //now being pulled in the view UDF; can uncomment this later,
    //but right now we don't need to implement any changes in middleware

    public string   quarterStartDateStr;
    public string   quarterEndDateStr;
    public string   quarterStartDateStrYMD;
    public string   quarterEndDateStrYMD;
    public string   participantsJSON;
    public bool     quarterIsInPast   = false;
    public bool     quarterIsCurrent  = false;
    public bool     quarterIsInFuture = false;

    public int      numParticipants;

    public long fyID;
  }

  public class ReturnRmtsParticipationRoster : Return
  {
      public ReturnRmtsParticipationRoster() : base() { }
      public ReturnRmtsParticipationRoster(string msg) : base(msg) { }
      public ReturnRmtsParticipationRoster(Exception e) : base(e) { }
      public ReturnRmtsParticipationRoster(Warning e) : base(e) { }
      public ReturnRmtsParticipationRoster(Critical e) : base(e) { }
      public ReturnRmtsParticipationRoster(SessionExpired e) : base(e) { }
      public bool hasRecord = false;
      public RmtsParticipationRoster roster;
  }
  
  public class ReturnRmtsParticipationRosterHistHtml : Return
  {
      public ReturnRmtsParticipationRosterHistHtml() : base() { }
      public ReturnRmtsParticipationRosterHistHtml(string msg) : base(msg) { }
      public ReturnRmtsParticipationRosterHistHtml(Exception e) : base(e) { }
      public ReturnRmtsParticipationRosterHistHtml(Warning e) : base(e) { }
      public ReturnRmtsParticipationRosterHistHtml(Critical e) : base(e) { }
      public ReturnRmtsParticipationRosterHistHtml(SessionExpired e) : base(e) { }
      public bool hasRecord = false;
      public string htmlText;
  }
  
  /***************************************************************************
   * RmtsParticipationRosters */
  /**
   * 
   *
   * 
   **************************************************************************/
  public class RmtsParticipationRosters:Entities
  {            
      public const string SEL_LABEL               = @"RMTS Participation Rosters";
      public const string SEL_LABEL_MANAGE        = SEL_LABEL;
      public const string SEL_LABEL_ADD_NEW       = @"Add New";
      public const string SEL_LABEL_EDIT          = @"Edit";
      public const string MENU_LINK_MANAGE        = @"rmtsparticipationrostermanagelink";
      public const string URL_MANAGE              = @"user_all_rmts_participation_roster_manage.aspx";
      public static string VAL_FILE_NAMESPACE     = @"rmts_supporting_docs";
      public static string VAL_FILE_SOURCE        = @"rmts_supporting_docs";
      public const string  URL_REST_VIEW          = @"api/v1/rmtsparticipantrosters";
      public const string  URL_ASHX               = @"rmts_participant_roster_quarter.ashx";

      public const string  URL_ASMX               = @"rmts_participant_rosters.asmx";

      public const string  URL_LOAD_BY_QUARTER    = URL_ASMX + @"/loadByQuarter";
      public const string  URL_SAVE               = URL_ASMX + @"/save";
      public const string  URL_GET_INIT_DATA      = URL_ASMX + @"/getInitialData";
      public const string  URL_LOAD               = URL_ASMX + @"/loadRoster";
      public const string  URL_VIEW_HTML_HIST_TBL = URL_ASMX + @"/viewHTMLTblModHist";

      public const string URL_GET_QUARTER_ID      = @"company_fiscal_years.asmx/getQuarterID";

      

      public static string URL_MANAGE_BASE()
      {
          return MBA.HttpApplication.createLink(RmtsParticipationRosters.URL_MANAGE, true);
      }


      public static string URL_REST_VIEW_BASE()
      {
          return MBA.HttpApplication.createLink(RmtsParticipationRosters.URL_REST_VIEW, true);
      }        
        
      public static string URL_ASHX_BASE()
      {
          return MBA.HttpApplication.createLink(RmtsParticipationRosters.URL_ASHX, true);
      }        
        
      public static string URL_SAVE_BASE()
      {
            return MBA.HttpApplication.createLink(RmtsParticipationRosters.URL_SAVE, true);
      }
        
      public static string URL_LOAD_BY_QUARTER_BASE()
      {
            return MBA.HttpApplication.createLink(RmtsParticipationRosters.URL_LOAD_BY_QUARTER, true);
      }

      public static string URL_GET_QUARTER_ID_BASE()
      {
            return MBA.HttpApplication.createLink(RmtsParticipationRosters.URL_GET_QUARTER_ID, true);
      }
        
      public static string URL_LOAD_BASE()
      {
            return MBA.HttpApplication.createLink(RmtsParticipationRosters.URL_LOAD, true);
      }
        
      public static string URL_GET_INIT_DATA_BASE()
      {
            return MBA.HttpApplication.createLink(RmtsParticipationRosters.URL_GET_INIT_DATA, true);
      }
        
      public static string URL_VIEW_HTML_HIST_TBL_BASE()
      {
            return MBA.HttpApplication.createLink(RmtsParticipationRosters.URL_VIEW_HTML_HIST_TBL, true);
      }


      /***************************************************************************
        * generatePartipantsSelectionsList */
      /**
        * 
        **************************************************************************/
      public static List<RmtsParticipantSelection> generatePartipantsSelectionsList (ref List<RmtsParticipantPossible> participants)
      {
        var _selections = new List<RmtsParticipantSelection>();

        foreach (var _participant in participants)
        {
          var _selection = new RmtsParticipantSelection();
          _selection.id              = _participant.id;
          _selection.name            = _participant.name;
          _selection.title           = _participant.title;
          _selection.submitClaimsStr = _participant.submitClaimsStr;
          _selections.Add(_selection);
        }
        return _selections;
      }
 
      /***************************************************************************
       * generatePartipantsSelectionJSON */
      /**
       * 
       **************************************************************************/
      public static string generatePartipantsSelectionJSON (ref List<RmtsParticipantPossible> participants)
      {
        var _selections = generatePartipantsSelectionsList(ref participants);
        return MBA.JSON.toJSONString(_selections,JsonLibrary.NEWTONSOFT);      
      }
      

      /***************************************************************************
       * loadIntialData */
      /**
       * 
       **************************************************************************/
 
      public static RmtsParticipationRoster loadInitialData (  SqlConnection connSpedmon
                                                             , DetailsLog    log
                                                             , UserInfo      uInfo
                                                             , string        clientID)
      {
        var so = new RmtsParticipationRoster();
        
        var clientRec = Clients.load(connSpedmon,log,uInfo,clientID);
        so.clientID   = clientRec.id;
        so.clientName = clientRec.name;

        var participants    = RmtsParticipantsIncluded.viewList (connSpedmon,log,uInfo,clientID,null);
        so.participantsJSON = RmtsParticipationRosters.generatePartipantsSelectionJSON(ref participants);

        var qtr = RmtsCurrentQuarters.loadCurrentQuarter(connSpedmon,log,uInfo);   
        
        so.quarterID           = qtr.id;
        so.quarterName         = qtr.name;       
        so.startDate           = qtr.startDate;
        so.endDate             = qtr.endDate;
        so.quarterStartDateStr = qtr.startDateStr;
        so.quarterEndDateStr   = qtr.endDateStr;
        so.quarterIsInPast     = false;
        so.quarterIsCurrent    = true;
        so.quarterIsInFuture   = false;

        return so;
      }
        
      /***************************************************************************
       * getInitialData */
      /**
       * 
       **************************************************************************/
 
      public static ReturnRmtsParticipationRoster getInitialData(  SqlConnection connSpedmon
                                                             , DetailsLog    log
                                                             , UserInfo      uInfo
                                                             , string        clientID)
      {
        ReturnRmtsParticipationRoster so = new ReturnRmtsParticipationRoster();

        so.roster = loadInitialData(connSpedmon, log, uInfo, clientID);

        so.hasRecord = (!String.IsNullOrEmpty(so.roster.participantsJSON)); // double check this

        return so;
      }

      /***************************************************************************
       * load */
      /**
       * 
       **************************************************************************/
 
      public static RmtsParticipationRoster load (  SqlConnection connSpedmon
                                                   , DetailsLog    log
                                                   , UserInfo      uInfo
                                                   , string        clientID
                                                   , string        recID)
      {
        var so = new RmtsParticipationRoster();

        so = (RmtsParticipationRoster) Entities.load (  connSpedmon
                                                      , log
                                                      , uInfo
                                                      , recID
                                                      , typeof(RmtsParticipationRoster)
                                                      , delegate { 
                                                          return RmtsParticipationRosters.view ( connSpedmon
                                                                                                , log
                                                                                                , uInfo
                                                                                                , Entities.REC_VIEW_LOAD                                                                                               
                                                                                                , false
                                                                                                , recID
                                                                                                , ""
                                                                                                , ""
                                                                                                , clientID
                                                                                                , null );});
        
        var refDate = DateTime.Now.Date;
        
        so.quarterIsInPast   = Util.isAfterStartAndEndDate   (refDate, so.startDate, so.endDate);
        so.quarterIsCurrent  = Util.isBetweenStartAndEndDate (refDate, so.startDate, so.endDate);
        so.quarterIsInFuture = Util.isBeforeStartAndEndDate  (refDate, so.startDate, so.endDate);
        
        return so;
      }
        
      /***************************************************************************
       * loadRoster */
      /**
       * needed for web service end points
       **************************************************************************/
 
      public static ReturnRmtsParticipationRoster loadRoster(  SqlConnection connSpedmon
                                                   , DetailsLog    log
                                                   , UserInfo      uInfo
                                                   , string        clientID
                                                   , string        recID)
      {
        var so = new ReturnRmtsParticipationRoster();

        var rd = (RmtsParticipationRoster) Entities.load (  connSpedmon
                                                      , log
                                                      , uInfo
                                                      , recID
                                                      , typeof(RmtsParticipationRoster)
                                                      , delegate { 
                                                          return RmtsParticipationRosters.view ( connSpedmon
                                                                                                , log
                                                                                                , uInfo
                                                                                                , Entities.REC_VIEW_LOAD                                                                                               
                                                                                                , false
                                                                                                , recID
                                                                                                , ""
                                                                                                , ""
                                                                                                , clientID
                                                                                                , null );});
        
        so.roster = rd;
        so.hasRecord = (!String.IsNullOrEmpty(rd.participantsJSON)); // double check this

        return so;
      }
        
      /***************************************************************************
       * loadByQuarter */
      /**
       * recID is quarter id
       **************************************************************************/
 
      public static ReturnRmtsParticipationRoster loadByQuarter (  SqlConnection connSpedmon
                                                   , DetailsLog    log
                                                   , UserInfo      uInfo
                                                   , string        active
                                                   , string        clientID
                                                   , string        recID)
      {
            ReturnRmtsParticipationRoster so = new ReturnRmtsParticipationRoster();

            /*###########################################################################
              # Set up custom view method params for log history UDF call 
              ###########################################################################*/

            string sql = "select * from dbo.RMTS_PARTICIPATION_ROSTER_BY_QUARTER_VIEW (@clientID, @active, @recID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var vClientID = Validate.reqClientID(uInfo, clientID);
            var vActive   = Validate.optFlag(active, Messages.INVALID_FLAG_ACTIVE);
            var vRecID    = Validate.reqInteger(recID, Messages.INVALID_RECORD_ID);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@active"  , SqlDbType.Bit   , vActive  , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@recID"   , SqlDbType.BigInt, vRecID   , ParameterDirection.Input));

            ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);

            so.hasRecord = rd.hasRecords;
            so.roster = new RmtsParticipationRoster();
            if (so.hasRecord)
            {
                so.roster = (RmtsParticipationRoster)Database.convertRecord(rd.records, typeof(RmtsParticipationRoster));
            }
            return so;
      }


      public static ReturnRmtsParticipationRoster loadByQuarterNum (  SqlConnection connSpedmon
                                                   , DetailsLog    log
                                                   , UserInfo      uInfo
                                                   , string        active
                                                   , string        clientID
                                                   , string        recID // will be fiscalYearID from now on instead of fiscalQuarterID
                                                   , string        quarterNum)
      {
            ReturnRmtsParticipationRoster so = new ReturnRmtsParticipationRoster();

            /*###########################################################################
              # Set up custom view method params for log history UDF call 
              ###########################################################################*/

            string sql = "select * from dbo.RMTS_PARTICIPATION_ROSTER_BY_QUARTERNUM_VIEW (@clientID, @active, @recID, @quarterNum)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var vClientID = Validate.reqClientID(uInfo, clientID);
            var vActive   = Validate.optFlag(active, Messages.INVALID_FLAG_ACTIVE);
            var vRecID    = Validate.reqInteger(recID, Messages.INVALID_RECORD_ID);

            var vQuarterNum = Validate.reqInteger(quarterNum, Messages.INVALID_RECORD_ID);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@active"  , SqlDbType.Bit   , vActive  , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@recID"   , SqlDbType.BigInt, vRecID   , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@quarterNum", SqlDbType.BigInt, vQuarterNum, ParameterDirection.Input));

            ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);

            so.hasRecord = rd.hasRecords;
            so.roster = new RmtsParticipationRoster();
            if (so.hasRecord)
            {
                so.roster = (RmtsParticipationRoster)Database.convertRecord(rd.records, typeof(RmtsParticipationRoster));
            }
            return so;
      }


     /***************************************************************************
      * save */
     /**
      * Save 
      * 
      ***************************************************************************/   
  
      public static ReturnSaveRecord save (   SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , string        clientID
                                            , string        fyQuarterID
                                            , string        participantsRosterJSON
                                            , string        participantsRosterChangesJSON
                                            , string        saveType
                                            , string        validateRec
                                            , string        editDelReason
                                            , string        recID )
      {           
    
        /*----------------------------
         * Validate parameters specific
         * to this entity.save
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/
        
       string saveSproc = "RMTS_PARTICIPATION_ROSTER_SAVE";                
		   
       long      vClientID                     = Validate.reqClientID ( uInfo, clientID);
       long      vFyQuarterID                  = Validate.reqInteger  ( fyQuarterID,                   @"Invalid quarter", false);
		   string    vParticipantRosterJSON        = Validate.optString   ( participantsRosterJSON,        @"Invalid participant roster");
       string    vParticipantRosterChangesJSON = Validate.optString   ( participantsRosterChangesJSON, @"Invalid participant roster changes");
                
       List<SqlParameter> parms = new List<SqlParameter>();  

 		   parms.Add(Database.SqlParm( "@clientID",                      SqlDbType.BigInt,    vClientID,                      ParameterDirection.Input) );
 		   parms.Add(Database.SqlParm( "@fyQuarterID",                   SqlDbType.BigInt,    vFyQuarterID,                   ParameterDirection.Input) );
       parms.Add(Database.SqlParm( "@participantRosterJSON",         SqlDbType.VarChar,   vParticipantRosterJSON,         ParameterDirection.Input, -1) );
 		   parms.Add(Database.SqlParm( "@participantRosterChangesJSON",  SqlDbType.VarChar,   vParticipantRosterChangesJSON,  ParameterDirection.Input, -1) );
                
       /*----------------------------
        * Call base method which 
        * handles the rest and return
        * results
        *----------------------------*/  

       ReturnSaveRecord so = Entities.save (   connSpedmon
                                             , log
                                             , uInfo
                                             , saveType
                                             , validateRec
                                             , editDelReason
                                             , recID
                                             , saveSproc
                                             , @"A roster has already been created for this quarter"
                                             , ref parms
                                             , delegate(){});
                                                                                       
       
       return so;

    }

    /*************************************************************************
     * view */
    /**
     *
     * 
     **************************************************************************/   

    public static ReturnDB view (   SqlConnection connSpedmon
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , int           recViewType
                                  , bool          pagedOrTop
                                  , string        idx
                                  , string        canEdit
                                  , string        active   
                                  , string        clientID
                                  , defineCols    dc )
    {
      
      string viewUDF = "dbo.RMTS_PARTICIPATION_ROSTER_VIEW (@userID, @userGroup, @userRank, @clientID, @active, @recID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      var vClientID = Validate.reqClientID (uInfo, clientID);

      var parms = new List<SqlParameter>();   
      
      parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
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
                                           , string        clientID
                                           , string        canEdit
                                           , string        active )
   {
     ReturnDataTable so = new ReturnDataTable();
     
     /*###########################################################################
       # Define our display columns and set the page order.  Page order needs to
       # be in the same sort order as the udf called in the view.
       ###########################################################################*/  

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
     {       
       ss.addDisplayColumn("id");   
       ss.addDisplayColumn("name                   as [Name]",        true);
       ss.addDisplayColumn("numParticipants        as [Participant Count]");
       ss.addDisplayColumn("quarterStartDateStr    as [Starts On]");
       ss.addDisplayColumn("quarterEndDateStr      as [Ends On]");
       pageroworder = ss.pageRowOrder();
     };

     /*###########################################################################
       # Call the base method which handles the rest and returns a ReturnDataTable
       ###########################################################################*/  

     so = Entities.viewTbl(  connSpedmon
                           , log
                           , uInfo
                           , paged
                           , pageNumber
                           , delegate { return                            
                             RmtsParticipationRosters.view (  connSpedmon
                                                            , log
                                                            , uInfo
                                                            , Entities.REC_VIEW_TBL
                                                            , paged
                                                            , pageNumber
                                                            , canEdit
                                                            , active
                                                            , clientID
                                                            , dc); 
                            });
   
     /*###########################################################################
       # Add a title and footer to ReturnDataTable then return
       ###########################################################################*/  
               
     so.tableName   = SEL_LABEL;
     so.tableFooter = Messages.CONFIDENTIAL;
         
     return so;
     
    }            

    /***************************************************************************
     * viewTblModHist */
    /**
     * Returns a data table of records for recent activity on RMTS
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTblModHist (  SqlConnection connSpedmon
                                                   , DetailsLog    log
                                                   , UserInfo      uInfo
                                                   , string        clientID
                                                   , string        rosterID )
   {
        ReturnDataTable so = new ReturnDataTable();
        
        /*###########################################################################
          # Define our display columns and set the page order.  Page order needs to
          # be in the same sort order as the udf called in the view.
          ###########################################################################*/  

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {       
          ss.addDisplayColumn("name   as [Name]", true );
          ss.addDisplayColumn("action as [Action]"     );
          ss.addDisplayColumn("date   as [Date / Time]");
          pageroworder = ss.pageRowOrder();
        };

        /*###########################################################################
          # Set up custom view method params for log history UDF call 
          ###########################################################################*/
        
         string viewUDF = "dbo.RMTS_PARTICIPATION_ROSTER_RECENT_MODIFICATION_HISTORY_VIEW (@userID, @userGroup, @userRank, @clientID, @rosterID)";
        
        /*----------------------------
         * Validate parameters specific
         * to this entity.view
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/

        var vClientID = Validate.reqClientID (uInfo,clientID);
        var vRosterID = Validate.reqInteger  (rosterID, Messages.INVALID_ENTITY_ID);
        
        var logParms = new List<SqlParameter>();

        logParms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
        logParms.Add(Database.SqlParm("@rosterID", SqlDbType.BigInt, vRosterID, ParameterDirection.Input));
        
        /*----------------------------
         * Call base method which 
         * handles the rest and return
         * results
         *----------------------------*/             
        
        /*###########################################################################
          # Call the base method which handles the rest and returns a ReturnDataTable
          ###########################################################################*/  

        so = Entities.viewTbl(  connSpedmon
                              , log
                              , uInfo
                              , false
                              , "1"
                              , delegate { return
                                Entities.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, false, "1", null, null, viewUDF, ref logParms, null, dc);
                               });
   
        /*###########################################################################
          # Add a title and footer to ReturnDataTable then return
          ###########################################################################*/  
                  
        so.tableName   = SEL_LABEL;
        so.tableFooter = Messages.CONFIDENTIAL;
            
        return so;
     
    }
        
    /***************************************************************************
     * viewHTMLTblModHist */
    /**
     * Returns a data table of records for recent activity on RMTS
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnRmtsParticipationRosterHistHtml viewHTMLTblModHist (  SqlConnection connSpedmon
                                                   , DetailsLog    log
                                                   , UserInfo      uInfo
                                                   , string        clientID
                                                   , string        rosterID )
    {
        ReturnDataTable modHist = RmtsParticipationRosters.viewTblModHist(connSpedmon, log, uInfo, clientID, rosterID);
   
        /*###########################################################################
          # Add a title and footer to ReturnDataTable
          ###########################################################################*/  
                  
        modHist.tableName   = "Roster Modification History";
        modHist.tableFooter = "";

        ReturnRmtsParticipationRosterHistHtml so = new ReturnRmtsParticipationRosterHistHtml();
        so.htmlText = (modHist.iTotalDisplayRecords > 0) ? ReturnDataTable.createHTMLTable(ref modHist) :
                                                         "<span>No audit records were found</span>";
        so.hasRecord = (modHist.iTotalDisplayRecords > 0);
        return so;
     
    }
        
    /***************************************************************************
     * viewTblQuarterData */
    /**
     * Returns a data table of records for selected quarter
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTblQuarterData (  SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , bool paged
                                           , string pageNumber
                                           , string clientID
                                           , string recordID
                                           , string canEdit
                                           , string active
                                           )
   {
        ReturnDataTable so = new ReturnDataTable();
        
        /*###########################################################################
          # Define our display columns and set the page order.  Page order needs to
          # be in the same sort order as the udf called in the view.
          ###########################################################################*/  

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {

          ss.addDisplayColumn("quarterName                 as [Quarter]", true );
          ss.addDisplayColumn("pracLastName                as [Practitioner Last Name]");
          ss.addDisplayColumn("pracFirstName               as [Practitioner First Name]");
          ss.addDisplayColumn("pracEmail                   as [Practitioner Email]");
          ss.addDisplayColumn("pracTitle                   as [Practitioner Title]");
          ss.addDisplayColumn("JobClassification           as [Job Classification]");
          ss.addDisplayColumn("reportingGroup              as [Reporting Group]");
          ss.addDisplayColumn("startDateStr                as [Start Date]");
          ss.addDisplayColumn("reasonForStartDateChangeStr as [Reason For Start Date Change]");
          ss.addDisplayColumn("endDateStr                  as [End Date]");
          ss.addDisplayColumn("reasonForEndDateChangeStr   as [Reason For End Date Change]");
          ss.addDisplayColumn("hasServiceRecordsStr        as [Has Service Records]");
          ss.addDisplayColumn("qtrHasReimbursedClaims           as [QTR Has Reimbursed Claims?]");

          ss.addDisplayColumn("fyHasReimbursedClaims           as [FY Has Reimbursed Claims?]");

          pageroworder = ss.pageRowOrder();
        };

        /*###########################################################################
          # Set up custom view method params for log history UDF call 
          ###########################################################################*/
        string viewUDF = "dbo.RMTS_PARTICIPATION_ROSTER_QUARTER_VIEW (@userID, @userGroup, @userRank, @clientID, @recordID, @active)";
                                                                                                      
        /*----------------------------                                                                    
         * Validate parameters specific                                                                   
         * to this entity.view
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/
        
        var vClientID    = Validate.reqClientID (uInfo, clientID);
        var vRecordID    = Validate.reqInteger  (recordID, Messages.INVALID_NUMBER);
        
        var rosterParms = new List<SqlParameter>();
        
        rosterParms.Add(Database.SqlParm("@recordID",   SqlDbType.BigInt,    vRecordID,   ParameterDirection.Input));
        rosterParms.Add(Database.SqlParm("@clientID",   SqlDbType.BigInt,    vClientID,   ParameterDirection.Input));
        
        /*----------------------------
         * Call base method which 
         * handles the rest and return
         * results
         *----------------------------*/             
        
        /*###########################################################################
          # Call the base method which handles the rest and returns a ReturnDataTable
          ###########################################################################*/  

        so = Entities.viewTbl(  connSpedmon
                              , log
                              , uInfo
                              , paged
                              , pageNumber
                              , delegate { return
                                Entities.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, null, null, viewUDF, ref rosterParms, null, dc);
                               });
   
        /*###########################################################################
          # Add a title and footer to ReturnDataTable then return
          ###########################################################################*/  
                  
        so.tableName   = SEL_LABEL;
        so.tableFooter = Messages.CONFIDENTIAL;
            
        return so;
    }            

    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of objects
     * 
     ***************************************************************************/
    public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , bool pageObjectList
                                                , string pageOrder
                                                , string idx
                                                , string active
                                                , string clientID
    )
    {

        /* Default page order */

        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = RmtsParticipationRoster.DEFAULT_PAGING_ORDER;

        /* Define columns delegate is used to specify columns and page order 
            * We pass in the desired page row order here */

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };

        return Entities.viewObjects(connSpedmon
                                        , log
                                        , uInfo
                                        , typeof(RmtsParticipationRoster)
                                        , pageObjectList
                                        , pageOrder
                                        , delegate
                                        {
                                            return RmtsParticipationRosters.view(
                                                                      connSpedmon
                                                                    , log
                                                                    , uInfo
                                                                    , Entities.REC_VIEW_OBJECTS
                                                                    , pageObjectList
                                                                    , idx
                                                                    , "" // canEdit
                                                                    , active
                                                                    , clientID
                                                                    , dc
                                            );
                                        });
    }

    /***************************************************************************
     * loadOrCreateRoster */
    /**
    * returns id of a new or existing roster that matches the passed in params
    * 
    * returns 0 in case of error
    ****************************************************************************/

    public static long loadOrCreateRoster(SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , string clientID
                                         , string fyQuarterID)
    {

        var rosterData = RmtsParticipationRosters.loadByQuarter(connSpedmon, log, uInfo, "1", clientID, fyQuarterID);
        var retRosterID = (rosterData.hasRecord) ? rosterData.roster.id : 0 ;

        // if roster doesn't exist create it
        if (!rosterData.hasRecord)
        {
            var newRoster = RmtsParticipationRosters.save(connSpedmon, log, uInfo, clientID, fyQuarterID, "[]", null, Constants.SAVE_TYPE_NEW.ToString(), "0", "", null);
            retRosterID = newRoster.recordID;
        }

        return retRosterID;

    }



    }
}
