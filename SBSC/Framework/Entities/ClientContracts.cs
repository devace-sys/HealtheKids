using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;


namespace Spedmon
{
    
  /***************************************************************************
   * ClientContactsRecord */
  /**
   *
   **************************************************************************/

  public class ClientContractsRecord: Entity
  {
    public long   clientID;
    public string contractNumber;
    public string startDateStr;
    public string endDateStr;
    public long   contractTypeID;
    public long   feeStructureID;
    public string additionalFeeAnswersJSON;
  }

  /***************************************************************************
   * ClientContacts */
  /**
   ***************************************************************************/   
  
  public class ClientContracts:Entities
  {
    public const string VAL_FILE_CLASS_CONTRACT = "50";
    
    /***************************************************************************
     * delete */
    /**
     * "Deletes" record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord delete (  SqlConnection   connSpedmon
                                           , DetailsLog      log
                                           , UserInfo        uInfo
                                           , string          editDelReason
                                           , string          validateRec
                                           , string          recID )
    {           
                
      string deleteSproc  = @"CLIENT_CONTRACTS_DELETE";
    
      /*###########################################################################
        # Validate parameters specific to this entity delete and create their 
        # database parameters.
        ###########################################################################*/  

      Object vClientID = Validate.optClientID(uInfo, "");      
      
      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
     
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.delete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,deleteSproc,ref parms);
    }
    
   /***************************************************************************
    * save */
   /**
    * Save new or update existing record
    *
    * @param  userID          User id of who is recording service
    * @param  userGroup       1 = Client, 2 = SBSC (from users db)
    * @param  userRank        Users role ranking
    * @param  clientID        Client id
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
  
    public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , string        clientID
										 , string        contractNumber
                                         , string        startDate
                                         , string        endDate
										 , string        contractTypeID
										 , string        feeStructureID
										 , string        additionalFeeAnswersJSON
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID)
    {           
                       
      string saveSproc = @"CLIENT_CONTRACTS_SAVE";
      string dupRecMsg = @"Contract already exists";

      /*###########################################################################
        # Validate parameters specific to this entity save and create their 
        # database parameters
        ###########################################################################*/

      var  vClientID                 = Validate.reqClientID (uInfo,                    clientID);
      var  vContractNumber           = Validate.reqString   (contractNumber,           @"Invalid Contract Number");
      var  vStartDate                = Validate.optDate     (startDate,                Messages.INVALID_START_DATE);
      var  vEndDate                  = Validate.optDate     (endDate,                  Messages.INVALID_END_DATE);
      var  vContractTypeID           = Validate.optInteger  (contractTypeID,           Messages.INVALID_NUMBER, true);
      var  vFeeStructureID           = Validate.optInteger  (feeStructureID,           Messages.INVALID_NUMBER, true);
      var  vAdditionalFeeAnswersJSON = Validate.optString   (additionalFeeAnswersJSON, Messages.INVALID_TEXT);
                 
      List<SqlParameter> parms = new List<SqlParameter>();
  
      parms.Add(Database.SqlParm("@clientID",                 SqlDbType.BigInt,   vClientID,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@contractNumber",           SqlDbType.VarChar,  vContractNumber,           ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@startDate",                SqlDbType.DateTime, vStartDate,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",                  SqlDbType.DateTime, vEndDate,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@contractTypeID",           SqlDbType.BigInt,   vContractTypeID,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@feeStructureID",           SqlDbType.BigInt,   vFeeStructureID,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@additionalFeeAnswersJSON", SqlDbType.VarChar,  vAdditionalFeeAnswersJSON, ParameterDirection.Input, -1));
      
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms,null);
    }
     
    /***************************************************************************
     * view */
    /**
     * View client contact roles
     * 
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnDB view ( SqlConnection connSpedmon
                                 , DetailsLog log
                                 , UserInfo uInfo
                                 , int recViewType
                                 , bool   pagedOrTop
                                 , string idx
                                 , string canEdit
                                 , string active
                                 , string clientID
                                 , defineCols dc)
    {

      string viewUDF  = "dbo.CLIENT_CONTRACTS_VIEW (@userID, @userGroup, @userRank, @clientID, @active, @recID)";
      
      /*----------------------------
      * Validate parameters specific
      * to this entity.view
      * and populate their
      * coresponding database
      * parameters
      *----------------------------*/
      
      Object vClientID = Validate.optClientID (uInfo, clientID);

      List<SqlParameter> parms    = new List<SqlParameter>();   

      parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
   
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
    }

    /*************************************************************************
    * viewList */
   /**
    * Return a list of Special Authorization records
    * 
    ***************************************************************************/

    public static List<ClientContractsRecord> viewList( SqlConnection connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo
                                                         , string        clientID
                                                         , string        active)
      
     {
        var recs = new List<ClientContractsRecord>();
        ReturnDB rd = ClientContracts.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, clientID, null);       
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(ClientContractsRecord));
        foreach (var o in slo) {
            recs.Add((ClientContractsRecord) o);
        }
        return recs;
    }

    /***************************************************************************
     * load */
    /**
     * Loads single record
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing client specific data
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static ClientContractsRecord load (  SqlConnection connSpedmon
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , string        clientID
                                                 , string        recID )
    {      
      return (ClientContractsRecord) Entities.load(connSpedmon, log, uInfo, recID, typeof(ClientContractsRecord),
      delegate { return ClientContracts.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, "", "", "", clientID, null); });
    }
  
  }
}
