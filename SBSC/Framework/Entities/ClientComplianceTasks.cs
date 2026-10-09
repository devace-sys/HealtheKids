using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;


namespace Spedmon
{
    public class ClientComplianceTask : Entity
    {
    }
    
    public class ClientComplianceTasks : Entities
    {
        public static string URL_WEB_SERVICE = "client_compliance_tasks.asmx";
        public static string URL_VIEW_SEL = URL_WEB_SERVICE + "/viewSel";
        public static string URL_SAVE     = URL_WEB_SERVICE + "/save";

        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SAVE, true);
        }

        public static ReturnDB view(SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , int recViewType
                                     , bool pagedOrTop
                                     , string idx
                                     , string canEdit
                                     , string active
                                     , string term
                                     , defineCols dc)
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();
            string viewUDF = "dbo.CLIENT_COMPLIANCE_TASKS_VIEW (@userID, @userGroup, @userRank, @term, @active, @recID)";

            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, term, ParameterDirection.Input, 1000));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        public static ReturnSel viewSel(SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , bool paged
                                         , string pageNumber
                                         , string active
                                         , string term)
        {

            string vTerm = Validate.optString(term);

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
            };

            return Entities.viewSel(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, vTerm, dc); });
        }

        public static ReturnSaveRecord save(SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , string name
                                         , string editDelReason
                                         , string validateRec
                                         , string saveType
                                         , string recID)
        {

            string saveSproc = @"CLIENT_COMPLIANCE_TASK_SAVE";
            string dupRecMsg = @"This task already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            string vName = Validate.reqString(name, "Invalid Task Name");

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@name", SqlDbType.VarChar, vName, ParameterDirection.Input));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }

    }
}
