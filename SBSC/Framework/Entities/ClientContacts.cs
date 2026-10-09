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

  public class ClientContactsRecord: Entity
  {
    public long     clientID;
    public string   contactName;
    public long     contactRoleID;
    public string   contactRoleName;
    public string   email;
    public string   phone;
  }

  /***************************************************************************
   * ClientContacts */
  /**
   ***************************************************************************/   
  
  public class ClientContacts:Entities
  {

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
                
      string deleteSproc  = @"CLIENT_CONTACTS_DELETE";
    
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
										 , string        name
                                         , string        roleID
                                         , string        email
										 , string        phone
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID)
    {           
                       
      string saveSproc = @"CLIENT_CONTACTS_SAVE";
      string dupRecMsg = @"Contact already exists";

      /*###########################################################################
        # Validate parameters specific to this entity save and create their 
        # database parameters
        ###########################################################################*/

      long     vClientID    = Validate.reqClientID (uInfo,  clientID);
      string   vName        = Validate.reqString   (name,   Messages.INVALID_FNAME);
	  long     vRoleID      = Validate.reqInteger  (roleID, Messages.INVALID_NUMBER);      
      string   vEmail       = Validate.reqString   (email,  Messages.INVALID_EMAIL);
      string   vPhone       = Validate.optString   (phone);
                 
      List<SqlParameter> parms = new List<SqlParameter>();
  
      parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt,  vClientID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@name",     SqlDbType.VarChar, vName,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@roleID",   SqlDbType.BigInt,  vRoleID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@email",    SqlDbType.VarChar, vEmail,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@phone",    SqlDbType.VarChar, vPhone,    ParameterDirection.Input));
      
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
                                 , string term
                                 , defineCols dc)
    {

      string viewUDF  = "dbo.CLIENT_CONTACTS_VIEW (@userID, @userGroup, @userRank, @clientID, @active, @term, @recID)";
      
      /*----------------------------
      * Validate parameters specific
      * to this entity.view
      * and populate their
      * coresponding database
      * parameters
      *----------------------------*/
      
      Object vClientID = Validate.optClientID (uInfo, clientID);

      List<SqlParameter> parms    = new List<SqlParameter>();   

      parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt,  vClientID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",     SqlDbType.VarChar, term,      ParameterDirection.Input, 1000));
   
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

    public static List<ClientContactsRecord> viewList( SqlConnection connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo
                                                         , string        clientID
                                                         , string        active)
      
     {
        var recs = new List<ClientContactsRecord>();
        ReturnDB rd = ClientContacts.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, clientID, "", null);       
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(ClientContactsRecord));
        foreach (var o in slo) {
            recs.Add((ClientContactsRecord) o);
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

    public static ClientContactsRecord load (  SqlConnection connSpedmon
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , string        clientID
                                                 , string        recID )
    {      
      return (ClientContactsRecord) Entities.load(connSpedmon, log, uInfo, recID, typeof(ClientContactsRecord),
      delegate { return ClientContacts.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, "", "", "", clientID, "", null); });
    }

    /***************************************************************************
     * viewSel */
    /**
     * 
     ***************************************************************************/

     public static ReturnSel viewSel (  SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID
                                      , string        term )
     {

       string vTerm = Validate.optString(term);

       defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
           ss.addDisplayColumn("[contactRoleName] as recData1");
           ss.addDisplayColumn("[email]           as recData2");
       };
     
       return Entities.viewSel(  connSpedmon
                               , log
                               , uInfo
                               , top
                               , topSize
                               , delegate {
                                   return ClientContacts.view (  connSpedmon
                                                      , log
                                                      , uInfo
                                                      , Entities.REC_VIEW_SEL
                                                      , top
                                                      , topSize
                                                      , ""
                                                      , "1"
                                                      , clientID
                                                      , vTerm
                                                      , dc);});
    
         
     }
  
  }
}
