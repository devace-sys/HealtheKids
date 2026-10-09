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

	public abstract class StoredFileUploadHandlerBase : System.Web.IHttpHandler
	{

     public StoredFileUploadHandlerBase (bool usestandardaccesscontrol)
     {
       useStandardAccessControl = usestandardaccesscontrol;
     }

    /*-------------------------------
     * Database connection, request
     * response, and logging objects
     * Used by call method for
     * invoking framework methods
     *------------------------------*/

    protected   SqlConnection             dbConnUser;  // Connection to user database
    protected   SqlConnection             dbConnApp;   // Connection to application database
    protected   DetailsLog                log;         // Our logging object
    protected   RequestResponse           rd;          // Request/response data
    protected   UserInfo                  uInfo;       // User info
    protected   HttpContext               ctx;         // Request context
    protected   string                    appName ;
    protected   string                    fileClass                  = "";
    protected   string                    fileSubClass               = "";
    protected   string                    fileDescription            = "";
    protected   string                    fileNameSpace              = "";
    protected   string                    fileSource                 = "";
    protected   string                    isConfidentialPracticeFile = "N";
    protected   string                    fileAdditionalDataJSONStr  = "";      
    protected   Dictionary<String,String> fileAdditionalDataDict;
    protected   HttpFileCollection        files;
    
    protected   string[]                  permittedRoles;    
    protected   MethodCallback            cbSaveFileUpload;
    protected   ReturnSaveRecord          rsr;
    public      bool                        IsReusable      { get { return false; } }

    protected   bool                        useStandardAccessControl = true;
    protected   MethodCallback              cbAccessControl;

    protected ReturnStoredFileAppendInfo  rsai;

    /***************************************************************************
     * InitResponse */
    /**
     * 
     ***************************************************************************/

    protected void InitResponse ()
    {
       this.ctx.Response.Clear();
       this.ctx.Response.ContentType = "application/json";
       this.ctx.Response.Charset     = "utf-8";    
    }
          
    /***************************************************************************
     * ErrorResponse */
    /**
     * 
     ***************************************************************************/

    protected void ErrorResponse ()
    {
       InitResponse();       
       string json = JSON.toJSONString(this.rsr);       
       this.ctx.Response.Write(json);
       this.ctx.Response.End();
    }
    
    /***************************************************************************
     * NormalResponse */
    /**
     * 
     ***************************************************************************/
	public void NormalResponse ()
	{
	  InitResponse();
	  string json = JSON.toJSONString(this.rsr);       
      this.ctx.Response.Write(json);
      return;
	}
		
	/***************************************************************************
     * SaveFile */
    /**
     * 
     ***************************************************************************/
         
    protected void SaveFile ()
    {
       if (useStandardAccessControl == true)
       {
         this.rsr = (ReturnSaveRecord) MBA.HttpApplication.callMethod (  ref this.dbConnUser
                                                                       , ref this.dbConnApp
                                                                       , ref this.log
                                                                       , ref this.rd
                                                                       , ref this.uInfo
                                                                       , typeof(ReturnSaveRecord)
                                                                       , this.cbSaveFileUpload
                                                                       , true
                                                                       , this.permittedRoles );
       } 
       else
       {
         
         this.rsai               = new ReturnStoredFileAppendInfo();
         this.rsai.accessGranted = false;
         this.rsai.clientID      = - 1;
         
         /* Call method to check if file upload is allowed and get supporting info (if needed) to
          * save with the file upload (stored file).  Supporting data (such as file class, etc) needs
          * to be returned in rsai.
          */

         this.rsai = (ReturnStoredFileAppendInfo) HttpApplication.callMethod (  ref this.dbConnUser
                                                                              , ref this.dbConnApp
                                                                              , ref this.log
                                                                              , ref this.rd
                                                                              , ref this.uInfo
                                                                              , typeof (ReturnStoredFileAppendInfo)
                                                                              , this.cbAccessControl);
         /* If access is not granted then get out */

         if (!this.rsai.accessGranted) throw new Critical(@"Access denied");

         /* Call method to get file and save file upload record.  
          * Method is expected to handle any additional access control and any uInfo repopulation */

         this.rsr = (ReturnSaveRecord) MBA.HttpApplication.callMethod (  ref this.dbConnUser
                                                                       , ref this.dbConnApp
                                                                       , ref this.log
                                                                       , ref this.rd
                                                                       , ref this.uInfo
                                                                       , typeof(ReturnSaveRecord)
                                                                       , this.cbSaveFileUpload
                                                                      );

       }
       return;
    }   
	
	/***************************************************************************
     * GetFormDataAndFiles */
    /**
     * 
     ***************************************************************************/

	  protected void GetFormDataAndFiles ()
	  {
	    fileClass                  = MBA.HttpApplication.getParameter(@"fileclass");
        fileSubClass               = MBA.HttpApplication.getParameter(@"filesubclass");
        fileAdditionalDataJSONStr  = MBA.HttpApplication.getParameter(@"fileadditionaldata");
        fileDescription            = MBA.HttpApplication.getParameter(@"filedesc");
        fileNameSpace              = MBA.HttpApplication.getParameter(@"filenamespace");
        fileSource                 = MBA.HttpApplication.getParameter(@"filesource");
        isConfidentialPracticeFile = MBA.HttpApplication.getParameter(@"isconfidentialpracticefile");

        files                     = ctx.Request.Files;    
        fileAdditionalDataDict    = JSON.dictFromJSONString (fileAdditionalDataJSONStr);
	  }
	  
	/***************************************************************************
     * GetAdditionalDataValue */
    /**
     * 
     ***************************************************************************/

	  protected String GetAdditionalDataValue (String key) 
	  {
	    return Util.getValueFromDictionary(key, ref fileAdditionalDataDict);
	  }
	  
	 /***************************************************************************
      * ProcessFiles */
     /**
      * 
      ***************************************************************************/

	public void ProcessRequest (HttpContext context)
	{  	    
      
      this.rsr = new ReturnSaveRecord();
      this.ctx = context;
      
      try
      {                
        GetFormDataAndFiles();
        SaveFile();       
        NormalResponse();
      }

      catch (Exception e)
      {        
        this.rsr = new ReturnSaveRecord(e);
        ErrorResponse();
      }
                 
		  return;

		}
	}
}
