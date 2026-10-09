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
    /*****************************************************************************************************
     * IMPORTANT
     * 
     * For employee relationship, we are NOT going based off "dbo.EMPLOYMENT_RELATIONSHIPS"
     * Instead we have: 
     *      10: Employee
     *      20: Contractor
     *      30: Not on TSP
     *      40: Duplicate
     ******************************************************************************************************/
    public class CrcsPracSalary : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"crcsPracticeFamilyName asc, pracName asc";

        public long    clientID;
        public long    pracID;
        public long    fiscalYearID;
        public string  pracName;
        public string  pracTitle;
        public decimal hoursWorkedThisQuarter;
        public decimal salary;
        public decimal federalSalary;
        public string  federalSalaryResourceCode;
        public decimal benefits;
        public decimal federalBenefits;
        public string  grossAmount;
        public string  grossFederalAmount;
        public string  federalBenefitsResourceCode;
        public string  clientEmployeeID;
        public int     quarterNumber;
        public string  crcsPracticeFamilyName;
        public bool    pracParticipatedEntireQuarter;
        public string  pracRmtsParticipatedStartDateStr;
        public string  pracRmtsParticipatedEndDateStr;
        public int     employeeRelationshipID;
        public string  employeeRelationshipName;
        public bool    pracCanHaveCostsEntered;
        public bool    isEditable;

        public string  fiscalquarterSalaryExpenditures;
        public string  fiscalquarterBenefitExpenditures; 
    }


    public class CrcsPracAnnualRateRebasedSalaryPerHour : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"crcsPracticeFamilyName asc, pracName asc";

        public long clientID;
        public long pracID;
        public long fiscalYearID;

        public string pracName;

        public string qs_incl;

        public decimal expenditures;

        public int hoursWorked;

        public decimal SalaryExpenditures_money;

        public decimal BenefitExpenditures_money;

        public decimal per_hour;

        public string pracTitle;
        public string reportingGroup;

        public string crcsPracticeFamilyName;

    }

    public class CrcsPracSalaries : Entities
    {

        public const string URL_MANAGE       = @"user_all_crcs_salary_benefits_manage.aspx";

        public const string URL_WEB_SERVICE  = @"crcs_prac_salaries.asmx";

        public const string URL_SAVE            = URL_WEB_SERVICE + @"/save";

        public const string URL_SAVE_HOURS_FY   =  URL_WEB_SERVICE + @"/saveHoursWorked_FY";

        public const string URL_SAVE_OR_REPLACE_COMPLETED_FLAG = URL_WEB_SERVICE + @"/saveorreplacecompletedflag";
        public const string URL_LOAD_COMPLETED_FLAG            = URL_WEB_SERVICE + @"/loadcompletedflag";

        public const string URL_REST_VIEW    = @"api/v1/crcspracsalaries";

        public const string URL_REST_RATEREBASING_VIEW = @"api/v1/crcspracsalariesraterebasing";

        public const string URL_REPORT       = @"crcs_prac_salaries.ashx";

        public const string URL_SALARYBENEFITS_4QS = @"user_all_crcs_salary_benefits_manage.aspx";

        public const string URL_PAGE_RATE_REBASING = @"user_all_crcs_salary_benefits_rate_rebasing.aspx";


        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsPracSalaries.URL_REST_VIEW, true);
        }

        public static string URL_REST_VIEW_RATEREBASING_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsPracSalaries.URL_REST_RATEREBASING_VIEW, true);
        }

        public static string URL_SALARYBENEFITS_4QS_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsPracSalaries.URL_SALARYBENEFITS_4QS, true);
        }

        public static string URL_PAGE_RATE_REBASING_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsPracSalaries.URL_PAGE_RATE_REBASING, true);
        }

        /***************************************************************************
         * URL_MANAGE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsPracSalaries.URL_MANAGE, true);
        }        
        
        /***************************************************************************
         * URL_SAVE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsPracSalaries.URL_SAVE, true);
        }

        public static string URL_SAVE_HOURS_FY_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsPracSalaries.URL_SAVE_HOURS_FY, true);
        }

        public static string URL_REST_VIEW_REPORT()
        {
            return MBA.HttpApplication.createLink(CrcsPracSalaries.URL_REPORT, true);
        }

        public static string URL_SAVE_OR_REPLACE_COMPLETED_FLAG_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsPracSalaries.URL_SAVE_OR_REPLACE_COMPLETED_FLAG, true);
        }

        public static string URL_LOAD_COMPLETED_FLAG_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsPracSalaries.URL_LOAD_COMPLETED_FLAG, true);
        }

        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/
        /*****************************************************************************************************
         * IMPORTANT
         * 
         * For employee relationship, we are NOT going based off "dbo.EMPLOYMENT_RELATIONSHIPS"
         * Instead we have: 
         *      10: Employee
         *      20: Contractor
         *      30: Not on TSP
         *      40: Duplicate
         ******************************************************************************************************/
        public static ReturnDB view(SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , int recViewType
                                     , bool pagedOrTop
                                     , string idx
                                     , string canEdit
                                     , string active
                                     , string clientID
                                     , string fiscalYearID
                                     , string quarter
                                     , defineCols dc)
        {

            string viewUDF = "dbo.CRCS_PRAC_SALARIES_VIEW (@userID, @userGroup, @userRank, @clientID, @fiscalYearID, @quarter, @recID)";

            /*----------------------------
            * Validate parameters specific
            * to this entity.view
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/

            var vClientID     = Validate.optClientID(uInfo       , clientID);
            var vFiscalYearID = Validate.optInteger (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);
            var vQuarter      = Validate.optInteger (quarter     , Messages.INVALID_NUMBER);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"    , SqlDbType.BigInt, vClientID    , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID", SqlDbType.BigInt, vFiscalYearID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@quarter"     , SqlDbType.BigInt, vQuarter     , ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        public static ReturnDB viewRateRebasing(SqlConnection connSpedmon
                             , DetailsLog log
                             , UserInfo uInfo
                             , int recViewType
                             , bool pagedOrTop
                             , string idx
                             , string canEdit
                             , string active
                             , string clientID
                             , string fiscalYearID
                             //, string quarter
                             , defineCols dc)
        {

            string viewUDF = "dbo.CRCS_PRAC_SALARIES_RATE_REBASING_VIEW (@userID, @userGroup, @userRank, @clientID, @fiscalYearID, @recID)";

            /*----------------------------
            * Validate parameters specific
            * to this entity.view
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/

            var vClientID = Validate.optClientID(uInfo, clientID);
            var vFiscalYearID = Validate.optInteger(fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);
            //var vQuarter = Validate.optInteger(quarter, Messages.INVALID_NUMBER);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID", SqlDbType.BigInt, vFiscalYearID, ParameterDirection.Input));
            //parms.Add(Database.SqlParm("@quarter", SqlDbType.BigInt, vQuarter, ParameterDirection.Input));

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
        /*****************************************************************************************************
         * IMPORTANT
         * 
         * For employee relationship, we are NOT going based off "dbo.EMPLOYMENT_RELATIONSHIPS"
         * Instead we have: 
         *      10: Employee
         *      20: Contractor
         *      30: Not on TSP
         *      40: Duplicate
         ******************************************************************************************************/
        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string active
                                                  , string clientID
                                                  , string fiscalYearID
                                                  , string quarter
        )
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = CrcsPracSalary.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(CrcsPracSalary)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return CrcsPracSalaries.view(
                                                                         connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" // canEdit
                                                                       , active
                                                                       , clientID
                                                                       , fiscalYearID
                                                                       , quarter
                                                                       , dc
                                               );
                                          });
        }

        public static ReturnObjects viewObjectsRateRebasing(
                                                    SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string active
                                                  , string clientID
                                                  , string fiscalYearID
                                                  //, string quarter
        )
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = CrcsPracAnnualRateRebasedSalaryPerHour.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(CrcsPracAnnualRateRebasedSalaryPerHour)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return CrcsPracSalaries.viewRateRebasing(
                                                                         connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" // canEdit
                                                                       , active
                                                                       , clientID
                                                                       , fiscalYearID
                                                                       , dc
                                               );
                                          });
        }

        /***************************************************************************
        * save */
        /**
         * Save new or update existing record
         *
         * @param  userID          User id of who is recording service
         * @param  userGroup       1 = Client, 2 = SBSC (from users db)
         * @param  userRank        Users role ranking
         * @param  clientID        Client id
         * @param  editDelReason   Reason for record edit or delete
         * @param  validateRec     1 = Performs data integrity validation tasks
         *                             Perform advisory validation tasks that can
         *                             only be conducted by referencing data from the
         *                             database and then exits WITHOUT saving the record
         *                         0 = Peform data integrity validation tasks and
         *                             if these tasks succeed peforms the desired
         *                             operation (saveType) on the record and exits
         * @param  saveType        Type of operation to perform
         *                         1 = New, 2 = Edit, 3 = Delete
         * @param  recID           Record id of existing patient record to edit or
         *                         delete.
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/
        /*****************************************************************************************************
         * IMPORTANT
         * 
         * For employee relationship, we are NOT going based off "dbo.EMPLOYMENT_RELATIONSHIPS"
         * Instead we have: 
         *      10: Employee
         *      20: Contractor
         *      30: Not on TSP
         *      40: Duplicate
         ******************************************************************************************************/
        public static ReturnSaveRecord save(SqlConnection connSpedmon
                                             , DetailsLog log
                                             , UserInfo uInfo
                                             , string clientID
                                             , string pracID  
                                             , string fiscalYearID
                                             , string quarterNumber
                                             , string employeeRelationshipID
                                             //, string hoursWorkedThisQuarter
                                             , string salary                     
                                             , string federalSalary				
                                             , string federalSalaryResourceCode 	
                                             , string benefits                  	
                                             , string federalBenefits
                                             , string federalBenefitsResourceCode
                                             , string clientEmployeeID
                                             , string editDelReason
                                             , string validateRec
                                             , string saveType
                                             , string recID)
        {

            string saveSproc = @"CRCS_PRAC_SALARY_SAVE";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID                    = Validate.reqClientID    (uInfo                      , clientID);
            var vPracID                      = Validate.reqInteger     (pracID                     , Messages.INVALID_PRAC_ID);
            var vFiscalYearID                = Validate.reqInteger     (fiscalYearID               , Messages.INVALID_FISCAL_YEAR_ID);
            var vQuarterNumber               = Validate.reqInteger     (quarterNumber              , Messages.INVALID_NUMBER);
            var vEmployeeRelationshipID      = Validate.reqInteger     (employeeRelationshipID     , Messages.INVALID_EMPLOYEE_RELATIONSHIP);
            //var vHoursWorkedThisQuarter      = Validate.reqFixedAmount (hoursWorkedThisQuarter     , @"Invalid number of hours");
            var vSalary                      = Validate.optUsdAmount   (salary                     , Messages.INVALID_DOLLAR_AMT);
            var vFederalSalary               = Validate.optUsdAmount   (federalSalary              , Messages.INVALID_DOLLAR_AMT);
            var vFederalSalaryResourceCode   = Validate.optString      (federalSalaryResourceCode  , Messages.INVALID_TEXT);
            var vBenefits                    = Validate.optUsdAmount   (benefits                   , Messages.INVALID_DOLLAR_AMT);
            var vFederalBenefits             = Validate.optUsdAmount   (federalBenefits            , Messages.INVALID_DOLLAR_AMT);
            var vFederalBenefitsResourceCode = Validate.optString      (federalBenefitsResourceCode, Messages.INVALID_TEXT);
            var vClientEmployeeID            = Validate.optString      (clientEmployeeID           , Messages.INVALID_EMPLOYEE_ID);


            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"                   , SqlDbType.BigInt , vClientID                    , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@pracID"                     , SqlDbType.BigInt , vPracID                      , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@fiscalYearID"               , SqlDbType.BigInt , vFiscalYearID                , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@quarterNumber"              , SqlDbType.Int    , vQuarterNumber               , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@employeeRelationshipID"     , SqlDbType.Int    , vEmployeeRelationshipID      , ParameterDirection.Input    ));
            //parms.Add(Database.SqlParm("@hoursWorkedThisQuarter"     , SqlDbType.Money  , vHoursWorkedThisQuarter      , ParameterDirection.Input    ));
            
            parms.Add(Database.SqlParm("@salary"                     , SqlDbType.Money  , vSalary                      , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@federalSalary"              , SqlDbType.Money  , vFederalSalary               , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@federalSalaryResourceCode"  , SqlDbType.VarChar, vFederalSalaryResourceCode   , ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@benefits"                   , SqlDbType.Money  , vBenefits                    , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@federalBenefits"            , SqlDbType.Money  , vFederalBenefits             , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@federalBenefitsResourceCode", SqlDbType.VarChar, vFederalBenefitsResourceCode , ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@clientEmployeeID"           , SqlDbType.VarChar, vClientEmployeeID            , ParameterDirection.Input, 500));


            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }


        public static ReturnSaveRecord saveHoursWorked_FY(
                                               SqlConnection connSpedmon
                                             , DetailsLog log
                                             , UserInfo uInfo

                                             , string clientID
                                             , string pracID
                                             , string fiscalYearID

                                             , string hoursWorked

                                             //, string editDelReason
                                             //, string validateRec

                                             , string recID)
        {

            //trying to force this to work; don't know if we already have an "insert or update" pattern for simple sprocs

            string saveType;
            if (recID == "0") {
                
              saveType = "1";
              recID    = null;
              
            }
            else
              saveType = "2";

            string saveSproc = @"CRCS_PRAC_HOURS_FY_SAVE";

            var vClientID = Validate.reqClientID(uInfo, clientID);
            var vPracID = Validate.reqInteger(pracID, Messages.INVALID_PRAC_ID);
            var vFiscalYearID = Validate.reqInteger(fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);

            var vHoursWorkd = Validate.reqInteger(hoursWorked, "enter hours", true);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.BigInt, vPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID", SqlDbType.BigInt, vFiscalYearID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@hoursWorked",  SqlDbType.BigInt, vHoursWorkd, ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(connSpedmon, log, uInfo, saveType , "0" /* validateRec */, "" /* editDelReason */, recID, saveSproc, "dup" /* dupRecMsg */, ref parms, null);
        }

        /***************************************************************************
        * reactivateValidRecords */
        /**
         * Reactivates CRCS salary records for practitioners who have new service records
         * if 1. records were entered for them in the past and 2. they have no active
         * current CRCS salary records
         *
         * the reason we had to do this was because of rapid changes in DHCS' 
         * CRCS requirements
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/
        public static ReturnDB reactivateValidRecords(SqlConnection connSpedmon
                                             , DetailsLog log
                                             , UserInfo uInfo
                                             , string clientID
                                             , string fiscalYearID
                                             , string quarterNumber)
        {

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID                    = Validate.optClientID  (uInfo                      , clientID);
            var vFiscalYearID                = Validate.optInteger   (fiscalYearID               , Messages.INVALID_FISCAL_YEAR_ID);
            var vQuarterNumber               = Validate.optInteger   (quarterNumber              , Messages.INVALID_NUMBER);


            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"                   , SqlDbType.BigInt , vClientID                    , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@fiscalYearID"               , SqlDbType.BigInt , vFiscalYearID                , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@quarterNumber"              , SqlDbType.Int    , vQuarterNumber               , ParameterDirection.Input    ));

            Entities.validateAndAddCommonUserInfoParameters(uInfo, ref parms);

            ReturnDB rd = Database.execSproc(connSpedmon, log, "CRCS_PRAC_SALARIES_REACTIVATE_VALID_RECORDS", parms);

            return rd;
        }




        public static ReturnDataTable viewTblRateRebasing(SqlConnection connSpedmon
                                           , DetailsLog log
                                           , UserInfo uInfo
                                           , bool paged
                                           , string pageNumber
                                           , string clientID
                                           , string fiscalYearID
                                           //, string quarter
                                           , string canEdit
                                           , string active)
        {
            ReturnDataTable so = new ReturnDataTable();


            /*###########################################################################
              # Define our display columns and set the page order.  Page order needs to
              # be in the same sort order as the udf called in the view.
              ###########################################################################*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("pracName                    as [Practitioner]", true);


                ss.addDisplayColumn("pracTitle                    as [Practitioner Title]");
                ss.addDisplayColumn("reportingGroup               as [Reporting Group]");


                ss.addDisplayColumn("qs_incl                     as [CRCS Fiscal Quarters]");
                ss.addDisplayColumn("SalaryExpenditures_money    as [Salary Total Fiscal Year]");

                ss.addDisplayColumn("BenefitExpenditures_money   as [Benefits Total Fiscal Year]");
                ss.addDisplayColumn("expenditures                as [PayrollCosts Total Fiscal Year]");

                ss.addDisplayColumn("hoursWorked                 as [Total Number of Hours Worked This Fiscal Year]");
                ss.addDisplayColumn("per_hour                    as [Per Hour]");

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
                        CrcsPracSalaries.viewRateRebasing(connSpedmon
                                                            , log
                                                            , uInfo
                                                            , Entities.REC_VIEW_TBL
                                                            , paged
                                                            , pageNumber
                                                            , canEdit
                                                            , active
                                                            , clientID
                                                            , fiscalYearID
                                                            //, quarter
                                                            , dc);
                                  });


            so.tableFooter = Messages.CONFIDENTIAL;

            return so;

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
                                           , string        fiscalYearID
                                           , string        quarter
                                           , string        canEdit
                                           , string        active )
        {
         ReturnDataTable so = new ReturnDataTable();
         
         /*###########################################################################
           # We need to get the client id for client users because we call the client
           # load method.  Practi-cal users pass the client ID (which is required)
           # so this helps validate that.
           ###########################################################################*/  

         var vClientID = Validate.reqClientID (uInfo, clientID);
         clientID = vClientID.ToString();

         /*###########################################################################
           # Define our display columns and set the page order.  Page order needs to
           # be in the same sort order as the udf called in the view.
           ###########################################################################*/  

         defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
         {       
           ss.addDisplayColumn("pracName                    as [Practitioner]", true);
           ss.addDisplayColumn("crcsPracticeFamilyName      as [CRCS Practice \n Family]");
           ss.addDisplayColumn("employeeRelationshipName    as [Employee Status]");

           ss.addDisplayColumn("fiscalquarterSalaryExpenditures     as [Salary Expenditures]");


           ss.addDisplayColumn("salary                      as [Gross Salary \n (Object Code 1000-2999)]");
           ss.addDisplayColumn("federalSalary               as [Federal Salary \n 3000-5999]");
           ss.addDisplayColumn("federalSalaryResourceCode   as [Federal Resource \n Code]");

           ss.addDisplayColumn("fiscalquarterBenefitExpenditures    as [Benefit Expenditures]");


           ss.addDisplayColumn("benefits                    as [Gross Benefits \n (Object Code 3000-3999)]");
           ss.addDisplayColumn("federalBenefits             as [Federal portion of \n gross benefits]");
           ss.addDisplayColumn("federalBenefitsResourceCode as [Federal Resource \n Code]");
           ss.addDisplayColumn("clientEmployeeID            as [Employee ID / Notes]");
           ss.addDisplayColumn("grossAmount                 as [Gross Amount]");
           ss.addDisplayColumn("grossFederalAmount          as [Gross Fed Amount]");

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
                                 CrcsPracSalaries.view (  connSpedmon
                                                                     , log
                                                                     , uInfo
                                                                     , Entities.REC_VIEW_TBL
                                                                     , paged
                                                                     , pageNumber
                                                                     , canEdit
                                                                     , active
                                                                     , clientID
                                                                     , fiscalYearID
                                                                     , quarter
                                                                     , dc); 
                                });
   
         /*###########################################################################
           # Add a title and footer to ReturnDataTable then return
           ###########################################################################*/  

         var c = Clients.load(connSpedmon, log, uInfo, clientID);
         var fy = CompanyFiscalYears.load(connSpedmon, log, uInfo, fiscalYearID);

         so.tableName   = @"CRCS Salary & Benefits For " 
                        + c.name 
                        + @", " + fy.name 
                        + @", Quarter " + quarter;
         so.tableFooter = Messages.CONFIDENTIAL;
             
         return so;
         
        }

    }
}
