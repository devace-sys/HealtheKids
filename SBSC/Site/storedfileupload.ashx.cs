using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * storedfileupload.ashx.cs */
    /*
     ***************************************************************************/

    public class StoredFileUpload : StoredFileUploadHandler
    {
        protected string clientID;
        protected string pracID;
        protected string patID;
        protected string referencedEntityID;
        protected string referenceDate1;

        public StoredFileUpload()
        {
			/*-------------------------------
             * Define permitted roles 
             * Define delegates to retrieve record data
             *------------------------------*/
           
            this.permittedRoles   = Constants.ROLE_ALL_PCAL_AND_CLIENT;
            
            this.cbSaveFileUpload = delegate() {
              
              ReturnSaveRecord so = new ReturnSaveRecord();                   
                          
              clientID           = GetAdditionalDataValue ("clientid");
              pracID             = GetAdditionalDataValue ("pracid");
              patID              = GetAdditionalDataValue ("patid");
              referencedEntityID = GetAdditionalDataValue ("referencedentityid");
              referenceDate1     = GetAdditionalDataValue ("referencedate1");

              so = StoredFiles.save (  dbConnApp
                                     , log
                                     , uInfo
                                     , fileClass
                                     , fileSubClass
                                     , fileDescription
                                     , fileNameSpace
                                     , fileSource
                                     , clientID
                                     , pracID
                                     , patID
                                     , referencedEntityID
                                     , isConfidentialPracticeFile
                                     , referenceDate1
                                     , files
                                     , ""
                                     , "0"
                                     , Constants.SAVE_TYPE_NEW.ToString()
                                     , "" );
  
       			  return so;
             
            };
			    
        }
    }
}
