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

	public class StoredFileUploadHandler : StoredFileUploadHandlerBase
    {
	  public StoredFileUploadHandler():base(true) 
	  {
	  }
   
	}
}
