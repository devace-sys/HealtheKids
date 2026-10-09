using System;
using System.Globalization;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Drawing;

/**************************************************************************
 * PSV */
/**
 * There is (at the time of the creation of this lib) no RFC for pipe
 * delim files.
 * 
 * This lib will replace replace CR LF with whitespace and it will remove
 * any instances of the delimeter from values but everything else
 * is allowed 
 **************************************************************************/
   
namespace MBA
{
  public class PSV:File2
  {      
    
    public const string DELIMITER_PIPE = "|";

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
      return GenerateFileName(folder, name, "txt");
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

      if (value is null) return String.Empty;
      

      string cell = value
                   .Replace(seperator,"")       /* Replace seperator with empty string */
				   .Replace("\r"," ")           /* Replace cr */
                   .Replace("\n"," ")           /* Replace newline */
                   .Trim();                     /* Remove leading/trailing ws */
      return cell;
    }

    /**************************************************************************
     * returnDataTableToFile */
    /**
     * Generate CSV file bytes from contents of rd
     ***************************************************************************/

    public static Byte[] returnDataTableToFile (ref ReturnDataTable rd)
    {
       return returnDataTableToFile(DELIMITER_PIPE,ref rd);
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
     * Generate PSV file bytes from contents of rd
     * Not used.  Not implemented.  Included here to satify interfaces.
     ***************************************************************************/

    public static Byte[] returnRptDataToFile ( ref ReturnRptData rd )
    {
      return null;
    }   	           
  }
}
