using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * storedfiletelecommdownload.ashx.cs */
    /*
     ***************************************************************************/

    public class StoredFileTeleCommDownload : StoredFileDownloadHandlerTeleCommFileShare
    {
        public StoredFileTeleCommDownload():base()
        {
            /* Note: We are verifiying if the user has access in StoredFileDownloadHandlerTeleCommFileShare
             * If we get to this point then access was granted and we can proceed.
             * Also note that we have to perform these operations in this seperate class because the
             * stored files are in the Spedmon namespace and database.   If we ever get a chance to move
             * stored files (file uploads) to the users database and MBA namespace we can simplify.
             */
            
            this.cbGetFileData = delegate() {            
              
              /* Note: We are verifiying if the user has access in StoredFileDownloadHandlerTeleCommFileShare
               * so we pass an argument to the database to skip the canUserView check (assumeUserCanView = true)
               */ 
              var so = StoredFiles.retrieve(dbConnApp,log,uInfo,fileRecordID, true);                            
			  return so;             
          };
			
        }
    }
}
