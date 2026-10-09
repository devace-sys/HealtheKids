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
    public class CRCSCompletionReportForAllClientsEntity : Entity
    {
        public long   rowNumber;
        public string clientName;
        public bool   crcsPracSalariesCompletedQ1;
        public bool   crcsPracSalariesCompletedQ2;
        public bool   crcsPracSalariesCompletedQ3;
        public bool   crcsPracSalariesCompletedQ4;
        public bool   crcsPracSalariesCompleted;
        public bool   crcsOtherCostsCompleted;
        public bool   crcsContractorCostsCompleted;
        public bool   crcsMedEquipmentDepreciationCostsCompleted;
        public bool   crcsTransportationPersonnelCostsCompleted;
        public bool   crcsTransportationOtherCostsCompleted;
        public bool   crcsTransportationEquipmentDepreciationCostsCompleted;
        public bool   crcsTransportationCompleted;
        public bool   crcsProgramInfoCompleted;
    }


    public class CRCSCompletionReportForAllClients : Entities
    {
        public static string URL_ASHX = @"crcs_completion_rpt_for_all_clients.ashx";

        public static string URL_ASHX_BASE()
        {
            return MBA.HttpApplication.createLink(CRCSCompletionReportForAllClients.URL_ASHX, true);
        }
        public static ReturnDataTable viewRpt(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo
                                            , bool paged
                                            , string pageNumber
                                            , string fiscalYearID
        )
        {

            var vFiscalYearID = Validate.optInteger(fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);

            List<SqlParameter> parameters = new List<SqlParameter>();

            parameters.Add(Database.SqlParm("@fiscalYearID", SqlDbType.BigInt, vFiscalYearID, ParameterDirection.Input));

            string reportUDF = "dbo.CRCS_CLIENT_COMPLETION_STATUS_RPT_VIEW (@userID, @userGroup, @userRank, @fiscalYearID, @recID)";

            /*----------------------------                              
             * Define our columns and                                    
             * set the page order for                                
             * paging                                                      
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

                ss.addDisplayColumn("rowNumber                                             as [#]", true);
                ss.addDisplayColumn("clientName                                            as [Client]");
                ss.addDisplayColumn("crcsPracSalariesCompletedQ1                           as [Salary & Benefits (Q1)]");
                ss.addDisplayColumn("crcsPracSalariesCompletedQ2                           as [Salary & Benefits (Q2)]");
                ss.addDisplayColumn("crcsPracSalariesCompletedQ3                           as [Salary & Benefits (Q3)]");
                ss.addDisplayColumn("crcsPracSalariesCompletedQ4                           as [Salary & Benefits (Q4)]");
                ss.addDisplayColumn("crcsPracSalariesCompleted                             as [Salary & Benefits (all quarters)]");
                ss.addDisplayColumn("crcsOtherCostsCompleted                               as [Other Costs]");
                ss.addDisplayColumn("crcsContractorCostsCompleted                          as [Contractor Costs]");
                ss.addDisplayColumn("crcsMedEquipmentDepreciationCostsCompleted            as [Medical Equipment Depreciation]");
                ss.addDisplayColumn("crcsTransportationPersonnelCostsCompleted             as [Transportation Personnel Costs]");
                ss.addDisplayColumn("crcsTransportationOtherCostsCompleted                 as [Transportation Other Costs]");
                ss.addDisplayColumn("crcsTransportationEquipmentDepreciationCostsCompleted as [Transportation Equipment Depreciation]");
                ss.addDisplayColumn("crcsTransportationCompleted                           as [Transportation (all categories)]");
                ss.addDisplayColumn("crcsProgramInfoCompleted                              as [Program Info]");

                pageroworder = ss.pageRowOrder();
            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/
            /* Store the ReturnDataTable object that is returned from the base method call into a local variable versus returning the call to base method */

            return Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, parameters, null, dc, "CRCS COMPLETION REPORT FOR ALL CLIENTS", "");
        }

    }
}

