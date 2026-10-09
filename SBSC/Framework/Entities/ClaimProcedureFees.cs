using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * ClaimProcedure */
    /**
     **************************************************************************/
    public class ClaimProcedureFee : Entity
    {
        public decimal fee;
        public int     procID;

    }
    /***************************************************************************
     * ClaimProceduresFees */
    /**
     ***************************************************************************/

    public class ClaimProcedureFees : Entities
    {

        public const string MENU_ID_SERVICE_FEES_UPDATE           = @"claimproceduresservicefeesupdatelnk";
        public const string SEL_LABEL_SERVICE_FEES_UPDATE         = @"Claim Procedures Service Fees Update";
        public const string URL_SERVICE_FEES_UPDATE               = @"sbs_all_claim_procedures_service_fees_update.aspx";   
        public const string URL_WEB_SVC_BASE                      = @"claimprocedurefees.asmx";  
        public const string URL_WEB_SVC_SERVICE_FEES_UPDATE_BASE  = URL_WEB_SVC_BASE + @"/updateservicefees";

        /***************************************************************************
         * URL_WEB_SVC_SERVICE_FEES_UPDATE */
        /**
         ***************************************************************************/

        public static string URL_WEB_SVC_SERVICE_FEES_UPDATE()
        {
          return MBA.HttpApplication.createLink(  URL_WEB_SVC_SERVICE_FEES_UPDATE_BASE , true);
        }

        /***************************************************************************
         * delete */
        /**
         * "Deletes" a practitioner record
         * 
         * @param  editDelReason   Reason for edit/delete 
         * @param  validateRec     Perform validation for this record?
         * @param  recID           Record id reference for edit and delete
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord delete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                               string editDelReason, string validateRec, string recID)
        {


            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * delete method.
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            /*----------------------------
             * Call base method 
             *----------------------------*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "CLAIM_PROCEDURE_FEES_Delete", ref parms);
        }

        /***************************************************************************
        * load */
        /**
         * Outputs data for a single claim procedure fee
         *         
         * 
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object        
         * @return                 ReturnEntity
         ***************************************************************************/

        public static ClaimProcedureFee load(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                         string recID)
        {
            return (ClaimProcedureFee)Entities.load(connSpedmon, log, uInfo, recID, typeof(ClaimProcedureFee),
            delegate { return ClaimProcedureFees.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", null,null,null, "", null); });
        }


        /***************************************************************************
        * view */
        /**
         * Returns a list of Claim Procedures fee
         * 
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                     int    recViewType,
                                     bool   pagedOrTop,
                                     string idx,
                                     string canEdit,
                                     string procID,
                                     string procCode,
                                     string startDate,
                                     string active,
                                     defineCols dc
                                     )
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            Object vProcID    = Validate.optString(procID,   Messages.INVALID_PLAN_ID);
            string vProcCode  = Validate.optString(procCode, Messages.INVALID_PLAN_ID);
            Object vStartDate = Validate.optDate(startDate,  Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);

            parms.Add(Database.SqlParm("@procID",   SqlDbType.Int,      vProcID,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@procCode", SqlDbType.NChar,    vProcCode,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@efctDate", SqlDbType.DateTime, vStartDate, ParameterDirection.Input, 50));           

            string viewUDF = "dbo.CLAIM_PROCEDURE_FEES_VIEW(@userID, @userGroup, @userRank, @recID, @procID, @procCode, @efctDate, @active, @canEdit)";

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * viewTbl */
        /**
         * Returns a data table of records for preview or record selection.
         * 
         * @return                 ReturnDataTable
         ***************************************************************************/


        public static ReturnDataTable viewTbl(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                               bool   paged,
                                               string pageNumber,
                                               string canEdit,
                                               string procID,
                                               string procCode,
                                               string startDate,
                                               string active)
        {
            /*----------------------------
             * Define our columns and
             * set the page order for 
             * paging
             *----------------------------*/

            defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("id", true);
                ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(active) as [Is Active]");
                ss.addDisplayColumn("[name] as [Procedure Name]");
                ss.addDisplayColumn("[proccode] as [Procedure Code]");
                ss.addDisplayColumn("[procmod1] as [Procedure Modifier-1]");
                ss.addDisplayColumn("[procmod2] as [Procedure Modifier-2]");
                ss.addDisplayColumn("[procmod3] as [Procedure Modifier-3]");
                ss.addDisplayColumn("[startDate] as [Effective Date]");               
                ss.addDisplayColumn("[fee] as [Service Fee]");               
                ss.addDisplayColumn("id as [ProcFeeID]");

                pageroworder = ss.pageRowOrder();

            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return ClaimProcedureFees.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", procID,procCode, startDate, "", dc); });
        }


        /***************************************************************************
        * save */
        /**
        * Saves a procedure fee record
        *
        * @param   userID          User id of who is recording service
        * @param   userGroup       1 = Client, 2 = SBSC (from users db)
        * @param   userRank        Users role ranking           
        * @param   procID         
        * @param   fees
        * @param   startDate
        * @param   endDate 
        * @param   editDelReason   Reason for record edit or delete
        * @param   validateRec     1 = Performs data integrity validation tasks
        *                             Perform advisory validation tasks that can
        *                             only be conducted by referencing data from the
        *                             database and then exits WITHOUT saving the record
        *                         0 = Peform data integrity validation tasks and
        *                             if these tasks succeed peforms the desired
        *                             operation (saveType) on the record and exits
        * @param   saveType        Type of operation to perform
        *                         1 = New, 2 = Edit, 3 = Delete
        * @param   recID           Record id of existing patient record to edit or
        *                         delete.
        * @return                 ReturnSaveNewRecord
        ***************************************************************************/

        public static ReturnSaveRecord save(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                            string procID,
                                            string startDate,
                                            string fee,                                            
                                            string editDelReason,
                                            string validateRec,
                                            string saveType,
                                            string recID)
        {

            /*----------------------------
             * Check for required and 
             * optional parameters
             * and validate data integrity
             * of all supplied parameters
             *----------------------------*/


            object vProcID    = Validate.reqInteger(procID, Messages.INVALID_GROUP_ID, true);            
            Object vStartDate = Validate.reqDate(startDate, Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
            Object vFee       = Validate.reqFloat(fee,      Messages.INVALID_CLIENT_NAME);
           

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * save method.
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@procID",        SqlDbType.Int,      vProcID,    ParameterDirection.Input));            
            parms.Add(Database.SqlParm("@efctDate",      SqlDbType.DateTime, vStartDate, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@fees",          SqlDbType.Decimal,  vFee,       ParameterDirection.Input));            
            parms.Add(Database.SqlParm("@MsgNoClient",   SqlDbType.VarChar, Messages.INVALID_CLIENT_ID,     ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgNoGroup",    SqlDbType.VarChar, Messages.INVALID_GROUP_ID,      ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgNoFullEdit", SqlDbType.VarChar, Messages.EDIT_REC_NO_EDIT_FULL, ParameterDirection.Input, 1000));

            /*----------------------------
             * Call base method with 
             * the new parms and the
             * pre database call validate
             * delegate
             *----------------------------*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "CLAIM_PROCEDURE_FEES_Save", Messages.DUP_PRAC_REC, ref parms, null);
        }


        /***************************************************************************
         * updateServiceFees */
        /**
         * Bulk update service fees
         ***************************************************************************/

        public static ReturnSaveRecordWithJSONData updateServiceFees (  SqlConnection connSpedmon
                                                                       , DetailsLog    log
                                                                       , UserInfo      uInfo
                                                                       , string        procModCombosStr
                                                                       , string        serviceFee      
                                                                       , string        over17Fee       
                                                                       , string        under18Fee
                                                                       , string        billingProgramID
                                                                       , string        validate)
        {

          var so = new ReturnSaveRecordWithJSONData();


          string vProcModCombosStr = Validate.reqString (procModCombosStr, @"Proc mod combo(s) required")
                                     .Replace("\n", "").Replace("\r", ""); /* Strip out crlf from proc mod combo.*/

          Decimal vServiceFee       = Validate.reqUsdAmount (serviceFee,       @"Allowable rate required");
          Decimal vOver17Fee        = Validate.reqUsdAmount (over17Fee,        @"18+ allowable rate required");
          Decimal vUnder18Fee       = Validate.reqUsdAmount (under18Fee,       @"Under 18 allowable rate required");
          byte    vBillingProgramID = Validate.reqTinyInt   (billingProgramID, @"Invalid billing program");
          bool    vValidate         = Validate.reqFlag      (validate,         @"Validation flag required",false);
          
          if (vServiceFee <= 0m)
          {
            throw new Warning(@"Service fee must be a number greater than 0");
          }

          var parms = new List<SqlParameter>();

          parms.Add(Database.SqlParm("@procModCombosStr",   SqlDbType.VarChar, vProcModCombosStr,   ParameterDirection.Input, 8000));
          parms.Add(Database.SqlParm("@serviceFee",         SqlDbType.Money,   vServiceFee,         ParameterDirection.Input));            
          parms.Add(Database.SqlParm("@over17Fee",          SqlDbType.Money,   vOver17Fee,          ParameterDirection.Input));            
          parms.Add(Database.SqlParm("@under18Fee",         SqlDbType.Money,   vUnder18Fee,         ParameterDirection.Input));            
          parms.Add(Database.SqlParm("@billingProgramID",   SqlDbType.TinyInt, vBillingProgramID,   ParameterDirection.Input));
          parms.Add(Database.SqlParm("@validate",           SqlDbType.Bit,     vValidate,           ParameterDirection.Input));            
          parms.Add(Database.SqlParm("@jsonData",           SqlDbType.VarChar, null,                ParameterDirection.Output, -1));
         
          var rd = Database.execSproc(connSpedmon,log,@"CLAIM_PROCEDURES_UPDATE_SERVICE_FEES",parms);
          so = (ReturnSaveRecordWithJSONData) Database.convertParameters(rd,typeof(ReturnSaveRecordWithJSONData));
          return so;

        }

    }
}
