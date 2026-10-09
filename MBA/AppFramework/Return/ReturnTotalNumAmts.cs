using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
 
 /***************************************************************************
  * ReturnTotalNumAmts */
 /**
  * Return total number amount
  ***************************************************************************/   
  
  public class ReturnTotalNumAmts : Return
  {
    public ReturnTotalNumAmts ()            : base(){}
    public ReturnTotalNumAmts (string msg)  : base(msg){}
    public ReturnTotalNumAmts (Exception e) : base(e){}
    public ReturnTotalNumAmts (Warning e)   : base(e){}
    public ReturnTotalNumAmts (Critical e)  : base(e){}
    public ReturnTotalNumAmts (SessionExpired e) : base(e){}

    public TotalNumAmt[] totalNumAmts;
  
  }
}
