using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Collections.Specialized;
using System.Collections;
using MBA;
using Geo;
using Geo.CDE;

namespace Spedmon
{    
  
  /***************************************************************************
   * CdeComplianceBucketSummaryByService */
  /**
   * 
   ****************************************************************************/

  public class CdeComplianceBucketSummaryByService: CdeComplianceBucketByServiceBase
  {
    public int    totPats;
    public string siteIDStr;
  }
  
  /***************************************************************************
   * CdeComplianceBucketSummariesByService */
  /**
   * 
   ****************************************************************************/

  public class CdeComplianceBucketSummariesByService: Entities
  {
        
    /***************************************************************************
     * view */
    /**
     * View base method
     * 
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnDB view (  SqlConnection connSpedmon
                                 , DetailsLog    log
                                 , UserInfo      uInfo
                                 , int           recViewType
                                 , bool          pagedOrTop
                                 , string        idx
                                 , string        canEdit
                                 , string        active
                                 , string        clientID
                                 , string        siteID
                                 , defineCols    dc )
    {
      
      string viewUDF = "dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_SERVICE_SUMMARY (@userID,@userGroup,@userRank,@clientID, @siteID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      long  vClientID  = Validate.reqClientID (uInfo, clientID);
      var  vSiteID     = Validate.optInteger (siteID, "invalid siteID");

      var parms = new List<SqlParameter>();   

      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,    vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@siteID",    SqlDbType.BigInt,    vSiteID,      ParameterDirection.Input));

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
    public static List<CdeComplianceBucketSummaryByService> viewList (  SqlConnection connSpedmon
                                                                      , DetailsLog    log
                                                                      , UserInfo      uInfo
                                                                      , string        clientID
                                                                      , string        siteID )
    {

      var recs = new List<CdeComplianceBucketSummaryByService>();
      var rd = CdeComplianceBucketSummariesByService.view (connSpedmon,log,uInfo,Entities.REC_VIEW_RAW,false,"","","Y",clientID, siteID, null);
      var slo = Database.convertRecordsToList(ref rd.records, typeof(CdeComplianceBucketSummaryByService));
      foreach (var o in slo) {
         recs.Add ( (CdeComplianceBucketSummaryByService)o );
      }
      return recs;
    
    }

    /***************************************************************************
     * getCdeComplianceBucketsSummaryByService */
    /**
     * 
     ***************************************************************************/

     public static ReturnTotalNumAmts getCdeComplianceBucketsSummaryByService (  SqlConnection connSpedmon
                                                                               , DetailsLog    log
                                                                               , UserInfo      uInfo
                                                                               , string        clientID
                                                                               , string        siteID )             
     {
       ReturnTotalNumAmts so = new ReturnTotalNumAmts();
       var amts = new List<TotalNumAmt>();
       var svcs = CdeComplianceBucketSummariesByService.viewList(connSpedmon,log,uInfo,clientID, siteID);
       foreach(var svc in svcs)
       {
          TotalNumAmt tna = new TotalNumAmt();
          tna.label           = svc.spEdServiceCodeAndName;
          tna.totalNumVal     = (long) svc.pctExpectedApplicable;
          tna.totalNumStr     = svc.pctExpectedApplicable.ToString();
          tna.additionalData1 = svc.totPats.ToString();
          tna.additionalData2 = svc.totMinsExpected.ToString();
          tna.additionalData3 = svc.totMinsApplicable.ToString();
          tna.additionalData4 = svc.startDateStr + " - " + svc.endDateStr;
          tna.actionURL       = CdeComplianceBucketDetailsByService.generateActionURL(  svc.clientID.ToString()
                                                                                      , svc.siteIDStr
                                                                                      , ""
                                                                                      , svc.spEdServiceCode.ToString()
                                                                                      , ""
                                                                                      , "");
          amts.Add(tna);
       }

       so.totalNumAmts = amts.ToArray();
       return so;
      
     }
  
  }    
}
