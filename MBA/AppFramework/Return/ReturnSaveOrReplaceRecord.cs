using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * ReturnSaveOrReplaceRecord */
  /**
   * Standard output class for services that save or replace records.  
   ***************************************************************************/   
 
  public class ReturnSaveOrReplaceRecord:Return
  {
    public ReturnSaveOrReplaceRecord ()                 : base(){}
    public ReturnSaveOrReplaceRecord (string msg)       : base(msg){}
    public ReturnSaveOrReplaceRecord (Exception e)      : base(e){}
    public ReturnSaveOrReplaceRecord (Warning e)        : base(e){}
    public ReturnSaveOrReplaceRecord (Critical e)       : base(e){}  
    public ReturnSaveOrReplaceRecord (SessionExpired e) : base(e){}
    
    public long     recordID;
    public int      saveType;
    public string   spDetails;

  }

}
