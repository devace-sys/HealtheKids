using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;


namespace MBA
{
  /***************************************************************************
   * SiteLogEntry */
  /**
   * Holds a site log entry
   ***************************************************************************/  		
	
	public class SiteLogEntry
	{

	  public bool            complete;          // Is this a complete record?
	  public string          ip;
	  public DateTime        datetime;
	  public string          yearmonth;
    public string          original;
	  public PlatformBrowser platformbrowser;

	  protected string useragent;	  

	  /*---------------------------------
	   * Constructors
	   *--------------------------------*/
	  
	  public SiteLogEntry()	  
	  {
	    this.complete = false;
		  this.platformbrowser = new PlatformBrowser();
	  }
	 
	  /*---------------------------------
	   * Overrides
	   *--------------------------------*/
	  
	  public override string ToString ()
	  {
	    string s = this.yearmonth                  + "|" +
				         this.platformbrowser.ToString() + "|" +
				         this.ip                         + "|" +
				         this.original;
		  return s;
	  }
		
	  /*---------------------------------
	   * Static Methods
	   *--------------------------------*/		
	
	  public static SiteLogEntry ParseLogEntryLine (string linein)
	  {
	    
	    SiteLogEntry entry = new SiteLogEntry();		
		  entry.complete = false;
	  	entry.original = linein;
			
		  if (linein == null)     return entry;
		  if (linein.Length == 0) return entry;
			
		  try
		  {		  
		    string[] lineparts = linein.Split('|',']');
		
		    int position = 0;
			
		    foreach (string linepart in lineparts)
	      {
		  
		      // We are only parsing part of the line
			  
			    if (position > 4) break;
		  
		      // Clean up line part
			
			    string lp = linepart.Replace("[","").Trim();
		  	
		      // Extract field
					
		      if (position == 2)
		        entry.useragent = lp;
		      else if (position == 3)
		        entry.ip = lp;
		      else if (position == 4)
		      {
		        DateTime.TryParse(lp,out entry.datetime);
			      entry.yearmonth = entry.datetime.ToString("yyyy-MM");
		      }  		    
			    position++;		
		    }
		    
		    entry.platformbrowser = PlatformBrowser.Parse(entry.useragent);		  
		    entry.complete        = entry.platformbrowser.complete && true;
		    if (entry.datetime == DateTime.MinValue)
	        entry.complete = false;	
      }
		  catch
		  {
		    entry.complete = false;
		  }		  
		  return entry;
	  }
	}

  
  /***************************************************************************
   * SiteLogUtilities */
  /**
   * Tools for parsing site logs
   ***************************************************************************/  		
   		
	public class SiteLogUtilities		
	{      
	  	  	  	  		
    /***************************************************************************
     * ParseLogFile */
    /**
     * Parses log file into list of site log entries
     ***************************************************************************/  		

    public static List<SiteLogEntry> ParseLogFile(string file)
	  {
	    List<SiteLogEntry> entries = new List<SiteLogEntry>();
		  StreamReader       sr      = new StreamReader(file);
	    
	    string linein = "";
	    
	    while ((linein = sr.ReadLine()) != null)
	    {
	      
	      // Create site log entry
	      
	      SiteLogEntry e = SiteLogEntry.ParseLogEntryLine(linein);
		    
		    // Only add complete entries
		    
		    if (e.complete)
		      entries.Add(e);
	    }
  	  
  	  sr.Close();
		  return entries;
	  }	  	  
	 
	}		
}