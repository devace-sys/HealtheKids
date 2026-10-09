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
     * CYBHIProviderDegree */
    /**
     ***************************************************************************/
    public class CYBHIProviderDegree
    {
        public long   id;
        public string codeValue;
        public string name;
    }

    /***************************************************************************
     * CYBHIProviderDegrees */
    /**
     ***************************************************************************/

    public class CYBHIProviderDegrees : Entities
    {

        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/

        public static ReturnDB view ( SqlConnection connSpedmon
                                     , DetailsLog   log
                                     , UserInfo     uInfo
                                     , int          recViewType
                                     , bool         pagedOrTop
                                     , string       idx
                                     , string       canEdit
                                     , string       active
                                     , string       term
                                     , defineCols   dc)
        {

            string viewUDF = "dbo.CYBHI_Provider_Degrees_View (@userID, @userGroup, @userRank, @term)";

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

        public static List<CYBHIProviderDegree> viewList (  SqlConnection connSpedmon
                                                          , DetailsLog    log
                                                          , UserInfo      uInfo )
        {
          List<CYBHIProviderDegree> recs = new List<CYBHIProviderDegree>();
          var rd = CYBHIProviderDegrees.view (connSpedmon,log,uInfo,Entities.REC_VIEW_RAW,false,"","","Y","",null);
          var slo = Database.convertRecordsToList(ref rd.records, typeof(CYBHIProviderDegree));
          foreach (var o in slo) {
            recs.Add ( (CYBHIProviderDegree)o );
          }
          return recs;
        }
    }
}
