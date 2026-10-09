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
   * ReturnServiceRecordNote */
  /**
   * Output class for returning service record note details
   ***************************************************************************/   
 
  public class ReturnServiceRecordNote:Return
  {
    public ReturnServiceRecordNote ()                 : base(){}
    public ReturnServiceRecordNote (string msg)       : base(msg){}
    public ReturnServiceRecordNote (Exception e)      : base(e){}
    public ReturnServiceRecordNote (Warning e)        : base(e){}
    public ReturnServiceRecordNote (Critical e)       : base(e){}  
    public ReturnServiceRecordNote (SessionExpired e) : base(e){}
    
    public List<ServiceRecordNoteSvcRec>      SvcRecNotesSvcRec;
    public List<ServiceRecordNoteUnformatted> SvcRecNotesUnformatted;
    public List<ServiceRecordNoteFormatted>   SvcRecNotesFormatted;
  
  }
  
  /***************************************************************************
   * ServiceRecordsNote */
  /**
   * Methods to load details
   ***************************************************************************/

  public class ServiceRecordsNote
  {
       	
	  /***************************************************************************
     * load */
    /**
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @return                 ReturnEntity
     ***************************************************************************/
      
    public static ReturnServiceRecordNote load (    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo 
      , string        clientID     
      , string        recID )

    {         
      ReturnServiceRecordNote rd = new ReturnServiceRecordNote();
   
      /*-------------------------------
       * Populate
       *------------------------------*/
        
      rd.SvcRecNotesSvcRec      = ServiceRecordsNotesSvcRec.viewList      (connSpedmon,log,uInfo,clientID,recID);
      rd.SvcRecNotesUnformatted = ServiceRecordsNotesUnformatted.viewList (connSpedmon,log,uInfo,clientID,recID);
      rd.SvcRecNotesFormatted   = ServiceRecordsNotesFormatted.viewList   (connSpedmon,log,uInfo,clientID,recID);

      return rd;
    }   
                 
  }
} 

