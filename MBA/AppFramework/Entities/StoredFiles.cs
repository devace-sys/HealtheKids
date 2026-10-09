using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using EAW.MediaFile;

namespace MBA
{
  
  /***************************************************************************
   * StoredFileRecord */
  /**
   * Stored file record
   ***************************************************************************/   
 
  public class StoredFileRecord
  {
    public long   id;
    public string label;
    public string fileId;
    public string fileRoot;
    public string filePath;
    public string fileName;
  }
  
  /***************************************************************************
   * StoredFileTarget */
  /**
   * Stored file target
   ***************************************************************************/   

  public class StoredFileTarget
  {
    public string        id;
    public string        fullPathFileName;
    public MediaFileInfo mfi;
  }
  
  /***************************************************************************
   * StoredFiles*/
  /**
   * Stored files entity
   ***************************************************************************/   
  
  public class StoredFiles:Entities
  {    
      public const string URL_DOWNLOAD_HANDLER_PRIVATE = @"storedfiledownload.ashx";
      public const string URL_UPLOAD_HANDLER_PRIVATE   = @"storedfileupload.ashx";
      public const string URL_LIST_HANDLER_PRIVATE     = @"storedfilelist.ashx";
      public const string URL_WEB_SVC                  = @"storedfiles.asmx";
      public const string URL_WEB_RPT                  = @"storedfiles.ashx";
      public static string URL_WEB_SVC_VIEW_SEL        = StoredFiles.URL_WEB_SVC + @"/viewSel";
      
      public const string PDF_VIEWER_URL_BASE          = @"third-party/pdfjs/web/viewer.html";

      public const string PARAM_FILE_ID                      = "sf-fid";
      public const string FILE_CLASS_MD_ORDERS               = @"3";
      public const string FILE_CLASS_PRESCRIPTIONS           = @"6";
      public const string FILE_CLASS_PROOF_OF_QUALIFICATIONS = @"9";
      public const string FILE_CLASS_MISC                    = @"1000";
      public const string FILE_CLASS_TELECOMM_TELE_HEALTH    = @"500";
      public const string FILE_CLASS_TELECOMM_TELE_IEP       = @"501";
      public const string FILE_CLASS_RMTS_SUPPORTING_DOCS    = @"600";
      public const string FILE_CARE_PLAN_AUTH                = @"35";
      
      public const string FILE_CLASS_FILLABLE_PDF_FOR_SERVICE_REC_BLANK      = @"60";

      public static string DOWNLOAD_HANDLER_PRIVATE ()
      {
        return MBA.HttpApplication.createLink(URL_DOWNLOAD_HANDLER_PRIVATE, true);
      }
      
      public static string UPLOAD_HANDLER_PRIVATE()
      {
        return MBA.HttpApplication.createLink(URL_UPLOAD_HANDLER_PRIVATE, true);      
      }

      public static string LIST_HANDLER_PRIVATE()
      {
        return MBA.HttpApplication.createLink(URL_LIST_HANDLER_PRIVATE, true);      
      }      
  }

}
