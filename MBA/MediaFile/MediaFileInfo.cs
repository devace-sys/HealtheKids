using System;
using System.IO;
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
   * MediaFileInfo */
  /**
   * Return info about a media file
   * 
   ***************************************************************************/
  
  public class MediaFileInfo
  {

    #region Properties

    /*###########################################################################
      #
      # Properties
      #
      ###########################################################################*/	

    protected   bool                  _fileInfoOK    = false;
    protected   FileInfo              _fi            = null;
    protected   string                _file          = null;
    protected   string                _name          = null;
    protected   string                _filename      = null;
    protected   string                _label         = null;
    protected   long?                 _length        = null;
    protected   string                _ext           = null;
    protected   string                _mimetype      = null;    
    protected   MediaType             _mediatype     = MediaType.UNSUPPORTED;
    protected   MediaSubType          _mediasubtype  = MediaSubType.UNSUPPORTED;
    protected   MediaClass            _mediaclass    = MediaClass.UNSUPPORTED;
	  protected   int?                  _numpages      = null;
    protected   int?                  _numlines      = null;
    protected   int?                  _numwords      = null;
    protected   Encoding              _encoding      = null;
    protected   string                _xmp           = null;
    protected   TimeSpan?             _duration      = null;
    protected   string                _durationstr   = null;
    protected   int?                  _width         = null;
    protected   int?                  _height        = null;
    protected   DateTime?             _datetime      = null;
    protected   ImageOrientation      _orientation   = ImageOrientation.None;
    protected   string                _make          = null;
    protected   string                _model         = null;
    protected   double?               _lat           = null;
    protected   double?               _lon           = null;
    protected   string                _mapuri_gm     = null;
    protected   string                _mapuri_osm    = null;
    protected   string                _humansize     = null;
    protected   Image                 _thumbnail     = null;
    protected   string                _title         = null;
    protected   string                _author        = null;
    protected   bool                  _filesupported = false;
    protected   string                _linkAddress   = "";
    protected   List<String>          _tags          = null;

    public bool         fileInfoOK    { get { return _fileInfoOK;    } }
    public FileInfo     fi            { get { return _fi;            } }
    public string       file          { get { return _file;          } }
    public string       name          { get { return _name;          } }
    public string       filename      { get { return _filename;      } }
    public string       label         { get { return _label;         } }
    public long?        length        { get { return _length;        } }
    public string       ext           { get { return _ext;           } }
    public string       mimetype      { get { return _mimetype;      } }
    public MediaType    mediatype     { get { return _mediatype;     } }
    public MediaSubType mediasubtype  { get { return _mediasubtype;  } }
    public MediaClass   mediaclass    { get { return _mediaclass;    } }
    public string       make          { get { return _make;          } }
    public string       model         { get { return _model;         } }
    public int?         width         { get { return _width;         } }
    public int?         height        { get { return _height;        } }
    public DateTime?    datetime      { get { return _datetime;      } }
    ImageOrientation    orientation   { get { return _orientation;   } }
    public double?      lat           { get { return _lat;           } }
    public double?      lon           { get { return _lon;           } }
    public string       mapuri_gm     { get { return _mapuri_gm;     } }
    public string       mapuri_osm    { get { return _mapuri_osm;    } }
    public int?         numpages      { get { return _numpages;      } }
    public int?         numlines      { get { return _numlines;      } }
    public int?         numwords      { get { return _numwords;      } }
    public Encoding     encoding      { get { return _encoding;      } }
    public string       xmp           { get { return _xmp;           } }
    public TimeSpan?    duration      { get { return _duration;      } }
    public string       durationstr   { get { return _durationstr;   } }
    public string       humansize     { get { return _humansize;     } }
    public Image        thumbnail     { get { return _thumbnail;     } }
    public string       title         { get { return _title;         } }
    public string       author        { get { return _author;        } }
    public bool         fileSupported { get { return _filesupported; } }
    public List<String> tags          { get { return _tags;          } }
    public string       linkAddress   { get { return _linkAddress;   } }
    
    #endregion

    #region Methods

    /*###########################################################################
      #
      # Methods
      #
      ###########################################################################*/	

    /***************************************************************************
     * Init */
    /**
     * Resets all properties to default (unknown) values
     ***************************************************************************/  

    protected void Init ()
    {
      _fileInfoOK    = false;
      _fi            = null;
      _file          = null;
      _name          = null;
      _filename      = null;
      _length        = null;
      _ext           = null;
      _mimetype      = null;
      _mediatype     = MediaType.UNSUPPORTED;
      _mediasubtype  = MediaSubType.UNSUPPORTED;
	  //_mediaicon     = null;
      _filesupported = false;
      _numpages      = null;
      _numlines      = null;
      _numwords      = null;
      _encoding      = null;
      _xmp           = null;
      _duration      = null;
      _durationstr   = null;
      _width         = null;
      _height        = null;
      _datetime      = null;
      _orientation   = ImageOrientation.None;
      _make          = null;
      _model         = null;
      _lat           = null;
      _lon           = null;
      _mapuri_gm     = null;
      _mapuri_osm    = null;
      _humansize     = null;
      _thumbnail     = null;
      _title         = null;
      _author        = null;
      _tags          = null;
      _linkAddress   = null;

    }
    
    /***************************************************************************
     * Create */
    /**
     * Populates properties
     ***************************************************************************/  
    
    protected bool Create (string file)
    {
      FileLogger f = null;
      return Create (file, ref f);
    }
   
    protected bool Create (string file, ref FileLogger log)
    {     
      try
      {

        /*============================================================
         * Reset 
         *============================================================*/

        Init ();
      
        /*============================================================
         * If the file is not passed in, get out
         *============================================================*/

        if (String.IsNullOrEmpty(file)) return false;     
      
        /*============================================================
         * Get basic file info
         *============================================================*/

        _file          = file;			
        _fi            = new FileInfo (_file);

        /*============================================================
         * If the file does not exist, get out
         *============================================================*/
      
        if (!_fi.Exists) return false;       

        /*============================================================
         * Otherwise get some more info
         *============================================================*/
      
        _fileInfoOK    = true;
        _name          = Path.GetFileNameWithoutExtension (fi.FullName);
        _filename      = Path.GetFileName                 (fi.FullName);
        _length        = fi.Length;
        _ext           = MediaFileCommon.GetFileExtension         (_file);
        _mimetype      = MediaFileCommon.GetMimeTypeFromExtension (_ext);
        _mediatype     = MediaFileCommon.GetMediaTypeFromMime     (_mimetype);
        _mediasubtype  = MediaFileCommon.GetMediaSubTypeFromMime  (_mimetype);
        _mediaclass    = MediaFileCommon.GetMediaClassFromMime    (_mimetype);
        //_mediaicon     = MediaFileCommon.GetMediaIcon             (_mediaclass);
        _filesupported = MediaFileCommon.IsFileSupported          (_mediatype, _mediasubtype);
      
        /*============================================================
         * If this file is not supported get out
         *============================================================*/
     
        if (!_filesupported) return false;

        /*============================================================
         * Start tags list and add initial tags
         *===========================================================*/
    
        _tags = new List<string>();

        _tags.Add (MediaFileCommon.GenerateTag (TagType.FILE_CLASS, "Class", _mediaclass.ToString()));
        _tags.Add (MediaFileCommon.GenerateTag (TagType.FILE_TYPE,  "Type",  _mediasubtype.ToString()));

        /*===========================================================
         * If this file is link file we use IO.File methods to 
         * retrieve the url
         *============================================================*/

        if (_mediatype == MediaType.LINK) {
        
          using (StreamReader sr = System.IO.File.OpenText(_file)){
            _encoding = sr.CurrentEncoding;
            string s = String.Empty;
            _linkAddress = String.Empty;
            while ((s = sr.ReadLine()) != null) {              
              string l = s.Trim();         
              if (String.IsNullOrEmpty(l)) continue;  /* Skip blank lines */
              if (l.StartsWith("--"))      continue;  /* Skip comments    */  
              /* Grab first non blank non comment line then exit */
              if (!String.IsNullOrEmpty(l)) 
              {
                _linkAddress = l;
                break;
              }
            }
            sr.Close();
          }
        }
        
        /*===========================================================
         * If this file is a text file we use IO.File methods to 
         * generate meta data
         *============================================================*/

        if (_mediatype == MediaType.TEXT)
        {
          int    _lc = 0;
          int    _wc = 0;
          char[] _delims = new char[] {' ', '\r', '\n' };

          using (StreamReader sr = System.IO.File.OpenText(_file))
          {
            _encoding = sr.CurrentEncoding;
            _width    = 612; 
            _height   = 792;
            string s = String.Empty;

            while ((s = sr.ReadLine()) != null)
            {

              /*==============
               * Count words
               *=============*/

              _wc = _wc + s.Split(_delims, StringSplitOptions.RemoveEmptyEntries).Length; 
     
              /*==============
               * Count lines
               *=============*/

              _lc++;
            }
            sr.Close();
          }

          _numlines  = _lc;
          _numwords  = _wc;
         
          /*==============
           * Add tags
           *=============*/

          _tags.Add (MediaFileCommon.GenerateTag (TagType.CONTENT_DIMENSION, "Lines", _lc.ToString()));
          _tags.Add (MediaFileCommon.GenerateTag (TagType.CONTENT_DIMENSION, "Words", _wc.ToString()));


          _humansize = String.Format ("{0} lines and {1} words",_lc,_wc);
        }
 
        /*============================================================
         * If this file is an audio, video, or image we use the 
         * TagLib library to extract meta data
         *============================================================*/

        if (
               (_mediatype == MediaType.AUDIO) 
            || (_mediatype == MediaType.VIDEO) 
            || (_mediatype == MediaType.IMAGE)
           )
        {

         /*==========================
          * Create file abstraction
          *============================*/

          TagLib.File tf = TagLib.File.Create(_file);
       
          /*============================================================
           * Image
           *============================================================*/

          if (_mediatype == MediaType.IMAGE)
          {
          
            /*==============
             * Dimensions
             * in pixels
             *=============*/

            this._width  = tf.Properties.PhotoWidth;
            this._height = tf.Properties.PhotoHeight;
                       
            /*==============
             * More specific
             * data
             *=============*/

            TagLib.Image.File img = (TagLib.Image.File) tf;

            /*==============
             * Camera info
             *=============*/

            this._make        = img.ImageTag.Make;
            this._model       = img.ImageTag.Model;
            this._orientation = img.ImageTag.Orientation;

            /*==============
             * Date, time,
             * location
             *=============*/

            this._datetime    = img.ImageTag.DateTime;
            this._lat         = img.ImageTag.Latitude;
            this._lon         = img.ImageTag.Longitude;
            this._mapuri_gm   = MediaFileCommon.GenerateGoogleMapURI (this._lat, this._lon);
            this._mapuri_osm  = MediaFileCommon.GenerateOpenMapURI   (this._lat, this._lon);
            /*==============
             * Add tags
             *=============*/

            _tags.Add (MediaFileCommon.GenerateTag  (TagType.CONTENT_DIMENSION,   "Width",  this._width.ToString()));
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.CONTENT_DIMENSION,   "Height", this._height.ToString()));
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.RECORDING_DEVICE,    "Camera Make",  this._make.ToString()));
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.RECORDING_DEVICE,    "Camera Model", this._model.ToString()));
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.RECORDING_DATE_TIME, "Taken On",  this._datetime));
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.RECORDING_LOCATION,  "Latitude",  this._lat));
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.RECORDING_LOCATION,  "Longitude", this._lon));

             string _gmap = MediaFileCommon.GenerateLink (this._mapuri_gm, "Google Maps");            
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.RECORDING_LOCATION,  "Map", _gmap));

             string _osmap = MediaFileCommon.GenerateLink (this._mapuri_osm, "OpenStreet Maps");            
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.RECORDING_LOCATION,  "Map", _osmap));


            this._humansize   = String.Format ("{0} by {1} pixels",_width.ToString(), _height.ToString());

          }

          /*============================================================
           * Video
           *============================================================*/

          if (_mediatype == MediaType.VIDEO)
          {

            /*==============
             * Dimensions
             * in pixels
             *=============*/

            this._width    = tf.Properties.VideoWidth;
            this._height   = tf.Properties.VideoHeight;

            /*==============
             * Title and
             * Author
             *=============*/

            this._title    = tf.Tag.Title;
            this._author   = tf.Tag.FirstAlbumArtist;
		
            /*==============
             * Duration in
             * time
             *=============*/

            this._duration    = tf.Properties.Duration;
            this._durationstr = MediaFileCommon.GenerateDurationString (_duration);

            /*==============
             * Add tags
             *=============*/
        
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.CONTENT_DIMENSION, "Width",  this._width.ToString()));
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.CONTENT_DIMENSION, "Height", this._height.ToString()));
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.RECORDING_TITLE,   "Title",    this._title));
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.RECORDING_AUTHOR,  "Author",   this._author));
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.CONTENT_DIMENSION, "Duration", this._duration));

            /*==============
             * Generate
             * human size
             *=============*/

            this._humansize   = String.Format ("{0} duration and {1} by {2} pixels",_durationstr, _width.ToString(), _height.ToString());

		  
          }

          /*============================================================
           * Audio
           *============================================================*/

          if (_mediatype == MediaType.AUDIO)
          {
            this._duration    = tf.Properties.Duration;
            this._durationstr = MediaFileCommon.GenerateDurationString (_duration);

            /*==============
             * Title and
             * Author
             *=============*/

            this._title       = tf.Tag.Title;
            this._author      = tf.Tag.FirstAlbumArtist;

            /*==============
             * Add tags
             *=============*/

            _tags.Add (MediaFileCommon.GenerateTag  (TagType.RECORDING_TITLE,   "Title",    this._title));
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.RECORDING_AUTHOR,  "Author",   this._author));
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.CONTENT_DIMENSION, "Duration", this._duration));

            /*==============
             * Generate
             * human size
             *=============*/

            this._humansize   = String.Format ("{0} duration",_durationstr);

            /*==============
             * Thumbnail
             * Images
             * (built in)
             *=============*/

            foreach (IPicture pic in tf.Tag.Pictures)
            {
              MemoryStream ms = new MemoryStream(pic.Data.Data);
              this._thumbnail = Image.FromStream(ms);
              ms.Close();
              break; /* Only grab 1st one */
            }
          }
        }

        /*============================================================
         * If this file is an application file we use various libraries 
         * to extract meta data
         *============================================================*/

        if (_mediatype == MediaType.APPLICATION)
        {

          /*============================================================
           * If this a PDF we use the iText library to extract data
           *============================================================*/

          if (_mediasubtype == MediaSubType.PDF)
		  {

            iTextSharp.text.pdf.PdfReader pr = new iTextSharp.text.pdf.PdfReader(_file);
            this._numpages = pr.NumberOfPages;

	    
            /*=============================
             * XMP Data
             *============================*/

            byte[] b = pr.Metadata;

            if (b != null)
            {
              /* http://en.wikipedia.org/wiki/Extensible_Metadata_Platform */

              _xmp = new UTF8Encoding().GetString(b).Trim();
            }

            pr.Close();

            /*==============
             * Add tags
             *=============*/
        
            _tags.Add (MediaFileCommon.GenerateTag  (TagType.CONTENT_DIMENSION, "Pages",  this._numpages));

            /*==============
             * Generate
             * human size
             *=============*/

            this._humansize = String.Format ("{0} pages",this._numpages.ToString());
		  }
        }
        return true; 

      }
      catch (Exception e)
      {
        if (log != null) 
          log.WriteLog(LogLevel.Crit, e.Message);
        
        return false;
      }
      finally
      {
      }

    }

    #endregion
 
    #region Constructors
    
    /*###########################################################################
      #
      # Contructors
      #
      ###########################################################################*/	
    
    public MediaFileInfo (string file)
    {
      Create (file);
    }

    public MediaFileInfo (string file, ref FileLogger log)
    {
      Create (file,ref log);
    }

    #endregion
  }
  
}

