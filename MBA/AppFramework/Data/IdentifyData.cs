using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Globalization;

namespace MBA.IdentifyData
{          
  /***************************************************************************
   * IdentifiedValue
  /**
   * Contains meta data about a given value.
   ***************************************************************************/   

  public class IdentifiedValue
  {
    public  Object    value;                     // Original value    
	  public  string    valueStr;                  // String representation of value (raw)
    public  string    valueStrFormatted;         // String representation of value (formatted)
    public  string    formatString;              // Format string used (if any)
    public  Type      valueType;                 // Original value type
    public  Type      valueTypeConvertTo;        // Type that value can/should be converted to for storage/calulations
    public  string    typename;                  // .NET typename
	  public  bool      valueIsStoredAsString;     // Original value was stored as a string
    public  bool      valueIsNullOrEmpty;        // Original value is null or empty    
    public  bool      valueIsDBNull;             // Original value is a DB null
	  public  bool      valueIsNegative;           // Numeric value is negative
    public  bool      valueIsPositive;           // Numeric value is positive (> 0)
    
	  public  DataClass dataClass;                 // Generic class of data original value falls under
    public  DataType  dataType;                  // Specific class of data original value falls under
    
    /*-------------------------------
     * Native representations of value
     * depending on its type
     *------------------------------*/ 
    
    public  bool      boolValue;                
    public  Int32     intValue;
    public  Int64     bigintValue;
    public  decimal   decimalValue;
    public  Single    singleValue;
    public  double    doubleValue;
    public  DateTime  dateValue; 
    public  TimeSpan  timeValue;   
    	
    /***************************************************************************
     * DataClass
    /**
     * Generic classes of data.
     * For example integers, decimals, and floats are all numbers.
     ***************************************************************************/   
  
    public enum DataClass
    {
      BOOL    = 0,
      NUMBER  = 1,
      DATE    = 2,
      TEXT    = 3,
      OBJECT  = 4,
      UNKNOWN = 999
    }
    
    /***************************************************************************
     * DataClassWidths
    /**
     * Width (in characters) for various data clases
     ***************************************************************************/   

    public const int CHAR_WIDTH_TEXT    = 50;
    public const int CHAR_WIDTH_NUMBER  = 15;
    public const int CHAR_WIDTH_DATE    = 20;
    public const int CHAR_WIDTH_BOOL    = 10;
    public const int CHAR_WIDTH_UNKNOWN = 0;
        
    /***************************************************************************
     * DataTypes
    /**
     * Specific data types.
     ***************************************************************************/   

    public enum DataType
    {
      BOOLEAN    = 0,
      INT32      = 1,
      INT64      = 2,
      DECIMAL    = 3,
      SINGLE     = 4,
      DOUBLE     = 5,
      DATETIME   = 6,
      STRING     = 7,
      TIME       = 8,
      UNKNOWN    = 999
    }
                
    /***************************************************************************
     * DataClassToCharWidth
    /**
     * Determines the character width for a given dataclass (cls)
     *
     * @param    cls             The dataclass to lookup the width for
     *
     * @returns  int 
     ***************************************************************************/   
    
    public static int DataClassToCharWidth (DataClass cls)
    {
      if (cls == DataClass.BOOL)    return CHAR_WIDTH_BOOL;
      if (cls == DataClass.TEXT)    return CHAR_WIDTH_TEXT;
      if (cls == DataClass.NUMBER)  return CHAR_WIDTH_NUMBER;
      if (cls == DataClass.DATE)    return CHAR_WIDTH_DATE;
      if (cls == DataClass.UNKNOWN) return CHAR_WIDTH_UNKNOWN;
      
      return CHAR_WIDTH_TEXT;
    }
            							
    /***************************************************************************
     * Parse
    /**
     * Parses value into an Identified value
     *
     * @param    value           The value to parse stored as an object
     * @param    formatString    Desired format for the string representation of
     *                           value
     * @returns Identified value
     ***************************************************************************/   

    public static IdentifiedValue Parse (Object value)
		{
      return Parse(value,"");
    }

    public static IdentifiedValue Parse (Object value, string formatString)
    {

      /*-------------------------------
       * Create instance of Identified
       * Value and init various values
       *------------------------------*/ 

      IdentifiedValue so = new IdentifiedValue();   
      so.valueIsNegative = false;			
      so.valueIsPositive = false;
            
      /*-------------------------------
       * Save a copy of value and 
       * create a raw string 
       * representation of the value.
       *------------------------------*/ 

      so.value              = value;      
      so.valueStr           = value.ToString();
      so.valueStrFormatted  = so.valueStr;

            
      /*-------------------------------
       * Save a copy of the format 
       * string and see if it is one
       * of our predefined strings.
       *------------------------------*/ 
      
      so.formatString = formatString;
              
     /*-------------------------------
      * Determine values .NET type
      *------------------------------*/ 

      so.valueType          = value.GetType();
      so.typename           = so.valueType.ToString();
      so.valueTypeConvertTo = so.valueType;
      
      /*-------------------------------
       * Determine if value is null or
       * empty and determine if its 
       * original type is a string
       *------------------------------*/ 
      
      so.valueIsDBNull      = (so.value == DBNull.Value);
      so.valueIsNullOrEmpty = Util.IsNullOrEmpty(so.valueStr);            
      
      if (so.valueType == typeof(System.String))
        so.valueIsStoredAsString = true;
      else
        so.valueIsStoredAsString = false;

      /*-------------------------------
       * If this is a db null get out
       *------------------------------*/       
      
      if (so.valueIsDBNull)
      {
        so.dataType           = DataType.UNKNOWN;
        so.dataClass          = DataClass.UNKNOWN;
        so.valueTypeConvertTo = null;
        return so;
      }

      /*-------------------------------
       * If the value is a null or empty
       * and it is stored as a string
       * get out
       *------------------------------*/       
      
      if (so.valueIsNullOrEmpty && so.valueIsStoredAsString)
      {
        so.dataType           = DataType.STRING;
        so.dataClass          = DataClass.TEXT;
        so.valueTypeConvertTo = typeof(String);
        return so;
      }
      
      /*-------------------------------
       * If we reach this point we have
       * some value that is not null
       * 
       * Begin identification process
       *------------------------------*/       

      Object valueToTest = value;

      /*-------------------------------
       * If the value is stored as a
       * string, see if we can
       * parse it into something more
       * specific
       *------------------------------*/       
      
      bool stringparsed = false;     
      
      if (so.valueIsStoredAsString)
      {
    
        /*-------------------------------
         * The following evaluation is
         * in order of priority for types.
         *------------------------------*/ 

        /* Evaluation based on a solution provided by Callisto
         * http://stackoverflow.com/questions/5311699/get-datatype-from-values-passed-as-string/5325687#5325687
         */
						
        /*-------------------------------
         * Test if value is a 32 bit
         * integer
         *------------------------------*/ 

        if (Int32.TryParse(so.valueStr, out so.intValue))
        {      
          so.valueTypeConvertTo = so.intValue.GetType();
          valueToTest           = so.intValue;
          stringparsed          = true;
        }

	      /*-------------------------------
         * Test if value is a 64 bit
         * integer
         *------------------------------*/ 

        else if (Int64.TryParse(so.valueStr, out so.bigintValue))
        {      
	        so.valueTypeConvertTo = so.bigintValue.GetType();
		      valueToTest           = so.bigintValue;
          stringparsed          = true;
        }
      
       /*-------------------------------
        * Test if value is a decimal 
        *------------------------------*/ 

        else if (decimal.TryParse(so.valueStr, out so.decimalValue))
        {
  		    so.valueTypeConvertTo = so.decimalValue.GetType();
	  	    valueToTest           = so.decimalValue;
          stringparsed          = true;        
        }
      
        /*-------------------------------
         * Test if value is a double
         *------------------------------*/ 

        else if (double.TryParse(so.valueStr, out so.doubleValue))
        {
  		    so.valueTypeConvertTo = so.doubleValue.GetType();
          valueToTest           = so.doubleValue;
		      stringparsed          = true;        
        }		
		
	     /*-------------------------------
        * If the value could be a 
        * timespan
        *------------------------------*/ 
        
	     else if (TimeSpan.TryParse(so.valueStr, out so.timeValue))
	     {
		     so.valueTypeConvertTo = so.timeValue.GetType();
         valueToTest           = so.timeValue;
         stringparsed          = true;

	     }
	     
	     /*-------------------------------
        * If the value could be a date
        *------------------------------*/ 

	     else if (DateTime.TryParse(so.valueStr, out so.dateValue))
	     {				
		     so.valueTypeConvertTo = so.dateValue.GetType();
         valueToTest           = so.dateValue;
         stringparsed          = true;
       }
       
       /*-------------------------------
        * If the value could be a bool
        * or text we would want to
        * represent as a boolean
        *------------------------------*/ 
       
       else if (Boolean.TryParse(so.valueStr, out so.boolValue))       
       {
		     so.valueTypeConvertTo = so.boolValue.GetType();
         valueToTest           = so.boolValue;
         stringparsed          = true;
       }

   	  /*-------------------------------
       * Test if value is something else
       *------------------------------*/ 

       else
       {
         bool? bVal = Util.evaluateFlag(value, false);
			
         if (bVal.HasValue)
         {
           so.boolValue          = bVal.Value;
           valueToTest           = so.boolValue;
      		 so.valueTypeConvertTo = so.boolValue.GetType();
           stringparsed          = true;
         }
       }

       /*-------------------------------
        * If we reach this point and we
        * have not been able to parse the
        * string
        *------------------------------*/       

      if (!stringparsed)
      {
        /*-------------------------------
         * Then the value must be a string
         * lets get out
         *------------------------------*/       

        so.dataType           = DataType.STRING;
        so.dataClass          = DataClass.TEXT;
        so.valueTypeConvertTo = typeof(String);
        return so;
      }    
    }

   /*-------------------------------
    * If the value is not stored as
    * a string or we were able to
    * parse it into something more
    * specific then finish 
    * processing it based on its
    * datatype.  
    * 
    * We want to especialy do this
    * for booleans and numbers to
    * avoid ambiguity with the 
    * values 0 and 1
    *------------------------------*/ 
   
   if ((!so.valueIsStoredAsString) || (stringparsed))
   {        
     
     Type valueType = valueToTest.GetType();	      
     
     /*-------------------------------
      * Parse booleans
      *------------------------------*/ 

     if (valueType == typeof(System.Boolean))
     {
       so.boolValue = (bool) valueToTest;
       so.dataType  = DataType.BOOLEAN;
       so.dataClass = DataClass.BOOL;					
       so.valueStrFormatted = Util.boolToYesNo(so.boolValue);
       return so;
      }
        
      /*-------------------------------
       * Parse decimals
       *------------------------------*/ 

		  if (valueType == typeof(System.Decimal))
      {
        so.decimalValue = (Decimal) valueToTest;
        so.dataType     = DataType.DECIMAL;
        so.dataClass    = DataClass.NUMBER;
        		      
        if (so.decimalValue < 0m) 
          so.valueIsNegative = true;
        
        if (so.decimalValue > 0m) 
          so.valueIsPositive = true;  
        
        if (!Util.IsNullOrEmpty(formatString))
          so.valueStrFormatted = so.decimalValue.ToString(formatString);

        return so;  
      }

      /*-------------------------------
       * Parse 32 bit Integers
       *------------------------------*/ 
				
      if (valueType == typeof(System.Int32))
      {
        so.intValue  = (Int32) valueToTest;
        so.dataType  = DataType.INT32;
        so.dataClass = DataClass.NUMBER;

        if (so.intValue < 0)
          so.valueIsNegative = true;
        
        if (so.intValue > 0)
          so.valueIsPositive = true;
        
        if (!Util.IsNullOrEmpty(formatString))
          so.valueStrFormatted = so.intValue.ToString(formatString);

        return so;
      }

      /*-------------------------------
       * Parse 64 bit Integers
       *------------------------------*/ 
        
		  if (valueType == typeof(System.Int64))
      {      
        so.bigintValue = (Int64) valueToTest;
        so.dataType    = DataType.INT64;
        so.dataClass   = DataClass.NUMBER;
		      
        if (so.bigintValue < 0) 
          so.valueIsNegative = true;
               
        if (so.bigintValue > 0) 
          so.valueIsPositive = true;
 
        if (!Util.IsNullOrEmpty(formatString))
          so.valueStrFormatted = so.bigintValue.ToString(formatString);
          
        return so;
      }
        
      /*-------------------------------
       * Parse singles
       *------------------------------*/         
		    
      if (valueType == typeof(System.Single))
      {
        so.doubleValue = (Single) valueToTest;
        so.dataType    = DataType.SINGLE;
        so.dataClass   = DataClass.NUMBER;
		      
        if (so.singleValue < 0f) 
          so.valueIsNegative = true;
        
        if (so.singleValue > 0f) 
          so.valueIsPositive = true;
        
        if (!Util.IsNullOrEmpty(formatString))
          so.valueStrFormatted = so.singleValue.ToString(formatString);
          
        return so;        
      }

      /*-------------------------------
       * Parse doubles
       *------------------------------*/         

      if (valueType == typeof(System.Double))
      {
        so.doubleValue = (Double) valueToTest;
        so.dataType    = DataType.DOUBLE;
        so.dataClass   = DataClass.NUMBER;

        if (so.doubleValue < 0f) 
          so.valueIsNegative = true;
		      
        if (so.doubleValue > 0f) 
          so.valueIsPositive = true;

        if (!Util.IsNullOrEmpty(formatString))
          so.valueStrFormatted = so.doubleValue.ToString(formatString);
          
        return so;
      }

      /*-------------------------------
       * Parse timespan
       *------------------------------*/         

      if (valueType == typeof(System.TimeSpan))
      {
        so.timeValue   = (TimeSpan) valueToTest;
        so.dataType    = DataType.TIME;
        so.dataClass   = DataClass.DATE;	

      }
      
      /*-------------------------------
       * Parse date/time
       *------------------------------*/         

      if (valueType == typeof(System.DateTime))
      {
        so.dateValue   = (DateTime) valueToTest;
        so.dataType    = DataType.DATETIME;
        so.dataClass   = DataClass.DATE;	

        if (!Util.IsNullOrEmpty(formatString))
          so.valueStrFormatted = so.dateValue.ToString(formatString);

        return so;        
      }
            
    }
    
    /*-------------------------------
     * We should never reach this point
     * but just in case...
     *------------------------------*/         
    
    return so;

         
    }	
  }
}