using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using System.IO.Compression;
using System.Globalization;
using System.Threading;
using System.Web;
using System.Drawing;
using System.Net.Mail;

namespace MBA
{
  /***************************************************************************
   * Util */
  /**
   * Contains a collection of various commonly used utility functions.
   ***************************************************************************/   

  public class Util
  {
  
  /***************************************************************************
   * zeroOrNullToEmptyStrOrValueStr
  /**
   * If value is null or 0 returns an empty string.  Otherwise returns
   * string rep of value.   
   ***************************************************************************/   

  public static string zeroOrNullToEmptyStrOrValueStr (long? value)
  {
    if (!value.HasValue) return String.Empty;
    if (value.Value == 0) return String.Empty;
    return value.Value.ToString();
  }

  /***************************************************************************
   * getLengthOfBase64StringInBytes
  /**
   * Get number of encoded bytes 
   * Courtesy of :
   * https://blog.aaronlenoir.com/2017/11/10/get-original-length-from-base-64-string/
   ***************************************************************************/   

  public static int base64GetLengthInBytes (string base64string)
  {
    /*
     * Base64 encodes three bytes to four characters. 
     * Sometimes, padding is added in the form of one or two '=' characters.
     * To get the length of bytes we use the formula:
     * (3 * (LengthInCharacters / 4)) - (numberOfPaddingCharacters)
     *
     */

    if (String.IsNullOrWhiteSpace(base64string)) { return 0; }

    var characterCount = base64string.Length;
    var paddingCount = base64string.Substring(characterCount - 2, 2)
                                   .Count(c => c == '=');
    return (3 * (characterCount / 4)) - paddingCount;
 

  }

  /***************************************************************************
   * base64ImageToImage
  /**
   * Converts image in base64 to a generic image 
   * Note: Assume base64 image data is valid.
   ***************************************************************************/   

  public static Image base64ImageToImage (string base64ImageDataIn)
  {
    var bytes = Convert.FromBase64String(base64ImageDataIn);     
    using (var ms = new MemoryStream(bytes)) { 
       return Image.FromStream(ms);
    }
  }

  /***************************************************************************
   * imageToPngData
  /**
   * Converts image to png (data returned as byte array)
   *
   * Note: Take an intermediate step of converting image to bitmap and then saving
   * the bitmap itself to png.  This intermediate step is neccessary to avoid
   * a GDI+ error.  See https://stackoverflow.com/a/10174671 for discussion
   * on this.
   ***************************************************************************/   
  public static byte[] imageToPngData (Image img)
  {
    using (var ms = new MemoryStream()) { 
      Bitmap bm = new Bitmap(img);   /* Very important to avoid GDI+ error */
      bm.Save(ms,System.Drawing.Imaging.ImageFormat.Png);
      return ms.ToArray();      
    }
  }     
  
  /***************************************************************************
   * base64ImageToBase64PngImage
  /**
   * Converts image data into png formatted image
   *
   ***************************************************************************/   
  public static string base64ImageToBase64PngImage (string base64ImageDataIn, int? maxSizeInBytes)
  {
    if (maxSizeInBytes.HasValue) { 
      int numBytes = base64GetLengthInBytes(base64ImageDataIn);
      if (numBytes > maxSizeInBytes.Value) throw new Critical("Image is too large");
    }
    var img = base64ImageToImage(base64ImageDataIn);
    var bytes = imageToPngData(img);
    return Convert.ToBase64String(bytes);    
  }     

  
  /***************************************************************************
   * isTodayAnAnniversary
  /**
   * Returns true if month and day equal current dates month and day
   ***************************************************************************/   
  public static bool isTodayAnAnniversary (int month, int day)
  {
     var currentDate = DateTime.Today;
     if ((currentDate.Month == month) && (currentDate.Day == day)) return true;
     return false;
  }

  /***************************************************************************
   * removeAllControlChars
  /**
   * Based on function by Yannick Blondeau https://stackoverflow.com/a/15259355
   ***************************************************************************/   
  
  public static string removeAllControlChars (string value)
  {
    if (String.IsNullOrWhiteSpace(value)) return value;
    string valueOut = new string(value.Where(cx => !Char.IsControl(cx)).ToArray());
            
    return valueOut;
  }
  /***************************************************************************
   * removeScriptTags
  /**
   * For sanitizing inputs
   ***************************************************************************/   

  public static string removeScriptTags (string value)
  {
     value = Regex.Replace(value,@"<script>",    "", RegexOptions.IgnoreCase);
     value = Regex.Replace(value,@"<\/script>",  "", RegexOptions.IgnoreCase);
     value = Regex.Replace(value,@"<script",     "", RegexOptions.IgnoreCase);
     return value; 
 }

  /***************************************************************************
   * removeAllNonASCIIChars
  /**
   * Based on function by bzlm https://stackoverflow.com/a/135473
   ***************************************************************************/   

  public static string removeAllNonASCIIChars (string value)
  {
    if (String.IsNullOrWhiteSpace(value)) return value;
    var valueBytes = Encoding.UTF8.GetBytes(value);
    var valueOutBytes = Encoding.Convert (
          Encoding.UTF8
        , Encoding.GetEncoding(Encoding.ASCII.EncodingName, new EncoderReplacementFallback(string.Empty), new DecoderExceptionFallback())
        , valueBytes);
    string valueOut = Encoding.ASCII.GetString (valueOutBytes);      
    return valueOut;
  }

  /***************************************************************************
   * removeAllControlAndNonASCIIChars
  /**
   * 
   ***************************************************************************/   
        
  public static string removeAllControlAndNonASCIIChars (string value)
  {
     if (String.IsNullOrWhiteSpace(value)) return value;
     string tempVal1 = removeAllControlChars(value);
     string tempVal2 = removeAllNonASCIIChars(tempVal1);
     return tempVal2;     
  }

  /***************************************************************************
   * addQuotesToPathIfRequired */
  /**
   * Courtesey of https://stackoverflow.com/a/34033925
   ***************************************************************************/   
  
  public static string addQuotesToPathIfRequired (string path)
  {
      return (!String.IsNullOrWhiteSpace(path)) ? 
          path.Contains(" ") && (!path.StartsWith("\"") && !path.EndsWith("\"")) ? 
              "\"" + path + "\"" : path : 
              string.Empty;
  }
  
  /***************************************************************************
   * timeSpanToShortTimeString */
  /**
   ***************************************************************************/   
  public static string timeSpanToShortTimeString(TimeSpan value)
  {
     return new DateTime(value.Ticks).ToShortTimeString();
  }  

  /***************************************************************************
   * jsonStringReplaceAllNonStringValuesWithStringValues */
  /**
   ***************************************************************************/   
  public static string jsonStringReplaceAllNonStringValuesWithStringValues (string jsonIn)
  {
    var jsonOut = jsonIn.Replace(  @":null", @":""""");
    jsonOut = Regex.Replace(jsonOut,@":(\d+)",@":""$1""");
    return jsonOut;
  }
    
  /***************************************************************************
     * isIpAddressInTrustedLocalIPs */
    /**
     ***************************************************************************/   
  
    public static bool isIpAddressIsInTrustedLocalIPs (string ipaddress)
    {
      if (String.IsNullOrEmpty(ipaddress)) return false;    
      foreach (string ip in Constants.TRUSTED_LOCAL_IPS)
      {
        if (ipaddress == ip) return true;
      }
      return false;
    }
    
    /***************************************************************************
      * IntegerValueIsBetween */
    /**
     ***************************************************************************/   

    public static bool IntegerValueIsBetween (long value, long minValue, long maxValue)
    {
      return ( value >= minValue && value <= maxValue );
    }

    /***************************************************************************
     * _validateRefStartAndEndDates */
    /**
     ***************************************************************************/   

    private static void _validateRefStartAndEndDates (DateTime refDate, DateTime startDate, DateTime endDate)
    {
      if (refDate   == null)   throw ( new ArgumentException("refDate required"));
      if (startDate == null)   throw ( new ArgumentException("startDate required"));
      if (endDate   == null)   throw ( new ArgumentException("endDate required"));
      if (startDate > endDate) throw ( new ArgumentException("startDate cannot be greater than endDate"));
    }

    /***************************************************************************
     * isBeforeStartAndEndDate */
    /**
     ***************************************************************************/   

    public static bool isBeforeStartAndEndDate (DateTime refDate, DateTime startDate, DateTime endDate) 
    {
      _validateRefStartAndEndDates (refDate, startDate, endDate);
      return ((refDate < startDate) && (refDate < endDate));
    }

    /***************************************************************************
     * isBetweenStartAndEndDate */
    /**
     ***************************************************************************/   
    
    public static bool isBetweenStartAndEndDate (DateTime refDate, DateTime startDate, DateTime endDate)
    {
      _validateRefStartAndEndDates (refDate, startDate, endDate);
      return ((refDate >= startDate) && (refDate <= endDate));
    }

    /***************************************************************************
     * isAfterStartAndEndDate */
    /**
     ***************************************************************************/   
    
    public static bool isAfterStartAndEndDate (DateTime refDate, DateTime startDate, DateTime endDate) 
    {
      _validateRefStartAndEndDates (refDate, startDate, endDate);
      return ((refDate > startDate) && (refDate > endDate));    
    }
    
    /***************************************************************************
     * createContentDispositionFileName */
    /**
     ***************************************************************************/   
    
    public static string createContentDispositionFileName (string label)
    {
     /* Wrap in double quotes to handle white space */
     string _fn = @"""" + label + @"""";
     return _fn;
    }
    
    /***************************************************************************
     * getFileContentLength */
    /**
     ***************************************************************************/   
    
    public static long? getFileContentLength (string fullPathFile) {
    
      long _filelen = 0;

      if (System.IO.File.Exists(fullPathFile)) {
        using (var sr = System.IO.File.OpenRead(fullPathFile)) {
          _filelen = sr.Length;
          sr.Close();
        }
      }
      else {
        return null;
      }
      return _filelen;
    }
    
    /***************************************************************************
     * IsGzipSupported */
    /**
     * Determine if client supports gzip.  This is used for our response
     * compression.  This is a slightly modifed version of Rich Strahl's 
     * solution found on http://www.west-wind.com/Weblog/posts/10294.aspx
     * 
     * @return true if yes
     ***************************************************************************/   
    
    public static bool IsGZipSupported (ref HttpContext context)
    {
      string AcceptEncoding = context.Request.Headers["Accept-Encoding"];

      if (!String.IsNullOrEmpty(AcceptEncoding))
      {
        if (AcceptEncoding.Contains("gzip") || AcceptEncoding.Contains("deflate"))
        {
          return true;
        }
      }
      return false;
    } 

    /***************************************************************************
     * GZipEncodeResponse */
    /**
     * If the client supports gzip compression and the COMPRESS_RESPONSES rule
     * is set to true, gzip compress our response.  This call needs
     * to be placed right before any response data is generated.
     * To accomplish this in our framework this has been placed in callMethod()
     *
     * Please note:
     * 
     * This only compresses DYNAMIC content from your application (ie anything
     * that goes through ASP.NET).  Static content such as HTML, images, CSS,
     * Javascript, SWF files, etc are not compressed by this.  These resources
     * COULD be compressed at the web server level though if the web server
     * supports compression or through the use of a custom handler (coupled with
     * modified src, href tags) to run all static content through ASP.NET. 
     * 
     * This is a slightly modifed version of Rich Strahl's solution found on
     * http://www.west-wind.com/Weblog/posts/10294.aspx
     ***************************************************************************/     
  
    public static void GZipEncodeResponse (ref HttpContext context)
    {
      
      if (IsGZipSupported(ref context))
      {
        string AcceptEncoding = context.Request.Headers["Accept-Encoding"];
        
        if (AcceptEncoding.Contains("deflate"))
        {
          context.Response.Filter = new DeflateStream (context.Response.Filter, CompressionMode.Compress);
          context.Response.AppendHeader("Content-Encoding", "deflate");
        }
        else
        {
          context.Response.Filter = new GZipStream (context.Response.Filter, CompressionMode.Compress);
          context.Response.AppendHeader("Content-Encoding", "gzip");                    
        }
     }

     // Allow proxy servers to cache encoded and unencoded versions separately

     context.Response.AppendHeader("Vary", "Content-Encoding");
    
    }
    
    /***************************************************************************
     * getValueFromDictionary */
    /**
     * Gets value
     ***************************************************************************/   

    public static string getValueFromDictionary (string key, ref Dictionary<String,String> dict)
    {
      string value = @"";
      if (dict.ContainsKey(key)) value = dict[key];
      return value;
    }
    
    /***************************************************************************
     * calculateAge */
    /**
     * Calculates an age based on date of birth and date of reference
     * Based on a snipet of code from http://snippets.dzone.com/posts/show/1632
     * 
     * @param   dob   date of birth
     * @param   dor   date of reference
     * @return  age
     ***************************************************************************/   

    public static int calculateAge(DateTime dob, DateTime dor)
    {

      int years = dor.Year - dob.Year;
      // subtract another year if we're before the birth day in the reference year
      if (dor.Month < dob.Month || (dor.Month == dob.Month && dor.Day < dor.Day))
          years--;
      return years;
    }

    /***************************************************************************
     * createBasicStandAloneHTMLDocString  */
    /**
     *
     ****************************************************************************/   

    public static string createBasicStandAloneHTMLDocString (string title, string style, string content) {
    
      StringBuilder sb = new StringBuilder();
      
      if (String.IsNullOrEmpty(title))   title = @"";
      if (String.IsNullOrEmpty(style))   style = @"";
      if (String.IsNullOrEmpty(content)) content = @"";
      
      sb.Append (@"<!doctype html>");
      sb.Append (@"<html lang=""en"">");
      sb.Append (@"<head>");
      sb.Append (@"<meta charset=""utf-8""/>");
      sb.Append (@"<meta name=""viewport"" content=""width=device-width, initial-scale=1""/>");
      sb.Append (@"<title>");
      sb.Append (title);
      sb.Append (@"</title>");
      sb.Append (@"<style>");
      sb.Append (style);
      sb.Append (@"</style>");
	    sb.Append (@"</head>");	  
	    sb.Append (@"<body>");
      sb.Append (content);
	    sb.Append (@"</body>");
	    sb.Append (@"</html>");
      
      return sb.ToString();
      
    }
   
    /***************************************************************************
     * CreateLink 
    /**
     * Creates and returns a link
     * 
     * @param    url      Base url
     * @param    parms    Name/Value pairs of parameters
     * @return   string           
     ***************************************************************************/   
    
    public static string createLink(string url, params NameValue[] parms)
    {
       
      string p = @"";
      
      if (parms != null)
      {
        if (parms.Length > 0)
        {
          p = @"?" + parms[0].name + @"=" +   HttpUtility.UrlEncode(parms[0].value.ToString());
          for (int i=1;i<parms.Length;i++)
          {
            p = p + "&" + parms[i].name + @"=" +   HttpUtility.UrlEncode(parms[i].value.ToString());
          }
        }
      }
      return url + p;
    }

    /***************************************************************************
     * appendParmToLink
    /**
     * Appends a new name,value to an link
     * 
     * @param    url      Base url
     * @parm     name     Name
     * @param    value    Value
     * @param    urlHasExistingParms (true or false) url has params in query string
     * @return   string           
     ***************************************************************************/   

    public static string appendParmToLink (string url, string name, string value, bool urlHasExistingParms)
    {
      return url 
             + ((urlHasExistingParms == true) ? "&" : "?")
             + name 
             + @"=" 
             +  HttpUtility.UrlEncode(value);
    }
    
    /***************************************************************************
     * createUniqueID
    /**
     * Creates and returns a string containing a unique id
     * 
     * @param    base    String to prepend to unique id
     * @return   string  Unique id
     ***************************************************************************/   
    
    public static string createUniqueID ()
	  {
	    return createUniqueID("");
	  }
		
	  public static string createUniqueID (string idbase)
    {      	    
		  /*------------------------------
       * Generate a new guid
       *------------------------------*/ 
		  
		  Guid g;
	    g = Guid.NewGuid();			    

		  /*------------------------------
       * Append its hex value only
       * (hex without hyphens) 
       * string representation to
       * our base
       *------------------------------*/ 
       		  
      string s = idbase + g.ToString("N");
		  return s;
    }
        
    /***************************************************************************
     * createFormFieldIdOrName
    /**
     * Creates and returns a string containing args seperated by seperator
     * 
     ***************************************************************************/   

    public static string createFormFieldIdOrName (params string[] args)
    {
      return createFormFieldIdOrName(@"_",args);
    }
    
    public static string createFormFieldIdOrName (string seperator, params string[] args)
    {
      StringBuilder sb = new StringBuilder();
      foreach (string arg in args)
      {
        if (!IsNullOrEmpty(arg))
        {
          sb.AppendFormat(@"{0}{1}",seperator,arg);
        }
      }
      return sb.ToString();
    }
               
    /***************************************************************************
     * createMessageString
    /**
     * Creates and returns a string from the given pattern
     * 
     * @param    stringPattern    String pattern to use.  Placeholders are denoted
     *                            by braces and integers {0} {1} {2} .. {n}
     * @param    p                Values to substitute for placeholders.
     *                            p[0] will replace {0}, p[1] will replace {1}, etc.
     *                            
     * @return   string           The new message
     ***************************************************************************/   

    public static string createMessageString (string stringPattern, params string[] p)
    {
      string msg = "";
     
      /*------------------------------
       * If there is no pattern
       * return an empty string
       *------------------------------*/ 

      if (Util.IsNullOrEmpty(stringPattern)) return msg;

      /*------------------------------
       * If there are no values to
       * substitute return an empty
       * string
       *------------------------------*/ 
      
      if (p == null)                         return msg;
      if (p.Length == 0)                     return msg;
      
      /*------------------------------
       * Check format of string pattern
       *------------------------------*/
 
      for (int i=0;i < p.Length;i++)
      {
        string ph = @"{" + i.ToString() + "}";
        if (!stringPattern.Contains(ph)) throw new Warning(@"Missing placeholder");
      }

      /*------------------------------
       * Create new string and return
       *------------------------------*/
 
      msg = String.Format(stringPattern, p);      
      return msg;

    }

    /***************************************************************************
     * evaluateFlag
    /**
     * Evaluates value to see if its a valid flag and returns true, false, or null
     * 
     * @param    value               Value to evaluate
     * @param    nullOrBlankIsFalse  Indicates nulls or blanks are treated as false
     *                               values
     * @return   ?bool               True, false, or null
     ***************************************************************************/   

    public static bool? evaluateFlag (Object value, bool nullOrBlankIsFalse)
    {
      /*-------------------------------
       * If value is null and we are
       * treating nulls or blanks as
       * false, return false.
       *------------------------------*/  

      if ((value == null) && (nullOrBlankIsFalse))
        return false;
    
      /*-------------------------------
       * Otherwise evaluate value
       * if value exists
       *------------------------------*/  

      if (value != null)
      {                     
        
        /*-------------------------------
         * Convert it to a string
         *------------------------------*/  

        string val = Convert.ToString(value);
        
        /*-------------------------------
         * If we are treating nulls or 
         * blanks as false, check to see
         * if the string is null or blank
         * and return false if it is.
         *------------------------------*/  

        if ((Util.IsNullOrEmpty(val)) && (nullOrBlankIsFalse))
          return false;

        /*-------------------------------
         * Lowercase and trim string
         * to make evaluation easier
         *------------------------------*/  
        
        val = val.ToLower().Trim();
     
        /*-------------------------------
         * Evaluate it by comparing it
         * to common expressions of a 
         * boolean state and return the
         * result.
         *------------------------------*/  

        switch (val) {
      
          case "y":        { return true;  }
          case "n":        { return false; }
          case "1":        { return true;  }
          case "0":        { return false; }
          case "t":        { return true;  }
          case "f":        { return false; }
          case "yes":      { return true;  }
          case "no":       { return false; }
          case "true":     { return true;  }
          case "false":    { return false; }
          case "on":       { return true;  }
          case "off":      { return false; }
          case "active":   { return true;  }
          case "inactive": { return false; } 
          case "x":        { return true;  } /* Note: opposite of x is blank which is taken care of by null or blank */          
          default:         { return null;  }
        }
      }
    
      /*-------------------------------
       * Value does not exist, exit
       *------------------------------*/
     
      else
      {  
        return null;
      }
    }

    /***************************************************************************
     * maxIntInBits
    /**
     * Computes the maximum integer value for a given number of bits.
     * For example numbits = 3 would result in 2^0 + 2^1 + 2^2 = 7
     * 
     * @param    numbits        Number of bits in binary number
     * @return   int
     ***************************************************************************/ 
    
   	 public static int maxIntInBits (int numbits)
     {
       double max = 0;
		   
		   /*-------------------------------
        * If the number of bits is > 1 
        * we can compute the max value
        * that can be encoded in binary
        *------------------------------*/
		   
		   if (numbits > 0)
	     {
			   for (int exp=0; exp < numbits; exp++)
         {
         
          /*-------------------------------
           * We compute the max value
           * by assuming all of the bits are
           * 1 and then we convert the bits
           * to an integer.
           * 
           * Note: C# does not have a power
           * operator and ^ is used for XOR
           * so we have to use the Math.Pow
           * function.
           *------------------------------*/
			     
			     double val = Math.Pow(2,exp);	
           max = max + val;
         }
		   }
       
       /*-------------------------------
        * Otherwise return a 0
        *------------------------------*/
       
       else
       {
         max = 0;
       }

       return Convert.ToInt32(max);
     }
    
    /***************************************************************************
     * intToBinaryString
    /**
     * Converts value to a string representing the binary value of value
     * For example a value of 8 would return 1000
     * 
     * @param    value          Base 10 value to convert to base 2
     * @param    numbits        Number of bits in binary number
     * @param    allowNegative  True : Negative numbers allowed
     *                          False: >= 0 only
     * @return           String
     ***************************************************************************/ 
    
    public static string intToBinaryString (int value)
    {
      return intToBinaryString(value, 32, true);
    }
    
    public static string intToBinaryString (int value, int numbits, bool allowNegative)
    {
      // Courtesey of Anthony Pegram
      // http://stackoverflow.com/questions/2954962/decimal-to-binary-conversion-in-c/2955001#2955001

      if (!allowNegative)
        if (value < 0)        
          return null;
      
      if (numbits <=0)
        return null;

      string binary = Convert.ToString(value, 2);  
      return binary.PadLeft(numbits,'0');
    }

    /***************************************************************************
     * countCharsInValue
    /**
     * Counts the number of c in value
     * 
     * @param    value    String to evaluate
     * @param    c        Characters to find
     * @return            Number of characters found
     ***************************************************************************/ 

    public static int countCharsInValue (string value, char c)
    {
      if (IsNullOrEmpty(value))
        return 0;

      int ctr = 0;
      
      char[] valueArr = value.ToCharArray();
      
      foreach (char vc in valueArr)
        if (vc == c) ctr++;      
      
      return ctr;
    
    }
    
    /***************************************************************************
     * findIndexOfCharInValue
    /**
     * Finds all of the indexes of c in value
     * 
     * @param    value    String to evaluate
     * @param    c        Characters to find
     * @return            indexes
     ***************************************************************************/ 
    
    public static int[] findIndexesOfCharInValue (string value, char c)
    {
      if (IsNullOrEmpty(value))
        return null;
     
      List<int> positions = new List<int>();

      int searchpos       = 0;
      int indexof         = 0;
      int maxsearchpos    = value.Length - 1;

      while (indexof != -1)
      {
        indexof = value.IndexOf(c,searchpos);
        
        /* If we found an index */

        if (indexof != -1)
        {
          /* Add it */

          positions.Add(indexof);

          /* Advance search to look at characters just past index of last one found */
          
          searchpos = indexof + 1;
        
          /* If new search position exceeds length, we are done */
          
          if (searchpos > maxsearchpos)
            indexof = -1;
        }
      }
      return positions.ToArray();
    }


    /***************************************************************************
     * isValidURL
    /**
     * Tests url to see if it is valid.
     * 
     * @param    url     url to test
     * @return           true = url is valid, false= url is not
     ***************************************************************************/   
    
    public static bool isValidURL (string url)
    {
      /*------------------------------
       * If a blank or null url is 
       * passed its not valid
       *------------------------------*/
      
      if (Util.IsNullOrEmpty(url)) return false;
      
      /*------------------------------
       * Test URL using Uri methods
       *------------------------------*/

      if (!Uri.IsWellFormedUriString(Uri.EscapeUriString(url),UriKind.RelativeOrAbsolute)) return false;      
  
      return true;
    }

    /***************************************************************************
     * removeParameterFromURL
    /**
     * Removes param from the query string of the given url and returns the
     * modified url.
     * 
     * @param    url     url to strip parameter from
     * @param    parm    parameter to strip
     * @return   string  url sans parameter
     ***************************************************************************/   

    public static string removeParameterFromURL (string url, string parm)
    {
     
      /*------------------------------
       * Test url to make sure its 
       * valid and if so proceed
       *------------------------------*/
      
      if (!isValidURL (url)) throw new Warning (@"URL is invalid");      
      string newurl = url;

      /*------------------------------
       * If parm is not defined we
       * have nothing to remove
       * so just return the url
       *------------------------------*/
      
      if (Util.IsNullOrEmpty(parm)) return newurl;

      /*------------------------------
       * If the paramter contains 
       * characters that would 
       * intefere with replacing it
       * throw a warning and exit.
       *------------------------------*/

      if (parm.Contains(@"?") || parm.Contains(@"&") || parm.Contains(@"=")) throw new Warning(@"Parameter is invalid");

      /*------------------------------
       * Build our search pattern
       *------------------------------*/

      string ptrn = @"[?,&]" + parm + @"=[^&]{1,}";

      /*------------------------------
       * Search and replace 
       * if applicable
       *------------------------------*/

      if (Regex.IsMatch(url,ptrn))
        newurl = Regex.Replace(url,ptrn,@"");
      else
        newurl = url;

      return newurl;

    }
    
    /***************************************************************************
     * generateStartOfCurrentFiscalYearDefaultValue
    /**
     * Generates a short date string value containing the start of the current
     * fiscal year using our default settings for that
     ***************************************************************************/   

    public static string generateStartOfCurrentFiscalYearDefaultValue()
    {
       DateTime startDate;
       DateTime endDate;
       MBA.Dates.ComputeFiscalYear (DateTime.Today,out startDate,out endDate);
       return startDate.ToShortDateString();
    }
    
    /***************************************************************************
     * dateStart
    /**
     * Computes a start date and time based on datein and start on
     * 
     * @param    datein    Reference date
     * @param    starton   1 = start of day, 
     *                     2 = start of week
     *                     3 = start of month
     *                     4 = start of calendar year
     * @return   DateTime  Date + 00:00:00
     ***************************************************************************/   
    
    public static DateTime dateStart(DateTime datein, int starton)
    {
      
      DateTime dateout;

     /*------------------------------
      * Extract month, day, and year
      * components from datein
      *------------------------------*/
      
      int startmonth = datein.Month;
      int startday   = datein.Day;
      int startyear  = datein.Year;

     /*------------------------------
      * Compute start date and store
      * as a string
      *------------------------------*/              
      
      if      (starton == 1) { /* Do nothing */              }
      else if (starton == 2) { /* TODO: Start of week */     }
      else if (starton == 3) { startday = 1;                 }
      else if (starton == 4) { startday = 1; startmonth = 1; }
      
      string startdate = startmonth.ToString() + "-" + startday.ToString() + "-" + startyear.ToString() + " 00:00:00";
      
     /*------------------------------
      * Convert to datetime and return
      *------------------------------*/              

      bool newdateok = DateTime.TryParse(startdate, out dateout);     
      return dateout;
      
    }
    
    /***************************************************************************
     * generateStartDate */
    /**
     * Generates a start date based on when
     * 
     * @param   when     0 = today, 1= today trailing, 2 = start of week, 
     *                   3 = start of month, 4 = start of calendar year  
     * @return  DateTime 
     ***************************************************************************/   
    
    public static DateTime generateStartDate(int when)
    {
      DateTime retDate = DateTime.Now;
			
     // int retDay       = retDate.Date.Day;
      int retMonth     = retDate.Date.Month;
      int retYear      = retDate.Date.Year;

      // 0 = todays date
      
      if (when == 1)
      {        
        // Trailing (if its less than 4AM return the previous days date)
        if (retDate.Hour < 4)
        {
          return retDate.AddDays(-1);
        }
        else
        {
          return retDate;
        }
      }
      if (when == 2)
      {
        // Start of week
        // http://bytes.com/topic/c-sharp/answers/231622-calculate-first-last-date-week
        
        CultureInfo info     = Thread.CurrentThread.CurrentCulture;
        DayOfWeek   firstday = info.DateTimeFormat.FirstDayOfWeek;
        DayOfWeek   today    = info.Calendar.GetDayOfWeek(DateTime.Now);
        int diff = today - firstday;
        retDate = DateTime.Now.AddDays(-diff);
      }
    
      // Start of month

      if (when == 3)
      {
        string newDate = retMonth.ToString() + "- 1 - " + retYear.ToString();
        retDate = DateTime.Parse(newDate);
      }

      // Start of current calendar year

      if (when == 4)
      {
        string newDate = "1 - 1 - " + retYear.ToString();
        retDate = DateTime.Parse(newDate);      
      }

      return retDate;
    }

    /***************************************************************************
     * generateStartDateThisMondayOrNext */
    /**
     ***************************************************************************/   

    public static DateTime generateStartDateThisMondayOrNext (DateTime? refDateTime)
    {
      if (refDateTime == null) refDateTime = DateTime.Now;
      DateTime refDate   = refDateTime.Value.Date;      
      DateTime startDate = refDate;
      
		  if      (refDate.DayOfWeek == DayOfWeek.Sunday)    startDate = refDate.AddDays(1);
		  else if (refDate.DayOfWeek == DayOfWeek.Monday)    startDate = refDate;
		  else if (refDate.DayOfWeek == DayOfWeek.Tuesday)   startDate = refDate.AddDays(6);
		  else if (refDate.DayOfWeek == DayOfWeek.Wednesday) startDate = refDate.AddDays(5);
		  else if (refDate.DayOfWeek == DayOfWeek.Thursday)  startDate = refDate.AddDays(4);
		  else if (refDate.DayOfWeek == DayOfWeek.Friday)    startDate = refDate.AddDays(3);
		  else if (refDate.DayOfWeek == DayOfWeek.Saturday)  startDate = refDate.AddDays(2);		  
      else startDate = refDate;
      return startDate;
    }
    
    /***************************************************************************
     * generateStartDateStr */
    /**
     * Generates a start date based on when
     * 
     * @param   when     0 = today, 1= today trailing, 2 = start of week, 
     *                   3 = start of month, 4 = start of this calendar year  
     * @return  string 
     ***************************************************************************/   
         
    public static string generateStartDateStr (int when)
    {
      if ((when < 1) || (when > 4)) return "";
      return generateStartDate(when).ToShortDateString();
    }

    /***************************************************************************
     * generateStartTimeStr */
    /**
     * Generates a start time based on when
     * 
     * @param   when     0 = today, 1= today trailing
     * @return  string 
     ***************************************************************************/   
    
    public static string generateStartTimeStr (int when)
    {
      if ((when < 1) || (when > 2)) return "";
      return generateStartDate(when).ToShortTimeString();
    }

    
    /***************************************************************************
     * calculateStartEndOfWeekDates */
    /**
     * Calculate start and end of current and previous week with respect to refDate
     ***************************************************************************/   
  
    public static void calculateStartEndOfWeekDates   ( DateTime     refDate
                                                      , DayOfWeek    dayOfWeekStart
                                                      , out DateTime startOfCurrWeek
                                                      , out DateTime endOfCurrWeek
                                                      , out DateTime startOfPrevWeek
                                                      , out DateTime endOfPrevWeek )
    {
      
			DateTime startingDate = refDate.Date;
      
      while (startingDate.DayOfWeek != dayOfWeekStart)
      {
        startingDate = startingDate.AddDays(-1);
      }
			
			startOfCurrWeek = startingDate.Date;
			endOfCurrWeek   = startingDate.AddDays(7).AddHours(23).AddMinutes(59).AddSeconds(59);;
      startOfPrevWeek = startingDate.AddDays(-7).Date;
      endOfPrevWeek   = startingDate.AddDays(-1).Date.AddHours(23).AddMinutes(59).AddSeconds(59);   
   }
   
    
   /***************************************************************************
    * calculatePrevOrCurrWeekDateRange */
   /**
    * Calculate either the start and end of the previous or current a week 
    * with respect to refDate.  
    ***************************************************************************/     
    public static void calculatePrevOrCurrWeekDateRange   (   DateTime     refDate
                                                            , DayOfWeek    dayOfWeekPrevCurrSwitch
                                                            , out DateTime startDate
                                                            , out DateTime endDate
                                                            , out String   dateRangeStr)
    {
       
       /* Compute date ranges for current and previous weeks.  Note: We use Sunday as our starting day. */
       
       DateTime startOfCurrWeek;
       DateTime endOfCurrWeek;
       DateTime startOfPrevWeek;
       DateTime endOfPrevWeek;

              
       Util.calculateStartEndOfWeekDates(refDate,DayOfWeek.Sunday,out startOfCurrWeek, out endOfCurrWeek, out startOfPrevWeek, out endOfPrevWeek);
    
       /* If the refDate is before dayOfWeekPrevCurrSwitch then return the previous weeks dates. */
       
       if (refDate.DayOfWeek < dayOfWeekPrevCurrSwitch) {
         startDate = startOfPrevWeek;
         endDate   = endOfPrevWeek;
       }  
       
       /* Otherwise return the current weeks dates. */

       else
       {
         startDate = startOfCurrWeek;
         endDate   = endOfCurrWeek;
       }
       
       /* Finally generate the date range string */
       
       dateRangeStr = Util.startAndEndDateToDateRangeStr (startDate, endDate);
     
     }     
   public static void calculatePrevOrCurrWeekDateRange   (    DayOfWeek    dayOfWeekPrevCurrSwitch
                                                            , out DateTime startDate
                                                            , out DateTime endDate
                                                            , out String   dateRangeStr)
   {    
     DateTime refDate = DateTime.Today;
     Util.calculatePrevOrCurrWeekDateRange(refDate,dayOfWeekPrevCurrSwitch, out startDate, out endDate, out dateRangeStr);
   }

   /***************************************************************************
    * calculatePrevOrCurrWeekDateRangeStr */
   /**
    * Calculate either the start and end of the previous or current week 
    * with respect to todays date and dayOfWeekPrevCurrSwitch and returns
    * just the date range string.
    ***************************************************************************/     

   public static string calculatePrevOrCurrWeekDateRangeStr ( DayOfWeek dayOfWeekPrevCurrSwitch )
   {
    
     DateTime startDate;
     DateTime endDate;
     String   dateRangeStr;

     Util.calculatePrevOrCurrWeekDateRange   (dayOfWeekPrevCurrSwitch, out startDate, out endDate, out dateRangeStr);
     return dateRangeStr;
   }
   
   /***************************************************************************
     * calculateProgress */
    /**
		 *
     * Caculate the progress of something.
     * 
     * @param   count       Current count (counter in a loop)
     * @param   total       Total count to reach
     * @return  int
     ***************************************************************************/   
  
    public static int calculateProgress (int count, int total)
    {
      /*----------------------------
       * Compute a progress 
       * percentage
       *----------------------------*/   

      double percent = (double)(count * 100) / total;
      int progress = (int) Math.Ceiling(percent);
      return progress;
    }
    
    /***************************************************************************
     * calculatePageNumber */
    /**
		 *
     * Takes a given start row and page size and calculates what page number
     * the row would be on.  For example:
     *   startRow = 11
     *   pageSize = 10
     *   pageNumber = 11/10 = 1.1 = 1
     * 
     * @param   startRow     0 - ?
     * @param   pageSize     1 - ?
     * @return  pageNumber
     ***************************************************************************/   
    
    public static int calculatePageNumber (int startRow, int pageSize)
    {
      int     pageNumber      = 0;
      double  pageNumberCalc  = 0;
      double  startRowCalc    = 0;
      double  pageSizeCalc    = 0;

      if (pageSize == 0) return pageNumber;
      if (startRow == 0) return 1;
      
      startRowCalc = (double) (startRow+1);
      pageSizeCalc = (double) pageSize;

      pageNumberCalc = startRowCalc / pageSizeCalc;
      pageNumber     = (int) Math.Ceiling(pageNumberCalc);

      return pageNumber;
    }

    /***************************************************************************
     * calculateNumberOfPages */
    /**
		 *
     ***************************************************************************/   
    
    public static int calculateNumOfPages (int pageSize, long rowCount)
    {
      if (pageSize <= 0) return 0;
      if (rowCount <= 0) return 0;
      var psize  = (double) pageSize;
      var rcount = (double) rowCount;      
      var npages = Math.Ceiling((rcount/psize));
      return (int) npages;
    }

    /***************************************************************************
     * EvaluateDateExpression */
    /**
		 * Takes a given date expression and returns a date time.  
     * This is similar to the jQuery UI date picker default value settings.
     *
     * Modified version of Adam Robinson's CalcDate function.
     * http://stackoverflow.com/questions/2738713/library-to-work-with-date-expressions-in-c/2738742#2738742
     * 
     * @param     expression    A date expression consisting of one or more elements of the form +-nI
     *                          where +- n is an integer and I is an interval.  
     *
     *                          Valid intervals are: 
     *                          
     *                            D for day(s), W for week(s), M for month(s), and Y for year(s)
     *
     *                          For example:
     *                          
     *                            +1W+2D = +1 week and +2 days
     *                            -1M+1W = - 1 month and + 1 week.
     *
     * @param     epoch         Current date or reference date
     *
     * @return    DateTime      Calculated date time
     ***************************************************************************/      
    
    public static DateTime EvaluateDateExpression (string expression)
    {
      return EvaluateDateExpression(expression, DateTime.Now);
    }

    public static DateTime EvaluateDateExpression (string expression, DateTime epoch)
    {
      
      if (Util.IsNullOrEmpty(expression))
        return DateTime.Now;
      
      expression = expression.Trim().ToUpper();
      var match  = System.Text.RegularExpressions.Regex.Match(expression, @"(([+-])(\d+)([YDMW]))+");

      if (match.Success && match.Groups.Count >= 5)
      {
        var signs  = match.Groups[2];
        var counts = match.Groups[3];
        var units  = match.Groups[4];

        for (int i = 0; i < signs.Captures.Count; i++)
        {
          string sign  = signs.Captures[i].Value;
          int    count = int.Parse(counts.Captures[i].Value);
          string unit  = units.Captures[i].Value;

          if (sign == "-") count *= -1;

          switch (unit)
          {
            case "Y": epoch = epoch.AddYears(count);  break;
            case "M": epoch = epoch.AddMonths(count); break;
            case "D": epoch = epoch.AddDays(count);   break;
            case "W": count = count * 7; 
                      epoch = epoch.AddDays(count);   break;
          }
        }
      }
      else
      {
        throw new Warning("The specified expression was not a valid date expression.");
      }

      return epoch;
    }

    /***************************************************************************
     * mayBeADate
    /**
     * Value may be a date
     ***************************************************************************/   
		
	  public static bool mayBeADate (string value)
	  {
	    // If value contains digits
      if (Regex.IsMatch(value,@"\d+",RegexOptions.IgnoreCase))
	    {	  
        // And it contains a month name
	      if (Regex.IsMatch(value,@"\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)",RegexOptions.IgnoreCase))
          return true;

        // Or it contains a weekday name
        if (Regex.IsMatch(value,@"\b(sun|mon|tue|wed|thu|fri|sat)",RegexOptions.IgnoreCase))
          return true;
				
		    // Or it contains no letters
		    if (!Regex.IsMatch(value,@"[a-z]{1,}",RegexOptions.IgnoreCase))
		      return true;		
       }
	    // Otherwise it may not be a date
	    return false;
	  }

    /***************************************************************************
     * valueHasLineBreaks */
    /**
	 	 * If the value has line breaks return true otherwise false.
     ***************************************************************************/   

    public static bool valueHasLineBreaks (string value)
    {
      if (String.IsNullOrEmpty(value)) return false;
      if (value.IndexOf("\n") == -1)   return false;
      return true;
    }

    /***************************************************************************
     * valueHasNumbers */
    /**
	 * If the value has numbers return true
     ***************************************************************************/   
    
    public static bool valueHasNumbers (string value)
    {
      if (String.IsNullOrWhiteSpace(value)) return false;            
      MatchCollection mc = Regex.Matches(value,@"\d");
      if (mc.Count == 0 ) return false;
      return true;
    }

    /***************************************************************************
     * nameCase */
    /**
	 	 *
     * Takes an incoming first, middle, or last name and returns the name as a
     * proper noun
     * 
     * Examples andy -> Andy
     *          ANDY -> Andy
     *          a    -> A    * @param   dob   date of birth
     * 
     * @param   name   Incoming name
     * @return  processed name
     ***************************************************************************/   

    public static string nameCase(string name)
    {
      if (String.IsNullOrWhiteSpace(name)) return "";
      if (String.IsNullOrEmpty(name)) return "";
      name = name.Trim();
      if (name.Length == 1) return name.ToUpper();
      string uLName = name.Substring(0,1).ToUpper() + name.Substring(1).ToLower();
      return uLName;
    }

    /***************************************************************************
     * RandomNumber */
    /**
     * Generates a random number
     * 
     * @param   min  minimum value generated
     * @param   max  maximum value generated
     * @return  random number
     ***************************************************************************/   

		public static int RandomNumber(int min, int max)
		{
	    Random random = new Random();
			return random.Next(min, max);
		}

    /***************************************************************************
     * randomString */
    /**
     * Generates a random string
     * 
     * @param   size  size of the string to generate
     * @return  random string
     ***************************************************************************/   

		public static string randomString(int size)
		{
			StringBuilder builder = new StringBuilder();
			Random random = new Random();
			char ch ;
			for(int i=0; i<size; i++)
			{
				// Replace 55 with 26 if you just want the first set of ASCII letters
				ch = Convert.ToChar(Convert.ToInt32(Math.Floor(55 * random.NextDouble() + 65)));
				builder.Append(ch);
			}
			return builder.ToString();
		}
		  
    /***************************************************************************
     * TokenSafeString */
    /**
     * Removes web unfriendly characters and replaces them with random numbers.
     * This is mainly used for security token generation.
     * 
     * @param   strIn   string to clean up
     * @return  clean string
     **************************************************************************/   
    
		public static string TokenSafeString(string strIn)
		{
			if (Util.IsNullOrEmpty(strIn)) return "";

      string Token = strIn.Trim();
			
			Token = Token.Replace("=",  RandomNumber(1,99).ToString());
		    Token = Token.Replace("&",  RandomNumber(1,99).ToString());
			Token = Token.Replace("\\", RandomNumber(1,99).ToString());
			Token = Token.Replace("/",  RandomNumber(1,99).ToString());
			Token = Token.Replace("<",  RandomNumber(1,99).ToString());
			Token = Token.Replace(">",  RandomNumber(1,99).ToString());
			Token = Token.Replace("+",  RandomNumber(1,99).ToString());
			Token = Token.Replace("[",  RandomNumber(1,99).ToString());
			Token = Token.Replace("]",  RandomNumber(1,99).ToString());
			Token = Token.Replace("'",  RandomNumber(1,99).ToString());
			Token = Token.Replace("\"", RandomNumber(1,99).ToString());
			Token = Token.Replace("`",  RandomNumber(1,99).ToString());
			Token = Token.Replace("^",  RandomNumber(1,99).ToString());
			Token = Token.Replace("|",  RandomNumber(1,99).ToString());
            Token = Token.Replace("?",  RandomNumber(1,99).ToString());
            Token = Token.Replace("{",  RandomNumber(1,99).ToString());
            Token = Token.Replace("}",  RandomNumber(1,99).ToString());
            Token = Token.Replace(":",  RandomNumber(1,99).ToString());
            Token = Token.Replace(";",  RandomNumber(1,99).ToString());
            Token = Token.Replace(",",  RandomNumber(1,99).ToString());
            Token = Token.Replace(@"""",  RandomNumber(1,99).ToString());
            return Token;
		}
	  
   /***************************************************************************
    * WebSafeString */
   /**
    * Removes web unfriendly characters.  This is mainly used for
    * security token generation.
    * 
    * @param   strIn   string to clean up
    * @return  clean string
    **************************************************************************/   
    
		public static string webSafeString(string strIn)
		{
			if (String.IsNullOrWhiteSpace(strIn)) strIn = @"";
                                
            string strOut = strIn.Trim();
			if (String.IsNullOrWhiteSpace(strOut)) return strOut;

			strOut = strOut.Replace("=",  "");
		    strOut = strOut.Replace("&",  "");
			strOut = strOut.Replace("\\", "");
			strOut = strOut.Replace("/",  "");
			strOut = strOut.Replace("<",  "");
			strOut = strOut.Replace(">",  "");
			strOut = strOut.Replace("+",  "");
			strOut = strOut.Replace("[",  "");
			strOut = strOut.Replace("]",  "");
			strOut = strOut.Replace("'",  "");
			strOut = strOut.Replace("\"", "");
			strOut = strOut.Replace("`",  "");
			strOut = strOut.Replace("^",  "");
			strOut = strOut.Replace("|",  "");
            strOut = strOut.Replace("?",  "");
            strOut = strOut.Replace("{",  "");
            strOut = strOut.Replace("}",  "");
            strOut = strOut.Replace(":",  "");
            strOut = strOut.Replace(";",  "");
            strOut = strOut.Replace(",",  "");
            
            return strOut;
		}
   
    /***************************************************************************
     * convertScientificNotationStringToNumberString */
    /**
     * Converts scientific notation string to number string
     *
     * @param  value    string with alpha numeric value
     * @return          string with just numeric value
     ***************************************************************************/  

    public static string convertScientificNotationStringToNumberString (string value)
    {
      /* If value is empty then return value*/

      if (String.IsNullOrWhiteSpace(value)) return value;
      
      /* Trim and lowecase so we can perform an easier test for e */

      value = value.Trim().ToLower();
      
      /* If the value contains e then attempt to convert */
      
      if (value.Contains("e")) 
      { 
        Decimal result;
        
        /* If value parses OK, then return the parsed result as a string */

        if (Decimal.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out result))
        {
          return result.ToString();
        }
        
        /* Otherwise return original value */

        else
        {
          return value;
        }      
      }
      /* If we get here value did not contain an e so just return original value */
      return value;
    }

    /***************************************************************************
     * removeAllNonNumeric */
    /**
     * Removes all non numeric characters from value and returns the resulting
     * string.  Fot example if value is (123) 456-789 this function will return
     * 123456789.
     *
     * @param  value    string with alpha numeric value
     * @return          string with just numeric value
     ***************************************************************************/  

    public static string removeAllNonNumeric(string value)
    {
      
      if (IsNullOrEmpty(value)) return "";
 
     /*-------------------------------
      * Search for all numeric 
      * strings in value.  If none
      * are found exit.  If some
      * are found build our output
      * string in the order that
      * the matches were found
      * left -> right
      *------------------------------*/

     MatchCollection mc = Regex.Matches(value,@"\d");
     if (mc.Count == 0 ) return "";
     StringBuilder sb = new StringBuilder();
     foreach (Match m in mc) sb.Append(m.Value);
     return sb.ToString();
    }

    /***************************************************************************
     * textToHTML */
    /**
     * Converts /n to <br/>
     * 
     * Note: This converts the new line code itself, not the \n string
     * 
     * @param   textIn
     * @return  textIn with break tags
     ***************************************************************************/  

    public static string textToHTML(string textIn)
    {
      string textOut = Regex.Replace(textIn.Trim(),@"\n",@"<br/>");
      return textOut;
    }

    /***************************************************************************
     * stringToHTML */
    /**
     * Converts /n to <br/>
     * 
     * @param   stringIn
     * @return  stringIn with break tags
     ***************************************************************************/  

    public static string stringToHTML (string stringin)
    {
      string stringOut = stringin.Replace(@"\n",@"<br/>");
      
      return stringOut;
    }
    
    /***************************************************************************
     * textToHTMLPre */
    /**
     * Preserved text formatting (line breaks, white space, etc) by wrapping 
     * text in <pre> tags.  Also attempts to handle word wrapping.
     * Note: This method does NOT attempt to escape any reserved HTML characters.
     *
     * @param   textIn
     * @return  textIn wrapped in pre
     ***************************************************************************/  
    
    public static string textToHTMLPre (string textIn)
    {
      if (String.IsNullOrEmpty(textIn)) textIn = @"";
      string textOut = @"<pre style=""white-space:pre-wrap;word-wrap:break-word;font-family:'Courier New',Courier,monospace"">" + textIn + @"</pre>";
      return textOut;
    }
    
    /***************************************************************************
     * textToHTMLStickyNote */
    /**
     * Wraps textIn in markup that (if using default style) resembles a sticky
     * note.  The markup selected (p tags with a white-space:pre-wrap) 
     * preserves any white space that may have been entered in a textarea.  
     *
     * Note: A p element is used instead of pre because p has better support 
     * in email clients.
     *
     * Any reserved characters in textIn are escaped.
     *
     * @param   textIn
     * @parm    style  Inline CSS to inject into p element style attribute.
     * @return  textIn wrapped in HTML markup
     ***************************************************************************/  
   
    public static string textToHTMLStickyNote (string textIn, string style = null)
    {
      var sb = new StringBuilder();

      /* If no style is provided use the default.
       * Default is to override any inherited alignment so text matches what would have been inside a text area and 
       * to use a light yellow background and a charcoal text color set at 12pt with monospaced fonts and minimal padding
       * to generate markup that resembles a sticky note */

      if (String.IsNullOrWhiteSpace(style)) { 
        style = @"background-color:#FFFFE0;color:#36454F;white-space:pre-wrap;width:100%;text-align:left;padding:10px;font-size:12pt;font-family:'Courier New',Courier,monospace";
      }
      
      /* If text is empty or null replace with empty string */     
      
      if (String.IsNullOrEmpty(textIn)) {
        textIn = @"";
      }

      /* Replace any reserved HTML characters in textIn with entity codes */
      
      textIn = System.Net.WebUtility.HtmlEncode(textIn); 
            
      /* Generate markup */
      
      sb.AppendFormat(@"<p style=""{0}"">", style);
      sb.Append(textIn); 
      sb.Append(@"</p>");

      /* Return markup */

      return sb.ToString();
   }


   /***************************************************************************
    * isWeekend */
   /**
    * Tests if date falls on a weekend
    * 
    * @param   date    date in question
    * @return  true or false
    ***************************************************************************/   

    public static bool isWeekend(DateTime date)
    {
      return ((date.DayOfWeek == DayOfWeek.Saturday) || (date.DayOfWeek == DayOfWeek.Sunday));                                              
    }

    /***************************************************************************
     * convertDayNumberToDay */
    /**
     * Takes a day number and returns the day of week
     * 
     * @param   day   1-7
     * @return  the weekday
     ***************************************************************************/   

    static public string convertDayNumberToDay(int day)
    {
      string returnDay = null;
      switch(day)
      {
        case 1: {returnDay = "Sunday"    ;break;}
        case 2: {returnDay = "Monday"    ;break;}
        case 3: {returnDay = "Tuesday"   ;break;}
        case 4: {returnDay = "Wednesday" ;break;}
        case 5: {returnDay = "Thursday"  ;break;}
        case 6: {returnDay = "Friday"    ;break;}
        case 7: {returnDay = "Saturday"  ;break;}
        default:{returnDay = null        ;break;}
      }
      return returnDay;
    } 
    
    /***************************************************************************
     * netBoolToJSBool */
    /**
     * Takes a bool and converts to a lowercase true or false
     * 
     * @param  boolin  boolean in
     * @return true or false
     ***************************************************************************/     
     
    public static string netBoolToJSBool (bool boolin)
    {
      return boolin.ToString().ToLower();
    }
    
    /***************************************************************************
     * boolToYesNo */
    /**
     * Takes a bool and converts to a Yes or No
     * 
     * @param  boolin  boolean in
     * @return string
     ***************************************************************************/          

    public static string boolToYesNo (bool boolin)
    {
      if (boolin) return "Yes"; else return "No";
    }

    /***************************************************************************
     * boolToYesNoUnknown */
    /**
     * Takes a bool and converts to a Yes or No
     * 
     * @param  boolin  boolean in
     * @return string
     ***************************************************************************/

    public static string boolToYesNoUnknown (bool? boolin)
    {
      return boolToYesNoUnknown(boolin,"Unknown");
    }
    
    public static string boolToYesNoUnknown (bool? boolin, string unknownValue)
    {
      if (String.IsNullOrEmpty(unknownValue)) 
        unknownValue = "Unknown";
      
      if (boolin.HasValue) 
        return boolToYesNo(boolin.Value);
        
      return unknownValue;
    }

    /***************************************************************************
     * boolTo1or0Str */
    /**
     * Takes a bool and converts to a "1" or "0" 
     * 
     * @param  boolin  boolean in
     * @return string
     ***************************************************************************/          

    public static string boolTo1or0Str (bool boolin)
    {
     if (boolin) return "1"; else return "0";
    }
   
   /***************************************************************************
    * dateTimeToShortDate */
   /**
    * Takes an incoming date time value and returns the date component as a string
    * or a blank if the value is the date time min value
    * 
    * @param  value    Datetime in
    * @return string
    ***************************************************************************/          

    public static string dateTimeToShortDate (DateTime value)
    {     
      return dateTimeToShortDate(value, FormatStrings.DATETIME_MM_DD_YYYY);
    }
    
    public static string dateTimeToShortDate (DateTime value, string shortdateformat)
    {
      string d = "";
      if (value == DateTime.MinValue)
        d = "";
      else
        d = value.ToString(shortdateformat);
      return d;
    }

    public static string dateTimeToShortDate (string value)
    {
      return dateTimeToShortDate(value, FormatStrings.DATETIME_MM_DD_YYYY);
    }
    
    public static string dateTimeToShortDate (string value, string shortdateformat)
    {
      if (Util.IsNullOrEmpty(value)) return null;
      DateTime dt = DateTime.Parse(value);
      return dateTimeToShortDate(dt);
    }
    
   /***************************************************************************
    * previewString */
   /**
    * Takes an incoming string value and creates a value appropriate for
    * preview display
    * 
    * @param  value    string in
    * @return string
    ***************************************************************************/  

    public static string previewString (string value)
    {
      string p = value;
      if (Util.IsNullOrEmpty(p)) return p;
      if (p.Length <= 50)        return p;
      if (p.Length > 50 ) 
        p = p.Substring(0,50) + " ...";
      return p;
    }

    /***************************************************************************
     * fileTimeStamp */
    /**
     * Create a unique file name
     ***************************************************************************/    

    public static string fileTimeStamp(string app_root_dir, string sub_dir, string relative_file)
    {
      string physical_file = app_root_dir + @"/" + sub_dir + @"/" + relative_file;
      physical_file = physical_file.Replace(@"/",@"\");
      return fileTimeStamp(physical_file);
    }
    
    public static string fileTimeStamp(string physical_file)
    {
      /*------------------------------
       * If physical_file exists we 
       * retrive the last time it was 
       * modified and convert this
       * timestamp to a unique number.
       * If this file is a static
       * file (html, image, swf, etc)
       * it can be appended to a url
       * that references this file.
       * using the following form:
       *   filename?stamp
       *   logo.png?13384385345
       * This will help the users
       * browser to only fetch files
       * from the server that have 
       * been changed. 
       *------------------------------*/ 

      if (!System.IO.File.Exists(physical_file)) { throw new Exception("Cannot generate URL time stamp.  Physical file not found");}
      DateTime lastModified = System.IO.File.GetLastWriteTime(physical_file);
      string filestamp = lastModified.Ticks.ToString();
      return filestamp;
    }
  
    /***************************************************************************
     * isNullOrEmpty */
    /**
     * Wrapper for the String.isNullOrEmpty method.
     * Will also return a true if:
     *   - a string value of "null" is passed in
     *   - an empty string "" is passed in
     *
     * @param   value string value to test
     * @return  true if null or empty, false if not
    ***************************************************************************/   

    public static bool IsNullOrEmpty (string value)
    {
      if (String.IsNullOrEmpty(value))      return true;
      if (String.IsNullOrWhiteSpace(value)) return true;
      if (value.Trim().ToLower() == "null") return true;
      if (value.Trim().Length == 0)         return true;
      return false;
    }
   
    /***************************************************************************
     * isNullOrPseduoNullValue */
    /**
     * 
     * 
    ***************************************************************************/   

   public static bool isNullOrPseduoNullValue (string value)
   {
     if (String.IsNullOrWhiteSpace(value)) return true;
     if ((value == "0") || (value =="-1")) return true;
     return false;
   }
    
    /***************************************************************************
     * isNullUnknownEmpty */
    /**
     * Wrapper for the String.isNullOrEmpty method.
     * Will also return a true if:
     *   - a string value of "null" is passed in
     *   - an empty string "" is passed in
     *
     * @param   value string value to test
     * @return  true if null or empty, false if not
    ***************************************************************************/   

    public static bool IsNullUnknownOrEmpty (string value)
    {
      if (String.IsNullOrEmpty(value))         return true; 
      if (value.Trim().ToLower() == "null")    return true;
      if (value.Trim().ToLower() == "unknown") return true;
      if (value.Trim().Length == 0)            return true;
      return false;
    }

   /***************************************************************************
    * isNDigitInteger */
   /**
    * Is value an n digit integer where value is an integer and n is the 
    * the number of digits.
    *
    * @param   value   integer to test (as a string)
    * @param   n       number of digits 
    * @return  true  = integer is n digits long
    *          false = integer is invalid or not n digits long
    ***************************************************************************/   
    
    public static bool isNDigitInteger (string value, int n)
    {
      if (IsNullOrEmpty(value)) return false;
      if (n <= 0)               return false;
      string ptrn = @"^\d{" + n.ToString() + @"}$";
      return Regex.IsMatch(value,ptrn);
    }

   /***************************************************************************
    * isANumber */
   /**
    * Is value a number
    *
    * @param   value   value to test (as a string)
    * @return  true  = yes
    *          false = no
    ***************************************************************************/   
    
    public static bool isANumber (string value)
    {
      if (IsNullOrEmpty(value)) return false;
      return Decimal.TryParse(value,out var _decResult);
    }

   /***************************************************************************
    * countTerms */
   /**
    * Searches value for term and returns # of terms
    *
    * @param   value  string to clean up
    * @param   term   search term 
    * @return  value without spaces 
    ***************************************************************************/   
    
    public static int countTerms (string value, string term)
    {
    
      int numOf = 0;

      /*-------------------------------
       * Exit early if we know the
       * count will be 0
       *------------------------------*/ 
      
      if (IsNullOrEmpty(value))  return numOf;
      if (IsNullOrEmpty(term))   return numOf;
      if (!value.Contains(term)) return numOf;

      /*-------------------------------
       * Perform the count using a split
       * The number of terms will be
       * the size of the array - 1
       * For example:
       * hello, world would return
       * a string[2] and 2-1 is the
       * number of delimiters
       *------------------------------*/ 

      string[] delm = new string[1];
      delm[0] = term;
      numOf   = value.Split(delm,StringSplitOptions.None).Length - 1;
      return numOf;
    
    }
    
    /***************************************************************************
     * removeFirstAndLastCharacter */
    /**
     * Removes first and last character from value
     *
     * @param   value  string to remove first and last characters
     * @return  value sans first and last
     ***************************************************************************/   
   
    public static string removeFirstAndLastCharacter (string value)
    {      
      if (Util.IsNullOrEmpty(value)) return value;      
            
      string v1 = value.Remove(0,1);
      int lastIdx = v1.Length - 1;
      if (lastIdx < 0 ) return v1;
      string v2 = v1.Remove(lastIdx,1);
      return v2;
    }
    
    /***************************************************************************
     * removeWhiteSpace */
    /**
     * Removes all spaces from a string
     *
     * @param   value  string to clean up
     * @return  value  without spaces 
     ***************************************************************************/   
    
    public static string removeWhiteSpace (string value)
    {
      value = value.Trim();
      return Regex.Replace(value,@"\s{1,}",String.Empty);
    }

    /***************************************************************************
     * DateDiffInMonths */
    /**
     * Computes difference in months
     *
     * @param   date1    Date 1
     * @param   date2    Date 2
     * @return  int       
     ***************************************************************************/   
    
    public static int DateDiffInMonths (DateTime date1, DateTime date2)
    {
      // Courtesey of Adam Ralph
      // http://stackoverflow.com/a/4639057
      
      int numMonths = ((date1.Year - date2.Year) * 12) + date1.Month - date2.Month;
      return numMonths;
    }
    
    /***************************************************************************
     * startAndEndDateStrToDateRangeStr
    /**
     * For a given startDateStr and endDateStr generate a date range string
     *
     * @param   startDateStr   Start date as string
     * @param   endDateStr     End date as string
     * @return  string
     ***************************************************************************/  
    
    public static string startAndEndDateStrToDateRangeStr (string startDateStr, string endDateStr, string dashString = @"-")
	{		  		  			
		string fyearRange = String.Format(@"{0} {1} {2}",startDateStr,dashString,endDateStr);	
	    return fyearRange;	
	}
	
    /***************************************************************************
     * startAndEndDateToDateRangeStr
    /**
     * For a given startDate and endDate generate a date range string
     *
     * @param   startDate   Start date
     * @param   endDate     End date
     * @return  string
     ***************************************************************************/  
     
    public static string startAndEndDateToDateRangeStr (DateTime startDate, DateTime endDate, string dashString = @"-")
	{		  		  			
		string sDate      = startDate.ToShortDateString();
		string eDate      = endDate.ToShortDateString();
        return startAndEndDateStrToDateRangeStr(sDate,eDate,dashString);		  	    
	}
	 
    /***************************************************************************
     * startAndEndDateToDateRangeFileNamePart
    /**
     * For a given startDate and endDate generate a string suitable to include
     * in a file name
     *
     * @param   startDate   Start date
     * @param   endDate     End date
     * @return  string
     ***************************************************************************/  
     
    public static string startAndEndDateToDateRangeFileNamePart (DateTime startDate, DateTime endDate)
		{		  		  			
		  return String.Format( @"{0}{1}{2}-{3}{4}{5}"
		                      , startDate.Year.ToString()
		                      , startDate.Month.ToString()
		                      , startDate.Day.ToString()
		                      , endDate.Year.ToString()
		                      , endDate.Month.ToString()
		                      , endDate.Day.ToString());
		}
	 
    /***************************************************************************
     * computeFiscalYear */
    /**
     * For a given start month/day, end month/day, and reference date
     * this function computes the fiscal year the reference date falls under
     *
     * @param   monthStart  Start month, for example 7
     * @param   dayStart    Start day, for example 1
     * @param   monthEnd    End month, for example 6
     * @param   dayEnd      End day, for example 30
     * @param   refDate     Reference date
     * @return  dateRange
     ***************************************************************************/  
     
    public static bool computeFiscalYear (int monthStart, 
                                          int dayStart, 
                                          int monthEnd, 
                                          int dayEnd, 
                                          DateTime refdate, 
                                          out DateTime startDate, 
                                          out DateTime endDate)
    {
		  
		  /*----------------------------
       * Set reference date to today
       * if it was not passed in
       *----------------------------*/
		  
		  if (refdate == null)
		    refdate = DateTime.Now;
		    
		  int refYear   = refdate.Year;
		  int refMonth  = refdate.Month;
		  
		  int yearStart = refYear;
	    int yearEnd   = refYear;
		  
		  string sDate = "";
		  string eDate = "";
	      	      
		  /*----------------------------
       * Set month/day start and ends
       * to sensible values if they
       * do not make sense
       *----------------------------*/
		  
		  if ((monthStart < 1) || (monthStart > 12))   monthStart = 1;
		  if ((monthEnd   < 1) || (monthEnd   > 12))   monthEnd   = 12;
		  if ((dayStart   < 1) || (dayStart   > 31))   dayStart   = 1;
		  if ((dayEnd     < 1) || (dayEnd     > 31))   dayEnd     = 31;  
			
	    /*----------------------------
       * Compute fiscal year
       *----------------------------*/
	    
	    if ((refMonth >= monthStart) && (refMonth <= 12))
	    {
  	    
  	    /*----------------------------
         * Fiscal year is between two 
         * years and reference year is
         * in the 1st of those two years
         *----------------------------*/
         
		    yearStart = refYear;
		    yearEnd   = refYear + 1;
		  }
		  else if ((refMonth >= 1) && (refMonth <= monthEnd))
	    {

  	    /*----------------------------
         * Fiscal year is between two 
         * years and reference year is
         * in the 2nd of those two years
         *----------------------------*/

		    yearStart = refYear - 1;
		    yearEnd   = refYear;	        
		  }
		  else
		  {
		  
		   /*----------------------------
        * Fiscal year is a calendar
        * year
        *----------------------------*/

		    yearStart = refYear;
			  yearEnd   = refYear;
		  }
			
		  /*----------------------------
       * Create start and end date
       * strings
       *----------------------------*/
		  
		  sDate = monthStart.ToString() + "/" + dayStart.ToString() + "/" + yearStart.ToString();
		  eDate = monthEnd.ToString()   + "/" + dayEnd.ToString()   + "/" + yearEnd.ToString();
		  		  
		  /*----------------------------
       * Convert them to dates
       *----------------------------*/

		  bool date1ok = DateTime.TryParse(sDate, out startDate);		  		    
		  bool date2ok = DateTime.TryParse(eDate, out endDate);
		  
		  /*----------------------------
       * Make sure the difference
       * is 12 months
       *----------------------------*/

		  bool datediffok = true;
		  
      if (DateDiffInMonths(startDate,endDate) != 12)
        datediffok = false;
        
      /*----------------------------
       * Return state of calculation
       *----------------------------*/

      bool state = date1ok && date2ok && datediffok;
      
      return state;
      
    }
    
    public static string computeFiscalYear(int monthStart, int dayStart, int monthEnd, int dayEnd, DateTime refdate)
		{
		  DateTime startDate;
		  DateTime endDate;
		  
		  computeFiscalYear(monthStart, dayStart, monthEnd, dayEnd, refdate, out startDate, out endDate);
		  return startAndEndDateToDateRangeStr(startDate, endDate);		  			
		}
	  
	/***************************************************************************
     * computeCalendarYear */
    /**
     * For a given reference date
     * this function computes the calendar year the reference date falls under
     *
     * @param   refDate     Reference date
     * @return  dateRange
     ***************************************************************************/    
    
    public static bool computeCalendarYear (DateTime refdate, 
                                            out DateTime startDate, 
                                            out DateTime endDate)
    {    
      return computeFiscalYear(1, 1, 12, 31, refdate, out startDate, out endDate);                  
    }
    
    public static string computeCalendarYear(DateTime refdate)
		{
		  DateTime startDate;
		  DateTime endDate;
		  
		  computeCalendarYear(refdate, out startDate, out endDate);
		  return startAndEndDateToDateRangeStr(startDate, endDate);		  			
		}

        /***************************************************************************
         * computeClaimingYear */
        /**
         * For a given reference date
         * this function computes the 12 month window claims can be submitted for
         *
         * @param   refDate     Reference date
         * @return  dateRange
         ***************************************************************************/
        public static void computeClaimingYear(out DateTime startDate, out DateTime endDate)
        {
            computeClaimingYear(null,out startDate,out endDate);
            return;
        }
        public static void computeClaimingYear (DateTime? refDate, out DateTime startDate, out DateTime endDate)
        {
          if (!refDate.HasValue) refDate = DateTime.Today.Date;
          endDate = refDate.Value;
          startDate = new DateTime(refDate.Value.Year, refDate.Value.Month, 1).AddMonths(-12);  
          return;
       }

	/***************************************************************************
     * GenerateDateRange */
    /**
     * For a given when constant
     * this function computes a date range
     *
     * @param   when       
     * @return  dateRange
     ***************************************************************************/    
	  	  
	public static bool GenerateDateRange (int when, out DateTime startDate, out DateTime endDate)
    {
      
      DateTime refDateThisYear = DateTime.Now;
      DateTime refDateLastYear = refDateThisYear.AddYears(-1);
      
      bool state      = true;      
      int  monthStart = 7;
      int  dayStart   = 1;
      int  monthEnd   = 6;
      int  dayEnd     = 30;
      
      startDate = refDateThisYear;
      endDate   = refDateThisYear;
      
      /*----------------------------
       * Today
       *----------------------------*/
      
      if (when == 0)
        return state;
              
      /*----------------------------
       * Last 7 days
       *----------------------------*/

      else if (when == 1)
      {
        startDate = refDateThisYear.AddDays(-7);
        return state;        
      }

      /*----------------------------
       * Fiscal year to date
       *----------------------------*/
      
      else if (when == 3)
      {
        state   = computeFiscalYear (monthStart, dayStart, monthEnd, dayEnd, refDateThisYear, out startDate, out endDate);            
        endDate = refDateThisYear;
        return state;
      }

      /*----------------------------
       * Last fiscal year
       *----------------------------*/
      
      else if (when == 4) return computeFiscalYear (monthStart, dayStart, monthEnd, dayEnd, refDateLastYear, out startDate, out endDate);      
      
      /*----------------------------
       * Calendar year to date
       *----------------------------*/

      else if (when == 5) 
      {
        state   = computeCalendarYear (refDateThisYear, out startDate, out endDate);            
        endDate = refDateThisYear;
        return state;      
      }
      
      /*----------------------------
       * Last calendar year
       *----------------------------*/

      else if (when == 6) return computeCalendarYear (refDateLastYear, out startDate, out endDate);            
      
      
      /*----------------------------
       * Last 60 days
       *----------------------------*/

      else if (when == 7)
      {
        startDate = refDateThisYear.AddDays(-60);
      return state;
    }

      /*----------------------------
       * Last 90 days
       *----------------------------*/

      else if (when == 8)
      {
        startDate = refDateThisYear.AddDays(-90);
        return state;        
      }

      /*----------------------------
       * Current claiming year
       *----------------------------*/

      else if (when == 9)
      {
        computeClaimingYear(out startDate,out endDate);
        return state;
      }
      
      return state;
    }

    public static string GenerateDateRange(int when)
    {
      DateTime startDate;
		  DateTime endDate;		  
		  GenerateDateRange(when, out startDate, out endDate);
		  return startAndEndDateToDateRangeStr(startDate, endDate);		
    }
    
    /***************************************************************************
     * parseDateRange */
    /**
     * For a given dateRange of the form mm/dd/yyyy - mm/dd/yyyy or mm/dd/yyyy parses
     * range into a start and end date.  If a single date is provided, start and end
     * dates are set to the single date.
     *
     * @param   dateRange   mm/dd/yyyy - mm/dd/yyyy or mm/dd/yyyy
     * @return  startDate   Start date
     * @return  endDate     End date
     ***************************************************************************/  

    public static void parseDateRange (string dateRange, out string startDate, out string endDate)
    {
      // TODO: Regular expression check
      
      startDate = "";
      endDate   = "";
      
      if (String.IsNullOrWhiteSpace(dateRange)) return;

      string[] dateParts = dateRange.Split(new char[]{'-',','},StringSplitOptions.RemoveEmptyEntries);
      
      if (dateParts != null)
      {
        if (dateParts.Length > 1)
        {
          startDate = dateParts[0] + " 00:00:00";
          endDate   = dateParts[1] + " 23:59:59";
        }
        else if (dateParts.Length == 1)
        {
          startDate = dateParts[0] + " 00:00:00";
          endDate   = dateParts[0] + " 23:59:59";
        }
        else
        {
          startDate = "";
          endDate   = "";
        }
      }
      return;
    }             
    
    /***************************************************************************
     * valueIsNativeInteger */
    /**
     * For a given value determine if it is a native integer
     *
     * @param   value       Object containing value
     * @return  true or false
     ***************************************************************************/  

    public static bool valueIsNativeInteger (Object value)
    {
      if (  
            (value is byte)
         || (value is sbyte)
         || (value is SByte)  
         || (value is ushort) 
         || (value is short) 
	       || (value is uint)  
	       || (value is int)    
	       || (value is ulong)
	       || (value is long)  
	       || (value is UInt16) 
	       || (value is Int16)  
	       || (value is Int32)
	       || (value is UInt32)
	       || (value is UInt64)
	       || (value is Int64) 
	    )    
	    return true; else return false;
    }
   
    /***************************************************************************
     * valueIsNativeFloat */
    /**
     * For a given value determine if it is a native floating point
     *
     * @param   value       Object containing value
     * @return  true or false
     ***************************************************************************/  

    public static bool valueIsNativeFloat (Object value)
    {
      if (  (value is float)  
         || (value is Single) 
         || (value is Double) 
	    )    
	    return true; else return false;
    }
    
    /***************************************************************************
     * valueIsNativeDecimal */
    /**
     * For a given value determine if it is a native decimal
     *
     * @param   value       Object containing value
     * @return  true or false
     ***************************************************************************/  

    public static bool valueIsNativeDecimal (Object value)
    {
      if (  (value is Decimal)  
         || (value is decimal)  
	    )    
	    return true; else return false;
    }
   
    /***************************************************************************
     * valueIsStringInteger */
    /**
     * For a given value determine if the string is an integer
     *
     * @param   value       Object containing value
     * @return  true or false
     ***************************************************************************/  

    public static bool valueIsStringInteger (String value, out long valueInt)
    {           
      return long.TryParse(value, NumberStyles.Integer, new CultureInfo("en-US"), out valueInt);      	    
    } 
    
    /***************************************************************************
     * valueIsStringDecimal */
    /**
     * For a given value determine if the string is a decimal
     *
     * @param   value       Object containing value
     * @return  true or false
     ***************************************************************************/  

    public static bool valueIsStringDecimal (String value, out Decimal valueDecimal)
    {      
      return System.Decimal.TryParse(value, NumberStyles.Currency, new CultureInfo("en-US"), out valueDecimal);
    } 
    
    /***************************************************************************
     * valueIsStringYesNo */
    /**
     * For a given value determine if the string is a decimal
     *
     * @param   value       Object containing value
     * @return  true or false
     ***************************************************************************/  

    public static bool valueIsStringYesNo ( String value, out bool? valueBool )
    {      
    
      valueBool = null;
      
      if (String.IsNullOrEmpty(value)) return false;    
      
      string val = value.ToLower().Trim();  
      
      if (String.IsNullOrEmpty(val)) return false;
    
      switch (val) {
      
        case "y"   : { valueBool = true;  return true;  }
        case "n"   : { valueBool = false; return true;  }
        case "yes" : { valueBool = true;  return true;  }
        case "no"  : { valueBool = false; return true;  }
        default:     { valueBool = null;  return false; }
      }
    
    } 


    /***************************************************************************
     * valueIsStringPercentage */
    /**
     * For a given value determine if the string is a percentage
     *
     * @param   value       Object containing value
     * @return  true or false
     ***************************************************************************/  
    
    public static bool valueIsStringPercentage ( String value, out Double? valueFloat )
    {
      return valueIsStringPercentage (value, true, out valueFloat);
    }
    
    public static bool valueIsStringPercentage ( String value, bool divRetValBy100, out Double? valueFloat )
    {      
      Double v;
      
      if (value.Contains(@"%"))
	    {
	      if ( Double.TryParse ( value.Replace ( @"%", @"" ), out v ) )
	      {	          
	        if ( divRetValBy100 )
	          valueFloat = v / 100d;
	        else
	          valueFloat = v;
	        return true;
	      }
      }
      valueFloat = null;
      return false; 
    }
  
    /***************************************************************************
     * valueIsStringFloat */
    /**
     * For a given value determine if the string is a float
     *
     * @param   value       Object containing value
     * @return  true or false
     ***************************************************************************/  

    public static bool valueIsStringFloat (String value, out Double valueFloat)
    {      
      return System.Double.TryParse (value, NumberStyles.AllowLeadingSign | NumberStyles.AllowDecimalPoint, new CultureInfo("en-US"), out valueFloat);
    } 
        
    /***************************************************************************
     * isValidEmail */
    /**
     * For a given value determine if the string is a valid email address
     * 
     * Note: .NET 3.5 and earlier apparently has issues with validation of emails
     * using the MailAddress constructor (see: http://disq.us/p/116bhqw).
     * 
     * @param   value       Object containing value
     * @return  true or false
     ***************************************************************************/  
    
    static bool isValidEmail (String value) {
      
      /* http://haacked.com/archive/2007/08/21/i-knew-how-to-validate-an-email-address-until-i.aspx/ */
      
      bool result = false;
      
      if (String.IsNullOrEmpty(value)) return result;
      
      try
      {
                       
        string pattern = @"^(?!\.)(""([^""\r\\]|\\[""\r\\])*""|"
                       + @"([-a-z0-9!#$%&'*+/=?^_`{|}~]|(?<!\.)\.)*)(?<!\.)"
                       + @"@[a-z0-9][\w\.-]*[a-z0-9]\.[a-z][a-z\.]*[a-z]$";

        System.Text.RegularExpressions.Regex regex = new System.Text.RegularExpressions.Regex(pattern, System.Text.RegularExpressions.RegexOptions.IgnoreCase);
      
        result = regex.IsMatch(value);
      }
      catch
      {
        result = false;
      }
      
      return result;
    
    }
    
    /***************************************************************************
     * valueIsStringEmail */
    /**
     * For a given value determine if the string is an email address
     *
     * @param   value       Object containing value
     * @return  true or false
     ***************************************************************************/  
    
    public static bool valueIsStringEmail (String value, out System.Net.Mail.MailAddress valueEmail)
    {
      
      /* .NET 3.5 and before has validation issues with MailAddress http://disq.us/p/116bhqw */
      
      if (! isValidEmail(value) ) {
        valueEmail = null;
        return false;
      }
      
      try {
        valueEmail = new System.Net.Mail.MailAddress(value);
        return true;
      } 
      catch(FormatException) {
        valueEmail = null;
        return false;        
      }      
    }
 
   /***************************************************************************
     * valueIsStringUri */
    /**
     * For a given value determine if the string is an Uri
     * 
     * Technique courtesey of http://stackoverflow.com/a/7581824
     *
     * @param   value       Object containing value
     * @return  true or false
     ***************************************************************************/  
    
    public static bool valueIsStringUri ( String value, out Uri valueUri )
    {
     
     
      Uri uriResult;
      bool result;
      result = Uri.TryCreate (value, UriKind.Absolute, out uriResult) 
               && (uriResult.Scheme == Uri.UriSchemeHttp || uriResult.Scheme == Uri.UriSchemeHttps);
     
      valueUri = uriResult;
      return result;     
    }
  
 
   /**************************************************************************
    * valueIsStringDateMonthYear */
   /**
    * 
    ***************************************************************************/

   protected static bool valueIsStringDateMonthYear ( String value, out DateTime valueDate )
   {
     
     string[] formats = new string[] { @"MMM yy"
                                     , @"MMM yyyy"
                                     , @"MMM-yy"
                                     , @"MMM-yyyy"
                                     , @"MMM/yy"
                                     , @"MMM/yyyy" }; 
                                         
     return DateTime.TryParseExact (  value 
                                    , formats
                                    , CultureInfo.InvariantCulture
                                    , DateTimeStyles.AllowWhiteSpaces
                                    , out valueDate );
   }
   
   /**************************************************************************
    * valueIsStringTime */
   /**
    * 
    ***************************************************************************/

   protected static bool valueIsStringTime ( String value, out DateTime valueDate, out TimeSpan? valueTime )
   {
     
     bool     retState;
     
     string[] formats = new string[] {  "h:mm:ss tt"
                                      , "h:mm tt"
                                      , "hh:mm:ss"
                                      , "h:mm:ss"
                                      , "hh:mm tt"
                                      , "hh tt"
                                      , "h:mm"
                                      , "hh:mm" };
                                         
     valueTime = null;
     
     retState  = DateTime.TryParseExact (  value 
                                         , formats
                                         , CultureInfo.InvariantCulture
                                         , DateTimeStyles.AllowWhiteSpaces
                                         , out valueDate );
     
     if (retState) 
       valueTime = valueDate.TimeOfDay;
     
     return retState;
   }
   

   /**************************************************************************
    * ValueDataClass */
   /**
    * 
    ***************************************************************************/

   public enum ValueDataClass
   {
       EMPTY
     , UNKNOWN
     , TIME
     , DATETIME
     , DATETIME_MONTH_YEAR
     , BOOLEAN
     , NUMBER_INTEGER
     , NUMBER_FLOATING
     , NUMBER_FIXED
     , STRING_PERCENTAGE
     , STRING_EMAIL
     , STRING_URI
     , STRING
   }
   
   /**************************************************************************
    * valueDataClassToDtCssClass */
   /**
    * 
    * 
    ***************************************************************************/
   
   public static string valueDataClassToDtCssClass (ValueDataClass valueDataClass)
   {     
     if (valueDataClass == ValueDataClass.EMPTY)               return @"dt-empty";
     if (valueDataClass == ValueDataClass.BOOLEAN)             return @"dt-bool";
     if (valueDataClass == ValueDataClass.DATETIME_MONTH_YEAR) return @"dt-date";
     if (valueDataClass == ValueDataClass.DATETIME)            return @"dt-date";
     if (valueDataClass == ValueDataClass.NUMBER_INTEGER)      return @"dt-numeric";
     if (valueDataClass == ValueDataClass.NUMBER_FIXED)        return @"dt-numeric";
     if (valueDataClass == ValueDataClass.NUMBER_FLOATING)     return @"dt-numeric";
     if (valueDataClass == ValueDataClass.STRING)              return @"dt-string";
     if (valueDataClass == ValueDataClass.STRING_EMAIL)        return @"dt-string";
     if (valueDataClass == ValueDataClass.STRING_URI)          return @"dt-string";
     if (valueDataClass == ValueDataClass.STRING_PERCENTAGE)   return @"dt-string";
     return @"dt-string";
   }
   
   /**************************************************************************
    * identifyAndParseValue */
   /**
    * 
    * 
    ***************************************************************************/

   public static bool identifyAndParseValue (   ref  Object                  value
                                              , out  ValueDataClass          valueDataClass
                                              , out  int                     valueSizeInChars
                                              , out  bool                    valueHasLineBreaks
                                              , out  bool                    valueIsLink
                                              , out  String                  valueString
                                              , out  TimeSpan?               valueTimeSpan
                                              , out  DateTime?               valueDateTime
                                              , out  long?                   valueInteger                                                
                                              , out  Decimal?                valueFixed
                                              , out  Double?                 valueFloating
                                              , out  Boolean?                valueBoolean
                                              , out  MailAddress             valueEmail
                                              , out  Uri                     valueUri)
	 {
	 
	   /*###########################################################################
       # Init
       ###########################################################################*/ 
   
     valueDataClass     = Util.ValueDataClass.EMPTY;
     valueSizeInChars   = 0;
     valueHasLineBreaks = false;
     valueIsLink        = false;
     valueString        = null;
     valueTimeSpan      = null;
     valueDateTime      = null;
	   valueInteger       = null;
	   valueFixed         = null;
	   valueFloating      = null;
	   valueBoolean       = null;
	   valueEmail         = null;
	   valueUri           = null;
	   
	   Double      valDouble;
	   long        valLong;
	   Decimal     valDecimal;
	   Double?     valDoubleOrNull;
	   TimeSpan    valTimeSpan;
	   TimeSpan?   valTimeSpanOrNull;    
	   DateTime    valDateTime;
	   bool        valBool;
	   bool?       valBoolOrNull;	   
	   MailAddress valEmail;
	   Uri         valUri;
	   
	   /*###########################################################################
       # If the value object passed in is null or empty, treat it as an empty string
       ###########################################################################*/ 
      
	   if ( value == null )
	   {
	     valueDataClass = Util.ValueDataClass.EMPTY;
       valueString    = String.Empty;
	     return true;
	   }
	   
	   /*###########################################################################
       # Get string version of value object and determine if it has line breaks
       ###########################################################################*/ 

	   valueString        = value.ToString().Trim();
	   valueHasLineBreaks = Util.valueHasLineBreaks(valueString);
     valueSizeInChars   = valueString.Length;
     
	   /*###########################################################################
       # If the string rep of value is null or empty, cell will be empty
       ###########################################################################*/ 
      
	   if ( String.IsNullOrEmpty ( valueString ) )
	   {
	     valueDataClass = Util.ValueDataClass.EMPTY;
	     valueString    = String.Empty;
	     return true;
	   }
	   
	   /*###########################################################################
       # Native timespan, cell will be time
       ###########################################################################*/ 
    	  	
	   if ( value is TimeSpan)
	   {
	     valueDataClass = Util.ValueDataClass.TIME;
	     TimeSpan.TryParse( valueString, out valTimeSpan ); 
	     valueTimeSpan  = valTimeSpan;
	     return true;
	   }
	   
	   /*###########################################################################
       # Native datetime, cell will be date
       ###########################################################################*/ 

	   if ( value is DateTime ) 
	   {
	     valueDataClass = Util.ValueDataClass.DATETIME;
	     DateTime.TryParse ( valueString, out valDateTime ); 
	     valueDateTime  = valDateTime;
	     return true;
	   }
	    
	   /*###########################################################################
       # Native boolean.  String rep of boolean (Yes/No)
       ###########################################################################*/ 

	   if ( value is Boolean )  
	   {
	     valueDataClass = Util.ValueDataClass.BOOLEAN;
	     
	     Boolean.TryParse ( valueString, out valBool );
	     valueBoolean   = valBool;
	     valueString    = Util.boolToYesNo ( valueBoolean.Value );
       
       return true;
	   }
	    
	   /*###########################################################################
       # Native integer
       ###########################################################################*/ 

	   if ( Util.valueIsNativeInteger ( value ) )	        
	   {
	     valueDataClass = Util.ValueDataClass.NUMBER_INTEGER;
	     
	     long.TryParse ( valueString, out valLong );
	     valueInteger = valLong;
	 
	     Double.TryParse ( valueString, out valDouble );
	     valueFloating  = valDouble;	     
	       	     
	     return true;
	   }
	    
	   /*###########################################################################
       # Value is a native float
       ###########################################################################*/ 

	   if ( Util.valueIsNativeFloat ( value ) )
	   {
	     valueDataClass = Util.ValueDataClass.NUMBER_FLOATING;
	     
	     Double.TryParse ( valueString, out valDouble );
	     valueFloating  = valDouble;
	      
	     return true;
	   }
	    
	   /*###########################################################################
       # Value is a native fixed
       ###########################################################################*/ 

	   if ( Util.valueIsNativeDecimal ( value ) )
	   {
	     valueDataClass = Util.ValueDataClass.NUMBER_FIXED;
	     
	     Decimal.TryParse ( valueString, out valDecimal );
	     valueFixed = valDecimal;
	 
	     Double.TryParse ( valueString, out valDouble );
	     valueFloating = valDouble;	     
	     
	     return true;
	   }
	   	   
	   /*###########################################################################
        # Value is a native string, futher evaluation needed
        ###########################################################################*/ 

	   if ( value is String )
	   {
         /*-------------------------------
          * If the string has line breaks
          * classify this as a string and
          * exit.
          *------------------------------*/
	    
         if (valueHasLineBreaks)
         {
           valueDataClass = ValueDataClass.STRING;
           return true;
         }
         
         /*-------------------------------
          * String is a integer
          *------------------------------*/
	    	        
	     if ( Util.valueIsStringInteger ( valueString, out valLong ) )
	     {
	       valueDataClass = Util.ValueDataClass.NUMBER_INTEGER;
	       valueInteger   = valLong;
	       Decimal.TryParse ( valueInteger.ToString(), out valDecimal);
	       Double.TryParse  ( valueInteger.ToString(), out valDouble );
	       valueFixed     = valDecimal;
	       valueFloating  = valDouble;
	       return true;
	     }
	      	      
	     /*-------------------------------
        * String is a decimal
        *------------------------------*/
	      
	     if ( Util.valueIsStringDecimal ( valueString, out valDecimal ) )
	     {
  	     valueDataClass = Util.ValueDataClass.NUMBER_FIXED;
	       valueFixed     = valDecimal;	         
	       Double.TryParse ( valDecimal.ToString(), out valDouble );	       
	       valueFloating  = valDouble;	       
	       return true;
	     }
	     
	     /*-------------------------------
        * String is a percentage
        *------------------------------*/
	      	     
	     if ( Util.valueIsStringPercentage ( valueString, out valDoubleOrNull ) )
	     {
	       valueDataClass = Util.ValueDataClass.STRING_PERCENTAGE;
	       valueFloating  = valDoubleOrNull;
	       return true;
	     }
	      
	     /*-------------------------------
        * String is a float
        *------------------------------*/

	     if ( Util.valueIsStringFloat ( valueString, out valDouble ) )
	     {
	       valueDataClass = Util.ValueDataClass.NUMBER_FLOATING;
	       valueFloating  = valDouble;
         return true;
	     }

       /*-------------------------------
        * String is a just the month year
        * part of a datetime
        *------------------------------*/	      
	     
	     if ( Util.valueIsStringDateMonthYear ( valueString, out valDateTime ) )
	     {
	       valueDataClass = Util.ValueDataClass.DATETIME_MONTH_YEAR;
	       valueDateTime  = valDateTime;
	       return true;
	     }
	     
	     /*-------------------------------
        * String is a time span
        *------------------------------*/	      

	     if ( Util.valueIsStringTime ( valueString, out valDateTime, out valTimeSpanOrNull) )
	     {
	       valueDataClass = Util.ValueDataClass.TIME;
	       valueDateTime  = valDateTime;
	       valueTimeSpan  = valTimeSpanOrNull;
	       return true;
	     }
	     
	     /*-------------------------------
        * String is a datetime
        *------------------------------*/

	     if ( DateTime.TryParse ( valueString, out valDateTime ) )	    	     
	     {
	       
	       valueDataClass = Util.ValueDataClass.DATETIME;
	       valueDateTime  = valDateTime;
	       return true;
	     }

       /*-------------------------------
        * String is a Yes or No
        *------------------------------*/
	      
	     if ( Util.valueIsStringYesNo ( valueString, out valBoolOrNull ) )
	     {
	       valueDataClass = Util.ValueDataClass.BOOLEAN;
	       valueBoolean   = valBoolOrNull;
	       return true;
	     }
	  
       /*-------------------------------
        * String is an email
        *------------------------------*/
	  
	     if ( Util.valueIsStringEmail ( valueString, out valEmail ) )
	     {
	       valueDataClass = Util.ValueDataClass.STRING_EMAIL;
	       valueEmail     = valEmail;
	       valueIsLink    = true;
	       return true;
	     }

       /*-------------------------------
        * String is an uri
        *------------------------------*/
	     
	     if ( Util.valueIsStringUri ( valueString, out valUri ) )
	     {
	       valueDataClass = Util.ValueDataClass.STRING_URI;
	       valueUri       = valUri;
	       valueIsLink    = true;
	       return true;
	     }
	     
	     /*-------------------------------
        * String is something else
        *------------------------------*/
	     
	     valueDataClass = ValueDataClass.STRING;
	     return true;

	   }
	    
	   /*-------------------------------
      * Value is something else
      * represent it as a string
      *------------------------------*/
      
	   valueDataClass = Util.ValueDataClass.UNKNOWN;    	     
	   return true;
	  
	 }
  

  }
}