using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Drawing;
using MBA.IdentifyData;


namespace MBA
{ 
  

  /***************************************************************************
   * StructuredDataFieldType */
  /**
   * 
   **************************************************************************/   
  public class StructuredDataFieldDataType
  {
     public const string NOUN                 = @"noun";          /* Alpha numeric but values containing all numbers are not allowed */
     public const string STRING               = @"string";        /* Alpha numeric */
     public const string DATE                 = @"date";          /* Date */
     public const string TIME                 = @"time";          /* Time*/
     public const string DATETIME             = @"datetime";      /* Date and time*/
     public const string USD                  = @"usd";           /* Valid US dollars*/
     public const string INTEGER              = @"integer";       /* Valid whole number */
     public const string SSID                 = @"ssid";          /* Calpads student id */
     public const string CDSCODE              = @"cdscode";       /* CDE county district school */
     public const string SCHOOLCDSCODE        = @"schoolcdscode"; /* CDE school */
     public const string CDSFULLORSCHOOLCODE  = @"cdsfullorschoolcode";  /* Full 14 or last 7 code */
     public const string ZIP5                 = @"zip5";                 /* First 5 digits of a zip */
     public const string GENDER               = @"gender";               /* Valid sex */
     public const string FLAG                 = @"flag";                 /* Any flag type of value */      
     public const string FLAGDFLTYES          = @"flagdfltyes";          /* Any flag type of value.  If null or blank assume yes */      
     public const string FLAGDFLTNO           = @"flagdfltno";           /* Any flag type of value.  If null or blank assume no  */      
     public const string EMAIL                = @"email";                /* Valid emails */
     public const string PHONENANP            = @"phonenanp";            /* Valid Canadian and US phone numbers */
  }
  
  /***************************************************************************
   * StructuredDataField */
  /**
   * 
   **************************************************************************/   

  public class StructuredDataField
  {
    public string     name;
    public bool       columnRequired;
    public bool       dataRequired;
    public string     dataType;
    public string     label;
    public string     description;
    public string[]   commonColumnNames;
    public string[]   acceptableValues;
    public int        maxChars;

   /***************************************************************************
    * validate */
   /**
    * validates and sanitizes value.  Replaces nulls with empty strings.
    **************************************************************************/   

   public static string validate (  int                 rowNumIn
                                  , StructuredDataField fieldDef                                   
                                  , string              valueIn)
   {            
      string valueOut = _validateAndSanitizeValue (rowNumIn, fieldDef, valueIn);
      if (valueOut is null)                    return  @"";
      if (String.IsNullOrWhiteSpace(valueOut)) return  @"";
      return valueOut;
   }
   
   /***************************************************************************
    * validateAndSanitize */
   /**
    * Validates value, sanitizes and standardizes it.  Returns sanitized and
    * standardized value as as string.  Everything must be returned as a string.
    **************************************************************************/   

   private static string _validateAndSanitizeValue (   long                rowNumIn
                                                     , StructuredDataField fieldDef                                                    
                                                     , string valueIn)
    {
     

        string msg = @"* " + fieldDef.name + @": ";

            /*--------------- 
             * Noun
             *--------------*/

            if (fieldDef.dataType == StructuredDataFieldDataType.NOUN)
            {
                msg = msg + @"Expected a proper noun";
                if (fieldDef.dataRequired)
                    return Validate.reqNoun(valueIn, msg);
                else
                    return Validate.optNoun(valueIn, msg);
            }
            
            /*--------------- 
             * Gender
             *---------------*/
            
            else if (fieldDef.dataType == StructuredDataFieldDataType.GENDER)
            {
                msg = msg + @"Unsupported value for gender/sex";
                if (fieldDef.dataRequired)
                    return Validate.reqSex(valueIn, msg);
                else
                    return Validate.optSex(valueIn, msg);
            }
            
            /*--------------- 
             * Flag
             * Requires yes
             * or no
             *--------------*/
            
            else if (fieldDef.dataType == StructuredDataFieldDataType.FLAG)
            {
                msg = msg + @"Unsupported value for indicating yes or no";
                if (fieldDef.dataRequired) 
                { 
                  return Util.boolTo1or0Str(Validate.reqFlag(valueIn,msg,false));
                }
                else
                { 
                  var flagObj = Validate.optFlag(valueIn, msg,false);                    
                  if (flagObj is null) return @"";
                  var flagVal = (bool) flagObj;
                  return Util.boolTo1or0Str(flagVal);
                }
            }
            
            /*--------------- 
             * Flag
             * default yes
             *--------------*/
            
            else if (fieldDef.dataType == StructuredDataFieldDataType.FLAGDFLTYES)
            {
                msg = msg + @"Unsupported value for indicating yes or no";
                if (fieldDef.dataRequired) 
                { 
                  return Util.boolTo1or0Str(Validate.reqFlag(valueIn,msg,true,true));
                }
                else
                { 
                  var flagObj = Validate.optFlag(valueIn, msg,true,true);                    
                  var flagVal = (bool) flagObj;
                  return Util.boolTo1or0Str(flagVal);
                }
            }
            
            /*--------------- 
             * Flag 
             * default no
             *--------------*/
            
            else if (fieldDef.dataType == StructuredDataFieldDataType.FLAGDFLTNO)
            {
                msg = msg + @"Unsupported value for indicating yes or no";
                if (fieldDef.dataRequired) 
                { 
                  return Util.boolTo1or0Str(Validate.reqFlag(valueIn, msg, true, false));
                }
                else
                { 
                  var flagObj = Validate.optFlag(valueIn, msg, true, false);                                      
                  var flagVal = (bool) flagObj;
                  return Util.boolTo1or0Str(flagVal);
                }
            }
            
            /*--------------- 
             * Zip 5
             *--------------*/

            else if (fieldDef.dataType == StructuredDataFieldDataType.ZIP5)
            {
                msg = msg + @"Unsupported value for 5 digit zip code";
                if (fieldDef.dataRequired)
                    return Validate.reqZip5(valueIn, msg, true);
                else
                    return Validate.optZip5(valueIn, msg, true);
            }
            
            /*--------------- 
             * CDS Code
             *--------------*/
            
            else if (fieldDef.dataType == StructuredDataFieldDataType.CDSCODE)
            {
                msg = msg + @"Invalid value for 14 digit CDS code";
                if (fieldDef.dataRequired)
                    return Validate.reqCDSCode(valueIn, msg);
                else
                    return Validate.optCDSCode(valueIn, msg);
            }
            
            /*--------------- 
             * School CDS code
             *--------------*/
          
            else if (fieldDef.dataType == StructuredDataFieldDataType.SCHOOLCDSCODE)
            {
                msg = msg + @"Invalid value for 7 digit CDS site code";
                if (fieldDef.dataRequired)
                    return Validate.reqCdsSiteCode(valueIn, msg);
                else
                    return Validate.optCdsSiteCode(valueIn, msg);
            }
            
            /*--------------- 
             * Full CDS code
             * or just site
             * code portion
             *--------------*/
          
            else if (fieldDef.dataType == StructuredDataFieldDataType.CDSFULLORSCHOOLCODE)
            {
                msg = msg + @"Invalid value for either 14 digit full CDS code or 7 digit site portion of CDS code";
                if (fieldDef.dataRequired)
                    return Validate.reqCdsFullOrSchoolCode(valueIn, msg);
                else
                    return Validate.optCdsFullOrSchoolCode(valueIn, msg);
            }
            /*--------------- 
             * Integer
             *--------------*/

            else if (fieldDef.dataType == StructuredDataFieldDataType.INTEGER)
            {
                msg = msg + "Invalid value for a whole number";
                if (fieldDef.dataRequired)
                {
                    return Validate.reqInteger(valueIn, msg, true).ToString();
                }
                else
                {
                    var intObj = Validate.optInteger(valueIn, msg, true);
                    if (intObj is null) return @"";
                    var intVal = (int)intObj;
                    return intVal.ToString();
                }
            }
            
            /*--------------- 
             * USD
             *--------------*/

            else if (fieldDef.dataType == StructuredDataFieldDataType.USD)
            {
                msg = msg + "Invalid value for a USD amount";
                if (fieldDef.dataRequired)
                {
                    return Validate.reqUsdAmount(valueIn, msg).ToString();
                }
                else
                {
                    var usdObj = Validate.optUsdAmount(valueIn, msg);
                    if (usdObj is null) return @"";
                    var usdVal = (Decimal)usdObj;
                    return usdVal.ToString();
                }
            }
            
            /*--------------- 
             * Date
             *--------------*/
            
            else if (fieldDef.dataType == StructuredDataFieldDataType.DATE)
            {
                msg = msg + @"Invalid value for a date";
                if (fieldDef.dataRequired)
                {
                    return Validate.reqDate(valueIn, msg).ToShortDateString();
                }
                else
                {
                    var dateObj = Validate.optDate(valueIn, msg);
                    if (dateObj is null) return @"";
                    var dateVal = (DateTime)dateObj;
                    return dateVal.ToShortDateString();
                }
            }

            /*--------------- 
             * Time
             *--------------*/
            
            else if (fieldDef.dataType == StructuredDataFieldDataType.TIME)
            {
                msg = msg + @"Invalid value for a time";
                if (fieldDef.dataRequired)
                {
                  return Util.timeSpanToShortTimeString(Validate.reqTime(valueIn, msg));                    
                }
                else
                {
                    var timeObj = Validate.optTime(valueIn, msg);
                    if (timeObj is null) return @"";
                    var timeVal = (TimeSpan)timeObj;
                    return Util.timeSpanToShortTimeString(timeVal);                    
                }
            }           

            /*--------------- 
             * Date time
             *--------------*/
           
           else if (fieldDef.dataType == StructuredDataFieldDataType.DATETIME)
           {
             msg = msg + @"Invalid value for a date time";
             if (fieldDef.dataRequired)
             { 
               return Validate.reqDate(valueIn,msg).ToShortDateAndTimeString();
             }
             else
             { 
               var dateObj = Validate.optDate(valueIn,msg);
               if (dateObj is null) return @"";
               var dateVal = (DateTime) dateObj;
               return dateVal.ToShortDateAndTimeString();
             }
          }
        
        /*--------------- 
         * SSID
         *--------------*/

        else if (fieldDef.dataType == StructuredDataFieldDataType.SSID)
        {
            msg = msg + @"Invalid value for CSIS/SSID";
            if (fieldDef.dataRequired)
              return Validate.reqCSISOrSSID (valueIn,msg);
            else
              return Validate.optCSISOrSSID(valueIn,msg);
         }
        
        /*---------------
         * Email 
         *--------------*/
        
        else if (fieldDef.dataType == StructuredDataFieldDataType.EMAIL)
        {
            msg = msg + @"Invalid value for an email";
            if (fieldDef.dataRequired)
            { 
              return Validate.reqEmail(valueIn,msg);
            }
            else
            {
              if (String.IsNullOrWhiteSpace(valueIn)) return String.Empty;
              return Validate.reqEmail(valueIn,msg);
            }              
        }
        
        /*---------------
         * Phone
         * Canada & US
         *--------------*/
        
        else if (fieldDef.dataType == StructuredDataFieldDataType.PHONENANP)
        {
            msg = msg + @"Invalid value for a phone number";
            if (fieldDef.dataRequired)
            { 
              return Validate.reqPhoneNumber(valueIn,msg);
            }
            else
            {
              if (String.IsNullOrWhiteSpace(valueIn)) return String.Empty;
              return Validate.reqPhoneNumber(valueIn,msg);
            }              
        }
            
        /*--------------- 
         * String
         *--------------*/
        
        else if (fieldDef.dataType == StructuredDataFieldDataType.STRING)
        {           
            msg = msg + @"Expected a value";
            if (fieldDef.dataRequired)
              return Validate.reqString(valueIn,msg);
            else 
              return Validate.optString(valueIn,msg);
        }

        /*--------------- 
         * Other
         *--------------*/

        else
        {
           msg = msg + @"Expected a value";
           if (fieldDef.dataRequired)
              return Validate.reqString(valueIn,msg);
            else 
              return Validate.optString(valueIn,msg);
        }  
     }
  }

  /// <summary>
  /// User defined manipulation of incoming data fields prior to validate. 
  /// Use this to alter incoming data if neccessary.
  /// Replace name/value in dataFieldsForDataRow with whatever you want. 
  /// Example:
  /// MBA.StructuredDataRowDataFieldsManipulation _fnManipulateRow = delegate (ref Dictionary<string, string> dataFieldsForDataRow)
  /// {
  ///     return;
  /// }
  /// </summary>
  /// <param name="dataFieldsForDataRow"></param>
    public delegate void StructuredDataRowDataFieldsManipulation (ref Dictionary<string,string> dataFieldsForDataRow);

  /// <summary>    
  /// User defined validation. 
  /// Perform any additional validation needed and return either the original or a sanitized version of valueIn. 
  /// Throw exceptions if there are any issues. 
  /// Example:
  /// MBA.StructuredDataFieldAdditionalValidation _fnAdditionalFieldValidation = delegate (int rowNum, StructuredDataField field, string valueIn)
  /// {                        
  ///   return valueIn;
  /// }
  /// </summary>
  /// <param name="rowNumIn">row number</param>
  /// <param name="fieldDef">structure data field definition</param>
  /// <param name="valueIn">the value parsed from the row</param>
  /// <returns></returns>
  public delegate string StructuredDataFieldAdditionalValidation (int rowNumIn, StructuredDataField fieldDef, string valueIn);

  /***************************************************************************
   * StructuredDataFieldMatch */
  /**
   * 
   **************************************************************************/   
  public class StructuredDataFieldMatch
  {
     public string inputFieldName;
	 public string outputFieldName;
	 public long   inputFieldIdx;
	 public long   outputFieldIdx;
	 public string outputFieldLabel;
  }

  /***************************************************************************
   * StructuredDataColValidationMessage */
  /**
   * 
   **************************************************************************/       
  public class StructuredDataColValidationMessage
  {
    public string              columnLabelOriginal;    
    public string              value;
    public string              message;
    public StructuredDataField fieldDef;
    public StructuredDataColValidationMessage()
    {
    
    }
    public StructuredDataColValidationMessage (  StructuredDataField fieldDef
                                               , string columnLabelOriginal
                                               , string value
                                               , string message)
    { 
      this.fieldDef            = fieldDef;
      this.columnLabelOriginal = columnLabelOriginal;  
      this.value               = value;
      this.message             = message;
    }
  }

  /***************************************************************************
   * StructuredDataRow */
  /**
   * 
   **************************************************************************/       
  public class StructuredDataRow
  {
    public int          rowIdx;
    public int          rowNumIn;
    public bool         rowBad;
    public bool         optionalRowDataBad;
    public Object       rowData;
        
    public List<StructuredDataColValidationMessage> validationMessages;

    public StructuredDataRow() : this(-1, -1) 
    {
    
    }
    public StructuredDataRow(int rowIdx,int rowNumIn)
    {
      this.rowIdx             = rowIdx;
      this.rowNumIn           = rowNumIn;
      this.rowBad             = false;
      this.optionalRowDataBad = false;
      this.rowData            = null;
      this.validationMessages = new List<StructuredDataColValidationMessage>();

    }
  }

  /***************************************************************************
   * StructuredDataProfile */
  /**
   * Profile
   **************************************************************************/   
  public class StructuredDataProfile
  {
    public string id;
    public string fileClass;
    public string fileSubClass;
    public string name;
    public string label;
    public string description;
    public StructuredDataField[] fields;
  }  

  /***************************************************************************
   * StructuredDataInputDataObj */
  /**
   * Preparsed data
   **************************************************************************/   

  public class StructuredDataInputDataObj
  {
  	public bool     hasData;
    public Object   sheetData;    
	public int      numRows;
    public int      headerIdx;
    public int      dataStartIdx;
	public string[] hdrArr;    
    public int      numPreviewRows;
  }

  /***************************************************************************
   * StructuredDataFileInfoObj */
  /**
   *
   **************************************************************************/   

  public class StructuredDataFileInfoObj
  {
    public string name;
    public string mimeType;
    public long   size;	
  }

  
  /***************************************************************************
   * StructuredDataOutputDataObj */
  /**
   * Profile
   **************************************************************************/   

  public class StructuredDataOutputDataObj
  {
  	public Object[]            sheetData;   
	public int                 numPreviewRows;
	public int                 dataStartIdx;
	public string[]            hdrArr;        
  }
  
  /***************************************************************************
   * StructuredDataToImport */
  /**
   * Profile
   **************************************************************************/   
  public class StructuredDataToImport
  {
    public string                      fileProfileID;
    public StructuredDataProfile       fileProfile;          /* Not from request.  Populated internally. */
    public StructuredDataFileInfoObj   fileInfo;
    public StructuredDataInputDataObj  inputDataObj;
    public StructuredDataFieldMatch[]  inputOutputFieldMatches;
	public StructuredDataOutputDataObj outputDataObj;
    public List<StructuredDataRow>     structuredDataRows;   /* Not from request.  Populated internally.  Sanitized, standarized data with row references*/ 

    public int totNumRows                        = 0; /* Not from request.  Populated internally. */
    public int totNumGoodRows                    = 0; /* Not from request.  Populated internally. */
    public int totNumBadRows                     = 0; /* Not from request.  Populated internally. */
    public int totNumGoodRowsWithBadOptionalData = 0; /* Not from request.  Populated internally. */

    public StructuredDataToImport()
    {
      this.structuredDataRows                                  = new List<StructuredDataRow>();
      this.totNumRows                        = 0;
      this.totNumGoodRows                    = 0;
      this.totNumBadRows                     = 0;
      this.totNumGoodRowsWithBadOptionalData = 0;
    }
  }  

  /***************************************************************************
   * StructuredDataImportFiles */
  /**
   * Data file base class
   **************************************************************************/   
  public class StructuredDataImportFiles
  { 
    public const string EMPTY_PROFILE_SET = @"[]";
   
   /***************************************************************************
    * loadProfileSetsFileIntoString */
   /**
    *
    **************************************************************************/   
    public static string loadProfileSetsFileIntoString (string profileSetsFileName)
    {      
      string profileSetsPath = Constants.STRUCTURED_DATA_IMPORT_PROFILES_PATH;

      if (String.IsNullOrWhiteSpace(profileSetsPath))      return StructuredDataImportFiles.EMPTY_PROFILE_SET;
      if (String.IsNullOrWhiteSpace(profileSetsFileName))  return StructuredDataImportFiles.EMPTY_PROFILE_SET;
      string profileSetsPathAndFileName = System.IO.Path.Combine (profileSetsPath,  profileSetsFileName);
      if (!System.IO.File.Exists(profileSetsPathAndFileName)) return StructuredDataImportFiles.EMPTY_PROFILE_SET;
      string content = String.Empty;        
      using (var fs = new FileStream (   profileSetsPathAndFileName
                                       , FileMode.Open
                                       , FileAccess.Read
                                       , FileShare.ReadWrite))
       { 
         using (var tr = new StreamReader(fs))
         {
           content = tr.ReadToEnd();           
         }      
       }
       return content;
    }
 
    /***************************************************************************
     * loadProfileSetsFileIntoObject */
    /**
     *
     **************************************************************************/   
 
    public static StructuredDataProfile[] loadProfileSetsFileIntoObject (string structuredDataImportProfilesFileName)
    {
      StructuredDataProfile[] rd;
      try
      { 
        var json = MBA.StructuredDataImportFiles.loadProfileSetsFileIntoString(structuredDataImportProfilesFileName);
        var ro   = JSON.fromJSONString(json,typeof(StructuredDataProfile[]),JsonLibrary.NEWTONSOFT);
        rd = (StructuredDataProfile[]) ro;
        return rd;
      }
      catch (Exception psErr)
      {
        throw new Critical(@"Invalid profile set data");
      }
      
    }

    /***************************************************************************
     * loadDataToImportJSONIntoObj */
    /**
     *
     **************************************************************************/   
    public static StructuredDataToImport loadDataToImportJSONIntoObject (  string json 
                                                                         , string msgInvalidImportData)
    {
      StructuredDataToImport rd;
      try { 
        rd = (StructuredDataToImport) JSON.fromJSONString(json,typeof(StructuredDataToImport),JsonLibrary.NEWTONSOFT);             
        if (rd == null) throw new Critical(msgInvalidImportData);
        return rd;
      }
      catch (Exception importErr)
      {
         throw new Critical(msgInvalidImportData);
      }
    }

    /***************************************************************************
     * validate */
    /**
     * importFileObj.fileProfileID 
	 * importFileObj.outputDataObj
     **************************************************************************/   

    public static string validate (  string structuredDataImportProfilesFileName  
                                   , string dataToImportJSON
                                   , string msgInvalidImportData
                                   , string msgInvalidProfileID
                                   , string msgNoDataToImport
                                   , string msgAllRowsAreBad
                                   , StructuredDataRowDataFieldsManipulation dataRowDataFieldsManipulation
                                   , StructuredDataFieldAdditionalValidation additionalDataFieldValidation)
    {
      
       /* Load profiles set that is being used for this structured data import */

       var profileSetsObj = loadProfileSetsFileIntoObject(structuredDataImportProfilesFileName);
       
       /* Deserialize all of the standard elements of the data to import*/
       
       var dataToImportObj = loadDataToImportJSONIntoObject(dataToImportJSON, msgInvalidImportData);
       dataToImportObj.structuredDataRows = new List<StructuredDataRow>();
        
       StructuredDataProfile profileToUse = null;

       /* Make sure a file profile was selected */
     
       dataToImportObj.fileProfileID = Validate.reqString (dataToImportObj.fileProfileID,msgInvalidProfileID);
     
       /* Find data profile that was selected in the profile set  */

       foreach (var profile in profileSetsObj)
       {
          if (profile.id == dataToImportObj.fileProfileID)
          { 
            profileToUse = profile;
            break;
          }
       }

       /* If its not found then exit with an error */

       if (profileToUse is null) throw new Critical(msgInvalidProfileID);
       
       /* Otherwise save a copy of the profile used for later storage with the imported data.  We save a copy of the
        * profile used at the time for reference purposes since profiles may change. */

       dataToImportObj.fileProfile = profileToUse;       
       
       /* Create output field name to input field name (label) lookup so we can return the original field name to the user
        * in the event of a validation issue.  We also check for duplicate column names when we create the structure. */

       var dictOutToInFldName = new Dictionary<string, string>();
       
       foreach (var fldMatch in dataToImportObj.inputOutputFieldMatches)
       {
         if (dictOutToInFldName.ContainsKey(fldMatch.outputFieldName))
         {                      
           throw new Critical(@"Multiple columns were mapped to " + fldMatch.outputFieldName);
         } 
         else
         { 
            dictOutToInFldName.Add(fldMatch.outputFieldName,fldMatch.inputFieldName);                
         }
       }

       int rowIdxIn                       = 0;
       int rowNumIn                       = 2; /* Assumes header is first row */
       int numBadRows                     = 0;
       int numGoodRows                    = 0;
       int numGoodRowsWithBadOptionalData = 0;

       dataToImportObj.totNumRows                        = dataToImportObj.outputDataObj.sheetData.Length;
       dataToImportObj.totNumGoodRows                    = 0;
       dataToImportObj.totNumBadRows                     = 0;
       dataToImportObj.totNumGoodRowsWithBadOptionalData = 0;

       /* If there are 0 rows to import, exit */

       if (dataToImportObj.totNumRows == 0)
       {
         throw new Critical(msgNoDataToImport);       
       }

       /* Go through each row being imported */

       Dictionary<string, string> badRowSummary = new Dictionary<string, string>();
       
       foreach (var dataRowIn in dataToImportObj.outputDataObj.sheetData)
       {           
         /* Create new structured data row to hold the validated, sanitized, and standardized data */

         dataToImportObj.structuredDataRows.Add(new StructuredDataRow(rowIdxIn,rowNumIn));

         /* Get fields in row */

         Dictionary<string,string> dataFieldsForDataRow = JSON.dictFromJSONString(dataRowIn.ToString());

         /* Call data manipulation delegate if provided */

         if (dataRowDataFieldsManipulation != null) { 
           dataRowDataFieldsManipulation(ref dataFieldsForDataRow);           
         }

         /* Go through each field definition in the file profile used */
                  
         foreach (var fieldDef in profileToUse.fields)
         {                     
           string valueIn = String.Empty;
           string labelIn = String.Empty;

           /* Attempt to get individual field value by standard name from fields in incoming row */ 
           
           try
           {
             valueIn = dataFieldsForDataRow[fieldDef.name];
           }

           /* If any fields are missing, this means the incoming data structure is invalid.
            * The structure could be invalid due to a client side error or tampering with the request.
            * or a request that was not generated properly (ie not using the structured data import plugin to generate request data)
            * In any event, we cannot continue so exit with an expection.
            */ 

           catch(Exception derr)
           {
             string msg = String.Format(@"<p class=""structured-data-import-exceptions"">Invalid incoming data format, excepted to find a field for <strong class=""structured-data-import-exceptions structured-data-import-exceptions-field-name"">{0}</strong></p>", fieldDef.name);
             throw new Critical(msg);
           }
           
           /* Attempt to get original column label from the file being imported for this field.  We use this to provide
            * the user a reference back to their original file column if there is a problem. */

           if (dictOutToInFldName.TryGetValue(fieldDef.name,out labelIn) == false)
           {
             
             /* If its not found and the column is required exit with error and provide the user with a list of acceptable
              * column header names they can use. */

             if (fieldDef.columnRequired == true) 
             { 
               
                StringBuilder sbAcceptableNames = new StringBuilder();
                            
                sbAcceptableNames.AppendFormat(@"No source column was specified or could be automatically determined for <strong class=""structured-data-import-exceptions structured-data-import-exceptions-field-name"">{0}</strong>.", fieldDef.label);
                sbAcceptableNames.Append(@"<p class=""structured-data-import-exceptions"">");
                sbAcceptableNames.AppendFormat(@"Please edit <strong class=""structured-data-import-exceptions structured-data-import-exceptions-file-name"">{0}</strong>",dataToImportObj.fileInfo.name);
                sbAcceptableNames.AppendFormat(@"and change the column header for the column that contains <strong class=""structured-data-import-exceptions structured-data-import-exceptions-field-name"">{0}</strong> to one of the following acceptable values :", fieldDef.label);
                sbAcceptableNames.Append(@"<br>");
                sbAcceptableNames.AppendFormat(@"<strong class=""structured-data-import-exceptions structured-data-import-exceptions-field-name"">{0}</strong>",fieldDef.label);
                sbAcceptableNames.Append(@"<br>");
                sbAcceptableNames.AppendFormat(@"<strong class=""structured-data-import-exceptions structured-data-import-exceptions-field-name"">{0}</strong>",fieldDef.name);
                sbAcceptableNames.Append(@"</p>");
                string msg = sbAcceptableNames.ToString();
                throw new Critical(msg);
             }

             /* Otherwise its optional and there will be no mapping so use the placeholder label */

             else
             {
               labelIn = fieldDef.label;
             }

           }

           /* Validate and sanitize incoming field value */

           string valueOut = String.Empty;
           
           try 
           { 
            
             /* Validate, santitize, and standardize incoming value */
             
             valueOut = StructuredDataField.validate (rowNumIn,fieldDef,valueIn);

             /* Call additional validation if provided. */

             if (additionalDataFieldValidation != null) {  
               valueOut = additionalDataFieldValidation(rowNumIn,fieldDef,valueOut);
             }
             
           }
           
           /* If the validation throws an exception, we do not stop the import.  Rather we just see what we can salvage
            * and worse case scenerio we will not import this row on the back end. */
           
           catch (Exception cellErr)
           {
             
             /* We are not going to use the value */

             valueOut = String.Empty;             
             
             /* If the data is required then we don't import the row on the back end */

             if (fieldDef.dataRequired)
             { 
               dataToImportObj.structuredDataRows[rowIdxIn].rowBad = true;
               dataToImportObj.structuredDataRows[rowIdxIn].validationMessages.Add(new StructuredDataColValidationMessage(fieldDef,labelIn,valueIn,cellErr.Message));
               if (!badRowSummary.ContainsKey(fieldDef.label)) badRowSummary.Add(fieldDef.label,cellErr.Message);                          
             }

             /* Otherwise we try to salvage what we can */

             else
             {
               dataToImportObj.structuredDataRows[rowIdxIn].optionalRowDataBad = true;
               dataToImportObj.structuredDataRows[rowIdxIn].validationMessages.Add(new StructuredDataColValidationMessage(fieldDef,labelIn,valueIn,cellErr.Message));
             }
           }
           
           /* Replace the original field value with the sanitized one */

           dataFieldsForDataRow[fieldDef.name] = valueOut;            
           
         } /* Each field in that row */     
         
         /* Update row counters */

         if (dataToImportObj.structuredDataRows[rowIdxIn].rowBad == false) 
         {
           numGoodRows++;
           if (dataToImportObj.structuredDataRows[rowIdxIn].optionalRowDataBad == true)
           { 
             numGoodRowsWithBadOptionalData++;
           }  
         }
         else
         {
            numBadRows++;
         }
         
         /* Replace structured data row rowData with validated sanitized, standardized data.
          * outputDataObj.sheetData continues to have the original data mapped out to standard column names */
         
         dataToImportObj.structuredDataRows[rowIdxIn].rowData = dataFieldsForDataRow;
         rowIdxIn++;
         rowNumIn++;                      

       } /* Each incoming row */

       dataToImportObj.totNumGoodRows                    = numGoodRows;
       dataToImportObj.totNumBadRows                     = numBadRows;
       dataToImportObj.totNumGoodRowsWithBadOptionalData = numGoodRowsWithBadOptionalData;

       /* If ALL of the rows are bad then exit with an error */
       
       if ((dataToImportObj.totNumGoodRows == 0) && (dataToImportObj.totNumBadRows != 0))
       {                  
          /* Exit with exception */

          StringBuilder sbAllBadRowsMsg = new StringBuilder();
          sbAllBadRowsMsg.Append(msgAllRowsAreBad);
          sbAllBadRowsMsg.AppendFormat(@"<p class=""structured-data-import-exceptions"">Some or all of the following columns in <strong class=""structured-data-import-exceptions structured-data-import-exceptions-file-name"">{0}</strong> contain invalid data in every single row.</p>", dataToImportObj.fileInfo.name);
          sbAllBadRowsMsg.Append(@"<table class=""structured-data-import-exceptions""><thead><tr><th>Column</th><th>Issue Detected</th></tr></thead><tbody>");
          foreach (var kvp in badRowSummary)
          {
            sbAllBadRowsMsg.AppendFormat (@"<tr><td>{0}</td><td>{1}</td></tr>",kvp.Key,kvp.Value); 
          }
          sbAllBadRowsMsg.Append(@"</tbody></table>");
          throw new Critical(sbAllBadRowsMsg.ToString());
       }  
        
       /* Reserialize and return clean and validated importData */

       string dataToImportOutJSON = JSON.toJSONString(dataToImportObj,JsonLibrary.NEWTONSOFT);       
       return dataToImportOutJSON;        
    }
  }
}
