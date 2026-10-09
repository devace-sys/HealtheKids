using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
  /***************************************************************************
   * CYBHIProgramHealthStat */
  /**
   *
   ***************************************************************************/
  public class CYBHIProgramHealthStat
  {
    public long     clientID;
    public int      code;
    public string   label;
    public int      chartType;    
    public int      totNum;    
    public decimal  totAmt;
    public string   totAmtStr;
    public string   valuesJSON;    
  }

  /***************************************************************************
   * CYBHIProgramHealthStats */
  /**
   * Common methods
   ***************************************************************************/
    
  public class CYBHIProgramHealthStats
  {
    public static string URL_WEB_SERVICE  = "cybhi_program_health_stats.asmx";
    public static string URL_GET_STATS    = URL_WEB_SERVICE + "/getstats";
    public static string URL_MANAGE       = "user_all_cybhi_program_health_manage.aspx";
    public static string BODY_ID_MANAGE   = "user_all_cybhi_program_health";
    public static string MENU_ID_MANAGE   = "cybhiprogramhealthmanagelnk";
    public static string SEL_LABEL_MANAGE = "CYBHI Program Health";

	    
    /***************************************************************************
     * userHasAccess */
    /**
     * Access to menu option
     ***************************************************************************/

     public static bool userHasAccess (RequestResponse rd)
     {
       /* PCAL staff have access */
            
       if (rd.wu.usr.pcalStaff == true) return true;
                        
       /* LEA and CYBHI coordinators have access  */

       if (   (rd.wu.usr.roleID == Constants.ROLE_LEA_COORDINATOR_ID) 
           || (rd.wu.usr.roleID == Constants.ROLE_CYBHI_CORDINATOR_ID)) {
                               
         return true;
                            
       }

       /* Everyone else, no access */
            
       return false;
     }

    /***************************************************************************
     * URL_GET_STATS_BASE */
    /**
     * Returns base URL with token for retrieving stats data.  
     * Front end code will append client id parm to this
     ***************************************************************************/   

    public static string URL_GET_STATS_BASE()
    {
      return MBA.HttpApplication.createLink(URL_GET_STATS, true);
    }

	/***************************************************************************
     * URL_PAGE_MANAGE_BASE */
    /**
     * Returns base URL with token and app mode
     * Front end code will append client id parm to this
     ***************************************************************************/   

    public static string URL_PAGE_MANAGE_BASE ()
    { 
       return MBA.HttpApplication.createLink ( URL_MANAGE
                                               , true
                                               , new NameValue (Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)                                               
                                              );
    }

	/***************************************************************************
     * view */
    /**
     * View base method
     * 
     * @return            ReturnDB
     ***************************************************************************/   

    private static ReturnDB view (  SqlConnection connSpedmon
                                   , DetailsLog    log
                                   , UserInfo      uInfo
                                   , int           recViewType
                                   , bool          pagedOrTop
                                   , string        idx
                                   , string        canEdit
                                   , string        active
                                   , string        clientID                                 
                                   , defineCols    dc )
    {
      
      string viewUDF = "dbo.CYBHI_Program_Health_Stats_View (@userID, @userGroup, @userRank, @clientID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      long  vClientID  = Validate.reqClientID (uInfo, clientID,false,true); /* Note: Using applyConsortium lead exception */
     
      var parms = new List<SqlParameter>();   

      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,    vClientID,    ParameterDirection.Input));
     
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
    }
	
	/***************************************************************************
     * viewList */
    /**
     * 
     ***************************************************************************/   
	 
	public static List<CYBHIProgramHealthStat> viewList (  SqlConnection connSpedmon
                                                          , DetailsLog    log
                                                          , UserInfo      uInfo
                                                          , string        clientID )
    {

      var recs = new List<CYBHIProgramHealthStat>();
      var rd = CYBHIProgramHealthStats.view (connSpedmon,log,uInfo,Entities.REC_VIEW_RAW,false,"","","Y",clientID,null);
      var slo = Database.convertRecordsToList(ref rd.records, typeof(CYBHIProgramHealthStat));
      foreach (var o in slo) {
         recs.Add ((CYBHIProgramHealthStat) o );
      }
      return recs;    
    }
	
    /***************************************************************************
     * userCanDrillDown */
    /**
     * 
     ***************************************************************************/   
	
    public static bool userCanDrillDown (UserInfo uInfo, string clientID)
    {
       /* Revalidate */

       var clientIDVal = Validate.reqClientID (uInfo, clientID,false,true); /* Note: Using applyConsortium lead exception */
       
       /* Pcal can drill down */     

       if (uInfo.userGroup == Constants.USER_GROUP_SBSC) return true;
       
       /* Client can drill down to their own client or consortium client if applicable */
       
       if (uInfo.userGroup == Constants.USER_GROUP_CLIENT) {
            
            /* Not a consortium lead, client id should be their own client */
            
            if (uInfo.cybhiConsortiumIsLead == false) {
              return true;
            }
            
            /* Consortium lead, client id */

            if (uInfo.cybhiConsortiumIsLead == true) {

              /* If client id is the users client id then ok*/

              if (uInfo.userClientID == clientIDVal) return true;  

              /* Otherwise no */

              return false;  
            }
       }
       
       /* Everyone else no */
       
       return false; 
       
    }
    
	/***************************************************************************
     * getStats */
    /**
     * 
     ***************************************************************************/   

    public static ReturnTotalNumAmts getStats (  SqlConnection  connSpedmon
                                                , DetailsLog    log
                                                , UserInfo      uInfo
                                                , string        clientID )  
    {
       ReturnTotalNumAmts so = new ReturnTotalNumAmts();
       var amts              = new List<TotalNumAmt>();
       var stats             = CYBHIProgramHealthStats.viewList(connSpedmon, log, uInfo, clientID);       
       var userCanDrillDown  = CYBHIProgramHealthStats.userCanDrillDown(uInfo,clientID);
       
       foreach(var stat in stats)
       {
          TotalNumAmt tna = new TotalNumAmt();

          tna.label            = stat.label;
          tna.totalNumVal      = stat.totNum;
          tna.totalNumStr      = stat.totNum.ToString();          
          tna.totalAmtVal      = stat.totAmt;
          tna.totalAmtStr      = stat.totAmtStr;
          tna.chartType        = stat.chartType;
          tna.valuesJSON       = stat.valuesJSON;

          tna.additionalData1  = stat.code.ToString();
          tna.additionalData2  = stat.chartType.ToString();
          tna.additionalData3  = "";
          tna.additionalData4  = "";
          tna.actionURL        = "";
          

          var clientNVP                = new NameValue(Constants.PARM_CLIENT_ID, stat.clientID);
          var missingInsuranceInfoNVP  = new NameValue(Constants.PARM_MISSING_INSURANCE_INFO, 1);
          var missingAddressInfoNVP    = new NameValue(Constants.PARM_MISSING_ADDRESS_INFO, 1);
          var missingFerpaConsentNVP   = new NameValue(Constants.PARM_MISSING_FERPA_CONSENT, 1);
          var dataSourceNVP            = new NameValue(Constants.PARM_DATA_SOURCE, 1);
          var newWinNVP                = new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE);
          
          var tabToOpenMissingInfoPatReqFupNVP = new NameValue(Constants.PARM_TAB_TO_OPEN, "tab-missing-info-pats-require-followup");
          if (userCanDrillDown) {
                    
          switch (stat.code)
          { 
            case 2000:  
                tna.isReportDownload = false;
                tna.actionURL = MBA.HttpApplication.createLink( PatientsWithMissingInfo.URL_MANAGE
                                                               , true
                                                               , clientNVP
                                                               , dataSourceNVP
                                                               , missingInsuranceInfoNVP
                                                               , newWinNVP);
                break;
            
            case 2010: 
                tna.isReportDownload = false;
                tna.actionURL = MBA.HttpApplication.createLink( PatientsWithMissingInfo.URL_MANAGE
                                                               , true
                                                               , clientNVP
                                                               , dataSourceNVP
                                                               , missingAddressInfoNVP
                                                               , newWinNVP);
                break;
  
            case 2020:
                tna.isReportDownload = false;
                tna.actionURL = MBA.HttpApplication.createLink( PatientsWithMissingInfo.URL_MANAGE
                                                               , true
                                                               , clientNVP
                                                               , dataSourceNVP
                                                               , missingFerpaConsentNVP
                                                               , newWinNVP);
                break;          

            case 2030:
                tna.isReportDownload = false;
                tna.actionURL = MBA.HttpApplication.createLink( PatientsWithMissingInfo.URL_MANAGE
                                                               , true
                                                               , clientNVP
                                                               , dataSourceNVP
                                                               , tabToOpenMissingInfoPatReqFupNVP
                                                               , newWinNVP);            
                 break;

            case 2040:
                tna.isReportDownload = false;
                tna.actionURL = MBA.HttpApplication.createLink(PatientInfoRequestsPublicInsuranceFormResponses.URL_MANAGE, true, clientNVP);
                break;

            /*case 2050:
                tna.isReportDownload = false;
                tna.additionalData3 = "NO DETAIL";
                tna.additionalData4 = "NO VARIABLE NUMBER COLOR";
                break;

            case 2060:
                tna.isReportDownload = false;
                tna.additionalData3 = "NO DETAIL";
                tna.additionalData4 = "NO VARIABLE NUMBER COLOR";
                break;
            */
            case 5000:
                tna.isReportDownload = true;
                tna.actionURL        = MBA.HttpApplication.createLink ( Spedmon.Practitioners.URL_VIEW_REPORT
                                                                       , true
                                                                       , clientNVP);
                tna.rptNum  = Constants.RPT_CYBHI_PRACS_AUDIT.ToString();
                tna.rptFmt  = Constants.REPT_FORMAT_XLS.ToString();
                break;
          
            case 5010:
                tna.isReportDownload = true;
                tna.actionURL        = MBA.HttpApplication.createLink ( Spedmon.Patients.URL_WEB_REPORT
                                                                       , true
                                                                       , clientNVP);
                
                tna.rptNum  = Constants.RPT_CYBHI_PATS_AUDIT.ToString();
                tna.rptFmt  = Constants.REPT_FORMAT_XLS.ToString();
                break;
            
            case 6000:
                tna.isReportDownload = false;

                //tna.additionalData3 = "NO DETAIL";
                //tna.additionalData4 = "NO VARIABLE NUMBER COLOR";

                tna.actionURL = MBA.HttpApplication.createLink(
                       Spedmon.CYBHIProgramHealthDetailedServicesDocumented.URL_WEB_PAGE_BASE
                      , true
                      , newWinNVP
                      , clientNVP
                    );

                break;
            
            case 6010:
                tna.isReportDownload = false;
                tna.additionalData3 = "NO DETAIL";
                tna.additionalData4 = "NO VARIABLE NUMBER COLOR";
                break;

            case 6020:
                tna.isReportDownload = false;
                tna.additionalData3 = "NO DETAIL";
                tna.additionalData4 = "NO VARIABLE NUMBER COLOR";
                break;

            case 6030:
                tna.isReportDownload = false;
                tna.additionalData3 = "NO DETAIL";
                tna.additionalData4 = "NO VARIABLE NUMBER COLOR";
                break;

            case 6040:
                tna.isReportDownload = false;
                tna.additionalData3 = "NO DETAIL";
                tna.additionalData4 = "NO VARIABLE NUMBER COLOR";
                break;

           case 6050:
                tna.isReportDownload = false;
                tna.additionalData3 = "NO DETAIL";
                tna.additionalData4 = "NO VARIABLE NUMBER COLOR";
                break;
 
           case 7010:
                tna.isReportDownload = false;
                tna.additionalData3 = "NO DETAIL";
                tna.additionalData4 = "NO VARIABLE NUMBER COLOR";
                break;

            case 7020:
                tna.isReportDownload = false;
                tna.additionalData3 = "NO DETAIL";
                tna.additionalData4 = "NO VARIABLE NUMBER COLOR";
                break;

           case 9000:
                tna.isReportDownload = false; /* Will have a download later */
                tna.additionalData3 = "NO DETAIL";
                tna.additionalData4 = "NO VARIABLE NUMBER COLOR";
                break;

            case 9010:
            case 9020:
            case 9030:
                tna.isReportDownload = false;

                //tna.additionalData3 = "NO DETAIL";
                //tna.additionalData4 = "NO VARIABLE NUMBER COLOR";

                tna.actionURL = MBA.HttpApplication.createLink(
                       Spedmon.CYBHIProgramHealthDetailedServicesDocumented.URL_WEB_PAGE_BASE
                      , true
                      , newWinNVP
                      , clientNVP //  NOTE: I'm implemented the groupID append at the JS level.
                                //  easier to extract it from the JSON payload, at the JS level.
                    );

                break;


           default:
                break;
           }          
          
           } /* User can drill down*/

          amts.Add(tna);
       }
       so.totalNumAmts = amts.ToArray();
       return so;
    }
  
  }
}

