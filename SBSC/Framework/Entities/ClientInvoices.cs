using MBA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;


namespace Spedmon
{
    public class ClientInvoice : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"clientName asc, invoiceDate desc";

        public long      clientID;
        public string    clientName;

        public long      invoiceNum;
        public Decimal   invoiceAmt;

        public Decimal   amountPaid;
        public DateTime  invoiceDate;

        public string    invoiceDateYMD;
        public string    invoiceDateStr;

        public DateTime dateCollected;
        public string   dateCollectedYMD;
        public string   dateCollectedStr;
        public string   consultant;


        public DateTime depositDate;
        public string depositDateYMD;
        public string depositDateStr;

        /*
        
        // Moved to ClientInvoiceWithPartnerData for privacy and security reasons.
        
        public   string revenueCode;
        public  string  revenueProgram;
        public DateTime depositDate;
        public string depositDateYMD;
        public string depositDateStr;
        public DateTime distributedDate;
        public string distributedDateYMD;
        public string distributedDateStr;

        public string   distributionNotes;  
        */

    }
    public class ClientInvoiceWithPartnerData:ClientInvoice
    {

        public   string revenueCode;
        public  string  revenueProgram;

        public DateTime distributedDate;
        public string distributedDateYMD;
        public string distributedDateStr;

        public string   distributionNotes;  

        public Decimal  spEdCareShare;
        public Decimal  pcalShare;
        
        public Decimal accountingFee;
        public Decimal partnerRevenue;

        public Decimal partnerShareRevenue;

        public Decimal csbaShare;
        public Decimal lbaShare;

        public Decimal partner1Share;
        public Decimal partner2Share;

        public Decimal clientRetention;
        public Decimal mbaShare;
        public Decimal spEdCarePartners;

        public Decimal mbaBba;
        public Decimal mbaDg;

        public Decimal spEdCareBba;
        public Decimal spEdCareDg;

        public Decimal revShare;


        // TODO: we're using Decimal here, but the underlying db fields are type [money].  Not sure if this could ever be a problem

        public string spEdCareShareStr;
        public string pcalShareStr;

        public string accountingFeeStr;
        public string partnerRevenueStr;

        public string partnerShareRevenueStr;

        public string csbaShareStr;
        public string lbaShareStr;

        public string partner1ShareStr;
        public string partner2ShareStr;

        public string clientRetentionStr;
        public string mbaShareStr;
        public string spEdCarePartnersStr;

        public string mbaBbaStr;
        public string mbaDgStr;

        public string spEdCareBbaStr;
        public string spEdCareDgStr;

        public string revShareStr;

        public string invoiceAmtStr;
    }

    public class ClientInvoices : Entities
    {
        public const string URL_MANAGE       = @"sbs_mgmt_invoices_manage.aspx";

        public const string URL_MANAGE_PARTNER_DISTRIBUTIONS = @"sbs_mgmt_partner_distributions_manage.aspx";

        public const string URL_MANAGE_PARTNER_CYBHI_DISTRIBUTIONS = @"sbs_mgmt_partner_cybhi_distributions_manage.aspx";

        public const string URL_MANAGE_PARTNER_RETNTN_DISTRIBUTIONS = @"sbs_mgmt_partner_retention_distributions_manage.aspx";

        public const string SEL_LABEL_MANAGE = @"Manage Invoices";

        public const string SEL_LABEL_MANAGE_DISTR = @"Manage Partner Distributions";

        public const string SEL_LABEL_MANAGE_PARTN1_2 = "Partner 1 & 2 Distribution";

        public const string SEL_LABEL_MANAGE_RETNTN_DISTR = "Partner Distributions \u2014 Client Retention";


        public const string MENU_LNK         = @"clientinvoiceslnk";


        public const string MENU_LNK_PARTNER = @"partnerdistributionslnk";
        public const string MENU_LNK_PARTNER_CYBHI = @"partnerdistributionscybhilnk";
        public const string MENU_LNK_PARTNER_RETNTN = @"partnerdistributionsretntnlnk";


        public const string URL_WEB_REPORT   = @"client_invoices.ashx";
        public const string URL_WEB_SERVICE  = @"client_invoices.asmx";

        public const string URL_SAVE_NOTES         = URL_WEB_SERVICE + @"/savenotes";

        public const string URL_SAVE_PMT_INFO      = URL_WEB_SERVICE + @"/savepmtinfo";

        public const string URL_SAVE_DEPOSIT_INFO = URL_WEB_SERVICE + @"/savedepositinfo";


        public const string URL_REST_VIEW    = @"api/v1/clientinvoices";

        public const string URL_REST_VIEW_PARTNER_DISTRIBUTIONS = @"api/v1/partnerdistributions";


        public const string URL_GET_TOTALS = URL_WEB_SERVICE + @"/gettotals";

        public const string URL_BULK_UPDATE_DISTRIB_DATE = URL_WEB_SERVICE + @"/bulkupdatedistribdate";


        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(ClientInvoices.URL_REST_VIEW, true);
        }

        public static string URL_REST_VIEW_PARTNER_DISTRIBUTIONS_BASE()
        {
            return MBA.HttpApplication.createLink(ClientInvoices.URL_REST_VIEW_PARTNER_DISTRIBUTIONS, true);
        }

        /***************************************************************************
         * URL_MANAGE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_MANAGE_BASE()   
        {
            return MBA.HttpApplication.createLink(ClientInvoices.URL_MANAGE, true);
        }

        public static string URL_MANAGE_PARTNER_DISTRIBUTIONS_BASE() 
        {
            return MBA.HttpApplication.createLink(ClientInvoices.URL_MANAGE_PARTNER_DISTRIBUTIONS, true);
        }

        /***************************************************************************
         * URL_SAVE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_SAVE_NOTES_BASE()
        {
            return MBA.HttpApplication.createLink(ClientInvoices.URL_SAVE_NOTES, true);
        }


        public static string URL_SAVE_PMT_INFO_BASE()
        {
            return MBA.HttpApplication.createLink(ClientInvoices.URL_SAVE_PMT_INFO, true);
        }

        public static string URL_SAVE_DEPOSIT_INFO_BASE()
        {
            return MBA.HttpApplication.createLink(ClientInvoices.URL_SAVE_DEPOSIT_INFO, true);
        }


        /***************************************************************************
         * URL_WEB_REPORT_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_WEB_REPORT_BASE()
        {
            return MBA.HttpApplication.createLink(ClientInvoices.URL_WEB_REPORT, true);
        }

        /***************************************************************************
         * userCanSeePartnerData
         *
         * 
         ***************************************************************************/
        public static bool userCanSeePartnerData (UserInfo uInfo)
        {          
          if (uInfo.pcalStaff == true)
          {
            return UserAssignedRoles.userHasPermittedRole(Constants.ROLE_MANAGE_PARTNER_SHARES,uInfo.userRoleLower);
          }
          return false;           
        } 

        public static string URL_GET_TOTALS_BASE()
        {

            return MBA.HttpApplication.createLink(ClientInvoices.URL_GET_TOTALS, true);
        }

        public static string URL_BULK_UPDATE_DISTRIB_DATE_BASE()
        {

            return MBA.HttpApplication.createLink(ClientInvoices.URL_BULK_UPDATE_DISTRIB_DATE, true);
        }
        /***************************************************************************
         * getTotals */
        /**
         *
         **************************************************************************/

        public static ReturnObjects getTotals(SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , string clientID
                                              //, string dateRange
                                              , string invoicePaid

                                              , string daterangeinvoice

                                              , string distbPaid

                                              // , string distbpaiddaterange
                                              , string invcolldaterange
                                              , string calcShares

                                              , string inclPartner1Col
                                              , string inclRetentionCol 
                                              , string inclCybhiRows
                                              , string inclCybhiRowsOnly
                                              )
        {

            // Default page order

            var pageOrder = ClientInvoice.DEFAULT_PAGING_ORDER;

            // Define columns delegate is used to specify columns and page order 
            // We pass in the desired page row order here 

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            viewCall dg = delegate ()
            {   // this is kinda a clone of ClientInvoices.view() except it calls a different UDF.
                // I suppose I coulda defined it as a method, even a private method of ClientInvoices.
                // But it's not called from anywhere else and I subjectively decided that placing it here
                // makes the developer intent more readable.  Hi!
                var rDB = new ReturnDB();

                string viewUDF = "dbo.CLIENT_INVOICES_TOTALS_VIEW (" +
                   @"@userID, @userGroup, @userRank, @clientID, @startDateInvoiceRange, @endDateInvoiceRange," +

                   @"@invoicePaid, @distributionPaid, @startDateInvCollRange, @endDateInvCollRange, @calcShares, " +
                   @"@inclPartner1Col, @inclRetentionCol, @inclCybhi, @inclCybhiOnly)";

                /*----------------------------
                * Validate parameters specific
                * to this entity.view
                * and populate their
                * coresponding database
                * parameters
                *----------------------------*/

                List<SqlParameter> parms = new List<SqlParameter>();

                //viewParams(uInfo  // permission validation for calcShares
                //, clientID
                //, ""  // startDateInvoiceRange
                //, ""  // endDateInvoiceRange
                //, invoicePaid
                //, "1"  // calcShares
                //, distbPaid
                //, ref parms
                //, daterangeinvoice
                //, distbpaiddaterange);

                viewParams(uInfo  // permission validation for calcShares
                    , clientID
                    , ""  // startDateInvoiceRange
                    , ""  // endDateInvoiceRange
                    , invoicePaid
                    , calcShares
                    , distbPaid
                    , ref parms
                    , daterangeinvoice
                    , invcolldaterange   ,

                    null,
                    null,

                    inclPartner1Col ,
                    inclRetentionCol ,
                    inclCybhiRows    ,
                    inclCybhiRowsOnly

                    );

                /*----------------------------
                 * Call base method which 
                 * handles the rest and return
                 * results
                 *----------------------------*/

                return Entities.view(connSpedmon, log, uInfo,
                    Entities.REC_VIEW_OBJECTS , // recViewType,
                    false ,  // pagedOrTop,

                    "1"    , //idx  is IGNORED at the UDF level; but this required in the middleware call

                    ""    , // canEdit,
                    "1" ,  //active,
                    viewUDF, ref parms, null, dc);

            };
            
            bool bUserCanSeePartnerData = userCanSeePartnerData(uInfo);

            ReturnObjects ro = new ReturnObjects();

            ro = Entities.viewObjects(connSpedmon
                                            , log
                                            , uInfo
                                            ,  ((bUserCanSeePartnerData) ? typeof(ClientInvoiceWithPartnerData) : typeof(ClientInvoice))
                                            , false // pageObjectList
                                            , pageOrder
                                            , dg
                                            ) ;


            return ro;
        }

        // the .view() and the .viewTotals() methods send the same params to the UDF call.
        public static void viewParams(
                               UserInfo uInfo  // permission validation for calcShares
                             , string clientID
                             , string startDateInvoiceRange
                             , string endDateInvoiceRange
                             , string invoicePaid
                             , string calcShares
                             , string distbpaid
                             , ref List<SqlParameter> parms
                             , string daterangeInvoiceRange = null

                             // , string  daterangeDistbPaidRange = null

                             // , string startDateDistbPaidRange  = null 
                             // , string endDateDistbPaidRange    = null

                             , string daterangeInvCollRange = null

                             , string startDateInvCollRange = null
                             , string endDateInvCollRange = null

                             , string  inclPartner1Col = "0"
                             , string  inclRetentionCol = "0"
                             , string  inclCybhiRows = "0"
                             , string  inclCybhiRowsOnly="0" 

            )
        {
             bool bUserCanSeePartnerData = userCanSeePartnerData(uInfo);
            
            var vClientID = Validate.optClientID(uInfo, clientID);

            var vStartDateInvoiceRange = Validate.optDate(startDateInvoiceRange, Messages.INVALID_START_DATE);
            var vEndDateInvoiceRange = Validate.optDate(endDateInvoiceRange, Messages.INVALID_END_DATE);


            var vStartDateInvCollRange = Validate.optDate(startDateInvCollRange, Messages.INVALID_START_DATE);
            var vEndDateInvCollRange = Validate.optDate(endDateInvCollRange, Messages.INVALID_END_DATE);

            var vInvoicePaid = Validate.optFlag(invoicePaid, Messages.INVALID_FLAG);

            if (!(Util.IsNullOrEmpty(daterangeInvoiceRange))) {

                var invoiceRangeDatesFromDateRange = Validate.reqDateRange(daterangeInvoiceRange, "invalid date range!");

                vStartDateInvoiceRange = invoiceRangeDatesFromDateRange[0];
                vEndDateInvoiceRange = invoiceRangeDatesFromDateRange[1];
            }

            if (!(Util.IsNullOrEmpty(daterangeInvCollRange)))
            {

                var distbPaidDatesFromDateRange = Validate.reqDateRange(daterangeInvCollRange, "invalid date range!");

                vStartDateInvCollRange = distbPaidDatesFromDateRange[0];
                vEndDateInvCollRange = distbPaidDatesFromDateRange[1];
            }

            var vDistributionPaid = Validate.optFlag(distbpaid, Messages.INVALID_FLAG);

            var vCalcShares = Validate.reqFlagOrUnknown(calcShares, "calculate shares?");

            var vInclPartner1Col = Validate.reqFlagOrUnknown(inclPartner1Col, "include partner1?");

            var vInclCybhiRows = Validate.reqFlagOrUnknown(inclCybhiRows, "include cybhi rows?");

            var vInclCybhiRowsOnly = Validate.reqFlagOrUnknown(inclCybhiRowsOnly, "include cybhi rows only?");

            var vInclRetentionCol = Validate.reqFlagOrUnknown( inclRetentionCol, "include client retention?" );

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@startDateInvoiceRange", SqlDbType.DateTime, vStartDateInvoiceRange, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@endDateInvoiceRange", SqlDbType.DateTime, vEndDateInvoiceRange, ParameterDirection.Input));

            //parms.Add(Database.SqlParm("@startDateDistbPaidRange", SqlDbType.DateTime, vStartDateDistbPaidRange, ParameterDirection.Input));
            //parms.Add(Database.SqlParm("@endDateDistbPaidRange", SqlDbType.DateTime, vEndDateDistbPaidRange, ParameterDirection.Input));


            parms.Add(Database.SqlParm("@startDateInvCollRange", SqlDbType.DateTime, vStartDateInvCollRange, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@endDateInvCollRange", SqlDbType.DateTime, vEndDateInvCollRange, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@invoicePaid", SqlDbType.Bit, vInvoicePaid, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@distributionPaid", SqlDbType.Bit, vDistributionPaid, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@calcShares", SqlDbType.Bit, vCalcShares, ParameterDirection.Input));

            parms.Add(Database.SqlParm( "@inclPartner1Col",   SqlDbType.Bit,         vInclPartner1Col,      ParameterDirection.Input));

            parms.Add(Database.SqlParm( "@inclRetentionCol", SqlDbType.Bit,  vInclRetentionCol, ParameterDirection.Input));

            parms.Add(Database.SqlParm( "@inclCybhi",         SqlDbType.Bit,         vInclCybhiRows,        ParameterDirection.Input));

            parms.Add(Database.SqlParm( "@inclCybhiOnly", SqlDbType.Bit, vInclCybhiRowsOnly, ParameterDirection.Input));


            // doublecheck permissions for calcShares here
            if (vCalcShares != null && (bool)vCalcShares && !(bUserCanSeePartnerData))
                throw new Warning("user does not have permissions to calculate partner shares.");

            if (vInclPartner1Col != null && (bool)vInclPartner1Col
              && (vCalcShares == null || (bool)vCalcShares == false)  // if inclPartner1Col is true, the calcShares param must be true and validated as permissible; error otherwise
            )
                throw new Warning("user does not have permissions to view partner1 data.");

            if (vInclRetentionCol != null && (bool)vInclRetentionCol
              && (vCalcShares == null || (bool)vCalcShares == false)  // if vInclRetentionCol is true, the calcShares param must be true and validated as permissible; error otherwise
            )
                throw new Warning("user does not have permissions to view retention amount.");

        }


        /***************************************************************************
          * view */
        /**
         * 
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , int recViewType
                                     , bool pagedOrTop
                                     , string idx
                                     , string canEdit
                                     , string active
                                     , string clientID
                                     , string startDateInvoiceRange
                                     , string endDateInvoiceRange
                                     , string  invoicePaid

                                     , defineCols dc     = null
                                     , string  calcShares  = "0"
                                     , string distbpaid = null

                                     //   , distbpaiddaterange

                                     , string invcolldaterange = null

                                     , string inclPartner1Col = null
                                     , string inclRetentionCol = null
                                     , string inclCybhiRows   = null
                                     , string inclCybhiRowsOnly = null
            )
        {

            string viewUDF = "dbo.CLIENT_INVOICES_VIEW (" +
                @"@userID, @userGroup, @userRank, @clientID, @startDateInvoiceRange, @endDateInvoiceRange, " +
                @"@invoicePaid, @distributionPaid, @startDateInvCollRange, @endDateInvCollRange, @calcShares, " +
                @"@inclPartner1Col, @inclRetentionCol, @inclCybhi, @inclCybhiOnly, @active, @recID)";

            /*----------------------------
            * Validate parameters specific
            * to this entity.view
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            viewParams(uInfo  // permission validation for calcShares
            , clientID
            , startDateInvoiceRange
            , endDateInvoiceRange
            , invoicePaid
            , calcShares
            , distbpaid
            , ref parms
            , null  // invoice date range as a daterange; using separate start and end date vals instead

            // , distbpaiddaterange
            , invcolldaterange  ,

            null,
            null

          , inclPartner1Col
          , inclRetentionCol 
          , inclCybhiRows
          , inclCybhiRowsOnly
            );

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
                                                  , string startDate
                                                  , string endDate
                                                  , string invoicePaid
                                                  , string calcShares
                                                  , string distbPaid

                                                  // , string distbPaidDateRange

                                                  , string invCollDateRange

                                                  , string inclPartner1Col 
                                                  , string inclRetentionCol
                                                  , string inclCybhiRows
                                                  , string inclCybhiRowsOnly
        )
        {
            bool bUserCanSeePartnerData = userCanSeePartnerData(uInfo);

            var b_calcShares = Validate.reqFlagOrUnknown(calcShares, "calc shares?");

            bool bCanCalcShares = false;

            if (bUserCanSeePartnerData == true)
            {
                bCanCalcShares = ((b_calcShares != null) && ((bool)b_calcShares));
            }
            else
            {
               bCanCalcShares = false;
            }

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ClientInvoice.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };
            
            ReturnObjects ro = new ReturnObjects();

            /* If the caller is a pcal admin then return the invoice with additional partner shares class */
            
            ro = Entities.viewObjects(connSpedmon
                                            , log
                                            , uInfo
                                            , ( ( bCanCalcShares == true )
                                                  ? typeof(ClientInvoiceWithPartnerData)
                                                  : typeof(ClientInvoice)  )
                                            , pageObjectList
                                            , pageOrder
                                            , delegate
                                            {
                                                return ClientInvoices.view(
                                                                           connSpedmon
                                                                         , log
                                                                         , uInfo
                                                                         , Entities.REC_VIEW_OBJECTS
                                                                         , pageObjectList
                                                                         , idx
                                                                         , "" // canEdit
                                                                         , active
                                                                         , clientID
                                                                         , startDate
                                                                         , endDate
                                                                         , invoicePaid
                                                                         //, disbPaid
                                                                         , dc
                                                                         , calcShares
                                                                         , distbPaid

                                                                         , invCollDateRange

                                                                         , inclPartner1Col
                                                                         , inclRetentionCol
                                                                         , inclCybhiRows
                                                                         , inclCybhiRowsOnly
                                                 );
                                            });
            

            return ro;
        }



        /***************************************************************************
         * viewTbl */
        /**
         * Returns a data table of records for preview or record selection.
         *
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable viewTbl(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
                                                   , bool paged
                                                   , string pageNumber
                                                   , string canEdit
                                                   , string active
                                                   , string clientID
                                                   , string startDate
                                                   , string endDate
                                                   , string invoicePaid

                                                   , string showClientName
                                                   , string showConsultantName

                                                   , string showBasicInvoiceData
                                                   , string showDistBreakdownsDollarAmounts

                                                   , string calcShares
                                                   , string distbpaid

                                                    , string invcolldaterange

                                                    , string inclPartner1Col
                                                    , string inclRetentionCol 
                                                    , string inclCybhiRows
                                                    , string inclCybhiRowsOnly
                                                    , string isCybhiDistScreen

        ) {
            ReturnDataTable so = new ReturnDataTable();

            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            bool bUserCanSeePartnerData = userCanSeePartnerData(uInfo);

            var bShowClientName       =  (bool) Validate.optFlag(showClientName, "show client name?", true);
            var bShowConsultantName   =  (bool) Validate.optFlag(showConsultantName, "show consultant name?", true);

            var bShowBasicInvoiceData  = (bool) Validate.optFlag(showBasicInvoiceData, "show basic invoice data?", true);
            var bShowDistBreakdownDollarAmounts = (bool)Validate.optFlag(showDistBreakdownsDollarAmounts, "show distribution breakdown?", true);

            var bIsCybhiDistScreen     = (bool) Validate.optFlag(isCybhiDistScreen, "is cybhi dist screen?", true);

            var bInclPartner1Col       = (bool) Validate.optFlag(inclPartner1Col, "incl partner1 col?", true);

            var bInclRetentionCol      = (bool) Validate.optFlag(inclRetentionCol, "incl retention col?", true);

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

                /* Pcal staff can see client and consultant*/


                if (uInfo.pcalStaff == true)    /// MOTE: notice the nested IFs here.  This same structure is implemented in the JS
                {
                    if (bShowClientName)
                    {
                        ss.addDisplayColumn("clientName           as [Client]");
                    }


                    if (bShowConsultantName)
                    {
                        ss.addDisplayColumn("consultant           as [Consultant]");
                    }

                    if (bUserCanSeePartnerData)
                    {
                        if ( !(bIsCybhiDistScreen) )
                            ss.addDisplayColumn("revenueCode   as [Revenue Code]");

                        ss.addDisplayColumn("revenueProgram   as [Revenue Program]");
                    }

                } /* pcal staff */

                ss.addDisplayColumn("invoiceNum    as  [Invoice Number]");

                if (bShowBasicInvoiceData || bInclPartner1Col)
                    ss.addDisplayColumn("invoiceAmt    as  [Invoice Amount]");


                ss.addDisplayColumn("invoiceDateStr      as  [Date Invoiced]");

                ss.addDisplayColumn("dateCollectedStr    as  [Date Collected]");

                if (bUserCanSeePartnerData) { 
                  ss.addDisplayColumn("depositDateStr      as  [Date Deposited]");
                }

                if ( bUserCanSeePartnerData
                        && (bShowDistBreakdownDollarAmounts || bInclPartner1Col)
                        && ( !(bIsCybhiDistScreen ))
                  ) { 

                      ss.addDisplayColumn("spEdCarePartners   as  [SpEdCare Share]");  //spEdCarePartners

                      //ss.addDisplayColumn("pcalShare          as  [PCal Share]");

                      ss.addDisplayColumn("accountingFee      as  [Accounting Fee]");
                }
 
                if (bUserCanSeePartnerData
                  && bInclPartner1Col )
                {
                      ss.addDisplayColumn("partner1Share      as  [Partner 1 Share]");
                      ss.addDisplayColumn("partner2Share      as  [Partner 2 Share]");
                }

                else if (bUserCanSeePartnerData
                   && bShowDistBreakdownDollarAmounts )
                {
                    ss.addDisplayColumn("partnerRevenue          as  [LEA BOP Revenue]");

                    ss.addDisplayColumn("partnerShareRevenue     as  [Partner Share Revenue]");

                    ss.addDisplayColumn("csbaShare          as  [CSBA Share]");

                    ss.addDisplayColumn("lbaShare           as  [LBA Share]");

                    //ss.addDisplayColumn("spEdCarePartners   as  [SpEdCare Share]");  //spEdCarePartners

                    ss.addDisplayColumn("mbaShare           as  [MBA Share]");

                    ss.addDisplayColumn("mbaBba             as  [MBA BBA/DG]");

                    //ss.addDisplayColumn("mbaDg              as  [MBA DG]");

                    ss.addDisplayColumn("spEdCareBba        as  [SpEdCare BBA/DG]");

                    ss.addDisplayColumn("distributedDateStr      as  [Date Distributed]");

                }

                if (bShowBasicInvoiceData)
                {

                    if (!bShowDistBreakdownDollarAmounts && bUserCanSeePartnerData )
                    {  // NOT condition, which prevents us from rendering this column twice (see below)

                        ss.addDisplayColumn("distributionNotes      as  [Distribution Notes]");  // rendered in modal, rather than the restview, in JS

                        
                    }

                }

                if (bInclRetentionCol && bUserCanSeePartnerData)
                { 
                    ss.addDisplayColumn("clientRetention      as [Client Retention]");
                }
                
                if (uInfo.pcalStaff == true)  // TODO! dyn show/hide notes col in js for widget
                {
                    ss.addDisplayColumn("notes            as [Notes]");
                }

                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * Call base method which
             * handles the rest
             *----------------------------*/

            so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
              delegate {
                  return ClientInvoices.view(connSpedmon
                                           , log
                                           , uInfo
                                           , Entities.REC_VIEW_TBL
                                           , paged
                                           , pageNumber
                                           , canEdit
                                           , active
                                           , clientID
                                           , startDate
                                           , endDate
                                           , invoicePaid
                                           , dc
                                           , calcShares
                                           , distbpaid

                                           // , distbpaiddaterange

                                           , invcolldaterange

                                           , inclPartner1Col
                                           , inclRetentionCol
                                           , inclCybhiRows
                                           , inclCybhiRowsOnly
                                           );
              });

            /*----------------------------
             * Add a title and footer
             *----------------------------*/

            so.tableName = "Invoices";
            so.tableFooter = Messages.CONFIDENTIAL;

            /*----------------------------
             * Done
             *----------------------------*/

            return so;
        }


        /***************************************************************************
         * save
         *
         * Save invoice notes
         * 
         ***************************************************************************/

        public static Return save(SqlConnection dbConnSpedmon
                                , DetailsLog log
                                , UserInfo uInfo
                                , string clientID

                                , string editDelReason
                                , string validateRec
                                , string saveType
                                , string recID

                                , string notes        

                                , bool updateNotesOnly     = true  // pencil icon onscreen allows editing the "notes" field only.
                                                                   // other fields are edited via the modal dialog, opened via the dollar-sign icon.

                                , bool updatePmtInfo          = false
                                , bool updateDepositDistInfo  = false

                                , string depositDate       = null
                                , string dateCollected     = null


                                , string amountPaid         = null

                                , string distributedDate    = null
                                , string distributionNotes  = null


         )  {

            string saveSproc = @"CLIENT_INVOICES_SAVE";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID                = Validate.reqClientID (uInfo, clientID);         
            List<SqlParameter> parms     = new List<SqlParameter>();

            var vNotes                  =   Validate.optString(notes, Messages.INVALID_NOTES);
            Object vDepositDate         =   Validate.optDate(depositDate, @"Invalid deposit Date.");
            Object vDateCollected       =   Validate.optDate(dateCollected, @"Invalid Date Collected.");
            var vAmountPaid             =   Validate.optUsdAmount(amountPaid, @"Invalid Amount Paid.");

            Object vDistributedDate     =   Validate.optDate(distributedDate, @"Invalid distributed date.");

            Object vDistributionNotes     = Validate.optString(distributionNotes, @"Distribution notes.");

            parms.Add( Database.SqlParm( "@clientID",      SqlDbType.BigInt, vClientID, ParameterDirection.Input));

            parms.Add(Database.SqlParm(  "@notes",         SqlDbType.VarChar, vNotes, ParameterDirection.Input, -1));

            parms.Add( Database.SqlParm( "@depositDate",   SqlDbType.Date, vDepositDate, ParameterDirection.Input));
            parms.Add( Database.SqlParm( "@dateCollected", SqlDbType.Date, vDateCollected, ParameterDirection.Input));
            parms.Add( Database.SqlParm( "@amountPaid",    SqlDbType.Money, vAmountPaid, ParameterDirection.Input));

            parms.Add( Database.SqlParm( "@distributionDate", SqlDbType.Date, vDistributedDate, ParameterDirection.Input));

            parms.Add(Database.SqlParm(  "@updateNotesOnly"   ,  SqlDbType.Bit,    updateNotesOnly     , ParameterDirection.Input));



            parms.Add(Database.SqlParm( "@updatePmtInfo"            , SqlDbType.Bit ,  updatePmtInfo         ,  ParameterDirection.Input ));
            parms.Add(Database.SqlParm( "@updateDepositDistribInfo" , SqlDbType.Bit ,  updateDepositDistInfo ,  ParameterDirection.Input ));

            // not supported from this method; use the other webmethod
            parms.Add(Database.SqlParm("@updateDepositDistribDateOnly", SqlDbType.Bit, null, ParameterDirection.Input));

            parms.Add(Database.SqlParm(  "@distributionNotes" ,  SqlDbType.VarChar, vDistributionNotes , ParameterDirection.Input, -1));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(dbConnSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }


        /***************************************************************************
         * saveBulkUpdateDistribDate */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord saveBulkUpdateDistribDate(
              SqlConnection connSpedmon
            , DetailsLog    log
            , UserInfo      uInfo
            , string        clientID
            , string        distbdate
            , string        editDelReason
            , string        validateRec
            , string        recIDs )
        {

            var parms = new List<SqlParameter>();

            var vClientID    =  Validate.optClientID(uInfo, clientID);

            var vDistbdate   =  Validate.reqDate(distbdate, "select date distributed");

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@distributionDate", SqlDbType.Date, vDistbdate, ParameterDirection.Input));

            return Entities.recordOpMulti (  connSpedmon
                                           , log
                                           , uInfo
                                           , editDelReason
                                           , validateRec                                           
                                           , recIDs  
                                           , "CLIENT_INVOICES_DISTRIBUTED_DATE_UPDATE_MULTI"
                                           , true 
                                           , ref parms);
        }

    }

}
