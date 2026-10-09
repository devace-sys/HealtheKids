using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MBA
{

  /***************************************************************************
   * NounVerbNameValue */
  /**
   ***************************************************************************/  
  
  public class NounVerbNameValue:NameValue
  {
    
    public NounVerbNameValue():base(){}
    
    public  long     id;
    public  string   appDomain;
    public  string   appName;
    public  string   selector;
    public  string   selectorType;
    public  string   noun;
    public  string   verb;
    public  DateTime created;
    public  long     createdBy;
    public  DateTime lastModified;
    public  long     lastModifiedBy;

  }
}
