using System;
using System.Collections.Generic;
using System.Text;
using EAW.MediaFile;

namespace MBA
{
  
   
  /***************************************************************************
   * ReturnStoredFileAccessStatus */
  /**
   * Stored file data
   ***************************************************************************/   
 
  public class ReturnStoredFileAccessStatus:Return, iReturnStoredFileAccessStatus
  {
    public ReturnStoredFileAccessStatus ()                 : base(){}
    public ReturnStoredFileAccessStatus (string msg)       : base(msg){}
    public ReturnStoredFileAccessStatus (Exception e)      : base(e){}
    public ReturnStoredFileAccessStatus (Warning e)        : base(e){}
    public ReturnStoredFileAccessStatus (Critical e)       : base(e){}  
    public ReturnStoredFileAccessStatus (SessionExpired e) : base(e){}
    public bool accessGranted { get; set; }
    public long clientID      { get; set; }

  }
}
