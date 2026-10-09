using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;


namespace MBA
{
  /***************************************************************************
   * Platform */
  /**
   * Platform the user is using
   ***************************************************************************/  	
	
	public class Platform: IEqualityComparer<Platform>
	{
		
	  public bool   complete;  // Is this a complete record?	  
	  public string device;
	  public string os;
	  
	  public bool isMobile;
	  public bool isDesktop;
	  public bool isBot;
	  public bool isOther;
	  
   /*---------------------------------
	  * Constructors
	  *--------------------------------*/
	  
	  public Platform()
	  {
		  this.complete  = false;
		  this.device    = "";
		  this.os        = "";
		  this.isMobile  = false;
		  this.isDesktop = false;
		  this.isBot     = false;
		  this.isOther   = false;
	  }
	  
	  /*---------------------------------
	   * Interface methods
	   *--------------------------------*/		      	 
	  
	  public bool Equals(Platform x, Platform y)
	  {
	    bool isEqual = false;
		  isEqual = ((x.os == y.os) && (x.device == y.device));
		  return isEqual;
	  }
	  
	  public int GetHashCode(Platform obj)
	  {
	    string hash = obj.device + obj.os;
		  return hash.GetHashCode();
	  }
		
	  /*---------------------------------
	   * Overrides
	   *--------------------------------*/

   	public override string ToString ()
	  {
      string s = this.device + " | " + this.os;
		  return s;
	  }

	  /*---------------------------------
	   * Static methods
	   *--------------------------------*/
			  
	  public static Platform Parse (string useragent)
	  {
	    Platform p = new Platform();		
				
		  try
		  {
	
	      /*---------------------------------
	       * First check to see if the
	       * platform is a mobile device
	       *--------------------------------*/	

		    Match m = Regex.Match(useragent, @"(iphone|ipod|ipad|blackberry|android|palm|windows\s+ce)", RegexOptions.IgnoreCase);
	      if (m.Success)
		    {
		      p.device = "Mobile";
          p.isMobile = true;
		    }

		    /*---------------------------------
	       * If its not a mobile device
	       * check to see if its a desktop
	       *--------------------------------*/	

		    if (!m.Success)
		    {
		      m = Regex.Match(useragent, @"(windows|linux|os\s+[x9]|solaris|bsd)", RegexOptions.IgnoreCase);
		      if (m.Success)
			    {
			      p.device    = "Desktop";
			      p.isDesktop = true;
			    }
		    }

		    /*---------------------------------
	       * If its not a desktop check to
	       * see if its a bot
	       *--------------------------------*/	
		
		    if (!m.Success)
		    {
		      m = Regex.Match(useragent, @"(spider|crawl|slurp|bot)", RegexOptions.IgnoreCase);
		      if (m.Success)
			    {
			      p.device = "Bot";						
			      p.isBot  = true;
	        
		        /*---------------------------------
	           * Determine the bot "os"
	           *--------------------------------*/							
			 
			      Match b = Regex.Match(useragent, @"(msnbot|bingbot|googlebot|slurp)", RegexOptions.IgnoreCase);
			  
			      if (b.Success)
			        p.os = b.Value;	
			      else
			       p.os = "Other";
			    }
		    }

		    /*---------------------------------
	       * If nothing matched then classify
	       * this as an other device
	       *--------------------------------*/	
				
		    if (!m.Success)
	  	  {
		      p.device = "Other";
			    p.isOther = true;
		    }

	      /*---------------------------------
	       * For all devices other than bots
	       * determine the OS
	       *--------------------------------*/	
		
		    if (!p.isBot)
		      p.os = m.Value;
		  
	      /*---------------------------------
	       * Done
	       *--------------------------------*/	

		    p.complete = true;

		  }
		  catch
		  { 
		    p.complete = false;
		  }
		  return p;
	  }		
	}	
}