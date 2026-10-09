using System;
using System.Collections.Generic;
using System.Web;
using System.Text;
using System.IO;

namespace MBA
{

/***************************************************************************
 * MinifierHandlerCommon */
/**
 * 
 * Common static and instance methods
 ***************************************************************************/

public class MinifierHandlerCommon 
{
  
  public static string getPhysicalFilePath (HttpContext context, string src)
  {
	return context.Server.MapPath(src);					
  }

  public static long getPhysicalFileNumTicks (string physicalFilePath)
  {
  	var physicalFileDateTime = System.IO.File.GetLastWriteTime(physicalFilePath);
    return physicalFileDateTime.Ticks;
  }
   
  public static string urlEncodeSrc (string src) 
  {
    return System.Web.HttpUtility.UrlEncode(src);
  }
  
  public static string getPhysicalFileContent (string requestedPhysicalFile) 
  {
	//return System.IO.File.ReadAllText(requestedPhysicalFile);				 
    using (var fileStream = new FileStream(requestedPhysicalFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
    using (var textReader = new StreamReader(fileStream))
    return textReader.ReadToEnd();
 }
  public static string generateRequestEndPointUrl (HttpContext context, string src, string handlerEndpoint, string parmRequestedFile)
  {
    
    var physicalFilePath  = getPhysicalFilePath     (context, src);
	var numTicks          = getPhysicalFileNumTicks (physicalFilePath);
	var srcUrlEncoded     = urlEncodeSrc            (src);
	
	return String.Format(@"{0}?{1}&{2}={3}"
                         , handlerEndpoint
						 , numTicks
						 , parmRequestedFile
						 , srcUrlEncoded);

  }
  public static void addCacheHeaders (HttpContext context)
  {
    context.Response.Cache.SetExpires      (DateTime.Now.Add(MBA.Rules.CACHE_DURATION));
	context.Response.Cache.SetMaxAge       (MBA.Rules.CACHE_DURATION);
	context.Response.Cache.SetCacheability (HttpCacheability.Private);
  }
  
  public static void addCompressionHeaders (HttpContext context)
  {
  
    /*-------------------------------
     * Compress output if supported
     *------------------------------*/

    /* Determine what client can support */
	
    string encodingsAccepted = context.Request.Headers["Accept-Encoding"];
		
	if (!String.IsNullOrEmpty(encodingsAccepted))
	{
	  encodingsAccepted = encodingsAccepted.ToLowerInvariant();
	  
	  /* Deflate is preferred (see: https://stackoverflow.com/questions/9170338/why-are-major-web-sites-using-gzip/9186091#9186091) */
      
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
          
	  /* Allow proxy servers to cache encoded and unencoded versions separately */

	  context.Response.AppendHeader("Vary", "Content-Encoding");

	} /* encodings*/
  }
  
} /* class */
} /* namespace */