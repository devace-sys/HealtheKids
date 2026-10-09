using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    public class UsersPcal : Entities
    {

        public const string URL_SVC_BASE = @"users_pcal.asmx";
        public const string URL_VIEW_SEL = URL_SVC_BASE + "/viewSelInputStaff";
        public const string URL_VIEW_SEL_STAFF = URL_SVC_BASE + "/viewSelStaff";

        /***************************************************************************
         * URL_VIEW_SEL_BASE */
        /**
         *
         **************************************************************************/
        public static string URL_VIEW_SEL_BASE()
        {
            return MBA.HttpApplication.createLink(UsersPcal.URL_VIEW_SEL, true);
        }

        /***************************************************************************
         * URL_VIEW_SEL_STAFF_BASE */
        /**
         * Input staff and work leaders (no role filter)
         **************************************************************************/
        public static string URL_VIEW_SEL_STAFF_BASE()
        {
            return MBA.HttpApplication.createLink(UsersPcal.URL_VIEW_SEL_STAFF, true);
        }

        /***************************************************************************
         * viewSelStaff */
        /**
         * Returns all active Pcal staff (input staff + work leaders)
         ***************************************************************************/

        public static ReturnSel viewSelStaff(SqlConnection connUsers
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , bool top
                                               , string topSize
                                               , string term)
        {
            return viewSel(connUsers, log, uInfo, top, topSize, "", "", term);
        }

        /***************************************************************************
         * viewSelInputStaff */
        /**
         *
         ***************************************************************************/

        public static ReturnSel viewSelInputStaff(SqlConnection connUsers
                                                     , DetailsLog log
                                                     , UserInfo uInfo
                                                     , bool top
                                                     , string topSize
                                                     , string term)
        {
            return viewSel(connUsers, log, uInfo, top, topSize, "Y", "", term);
        }

        /***************************************************************************
         * viewSel */
        /**
         * 
         ***************************************************************************/

        public static ReturnSel viewSel(SqlConnection connUsers
                                          , DetailsLog log
                                          , UserInfo uInfo
                                          , bool top
                                          , string topSize
                                          , string isInputStaff
                                          , string isClientRep
                                          , string term)
        {

            /*----------------------------
             * Parse search term
             *----------------------------*/

            string vTerm = Validate.optString(term);
            string lname = "";
            string fname = "";
            string other = "";

            Parse.searchTermToLastFirstOther(vTerm, out lname, out fname, out other);

            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
                ss.addDisplayColumn("roleName as [context1]");
                ss.addDisplayColumn("roleName as [recData2]");
            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewSel(connUsers, log, uInfo, top, topSize, delegate { return UsersPcal.view(connUsers, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, lname, fname, isInputStaff, isClientRep, "", "1", dc); });

        }


        /***************************************************************************
         * view */
        /**
         * Returns JUST PCAL users
         *           
         * @return            ReturnDB
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connUsers
                                        , DetailsLog log
                                                      , UserInfo uInfo
                                                      , int recViewType
                                      , bool pagedOrTop
                                      , string idx
                                      , string lname
                                      , string fname
                                      , string isInputStaff
                                      , string isClientRep
                                      , string canEdit
                                      , string active
                                      , defineCols dc)
        {


            string viewUDF = "dbo.USERS_VIEW_PCAL (@userID, @userGroup, @userRank, @lname, @fname, @isInputStaff, @isClientConsultant, @canEdit, @active, @recID)";
            List<SqlParameter> parms = new List<SqlParameter>();

            /*----------------------------
             * Validate params specific
             * to this method and add to 
             * params list
             *----------------------------*/

            Object vLname = Validate.optString(lname, Messages.INVALID_LNAME);
            Object vFname = Validate.optString(fname, Messages.INVALID_FNAME);
            Object vIsInputStaff = Validate.optFlag(isInputStaff, Messages.INVALID_FLAG);
            Object vIsClientRep = Validate.optFlag(isClientRep, Messages.INVALID_FLAG);

            parms.Add(Database.SqlParm("@lname", SqlDbType.NVarChar, vLname, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@fname", SqlDbType.NVarChar, vFname, ParameterDirection.Input, 50));
            parms.Add(Database.SqlParm("@isInputStaff", SqlDbType.Bit, vIsInputStaff, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@isClientConsultant", SqlDbType.Bit, vIsClientRep, ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connUsers, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }
    }
}
