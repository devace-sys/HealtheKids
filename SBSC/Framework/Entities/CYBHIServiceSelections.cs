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
     * CYBHIServiceSelection */
    /**
     ***************************************************************************/

	public class CYBHIServiceSelection
    {
        public long   id;        
        public string name;
    }

    /***************************************************************************
     * CYBHIServiceSelections */
    /**
     ***************************************************************************/

    public class CYBHIServiceSelections : Entities
    {

        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/

        public static ReturnDB view ( SqlConnection connSpedmon
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

            string viewUDF = "dbo.CYBHI_Service_Selections_View (@userID, @userGroup, @userRank, @term)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, term, ParameterDirection.Input, 256));

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

        public static List<CYBHIServiceSelection> viewList (  SqlConnection connSpedmon
                                                             , DetailsLog    log
                                                             , UserInfo      uInfo )
        {
          List<CYBHIServiceSelection> recs = new List<CYBHIServiceSelection>();
          var rd = CYBHIServiceSelections.view (connSpedmon,log,uInfo,Entities.REC_VIEW_RAW,false,"","","Y","",null);
          var slo = Database.convertRecordsToList(ref rd.records, typeof(CYBHIServiceSelection));
          foreach (var o in slo) {
            recs.Add ( (CYBHIServiceSelection) o );
          }
          return recs;
        }
    }
}
