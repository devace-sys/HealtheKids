using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Collections.ObjectModel;
using System.Web.UI.WebControls;
using System.Collections;
using System.Collections.Specialized;
using System.Web.Script.Serialization;
using System.Text;

using MBA;

namespace Spedmon
{     
     
  /***************************************************************************
   * ServiceRecordNoteUnformatted */
  /**
   * Unformatted note
   ***************************************************************************/
  
  public class ServiceRecordNoteSvcRec
  {
    public long   id;
	  public long   clientID;
	  public long   pracID;
	  public long   patID;
	  public string clientName;
	  public string pracName;
	  public string patName;
	  public string svcName;
	  public int    numMins;	
	  public string reviewStatus;
	  public string reviewNotes;
	  public string currReviewStatus;
	  public string currReviewNotes;
	  public string prevReviewStatus;
	  public string prevReviewNotes;
	  public long   journalID;	  
  }
  
  /***************************************************************************
   * ServiceRecordsNotesSvcRec */
  /**
   * General methods to retrieve individual service record data
   ***************************************************************************/

  public class ServiceRecordsNotesSvcRec
  {
    
    /***************************************************************************
     * view */
    /**
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  uInfo           User info object
     * @param  clientId        Client ID
     * @param  recID           Service record ID
     * @return                 ReturnDB
     ***************************************************************************/
      
    public static ReturnDB view (    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo 
      , string        clientID     
      , string        recID )
    {         

      ReturnDB rd = new ReturnDB();
     
      /*-------------------------------
       * Validate Parameters passed in
       *------------------------------*/ 

      Object vClientID = Validate.optClientID(uInfo, clientID);
      long   vRecID    = Validate.reqInteger (recID, Messages.INVALID_RECORD_ID);
      
      /*-------------------------------
       * Populate Parms for Query
       *------------------------------*/ 

      List<SqlParameter> parms = new List<SqlParameter>();    
      
      parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt,  uInfo.userid,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",  SqlDbType.Int,     uInfo.userGroup,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",   SqlDbType.Int,     uInfo.userRank,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@clientID",   SqlDbType.BigInt,  vClientID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recID",      SqlDbType.BigInt,  vRecID,           ParameterDirection.Input));

      /*-------------------------------
       * Define Query
       *------------------------------*/ 

      string sql = "select * from dbo.SERVICE_RECORD_VIEW_SVC_NOTE_SVC_REC (@userID, @userGroup, @userRank, @clientID, null, null, @recID)";
     
      /*-------------------------------
       * Run Query and return results
       *------------------------------*/ 
  
      rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      return rd;
    }

    /***************************************************************************
     * viewList */
    /**
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  uInfo           User info object
     * @param  clientId        Client ID
     * @param  recID           Service record ID
     * @return                 List<ServiceRecordNoteSvcRec>
     ***************************************************************************/

    public static List<ServiceRecordNoteSvcRec> viewList (  
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        clientID     
      , string        recID )       
                                    
    {
      List<ServiceRecordNoteSvcRec> rl = new List<ServiceRecordNoteSvcRec>();
      ReturnDB rd = view (connSpedmon, log, uInfo,clientID,recID);
      Object[] ol = Database.convertRecords(rd.records, typeof(ServiceRecordNoteSvcRec));
      foreach (Object o in ol) {
        ServiceRecordNoteSvcRec r = (ServiceRecordNoteSvcRec)o;
        rl.Add(r);
      }
      return rl;
    }                  
  }
} 

