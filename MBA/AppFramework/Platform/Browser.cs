using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;

namespace MBA
{
  
  /***************************************************************************
   * Browser */
  /**
   * What browser the user is using
   ***************************************************************************/  	
  
  public class Browser: IEqualityComparer<Browser>
	{					  
	  public bool   complete;  // Is this a complete record?	  
	  public string name;
	  public string version;
		
	  public bool isIE;
	  public bool isFF;
	  public bool isGC;
	  public bool isSF;
	  public bool isOP;
	  public bool isOther;
		
	  /*---------------------------------
	   * Constructors
	   *--------------------------------*/

	  public Browser()
	  {
	    this.complete = false;
		  this.name     = "";
		  this.version  = "";
	    this.isIE     = false;
	    this.isFF     = false;
	    this.isGC     = false;
	    this.isSF     = false;
	    this.isOP     = false;
	    this.isOther  = false;	  
	  }
			  
	  /*---------------------------------
	   * Interface methods
	   *--------------------------------*/
	  
	  public bool Equals(Browser x, Browser y)
	  {
	    bool isEqual = false;
		  isEqual = ((x.name == y.name) && (x.version == y.version));
		  return isEqual;
	  }
	  
	  public int GetHashCode(Browser obj)
	  {
	    string hash = obj.name + obj.version;
		  return hash.GetHashCode();
	  }
	  
	  /*---------------------------------
	   * Overrides
	   *--------------------------------*/

   	public override string ToString ()
	  {
      string s = this.name + " | " + this.version;  		
		  return s;
	 }
	  	  
	  public static Browser Parse (string useragent)
	  {
		  Browser b = new Browser();
		  
		  bool crios = false;
		  bool ie11  = false;
		  			
		  try
		  {				
	      Match m;
			
		    /*---------------------------------
	       * See if the browser is IE 10 or
         * lower
	       *--------------------------------*/	

		    m = Regex.Match(useragent, @"msie\s\d+\.\d+", RegexOptions.IgnoreCase);				
		    if (m.Success) 
		    {
		      b.isIE = true;
          ie11   = false;
        }

		    /*---------------------------------
	       * See if the browser is IE 11 or
         * higher
	       *--------------------------------*/	
	       
        if (!m.Success)
        {        
          m = Regex.Match(useragent, @"trident/\d*\.\d*; rv:\d*\.\d*", RegexOptions.IgnoreCase);			    
          if (m.Success) b.isIE = true;
          ie11 = false;
        }
		    
		    /*---------------------------------
	       * If its not IE see if its Firefox
	       *--------------------------------*/	
				
		    if (!m.Success)
		    {
		      m = Regex.Match(useragent, @"firefox/\d+\.\d+", RegexOptions.IgnoreCase);
		      if (m.Success) b.isFF = true;
	   	  }

		    /*---------------------------------
	       * If its not Firefox see if its 
	       * Opera
	       *--------------------------------*/	
			
		    if (!m.Success)
		    {	
		      m = Regex.Match(useragent, @"opera/\d+\.\d+", RegexOptions.IgnoreCase);
		      if (m.Success) b.isOP = true;
		    }

		    /*---------------------------------
	       * If its not Opera see if its 
	       * Chrome
	       *--------------------------------*/	
			
		    /*---------------------------------
	       * Chrome on iOS
	       *--------------------------------*/	

        if (!m.Success)
        {
          m = Regex.Match(useragent,@"crios"); /* Chrome on ios */
          if (m.Success) b.isGC = true;
          crios = true;
        }

		    /*---------------------------------
	       * Chrome on everything else
	       *--------------------------------*/	

		    if (!m.Success)
	  	  {
		      m = Regex.Match(useragent, @"chrome", RegexOptions.IgnoreCase);
			    if (m.Success) b.isGC = true;
		      crios = false;
		    }	

        		    
		    /*---------------------------------
	       * If its not Chrome see if its 
	       * Safari
	       *--------------------------------*/	
			
		    if (!m.Success)
	  	  {
		      m = Regex.Match(useragent, @"safari/\d+\.\d+", RegexOptions.IgnoreCase);
          if (m.Success) b.isSF = true;		  
		    }	

		    /*---------------------------------
	       * If its not any of these
	       * then classify it as other
	       * and get out
	       *--------------------------------*/	
				
		    if (!m.Success)
		    {
		      b.name     = "Other";
		      b.version  = "";
			    b.isOther  = true;
			    b.complete = true;
			    return b;
		    }

		   /*---------------------------------
	      * Get the browser version
	      * for browsers that were identified
	      * as IE and then get out
	      *--------------------------------*/	
		
		  if (b.isIE)
	  	{
		    if (ie11 == false)
		    {
		      string[] valueparts = m.Value.Split(' ');
		      b.name     = valueparts[0];
		      b.version  = valueparts[1];
			    b.complete = true;
		      return b;
		    }
		    else
		    {
		      b.name = "msie";
		      b.version = "11";
		      b.complete = true;
		      return b;
		    }
		  }

		  /*---------------------------------
	     * Get the browser version
	     * for browsers that were identifed
	     * as Firefox or Safari and then
	     * get out.
	     *--------------------------------*/	
		
     if (b.isFF | b.isOP)
		 {
		   string[] valueparts = m.Value.Split('/');
		   b.name              = valueparts[0];
		   b.version           = valueparts[1];
			 b.complete          = true;
       return b;
		 }

		 /*---------------------------------
	    * Get the browser version
	    * for browsers that were identifed
	    * as Chrome and get out.
	    *--------------------------------*/	

		 if (b.isGC)
		 {
        b.name = m.Value;
			 
			  if (crios == false)
			  {
			    m  = Regex.Match(useragent, @"chrome/\d+\.\d+", RegexOptions.IgnoreCase);		
        }
        else
        {
          m  = Regex.Match(useragent, @"crios/\d+\.\d+", RegexOptions.IgnoreCase);		
        }
          	
			  if (m.Success)
			  {
			    string[] valueparts = m.Value.Split('/');		    
			    b.version = valueparts[1];			
			  }
			  else
			  {
			    b.version = "0";  // Beta
			 }
			 
			 return b;
		 }
		  
		 /*---------------------------------
	     * Get the browser version
	     * for browsers that were identifed
	     * as Chrome and get out.
	     *--------------------------------*/					
				
		 if (b.isSF)
		 {
		   string[] valueparts = m.Value.Split('/');
		   b.name = valueparts[0];
			 m = Regex.Match(useragent,@"version/\d+\.\d+",RegexOptions.IgnoreCase);
			 if (m.Success)
			 {
			   string[] versionparts = m.Value.Split('/');
         b.version = versionparts[1];
			 }
			 else
			 {
			   b.version = "";
			 }
		   return b;
		 }       
	 }
   catch
   {
	   b.complete = false;
	 }
		
   /*---------------------------------
	  * We should never reach this point
	  * unless an exception was
	  * caught
	  *--------------------------------*/		    

		return b;
		
    }
  } 		
}