using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Collections.Specialized;
using System.Collections;
using System.IO;
using System.Globalization;
using CsvHelper;
using MBA;

namespace Spedmon
{    
  public class DHCSReturnFileColumnMap
  {
     public int csvIndex     { get ; set; }
     public string csvField  { get ; set; }
     public string txtField  { get ; set; }
     public int txtFieldSize { get ; set; }
  }

  public class FromDHCSFiles 
  {
    /***************************************************************************
     * getReturnFileColumnMaps */
    /**
     * 
     ****************************************************************************/

     public static List<DHCSReturnFileColumnMap> getReturnFileColumnMaps (string mappingFile)
     {
       var mappingData = new List<DHCSReturnFileColumnMap>();

       if (String.IsNullOrWhiteSpace(mappingFile)) return mappingData; /* No filename passed, get out with empty list */
       if (!System.IO.File.Exists(mappingFile))    return mappingData; /* File not found, get out with empty list */

       /* Attempt to parse column mapping file */

       try { 
         using (var sr = new StreamReader(mappingFile)) { 
           using (var csv = new CsvReader(sr, CultureInfo.InvariantCulture)) {
             var recs = csv.GetRecords<DHCSReturnFileColumnMap>();
               foreach (var rec in recs){
                 mappingData.Add((DHCSReturnFileColumnMap) rec);
               }
           } /* csv */
         } /* sr */
       } /* try */
       
       /* Any issues parsing.  Get out with empty list.*/

       catch {
         mappingData.Clear();
         return mappingData;
       }

       /* If we get to this point, no issues. */
       return mappingData;
     }      
     
    /***************************************************************************
     * createEmptyFileOut */
    /**
     * 
     ****************************************************************************/

    public static bool createEmptyFileOut ( string fileOut )
    {      
      if (String.IsNullOrWhiteSpace(fileOut)) return false;  /* If fileOut is not specified, get out */
      try { 
        using (var sw = new StreamWriter(fileOut,false)) {          
          sw.Write(String.Empty);
        }
      }
      catch {
        return false;
      }
      return true;
    }
    
    /***************************************************************************
     * parseReturnFile */
    /**
     * 
     ****************************************************************************/

     public static bool parseReturnFile (  ref List<DHCSReturnFileColumnMap> colMaps
                                         , string fileIn
                                         , string fileOut
                                         , bool   appendToFileOut = false)
     {      
       if (String.IsNullOrWhiteSpace(fileIn))  return false;  /* If fileIn is not specified, get out */
       if (String.IsNullOrWhiteSpace(fileOut)) return false;  /* If fileOut is not specified, get out */
       if (!System.IO.File.Exists(fileIn))     return false;  /* If fileIn does not exist, get out */       
       
       /* Get info for fileIn */

       var fi = new System.IO.FileInfo(fileIn);  

       if (fi.Length == 0)     return false;     /* If file in is empty (0 bytes), get out */
       if (colMaps.Count == 0) return false;     /* No column maps, get out */
       
       /* Try to parse */

       try { 
         using (var sw = new StreamWriter(fileOut,appendToFileOut)) {
           using (var sr = new StreamReader(fileIn)) { 
             using (var csv = new CsvReader(sr, CultureInfo.InvariantCulture)) {
               csv.Read();
               csv.ReadHeader();
               while (csv.Read()) {
                 var sb = new StringBuilder();
                 foreach (var colMap in colMaps) {                    
                  /* This is a data field */ 
                  if (colMap.csvIndex != -1) {                     
                     string fld = Util.removeAllControlAndNonASCIIChars(csv.GetField(colMap.csvIndex)); /* Get raw field and sanitize its data */
                     sb.Append(fld.Trim().PadRight(colMap.txtFieldSize));                               /* Trim sanitized field and add padding */           
                   }
                   /* This is a filler field */
                   else {
                     sb.Append("".PadRight(colMap.txtFieldSize)); /* Create padding field */
                   }
                 } /* colmaps */ 
                 sw.WriteLine(sb.ToString());
               } /* csv read*/
             } /* csv */
           } /* filein */
         } /* file out */  
       } /* try */
       /* Any issues in parsing, get out */
       catch {
         return false;
       }
       /* If we get to this point no issues */
       return true;            
     }
  }
}
