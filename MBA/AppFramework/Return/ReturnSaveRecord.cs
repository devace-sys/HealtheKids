using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * ReturnSaveRecord */
  /**
   * Standard output class for services that save records.  Save is a generic
   * term for creating new, editing existing, or deleting existing records
   ***************************************************************************/   
 
  public class ReturnSaveRecord:Return
  {
    public ReturnSaveRecord ()                 : base(){}
    public ReturnSaveRecord (string msg)       : base(msg){}
    public ReturnSaveRecord (Exception e)      : base(e){}
    public ReturnSaveRecord (Warning e)        : base(e){}
    public ReturnSaveRecord (Critical e)       : base(e){}  
    public ReturnSaveRecord (SessionExpired e) : base(e){}
    
    public long         recordID;
    public string       spDetails;    

  }

}
