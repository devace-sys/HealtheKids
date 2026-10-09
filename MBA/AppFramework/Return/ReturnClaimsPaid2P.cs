using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
 
 /***************************************************************************
  * ReturnClaimsPaid2P */
 /**
  * Return total number amount
  ***************************************************************************/   
  
  public class ReturnClaimsPaid2P : Return
  {
    public ReturnClaimsPaid2P ()            : base(){}
    public ReturnClaimsPaid2P (string msg)  : base(msg){}
    public ReturnClaimsPaid2P (Exception e) : base(e){}
    public ReturnClaimsPaid2P (Warning e)   : base(e){}
    public ReturnClaimsPaid2P (Critical e)  : base(e){}
    public ReturnClaimsPaid2P (SessionExpired e) : base(e){}

    public ClaimPaid2P[] claimsPaid2P;
  
  }
}
