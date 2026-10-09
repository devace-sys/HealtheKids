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
    /***************************************************************************
     * CRCSCompletionStatus  */
    /**
     * Used for summary reporting
     ***************************************************************************/
    public class CRCSCompletionReportEntity : Entity
    {
        public long clientID;
        public long pracID;
        public long fiscalYearID;
        public int displayOrder;
        public long grpSvcClassNameID;
        public string grpSvcClassName;
        public decimal salary;
        public decimal benefits;
        public decimal federalRevenues;
        public string federalResourceCodes;
        public decimal materialsAndSupplies;
        public decimal nonCapitalizedEquipment;
        public decimal travelAndConference;
        public decimal duesAndMembership;
        public decimal communications;
        public decimal contractorCosts5800;
        public decimal contractorCosts5100;
        public decimal federalResourceAmounts;
        public decimal hoursPaid;
        public decimal avgContractRatePerHour;
    }


    public class CRCSCompletionReport : Entities
    {
        public static string URL_ASHX = @"crcs_completion_rpt.ashx";

        public static string URL_ASHX_BASE()
        {
            return MBA.HttpApplication.createLink(CRCSCompletionReport.URL_ASHX, true);
        }
        public static ReturnDataTable viewRpt(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo
                                            , bool paged
                                            , string pageNumber
                                            , string clientID
                                            , string fiscalYearID
        )
        {

            var vClientID = Validate.optClientID(uInfo, clientID);
            var vFiscalYearID = Validate.optInteger(fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);

            List<SqlParameter> parameters = new List<SqlParameter>();

            parameters.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parameters.Add(Database.SqlParm("@fiscalYearID", SqlDbType.BigInt, vFiscalYearID, ParameterDirection.Input));

            string reportUDF = "dbo.CRCS_COMPLETION_TOTALS_RPT_VIEW (@userID, @userGroup, @userRank, @clientID, @fiscalYearID, @recID)";

            /*----------------------------                              
             * Define our columns and                                    
             * set the page order for                                
             * paging                                                      
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

                ss.addDisplayColumn("grpSvcClassName                       as [Practitioner Type]", true);

                ss.addDisplayColumn("seperator                             as [Begin Salary Q1]");

                ss.addDisplayColumn("salaryExpenditures1                   as [Salary Expenditures]");
                ss.addDisplayColumn("benefitExpenditures1                  as [Benefit Expenditures]");
                ss.addDisplayColumn("totalOtherCosts1                      as [Total Other Costs]");
                ss.addDisplayColumn("federalRevenues1                      as [Federal Revenues]");
                ss.addDisplayColumn("federalResourceCodes1                 as [Revenue Account Number(s)]");
                ss.addDisplayColumn("netPersonalCosts1                     as [Net Personnel Costs]");
                                                                           
                ss.addDisplayColumn("seperator                             as [End Salary Q1 / Begin Salary Q2]");

                ss.addDisplayColumn("salaryExpenditures2                   as [Salary Expenditures]");
                ss.addDisplayColumn("benefitExpenditures2                  as [Benefit Expenditures]");
                ss.addDisplayColumn("totalOtherCosts2                      as [Total Other Costs]");
                ss.addDisplayColumn("federalRevenues2                      as [Federal Revenues]");
                ss.addDisplayColumn("federalResourceCodes2                 as [Revenue Account Number(s)]");
                ss.addDisplayColumn("netPersonalCosts2                     as [Net Personnel Costs]");

                ss.addDisplayColumn("seperator                             as [End Salary Q2 / Begin Salary Q3]");

                ss.addDisplayColumn("salaryExpenditures3                   as [Salary Expenditures]");
                ss.addDisplayColumn("benefitExpenditures3                  as [Benefit Expenditures]");
                ss.addDisplayColumn("totalOtherCosts3                      as [Total Other Costs]");
                ss.addDisplayColumn("federalRevenues3                      as [Federal Revenues]");
                ss.addDisplayColumn("federalResourceCodes3                 as [Revenue Account Number(s)]");
                ss.addDisplayColumn("netPersonalCosts3                     as [Net Personnel Costs]");

                ss.addDisplayColumn("seperator                             as [End Salary Q3 / Begin Salary Q4]");

                ss.addDisplayColumn("salaryExpenditures4                   as [Salary Expenditures]");
                ss.addDisplayColumn("benefitExpenditures4                  as [Benefit Expenditures]");
                ss.addDisplayColumn("totalOtherCosts4                      as [Total Other Costs]");
                ss.addDisplayColumn("federalRevenues4                      as [Federal Revenues]");
                ss.addDisplayColumn("federalResourceCodes4                 as [Revenue Account Number(s)]");
                ss.addDisplayColumn("netPersonalCosts4                     as [Net Personnel Costs]");

                ss.addDisplayColumn("seperator                             as [End Salary Q4 / Begin Other Costs]");

                ss.addDisplayColumn("materialsAndSupplies                  as [Materials and Supplies]");
                ss.addDisplayColumn("nonCapitalizedEquipment               as [Equipment]");
                ss.addDisplayColumn("travelAndConference                   as [Travel]");
                ss.addDisplayColumn("duesAndMembership                     as [Dues]");
                ss.addDisplayColumn("communications                        as [Communications]");
                ss.addDisplayColumn("otherFederalCosts                     as [Federal Revenues]");
                ss.addDisplayColumn("otherFederalResourceCodes             as [Federal Revenue Codes]");
                                                                           
                ss.addDisplayColumn("seperator                             as [End Other Costs / Begin Contractor]");
                                                                           
                ss.addDisplayColumn("contractorCosts5800                   as [Contractor Costs (5800)]");
                ss.addDisplayColumn("contractorCosts5100                   as [Contractor Costs (5100)]");
                ss.addDisplayColumn("federalResourceAmounts                as [Federal Contractor Costs]");
                ss.addDisplayColumn("hoursPaid                             as [Total Hours Paid]");
                ss.addDisplayColumn("avgContractRatePerHour                as [Avg Contract Rate Per Hour]");
                                                                           
                ss.addDisplayColumn("seperator                             as [End Contractor / Begin Medical Equipment]");
                                                                           
                ss.addDisplayColumn("medEqAssetID                          as [Asset ID]");
                ss.addDisplayColumn("medEqAssetType                        as [Asset Type]");
                ss.addDisplayColumn("medEqPlacedInServiceOnStr             as [Month/Year Placed in Service]");
                ss.addDisplayColumn("medEqYearsUseful                      as [Years if Useful Life]");
                ss.addDisplayColumn("medEqDepreciableCost                  as [Depreciable Cost]");
                ss.addDisplayColumn("medEqFedResourceOrGrant               as [Federal Resources or Grants]");
                ss.addDisplayColumn("medEqResourceCodeAcctNum              as [Resource Code Account Numbers]");
                ss.addDisplayColumn("medEqAnnualDepreciation               as [Annual Straight-Line Depreciation]");
                ss.addDisplayColumn("medEqRetiredDuringCostPeriod          as [Was the Asset Retired During the Cost Report Period?]");
                ss.addDisplayColumn("medEqPlacedOutOfServiceOnStr          as [Month/Year Placed Out Of Service]");
                ss.addDisplayColumn("medEqAccumulatedDepreciation          as [Prior Period Accumulated Depreciation]");
                ss.addDisplayColumn("medEqDepreciationForReportPeriod      as [Depreciation for Reporting Period]");
                                                                           
                ss.addDisplayColumn("seperator                             as [End Medical Equipment / Begin Transportation Personnel]");
                                                                           
                ss.addDisplayColumn("jobCategory                           as [Job Category]");
                ss.addDisplayColumn("totalSalaries                         as [Total Salaries]");
                ss.addDisplayColumn("salaryRatio                           as [Salary Ratio]");
                ss.addDisplayColumn("totalBenefits                         as [Total Benefits]");
                ss.addDisplayColumn("benefitsRatio                         as [Benefits Ratio]");
                ss.addDisplayColumn("transPersonnelFedResourceOrGrant      as [Expenditures from Federal Resources or Grants]");
                ss.addDisplayColumn("federalRatio                          as [Federal Ratio]");
                                                                           
                ss.addDisplayColumn("seperator                             as [End Transportation Personnel / Begin Transportation Other]");
                                                                           
                ss.addDisplayColumn("description                           as [Description]");
                ss.addDisplayColumn("grossCosts                            as [Gross Costs]");
                ss.addDisplayColumn("grossRatio                            as [Gross Ratio]");
                ss.addDisplayColumn("expenditures                          as [Expenditures]");
                ss.addDisplayColumn("expendituresRatio                     as [Federal Ratio]");
                                                                           
                ss.addDisplayColumn("seperator                             as [End Transportation Other / Begin Transportation Medical Equipment]");

                ss.addDisplayColumn("transMedEqAssetID                     as [Asset ID]");
                ss.addDisplayColumn("transMedEqAssetType                   as [Asset Type]");
                ss.addDisplayColumn("transMedEqPlacedInServiceOnStr        as [Month/Year Placed in Service]");
                ss.addDisplayColumn("transMedEqYearsUseful                 as [Years if Useful Life]");
                ss.addDisplayColumn("transMedEqDepreciableCost             as [Depreciable Cost]");
                ss.addDisplayColumn("transMedEqFedResourceOrGrant          as [Federal Resources or Grants]");
                ss.addDisplayColumn("transMedEqAnnualDepreciation          as [Annual Straight-Line Depreciation]");
                ss.addDisplayColumn("transMedEqRetiredDuringCostPeriod     as [Was the Asset Retired During the Cost Report Period?]");
                ss.addDisplayColumn("transMedEqPlacedOutOfServiceOnStr     as [Month/Year Placed Out Of Service]");
                ss.addDisplayColumn("transMedEqAccumulatedDepreciation     as [Prior Period Accumulated Depreciation]");
                ss.addDisplayColumn("transMedEqDepreciationForReportPeriod as [Depreciation for Reporting Period]");
                ss.addDisplayColumn("transMedEqDepreciationForReportPeriodRatio as [Depreciation Ratio]");

                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * table name
             *----------------------------*/

            var c = Clients.load(connSpedmon, log, uInfo, vClientID.ToString());
            var fy = CompanyFiscalYears.load(connSpedmon, log, uInfo, vFiscalYearID.ToString());

            var viewtitle = @"CRCS Completion Report For "
                            + c.name
                            + @", " + fy.name;

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/
            /* Store the ReturnDataTable object that is returned from the base method call into a local variable versus returning the call to base method */

            return Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, parameters, null, dc, viewtitle, "");
        }

    }
}

