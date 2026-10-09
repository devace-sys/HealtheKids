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
   * MediaFileLink */
  /**
   * Stand alone link to media file
   ***************************************************************************/  
  
  public class MediaFileLink:MediaFileItem
  {
       
    #region Contructors

    /*###########################################################################
      #
      # Constructors
      #
      ###########################################################################*/

    public MediaFileLink ()
    {
    }

    public MediaFileLink (string filesroot, string file, string filehandler)
    {
      this._filesRoot   = filesroot;
      this._file        = file;
      this._fileHandler = filehandler;
    }

    #endregion
    
    #region Methods

	/*###########################################################################
      #
      # Methods
      #
      ###########################################################################*/				

    protected override void Render (HtmlTextWriter writer)
    {
      /*============================================================
       * Check file name
       *============================================================*/

	  if (!FileNameCheck())
      {
        writer.Write(@"<span class=""{0}"">File required</span>"
                     , MediaFileCommon.CSS_ERROR);
        base.Render(writer);
        return;
      } 

      /*============================================================
       * Append file root if neccessary
       *============================================================*/

      AppendFileRoot();            
 
      /*============================================================
       * Get media file info
       *============================================================*/

      if (!GetMediaFileInfo())
      {
        writer.Write(@"<span class=""{0}"">File does not exist</span>"
                     , MediaFileCommon.CSS_ERROR);
        base.Render(writer);
        return;
      }

      /*============================================================
       * Default label if neccessary
       *============================================================*/

      DefaultLabel();

      /*============================================================
       * Create a url for the file that references the file handler
       *============================================================*/

      CreateURLs();


      /*============================================================
       * Render link
       *============================================================*/

      writer.Write (MediaFileCommon.GenerateLink (_displayUrl,_label,_style)); 

      base.Render (writer);

    }
    #endregion
  }
}

