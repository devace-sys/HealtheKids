using System;
using System.Collections.Generic;
using System.Text;
using EAW.MediaFile;

namespace MBA
{
  
   
  /***************************************************************************
   * ReturnStoredFileRecord */
  /**
   * Stored file data
   ***************************************************************************/   
 
  public class ReturnStoredFileRecord:Return
  {
    public ReturnStoredFileRecord ()                 : base(){}
    public ReturnStoredFileRecord (string msg)       : base(msg){}
    public ReturnStoredFileRecord (Exception e)      : base(e){}
    public ReturnStoredFileRecord (Warning e)        : base(e){}
    public ReturnStoredFileRecord (Critical e)       : base(e){}  
    public ReturnStoredFileRecord (SessionExpired e) : base(e){}
    
    public   string             storedFileRecordID;
    public   bool               storedFileRecordFound;
    public   StoredFileRecord   storedFileRecord;	
    
    public   string             storedFileTargetLocation;
    public   bool               storedFileTargetFound;
    public   StoredFileTarget   storedFileTarget;

    public   string             endPoint;
    public   string             displayURL;
    public   string             deliverURL;
    public   string             downloadURL;    
    
  }
}
