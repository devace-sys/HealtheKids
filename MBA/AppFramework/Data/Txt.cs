using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace MBA
{

  /***************************************************************************
   * File */
  /**
   * Text file utilities
   **************************************************************************/   
 
  public class Txt:File
  {
    
    /***************************************************************************
     * loadText */
    /**
     * load the contents of a text file
     * 
     * @param  filename   Full path and filename
     * @param  newLines   true  = preserve newlines
     *                    false = remove newlines (if any)
     * @return string containing text or null if file is not found
     **************************************************************************/   
    
    public static string loadText(string filename)
    {
      return loadText(filename, false);
    }
    
    public static string loadText(string filename, bool newLines)
    {
      if (!System.IO.File.Exists(filename)) return null;

      FileStream   fs = new FileStream(filename,FileMode.Open, FileAccess.Read, FileShare.Read);
      StreamReader sr = new StreamReader(fs);
      
      try
      {
        StringBuilder  sb     = new StringBuilder();
        string         lineIn = "";
        
        while ((lineIn = sr.ReadLine()) != null) 
        {
          if (newLines)
            sb.AppendLine(lineIn);
          else
            sb.Append(lineIn);
        }
        
        string textOut = sb.ToString();
        return textOut;
      }
      catch (Exception e)
      {
        throw e;
      }
      finally
      {
        sr.Close();
      }
    }        
  }
}
