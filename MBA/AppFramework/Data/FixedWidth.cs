using System;
using System.Globalization;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Drawing;

/**************************************************************************
 * FixedWidth */
/**
 * Fixed position fields export
 **************************************************************************/
   
namespace MBA
{
 
  /**************************************************************************
   * FixedWidth */
  /**
   * 
   * 
   ***************************************************************************/

  public class FixedWidth:File2
  {      
    
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
    public static string createCell (FixedWidthFieldDefinition fd, Object value)
    {
      if (fd is null) return String.Empty;
      if (value is null) value = String.Empty;
      string valueStr = value.ToString();
      return createCell(fd,valueStr);
    }	        
    public static string createCell (FixedWidthFieldDefinition fd, string value)
    {
      if (String.IsNullOrWhiteSpace(value)) value = String.Empty;

      string cell = value
                    .Replace("\r", " ")           /* Replace cr */
                    .Replace("\n", " ")           /* Replace newline */
                    .Trim();                     /* Remove leading/trailing ws */

      if (fd.padRight == true)
          return cell.PadRight(fd.size);
      else 
          return cell.PadLeft(fd.size);
    }

    /**************************************************************************
     * returnDataTableToFile */
    /**
     * Generate file bytes from contents of rd	 
     ***************************************************************************/

    public static Byte[] returnDataTableToFile ( ref ReturnDataTable rd )
    {
      if (rd.fixedWidthFieldDefinitions is null) throw new Critical("Fixed width field definitions not defined");
      if (rd.fixedWidthFieldDefinitions.Count == 0) throw new Critical("Fixed width field definitions not defined");

      StringBuilder doc = new StringBuilder();
                  
      foreach (Object[] arow in rd.aaData)        
      {
        int colPtr = 0;      
        List<String> recordCells = new List<string>();
        foreach (Object fld in arow)
        {                    
          aoColumn col = rd.aoColumns[colPtr];
          var fd = rd.fixedWidthFieldDefinitions.Find(x => x.fieldName == col.sTitle);          
          recordCells.Add(createCell(fd,fld));          
          colPtr++;
        }
        doc.AppendLine(String.Join(@"",recordCells));
      }

      if (!String.IsNullOrWhiteSpace(rd.tableFooter))
      { 
        doc.AppendLine(rd.tableFooter);
      }
      byte[] b1 = System.Text.Encoding.UTF8.GetBytes (doc.ToString());
      return b1;	      
    }

    /**************************************************************************
     * returnRptDataToFile */
    /**
     * Generate file bytes from contents of rd
     * Not used.  Not implemented.  Included here to satify interfaces.
     ***************************************************************************/

    public static Byte[] returnRptDataToFile ( ref ReturnRptData rd )
    {
      return null;
    }   	           
  }
}
