using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;



namespace Spedmon
{
    /***************************************************************************
     * ClaimsProcessingExceptions */
    /**
     * 
     ***************************************************************************/


    public class ClaimsProcessingException : Entity
    {

        public long   clientid;        // Client (district) id
        public long   pracid;
        public string pracname;
        public long   exceptionid;
        public string exceptionname;

    }

         public class ClaimsProcessingExceptions : Entities
    {

        /***************************************************************************
         * delete */
        /**
         * "Deletes" a ClaimsProcessingExceptions record
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

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "CLAIMS_PROCESSING_EXCEPTION_Delete", ref parms);
        }

        /***************************************************************************
         * load */
        /**
         * Outputs data for a single ClaimsProcessingException
         * 
         * Note: This calls the view method.
         * 
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @return                 ReturnEntity
         ***************************************************************************/

        public static ClaimsProcessingException load(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                         string recID)
        {
            return (ClaimsProcessingException)Entities.load(connSpedmon, log, uInfo, recID, typeof(ClaimsProcessingException),
            delegate { return ClaimsProcessingExceptions.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", "","", "","", null); });
        }

        /***************************************************************************
         * view */
        /**
         * Returns a list of Claim Processing exceptions
         * 
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                     int    recViewType,
                                     bool   pagedOrTop,
                                     string idx,                                    
                                     string clientID,
                                     string pracID,                                    
                                     string startDate,
                                     string endDate,
                                     string exceptionID,
                                     string active,
                                     string canEdit,
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

            string viewUDF = "dbo.CLAIMS_PROCESSING_EXCEPTION_VIEW(@userID, @userGroup, @userRank, @recID, @clientID, @pracID, @startDate, @endDate, @exceptionID, @active, @canEdit)";

            Object vClientID    = Validate.optClientID(uInfo, clientID);
            Object vPracID      = Validate.optInteger(pracID, Messages.INVALID_PRAC_ID);
            Object vStartDate   = Validate.optDate   (startDate,   Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
            Object vEndDate     = Validate.optDate   (endDate,     Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NO_FUTURE);
            Object vExceptionID = Validate.optInteger(exceptionID, Messages.INVALID_PRAC_ID);


            parms.Add(Database.SqlParm("@clientID",    SqlDbType.Int,      vClientID,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",      SqlDbType.Int,      vPracID,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@exceptionID", SqlDbType.Int,      vExceptionID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@startDate",   SqlDbType.DateTime, vStartDate,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@endDate",     SqlDbType.DateTime, vEndDate,     ParameterDirection.Input));    
            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * viewSel */
        /**
         * Returns a list of claim Processing exceptions for a given clientID
         * 
         ***************************************************************************/

        public static ReturnSel viewSel(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize, string clientid)
        {

            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("EXCEPTION_ID as context1");
            };

            /*----------------------------
              * Call base method which
              * handles the rest and return
              * results
              *----------------------------*/

            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return ClaimsProcessingExceptions.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, clientid, "", "", "", "","","", dc); });

        }

        /***************************************************************************
         * save */
        /**
         * Save a Claims Processing Exceptions record
         *
         * @param  userID          User id of who is recording service
         * @param  userGroup       1 = Client, 2 = SBSC (from users db)
         * @param  userRank        Users role ranking
         * @param  clientID        client id   
         * @param  pracID          Practitioner id       
         * @param  startDate       Claims Processing Exceptions startdate   
         * @param  enddate         Claims Processing Exceptions enddate
         * @param  notes
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
         * @param  recID           Record id of existing Claims Processing Exceptions record to edit or
         *                         delete.
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/

        public static ReturnSaveRecord save(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                             string clientID,
                                             string pracID,
                                             string startDate,
                                             string endDate,
                                             string notes,
                                             string exceptionID,
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

            int    vClientID    = Validate.reqClientID   (uInfo, clientID);
            Object vPracID      = Validate.reqInteger(pracID,      Messages.INVALID_PRAC_ID);
            Object vStartDate   = Validate.reqDate(startDate,      Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
            Object vEndDate     = Validate.reqDate(endDate,        Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NO_FUTURE);
            Object vExceptionID = Validate.reqInteger(exceptionID, Messages.INVALID_PRAC_ID);
            Object vNotes       = Validate.optString(notes,        Messages.INVALID_NOTES);

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * save method.
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();
             
            parms.Add(Database.SqlParm("@clientID",      SqlDbType.Int,      vClientID,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",        SqlDbType.Int,      vPracID,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@startDate",     SqlDbType.DateTime, vStartDate,   ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@endDate",       SqlDbType.DateTime, vEndDate,     ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@exceptionID",   SqlDbType.Int,      vExceptionID, ParameterDirection.Input));            
            parms.Add(Database.SqlParm("@notes",         SqlDbType.VarChar,  vNotes,       ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@MsgNoClient",   SqlDbType.VarChar, Messages.INVALID_CLIENT_ID,     ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgNoGroup",    SqlDbType.VarChar, Messages.INVALID_GROUP_ID,      ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgNoFullEdit", SqlDbType.VarChar, Messages.EDIT_REC_NO_EDIT_FULL, ParameterDirection.Input, 1000));

            /*----------------------------
             * Call base method with 
             * the new parms and the
             * pre database call validate
             * delegate
             *----------------------------*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "CLAIMS_PROCESSING_EXCEPTION_Save", Messages.DUP_PRAC_REC, ref parms, null);
        }

        /***************************************************************************
         * viewTbl */
        /**
         * Returns a data table of records for preview or record selection.
         * 
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable viewTbl(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                            bool paged,
                                            string pageNumber,
                                            string clientID,
                                            string pracID,
                                            string startDate,
                                            string endDate,
                                           // string exceptionID,
                                            string canEdit,
                                            string active
                                            )
        {
            /*----------------------------
             * Define our columns and
             * set the page order for 
             * paging
             *----------------------------*/

            defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

                ss.addDisplayColumn("id");
                ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(active)      as [Is Active]");
                ss.addDisplayColumn("name as [Client Name]", true);               
                
                ss.addDisplayColumn("startDate AS [Start Date]");
                ss.addDisplayColumn("endDate AS [End Date]");
                ss.addDisplayColumn("exceptionname AS [Exception]");
                ss.addDisplayColumn("pracname AS [Practitioner Name]");
                ss.addDisplayColumn("pracid AS [Practitioner ID]");
                
                ss.addDisplayColumn("id as [ClaimExceptionID]");

                pageroworder = ss.pageRowOrder();

            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return ClaimsProcessingExceptions.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber,clientID,pracID,startDate,endDate,"",active, canEdit, dc); });
        }

        /***************************************************************************
         * viewEntity */
        /**
         * Outputs data for a single Claims Processing Exception
         * 
         * @param  connSpedmon       Spedmon database connection object
         * @param  log               Logging object
         * @param  claimexceptionID  ID
         * @return                   ReturnEntity
         ***************************************************************************/

        public static ReturnEntity viewEntity(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                               string claimexceptionID)
        {

            // TODO: Legacy remove

            ReturnEntity so = new ReturnEntity();
            ClaimsProcessingException e = load(connSpedmon, log, uInfo, claimexceptionID);
            so.entity = (Entity)e;
            return so;
        } 


    }
}