using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;



using System.Text;


using System.Linq;
using System.Collections.ObjectModel;
using System.Web.UI.WebControls;
using System.Collections;
using System.Collections.Specialized;
using System.Web.Script.Serialization;


using MBA;

namespace Spedmon
{


    public class RmtsMomentMissingOrUndocumentedStatsObj : Entity
    {

       public int  numActionRequired ;
       public int  numUploadedDocumentationOnly ;

       public int  numUnmatchedActionRequired;
       public int  numNoDocsActionRequired;


       public int  numAwaitingCoord;
       public int numDeferred;
       public int numParticipantsWoSvcrecs;
       public int numPossibleAppeals;
       public int numAwaitingCodeReview;

    }

 

    public class RmtsMomentMissingOrUndocumentedStatsObjs : Entities
    {

        public const string URL_PAGE_STATSDASH = "user_all_rmts_healthdash_stats.aspx";

        public const string URL_SVC_BASE = @"rmts_moments.asmx";


        public const string URL_STATS_MISSING_FOR_CLIENT = URL_SVC_BASE + @"/statsmissingforclient";

        public static string URL_STATS_MISSING_FOR_CLIENT_BASE()
        {
          return MBA.HttpApplication.createLink(RmtsMoments.URL_STATS_MISSING_FOR_CLIENT, true);
        }

        public static string URL_PAGE_STATSDASH_BASE()
        {
            return MBA.HttpApplication.createLink(RmtsMomentMissingOrUndocumentedStatsObjs.URL_PAGE_STATSDASH,
               true ,
               new NameValue(Constants.PARM_CONTENT_ONLY, 1)
            );
        }

        public static string URL_PAGE_STATSDASH_PRE_BASE()
        {
            return MBA.HttpApplication.createLink(RmtsMomentMissingOrUndocumentedStatsObjs.URL_PAGE_STATSDASH,
              true,
              new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE) ,
              new NameValue("ispreview", "1") ,
              new NameValue(Constants.PARM_CONTENT_ONLY, 1)
            );
        }


        /***************************************************************************
         * view */
        /**
         *
         **************************************************************************/
        public static ReturnObject viewStatsMissingOrUndocumented(
                                          SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo

                                        , string clientid
                                        , string quarterID = null

                                        , string fyID = null
                    , string quarterNum = null)
        {

            Object vClientID = Validate.optClientID(uInfo, clientid);

            Object vQuarterID = Validate.optInteger(quarterID, "error: quarter ID");


            Object vFyID = Validate.optInteger(fyID, "error: quarter ID");
            Object vQuarterNum = Validate.optInteger(quarterNum, "error: quarter ID");


            List<SqlParameter> prms = new List<SqlParameter>();

            prms.Add(
              Database.SqlParm("@environmentID", SqlDbType.Int, Constants.STORED_FILES_APP_ENVIRONMENT, ParameterDirection.Input)
            );

            prms.Add(Database.SqlParm("@fyquarterid", SqlDbType.BigInt, vQuarterID, ParameterDirection.Input));

            prms.Add(Database.SqlParm("@fyID", SqlDbType.BigInt, vFyID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@quarterNum", SqlDbType.BigInt, vQuarterNum, ParameterDirection.Input));


            prms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
            };

            string viewUDF = "dbo.RMTS_MOMENTS_2A_STATS_MISSING_OR_UNDOCUMENTED ( @userID, @userGroup, @userRank, @recid, @environmentID, @fyquarterid, @fyID, @quarterNum, @clientID )";

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/
            return Entities.viewObject(connSpedmon
                                                 , log
                                                 , uInfo
                                                 , typeof(RmtsMomentMissingOrUndocumentedStatsObj)
                                                 , delegate () {
                                                     return Entities.view(connSpedmon, log, uInfo,
                                                         Entities.REC_VIEW_RPT, // NOTE: definecols ignored in call unless we use REC_VIEW_RPT
                                                         true /* paged */, "1" /* pagesize */, "1" /* pageNumber */, "" /* canEdit */, "1" /* active */, viewUDF, ref prms, null, dc);
                                                 });
        }

    }

}
