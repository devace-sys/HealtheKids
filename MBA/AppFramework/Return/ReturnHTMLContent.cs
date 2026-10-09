using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
 
 /***************************************************************************
  * ReturnHTMLContent */
 /**
  * Returns HTML content
  ***************************************************************************/   
  
  public class ReturnHTMLContent : Return
  {
    public ReturnHTMLContent ()            : base(){}
    public ReturnHTMLContent (string msg)  : base(msg){}
    public ReturnHTMLContent (Exception e) : base(e){}
    public ReturnHTMLContent (Warning e)   : base(e){}
    public ReturnHTMLContent (Critical e)  : base(e){}
    public ReturnHTMLContent (SessionExpired e):base(e){}

    public string content = @"";
  
  }
}
