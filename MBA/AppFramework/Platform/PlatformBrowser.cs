using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;


namespace MBA
{
  /***************************************************************************
   * PlatformBrowser */
  /**
   * Platform and browser
   ***************************************************************************/  	
    
  public class PlatformBrowser:IEqualityComparer<PlatformBrowser>
	{
	
	  public Platform platform;
	  public Browser  browser;
		
	  /*---------------------------------
	   * Properties
	   *--------------------------------*/		
		
    public bool complete {get{return platform.complete && browser.complete;}}
		
	  /*---------------------------------
	   * Constructors
	   *--------------------------------*/

	  public PlatformBrowser()
	  {
	    this.platform = new Platform();
		  this.browser  = new Browser();
	  }
		
	  public PlatformBrowser(Platform p, Browser b)
	  {
	    this.platform = p;
		  this.browser  = b;
	  }
	  
	  /*---------------------------------
	   * Interface methods
	   *--------------------------------*/
		
	  public bool Equals(PlatformBrowser x, PlatformBrowser y)
	  {
	    bool isEqual = false;		
			
		  isEqual = x.platform.Equals(x.platform, y.platform) &&
				        y.platform.Equals(x.platform, y.platform) &&
                x.browser.Equals(x.browser,y.browser)     && 
				        y.browser.Equals(x.browser, y.browser);
		
		  return isEqual;
	  }
	  
	  public int GetHashCode(PlatformBrowser obj)
	  {
	    string hash = obj.platform.device + 
				            obj.platform.os     + 
					          obj.browser.name    + 
					          obj.browser.version;			
		
		  return hash.GetHashCode();
	  }		
      
	  /*---------------------------------
	   * Overrides
	   *--------------------------------*/

   	public override string ToString ()
	  {
      string s = this.platform.ToString() + " | " + this.browser.ToString();
		  return s;
	  }
		
	  /*---------------------------------
	   * Static Methods
	   *--------------------------------*/		
	
	  public static PlatformBrowser Parse (string useragent)
	  {
	    PlatformBrowser pb = new PlatformBrowser();

		  pb.platform = Platform.Parse(useragent);
		  pb.browser  = Browser.Parse(useragent);		  
		  return pb;
	  }		
	}	
}