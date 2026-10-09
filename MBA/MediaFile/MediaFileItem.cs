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

namespace EAW.MediaFile
{
  
  /***************************************************************************
   * MediaFileItem */
  /**
   * Base class for media file controls that handle a single item
   ***************************************************************************/  
  
  public abstract class MediaFileItem:MediaFileControl
  {
    #region Contructors

    /*###########################################################################
      #
      # Constructors
      #
      ###########################################################################*/

    public MediaFileItem ()
    {
    }

    #endregion

    #region Properties

	/*###########################################################################
      #
      # Properties
      #
      ###########################################################################*/

    protected string        _label                = "";
    protected string        _displayUrl           = "";
    protected string        _downloadUrl          = "";

    protected MediaFileInfo _mfi                  = null;
	
    [ReadOnly(true)]
    public MediaFileInfo mfi { get { return _mfi; } }
    	
    public string Label { get { return _label; } set { _label = value; }}

	#endregion
	
    #region Methods

	/*###########################################################################
      #
      # Methods
      #
      ###########################################################################*/

    protected bool GetMediaFileInfo ()
    {
      _mfi  = new MediaFileInfo(_file);
      return _mfi.fileInfoOK;
    }

    protected void CreateURLs ()
    {   
      if (_mfi.mediatype == MediaType.LINK)
      {
        _displayUrl  = _mfi.linkAddress;
        _downloadUrl = _mfi.linkAddress;
        return;
      }
      string _f           = _mfi.file.Replace(_filesRoot,"");
      HttpContext ctx     = this.Context;      
      _displayUrl         = MediaFileCommon.CreateURL (ref ctx,_fileHandler,_f, _mfi.fi.LastWriteTime.Ticks, DistributionModes.DISPLAY);
      _downloadUrl        = MediaFileCommon.CreateURL (ref ctx,_fileHandler,_f, _mfi.fi.LastWriteTime.Ticks, DistributionModes.DOWNLOAD);
    }

    protected void AppendFileRoot ()
    {
      if (_file.StartsWith (_filesRoot)) return;
      string _f1 = _file.Replace (_filesRoot,"");
	  string _f2 = Path.Combine  (_filesRoot,_f1);
      _file = _f2;
    }
           
    protected bool FileNameCheck()
    {
      return !String.IsNullOrEmpty(_file );      
    }
    
    protected void DefaultLabel()
    {
      if (String.IsNullOrEmpty(_label)) _label = Path.GetFileNameWithoutExtension(_file);
    }
		  
    protected override void Render (HtmlTextWriter writer)
    {      
	  base.Render(writer);
    }

    #endregion
  }
}

