using System;
using System.Collections.Generic;
using System.Text;
using System.Net;
using Geo.CDE;

namespace MBA
{
  /***************************************************************************
   * ReturnCdeSchoolDirectoryEntry */
  /**
   * 
   ***************************************************************************/   
 
  public class ReturnCdeSchoolDirectoryEntry:Return
  {
    public ReturnCdeSchoolDirectoryEntry ()                 : base(){}
    public ReturnCdeSchoolDirectoryEntry (string msg)       : base(msg){}
    public ReturnCdeSchoolDirectoryEntry (Exception e)      : base(e){}
    public ReturnCdeSchoolDirectoryEntry (Warning e)        : base(e){}
    public ReturnCdeSchoolDirectoryEntry (Critical e)       : base(e){}  
    public ReturnCdeSchoolDirectoryEntry (SessionExpired e) : base(e){}
    
    public Geo.CDE.SchoolDirectoryEntry directoryEntry;
    
  }
}
