using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /// <summary>
    /// Defines the different types for "Services by Prac" reports
    /// </summary>
    public enum ServicesByPracRptTypes
    {
          BY_MINS         = 1
        , BY_NUM_SERVICES = 2
        , TATTLE          = 3
        , EFFICIENCY      = 4
    }    

    /***************************************************************************
     * ServiceByPracRpt
     *
     ***************************************************************************/

    public class ServiceByPracRpt
    {

    }

    /***************************************************************************
     * ServicesByPracRpt
     *
     ***************************************************************************/

    public class ServicesByPracRpt : Entities
    {
        public const string BODY_ID                = "pracsubrepts";
        public const string MENU_ID                = Practitioners.MENU_ID_TATTLE_TALE_RPT;
        public const string SEL_LABEL              = "Practitioners Submission Reports";
        public const string SEL_LABEL_BY_MINS      = "Practitioners Submission Report (by mins)";
        public const string SEL_LABEL_BY_COUNTS    = "Practitioners Submission Report (by num of services)";
        public const string SEL_LABEL_EFFICIENCY   = PractitionersEfficiency.SEL_LABEL;

        public const string SEL_LABEL_RPT_BY_MINS     = @"Service Minutes";
        public const string SEL_LABEL_RPT_BY_COUNT    = @"Number of Services";
        public const string SEL_LABEL_RPT_SUMMARY     = @"Service Record Entry Summary";
        public const string SEL_LABEL_RPT_EFFICIENCY  = PractitionersEfficiency.SEL_LABEL;

        public const string URL_USER_ALL_RPT       = @"user_all_services_by_prac_rpt.aspx";

        public const string URL_ASHX = @"services_by_prac_rpt.ashx";

        public static string URL_USER_ALL_RPT_BASE()
        {
            return MBA.HttpApplication.createLink(URL_USER_ALL_RPT, true);
        }
        
        public static string URL_ASHX_BASE()
        {
            return MBA.HttpApplication.createLink(URL_ASHX, true);
        }
        
        /***************************************************************************
         * viewRpt
         *
         ***************************************************************************/

        public static ReturnDataTable viewRpt(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                  bool paged,
                                  string pageNumber,
                                  string canEdit,
                                  string rptTypeNum,
                                  string clientID,
                                  string rptGroupID,
                                  string pracID,
                                  string endDate
        )
        {
            ServicesByPracRptTypes rptType;

            // case to enum and if invalid value, throw error
            try
            {
                int rptTypeInt = int.Parse(rptTypeNum);
                rptType = (ServicesByPracRptTypes)Enum.ToObject(typeof(ServicesByPracRptTypes), rptTypeInt);
            }
            catch (Exception ex)
            {
                throw new Exception("Invalid report type");
            }

            // choose which report to return
            switch (rptType)
            {
                case ServicesByPracRptTypes.BY_MINS:

                    return viewRptForMins(connSpedmon, log, uInfo, paged, pageNumber, canEdit, clientID, rptGroupID, pracID, endDate);

                case ServicesByPracRptTypes.BY_NUM_SERVICES:

                    return viewRptForNumOfServices(connSpedmon, log, uInfo, paged, pageNumber, canEdit, clientID, rptGroupID, pracID, endDate);
                
                case ServicesByPracRptTypes.TATTLE:

                  return viewRptPracTattle (connSpedmon, log, uInfo, paged, pageNumber, clientID, "", "", rptGroupID, pracID, endDate);
                    
                case ServicesByPracRptTypes.EFFICIENCY:
                 
                  return viewRptPracEfficiency (connSpedmon, log, uInfo, paged, pageNumber, canEdit, clientID, rptGroupID, pracID, endDate);                 
             }

            // by default return the minutes report
            return viewRptForMins(connSpedmon, log, uInfo, paged, pageNumber, canEdit, clientID, rptGroupID, pracID, endDate);
        }
        
        /***************************************************************************
         * viewRptForMins
         *
         ***************************************************************************/
        public static ReturnDataTable viewRptForMins(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                  bool paged,
                                  string pageNumber,
                                  string canEdit,
                                  string clientID,
                                  string rptGroupID,
                                  string pracID,
                                  string endDate
        )
        {

            ReturnDataTable rdt;

            List<SqlParameter> prms = new List<SqlParameter>();

            Object vClientID    = Validate.reqClientID(uInfo, clientID);
            Object vEndDate     = Validate.reqDate(endDate, Messages.INVALID_END_DATE);
            Object vPracID      = Validate.optInteger(pracID, Messages.INVALID_PRAC_ID);
            Object vRptGroupID  = Validate.optInteger(rptGroupID, "Invalid reporting group");

            prms.Add(Database.SqlParm("@clientID"   , SqlDbType.BigInt, vClientID   , ParameterDirection.Input));
            prms.Add(Database.SqlParm("@pracID"     , SqlDbType.BigInt, vPracID     , ParameterDirection.Input));
            prms.Add(Database.SqlParm("@rptGroupID" , SqlDbType.BigInt, vRptGroupID , ParameterDirection.Input));
            prms.Add(Database.SqlParm("@endDate"    , SqlDbType.Date  , vEndDate    , ParameterDirection.Input));

            string reportUDF = "dbo.SERVICE_MINS_BY_PRAC_RPT(@userID, @userGroup, @userRank, @clientID, @rptGroupID, null, @pracID, @endDate)";
            
            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

                ss.addDisplayColumn("[Practitioner Name]", true);
                ss.addDisplayColumn("[Reporting Group]");
                ss.addDisplayColumn("[Service Entered]");

                ss.addDisplayColumn("[c12(_col_label)]");
                ss.addDisplayColumn("c12");

                ss.addDisplayColumn("[c11(_col_label)]");
                ss.addDisplayColumn("c11");

                ss.addDisplayColumn("[c10(_col_label)]");
                ss.addDisplayColumn("c10");

                ss.addDisplayColumn("[c9(_col_label)]");
                ss.addDisplayColumn("c9");

                ss.addDisplayColumn("[c8(_col_label)]");
                ss.addDisplayColumn("c8");

                ss.addDisplayColumn("[c7(_col_label)]");
                ss.addDisplayColumn("c7");

                ss.addDisplayColumn("[c6(_col_label)]");
                ss.addDisplayColumn("c6");

                ss.addDisplayColumn("[c5(_col_label)]");
                ss.addDisplayColumn("c5");

                ss.addDisplayColumn("[c4(_col_label)]");
                ss.addDisplayColumn("c4");

                ss.addDisplayColumn("[c3(_col_label)]");
                ss.addDisplayColumn("c3");

                ss.addDisplayColumn("[c2(_col_label)]");
                ss.addDisplayColumn("c2");

                ss.addDisplayColumn("[c1(_col_label)]");
                ss.addDisplayColumn("c1");

                pageroworder = ss.pageRowOrder();
            };

            /* TODO: Group name */

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/
            string tableName;

            if (clientID != "")
            {  //earlier on we said that clientID was optional... 
                Client c = Clients.load(connSpedmon, log, uInfo, vClientID.ToString());
                //because the clientID param may have come in blank (depending on the user role of whoever is requesting this report),
                //we must instead use the validated client id.  vClientID.ToString()

                tableName = SEL_LABEL_RPT_BY_MINS + " for " + c.name;
            }
            else
                tableName = SEL_LABEL_RPT_BY_MINS;

            rdt = Entities.viewRpt(connSpedmon
                                     , log
                                     , uInfo
                                     , paged
                                     , pageNumber
                                     , null
                                     , reportUDF
                                     , prms
                                     , null
                                     , dc
                                     , tableName
                                     , Messages.CONFIDENTIAL);
            
            rdt.columnTitlesReplaceSpacesWithBreaks = true;

            return rdt;

        }

        /***************************************************************************
         * viewRptForNumOfServices
         *
         ***************************************************************************/
        public static ReturnDataTable viewRptForNumOfServices(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                  bool paged,
                                  string pageNumber,
                                  string canEdit,
                                  string clientID,
                                  string rptGroupID,
                                  string pracID,
                                  string endDate
        )
        {

            ReturnDataTable rdt;

            List<SqlParameter> prms = new List<SqlParameter>();

            Object vClientID    = Validate.reqClientID(uInfo, clientID);
            Object vEndDate     = Validate.reqDate(endDate, Messages.INVALID_END_DATE);
            Object vPracID      = Validate.optInteger(pracID, Messages.INVALID_PRAC_ID);
            Object vRptGroupID  = Validate.optInteger(rptGroupID, "Invalid reporting group");

            prms.Add(Database.SqlParm("@clientID"  , SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            prms.Add(Database.SqlParm("@pracID"    , SqlDbType.BigInt, vPracID  , ParameterDirection.Input));
            prms.Add(Database.SqlParm("@rptGroupID", SqlDbType.BigInt, vRptGroupID , ParameterDirection.Input));
            prms.Add(Database.SqlParm("@endDate"   , SqlDbType.Date  , vEndDate , ParameterDirection.Input));

            string reportUDF = "dbo.SERVICE_COUNTS_BY_PRAC_RPT(@userID, @userGroup, @userRank, @clientID, @rptGroupID, null, @pracID, @endDate)";
            
            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

               defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {

                ss.addDisplayColumn("[Practitioner Name]", true);
                ss.addDisplayColumn("[Reporting Group]");
                ss.addDisplayColumn("[Service Entered]");

                ss.addDisplayColumn("[c12(_col_label)]");
                ss.addDisplayColumn("c12");

                ss.addDisplayColumn("[c11(_col_label)]");
                ss.addDisplayColumn("c11");

                ss.addDisplayColumn("[c10(_col_label)]");
                ss.addDisplayColumn("c10");

                ss.addDisplayColumn("[c9(_col_label)]");
                ss.addDisplayColumn("c9");

                ss.addDisplayColumn("[c8(_col_label)]");
                ss.addDisplayColumn("c8");

                ss.addDisplayColumn("[c7(_col_label)]");
                ss.addDisplayColumn("c7");

                ss.addDisplayColumn("[c6(_col_label)]");
                ss.addDisplayColumn("c6");

                ss.addDisplayColumn("[c5(_col_label)]");
                ss.addDisplayColumn("c5");

                ss.addDisplayColumn("[c4(_col_label)]");
                ss.addDisplayColumn("c4");

                ss.addDisplayColumn("[c3(_col_label)]");
                ss.addDisplayColumn("c3");

                ss.addDisplayColumn("[c2(_col_label)]");
                ss.addDisplayColumn("c2");

                ss.addDisplayColumn("[c1(_col_label)]");
                ss.addDisplayColumn("c1");

                pageroworder = ss.pageRowOrder();
            };

            /* TODO: Group name */

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/
            string tableName;

            if (clientID != "")
            {  //earlier on we said that clientID was optional... 
                Client c = Clients.load(connSpedmon, log, uInfo, vClientID.ToString());
                //because the clientID param may have come in blank (depending on the user role of whoever is requesting this report),
                //we must instead use the validated client id.  vClientID.ToString()

                tableName = SEL_LABEL_RPT_BY_COUNT + " for " + c.name;
            }
            else
                tableName = SEL_LABEL_RPT_BY_COUNT;

            rdt = Entities.viewRpt(connSpedmon
                                     , log
                                     , uInfo
                                     , paged
                                     , pageNumber
                                     , null
                                     , reportUDF
                                     , prms
                                     , null
                                     , dc
                                     , tableName
                                     , Messages.CONFIDENTIAL);

            rdt.columnTitlesReplaceSpacesWithBreaks = true;

            return rdt;

        }


    /***************************************************************************
     * viewRptPracTattle 
     *
     ***************************************************************************/

  public static ReturnDataTable viewRptPracTattle (
  
      SqlConnection connSpedmon
     , DetailsLog   log
     , UserInfo     uInfo
     , bool         paged
     , string       pageNumber
     , string       clientID
     , string       repID
     , string       groupSvcClassNameID
     , string       rptGroupID
     , string       pracID
     , string       refDate )
  {

        ReturnDataTable rdt;
        
        var prms = new List<SqlParameter>();
      
        Object vClientID            = Validate.optClientID  ( uInfo, clientID);
        Object vRepID               = Validate.optInteger   ( repID,               Messages.INVALID_REP_ID);
        Object vGroupSvcClassNameID = Validate.optInteger   ( groupSvcClassNameID, Messages.INVALID_GROUP_FAMILY);
        Object vRptGroupID          = Validate.optInteger   ( rptGroupID,          Messages.INVALID_REPT_GROUP_ID);        
        Object vPracID              = Validate.optInteger   ( pracID,              Messages.INVALID_PRAC_ID);
        Object vRefDate             = Validate.optDate      ( refDate,             Messages.INVALID_END_DATE);

        prms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,    vClientID,             ParameterDirection.Input));
        prms.Add(Database.SqlParm("@repID",                SqlDbType.BigInt,    vRepID,                ParameterDirection.Input));
        prms.Add(Database.SqlParm("@groupSvcClassNameID",  SqlDbType.BigInt,    vGroupSvcClassNameID,  ParameterDirection.Input));
        prms.Add(Database.SqlParm("@pracID",               SqlDbType.BigInt,    vPracID,               ParameterDirection.Input));
        prms.Add(Database.SqlParm("@rptGroupID",           SqlDbType.BigInt,    vRptGroupID,           ParameterDirection.Input));
        prms.Add(Database.SqlParm("@refDate",              SqlDbType.DateTime,  vRefDate,              ParameterDirection.Input));
        
        string reportUDF = "dbo.RPT_PRAC_TATTLE_TALE (@userID, @userGroup, @userRank, @clientID, @repID, @rptGroupID, @groupSvcClassNameID, @pracID, @refDate)";

        /*----------------------------
         * Define our columns and
         * set the page order for
         * paging
         *----------------------------*/
        
        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {                        
            if (clientID == @"") ss.addDisplayColumn("[clientName]  as [Client\nName]",true);
            
            ss.addDisplayColumn("[reportingGroup] as [Reporting\nGroup]",true);

            ss.addDisplayColumn("[pracName]  as [Practitioner\nName]",true);
            ss.addDisplayColumn("[dispGroup]      as [Practice]");
            ss.addDisplayColumn("[practiceFamily] as [Practice\nFamily]");            
            ss.addDisplayColumn("[employmentRelationship] as [Employment\nRelationship]");            
            ss.addDisplayColumn("[departmentHeadStr] as [Dept\nHead]");
            ss.addDisplayColumn("[dateAddedStr] as [Date\nAdded]");
            ss.addDisplayColumn("[hasAssociatedUserAccountStr] as [Has\nSpEdCare\nAccount]");
            ss.addDisplayColumn("[lastLoggedOnToSpEdCareOnStr] as [Last\nSpEdCare\nLogin On]");
            ss.addDisplayColumn("[numPatsOnCaseload] as [Caseload\nSize]");
            ss.addDisplayColumn("[totalNumSvcs] as [Total\nNumber\nServices\nEntered\nThis\nPeriod]");
            ss.addDisplayColumn("[lastDateSvcsEnteredStr] as [Last\nDate\nServices\nEntered\nAny\nPeriod]");
                                                       
            /* Note: cx(_col_label) is in brackets.  This is to prevent sql from evaluating this as a udf */
            
            ss.addDisplayColumn("[c1(_col_label)]");
            ss.addDisplayColumn("c1");

            ss.addDisplayColumn("[c2(_col_label)]");
            ss.addDisplayColumn("c2");

            ss.addDisplayColumn("[c3(_col_label)]");
            ss.addDisplayColumn("c3");

            ss.addDisplayColumn("[c4(_col_label)]");
            ss.addDisplayColumn("c4");
            
            ss.addDisplayColumn("[c5(_col_label)]");
            ss.addDisplayColumn("c5");

            ss.addDisplayColumn("[c6(_col_label)]");
            ss.addDisplayColumn("c6");

            ss.addDisplayColumn("[c7(_col_label)]");
            ss.addDisplayColumn("c7");

            ss.addDisplayColumn("[c8(_col_label)]");
            ss.addDisplayColumn("c8");

            ss.addDisplayColumn("[c9(_col_label)]");
            ss.addDisplayColumn("c9");
                                                           
            ss.addDisplayColumn("[c10(_col_label)]");
            ss.addDisplayColumn("c10");
            
            ss.addDisplayColumn("[c11(_col_label)]");
            ss.addDisplayColumn("c11");

            ss.addDisplayColumn("[c12(_col_label)]");
            ss.addDisplayColumn("c12");

            ss.addDisplayColumn("[c13(_col_label)]");   
            ss.addDisplayColumn("c13");

            ss.addDisplayColumn("[comments] as [Remarks]");
            ss.addDisplayColumn("[clientBreaks]  as [District\nBreak Dates\nfor this\nPeriod]");

            pageroworder = ss.pageRowOrder();
        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/
        
         string tableName = SEL_LABEL_RPT_SUMMARY;
            
         if (clientID != "")
         {  
            Client c = Clients.load(connSpedmon, log, uInfo, vClientID.ToString());           
            tableName = SEL_LABEL_RPT_SUMMARY + " for " + c.name;
         }
         
         rdt = Entities.viewRpt (  connSpedmon
                                 , log
                                 , uInfo
                                 , paged
                                 , pageNumber
                                 , null
                                 , reportUDF
                                 , prms
                                 , null
                                 , dc
                                 , tableName
                                 , Messages.CONFIDENTIAL);
        
        rdt.columnTitlesReplaceSpacesWithBreaks = true;
        return rdt;
        
    }

    /***************************************************************************
     * viewRptPracEfficiency 
     *
     ***************************************************************************/
        
       public static ReturnDataTable viewRptPracEfficiency (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                  bool paged,
                                  string pageNumber,
                                  string canEdit,
                                  string clientID,
                                  string rptGroupID,
                                  string pracID,
                                  string endDate
        )
        {

            ReturnDataTable rdt;        
            rdt = PractitionersEfficiency.viewTbl (connSpedmon, log, uInfo, paged, pageNumber,canEdit,clientID,rptGroupID,pracID,endDate);
            return rdt;
        }
  }
}
