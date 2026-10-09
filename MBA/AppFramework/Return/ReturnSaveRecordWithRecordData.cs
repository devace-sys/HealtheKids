using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * ReturnSaveRecordWithRecordData */
  /**
   * 
   *
   ***************************************************************************/   
 
  public class ReturnSaveRecordWithRecordData:ReturnSaveRecord
  {
    public ReturnSaveRecordWithRecordData ()                 : base(){}
    public ReturnSaveRecordWithRecordData (string msg)       : base(msg){}
    public ReturnSaveRecordWithRecordData (Exception e)      : base(e){}
    public ReturnSaveRecordWithRecordData (Warning e)        : base(e){}
    public ReturnSaveRecordWithRecordData (Critical e)       : base(e){}  
    public ReturnSaveRecordWithRecordData (SessionExpired e) : base(e){}
    
    public string   recData1;       // Extra data (add more as needed.. keep in synch with selRec
    public string   recData2;
    public string   recData3;
    public string   recData4;


  }

}
