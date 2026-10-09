using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * ReturnNamesValues */
  /**
   * Return structure for WebUIControl ComboBox or SearchBox requests
   * This structure can be efficiently parsed by the client side code
   ***************************************************************************/   
  
  public class ReturnNamesValues : Return
  {
    public ReturnNamesValues ()            : base(){}
    public ReturnNamesValues (string msg)  : base(msg){}
    public ReturnNamesValues (Exception e) : base(e){}
    public ReturnNamesValues (Warning e)   : base(e){}
    public ReturnNamesValues (Critical e)  : base(e){}
    public ReturnNamesValues (SessionExpired e):base(e){}
    
    public NameValue[] NamesValues;
  }


}
