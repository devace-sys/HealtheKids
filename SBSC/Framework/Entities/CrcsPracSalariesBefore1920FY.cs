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
    public class CrcsPracSalaryBefore1920FY : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"crcsPracticeFamilyName asc, pracName asc";

        public long    clientID;
        public long    pracID;
        public long    fiscalYearID;
        public long    employeeRelationshipID;
        public string  pracName;
        public string  pracTitle;
        public decimal salary;
        public decimal federalSalary;
        public string  federalSalaryResourceCode;
        public decimal benefits;
        public decimal federalBenefits;
        public string  grossAmount;
        public string  grossFederalAmount;
        public string  federalBenefitsResourceCode;
        public string  clientEmployeeID;
        public string  crcsPracticeFamilyName;
    }

    public class CrcsPracSalariesBefore1920FY : Entities
    {
        public const string URL_MANAGE       = @"user_all_crcs_salary_benefits_before_19_20_fy_manage.aspx";

        public const string URL_WEB_SERVICE  = @"crcs_prac_salaries_before_19_20_fy.asmx";
        public const string URL_SAVE         = URL_WEB_SERVICE + @"/save";

        public const string URL_REST_VIEW    = @"api/v1/crcspracsalariesbefore1920fy";

        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsPracSalariesBefore1920FY.URL_REST_VIEW, true);
        }        
        
        /***************************************************************************
         * URL_MANAGE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsPracSalariesBefore1920FY.URL_MANAGE, true);
        }        
        
        /***************************************************************************
         * URL_SAVE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsPracSalariesBefore1920FY.URL_SAVE, true);
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
                                     , defineCols dc)
        {

            string viewUDF = "dbo.CRCS_PRAC_SALARIES_BEFORE_19_20_FY_VIEW (@userID, @userGroup, @userRank, @clientID, @fiscalYearID, @recID)";

            /*----------------------------
            * Validate parameters specific
            * to this entity.view
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/

            var vClientID     = Validate.optClientID(uInfo       , clientID);
            var vFiscalYearID = Validate.optInteger (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"    , SqlDbType.BigInt, vClientID    , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID", SqlDbType.BigInt, vFiscalYearID, ParameterDirection.Input));

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
        )
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = CrcsPracSalaryBefore1920FY.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(CrcsPracSalaryBefore1920FY)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return CrcsPracSalariesBefore1920FY.view(
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
                                             , string employeeRelationshipID
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
            string saveSproc = @"CRCS_PRAC_SALARIES_BEFORE_19_20_FY_SAVE";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID                    = Validate.reqClientID  (uInfo                      , clientID);
            var vPracID                      = Validate.reqInteger   (pracID                     , Messages.INVALID_PRAC_ID);
            var vFiscalYearID                = Validate.reqInteger   (fiscalYearID               , Messages.INVALID_FISCAL_YEAR_ID);
            var vEmployeeRelationshipID      = Validate.reqInteger   (employeeRelationshipID     , Messages.INVALID_EMPLOYEE_RELATIONSHIP);
            var vSalary                      = Validate.optUsdAmount (salary                     , Messages.INVALID_DOLLAR_AMT);
            var vFederalSalary               = Validate.optUsdAmount (federalSalary              , Messages.INVALID_DOLLAR_AMT);
            var vFederalSalaryResourceCode   = Validate.optString    (federalSalaryResourceCode  , Messages.INVALID_TEXT);
            var vBenefits                    = Validate.optUsdAmount (benefits                   , Messages.INVALID_DOLLAR_AMT);
            var vFederalBenefits             = Validate.optUsdAmount (federalBenefits            , Messages.INVALID_DOLLAR_AMT);
            var vFederalBenefitsResourceCode = Validate.optString    (federalBenefitsResourceCode, Messages.INVALID_TEXT);
            var vClientEmployeeID            = Validate.optString    (clientEmployeeID           , Messages.INVALID_EMPLOYEE_ID);


            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"                   , SqlDbType.BigInt , vClientID                    , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@pracID"                     , SqlDbType.BigInt , vPracID                      , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@fiscalYearID"               , SqlDbType.BigInt , vFiscalYearID                , ParameterDirection.Input    ));
            parms.Add(Database.SqlParm("@employeeRelationshipID"     , SqlDbType.BigInt , vEmployeeRelationshipID      , ParameterDirection.Input    ));
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

    }
}
