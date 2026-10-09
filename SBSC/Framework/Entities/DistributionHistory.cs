using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Reflection;

using MBA;

namespace Spedmon
{   
  /***************************************************************************
   * DistributionHistory */
  /**
   * 
   **************************************************************************/
   
  public class DistributionHistory:MBA.DistributionHistory
  {        
    
    /***************************************************************************
     * Create */
    /**
     * Create instance from Distribution instance.
     **************************************************************************/
   
    public static DistributionHistory Create(Distribution d)
    {
      DistributionHistory dh = new DistributionHistory();
      
      foreach (FieldInfo fld in d.GetType().GetFields())
      {
        FieldInfo fld2 = d.GetType().GetField(fld.Name);
        fld2.SetValue(dh, fld.GetValue(d));
      }    
      return dh;
    }                     
  
    
  }
  
  /***************************************************************************
   * DistributionsHistory */
  /**
   * Note: The s.
   **************************************************************************/

  public class DistributionsHistory:Entities
  {          
    
    /***************************************************************************
     * save */
    /**
     * Save a history record.
     * For internal automation use only.
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Patient's client id
     * @param  publicationID   Publication id,
     * @param  distributeToEmails      Email list (; delimited)
     * @param  distributionOptionFlags 1 = Managed 2, 4,
     * @param  editDelReason   Reason for record edit or delete
     * @param  validateRec     1 = Performs data integrity validation tasks
     *                             Perform advisory validation tasks that can
     *                             only be conducted by referencing data from the
     *                             database and then exits WITHOUT saving the record
     *                         0 = Peform data integrity validation tasks and
     *                             if these tasks succeed peforms the desired
     *                             operation (saveType) on the record and exits
     * @param  saveType        Type of operation to perform
     *                         1 = New, 2 = Edit, 3 = Delete
     * @param  recID           Record id of existing patient record to edit or
     *                         delete.
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
   public static ReturnSaveRecord save (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,                                         
                                         DistributionHistory rec)
    {           
            
      /*----------------------------
       * Create db parms and populate
       * 
       * Note: There is no validation
       * this is meant to be called
       * via automation with 
       * prevalidated values
       *----------------------------*/
      
      List<SqlParameter> parms  = new List<SqlParameter>();
                            
      parms.Add(Database.SqlParm("@clientID",                SqlDbType.Int,       rec.ClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@publicationID",           SqlDbType.Int,       rec.PublicationID,       ParameterDirection.Input));           
      parms.Add(Database.SqlParm("@runDate",                 SqlDbType.DateTime,  rec.RunDate,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@procRunDate",             SqlDbType.DateTime,  rec.ProcRunDate,         ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@referenceDate",           SqlDbType.DateTime,  rec.ReferenceDate,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@OKToPublishUpToDate",     SqlDbType.DateTime,  rec.OKToPublishUpToDate, ParameterDirection.Input));
      
      parms.Add(Database.SqlParm("@actualDateRange1",        SqlDbType.VarChar,   rec.ActualDateRange1,    ParameterDirection.Input, 1000));   
      parms.Add(Database.SqlParm("@status",                  SqlDbType.Int,       rec.Status,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@resultFlags",             SqlDbType.Int,       rec.ResultFlags,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@retryDate",               SqlDbType.DateTime,  rec.RetryDate,           ParameterDirection.Input));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, Constants.SAVE_TYPE_NEW.ToString(), "0", "", "", "REPORT_PUBLICATION_DISTRIBUTION_HISTORY_Save", "Duplicate Record", ref parms,null);
    }     
        
  
  }
}
