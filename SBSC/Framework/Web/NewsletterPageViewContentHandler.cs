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


namespace Spedmon
{


  public class NewsletterPageViewContentHandler : IHttpHandler
  {
    
    protected   SqlConnection    dbConnUser;  // Connection to user database
    protected   SqlConnection    dbConnApp;   // Connection to application database
    protected   MBA.DetailsLog       log;         // Our logging object
    protected   MBA.RequestResponse  rd;          // Request/response data
    protected   MBA.UserInfo         uInfo;       // User info 
    protected   string           recID;
    protected   ReturnNewsletterPage retNewsletterPage;
    
    protected string[]         _permittedRoles;              // Who can access this
    protected MBA.MethodCallback   _cbReturnNewsletterPage;              // Data 
    
    public    string[]         permittedRoles      {get { return _permittedRoles;  } set { _permittedRoles  = value; }}   
    public    MBA.MethodCallback   cbReturnNewsletterPage     {get { return _cbReturnNewsletterPage; } set { _cbReturnNewsletterPage = value; }}
       


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

      this.recID      = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);    
                    
      this.retNewsletterPage = (ReturnNewsletterPage) MBA.HttpApplication.callMethod(  ref this.dbConnUser
                                                                   , ref this.dbConnApp
                                                                   , ref this.log
                                                                   , ref this.rd
                                                                   , ref this.uInfo
                                                                   , typeof(ReturnNewsletterPage)
                                                                   , this._cbReturnNewsletterPage
                                                                   , true
                                                                   , this._permittedRoles);            
      StringBuilder sb = new StringBuilder();	  
          
      /*============================================================
       * Build html string
       *============================================================*/
	  
      string resultString = MBA.Util.createBasicStandAloneHTMLDocString(   this.retNewsletterPage.multimediaPage.title
                                                                     , @""
                                                                     , this.retNewsletterPage.multimediaPage.content);
      
      /*============================================================
       * Store in temp array
       *============================================================*/
	  
      byte[] resultBytes  = Encoding.UTF8.GetBytes (resultString);
      

      /*============================================================
       * Add our response type
       *============================================================*/

      context.Response.ContentType = @"text/html";            

      
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


