using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace MBA
{   

  /***************************************************************************
   * FileExportDistribution */
  /**
   * 
   **************************************************************************/
  public class FileExportDistribution
  {                   
    public string                      distributionSourceName;
    public string                      PublicationName;
    public int                         DataSource;        
    public string                      Schedule;                                 /* Cron tab */   
    public short                       fileTypeRequested;
    public long?                       clientID;          //must be nullable
    public string                      destinationFolder;
  }

  
  /***************************************************************************
   * FileExportDistributions */
  /**
   * 
   **************************************************************************/

  public class FileExportDistributions:Entities
  { 
               
    /***************************************************************************
     * view */
    /**
     * View distributions
     * 
     **************************************************************************/  
    
    public static ReturnDB view (  SqlConnection connUsers
                                  , DetailsLog   log
                                  , UserInfo     uInfo
                                  , int          recViewType
                                  , bool         pagedOrTop
                                  , string       idx
                                  , string       canEdit
                                  , string       active
                                  , string       appName
                                  , string       clientID                                 
                                  , defineCols   dc )
    {
    
      /*----------------------------
       * Udf
       *----------------------------*/

       string viewUDF = "dbo.FILE_EXPORT_DISTRIBUTIONS_VIEW (null,null,null,@appName,@clientID)";    

      /*----------------------------
       * Validate
       *----------------------------*/

      string vAppName = Validate.reqString (appName,Messages.INVALID_APP_NAME); 
      Object vClientID = Validate.optInteger(clientID, Messages.INVALID_CLIENT_ID);

      /*----------------------------
       * Setup db parms
       *----------------------------*/
     
      var parms = new List<SqlParameter>();              

      parms.Add(Database.SqlParm("@appName",  SqlDbType.VarChar, vAppName, ParameterDirection.Input,50));
      parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt,  vClientID, ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connUsers, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }
 
  }
}
