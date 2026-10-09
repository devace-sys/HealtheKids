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
using MBA;
using EAW.MediaFile;


namespace MBA
{    

  /***************************************************************************
   * PostedFile */
  /**
   *
   ****************************************************************************/
  
  public class PostedFile
  {
    public string uploadedAs;
    public string savedAs;
    public string savedIn;
    public string ContentType;
    public int    ContentLength;
    public long   fileSize;
    public string mimeType;
  }
      
  /***************************************************************************
   * PostedFiles */
  /**
   * Request 
   ****************************************************************************/

  public class PostedFiles:Entities
  {

    /***************************************************************************
     * getOriginalPostedFilename */
    /**
     * Gets original file name of posted file, removing path data if neccessary.
     ****************************************************************************/
     
    public static string getOriginalPostedFilename (HttpPostedFile file)
    {      
      string ofn = System.IO.Path.GetFileName(file.FileName);
      return ofn;
    }
    
    /***************************************************************************
     * createUniqueFilenameFromOriginalPostedFilename */
    /**
     * Creates unique file name from original file name.  Also replaces spaces
     * with underscores.
     * 
     * @parm    originalFileName    Original file name
     ****************************************************************************/   
    
    public static string createUniqueFilenameFromOriginalPostedFilename (int fileIdx, string originalFileName)
    {      
      string ofn1 = System.IO.Path.GetFileName(originalFileName);
      string uid  = MBA.Util.createUniqueID();
      string ofn2 = ofn1.Replace(' ','_').Trim();
      string ufn  = String.Format(@"{0}-{1}-{2}",uid,fileIdx,ofn2);
      return ufn;
    }

    /***************************************************************************
     * createSavedFolderFilename */
    /**
     * Creates path + filename to save file under
     * 
     * @parm    uploadFolder    Folder to save file in
     ****************************************************************************/   
    
    public static string createSavedFolderFilename (string saveInFolder, string saveAsFilename)
    {
      string sfn = System.IO.Path.Combine(saveInFolder, saveAsFilename);
      return sfn;
    }   
    
    /***************************************************************************
     * getFilesPosted */
    /**
     * Gets uploaded files
     * 
     ****************************************************************************/
     
    public static List<PostedFile> getFilesPosted (HttpFileCollection postedFiles)
    {
      
      List <PostedFile> uploadedFiles = new List<PostedFile>();
      
      int fileCount = postedFiles.Count;

      if (fileCount > 0)
      {                              
        for (int idx = 0 ; idx < fileCount ; idx++)
        {                    
          HttpPostedFile postedFile   = postedFiles[idx];                            
          PostedFile uploadedFile = new PostedFile();
          
          if (postedFile != null)
          {                  
            if (postedFile.ContentLength > 0)
            {
              string origfile = PostedFiles.getOriginalPostedFilename (postedFile);
              uploadedFile.uploadedAs = origfile;
              uploadedFile.ContentLength = postedFile.ContentLength;
              uploadedFile.ContentType   = postedFile.ContentType;
              uploadedFiles.Add(uploadedFile);
            }              
          }  
        }
      }

      return uploadedFiles;

    }
               
    /***************************************************************************
     * saveFilesPosted */
    /**
     * Saves posted files and returns a list of what was saved
     * 
     ****************************************************************************/

    public static List<PostedFile> saveFilesPosted ( HttpFileCollection postedFiles )
    {
      return saveFilesPosted(postedFiles, Constants.FILE_UPLOAD_PATH);
    }
    
    public static List<PostedFile> saveFilesPosted ( HttpFileCollection postedFiles, string uploadFolder)
    {
      
      List<PostedFile> uploadedFiles = getFilesPosted (postedFiles);
                            
      int fileCount = uploadedFiles.Count;
      
      if (fileCount > 0)
      {               
           
        for (int idx = 0 ; idx < fileCount ; idx++)
        {                              
          HttpPostedFile postedFile = postedFiles[idx];                  

          string origfile = uploadedFiles[idx].uploadedAs;
          string uniqfile = PostedFiles.createUniqueFilenameFromOriginalPostedFilename (idx,origfile);
          string savefile = PostedFiles.createSavedFolderFilename  (uploadFolder, uniqfile);                 
          
          uploadedFiles[idx].savedAs = uniqfile;
          
          if (System.IO.Directory.Exists(uploadFolder))
          {
            uploadedFiles[idx].savedIn = savefile;
            postedFile.SaveAs(savefile);
            System.IO.FileInfo fi = new System.IO.FileInfo(savefile);
            uploadedFiles[idx].fileSize = fi.Length;
            uploadedFiles[idx].mimeType = MediaFileCommon.GetMIMETypeFromFilename(fi.Name);
          }                                                   
        }              
      }              
      return uploadedFiles;
    }
                 
  }    
}
