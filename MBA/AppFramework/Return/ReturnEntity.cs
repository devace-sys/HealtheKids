using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
 
 /***************************************************************************
  * ReturnEntity */
 /**
  * Return basic data on a given entity
  ***************************************************************************/   
  
  public class ReturnEntity : Return
  {
    public ReturnEntity ()            : base(){}
    public ReturnEntity (string msg)  : base(msg){}
    public ReturnEntity (Exception e) : base(e){}
    public ReturnEntity (Warning e)   : base(e){}
    public ReturnEntity (Critical e)  : base(e){}
    public ReturnEntity (SessionExpired e):base(e){}
    
    public Entity entity;
  
  }
}
