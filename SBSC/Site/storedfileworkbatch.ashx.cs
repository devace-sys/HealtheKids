using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * storedfileworkbatch.ashx.cs */
    /*
     ***************************************************************************/

    public class StoredFileWorkBatch : StoredFileViewOrDownloadHandler
    {
        public StoredFileWorkBatch()
        {
            /*-------------------------------
             * Define permitted roles 
             * Define delegates to retrieve record data
             *------------------------------*/
           
            this._permittedRoles = Constants.ROLE_SBS_ALL;
            
            this._cbRetrieveFileTargetFromDB = delegate() {
            
              ReturnStoredFileRecord so = new ReturnStoredFileRecord();
              so.storedFileRecord       = new StoredFileRecord();
              so.storedFileRecordFound  = false;
              
              string sql = @"select top 1 * from dbo.STORED_FILE_WORK_BATCH_VIEW (null,null,null,@fileReference)";
              
              List<SqlParameter> parms = new List<SqlParameter>();
              parms.Add(Database.SqlParm("@fileReference",  SqlDbType.VarChar, _storedFileRecordID, ParameterDirection.Input, 500));
    
              ReturnDB rd = Database.execQuery(dbConnApp,log,sql,false,parms);
              
              so.storedFileRecordFound = rd.hasRecords;
              
              if (rd.hasRecords) {                 
                so.storedFileRecord = (StoredFileRecord) Database.convertRecord(rd.records,typeof(StoredFileRecord));                
              } 
             			        			       
			  return so;
             
            };			
        }
    }
}
