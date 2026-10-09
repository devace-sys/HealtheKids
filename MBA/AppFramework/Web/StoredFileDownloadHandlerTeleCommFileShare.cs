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
   * StoredFileDownloadHandlerTeleCommFileShare */
  /**
   * Custom handler for displaying, delivering, and downloading static files
   * referenced by a db record id and stored on a local or network volume 
   *
   * Requires: MediaFileCommon.cs, MediaFileInfo.cs
   * 
   ***************************************************************************/  

  public abstract class StoredFileDownloadHandlerTeleCommFileShare : StoredFileDownloadHandlerBase
  {
    
    public StoredFileDownloadHandlerTeleCommFileShare(): base (false,false,true)
    {
       /* Access control is common despite instance
        * Also note that we have to perform additional operations in a seperate class that inherits
        * from this because the stored files are in the Spedmon namespace and database.   
        * If we ever get a chance to move stored files (file uploads) to the users database 
        * and MBA namespace we can simplify.
        */
      
      this.cbAccessControl = delegate() {

        
         var so = TeleCommSessionFileShares.canParticipantAccessSharedFile ( dbConnUser
                                                                            , log
                                                                            , uInfo
                                                                            , rd
                                                                            , appName
                                                                            , MBA.HttpApplication.getParameter(Constants.PARM_ROOM_ID)
                                                                            , MBA.HttpApplication.getParameter(Constants.PARM_ROOM_PART_UID)
                                                                            , MBA.HttpApplication.getParameter(Constants.PARM_ROOM_PART_PIN)
                                                                            , fileRecordID );

         
          return so;
       };       
     }
  }     
}


