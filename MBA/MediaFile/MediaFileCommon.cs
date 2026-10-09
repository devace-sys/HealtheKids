using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Configuration;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Security.Cryptography;
using System.Web;
using System.Web.UI;
using System.ComponentModel;
using TagLib;
using TagLib.Image;

namespace EAW.MediaFile
{
  #region CommonEnums

  /***************************************************************************
   * MediaType */
  /**
   * General media types based on common mime types
   ***************************************************************************/	
  
  public enum MediaType
  {
    UNSUPPORTED   = 0,
    AUDIO         = 1,    /* Audio files like music or voice recordings*/
    VIDEO         = 2,    /* Video or animated files*/
    IMAGE         = 3,    /* Image files like photos or drawings */
    APPLICATION   = 4,    /* Binary files and specific applications */
    TEXT          = 5,    /* Text files that can handle several character sets in several languages */
    LINK          = 6     /* Link to file */
    
  }

  /***************************************************************************
   * MediaSubType */
  /**
   * General media sub types based on common mime types
   ***************************************************************************/	

  public enum MediaSubType
  {
    UNSUPPORTED   = 0,
    MP3           = 1,
    MP4           = 2,
    PNG           = 3,
    JPG           = 4,
    GIF           = 5,
    PDF           = 6,
    TXT           = 7,
    HTM           = 8
  }


  /***************************************************************************
   * MediaClass */
  /**
   * General media class based on common mime types
   ***************************************************************************/	

  public enum MediaClass
  {
    UNSUPPORTED   = 0,
    AUDIO         = 1,
    VIDEO         = 2,
    IMAGE         = 3,
    DOCUMENT      = 4,
    INTERACTIVE   = 5,
    TEXT          = 6,
    LINK          = 7
  }

  /***************************************************************************
   * TagType */
  /**
   * Indicates what the tag is about
   ***************************************************************************/

  public enum TagType
  {
    META                = 0,
    FILE_CLASS          = 1,
    FILE_TYPE           = 2,
    CONTENT_DIMENSION   = 3,
    RECORDING_DEVICE    = 4,
    RECORDING_DATE_TIME = 5,
    RECORDING_LOCATION  = 6,
    RECORDING_TITLE     = 7,
    RECORDING_AUTHOR    = 8
  }

  /***************************************************************************
   * DistributionModes */
  /**
   * Modes for the handler
   ***************************************************************************/	

    public enum DistributionModes
    {
      UNKNOWN      = 0,
      DISPLAY      = 1,
      DELIVER      = 2,
      DOWNLOAD     = 3
    } 

  #endregion

  /***************************************************************************
   * MediaFileCommon */
  /**
   * Common constants and utility methods
   * 
   ***************************************************************************/
  
  public sealed class MediaFileCommon
  {
    #region Constants
	
    /*###########################################################################
      #
      # Constants
      #
      ###########################################################################*/		
  
    
    /***************************************************************************
     * MEDIA_FILE_PATH */
    /**
     * Media file path
     * Note: Path must end with a /
     ***************************************************************************/	

    public static string MEDIA_FILE_PATH           = GetAppSetting(@"MediaFilePath");

    /***************************************************************************
     * MEDIA_SERVICE_LOG_PATH */
    /**
     * Log file path
     * Note: Path must end with a /
     ***************************************************************************/	

    public static string MEDIA_SERVICE_LOG_PATH    = GetAppSetting (@"MediaServiceLogPath");
    public static string MEDIA_SERVICE_LOG_NAME    = GetAppSetting (@"MediaServiceLogName", @"mediafile");

    /***************************************************************************
     * MEDIA_FILE_HANDLER */
    /**
     * Media file handler
     ***************************************************************************/	

    public static string MEDIA_FILE_HANDLER        = GetAppSetting (@"MediaFileHandler",    @"mediafile.ashx");

    /***************************************************************************
     * FILE_ */
    /**
     * Path to files
     ***************************************************************************/	

    public static string FILE_JS          = @"js/";
    //public static string FILE_JS_JQUERY   = @"js/jquery-1.10.2.min.js";
    public static string FILE_JS_JQUERY   = @"js/jquery-1.8.0.min.js";
    public static string FILE_JS_JPLAYER  = @"js/jquery.jplayer.min.js";
    public static string FILE_JS_MF       = @"js/media-file.js";
    
    public static string FILE_CSS         = @"css/";
    public static string FILE_CSS_JPLAYER = @"css/media-file/skin/jplayer.blue.monday.css";
    public static string FILE_CSS_MF      = @"css/media-file/media-file.css";

    public static TimeSpan CACHE_DURATION = new TimeSpan(30,0,0,0);

    /***************************************************************************
     * PARAM_* */
    /**
     * Request parameters
     ***************************************************************************/	

    public static string PARAM_MODE       = "mf-mde";
    public static string PARAM_FILE_NAME  = "mf-fnm";
    public static string PARAM_FILE_TS    = "mf-ts";
    public static string PARAM_FILE_ID    = "mf-fid";
    
    /***************************************************************************
     * ID_* */
    /**
     * Various element ids
     ***************************************************************************/	

    public static string ID_DISP_CONTAINER            = @"mf-disp-container";
    public static string ID_DISP_TOP                  = @"mf-disp-top";
    public static string ID_DISP_CONTENT              = @"mf-disp-content";
    public static string ID_DISP_FOOTER               = @"mf-disp-footer";
    
    public static string ID_DISP_FILE_CONTAINER       = @"mf-disp-file-container";
    public static string ID_DISP_FILE_CONTAINER_W_SEL = @"#" + ID_DISP_FILE_CONTAINER;
    public static string ID_DISP_FILE                 = @"mf-file";
    public static string ID_DISP_FILE_W_SEL           = @"#" + ID_DISP_FILE;    
    public static string ID_DISP_FILE_PLAYER          = @"mf-file-player";
    public static string ID_DISP_FILE_PLAYER_W_SEL    = @"#" + ID_DISP_FILE_PLAYER;
    public static string ID_DISP_META_CONTAINER       = @"mf-file-meta-container";

    /***************************************************************************
     * CSS_* */
    /**
     * Various CSS classes
     ***************************************************************************/	

    public static string CSS_LINK               = @"mf-link";
    public static string CSS_LABEL              = @"mf-label";
    public static string CSS_ERROR              = @"mf-error";
    public static string CSS_TAGS               = @"mf-tags";
    public static string CSS_TAG                = @"mf-tag";
    public static string CSS_TAG_NAME           = @"mf-tag-name";
    public static string CSS_TAG_VALUE          = @"mf-tag-value";

    public static string CSS_ICON               = @"mf-icon";
    public static string ICON_AUDIO             = @"mf-icon-audio";
    public static string ICON_VIDEO             = @"mf-icon-video";
	public static string ICON_APPLICATION       = @"mf-icon-application";
	public static string ICON_IMAGE             = @"mf-icon-image";
	public static string ICON_TEXT              = @"mf-icon-text";
    public static string ICON_FOLDER            = @"mf-icon-folder";
	public static string ICON_UNSUPPORTED       = @"mf-icon-unsupported";
    public static string CSS_META_DATA          = @"mf-meta";
    public static string CSS_MESSAGE            = @"mf-message";
    public static string CSS_CTRL_CONTAINER     = @"mf-control-container";
    public static string CSS_FOLDER_CONTAINER   = @"mf-folder-container";
    public static string CSS_DISP_CONTAINER     = @"mf-display-container";
    public static string CSS_FOLDER_HEADER      = @"mf-folder-header";
    public static string CSS_DISP_HEADER        = @"mf-display-header";
    public static string CSS_DISP_FOOTER        = @"mf-display-footer";
    public static string CSS_FOLDER_CONTENT     = @"mf-folder-content";
    public static string CSS_DISP_CONTENT       = @"mf-display-content";
    public static string CSS_DISP_CONTENT_FILE  = @"mf-display-content-file";
    public static string CSS_DISP_CONTENT_META  = @"mf-display-content-meta";
    public static string CSS_SELECTIONS         = @"mf-selections";
    public static string CSS_SELECTION          = @"mf-selection";
    public static string CSS_VIDEO              = @"mf-video";
    public static string CSS_AUDIO              = @"mf-audio";
    public static string CSS_IMAGE_CONTAINER    = @"mf-image-container";
    public static string CSS_IMAGE              = @"mf-image";
    public static string CSS_OBJECT_CONTAINER   = @"mf-object-container";
    public static string CSS_OBJECT             = @"mf-object";
    public static string CSS_UPGRADE_REQUIRED   = @"mf-upgrade-required";

    /***************************************************************************
     * URL_* */
    /**
     * Various urls
     ***************************************************************************/	    

    public static string URL_FLASH_PLAYER       = @"http://get.adobe.com/flashplayer/";
    public static string URL_PDF_READER         = @"http://get.adobe.com/reader/";
    public static string URL_WHAT_BROWSER       = @"http://whatbrowser.org/";
    public static string URL_GMAP_PTRN          = @"http://maps.google.com/maps?z={0}&t={1}&q=loc:{2}+{3}";
    public static string URL_OSM_PTRN           = @"http://www.openstreetmap.org/#map=[{0}]/[{1}]/[{2}]";
 
    /***************************************************************************
     * MimeTypesDictionary */
    /**
     * Dictionary of common mime types
     * Initial version courtesy of stimms
     * http://stackoverflow.com/a/7161265
     ***************************************************************************/	
    
    public static string UNKNOWN_MIME_TYPE        = @"unknown/unknown";
    public static string UNSPECIFIED_CONTENT_TYPE = @"application/octet-stream";
    
    public static readonly Dictionary <string, string> MIMETypesDictionary = new Dictionary <string, string>
    {
      {"ai", "application/postscript"},
      {"aif", "audio/x-aiff"},
      {"aifc", "audio/x-aiff"},
      {"aiff", "audio/x-aiff"},
      {"asc", "text/plain"},
      {"atom", "application/atom+xml"},
      {"au", "audio/basic"},
      {"avi", "video/x-msvideo"},
      {"bcpio", "application/x-bcpio"},
      {"bin", "application/octet-stream"},
      {"bmp", "image/bmp"},
      {"cdf", "application/x-netcdf"},
      {"cgm", "image/cgm"},
      {"class", "application/octet-stream"},
      {"cpio", "application/x-cpio"},
      {"cpt", "application/mac-compactpro"},
      {"csh", "application/x-csh"},
      {"css", "text/css"},
      {"csv", "text/csv"},
      {"dcr", "application/x-director"},
      {"dif", "video/x-dv"},
      {"dir", "application/x-director"},
      {"djv", "image/vnd.djvu"},
      {"djvu", "image/vnd.djvu"},
      {"dll", "application/octet-stream"},
      {"dmg", "application/octet-stream"},
      {"dms", "application/octet-stream"},
      {"doc", "application/msword"},
      {"docx","application/vnd.openxmlformats-officedocument.wordprocessingml.document"},
      {"dotx", "application/vnd.openxmlformats-officedocument.wordprocessingml.template"},
      {"docm","application/vnd.ms-word.document.macroEnabled.12"},
      {"dotm","application/vnd.ms-word.template.macroEnabled.12"},
      {"dtd", "application/xml-dtd"},
      {"dv", "video/x-dv"},
      {"dvi", "application/x-dvi"},
      {"dxr", "application/x-director"},
      {"eps", "application/postscript"},
      {"etx", "text/x-setext"},
      {"exe", "application/octet-stream"},
      {"ez", "application/andrew-inset"},
      {"gif", "image/gif"},
      {"gram", "application/srgs"},
      {"grxml", "application/srgs+xml"},
      {"gtar", "application/x-gtar"},
      {"hdf", "application/x-hdf"},
      {"hqx", "application/mac-binhex40"},
      {"htm", "text/html"},
      {"html", "text/html"},
      {"hlnk", "link/html"}, /* Unofficial internal extension, not a standard */
      {"ice", "x-conference/x-cooltalk"},
      {"ico", "image/x-icon"},
      {"ics", "text/calendar"},
      {"ief", "image/ief"},
      {"ifb", "text/calendar"},
      {"iges", "model/iges"},
      {"igs", "model/iges"},
      {"jnlp", "application/x-java-jnlp-file"},
      {"jp2", "image/jp2"},
      {"jpe", "image/jpeg"},
      {"jpeg", "image/jpeg"},
      {"jpg", "image/jpeg"},
      {"js", "application/x-javascript"},
      {"kar", "audio/midi"},
      {"latex", "application/x-latex"},
      {"lha", "application/octet-stream"},
      {"lzh", "application/octet-stream"},
      {"m3u", "audio/x-mpegurl"},
      {"m4a", "audio/mp4a-latm"},
      {"m4b", "audio/mp4a-latm"},
      {"m4p", "audio/mp4a-latm"},
      {"m4u", "video/vnd.mpegurl"},
      {"m4v", "video/x-m4v"},
      {"mac", "image/x-macpaint"},
      {"man", "application/x-troff-man"},
      {"mathml", "application/mathml+xml"},
      {"me", "application/x-troff-me"},
      {"mesh", "model/mesh"},
      {"mid", "audio/midi"},
      {"midi", "audio/midi"},
      {"mif", "application/vnd.mif"},
      {"mov", "video/quicktime"},
      {"movie", "video/x-sgi-movie"},
      {"mp2", "audio/mpeg"},
      {"mp3", "audio/mpeg"},
      {"mp4", "video/mp4"},
      {"mpe", "video/mpeg"},
      {"mpeg", "video/mpeg"},
      {"mpg", "video/mpeg"},
      {"mpga", "audio/mpeg"},
      {"ms", "application/x-troff-ms"},
      {"msh", "model/mesh"},
      {"mxu", "video/vnd.mpegurl"},
      {"nc", "application/x-netcdf"},
      {"oda", "application/oda"},
      {"ogg", "application/ogg"},
      {"pbm", "image/x-portable-bitmap"},
      {"pct", "image/pict"},
      {"pdb", "chemical/x-pdb"},
      {"pdf", "application/pdf"},
      {"pgm", "image/x-portable-graymap"},
      {"pgn", "application/x-chess-pgn"},
      {"pic", "image/pict"},
      {"pict", "image/pict"},
      {"png", "image/png"},
      {"pnm", "image/x-portable-anymap"},
      {"pnt", "image/x-macpaint"},
      {"pntg", "image/x-macpaint"},
      {"ppm", "image/x-portable-pixmap"},
      {"ppt", "application/vnd.ms-powerpoint"},
      {"pptx","application/vnd.openxmlformats-officedocument.presentationml.presentation"},
      {"potx","application/vnd.openxmlformats-officedocument.presentationml.template"},
      {"ppsx","application/vnd.openxmlformats-officedocument.presentationml.slideshow"},
      {"ppam","application/vnd.ms-powerpoint.addin.macroEnabled.12"},
      {"pptm","application/vnd.ms-powerpoint.presentation.macroEnabled.12"},
      {"potm","application/vnd.ms-powerpoint.template.macroEnabled.12"},
      {"ppsm","application/vnd.ms-powerpoint.slideshow.macroEnabled.12"},
      {"ps", "application/postscript"},
      {"qt", "video/quicktime"},
      {"qti", "image/x-quicktime"},
      {"qtif", "image/x-quicktime"},
      {"ra", "audio/x-pn-realaudio"},
      {"ram", "audio/x-pn-realaudio"},
      {"ras", "image/x-cmu-raster"},
      {"rdf", "application/rdf+xml"},
      {"rgb", "image/x-rgb"},
      {"rm", "application/vnd.rn-realmedia"},
      {"roff", "application/x-troff"},
      {"rtf", "text/rtf"},
      {"rtx", "text/richtext"},
      {"sgm", "text/sgml"},
      {"sgml", "text/sgml"},
      {"sh", "application/x-sh"},
      {"shar", "application/x-shar"},
      {"silo", "model/mesh"},
      {"sit", "application/x-stuffit"},
      {"skd", "application/x-koan"},
      {"skm", "application/x-koan"},
      {"skp", "application/x-koan"},
      {"skt", "application/x-koan"},
      {"smi", "application/smil"},
      {"smil", "application/smil"},
      {"snd", "audio/basic"},
      {"so", "application/octet-stream"},
      {"spl", "application/x-futuresplash"},
      {"src", "application/x-wais-source"},
      {"sv4cpio", "application/x-sv4cpio"},
      {"sv4crc", "application/x-sv4crc"},
      {"svg", "image/svg+xml"},
      {"swf", "application/x-shockwave-flash"},
      {"t", "application/x-troff"},
      {"tar", "application/x-tar"},
      {"tcl", "application/x-tcl"},
      {"tex", "application/x-tex"},
      {"texi", "application/x-texinfo"},
      {"texinfo", "application/x-texinfo"},
      {"tif", "image/tiff"},
      {"tiff", "image/tiff"},
      {"tr", "application/x-troff"},
      {"tsv", "text/tab-separated-values"},
      {"txt", "text/plain"},
      {"ustar", "application/x-ustar"},
      {"vcd", "application/x-cdlink"},
      {"vrml", "model/vrml"},
      {"vxml", "application/voicexml+xml"},
      {"wav", "audio/x-wav"},
      {"wbmp", "image/vnd.wap.wbmp"},
      {"wbmxl", "application/vnd.wap.wbxml"},
      {"wml", "text/vnd.wap.wml"},
      {"wmlc", "application/vnd.wap.wmlc"},
      {"wmls", "text/vnd.wap.wmlscript"},
      {"wmlsc", "application/vnd.wap.wmlscriptc"},
      {"wrl", "model/vrml"},
      {"xbm", "image/x-xbitmap"},
      {"xht", "application/xhtml+xml"},
      {"xhtml", "application/xhtml+xml"},
      {"xls", "application/vnd.ms-excel"},
      {"xml", "application/xml"},
      {"xpm", "image/x-xpixmap"},
      {"xsl", "application/xml"},
      {"xlsx","application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"},
      {"xltx","application/vnd.openxmlformats-officedocument.spreadsheetml.template"},
      {"xlsm","application/vnd.ms-excel.sheet.macroEnabled.12"},
      {"xltm","application/vnd.ms-excel.template.macroEnabled.12"},
      {"xlam","application/vnd.ms-excel.addin.macroEnabled.12"},
      {"xlsb","application/vnd.ms-excel.sheet.binary.macroEnabled.12"},
      {"xslt", "application/xslt+xml"},
      {"xul", "application/vnd.mozilla.xul+xml"},
      {"xwd", "image/x-xwindowdump"},
      {"xyz", "chemical/x-xyz"},
      {"zip", "application/zip"}
    };

    #endregion
    
 /***************************************************************************
    * GetMimeTypeFromFileName */
   /**
    * Gets mime type from filename
    ***************************************************************************/	

    public static string GetMIMETypeFromFilename(string fileName)
    {
      if (String.IsNullOrEmpty(fileName)) return UNKNOWN_MIME_TYPE;
      fileName = fileName.Trim().ToLower();
      if (String.IsNullOrEmpty(fileName)) return UNKNOWN_MIME_TYPE;      
      string extension = Path.GetExtension(fileName).Remove(0,1);
      return GetMimeTypeFromExtension(extension);
    }

   /***************************************************************************
    * GetMimeTypeFromExtension */
   /**
    * Gets mime type from extension
    ***************************************************************************/	
		
	public static string GetMimeTypeFromExtension (string extension)
	{
	  if (String.IsNullOrEmpty(extension))            return UNKNOWN_MIME_TYPE;
      extension = extension.Trim().ToLower();
	  if (String.IsNullOrEmpty(extension))            return UNKNOWN_MIME_TYPE;
      if (MIMETypesDictionary.ContainsKey(extension)) return MIMETypesDictionary[extension];
	  return UNKNOWN_MIME_TYPE;
    }

    /***************************************************************************
     * GetFileExtension */
    /**
     * Returns the lowercase extension of path without the period
     *
     * @param    path    Full path of file
     * @return   String
     ***************************************************************************/

    public static string GetFileExtension (string file)
    {
      if (String.IsNullOrEmpty(file)) return null;
      string _ext = "";
      _ext = Path.GetExtension(file).Trim().ToLower();
      _ext = _ext.Remove(0,1);
      return _ext;
    }
		  
    /***************************************************************************
     * GetMediaTypeFromMime */
    /**
     * Returns a general media type from the mime
     *
     * @param    mimetype    Mime type
     * @return   MediaType
     ***************************************************************************/		

    public static MediaType GetMediaTypeFromMime (string mimetype)
    {
      if (String.IsNullOrEmpty(mimetype))      return MediaType.UNSUPPORTED;
      
      string _mimetype = mimetype.Trim().ToLower();
      
      if (String.IsNullOrEmpty(_mimetype))     return MediaType.UNSUPPORTED;

      if (_mimetype.StartsWith("audio"))       return MediaType.AUDIO;
      if (_mimetype.StartsWith("video"))       return MediaType.VIDEO;
      if (_mimetype.StartsWith("image"))       return MediaType.IMAGE;
      if (_mimetype.StartsWith("text"))        return MediaType.TEXT;
      if (_mimetype.StartsWith("application")) return MediaType.APPLICATION;
      if (_mimetype.StartsWith("link"))        return MediaType.LINK;

      return MediaType.UNSUPPORTED;
      
    }
		
    /***************************************************************************
     * GetMediaSubTypeFromMime */
    /**
     * Returns a general media sub type from the mime
     *
     * @param    mimetype    Mime type
     * @return   MediaSubType
     ***************************************************************************/		

    public static MediaSubType GetMediaSubTypeFromMime (string mimetype)
    {
      if (String.IsNullOrEmpty(mimetype)) return MediaSubType.UNSUPPORTED;
      
      mimetype = mimetype.Trim().ToLower();
      
      if (mimetype == @"video/mp4")       return MediaSubType.MP4; 
      if (mimetype == @"audio/mpeg")      return MediaSubType.MP3;
      if (mimetype == @"image/jpeg")      return MediaSubType.JPG;
      if (mimetype == @"image/gif")       return MediaSubType.GIF;
      if (mimetype == @"image/png")       return MediaSubType.PNG;
      if (mimetype == @"application/pdf") return MediaSubType.PDF;
      if (mimetype == @"text/plain")      return MediaSubType.TXT;
      if (mimetype == @"link/html")       return MediaSubType.HTM;
      if (mimetype == @"text/html")       return MediaSubType.HTM;
      
      return MediaSubType.UNSUPPORTED;
      
    }
    
    /***************************************************************************
     * GetMediaClassFromMime */
    /**
     * Returns a general media sub type from the mime
     *
     * @param    mimetype    Mime type
     * @return   MediaSubType
     ***************************************************************************/		

    public static MediaClass GetMediaClassFromMime (string mimetype)
    {
      if (String.IsNullOrEmpty(mimetype)) return MediaClass.UNSUPPORTED;
      
      mimetype = mimetype.Trim().ToLower();
      
      if (mimetype == @"video/mp4")       return MediaClass.VIDEO; 
      if (mimetype == @"audio/mpeg")      return MediaClass.AUDIO;
      if (mimetype == @"image/jpeg")      return MediaClass.IMAGE;
      if (mimetype == @"image/gif")       return MediaClass.IMAGE;
      if (mimetype == @"image/png")       return MediaClass.IMAGE;
      if (mimetype == @"application/pdf") return MediaClass.DOCUMENT;
      if (mimetype == @"text/plain")      return MediaClass.TEXT;
      if (mimetype == @"link/html")       return MediaClass.LINK;
      
      return MediaClass.UNSUPPORTED;
      
    }


    /***************************************************************************
     * IsMimeSupported */
    /**
     * Determines if the mime type is supported by our viewers or players
     *
     * @param    mimetype    Mime type 
     * @return   bool
     ***************************************************************************/		

    public static bool IsFileSupported (MediaType mediatype, MediaSubType mediasubtype)
    {

      if (mediatype    == MediaType.UNSUPPORTED)    return false;
      if (mediasubtype == MediaSubType.UNSUPPORTED) return false;
      return true;

    }

    /***************************************************************************
     * GetMediaIcon */
    /**
     * Returns a media icon class from mt
     *
     * @return   String
     ***************************************************************************/
		
	public static string GetMediaIcon (MediaClass mc)
	{
	  
      string _icon = "";
	  switch (mc)
	  {
	    case MediaClass.DOCUMENT    : {_icon = MediaFileCommon.ICON_APPLICATION; break;}
		case MediaClass.IMAGE       : {_icon = MediaFileCommon.ICON_IMAGE;       break;}
		case MediaClass.AUDIO       : {_icon = MediaFileCommon.ICON_AUDIO;       break;}
		case MediaClass.VIDEO       : {_icon = MediaFileCommon.ICON_VIDEO;       break;}
        case MediaClass.TEXT        : {_icon = MediaFileCommon.ICON_TEXT;        break;}
		case MediaClass.UNSUPPORTED : {_icon = MediaFileCommon.ICON_UNSUPPORTED; break;}
	  }
	  return _icon;
	}

    #region GenerateMethods

    /***************************************************************************
     * GenerateDurationString */
    /**
     * Returns a string value of a timespan
     *
     * @param    ts    Timespan
     * @return   String
     ***************************************************************************/

    public static string GenerateDurationString (TimeSpan? ts)
    {
      if (ts == null) return null;

      string hh  = ts.Value.Hours.ToString("D2");
      string mm  = ts.Value.Minutes.ToString("D2");
      string ss  = ts.Value.Seconds.ToString("D2");
      string dur = String.Format("{0}:{1}:{2}",hh,mm,ss);

      return dur;
    }

    /***************************************************************************
     * GenerateOpenMapURI */
    /**
     * Returns a open street map URI
     *
     * @param    lt         Latitude
     * @param    ln         Longitude
     * @param    zoomlevel  Zoom level (0-19)
     * @return   String
     ***************************************************************************/

		
    public static string GenerateOpenMapURI (double? lt, double? ln)
    {
      return GenerateOpenMapURI(lt,ln,null);
    }

    public static string GenerateOpenMapURI (double? lt, double? ln, int? zoomlevel)
    {
      // zoom level 0-19 

      if ((lt != null) && (ln != null))
      {
	    if (zoomlevel == null) zoomlevel = 10;
        
        string _url = String.Format (URL_OSM_PTRN
                      ,lt
                      ,ln
                      ,zoomlevel);
        return _url;
      }        
      return null;
    }

    /***************************************************************************
     * GenerateGoogleMapURI */
    /**
     * Returns a google map URI
     *
     * @param    lt         Latitude
     * @param    ln         Longitude
     * @param    zoomlevel  Zoom level (1-20)
     * @param    maptype    Map type
     * @return   String
     ***************************************************************************/

    public static string GenerateGoogleMapURI (double? lt, double? ln)
    {
      return GenerateGoogleMapURI(lt,ln, 20, "m");
    }

    public static string GenerateGoogleMapURI (double? lt, double? ln, int zoomlevel, string maptype)
    {
      /* http://stackoverflow.com/a/9919251 */

      /* z is the zoom level (1-20)
         t is the map type ("m" map, "k" satellite, "h" hybrid, "p" terrain, "e" GoogleEarth)
         q is the search query, if it is prefixed by loc: then google assumes it is a lat lon separated by a +
       */

      if ((lt != null) && (ln != null))
      {
        string zl  = zoomlevel.ToString();
        string mt  = maptype.ToLower().Trim();
        string lts = lt.ToString();
        string lns = ln.ToString();
        string uri = String.Format (URL_GMAP_PTRN
                                    ,zl
                                    ,mt
                                    ,lts
                                    ,lns);
        return uri;
      }
      return null;
    }
	
    /***************************************************************************
     * GenerateTag */
    /**
     * Returns tag HTML
     *
     * @param    tt     Tag type
     * @param    name   Name of the tag
     * @param    value  Various values
     *
     * @return   String
     ***************************************************************************/
	  
    public static string GenerateTag (TagType tt, string name, DateTime? val)
    {   
      if (!val.HasValue) return String.Empty;
      return GenerateTag (tt, name, val.Value.ToString());
    }

    public static string GenerateTag (TagType tt, string name, Double? val)
    {   
      if (!val.HasValue) return String.Empty;

      return GenerateTag (tt, name, val.Value.ToString());
    }

    public static string GenerateTag (TagType tt, string name, Int32? val)
    {   
      if (!val.HasValue) return String.Empty;
      return GenerateTag (tt, name, val.Value.ToString());
    }
	    	
    public static string GenerateTag (TagType tt, string name, TimeSpan? val)
    { 
      if (!val.HasValue) return String.Empty;
      return GenerateTag (tt, name, GenerateDurationString(val.Value));
    }

    public static string GenerateTag (TagType tt, string name, string val)
    { 

      if (String.IsNullOrEmpty(val)) return String.Empty;

      string _tagtype   = tt.ToString().ToLower();
      string _tagformat = @"<span class=""{0} {1}""><span class=""{2}"">{3}</span> <span class=""{4}"">{5}</span></span>";
      string _tag       = String.Format(_tagformat
                                        , CSS_TAG
                                        , _tagtype 
                                        , CSS_TAG_NAME 
                                        , name
                                        , CSS_TAG_VALUE        
                                        , val);
      return _tag;
    }

    /***************************************************************************
     * ListTags */
    /**
     * Returns a list of tags
     *
     * @param    mfi          MediaFileInfo object
     *
     * @return   List<String>
     ***************************************************************************/

    public static List<String> ListTags (MediaFileInfo mfi)
    {
      List<String> _tagsOut = new List<String>(); 
      if (mfi.tags != null)
      {
        foreach (String _tag in mfi.tags)
        {
          if (_tag == null)         continue;
          if (_tag == String.Empty) continue;
          _tagsOut.Add(_tag);
        }
      }
      return _tagsOut;
    }

    /***************************************************************************
     * GenerateLink */
    /**
     * Returns a anchor
     *
     * @param    url      URL
     * @param    label    Label
     *
     * @return   String
     ***************************************************************************/
	
    public static string GenerateLink (string url, string label)
    {  
      return GenerateLink (url,label,null);    
    }
    
    public static string GenerateLink (string url, string label, string style)
    {
      return GenerateLink (url, label, style, "_blank");
    }

    
    public static string GenerateLink (string url, string label, string style, string target)
    {
      
      if (String.IsNullOrEmpty(url)) return String.Empty;
      if (String.IsNullOrEmpty(label)) label = url;
      if (String.IsNullOrEmpty(style)) style = "";
      
      string _ptrn = @"<a href=""{0}"" class=""{1}"" style=""{2}"" target=""{3}"">{4}</a>";

      string _link = String.Format (_ptrn 
                                    ,url
                                    ,CSS_LINK
                                    ,style
                                    ,target
                                    ,label);
      return _link;               
	}

    /***************************************************************************
     * GenerateMessage */
    /**
     * Returns a message
     *
     * @param    msgclass  Class of message
     * @param    msgtext   Text of message
     *
     * @return   String
     ***************************************************************************/

	public static string GenerateMessage (string msgclass, string msgtext)
    {

      StringBuilder _sb = new StringBuilder();

      _sb.AppendFormat (@"<div class=""{0}"""
                        , CSS_MESSAGE);
      _sb.Append (@"</div>");

      return _sb.ToString(); 
    }
   

    #endregion

    #region UtilityMethods

    /***************************************************************************
     * getAppSetting */
    /**
     * Returns setting from app settings (settings are stored as strings)
     * 
     * @param    setting        Setting value (case sensitive)
     * @param    defaultvalue   Default to use if setting is null or empty
     * @return                  Value of setting
     ***************************************************************************/   

    public static string GetAppSetting(string setting)
    {
      return GetAppSetting (setting, null);
    }

    public static string GetAppSetting (string setting, string defaultvalue)
    {
      string value   = "";
      string dvalue  = String.IsNullOrEmpty(defaultvalue) ? null : defaultvalue;       
      
      try
      {
        value = System.Configuration.ConfigurationManager.AppSettings.Get(setting);        
      }
      catch
      {
        value = null;
      }
      
      if (String.IsNullOrEmpty(value))
        return dvalue;
      else
        return value;      
    }
     
    /*###########################################################################
      #
      # Utility methods
      #
      ###########################################################################*/		
		
    /***************************************************************************
     * CurrentServerAndApplicationRoot */
    /**
     * Returns the current server and application root
     *
     * Courtesy of MartinHN 
     * http://stackoverflow.com/a/689888
     *
     * @param    context    Current request/response context object
     ***************************************************************************/
    
    public static string CurrentServerAndApplicationRoot (HttpContext context)
    {
      /*============================================================
       * Get the web server port
       *  
       * If it is a common port or not defined dont worry about 
       * including it.
       *============================================================*/
  
      string port = context.Request.ServerVariables["SERVER_PORT"];

      if (port == null || port == "80" || port == "443")
        port = "";
      else
        port = ":" + port;

      /*============================================================
       * Secure request yes or no
       *============================================================*/

      string protocol = context.Request.ServerVariables["SERVER_PORT_SECURE"];

      if (protocol == null || protocol == "0")
        protocol = "http://";
      else
        protocol = "https://";

      /*============================================================
       * Get server name
       *============================================================*/

      string servername = context.Request.ServerVariables["SERVER_NAME"]; 

      /*============================================================
       * Get application path name
       *============================================================*/

      string apppath = context.Request.ApplicationPath;

      /*============================================================
       * Create current server root
       *============================================================*/

      string sOut = protocol + servername + port + apppath;

      if (sOut.EndsWith("/"))
      {
        sOut = sOut.Substring(0, sOut.Length - 1);
      }

      /*============================================================
       * Return it
       *============================================================*/
      
     return sOut;

    }

    /***************************************************************************
     * CurrentEndPointName */
    /**
     * Returns the filename of the end point being requested.  For example if
     * http://localhost/AppName/index.aspx is the requested end point then
     * index.aspx would be returned.
     *
     * @param    context    Current request/response context object
     ***************************************************************************/

    public static string CurrentEndPointName (HttpContext context)
    {
      return System.IO.Path.GetFileName(context.Request.PhysicalPath);    
    }

	/***************************************************************************
     * CreateURL */
    /**
     * Create URL
     * 
     * @param    context      Current request/response context object
     * @param    virtualpath  Virtual path such as css/screen.css
     ***************************************************************************/    	

    public static string CreateURL (ref HttpContext context, string virtualpath)
    {
      /*============================================================
       * Get physical path and file info of virtual path
       *============================================================*/

      string   _ppath = context.Server.MapPath (virtualpath);
      FileInfo _fi    = new FileInfo(_ppath);


      /*=========================================================
       * Create the full url 
       *============================================================*/
			
      string _url =  String.Format(@"{0}?{1}={2}"
                     , virtualpath 
                     , PARAM_FILE_TS 
                     , _fi.LastWriteTime.Ticks);

      return _url;

    }
                                  
    /***************************************************************************
     * CreateURL */
    /**
     * Create URL
     * 
     * @param    context    Current request/response context object
     * @param    ep         End point to use
     * @param    fn         File name requested 
     * @param    fa         File age in ticks    
     * @param    mode       Distribution mode
     ***************************************************************************/    


    public static string CreateURL (ref HttpContext context, 
                                    string ep, 
                                    string fn, 
                                    long   fa,
                                    DistributionModes mode)
    {

      /*============================================================
       * Get current server root
       *============================================================*/

      string _sr = CurrentServerAndApplicationRoot (context);            

      /*============================================================
       * Get the contextual end point name
       *============================================================*/

      string _ep = CurrentEndPointName (context);
      
      /*============================================================
       * If an end point name has not been provided by the user then
       * use the contextual one
       *============================================================*/

      if (!String.IsNullOrEmpty(ep))
        _ep = ep;

      /*============================================================
       * Create the full end point name 
       *============================================================*/
			
      string _epn =  String.Format(@"{0}/{1}",_sr,_ep);

      /*============================================================
       * URL encode the file name
       *============================================================*/

      string _fn = HttpUtility.UrlEncode (fn);

      /*============================================================
       * Attach file name and other params to the full end point name
       *============================================================*/

      string _ur = String.Format("{0}?{1}={2}&{3}={4}&{5}={6}", 
                                 _epn,                              
                                 PARAM_FILE_NAME, 
                                 _fn, 
                                 PARAM_MODE, 
                                 mode.GetHashCode(),
                                 PARAM_FILE_TS,
                                 fa);

      /*============================================================
       * Return 
       *============================================================*/

       return _ur;
    }
    #endregion
  }  
}

