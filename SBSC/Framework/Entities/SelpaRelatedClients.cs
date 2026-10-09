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
    * SelpaRelatedClient */
   /**
    ***************************************************************************/ 
    public class SelpaRelatedClient: MBA.SelpaRelatedClient
    {
        public const string DEFAULT_PAGING_ORDER = @"clientName asc";
    }

    /***************************************************************************
     * SelpaRelatedClients */
    /**
     ***************************************************************************/

    public class SelpaRelatedClients : Entities
    {

        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/
        public static ReturnDB view (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , string        selpaCode
									  , int           recViewType
                                      , bool          pagedOrTop
                                      , string        idx
                                      , string        canEdit
                                      , string        active
                                      , string        term  /* Possible future use */
                                      , defineCols    dc )
        {
            string viewUDF = @"dbo.SELPA_RELATED_CLIENTS_VIEW (@userID, @userGroup, @userRank, @selpaCode)";            
            Object vSelpaCode = Validate.reqSelpaCode(uInfo ,selpaCode);
            var parms = new List<SqlParameter>();                        
            parms.Add(Database.SqlParm("@selpaCode", SqlDbType.Int, vSelpaCode, ParameterDirection.Input));       
            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
        }        

        /***************************************************************************
         * viewList */
        /**
         * 
         ***************************************************************************/
         public static List<SelpaRelatedClient> viewList ( SqlConnection connSpedmon
                                                          , DetailsLog    log
                                                          , UserInfo      uInfo                                                         
                                                          , string        selpaCode) 
         {
           var recs = new List<SelpaRelatedClient>();
           ReturnDB rd = SelpaRelatedClients.view (connSpedmon, log, uInfo, selpaCode, Entities.REC_VIEW_RAW, false, null, null, null, null, null);       
           List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(SelpaRelatedClient));
           foreach (var o in slo) {
             recs.Add((SelpaRelatedClient) o);
           }
           return recs;        
         }
         
         /***************************************************************************
          * viewObjects */
         /**
          * 
          ***************************************************************************/
         public static ReturnObjects viewObjects ( SqlConnection connSpedmon
                                                  , DetailsLog    log
                                                  , UserInfo      uInfo  
                                                  , bool          pageObjectList
                                                  , string        pageOrder
                                                  , string        idx
                                                  , string        active
                                                  , string        selpaCode)
        {
          /* Default page order */
 
          if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = SelpaRelatedClient.DEFAULT_PAGING_ORDER;
 
          /* Define columns delegate is used to specify columns and page order 
           * We pass in the desired page row order here */
 
          defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
          {
            pageroworder = pageOrder;
          };

          return Entities.viewObjects(connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(SelpaRelatedClient)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return SelpaRelatedClients.view(connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , selpaCode                                                                       
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" /* Can edit */
                                                                       , active
                                                                       , ""
                                                                       , dc);
                                      });
 
 

        }
    }
}
