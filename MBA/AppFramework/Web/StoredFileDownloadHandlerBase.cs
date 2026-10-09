using System;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Security.Cryptography;
using System.Web;
using System.Web.UI;
using System.ComponentModel;
using EAW.MediaFile;

namespace MBA
{
  
  /***************************************************************************
   * StoredFileDownloadHandlerBase */
  /**
   * Custom handler for displaying, delivering, and downloading static files
   * referenced by a db record id and stored on a local or network volume 
   *
   * Requires: MediaFileCommon.cs, MediaFileInfo.cs
   * 
   ***************************************************************************/  

  public abstract class StoredFileDownloadHandlerBase : IHttpHandler
  {

    /*-------------------------------
     * Database connection, request
     * response, and logging objects
     * Used by call method for
     * invoking framework methods
     *------------------------------*/

    protected   SqlConnection          dbConnUser;  // Connection to user database
    protected   SqlConnection          dbConnApp;   // Connection to application database
    protected   DetailsLog             log;         // Our logging object
    protected   string                 appName;
    protected   RequestResponse        rd;          // Request/response data
    protected   UserInfo               uInfo;       // User info
    protected   HttpContext            ctx;         // Request context
    protected   ReturnStoredFileRecord rsfr;        // Object that contains all of the info we need for file
    
    protected   string[]                permittedRoles;
    protected   MethodCallback          cbGetFileData;
    protected   string                  fileRecordID;
    public      bool                    IsReusable      { get { return false; } }               

    protected   bool                    useStandardAccessControl = true;
    protected   bool                    useDownloadPlugin        = true;
    protected   bool                    removeResponseCompression = false;
    
    protected   MethodCallback               cbAccessControl;
    protected   ReturnStoredFileAccessStatus rsfas;

    public StoredFileDownloadHandlerBase(bool usestandardaccesscontrol, bool usedownloadplugin, bool removeresponsecompression)
    {
       useStandardAccessControl  = usestandardaccesscontrol;
       useDownloadPlugin         = usedownloadplugin;
       removeResponseCompression = removeresponsecompression;
    }
    
    
    /***************************************************************************
     * InitResponse */
    /**
     * 
     ***************************************************************************/
     
    protected void InitResponse ()
    {
       this.ctx.Response.Clear();       

    }
              
    /***************************************************************************
     * GetRequestData */
    /**
     * 
     ***************************************************************************/

	  protected void GetRequestData ()
	  {	  
      fileRecordID = MBA.HttpApplication.getParameter(MBA.StoredFiles.PARAM_FILE_ID);
    }
    
    /***************************************************************************
     * GetStoredFileData */
    /**
     * 
     ***************************************************************************/
    
     protected void GetStoredFileData ()
     {      
       if (useStandardAccessControl == true)
       { 
         this.rsfr  = (ReturnStoredFileRecord) HttpApplication.callMethod (  ref this.dbConnUser
                                                                           , ref this.dbConnApp
                                                                           , ref this.log
                                                                           , ref this.rd
                                                                           , ref this.uInfo
                                                                           , typeof (ReturnStoredFileRecord)
                                                                           , this.cbGetFileData
                                                                           , true
                                                                           , this.permittedRoles );
       }
       else 
       {
         
         if (uInfo == null) {     
           uInfo = new UserInfo();
           uInfo.userid    = 0;
           uInfo.userGroup = 0;
           uInfo.userRank  = 0;
         }
         
         /* Call method to check access */

         this.rsfas = new ReturnStoredFileAccessStatus();
         this.rsfas.accessGranted = false;
         this.rsfas.clientID = -1;
         rsfas = (ReturnStoredFileAccessStatus) HttpApplication.callMethod (  ref this.dbConnUser
                                                                             , ref this.dbConnApp
                                                                             , ref this.log
                                                                             , ref this.rd
                                                                             , ref this.uInfo
                                                                             , typeof (ReturnStoredFileAccessStatus)
                                                                             , this.cbAccessControl);

         if (!rsfas.accessGranted) throw new Critical(@"Access denied");

         /* Call method to get stored file.  
          * Method is expected to handle access control and any uInfo repopulation */
         
         this.rsfr  = (ReturnStoredFileRecord) HttpApplication.callMethod (  ref this.dbConnUser
                                                                           , ref this.dbConnApp
                                                                           , ref this.log
                                                                           , ref this.rd
                                                                           , ref this.uInfo
                                                                           , typeof (ReturnStoredFileRecord)
                                                                           , this.cbGetFileData);
       }
      
       return;
    }
       
    /***************************************************************************
     * SendFile */
    /**
     * Send file 
     ***************************************************************************/

    private void SendFile ()
    {
      
      string _fn  = @"attachment;filename=" + Util.createContentDispositionFileName (rsfr.storedFileRecord.label);            
      long?  _fl = rsfr.storedFileTarget.mfi.length;
      string _ct  = this.rsfr.storedFileTarget.mfi.mimetype;

      if (!_fl.HasValue) throw new Critical(@"File not found");
      if (_ct == MediaFileCommon.UNKNOWN_MIME_TYPE) _ct = MediaFileCommon.UNSPECIFIED_CONTENT_TYPE;

      
      if (removeResponseCompression)
      {       
        this.ctx.Response.Headers.Remove("Content-Encoding");
        this.ctx.Response.Filter = null;
      }

      var fileBytes = System.IO.File.ReadAllBytes(rsfr.storedFileTargetLocation);
           
      ctx.Response.ContentType = _ct;
      ctx.Response.AddHeader ("content-disposition", _fn);
      ctx.Response.AddHeader ("content-length",      _fl.ToString());   

      if (useDownloadPlugin)
      { 
          ctx.Response.SetCookie (HttpApplication.createFileDownloadCookie()); // Required for filedownload plugin       
      }
      
      ctx.Response.BinaryWrite(fileBytes);
      ctx.Response.Flush();
    }
    
    /***************************************************************************
     * ProcessRequest */
    /**
     * Entry point for the handler
     * 
     * @param    context    The request/response context
     ***************************************************************************/  
     
    public virtual void ProcessRequest (HttpContext context)
    {
      this.rsfr = new ReturnStoredFileRecord();
      this.ctx  = context;
      
      try
      {
        try
        {                
          InitResponse();
          GetRequestData();
          GetStoredFileData();
          SendFile();        
        }      
        catch (Exception pe)
        {
          throw new HttpException(400, pe.Message);
        }
      } 
      catch (Exception oe)
      {
        InitResponse();
        if (useDownloadPlugin)
        { 
          ctx.Response.Charset     = "utf-8";       
          ctx.Response.ContentType = "application/json";
          string json = JSON.toJSONString(this.rsfr);       
          ctx.Response.Write(json);
          ctx.Response.End();
        }
        else
        {
          throw new HttpException(404, oe.Message);
        }
      }      
    }
  }     
}


