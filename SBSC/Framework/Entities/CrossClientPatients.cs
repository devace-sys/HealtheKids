
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * CrossClientPatient */
    /**
     * For future use.
     *************************************************************************/

    public class CrossClientPatient: Person 
    {
        public long     patID;
        public string   preferredNickname;
        public string   CSIS;
        public DateTime dob;
        public string   dobStrYMD;
        public string   gender;
        public int?     ageCurrent;
        public bool     recExistsForCallingClient;
        public string   ageCurrentStr;        
        public string   recExistsForCallingClientStr;
        public string   clientIDStr;
        public string   patIDStr;
    }

    /***************************************************************************
     * CrossClientPatients */
    /**
     * This is a read only type of entity
     *************************************************************************/

    public class CrossClientPatients : Entities
    {

        public const string URL_WEB_SERVICE           = @"cross_client_patients.asmx";
        public const string URL_VIEW_SEL_FOR_NEW_RECS = URL_WEB_SERVICE + @"/viewselfornewrecords";
        
        /***************************************************************************
         * URL_VIEW_SEL_FOR_NEW_RECS_BASE() */
        /**
         * 
         *************************************************************************/

        public static string URL_VIEW_SEL_FOR_NEW_RECS_BASE()
        {
            return MBA.HttpApplication.createLink(URL_VIEW_SEL_FOR_NEW_RECS, true);
        }

        /***************************************************************************
         * view */
        /**
         * 
         *************************************************************************/

        protected static ReturnDB view (  SqlConnection connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , int           recViewType
                                         , bool          pagedOrTop
                                         , string        idx
                                         , string        canEdit
                                         , string        clientID
                                         , string        ssid
									     , string        active
										 , bool          excludeOtherClientDataIfCallingClientHasRecs
									     , bool          excludeOtherClientIDAndPatID                                         
                                         , defineCols dc)
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            int vClientID = Validate.reqClientID   (uInfo, clientID);
            var vSSID     = Validate.reqCSISOrSSID (ssid,Messages.INVALID_CSIS);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@ssid",     SqlDbType.VarChar, vSSID, ParameterDirection.Input,50));
               
            /* Note: These are internal flags only.  Dont expose to web services, etc */

            parms.Add(Database.SqlParm("@excludeOtherClientDataIfCallingClientHasRecs", SqlDbType.Bit, excludeOtherClientDataIfCallingClientHasRecs, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@excludeOtherClientIDAndPatID",                 SqlDbType.Bit, excludeOtherClientIDAndPatID,                 ParameterDirection.Input));

            string viewUDF = "CROSS_CLIENT_PATIENTS_VIEW (@userID, @userGroup, @userRank, @clientID, @ssid, @excludeOtherClientDataIfCallingClientHasRecs, @excludeOtherClientIDAndPatID)";

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * viewSelForNewRecs */
        /**
         * recData slot allocation
         * -----------------------
         * 
         * lastName                     : recData1
         * firstName                    : recData2
         * middleName                   : recData3
         * preferredNickname            : recData4
         * dobStrYMD                    : recData5
         * gender                       : recData6
         * CSIS                         : recData7
         * ageCurrentStr                : recData8              
         * recExistsForCallingClientStr : recData9
         * clientIDStr                  : recData10
         * patIDStr                     : recData11
         ***************************************************************************/

        public static ReturnSel viewSelForNewRecs (  SqlConnection connSpedmon
                                                   , DetailsLog    log
                                                   , UserInfo      uInfo
                                                   , bool          paged
                                                   , string        pageNumber
                                                   , string        active
                                                   , string        clientID
                                                   , string        ssid )
        {
            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
              ss.addDisplayColumn("name as label");
           
              ss.addDisplayColumn("lastName as recData1");
              ss.addDisplayColumn("firstName as recData2");
              ss.addDisplayColumn("middleName as recData3");
              ss.addDisplayColumn("preferredNickname as recData4");

              ss.addDisplayColumn("dobStrYMD as recData5");
              ss.addDisplayColumn("gender as recData6");
              ss.addDisplayColumn("CSIS as recData7");
              ss.addDisplayColumn("ageCurrentStr as recData8");
              
              ss.addDisplayColumn("recExistsForCallingClientStr as recData9");
              ss.addDisplayColumn("clientIDStr as recData10");
              ss.addDisplayColumn("patIDStr    as recData11");

            };

            return Entities.viewSel(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return CrossClientPatients.view (
                    connSpedmon
                  , log
                  , uInfo
                  , Entities.REC_VIEW_SEL
                  , paged
                  , pageNumber
                  , ""
                  , clientID
                  , ssid
                  , active 
                  , true
                  , false
                  , dc); });
        }        
   }
}
