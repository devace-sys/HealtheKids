

using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;

using MBA.Reporting;
using MBA;


namespace Spedmon
{


   /***************************************************************************
    * CYBHIProgramHealthDetailedServicesDocumented */
  /**

     **************************************************************************/  
    public class CYBHIProgramHealthDetailedServiceDocumented : MBA.Entity
    {
        public const string DEFAULT_PAGING_ORDER = "pracName asc";


        public   string   pracName;
        public   DateTime dos;
        public   string   dosStr;

        public   string   svcName;
        public   string   groupName;
        public   int      numMins;

        public   bool     patAbsent;
        public   bool     pracAbsent;
        public   bool     svcAbsent;

        public   string   patAbsentYN;
        public   string   pracAbsentYN;
        public   string   svcAbsentYN;

        public   Decimal  amountClaimed;
        public   Decimal  amountPaid;

        public   bool     waitingForAdjudication;
        public   bool     adjudicationCompleted;
        public   bool     paid;
        public   bool     svcClaimHeld;

        public   string   waitingForAdjudicationYN;
        public   string   adjudicationCompletedYN;
        public   string   paidYN;
        public   string   svcClaimHeldYN;

        public   string   processingRemark;
        public   long     lastHoldCode;

        public   bool     billableSvc;

        public   string   billableSvcYN;

        public   long     svcRecID;
        public   DateTime   todayDateTime;


        // public  bool     waitingForFirstTxAttempt; 
        // public  bool     adjudicationCompleted;  ??
        // public  long     lastHoldSiteID;
        // public  long     lastHoldClaimingPracID;
        // public  bool     canAttemptTx;
        // public  bool     belowThresholdToTx;
        // public  int      numOfRx;
        // public  int      numOfTx;
        // public  long     svcRecState;
        // public  long     pracGrpSvcClsNameID;
        // public  long     pracID;
        // public  long     nameID;
        // public  long     groupID;
        // public  long      patID;
        // public  long      clientID;

    }




    /***************************************************************************
     * CYBHIProgramHealthDetailedServicesDocumenteds */
    /**
     * Graphically-emhanced richtext documents that can be sent as emails;
     * also included in help library
       **************************************************************************/
    public class CYBHIProgramHealthDetailedServicesDocumented:Entities
    {
	     public const string SEL_LABEL_MANAGE          = @"";
	     public const string URL_MANAGE                = @"";
	     public const string MENU_LNK_ID_MANAGE        = @"";
	
	
	
	     public const string URL_REST_VIEW_BASE = @"api/v1/cybhiprogramhealthdetailedservicesdocumented";
	

	     public const string URL_WEB_REPORT_BASE = @"cybhi_health_detailed_services_documented.ashx";  // TODO: consider renaming as cybhi_program_health....

	     public const string URL_WEB_PAGE_BASE = @"user_all_cybhi_program_health_details_services_documented_manage.aspx";



       /***************************************************************************
        * URL_REST_VIEW */
       /**
        * 
        **************************************************************************/
        public static string URL_REST_VIEW()
        {
            return MBA.HttpApplication.createLink(CYBHIProgramHealthDetailedServicesDocumented.URL_REST_VIEW_BASE, true);
        }

       /***************************************************************************
         * URL_WEB_REPORT */
       /**
        * 
        **************************************************************************/
        public static string URL_WEB_REPORT()
        {
            return MBA.HttpApplication.createLink(CYBHIProgramHealthDetailedServicesDocumented.URL_WEB_REPORT_BASE, true);
        }



       /***************************************************************************
         * URL_WEB_PAGE */
       /**
        * 
        **************************************************************************/
        public static string URL_WEB_PAGE()
        {
            return MBA.HttpApplication.createLink(CYBHIProgramHealthDetailedServicesDocumented.URL_WEB_PAGE_BASE, true);
        }


      /***************************************************************************
       * view */
      /**

       * @return                   ReturnDB
       */
       protected static ReturnDB view (  SqlConnection connUsers
                                    , DetailsLog    log
                                    , UserInfo      uInfo

                                    , int           recViewType
                                    , defineCols dc
                                    , bool          pagedOrTop
                                    , string        idx
                                    , string        canEdit
                                    , string        active

                                    , string        clientID
                                    , string        groupID
                                    , string        pracID
                                    , string        patID
                                    , string        nameID
                                    , string        startDOS
                                    , string        endDOS
                                    , string        isPaid
                                     )
       {

	      List<SqlParameter> parms        = new List<SqlParameter>();
          
	      string             viewUDF             = "dbo.CYBHI_SERVICE_RECORDS_WITH_CLAIM_PROCESSING_DETAILS_VIEW " +
                @"( @userID, @userGroup, @userRank, @clientID , @groupID , @pracID , @patID , @nameID , @startDOS , @endDOS , @paid )";

          var vCliID = Validate.reqClientID(uInfo, clientID );
          var vGrpID = Validate.optInteger(groupID, "invalid group ID");
          var vPracID = Validate.optPracID(uInfo, pracID);
          var vPatID  = Validate.optPatID(uInfo, patID);
          var vNameID = Validate.optInteger(nameID, Messages.INVALID_NAME_ID);

          object[] vStartDos = Validate.optStartAndEndDate(startDOS, endDOS, Messages.INVALID_DATE_RANGE);
          var      vPaid     = Validate.optFlag(isPaid, "is paid?");


	      parms.Add(Database.SqlParm( "@clientID",   SqlDbType.BigInt,  vCliID,       ParameterDirection.Input));

	      parms.Add(Database.SqlParm("@groupID",     SqlDbType.BigInt  ,vGrpID,               ParameterDirection.Input));

	      parms.Add(Database.SqlParm("@pracID",      SqlDbType.BigInt, vPracID,              ParameterDirection.Input));
	      parms.Add(Database.SqlParm("@patID",       SqlDbType.BigInt, vPatID,               ParameterDirection.Input));

          parms.Add(Database.SqlParm("@nameID", SqlDbType.BigInt, vNameID, ParameterDirection.Input));
          parms.Add(Database.SqlParm("@startDOS", SqlDbType.DateTime, vStartDos[0], ParameterDirection.Input));
          parms.Add(Database.SqlParm("@endDOS", SqlDbType.DateTime, vStartDos[1], ParameterDirection.Input));
          parms.Add(Database.SqlParm("@paid", SqlDbType.Bit, vPaid, ParameterDirection.Input));

          return Entities.view (connUsers, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

       }




      /***************************************************************************
       * viewTbl */
      /**
       * Calls the view() method and populates a ReturnDataTable object

       * @return                   ReturnDataTable
	
       ***************************************************************************/ 
       public static ReturnDataTable viewTbl (  SqlConnection connApp
                                              , DetailsLog    log
                                              , UserInfo      uInfo
                                              , bool          paged
                                              , string        pageNumber
                                              
                                            , string        canEdit
                                            , string        active

                                            , string clientID
                                            , string groupID
                                            , string pracID
                                            , string patID
                                            , string nameID
                                            , string startDOS
                                            , string endDOS
                                            , string isPaid
           )
       {

          defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
          {
                ss.addDisplayColumn("pracName    as  [Practitioner Name]");

                ss.addDisplayColumn("dos         as  [DOS]");
                ss.addDisplayColumn("svcName     as  [Service Name]");
                ss.addDisplayColumn("groupName   as  [Practitioner Type]");

                ss.addDisplayColumn("numMins     as  [Minutes]");

                ss.addDisplayColumn("patAbsent   as  [Patient Absent]");
                ss.addDisplayColumn("pracAbsent  as  [Practitioner Absent]");
                ss.addDisplayColumn("svcAbsent   as  [Service Absent]");

                ss.addDisplayColumn("amountClaimed     as  [Claimable Amount]");
                ss.addDisplayColumn("amountPaid        as  [Paid Amount]");

                ss.addDisplayColumn("waitingForAdjudication    as  [Transmitted Awaiting Adjudication]");
                ss.addDisplayColumn("adjudicationCompleted     as  [Adjudication Completed]");

                ss.addDisplayColumn("paid                      as  [Paid]");
                ss.addDisplayColumn("svcClaimHeld              as  [Service Held]");
                ss.addDisplayColumn("processingRemark          as  [Processing Remark]");

                ss.addDisplayColumn("lastHoldCode              as  [Hold Code]");
                ss.addDisplayColumn("billableSvc               as  [Service Billable]");

                ss.addDisplayColumn("svcRecID                  as  [SvcRecID]");
                ss.addDisplayColumn("todayDatetime             as  [Report Date]");

                pageroworder = ss.pageRowOrder();
          };

            Validate.reqClientID(uInfo, clientID);
            var c_name = Clients.load(connApp, log, uInfo, clientID).name;

            return Entities.viewTbl(connApp, log, uInfo, paged, pageNumber,
            delegate
            {
                return CYBHIProgramHealthDetailedServicesDocumented.view(
           connApp, log, uInfo, // appName,
           Entities.REC_VIEW_TBL,
           dc, paged, pageNumber, canEdit, active

           , clientID
           , groupID
           , pracID
           , patID
           , nameID
           , startDOS
           , endDOS
           , isPaid
           );
            }
            , @"CYBHI Program Health Report - Documented Records - " + c_name
            , Messages.CONFIDENTIAL
            ) ;

       }



       /***************************************************************************
         * viewObjects */
       /**
         * Returns a database result set of records for REST handlers
         * @return                   ReturnObjects
	
       ***************************************************************************/ 
       public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
                                                   , bool pageObjectList
                                                   , string pageOrder
                                                   , string idx
                                                   //, string active
                                                , string clientID
                                                , string groupID
                                                , string pracID
                                                , string patID
                                                , string nameID
                                                , string startDOS
                                                , string endDOS
                                                , string isPaid)
       {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = CYBHIProgramHealthDetailedServiceDocumented.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            var rd = Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(CYBHIProgramHealthDetailedServiceDocumented)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate {
                                              return CYBHIProgramHealthDetailedServicesDocumented.view
                                                                                  ( connSpedmon
                                                                                   , log
                                                                                   , uInfo
                                                                                   //, Constants.APP_NAME
                                                                                   , Entities.REC_VIEW_OBJECTS
                                                                                   , dc
                                                                                   , pageObjectList
                                                                                   , idx
                                                                                   , null
                                                                                   , "Y" /* Active */
                                                ,  clientID
                                                ,  groupID
                                                ,  pracID
                                                ,  patID
                                                ,  nameID
                                                ,  startDOS
                                                ,  endDOS
                                                ,  isPaid
                                                                                   );                                             
                                          });

            return rd;
       }



    }
}