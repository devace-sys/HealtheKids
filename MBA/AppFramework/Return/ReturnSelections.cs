using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * ReturnSelections */
  /**
   * Return structure for returning selections
   ***************************************************************************/   
  
  public class Selection
  {
    public string     name;
    public string     value;
    public string     detail;
	  public bool       active;
	  public DateTime   created;
	  public DateTime   modified;
  }
  
  public class ReturnSelections : Return
  {
    public ReturnSelections ()                 : base(){}
    public ReturnSelections (string msg)       : base(msg){}
    public ReturnSelections (Exception e)      : base(e){}
    public ReturnSelections (Warning e)        : base(e){}
    public ReturnSelections (Critical e)       : base(e){}
    public ReturnSelections (SessionExpired e) : base(e){}    
    public Selection[] Selections;
  }

}
