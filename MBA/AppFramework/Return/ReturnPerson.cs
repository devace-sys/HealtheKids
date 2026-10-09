using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
 
 /***************************************************************************
  * ReturnPerson*/
 /**
  * Return basic data on a given person
  ***************************************************************************/   
  
  public class ReturnPerson : Return
  {
    public ReturnPerson ()            : base(){}
    public ReturnPerson (string msg)  : base(msg){}
    public ReturnPerson (Exception e) : base(e){}
    public ReturnPerson (Warning e)   : base(e){}
    public ReturnPerson (Critical e)  : base(e){}
    public ReturnPerson (SessionExpired e):base(e){}
    
    public Person person;
  
  }
}
