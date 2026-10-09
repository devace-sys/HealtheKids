using System;
using System.Collections.Generic;
using System.Text;
using System.Net;
using Geo.USPS;

namespace MBA
{
  /***************************************************************************
   * ReturnUspsAddress */
  /**
   * 
   ***************************************************************************/   
 
  public class ReturnUspsAddress:Return
  {
    public ReturnUspsAddress ()                 : base(){}
    public ReturnUspsAddress (string msg)       : base(msg){}
    public ReturnUspsAddress (Exception e)      : base(e){}
    public ReturnUspsAddress (Warning e)        : base(e){}
    public ReturnUspsAddress (Critical e)       : base(e){}  
    public ReturnUspsAddress (SessionExpired e) : base(e){}
        
    public Geo.USPS.Address addressIn;
    public Geo.USPS.Address addressOut;       
    
  }
}
