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
using TagLib;
using TagLib.Image;
using EAW.Logger;

namespace EAW.MediaFile
{
  
  /***************************************************************************
   * MediaFileHandler */
  /**
   * Custom handler for displaying, delivering, and downloading media files
   *
   * Requires: MediaFileCommon.cs, MediaFileInfo.cs
   * 
   ***************************************************************************/  

  public class MediaFileHandler : IHttpHandler
  {

    #region Properties

    /*###########################################################################
      #
      # Properties
      #
      ###########################################################################*/		
   
    protected string          _mode;
    protected int             _modeValue;
    protected string          _filename;
    protected string          _fullpath;
    protected string          _label;
    protected MediaFileInfo   _mfi;
    protected string          _filesRoot  = MediaFileCommon.MEDIA_FILE_PATH;
    protected string          _endpoint   = "";
  
    /***************************************************************************
     * FilesRoot */
    /**
     * Files root
     ***************************************************************************/  
 
    public string FilesRoot    { get { return _filesRoot; } set { _filesRoot = value; }}    

    /***************************************************************************
     * IsReusable */
    /**
     * Indicates whether or not instances of this can be reused
     ***************************************************************************/  
 
    public bool IsReusable
    {
      get { return false; }
    }

    #endregion

    #region Methods

    /*###########################################################################
      #
      # Methods
      #
      ###########################################################################*/		

    #region ParameterProcessingMethods

    /*###########################################################################
      #
      # Parameter processing methods
      #
      ###########################################################################*/		

    /***************************************************************************
     * RetrieveMode */
    /**
     * Retrieve the mode that this handler will be used in and stores in globals
     * If there are any issues exceptons are thrown
     ***************************************************************************/    

    private void RetrieveMode (ref FileLogger log, ref HttpContext context)
    {
      _mode      = context.Request[MediaFileCommon.PARAM_MODE];
      _modeValue = (int) DistributionModes.UNKNOWN;
	  if (String.IsNullOrEmpty(_mode)) throw new HttpException(400, "Mode required");
      int.TryParse(_mode, out _modeValue);
      log.WriteLog(LogLevel.Info, "Mode : " + _mode);     
    }

    /***************************************************************************
     * RetrieveFileName */
    /**
     * Retrieve the file name to work with and stores in a global
     * If there are any issues an exception is thrown
     ***************************************************************************/    

    private void RetrieveFileName (ref FileLogger log, ref HttpContext context)
    {
      _filename  = context.Request [MediaFileCommon.PARAM_FILE_NAME];	  
      if (String.IsNullOrEmpty(_filename)) throw new HttpException(400, "Filename required");                 
      _label = Path.GetFileNameWithoutExtension(_filename);
      log.WriteLog(LogLevel.Info, "Filename : " + _filename);
    }
    
    #endregion

    #region FilePathAndInfoMethods
  
    /*###########################################################################
      #
      # File path and info methods
      #
      ###########################################################################*/	

    /***************************************************************************
     * ReconstructFullFilePath */
    /**
     * Reconstruct the actual location of the file on the server and stores in
     * a global
     ***************************************************************************/    

    private void ReconstructFullFilePath (ref FileLogger log, ref HttpContext context)
    {            
      _fullpath = Path.Combine(_filesRoot, _filename);
      log.WriteLog(LogLevel.Info, "Fullpath : " + _fullpath);
    }
    /***************************************************************************
     * GetInfoAboutFile */
    /**
     * Gets info about the file and stores in a global.
     * If there are any issues an exception is thrown
     ***************************************************************************/    

    private void GetInfoAboutFile (ref FileLogger log, ref HttpContext context)
    {
      
      _mfi = new MediaFileInfo (_fullpath);      
      log.WriteLog(LogLevel.Info, "Retrieving info about : " + _fullpath);
      if (!_mfi.fileInfoOK)    throw new HttpException(404, "File not found");
      log.WriteLog (LogLevel.Info, _mfi.mimetype);
      if (!_mfi.fileSupported) throw new HttpException(415, "Unsupported media type");
    }   

    #endregion

    #region DeliveryAndDownloadMethods

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


    /*###########################################################################
      #
      # Delivery and Download Methods
      #
      ###########################################################################*/

    /***************************************************************************
     * FullDownload */
    /**
     * Send full file
     ***************************************************************************/

    private void FullDownload (ref FileLogger log, ref HttpContext context, bool inline)
    {
      
      log.WriteLog(LogLevel.Info,"Full download");

      context.Response.ContentType = _mfi.mimetype;

      /*============================================================
       * Create a filename we hope will work across all browsers
       *============================================================*/
      
      // Note: See http://stackoverflow.com/questions/93551/how-to-encode-the-filename-parameter-of-content-disposition-header-in-http

	  string _fn = "mediafile" + _mfi.fi.Extension.ToLower();

      /*============================================================
       * We want to force a download
       *============================================================*/

      if (!inline)
      {   
        log.WriteLog(LogLevel.Detail,"As attachment");
        context.Response.AddHeader("content-disposition", "attachment;filename=" + _fn);
      } 

      /*============================================================
       * This file will be part of the page
       *============================================================*/

      else
      {
       log.WriteLog(LogLevel.Detail,"As inline");
       context.Response.AddHeader("content-disposition", "inline;filename="      + _fn);
	  }

      log.WriteLog(LogLevel.Detail,"File name delivered : " + _fn);
      log.WriteLog(LogLevel.Detail,"Type : " + _mfi.mimetype);

      bool _compressed = false;

      if (_mfi.mediatype == MediaType.TEXT)
      {
        if (IsGZipSupported(ref context)) 
        {
          log.WriteLog(LogLevel.Detail,"Compressing file");
          GZipEncodeResponse(ref context);
          _compressed = true;
        }  
      }

            
      if (!_compressed)
      {
        long _filelen = 0;
        using (var sr = System.IO.File.OpenRead(_fullpath))
        {
          _filelen = sr.Length;
          sr.Close();
        }

        context.Response.AddHeader("Content-Length", _filelen.ToString());
      }      

      context.Response.WriteFile (_fullpath);
      
    }

    /***************************************************************************
     * RangeDownload */
    /**
     * Send chunks of file
     ***************************************************************************/
		
    private void RangeDownload (ref FileLogger log, ref HttpContext context)
    {
        log.WriteLog(LogLevel.Info,"Range download");

        context.Response.ContentType = _mfi.mimetype;

        log.WriteLog(LogLevel.Detail,"File : " + _filename);
        log.WriteLog(LogLevel.Detail,"Type : " + _mfi.mimetype);

        long size,start,end,length,fp=0;
        using (StreamReader reader = new StreamReader(_fullpath))
        {
           
            size = reader.BaseStream.Length;       
            start = 0;
            end = size - 1;
            length = size;
            // Now that we've gotten so far without errors we send the accept range header
            /* At the moment we only support single ranges.
             * Multiple ranges requires some more work to ensure it works correctly
             * and comply with the spesifications: http://www.w3.org/Protocols/rfc2616/rfc2616-sec19.html#sec19.2
             *
             * Multirange support annouces itself with:
             * header('Accept-Ranges: bytes');
             *
             * Multirange content must be sent with multipart/byteranges mediatype,
             * (mediatype = mimetype)
             * as well as a boundry header to indicate the various chunks of data.
             */
            context.Response.AddHeader("Accept-Ranges", "0-" + size);
            // header('Accept-Ranges: bytes');
            // multipart/byteranges
            // http://www.w3.org/Protocols/rfc2616/rfc2616-sec19.html#sec19.2
    
            if (!String.IsNullOrEmpty(context.Request.ServerVariables["HTTP_RANGE"]))
            {
                long anotherStart = start;
                long anotherEnd = end;
                string[] arr_split = context.Request.ServerVariables["HTTP_RANGE"].Split(new char[] { Convert.ToChar("=") });
                string range = arr_split[1];

                // Make sure the client hasn't sent us a multibyte range
                if (range.IndexOf(",") > -1)
                {
                    // (?) Shoud this be issued here, or should the first
                    // range be used? Or should the header be ignored and
                    // we output the whole content?
                    context.Response.AddHeader("Content-Range", "bytes " + start + "-" + end + "/" + size);
                    throw new HttpException(416, "Requested Range Not Satisfiable");

                }

                // If the range starts with an '-' we start from the beginning
                // If not, we forward the file pointer
                // And make sure to get the end byte if spesified
                if (range.StartsWith("-"))
                {
                    // The n-number of the last bytes is requested
                    anotherStart = size - Convert.ToInt64(range.Substring(1));
                }
                else
                {
                    arr_split = range.Split(new char[] { Convert.ToChar("-") });
                    anotherStart = Convert.ToInt64(arr_split[0]);
                    long temp = 0;
                    anotherEnd = (arr_split.Length > 1 && Int64.TryParse(arr_split[1].ToString(), out temp)) ? Convert.ToInt64(arr_split[1]) : size;
                }
                /* Check the range and make sure it's treated according to the specs.
                 * http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
                 */
                // End bytes can not be larger than $end.
                anotherEnd = (anotherEnd > end) ? end : anotherEnd;
                // Validate the requested range and return an error if it's not correct.
                if (anotherStart > anotherEnd || anotherStart > size - 1 || anotherEnd >= size)
                {

                    context.Response.AddHeader("Content-Range", "bytes " + start + "-" + end + "/" + size);
                    throw new HttpException(416, "Requested Range Not Satisfiable");
                }
                start = anotherStart;
                end = anotherEnd;

                length = end - start + 1; // Calculate new content length
                fp = reader.BaseStream.Seek(start, SeekOrigin.Begin);
                context.Response.StatusCode = 206;
            }
        }

        // Notify the client the byte range we'll be outputting

        context.Response.AddHeader("Content-Range", "bytes " + start + "-" + end + "/" + size);
        context.Response.AddHeader("Content-Length", length.ToString());

        // Start buffered download
        context.Response.WriteFile(_fullpath, fp, length);
         
    }
	
    /***************************************************************************
     * DeliverFile */
    /**
     * Delivers the file to a viewer
     ***************************************************************************/   	    
    
    private void DeliverFile (ref FileLogger log, ref HttpContext context)
    {
      
      log.logDetail ("Deliver file mode");

      /*============================================================
       * Check file name and get info
       *============================================================*/

      RetrieveFileName        (ref log, ref context);      
      ReconstructFullFilePath (ref log, ref context); 
      GetInfoAboutFile        (ref log, ref context);
       
      /*============================================================
       * Handle caching.  We want the delivered files cached.
       *============================================================*/
      
      context.Response.Cache.SetCacheability (HttpCacheability.Public);
      context.Response.Cache.SetExpires      (DateTime.Now.Add (MediaFileCommon.CACHE_DURATION));
      context.Response.Cache.SetMaxAge       (MediaFileCommon.CACHE_DURATION); 
      context.Response.AddHeader ("Last-Modified", _mfi.fi.LastWriteTime.ToLongDateString());         
              
      /*============================================================
       * If the requester supports range requests then use them
       *============================================================*/

      if (!String.IsNullOrEmpty(context.Request.ServerVariables["HTTP_RANGE"]))
      {    
        RangeDownload (ref log, ref context);  // request for chunk
      }

      /*============================================================
       * Otherwise send entire file
       *============================================================*/

      else
      {
        FullDownload (ref log, ref context, true);
      }   

    }

    /***************************************************************************
     * DownloadFile */
    /**
     * Forces download of file
     ***************************************************************************/   	

    private void DownloadFile (ref FileLogger log, ref HttpContext context)
    {

      /*============================================================
       * Check file name and get info
       *============================================================*/

      RetrieveFileName        (ref log, ref context);      
      ReconstructFullFilePath (ref log, ref context); 
      GetInfoAboutFile        (ref log, ref context); 


      FullDownload (ref log, ref context, false);         
    }	
    #endregion
    
    #region DisplayMethods

    /*###########################################################################
      #
      # Display Methods
      #
      ###########################################################################*/

   protected void DisplayUpgradeMessage (ref HttpContext context, ref StringBuilder sb, ref string urlDownload)
   {
      sb.AppendFormat (@"<div class=""{0}"">"
                       , MediaFileCommon.CSS_UPGRADE_REQUIRED);
      sb.Append (@"<h4>Sorry it looks like either your browser or device will not let you view this file in the browser itself.</h4>");
      sb.AppendFormat (@"Click <a href=""{0}"">here</a> to download the file", urlDownload);
      sb.Append (@"</div>");

   }

    /***************************************************************************
     * DisplayAudio */
    /**
     * Displays audio player
     ***************************************************************************/   	

    protected void DisplayAudio (HttpContext context, string urlDeliver, string urlDownload, ref StringBuilder sb)
    {
      /*============================================================
       * Render script that creates player
       *============================================================*/
      
      sb.Append (@"<script type=""text/javascript"">");
      sb.Append (@"$(document).ready(function(){");

      /*============================================================
       * Force maximize
       *============================================================*/   

      sb.Append ("window.moveTo(0, 0);");
      sb.Append ("window.resizeTo(screen.availWidth, screen.availHeight);");

      /*============================================================
       * Create player
       *============================================================*/   

      sb.AppendFormat (@"$('{0}').jPlayer(", MediaFileCommon.ID_DISP_FILE_W_SEL);
      sb.Append (@"{");
      sb.Append (@"ready: function () {");
      sb.Append (@"$(this).jPlayer(""setMedia"", {");
      sb.Append (@"""mp3"": """ + urlDeliver + @"""");        
      sb.Append (@"});");
      //sb.Append (@"$(this).jPlayer(""play"");"); 
      sb.Append (@"},");
      sb.AppendFormat (@"cssSelectorAncestor:""{0}"",",MediaFileCommon.ID_DISP_FILE_CONTAINER_W_SEL);
      sb.Append (@"solutions:""html,flash"",");
      sb.Append (@"supplied: ""mp3""");
      sb.Append (@"});");
      sb.Append (@"});");
      sb.Append (@"</script>");        

      /*============================================================
       * Render required HTML for player
       *============================================================*/
     
      sb.AppendFormat (@"<div id=""{0}"" class=""jp-jplayer {1}""></div>"
                       , MediaFileCommon.ID_DISP_FILE
                       , MediaFileCommon.CSS_AUDIO);

      sb.AppendFormat (@"<div id=""{0}"" class=""jp-audio"">"
                       , MediaFileCommon.ID_DISP_FILE_CONTAINER);

      sb.AppendFormat (@"<div id=""{0}"" class=""jp-type-single"">"
                       , MediaFileCommon.ID_DISP_FILE_PLAYER);
     
      sb.Append (@"<div class=""jp-gui jp-interface"">");

      sb.Append (@"<ul class=""jp-controls"">");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-play"" tabindex=""1"">play</a></li>");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-pause"" tabindex=""1"">pause</a></li>");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-stop"" tabindex=""1"">stop</a></li>");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-mute"" tabindex=""1"" title=""mute"">mute</a></li>");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-unmute"" tabindex=""1"" title=""unmute"">unmute</a></li>");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-volume-max"" tabindex=""1"" title=""max volume"">max volume</a></li>");
      sb.Append (@"</ul>"); // controls
      
      sb.Append (@"<div class=""jp-progress"">");
      sb.Append (@"<div class=""jp-seek-bar"">");
      sb.Append (@"<div class=""jp-play-bar""></div>");
      sb.Append (@"</div>"); // seek-bar
      sb.Append (@"</div>"); // progress
      
      sb.Append (@"<div class=""jp-volume-bar"">");
      sb.Append (@"<div class=""jp-volume-bar-value""></div>");      
      sb.Append (@"</div>"); // volume-bar
      
      sb.Append (@"<div class=""jp-time-holder"">");
      sb.Append (@"<div class=""jp-current-time""></div>");
      sb.Append (@"<div class=""jp-duration""></div>");
      
      sb.Append (@"<ul class=""jp-toggles"">");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-repeat"" tabindex=""1"" title=""repeat"">repeat</a></li>");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-repeat-off"" tabindex=""1"" title=""repeat off"">repeat off</a></li>");
      sb.Append (@"</ul>"); // toggles

      sb.Append (@"</div>"); //time-holder
      
      sb.Append (@"</div>"); // interface

      sb.Append (@"<div class=""jp-title"">");
      sb.Append (@"<ul>");
      sb.Append (@"<li>");
      sb.Append (_label);
      sb.Append (@"</li>");
      sb.Append (@"</ul>");
      sb.Append (@"</div>"); // title

      sb.Append (@"<div class=""jp-no-solution"">");

      DisplayUpgradeMessage(ref context, ref sb, ref urlDownload);

      sb.Append (@"</div>"); // no solution

      sb.Append (@"</div>"); // single
      sb.Append (@"</div>"); // container

    }

    /***************************************************************************
     * DisplayVideo */
    /**
     * Displays video player
     ***************************************************************************/   

    protected void DisplayVideo (HttpContext context, string urlDeliver, string urlDownload, ref StringBuilder sb)
    {
    
      /*============================================================
       * Render script that creates player
       *============================================================*/

      sb.Append (@"<script type=""text/javascript"">");
      sb.Append (@"$(document).ready(function(){");

      /*============================================================
       * Force maximize
       *============================================================*/   

      sb.Append ("window.moveTo(0, 0);");
      sb.Append ("window.resizeTo(screen.availWidth, screen.availHeight);");

      /*============================================================
       * Create player
       *============================================================*/   

      sb.AppendFormat (@"$('{0}').jPlayer(", MediaFileCommon.ID_DISP_FILE_W_SEL );
      sb.Append (@"{");
      sb.Append (@"ready: function () {");
      sb.Append (@"$(this).jPlayer(""setMedia"", {");

      sb.AppendFormat (@"""{0}"": ""{1}""", "m4v", urlDeliver);

      sb.Append (@"});");
      //sb.Append (@"$(this).jPlayer(""play"");"); 
      sb.Append (@"},");
      sb.AppendFormat (@"cssSelectorAncestor:""{0}"",",MediaFileCommon.ID_DISP_FILE_CONTAINER_W_SEL);
      sb.Append (@"solutions:""html,flash"",");
      sb.Append (@"supplied: ""m4v""");
      //sb.Append (@",sizeFull: {width: """ + _mfi.width.ToString() + @"px"", height:""" + _mfi.height.ToString() + @"px""}"); // Cant use format here
      sb.Append (@"});");
      sb.Append (@"});");
      sb.Append (@"</script>");

      /*============================================================
       * Render required HTML for player
       *============================================================*/

      sb.AppendFormat (@"<div id=""{0}"" class=""jp-video {1}"">"
                       , MediaFileCommon.ID_DISP_FILE_CONTAINER
                       , MediaFileCommon.CSS_VIDEO);     

      sb.Append (@"<div class=""jp-type-single"">");
      
      // File

      sb.AppendFormat (@"<div id=""{0}"" class=""jp-jplayer""></div>", MediaFileCommon.ID_DISP_FILE);
      
      // Gui 

      sb.Append (@"<div class=""jp-gui"">");

      sb.Append (@"<div class=""jp-video-play"">");
      sb.Append (@"<a href=""javascript:;"" class=""jp-video-play-icon"" tabindex=""1"">play</a>");
      sb.Append (@"</div>"); // video play

      sb.Append (@"<div class=""jp-interface"">");

      // Progress 
      sb.Append (@"<div class=""jp-progress"">");
      sb.Append (@"<div class=""jp-seek-bar"">");
      sb.Append (@"<div class=""jp-play-bar""></div>");
      sb.Append (@"</div>"); // Seek bar
      sb.Append (@"</div>"); // Progress

      sb.Append (@"<div class=""jp-current-time""></div>");
      sb.Append (@"<div class=""jp-duration""></div>");

      // Controls holder

      sb.Append (@"<div class=""jp-controls-holder"">");

      sb.Append (@"<ul class=""jp-controls"">");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-play"" tabindex=""1"">play</a></li>");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-pause"" tabindex=""1"">pause</a></li>");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-stop"" tabindex=""1"">stop</a></li>");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-mute"" tabindex=""1"" title=""mute"">mute</a></li>");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-unmute"" tabindex=""1"" title=""unmute"">unmute</a></li>");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-volume-max"" tabindex=""1"" title=""max volume"">max volume</a></li>");
      sb.Append (@"</ul>");

      sb.Append (@"<div class=""jp-volume-bar"">");
      sb.Append (@"<div class=""jp-volume-bar-value""></div>");
      sb.Append (@"</div>"); // Volume bar 

      sb.Append (@"<ul class=""jp-toggles"">");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-full-screen"" tabindex=""1"" title=""full screen"">full screen</a></li>");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-restore-screen"" tabindex=""1"" title=""restore screen"">restore screen</a></li>");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-repeat"" tabindex=""1"" title=""repeat"">repeat</a></li>");
      sb.Append (@"<li><a href=""javascript:;"" class=""jp-repeat-off"" tabindex=""1"" title=""repeat off"">repeat off</a></li>");
      sb.Append (@"</ul>");
      
      sb.Append (@"</div>"); // Controls holder

      // Title 

      sb.Append (@"<div class=""jp-title"">");
      sb.Append (@"<ul>");
      sb.Append (@"<li>");
      sb.Append (_label);
      sb.Append (@"</li>");
      sb.Append (@"</ul>");
      sb.Append (@"</div>"); // Title

      sb.Append (@"</div>"); // Interface
      sb.Append (@"</div>"); // Gui

      // No Solution

      sb.Append (@"<div class=""jp-no-solution"">");

      DisplayUpgradeMessage (ref context, 
                             ref sb, 
                             ref urlDownload);

      sb.Append (@"</div>"); // No solution

      sb.Append (@"</div>"); // Single
      sb.Append (@"</div>"); // Container

    }

    /***************************************************************************
     * DisplayImage */
    /**
     * Displays image
     ***************************************************************************/   
    
    protected void DisplayImage (HttpContext context, string urlDeliver, string urlDownload, ref StringBuilder sb)
    {
      
      sb.Append (@"<script type=""text/javascript"">");              
      sb.Append (@"$(document).ready( function() {"); 

      /*============================================================
       * Force maximize
       *============================================================*/   

      sb.Append ("window.moveTo(0, 0);");
      sb.Append ("window.resizeTo(screen.availWidth, screen.availHeight);");
      sb.Append (@"});");

      sb.Append (@"</script>"); 
      
      sb.AppendFormat (@"<div id=""{0}"" class=""{1}"">"
                      , MediaFileCommon.ID_DISP_FILE_CONTAINER
                      , MediaFileCommon.CSS_IMAGE_CONTAINER); 
    
      sb.AppendFormat (@"<img id=""{0}"" class=""{1}"" src=""{2}"" width=""{3}"" height=""{4}"">" 
                      , MediaFileCommon.ID_DISP_FILE 
                      , MediaFileCommon.CSS_IMAGE
                      , urlDeliver
                      , _mfi.width
                      , _mfi.height);
      sb.Append       (@"</img>");
      sb.Append       (@"</div>");
	}
     		
    /***************************************************************************
     * DisplayObject */
    /**
     * Displays application file
     ***************************************************************************/   

    protected void DisplayObject (HttpContext context, string urlDeliver, string urlDownload, ref StringBuilder sb)
    {

      sb.Append (@"<script type=""text/javascript"">");              
      sb.Append (@"$(document).ready( function() {");      

      /*============================================================
       * Force maximize
       *============================================================*/      

      sb.Append ("window.moveTo(0, 0);");
      sb.Append ("window.resizeTo(screen.availWidth, screen.availHeight);");

      /*============================================================
       * Early exit for object load failure
       *============================================================*/      

      //sb.Append (@"if ( $('div.mf-upgrade-required').is(':visible')) {return;}");

      /*============================================================
       * Handle scrolling for iOS devices
       *============================================================*/      

      sb.Append       (@"if (/iPhone|iPod|iPad/.test(navigator.userAgent))");
      sb.Append       (@"{");
      sb.AppendFormat (@"$('#{0}').append('<div>Hint: Use two fingers to scroll');",MediaFileCommon.ID_DISP_TOP);
      sb.AppendFormat (@"$('{0}').css",MediaFileCommon.ID_DISP_FILE_CONTAINER_W_SEL);
      sb.Append       (@"({overflow:'auto'});");
      sb.AppendFormat (@"var obj = $('{0}');",MediaFileCommon.ID_DISP_FILE_W_SEL);
      sb.Append       (@"$(obj).css({");
      sb.Append       (@"overflow: 'auto',");
      sb.Append       (@"'-webkit-overflow-scrolling': 'touch'");
      sb.Append       (@"});");
      sb.Append       (@"};");

      /*============================================================
       * Handle initial and rezize
       *============================================================*/      

      sb.Append       (@"var adjustObjSize = function () {");	

      sb.Append       (@"var ww = $(window).width();");
	    sb.Append       (@"var wh = $(window).height();");

      sb.AppendFormat (@"var th  = $('#{0}').height();", MediaFileCommon.ID_DISP_TOP);
      sb.AppendFormat (@"var ch  = $('#{0}').height();", MediaFileCommon.ID_DISP_CONTENT);
      sb.AppendFormat (@"var fch = $('#{0}').height();", MediaFileCommon.ID_DISP_FILE_CONTAINER);
      sb.AppendFormat (@"var fmh = $('#{0}').height();", MediaFileCommon.ID_DISP_META_CONTAINER);
      sb.AppendFormat (@"var fh  = $('#{0}').height();", MediaFileCommon.ID_DISP_FOOTER);

      sb.Append       (@"var w  = ww - 50;");      
      sb.Append       (@"var h  = wh - th - fh - fmh - 60;");
      sb.Append       (@"if (w < 0) w = 500;");
      sb.Append       (@"if (h < 0) h = 500;");
      sb.Append       (@"var wp = w + 'px !important';");
      sb.Append       (@"var hp = h + 'px !important';");  

    
	  sb.AppendFormat (@"$('#{0}').attr('width', w);", MediaFileCommon.ID_DISP_FILE);
      sb.AppendFormat (@"$('#{0}').attr('height',h);", MediaFileCommon.ID_DISP_FILE);
      sb.AppendFormat (@"$('#{0}').css('width',wp);",  MediaFileCommon.ID_DISP_FILE);
      sb.AppendFormat (@"$('#{0}').css('height',hp);", MediaFileCommon.ID_DISP_FILE);

      sb.Append (@"};");
      
      sb.Append (@"adjustObjSize();");

      sb.Append (@"$(window).resize(adjustObjSize());");
      sb.Append (@"});");
      sb.Append (@"</script>"); 
      
      sb.AppendFormat (@"<div id=""{0}"" class=""{1}"">"
                      , MediaFileCommon.ID_DISP_FILE_CONTAINER
                      , MediaFileCommon.CSS_OBJECT_CONTAINER); 
      
      sb.AppendFormat (@"<object id=""{0}"" class=""{1}"" data=""{2}"" type=""{3}"" width=""100"" height=""50"">"
                       , MediaFileCommon.ID_DISP_FILE
                       , MediaFileCommon.CSS_OBJECT           
                       , urlDeliver
                       , _mfi.mimetype);

      DisplayUpgradeMessage (ref context, 
                             ref sb, 
                             ref urlDownload);

      sb.Append (@"</object>");
      sb.Append (@"</div>");
      
    }

    /***************************************************************************
     * DisplayFile */
    /**
     * Displays the file
     ***************************************************************************/  
    
    protected void DisplayFile (ref FileLogger log, ref HttpContext context)
    {
      
      /*============================================================
       * Fetch the actual file.  If there are any problems then we
       * will have to exit
       *============================================================*/
           
      RetrieveFileName        (ref log, ref context);
      ReconstructFullFilePath (ref log, ref context);
      GetInfoAboutFile        (ref log, ref context);

      /*============================================================
       * No issues.  Display
       *============================================================*/      

      StringBuilder sb = new StringBuilder();	  
      
      /*============================================================
       * Build start of document
       *============================================================*/
     
      sb.Append (@"<!doctype html>");
      sb.Append (@"<html lang=""en"">");

      /*============================================================
       * Head
       *============================================================*/

      sb.Append (@"<head>");
      sb.Append (@"<meta charset=""utf-8"" />");
      sb.Append (@"<meta name=""viewport"" content=""width=device-width, initial-scale=1""/>");
      sb.Append (@"<title>");
      sb.Append (_label);
      sb.Append (@"</title>");

      /*============================================================
       * CSS and JS includes
       *============================================================*/

	    sb.AppendFormat (@"<link type=""text/css"" href=""{0}"" rel=""stylesheet"" />",MediaFileCommon.CreateURL(ref context, MediaFileCommon.FILE_CSS_JPLAYER));
	    sb.AppendFormat (@"<link type=""text/css"" href=""{0}"" rel=""stylesheet"" />",MediaFileCommon.CreateURL(ref context, MediaFileCommon.FILE_CSS_MF));

      sb.AppendFormat (@"<script type=""text/javascript"" src=""{0}""></script>",MediaFileCommon.CreateURL(ref context, MediaFileCommon.FILE_JS_JQUERY));
      sb.AppendFormat (@"<script type=""text/javascript"" src=""{0}""></script>",MediaFileCommon.CreateURL(ref context, MediaFileCommon.FILE_JS_JPLAYER));
      sb.AppendFormat (@"<script type=""text/javascript"" src=""{0}""></script>",MediaFileCommon.CreateURL(ref context, MediaFileCommon.FILE_JS_MF));

      sb.Append (@"</head>");
      
      /*============================================================
       * Body
       *============================================================*/

      sb.Append (@"<body>");

      /*============================================================
       * Build container
       *============================================================*/

      sb.AppendFormat (@"<div id=""{0}"" class=""{1}"">"
                       , MediaFileCommon.ID_DISP_CONTAINER
                       , MediaFileCommon.CSS_DISP_CONTAINER);

      /*============================================================
       * Build top and label
       *============================================================*/

      sb.AppendFormat (@"<div id=""{0}"" class=""{1}"">"
                       , MediaFileCommon.ID_DISP_TOP
                       , MediaFileCommon.CSS_DISP_HEADER);
       
      sb.AppendFormat (@"<h3>{0}</h3>"
                       , _label);
        
      sb.Append (@"</div>");            

      /*============================================================
       * Build content
       *============================================================*/

      sb.AppendFormat (@"<div id=""{0}"" class=""{1}"">"
                       , MediaFileCommon.ID_DISP_CONTENT
                       , MediaFileCommon.CSS_DISP_CONTENT);

      /*============================================================
       * Our end point is this
       *============================================================*/
        
      _endpoint = MediaFileCommon.CurrentEndPointName (context);
      
      /*============================================================
       * Create urls we will need
       *============================================================*/  
      
      string urlDeliver  = MediaFileCommon.CreateURL (ref context, _endpoint, _filename,  _mfi.fi.LastWriteTime.Ticks, DistributionModes.DELIVER);
      string urlDownload = MediaFileCommon.CreateURL (ref context, _endpoint, _filename,  _mfi.fi.LastWriteTime.Ticks, DistributionModes.DOWNLOAD);
        
      /*============================================================
       * If the file should be displayable in browser do it
       *============================================================*/
        
      if (_mfi.fileSupported)

      {        
          
        /*===========================================================
         * Depending on our type of media we use different methods
         * to display the content
         *============================================================*/ 
         
        if (_mfi.mediatype == MediaType.IMAGE)       DisplayImage  (context, urlDeliver, urlDownload, ref sb);
        if (_mfi.mediatype == MediaType.APPLICATION) DisplayObject (context, urlDeliver, urlDownload, ref sb);
        if (_mfi.mediatype == MediaType.AUDIO)       DisplayAudio  (context, urlDeliver, urlDownload, ref sb);
		    if (_mfi.mediatype == MediaType.VIDEO)       DisplayVideo  (context, urlDeliver, urlDownload, ref sb);
        if (_mfi.mediatype == MediaType.TEXT)        DisplayObject (context, urlDeliver, urlDownload, ref sb);

        /*============================================================
         * Meta data
         *============================================================*/ 

        sb.AppendFormat (@"<div id=""{0}"" class=""{1}"">"
                        , MediaFile.MediaFileCommon.ID_DISP_META_CONTAINER
                        , MediaFileCommon.CSS_DISP_CONTENT_META);
                    
        //sb.AppendFormat (@"<ul class=""{0}"">"
        //                 , MediaFileCommon.CSS_TAGS);
		
        //List<String> _tags = MediaFileCommon.ListTags(_mfi);
		
        //foreach (string _tag in _tags)
       // {
       //   sb.AppendFormat(@"<li>{0}</li>",_tag);
       // }

        //sb.Append (@"</ul>");
        
        sb.Append (@"</div>");
         
	  }

        
      sb.Append (@"</div>");  // Content

      /*============================================================
       * Display footer
       *============================================================*/ 
          
      sb.AppendFormat (@"<div id=""{0}"" class=""{1}"">"
                       , MediaFileCommon.ID_DISP_FOOTER
                       , MediaFileCommon.CSS_DISP_FOOTER);

      /*============================================================
       * Links
       *============================================================*/ 
           
      //sb.AppendFormat (@"<ul class=""{0}"">", MediaFileCommon.CSS_DISP_FOOTER);
      
      //sb.AppendFormat (@"<li class=""{0}"">", MediaFileCommon.CSS_DISP_FOOTER);        
      //sb.Append(MediaFileCommon.GenerateLink(urlDeliver, "Open In Browser"));
      //sb.Append (@"</li>");
      //sb.AppendFormat (@"<li class=""{0}"">", MediaFileCommon.CSS_DISP_FOOTER);
      //sb.Append(MediaFileCommon.GenerateLink(urlDownload, "Download"));
      //sb.Append (@"</li>");
      //sb.Append (@"</ul>");              
      sb.Append (@"</div>");  // Footer

      sb.Append (@"</div>");  // Container

      sb.Append (@"</body>");
      sb.Append (@"</html>");

      /*============================================================
       * Build string holding our html and store in temp array
       *============================================================*/
	  
      string resultString = sb.ToString();
      byte[] resultBytes  = Encoding.UTF8.GetBytes (resultString);
      
      /*============================================================
       * If we can compress the response, do it
       *============================================================*/

      if (IsGZipSupported(ref context)) 
        GZipEncodeResponse(ref context);      
     
      /*============================================================
       * Add our response type
       *============================================================*/

      context.Response.ContentType = @"text/html";            

      /*============================================================
       * If we could not compress the response, add the length hdr
       *============================================================*/

      if (!IsGZipSupported(ref context))
        context.Response.AddHeader ("Content-Length", resultBytes.Length.ToString());
      
      /*============================================================
       * Handle caching.  We dont want the display code cached.
       *============================================================*/
      
      context.Response.Cache.SetCacheability (HttpCacheability.NoCache);
            
      /*============================================================
       * Write out html
       *============================================================*/

      context.Response.BinaryWrite (resultBytes);
     

    }
    #endregion
    
    #region InterfaceMethods
    
    /*###########################################################################
      #
      # Interface methods
      #
      ###########################################################################*/		

    /***************************************************************************
     * ProcessRequest */
    /**
     * Entry point for the handler
     * 
     * @param    context    The request/response context
     ***************************************************************************/  
     
    public virtual void ProcessRequest (HttpContext context)
    {

      FileLogger log = new FileLogger ( MediaFileCommon.MEDIA_SERVICE_LOG_PATH 
                                       ,MediaFileCommon.MEDIA_SERVICE_LOG_NAME);
		
      try
      {

		log.WriteLog (LogLevel.Info, "Starting");
		log.WriteLog (LogLevel.Info, "User agent data");
        log.WriteLog (LogLevel.Detail,context.Request.UserAgent);
        log.WriteLog (LogLevel.Detail,context.Request.UserHostAddress);
        log.WriteLog (LogLevel.Detail,context.Request.UserHostName);
              
        /*============================================================
         * Determine what mode this handler is being called in
         *============================================================*/
    
        RetrieveMode (ref log, ref context);      

        /*============================================================
         * Then perform the action the mode is asking
         *============================================================*/
       
        if      (_modeValue == (int) DistributionModes.DELIVER)  DeliverFile  (ref log, ref context);      
        else if (_modeValue == (int) DistributionModes.DISPLAY)  DisplayFile  (ref log, ref context);
        else if (_modeValue == (int) DistributionModes.DOWNLOAD) DownloadFile (ref log, ref context);
      
        /*============================================================
         * If we get here we don't know what to do so get out
         *============================================================*/
        
        else 
        {
          log.logWarn("Not sure what to do here");
        }
	            
      }

      catch (HttpException e)
      {
        log.WriteLog(LogLevel.Alert, e.Message);
        throw (e);
      }

      catch (Exception e)
      {        
        log.WriteLog(LogLevel.Crit, e.Message);        
      }

      finally
      {		
        log.WriteLog(LogLevel.Info, "Status code : " + context.Response.StatusCode.ToString());
        log.WriteLog(LogLevel.Info, "Status : "      + context.Response.Status);
        log.WriteLog(LogLevel.Info, "Ending");
        log.Dispose();
        // Note: We do not end the response because we do not want to interfere with caching
      }

    }
    #endregion
    #endregion
    
    }     
  }


