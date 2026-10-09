using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Drawing;
using MBA.IdentifyData;
using MBA.Reporting;

namespace MBA
{ 
  
  /***************************************************************************
   * File */
  /**
   * Data file base class
   **************************************************************************/   
 
  public abstract class File2
  { 
  
    protected const string FS_EMPTY           = @"empty";    
    protected const string FS_DATE            = @"date";
    protected const string FS_TIME            = @"time";
    protected const string FS_DATE_MONTH_YEAR = @"date_month_year";
    protected const string FS_BOOLEAN         = @"boolean";
    protected const string FS_INTEGER         = @"integer";
    protected const string FS_FLOAT           = @"float";
    protected const string FS_PERCENT         = @"percent";
    protected const string FS_DECIMAL         = @"decimal";
    protected const string FS_STRING          = @"string";
    protected const string FS_EMAIL           = @"email";
    protected const string FS_URI             = @"uri";
      
	  /***************************************************************************
     * GenerateFileName */
    /**
     * Combines folder, name, and extension into a filename
     * 
     * @param  folder     Path to file (optional)
     * @param  name       Name of the file (no extension)
     * @param  extension  File extension
     **************************************************************************/           

    public static string GenerateFileName (string name, string extension)
    {
      return GenerateFileName("", name, extension);
    }

    public static string GenerateFileName (string folder, string name, string extension)
    {
      string _filename;
      string _folder;
      string _name;
      string _extension;
            
      if (Util.IsNullOrEmpty(folder))    _folder = "" ; else _folder    = folder.Trim();
      if (Util.IsNullOrEmpty(name))      return ""    ; else _name      = name.Trim();
      if (Util.IsNullOrEmpty(extension)) return ""    ; else _extension = extension.Trim().Replace(".","");
            
      if (!Util.IsNullOrEmpty(_folder))
        _filename = System.IO.Path.Combine(_folder,_name);
      else
        _filename = _name;
      
      _filename = _filename + "." + _extension;
      
      return _filename;
    }
 	      
    /***************************************************************************
     * WriteBytes */
    /**
     * Write the contents of a byte array out to a file
     * 
     * @param  filename   Full path and filename
     * @param  file       Byte array containing file data
     **************************************************************************/   

    public static void WriteBytes (string filename, ref Byte[] file)
    {
      System.IO.File.WriteAllBytes(filename, file);      
    }
    
  }
}
