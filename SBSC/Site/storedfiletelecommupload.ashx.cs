using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * storedfiletelecommupload.ashx.cs */
    /*
     ***************************************************************************/

    public class StoredFileTeleCommUpload : StoredFileUploadHandlerTeleCommFileShare
    {
                  
        public StoredFileTeleCommUpload()
        {

            /* Note: We are verifiying if the user has access in StoredFileUploadHandlerTeleCommFileShare
             * and we are returning some additional data such as the spedcare user data and file class info.
             * If we get to this point then access was granted and we can proceed.
             * Also note that we have to perform these operations in this seperate class because the
             * stored files are in the Spedmon namespace and database.   If we ever get a chance to move
             * stored files (file uploads) to the users database and MBA namespace we can simplify.
             */

            this.cbSaveFileUpload = delegate ()
            {
                
               /*-------------------------------    
                * Save the file 
                *------------------------------*/

                var sfs = StoredFiles.save (  dbConnApp
                                            , log
                                            , uInfo
                                            , this.rsai.fileClassStr
                                            , ""
                                            , fileDescription
                                            , this.rsai.fileNameSpace
                                            , this.rsai.fileSource
                                            , this.rsai.clientIDStr
                                            , this.rsai.pracIDStr
                                            , this.rsai.patIDStr
                                            , this.rsai.referencedEntityIDStr
                                            , @"N"
                                            , ""
                                            , files
                                            , ""
                                            , "0"
                                            , Constants.SAVE_TYPE_NEW.ToString()
                                            , "");

                /*-------------------------------    
                 * Add the file to the meetings
                 * file shares
                 *------------------------------*/

                var afs = MBA.TeleCommSessionFileShares.appendFileShare (  dbConnUser
                                                                          , log
                                                                          , uInfo
                                                                          , sfs.recordID.ToString()
                                                                          , "N"
                                                                          , ""
                                                                          , this.rsai.teleCommSessionID.ToString());

                /*-------------------------------    
                 * Send signal
                 *------------------------------*/

                MBA.TeleCommSessionParticipants.sendSignalRefreshFileShares(rsai.teleCommServerSessionID, "File Added");

                /*-------------------------------    
                 * Return stored file save data
                 *------------------------------*/
                
                return sfs;
            };
			    
       }
    }
}
