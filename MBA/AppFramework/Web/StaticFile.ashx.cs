using System;
using System.Collections.Generic;
using System.Web;

namespace MBA
{

/***************************************************************************
* StaticFile */
/**
* Uncompressable static file.  Binary files such as images, pdfs, swfs, etc
* are good examples of these.
* 
* See http://www.webmaster-toolkit.com/mime-types.shtml for a list of 
* mime types
*
* See http://www.codeguru.com/Csharp/Csharp/cs_data/cachingandpeformance/article.php/c4231
* for a good explanation of ASP.NET caching.
***************************************************************************/

public class StaticFile : IHttpHandler
{
  public bool IsReusable {get{return false;}}
  
	public class ContentTypes
	{
    public const string PNG   = "image/png";
    public const string GIF   = "image/gif";
    public const string JPG   = "image/jpeg";
    public const string HTML  = "text/html";
    public const string SWF   = "application/x-shockwave-flash";
    public const string PDF   = "application/pdf";
    public const string ERROR = "text/plain";
	}
		
	public class Extensions
	{
    public const string PNG  = ".png";
    public const string GIF  = ".gif";
    public const string JPG  = ".jpg";
    public const string HTML = ".html";
    public const string SWF  = ".swf";
    public const string PDF  = ".pdf";
	}
	
  public void ProcessRequest(HttpContext context)
	{
		/*-------------------------------
    * Create response header
    *------------------------------*/

		context.Response.Cache.SetExpires(DateTime.Now.Add(MBA.Rules.CACHE_DURATION));
		context.Response.Cache.SetMaxAge(MBA.Rules.CACHE_DURATION);
		context.Response.Cache.SetCacheability(HttpCacheability.Private);

	 /*-------------------------------
    * Pull file name from
    * query string parameter
    *------------------------------*/
  	
    string fileName = context.Request.QueryString["f"];
		
	  /*-------------------------------
    * Process file name
    * and output time stamped content 
    * to the response object
    *------------------------------*/

    if (!String.IsNullOrEmpty(fileName))
		{
			if (fileName.EndsWith(Extensions.JPG))
			{
				context.Response.ContentType = ContentTypes.JPG;
				WriteStaticFile(context, fileName, Constants.REL_PATH_IMG);
			}
			else if (fileName.EndsWith(Extensions.PNG))
			{
				context.Response.ContentType = ContentTypes.PNG;
				WriteStaticFile(context, fileName, Constants.REL_PATH_IMG);
			}
		  else if (fileName.EndsWith(Extensions.GIF))
			{
				context.Response.ContentType = ContentTypes.GIF;
				WriteStaticFile(context, fileName, Constants.REL_PATH_IMG);
			}
			else
			{
				context.Response.ContentType = ContentTypes.ERROR;
        throw new Exception("The file you are attempting to write does not appear to be a permitted type");
			}
		}
		else
		{
			context.Response.ContentType = ContentTypes.ERROR;
			context.Response.Write(Environment.NewLine);
      throw new Exception("Please provide a valid file name to write.");
		}
	}
	
	/*-------------------------------
   * Output Static File
   *------------------------------*/	
	
  public void WriteStaticFile(HttpContext context, string fileName, string folder) 
	{
		// Add each file's contents to the cache as it is read with a file dependency on itself
		if (context.Cache[fileName] == null)
		{
			try
			{
        string filePath = HttpContext.Current.Server.MapPath(folder + fileName);
        if (!System.IO.File.Exists(filePath)) throw new Exception("Please provide a valid file name to output");
        context.Response.WriteFile(filePath);
        context.Cache.Insert(fileName, filePath, new System.Web.Caching.CacheDependency(filePath));
			}
			catch (System.IO.FileNotFoundException)
			{
			  throw new Exception("Unable to output file.");
			}
		}
		else
    {
      context.Response.WriteFile((string) context.Cache[fileName]);
    }
	}
}
}