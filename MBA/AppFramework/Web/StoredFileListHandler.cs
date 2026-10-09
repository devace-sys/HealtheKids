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
   * StoredFileListHandler */
  /**
   * Custom handler for displaying, delivering, and downloading static files
   * referenced by a db record id and stored on a local or network volume 
   *
   * Requires: MediaFileCommon.cs, MediaFileInfo.cs
   * 
   ***************************************************************************/  

  public class StoredFileListHandler : IHttpHandler
  {

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
    
    protected   string                    fileDateRange             = "";
    protected   string                    fileClass                 = "";
    protected   string                    fileSubClass              = "";
    protected   string                    fileNameSpace             = "";
    protected   string                    fileSource                = "";
    protected   string                    fileAdditionalDataJSONStr = "";      
    protected   Dictionary<String,String> fileAdditionalDataDict;
    protected   bool                      outputPaging               = true;
    protected   string                    outputDisplayStart         = "";
    protected   int                       vOutputStartRow            = 0;
    protected   string                    outputEcho                 = "";
    protected   int                       vOutputEcho                = 0;
    protected   string                    outputPageNumber           = "";
    
    protected   string[]                  permittedRoles;    
    protected   MethodCallback            cbFileList;
    protected   ReturnDataTable           rdt;    
    
    public bool IsReusable { get { return false; } }  
    
    public StoredFileListHandler()
    {
        
    }
    
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
      string json = JSON.toJSONString(this.rdt);       
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
		  string json = JSON.toJSONString(this.rdt);       
      this.ctx.Response.Write(json);
		  return;
		}
		
    /***************************************************************************
     * GetFileList */
    /**
     * Wrapper for calling framework methods to generate ReturnDataTable
     * 
     * @param  cb              Method callback (use delegate) 
     * @param  permittedRoles  If this method should be private
     *                         supply all authorized roles
     * @return                 Object containing rt (need to cast)
     ***************************************************************************/
           
     protected void GetFileList ()
     {      
       this.rdt = (ReturnDataTable) HttpApplication.callMethod (  ref this.dbConnUser
                                                                , ref this.dbConnApp
                                                                , ref this.log
                                                                , ref this.rd
                                                                , ref this.uInfo
                                                                , typeof (ReturnDataTable)
                                                                , this.cbFileList
                                                                , true
                                                                , this.permittedRoles );
       /*-------------------------------
        * Pass back challenge/response
        * type of parameters
        *------------------------------*/    

      this.rdt.sEcho = vOutputEcho;
      
      return;
    }   

    /***************************************************************************
     * GetFormDataAndFiles */
    /**
     * 
     ***************************************************************************/

	  protected void GetFormDataAndFiles ()
	  {
	  
	    outputEcho                = MBA.HttpApplication.getParameter (Constants.PARM_REP_S_ECHO);
      outputDisplayStart        = MBA.HttpApplication.getParameter (Constants.PARM_REP_START_ROW);
	    fileClass                 = MBA.HttpApplication.getParameter (@"fileclass");
      fileSubClass              = MBA.HttpApplication.getParameter (@"filesubclass");
      fileNameSpace             = MBA.HttpApplication.getParameter (@"filenamespace");
      fileSource                = MBA.HttpApplication.getParameter (@"filesource");     
      fileDateRange             = MBA.HttpApplication.getParameter (@"daterange");
      fileAdditionalDataJSONStr = MBA.HttpApplication.getParameter (@"fileadditionaldata");     
      fileAdditionalDataDict    = JSON.dictFromJSONString (fileAdditionalDataJSONStr);
        
      int.TryParse(outputEcho,         out vOutputEcho);
      int.TryParse(outputDisplayStart, out vOutputStartRow);
      
      outputPageNumber = Util.calculatePageNumber(vOutputStartRow,Rules.VIEW_TBL_PAGE_SIZE).ToString();
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
     * ProcessRequest */
    /**
     * Entry point for the handler
     * 
     * @param    context    The request/response context
     ***************************************************************************/  
     
    public virtual void ProcessRequest (HttpContext context)
    {
      this.rdt = new ReturnDataTable();
      this.ctx = context;
      
      try
      {                        
        GetFormDataAndFiles();
        GetFileList();        
        NormalResponse();
      }

      catch (Exception e)
      {        
        this.rdt = new ReturnDataTable(e);
        ErrorResponse();
      }
    }    
  }     
}


