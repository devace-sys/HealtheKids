using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;


namespace Spedmon
{
    /***************************************************************************
     * PotentialLostReimbursementSums  */
    /**
     * Used for summary reporting
     ***************************************************************************/
    public class PotentialLostReimbursementSums
    {
        public decimal deferred = 0.00M;
        public decimal review   = 0.00M;
    }

    /***************************************************************************
     * ReturnPotentialLostReimbursementSums  */
    /**
     * Used for summary reporting
     ***************************************************************************/

    public class ReturnPotentialLostReimbursementSums : Return
    {
        public ReturnPotentialLostReimbursementSums() : base() { }
        public ReturnPotentialLostReimbursementSums(string msg) : base(msg) { }
        public ReturnPotentialLostReimbursementSums(Exception e) : base(e) { }
        public ReturnPotentialLostReimbursementSums(Warning e) : base(e) { }
        public ReturnPotentialLostReimbursementSums(Critical e) : base(e) { }
        public ReturnPotentialLostReimbursementSums(SessionExpired e) : base(e) { }
        public bool hasRecord = false;
        public PotentialLostReimbursementSums sums;
    }

    /***************************************************************************
     * PLRClassCodes */
    /**
     *
     **************************************************************************/
    public static class PLRClassCodes
    {
        public static int missingOrders      { get { return 100; } }
        public static int missingSupervision { get { return 300; } }
    }
    /***************************************************************************
     * PotentialLostReimbursement */
    /**
     *
     **************************************************************************/

    public class PotentialLostReimbursement : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"patName asc";

        public long     patID;
        public string   patName;
        public DateTime dob;
        public string   dobStr;
        public long     pracGroupID;
        public string   pracGroupName;
        public DateTime earliestDOS;
        public string   earliestDOSStr;
        public DateTime latestDOS;
        public string   latestDOSStr;
        public Decimal  potentialReimbursementAmt;
        public string   potentialReimbursementAmtStr;
        public long     holdCode;
        public string   holdReason;
        public string   instructions;
        public long     siteID;
        public string   siteName;
        public long     clientID;
        public long     pracID;
        public string   pracName;
        public long     refID;
        public long     pracGrpSvcClassNameID;
        public string   plrIDString;
        public bool     deferred;
    }

    /***************************************************************************
     * PotentialLostReimbursements */
    /**
     ***************************************************************************/
    public class PotentialLostReimbursements : Entities
    {

        public const string MENU_ID_MANAGE_HOLDS = @"plrholdsmanage";
        public const string SEL_MANAGE_HOLDS     = @"Manage PLR Holds";
        public const string URL_MANAGE_HOLDS     = @"user_all_plr_holds_manage.aspx";
        public const string SEL_LABEL_RPT        = @"Potential Lost Reimbursements Report";

        public const string URL_REST_VIEW = @"api/v1/potentiallostreimbursements";

        public const string URL_ASHX = @"potential_lost_reimbursements.ashx";

        public const string URL_WEB_SERVICE = @"potential_lost_reimbursements.asmx";
        public const string URL_GET_SUMS    = URL_WEB_SERVICE + @"/getpotentialreimbursesums";

        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(PotentialLostReimbursements.URL_REST_VIEW, true);
        }
        
        /***************************************************************************
         * URL_SVC_GET_SUMS */
        /**
         * 
         **************************************************************************/

        public static string URL_SVC_GET_SUMS()
        {
            return MBA.HttpApplication.createLink(PotentialLostReimbursements.URL_GET_SUMS, true);
        }

        public static string URL_MANAGE_HOLDS_BASE()
        {
            return MBA.HttpApplication.createLink(PotentialLostReimbursements.URL_MANAGE_HOLDS, true);
        }
        
        public static string URL_ASHX_BASE()
        {
            return MBA.HttpApplication.createLink(URL_ASHX, true);
        }

        /***************************************************************************
         * view */
        /**
         * View client contact roles
         * 
         * @return            ReturnDB
         ***************************************************************************/

        public static ReturnDB view(SqlConnection                             connSpedmon
                                     , DetailsLog                             log
                                     , UserInfo                               uInfo
                                     , int                                    recViewType
                                     , bool                                   pagedOrTop
                                     , string                                 idx
                                     , string                                 canEdit
                                     , string                                 active
                                     , string                                 clientID
                                     , string                                 pracID
                                     , string                                 repID
                                     , string                                 groupSvcClassNameID
                                     , string                                 patID
                                     , string                                 plrClassCode
                                     , string                                 deferred
                                     , defineCols                             dc)
        {

            string viewUDF = "dbo.POTENTIAL_LOST_REIMBURSEMENTS_ACTIONABLE_DATA_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @repID, @groupSvcClassNameID, @patID, @plrClassCode, @deferred)";

            /*----------------------------
            * Validate parameters specific
            * to this entity.view
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/

            Object vClientID            = Validate.optClientID               (uInfo        , clientID);
            Object vPracID              = Validate.optPracID                 (uInfo        , pracID);
            Object vRepID               = Validate.optInteger                (repID        , Messages.INVALID_NUMBER);
            Object vGroupSvcClassNameID = Validate.optStdGroupSvcClassNameID (uInfo        , groupSvcClassNameID);
            Object vPatID               = Validate.optInteger                (patID        , Messages.INVALID_PAT_ID);
            Object vPLRCLassCode        = Validate.reqInteger                (plrClassCode , Messages.INVALID_NUMBER);
            Object vDeferred            = Validate.optFlag                   (deferred     , Messages.INVALID_FLAG);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"           , SqlDbType.BigInt , vClientID           , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt , vGroupSvcClassNameID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID"             , SqlDbType.BigInt , vPracID             , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@repID"              , SqlDbType.BigInt , vRepID              , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID"              , SqlDbType.BigInt , vPatID              , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@plrClassCode"       , SqlDbType.Int    , vPLRCLassCode       , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@deferred"           , SqlDbType.Bit    , vDeferred           , ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

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
                                                  , string pracID
                                                  , string repID
                                                  , string groupSvcClassNameID
                                                  , string patID
                                                  , string plrClassCode
                                                  , string deferred
        )
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PotentialLostReimbursement.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(PotentialLostReimbursement)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return PotentialLostReimbursements.view(
                                                                         connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" // canEdit
                                                                       , active
                                                                       , clientID
                                                                       , pracID
                                                                       , repID
                                                                       , groupSvcClassNameID
                                                                       , patID
                                                                       , plrClassCode
                                                                       , deferred
                                                                       , dc
                                               );
                                          });
        }

        public static ReturnDataTable viewTbl(SqlConnection connSpedmon
                                           , DetailsLog log
                                           , UserInfo uInfo
                                           , bool paged
                                           , string pageNumber
                                           , string canEdit
                                           , string active
                                           , string clientID
                                           , string pracID
                                           , string repID
                                           , string groupSvcClassNameID
                                           , string patID
                                           , string plrClassCode
                                           , string deferred
        )
        {
            ReturnDataTable so = new ReturnDataTable();

            /*###########################################################################
              # Define our display columns and set the page order.  Page order needs to
              # be in the same sort order as the udf called in the view.
              ###########################################################################*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("patName                      as [Patient Last, First]", true);
                ss.addDisplayColumn("dobStr                       as [Date Of Birth]");
                ss.addDisplayColumn("siteName                     as [Site]");
                ss.addDisplayColumn("pracName                     as [Practitioner]");
                ss.addDisplayColumn("pracGroupName                as [Practitioner Group]");
                ss.addDisplayColumn("earliestDOSStr               as [Earliest Service]");
                ss.addDisplayColumn("latestDOSStr                 as [Latest Service]");
                ss.addDisplayColumn("notes                        as [Notes]");
                ss.addDisplayColumn("potentialReimbursementAmtStr as [Potential Lost Reimbursement]");
                ss.addDisplayColumn("holdReason                   as [Hold Reason]");
                                     
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
                                            view(connSpedmon
                                                   , log
                                                   , uInfo
                                                   , Entities.REC_VIEW_TBL
                                                   , paged
                                                   , pageNumber
                                                   , canEdit
                                                   , active
                                                   , clientID
                                                   , pracID
                                                   , repID
                                                   , groupSvcClassNameID
                                                   , patID
                                                   , plrClassCode
                                                   , deferred
                                                   , dc);
                                  });

            /*###########################################################################
              # Add a title and footer to ReturnDataTable then return
              ###########################################################################*/

            so.tableName = SEL_LABEL_RPT;
            so.tableFooter = Messages.CONFIDENTIAL;

            return so;

        }

        /***************************************************************************
         * getpotentialreimbursesums 
         *
         * Returns PLR sums
         * 
         ***************************************************************************/

        public static ReturnPotentialLostReimbursementSums getPotentialReimburseSums(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , string clientID
                                                  , string plrClassCode
        )
        {
            
            var so = new ReturnPotentialLostReimbursementSums();
            
            long   vClientID     = Validate.reqClientID (uInfo, clientID);
            Object vPLRCLassCode = Validate.reqInteger  (plrClassCode, Messages.INVALID_NUMBER);

            var parms = new List<SqlParameter>();

              parms.Add(Database.SqlParm("@clientID",      SqlDbType.BigInt,   vClientID,      ParameterDirection.Input));
              parms.Add(Database.SqlParm("@plrClassCode",  SqlDbType.Int,      vPLRCLassCode,  ParameterDirection.Input));

              var sql = @"select top 1 * from dbo.POTENTIAL_LOST_REIMBURSEMENTS_AMOUNTS_VIEW (@clientID, @plrClassCode)";

              ReturnDB rd = Database.execQuery(connSpedmon,log,sql,false,parms);
      
              so.hasRecord = rd.hasRecords;
              so.sums = new PotentialLostReimbursementSums();
              if (so.hasRecord)
              {
                so.sums = (PotentialLostReimbursementSums)Database.convertRecord(rd.records, typeof(PotentialLostReimbursementSums));
              }
              return so;      
           
        }

    }
}
