using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * storedfiledownload.ashx.cs */
    /*
     ***************************************************************************/

    public class StoredFileDownload : StoredFileDownloadHandler
    {
        public StoredFileDownload()
        {
            /*-------------------------------
             * Define permitted roles 
             * Define delegates to retrieve record data
             *------------------------------*/
           
            this.permittedRoles = Constants.ROLE_ALL_PCAL_CLIENT_ALL_THIRD_PARTY_ORP_PG;
            
            this.cbGetFileData = delegate() {            
              ReturnStoredFileRecord so = new ReturnStoredFileRecord();
              so = StoredFiles.retrieve(dbConnApp,log,uInfo,fileRecordID);                            
			  return so;             
            };
			
        }
    }
}
