using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * ReturnSaveRecordWithJSONData */
  /**
   * 
   *
   ***************************************************************************/   
 
  public class ReturnSaveRecordWithJSONData:ReturnSaveRecord
  {
    public ReturnSaveRecordWithJSONData ()                 : base(){}
    public ReturnSaveRecordWithJSONData (string msg)       : base(msg){}
    public ReturnSaveRecordWithJSONData (Exception e)      : base(e){}
    public ReturnSaveRecordWithJSONData (Warning e)        : base(e){}
    public ReturnSaveRecordWithJSONData (Critical e)       : base(e){}  
    public ReturnSaveRecordWithJSONData (SessionExpired e) : base(e){}
    
    public string jsonData; /* Use sql data type varchar(max) */

  }

}
