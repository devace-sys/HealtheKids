using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Data;
using System.Data.SqlClient;
using System.Reflection;
using System.Collections.ObjectModel;
using System.Web;

namespace MBA
{
  /***************************************************************************
  * PatternMatch */
  /**
  * Text pattern matching
  ***************************************************************************/

  public class PatternMatch
  {
    /***************************************************************************
    * REGEX_EMAIL */
    /**
    * Regex pattern courtesty of David Huyck
    * http://regexlib.com/DisplayPatterns.aspx?cattabindex=2&categoryId=3
    * Matches e-mail addresses, including some of the newer top-level-domain
    * extensions, such as info, museum, name, etc. Also allows for emails
    * tied directly to IP addresses.
    * Matches 	
    * example@example.com | foo@bar.info | blah@127.0.0.1
    * Non-Matches 	
    * broken@@example.com | foo@bar.infp | blah@.nospam.biz
    ***************************************************************************/  

    public static readonly string REGEX_EMAIL_PTRN    = @"^[_a-zA-Z0-9-]+(\.[_a-zA-Z0-9-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.(([0-9]{1,3})|([a-zA-Z]{2,3})|(aero|coop|info|museum|name))$";
    public static readonly Regex  REGEX_EMAIL         = new Regex(REGEX_EMAIL_PTRN,RegexOptions.Compiled);
    
    /***************************************************************************
    * REGEX_BETWEEN_TAGS */
    /**
    * Regex pattern courtesey of 
    * http://optimizeasp.net/remove-whitespace-from-html
    *
    * Matches extra space between html tags
    * When using a replace, you must replace the match with a >
    ***************************************************************************/  

    public static readonly Regex REGEX_BETWEEN_TAGS = new Regex(@">(?! )\s+", RegexOptions.Compiled);
    
    /***************************************************************************
    * REGEX_LINE_BREAKS */
    /**
    * Regex pattern courtesey of 
    * http://optimizeasp.net/remove-whitespace-from-html
    * 
    * Matches line breaks between tags.  
    * Preserves line breaks within tags such as textareas, inline scripts, etc.
    * When using a replace, you must replace the line break with a <
    ***************************************************************************/  

    public static readonly Regex REGEX_LINE_BREAKS = new Regex(@"([\n\s])+?(?<= {2,})<", RegexOptions.Compiled);

    /***************************************************************************
    * REGEX_WHITE_SPACE */
    /**
    * Extra white space
    * Regex pattern courtesey of Mads Kristensen 
    * http://madskristensen.net/post/A-whitespace-removal-HTTP-module-for-ASPNET-20.aspx
    ***************************************************************************/  

    public static readonly Regex REGEX_WHITE_SPACE = new Regex(@"(?<=[^])\t{2,}|(?<=[>])\s{2,}(?=[<])|(?<=[>])\s{2,11}(?=[<])|(?=[\n])\s{2,}", RegexOptions.Compiled);

    /***************************************************************************
     * REGEX_MM_DD_YYYY */
    /**
     * Evaluate if a string contains a date of the form mm/dd/yyyy
     * Regex pattern based on a similar pattern found at:
     * http://www.regular-expressions.info/regexbuddy/datemmddyyyy.html
     ***************************************************************************/  
     
    public static readonly Regex REGEX_MM_DD_YYYY  = new Regex(@"(0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])[- /.](19|20)\d\d", RegexOptions.Compiled);
  }
}
