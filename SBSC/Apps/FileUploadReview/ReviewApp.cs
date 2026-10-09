using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using MBA;
using Spedmon;
using System.IO;
using System.Threading;
using wf = System.Windows.Forms;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Configuration;

namespace Spedmon
{
  /***************************************************************************
   * FileUploadReviewApp */
  /**
   * A windows forms application for reviewing file uploads
   ***************************************************************************/   

  partial class FileUploadReviewApp:WinFormsApplication
  {
  
    public const string NO_FILE_SELECTED = "No File Selected";
    
   /***************************************************************************
    * ValidFolderOrFileNameSelected */
   /**
    * Returns
    ***************************************************************************/   
   
    public static bool ValidFolderOrFileNameSelected (string path)
    {
      if (path == NO_FILE_SELECTED)     return false;
      if (path == "")                   return false;
      return true;
    }
    
   /***************************************************************************
    * FileUploadReviewApp */
   /**
    * A windows forms application for reviewing file uploads
    ***************************************************************************/   
    
    public static long getAppEnvironmentID()
    {
      return getAppSettingEnvironmentID();
      
    }
    
    /***************************************************************************
     * getFileUploads*/
    /**
     * Returns all active upload files
     ***************************************************************************/   
    
    public static ReturnFileUploads getFileUploads ()
    {
      return getFileUploads(getAppEnvironmentID());
    }
    
    public static ReturnFileUploads getFileUploads (long environmentValue)
    {
      ReturnFileUploads rd;
   
      rd = (ReturnFileUploads) callMethod(typeof(ReturnFileUploads), delegate {
          ReturnFileUploads rfu = new ReturnFileUploads ();
          rfu.fileUploads = FileUploads.viewFileUploadsDataList(dbConnApp, log, uInfo, environmentValue, null, null, "Y");      
          return rfu;

      }, false, true);  
    
      return rd;        
    }
    
    /***************************************************************************
     * getFileUpload */
    /**
     * Returns 
     ***************************************************************************/   

    public static ReturnFileUpload getFileUpload (long uploadID)
    {
      return getFileUpload(getAppEnvironmentID(),uploadID);
    }
    
    public static ReturnFileUpload getFileUpload (long environmentID, long uploadID)
    {
      ReturnFileUpload rd;

      rd = (ReturnFileUpload) callMethod(typeof(ReturnFileUpload), delegate {
        return Spedmon.FileUploads.getFileUpload(dbConnApp, log, uInfo, environmentID, uploadID);
      }, false, true);  

      return rd;
    }
    
    
    /***************************************************************************
     * replaceFile */
    /**
     * Returns 
     ***************************************************************************/   
    
    public static ReturnFileUpload replaceFile  (  long       uploadID
                                                 , FileUpload fileUploadIn
                                                 , string     incomingFileRootPathFilename)
    {
      return replaceFile(getAppEnvironmentID(), uploadID, fileUploadIn, incomingFileRootPathFilename);
    }
    
    public static ReturnFileUpload replaceFile (  long       environmentID
                                                , long       uploadID
                                                , FileUpload fileUploadIn
                                                , string     incomingFileRootPathFilename)
    {
      ReturnFileUpload rd;
      rd = (ReturnFileUpload) callMethod(typeof(ReturnFileUpload), delegate {
        
        FileUpload fileUploadOut = fileUploadIn;
        bool       processOK     = true;
        
        FileUploads.processReplacementIncomingFileUpload (  dbConnApp
                                                          , log
                                                          , uInfo
                                                          , environmentID
                                                          , uploadID
                                                          , fileUploadIn
                                                          , incomingFileRootPathFilename
                                                          , out fileUploadOut
                                                          , out processOK);
                                                          
        return Spedmon.FileUploads.getFileUpload(dbConnApp, log, uInfo, environmentID, uploadID);

      }, false, true);  

      return rd;
    }
        
  }
}
