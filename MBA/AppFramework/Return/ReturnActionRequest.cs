using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * ReturnActionRequest */
  /**
   * Standard output class for services that return the result of an action
   * request
   ***************************************************************************/   
 
  public class ReturnActionRequest:ReturnSaveRecord
  {
    public ReturnActionRequest ()                 : base(){}
    public ReturnActionRequest (string msg)       : base(msg){}
    public ReturnActionRequest (Exception e)      : base(e){}
    public ReturnActionRequest (Warning e)        : base(e){}
    public ReturnActionRequest (Critical e)       : base(e){}  
    public ReturnActionRequest (SessionExpired e) : base(e){}
    
    public string confirmValue;
    public string confirmEmail;

  }

}
