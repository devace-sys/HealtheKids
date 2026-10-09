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

    public class ClaimProcedure : Entity
    {
        public int      noPlanNameID;
        public int      IEP_IFSPNameID;
        public string   noPlanName;
        public string   IEP_IFSPName;
        public string   proccode;
        public string   procmod1;
        public string   procmod2;
        public string   procmod3;
        public DateTime dateEffective;
        public DateTime dateExpires;
        public string   IEPRequired;
        public decimal  svcFee;
        public string   maxUnits;
        public string   maxSvcUnits;
        public string   TCMlowRate;
        public string   TCMmedRate;
        public string   TCMhighRate;
        public string   over17Fee;
        public string   under18Fee;
        public string   pageNum;
        public string   diagnosisCode;
        public string   yearlyFlag;       
        public bool     putIn837;
        public bool     combIntoProxy;
        public bool     linkToSvc;      

    }
    /***************************************************************************
     * ClaimProcedures */
    /**
     ***************************************************************************/

    public class ClaimProcedures:Entities
    {
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

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "CLAIM_PROCEDURES_Delete", ref parms);
        }

        /***************************************************************************
         * load */
        /**
         * Outputs data for a single claim procedure
         *         
         * 
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object        
         * @return                 ReturnEntity
         ***************************************************************************/

        public static ClaimProcedure load(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                         string recID)
        {
            return (ClaimProcedure)Entities.load(connSpedmon, log, uInfo, recID, typeof(ClaimProcedure),
            delegate { return ClaimProcedures.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "",null,null,null,null,"",null); });
        } 

       /***************************************************************************
        * save */
        /**
        * Saves a claim procedure record
        *
        * @param   userID          User id of who is recording service
        * @param   userGroup       1 = Client, 2 = SBSC (from users db)
        * @param   userRank        Users role ranking
        * @param   noPlanName       
        * @param   IEP_IFSP_NAME 
        * @param   procCode    
        * @param   procMod1         
        * @param   procMod2        
        * @param   procMod3         
        * @param   procName         
        * @param   dateEffective    
        * @param   dateExpires      
        * @param   IEPRequired      
        * @param   serviceFee       
        * @param   maxUnits         
        * @param   maxServiceUnits  
        * @param   tcmLowRate      
        * @param   tcmMedRate       
        * @param   tcmHighRate      
        * @param   over17Fee        
        * @param   under18Fee       
        * @param   page             
        * @param   diagnosisCode    
        * @param   yearlyFlag       
        * @param   putIn837        
        * @param   combineINTOProxy 
        * @param   linkToService
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
                                            string noPlanName,
                                            string IEP_IFSPname,
                                            string procCode,
                                            string procMod1,
                                            string procMod2,
                                            string procMod3,
                                            string procName,                                          
                                            string dateEffective,
                                            string dateExpires,
                                            string IEPrequired,
                                            string serviceFee,
                                            string maxUnits,
                                            string maxSvcUnits,
                                            string TCMlowRate,
                                            string TCMmedRate,
                                            string TCMhighRate,
                                            string over17Fee,
                                            string under18FEE,
                                            string page,
                                            string diagnosisCode,
                                            string yearlyFlag,
                                            string putIn837,
                                            string combineIntoProxy,
                                            string link2Svc,
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

             
            object vNoPlanNameID     = Validate.optInteger(noPlanName,   Messages.INVALID_GROUP_ID,true);
            object vIEP_IFSPNameID   = Validate.optInteger(IEP_IFSPname, Messages.INVALID_GROUP_ID,true);
            string vProcCode         = Validate.reqString(procCode,      Messages.INVALID_CLIENT_NAME);
            string vProcMod1         = Validate.optString(procMod1,      Messages.INVALID_LNAME);
            string vProcMod2         = Validate.optString(procMod2,      Messages.INVALID_LNAME);
            string vProcMod3         = Validate.optString(procMod3,      Messages.INVALID_LNAME);
            string vProcName         = Validate.reqString(procName,      Messages.INVALID_FNAME);
            Object vDateEffective    = Validate.optDate(dateEffective,   Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
            Object vDateExpires      = Validate.optDate(dateExpires,     Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
            Object vServiceFee       = Validate.reqFloat(serviceFee,     Messages.INVALID_CLIENT_NAME);
            string vIEPrequired      = Validate.optString(IEPrequired,   Messages.INVALID_LNAME);            
            string vMaxUnits         = Validate.optString(maxUnits,      Messages.INVALID_LNAME);
            string vMaxSvcUnits      = Validate.optString(maxSvcUnits,   Messages.INVALID_LNAME);
            string vTCMlowRate       = Validate.optString(TCMlowRate,    Messages.INVALID_LNAME);
            string vTCMmedRate       = Validate.optString(TCMmedRate,    Messages.INVALID_LNAME);
            string vTCMhighRate      = Validate.optString(TCMhighRate,   Messages.INVALID_LNAME);
            string vOver17Fee        = Validate.optString(over17Fee,     Messages.INVALID_LNAME);
            string vUnder18FEE       = Validate.optString(under18FEE,    Messages.INVALID_LNAME);
            string vPage             = Validate.optString(page,          Messages.INVALID_LNAME);
            string vDiagnosisCode    = Validate.optString(diagnosisCode, Messages.INVALID_LNAME);
            string vYearlyFlag       = Validate.optString(yearlyFlag,    Messages.INVALID_LNAME);
            bool   vputin837         = Validate.reqFlag(putIn837,        Messages.INVALID_COE_FLAG);
            bool   vCombIntoProxy    = Validate.reqFlag(combineIntoProxy,Messages.INVALID_LEA_FLAG);
            bool   vLink2Svc         = Validate.reqFlag(link2Svc,        Messages.INVALID_MAA_FLAG);
            
          
            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * save method.
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@noPlanName",      SqlDbType.Int,      vNoPlanNameID,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@IEP_IFSP_NAME",   SqlDbType.Int,      vIEP_IFSPNameID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@procCode",        SqlDbType.NChar,    vProcCode,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@procMod1",        SqlDbType.NChar,    vProcMod1,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@procMod2",        SqlDbType.NChar,    vProcMod2,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@procMod3",        SqlDbType.NChar,    vProcMod3,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@procName",        SqlDbType.NVarChar, vProcName,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@dateEffective",   SqlDbType.DateTime, vDateEffective,    ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@dateExpires",     SqlDbType.DateTime, vDateExpires,      ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@IEPRequired",     SqlDbType.NChar,    vIEPrequired,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@serviceFee",      SqlDbType.Decimal,  vServiceFee,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@maxUnits",        SqlDbType.NChar,    vMaxUnits,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@maxServiceUnits", SqlDbType.NChar,    vMaxSvcUnits,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@tcmLowRate",      SqlDbType.NChar,    vTCMlowRate,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@tcmMedRate",      SqlDbType.NChar,    vTCMmedRate,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@tcmHighRate",     SqlDbType.NChar,    vTCMhighRate,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@over17Fee",       SqlDbType.NChar,    vOver17Fee,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@under18Fee",      SqlDbType.NChar,    vUnder18FEE,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@page",            SqlDbType.NChar,    vPage,             ParameterDirection.Input));
            parms.Add(Database.SqlParm("@diagnosisCode",   SqlDbType.NChar,    vDiagnosisCode,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@yearlyFlag",      SqlDbType.NChar,    vYearlyFlag,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@putIn837",        SqlDbType.Bit,      vputin837,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@combineINTOProxy",SqlDbType.Bit,      vCombIntoProxy,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@linkToService",   SqlDbType.Bit,      vLink2Svc,         ParameterDirection.Input));        
            parms.Add(Database.SqlParm("@MsgNoClient",     SqlDbType.VarChar, Messages.INVALID_CLIENT_ID,     ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgNoGroup",      SqlDbType.VarChar, Messages.INVALID_GROUP_ID,      ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgNoFullEdit",   SqlDbType.VarChar, Messages.EDIT_REC_NO_EDIT_FULL, ParameterDirection.Input, 1000));

            /*----------------------------
             * Call base method with 
             * the new parms and the
             * pre database call validate
             * delegate
             *----------------------------*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "CLAIM_PROCEDURES_Save", Messages.DUP_PRAC_REC, ref parms, null);
        }

        /***************************************************************************
         * viewSel */
        /**
         * Returns a list of claim procedures
         * 
         ***************************************************************************/

        public static ReturnSel viewSel(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize, string term)
        {          

            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("proccode +' | '+ procmod1 + ' | ' + procmod2 + ' | '+ procmod3 as context1");
            };

            /*----------------------------
              * Call base method which
              * handles the rest and return
              * results
              *----------------------------*/

            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return ClaimProcedures.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top,topSize,"",term,"","","", "1", dc); });

        }



        /***************************************************************************
         * view */
        /**
         * Returns a list of Claim Procedures
         * 
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                     int        recViewType,
                                     bool       pagedOrTop,
                                     string     idx,
                                     string     canEdit,
                                     string     procCode,
                                     string     procMod1,
                                     string     procMod2,
                                     string     procMod3,
                                     string     active,                                                                         
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

            string vProcCode = Validate.optString(procCode, Messages.INVALID_CLIENT_NAME);
            string vProcMod1 = Validate.optString(procMod1, Messages.INVALID_LNAME);
            string vProcMod2 = Validate.optString(procMod2, Messages.INVALID_LNAME);
            string vProcMod3 = Validate.optString(procMod3, Messages.INVALID_LNAME);


            parms.Add(Database.SqlParm("@procCode", SqlDbType.NChar, vProcCode, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@procMod1", SqlDbType.NChar, vProcMod1, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@procMod2", SqlDbType.NChar, vProcMod2, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@procMod3", SqlDbType.NChar, vProcMod3, ParameterDirection.Input));

            string viewUDF = "dbo.CLAIM_PROCEDURES_VIEW(@userID, @userGroup, @userRank,@procCode,@procMod1,@procMod2,@procMod3, @recID,@active, @canEdit)";            

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
                                               string procCode,
                                               string procMod1,
                                               string procMod2,
                                               string procMod3,
                                               string active)
        {
            /*----------------------------
             * Define our columns and
             * set the page order for 
             * paging
             *----------------------------*/

            defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("id",true);                        
                ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(active) as [Is Active]");
                ss.addDisplayColumn("[noPlanName] as [No Plan Name]");
                ss.addDisplayColumn("[IEP_IFSPName]");
                ss.addDisplayColumn("[proccode] as [Procedure Code]");
                ss.addDisplayColumn("[procmod1] as [Modifier-1]");
                ss.addDisplayColumn("[procmod2] as [Modifier-2]");
                ss.addDisplayColumn("[procmod3] as [Modifier-3]");
                ss.addDisplayColumn("[name] as [Procedure Name]");
                ss.addDisplayColumn("[DATE_ADDED] as [Date Added]");
                ss.addDisplayColumn("[dateEffective] as [Date Effective]");
                ss.addDisplayColumn("[dateExpires] as [Date Expires]");
                ss.addDisplayColumn("[IEPRequired]");
                ss.addDisplayColumn("[svcFee] as [Service Fee]");
                ss.addDisplayColumn("[maxUnits]");
                ss.addDisplayColumn("[maxSvcUnits]");
                ss.addDisplayColumn("[TCMlowRate]");
                ss.addDisplayColumn("[TCMmedRate]");
                ss.addDisplayColumn("[TCMhighRate]");
                ss.addDisplayColumn("[over17Fee]");
                ss.addDisplayColumn("[under18Fee]");
                ss.addDisplayColumn("[pageNum]");
                ss.addDisplayColumn("[diagnosisCode] as [Diagnosis code]");
                ss.addDisplayColumn("[yearlyFlag] as [Yearly Flag]");
                ss.addDisplayColumn("[putIn837] as [PutIn837]");
                ss.addDisplayColumn("[combIntoProxy] as [Combine into Proxy]");
                ss.addDisplayColumn("[linkToSvc] as [Link2Svc]");
                ss.addDisplayColumn("id as [ProcedureID]");
               
                pageroworder = ss.pageRowOrder();

            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return ClaimProcedures.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit,procCode,procMod1,procMod2,procMod3, active, dc); });
        }

        /***************************************************************************
         * NoPlanNamesview */
        /**
         * Returns a list of NoPlanNames
         * 
         ***************************************************************************/

        public static ReturnDB NoPlanNamesview(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                             int    recViewType,
                                             bool   pagedOrTop,
                                             string idx,
                                             string canEdit,
                                             string active,
                                             string noplanname,
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

            Object vName = Validate.optString(noplanname);

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@name", SqlDbType.NVarChar, vName, ParameterDirection.Input)); string viewUDF = "dbo.CLAIM_NoPlanNames_LIST_VIEW(@userID, @userGroup, @userRank, @recID, @name)";

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
         * Returns a list of No_Plan_Names_LIST
         * 
         ***************************************************************************/

        public static ReturnSel NoPlanNamesviewSel(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize,string term)
        {

            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("'' as context1");
            };

            /*----------------------------
              * Call base method which
              * handles the rest and return
              * results
              *----------------------------*/

            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return ClaimProcedures.NoPlanNamesview(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "1",term, dc); });

        }

        /***************************************************************************
         * IEPandIFSPNamesview */
        /**
         * Returns a list of IEPandIFSPNames
         * 
         ***************************************************************************/

        public static ReturnDB IEPandIFSPNamesview(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                             int recViewType,
                                             bool pagedOrTop,
                                             string idx,
                                             string canEdit,
                                             string active,
                                             string iepifspname,
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
            Object vName = Validate.optString(iepifspname);

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@name", SqlDbType.NVarChar, vName, ParameterDirection.Input));

            string viewUDF = "dbo.CLAIM_IEPandIFSPNames_LIST_VIEW(@userID, @userGroup, @userRank, @recID, @name)";

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
         * Returns a list of No_Plan_Names_LIST
         * 
         ***************************************************************************/

        public static ReturnSel IEPandIFSPNamesviewSel(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize,string term)
        {

            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("'' as context1");
            };

            /*----------------------------
              * Call base method which
              * handles the rest and return
              * results
              *----------------------------*/

            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return ClaimProcedures.IEPandIFSPNamesview(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "1",term, dc); });

        }

        /***************************************************************************
        * IEPandIFSPNamesview */
        /**
         * Returns a list of IEPandIFSPNames
         * 
         ***************************************************************************/

        public static ReturnDB procedureModifiersview(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                             int recViewType,
                                             bool pagedOrTop,
                                             string idx,
                                             string canEdit,
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
            string viewUDF = "dbo.CLAIM_PROCEDURE_MODIFIERS_LIST_VIEW(@userID, @userGroup, @userRank)";

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
         * Returns a list of No_Plan_Names_LIST
         * 
         ***************************************************************************/

        public static ReturnSel procedureModifiersviewSel(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize)
        {

            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("'' as context1");
            };

            /*----------------------------
              * Call base method which
              * handles the rest and return
              * results
              *----------------------------*/

            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return ClaimProcedures.procedureModifiersview(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "1", dc); });

        }





       

    }
}
