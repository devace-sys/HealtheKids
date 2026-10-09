using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;
using MBA.Reporting;
using System.Text.RegularExpressions;

using ca = MBA.ColumnAttribute;


namespace MBA
{
  
  public delegate void ReturnRptDataCallback (ref ReturnRptData so);
  
  /***************************************************************************
   * ReturnRptData */
  /**
   * Our return class containing all of the data we need to generate a report
   ***************************************************************************/

  public class ReturnRptData : Return, DataFileDistributable
  {
    public ReturnRptData ()                 : base()    {}
    public ReturnRptData (string msg)       : base(msg) {}
    public ReturnRptData (Exception e)      : base(e)   {}
    public ReturnRptData (Warning e)        : base(e)   {}
    public ReturnRptData (Critical e)       : base(e)   {}
    public ReturnRptData (SessionExpired e) : base(e)   {}
    
    public int numRows;
    public int numCols;

    public SQLStatement        sqlstatement;
    public List<TitleOrFooter> resultSetTitles;    
    public List<TitleOrFooter> resultSetFooters;    
    
    public DataTree         datatree;
    public int              output_orientation;
    public string           title;
    public string           filename;
   	
   	/***************************************************************************
     * CreateTitle */
    /**
     * Generates a combined title string from all of the report titles
     ***************************************************************************/   

    public static string CreateTitle(ref ReturnRptData rd)
    {
      /*-------------------------------
       * Create a title string suitable
       * for a file name or document
       * title.
       *------------------------------*/ 

      StringBuilder title = new StringBuilder();
            
      foreach (TitleOrFooter ttl in rd.resultSetTitles)
      {
        if (!Util.IsNullOrEmpty(ttl.name))
        {
		      title.Append(ttl.name.Trim());
		      title.Append(" - ");
		    }
      }
      string title2 = title.ToString();
      string title3 = title2.Remove(title2.LastIndexOf('-'));      

      return title3.Trim();
    
    }
    
    /***************************************************************************
     * CreateFileName */
    /**
     * Generates a file name using the report titles and strips any path unfriendly
     * characters out of the string.  Also if the report titles contain any titles
     * that contain parameter dates, the dates will be converted from mm/dd/yyyy
     * strings to yyyy/mm/dd strings.  This will create a more sort friendly 
     * filename;
     ***************************************************************************/   
 	  
 	  public static string CreateFileName (ref ReturnRptData rd)
 	  { 	    
 	    StringBuilder name = new StringBuilder();
 	    
 	    foreach (TitleOrFooter ttl in rd.resultSetTitles)
      {
        /*-------------------------------
         * If the title is defined
         *------------------------------*/ 
        
        if (!Util.IsNullOrEmpty(ttl.name))
		    {
		      string namepart;
		      
		      /*-------------------------------
           * If the title indicates that
           * it might contain parameter
           * dates 
           * 
           * (dates in the form mm/dd/yyyy)
           *------------------------------*/ 

		      if (ttl.hasAttribute(TitleOrFooterAttribute.Contains_Parameter_Dates))
		      {
		        
		        string newnamepart = ttl.name;
		        
		        /*-------------------------------
             * If the title actually contains
             * parameter dates
             *------------------------------*/ 

		        MatchCollection dates = PatternMatch.REGEX_MM_DD_YYYY.Matches(ttl.name);
		        
		        /*-------------------------------
             * Locate and replace each date
             * in the form mm/dd/yyyy
             * with a date in the form
             * yyyy/mm/dd
             *------------------------------*/ 

		        foreach (Match olddate in dates)
		        {
		          DateTime value = DateTime.Parse(olddate.Value);
		          string newdate = Util.dateTimeToShortDate(value,FormatStrings.DATETIME_YYYY_MM_DD);
		          newnamepart    = newnamepart.Replace(olddate.Value, newdate);
		        }
		        
		        namepart = newnamepart;  
		      
		      }
		      
		      /*-------------------------------
           * Otherwise just use the title as
           * is
           *------------------------------*/ 
		      
		      else
		      {
		        namepart = ttl.name;
		      }
		      
		      name.Append(namepart);
		      name.Append(" ");
		    }  
		  }
		  
		  /*-------------------------------
       * Generate title from string
       * builder and trim excess
       * white space
       *------------------------------*/ 
		  
		  string filename = name.ToString().Trim();		  
		  
		  /*-------------------------------
       * Remove any web unfriendly
       * characters and return
       *------------------------------*/ 
		  
		  return Util.webSafeString(filename);
    }

      public Byte[] DataToPDF()
      {
          ReturnRptData refthis = this;
          return PDF.ReturnRptDataToPDF(ref refthis);
      }

      public Byte[] DataToXLS()
      {
          ReturnRptData refthis = this;
          return Excel2.returnRptDataToFile(ref refthis);          
      }

      public Byte[] DataToHTML()
      {
          ReturnRptData refthis = this;
          return HTML.ReturnRptDataToHTML(ref refthis);
      }

      public string GenerateFileName(string ext)
      {
          return File.GenerateFileName("", this.filename, ext);
      }

      public new int status { get { return base.status; } }

      public new string message { get { return base.message;  } }
  	  
  }  
}
