using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using ICSharpCode.SharpZipLib.Core;
using ICSharpCode.SharpZipLib.Zip;
using System.Configuration;
using System.Reflection;

namespace MBA.X12
{
	public static class Utility
	{
	  	  
	  /// <summary>
	  /// Used to create output file name and path based on fileIn
	  /// </summary>
	  /// <param name="fileIn"></param>
	  /// <param name="appendToName"></param>
	  /// <param name="newExtension"></param>
	  /// <returns></returns>
	  
	  public static string CreateOutputFileName (string fileIn, string newExtension)
	  {
	    return CreateOutputFileName(fileIn,@"",newExtension,@"{0}.{2}");  
	  }

	  public static string CreateOutputFileName (string fileIn, string appendToName, string newExtension)
    {      
	    return CreateOutputFileName(fileIn,appendToName,newExtension,@"{0}_{1}.{2}");	    
    }

	  private static string CreateOutputFileName (string fileIn, string appendToName, string newExtension, string fmtString)
	  {	    
	  	var fi = new FileInfo(fileIn);
	  	return Path.Combine(fi.DirectoryName,String.Format(fmtString,fi.Name, appendToName, newExtension));
	  }
		
	  /// <summary>
    /// Gets the full path of the users desktop and provided filename.
    /// Filename does not have to exist
    /// </summary>
    /// <returns>The desktop path and file.</returns>
    /// <param name="filename">Filename.</param>

    public static string GetDesktopPathAndFile (string filename)
    {
      string folder = System.Environment.GetFolderPath(System.Environment.SpecialFolder.Desktop);
      return System.IO.Path.Combine(folder, filename);
    }

    /// <summary>
    /// Extracts contents of zip file.
    /// Code based on snippet from https://github.com/icsharpcode/SharpZipLib/wiki/Zip-Samples#unpack-a-zip-with-full-control-over-the-operation
    /// </summary>
    /// <param name="archiveFilenameIn"></param>
    /// <param name="password"></param>
    /// <param name="outFolder"></param>
    /// <returns>List<String> of file names</String></returns>
     
    public static List<String> ExtractZipFile (string archiveFilenameIn, string password, string outFolder)
    {
      var filesOut = new List<String>();
       
      ZipFile zf = null;
      try 
      {
        FileStream fs = File.OpenRead(archiveFilenameIn);
        zf = new ZipFile(fs);
        if (!String.IsNullOrEmpty(password)) 
        {
          zf.Password = password;    // AES encrypted entries are handled automatically
        }
        foreach (ZipEntry zipEntry in zf)
        {
          if (!zipEntry.IsFile) 
          {
            continue;      // Ignore directories
          }
          String entryFileName = zipEntry.Name;
        
          // to remove the folder from the entry:- entryFileName = Path.GetFileName(entryFileName);
          // Optionally match entrynames against a selection list here to skip as desired.
          // The unpacked length is available in the zipEntry.Size property.

          var buffer = new byte[4096];    // 4K is optimum
          Stream zipStream = zf.GetInputStream(zipEntry);

          // Manipulate the output filename here as desired.
           
          String fullZipToPath = Path.Combine(outFolder, entryFileName);
          filesOut.Add(fullZipToPath);
          string directoryName = Path.GetDirectoryName(fullZipToPath);
          if (directoryName.Length > 0)
            Directory.CreateDirectory(directoryName);

          // Unzip file in buffered chunks. This is just as fast as unpacking to a buffer the full size
          // of the file, but does not waste memory.
          // The "using" will close the stream even if an exception occurs.
            
          using (FileStream streamWriter = File.Create(fullZipToPath)) {
            StreamUtils.Copy(zipStream, streamWriter, buffer);
          }
        }
      } 
      finally 
      {
        if (zf != null) 
        {
          zf.IsStreamOwner = true; // Makes close also shut the underlying stream
          zf.Close(); // Ensure we release resources
        }
      }
      return filesOut;
    }
    
    /// <summary>
    /// Gets app setting from config
    /// </summary>
    /// <param name="key"></param>
    /// <returns></returns>
   
    public static string GetAppSetting (string key)
    {                    
      return ConfigurationManager.AppSettings[key];
    }
    
    /// <summary>
    /// Sets app setting in config
    /// </summary>
    /// <param name="key"></param>
    /// <param name="value"></param>
   
    public static void SetAppSetting(string key, string value)
    {
      var config = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
      config.AppSettings.Settings[key].Value = value;
      config.Save(ConfigurationSaveMode.Full, true);      
      ConfigurationManager.RefreshSection("appSettings");
    }
    
    /// <summary>
    /// Open folder in File Explorer
    /// </summary>
    /// <param name="name">Path of folder</param>
    
    public static void OpenFolder(string name)
    {
      try
      {
        if (String.IsNullOrEmpty(name)) return;
        if (!System.IO.Directory.Exists(name)) return;     
        var psi = new System.Diagnostics.ProcessStartInfo();
        psi.FileName = name;
        psi.UseShellExecute = true;
        psi.Verb = "open";
        System.Diagnostics.Process.Start(psi);
      }
      catch
      {
        return;
      }
    }
    /// <summary>
    /// Opens the containing folder in File Explorer that the given file is in 
    /// </summary>
    /// <param name="name"></param>
    
    public static void OpenFolderFileIsIn (string name)
    {
      try
      {
        if (String.IsNullOrEmpty(name)) return;
        if (!System.IO.File.Exists(name)) return;      
        var folder = System.IO.Path.GetDirectoryName(name);
        OpenFolder(folder);
      }
      catch
      {
        return;
      }
    }
    
  }
}