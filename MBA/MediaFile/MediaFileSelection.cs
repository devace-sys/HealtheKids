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
   * MediaFileSelection */
  /**
   * Media file selection
   ***************************************************************************/

  public class MediaFileSelection:MediaFileItem
  {
    
    #region Contructors

    /*###########################################################################
      #
      # Constructors
      #
      ###########################################################################*/		
		    
    public MediaFileSelection ()
    {
    }

    public MediaFileSelection (string parentid, 
                               int filenum, 
                               int rownum, 
                               string filesroot, 
                               string file, 
                               string filehandler,
                               string style)
    {
      
      this.ID           = String.Format (@"{0}_{1}_{2}", 
                                         parentid,
                                         filenum,
                                         rownum);
      this._filesRoot   = filesroot;
      this._file        = file;
      this._fileHandler = filehandler;
      this._filenum     = filenum;
      this._rownum      = rownum;
      this._style       = style;
      
      GetMediaFileInfo();

    }
    
    #endregion
		
    protected int    _filenum;
    protected int    _rownum;

    #region Methods
				
	/*###########################################################################
      #
      # Methods
      #
      ###########################################################################*/			

    protected override void Render (HtmlTextWriter writer)
    {
   
      /*============================================================
       * Get media file info
       *============================================================*/

      GetMediaFileInfo ();

      /*============================================================
       * Default label if neccessary
       *============================================================*/

      DefaultLabel ();

      /*============================================================
       * Create a url for the file that references the file handler
       *============================================================*/

      CreateURLs ();
      
      writer.Write (@"<li class=""{0}"">"
                   , MediaFileCommon.CSS_SELECTION);

      writer.Write(MediaFileCommon.GenerateLink (_displayUrl,_label,_style));

      writer.Write (@"</li>");

	  base.Render(writer);

    }
    #endregion
  }
}

