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

// PDF

using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.html;


namespace Spedmon
{    

  public class UploadFileClass
  {
    public long   fileClassValue;
    public string fileClassName;
	  //public string fileClassSaveAsNamePattern;
	  public bool   fileClassUploadAllowedFromPublic;
	  public bool   fileClassUploadAllowedFromPrivate;
	  public bool   fileClassActive;    
  }
  
  public class UploadFileType:UploadFileClass
  {
    public string fileTypeName;
    public string fileTypeValue;
  	public bool   fileTypeActive;
	  public bool   fileTypeUseInUploadList;
  }
  
  /***************************************************************************
   * FileUploadStatus */
  /**
   * Returns    
   ***************************************************************************/  

  public class FileUploadStatus
  {
    public long     id;
    public DateTime createdOn;
    public long     statusCode;
    public string   statusName;
    public long     returnStatusCode;
    public string   returnStatusName;
    public string   source;
    public string   destination;
    public string   note;
    
  }

  /***************************************************************************
   * FileUploadFormDataEntryLine */
  /**
   * Returns    
   ***************************************************************************/  
  
  public class FileUploadFormDataEntryLine
  {
    public string QuestionText;
    public string AnswerText;
    public string AnswerValues;
  }
  
  /***************************************************************************
   * FileUploadStorageLocation */
  /**
   * Returns    
   ***************************************************************************/  

  public class FileUploadStorageLocation
  {
    public long   id;
    public string name;
    public string root;
    public string path;
  }
  
  /***************************************************************************
   * FileUpload */
  /**
   * Returns    
   ***************************************************************************/  
     
  public class FileUpload 
  {
    public long     id;
    public long     fileUploadedFromID;
    public string   fileUploadedFromName;
    public long     fileClassID;
    public string   fileClassName;
    public string   fileSubClass;
    public DateTime fileUploadedOn;
    public DateTime fileEffectiveUploadedOn;
    public string   referenceDate1;
    public string   fileUploaderContactEmail;
    public long     currentStatusID;
    public string   currentStatusName;
    public string   originalName;
    public string   savedName;
    public string   fileAsName;
    public string   filedName;
    public string   receiveOriginalRoot;
    public string   receiveOriginalPath;
    public string   storeFiledRoot;
    public string   storeFiledPath;
    public string   archiveFiledRoot;
    public string   archiveFiledPath;
    public string   archiveOriginalRoot;
    public string   archiveOriginalPath;
    public string   reviewFiledRoot;
    public string   reviewFiledPath;    
    public string   deactivateOrReplaceRoot;
    public string   deactivateOrReplacePath;
    public string   notifyStaffEmails;
    public long     fileSize;
    public string   fileMimeType;
    public string   fileAsMimeType;
    public string   possibleDuplicateFiles;
    
    public bool     processFile;
    public bool     reviewFile;
    public bool     postProcessFile;
    public bool     fileReadyForUse;
    public bool     fileCancelled;
    public bool     fileAccepted;
    public bool     fileInfected;
    public bool     fileCorrupt;
    
    public string   receiveOriginalRootPath;
    public string   archiveOriginalRootPath;
    public string   storeFiledRootPath;
    public string   archiveFiledRootPath;
    public string   reviewFiledRootPath;
    public string   deactivateOrReplaceRootPath;
    
    public string   receiveOriginalRootPathFilename;
    public string   archiveOriginalRootPathFilename;
    public string   storeFiledRootPathFilename;
    public string   archiveFiledRootPathFilename;
    public string   reviewFiledRootPathFilename;
    
    public string   deactivateOrReplaceRootPathFilenameSavedName;
    public string   deactivateOrReplaceRootPathFilenameFileAsOrFiledName;    
    public string   currentWorkingCopyRootPathFileName;
    
    public long     clientID;
    public string   clientName;

    public bool fileIsGenerated    = false; /* Internally generated? */
    public int  processingPriority = 2;     /* 0 is highest */
            
  }
  
  
  /***************************************************************************
   * ReturnFileUploads */
  /**
   * Returns    
   ***************************************************************************/   
  
  public class ReturnFileUploads : Return
  {
    public ReturnFileUploads ()            : base(){}
    public ReturnFileUploads (string msg)  : base(msg){}
    public ReturnFileUploads (Exception e) : base(e){}
    public ReturnFileUploads (Warning e)   : base(e){}
    public ReturnFileUploads (Critical e)  : base(e){}
    public ReturnFileUploads (SessionExpired e):base(e){}
    
    public List<FileUpload> fileUploads;    
    
  }
  
  /***************************************************************************
   * ReturnFileUpload */
  /**
   * Returns    
   ***************************************************************************/   
  
  public class ReturnFileUpload:Return
  {
    public FileUpload                    fileUpload; 
    public FileUploadStatus[]            statusLog;        
    public FileUploadFormDataEntryLine[] formDataEntryLines;
  }
  
  /***************************************************************************
   * ReturnFileUploadStorageLocationData */
  /**
   * Returns    
   ***************************************************************************/   
  
  public class ReturnFileUploadStorageLocationData : Return
  {
    public ReturnFileUploadStorageLocationData ()            : base(){}
    public ReturnFileUploadStorageLocationData (string msg)  : base(msg){}
    public ReturnFileUploadStorageLocationData (Exception e) : base(e){}
    public ReturnFileUploadStorageLocationData (Warning e)   : base(e){}
    public ReturnFileUploadStorageLocationData (Critical e)  : base(e){}
    public ReturnFileUploadStorageLocationData (SessionExpired e):base(e){}
    
    public List<FileUploadStorageLocation> FileUploadStorageLocations;        
  }

  /***************************************************************************
   * FileUploads */
  /**
   * Request 
   ****************************************************************************/

  public class FileUploads:Entities
  {
    
    /***************************************************************************
     * saveFileUploadStatus */
    /**
     * 
     * 
     ****************************************************************************/

    public static bool saveFileUploadStatus (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          uploadID
      , long          statusCode
      , string        source
      , string        destination )     
    {
      return saveFileUploadStatus (connSpedmon, log, uInfo, uploadID, DateTime.Now, uInfo.userid, statusCode, source, destination,"");
    }
    
    public static bool saveFileUploadStatus (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          uploadID
      , long          statusCode
      , string        source
      , string        destination
      , string        note )     
    {
      return saveFileUploadStatus (connSpedmon, log, uInfo, uploadID, DateTime.Now, uInfo.userid, statusCode, source, destination, note);
    }

    /***************************************************************************
     * saveFileUploadStatus */
    /**
     * 
     * 
     ****************************************************************************/
    
    public static bool saveFileUploadStatus (

        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          uploadID
      , DateTime      createdOn
      , long          createdBy
      , long          statusCode
      , string        source
      , string        destination
      , string        note )     
    {
     
      bool result = true;
      try
      { 
     
        /*============================================================
         * Pass them into db parameters
         *============================================================*/

        string sql = "FILE_UPLOAD_SET_STATUS";
        long recID = 0;
      
        List<SqlParameter> parms = new List<SqlParameter>();
      
        parms.Add(Database.SqlParm("@uploadID",      SqlDbType.BigInt,   uploadID,     ParameterDirection.Input));
        parms.Add(Database.SqlParm("@createdOn",     SqlDbType.DateTime, createdOn,    ParameterDirection.Input));      
        parms.Add(Database.SqlParm("@createdBy",     SqlDbType.BigInt,   createdBy,    ParameterDirection.Input));      
        parms.Add(Database.SqlParm("@statusCode",    SqlDbType.BigInt,   statusCode,   ParameterDirection.Input));
        parms.Add(Database.SqlParm("@source",        SqlDbType.VarChar,  source,       ParameterDirection.Input, 8000));
        parms.Add(Database.SqlParm("@destination",   SqlDbType.VarChar,  destination,  ParameterDirection.Input, 8000));
        parms.Add(Database.SqlParm("@note",          SqlDbType.VarChar,  note,         ParameterDirection.Input, 8000));
        parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt,   recID,        ParameterDirection.Output));
                                      
        /*============================================================
         * Call sproc and return
         *============================================================*/

        ReturnDB rd = Database.execSproc(connSpedmon, log, sql, parms);
        result = true;
      }
      catch
      {
        result = false;
      }
      return result;
    }
    
    /***************************************************************************
     * copyFile */
    /**
     * 
     ***************************************************************************/ 
    
    public static bool copyFile (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          fileUploadID
      , string        fromFolderFile
      , string        toFolderFile )
    {
      bool _result = true;
      try
      {                      
        System.IO.File.Copy (fromFolderFile, toFolderFile);
        FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUploadID,1030,fromFolderFile,toFolderFile);            
      }
      catch
      {
        _result = false;
      }
      return _result;
    }    

    /***************************************************************************
     * moveFile */
    /**
     * 
     ***************************************************************************/ 

    public static bool moveFile (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          fileUploadID
      , string        fromFolderFile
      , string        toFolderFile)    
    {
      bool _result = true;
      try
      {                              
        System.IO.File.Move (fromFolderFile, toFolderFile);
        FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUploadID,1040,fromFolderFile,toFolderFile);        
      }
      catch
      {
        _result = false;
      }
      return _result;
    }
    
   

    /***************************************************************************
     * deleteFile */
    /**
     * 
     ***************************************************************************/ 

    public static bool deleteFile (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          fileUploadID
      , string        fromFolderFile )
    {
      bool result = true;

      try
      {                      
        System.IO.File.Delete(fromFolderFile);        
        saveFileUploadStatus(connSpedmon,log,uInfo,fileUploadID,1000,fromFolderFile,"");        
      }
      catch (Exception err)
      {
        result = false;
      }
      
      return result;
    }
    
    /***************************************************************************
     * deactivateFile */
    /**
     * 
     ***************************************************************************/ 

    public static bool deactivateFile (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          fileUploadID
      , string        fromFolderFile
      , string        backupFolderFile)
    {
      bool _result = true;
      
      try
      {                      
        System.IO.File.Move(fromFolderFile,backupFolderFile);        
        saveFileUploadStatus(connSpedmon,log,uInfo,fileUploadID,1050,fromFolderFile,"");
        saveFileUploadStatus(connSpedmon,log,uInfo,fileUploadID,1040,fromFolderFile,backupFolderFile);  
      }
      catch(Exception e)
      {
        _result = false;
      }
      return _result;
    }
    
         
    /***************************************************************************
     * scanIncomingFileUploadForExistanceOfFile */
    /**
     * 
     ***************************************************************************/ 

    public static bool scanIncomingFileUploadForExistanceOfFile (
        SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUpload
      , string        incomingFileRootPathFilename
      , bool          notifySender      
      , out bool fileOK)
    {

      bool result       = true;
      bool fileExists   = true;
      
      try
      { 
        saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,200,"","");
        
        fileExists = System.IO.File.Exists(incomingFileRootPathFilename);
        
        if (fileExists == false) saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,210,incomingFileRootPathFilename,"");
        else                     saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,220,incomingFileRootPathFilename,"");          
        
        result = true;
      }
      catch
      {
        result = false;
      }
      
      fileOK = fileExists;
      return result;
      
    }

 
    /***************************************************************************
     * ScanIncomingFileUploadForExistanceOfFolders */
    /**
     * 
     ***************************************************************************/ 

    public static bool scanIncomingFileUploadForExistanceOfFolders (
        SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUpload
      , string        incomingFileRootPathFilename
      , bool          notifySender
      , out bool foldersOK )
       
    {
      bool         result         = true;
      bool         foldersExist   = true;
      List<String> missingFolders = new List<string>();

      try
      {
        saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,240,"","");
                    
        if (!Directory.Exists(fileUpload.receiveOriginalRootPath)) { foldersExist = false; missingFolders.Add(fileUpload.receiveOriginalRootPath); }
        if (!Directory.Exists(fileUpload.archiveOriginalRootPath)) { foldersExist = false; missingFolders.Add(fileUpload.archiveOriginalRootPath); }
        if (!Directory.Exists(fileUpload.reviewFiledRootPath))     { foldersExist = false; missingFolders.Add(fileUpload.reviewFiledRootPath);     }
        if (!Directory.Exists(fileUpload.storeFiledRootPath))      { foldersExist = false; missingFolders.Add(fileUpload.storeFiledRootPath);      }
        if (!Directory.Exists(fileUpload.archiveFiledRootPath))    { foldersExist = false; missingFolders.Add(fileUpload.archiveFiledRootPath);    }    
        
        if (foldersExist == false) 
        {
          string note = String.Join("|",missingFolders.ToArray());
          saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,250,"","",note);          
        }
        else
        {        
          saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,260,"","");           
        }
        
        result = true;
      }
      catch
      {
        result = false;  
      }
      
      foldersOK = foldersExist;
      return result;
    }
    
    /***************************************************************************
     * notifySomeone  */
    /**
     * 
     ***************************************************************************/ 

    public static bool notifySomeone (
        SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUpload
      , long          statusCode
      , string        emails
      , string        title
      , string        fileName
      , string        fileDate
      , string        problems
      , string        actions
      , string        solutions
      , string        additionalInfo )
    {     
      
      bool result = true;      
            
      try
      {                                        
        StringBuilder sb = new StringBuilder();                  
                                                    
        sb.Append(@"<!doctype html>");
        sb.Append(@"<html>");
        sb.Append(@"<head>");
        sb.Append(@"<title>");
        sb.Append(title);
        sb.Append(@"</title>");                  
        sb.Append(@"</head>");
        sb.Append(@"<body>");
        sb.Append(@"<div style=""font-size:1em;"">");                
        sb.AppendFormat(@"<h1>{0}</h1>",Messages.DO_NOT_REPLY);
        sb.AppendFormat(@"<h1>{0}</h1>",title);
        sb.Append(@"<h2>Filename</h2>");
        sb.AppendFormat(@"<p>{0}</p>",fileName);
        sb.Append(@"<h2>Received On</h2>");        
        sb.AppendFormat(@"<p>{0}</p>",fileDate);
        sb.Append(@"<h2>The File Has the Following Problem</h2>");
        sb.AppendFormat(@"<p>{0}</p>",problems);
        sb.Append(@"<h2>We Have Taken the Following Actions to Attempt to Resolve this Problem or Prevent Additional Problems</h2>");
        sb.AppendFormat(@"<p>{0}</p>",actions);
        sb.Append(@"<h2>Please Take the Following Actions to Complete the Resolution of this Problem</h2>");
        sb.AppendFormat(@"<p>{0}</p>",solutions);
        
        if (!String.IsNullOrEmpty(additionalInfo))
        {
          sb.Append(@"<h2>Additional Information</h2>");
          sb.AppendFormat(@"<p>{0}</p>",additionalInfo);
        }
        
        sb.AppendLine(@"</div>");
        sb.AppendLine(@"<br/>");
        sb.AppendLine(@"<hr/>");
        sb.AppendLine(@"<div>");
        sb.AppendLine(@"<em style=""font-style:italic;font-size:.75em;"">");        
        sb.AppendLine(Messages.CONFIDENTIAL_EMAIL);
        sb.AppendLine(@"</em>");                
        sb.AppendLine(@"</div>");                
        sb.AppendLine(@"</body>");
        sb.AppendLine(@"</html>");                 
        
        string body = sb.ToString();
        string[] emailsArr = Email.parseEmailString(emails);
        foreach (string email in emailsArr)
        {
          string retStatus = "";
          result = Email.sendMail(email,title,body,true, out retStatus);        
          if (result)
          { 
            FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,statusCode,"","",additionalInfo);
          }
        }
        
      }
      catch (Exception e)
      {
        result = false;
      }
      
      return result;      
    }
                 
    /***************************************************************************
     * determineIncomingFileUploadDisposition  */
    /**
     * 
     ***************************************************************************/ 
    
    public static bool determineIncomingFileUploadDisposition  (
        SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUpload
      , string        incomingFileRootPathFilename
      , bool          canUseFile
      , bool          notifySender )
    {     
      bool result = true;
      
      try
      {
        FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,500,incomingFileRootPathFilename,"");      
        
        if (!canUseFile)    FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,510,incomingFileRootPathFilename,"");
        if (canUseFile)     FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,520,incomingFileRootPathFilename,"");                       
        result = true;
      }
      catch
      {
        result = false;      
      }
      return result;
      
    }
 
    /***************************************************************************
     * ScanIncomingFileUploadForThreats */
    /**
     * 
     ***************************************************************************/ 

    public static bool scanIncomingFileUploadForThreats (
        SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUpload
      , string        incomingFileRootPathFilename
      , bool          notifySender 
      , AntivirusApp  avApp
      , string        scanLogFolder
      , out bool   fileOK )
    
    {

      fileOK           = true;
      
      bool result      = true;
      bool fileIsClean = false;
      
      try
      {         
        
        saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,300,incomingFileRootPathFilename,"");
        
        System.IO.FileInfo  incomingFileInfo       = new System.IO.FileInfo      ( incomingFileRootPathFilename );
        FileToScan          incomingFileToScan     = FileToScan.CreateFileToScan ( scanLogFolder, incomingFileInfo);
        AntivirusScanResult incomingFileScanResult = Antivirus.ScanFile          ( avApp,         incomingFileToScan);
                    
        fileIsClean = incomingFileScanResult.keepFile;

        /*###########################################################################
          # If the file is not clean 
          ###########################################################################*/                  
        
        if (fileIsClean == false)
        {
                                      
          deleteFile(connSpedmon, log, uInfo, uploadID, incomingFileRootPathFilename);
          
          if (notifySender)
          {                         
            notifySomeone (  connSpedmon
                            , log
                            , uInfo
                            , environmentID
                            , uploadID
                            , fileUpload
                            , 310
                            , fileUpload.fileUploaderContactEmail
                            , "We Could Not Accept Your Recent File Upload"
                            , fileUpload.originalName
                            , fileUpload.fileUploadedOn.ToString()
                            , "Our antivirus software found problems with the file"
                            , "We have deleted the file"
                            , "Please upload a clean copy of this file"
                            , "Our antivirus software reported the following problem(s): " + incomingFileScanResult.scanAppThreatFoundText);                                   
          }            
          
        }
        else
        {
          FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,320,incomingFileRootPathFilename,"");
        }                

       result = true;
       
     }
       
     catch 
     {
       result = false;          
     }
     fileOK = fileIsClean;
     return result;
          
    }
        
    /***************************************************************************
     * scanIncomingFileUploadForIntegrity*/
    /**
     * 
     ***************************************************************************/ 

    public static bool scanIncomingFileUploadForIntegrity ( 
       SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUpload
      , string        incomingFileRootPathFilename
      , bool          notifySender
      , out bool fileOK )
    {    
      
      bool result      = true;
      bool fileTested  = false;
      bool fileIsOK    = true;
      string rdrResult = "";

      try
      {         

        FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,400,incomingFileRootPathFilename,"");
        
        int    numPages  = 0;
        string mimeType  = fileUpload.fileMimeType;
        
        /*###########################################################################
          # If the file is a PDF
          ###########################################################################*/                  
        
        if (mimeType == "application/pdf")
        {

          /*============================================================
           * Use iText 
           *============================================================*/       

          fileTested = true;                         
          PdfReader rdr = null;
          try
          {
            rdr = new PdfReader (incomingFileRootPathFilename);                
            numPages = rdr.NumberOfPages;
            fileIsOK = true;
          }
          catch (Exception rdrErr)
          {
            rdrResult = rdrErr.Message;
            fileIsOK = false;               
          }
          finally
          {
            if (rdr != null) rdr.Close();
          }
        }
                 
        /*###########################################################################
          # If the file is anything else
          ###########################################################################*/                  

        else
        {
          fileTested = false;
          fileIsOK   = true;
        } 
        
        /*###########################################################################
          # If the file integrity was actually tested
          ###########################################################################*/ 

        if (fileTested == true)
        {
                 
          /*============================================================
           * If the file integrity was bad
           *============================================================*/       

          if (fileIsOK == false)
          {

            /*--------------------------------------
             * Record the fact that we are 
             * rejecting the file
             *-------------------------------------*/
           
            FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,410,incomingFileRootPathFilename,"",rdrResult);


            /*--------------------------------------
             * Deactivate the file
             *-------------------------------------*/  
                      
            deactivateFile(connSpedmon, log, uInfo, uploadID, incomingFileRootPathFilename, fileUpload.deactivateOrReplaceRootPathFilenameSavedName);
            
            /*--------------------------------------
             * Notify the user
             *-------------------------------------*/           
            
            if (notifySender)
            {             
            
              notifySomeone (  connSpedmon
                            , log
                            , uInfo
                            , environmentID
                            , uploadID                           
                            , fileUpload
                            , 430
                            , fileUpload.fileUploaderContactEmail
                            , "We Could Not Accept Your Recent File Upload"
                            , fileUpload.originalName
                            , fileUpload.fileUploadedOn.ToString()
                            , "Our file processing software was unable to open the file"
                            , "We have archived the file"
                            , "Please upload another copy of this file...If your second try doesn't work, please create a new file and try one more time.  If that still doesn't work, send a description of what you tried and the error message you got to IT@Practi-Cal.com.  Sorry you are having trouble."
                            , "Our file processing software reported the following technical problem(s) : " + rdrResult);                                   
            }    
            
           
                       
          }
          else
          {
            FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo, fileUpload.id,420,incomingFileRootPathFilename,"");          
          }                     
        }
        else
        {
          FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,440,incomingFileRootPathFilename,"");
        }
        
      }
      catch
      {
        result = false;        
      }

      fileOK = fileIsOK;
      return result;
            
    }
   
    /***************************************************************************
     * getFormDetailsForNotification */
    /**
     * 
     ***************************************************************************/ 
    
    protected static string getFormDetailsForNotification (        
        SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID )
    {
      
      ReturnFileUpload rd = getFileUpload (connSpedmon, log, uInfo, environmentID, uploadID);
    
      StringBuilder sbDetails = new StringBuilder();
      
      sbDetails.Append(@"<h3>File Uploaded By</h3>");
      sbDetails.Append(@"<p>");
      sbDetails.Append(rd.fileUpload.fileUploaderContactEmail);
      sbDetails.Append(@"</p>");      
      sbDetails.Append(@"<h3>Form Data</h3>");
      sbDetails.Append(@"<table><thead>");
      sbDetails.Append(@"<tr><th>Question</th><th>Answer Text</th><th>Answer Value</th></tr>");
      sbDetails.Append(@"</thead><tbody>");
      
      foreach (FileUploadFormDataEntryLine entryLine in rd.formDataEntryLines)      
        sbDetails.AppendFormat(@"<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>",entryLine.QuestionText,entryLine.AnswerText,entryLine.AnswerValues);  
      
      sbDetails.Append(@"</tbody></table>");
     
      return sbDetails.ToString();
    }
    
    /***************************************************************************
     * determineFileClientRelationship */
    /**
     * 
     ***************************************************************************/ 
    
    public static bool determineFileClientRelationship  (

        SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUpload
      , string        incomingFileRootPathFilename
      , bool          notifySender 
      , out bool      earlyExit )
    {     

      bool result = true;
      earlyExit = false;

      try
      {        
        FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,600,"","");
                
        if (fileUpload.clientID == 0)
        {
          FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,610,incomingFileRootPathFilename,"");
        
          moveFile(connSpedmon, log, uInfo,uploadID,incomingFileRootPathFilename, fileUpload.archiveOriginalRootPathFilename);            
          earlyExit = true;
        
          string details = getFormDetailsForNotification(connSpedmon, log, uInfo, environmentID, uploadID);
               
          notifySomeone (  connSpedmon
                         , log
                         , uInfo
                         , environmentID
                         , uploadID
                         , fileUpload
                         , 630
                         , fileUpload.notifyStaffEmails
                         , "A Recent File Upload Was Received From A Non Client"                            
                         , fileUpload.archiveOriginalRootPathFilename
                         , fileUpload.fileUploadedOn.ToString()
                         , "The file was from a non client"
                         , "The file has been stored in the upload archives folder"
                         , "Please investigate"
                         , details);            
        }
        else
        {
          FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,620,incomingFileRootPathFilename,"");
          earlyExit = false;          
        }
        
        result = true;
      }
      catch
      {
        earlyExit = true;
        result = false;        
      }
      
      return result;
      
    }
    
 
    /***************************************************************************
     * scanIncomingFileUploadForExpectedFormat */
    /**
     * 
     ***************************************************************************/ 

    public static bool scanIncomingFileUploadForExpectedFormat ( 
       SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUpload
      , string        incomingFileRootPathFilename
      , bool          notifySender
      , out bool fileOK )
      
    {
      
      bool result               = true;
      bool fileInExpectedFormat = true;
      
      try
      {
        FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,700,"","");
        
        if (fileUpload.fileAsMimeType == fileUpload.fileMimeType)
        {
           fileInExpectedFormat = true;           
           FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,720,"","");
        }
        else
        {
          fileInExpectedFormat = false;           
          FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,710,"","");
        }  
      }
      catch
      {
        result = false;
      }
      
      fileOK = fileInExpectedFormat;
      return result;
    }
    
    /***************************************************************************
     * storeIncomingFileAsFiledForUse
    /**
     * 
     * 
     ****************************************************************************/

    public static void storeIncomingFileUploadAsFiledForUse (
        SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUpload
      , string        incomingFileRootPathFilename )
    {
      saveFileUploadStatus(connSpedmon,log,uInfo,uploadID,820,"","");     
      copyFile(connSpedmon, log, uInfo,uploadID,incomingFileRootPathFilename, fileUpload.storeFiledRootPathFilename);
      copyFile(connSpedmon, log, uInfo,uploadID,incomingFileRootPathFilename, fileUpload.archiveFiledRootPathFilename);
      moveFile(connSpedmon, log, uInfo,uploadID,incomingFileRootPathFilename, fileUpload.archiveOriginalRootPathFilename);
    } 
      
    /***************************************************************************
     * storeIncomingFileAsFiledForReview
    /**
     * 
     * 
     ****************************************************************************/
    
    public static void storeIncomingFileUploadAsFiledForReview (
        SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUpload
      , string        incomingFileRootPathFilename )
    {
      saveFileUploadStatus(connSpedmon,log,uInfo,uploadID,810,"","");
      copyFile(connSpedmon, log, uInfo,uploadID,incomingFileRootPathFilename, fileUpload.reviewFiledRootPathFilename);
      moveFile(connSpedmon, log, uInfo,uploadID,incomingFileRootPathFilename, fileUpload.archiveOriginalRootPathFilename);
            
      string details = getFormDetailsForNotification(connSpedmon, log, uInfo, environmentID, uploadID);
                        
      notifySomeone (  connSpedmon
                      , log
                      , uInfo
                      , environmentID
                      , uploadID
                      , fileUpload
                      , 830
                      , fileUpload.notifyStaffEmails
                      , "A Recent File Upload Requires Review"                            
                      , fileUpload.reviewFiledRootPathFilename
                      , fileUpload.fileUploadedOn.ToString()
                      , "The file was not in a format we expected"
                      , "The file has been put in a review folder"
                      , "Please open the file, save it in the correct format, and then use the review app to replace the old file with the new file."
                      , details);  
    
    } 


    /***************************************************************************
     * determineIncomingFileUploadStorageLocationAndReviewStatus */
    /**
     * 
     ***************************************************************************/ 
    
    public static bool determineIncomingFileUploadStorageAndReviewStatus  (

        SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUpload
      , string        incomingFileRootPathFilename
      , bool          fileInExpectedFormat
      , bool          notifySender )
    {     
      bool result = true;
      
      try
      {        
        FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUpload.id,800,"","");
                
        if (fileInExpectedFormat) storeIncomingFileUploadAsFiledForUse    (connSpedmon, log, uInfo, environmentID, uploadID, fileUpload, incomingFileRootPathFilename);
        else                      storeIncomingFileUploadAsFiledForReview (connSpedmon, log, uInfo, environmentID, uploadID, fileUpload, incomingFileRootPathFilename);         
        result = true;
      }
      catch
      {
        result = false;
      }
      
      return result;
      
    }
    
    /***************************************************************************
     * replaceIncomingFileUploadWithNewFile
    /**
     * 
     * Note: Status updated in sproc
     ****************************************************************************/    
    
    protected static void replaceIncomingFileUploadWithNewFile (
        
        SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUploadIn      
      , string        incomingFileRootPathFilename
      , out FileUpload fileUploadOut )
    
    {
      
         
      fileUploadOut = fileUploadIn;
      if (!System.IO.File.Exists(incomingFileRootPathFilename)) return;      

     /*###########################################################################
       # Get info
       ###########################################################################*/  

      System.IO.FileInfo fi = new System.IO.FileInfo(incomingFileRootPathFilename);
      
     /*###########################################################################
       # Create new name and get new data
       ###########################################################################*/  
         
      string replacementFileName = fi.Name;
      string fileNameNew         = PostedFiles.createUniqueFilenameFromOriginalPostedFilename (0,replacementFileName);
      long   fileSizeNew         = fi.Length;
      string fileMimeTypeNew     = MediaFileCommon.GetMIMETypeFromFilename(fi.Name);
                  
      /*###########################################################################
        # Pass arguments into db parameters
        ###########################################################################*/  

      string sql = "FILE_UPLOAD_REPLACE_INCOMING_FILE_WITH_NEW_FILE";     
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@userID",              SqlDbType.BigInt,   uInfo.userid,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",           SqlDbType.Int,      uInfo.userGroup,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",            SqlDbType.Int,      uInfo.userRank,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@environmentID",       SqlDbType.BigInt,   environmentID,     ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@uploadID",            SqlDbType.BigInt,   uploadID,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fileNameNew",         SqlDbType.VarChar,  fileNameNew,       ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@fileSizeNew",         SqlDbType.BigInt,   fileSizeNew,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fileMimeTypeNew",     SqlDbType.VarChar,  fileMimeTypeNew,   ParameterDirection.Input, 1000));
                                      
      /*###########################################################################
        # Call sproc
        ###########################################################################*/  

      ReturnDB rd = Database.execSproc(connSpedmon, log, sql, parms);
      
      /*###########################################################################
        # Get updated file upload record
        ###########################################################################*/  

      fileUploadOut = load(connSpedmon, log, uInfo, environmentID, uploadID);
                  
    }
    
    /***************************************************************************
     * preProcessFileUploadRecord
    /**
     * Note: Status updated in sproc
     * 
     ****************************************************************************/    
    
    protected static void preProcessFileUploadRecord (
        SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUploadIn      
      , string        incomingFileRootPathFilename
      , out FileUpload fileUploadOut )
    
    {
      
      fileUploadOut = fileUploadIn;
                           
      /*###########################################################################
        # Pass arguments into db parameters
        ###########################################################################*/  

      string sql = "FILE_UPLOAD_PRE_PROCESS_INCOMING_FILE";     
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@userID",              SqlDbType.BigInt,   uInfo.userid,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",           SqlDbType.Int,      uInfo.userGroup,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",            SqlDbType.Int,      uInfo.userRank,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@environmentID",       SqlDbType.BigInt,   environmentID,     ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@uploadID",            SqlDbType.BigInt,   uploadID,          ParameterDirection.Input));
                                      
      /*###########################################################################
        # Call sproc
        ###########################################################################*/  

      ReturnDB rd = Database.execSproc(connSpedmon, log, sql, parms);
        
      /*###########################################################################
        # Get updated file upload record
        ###########################################################################*/  

      fileUploadOut = load(connSpedmon, log, uInfo, environmentID, uploadID);
    
                  
    }

    /***************************************************************************
     * completeProcessFileUploadRecord
    /**
     * 
     * Note: Status handled in sproc
     ****************************************************************************/    
    
    protected static void completeProcessFileUploadRecord (
        SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUploadIn
      , string        incomingFileRootPathFilename
      , out FileUpload fileUploadOut )
    {

      /*###########################################################################
        # Pass arguments into db parameters
        ###########################################################################*/  
        
      string sql = "FILE_UPLOAD_COMPLETE_PROCESS_INCOMING_FILE";     
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@userID",               SqlDbType.BigInt,   uInfo.userid,                     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",            SqlDbType.Int,      uInfo.userGroup,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",             SqlDbType.Int,      uInfo.userRank,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@environmentID",        SqlDbType.BigInt,   environmentID,                    ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@uploadID",             SqlDbType.BigInt,   uploadID,                         ParameterDirection.Input));

      /*###########################################################################
        # Call sproc
        ###########################################################################*/  
                                      
      ReturnDB rd = Database.execSproc(connSpedmon, log, sql, parms);
      
      /*###########################################################################
        # Get updated file upload record
        ###########################################################################*/  

      fileUploadOut = load(connSpedmon, log, uInfo, environmentID, uploadID);
                  
    }
    
    /***************************************************************************
     * postProcessFileUploadRecord
    /**
     * 
     * Note: Status handled in sproc
     ****************************************************************************/    
    
    protected static void postProcessFileUploadRecord (
        SqlConnection connSpedmon 
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentID
      , long          uploadID
      , FileUpload    fileUploadIn
      , string        incomingFileRootPathFilename
      , out FileUpload fileUploadOut )
    {

      /*###########################################################################
        # Pass arguments into db parameters
        ###########################################################################*/  
        
      string sql = "FILE_UPLOAD_POST_PROCESS_INCOMING_FILE";     
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@userID",               SqlDbType.BigInt,   uInfo.userid,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",            SqlDbType.Int,      uInfo.userGroup,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",             SqlDbType.Int,      uInfo.userRank,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@environmentID",        SqlDbType.BigInt,   environmentID,      ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@uploadID",             SqlDbType.BigInt,   uploadID,           ParameterDirection.Input));

      /*###########################################################################
        # Call sproc
        ###########################################################################*/  
                                      
      ReturnDB rd = Database.execSproc(connSpedmon, log, sql, parms);
      
      /*###########################################################################
        # Get updated file upload record
        ###########################################################################*/  

      fileUploadOut = load(connSpedmon, log, uInfo, environmentID, uploadID);
                  
    }
    
    /***************************************************************************
     * processReplacementIncomingFileUpload
    /**
     * 
     * 
     ****************************************************************************/    

    public static bool processReplacementIncomingFileUpload (
        SqlConnection  connSpedmon 
      , DetailsLog     log
      , UserInfo       uInfo
      , long           environmentID
      , long           uploadID
      , FileUpload     fileUploadIn
      , string         incomingFileRootPathFilename      
      , out FileUpload fileUploadOut
      , out bool       processOK )
    {
      return processIncomingFileUpload (  connSpedmon
                                        , log
                                        , uInfo
                                        , environmentID
                                        , uploadID
                                        , fileUploadIn
                                        , incomingFileRootPathFilename
                                        , false
                                        , true
                                        , false
                                        , false
                                        , null
                                        , null
                                        , out fileUploadOut
                                        , out processOK);
    }

    /***************************************************************************
     * processNewIncomingFileUpload
    /**
     * 
     * 
     ****************************************************************************/            
    public static bool processNewIncomingFileUpload (
        SqlConnection  connSpedmon 
      , DetailsLog     log
      , UserInfo       uInfo
      , long           environmentID
      , long           uploadID
      , FileUpload     fileUploadIn
      , string         incomingFileRootPathFilename 
      , AntivirusApp   avApp
      , string         scanLogFolder     
      , out FileUpload fileUploadOut
      , out bool       processOK )
    {
      return processIncomingFileUpload (  connSpedmon
                                        , log
                                        , uInfo
                                        , environmentID
                                        , uploadID
                                        , fileUploadIn
                                        , incomingFileRootPathFilename
                                        , true
                                        , false
                                        , true
                                        , true
                                        , avApp
                                        , scanLogFolder 
                                        , out fileUploadOut
                                        , out processOK);
    }
    
    /***************************************************************************
     * processGeneratedFileUpload
    /**
     * 
     * 
     ****************************************************************************/    

    public static bool processGeneratedFileUpload (
        SqlConnection  connSpedmon 
      , DetailsLog     log
      , UserInfo       uInfo
      , long           environmentID
      , long           uploadID
      , FileUpload     fileUploadIn
      , string         incomingFileRootPathFilename 
      , AntivirusApp   avApp
      , string         scanLogFolder     
      , out FileUpload fileUploadOut
      , out bool       processOK )
    {
      return processIncomingFileUpload (  connSpedmon
                                        , log
                                        , uInfo
                                        , environmentID
                                        , uploadID
                                        , fileUploadIn
                                        , incomingFileRootPathFilename
                                        , false
                                        , false
                                        , false
                                        , false
                                        , avApp
                                        , scanLogFolder 
                                        , out fileUploadOut
                                        , out processOK);
    }
    
    /***************************************************************************
     * processIncomingFileUpload
    /**
     * Note: This is not directly called
     * 
     ****************************************************************************/

    public static bool processIncomingFileUpload (
    
        SqlConnection  connSpedmon 
      , DetailsLog     log
      , UserInfo       uInfo
      , long           environmentID
      , long           uploadID
      , FileUpload     fileUploadIn
      , string         incomingFileRootPathFilename      
      , bool           notifySender
      , bool           replaceFile
      , bool           threatScan
      , bool           integrityScan       
      , AntivirusApp   avApp
      , string         scanLogFolder     
      , out FileUpload fileUploadOut
      , out bool       processOK )
    {
      
      bool result       = true;
      string resultText = "";

      fileUploadOut = fileUploadIn;
      
      try
      {
        
        bool       fileOK        = true;
        bool       foldersOK     = true;
        FileUpload fuIn          = fileUploadIn;
        FileUpload fuOut         = fileUploadIn;
                  
        /*###########################################################################
          # Replace file if neccessary
          ###########################################################################*/  

        if (replaceFile)
        {
          replaceIncomingFileUploadWithNewFile(connSpedmon, log, uInfo, environmentID, uploadID, fuIn, incomingFileRootPathFilename, out fuOut);
          fileUploadIn  = fuOut;
          fileUploadOut = fileUploadIn;
          
        }
                     
        /*###########################################################################
          # Check for existance of file
          ###########################################################################*/  

        result = scanIncomingFileUploadForExistanceOfFile (   connSpedmon
                                                            , log
                                                            , uInfo
                                                            , environmentID
                                                            , uploadID
                                                            , fileUploadIn
                                                            , incomingFileRootPathFilename
                                                            , notifySender
                                                            , out fileOK );

        /*============================================================
         * If the step failed get out
         *============================================================*/
         
        if (!result) 
        {
          processOK = false;
          return result;
        }
        
        /*============================================================
         * If file not found get out
         *============================================================*/

        if (!fileOK) 
        {
          processOK = false;
          return result;
        }                
       
       /*###########################################################################
         # Check for existance of associated folders
         ###########################################################################*/  

        result = scanIncomingFileUploadForExistanceOfFolders (   connSpedmon
                                                               , log
                                                               , uInfo
                                                               , environmentID
                                                               , uploadID
                                                               , fileUploadIn
                                                               , incomingFileRootPathFilename
                                                               , notifySender
                                                               , out foldersOK);      
        
        /*============================================================
         * If step failed get out
         *============================================================*/

        if (!result) 
        {
          processOK = false;
          return result;
        }

        /*============================================================
         * If folders not found get out
         *============================================================*/

        if (!foldersOK) 
        {
          processOK = false;
          return result;
        }
                             
        /*###########################################################################
          # Pre process record (not file)
          ###########################################################################*/  
        
        fuIn  = fileUploadIn;
        fuOut = fileUploadIn;
        
        preProcessFileUploadRecord (  connSpedmon
                                    , log
                                    , uInfo
                                    , environmentID
                                    , uploadID
                                    , fuIn
                                    , incomingFileRootPathFilename
                                    , out fuOut );
               
        /*###########################################################################
          # Scan file for threats
          ###########################################################################*/  
              
        if (threatScan)
        {
          fileUploadIn = fuOut;
          fileUploadOut = fileUploadIn;
         
        
          result = scanIncomingFileUploadForThreats (   connSpedmon
                                                      , log
                                                      , uInfo
                                                      , environmentID
                                                      , uploadID
                                                      , fileUploadIn
                                                      , incomingFileRootPathFilename
                                                      , notifySender
                                                      , avApp
                                                      , scanLogFolder
                                                      , out fileOK );      

          /*============================================================
           * If the step failed get out
           *============================================================*/

          if (!result) 
          {
            processOK = false;
            return result;
          }
         
          /*============================================================
           * If the file is not ok make a note
           *============================================================*/

          if (!fileOK) 
          {
            result = determineIncomingFileUploadDisposition (connSpedmon, log, uInfo, environmentID, uploadID, fileUploadIn, incomingFileRootPathFilename, fileOK, notifySender);

            if (!result) 
            {
              processOK = false;
              return result;
            }

            processOK = false;
            return result;
          }
        }
        
        /*###########################################################################
          # Scan file for content integrity
          ###########################################################################*/  
        
        if (integrityScan)
        {
          result = scanIncomingFileUploadForIntegrity (  connSpedmon
                                                       , log
                                                       , uInfo
                                                       , environmentID
                                                       , uploadID
                                                       , fileUploadIn
                                                       , incomingFileRootPathFilename
                                                       , notifySender
                                                       , out fileOK);

          /*============================================================
           * If the step failed get out
           *============================================================*/

          if (!result) 
          {
            processOK = false;
            return result;
          }
          
          /*============================================================
           * If the file is not ok make a note
           *============================================================*/

          if (!fileOK) 
          {
            result = determineIncomingFileUploadDisposition (connSpedmon, log, uInfo, environmentID, uploadID, fileUploadIn, incomingFileRootPathFilename, fileOK, notifySender);

            if (!result) 
            {
              processOK = false;
              return result;
            }

            processOK = false;
            return result;
          }
       }
       
       /*###########################################################################
         # If we reach this point we are keeping the file so make a note
         ###########################################################################*/  

       result = determineIncomingFileUploadDisposition (  connSpedmon
                                                        , log
                                                        , uInfo
                                                        , environmentID
                                                        , uploadID
                                                        , fileUploadIn
                                                        , incomingFileRootPathFilename
                                                        , fileOK
                                                        , notifySender );


       /*============================================================
        * If the step failed get out
        *============================================================*/ 
       
       if (!result) 
       {
         processOK = false;
         return result;
       }
              
       /*###########################################################################
         # Check to see if the file is coming from a client
         ###########################################################################*/  

       bool earlyExit = false;

       result = determineFileClientRelationship ( connSpedmon
                                                  , log
                                                  , uInfo
                                                  , environmentID
                                                  , uploadID
                                                  , fileUploadIn
                                                  , incomingFileRootPathFilename
                                                  , notifySender
                                                  , out earlyExit ); 

       /*============================================================
        * If the step failed get out
        *============================================================*/ 

        if (!result) 
        {
          processOK = false;
          return result;
        }

       /*============================================================
        * If file is not from a client get out
        *============================================================*/ 
        
        if (earlyExit)
        {
          processOK = true;
          return result;
        }
        
       
       /*###########################################################################
         # Scan file for expected format
         ###########################################################################*/  
                    
        result = scanIncomingFileUploadForExpectedFormat (  connSpedmon
                                                          , log
                                                          , uInfo
                                                          , uploadID
                                                          , environmentID
                                                          , fileUploadIn
                                                          , incomingFileRootPathFilename
                                                          , notifySender
                                                          , out fileOK);      

       /*============================================================
        * If the step failed get out
        *============================================================*/ 

        if (!result) 
        {
          processOK = false;
          return result;
        }
        
         
       /*###########################################################################
         # Determine where to store file and review status
         ###########################################################################*/  

        result = determineIncomingFileUploadStorageAndReviewStatus (  connSpedmon
                                                                    , log
                                                                    , uInfo
                                                                    , environmentID
                                                                    , uploadID
                                                                    , fileUploadIn
                                                                    , incomingFileRootPathFilename
                                                                    , fileOK
                                                                    , notifySender); 
       
        /*============================================================
         * If the step failed get out
         *============================================================*/ 
        
        if (!result) 
        {
          processOK = false;
          return result;
        }
       
       /*###########################################################################
         # Complete process
         ###########################################################################*/ 
       
       fuIn  = fileUploadIn;
       fuOut = fileUploadIn;

       completeProcessFileUploadRecord (  connSpedmon
                                        , log
                                        , uInfo
                                        , environmentID
                                        , uploadID
                                        , fuIn
                                        , incomingFileRootPathFilename
                                        , out fuOut);
        
       fileUploadIn = fuOut;
       fileUploadOut = fileUploadIn;
       
       /*###########################################################################
         # Post process
         ###########################################################################*/  
         
        fuIn  = fileUploadIn;
        fuOut = fileUploadIn;
        
        postProcessFileUploadRecord (  connSpedmon
                                     , log
                                     , uInfo
                                     , environmentID
                                     , uploadID
                                     , fuIn
                                     , incomingFileRootPathFilename
                                     , out fuOut);
        
        fileUploadIn = fuOut;
        fileUploadOut = fileUploadIn;
        
        /*###########################################################################
          # Done
          ###########################################################################*/  
       
        processOK = true;
        result    = true;
        return result;
      }
      catch (Exception err)
      {
        resultText = err.Message;        
        processOK  = false;
        result     = false;
        return result;
      }
      finally
      {        
        saveFileUploadStatus(connSpedmon,log,uInfo,fileUploadIn.id,900,"","");        
        if (!result) FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUploadIn.id,910,"","",resultText);
        if (result)  FileUploads.saveFileUploadStatus(connSpedmon,log,uInfo,fileUploadIn.id,920,"","");
      }
      
    }
  
    /***************************************************************************
     * viewUploadFileClasses */
    /**
     * List of upload file classes
     * 
     ****************************************************************************/
     
    public static ReturnDB viewUploadFileClasses (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        uploadAllowedFromPublic
      , string        uploadAllowedFromPrivate      
      , string        term)     
    
    {
    
      ReturnDB rd = new ReturnDB();
            
      Object vTerm    = Validate.optString(term);
      Object vPublic  = Validate.optFlag(uploadAllowedFromPublic,  @"Valid flag required");
      Object vPrivate = Validate.optFlag(uploadAllowedFromPrivate, @"Valid flag required");
      
      string sql = @"select * from dbo.FILE_UPLOAD_CLASS_VIEW (@fileClassUploadAllowedFromPublic, @fileClassUploadAllowedFromPrivate, @term, null, 1, 1)";
      
      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@fileClassUploadAllowedFromPublic",   SqlDbType.Bit,     vPublic,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fileClassUploadAllowedFromPrivate",  SqlDbType.Bit,     vPrivate,  ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@term",                               SqlDbType.VarChar, vTerm,     ParameterDirection.Input,1000));

      rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      return rd;
    }

    
    /***************************************************************************
     * viewUploadFileClassesNamesValues */
    /**
     * List of upload file classes
     * 
     ****************************************************************************/

    public static ReturnNamesValues viewUploadFileClassesNamesValues (      
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        uploadAllowedFromPublic
      , string        uploadAllowedFromPrivate      
      , string        term )
    {
      ReturnNamesValues r = new ReturnNamesValues();
      ReturnDB rd = viewUploadFileClasses(connSpedmon, log, uInfo,uploadAllowedFromPublic,uploadAllowedFromPrivate,term);
      r = Database.convertReturnDBToReturnNamesValues(ref rd);
      return r;
    }        
   
    /***************************************************************************
     * viewUploadFileClassesList*/
    /**
     * List of upload file classes
     * 
     ****************************************************************************/
   
     public static List<UploadFileClass> viewUploadFileClassesList (  
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        uploadAllowedFromPublic
      , string        uploadAllowedFromPrivate      
      , string        term )
                                    
    {
      List<UploadFileClass> rl = new List<UploadFileClass>();
      ReturnDB rd = viewUploadFileClasses(connSpedmon, log, uInfo,uploadAllowedFromPublic,uploadAllowedFromPrivate,term);
      Object[] ol = Database.convertRecords(rd.records, typeof(UploadFileClass));
      foreach (Object o in ol)
      {
        UploadFileClass r = (UploadFileClass)o;
        rl.Add(r);
      }
      return rl;
    }
    
    /***************************************************************************
     * getFileUpload */
    /**
     * Returns all data related to a given upload
     * 
     ****************************************************************************/    
    
    public static ReturnFileUpload getFileUpload (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentValue
      , long          uploadID )
    {
    
      ReturnFileUpload rd = new ReturnFileUpload ();
      
      FileUpload                        fileUpload     = FileUploads.load               (connSpedmon, log, uInfo, environmentValue, uploadID);
      List<FileUploadFormDataEntryLine> dataEntryLines = FileUploads.viewFileUploadFormDataList   (connSpedmon, log, uInfo, uploadID);
      List<FileUploadStatus>            statusLog      = FileUploads.viewFileUploadStatusDataList (connSpedmon, log, uInfo, uploadID);
      
      rd.fileUpload         = fileUpload;      
      rd.statusLog          = statusLog.ToArray();                       
      rd.formDataEntryLines = dataEntryLines.ToArray();
               
      return rd;
    }          

    
    /***************************************************************************
     * viewAllActiveFileUploadStorageLocationData */
    /**
     * List of upload storage location data
     * 
     ****************************************************************************/    
    
    public static ReturnFileUploadStorageLocationData viewAllActiveFileUploadStorageLocationData (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentValue)
    {
      ReturnFileUploadStorageLocationData rd = new ReturnFileUploadStorageLocationData();
      rd.FileUploadStorageLocations = FileUploads.viewFileUploadStorageLocationList(connSpedmon,log,uInfo,environmentValue);      
      return rd;
    }
            
    /***************************************************************************
     * viewFileUploadStorageLocationList */
    /**
     * List of file upload storage locations
     * 
     ****************************************************************************/
    
    public static List<FileUploadStorageLocation> viewFileUploadStorageLocationList (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentValue )      
    {
    
      List<FileUploadStorageLocation> rl = new List<FileUploadStorageLocation>();
      ReturnDB rd = viewFileUploadFileStorageLocationData (connSpedmon, log, uInfo, environmentValue);
      
      Object[] ol = Database.convertRecords(rd.records, typeof(FileUploadStorageLocation));
      foreach (Object o in ol)
      {
        FileUploadStorageLocation r = (FileUploadStorageLocation) o;
        rl.Add(r);
      }
      return rl;
    }    


    /***************************************************************************
     * viewFileUploadFileStorageData */
    /**
     * List of storage locations
     * 
     ****************************************************************************/
    
    public static ReturnDB viewFileUploadFileStorageLocationData (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentValue )

    {
      ReturnDB rd = new ReturnDB();            
      string sql = @"select * from dbo.FILE_UPLOAD_VIEW_FILE_STORAGE_DATA (null,null,null,@environmentID)";      
      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@environmentID",  SqlDbType.BigInt,  environmentValue,  ParameterDirection.Input));           
      rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      return rd;
    }
    
    /***************************************************************************
     * load */
    /**
     * File upload record itself
     * 
     ****************************************************************************/
       
    public static FileUpload load (    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentValue
      , long          uploadID)
    {         
      FileUpload         r     = new FileUpload();
      List<SqlParameter> parms = new List<SqlParameter>();
      string sql = @"select * from dbo.FILE_UPLOAD_DATA_RECORD_CORE (null, null, null, @environmentID, @uploadID, null, null)";
      parms.Add(Database.SqlParm("@environmentID",  SqlDbType.BigInt,  environmentValue,  ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@uploadID",       SqlDbType.BigInt,  uploadID,  ParameterDirection.Input));    
      ReturnDB rd = Database.execQuery(connSpedmon,log,sql,false,parms);
      Object o    = Database.convertRecord(rd.records, typeof(FileUpload));
      r = (FileUpload) o;
      return r;
    }
      
    /***************************************************************************
     * viewFileUploadsToProcess */
    /**
     * List of pending uploads
     * 
     ****************************************************************************/
   
    public static List<FileUpload> viewFileUploadsToProcessDataList (    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentValue )
       
    {
    
      List<FileUpload> rl = new List<FileUpload>();      
      List<SqlParameter> parms = new List<SqlParameter>();

      string sql = @"select * from dbo.FILE_UPLOADS_PROCESSING_VIEW ( null,null,null, @environmentID )";      
      parms.Add(Database.SqlParm("@environmentID",  SqlDbType.BigInt,  environmentValue,  ParameterDirection.Input));      
     
      ReturnDB rd  = Database.execQuery(connSpedmon,log,sql,false,parms);
      Object[] ol = Database.convertRecords(rd.records, typeof(FileUpload));
      foreach (Object o in ol)
      {
        FileUpload r = (FileUpload) o;
        rl.Add(r);
      }
      return rl;
    }
    
    /***************************************************************************
     * viewFileUploadDataList */
    /**
     * List of upload data (contents of file uploads table)
     * 
     ****************************************************************************/
   
    public static List<FileUpload> viewFileUploadsDataList (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentValue
      , string        processFile
      , string        reviewFile
      , string        active )      
    {
    
      List<FileUpload> rl = new List<FileUpload>();
      ReturnDB rd = viewFileUploads (connSpedmon, log, uInfo, environmentValue, null, processFile, reviewFile, active);
      
      Object[] ol = Database.convertRecords(rd.records, typeof(FileUpload));
      foreach (Object o in ol)
      {
        FileUpload r = (FileUpload) o;
        rl.Add(r);
      }
      return rl;
    }
    
    /***************************************************************************
     * viewFileUploadStatusDataList */
    /**
     * List of upload data (contents of file uploads table)
     * 
     ****************************************************************************/
        
    public static List<FileUploadStatus> viewFileUploadStatusDataList (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          uploadID )      
    {
    
      List<FileUploadStatus> rl = new List<FileUploadStatus>();
      ReturnDB rd = viewFileUploadStatusData (connSpedmon, log, uInfo, uploadID);
      
      Object[] ol = Database.convertRecords(rd.records, typeof(FileUploadStatus));
      foreach (Object o in ol)
      {
        FileUploadStatus r = (FileUploadStatus) o;
        rl.Add(r);
      }
      return rl;
    }
        
    /***************************************************************************
     * viewFileUploadStatusData */
    /**
     * List of upload status data (contents of file uploads status log table)
     * 
     ****************************************************************************/
    
    public static ReturnDB viewFileUploadStatusData (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          uploadID)
    {
      ReturnDB rd = new ReturnDB();            
      string sql = @"select * from dbo.FILE_UPLOAD_VIEW_STATUS (null,null,null, @uploadID)";      
      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@uploadID",       SqlDbType.BigInt,  uploadID,  ParameterDirection.Input));           
      rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      return rd;
    }
     
    /***************************************************************************
     * viewFileUploadFormDataList */
    /**
     * List of upload data (contents of file uploads table)
     * 
     ****************************************************************************/
        
    public static List<FileUploadFormDataEntryLine> viewFileUploadFormDataList (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          uploadID )      
    {
    
      List<FileUploadFormDataEntryLine> rl = new List<FileUploadFormDataEntryLine>();
      ReturnDB rd = viewFileUploadFormData (connSpedmon, log, uInfo, uploadID);
      
      Object[] ol = Database.convertRecords(rd.records, typeof(FileUploadFormDataEntryLine));
      foreach (Object o in ol)
      {
        FileUploadFormDataEntryLine r = (FileUploadFormDataEntryLine) o;
        rl.Add(r);
      }
      return rl;
    }
        
    /***************************************************************************
     * viewFileUploadFormData*/
    /**
     * List of upload status data (contents of file uploads status log table)
     * 
     ****************************************************************************/
    
    public static ReturnDB viewFileUploadFormData (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          uploadID)
    {
      ReturnDB rd = new ReturnDB();            
      string sql = @"select * from dbo.FILE_UPLOAD_VIEW_FORM_DATA (null,null,null, @uploadID)";      
      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@uploadID",       SqlDbType.BigInt,  uploadID,  ParameterDirection.Input));           
      rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      return rd;
    }    
    
    /***************************************************************************
     * rptFileUploads */
    /**
     * Returns a list of files that have been uploaded to SpEdCare
     *     
     ***************************************************************************/

    public static ReturnDataTable rptFileUploads (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , bool          paged
      , string        pageNumber
      , string        clientID
      , string        uploadedOnDateRange
      , string        fileClass
    )

    {

      ReturnDataTable dt = new ReturnDataTable();
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

       List<SqlParameter> prms = new List<SqlParameter>();
        
       string viewUDF = "dbo.FILE_UPLOAD_VIEW_RPT(null,null,null,@clientID,@uploadedOnStartDate,@uploadedOnEndDate,@fileClass,3,1)";
                
       string uploadedOnStartDate = "";
       string uploadedOnEndDate   = "";
       MBA.Util.parseDateRange(uploadedOnDateRange , out uploadedOnStartDate, out uploadedOnEndDate);

       Object  vClientID            = Validate.optClientID (uInfo, clientID);      
       Object  vUploadedOnStartDate = Validate.optDate     (uploadedOnStartDate, Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
       Object  vUploadedOnEndDate   = Validate.optDate     (uploadedOnEndDate,   Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NO_FUTURE);
       Object  vFileClass           = Validate.optInteger  (fileClass,           Messages.INVALID_FILE_CLASS);
       
       prms.Add(Database.SqlParm("@clientID",            SqlDbType.Int,      vClientID,            ParameterDirection.Input));
       prms.Add(Database.SqlParm("@uploadedOnStartDate", SqlDbType.DateTime, vUploadedOnStartDate, ParameterDirection.Input));
       prms.Add(Database.SqlParm("@uploadedOnEndDate",   SqlDbType.DateTime, vUploadedOnEndDate,   ParameterDirection.Input));
       prms.Add(Database.SqlParm("@fileClass",           SqlDbType.Int,      vFileClass,           ParameterDirection.Input));
       
       /*----------------------------
        * Define our columns and
        * set the page order for 
        * paging
        *----------------------------*/

       defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
       {
         ss.addDisplayColumn("id");
         ss.addDisplayColumn("clientName as [Client Name]",                              true);
         ss.addDisplayColumn("convert(varchar(10),fileUploadedOn,101) as [Uploaded On]", true);
         ss.addDisplayColumn("fileUploaderContactEmail as [Uploaded By]");
         ss.addDisplayColumn("generalStatus as [File Status]");
         ss.addDisplayColumn("fileSizeHuman as [File Size]");                  
         ss.addDisplayColumn("fileClassName as [File Contains]");
         ss.addDisplayColumn("originalName as [Original File Name]");
         ss.addDisplayColumn("fileAsOrFiledName as [SpEdCare File Name]");
         ss.addDisplayColumn("possibleDuplicateFiles as [File Is Possible Duplicate Of These Files]");
            
         pageroworder = ss.pageRowOrder();

        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/
        
        dt = Entities.viewRpt (connSpedmon, log, uInfo, paged, pageNumber,"Y", viewUDF, prms, null, dc);
        dt.tableName = "Files Uploaded to SpEdCare";
        return dt;
    }
  
    /***************************************************************************
     * viewFileUploads */
    /**
     * List of file uploads
     * 
     ****************************************************************************/
    
    public static ReturnDB viewFileUploads (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , long          environmentValue
      , string        uploadID
      , string        processFile
      , string        reviewFile
      , string        active )

    {
      ReturnDB rd = new ReturnDB();
            
      Object uploadIDValue    = Validate.optInteger (uploadID,    @"Invalid upload id");
      Object processFileValue = Validate.optFlag    (processFile, @"Invalid process file flag");
      Object reviewFileValue  = Validate.optFlag    (reviewFile,  @"Invalid review file flag");
      Object activeValue      = Validate.optFlag    (active,      @"Invalid active flag");

      string sql = @"select * from dbo.FILE_UPLOAD_VIEW (null,null,null, @environmentID, @uploadID, @processFile, @reviewFile, @active)";
      
      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@environmentID",  SqlDbType.BigInt,  environmentValue,  ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@uploadID",       SqlDbType.BigInt,  uploadIDValue,     ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@processFile",    SqlDbType.Bit,     processFileValue,  ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@reviewFile",     SqlDbType.Bit,     reviewFileValue,   ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@active",         SqlDbType.Bit,     activeValue,       ParameterDirection.Input));      
     
      rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      return rd;
    }
    
    
    /***************************************************************************
     * viewUploadFileTypes */
    /**
     * List of upload file types
     * 
     ****************************************************************************/
     
    public static ReturnDB viewUploadFileTypes (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        uploadAllowedFromPublic
      , string        uploadAllowedFromPrivate
      , string        fileClassValue     
      , string        term)     
    
    {
    
      ReturnDB rd = new ReturnDB();
            
      Object vFileClass    = Validate.optInteger(fileClassValue,        @"File class invalid");
      Object vTerm         = Validate.optString(term);
      Object vPublic       = Validate.optFlag(uploadAllowedFromPublic,  @"Valid flag required");
      Object vPrivate      = Validate.optFlag(uploadAllowedFromPrivate, @"Valid flag required");
      
      string sql = @"select * from dbo.FILE_UPLOAD_TYPE_VIEW (@fileClassUploadAllowedFromPublic, @fileClassUploadAllowedFromPrivate, @term, null, @fileClassValue, 1, 1)";
      
      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@fileClassUploadAllowedFromPublic",   SqlDbType.Bit,     vPublic,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fileClassUploadAllowedFromPrivate",  SqlDbType.Bit,     vPrivate,    ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@fileClassValue",                     SqlDbType.BigInt,  vFileClass,  ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@term",                               SqlDbType.VarChar, vTerm,       ParameterDirection.Input,1000));

      rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      return rd;
    }

    /***************************************************************************
     * viewUploadFileClassesList*/
    /**
     * List of upload file classes
     * 
     ****************************************************************************/
   
     public static List<UploadFileType> viewUploadFileTypesList (  
       SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        uploadAllowedFromPublic
      , string        uploadAllowedFromPrivate      
      , string        fileClassValue
      , string        term  )
                                    
    {
      List<UploadFileType> rl = new List<UploadFileType>();
      ReturnDB rd = viewUploadFileTypes (connSpedmon, log, uInfo,uploadAllowedFromPublic,uploadAllowedFromPrivate, fileClassValue,term);
      Object[] ol = Database.convertRecords(rd.records, typeof(UploadFileType));
      foreach (Object o in ol)
      {
        UploadFileType r = (UploadFileType)o;
        rl.Add(r);
      }
      return rl;
    }

    /***************************************************************************
     * viewUploadFileTypesNamesValues */
    /**
     * List of upload file classes
     * 
     ****************************************************************************/

    public static ReturnNamesValues viewUploadFileTypesNamesValues (  
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        uploadAllowedFromPublic
      , string        uploadAllowedFromPrivate      
      , string        fileClassValue
      , string        term )
    {
      ReturnNamesValues r = new ReturnNamesValues();
      ReturnDB rd = viewUploadFileTypes (connSpedmon, log, uInfo,uploadAllowedFromPublic,uploadAllowedFromPrivate, fileClassValue,term);
      r = Database.convertReturnDBToReturnNamesValues(ref rd);
      return r;
    }    
                 
    /***************************************************************************
     * generateSelectOptionsMarkupForUploadFileTypes */
    /**
     * 
     ***************************************************************************/
     public static string generateSelectOptionsMarkupForUploadFileTypes (    
          SqlConnection connSpedmon
        , DetailsLog    log
        , UserInfo      uInfo
        , string        uploadAllowedFromPublic
        , string        uploadAllowedFromPrivate      
        , string        fileClassValue )
      
     {
       StringBuilder sb = new StringBuilder(); 
       var recs = viewUploadFileTypesList(connSpedmon,log,uInfo,uploadAllowedFromPublic,uploadAllowedFromPrivate,fileClassValue,"");
       sb.Append(@"<option disabled=""disabled"" selected=""selected"" value="""">Select One</option>");
       foreach (var rec in recs) {
         sb.AppendFormat(@"<option value=""{0}"">{1}</option>",rec.fileTypeValue,rec.fileTypeName);
       }
       return sb.ToString();
     }
     
    /***************************************************************************
     * saveFileUploadRequest */
    /**
     * Saves request
     * 
     ****************************************************************************/
    
    public static ReturnDB saveFileUploadRequest (

        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , bool          request_public
      , bool          request_private            
      , string        request_id
      , string        request_token
      , string        request_ip
      , string        request_user_agent
      , DateTime      request_datetime      
      , string        county_code
      , string        district_code
      , string        first_name
      , string        last_name
      , string        work_email
      , string        file_class
      , string        file_type
      , string        ref_date
      , string        uploaded_as
      , string        saved_as
      , string        saved_in
      , long          uploaded_from
      , long          fileSize
      , string        fileMimeType)     
    {
    
      /*============================================================
       * Validate parameters
       *============================================================*/
       
      string   vRequestID     = Validate.reqString  (request_id,    @"Request id required");
      string   vRequestToken  = Validate.optString  (request_token, @"Request token required");
      string   vCountyCode    = Validate.reqString  (county_code,   @"County code is required");
      string   vDistrictCode  = Validate.reqString  (district_code, @"District code is required");
      string   vFirstName     = Validate.reqString  (first_name,    @"First name is required");
      string   vLastName      = Validate.reqString  (last_name,     @"Last name is required");
      string   vWorkEmail     = Validate.reqEmail   (work_email,    @"Work email is required");
      long     vFileClass     = Validate.reqInteger (file_class,    @"File class is required");
      string   vFileType      = Validate.reqString  (file_type,     @"File type is required");
      object   vRefDate       = Validate.optDate    (ref_date,      @"Reference date is invalid");
      string   vUploadedAs    = Validate.reqString  (uploaded_as,   @"File uploaded as required");
      string   vSavedAs       = Validate.reqString  (saved_as,      @"File saved as required");
      string   vSavedIn       = Validate.reqString  (saved_in,      @"File saved in required");
      
      /*============================================================
       * Pass them into db parameters
       *============================================================*/

      string sql = "FILE_UPLOAD_REQUEST_SAVE";

      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@request_public",      SqlDbType.Bit,      request_public,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@request_private",     SqlDbType.Bit,      request_private,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@request_id",          SqlDbType.VarChar,  vRequestID,          ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@request_token",       SqlDbType.VarChar,  vRequestToken,       ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@request_ip",          SqlDbType.VarChar,  request_ip,          ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@request_user_agent",  SqlDbType.VarChar,  request_user_agent,  ParameterDirection.Input, 8000));      
      parms.Add(Database.SqlParm("@request_datetime",    SqlDbType.DateTime, request_datetime,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@county_code",         SqlDbType.VarChar,  vCountyCode,         ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@district_code",       SqlDbType.VarChar,  vDistrictCode,       ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@last_name",           SqlDbType.VarChar,  vLastName,           ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@first_name",          SqlDbType.VarChar,  vFirstName,          ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@work_email",          SqlDbType.VarChar,  vWorkEmail,          ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@file_class",          SqlDbType.BigInt,   vFileClass,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@file_type",           SqlDbType.VarChar,  vFileType,           ParameterDirection.Input, 100));
      parms.Add(Database.SqlParm("@ref_date",            SqlDbType.DateTime, vRefDate,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@uploaded_as",         SqlDbType.VarChar,  vUploadedAs,         ParameterDirection.Input, 4000));
      parms.Add(Database.SqlParm("@saved_as",            SqlDbType.VarChar,  vSavedAs,            ParameterDirection.Input, 4000));
      parms.Add(Database.SqlParm("@saved_in",            SqlDbType.VarChar,  vSavedIn,            ParameterDirection.Input, 4000));
      parms.Add(Database.SqlParm("@uploaded_from",       SqlDbType.BigInt,   uploaded_from,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fileSize",            SqlDbType.BigInt,   fileSize,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fileMimeType",        SqlDbType.VarChar,  fileMimeType,        ParameterDirection.Input, 8000));
                                    
      /*============================================================
       * Call sproc and return
       *============================================================*/

      ReturnDB rd = Database.execSproc(connSpedmon, log, sql, parms);
      return rd;
    }
    
                 
  }    
}
