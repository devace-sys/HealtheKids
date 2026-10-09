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
     * SpEdService */
    /**
     ***************************************************************************/

    public class SpEdService:Entity
    {
      public string codeSetName;
      public int    codeValue;
      public string codeName;
      public string definition;
    }

    /***************************************************************************
     * SpEdServices */
    /**
     ***************************************************************************/

    public class SpEdServices : Entities
    {
        public const string URL_WEB_SERVICE = @"sped_services.asmx";
        public const string URL_VIEW_SEL    = URL_WEB_SERVICE + @"/viewSel";

        public static string URL_VIEW_SEL_BASE()
        {
            return MBA.HttpApplication.createLink(SpEdServices.URL_VIEW_SEL, true);
        }

        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/

        public static ReturnDB view  (  SqlConnection connSpedmon
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

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();
            string viewUDF = "dbo.SPED_SERVICE_VIEW (@userID, @userGroup, @userRank, @term, @recID)";

            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, term, ParameterDirection.Input, 1000));

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
         * 
         ***************************************************************************/

        public static ReturnSel viewSel (   SqlConnection connSpedmon
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
              delegate { return SpEdServices.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, vTerm, dc); });
        }


        /***************************************************************************
         * viewList */
        /**
         * 
         ***************************************************************************/
        public static List<SpEdService> viewList (  SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo )
        {

            var listItems = new List<SpEdService>();
            bool hasRecords = false;

            Object[] recs = loadAllRecords ( connSpedmon
                                            , log
                                            , uInfo
                                            , typeof (SpEdService)
                                            , delegate { 
                                                return SpEdServices.view (  connSpedmon
                                                                          , log
                                                                          , uInfo
                                                                          , Entities.REC_VIEW_ALL
                                                                          , false
                                                                          , ""
                                                                          , ""
                                                                          , "Y"
                                                                          , null
                                                                          , null);
                                            }
                                     , out hasRecords);
    
            if (hasRecords == true)
            {
               foreach (Object rec in recs) {
                 SpEdService listItem = (SpEdService) rec;
                 listItems.Add(listItem);
               }
            }
            return listItems;
        }


    /***************************************************************************
     * load */
    /**
     * Loads single record
     ***************************************************************************/

    public static SpEdService load (  SqlConnection connSpedmon
                                     , DetailsLog    log
                                     , UserInfo      uInfo                                     
                                     , string        recID )
    {      
      return (SpEdService) Entities.load(connSpedmon, log, uInfo, recID, typeof(SpEdService),
      delegate { return SpEdServices.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID,"","Y","",null); });
    }
 
  }
}
