using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;


namespace MBA
{
  public class Parse
  {
  
  /***************************************************************************
   * multiInt */
  /**
   * Parses a multiInt.
   * 
   * @param    intsIn          One or more integers seperated by commas
   * @param    msg             Invalid integer message
   * @return   int[]
    ***************************************************************************/
  
  public static int[] multiInt (string ints, string msg)
  {
     List<int>  intsInVal  = new List<int>();
     int        numInts    = 1;

     /*-------------------------------
      * Parse incoming csv int string
      *------------------------------*/ 

     string   intsIn     = Validate.reqString(ints, msg);
     string[] intsInStr  = csvSearchTerm(intsIn);
     
     /*-------------------------------
      * Go through each int string
      * and convert to a int
      * value.  Exit if there are 
      * issues.
      *------------------------------*/ 

     foreach (string intInStr in intsInStr)
     {
       string message = msg + " (" + numInts.ToString() + ")";
       int intInVal = Validate.reqInteger(intInStr, message);
       intsInVal.Add(intInVal);
       numInts++;
     }

     int[] intsOut = intsInVal.ToArray();
     return intsOut;
  
  }
  
  /***************************************************************************
   * createMultiInt */
  /**
   * Creates a multi int string
   * 
   * Courtesey of http://stackoverflow.com/a/145864
   * 
   * @param    values          Int array containing values
   * @return   string
    ***************************************************************************/
    
  public static String createMultiInt (int[] values)
  {    
    return String.Join(",", values.Select(x => x.ToString()).ToArray());
  }
  
  /***************************************************************************
   * multiDate */
  /**
   * Parses a multidate.
   * 
   * @param    datesIn         One or more dates seperated by commas
   * @param    validateOption  Date validation option
   * @param    convertOption   Date convert option
   * @return   DateTime[]
    ***************************************************************************/
   
   public static DateTime[] multiDate (string dates, int validateOption, int convertOption, string msg)
   {
   
     List<DateTime>  datesInVal  = new List<DateTime>();
     int             numDates    = 1;

     /*-------------------------------
      * Parse incoming csv date string
      *------------------------------*/ 

     string datesIn      = Validate.reqString(dates, msg);
     string[] datesInStr = csvSearchTerm(datesIn);
     
     /*-------------------------------
      * Go through each date string
      * and convert to a datetime
      * value.  Exit if there are 
      * issues.
      *------------------------------*/ 

     foreach (string dateInStr in datesInStr)
     {
       string message = msg + " (" + numDates.ToString() + ")";
       DateTime dateInVal = Validate.reqDate(dateInStr, message, validateOption, convertOption);
       datesInVal.Add(dateInVal);
       numDates++;
     }

     DateTime[] datesOut = datesInVal.ToArray();
     return datesOut;
   }

    
   /***************************************************************************
    * searchTerm */
    /**
    * Parses a search term
    * 
    * @param  term            Search term
    * @return                 Parsed results or null
    ***************************************************************************/

    public static ParseResults searchTerm (string term, bool trimParts, params string[] delimeters)
    {

      /*-------------------------------
       * Preload output class with
       * search term and check for
       * empty search term.  If the
       * search term is empty get out
       *------------------------------*/ 
      
      ParseResults so = new ParseResults();
      so.numDelms = 0;
      so.numParts = 0;
      so.term     = term;
      so.hasParts = !Util.IsNullOrEmpty(term);
      if (!so.hasParts) return so;
      
     /*-------------------------------
       * If just whitespace is passed
       * in, we treat this as an empty
       * search term and we want to exit
       *------------------------------*/ 

      string vTerm = term.Trim();
      if (vTerm.Length == 0)
      {
        so.hasParts = false;
        return so;
      }
      
      /*-------------------------------
       * Check for passed in delimiters
       * If there are none use defaults
       *------------------------------*/ 
      
      string[] delm;
      if (delimeters.Length == 0) delm = new String[]{",",@"\","/","-"," "}; else delm = delimeters;

      /*-------------------------------
       * Load the delimiters that are 
       * found into the output class
       * and count # of instances.  Also
       * indicate if multiple delimiters
       * were found.  For example if 
       * we are using the default
       * delimiters, the term 
       * hello, world has (2)delimiters 
       * the comma and space.
       *------------------------------*/
      
      int numDel = delm.Length;
      so.delimiters = new Delimiter[numDel];
      so.hasDelms = false;
      so.hasMultiDelms = false;
      
      List<Delimiter> dl = new List<Delimiter>();

      for (int i=0;i<numDel;i++)
      {
        int c = Util.countTerms(vTerm, delm[i]);
        if (c >0)
        {
          Delimiter d = new Delimiter();
          d.delimiter = delm[i];
          d.count = c;
          dl.Add(d);
          if (so.hasDelms) so.hasMultiDelms = true;
          so.hasDelms = true;
        }
      }
      
      so.delimiters = dl.ToArray();
      so.numDelms   = so.delimiters.Length;

      /*-------------------------------
       * Split search term into parts.
       * Each delimiter is treated as
       * the end position for a part
       *------------------------------*/ 
      
      so.parts = vTerm.Split(delm,StringSplitOptions.None);
      so.numParts = so.parts.Length;

      if (trimParts)
      {
        for (int i=0;i<so.numParts;i++)
        {
          so.parts[i] = so.parts[i].Trim();
        }
      }
      
      /*-------------------------------
       * Return results
       *------------------------------*/

      return so; 
    }
  
    /***************************************************************************
    * csvSearchTerm */
    /**
    * Parses a comma seperated search term and removes whitespace from parts.
    * For example hello  ,   world (spaces intentional) would be parsed into
    * [hello,world]
    * 
    * @param  term            Search term
    * @return                 Parsed results or null
    ***************************************************************************/
    
    public static string[] csvSearchTerm (string term)
    {
      ParseResults pr = searchTerm(term,true,",");
      return pr.parts;
    }

   /***************************************************************************
    * searchTermToLastFirstOther */
    /**
    * Parses a comma seperated search term and returns values.
    * 
    * @param  term            Search term in form (last, first, other)
    * @return last            Last name (assumed to be the first part)
    * @return first           First name (assummed to be in the middle)
    * @return other           Other field (ie date of birth, assumed to be last)
    ***************************************************************************/
    
    public static void searchTermToLastFirstOther(string term, out string last, out string first, out string other)
    {
      
     /*-------------------------------
      * Setup default return values
      *------------------------------*/
      
      last  = "";
      first = "";
      other = "";

     /*-------------------------------
      * Parse search term
      *------------------------------*/

      string[] parts = csvSearchTerm(term);
      
     /*-------------------------------
      * If nothing comes back get out
      *------------------------------*/

      if (parts == null) return;

     /*-------------------------------
      * If we get results extract
      * last, first, and other
      *------------------------------*/

      if (parts.Length == 0)
        // Just spaces passed
        return;
      else if (parts.Length == 1)
        // Last name
        last = parts[0];
      else if (parts.Length == 2)
      {
        // Last name and first name
        last = parts[0];
        first = parts[1];
      }
      else if (parts.Length > 2)
      {
        // Last name, first name, and other
        last = parts[0];
        first = parts[1];
        other = parts[2];
      }
      
      return;
    
    }

   /***************************************************************************
    * searchTermToIDOrLastFirstDate */
    /**
    * Parses a comma seperated search term and returns values.
    * 
    * @param  term            Search term in form id or last, first, date 
    * @return id              ID (ie studentid.  Assummed to be the first part if not all letters)
    * @return last            Last name (assumed to be the first part)
    * @return first           First name (assummed to be in the middle)
    * @return date            Date field (ie date of birth, assumed to be last)
    ***************************************************************************/
    
    public static void searchTermToIDOrLastFirstDate (      string term
                                                      , out string id
                                                      , out string last
                                                      , out string first
                                                      , out string date)
    {
      
     /*-------------------------------
      * Setup default return values
      *------------------------------*/
      
      id    = "";
      last  = "";
      first = "";
      date  = "";

     /*-------------------------------
      * Parse search term
      *------------------------------*/

      string[] parts = csvSearchTerm(term);
      
     /*-------------------------------
      * If nothing comes back get out
      *------------------------------*/

      if (parts == null) return;

     /*-------------------------------
      * If we get results extract
      * last, first, and other
      *------------------------------*/

      if (parts.Length == 0) { 
        // Just spaces passed
        return;
      }
      else if (parts.Length == 1) {         
        if (Util.valueHasNumbers(parts[0]) == true) {
          id = parts[0];
        } 
        else {         
          last = parts[0];
        }
      }
      else if (parts.Length == 2) {
        // Last name and first name
        last = parts[0];
        first = parts[1];
      }
      else if (parts.Length > 2) {
        // Last name, first name, and other
        last  = parts[0];
        first = parts[1];
        date  = parts[2];
      }
      
      return;
    
    }
  }
  
  public class Delimiter
  {
    public string delimiter;
    public int    count;
  }

  public class ParseResults
  {
    public   string      term;
    public   bool        hasParts;
    public   bool        hasDelms;
    public   bool        hasMultiDelms;
    public   int         numParts;
    public   int         numDelms;
    public   string[]    parts;
    public   Delimiter[] delimiters;
  }

}
