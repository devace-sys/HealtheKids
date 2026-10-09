using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * TeleCommIEPType  */
    /**
     *
     ***************************************************************************/

    public class ContactMethod : Entity
    {
        public long id;
        public int code;
        public string name;
    }

    /***************************************************************************
     * TeleCommIEPTypes  */
    /**
     *
     ***************************************************************************/

    public class ContactMethods : Entities
    {
        public const string SEL_LABEL_MANAGE    = @"Contact Methods";
        public const string URL_WEB_SERVICE     = @"contact_methods.asmx";
        public const string URL_VIEW_SEL        = URL_WEB_SERVICE + @"/viewSel";


        public static string URL_VIEW_SEL_BASE()
        {
            return MBA.HttpApplication.createLink(URL_VIEW_SEL, true);
        }

        /***************************************************************************
        * view */
        /**
         *
         **************************************************************************/
        public static ReturnDB view  (  SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , int           recViewType
                                      , bool          pagedOrTop
                                      , string        idx
                                      , string        canEdit
                                      , string        active
                                      , string        term
                                      , defineCols    dc )
        {

            string viewUDF = @"dbo.CONTACT_METHODS_VIEW (@userID, @userGroup, @userRank, @term, @active)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            string vTerm = Validate.optString(term, @"Invalid search term");

            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, vTerm, ParameterDirection.Input, 256));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/


            return Entities.view (  connSpedmon
                                  , log
                                  , uInfo
                                  , recViewType
                                  , pagedOrTop
                                  , idx
                                  , canEdit
                                  , active
                                  , viewUDF
                                  , ref parms
                                  , null
                                  , dc );
        }

        /***************************************************************************
        * viewSel */
        /**
         * Returns a data table of records for preview or record selection.
         *
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnSel viewSel(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize, string term)
        {

            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
            };

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return ContactMethods.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top,"", "", "Y", term, dc); });

        }
    }
}
