using System;
using System.Collections.Generic;
using System.Web;
using System.Text.RegularExpressions;
using Yahoo.Yui.Compressor;

namespace MBA
{

/***************************************************************************
 * cssMinifierHandler */
/**
 * 
 * You can create an instance of the web handler by creating a text file with 
 * an extension of .ashx and put the following single line in the file:
 * 
 * <%@ WebHandler Language="C#" Class="MBA.cssMinifierHandler" %>
 *
 *  You can then include your js and css with the following markup
 *
 * <link rel="stylesheet" href="/your_handler_name.ashx?rcf=cssfilename">
 ***************************************************************************/

public class cssMinifierHandler : IHttpHandler
{
  public bool IsReusable {get{return false;}}
  
  public const string PARM_REQUESTED_CSS_FILE      = @"rcf";
  public const string DEFAULT_ENDPOINT_NAME        = @"cssmin.ashx";
  
  public static readonly Regex REGEX_FIND_EXCESS_SPACES = new Regex(@"\s\s+",     RegexOptions.Compiled | RegexOptions.Singleline);
  public static readonly Regex REGEX_FIND_COMMENTS      = new Regex(@"/\*.+?\*/", RegexOptions.Compiled | RegexOptions.Singleline);

  public static string minifyStylesheetContent (string content)
  {    
    content = REGEX_FIND_COMMENTS.Replace(content,String.Empty);
    content = REGEX_FIND_EXCESS_SPACES.Replace(content,@" ");
    content = content.Replace("\n","");
    content = content.Replace("\r","");
    content = content.Replace("\t","");    
    content = content.Trim();
    return content;
  }

  public static string generateLink (HttpContext context, string src)
  {
     return generateLink(context, src , DEFAULT_ENDPOINT_NAME);
  }
    
  public static string generateLink (HttpContext context, string src, string handlerEndpoint)
  {
	string url = MinifierHandlerCommon.generateRequestEndPointUrl (context, src, handlerEndpoint, PARM_REQUESTED_CSS_FILE);
	return String.Format(@"<link rel=""stylesheet"" href=""{0}"">",url);
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
      output =  minifyStylesheetContent(content);      
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
	context.Response.ContentType     = @"text/css";				
	MinifierHandlerCommon.addCacheHeaders(context);

    /*-------------------------------
     * Get fileName from query string
     *------------------------------*/
    
    string requestedFile = context.Request.QueryString[PARM_REQUESTED_CSS_FILE];
   
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