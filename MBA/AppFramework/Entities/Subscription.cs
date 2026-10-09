using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * Subscription */
  /**
   * 
   **************************************************************************/
  
  public class Subscription
  {                
    
    public long    id;
    public long    PublicationID;
    public string  PublicationName;
    public long    SubscriberID;
    public string  SubscriberName;
    public string  SubscriberEmail;    
    public string  ManagedByEmails;  
    public bool    AutoDistribute;
    public string  DistributionNotes;
    public bool    Active;
    public string  FileTypeRequestedName;
    public short   FileTypeRequestedValue;
  }
}
