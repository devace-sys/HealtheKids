using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
 
 /***************************************************************************
  * ReturnTotalNumAmt */
 /**
  * Return total number amount
  ***************************************************************************/   
  
  public class ReturnTotalNumAmt : Return
  {
    public ReturnTotalNumAmt ()            : base(){}
    public ReturnTotalNumAmt (string msg)  : base(msg){}
    public ReturnTotalNumAmt (Exception e) : base(e){}
    public ReturnTotalNumAmt (Warning e)   : base(e){}
    public ReturnTotalNumAmt (Critical e)  : base(e){}
    public ReturnTotalNumAmt (SessionExpired e) : base(e){}

    public TotalNumAmt totalNumAmt;
  
  }
}
