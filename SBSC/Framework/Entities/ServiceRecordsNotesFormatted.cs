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
   * ServiceRecordNoteFormatted */
  /**
   * Unformatted note
   ***************************************************************************/
  
  public class ServiceRecordNoteFormatted
  {
    public long   id;
	  public long   svcRecID;
	  public long   noteID;
	  public long   questionNumber;
	  public string questionText;
	  public string headerText;
	  public long   answerNumber;
	  public string answerText;
  }
  
  /***************************************************************************
   * ServiceRecordsNotesFormatted */
  /**
   * Methods to work with formatted notes
   ***************************************************************************/

  public class ServiceRecordsNotesFormatted
  {
   
    /***************************************************************************
     * view */
    /**
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @return                 ReturnEntity
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
      long vRecID      = Validate.reqInteger (recID, Messages.INVALID_RECORD_ID);
      
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

      string sql = "select * from dbo.SERVICE_RECORD_VIEW_SVC_NOTE_FORMATTED_NOTE (@userID, @userGroup, @userRank, @clientID, null, null, @recID)";
     
      /*-------------------------------
       * Run Query and return results
       *------------------------------*/ 
  
      rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      return rd;
    }
   
   
    /***************************************************************************
     * viewList */
    /**
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @return                 ServiceRecordNoteUnformatted
     ***************************************************************************/

    public static List<ServiceRecordNoteFormatted> viewList (  
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        clientID     
      , string        recID )       
                                    
    {
      List<ServiceRecordNoteFormatted> rl = new List<ServiceRecordNoteFormatted>();
      ReturnDB rd = view (connSpedmon, log, uInfo,clientID,recID);
      Object[] ol = Database.convertRecords(rd.records, typeof(ServiceRecordNoteFormatted));
      foreach (Object o in ol) {
        ServiceRecordNoteFormatted r = (ServiceRecordNoteFormatted) o;
        rl.Add(r);
      }
      return rl;
    }   
                     
  }

} 

