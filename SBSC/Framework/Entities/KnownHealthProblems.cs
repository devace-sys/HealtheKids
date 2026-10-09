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
     * KnownHealthProblem */
    /**
     ***************************************************************************/

    public class KnownHealthProblem : Entity
    {
      public const string DEFAULT_PAGING_ORDER = @"name asc";


      public bool belongsToHealthServices;
      public bool belongsToMentalHealth;

      public string belongsToHealthServicesYN;
      public string belongsToMentalHealthYN;


    }

    /***************************************************************************
     * KnownHealthProblems */
    /**
     ***************************************************************************/

    public class KnownHealthProblems : Entities
    {
        public const string SEL_LABEL               = @"Known Health Problem Selections";
        public const string SEL_LABEL_MANAGE        = SEL_LABEL + @" - Manage";
        public const string URL_SERVICE_BASE        = @"KnownHealthProblems.asmx";
        public const string URL_VIEW_SEL            = URL_SERVICE_BASE + @"/viewSel";
        public const string URL_SAVE_INLINE         = URL_SERVICE_BASE + @"/saveinline";
        public const string URL_SBS_ALL_MANAGE      = @"sbs_all_known_health_problems_manage.aspx";
        public const string MENU_LNK_SBS_ALL_MANAGE = @"sbsallknownhealthproblemsmanagelnk";
        public const string URL_REST_VIEW           = @"api/v1/knownhealthproblems";
        public const string URL_DELETE_INLINE       = URL_SERVICE_BASE + @"/deleteinline";

        /***************************************************************************
         * viewSelBase */
        /**
         * 
         *************************************************************************/

        public static string URL_VIEW_SEL_BASE()
        {
            return MBA.HttpApplication.createLink(URL_VIEW_SEL, true);
        }

        /***************************************************************************
         * URL_SAVE_INLINE_BASE */
        /**
         * 
         *************************************************************************/

        public static string URL_SAVE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SAVE_INLINE, true);
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
         * URL_DELETE_INLINE_BASE */
        /**
         * 
         *************************************************************************/

        public static string URL_DELETE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_DELETE_INLINE, true);
        }

        /***************************************************************************
         * save */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord save (   SqlConnection connSpedmon
                                              , DetailsLog   log
                                              , UserInfo     uInfo
                                              , string       name

                                              , string       belongsToHealthServices
                                              , string       belongsToMentalHealth

                                              , string       editDelReason
                                              , string       validateRec
                                              , string       saveType
                                              , string       recID )
        {

            string saveSproc = @"KNOWN_HEALTH_PROBLEMS_SAVE";
            string dupRecMsg = @"Selection already exists";

            string vName = Validate.reqString(name,Messages.INVALID_SELECTION_NAME);

            bool vHealthServices  =  Validate.reqFlag( belongsToHealthServices, "health services?", true);
            bool vMentalHealth    =  Validate.reqFlag( belongsToMentalHealth,   "mental health?",   true);

            var parms = new List<SqlParameter>();
            
            parms.Add(Database.SqlParm("@name", SqlDbType.VarChar, vName, ParameterDirection.Input, 500));

            parms.Add(Database.SqlParm("@belongsToMentalHealth",   SqlDbType.Bit, vMentalHealth   , ParameterDirection.Input ));
            parms.Add(Database.SqlParm("@belongsToHealthServices", SqlDbType.Bit, vHealthServices , ParameterDirection.Input ));


            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }

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

            string viewUDF = "dbo.KNOWN_HEALTH_PROBLEMS_VIEW (@userID, @userGroup, @userRank, @groupSvcClassNameID, @term, @recID, @canEdit, @active)";
            

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var vGroupSvcClassNameID = Validate.optStdGroupSvcClassNameID(uInfo, "");
            
            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt,  vGroupSvcClassNameID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@term",                SqlDbType.VarChar, term,                 ParameterDirection.Input, 256));

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

        public static ReturnSel viewSel(SqlConnection connSpedmon
                                         , DetailsLog log
                                         , UserInfo uInfo
                                         , bool paged
                                         , string pageNumber
                                         , string active
                                         , string term)
        {

            string vTerm = Validate.optString(term);

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
            };
            return Entities.viewSel(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return KnownHealthProblems.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, vTerm, dc); });
        }
       
      /***************************************************************************
       * viewObjects */
      /**       
       * 
       * @return                 ReturnObjects
       ***************************************************************************/
       public static ReturnObjects viewObjects (  SqlConnection connSpedmon
                                                , DetailsLog    log
                                                , UserInfo      uInfo
                                                , bool          pageObjectList
                                                , string        pageOrder
                                                , string        idx
                                                , string        active                                                
                                                , string        term )
       {
         /* Default page order */

        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = KnownHealthProblem.DEFAULT_PAGING_ORDER;

        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          pageroworder = pageOrder;
        };

        var rd = Entities.viewObjects( connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(KnownHealthProblem)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                        return KnownHealthProblems.view (  connSpedmon
                                                                          , log
                                                                          , uInfo
                                                                          , Entities.REC_VIEW_OBJECTS
                                                                          , pageObjectList
                                                                          , idx
                                                                          , "" /* Can Edit */
                                                                          , active                                                                                 
                                                                          , term
                                                                          , dc );
                                   });
            
         return rd;
       }

      /***************************************************************************
       * delete */
      /**
       * 
       *************************************************************************/

      public static ReturnSaveRecord delete (
             SqlConnection connSpedmon
            , DetailsLog   log
            , UserInfo     uInfo
            , string       editDelReason
            , string       validateRec
            , string       recID )
      {

        var parms = new List<SqlParameter>();
        return Entities.delete(  connSpedmon
                               , log
                               , uInfo
                               , editDelReason
                               , validateRec
                               , recID
                               , "KNOWN_HEALTH_PROBLEMS_DELETE"
                               , ref parms);
      }

    }
}
