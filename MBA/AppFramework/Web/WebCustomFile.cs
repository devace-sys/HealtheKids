using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.IO;

namespace MBA
{

/***************************************************************************
 * WebCustomFile */
/**
 ***************************************************************************/

public abstract class WebCustomFile : IHttpHandler
{
      
  /*-------------------------------
   * Database connection, request
   * response, and logging objects
   * Used by call method for
   * invoking framework methods
   *------------------------------*/

  protected   SqlConnection    dbConnUser;  // Connection to user database
  protected   SqlConnection    dbConnApp;   // Connection to application database
  protected   DetailsLog       log;         // Our logging object
  protected   RequestResponse  rd;          // Request/response data
  protected   UserInfo         uInfo;       // User info
   
  /*-------------------------------
   * Properties
   *------------------------------*/

  protected string[]         _permittedRoles;        // Who can access this
  protected MethodCallback   _cbGenerateFileBytes;   // Delegate to retrieve file data
  protected ReturnFileBytes  _fileBytes;             // File data
  
 /*-------------------------------
  * Commonly used report
  * parameters
  *------------------------------*/

  public    bool             IsReusable           {get { return false;}} 
  public    MethodCallback   cbGenerateFileBytes  {get { return _cbGenerateFileBytes;}  set { _cbGenerateFileBytes = value;} }
  public    string[]         permittedRoles       {get { return _permittedRoles;}       set { _permittedRoles      = value;} }
  

 /*-------------------------------
  * Constructors
  *------------------------------*/

  /***************************************************************************
   * WebCustomFile */
  /**
   * 
   * @param  purpose          What is the purpose of this request
   * @param  rptForm          FormatStrings of report document
   * @param  reportData       Report data
   ***************************************************************************/       
  
  public WebCustomFile()
  {
  }

  /***************************************************************************
   * callMethod */
  /**
   * Wrapper for calling framework methods to generate ReturnDB
   * 
   * @param  cb              Method callback (use delegate) 
   * @param  permittedRoles  If this method should be private
   *                         supply all authorized roles
   * @return                 Object containing rt (need to cast)
   ***************************************************************************/
       
  protected ReturnFileBytes callMethod ( MethodCallback cb )
  {
    return (ReturnFileBytes) HttpApplication.callMethod (  ref this.dbConnUser
                                                         , ref this.dbConnApp
                                                         , ref this.log
                                                         , ref this.rd
                                                         , ref this.uInfo
                                                         , typeof (ReturnFileBytes)
                                                         , cb);
  }
    
  protected ReturnFileBytes callMethod ( MethodCallback cb, params string[] permittedRoles )
  {      
    return (ReturnFileBytes) HttpApplication.callMethod (  ref this.dbConnUser
                                                         , ref this.dbConnApp
                                                         , ref this.log
                                                         , ref this.rd
                                                         , ref this.uInfo
                                                         , typeof(ReturnFileBytes)
                                                         , cb
                                                         , true
                                                         , permittedRoles );
  }   

  /***************************************************************************
   * ProcessRequest */
  /**
   * Required method to fulfill IHttpHandlert contract.
   * 
   * This method is called by the handler after the constructor
   * and it is where we define how to process the request.
   * 
   * @param  context         Current http request/response
   ***************************************************************************/       
  
  public void ProcessRequest(HttpContext context)
  {
                 
   /*-------------------------------
    * Determine if this is a public
    * or private report and call the 
    * appropriate method wrapper
    *------------------------------*/

   if (_permittedRoles == null)
     _fileBytes = callMethod (_cbGenerateFileBytes);
   else
     _fileBytes = callMethod (_cbGenerateFileBytes,_permittedRoles);
    
   context.Response.Clear();
  
   context.Response.ContentType  = _fileBytes.contentType;
   context.Response.AppendHeader ("content-disposition", "attachment; filename=\"" + _fileBytes.fileName + "\"");
   context.Response.SetCookie (HttpApplication.createFileDownloadCookie()); // Required for filedownload plugin             
   context.Response.BinaryWrite (_fileBytes.fileBytes);
   context.Response.End();
	
  }
 }
}