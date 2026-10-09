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
   * StoredFileDownloadHandler */
  /**
   * Custom handler for displaying, delivering, and downloading static files
   * referenced by a db record id and stored on a local or network volume 
   *
   * Requires: MediaFileCommon.cs, MediaFileInfo.cs
   * 
   ***************************************************************************/  

  public class StoredFileDownloadHandler : StoredFileDownloadHandlerBase
  {
    
    public StoredFileDownloadHandler():base(true,true,false)
    {
        
    }
    
  }     
}


