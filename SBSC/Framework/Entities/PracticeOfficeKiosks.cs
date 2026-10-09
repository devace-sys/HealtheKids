using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{

    /**************************************************************************
     * PracticeOfficeKiosk*/
    /**
     ***************************************************************************/

    public class PracticeOfficeKiosk : Entity
    {
        public static string DEFAULT_PAGING_ORDER = "siteName asc, name asc";

        public long     clientID;
        public long     groupSvcClassNameID;
        public long     siteID;
        public string   siteName;
        public string   publicToken;
        public TimeSpan startTime;
        public TimeSpan endTime;        
    }

    /**************************************************************************
     * PracticeOfficeKiosks*/
    /**
     ***************************************************************************/

    public class PracticeOfficeKiosks : Entities
    {
        public const string URL_REST_VIEW             = @"api/v1/practiceofficekiosks";
        public const string URL_WEB_SVC               = @"practice_office_kiosks.asmx";
        public const string URL_SVC_DELETE_INLINE     = URL_WEB_SVC + @"/deleteinline";
        public const string URL_SVC_SAVE_INLINE       = URL_WEB_SVC + @"/saveinline";

        /***************************************************************************
         * URL_SVC_SAVE_INLINE_BASE */
        /**
         * 
         **************************************************************************/
		 public static string URL_SVC_SAVE_INLINE_BASE()
         {
           return MBA.HttpApplication.createLink(PracticeOfficeKiosks.URL_SVC_SAVE_INLINE, true);
         }

        /***************************************************************************
         * URL_SVC_DELETE_INLINE_BASE */
        /**
         * 
         **************************************************************************/
		 public static string URL_SVC_DELETE_INLINE_BASE()
         {
           return MBA.HttpApplication.createLink(PracticeOfficeKiosks.URL_SVC_DELETE_INLINE, true);
         }

        /***************************************************************************
         * URL_REST_VIEW_BASE */
        /**
         * 
         **************************************************************************/

		public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(PracticeOfficeKiosks.URL_REST_VIEW, true);
        }


        /***************************************************************************
          * save */
        /**
         *
         **************************************************************************/

        public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , string clientID
                                              , string groupSvcClassNameID
                                              , string siteID
                                              , string name
                                              , string startTime
                                              , string endTime
                                              , string editDelReason
                                              , string validateRec
                                              , string saveType
                                              , string recID)
        {

            /* Set name of sproc */

            string saveSproc = "PRACTICE_OFFICE_KIOSKS_SAVE";

            /* Validate */

            long vClientID = Validate.reqClientID(uInfo, clientID);
            long vGroupSvcClassNameID = Validate.reqStdGroupSvcClassNameID(uInfo, groupSvcClassNameID);
            long vSiteID = Validate.reqInteger(siteID, @"Invalid site");
            Object vName = Validate.optString(name, @"Invalid name");
            Object vStartTime = Validate.optTime(startTime, @"Invalid start time");
            Object vEndTime = Validate.optTime(endTime, @"Invalid end time");


            /* Populate db parameters */

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt, vGroupSvcClassNameID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@siteID", SqlDbType.BigInt, vSiteID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@name", SqlDbType.VarChar, vName, ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@startTime", SqlDbType.Time, vStartTime, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@endTime", SqlDbType.Time, vEndTime, ParameterDirection.Input));

            /* Call base method */

            return Entities.save(connSpedmon
                                   , log
                                   , uInfo
                                   , saveType
                                   , validateRec
                                   , editDelReason
                                   , recID
                                   , saveSproc
                                   , @"Duplicate kiosk"
                                   , ref parms
                                   , delegate () { });

        }

        /***************************************************************************
         * delete */
        /**
         *
         **************************************************************************/

        public static ReturnSaveRecord delete (  SqlConnection connSpedmon
                                                , DetailsLog   log
                                                , UserInfo     uInfo
                                                , string       clientID
                                                , string       groupSvcClassNameID
                                                , string       editDelReason
                                                , string       validateRec
                                                , string       recID )
        {

            /* Set name of sproc */

            string deleteSproc = "PRACTICE_OFFICE_KIOSKS_DELETE";

            /* Validate */

            long vClientID            = Validate.reqClientID(uInfo, clientID);
            long vGroupSvcClassNameID = Validate.reqStdGroupSvcClassNameID(uInfo, groupSvcClassNameID);
            

            /* Populate db parameters */

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt, vGroupSvcClassNameID, ParameterDirection.Input));
            
            /* Call base method */

            return Entities.delete ( connSpedmon
                                     , log
                                     , uInfo                                    
                                     , editDelReason
                                     , validateRec
                                     , recID
                                     , deleteSproc                                   
                                     , ref parms );

        }
        
        /***************************************************************************
         * view */
        /**
         *
         **************************************************************************/

        protected static ReturnDB view (   SqlConnection connSpedmon
                                          , DetailsLog log
                                          , UserInfo uInfo
                                          , string clientID
                                          , string groupSvcClassNameID
                                          , int recViewType
                                          , bool pagedOrTop
                                          , string idx
                                          , string canEdit
                                          , string active
                                          , defineCols dc)
        {

            /* Set name of udf */

            string viewUDF = "PRACTICE_OFFICE_KIOSKS_VIEW (@userID, @userGroup, @userRank, @clientID, @groupSvcClassNameID, @active, @recID)";

            /* Validate */

            long vClientID = Validate.reqClientID(uInfo, clientID);
            Object vGroupSvcClassNameID = Validate.optStdGroupSvcClassNameID(uInfo, groupSvcClassNameID);

            /* Populate db parameters */

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt, vGroupSvcClassNameID, ParameterDirection.Input));

            /* Call base method */

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * viewObjects */
        /**
         ***************************************************************************/
        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
                                                   , bool pageObjectList
                                                   , string pageOrder
                                                   , string idx
                                                   , string clientID
                                                   , string groupSvcClassNameID)
        {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PracticeOfficeKiosk.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            var rd = Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(PracticeOfficeKiosk)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return PracticeOfficeKiosks.view(connSpedmon
                                                                              , log
                                                                              , uInfo
                                                                              , clientID
                                                                              , groupSvcClassNameID
                                                                              , Entities.REC_VIEW_OBJECTS
                                                                              , pageObjectList
                                                                              , idx
                                                                              , null
                                                                              , "Y" /* Active */
                                                                              
                                                                              , dc);
                                          });

            return rd;
        }

        /***************************************************************************
         * delete */
        /**
         *
         **************************************************************************/
        public static ReturnSaveRecord delete(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , string editDelReason
                                                , string validateRec
                                                , string recID)
        {

            /*----------------------------
             * Check for required and 
             * optional parameters
             * and validate data integrity
             * of all supplied parameters
             *----------------------------*/

            Object vClientID          = Validate.optClientID(uInfo, "");
            long vGroupSvcClassNameID = Validate.reqStdGroupSvcClassNameID(uInfo, "");

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * delete method.
             *----------------------------*/

            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt, vGroupSvcClassNameID, ParameterDirection.Input));

            /*----------------------------
             * Call base method 
             *----------------------------*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "PRACTICE_OFFICE_KIOSKS_DELETE", ref parms);
        }
    }

}

