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
     * Allergy */
    /**
     ***************************************************************************/
    
    public class Allergy : Entity
    {
      public const string DEFAULT_PAGING_ORDER = @"name asc";
    }

    /***************************************************************************
     * Allergies */
    /**
     ***************************************************************************/

    public class Allergies : Entities
    {
        
        public const string SEL_LABEL               = @"Allergies Selections";
        public const string SEL_LABEL_MANAGE        = SEL_LABEL + @" - Manage";
        public const string URL_SERVICE_BASE        = @"Allergies.asmx";
        public const string URL_VIEW_SEL            = URL_SERVICE_BASE + @"/viewSel";
        public const string URL_SAVE_INLINE         = URL_SERVICE_BASE + @"/saveinline";
        public const string URL_SBS_ALL_MANAGE      = @"sbs_all_allergies_manage.aspx";
        public const string MENU_LNK_SBS_ALL_MANAGE = @"sbsallallergiesmanagelnk";
        public const string URL_REST_VIEW           = @"api/v1/allergies";
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
                                              , string       editDelReason
                                              , string       validateRec
                                              , string       saveType
                                              , string       recID )
        {

            string saveSproc = @"ALLERGIES_SAVE";
            string dupRecMsg = @"Selection already exists";

            string vName = Validate.reqString(name,Messages.INVALID_SELECTION_NAME);

            var parms = new List<SqlParameter>();
            
            parms.Add(Database.SqlParm("@name", SqlDbType.VarChar, vName, ParameterDirection.Input, 500));

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

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();
            string viewUDF = "dbo.ALLERGIES_VIEW(@userID, @userGroup, @userRank, @term, @recID, @canEdit, @active)";

            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, term, ParameterDirection.Input, 256));
     


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
                                         , string term
                                         )
        {

            string vTerm = Validate.optString(term);
            
            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
            };

            return Entities.viewSel(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return Allergies.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, vTerm, dc); });
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

        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = Allergy.DEFAULT_PAGING_ORDER;

        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          pageroworder = pageOrder;
        };

        var rd = Entities.viewObjects( connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(Allergy)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                        return Allergies.view (  connSpedmon
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
                               , "ALLERGIES_DELETE"
                               , ref parms);
      }

    }
}
