using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
 
 /***************************************************************************
  * ReturnTeleCommSessionParticipant */
 /**
  * Return basic data on a given person
  ***************************************************************************/   
  
  public class ReturnTeleCommSessionParticipant : Return
  {
    public ReturnTeleCommSessionParticipant ()            : base(){}
    public ReturnTeleCommSessionParticipant (string msg)  : base(msg){}
    public ReturnTeleCommSessionParticipant (Exception e) : base(e){}
    public ReturnTeleCommSessionParticipant (Warning e)   : base(e){}
    public ReturnTeleCommSessionParticipant (Critical e)  : base(e){}
    public ReturnTeleCommSessionParticipant (SessionExpired e):base(e){}
   
    public bool                       hasRecord       = false;
    public TeleCommSessionParticipant tsp;

    public string                     directSignInUrl = @"";
    public string                     rsvpPageUrl     = @"";

    //public string                     spedPvtRsvpPageUrl     = @"";
  
  }
}
