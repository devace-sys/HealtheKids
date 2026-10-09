using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
 
 /***************************************************************************
  * ReturnValue */
 /**
  * Returns a single value as a string
  ***************************************************************************/   
  
  public class ReturnValue : Return
  {
    public ReturnValue ()            : base(){}
    public ReturnValue (string msg)  : base(msg){}
    public ReturnValue (Exception e) : base(e){}
    public ReturnValue (Warning e)   : base(e){}
    public ReturnValue (Critical e)  : base(e){}
    public ReturnValue (SessionExpired e):base(e){}
    
    public string value;
  
  }
}
