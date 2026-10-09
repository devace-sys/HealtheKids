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
    public class RmtsReasonForStartDateChange : Entity
    {
        public string reason;
    }

    public class RmtsReasonsForStartDateChange : Entities
    {

        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/

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

            string viewUDF = "dbo.RMTS_REASONS_FOR_START_DATE_CHANGE_VIEW (@userID, @userGroup, @userRank, @active, @term, @recID)";

            string vTerm = Validate.optString(term);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, vTerm, ParameterDirection.Input, 1000));


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
        public static List<RmtsReasonForStartDateChange> viewList (  SqlConnection connSpedmon
                                              , DetailsLog    log
                                              , UserInfo      uInfo ) 
        {
      
          var listItems = new List<RmtsReasonForStartDateChange>();

          bool hasRecords = false;
      
          Object[] recs = loadAllRecords (   connSpedmon
                                          , log
                                          , uInfo
                                          , typeof (RmtsReasonForStartDateChange)
                                          , delegate { 
                                            return RmtsReasonsForStartDateChange.view(connSpedmon
                                                      , log
                                                      , uInfo
                                                      , Entities.REC_VIEW_ALL
                                                      , false
                                                      , ""
                                                      , ""
                                                      , "1"
                                                      , null
                                                      , null
                                                    );
                                          }
                                         , out hasRecords);
    
          if (hasRecords == true)
          {
            foreach (Object rec in recs) {
              RmtsReasonForStartDateChange listItem = (RmtsReasonForStartDateChange) rec;
              listItems.Add(listItem);
            }
          }
          return listItems;
        }  


    }
}
