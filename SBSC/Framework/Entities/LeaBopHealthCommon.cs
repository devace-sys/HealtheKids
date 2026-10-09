using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{    
 
  public class LeaBopHealthCommon 
  {

    public const string SEL_LABEL_MANAGE   = "LEA Billing Options Program Health";
    public const string MENU_ID_MANAGE     = @"leabopprghealthmanagelnk";
    public const string BODY_ID_MANAGE     = @"leabopprghealthmanage";
    public const string URL_MANAGE         = @"user_all_lea_bop_health_manage.aspx";
    
    public static string URL_WEB_SVC_BASE                                  = @"lea_bop_health.asmx";
    public static string URL_WEB_SVC_AMTS_BY_DOS_FOR_THIS_YEAR_BASE        = URL_WEB_SVC_BASE + @"/getreimbursementamtbydosforthisyear";
    public static string URL_WEB_SVC_AMTS_BY_DOW_FOR_THIS_YEAR_BASE        = URL_WEB_SVC_BASE + @"/getreimbursementamtbydowforthisyear";
    public static string URL_WEB_SVC_POT_LOST_AMTS_FOR_SERVICE_AUTH_BASE   = URL_WEB_SVC_BASE + @"/getpotlostreimbursementserviceauth";
    public static string URL_WEB_SVC_POT_LOST_AMTS_FOR_RMTS_PART_BASE      = URL_WEB_SVC_BASE + @"/getpotlostreimbursementrmtspart";
    public static string URL_WEB_SVC_POT_LOST_AMTS_FOR_PRAC_SUP_BASE       = URL_WEB_SVC_BASE + @"/getpotlostreimbursementpracsup";
    public static string URL_WEB_SVC_POT_LOST_AMTS_FOR_PARENT_CONSENT_BASE = URL_WEB_SVC_BASE + @"/getpotlostreimbursementparentconsent";
    public static string URL_WEB_SVC_POT_LOST_AMTS_FOR_MISSING_TMTS_BASE   = URL_WEB_SVC_BASE + @"/getpotlostreimbursementmissingtmts";
    public static string URL_WEB_SVC_POT_LOST_AMTS_FOR_MISSING_ASMTS_BASE  = URL_WEB_SVC_BASE + @"/getpotlostreimbursementmissingasmts";
    public static string URL_WEB_SVC_POT_LOST_REIMBURSEMENT_AMTS_BASE      = URL_WEB_SVC_BASE + @"/getpotlostreimbursementamts";    
    public static string URL_WEB_SVC_CLAIMS_PAID_2P_BASE                   = URL_WEB_SVC_BASE + @"/getclaimspaid2p";

    public static string URL_WEB_SVC_AMTS_BY_DOS_FOR_THIS_YEAR()
    {
      return MBA.HttpApplication.createLink(  URL_WEB_SVC_AMTS_BY_DOS_FOR_THIS_YEAR_BASE
                                            , true);
    }
    public static string URL_WEB_SVC_AMTS_BY_DOW_FOR_THIS_YEAR()
    {
      return MBA.HttpApplication.createLink(  URL_WEB_SVC_AMTS_BY_DOW_FOR_THIS_YEAR_BASE
                                            , true);
    }

    public static string URL_WEB_SVC_POT_LOST_AMTS_FOR_SERVICE_AUTH()
    {
      return MBA.HttpApplication.createLink(  URL_WEB_SVC_POT_LOST_AMTS_FOR_SERVICE_AUTH_BASE
                                            , true);
    }

    public static string URL_WEB_SVC_POT_LOST_AMTS_FOR_RMTS_PART()
    {
      return MBA.HttpApplication.createLink(  URL_WEB_SVC_POT_LOST_AMTS_FOR_RMTS_PART_BASE
                                            , true);
    }

    public static string URL_WEB_SVC_POT_LOST_AMTS_FOR_PRAC_SUP()
    {
      return MBA.HttpApplication.createLink(  URL_WEB_SVC_POT_LOST_AMTS_FOR_PRAC_SUP_BASE
                                            , true);
    }
    public static string URL_WEB_SVC_POT_LOST_AMTS_FOR_MISSING_TMTS()
    {
      return MBA.HttpApplication.createLink(URL_WEB_SVC_POT_LOST_AMTS_FOR_MISSING_TMTS_BASE
                                            , true);
    }
 
    public static string WEB_SVC_POT_LOST_AMTS_FOR_MISSING_ASMTS()
    {
      return MBA.HttpApplication.createLink(  URL_WEB_SVC_POT_LOST_AMTS_FOR_MISSING_ASMTS_BASE
                                             , true);
    }

    public static string WEB_SVC_POT_LOST_AMTS_FOR_PARENT_CONSENT()
    {
      return MBA.HttpApplication.createLink(  URL_WEB_SVC_POT_LOST_AMTS_FOR_PARENT_CONSENT_BASE
                                             , true);
    }

    public static string WEB_SVC_POT_LOST_REIMBURSEMENT_AMTS()
    {
      return MBA.HttpApplication.createLink(  URL_WEB_SVC_POT_LOST_REIMBURSEMENT_AMTS_BASE
                                             , true);
    }

    public static string WEB_SVC_CLAIMS_PAID_2P()
    {
      return MBA.HttpApplication.createLink(URL_WEB_SVC_CLAIMS_PAID_2P_BASE
                                             , true);
    }
   
  }
}