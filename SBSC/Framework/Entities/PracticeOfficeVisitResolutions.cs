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
     * PracticeOfficeVisitResolution */
    /**
     ***************************************************************************/

	public class PracticeOfficeVisitResolution : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"name asc";

    }

    /***************************************************************************
     * PracticeOfficeVisitResolutions */
    /**
     ***************************************************************************/

    public class PracticeOfficeVisitResolutions : Entities
    {
        public const string URL_SERVICE_BASE  = @"practice_office_visit_resolutions.asmx";
        public const string URL_VIEW_SEL      = URL_SERVICE_BASE + @"/viewSel";
        public const string URL_SAVE_INLINE   = URL_SERVICE_BASE + @"/saveinline";   
        public const string URL_DELETE_INLINE = URL_SERVICE_BASE + @"/deleteinline";
        public const string URL_REST_VIEW     = @"api/v1/practiceofficevisitresolutions";


        /***************************************************************************
         * URL_VIEW_SEL_BASE */
        /**
         * 
         ***************************************************************************/

        public static string URL_VIEW_SEL_BASE()
        {
            return MBA.HttpApplication.createLink(URL_VIEW_SEL, true);
        }

        /***************************************************************************
         * URL_SAVE_INLINE_BASE */
        /**
         * 
         ***************************************************************************/

        public static string URL_SAVE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SAVE_INLINE, true);
        }
        /***************************************************************************
      * URL_DELETE_INLINE_BASE */
        /**
         * 
         ***************************************************************************/

        public static string URL_DELETE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_DELETE_INLINE, true);
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
        * delete */
        /**
         * 
         ***************************************************************************/
        public static ReturnSaveRecord delete(   SqlConnection connSpedmon
                                              , DetailsLog    log
                                              , UserInfo      uInfo                                                                                            
                                              , string        editDelReason
                                              , string        validateRec                                              
                                              , string        recID  )
        {

            string deleteSproc = @"PRACTICE_OFFICE_VISIT_RESOLUTIONS_DELETE";

            var parms = new List<SqlParameter>();

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, deleteSproc, ref parms);
        }

         /***************************************************************************
         * save */
        /**
         * 
         *************************************************************************/
        public static ReturnSaveRecord save (   SqlConnection connSpedmon
                                              , DetailsLog    log
                                              , UserInfo      uInfo                                              
                                              , string        name
                                              , string        editDelReason
                                              , string        validateRec
                                              , string        saveType
                                              , string        recID  )
        {

            string saveSproc = @"PRACTICE_OFFICE_VISIT_RESOLUTIONS_SAVE";

            string  vName  = Validate.reqString   (name,  @"Name required");
          
            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@name",  SqlDbType.VarChar,  vName,  ParameterDirection.Input, 256));

            return Entities.save(  connSpedmon
                                 , log
                                 , uInfo
                                 , saveType
                                 , validateRec
                                 , editDelReason
                                 , recID
                                 , saveSproc
                                 , "Resolution already exists"
                                 , ref parms
                                 , null);
        }
        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/
		 
        public static ReturnDB view (  SqlConnection connSpedmon
                                     , DetailsLog   log
                                     , UserInfo     uInfo
                                     , int          recViewType
                                     , bool         pagedOrTop
                                     , string       idx
                                     , string       canEdit
                                     , string       active
		                             , string       term                                     
                                     , defineCols   dc)
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

		    string vTerm                = Validate.optString(term);
            
            string viewUDF = "dbo.PRACTICE_OFFICE_VISIT_RESOLUTIONS_VIEW(@userID, @userGroup, @userRank, @term, @recID, @canEdit, @active)";

            var parms = new List<SqlParameter>();
			
            parms.Add(Database.SqlParm("@term",                SqlDbType.VarChar, vTerm,                ParameterDirection.Input, 256));

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

		public static ReturnSel viewSel ( SqlConnection connSpedmon
                                          , DetailsLog  log
                                          , UserInfo    uInfo
                                          , bool        paged
                                          , string      pageNumber
                                          , string      active
		                                  , string      term )
        {


            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
                //ss.addDisplayColumn("[ReasonCode] as recData2");
            };

            return Entities.viewSel(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return PracticeOfficeVisitResolutions.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, term, dc); });
        }
        
        /***************************************************************************
         * viewList */
        /**
         * 
         ***************************************************************************/
        public static List<PracticeOfficeVisitResolution> viewList(  SqlConnection  connSpedmon
                                                                   , DetailsLog    log
                                                                   , UserInfo      uInfo                                                                
                                                                   , string        active)
      
       {
         var recs = new List<PracticeOfficeVisitResolution>();
         ReturnDB rd = PracticeOfficeVisitResolutions.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, "", null);
         List<Object> slo = Database.convertRecordsToList (ref rd.records, typeof(PracticeOfficeVisitResolution));
         foreach (var o in slo) {
            recs.Add((PracticeOfficeVisitResolution) o);
         }
         return recs;
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

        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PracticeOfficeVisitResolution.DEFAULT_PAGING_ORDER;

        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          pageroworder = pageOrder;
        };

        var rd = Entities.viewObjects( connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(PracticeOfficeVisitResolution)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                        return PracticeOfficeVisitResolutions.view (  connSpedmon
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

    }
}
