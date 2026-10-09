using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
 
 /***************************************************************************
  * ReturnObject */
 /**
  * Return results of a view as an single entity
  ***************************************************************************/   
  
  public class ReturnObject : Return
  {
    public ReturnObject ()            : base(){}
    public ReturnObject (string msg)  : base(msg){}
    public ReturnObject (Exception e) : base(e){}
    public ReturnObject (Warning e)   : base(e){}
    public ReturnObject (Critical e)  : base(e){}
    public ReturnObject (SessionExpired e):base(e){}
        
    public bool     hasRecord;
    public string   objectFullName;

    public Object data;
  }
}
