using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * storedfilelist.ashx.cs */
    /*
     ***************************************************************************/

    public class StoredFileList : StoredFileListHandler
    {
        protected string clientID;
        protected string pracID;
        protected string patID;
        protected string referencedEntityID;

        public StoredFileList()
        {
	      /*-------------------------------
           * Define permitted roles 
           * Define delegates to retrieve record data
           *------------------------------*/
           
          this.permittedRoles   = Constants.ROLE_ALL_PCAL_AND_CLIENT;
            
          this.cbFileList = delegate() {
              
            ReturnDataTable so = new ReturnDataTable();
                        
            clientID           = GetAdditionalDataValue ("clientid");
            pracID             = GetAdditionalDataValue ("pracid");
            patID              = GetAdditionalDataValue ("patid");
            referencedEntityID = GetAdditionalDataValue ("referencedentityid");

            so = StoredFiles.viewTbl (  dbConnApp
                                      , log
                                      , uInfo
                                      , outputPaging
                                      , outputPageNumber
                                      , ""
                                      , "1"
                                      , clientID
                                      , pracID
                                      , patID
                                      , referencedEntityID
                                      , fileClass
                                      , fileDateRange
                                      , fileNameSpace
                                      , fileSource );
       			return so;
             
          };
			    
        }
    }
}
