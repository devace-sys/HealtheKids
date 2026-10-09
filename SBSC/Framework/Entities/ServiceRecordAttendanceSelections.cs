using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;


namespace Spedmon
{
    /***************************************************************************
     * ServiceRecordAttendanceSelection */
    /**
     ***************************************************************************/

	public class ServiceRecordAttendanceSelection : Entity
	{
	}
	
    /***************************************************************************
     * ServiceRecordAttendanceSelections */
    /**
     ***************************************************************************/

    public class ServiceRecordAttendanceSelections : Entities
    {
        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/

        public static ReturnDB view (  SqlConnection connSpedmon
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

            string viewUDF = "dbo.SERVICE_RECORD_ATTENDANCE_SELECTIONS_VIEW (@userID, @userGroup, @userRank, @term)";
            string vTerm = Validate.optString(term);
            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, vTerm, ParameterDirection.Input, 256));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }
        
		/***************************************************************************
         * viewList */
        /**
         * 
         ***************************************************************************/
		
		public static List<ServiceRecordAttendanceSelection> viewList (  SqlConnection connSpedmon
                                                                       , DetailsLog log
                                                                       , UserInfo uInfo
                                                                       , string active
                                                                       , string term )
        {

          var recs = new List<ServiceRecordAttendanceSelection>();
          var rd = ServiceRecordAttendanceSelections.view ( connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, "", "", active, term, null);
          var slo = Database.convertRecordsToList(ref rd.records, typeof(ServiceRecordAttendanceSelection));
          foreach (var o in slo) { recs.Add((ServiceRecordAttendanceSelection)o);}
          return recs;
        }
        
        /***************************************************************************
         * generateNvpValuesJSON */
        /**
         * 
         ***************************************************************************/

        public static string generateNvpValuesJSON (  SqlConnection connSpedmon
                                                     , DetailsLog log
                                                     , UserInfo uInfo )
        {
           var selections = ServiceRecordAttendanceSelections.viewList(connSpedmon, log, uInfo,"Y","");           
           var sb = new StringBuilder();           
           sb.Append(@"[");           
           var curSelectionNum = 1;
           foreach(var selection in selections)
           {
             if (curSelectionNum > 1) sb.Append(",");
             sb.AppendFormat(@"{{name:'{0}',value:'{1}'}}", selection.name, selection.id); 
             curSelectionNum++;
           }
           sb.Append(@"]");
           return sb.ToString();
        }

        /***************************************************************************
         * viewSel */
        /**
         * 
         ***************************************************************************/

        public static ReturnSel viewSel (  SqlConnection connSpedmon
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
              delegate { return ServiceRecordAttendanceSelections.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, vTerm, dc); });
        }
    }
}
