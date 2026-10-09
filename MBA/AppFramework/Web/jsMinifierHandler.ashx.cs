using System;
using System.Collections.Generic;
using System.Web;
using System.Text;
using DouglasCrockford.JsMin;

namespace MBA
{

/***************************************************************************
 * jsMinifierHandler */
/**
 * 
 * This is a handler that implements Andrey Taritsyn's port of 
 * Douglas Crawford's jsmin.
 * 
 * See https://github.com/Taritsyn/JSMin.NET for more details on the port
 * See https://www.crockford.com/jsmin.html and https://github.com/douglascrockford/JSMin 
 * for more details on the original.
 * 
 * You can create an instance of the web handler by creating a text file with 
 * an extension of .ashx and put the following single line in the file:
 * 
 * <%@ WebHandler Language="C#" Class="MBA.jsMinifierHandler" %>
 *
 *  You can then include your js and css with the following markup
 *
 * <script type="text/javascript" src="/your_handler_name.ashx?rjf=jsfilename"></script> 
 * 
 ***************************************************************************/

public class jsMinifierHandler : IHttpHandler
{
  public bool IsReusable {get{return false;}}
  
  public const string PARM_REQUESTED_JS_FILE = @"rjf";
  public const string DEFAULT_ENDPOINT_NAME  = @"jsmin.ashx";
  public static string generateUrl (HttpContext context, string src)
  {
	return generateUrl(context,src,DEFAULT_ENDPOINT_NAME);
  }
  public static string generateUrl (HttpContext context, string src, string handlerEndpoint)
  {
	return MinifierHandlerCommon.generateRequestEndPointUrl (context, src, handlerEndpoint, PARM_REQUESTED_JS_FILE);	
  }
  public static string generateLink (HttpContext context, string src)
  {
     return generateLink(context, src , DEFAULT_ENDPOINT_NAME);
  }    
  public static string generateLink (HttpContext context, string src, string handlerEndpoint)
  {
	//string url = MinifierHandlerCommon.generateRequestEndPointUrl (context, src, handlerEndpoint, PARM_REQUESTED_JS_FILE);
    string url = generateUrl (context, src, handlerEndpoint);
	return String.Format(@"<script type=""text/javascript"" src=""{0}""></script>",url);
  }

  protected void generateAndWriteMinifiedContent (HttpContext context, string requestedFile) 
  {
    
	string output;
	string requestedPhysicalFile = MinifierHandlerCommon.getPhysicalFilePath(context, requestedFile);

    /*-------------------------------
     * Minify content
     *------------------------------*/	

    try
	{
	  string content = MinifierHandlerCommon.getPhysicalFileContent(requestedPhysicalFile);
      var jm = new JsMinifier();
      output = jm.Minify(content);			
	}			
	catch (System.IO.FileNotFoundException)
	{
      throw new Exception("Invalid file or file not found");
	}
    
    /*-------------------------------
     * Output minified content
     *------------------------------*/	

	context.Response.Write(output);
  }	
  
  public void ProcessRequest(HttpContext context)
  {
    
	/*-------------------------------
     * Create response header
     *------------------------------*/
    
    context.Response.ContentEncoding = System.Text.Encoding.Default;    		
	context.Response.ContentType     = @"application/x-javascript";				
	MinifierHandlerCommon.addCacheHeaders(context);

    /*-------------------------------
     * Get fileName from query string
     *------------------------------*/
    
    string requestedFile = context.Request.QueryString[PARM_REQUESTED_JS_FILE];
   
    /*-------------------------------
     * Minify output
     *------------------------------*/
   
    generateAndWriteMinifiedContent (context, requestedFile);
		
    /*-------------------------------
     * Compress output 
     *------------------------------*/

	MinifierHandlerCommon.addCacheHeaders(context);

    
  }
} /* class */
} /* namespace */