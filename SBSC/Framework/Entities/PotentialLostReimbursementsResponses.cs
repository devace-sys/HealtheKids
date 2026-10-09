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
   * PotentialLostReimbursementsResponse */
  /**
   *
   **************************************************************************/

  public class PotentialLostReimbursementsResponse: Entity
  {

  }

  /***************************************************************************
   * PotentialLostReimbursementsResponses */
  /**
   ***************************************************************************/   
  
  public class PotentialLostReimbursementsResponses:Entities
  {

    public const string URL_SERVICE_BASE = @"potential_lost_reimbursements_responses.asmx";
    public const string URL_SERVICE_SAVE = URL_SERVICE_BASE + @"/save";

    public const string URL_DEFER_BATCH = URL_SERVICE_BASE + @"/deferbatch";

    public const string URL_UNDEFER_BATCH = URL_SERVICE_BASE + @"/undeferbatch";

    
    /***************************************************************************
     * URL_SERVICE_SAVE_BASE */
    /**
     * 
     **************************************************************************/

    public static string URL_SERVICE_SAVE_BASE()
    {
        return MBA.HttpApplication.createLink(PotentialLostReimbursementsResponses.URL_SERVICE_SAVE, true);
    }

    public static string URL_DEFER_BATCH_BASE()
    {
        return MBA.HttpApplication.createLink(PotentialLostReimbursementsResponses.URL_DEFER_BATCH, true);
    }

    public static string URL_UNDEFER_BATCH_BASE()
    {
        return MBA.HttpApplication.createLink(PotentialLostReimbursementsResponses.URL_UNDEFER_BATCH, true);
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
                                          , string        plrIDString
                                          , string        deferred
                                          , string        notes
                                          , string        editDelReason
                                          , string        validateRec
                                          , string        saveType)
    {           
                       
      string saveSproc = @"POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE";
      string dupRecMsg = @"Record already exists";

      /*###########################################################################
        # Validate parameters specific to this entity save and create their 
        # database parameters
        ###########################################################################*/

      string   vPlrIDString = Validate.reqString (plrIDString, @"Invalid PLR id");
      Object   vDeferred    = Validate.optFlag   (deferred,    @"Invalid defer flag");
      Object   vNotes       = Validate.optString (notes,       Messages.INVALD_NOTES);
                 
      List<SqlParameter> parms = new List<SqlParameter>();
  
      parms.Add(Database.SqlParm("@plrIDString", SqlDbType.VarChar,  vPlrIDString, ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@defer",       SqlDbType.Bit,      vDeferred,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@notes",       SqlDbType.VarChar,  vNotes,       ParameterDirection.Input, -1));
      
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, "1", saveSproc, dupRecMsg, ref parms,null);
    }

    /***************************************************************************
    * _saveBatchCore */
    /**
    * Defer or undefer a multi-selection of PLR rows as deferred.
    *
    * @param  userID          User id of who is recording service
    * @param  userGroup       1 = Client, 2 = SBSC (from users db)
    * @param  userRank        Users role ranking
    * @parm   defer           true = Defer batch, false = Undefer batch
    * @param  recIDMulti      Hyphenated text unique identifiers, separated by commas
    * @return                 ReturnSaveNewRecord
    ***************************************************************************/

    private static ReturnSaveRecord _setDeferBatchCore (   SqlConnection connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo
                                                         , string        clientID  /* For future use */
                                                         , string        recIDMulti
                                                         , bool          defer )
    {

      string opSproc = @"POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SET_DEFER_BATCH";

      var parms = new List<SqlParameter>();     

      parms.Add(Database.SqlParm("@defer",    SqlDbType.Bit,    defer,      ParameterDirection.Input));

      return Entities.recordOpMulti(connSpedmon,log, uInfo,"","N",recIDMulti,opSproc,false, ref parms);
    }

    /***************************************************************************
    *  undeferBatch */
    /**
    * Unflag a multi-selection of PLR rows as deferred.
    *
    * @param  userID          User id of who is recording service
    * @param  userGroup       1 = Client, 2 = SBSC (from users db)
    * @param  userRank        Users role ranking
    * @param  recIDMulti      Hyphenated text unique identifiers, separated by commas
    * @return                 ReturnSaveNewRecord
    ***************************************************************************/

    public static ReturnSaveRecord undeferBatch (  SqlConnection connSpedmon
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , string        clientID
                                                 , string        recIDMulti )
    {
      return _setDeferBatchCore (connSpedmon,log,uInfo,clientID,recIDMulti,false);
    }

    /***************************************************************************
    *  deferBatch */
   /**
    * Flag a multi-selection of PLR rows as deferred.
    *
    * @param  userID          User id of who is recording service
    * @param  userGroup       1 = Client, 2 = SBSC (from users db)
    * @param  userRank        Users role ranking
    * @param  recIDMulti      Hyphenated text unique identifiers, separated by commas
    * @return                 ReturnSaveNewRecord
    ***************************************************************************/

    public static ReturnSaveRecord deferBatch (   SqlConnection connSpedmon
                                                , DetailsLog    log
                                                , UserInfo      uInfo
                                                , string        clientID
                                                , string        recIDMulti )
    {
        return _setDeferBatchCore (connSpedmon,log,uInfo,clientID,recIDMulti,true);
    }
  }
}
