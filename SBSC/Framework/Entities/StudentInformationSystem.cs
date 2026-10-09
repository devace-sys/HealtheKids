using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * StudentInformationSystem */
    /**
     * 
     *************************************************************************/

    public class StudentInformationSystem
    {
        public long      id;
        public string    name;
        public string    additionalDataJSON;
        public DateTime  created;
        public long      createdBy;
        public DateTime? lastModified;
        public long?     lastModifiedBy;
        public bool      active;
    }

    /***************************************************************************
     * StudentInformationSystems */
    /**
     * 
     *************************************************************************/ 

    public class StudentInformationSystems : Entities
    {
        public const string ARIES            = "1";
        public const string SEIS             = "2";
        public const string URL_WEB_SVC      = @"student_information_systems.asmx";
        public const string URL_SVC_VIEW_SEL = URL_WEB_SVC + @"/viewsel";

        /***************************************************************************
         * URL_SVC_VIEW_SEL_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_SVC_VIEW_SEL_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SVC_VIEW_SEL, true);
        }

        /***************************************************************************
         * view */
        /**
         * 
         *************************************************************************/

        protected static ReturnDB view(SqlConnection connSpedmon
                                        , DetailsLog log
                                        , UserInfo uInfo
                                        , int recViewType
                                        , bool pagedOrTop
                                        , string idx
                                        , string canEdit
                                        , string active
                                        , defineCols dc)
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * corresponding database
             * parameters
             *----------------------------*/

            var parms = new List<SqlParameter>();

            string viewUDF = "dbo.STUDENT_INFORMATION_SYSTEMS_VIEW (@userID, @userGroup, @userRank)";

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

        public static ReturnSel viewSel (  SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , bool     paged
                                         , string   pageNumber )
        {
            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
            };

            return Entities.viewSel(connSpedmon, log, uInfo, paged, pageNumber,
              delegate {
                  return StudentInformationSystems.view(
             connSpedmon
           , log
           , uInfo
           , Entities.REC_VIEW_SEL
           , paged
           , pageNumber
           , ""
           , "Y"
           , dc);
              });
        }
    }
}