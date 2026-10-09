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
   * StoredFileViewOrDownloadHandler */
  /**
   * Custom handler for displaying, delivering, and downloading static files
   * referenced by a db record id and stored on a local or network volume 
   *
   * Requires: MediaFileCommon.cs, MediaFileInfo.cs
   * 
   ***************************************************************************/  

  public class StoredFileViewOrDownloadHandler : IHttpHandler
  {

    /*-------------------------------
     * Database connection, request
     * response, and logging objects
     * Used by call method for
     * invoking framework methods
     *------------------------------*/

    protected   SqlConnection          dbConnUser;  // Connection to user database
    protected   SqlConnection          dbConnApp;   // Connection to application database
    protected   DetailsLog             log;         // Our logging object
    protected   RequestResponse        rd;          // Request/response data
    protected   UserInfo               uInfo;       // User info
    protected   ReturnStoredFileRecord rsfr;        // Object that contains all of the info we need for file
    
    protected   string[]               _permittedRoles;
    protected   MethodCallback         _cbRetrieveFileTargetFromDB;
    public      string                 _storedFileRecordID;
    public      int                    _deliveryMode;
    
    public      bool             IsReusable      { get { return false; } }               

    
    public StoredFileViewOrDownloadHandler()
    {
        
    }
    
    /***************************************************************************
     * GenerateURL */
    /**
     * Wrapper for calling framework methods to generate ReturnDataTable
     * 
     * @param  cb              Method callback (use delegate) 
     * @param  permittedRoles  If this method should be private
     *                         supply all authorized roles
     * @return                 Object containing rt (need to cast)
     ***************************************************************************/

    public static string GenerateURL (  string endpoint
                                      , EAW.MediaFile.DistributionModes modeval
                                      , string fileidval)
    { 
      return GenerateURL( endpoint
                         ,EAW.MediaFile.MediaFileCommon.PARAM_MODE
                         ,modeval
                         ,EAW.MediaFile.MediaFileCommon.PARAM_FILE_ID
                         ,fileidval);
    }                                       
    
    public static string GenerateURL (  string endpoint
                                      , string modeparm
                                      , EAW.MediaFile.DistributionModes modeval
                                      , string fileidparm
                                      , string fileidval)
    {
      int mdeval = (int) modeval;
      return MBA.HttpApplication.createLink(endpoint,true,new NameValue(modeparm,mdeval.ToString()),new NameValue(fileidparm,fileidval));
    }
    

    /***************************************************************************
     * callMethod */
    /**
     * Wrapper for calling framework methods to generate ReturnDataTable
     * 
     * @param  cb              Method callback (use delegate) 
     * @param  permittedRoles  If this method should be private
     *                         supply all authorized roles
     * @return                 Object containing rt (need to cast)
     ***************************************************************************/
           
     protected Object callMethodRetrieveFileTargetFromDB (MethodCallback cb, params string[] permittedRoles)
     {      
       return HttpApplication.callMethod(   ref this.dbConnUser
                                          , ref this.dbConnApp
                                          , ref this.log
                                          , ref this.rd
                                          , ref this.uInfo
                                          , typeof(ReturnStoredFileRecord)
                                          , cb
                                          , true
                                          , permittedRoles);
     }   

    /***************************************************************************
     * RetrieveMode */
    /**
     * Retrieve the mode that this handler will be used in and stores in globals
     * If there are any issues exceptons are thrown
     ***************************************************************************/    

    protected void RetrieveDeliveryMode (   ref HttpContext context
                                          , string          modeparm
                                          , out int         modeval )
    {
      string modestr = context.Request[modeparm];
	    if (String.IsNullOrEmpty(modestr))       throw new HttpException(400, "Delivery mode required");
      if (!int.TryParse(modestr, out modeval)) throw new HttpException(400, "Invalid delivery mode");
    }

    /***************************************************************************
     * RetrieveFileID */
    /**
     * Retrieve the unique id that represents the file
     * If there are any issues an exception is thrown
     ***************************************************************************/    

    protected void RetrieveFileRecordID (  ref HttpContext context
                                         , string          fileidparm
                                         , out string      fileidval)
    {
      string fileidstr = context.Request [fileidparm];
      if (String.IsNullOrEmpty(fileidstr)) throw new HttpException(400, "File id required");
    	fileidval = fileidstr.Trim();
    	if (String.IsNullOrEmpty(fileidval)) throw new HttpException(400, "Invalid file id");
    }
        
    /***************************************************************************
     * RetrieveFileRecord */
    /**
     * Retrieve the unique id that represents the file
     * If there are any issues an exception is thrown
     ***************************************************************************/    

    protected void RetrieveFileRecord (    string fileRecordID
                                         , out    ReturnStoredFileRecord rsfrout)
    {
      rsfrout = (ReturnStoredFileRecord) callMethodRetrieveFileTargetFromDB (  _cbRetrieveFileTargetFromDB
                                                                             , _permittedRoles);
      
      if (!rsfrout.storedFileRecordFound) throw new HttpException(404, "File not found in system");
      rsfrout.storedFileRecordID = fileRecordID;
    }
    
    /***************************************************************************
     * GenerateTargetLocation */
    /**
     * Generates full locatation of target
     * 
     * @param  rsfr    Current ReturnStoredFileRecord object
     ***************************************************************************/  

    protected void GenerateTargetLocation (ref ReturnStoredFileRecord rsfr)
    {
      rsfr.storedFileTargetLocation = rsfr.storedFileRecord.fileRoot + rsfr.storedFileRecord.filePath + rsfr.storedFileRecord.fileName;      
      rsfr.storedFileTargetFound = false;
      rsfr.storedFileTargetFound = System.IO.File.Exists(rsfr.storedFileTargetLocation);
      
      if (!rsfr.storedFileTargetFound) throw new HttpException (404, "File not found in folder");      
    }
    
    /***************************************************************************
     * RetrieveTargetInfo */
    /**
     * Retrieves meta data about target
     * 
     * @param  rsfr    Current ReturnStoredFileRecord object
     ***************************************************************************/  
    
    protected void RetrieveTargetInfo (ref ReturnStoredFileRecord rsfr)
    {      
      rsfr.storedFileTarget = new StoredFileTarget();
      rsfr.storedFileTarget.id               = rsfr.storedFileRecord.fileId;
      rsfr.storedFileTarget.fullPathFileName = rsfr.storedFileTargetLocation;
      rsfr.storedFileTarget.mfi = new MediaFileInfo(rsfr.storedFileTargetLocation);      
    }
    
    
    
    protected void GenerateURLS (   ref HttpContext context
                                  , ref ReturnStoredFileRecord rsfr)
    {
      /*============================================================
       * Get end point
       *============================================================*/
        
      rsfr.endPoint = System.IO.Path.GetFileName(context.Request.PhysicalPath);    
      
      /*============================================================
       * Generate delivery URL
       *============================================================*/

      rsfr.deliverURL  = GenerateURL (  rsfr.endPoint
                                       , EAW.MediaFile.MediaFileCommon.PARAM_MODE
                                       , EAW.MediaFile.DistributionModes.DELIVER
                                       , EAW.MediaFile.MediaFileCommon.PARAM_FILE_ID
                                       ,rsfr.storedFileRecordID );

      /*============================================================
       * Generate download URL
       *============================================================*/

      rsfr.downloadURL = GenerateURL (  rsfr.endPoint
                                      , EAW.MediaFile.MediaFileCommon.PARAM_MODE
                                      , EAW.MediaFile.DistributionModes.DOWNLOAD
                                      , EAW.MediaFile.MediaFileCommon.PARAM_FILE_ID
                                      , rsfr.storedFileRecordID );

               
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

    private void FullDownload (ref HttpContext context, ref ReturnStoredFileRecord rsfr, bool inline)
    {
      
      MediaFileInfo _mfi      = rsfr.storedFileTarget.mfi;
      string        _fullpath = rsfr.storedFileTargetLocation;
      
      context.Response.ContentType = _mfi.mimetype;

      /*============================================================
       * Create a filename we hope will work across all browsers
       *============================================================*/
      
      // Note: See http://stackoverflow.com/questions/93551/how-to-encode-the-filename-parameter-of-content-disposition-header-in-http

	    string _fn = rsfr.storedFileRecord.label + _mfi.fi.Extension.ToLower();

      /*============================================================
       * We want to force a download
       *============================================================*/

      if (!inline)
      {           
		    context.Response.AddHeader("content-disposition", "attachment;filename=" + _fn);
		    context.Response.SetCookie(HttpApplication.createFileDownloadCookie()); // Required for filedownload plugin 
      } 

      /*============================================================
       * This file will be part of the page
       *============================================================*/

      else
      {
        context.Response.AddHeader("content-disposition", "inline;filename="      + _fn);        
	    }

      bool _compressed = false;

      if (_mfi.mediatype == MediaType.TEXT)
      {
        if (Util.IsGZipSupported(ref context)) 
        {
          Util.GZipEncodeResponse(ref context);
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
		
    private void RangeDownload (ref HttpContext context, ref ReturnStoredFileRecord rsfr)
    {
      MediaFileInfo _mfi      = rsfr.storedFileTarget.mfi;
      string        _fullpath = rsfr.storedFileTargetLocation;

	
        context.Response.ContentType = _mfi.mimetype;

        
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
    
    private void DeliverFile (ref HttpContext context, ref ReturnStoredFileRecord rsfr)
    {
             
      MediaFileInfo _mfi      = rsfr.storedFileTarget.mfi;
      string        _fullpath = rsfr.storedFileTargetLocation;

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
        RangeDownload (ref context, ref rsfr);  // request for chunk
      }

      /*============================================================
       * Otherwise send entire file
       *============================================================*/

      else
      {
        FullDownload (ref context, ref rsfr, true);
      }   

    }

    /***************************************************************************
     * DownloadFile */
    /**
     * Forces download of file
     ***************************************************************************/   	

    private void DownloadFile (ref HttpContext context, ref ReturnStoredFileRecord rsfr)
    {
      FullDownload (ref context, ref rsfr, false);         
    }	
    
    /*###########################################################################
      #
      # Display Methods
      #
      ###########################################################################*/

   protected void DisplayUpgradeMessage (ref HttpContext context, ref ReturnStoredFileRecord rsfr, ref StringBuilder sb, ref string urlDownload)
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

    protected void DisplayAudio (ref HttpContext context, ref ReturnStoredFileRecord rsfr, string urlDeliver, string urlDownload, ref StringBuilder sb)
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
      sb.Append (rsfr.storedFileRecord.label);
      sb.Append (@"</li>");
      sb.Append (@"</ul>");
      sb.Append (@"</div>"); // title

      sb.Append (@"<div class=""jp-no-solution"">");

      DisplayUpgradeMessage(ref context, ref rsfr, ref sb, ref urlDownload);

      sb.Append (@"</div>"); // no solution

      sb.Append (@"</div>"); // single
      sb.Append (@"</div>"); // container

    }

    /***************************************************************************
     * DisplayVideo */
    /**
     * Displays video player
     ***************************************************************************/   

    protected void DisplayVideo (ref HttpContext context, ref ReturnStoredFileRecord rsfr, string urlDeliver, string urlDownload, ref StringBuilder sb)
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
      sb.Append (rsfr.storedFileRecord.label);
      sb.Append (@"</li>");
      sb.Append (@"</ul>");
      sb.Append (@"</div>"); // Title

      sb.Append (@"</div>"); // Interface
      sb.Append (@"</div>"); // Gui

      // No Solution

      sb.Append (@"<div class=""jp-no-solution"">");

      DisplayUpgradeMessage (ref context,
                             ref rsfr, 
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
    
    protected void DisplayImage (ref HttpContext context, ref ReturnStoredFileRecord rsfr, string urlDeliver, string urlDownload, ref StringBuilder sb)
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
                      , rsfr.storedFileTarget.mfi.width
                      , rsfr.storedFileTarget.mfi.height);
      sb.Append       (@"</img>");
      sb.Append       (@"</div>");
	}
     		
    /***************************************************************************
     * DisplayObject */
    /**
     * Displays application file
     ***************************************************************************/   

    protected void DisplayObject (ref HttpContext context, ref ReturnStoredFileRecord rsfr, string urlDeliver, string urlDownload, ref StringBuilder sb)
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
                       , rsfr.storedFileTarget.mfi.mimetype);

      DisplayUpgradeMessage (ref context,
                             ref rsfr, 
                             ref sb, 
                             ref urlDownload);

      sb.Append (@"</object>");
      sb.Append (@"</div>");
      
    }
    
    /**************************************************************************
     * DisplayFile */
    /**
     * Displays the file
     ***************************************************************************/  
    
    protected void DisplayFile (ref HttpContext context, ref ReturnStoredFileRecord rsfr)
    {
      
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
      sb.Append (rsfr.storedFileRecord.label);
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
                       , rsfr.storedFileRecord.label);
        
      sb.Append (@"</div>");            

      /*============================================================
       * Build content
       *============================================================*/

      sb.AppendFormat (@"<div id=""{0}"" class=""{1}"">"
                       , MediaFileCommon.ID_DISP_CONTENT
                       , MediaFileCommon.CSS_DISP_CONTENT);

      
      /*============================================================
       * Create urls we will need
       *============================================================*/  
      
      string urlDeliver  = rsfr.deliverURL;
      string urlDownload = rsfr.downloadURL;
        
      /*============================================================
       * If the file should be displayable in browser do it
       *============================================================*/
        
      if (rsfr.storedFileTarget.mfi.fileSupported)

      {        
          
        /*===========================================================
         * Depending on our type of media we use different methods
         * to display the content
         *============================================================*/ 
         
        if (rsfr.storedFileTarget.mfi.mediatype == MediaType.IMAGE)       DisplayImage  (ref context, ref rsfr, urlDeliver, urlDownload, ref sb);
        if (rsfr.storedFileTarget.mfi.mediatype == MediaType.APPLICATION) DisplayObject (ref context, ref rsfr, urlDeliver, urlDownload, ref sb);
        if (rsfr.storedFileTarget.mfi.mediatype == MediaType.AUDIO)       DisplayAudio  (ref context, ref rsfr, urlDeliver, urlDownload, ref sb);
		    if (rsfr.storedFileTarget.mfi.mediatype == MediaType.VIDEO)       DisplayVideo  (ref context, ref rsfr, urlDeliver, urlDownload, ref sb);
        if (rsfr.storedFileTarget.mfi.mediatype == MediaType.TEXT)        DisplayObject (ref context, ref rsfr, urlDeliver, urlDownload, ref sb);

        /*============================================================
         * Meta data
         *============================================================*/ 

        sb.AppendFormat (@"<div id=""{0}"" class=""{1}"">"
                        , EAW.MediaFile.MediaFileCommon.ID_DISP_META_CONTAINER
                        , EAW.MediaFile.MediaFileCommon.CSS_DISP_CONTENT_META);
                    
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
                       , EAW.MediaFile.MediaFileCommon.ID_DISP_FOOTER
                       , EAW.MediaFile.MediaFileCommon.CSS_DISP_FOOTER);

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

      if (Util.IsGZipSupported(ref context)) 
        Util.GZipEncodeResponse(ref context);      
     
      /*============================================================
       * Add our response type
       *============================================================*/

      context.Response.ContentType = @"text/html";            

      /*============================================================
       * If we could not compress the response, add the length hdr
       *============================================================*/

      if (!Util.IsGZipSupported(ref context))
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
   
    protected void ErrorResponse (ref HttpContext context, string message)
    {
      context.Response.Clear();
      context.Response.ContentType = "text/html";
      context.Response.Charset     = "utf-8";
      context.Response.Write(@"<!doctype html>");
      context.Response.Write(@"<html>");
      context.Response.Write(@"<head>");
      context.Response.Write(@"<title>");
      context.Response.Write(message);
      context.Response.Write(@"</title>");
      context.Response.Write(@"</head>");
      context.Response.Write(@"<body>");
      context.Response.Write(@"<h1>");
      context.Response.Write(@"Something Is Wrong With Our System");
      context.Response.Write(@"</h1>");
      context.Response.Write(@"<hr/>");

      context.Response.Write(@"<h2>");
      context.Response.Write(@"Problem");
      context.Response.Write(@"</h2>");        
      context.Response.Write(@"<p>");
      context.Response.Write("We are sorry, the following unexpected problem has occurred with our system and we could not complete your request at this time.");
      context.Response.Write(@"</p>");
      context.Response.Write(@"<h3>");
      context.Response.Write(message);
      context.Response.Write(@"</h3>");
      context.Response.Write(@"<hr/>");
        
      context.Response.Write(@"<h2>");
      context.Response.Write(@"Solution");
      context.Response.Write(@"</h2>");        
        
      context.Response.Write(@"<ul>");
      context.Response.Write("<li>Our IT department has been notified and they will do their best to solve the problem on our end</li>");
      context.Response.Write("<li>Please close your browser and try again in a few minutes</li>");
      context.Response.Write("<li>If this problem persists please contact us</li>");
      context.Response.Write(@"</ul>");
      context.Response.Write(@"<hr/>");

      context.Response.Write(@"<p>" + Constants.APP_CONTACT.name + @" | " + Constants.APP_CONTACT.mail + @" | <a href=""mailto:" + Constants.APP_CONTACT.email + @""" title=""Email us!"">" + Constants.APP_CONTACT.email + @"</a></p>");

      context.Response.Write(@"</body>");
      context.Response.Write(@"</html>");      
      context.Response.End();
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
      try
      {
        
        rsfr = new ReturnStoredFileRecord();
       
        RetrieveDeliveryMode   (ref context, MediaFileCommon.PARAM_MODE,    out _deliveryMode);        
        RetrieveFileRecordID   (ref context, MediaFileCommon.PARAM_FILE_ID, out _storedFileRecordID);
        RetrieveFileRecord     (_storedFileRecordID, out rsfr);
        GenerateTargetLocation (ref rsfr);
        RetrieveTargetInfo     (ref rsfr);
        GenerateURLS           (ref context, ref rsfr);
                
        if      (_deliveryMode == (int) DistributionModes.DELIVER)  DeliverFile  (ref context, ref rsfr);      
        else if (_deliveryMode == (int) DistributionModes.DISPLAY)  DisplayFile  (ref context, ref rsfr);
        else if (_deliveryMode == (int) DistributionModes.DOWNLOAD) DownloadFile (ref context, ref rsfr);
      }      
      catch (HttpException e)
      {
        ErrorResponse(ref context,e.Message);
      }

      catch (Exception e)
      {        
        ErrorResponse(ref context,e.Message);
      }
      
    }
    
  }     
}


