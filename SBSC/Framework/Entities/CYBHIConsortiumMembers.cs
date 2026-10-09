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
    * CYBHIConsortiumMember */
   /**
    ***************************************************************************/ 

    public class CYBHIConsortiumMember: MBA.ClientConsortiumMember
    {
      public const string DEFAULT_PAGING_ORDER = @"leadClient desc, name asc";

      /* Can add stats here */
    }

    /***************************************************************************
     * CYBHIConsortiumMembers */
    /**
     ***************************************************************************/

    public class CYBHIConsortiumMembers : Entities
    {

        
        
        public const string URL_REST_VIEW     = @"api/v1/cybhiconsortiummembers";
        public static string URL_MANAGE       = "user_all_cybhi_program_health_for_consortium_leads_manage.aspx";
        public static string MENU_ID_MANAGE   = "cybhiprogramhealthconsortiumleadmanagelnk";
        public static string SEL_LABEL_MANAGE = "CYBHI Consortium - Program Health";


        /***************************************************************************
         * userHasAccess */
        /**
         * Access to menu option
         ***************************************************************************/

        public static bool userHasAccess (RequestResponse rd)
        {
            /* PCAL staff have access */
            
            if (rd.wu.usr.pcalStaff == true) return true;
            
            /* Keep in synch with req/opt clientID logic in Validate.cs */
            
            /* LEA and CYBHI coordinators have access if they are a consortium lead */

            if (  (rd.wu.usr.roleID == Constants.ROLE_LEA_COORDINATOR_ID) 
               || (rd.wu.usr.roleID == Constants.ROLE_CYBHI_CORDINATOR_ID)) {
                
                if (rd.wu.usr.cybhiConsortiumBillingIsLead == true) { 
                    return true;
                }
                else {
                   return false;
                }
            }
            /* Everyone else, no access */
            return false;
        }

        /***************************************************************************
         * URL_REST_VIEW_BASE */
        /**
         *
         ***************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(URL_REST_VIEW, true);
        }
        
        /***************************************************************************
         * view */
        /**
         * Note: Keep in synch with MBA.Credentials.retrieveCybhiConsortiumMembers
         ***************************************************************************/

        public static ReturnDB view (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , string        consortiumLeadClientID
									  , int           recViewType
                                      , bool          pagedOrTop
                                      , string        idx
                                      , string        canEdit
                                      , string        active
                                      , string        term  /* Possible future use */
                                      , defineCols    dc )
        {
            string viewUDF = @"dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW (@userID, @userGroup, @userRank, @consortiumLeadClientID)";            
            var vClientID = Validate.reqClientID(uInfo,consortiumLeadClientID,false,false);
            var parms = new List<SqlParameter>();                        
            parms.Add(Database.SqlParm("@consortiumLeadClientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
        }        

        /***************************************************************************
         * viewList */
        /**
         * 
         ***************************************************************************/
		 
         public static List<ClientConsortiumMember> viewList ( SqlConnection connSpedmon
                                                              , DetailsLog    log
                                                              , UserInfo      uInfo                                                         
                                                              , string        consortiumLeadClientID) 
         {
           var recs = new List<ClientConsortiumMember>();
           ReturnDB rd = CYBHIConsortiumMembers.view (connSpedmon, log, uInfo, consortiumLeadClientID, Entities.REC_VIEW_RAW, false, null, null, null, null, null);
           List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(ClientConsortiumMember));
           foreach (var o in slo) {
             recs.Add((ClientConsortiumMember) o);
           }
           return recs;        
         }

        /***************************************************************************
         * viewObjects */
        /**
         * Returns a list of CYBHIConsortiumMember objects
         ***************************************************************************/
        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                 , DetailsLog log
                                                 , UserInfo uInfo
                                                 , bool pageObjectList
                                                 , string pageOrder
                                                 , string consortiumLeadClientID
                                                 , string idx
                                                 , string active
                                                 , string term  /* Possible future use */)
        {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = CYBHIConsortiumMember.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(CYBHIConsortiumMember)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return CYBHIConsortiumMembers.view(
                                                                         connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , consortiumLeadClientID
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" // canEdit
                                                                       , active
                                                                       , term
                                                                       , dc
                                               );
                                          });
        }
    } 
}
