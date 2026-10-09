using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Data;
using System.Data.SqlClient;
using System.Reflection;
using System.Collections.ObjectModel;
using System.Collections;
using System.Web;
using System.Runtime.Remoting;
using System.Linq;
using System.Globalization;

namespace MBA
{

  /***************************************************************************
   * AdditionalValidation */
  /**
   * Delegate for additional validation
   ***************************************************************************/

  public delegate void AdditionalValidation(Object o);

  /***************************************************************************
   * Validate */
  /**
   * Commonly used data validation tools.  Used for checking incoming data.
   * All methods throw an exception if problems are found.
   ***************************************************************************/

  public class Validate
  {
    /***************************************************************************
     * optParameterHasValue */
    /**
     * If the parameter has a value return true, otherwise return false.
     *
     *
     * @param  value           Incoming valid value
     * @return                 true  = value contains data
     *                         false = value contains nothing
     ***************************************************************************/

    public static bool optParameterHasValue(Object value)
    {
      if (value == null) return false;
      return true;
    }

    /***************************************************************************
     * optParameterGroupAllOrNone */
    /**
     * Either all of the parameters must be defined or none.
     *
     *
     * @param  msg             Error message
     * @param  parms           Optional parameters
     * @return                 true  = All or none are not null
     ***************************************************************************/

    public static bool optParameterGroupAllOrNone (string msg, params Object[] parms)
    {
      int numParmsPassedIn = parms.Length;
      int  numNonNull      = 0;

      if (numParmsPassedIn == 0) return true;
      foreach (Object p in parms) if (p != null) numNonNull++;
      if (numNonNull == 0) return true;
      if (numNonNull == numParmsPassedIn) return true;
      throw new Critical(msg);
    }

    /***************************************************************************
     * optParameterGroupOneOrMore */
    /**
     * At least one of the parms must be not null
     *
     * @param  msg             Error message
     * @param  parms           Optional parameters
     * @return                 true  = At least one is not null
     ***************************************************************************/

    public static bool optParameterGroupOneOrMore (string msg, params Object[] parms)
    {
      int numParmsPassedIn = parms.Length;
      int  numNonNull      = 0;
      if (numParmsPassedIn == 0) throw new Critical(msg);
      foreach (Object p in parms) if (p != null) numNonNull++;
      if (numNonNull > 0) return true;
      throw new Critical(msg);
    }

    /***************************************************************************
     * optRecIDMultiStr
    /**
     *
     * If value is not not check to see it its a valid multi record id string
     *
     ***************************************************************************/

    public static string optRecIDMultiStr (string value, string msg)
    {
      if(Util.IsNullOrEmpty(value)) return null;
      return reqRecIDMultiStr(value,msg);
    }
    
    /***************************************************************************
     * optFlagToBool */
    /**
     * Converts a valid value to a boolean.  Throws an exception if it cannot
     * do this.  Also if strict is true throws an exception if the incoming value
     * does not contain a value.
     *
     * @param  value           Incoming valid value
     * @param  strict          true  = throw warning if value contains nothing
     * @return                 true  = if value is true
     *                         false = if value is false or (if strict is false)
     *                                 if value contains nothing
     ***************************************************************************/

    public static bool optFlagToBool (object value, bool strict) // <---- TODO: Consider removing this function entirely; optFlag() is flexible enough to replace this completely
    {

      bool _tempFlag = false;

      if (optParameterHasValue(value))
      {
        try
        {
          _tempFlag = Convert.ToBoolean(value);
            //  https://msdn.microsoft.com/en-us/library/86hw82a3(v=vs.110).aspx
          // for string values, this function can interpret "true" and "false" only.
          // cannot interpret "yes", "no", "Y", "N", "0", "1", or anything of the sort.
          // it most certainly cannot interpret "I don't know", "Unknown", "U".

          // TODO: Maybe create a utility function that can interpret the input from one of our Yes-No-I-Don't-Know controls.

        }
        catch
        {
          throw new Warning(Messages.INVALID_BOOL);
        }
      }
      else
      {
        if (strict) throw new Warning(Messages.INVALID_BOOL);
      }
      return _tempFlag;
    }

    /***************************************************************************
     * optBase64String */
    /**
     * If value is provided checks to see if value is a valid base64 encoded string
     * Otherwise it returns a null
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value 
     ***************************************************************************/

    public static string optBase64String (string value, string msg, bool stringIsDataUrl = true)
    {
      if(String.IsNullOrWhiteSpace(value)) return null;
      return reqBase64String (value,msg,stringIsDataUrl);
    }
    
    /***************************************************************************
     * optDate */
    /**
     * If the value is provided it checks to see if value is a valid date.
     * Otherwise it returns a null.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as string
     ***************************************************************************/

    public static Object optDate (string value, string msg)
      {return optDate(value,msg,Constants.VAL_OPT_DATE_NONE);}

    public static Object optDate (string value, string msg, int validateOption)
    {
      if(Util.IsNullOrEmpty(value)) return null;
      return reqDate(value,msg,validateOption);
    }

    /***************************************************************************
     * optTime */
    /**
     * If the value is provided it checks to see if value is a valid time
     * Otherwise it returns a null.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as string
     ***************************************************************************/

    public static Object optTime (string value, string msg)
    {
      if (Util.IsNullOrEmpty(value)) return null;
      return reqTime(value,msg);
    }


    /***************************************************************************
     * optTimeStr */
    /**
     * If the value is provided it checks to see if value is a valid time
     * Otherwise it returns a null.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as string
     ***************************************************************************/

    public static Object optTimeStr (string value, string msg)
    {
      if (Util.IsNullOrEmpty(value)) return null;
      return reqTimeStr(value,msg);
    }

    /***************************************************************************
     * optStartAndEndDate */
    /**
     ***************************************************************************/

    public static Object[] optStartAndEndDate (string startdate, string enddate, string msg)
    {
      Object[] dto = new Object[2];
      dto[0] = null;
      dto[1] = null;

      if (Util.IsNullOrEmpty(startdate)) return dto;
      if (Util.IsNullOrEmpty(enddate))   return dto;

      DateTime[] dtv = reqStartAndEndDate(startdate,enddate,msg);
      dto[0] = (Object) dtv[0];
      dto[1] = (Object) dtv[1];

      return dto;
    }

    /***************************************************************************
     * optEmail */
    /**
     * If the value is provided it checks to see if value is a valid email.
     * Otherwise it returns a null.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as string
     ***************************************************************************/

    public static object optEmail (string value, string msg)
    {
      if(Util.IsNullOrEmpty(value)) return null;
      return reqEmail(value,msg);
    }

    /***************************************************************************
     * optString */
    /**
     * If the value is provided it checks to see if value is a valid string.
     * Otherwise it returns a null.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as string
     ***************************************************************************/

    public static string optString(string value){return optString(value,0,"",true);}
    public static string optString(string value, string msg){return optString(value,0,msg,true);}
    public static string optString(string value, int length, string msg, bool sanitize = true)
    {
      if(Util.IsNullOrEmpty(value)) return null;
      return reqString(value,length,msg, sanitize);
    }

   /***************************************************************************
    * optSSN */
   /**
    * If the value is provided it checks to see if value is a valid ssn.
    * Otherwise it returns a null.
    *
    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 value as string
    ***************************************************************************/

    public static string optSSN (string value, string msg)
    {
      if (Util.IsNullOrEmpty(value)) return null;
      return reqSSN(value,msg);
    }

    /***************************************************************************
     * optInteger */
    /**
    * If the value is provided it checks to see if value is a valid integer.
    * Otherwise it returns a null.
    *
    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 Integer in an object or null
    ***************************************************************************/

    public static object optInteger (string value, string msg)
    {
      if(Util.IsNullOrEmpty(value)) return null;
      return reqInteger(value,msg);
    }

    public static object optIntegerReturnNullIfValueIsZero (string value, string msg)
    {
        var validatedVal = optInteger( value, msg, true );
        if ((validatedVal != null) && ((int) validatedVal == 0)){
          return null;
        }          
        return validatedVal;
    }

        public static object optInteger (string value, string msg, bool allowZero)
    {
      if(Util.IsNullOrEmpty(value)) return null;
      return reqInteger(value,msg,allowZero);
    }

    /***************************************************************************
     * optFixed */
    /**
    * If the value is provided it checks to see if value is a valid fixed number.
    * Otherwise it returns a null.
    *
    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 Integer in an object or null
    ***************************************************************************/

    public static object optFixed (string value, string msg)
    {
      if(Util.IsNullOrEmpty(value)) return null;
      return reqFixed(value,msg);
    }

    /***************************************************************************
     * optUsdAmount */
    /**
     ***************************************************************************/

    public static Object optUsdAmount (string value, string msg)
    {
      if(String.IsNullOrWhiteSpace(value)) return null;
      return reqUsdAmount(value,msg);
    }

    /***************************************************************************
     * optFlag */
    /**
     * If the value is provided it checks to see if value is a valid flag.
     * Otherwise it returns a null or false depending on the value of
     * nullOrBlankIsFalse.
     *
     * @param  value               Incoming value
     * @param  msg                 Invalid value message
     * @param  nullOrBlankIsFalse  Treat nulls or blanks as false
     * @return                     Boolean in an object or null
     ***************************************************************************/


    public static Object optFlag (string value, string msg)
    {
      return optFlag(value,msg,false);
    }

    public static Object optFlag (string value, string msg, bool nullOrBlankIsFalse)
    {
      /*-------------------------------
       * If we are not treating nulls
       * or blanks as false then return
       * null if the value is null or
       * blank
       *------------------------------*/

      if (!nullOrBlankIsFalse)
        if(Util.IsNullOrEmpty(value)) return null;

      /*-------------------------------
       * Evaluate value passed in
       *------------------------------*/

      return reqFlag(value,msg,nullOrBlankIsFalse);
    }

    public static Object optFlag (string value, string msg, bool nullOrBlankIsReplacementValue, bool replacementValue)
    {
      /*-------------------------------
       * If we are not treating nulls
       * or blanks as a replacement value
       * then return null
       *------------------------------*/

      if (!nullOrBlankIsReplacementValue)
        if(Util.IsNullOrEmpty(value)) return null;

      /*-------------------------------
       * Evaluate value passed in
       *------------------------------*/

      return reqFlag(value,msg,nullOrBlankIsReplacementValue,replacementValue);

    }

    /***************************************************************************
     * optFlagYNUnknowwn */
    /**
     * Checks for proper Yes, No, Unknown
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 Phone number in an object or null
     ***************************************************************************/

    public static Object optFlagYNUnknown (string value, string msg)
    {
      if (Util.IsNullOrEmpty(value)) return null;
      String compstr = value.ToLower().Trim();
      if ((compstr == "unknown") || (compstr == "u"))
        return null;

      return optFlag(compstr, msg);
    }

    /***************************************************************************
     * optPhoneNumber */
    /**
    * If the value is provided it checks to see if value is a valid phone number
    * Otherwise it returns a null.
    *
    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 Phone number in an object or null
    ***************************************************************************/

    public static object optPhoneNumber (string value, string msg)
    {
      if(Util.IsNullOrEmpty(value)) return null;
      return reqPhoneNumber(value,msg);
    }

    /***************************************************************************
     * optZip5 */
    /**
    * If the value is provided it checks to see if value is a valid zip5
    * Otherwise it returns a null.
    *
    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 Zip5 in an object or null
    ***************************************************************************/

    public static string optZip5 (string value, string msg, bool attemptSalvage = false)
    {
      if(Util.IsNullOrEmpty(value)) return null;
      return reqZip5(value,msg,attemptSalvage);
    }

    /***************************************************************************
     * optZip4 */
    /**
    * If the value is provided it checks to see if value is a valid zip4
    * Otherwise it returns a null.
    *
    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 Zip4 in an object or null
    ***************************************************************************/

    public static object optZip4 (string value, string msg)
    {
      if(Util.IsNullOrEmpty(value)) return null;
      return reqZip4(value,msg);
    }


   /***************************************************************************
    * optNPI */
   /**
    * If value is provided checks to see if it is valid, otherwise returns
    * a null
    *
    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 value as string
    ***************************************************************************/

   public static string optNPI (string value)
   {
     return optNPI(value,Messages.INVALID_NPI);
   }

   public static string optNPI (string value, string msg)
   {
     if(Util.IsNullOrEmpty(value)) return null;
     value = reqNPI(value,msg);
     return value;
   }

   /***************************************************************************
    * optGuid */
   /**
    * Checks to see if value is a valid GUID if its provided.    
    * Throws an exception using msg as the error message if not valid.
    * If not provided returns a null.

    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 value 
    ***************************************************************************/
    public static Object optGuid (string value, string msg)
    {
       if (Util.IsNullOrEmpty(value)) return null;
       return reqGuid(value, msg);
    }

    /***************************************************************************
     * optObject */
    /**
     * If the value is provided it checks to see if value is valid object of type
     * className
     *
     * Otherwise it returns a null.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @param  classAssembly   Name of assembly where class can be found
     * @param  className       Name of class itself
     * @return                 value as a object or null.  You must cast to use.
     ***************************************************************************/

    public static object optObject (string value, string msg, string classAssembly, string className, AdditionalValidation av)
    {
      if(Util.IsNullOrEmpty(value)) return null;
      return reqObject (value, msg, classAssembly, className, av);
    }

    /***************************************************************************
     * optGotoPage */
    /**
     * Checks to see if value is a valid goto page for login redirects
     *
     ***************************************************************************/

    public static string optGotoPage(string value)
    {
      if (String.IsNullOrWhiteSpace(value)) return String.Empty;
      return reqGotoPage(value);
    }
    
    /***************************************************************************
     * reqGotoPage */
    /**
     * Checks to see if value is a valid goto page for login redirects
     *
     ***************************************************************************/
    
    public static string reqGotoPage (string value)
    {
      if (String.IsNullOrWhiteSpace(value)) throw new Critical (Messages.INVALID_GOTO_PAGE);
      var valueOut  = Util.removeWhiteSpace(value);
      var isValid = Regex.IsMatch(valueOut,@"^[A-z|_]+.aspx$");      
      if (!isValid) throw new Critical (Messages.INVALID_GOTO_PAGE);
      return valueOut;
    }

    /***************************************************************************
     * reqObject */
    /**
     * Checks to see if value is a valid object of type className
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @param  classAssembly   Name of assembly where class can be found
     * @param  className       Name of class itself
     * @return                 value as a object.  You must cast to use.
     ***************************************************************************/
    public static Object reqObject (string value, string msg, string classAssembly, string className)
    {
      return reqObject(value,msg,classAssembly,className,null);
    }

    public static Object reqObject (string value, string msg, string classAssembly, string className, AdditionalValidation av)
    {

      /*-------------------------------
       * Check for classAssemby and
       * className
       *------------------------------*/

      if ( Util.IsNullOrEmpty (classAssembly) ) throw new Critical ("Class assembly is required");
      if ( Util.IsNullOrEmpty (className)     ) throw new Critical ("Class name is required");

     /*-------------------------------
      * If value is empty we get out
      *------------------------------*/

      value = reqString(value, msg);

      /*-------------------------------
       * Otherwise we should have some
       * serialized form of the object
       * (in JSON) and we attempt to
       * parse it.
       *------------------------------*/

      try
      {

        /*-------------------------------
         * Create an instance of the
         * expected incoming class and
         * extract its type definition
         *------------------------------*/

        ObjectHandle oh  = Activator.CreateInstance (classAssembly, className);
        Type         ot  = oh.Unwrap().GetType();

        /*-------------------------------
         * Attempt to deserialize value
         * and return it
         *------------------------------*/

        Object o = JSON.fromJSONString(value, ot);

        /*-------------------------------
         * Perform additional validation
         * on o
         *------------------------------*/

        if (av != null)
          av(o);

        return o;

      }
      catch (AppException ae)
      {
        throw new Critical(ae.Message);
      }
      catch (Exception err)
      {
        throw new Critical(msg);
      }
    }

    /***************************************************************************
     * reqGuid */
    /**
     * Checks to see if value is a valid GUID
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value 
     ***************************************************************************/
     public static Guid reqGuid (string value, string msg)
     {
       Guid _result;
       if (!Guid.TryParse(value, out _result)) throw new Critical(msg);
       return _result;
     }

    /***************************************************************************
     * reqBase64String */
    /**
     * Checks to see if value is a valid base64 encoded string
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value 
     ***************************************************************************/

    public static string reqBase64String (string value, string msg, bool stringIsDataUrl = true)
    {
      value = reqString(value, msg); 
      string base64Data = value;

      try
      {
   
        if (stringIsDataUrl) 
          base64Data = Regex.Match(value, @"data:image/(?<type>.+?),(?<data>.+)").Groups["data"].Value;
       
        Convert.FromBase64String(base64Data);
      }
      catch (Exception e)
      {
        throw new Critical(msg);
      }
      return value;
    }

    /***************************************************************************
     * reqCDSCode */
    /**
     * Checks to see if value is a valid CDS code (14 character, all numbers)
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value 
     ***************************************************************************/

    public static string reqCDSCode (string value, string msg)
    {
     
     /* Check if value is passed and trim it */
      
      value = reqString(value, msg);
      
      /* Check for and convert if incoming value is in scientific notation */

      value = Util.convertScientificNotationStringToNumberString(value);

      /* Remove any delimeters, etc.  Note: If value was in sci notation this would probably not have delimiters */
      
      value = Util.removeAllNonNumeric(value);
      
      /* Reinstate any leading 0s that might have been lost */
      
      if (value.Length < 14) value = value.PadLeft(14,'0');                
      
      /* Finally test value.  Needs to be a 14 digit string */

      if (Util.isNDigitInteger(value, 14)) return value; else throw new Critical(msg);   

    }

    /***************************************************************************
     * reqCdsSiteCode */
    /**
     * Checks to see if value is a valid site portion of a CDS code 
     * (7 characters, all numbers)
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value 
     ***************************************************************************/

    public static string reqCdsSiteCode (string value, string msg)
    {
    
      /* Check if value is passed and trim it */
      
      value = reqString(value, msg);
      
      /* Remove any delimeters, etc*/
      
      value = Util.removeAllNonNumeric(value);
            
      /* Reinstate any leading 0s that might have been lost */

      value = value.PadLeft(7,'0');                
      
      if (value == "0000000") throw new Critical(msg);

      if (Util.isNDigitInteger(value, 7)) return value; else throw new Critical(msg);   

    }

    /***************************************************************************
     * reqCdsFullOrSchoolCode */
    /**
     * Checks to see if value is either a 
     *
     * - valid full CDS code (14 character, all numbers)
     * - or a valid site portion of a cds code
     * 
     * Note: The caller will be responsible for filling in the missing county
     *       and district code portions of the value if this is 
     *       just a site portion
     * 
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value 
     ***************************************************************************/

    public static string reqCdsFullOrSchoolCode (string value, string msg)
    {
    
      /* Check if value is passed and trim it */
      
      value = reqString(value, msg);
      
      /* Remove any delimeters, etc*/
      
      value = Util.removeAllNonNumeric(value);
      
      /* Get length */

      int _valLen = value.Length;

      /* If the size of the value is outside anticipated norms exit with error */
      
      if (_valLen == 0) throw new Critical(msg);
      if (_valLen > 14) throw new Critical(msg);

      /* If the size of the value is more than 7 characters, attempt to validate full cds */
      
      if (_valLen > 7)
      {
        return reqCDSCode(value,msg);
      }
            
      /* Else if the size of the value is 7 characters or less, attempt to validate site portion */
      
      else if (_valLen <= 7)
      {
        return reqCdsSiteCode(value,msg);
      }

      /* We get here, somethings up.  Exit with an error.*/
      else
      {
       throw new Critical(msg);      
      }
    
    }

    /***************************************************************************
     * optCdsFullOrSchoolCode */
    /**
     * @return                 value 
     ***************************************************************************/

    public static string optCdsFullOrSchoolCode (string value, string msg)
    {
      if (String.IsNullOrWhiteSpace(value)) return null;
      return reqCdsFullOrSchoolCode(value,msg);
    }

    /***************************************************************************
     * optCDSCode */
    /**
     * @return                 value 
     ***************************************************************************/
    public static string optCDSCode (string value, string msg)
    {
      if (String.IsNullOrWhiteSpace(value)) return null;
      return reqCDSCode(value,msg);
    }

    /***************************************************************************
     * optCdsSiteCode */
    /**
     * @return                 value 
     ***************************************************************************/
    public static string optCdsSiteCode (string value, string msg)
    {
      if (String.IsNullOrWhiteSpace(value)) return null;
      return reqCdsSiteCode(value,msg);
    }


    /***************************************************************************
     * reqCSISOrSSID */
    /**
     * Checks to see if value is a valid CSIS or SSID code (10 character, all numbers)
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as a datetime
     ***************************************************************************/

    public static string reqCSISOrSSID (string value, string msg)
    {
      
      /* Ensure value is passed in and trim it*/

      value = reqString(value, msg);
      
      /* Remove any internal delimiters*/

      value = Util.removeAllNonNumeric(value);
      
      /* Reinstate any leading 0s that might have been lost */

      value = value.PadLeft(10,'0');                

      /* Finally check if the value is a 10 digit integer.  If not then get out */

      if (Util.isNDigitInteger(value, 10)) return value; else throw new Critical(msg);   
    }

    /***************************************************************************
     * optCSISOrSSID */
    /**
     * @return                 value as a datetime
     ***************************************************************************/
    public static string optCSISOrSSID (string value, string msg)
    {
      if (String.IsNullOrWhiteSpace(value)) return null;
      return reqCSISOrSSID(value,msg);
    }
    
    /***************************************************************************
     * reqTime */
    /**
     * Checks to see if value is a valid time number.  Returns value as a
     * timespan
     *
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as a datetime
     ***************************************************************************/

    public static TimeSpan reqTime (string value, string msg)
    {
      // Determins if a time value is valid and returns a timspan
      // We could use a regex but the convert method is very flexible with
      // quite a large variety of formats and it will throw an invalid cast
      // exception if it can't convert the incoming date.

      value = reqString(value, msg);

      try
      {

        DateTime dt;
        TimeSpan ts;

		    // Convert to datetime 1st.  Datetime provides a great deal of flexibility in converting the
		    // time component.

		    if(!DateTime.TryParse(value,out dt))
			    throw new Critical(msg);

			  // Then extract the time portion and return

			  ts = dt.TimeOfDay;
			  return ts;

      }
      catch
      {
        throw new Critical(msg);
      }
    }

    /***************************************************************************
     * reqTimeStr */
    /**
     * Checks to see if value is a valid time Returns value as a string.
     *
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as a string
     ***************************************************************************/

    public static string reqTimeStr (string value, string msg)
    {

      value = reqString(value, msg);

      try
      {

        DateTime dt;

		    // Convert to datetime.  Datetime provides a great deal of flexibility in converting the
		    // time component.

		    if(!DateTime.TryParse(value,out dt)) throw new Critical(msg);

			  // Then extract the time portion and return

			  return dt.ToShortTimeString();
      }
      catch
      {
        throw new Critical(msg);
      }

    }

    /***************************************************************************
     * reqDate */
    /**
     * Checks to see if value is a valid date/time
     * number.  Returns value as an datetime.
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @parm   validateOption  Additional validations to perform on date
     * @return                 value as a datetime
     ***************************************************************************/

    public static DateTime reqDate (string value, string msg)
      {return reqDate(value,msg,Constants.VAL_OPT_DATE_NONE);}

    public static DateTime reqDate (string value, string msg, int validateOption){
      return reqDate(value,msg,validateOption,Constants.CONV_OPT_DATE_NONE);
    }

    public static DateTime reqDate (string value, string msg, int validateOption, int convertOption)
    {
      /* Determins if a date/time is valid and returns a data time value */
      
      /* First check if the value has been provided */
      
      value = reqString(value, msg);
      
      DateTime dv;
      bool valueIsOK = false;

      /* Then attempt to parse with the systems current culture rules (assuming USA).  
       * This method is fairly flexible and should catch most common cases of dates used */
      
      valueIsOK = DateTime.TryParse(value,out dv);
     
      /* If that did not work then remove all non numeric characters and try some known variants */
            
      value = Util.removeAllNonNumeric(value);

      /* Try year month day variant */

      if (!valueIsOK) 
      { 
        valueIsOK = DateTime.TryParseExact(value ,@"yyyyMMdd", CultureInfo.InvariantCulture, DateTimeStyles.None, out dv);
      }
      
      /* TODO: Add additional variants here as needed*/

      /* If we reach this point and the value is still not a valid date then get out */
      
      if (!valueIsOK)
      {
        throw new Critical(msg);
      }

      /* Otherwise see if there are any other validation options we need to apply*/
   
      switch (validateOption)
      {
          case Constants.VAL_OPT_DATE_NO_FUTURE:
          {
            /* Check the date component of value passed in against the date component of todays date */
            DateTime td = DateTime.Now;
            if (DateTime.Compare(dv.Date,td.Date) > 0) throw new Critical(msg);
            break;
          }
          case Constants.VAL_OPT_DATE_NONE : {break;}
          default                          : {break;}
      }
      
      /* Now check if the date is earlier than allowed */

      if (DateTime.Compare(Rules.MIN_DATE,dv.Date) > 0)
      {         
        throw new Critical(msg + @" (you entered a date that was before " + Rules.MIN_DATE.ToLongDateString() + @" please try using a 4 digit year)");
      }

      /* If we reach this point then we have a valid date, exit*/

      return dv;
            
    }

    /***************************************************************************
     * reqStartAndEndDates */
    /**
     * Checks to see if value is a valid date range.  Returns range as array of
     * datetime values.
     *
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  startdate       Start date string
     * @param  enddate         End date string
     * @return                 value as a datetime array
     ***************************************************************************/

    public static DateTime[] reqStartAndEndDate (string startdate, string enddate, string msg)
    {
      DateTime[] dates = null;

      DateTime sdate = reqDate(startdate, msg);
      DateTime edate = reqDate(enddate,   msg);

      if (sdate > edate) throw new Critical(msg);

      dates = new DateTime[2];

      dates[0] = sdate;
      dates[1] = edate;

      return dates;
    }

    /***************************************************************************
     * reqDateRange */
    /**
     * Checks to see if value is a valid date range.  Returns range as array of
     * datetime values.
     *
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as a datetime array
     ***************************************************************************/

    public static DateTime[] reqDateRange (string value, string msg)
    {
      try
      {

        DateTime[] dates        = new DateTime[2];
        string     startDateStr = "";
        string     endDateStr   = "";
        DateTime   startDate;
        DateTime   endDate;

        /*----------------------------
         * Make sure value is provided
         *----------------------------*/

        string v = reqString(value, msg);

        /*----------------------------
         * Parse (split) the date range
         * into seperate start
         * and end date strings
         *----------------------------*/

        Util.parseDateRange(v, out startDateStr, out endDateStr);

        /*----------------------------
         * Parse the start and end date
         * strings into start and end
         * datetime values
         *----------------------------*/

        if (!DateTime.TryParse(startDateStr, out startDate)) throw new Critical(msg);
        if (!DateTime.TryParse(endDateStr,   out endDate))   throw new Critical(msg);

        /*----------------------------
         * Return those values
         *----------------------------*/

        dates[0] = startDate;
        dates[1] = endDate;

        return dates;
      }
      catch
      {
        throw new Critical(msg);
      }
    }

    /***************************************************************************
     * reqRecIDMulti */
    /**
     * Checks to see if value is a valid multi record id csv string.
     * Returns array of record ids.
     *
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as a int array
     ***************************************************************************/

    public static int[] reqRecIDMulti (string value, string msg)
    {

      try
      {

        /*-------------------------------
         * Parse incoming csv recID string
         * Note: The parse takes care of
         * all of the validation steps.
         *------------------------------*/

        int[] recids = Parse.multiInt(value, msg);
        return recids;

      }
      catch
      {
        throw new Critical(msg);
      }
    }

    /***************************************************************************
     * reqRecIDMultiStr */
    /**
     * Checks to see if value is a valid multi record id csv string.
     * Returns original csv string
     *
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as a int array
     ***************************************************************************/

    public static string reqRecIDMultiStr (string value, string msg)
    {
      int[] recIDVals = reqRecIDMulti(value,msg);
      return value.Trim();
    }

    /***************************************************************************
     * reqDateMulti */
    /**
     * Checks to see if value is a valid multiple date value
     * Returns value as an datetime array
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @parm   validateOption  Additional validations to perform on date
     * @parm   convertOption   Convert options for date conversion
     * @return                 value as a datetime array
     ***************************************************************************/

    public static DateTime[] reqDateMulti (string value, string msg, int validateOption, int convertOption)
    {
      try
      {

        /*-------------------------------
         * Parse incoming csv date string
         * Note: The parse takes care of
         * all of the validation steps.
         *------------------------------*/

        DateTime[] dates = Parse.multiDate(value, validateOption , convertOption, msg);

        return dates;
      }
      catch
      {
        throw new Critical(msg);
      }
    }

    /***************************************************************************
     * reqEmail */
    /**
     * Checks to see if value is a valid email address
     * number.  Returns value as an string.
     * Throws an exception using msg as the error message if not valid.
     *
     * Courtesey of : http://stackoverflow.com/a/1903368
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as string
     ***************************************************************************/

    public static string reqEmail (string value, string msg)
    {

      value = reqString(value, msg);

      bool goodEmail = false;
      try {
        System.Net.Mail.MailAddress ma = new System.Net.Mail.MailAddress(value);
        goodEmail = true;
      }
      catch(FormatException) {
        goodEmail = false;
      }

      if (!goodEmail) {
        throw new Exception(msg);
      }

      return value;
    }

    /***************************************************************************
     * reqEmails */
    /**
     * Checks to see if value is a valid email address or delimited string of
     * emails.  Returns array of emails.
     *
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as string
     ***************************************************************************/

    public static string[] reqEmails (string value, string msg)
    {
      return reqEmails(value,Email.COMMON_EMAIL_DELIMITERS, msg);
    }

    public static string[] reqEmails (string value, char[] delimiters, string msg)
    {
      string       emailsStr = reqString(value,msg);
      string[]     emailsArr = Email.parseEmailString(emailsStr, delimiters);
      List<String> emailsLst = new List<string>();

      foreach (string emailStr in emailsArr)
      {
        string emailVal = reqEmail(emailStr,msg);
        
        if (emailsLst.Contains(emailVal))
          continue;
        else
          emailsLst.Add(emailVal);
      }

      if (emailsLst.Count == 0) throw new Critical(msg);

      return emailsLst.ToArray();
    }

    /***************************************************************************
     * reqFixed */
    /**
     * Checks to see if value is a valid fixed (decimal) number.
     * Returns value as an decimal.
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as decimal
     ***************************************************************************/

    public static Decimal reqFixed (string value, string msg)
    {
      // Regex patter courtesy of Andrew van der Stock, http://regexlib.com/DisplayPatterns.aspx?cattabindex=2&categoryId=3
      // Matches positive whole numbers with exactly zero or two decimal points if a . is present. Useful for checking currency amounts, such 5 or 5.00 or 5.25.
      // Matches
      // 1 | 1.23 | 1234.45
      // Non-Matches
      // a1.34 | 1.23a | a
      value = reqString(value, msg);
      string pattern = @"^\d+(?:\.\d{0,2})?$";
      if (Regex.IsMatch(value,pattern)){return Convert.ToDecimal(value);}
      else{throw new Warning(msg);}
    }

    /***************************************************************************
     * reqFlag */
    /**
     * Checks to see if value is a valid flag (true/false, yes/no, etc)
     * number.  Returns value as an bool.
     *
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value               Incoming value
     * @param  msg                 Invalid value message
     * @param  nullOrBlankIsFalse  Treat null or blank values as false
     * @return                     Value as a bool
     ***************************************************************************/

    public static bool reqFlag (string value, string msg)
    {
      return reqFlag(value,msg,false);
    }

    public static bool reqFlag (string value, string msg, bool nullOrBlankIsFalse)
    {

      /*-------------------------------
       * If we are treating null or
       * blank values as false
       * return a false if the value
       * is null or blank
       *------------------------------*/

      if (nullOrBlankIsFalse)
        if (Util.IsNullOrEmpty(value))
          return false;

      /*-------------------------------
       * Otherwise evaluate it
       *------------------------------*/

      value = reqString(value, msg);
      bool? val = Util.evaluateFlag(value, false);

      /*-------------------------------
       * And return result or throw
       * warning
       *------------------------------*/

      if (val.HasValue) return (bool) val;
      else              throw new Warning(msg);
    }

    public static bool reqFlag (string value, string msg, bool nullOrBlankIsReplacementValue, bool replacementValue)
    {

      /*-------------------------------
       * If we are treating null or
       * blank values as false
       * return a false if the value
       * is null or blank
       *------------------------------*/

      if (nullOrBlankIsReplacementValue)
        if (Util.IsNullOrEmpty(value))
          return replacementValue;

      /*-------------------------------
       * Otherwise evaluate it
       *------------------------------*/

      value = reqString(value, msg);
      bool? val = Util.evaluateFlag(value,false);

      /*-------------------------------
       * And return result or throw
       * warning
       *------------------------------*/

      if (val.HasValue) return (bool) val;
      else              throw new Warning(msg);

    }

    /***************************************************************************
     * reqFlagOrUnknown */
    /**
     * Checks to see if value is a valid flag (true/false, yes/no, unknown, etc)
     * number.  Returns value as an bool.
     * If blank or null, a null will be returned.
     *
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value               Incoming value
     * @param  msg                 Invalid value message
     * @return                     Value as a bool
     ***************************************************************************/

    public static Object reqFlagOrUnknown (string value, string msg)
    {
      /* Value is null so we treat this as unknown and return a null */

      if (Util.IsNullUnknownOrEmpty(value)) return null;

      /* Otherwise value better be a valid flag.. otherwise an exception will be thrown using msg as the message */

      return reqFlag (value, msg, false);
    }

    /***************************************************************************
     * reqFloat */
    /**
     * Checks to see if value is a valid floating (single, or double) point
     * number.  Returns value as an Double
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as double
    ***************************************************************************/

    public static Double reqFloat(string value, string msg)
    {
      // Regex pattern courtesy of Steven Smith, http://regexlib.com/DisplayPatterns.aspx?cattabindex=2&categoryId=3
      // Matches any floating point numer/numeric string, including optional sign character (+ or -). Also matches empty strings.
      // Matches
      // 123 | +3.14159 | -3.14159
      // Non-Matches
      // abc | 3.4.5 | $99.95
      value = reqString(value, msg);
      string pattern = @"^[-+]?\d*\.?\d*$";
      if (Regex.IsMatch(value,pattern)){return Convert.ToDouble(value);}
      else{throw new Warning(msg);}
    }

    /***************************************************************************
     * reqFixedAmount */
    /**
     * Checks to see if value is a valid fixed amount.  This is almost the same
     * as validUSDAmount except we dont allow currency sign
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as double
     ***************************************************************************/
    public static Decimal reqFixedAmount (string value, string msg)
    {
      
      value = reqString(value, msg);
      
      var style = System.Globalization.NumberStyles.Number 
                | System.Globalization.NumberStyles.AllowDecimalPoint
                | System.Globalization.NumberStyles.AllowThousands;

      var culture = System.Globalization.CultureInfo.CreateSpecificCulture("en-US");
      
      var result = 0m;

      if (!Decimal.TryParse(value, style, culture, out result)) throw new Warning(msg);
      return result;
    }

    /***************************************************************************
     * optFixedAmount */
    /**
     * If value is not provided returns null.  Otherwise checks to see if value
     * is a valid fixed amount.  This is almost the same as validUSDAmount except 
     * we dont allow currency sign
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as double
     ***************************************************************************/
    public static Object optFixedAmount (string value, string msg)
    {      
      if (String.IsNullOrWhiteSpace(value)) return null;
      return reqFixedAmount(value,msg);
    }


    /***************************************************************************
     * reqUsdAmount */
    /**
     * Checks to see if value is a valid US dollar amount
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as double
     ***************************************************************************/
    public static Decimal reqUsdAmount (string value, string msg)
    {
      
      value = reqString(value, msg);
      
      var style = System.Globalization.NumberStyles.Number 
                | System.Globalization.NumberStyles.AllowCurrencySymbol
                | System.Globalization.NumberStyles.AllowDecimalPoint
                | System.Globalization.NumberStyles.AllowThousands;

      var culture = System.Globalization.CultureInfo.CreateSpecificCulture("en-US");
      
      var result = 0m;

      if (!Decimal.TryParse(value, style, culture, out result)) throw new Warning(msg);
      return result;
    }

    /***************************************************************************
     * reqTinyInt */
    /**
     * Checks to see if value is a valid 8 bit integer (tiny int)
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as byte
     ***************************************************************************/

    public static byte reqTinyInt (string value, string msg)
    { 
        value = reqString(value, msg);
        byte valByte;
        if (!byte.TryParse(value,out valByte)) throw new Warning(msg);
        return valByte;
    }

    /***************************************************************************
     * reqInteger */
    /**
     * Checks to see if value is a valid integer.  Returns value as an integer.
     * Throws an exception using msg as the error message if not valid.
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @param  allowZero       true  = Allow zero values
     *                         false = Do not allow zero values
     * @return                 value as int
     ***************************************************************************/

    public static int reqInteger (string value, string msg)
    {
      return reqInteger(value,msg,false);
    }

    public static short reqShort (string value, string msg)
    {
      value = reqString(value, msg);
      short valShort;  
      if (!short.TryParse(value,out valShort)) throw new Warning(msg);
      return valShort;
    }

    public static int reqInteger (string value, string msg, bool allowZero)
        //TODO:  Why are we using regex?  Isn't it enough to just use Microsoft built-in converting and parsing utilities, and throw the exception
        //if they fail??
    {
      // Regex pattern courtesy of Chuck Scholton, http://regexlib.com/DisplayPatterns.aspx?cattabindex=2&categoryId=3
      // This will check if a number is an integer.  Positive integers are all the whole numbers greater than
      // zero: 1, 2, 3, 4, 5, ... . Negative integers are all the opposites of whole numbers: -1, -2, -3,-4, -5, ... .
      // Zero is not a whole number with either a positive or negative value, and is not an interger.
      // Null or Empty values are not intergers.
      // Matches
      // 10 | -10 | +10.00
      // Non-Matches
      // 0 | -10.50 | 10.50
      value = reqString(value, msg);
      string pattern = @"^[-+]?[1-9]\d*\.?[0]*$";
      if (allowZero)
        pattern = @"^[-+]?[0-9]\d*\.?[0]*$";
      if (Regex.IsMatch(value,pattern)){return Convert.ToInt32(value);}
      else{throw new Warning(msg);}
     }

    /***************************************************************************
     * reqIntegerInRange */
    /**
     * Checks to see if value is in the range specified by start, end.
     * number.  Returns value if the value is in the range.
     * Throws an exception using msg as the error message if not in the range.
     * For example value 2 would be found in the range start 1, end 3 but value 5
     * would not be found.
     *
     * @param  value           Incoming value
     * @param  start           Start of range
     * @parm   end             End of range (must be greater than start)
     * @param  msg             Invalid value message
     * @return                 value as a datetime
     ***************************************************************************/

    public static int reqIntegerInRange (string value, int start, int end, string msg)
    {
      // See if the value is in the supplied range and return it if we find it
      if (start > end){throw new Warning(Messages.BAD_VALIDATE_PARMS);}
      int vValue  = reqInteger(value,msg);
      if ((vValue >= start) && (vValue <= end)) {return vValue;}
      throw new Warning(msg);
    }

    /***************************************************************************
     * reqOption */
    /**
     * Checks to see if value is in possibleValues
     * number.  Returns value if the value is in possibleValues
     * Throws an exception using msg as the error message if not in possibleValues.
     *
     * @param  value           Incoming value
     * @param  possibleValues  Pipe delimited (|) string or string[] array of values
     *                         or optional set of parameters
     * @param  msg             Invalid value message
     * @return                 value as a datetime
     ***************************************************************************/

    public static string reqOption (string value, string possibleValues, string msg)
    {
      string[] possibleVals = possibleValues.Split('|');
      return reqOption (value, possibleVals, msg);
    }

    public static string reqOption (string value, string msg, params string[] possibleValues)
    {
      return reqOption (value,possibleValues,msg);
    }

    public static string reqOption (string value, string[] possibleValues, string msg)
    {
      // See if the value is in possibleValues and return it if it is
      value = reqString(value, msg);
      foreach (String val in possibleValues){if (String.Compare(val,value,true)== 0) return val;}
      throw new Warning(msg);
    }

   /***************************************************************************
    * reqStrongPassword */
   /**
    * Checks to see if value is a strong passwords.  Strong passwords are:
    *
    *   - at least 8 characters in length but no longer than 50
    *   - alpha numeric
    *   - mixed case
    *
    * This criteria ensures that no dictionary words can be entered.  It also
    * helps make the password tougher to break.
    *
    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 value as string
    ***************************************************************************/

   public static string reqStrongPassword (string value, string msg)
   {

     value = reqString (value, msg);                                     // Password cannot be blank

     if (value.Length < Rules.PWD_MIN_LENGTH) throw new Critical(msg);  // Too short!
     if (value.Length > Rules.PWD_MAX_LENGTH) throw new Critical(msg);  // Too long!

     //if (!Regex.IsMatch (value, @"\w{8,50}"))  throw new Critical(msg);  // 8-50 alpha numeric chars
     if (!Regex.IsMatch (value, @"\d{1,}"))    throw new Critical(msg);  // At least one number

     return value;

   }

  /***************************************************************************
   * reqNewPassword */
  /**
   * Checks to see if password1 and password2 are equal and strong passwords
   *
   * @param  password1    New password
   * @param  password2    New password entered again
   * @return              Password as string
   ***************************************************************************/

   public static string reqNewPassword(string password1, string password2)
   {
      string vPassword1 = Validate.reqString (password1, Messages.INVALID_PASSWORD_NEW_BLANK + " (1st Entry)");
      string vPassword2 = Validate.reqString (password2, Messages.INVALID_PASSWORD_NEW_BLANK + " (2nd Entry)");

      if (vPassword1 != vPassword2)
        throw new Critical(Messages.INVALID_PASSWORD_NEQ);

      vPassword1 = Validate.reqStrongPassword (password1, Messages.INVALID_PASSWORD_NEW);
      vPassword2 = Validate.reqStrongPassword (password2, Messages.INVALID_PASSWORD_NEW);

     return vPassword1;
   }

  /***************************************************************************
   * reqPhoneNumber */
  /**
   * Checks to see if value is a valid North American phone number in the sense of containing
   * the right number, values, and ordering of digits for a phone number w/o long distance or
   * extension encoding and then it returns the phone number as a string in the following format:
   *
   * (123) 456-9999
   *
   * Please note that this function DOES NOT provide any comprehensive checking to see
   * if the number is actually in use (ie area codes not in use, etc).  But it does check to see
   * if the number complies with NANP (http://en.wikipedia.org/wiki/North_American_Numbering_Plan).
   *
   * Valid phone numbers can be in any format just as long as the value contains three components:
   *
   *  - three digits for the area code and the first digit cannot be a 0
   *  - three digits for the prefix and the first digit cannot be a 0
   *  - and four digits for the sufix.
   *
   * And the components are stored in the value from left -> right
   *
   * For example consider a phone number that has the following components:
   *
   *  - 234 as its area code
   *  - 567 as its prefix
   *  - 9999 as its sufix
   *
   * All of the following representations (and more) of this phone number are valid:
   *
   *   - (234) 567-9999
   *   - (234) 567-9999
   *   - 234-567-9999
   *   - 234 567-9999
   *   - (234) 567-9999 (h)
   *   - 234567999
   *
   * @param  value    Incoming phone number
   * @param  msg      Message to display if the phone number is invalid
   * @return          String
   ***************************************************************************/

   public static string reqPhoneNumber(string value, string msg)
   {

     /*-------------------------------
      * Strip out all non numeric
      * characters
      *------------------------------*/

     value = reqString(value, msg);                       // Phone number cannot be blank
     value = Util.removeAllNonNumeric(value);             // Strip out all non numeric characters

     /*-------------------------------
      * Validate compliance with NANP
      * North American Numbering Plan
      * https://nationalnanpa.com/
      *------------------------------*/

     if (!Regex.IsMatch(value,@"^[2-9]\d{2}[2-9]\d{6}")) throw new Critical(msg);

     /*-------------------------------
      * A valid phone number value at
      * this point will be a number 10
      * digits long 9999999999
      *------------------------------*/

     if (value.Length != 10) throw new Critical(msg);

     /*-------------------------------
      * FormatStrings and return
      *------------------------------*/

     Double pv = Double.Parse(value);
     return String.Format("{0:###-###-####}", pv);  /* Note: Must fit 12 char limit*/

   }

  /***************************************************************************
   * reqSex */
   /**
   * Checks to see if value is a valid indication of gender.
   * Returns value as a string.
   *
   * @param  value           Incoming value
   * @param  msg             Invalid value message
   * @return                 value as string
   ***************************************************************************/

   public static string reqSex (string value, string msg)
   {
      
      /* Clean up incoming value */

      value = reqString(value, msg);
      value = value.ToLower();
      value = value.Replace(@" ",@"");
      value = value.Replace(@"-",@"");
      value = value.Replace(@"\",@"");
      value = value.Replace(@"/",@"");

      switch (value)
      {
        /* Male - Returns X12 standard value for male */

        case "m":            { return Constants.GENDER_MALE; }
        case "male":         { return Constants.GENDER_MALE; }
        case "b":            { return Constants.GENDER_MALE; }
        case "boy":          { return Constants.GENDER_MALE; }
        case "man":          { return Constants.GENDER_MALE; }

       /* Female - Returns X12 standard value for female */

        case "f":            { return Constants.GENDER_FEMALE; }
        case "female":       { return Constants.GENDER_FEMALE; }
        case "g":            { return Constants.GENDER_FEMALE; }
        case "girl":         { return Constants.GENDER_FEMALE; }
        case "woman":        { return Constants.GENDER_FEMALE; }  

       /* Unknown - Returns X12 standard value for unknown/notspecified */

        case "u":            { return Constants.GENDER_UNKNOWN; }
        case "x":            { return Constants.GENDER_UNKNOWN; }
        case "n":            { return Constants.GENDER_UNKNOWN; }
        case "nb":           { return Constants.GENDER_UNKNOWN; }
        case "nonbinary":    { return Constants.GENDER_UNKNOWN; }
        case "na":           { return Constants.GENDER_UNKNOWN; }
        case "unknown":      { return Constants.GENDER_UNKNOWN; }
        case "notspecified": { return Constants.GENDER_UNKNOWN; }
        case "notprovided":  { return Constants.GENDER_UNKNOWN; }

        default:             { throw new Critical(msg); }
      }
   }

  /***************************************************************************
   * optSex */
  /**
   ***************************************************************************/

  public static string optSex (string value, string msg)
  {
    if (String.IsNullOrWhiteSpace(value)) return null;
    return reqSex(value,msg);
  }

  /***************************************************************************
   * reqSSN */
   /**
   * Checks to see if value is a valid social security number
   * Accepts 999-99-9999, 999 99 9999, 999999999 and returns 999999999
   *
   * @param  value           Incoming value
   * @param  msg             Invalid value message
   * @return                 value as string
   ***************************************************************************/

   public static string reqSSN(string value, string msg)
   {
     value = reqString(value, msg);
     value = value.Replace("-","");
     value = Util.removeWhiteSpace(value);
     if (Util.isNDigitInteger(value,9)) return value; else throw new Critical(msg);
   }

   /***************************************************************************
    * reqString */
   /**
    * Checks to see if value is a valid string.  Returns value as a string.
    * We also use this method to remove any unfriendly characters
    * Throws an exception using msg as the error message if not valid.
    *
    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 value as string
    ***************************************************************************/

    public static string reqString(string value, string msg){return reqString(value,0,msg,true);}
    public static string reqString(string value, int length, string msg, bool sanitize = true)
    {
      // Determines if a string is valid

      if(Util.IsNullOrEmpty(value)) throw new Critical(msg);

      // Remove trailing and leading whitespace

      value = value.Trim();
      
      // Remove script tags 
     
      if (sanitize == true) {       
        value = Util.removeScriptTags(value);
      }
           
      // Check required length

      string pattern = (length > 0) ? @"^.{" + length.ToString() + @"}$" : @".*";
      if (Regex.IsMatch(value,pattern)) return value; else throw new Critical(msg);
    }
    
    /***************************************************************************
     * reqNoun */
    /**
     * Checks to see if value is alphanumeric but not all numbers
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as string
     ***************************************************************************/

     public static string reqNoun (string value, string msg)
     {
        value = Validate.reqString(value,@msg);
        if (Util.isANumber(value)) throw new Critical(msg);
        return value;
     }

    /***************************************************************************
     * optNoun */
    /**
     * Checks to see if value is alphanumeric but not all numbers
     *
     * @param  value           Incoming value
     * @param  msg             Invalid value message
     * @return                 value as string
     ***************************************************************************/
    public static string optNoun (string value, string msg)
    {
      if (String.IsNullOrWhiteSpace(value)) return null;
      return reqNoun(value,msg);
    }

   /***************************************************************************
    * reqZip5 */
   /**
    * Checks to see if value is a valid 5 digit zip code
    * Accepts 00000 to 99999
    *
    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 value as string
    ***************************************************************************/
   public static string reqZip5 (string value, string msg, bool attemptSalvage = false)
   {
     value = reqString(value, msg);
     
    if (attemptSalvage == true )
    { 
   
      /* Remove dashes and internal whitespace*/

      value = Util.removeAllNonNumeric(value);

      /* Attempt to replace leading 0s that might have gotten converted out */
       
      if (value.Length == 4) value = value.PadLeft(5,'0');
      
      /* Attempt to extract first 5 chars if a longer value is passed*/
     
      if (value.Length > 5) value = value.Substring(0,5); 
    }
     
    /* Test if the value is a 5 digit integer (leading 0s supported)*/

    if (Util.isNDigitInteger(value, 5)) return value; else throw new Critical(msg);
  
   }

   /***************************************************************************
    * reqZip4 */
   /**
    * Checks to see if value is a valid 4 digit zip extension
    * Accepts 0000 to 9999
    *
    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 value as string
    ***************************************************************************/

   public static string reqZip4 (string value, string msg)
   {
     value = reqString(value, msg);
     if (Util.isNDigitInteger(value, 4)) return value; else throw new Critical(msg);
   }

   /***************************************************************************
    * reqNPI */
   /**
    * Checks to see if the value is a valid NPI#
    *
    *
    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 value as string
    ***************************************************************************/

   public static string reqNPI (string value)
   {
     return reqNPI(value,Messages.INVALID_NPI);
   }

   public static string reqNPI (string value, string msg)
   {
     value = reqString(value,10,msg);
     // TODO: NPI API check
     return value;
   }  

   /***************************************************************************
    * reqClientID */
    /**
    * Validates client id and provides default
    * 
    * @param  userInfo        User information
    * @param  clientID        Client id passed in
    * @return                 Value of id
    ***************************************************************************/
       
    public static int reqClientID (UserInfo userInfo, string clientID, bool enforceSubValueForExplicitAccessUserRole = false, bool applyCybhiConsortiumLeadException = false)
    {
      return Convert.ToInt32(valClientID(userInfo, clientID, false, enforceSubValueForExplicitAccessUserRole, applyCybhiConsortiumLeadException));
    }
    
    public static object optClientID(UserInfo userInfo, string clientID, bool enforceSubValueForExplicitAccessUserRole = false, bool applyCybhiConsortiumLeadException = false)
    {
      return valClientID(userInfo, clientID, true, enforceSubValueForExplicitAccessUserRole, applyCybhiConsortiumLeadException);
    }
    
    protected static object valClientID (UserInfo userInfo, string clientID, bool optional, bool enforceSubValueForExplicitAccessUserRole = false, bool applyCybhiConsortiumLeadException = false)
    {

      Object retID = null;
      
      /*-------------------------------
       * Clients are restricted to their
       * own clientID in most cases
       *------------------------------*/
      
      if (userInfo.userGroup == Constants.USER_GROUP_CLIENT)
      {
        /* Start with users client id as the value that will be returned in any case */
        
        retID = userInfo.userClientID;

        /* The only exception is if we need to apply the cybhi consortium lead exception logic */

        if (applyCybhiConsortiumLeadException == true) {
            
            /* And the users associated client is a cybhi consortium lead */

            if (userInfo.cybhiConsortiumIsLead == true) { 
              
              /* And a value in clientID was actually passed. */

              if (!String.IsNullOrEmpty(clientID)) {
                 
                /* And the user is either a LEA or CYBHI coordinator */  
                
                if (((userInfo.userRoleID == Constants.ROLE_LEA_COORDINATOR_ID) || (userInfo.userRoleID == Constants.ROLE_CYBHI_CORDINATOR_ID))) {
                
                  /* And the value passed in client id is found in the authorized list (this includes their own) */
                  /* Note if a non numeric value or some other invalid value is passed, it will not be found in the list and the routine will just return the users clientID */

                  foreach (var cybhiConsortiumMember in userInfo.cybhiConsortiumMembers) { 

                    /* Found */

                    if (cybhiConsortiumMember.idStr == clientID) {
                      retID = cybhiConsortiumMember.idStr;
                      break;
                    }
                  } /* In authorized list */
                } /* Is coordinator */              
              } /* client id is passed */
            } /* The users associated client is a cybhi consortium lead */
         } /* Apply cybhi consortium lead expection logic */
         
        return retID;
      }
      
      /*-------------------------------
       * SELPAS are restricted to 
       * those clients that are 
       * associated with the selpa
       *------------------------------*/
      
      if (userInfo.userRoleID == Constants.ROLE_SELPA_USER_ID)
      {
        retID = null;

        foreach (var associatedClient in userInfo.associatedClients)
        {
          if (associatedClient.clientID.ToString() == clientID)
          { 
            retID = associatedClient.clientID;
            break;
          }
        } 
        if (retID == null) throw new Warning(Messages.INVALID_CLIENT_ID);
        return retID;
      }
      
      /*-------------------------------
       * Role with explicit client id
       * access.    
       *------------------------------*/
      
      if (enforceSubValueForExplicitAccessUserRole == true) 
      { 
      
        /*-------------------------------
         * Parent/guardians are restricted
         * to clients that have patients 
         * that they are associated with
         * no exceptions.
         *------------------------------*/
      
        if (userInfo.userRoleID == Constants.ROLE_PARENT_GUARDIAN_ID)      
        {         
          retID = null;

          foreach (var patientPerson in userInfo.associatedPatientPersons)
          {
            if (patientPerson.clientID.ToString() == clientID)
            { 
              retID = patientPerson.clientID;
              break;
            }
          } 
                 
          if (retID == null) throw new Warning(Messages.INVALID_CLIENT_ID);         
          return retID;
        } /* parent/guardian */

        /*-------------------------------
         * Patients are restricted
         * to clients that have patients 
         * that they are associated with
         * no exceptions.
         *------------------------------*/
      
        if (userInfo.userRoleID == Constants.ROLE_PATIENT_ID)      
        {         
          retID = null;

          foreach (var patientUserAccount in userInfo.associatedPatientUserAccounts)
          {
            if (patientUserAccount.clientID.ToString() == clientID)
            { 
              retID = patientUserAccount.clientID;
              break;
            }
          } 
                 
          if (retID == null) throw new Warning(Messages.INVALID_CLIENT_ID);         
          return retID;
        } /* patient */
      }
      
      /*-------------------------------
       * Everyone else (for now) 
       *------------------------------*/
      
      if (optional)
         retID = Validate.optInteger(clientID, Messages.INVALID_CLIENT_ID, true);
      else
        retID = Validate.reqInteger(clientID,Messages.INVALID_CLIENT_ID, true);
     
      return retID;
     
    }

    class ValidatePagingOrderInfo
    {
      public ValidatePagingOrderInfo() : this(null) { }
      public ValidatePagingOrderInfo(string ColumnName){this.ColumnName = ColumnName;}
      public string ColumnName { get; set; }
    }
    
    public static string ValidateReqPageOrder (Type objType, string value, string message)
    {
          
      string valueOut = @"";
      if (String.IsNullOrWhiteSpace(message)) message = @"Invalid page order";

      /* If any of the required parms are missing get out */

      if (objType == null)                  throw new Critical(@"You must pass an object type to validate page order");            
      if (String.IsNullOrWhiteSpace(value)) throw new Critical(message);

      /* Remove excessive spaces */

      valueOut = Regex.Replace(value, @"\s\s+", @"").Trim();
          
      /* Split up expression by comma */
      
      var colNameOrders = valueOut.Split(',');         
      var poil = new List<ValidatePagingOrderInfo>();

      Regex cnoTest = new Regex(@"^\w+(\sasc|\sdesc|$)", RegexOptions.IgnoreCase);

      /* Test each page order column name for valid form and put page order column names in a list */

      foreach (string colNameOrder in colNameOrders)
      {        
        var cno = colNameOrder.Trim();                                            /* Clean up name */
        if (!cnoTest.IsMatch(cno)) throw new Critical(message);                   /* Test form */        
        poil.Add(new ValidatePagingOrderInfo(colNameOrder.Trim().Split(' ')[0])); /* Add JUST the column name, ignore any ordering (asc, desc) */
      }
      
      /* Get properties and members of the object type */

      var pil = objType.GetProperties();
      var mil = objType.GetMembers();

      /* Build queries that join the page order to the property and method lists.*/
      
      var queryPil = from pi in pil join poi in poil on pi.Name equals poi.ColumnName select pi.Name;
      var queryMil = from mi in mil join poi in poil on mi.Name equals poi.ColumnName select mi.Name;

      /* Execute queries and if both have 0 results then the paging column name is not in the class */

      if ((!queryPil.Any()) && (!queryMil.Any())) throw new Critical(message);

      return valueOut;
   }

   /***************************************************************************
     * checkBoxOK */
    /**
     * Checks to see if value is valid
     *
     * @param  value           Incoming value
     * @return bool            True  = value is ok
     *                         False = value is not ok
     ***************************************************************************/

    public static bool checkBoxOK (bool? value)
    {
      bool isOK = false;
      if (value.HasValue)
        isOK = true;
      return isOK;
    }

    /***************************************************************************
     * numberBoxOK */
    /**
     * Checks to see if value is valid
     *
     * @param  value           Incoming value
     * @return bool            True  = value is ok
     *                         False = value is not ok
     ***************************************************************************/

    public static bool numberBoxOK (int? value)
    {
      bool isOK = false;

      if (value.HasValue)
        if (value.Value >= 0)
          isOK = true;
     return isOK;
    }

    /***************************************************************************
     * dateBoxOK */
    /**
     * Checks to see if value is valid
     *
     * @param  value           Incoming value
     * @return bool            True  = value is ok
     *                         False = value is not ok
     ***************************************************************************/

    public static bool dateBoxOK (DateTime? value)
    {
      bool isOK = false;
      if (value.HasValue)
        isOK = true;
      return isOK;
    }


 }
}
