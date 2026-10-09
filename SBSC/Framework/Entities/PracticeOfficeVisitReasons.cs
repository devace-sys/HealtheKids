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
     * PracticeOfficeVisitReason */
    /**
     ***************************************************************************/
    public class PracticeOfficeVisitReason : Entity
    {
      public long     groupgroupSvcClassNameID;
      public bool     hasFormData;
      public string   formDataJSON;
      public long     practiceOfficeVisitResolutionID;
      public string   practiceOfficeVisitResolutionName;
      public bool     hideVisitSection; 

      public const string DEFAULT_PAGING_ORDER = @"name asc";
    }

    /***************************************************************************
     * PracticeOfficeVisitReasons */
    /**
     ***************************************************************************/
    public class PracticeOfficeVisitReasons : Entities
    {
        public const string SEL_LABEL         = @"Practice Office Visit Reasons";
        public const string SEL_LABEL_MANAGE  = @"Manage";

        public const string URL_SERVICE_BASE  = @"practice_office_visit_reasons.asmx";
        public const string URL_SAVE_INLINE   = URL_SERVICE_BASE + @"/saveinline";
        public const string URL_DELETE_INLINE = URL_SERVICE_BASE + @"/deleteinline";
        public const string URL_VIEW_SEL      = URL_SERVICE_BASE + @"/viewSel";
        public const string URL_REST_VIEW     = @"api/v1/practiceofficevisitreasons";

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
        public static ReturnSaveRecord delete(SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , string editDelReason
                                              , string validateRec
                                              , string recID)
        {

            string deleteSproc = @"PRACTICE_OFFICE_VISIT_REASONS_DELETE";

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
                                              , string        groupServiceClassNameID
                                              , string        formDataJSON
                                              , string        practiceOfficeVisitResolutionID
                                              , string        hideVisitSection
                                              , string        editDelReason
                                              , string        validateRec
                                              , string        saveType
                                              , string        recID  )
        {

            string saveSproc = @"PRACTICE_OFFICE_VISIT_REASONS_SAVE";

            string dupRecMsg = @"Reason already exists";

            if (string.IsNullOrEmpty(practiceOfficeVisitResolutionID) || practiceOfficeVisitResolutionID.Equals(""))
            {
                practiceOfficeVisitResolutionID = "-1";
            }

            string  vName                            = Validate.reqString   (name,                            @"Name required");
            long    vGroupSvcClassNameID             = Validate.reqInteger  (groupServiceClassNameID,         @"Please select a valid practice family");
            string  vFormDataJSON                    = Validate.optString   (formDataJSON,                    @"Invalid form data");
            Object  vPracticeOfficeVisitResolutionID = Validate.optInteger  (practiceOfficeVisitResolutionID, @"Please select a valid resolution ID");
            Object vHideVisitSection                 = Validate.optFlag     (hideVisitSection,                Messages.INVALID_FLAG);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@groupSvcClassNameID",                        SqlDbType.BigInt,   vGroupSvcClassNameID,                    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@name",                                       SqlDbType.VarChar,  vName,                                   ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@formDataJSON",                               SqlDbType.VarChar,  vFormDataJSON,                           ParameterDirection.Input));
            parms.Add(Database.SqlParm("@practiceOfficeVisitResolutionID",            SqlDbType.BigInt,   vPracticeOfficeVisitResolutionID,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@hideVisitSection",                           SqlDbType.Bit,      vHideVisitSection,                       ParameterDirection.Input));

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
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
									 , string       groupServiceClassNameID
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
            long   vGroupSvcClassNameID = Validate.reqStdGroupSvcClassNameID (uInfo,groupServiceClassNameID);
            
            string viewUDF = "dbo.PRACTICE_OFFICE_VISIT_REASONS_VIEW(@userID, @userGroup, @userRank,@groupSvcClassNameID, @term, @recID, @canEdit, @active)";

            var parms = new List<SqlParameter>();
			
            parms.Add(Database.SqlParm("@term",                SqlDbType.VarChar, vTerm,                ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt,  vGroupSvcClassNameID, ParameterDirection.Input));

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
										  , string      groupSvcClassNameID
                                          , string      term )
        {


            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
                //ss.addDisplayColumn("[ReasonCode] as recData2");
            };

            return Entities.viewSel(connSpedmon, log, uInfo, paged, pageNumber,
              delegate { return PracticeOfficeVisitReasons.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, paged, pageNumber, "", active, groupSvcClassNameID, term, dc); });
        }
       
        /***************************************************************************
         * viewList */
        /**
         * 
         ***************************************************************************/
        public static List<PracticeOfficeVisitReason> viewList (   SqlConnection  connSpedmon
                                                                 , DetailsLog     log
                                                                 , UserInfo       uInfo
                                                                 , string         groupSvcClassNameID
                                                                 , string         active )
      
        {
          var recs = new List<PracticeOfficeVisitReason>();
          ReturnDB rd = PracticeOfficeVisitReasons.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, groupSvcClassNameID, "", null);
          List<Object> slo = Database.convertRecordsToList (ref rd.records, typeof(PracticeOfficeVisitReason));
          foreach (var o in slo) {
            recs.Add((PracticeOfficeVisitReason) o);
          }
          return recs;
        }

        /***************************************************************************
         * generateSelectOptionsMarkup */
        /**
         * 
         ***************************************************************************/
        public static string generateSelectOptionsMarkup (   SqlConnection  connSpedmon
                                                            , DetailsLog     log
                                                            , UserInfo       uInfo
                                                            , string         groupSvcClassNameID )
      
        {
         StringBuilder sb = new StringBuilder(); 
         var recs = viewList(connSpedmon,log,uInfo,groupSvcClassNameID,"Y");
         sb.Append(@"<option disabled=""disabled"" selected=""selected"" value="""">Select A Reason</option>");
         foreach (PracticeOfficeVisitReason rec in recs) {
           sb.AppendFormat(@"<option value=""{0}"">{1}</option>",rec.id,rec.name);
         }
         return sb.ToString();
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
                                                , string        groupServiceClassNameID
                                                , string        term )
       {
         /* Default page order */

        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PracticeOfficeVisitReason.DEFAULT_PAGING_ORDER;

        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          pageroworder = pageOrder;
        };

        var rd = Entities.viewObjects( connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(PracticeOfficeVisitReason)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                        return PracticeOfficeVisitReasons.view (  connSpedmon
                                                                                 , log
                                                                                 , uInfo
                                                                                 , Entities.REC_VIEW_OBJECTS
                                                                                 , pageObjectList
                                                                                 , idx
                                                                                 , "" /* Can Edit */
                                                                                 , active                                                                                 
                                                                                 , groupServiceClassNameID
                                                                                 , term
                                                                                 , dc );
                                   });
            
         return rd;
       }

       /***************************************************************************
        * load */
       /**
        * 
        ***************************************************************************/
       public static PracticeOfficeVisitReason load (  SqlConnection connSpedmon
                                                      , DetailsLog    log
                                                      , UserInfo      uInfo                                                 
                                                      , string        groupServiceClassNameID
                                                      , string        recID )
       {      
          return (PracticeOfficeVisitReason) Entities.load(connSpedmon, log, uInfo, recID, typeof(PracticeOfficeVisitReason),
          delegate { 
            return PracticeOfficeVisitReasons.view (
                connSpedmon
              , log
              , uInfo
              , Entities.REC_VIEW_LOAD
              , false
              , recID
              , ""
              , ""
              , groupServiceClassNameID
              , "" 
              , null );
           }
        );
      } 

    }
}
