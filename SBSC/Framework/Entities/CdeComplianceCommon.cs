using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;


namespace Spedmon
{
  
  /***************************************************************************
   * CdeComplianceOverallValue */
  /**
   *
   ****************************************************************************/
  public class CdeComplianceOverallValue
  {
    public int    numPlans                             = 0;
    public double planFulfillment                      = 0;
    public double pctCompliant                         = 0;    
    public int    numOfSvcsOverDelivered               = 0;
    public int    numOfUnreviewedSvcDeliveryExpections = 0;
  }

  /***************************************************************************
   * CdeComplianceMetric */
  /**
   *
   ****************************************************************************/

  public class CdeComplianceMetric
  {
    public string   spEdServiceCodeAndName;
    public int      totMinsExpected;
    public int      totMinsApplicable;
    public int      totMinsDiff;
    public Single   pctExpectedApplicable;
    public string   pctExpectedApplicableStr;
  }

  /***************************************************************************
   * CdeComplianceBucketByServiceBase */
  /**
   *
   ****************************************************************************/
  public class CdeComplianceBucketByServiceBase : CdeComplianceMetric
  {
    public long     clientID;
    public int      spEdServiceCode;
    public string   spEdServiceName;
    public DateTime startDate;
    public DateTime endDate;
    public string   startDateStr;
    public string   endDateStr;
    public Decimal  potLostReimbursement;
    public string   potLostReimbursementStr;  
   }

  /***************************************************************************
   * CdeComplianceBucketSummary */
  /**
   *
   ****************************************************************************/

  public class CdeComplianceBucketSummary : Entity
  {
    public string   startDateStr;
    public string   endDateStr;
    public string   startDateStrYMD;
    public string   endDateStrYMD;
    public long     patsInBucketC;
	public long     patsInBucketB;
	public long     patsInBucketA;
    public long     totalPats;
  }

  /***************************************************************************
   * CdeComplianceCommon */
  /**
   *
   ****************************************************************************/

  public class CdeComplianceCommon
  {
    public const string LABEL_SUCCESS_BUCKETS = @"IDEA Plan Implementation Success";

    public const string LABEL_BUCKET_A_LINE_1 = @"Category A";
    public const string LABEL_BUCKET_B_LINE_1 = @"Category B";
    public const string LABEL_BUCKET_C_LINE_1 = @"Category C";

    public const string LABEL_BUCKET_A_LINE_2 = @"(95% to 100%)";
    public const string LABEL_BUCKET_B_LINE_2 = @"(90% to 94.9%)";
    public const string LABEL_BUCKET_C_LINE_2 = @"(Less Than 90%)";

    public const string LABEL_BUCKET_TOTAL_STUDENTS_LINE_1 = @"Total";
    public const string LABEL_BUCKET_TOTAL_STUDENTS_LINE_2 = @"Students";

    public const string SEL_LABEL_MANAGE                         = "IDEA Compliance";

    public const string SEL_LABEL_MANGE_FOR_CLIENT               = "CDE Compliance for Client";
    public const string SEL_LABEL_MANGE_FOR_SELPA                = "CDE Compliance for SELPA";

    public const string SEL_LABEL_MANGE_FOR_CLIENT_CURRENT_AUDIT = "CDE Compliance for Current Audit Period";


    public const string SEL_LABEL_CURRENT_AUDIT_SHORT            = @"CDE Audit of SWD Plan Implementation";

    public const string SEL_LABEL_CURRENT_AUDIT                  =  @"CDE Audit of SWD Plan Implementation (Reported to CDE)";
    public const string SEL_LABEL_CURRENT_AUDIT_ROW              =  @"Last CDE Audit Reporting Results";

    public const string SEL_LABEL_ANNUAL                         =  @"Annual IDEA Compliance (Related Services)"; 
  
    public const string SEL_LABEL_ANNUAL_ROW                    =  @"Current IDEA Related Service Implementation";


    public const string MENU_ID_MANAGE                           = @"cdecompliancemanagelnk";
    public const string MENU_ID_FOR_SELPA_MANAGE                 = @"cdecompliancemanageforselpalnk";
    public const string MENU_ID_FOR_CLIENT_MANAGE_CURRENT_AUDIT  = @"cdecompliancemanageforcurraudperlnk";

    public const string BODY_ID_MANAGE               = @"cdecompliancemanage";
    public const string BODY_ID_FOR_SELPA_MANAGE     = @"cdecomplianceforselpamanage";
    public const string BODY_ID_MANAGE_CURRENT_AUDIT = @"cdecompliancemanageforcurraud";

    public const string URL_MANAGE                   = @"user_all_cde_compliance_manage.aspx";
    public const string URL_FOR_SELPA_MANAGE         = @"user_all_cde_compliance_manage_for_selpa.aspx";
    public const string URL_MANAGE_CURRENT_AUDIT     = @"user_all_cde_compliance_current_audit_manage.aspx";
    public const string URL_PDF_CDE_REQUIRMENTS      = @"pdf/CALPADS_Special_Education_Data_Spring_Roadshow_2024.pdf";

    public const string URL_MANAGE_CURRENT_AUDIT_DETAILS_BY_PATIENT = @"user_all_cde_compliance_current_audit_details_by_patient_manage.aspx";

    public static string URL_WEB_SVC_BASE                                      = @"cde_compliance.asmx";
    public static string URL_WEB_REPORT_BASE                                   = @"cde_compliance.ashx";

    public static string URL_WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY            = URL_WEB_SVC_BASE + @"/getcdecompliancebucketssummary";
    public static string URL_WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_FOR_SELPA  = URL_WEB_SVC_BASE + @"/getcdecompliancebucketssummaryforselpa";
    public static string URL_WEB_SVC_CDE_COMPLIANCE_GET_OVERALL_SUMMARY        = URL_WEB_SVC_BASE + @"/getoverallsummary";

    public static string URL_WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_BY_SVC         = URL_WEB_SVC_BASE + @"/getcdecompliancebucketssummarybyservice";
    public static string URL_WEB_SVC_CDE_COMPLIANCE_OVERALL_SUMMARY_FOR_A_PRAC     = URL_WEB_SVC_BASE + @"/getcdecomplianceoverallsummaryforapractitioner";
    public static string URL_WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_BY_PCAL_RATING = URL_WEB_SVC_BASE + @"/getcdecompliancebucketssummarybypcalcompliancerating";

    public static string URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_SAVE_BASE    = URL_WEB_SVC_BASE + @"/savecurrentauditperiod";
    public static string URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_GET_BASE     = URL_WEB_SVC_BASE + @"/getcurrentauditperiod";
    public static string URL_WEB_SVC_CDE_CURR_AUDIT_PATIENT_SAVE_BASE   = URL_WEB_SVC_BASE + @"/savecurrentauditperiodpatient";
    public static string URL_WEB_SVC_CDE_CURR_AUDIT_PATIENT_DELETE_BASE = URL_WEB_SVC_BASE + @"/deletecurrentauditperiodpatientinline";

    public static string URL_WEB_SVC_CDE_CURR_YEAR_GET_BASE             = URL_WEB_SVC_BASE + @"/getcurrentyear";
    public static string URL_WEB_SVC_CDE_CURR_YEAR_FOR_SELPA_GET_BASE   = URL_WEB_SVC_BASE + @"/getcurrentyearforselpa";

    public static string URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_GET_FOR_SELPA_BASE        = URL_WEB_SVC_BASE + @"/getcurrentauditperiodforselpa";
    public static string URL_WEB_SVC_CDE_CURR_AUDIT_REPROCESS_IMPORTED_PATIENT_DATA  = URL_WEB_SVC_BASE + @"/reprocessimportedpatientdataforcurrentaudit";

    public static string URL_WEB_SVC_CDE_CURR_AUDIT_SAVE_OR_REPLACE_USR_PROV_DEL_COMP_STATS_BASE = URL_WEB_SVC_BASE + @"/saveorreplaceuserprovideddeliverycompliancestats";


    /***************************************************************************
     * LABEL_BUCKET_A_LINES */
    /**
     *
     **************************************************************************/
    public static string LABEL_BUCKET_A_LINES (string seperator = @" ")
    {
      return LABEL_BUCKET_A_LINE_1  + seperator + LABEL_BUCKET_A_LINE_2;
    }

    /***************************************************************************
     * LABEL_BUCKET_B_LINES */
    /**
     *
     **************************************************************************/

    public static string LABEL_BUCKET_B_LINES (string seperator = @" ")
    {
      return LABEL_BUCKET_B_LINE_1  + seperator + LABEL_BUCKET_B_LINE_2;
    }

    /***************************************************************************
     * LABEL_BUCKET_C_LINES */
    /**
     *
     **************************************************************************/
    public static string LABEL_BUCKET_C_LINES (string seperator = @" ")
    {
      return LABEL_BUCKET_C_LINE_1 + seperator + LABEL_BUCKET_C_LINE_2;
    }

    /***************************************************************************
     * LABEL_BUCKET_TOTAL_STUDENTS_LINES */
    /**
     *
     **************************************************************************/
    public static string LABEL_BUCKET_TOTAL_STUDENTS_LINES (string seperator = @" ")
    {
      return LABEL_BUCKET_TOTAL_STUDENTS_LINE_1 + seperator + LABEL_BUCKET_TOTAL_STUDENTS_LINE_2;
    }

    /***************************************************************************
     * URL_WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY */
    /**
     *
     **************************************************************************/

    public static string WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY()
    {
      return MBA.HttpApplication.createLink(URL_WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY,true);
    }
    /***************************************************************************
     * URL_WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_FOR_SELPA */
    /**
     *
     **************************************************************************/
    public static string WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_FOR_SELPA()
    {
      return MBA.HttpApplication.createLink(URL_WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_FOR_SELPA,true);
    }

    /***************************************************************************
     * URL_WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_BY_SVC */
    /**
     *
     **************************************************************************/
    public static string WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_BY_SVC()
    {
      return MBA.HttpApplication.createLink(URL_WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_BY_SVC,true);
    }

    /***************************************************************************
     * WEB_SVC_CDE_COMPLIANCE_GET_OVERALL_SUMMARY */
    /**
     *
     **************************************************************************/
    public static string WEB_SVC_CDE_COMPLIANCE_GET_OVERALL_SUMMARY()
    {
      return MBA.HttpApplication.createLink(URL_WEB_SVC_CDE_COMPLIANCE_GET_OVERALL_SUMMARY,true);
    }
        
    /***************************************************************************
     * URL_WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_BY_PCAL_RATING_BASE */
    /**
     *
     **************************************************************************/
    public static string URL_WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_BY_PCAL_RATING_BASE()
    {
      return MBA.HttpApplication.createLink(URL_WEB_SVC_CDE_COMPLIANCE_BUCKETS_SUMMARY_BY_PCAL_RATING,true);
    }
        
    /***************************************************************************
     * WEB_SVC_CDE_COMPLIANCE_OVERALL_SUMMARY_FOR_A_PRAC */
    /**
     *
     **************************************************************************/
    public static string WEB_SVC_CDE_COMPLIANCE_OVERALL_SUMMARY_FOR_A_PRAC ()
    {
      return MBA.HttpApplication.createLink(  URL_WEB_SVC_CDE_COMPLIANCE_OVERALL_SUMMARY_FOR_A_PRAC
                                            , true );
    }

    public static string WEB_SVC_CDE_COMPLIANCE_OVERALL_SUMMARY_FOR_A_PRAC (string clientID, string pracID)
    {
      return MBA.HttpApplication.createLink(  URL_WEB_SVC_CDE_COMPLIANCE_OVERALL_SUMMARY_FOR_A_PRAC
                                            , true
                                            , new NameValue(Constants.PARM_CLIENT_ID,clientID)
                                            , new NameValue(Constants.PARM_PRACTITIONER_ID,pracID));
    }

    /***************************************************************************
     * URL_WEB_REPORT */
    /**
     *
     **************************************************************************/
     public static string URL_WEB_REPORT()
     {
        return MBA.HttpApplication.createLink(CdeComplianceCommon.URL_WEB_REPORT_BASE, true);
     }

    /***************************************************************************
     * URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_SAVE */
    /**
     *
     **************************************************************************/
    public static string URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_SAVE()
    {
        return MBA.HttpApplication.createLink(CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_SAVE_BASE, true);
    }

    /***************************************************************************
     * URL_WEB_SVC_CDE_CURR_AUDIT_PATIENT_SAVE */
    /**
     *
     **************************************************************************/
    public static string URL_WEB_SVC_CDE_CURR_AUDIT_PATIENT_SAVE()
    {
        return MBA.HttpApplication.createLink(CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_PATIENT_SAVE_BASE, true);
    }

    /***************************************************************************
     * URL_WEB_SVC_CDE_CURR_AUDIT_PATIENT_DELETE */
    /**
     *
     **************************************************************************/
    public static string URL_WEB_SVC_CDE_CURR_AUDIT_PATIENT_DELETE()
    {
        return MBA.HttpApplication.createLink(CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_PATIENT_DELETE_BASE, true);
    }

    /***************************************************************************
     * URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_GET */
    /**
     *
     **************************************************************************/
    public static string URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_GET()
    {
      return MBA.HttpApplication.createLink(CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_GET_BASE, true);
    }

    /***************************************************************************
     * URL_MANAGE_CURRENT_AUDIT_BASE */
    /**
     *
     **************************************************************************/
    public static string URL_MANAGE_CURRENT_AUDIT_BASE()
    {
       return MBA.HttpApplication.createLink(CdeComplianceCommon.URL_MANAGE_CURRENT_AUDIT, true);
    }

    /***************************************************************************
     * URL_WEB_SVC_CDE_CURR_YEAR_GET */
    /**
     *
     **************************************************************************/
    public static string URL_WEB_SVC_CDE_CURR_YEAR_GET()
    {
      return MBA.HttpApplication.createLink(CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_YEAR_GET_BASE, true);
    }


    /***************************************************************************
     * URL_WEB_SVC_CDE_CURR_YEAR_FOR_SELPA_GET */
    /**
     *
     **************************************************************************/
    public static string URL_WEB_SVC_CDE_CURR_YEAR_FOR_SELPA_GET()
    {
      return MBA.HttpApplication.createLink(CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_YEAR_FOR_SELPA_GET_BASE, true);
    }

    /***************************************************************************
     * URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_GET_FOR_SELPA */
    /**
     *
     **************************************************************************/
    public static string URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_GET_FOR_SELPA()
    {
      return MBA.HttpApplication.createLink(CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_PERIOD_GET_FOR_SELPA_BASE, true);
    }

    /***************************************************************************
     * URL_WEB_SVC_CDE_CURR_AUDIT_SAVE_OR_REPLACE_USR_PROV_DEL_COMP_STATS */
    /**
     *
     **************************************************************************/
    public static string URL_WEB_SVC_CDE_CURR_AUDIT_SAVE_OR_REPLACE_USR_PROV_DEL_COMP_STATS()
    {
      return MBA.HttpApplication.createLink(CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_SAVE_OR_REPLACE_USR_PROV_DEL_COMP_STATS_BASE, true);
    }

    /***************************************************************************
     * URL_MANAGE_CURRENT_AUDIT_DETAILS_BY_PATIENT_BASE */
    /**
     *
     **************************************************************************/
    public static string URL_MANAGE_CURRENT_AUDIT_DETAILS_BY_PATIENT_BASE()
    {
        return MBA.HttpApplication.createLink(CdeComplianceCommon.URL_MANAGE_CURRENT_AUDIT_DETAILS_BY_PATIENT
            , true
            , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));
    }

    /***************************************************************************
     * URL_MANAGE_BASE */
    /**
     *
     **************************************************************************/

    public static string URL_MANAGE_BASE()
    {
       return MBA.HttpApplication.createLink(CdeComplianceCommon.URL_MANAGE, true);
    }

    /***************************************************************************
     * URL_WEB_SVC_CDE_CURR_AUDIT_REPROCESS_IMPORTED_PATIENT_DATA_BASE */
    /**
     *
     **************************************************************************/

    public static string URL_WEB_SVC_CDE_CURR_AUDIT_REPROCESS_IMPORTED_PATIENT_DATA_BASE()
    {
       return MBA.HttpApplication.createLink(CdeComplianceCommon.URL_WEB_SVC_CDE_CURR_AUDIT_REPROCESS_IMPORTED_PATIENT_DATA, true);
    }

    /***************************************************************************
     * getCurrentWindowStartDateStr */
    /**
     *
     **************************************************************************/

     public static string getCurrentWindowStartDateStr (SqlConnection connUsers, DetailsLog log, UserInfo uInfo)
     {
       string currentWindowStartDateStr = null;
       MBA.AppSettings.getAppSetting ( connUsers, log, uInfo,"spedcare","cde","compliance","dates","global","current-window-start-date",out currentWindowStartDateStr);
       return currentWindowStartDateStr;
     }

     /***************************************************************************
      * getCurrentWindowEndDateStr */
     /**
      *
      **************************************************************************/
     public static string getCurrentWindowEndDateStr (SqlConnection connUsers, DetailsLog log, UserInfo uInfo)
     {
       string currentWindowEndDateStr = null;
       MBA.AppSettings.getAppSetting ( connUsers, log, uInfo,"spedcare","cde","compliance","dates","global","current-window-end-date",out currentWindowEndDateStr);
       return currentWindowEndDateStr;
     }

    /***************************************************************************
     * getCurrentAuditPatientGroupStartDateStr */
    /**
     *
     **************************************************************************/

     public static string getCurrentAuditPatientGroupStartDateStr (SqlConnection connUsers, DetailsLog log, UserInfo uInfo)
     {
       string currentWindowStartDateStr = null;
       MBA.AppSettings.getAppSetting ( connUsers, log, uInfo,"spedcare","cde","compliance","dates","global","current-audit-patient-group-start-date",out currentWindowStartDateStr);
       return currentWindowStartDateStr;
     }

     /***************************************************************************
      * getCurrentAuditPatientGroupEndDateStr */
     /**
      *
      **************************************************************************/
     public static string getCurrentAuditPatientGroupEndDateStr (SqlConnection connUsers, DetailsLog log, UserInfo uInfo)
     {
       string currentWindowEndDateStr = null;
       MBA.AppSettings.getAppSetting ( connUsers, log, uInfo,"spedcare","cde","compliance","dates","global","current-audit-patient-group-end-date",out currentWindowEndDateStr);
       return currentWindowEndDateStr;
     }


   /***************************************************************************
    * defineColsRptPerformanceByServiceSummary */

   /**
    * 
    * called from rptPerformanceByServiceSummary()
    * and  rptAnnualPerformanceByServiceSummary()
    **************************************************************************/

    public static defineCols defineColsRptPerformanceByServiceSummary(bool reportHasAbsenseCols) {

      return delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
         ss.addDisplayColumn("clientName as [District]",                true);
         ss.addDisplayColumn("spEdServiceCodeAndName as [Service]",     true);
         ss.addDisplayColumn("startDate as [From\nDate\nof\nService]");
         ss.addDisplayColumn("endDate as [To\nDate\nof\nService]");
         ss.addDisplayColumn("totPlans as [Number\nof\nPlans]");
         ss.addDisplayColumn("totMinsExpected as [Minutes\nExpected]");
         ss.addDisplayColumn("totMinsSatisfied as [Minutes\nSatisfied\n(Capped at\nExpected)]");
         ss.addDisplayColumn("pctExpectedSatisfiedStr as [Percent\nSatisfied\n(Capped at\n100)]");

         if (reportHasAbsenseCols == true) {
           ss.addDisplayColumn("totSvcRecs  as [Sessions\nDocumented]");

           ss.addDisplayColumn("pctAbsencePatStr   as [Percent\nSessions\nDocumented\nStudent\nAbsent]");
           ss.addDisplayColumn("pctAbsencePracStr  as [Percent\nSessions\nDocumented\nPractitioner\nAbsent]");
           ss.addDisplayColumn("pctAbsenceStr      as [Percent\nSessions\nDocumented\nAbsent]");

           ss.addDisplayColumn("totPatAbsent    as [Sessions\nDocumented\nStudents\nAbsent]");
           ss.addDisplayColumn("totPracAbsent   as [Sessions\nDocumented\nPractitioners\nAbsent]");
           ss.addDisplayColumn("totAbsent       as [Sessions\nDocumented\nAbsent]");
         }

         pageroworder = ss.pageRowOrder();
      };

   }

        /***************************************************************************
         * defineColsRptPerformanceBySiteServiceSummary */

        /**
         * called from rptCDEAuditPerformanceBySiteServiceSummary()
         * and rptAnnualPerformanceBySiteServiceSummary()
         **************************************************************************/

        public static defineCols defineColsRptPerformanceBySiteServiceSummary(bool reportHasAbsenseCols)
        {

            return delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("clientName as [District]", true);
                ss.addDisplayColumn("siteName as [Site]", true);
                ss.addDisplayColumn("spEdServiceCodeAndName as [Service]", true);
                ss.addDisplayColumn("startDate as [From\nDate\nof\nService]");
                ss.addDisplayColumn("endDate as [To\nDate\nof\nService]");
                ss.addDisplayColumn("totPlans as [Number\nof\nPlans]");
                ss.addDisplayColumn("totMinsExpected as [Minutes\nExpected]");
                ss.addDisplayColumn("totMinsSatisfied as [Minutes\nSatisfied\n(Capped at\nExpected)]");
                ss.addDisplayColumn("pctExpectedSatisfiedStr as [Percent\nSatisfied\n(Capped at\n100)]");

                if (reportHasAbsenseCols == true) {
                   ss.addDisplayColumn("totSvcRecs         as [Sessions\nDocumented]");
                   ss.addDisplayColumn("pctAbsencePatStr   as [Percent\nSessions\nDocumented\nStudent\nAbsent]");
                   ss.addDisplayColumn("pctAbsencePracStr  as [Percent\nSessions\nDocumented\nPractitioner\nAbsent]");
                   ss.addDisplayColumn("pctAbsenceStr      as [Percent\nSessions\nDocumented\nAbsent]");
                   ss.addDisplayColumn("totPatAbsent    as [Sessions\nDocumented\nStudents\nAbsent]");
                   ss.addDisplayColumn("totPracAbsent   as [Sessions\nDocumented\nPractitioners\nAbsent]");
                   ss.addDisplayColumn("totAbsent       as [Sessions\nDocumented\nAbsent]");
                }

                pageroworder = ss.pageRowOrder();
            };
        }
   }
}