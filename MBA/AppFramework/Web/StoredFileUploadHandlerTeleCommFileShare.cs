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
   * StoredFileUploadHandlerTeleCommFileShare */
  /**
   * Custom handler for uploading files in room
   * 
   ***************************************************************************/  

  public abstract class StoredFileUploadHandlerTeleCommFileShare : StoredFileUploadHandlerBase
  {
    
    public StoredFileUploadHandlerTeleCommFileShare(): base (false)
    {
       /* Access control is common despite instance
        * Also note that we have to perform additional operations in a seperate class that inherits
        * from this because the stored files are in the Spedmon namespace and database.   
        * If we ever get a chance to move stored files (file uploads) to the users database 
        * and MBA namespace we can simplify.
        */

      this.cbAccessControl = delegate() {
         
         var so = TeleCommSessionFileShares.canParticipantAppendASharedFile (  ref dbConnUser
                                                                             , ref log
                                                                             , ref uInfo
                                                                             , ref rd
                                                                             , appName
                                                                             , MBA.HttpApplication.getParameter(Constants.PARM_ROOM_ID)
                                                                             , MBA.HttpApplication.getParameter(Constants.PARM_ROOM_PART_UID)
                                                                             , MBA.HttpApplication.getParameter(Constants.PARM_ROOM_PART_PIN)
                                                                            );
         
         return so;
      };
    
     }
  }     
}


