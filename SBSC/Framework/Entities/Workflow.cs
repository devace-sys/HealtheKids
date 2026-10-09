using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
      
  /***************************************************************************
   * Workflow */
  /**
   * 
   ***************************************************************************/

  public class Workflow:Entities
	{
    
    public const string RPT_NAME_RECENT_ANI = "Recent A&I Batches Uploaded";
    
    /***************************************************************************
     * viewRecentANIFiles */
    /**
     * View recent A&I uploads
     * 
     * @param  clientID        Client ID
     * @param  pracID          Practitioner ID
     * @param  patID           Patient ID
     * @param  dateRange       Date range
     * @return                 Claim records
     ***************************************************************************/   

    public static ReturnDataTable viewRecentANIFiles (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                 bool   paged,
                                                 string pageNumber)
    {   
    

       ReturnDataTable so = new ReturnDataTable();
       
       string viewUDF = "dbo.INPUT_BATCHES_FILE_LIST_LAST_14(null,null,null)";
       string active  = "";
       
       List<SqlParameter> prms = new List<SqlParameter>();

        /*----------------------------
         * Define our columns and
         * set the page order for 
         * paging
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            
            ss.addDisplayColumn("FileName");
            ss.addPageOrderColumn("FileName desc");
            pageroworder = ss.pageRowOrder();
        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        so = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, active, viewUDF, prms, null, dc);
        so.tableName   = RPT_NAME_RECENT_ANI;
        so.tableFooter = Messages.CONFIDENTIAL;
        return so;

     } 
  }
}