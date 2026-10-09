using System;
using System.Collections.Generic;
using System.Web;
using System.Text;
using Yahoo.Yui.Compressor;

namespace MBA
{

/***************************************************************************
 * YuiCompressor */
/**
 * Yahoo tm. User Interface Compressor.
 * Modifed from dieseltravis's original and comments added
 * http://gist.github.com/130913
 * 
 * This is a wrapper for Yahoo's User Interface Compression library
 *
 * The YUI library provides a mechanism to dynamically minify and compress
 * Javascript and CSS files.
 *
 * The wrapper also sets the expires header so the assets can be cached.
 * The caching is provided by ASP.NET's caching framework.
 * This framework includes a watchdog feature that will refresh the cache
 * if a file is modified.
 * See http://www.codeguru.com/Csharp/Csharp/cs_data/cachingandpeformance/article.php/c4231
 * for a good summary of how ASP.NET's caching works. 
 *
 * The wrapper is provided as web handler.
 * You can create an instance of the web handler by creating a text file with 
 * an extension of .ashx and put the following single line in the file:
 * 
 * <%@ WebHandler Language="C#" Class="MBA.YuiCompressor" %>
 *
 *  You can then include your js and css with the following markup
 *
 * <link rel="stylesheet" type="text/css" href="/YuiCompressor.ashx?css=reset,style" />
 * <script type="text/javascript" src="/YuiCompressor.ashx?js=main,someotherscript"></script> 
 * 
 * Or you can use the methods in Generators
 * 
 * Note that the file extensions (.css, .js) are NOT included in the
 * markup.
 ***************************************************************************/

public class YuiCompressor : IHttpHandler
{
  public bool IsReusable {get{return false;}}
  
	
  public class ContentTypes
	{
		public const string CSS   = "text/css";
		public const string JS    = "application/x-javascript";
		public const string ERROR = "text/plain";
	}
		
	
  public class Extensions
	{
		public const string CSS = ".css";
		public const string JS  = ".js";
	}
	
  public const char DELIMITER = ',';
  
  public static class Generators
  {
        
    /**************************************************************************
     * cssLink */
    /**
     * Generates a css link using the yuicompressor as text suitable for output
     * via an html text writer
     * 
     * @param  cssdocument    file name (without the .css extension)
     *
     * @return css link string                
     **************************************************************************/         
    
    public static string cssLink(string cssdocument)
    {
      return cssLink(null,null,cssdocument);
    }
    
    /**************************************************************************
     * cssLink */
    /**
     * Generates a css link using the yuicompressor as text suitable for output
     * via an html text writer
     * 
     * @param  media           Media type.  Typically screen, print.  If this is
     *                         left blank, all is used.
     * @param  version         Unique version # to append to query string for cache 
     *                         purposes.  If this is left blank or null a version
     *                         number is generated.
     * @param  cssdocuments    One or more file names (without the .css extension)
     *
     * @return css link string                
     **************************************************************************/     
    
    public static string cssLink (string media, string version, params string[] cssdocuments)
    {      

      /*-------------------------------
       * Check over documents.
       * If nothing is passed in
       * return nothing.
       *------------------------------*/ 

      if (cssdocuments        == null) return "";
      if (cssdocuments.Length == 0)    return "";
     
      StringBuilder cl = new StringBuilder();
      
      /*-------------------------------
       * Create unique identifier
       * used as default version number
       *------------------------------*/ 

      string cssd  = HttpContext.Current.Server.MapPath(Constants.REL_PATH_CSS);
      long   csst  = System.IO.Directory.GetLastWriteTime(cssd).Ticks;
      string cssdm = csst.ToString();

      /*-------------------------------
       * Select media type and
       * version number to use
       *------------------------------*/ 
      
      string m  = Util.IsNullOrEmpty(media)   ? @"all" : Util.webSafeString(media);
      string v  = Util.IsNullOrEmpty(version) ? cssdm  : Util.webSafeString(version);

      /*-------------------------------
       * Build link and return
       *------------------------------*/ 

      cl.Append(@"<link rel=""stylesheet"" type=""text/css"" media=""");
      cl.Append(m);
      cl.Append(@""" href=""YuiCompressor.ashx?");
      cl.Append(v);
      cl.Append(@"&css=");
      
      string d = DELIMITER.ToString();
      string c = String.Join(d,cssdocuments);
      
      cl.Append(c);
      cl.Append(@"""/>");
      
      string newlink = cl.ToString();      
      return newlink;
    }

   /**************************************************************************
     * jsLink */
    /**
     * Generates a js link using the yuicompressor as text suitable for output
     * via an html text writer.
     * 
     * @param  version         Unique version # to append to query string for cache 
     *                         purposes.  If this is left blank or null a version
     *                         number is generated.
     * @param  jsdocuments     One or more file names (without the .js extension)
     *
     * @return js link string                
     **************************************************************************/     
    
    public static string jsLink (string version, params string[] jsdocuments)
    {      
      
      /*-------------------------------
       * Check over documents.
       * If nothing is passed in
       * return nothing.
       *------------------------------*/ 

      if (jsdocuments        == null) return "";
      if (jsdocuments.Length == 0)    return "";
     
      StringBuilder jl = new StringBuilder();
      
      /*-------------------------------
       * Create unique identifier
       * used as default version number
       *------------------------------*/ 

      string jsd  = HttpContext.Current.Server.MapPath(Constants.REL_PATH_JS);
      long   jst  = System.IO.Directory.GetLastWriteTime(jsd).Ticks;
      string jsdm = jst.ToString();

      /*-------------------------------
       * Select version number to use
       *------------------------------*/ 

      string v  = Util.IsNullOrEmpty(version) ? jsdm : Util.webSafeString(version);

      /*-------------------------------
       * Build link and return
       *------------------------------*/ 

      jl.Append(@"<script type=""text/javascript"" src=""YuiCompressor.ashx?");
      jl.Append(v);
      jl.Append(@"&js=");
      
      string d = DELIMITER.ToString();
      string j = String.Join(d,jsdocuments);
      
      jl.Append(j);
      jl.Append(@"""></script>");
      
      string newlink = jl.ToString();      
      return newlink;
    }

  }

  public void ProcessRequest(HttpContext context)
	{

    /*-------------------------------
     * Create response header
     *------------------------------*/
    
    context.Response.ContentEncoding = System.Text.Encoding.Default;    
		
    context.Response.Cache.SetExpires(DateTime.Now.Add(MBA.Rules.CACHE_DURATION));
		context.Response.Cache.SetMaxAge(MBA.Rules.CACHE_DURATION);
		context.Response.Cache.SetCacheability(HttpCacheability.Private);
    	
	 /*-------------------------------
    * Pull list of files from 
    * query string parameter
    *------------------------------*/
    
    string cssFiles = context.Request.QueryString["css"];
		string jsFiles  = context.Request.QueryString["js"];
		string fileName = context.Request.QueryString["f"];
		
	 /*-------------------------------
    * Process group of CSS files and
    * output optimized content to the
    * response object
    *------------------------------*/

    if (! string.IsNullOrEmpty(cssFiles))
		{
			context.Response.ContentType = ContentTypes.CSS;
			foreach (string cssFile in cssFiles.Split(DELIMITER)){WriteCompressedFile(context, cssFile + Extensions.CSS, Constants.REL_PATH_CSS);}
		} 

		/*-------------------------------
     * Process group of JS files and
     * output optimized content to the
     * response object
     *------------------------------*/
    
    else if (!String.IsNullOrEmpty(jsFiles)) 
		{
			context.Response.ContentType = ContentTypes.JS;
			foreach (string jsFile in jsFiles.Split(DELIMITER)){WriteCompressedFile(context, jsFile + Extensions.JS, Constants.REL_PATH_JS);}
		}
	  
   /*-------------------------------
    * Process a single CSS or JS file
    * and output optimized content 
    * to the response object
    *------------------------------*/
   
    else if (!String.IsNullOrEmpty(fileName))
		{
			if (fileName.EndsWith(Extensions.JS))
			{
				context.Response.ContentType = ContentTypes.JS;
				WriteCompressedFile(context, fileName, Constants.REL_PATH_JS);
			}
			else if (fileName.EndsWith(Extensions.CSS))
			{
				context.Response.ContentType = ContentTypes.CSS;
				WriteCompressedFile(context, fileName, Constants.REL_PATH_CSS);
			}
			else
			{
				context.Response.ContentType = ContentTypes.ERROR;
        throw new Exception("The file you are attempting to YUICompress does not appear to be a permitted type");
			}
		}
		else
		{
			context.Response.ContentType = ContentTypes.ERROR;
			context.Response.Write(Environment.NewLine);
      throw new Exception("Please provide a valid file name or group of files to YUICompress.");
		}
		
	 /*-------------------------------
    * Gzip compress output if
    * permitted
    *------------------------------*/
		
    if (Rules.RESPONSE_COMPRESS) 
		{
			string encodingsAccepted = context.Request.Headers["Accept-Encoding"];
			if (! string.IsNullOrEmpty(encodingsAccepted))
			{
				encodingsAccepted = encodingsAccepted.ToLowerInvariant();
				if (encodingsAccepted.Contains("deflate")) 
				{
					context.Response.AppendHeader("Content-Encoding", "deflate");
					context.Response.Filter = new System.IO.Compression.DeflateStream(context.Response.Filter, System.IO.Compression.CompressionMode.Compress);
				}
				else if (encodingsAccepted.Contains("gzip")) 
				{
					context.Response.AppendHeader("Content-Encoding", "gzip");
					context.Response.Filter = new System.IO.Compression.GZipStream(context.Response.Filter, System.IO.Compression.CompressionMode.Compress);
				}
			}
		}
	}
	
	
  /*-------------------------------
   * Output compressed file
   *------------------------------*/	
	
  public void WriteCompressedFile(HttpContext context, string fileName, string folder) 
	{
		// Add each file's compressed contents to the cache as it is read with a file dependency on itself
		
    if (context.Cache[fileName] == null)
		{
			string filePath = HttpContext.Current.Server.MapPath(folder + fileName);
			string output   = string.Empty;

      try
			{
				output = System.IO.File.ReadAllText(filePath);
				
        if (folder == Constants.REL_PATH_JS)
          output = JavaScriptCompressor.Compress(output) + Environment.NewLine;
				else 
          output = CssCompressor.Compress(output) + Environment.NewLine;
				
        context.Response.Write(output);
				context.Cache.Insert(fileName, output, new System.Web.Caching.CacheDependency(filePath));
			}
			
			catch (System.IO.FileNotFoundException)
			{
			  throw new Exception("Please provide a valid file name or group of files to YUICompress.");
			}
			
		}
		else
    {
      context.Response.Write((string) context.Cache[fileName]);
    }
	}
}
}