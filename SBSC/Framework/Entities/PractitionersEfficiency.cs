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
    * PractitionerEfficiency */
   /**
    ***************************************************************************/ 
    public class PractitionerEfficiency
    {
        public const string DEFAULT_PAGING_ORDER = @"reportingGroup asc, pracName asc";

        public string  pracName;
        public string  disciplineGroup;
        public string  reportingGroup;
        public string  practiceFamily;
        public int     numPatsOnCaseload;
        public int     numSvcsWithoutNotes;
                
        public string c1;
        public string c2;
        public string c3;
        public string c4;
        public string c5;
        public string c6;
        public string c7;
        public string c8;
        public string c9;
        public string c10;
        public string c11;
        public string c12;
        public string c13;
        public string c14;
        public string c15;
        public string c16;
        public string c17;
        public string c18;
        public string c19;
        public string c20;
        public string c21;
        public string c22;
        public string c23;
        public string c24;
        public string c25;

        public string _c1_col_label;
        public string _c2_col_label;
        public string _c3_col_label;
        public string _c4_col_label;
        public string _c5_col_label;
        public string _c6_col_label;
        public string _c7_col_label;
        public string _c8_col_label;
        public string _c9_col_label;
        public string _c10_col_label;
        public string _c11_col_label;
        public string _c12_col_label;
        public string _c13_col_label;
        public string _c14_col_label;
        public string _c15_col_label;
        public string _c16_col_label;
        public string _c17_col_label;
        public string _c18_col_label;
        public string _c19_col_label;
        public string _c20_col_label;
        public string _c21_col_label;
        public string _c22_col_label;
        public string _c23_col_label;
        public string _c24_col_label;
        public string _c25_col_label;    
    }

    /***************************************************************************
     * PractitionersEfficiency */
    /**
     ***************************************************************************/

    public class PractitionersEfficiency : Entities
    {
        public const string SEL_LABEL          = @"Practitioner Service Opportunities";
        public const string URL_REST_VIEW_BASE = @"api/v1/practitionersefficiency";
        public const string MENU_ID            = @"pracefficiencylnk";
        public const string BODY_ID            = @"pracefficiencyrpt";

        public const string URL_USER_ALL_RPT   = @"user_all_prac_efficiency_rpt.aspx";

        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/  
        public static string URL_REST_VIEW()
        { 
          return MBA.HttpApplication.createLink(PractitionersEfficiency.URL_REST_VIEW_BASE, true);
        }
        /***************************************************************************
         * computeStartAndEndDate */
        /**
         * 
         ***************************************************************************/
        protected static void _computeStartAndEndDate (DateTime asOfDate, out DateTime vStartDate, out DateTime vEndDate)
        {
            Util.computeClaimingYear(asOfDate,out vStartDate,out vEndDate); 
        }
        
        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/
        public static ReturnDB view (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
									  , int           recViewType
                                      , bool          pagedOrTop
                                      , string        idx
                                      , string        canEdit
                                      , string        active
                                      , string        clientID
                                      , string        rptGroupID
                                      , string        pracID
                                      , string        endDate                                      
                                      , defineCols    dc )
        {
            
            string viewUDF = @"dbo.RPT_PRACTITIONERS_EFFICENCY(@userID, @userGroup, @userRank, @clientID, @rptGroupID, null, @pracID, @startDate, @endDate)";

            int      vClientID    = Validate.reqClientID(uInfo, clientID);
            DateTime vAsOfDate    = Validate.reqDate(endDate,Messages.INVALID_END_DATE);
            Object   vPracID      = Validate.optInteger(pracID, Messages.INVALID_PRAC_ID);
            Object   vRptGroupID  = Validate.optInteger(rptGroupID, "Invalid reporting group");

            DateTime vStartDate; 
            DateTime vEndDate;
            _computeStartAndEndDate (vAsOfDate,out vStartDate, out vEndDate);

            var parms = new List<SqlParameter>();                        

            parms.Add(Database.SqlParm("@clientID"  , SqlDbType.BigInt,    vClientID,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID"    , SqlDbType.BigInt,    vPracID,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@rptGroupID", SqlDbType.BigInt,    vRptGroupID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@startDate" , SqlDbType.DateTime,  vStartDate,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@endDate"   , SqlDbType.DateTime,  vEndDate,      ParameterDirection.Input));

            var _rd = Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
            _rd.additionalDataStr = Util.startAndEndDateToDateRangeStr(vStartDate,vEndDate,@"to");
            return _rd;

         }        

         /***************************************************************************
          * viewObjects */
         /**
          * 
          ***************************************************************************/
         public static ReturnObjects viewObjects (  SqlConnection connSpedmon
                                                   , DetailsLog    log
                                                   , UserInfo      uInfo  
                                                   , bool          pageObjectList
                                                   , string        pageOrder
                                                   , string        idx
                                                   , string        active
                                                   , string        clientID
                                                   , string        rptGroupID
                                                   , string        pracID
                                                   , string        endDate                                      
)
        {
          /* Default page order */
 
          if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PractitionerEfficiency.DEFAULT_PAGING_ORDER;
 
          /* Define columns delegate is used to specify columns and page order 
           * We pass in the desired page row order here */
 
          defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
          {
            pageroworder = pageOrder;
          };

          return Entities.viewObjects(connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(PractitionerEfficiency)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return PractitionersEfficiency.view(connSpedmon
                                                                       , log
                                                                       , uInfo                                                                       
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" /* Can edit */
                                                                       , "Y"
                                                                       , clientID
                                                                       , rptGroupID
                                                                       , pracID
                                                                       , endDate                                                                        
                                                                       , dc);
                                      });
 
 

        }
        
        /***************************************************************************
          * viewTbl */
         /**
          * 
          ***************************************************************************/
        public static ReturnDataTable viewTbl (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                  bool paged,
                                  string pageNumber,
                                  string canEdit,
                                  string clientID,
                                  string rptGroupID,
                                  string pracID,
                                  string endDate)
        {    
            
            ReturnDataTable rdt;

            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("pracName as [Practitioner Name]", true);
                ss.addDisplayColumn("disciplineGroup as [Discipline]");
                ss.addDisplayColumn("reportingGroup as [Reporting Group]");
                ss.addDisplayColumn("practiceFamily as [Practice Family]");
                ss.addDisplayColumn("numSvcsWithoutNotes as [Number Of Service Records Without Notes]");
                
                ss.addDisplayColumn("_c1_col_label");
                ss.addDisplayColumn("c1");
                
                ss.addDisplayColumn("_c2_col_label");
                ss.addDisplayColumn("c2");
                
                ss.addDisplayColumn("_c3_col_label");
                ss.addDisplayColumn("c3");

                ss.addDisplayColumn("_c4_col_label");
                ss.addDisplayColumn("c4");
                
                ss.addDisplayColumn("_c5_col_label");
                ss.addDisplayColumn("c5");

                ss.addDisplayColumn("_c6_col_label");
                ss.addDisplayColumn("c6");
                
                ss.addDisplayColumn("_c7_col_label");
                ss.addDisplayColumn("c7");

                ss.addDisplayColumn("_c8_col_label");
                ss.addDisplayColumn("c8");

                ss.addDisplayColumn("_c9_col_label");
                ss.addDisplayColumn("c9");

                ss.addDisplayColumn("_c10_col_label");
                ss.addDisplayColumn("c10");

                ss.addDisplayColumn("_c11_col_label");
                ss.addDisplayColumn("c11");

                ss.addDisplayColumn("_c12_col_label");
                ss.addDisplayColumn("c12");

                ss.addDisplayColumn("_c13_col_label");
                ss.addDisplayColumn("c13");

                ss.addDisplayColumn("_c14_col_label");
                ss.addDisplayColumn("c14");

                ss.addDisplayColumn("_c15_col_label");
                ss.addDisplayColumn("c15");

                ss.addDisplayColumn("_c16_col_label");
                ss.addDisplayColumn("c16");

                ss.addDisplayColumn("_c17_col_label");
                ss.addDisplayColumn("c17");

                ss.addDisplayColumn("_c18_col_label");
                ss.addDisplayColumn("c18");

                ss.addDisplayColumn("_c19_col_label");
                ss.addDisplayColumn("c19");

                ss.addDisplayColumn("_c20_col_label");
                ss.addDisplayColumn("c20");

                ss.addDisplayColumn("_c21_col_label");
                ss.addDisplayColumn("c21");

                ss.addDisplayColumn("_c22_col_label");
                ss.addDisplayColumn("c22");

                ss.addDisplayColumn("_c23_col_label");
                ss.addDisplayColumn("c23");

                ss.addDisplayColumn("_c24_col_label");
                ss.addDisplayColumn("c24");

                ss.addDisplayColumn("_c25_col_label");
                ss.addDisplayColumn("c25");

                pageroworder = ss.pageRowOrder();
            };

          /*----------------------------
           * Call base method which
           * handles the rest and return
           * results
           *----------------------------*/
          
          Client c = Clients.load(connSpedmon, log, uInfo, clientID);  
            
          string tableName = String.Format(@"{0} - {1} - For Dates of Service "
                                            , c.name
                                            , SEL_LABEL);
                     
          string _additionalDataStr = @"";
          rdt = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber
              , delegate {                                           
                  var _rd = PractitionersEfficiency.view (connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, "", clientID, rptGroupID, pracID, endDate,  dc); 
                  _additionalDataStr = _rd.additionalDataStr;
                  return _rd;
              }
          , tableName
          , Messages.CONFIDENTIAL);

          rdt.tableName = rdt.tableName + _additionalDataStr;
          rdt.columnTitlesReplaceSpacesWithBreaks = true;

          return rdt;

        }
    }
}
