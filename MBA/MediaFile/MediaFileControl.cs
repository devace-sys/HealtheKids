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
   * MediaFileControl */
  /**
   * Base class for media file web controls
   ***************************************************************************/  
  
  public abstract class MediaFileControl:Control
  {
    #region Contructors

    /*###########################################################################
      #
      # Constructors
      #
      ###########################################################################*/

    public MediaFileControl ()
    {
    }

    #endregion

    #region Properties

	/*###########################################################################
      #
      # Properties
      #
      ###########################################################################*/

    protected string        _folder               = "";
    protected string        _file                 = "";
    protected string        _filesRoot            = MediaFileCommon.MEDIA_FILE_PATH;
    protected string        _fileHandler          = MediaFileCommon.MEDIA_FILE_HANDLER;
    protected string        _style                = "";    
    
    public string Folder          { get { return _folder;      }  set { _folder       = value; }}	
    public string File            { get { return _file;        }  set { _file         = value; }}
    public string FilesRoot       { get { return _filesRoot;   }  set { _filesRoot    = value; }}    
    public string FileHandler     { get { return _fileHandler; }  set { _fileHandler  = value; }}
	  public string Style           { get { return _style;       }  set { _style        = value; }}

	#endregion
	
    #region Methods

		  
    protected override void Render (HtmlTextWriter writer)
    {      
	  base.Render(writer);
    }

    #endregion
  }
}

