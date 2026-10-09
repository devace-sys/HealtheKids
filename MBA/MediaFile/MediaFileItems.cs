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
  
  public abstract class MediaFileItems:MediaFileControl
  {
    #region Contructors

    /*###########################################################################
      #
      # Constructors
      #
      ###########################################################################*/

    public MediaFileItems ()
    {
    }

    public MediaFileItems (string id, string filesroot, string folder, string file, string filehandler)
    {
      this.ID           = id;
      this._filesRoot   = filesroot;
      this._folder      = folder;
      this._file        = file;
      this._fileHandler = filehandler;
    }


    #endregion
    
    // TODO: Create abstract methods for traversal based on MediaFileSelections    

  }
  
}

