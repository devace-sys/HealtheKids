using System;
using System.Collections.Generic;
using System.Text;
using EAW.MediaFile;

namespace MBA
{
  
  /***************************************************************************
   * ReturnStoredFileAppendInfo */
  /**
   * Stored file data
   ***************************************************************************/   
 
  public class ReturnStoredFileAppendInfo:Return, iReturnStoredFileAccessStatus
  {
    public ReturnStoredFileAppendInfo ()                 : base(){}
    public ReturnStoredFileAppendInfo (string msg)       : base(msg){}
    public ReturnStoredFileAppendInfo (Exception e)      : base(e){}
    public ReturnStoredFileAppendInfo (Warning e)        : base(e){}
    public ReturnStoredFileAppendInfo (Critical e)       : base(e){}  
    public ReturnStoredFileAppendInfo (SessionExpired e) : base(e){}
    
    public bool accessGranted        { get; set; } 
    public long clientID             { get; set; }
    
    public long     teleCommSessionID;
    public string   teleCommServerSessionID = "";
    public string   appName                 = "";
    public long     userID;
    public int      userGroup;
    public int      userRank;
    public string   fileClassStr            = "";
    public string   fileNameSpace           = "";
    public string   fileSource              = "";
    public string   clientIDStr             = "";
    public string   pracIDStr               = "";
    public string   patIDStr                = "";
    public string   referencedEntityIDStr   = "";
    public bool     noUserInfoPassed = false;
    public UserInfo uInfo            = null;
  }
}
