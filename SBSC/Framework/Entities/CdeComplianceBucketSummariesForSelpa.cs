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
   * CdeComplianceBucketSummariesForSelpa` */
  /**
   * 
   ****************************************************************************/

  public class CdeComplianceBucketSummariesForSelpa: Entities
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
                                 , string        selpaCode
                                 , string        startDate
                                 , string        endDate
                                 , defineCols    dc )
    {
      
      string viewUDF = "dbo.RPT_CDE_COMPLIANCE_BUCKETS_SUMMARY_FOR_SELPA (@userID,@userGroup,@userRank,@selpaCode,@startDate,@endDate)";
      
      /*----------------------------
       * If no dates passed then 
       * calculate and use current
       * claiming window
       *----------------------------*/

      if (String.IsNullOrWhiteSpace(startDate) && String.IsNullOrWhiteSpace(endDate))
      {
          Util.parseDateRange(Util.GenerateDateRange(9), out startDate, out endDate);           
      }

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      Object   vSelpaCode    = Validate.reqSelpaCode  (uInfo,     selpaCode);
      DateTime vStartDate    = Validate.reqDate       (startDate, Messages.INVALID_START_DATE);
      DateTime vEndDate      = Validate.reqDate       (endDate,   Messages.INVALID_END_DATE);

      var parms = new List<SqlParameter>();   

      parms.Add(Database.SqlParm("@selpaCode",  SqlDbType.Int,       vSelpaCode,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate",  SqlDbType.DateTime,  vStartDate,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",    SqlDbType.DateTime,  vEndDate,     ParameterDirection.Input));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
    } 
        
    /***************************************************************************
     * load */
    /**
     * Loads single record
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing client specific data
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @return                 ReturnEntity
     ***************************************************************************/
    public static CdeComplianceBucketSummary load (  SqlConnection connSpedmon
                                                    , DetailsLog    log
                                                    , UserInfo      uInfo
                                                    , string        selpaCode
                                                    , string        startDate
                                                    , string        endDate )
    {            
      return (CdeComplianceBucketSummary) Entities.loadNRecord(connSpedmon, log, uInfo, 0, typeof(CdeComplianceBucketSummary),
      delegate { return CdeComplianceBucketSummariesForSelpa.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD_N, false, "", "", "", selpaCode, startDate,endDate, null); });
    }

    /***************************************************************************
     * get */
    /**
     * 
     **************************************************************************/
    public static ReturnEntity get (  SqlConnection connSpedmon
                                     , DetailsLog    log
                                     , UserInfo      uInfo
                                     , string        selpaCode)
    {
      var so = new ReturnEntity();
      so.entity = CdeComplianceBucketSummariesForSelpa.load(connSpedmon,log,uInfo,selpaCode,String.Empty,String.Empty);      
      return so;
    }          

    /***************************************************************************
     * getCdeComplianceBucketsSummary */
    /**
     * 
     ***************************************************************************/

     public static ReturnTotalNumAmts getCdeComplianceBucketsSummary (  SqlConnection connSpedmon
                                                                       , DetailsLog log
                                                                       , UserInfo uInfo
                                                                       , string selpaCode )             
     {
       ReturnTotalNumAmts so = new ReturnTotalNumAmts();
            
       var amts = new List<TotalNumAmt>();
       var cbs  = CdeComplianceBucketSummariesForSelpa.load(connSpedmon,log,uInfo,selpaCode,String.Empty,String.Empty);
       TotalNumAmt c = new TotalNumAmt();
       c.label = CdeComplianceCommon.LABEL_BUCKET_C_LINES(@" ");
       c.totalNumVal = cbs.patsInBucketC;
       c.totalNumStr = cbs.patsInBucketC.ToString();
       amts.Add(c);

       TotalNumAmt b = new TotalNumAmt();
       b.label = CdeComplianceCommon.LABEL_BUCKET_B_LINES(@" ");
       b.totalNumVal = cbs.patsInBucketB;
       b.totalNumStr = cbs.patsInBucketB.ToString();
       amts.Add(b);

       TotalNumAmt a = new TotalNumAmt();
       a.label = CdeComplianceCommon.LABEL_BUCKET_A_LINES(@" ");
       a.totalNumVal = cbs.patsInBucketA;
       a.totalNumStr = cbs.patsInBucketA.ToString();
       amts.Add(a);

       so.totalNumAmts = amts.ToArray();
       
       return so;
      
     }
   
   
  }    
}
