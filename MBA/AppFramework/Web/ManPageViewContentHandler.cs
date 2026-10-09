using System;
using System.IO;
using System.IO.Compression;
using System.Text;
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
using System.Data;
using System.Data.SqlClient;

namespace MBA
{
  
  /***************************************************************************
   * ManPageHandler */
  /**
   * 
   ***************************************************************************/  

  public class ManPageViewContentHandler : IHttpHandler
  {
    
    protected   SqlConnection    dbConnUser;  // Connection to user database
    protected   SqlConnection    dbConnApp;   // Connection to application database
    protected   DetailsLog       log;         // Our logging object
    protected   RequestResponse  rd;          // Request/response data
    protected   UserInfo         uInfo;       // User info 
    protected   string           recID;
    protected   ReturnManPage    retManPage;
    
    protected string[]         _permittedRoles;              // Who can access this
    protected MethodCallback   _cbReturnManPage;              // Data 
    
    public    string[]         permittedRoles      {get { return _permittedRoles;  } set { _permittedRoles  = value; }}   
    public    MethodCallback   cbReturnManPage     {get { return _cbReturnManPage; } set { _cbReturnManPage = value; }}
       
    	 	  
	  /***************************************************************************
     * IsGzipSupported */
    /**
     * Determine if client supports gzip.  This is used for our response
     * compression.  This is a slightly modifed version of Rich Strahl's 
     * solution found on http://www.west-wind.com/Weblog/posts/10294.aspx
     * 
     * @return true if yes
     ***************************************************************************/   
    
    protected bool IsGZipSupported (ref HttpContext context)
    {
      string AcceptEncoding = context.Request.Headers["Accept-Encoding"];

      if (!String.IsNullOrEmpty(AcceptEncoding))
      {
        if (AcceptEncoding.Contains("gzip") || AcceptEncoding.Contains("deflate"))
        {
          return true;
        }
      }
      return false;
    } 

    /***************************************************************************
     * GZipEncodeResponse */
    /**
     * If the client supports gzip compression and the COMPRESS_RESPONSES rule
     * is set to true, gzip compress our response.  This call needs
     * to be placed right before any response data is generated.
     * To accomplish this in our framework this has been placed in callMethod()
     *
     * Please note:
     * 
     * This only compresses DYNAMIC content from your application (ie anything
     * that goes through ASP.NET).  Static content such as HTML, images, CSS,
     * Javascript, SWF files, etc are not compressed by this.  These resources
     * COULD be compressed at the web server level though if the web server
     * supports compression or through the use of a custom handler (coupled with
     * modified src, href tags) to run all static content through ASP.NET. 
     * 
     * This is a slightly modifed version of Rich Strahl's solution found on
     * http://www.west-wind.com/Weblog/posts/10294.aspx
     ***************************************************************************/     
  
    protected void GZipEncodeResponse (ref HttpContext context)
    {
      
      if (IsGZipSupported(ref context))
      {
        string AcceptEncoding = context.Request.Headers["Accept-Encoding"];
        
        if (AcceptEncoding.Contains("deflate"))
        {
          context.Response.Filter = new DeflateStream (context.Response.Filter, CompressionMode.Compress);
          context.Response.AppendHeader("Content-Encoding", "deflate");
        }
        else
        {
          context.Response.Filter = new GZipStream (context.Response.Filter, CompressionMode.Compress);
          context.Response.AppendHeader("Content-Encoding", "gzip");                    
        }
     }

     // Allow proxy servers to cache encoded and unencoded versions separately

     context.Response.AppendHeader("Vary", "Content-Encoding");
    }
    
	  /***************************************************************************
     * IsReusable */
    /**
     * Indicates whether or not instances of this can be reused
     ***************************************************************************/  
 
    public bool IsReusable
    {
      get { return false; }
    }

        
    /***************************************************************************
     * ProcessRequest */
    /**
     * Entry point for the handler
     * 
     * @param    context    The request/response context
     ***************************************************************************/  
     
    public void ProcessRequest (HttpContext context)
    {

      this.recID      = HttpApplication.getParameter(Constants.PARM_REC_ID);    
                    
      this.retManPage = (ReturnManPage) HttpApplication.callMethod(  ref this.dbConnUser
                                                                   , ref this.dbConnApp
                                                                   , ref this.log
                                                                   , ref this.rd
                                                                   , ref this.uInfo
                                                                   , typeof(ReturnManPage)
                                                                   , this._cbReturnManPage
                                                                   , true
                                                                   , this._permittedRoles);            
      StringBuilder sb = new StringBuilder();	  
          
      /*============================================================
       * Build html string
       *============================================================*/
	  
      string resultString = Util.createBasicStandAloneHTMLDocString(   this.retManPage.manPage.title
                                                                     , @""
                                                                     , this.retManPage.manPage.content);
      
      /*============================================================
       * Store in temp array
       *============================================================*/
	  
      byte[] resultBytes  = Encoding.UTF8.GetBytes (resultString);
      
      /*============================================================
       * If we can compress the response, do it
       *============================================================*/

      //if (IsGZipSupported(ref context)) 
      //  GZipEncodeResponse(ref context);      
     
      /*============================================================
       * Add our response type
       *============================================================*/

      context.Response.ContentType = @"text/html";            

      /*============================================================
       * If we could not compress the response, add the length hdr
       *============================================================*/

      //if (!IsGZipSupported(ref context))
      //  context.Response.AddHeader ("Content-Length", resultBytes.Length.ToString());
      
      /*============================================================
       * Handle caching.  We dont want the display code cached.
       *============================================================*/
      
      context.Response.Cache.SetCacheability (HttpCacheability.NoCache);
            
      /*============================================================
       * Write out html
       *============================================================*/

      context.Response.BinaryWrite (resultBytes);

    }
    
  }     
}


