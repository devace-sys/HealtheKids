using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using HtmlAgilityPack;
using System.Web.Script.Serialization;

namespace MBA
{
  
  /***************************************************************************
   * ReturnScrape */
  /**
   * Our internal return class for scraping i/o.  
   ***************************************************************************/   

  public class ReturnScrape : Return
  {    
    public ReturnScrape ()                 : base()    {}
    public ReturnScrape (string msg)       : base(msg) {}
    public ReturnScrape (Exception e)      : base(e)   {}
    public ReturnScrape (Warning e)        : base(e)   {}
    public ReturnScrape (Critical e)       : base(e)   {}
    public ReturnScrape (SessionExpired e) : base(e)   {}
    
    public string       url;
    public NameValue[]  parms;
    
    public HtmlDocument doc;    
    public string       html;
    public string       link;
        
  }
}
