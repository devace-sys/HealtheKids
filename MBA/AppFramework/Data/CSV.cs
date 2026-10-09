using System;
using System.Globalization;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Drawing;

/**************************************************************************
 * CSV */
/**
 * The methods within are mostly compliant with RFC4180 
 * 
 * See : https://www.rfc-editor.org/rfc/rfc4180
 * 
 * The biggest difference is that we replace CR LF with whitespace. 
 *
 * The spec allows for these BUT simple parsing programs that use something
 * like readline() might have issues.  
 *
 * Its likely that any data exported using these methods would not suffer
 * much from having CR LF replaced (multi line free form text, etc).
 **************************************************************************/
   
namespace MBA
{
  public class CSV:File2
  {      
    
    public const string DELIMITER_COMMA = ",";

    /**************************************************************************
     * generateFileName */
    /**
     * Create file name
     * 
     ***************************************************************************/

    public static string generateFileName (string name)
    {
      return generateFileName("", name);
    }
    
    public static string generateFileName (string folder, string name)
    {
      return GenerateFileName(folder, name, "csv");
    }

    /**************************************************************************
     * needToEncloseCellInDoubleQuotes */
    /**
     * Does value contain characters that rfc4180 says to enclose the value in
     * double quotes if the characters are present
     ***************************************************************************/
              
    public static bool needToEncloseCellInDoubleQuotes (string seperator, string value)
    {
      /* See : https://www.rfc-editor.org/rfc/rfc4180#section-2 */

      if (value.Contains(seperator)) return true;  /* If a cell value contains the seperator the entire value needs to be enclosed in double quotes */
      if (value.Contains(@""""))     return true;  /* If a cell value contains double quotes the entire value needs to be enclosed in double quotes and the double quotes in the value escaped using an extra double quote.  We handle the escaping in another function. */      
      return false;
    }

    /**************************************************************************
     * createCell */
    /**
     * Take value and properly format it for inclusion in a row
     ***************************************************************************/
    public static string createCell (string seperator, Object value)
    {
      if (value is null) return String.Empty;
      string valueStr = value.ToString();
      return createCell(seperator,valueStr);      
    }
        
    public static string createCell (string seperator, string value)
    {
      /* See: https://www.rfc-editor.org/rfc/rfc4180#section-2 */

      if (value is null) return String.Empty;
      
      string enclosureString = (needToEncloseCellInDoubleQuotes(seperator,value)) ? @"""" : @"";

      string cell = enclosureString  
                   + value
                   .Replace(@"""",@"""""")      /* Escape double quotes.*/
                   .Replace("\r"," ")           /* Replace cr */
                   .Replace("\n"," ")           /* Replace newline */
                   .Trim()                      /* Remove leading/trailing ws */
                   + enclosureString;
      return cell;
    }

    /**************************************************************************
     * returnDataTableToFile */
    /**
     * Generate CSV file bytes from contents of rd
     ***************************************************************************/

    public static Byte[] returnDataTableToFile (ref ReturnDataTable rd)
    {
       return returnDataTableToFile(DELIMITER_COMMA,ref rd);
    }
    public static Byte[] returnDataTableToFile ( string seperator, ref ReturnDataTable rd )
    {
      StringBuilder doc = new StringBuilder();

      List<String> headerCells = new List<string>();
      foreach (aoColumn col in rd.aoColumns)
      {        
        if (col.bVisible) headerCells.Add(createCell(seperator,col.sTitle));
      }
      doc.AppendLine(String.Join(seperator,headerCells));      

      foreach (Object[] arow in rd.aaData)        
      {
        int colPtr = 0;      
        List<String> recordCells = new List<string>();
        foreach (Object fld in arow)
        {                    
          aoColumn col = rd.aoColumns[colPtr];         
          if (col.bVisible) recordCells.Add(createCell(seperator,fld));          
          colPtr++;
        }
        doc.AppendLine(String.Join(seperator,recordCells));
      }
      
      byte[] b1 = System.Text.Encoding.UTF8.GetBytes (doc.ToString());
      return b1;	      
    } 

    /**************************************************************************
     * returnRptDataToFile */
    /**
     * Generate CSV file bytes from contents of rd
     * Not used.  Not implemented.  Included here to satify interfaces.
     ***************************************************************************/

    public static Byte[] returnRptDataToFile ( ref ReturnRptData rd )
    {
      return null;
    }   	           
  }
}
