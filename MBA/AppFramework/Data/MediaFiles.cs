using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace MBA
{
 
  /**************************************************************************
   * MediaFileListType */
  /**
   * How to assemble the list
   * 
   ****************************************************************************/

  public enum MediaFileListCreateMode
  {
    ListFromSearch = 1,
    ListFromPath   = 2    
  }
  
  /**************************************************************************
   * MediaFileLists */
  /**
   * Methods uses to assemble media file lists
   * 
   ****************************************************************************/
  
  public class MediaFiles
  {
    
  
    public static List<MediaFile> CreateResultList(MediaFileListCreateMode mode, string root, string searchPattern, bool allMatches)
    {
      List<MediaFile> results = new List<MediaFile>();
      
      if (mode == MediaFileListCreateMode.ListFromPath)   results = CreateResultListFromPath(root);
      if (mode == MediaFileListCreateMode.ListFromSearch) results = CreateResultListFromSearch(root, searchPattern, allMatches);
      return results;
    }
    
    public static List<MediaFile> CreateResultListFromSearch(string root, string searchPattern, bool allMatches)
    {
      List<MediaFile> results = new List<MediaFile>();
      foreach (MediaFile f in MBA.MediaFiles.MediaFileSearch(root, searchPattern, allMatches))
        results.Add(f);  
      return results;
    }
 
    public static List<MediaFile> CreateResultListFromPath (string root)
    {
      
      int depth = 0;
      List<MediaFile> results = new List<MediaFile>();     
      MediaFileTraverse(root,depth,ref results);
      return results;
    }  
  
    public static IEnumerable<MediaFile> MediaFileSearch (string root, string searchPattern, bool allMatches)
    {

      Queue<string> dirs = new Queue<string>();

      // If root does not exist, get out

      if (!Directory.Exists(root)) yield break;

      // Put root in

      dirs.Enqueue(root);

      // Main loop.  This is what keeps the searching going

      while (dirs.Count > 0)
      {
        // Next dir to eval

        string dir = dirs.Dequeue();

        // files

        string[] paths = null;

        try
        {
          paths = Directory.GetFiles(dir, searchPattern);
        }
        catch
        {

        } // swallow

        // we got files

        if (paths != null && paths.Length > 0)
        {
          foreach (string file in paths)
          {
            // Get info on file

            FileInfo fi = new FileInfo(file);
                        
            // Return file to iterator
              
            yield return new MediaFile(fi,0);
                          
            // If we are just looking for the first match, get out

           if (!allMatches) yield break;
            
          }
        }

        // sub-directories

        paths = null;

        try
        {
          paths = Directory.GetDirectories(dir);
        }
        catch
        {
        } // swallow

        if (paths != null && paths.Length > 0)
        {
          foreach (string subDir in paths)
          {
            // Add the dir, keeping us in the loop

            dirs.Enqueue(subDir);
          }
        } // paths
      } // main loop
    } // method
    
    
    public static void MediaFileTraverse (string path, int depth, ref List<MediaFile> list)
    {
      try
      {
        string[] files = null;

        try
        {
          files = Directory.GetFiles(path);
        }
        catch
        {
        }

        if (files != null)
        {
          foreach (string f in files)
          {
            FileInfo fi = new FileInfo(f);            
            list.Add(new MediaFile(fi,depth));
          }
        }
        
        string[] dirs = null;

        try
        {
          dirs = Directory.GetDirectories(path);
        }
        catch
        {
        }

        if (dirs != null)
        {
          foreach (string d in dirs)
          {
            
            DirectoryInfo di = new DirectoryInfo(d);            
            list.Add(new MediaFile(di,depth));
            depth++;
            MediaFileTraverse (d,depth, ref list);            
            depth--;
          }
        }

        
        
      }
      catch (Exception e)
      {
        throw new Critical(e.Message);
      }
    }    

  }
}

