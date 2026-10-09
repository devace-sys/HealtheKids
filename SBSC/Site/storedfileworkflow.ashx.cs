using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * StoredFileWorkFlow */
    /*
     * Dedicated handler for work batch files that are managed by the workflow
     * app
     ***************************************************************************/

    public class StoredFileWorkFlow : StoredFileDownloadHandler
    {
        public StoredFileWorkFlow()
        {
            /*-------------------------------
             * Define permitted roles 
             * Define delegates to retrieve record data
             *------------------------------*/
           
            this.permittedRoles = Constants.ROLE_SBS_ALL_LEA_COORD_AND_ASSIST;
            
            this.cbGetFileData = delegate() {
              
              ReturnStoredFileRecord so = new ReturnStoredFileRecord();
              StoredFileRecord       sfr = null;

              string fileReference = MBA.HttpApplication.getParameter(Constants.PARM_BATCH_FILE_REFERENCE);
              string inputBatchID  = MBA.HttpApplication.getParameter(Constants.PARM_BATCH_ID);
              
              String vFileReference = Validate.optString  (fileReference, @"Invalid file reference");
              Object vInputBatchID  = Validate.optInteger (inputBatchID,  @"Invalid input batch ID");
              
              /* If the reference is passed it, strip off the extension (if any) */

              if (!String.IsNullOrWhiteSpace(vFileReference))
              {
                 vFileReference = System.IO.Path.GetFileNameWithoutExtension(vFileReference);
              }
                         
              string sql = @"select top 1 * from dbo.STORED_FILE_WORKFLOW_VIEW_FILE_RECORD (@inputBatchID, @fileReference)";
              
              var parms = new List<SqlParameter>();
              
              parms.Add(Database.SqlParm("@fileReference",  SqlDbType.VarChar, vFileReference, ParameterDirection.Input,500));
              parms.Add(Database.SqlParm("@inputBatchID",   SqlDbType.BigInt,  vInputBatchID, ParameterDirection.Input));

              ReturnDB rd = Database.execQuery(dbConnApp,log,sql,false,parms);
                            
              if (rd.hasRecords) {                 
                 sfr = (StoredFileRecord) Database.convertRecord(rd.records,typeof(StoredFileRecord));                
              } 
              else
              {
                sfr = null;
              }
              
              /* Get remaining file data and retrieve from stored file record returned back */

              so = StoredFiles.retrieve(sfr);
			  
              return so;
             
            };
			
        }
    }
}
