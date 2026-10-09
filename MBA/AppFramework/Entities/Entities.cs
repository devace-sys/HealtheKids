using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;
using MBA.Reporting;

namespace MBA
{
    
  /***************************************************************************
   * Entity */
  /**
   * Anything that is a noun.  Client, practioner, patient, etc are all
   * examples of entities.
   ***************************************************************************/   
  
  public class Entity
  {
    public long     id;               // Unique identifier for this entity
    public string   name;             // Name
    public string   notes;            // Notes
    public bool     active;           // Is this entity active
    public DateTime startDate;
    public DateTime endDate;
  }
  
  /***************************************************************************
   * validateParms */
  /**
   * Pre database call validation of parameters and sanity checks
   ***************************************************************************/   

  public delegate void validateParms();

  /***************************************************************************
   * defineCols */
  /**
   * Pre database call definition of columns for a view sql statement
   ***************************************************************************/   
  
  public delegate void defineCols(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms);
  
  /***************************************************************************
   * viewCall */
  /**
   * Subclass uses this to pass its view method to viewTbl and viewSel
   ***************************************************************************/   
  
  public delegate ReturnDB viewCall();

  /***************************************************************************
   * Entities */
  /**
   * Common methods used for working with entities
   ***************************************************************************/   
  
  public abstract class Entities
  {
        
    /***************************************************************************
     * validateAndAddCommonAddressParameters */
    /**
     * Validates values and adds database parms for common USPS address fields
     * 
     ***************************************************************************/ 

    public static void validateAndAddCommonAddressParameters (  ref string street1
                                                              , ref string street2
                                                              , ref string city
                                                              , ref string state
                                                              , ref string zip5
                                                              , ref string zip4
                                                              , ref List<SqlParameter> parms)
    {
      validateAndAddCommonAddressParameters (  @"@street1"
                                             , @"@street2"
                                             , @"@city"
                                             , @"@state"
                                             , @"@zip5"
                                             , @"@zip4"
                                             , ref street1
                                             , ref street2
                                             , ref city
                                             , ref state
                                             , ref zip5
                                             , ref zip4
                                             , ref parms);
    }                                                              
    
    public static void validateAndAddCommonAddressParameters (  string parmNameStreet1
                                                              , string parmNameStreet2
                                                              , string parmNameCity
                                                              , string parmNameState
                                                              , string parmNameZip5
                                                              , string parmNameZip4
                                                              , ref string street1
                                                              , ref string street2
                                                              , ref string city
                                                              , ref string state
                                                              , ref string zip5
                                                              , ref string zip4
                                                              , ref List<SqlParameter> parms)
    {    
      Object   vStreet1  = Validate.optString  (street1,  Messages.INVALID_STREET);
      Object   vStreet2  = Validate.optString  (street2,  Messages.INVALID_STREET);
      Object   vCity     = Validate.optString  (city,     Messages.INVALID_CITY);
      Object   vState    = Validate.optString  (state,    Messages.INVALID_STATE);
      string   vZip5     = Validate.optZip5    (zip5,     Messages.INVALID_ZIP);
      Object   vZip4     = Validate.optZip4    (zip4,     Messages.INVALID_ZIP);
      
      parms.Add(Database.SqlParm(parmNameStreet1, SqlDbType.VarChar,  vStreet1,   ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm(parmNameStreet2, SqlDbType.VarChar,  vStreet2,   ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm(parmNameCity,    SqlDbType.VarChar,  vCity,      ParameterDirection.Input, 100));
      parms.Add(Database.SqlParm(parmNameState,   SqlDbType.VarChar,  vState,     ParameterDirection.Input, 2));
      parms.Add(Database.SqlParm(parmNameZip5,    SqlDbType.VarChar,  vZip5,      ParameterDirection.Input, 5));
      parms.Add(Database.SqlParm(parmNameZip4,    SqlDbType.VarChar,  vZip4,      ParameterDirection.Input, 4));	    
    }
     
    /***************************************************************************
     * validateAndAddCommonUserInfoParameters */
    /**
     * Validates common user info parameters
     * 
     ***************************************************************************/ 

    public static void validateAndAddCommonUserInfoParameters (  UserInfo uInfo , ref List<SqlParameter> parms)
    {
      parms.Add(Database.SqlParm("@userID",         SqlDbType.BigInt,   uInfo.userid,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",      SqlDbType.Int,      uInfo.userGroup,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",       SqlDbType.Int,      uInfo.userRank,   ParameterDirection.Input));
    }

    /***************************************************************************
     * validateAndAddCommonSaveEntityParameters */
    /**
     * Adds and validates common save entity parameters
     * 
     ***************************************************************************/ 

    public static void validateAndAddCommonSaveEntityParameters (ref List<SqlParameter> parms
                                                                , string editDelReason 
                                                                , bool   vValidateRec
                                                                , int    vSaveType
                                                                , Object vRecID
                                                                , string vDupMsg)
    {
      parms.Add(Database.SqlParm("@editDelReason",SqlDbType.VarChar,  editDelReason,ParameterDirection.Input,7000));          
      parms.Add(Database.SqlParm("@validateRec",  SqlDbType.Bit,      vValidateRec, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@saveType",     SqlDbType.Int,      vSaveType,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recID",        SqlDbType.BigInt,   vRecID,       ParameterDirection.Input));

      parms.Add(Database.SqlParm("@MsgNotActive", SqlDbType.VarChar,  Messages.REC_NOT_ACTIVE,     ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgDupRec",    SqlDbType.VarChar,  vDupMsg,                     ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoRec",     SqlDbType.VarChar,  Messages.EDIT_REC_NOT_FOUND, ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoEdit",    SqlDbType.VarChar,  Messages.EDIT_REC_NO_EDIT,   ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgDataError", SqlDbType.VarChar,  Messages.DATA_ERROR,         ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@recordID",     SqlDbType.BigInt,   null,                        ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",    SqlDbType.VarChar,  null,                        ParameterDirection.Output, 8000));
    
    }
    
    /***************************************************************************
     * load */
    /**
     * Loads an entity record
     * 
     * @param  recID           Record id reference for edit and delete
     * @param  entityType      Type of entity (pass argument with typeof()
     * @param  vc              View call
     * @return                 Object (must cast to desired entity)
     ***************************************************************************/ 

    protected static Object load (SqlConnection connApp, DetailsLog log, UserInfo uInfo, 
                                            string recID, Type entityType, viewCall vc)
    {
      ReturnDB rd = vc();
      
      if (!rd.hasRecords) 
        throw new Warning(Messages.RECORD_NOT_FOUND);
      
      return Database.convertRecord(rd.records,entityType);
    }
        
    /***************************************************************************
     * load */
    /**
     * Loads an entity record but doesnt use record id
     *
     * Note: Use Entities.REC_VIEW_RAW as the view type
     * 
     * @param  entityType      Type of entity (pass argument with typeof()
     * @param  vc              View call
     * @return                 Object (must cast to desired entity)
     ***************************************************************************/ 

    protected static Object load (  SqlConnection connApp
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , Type          entityType
                                  , viewCall      vc )
    {
      ReturnDB rd = vc(); 
           
      if (!rd.hasRecords) return null;
      
      return Database.convertRecord(rd.records,entityType);
    }
    
    /***************************************************************************
     * loadNRecord */
    /**
     * Loads record n in collection of records
     * 
     * @param  recN            Ordinal position of record (starts at 0)
     * @param  entityType      Type of entity (pass argument with typeof()
     * @param  vc              View call
     * @return                 Object (must cast to desired entity)
     ***************************************************************************/ 

    protected static Object loadNRecord (SqlConnection connApp, DetailsLog log, UserInfo uInfo, 
                                         int n, Type entityType, viewCall vc)
    {
      if (n < 0 ) throw new Warning(Messages.INVALID_RECORD_INDEX);
      
      ReturnDB rd = vc();      
      if (!rd.hasRecords) throw new Warning(Messages.RECORD_NOT_FOUND);
      
      Object[] r = Database.convertRecords(rd.records,entityType);
      
      if (r == null)      throw new Warning(Messages.RECORD_NOT_FOUND);
      if (r.Length < n)   throw new Warning(Messages.INVALID_RECORD_INDEX);
      
      return r[n];
    }    
    
    /***************************************************************************
     * loadAllRecords */
    /**
     * Loads records 
     * 
     * @param  entityType      Type of entity (pass argument with typeof()
     * @param  vc              View call
     * @return                 Object (must cast to desired entity)
     ***************************************************************************/

    protected static Object[] loadAllRecords (   SqlConnection connApp
                                                , DetailsLog   log
                                                , UserInfo     uInfo
                                                , Type         entityType
                                                , viewCall     vc
                                                , out bool     hasRecords
                                                , out ReturnDB  rd) 
    {      
      hasRecords = false;
      rd = vc();      
      if (!rd.hasRecords) return null;      
      Object[] r = Database.convertRecords(rd.records,entityType);     
      if (r == null) return null;
      hasRecords = true;     
      return r;
    } 
    
    protected static Object[] loadAllRecords (   SqlConnection connApp
                                                , DetailsLog   log
                                                , UserInfo     uInfo
                                                , Type         entityType
                                                , viewCall     vc
                                                , out bool     hasRecords ) 
    {      
      ReturnDB rd;      
      Object[] r = loadAllRecords(connApp, log, uInfo, entityType, vc, out hasRecords, out rd);     
      return r;
    }    
    
    /***************************************************************************
     * validateAndAddCommonLogUserResponseParameters */
    /**
     * Does what method says
     ***************************************************************************/   

     protected static void validateAndAddCommonLogUserResponseParameters (   UserInfo      uInfo                                            
                                                                           , string        logUserResponseSproc
                                                                           , string        responseTypeID
                                                                           , string        recID
                                                                           , ref List<SqlParameter> parms )
    {
 
       /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters.
       * Note: We perform checks on
       * who can delete what records
       * inside the database
       *----------------------------*/

      long     vRecID           = Validate.reqInteger (recID,                Messages.INVALID_RECORD_ID);
      int      vResponseTypeID  = Validate.reqInteger (responseTypeID,       @"Invalid response type");
      string   vSproc           = Validate.reqString  (logUserResponseSproc, Messages.MISSING_SPROC_OP);
     
      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then delete the entity
       * record.
       * 
       * Note: We do not include
       * clientID here (even though
       * it is used quite often)
       * because this is a generic
       * method and client is an
       * entity
       *----------------------------*/
            
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      
      parms.Add(Database.SqlParm("@responseTypeID", SqlDbType.Int,      vResponseTypeID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recID",          SqlDbType.BigInt,   vRecID,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recordID",       SqlDbType.BigInt,   null,             ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",      SqlDbType.VarChar,  null,             ParameterDirection.Output, 8000));

    }
    
    /***************************************************************************
     * logUserResponse */
    /**
     * Calls a log sproc
     * 
     * @param  recID           Record id reference for edit and delete
     * @param  logSproc        The name of the sproc
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
    
    protected static ReturnSaveRecord logUserResponse (  SqlConnection connApp
                                                       , DetailsLog    log
                                                       , UserInfo      uInfo                                            
                                                       , string        logUserResponseSproc
                                                       , string        responseTypeID
                                                       , string        recID
                                                       , ref List<SqlParameter> parms)
    {           
      
      ReturnSaveRecord so = new ReturnSaveRecord();
      validateAndAddCommonLogUserResponseParameters(uInfo,logUserResponseSproc,responseTypeID,recID, ref parms);

      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, logUserResponseSproc, parms); 
      so = (ReturnSaveRecord) Database.convertParameters(rd,typeof(ReturnSaveRecord));
      return so;
    }
        
    /***************************************************************************
     * logUserResponseAndReturnJSONData */
    /**
     * Calls a log sproc
     * 
     * @param  recID           Record id reference for edit and delete
     * @param  logSproc        The name of the sproc
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
    
    protected static ReturnSaveRecordWithJSONData logUserResponseAndReturnJSONData (  SqlConnection connApp
                                                                                     , DetailsLog    log
                                                                                     , UserInfo      uInfo                                            
                                                                                     , string        logUserResponseSproc
                                                                                     , string        responseTypeID
                                                                                     , string        recID
                                                                                     , ref List<SqlParameter> parms)
    {           
      
      ReturnSaveRecordWithJSONData so = new ReturnSaveRecordWithJSONData();
      
      validateAndAddCommonLogUserResponseParameters(uInfo,logUserResponseSproc,responseTypeID,recID, ref parms);
      
      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, logUserResponseSproc, parms); 
      so = (ReturnSaveRecordWithJSONData) Database.convertParameters(rd,typeof(ReturnSaveRecordWithJSONData));
      return so;
    }
        

    /***************************************************************************
     * logUserResponses */
    /**
     * Calls a log sproc
     * 
     * @param  recID           Record id reference for edit and delete
     * @param  logSproc        The name of the delete sproc
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
    
    protected static ReturnSaveRecord logUserResponses ( SqlConnection connApp
                                                       , DetailsLog    log
                                                       , UserInfo      uInfo
                                                       , string        logUserResponsesSproc
                                                       , string        responseTypeID
                                                       , string        recIDMulti
                                                       , ref List<SqlParameter> parms)
    {           
      
      ReturnSaveRecord so = new ReturnSaveRecord();
      
      /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters.
       * Note: We perform checks on
       * who can delete what records
       * inside the database
       *----------------------------*/

      string   vRecIDMultiStr   = Validate.reqString     (recIDMulti,            Messages.INVALID_RECORD_ID);
      int[]    vRecIDMultiVal   = Validate.reqRecIDMulti (vRecIDMultiStr,        Messages.INVALID_RECORD_ID);
      int      vResponseTypeID  = Validate.reqInteger    (responseTypeID,        @"Invalid response type");
      string   vSproc           = Validate.reqString     (logUserResponsesSproc, Messages.MISSING_SPROC_OP);
     
      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then delete the entity
       * record.
       * 
       * Note: We do not include
       * clientID here (even though
       * it is used quite often)
       * because this is a generic
       * method and client is an
       * entity
       *----------------------------*/
            
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      
      parms.Add(Database.SqlParm("@responseTypeID", SqlDbType.Int,      vResponseTypeID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recIDMulti",     SqlDbType.VarChar,  vRecIDMultiStr,   ParameterDirection.Input, 8000)); 
      parms.Add(Database.SqlParm("@recordID",       SqlDbType.BigInt,   null,             ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",      SqlDbType.VarChar,  null,             ParameterDirection.Output, 8000));

      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, vSproc, parms); 
      so = (ReturnSaveRecord) Database.convertParameters(rd,typeof(ReturnSaveRecord));
      return so;
    }
        
    /***************************************************************************
     * recordOp */
    /**
     * Performs an operation against record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @param  deleteSproc     The name of the delete sproc
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
    
    protected static ReturnSaveRecord recordOp (SqlConnection connApp, DetailsLog log, UserInfo uInfo, 
                                           string editDelReason, 
                                           string validateRec, 
                                           string recID, 
                                           string opSproc, 
                                           ref List<SqlParameter> parms)
    {           
      
      ReturnSaveRecord so = new ReturnSaveRecord();
      
      /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters.
       * Note: We perform checks on
       * who can delete what records
       * inside the database
       *----------------------------*/

      bool     vValidateRec   = Validate.reqFlag    (validateRec,             Messages.INVALID_VALIDATE_FLAG);
      long     vRecID         = Validate.reqInteger (recID,                   Messages.INVALID_RECORD_ID);
      string   vSproc         = Validate.reqString  (opSproc,                 Messages.MISSING_SPROC_DEL);

      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then delete the entity
       * record.
       * 
       * Note: We do not include
       * clientID here (even though
       * it is used quite often)
       * because this is a generic
       * method and client is an
       * entity
       *----------------------------*/
            
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      
      parms.Add(Database.SqlParm("@editDelReason",  SqlDbType.VarChar,  editDelReason,    ParameterDirection.Input,7000));          
      parms.Add(Database.SqlParm("@validateRec",    SqlDbType.Bit,      vValidateRec,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recID",          SqlDbType.BigInt,   vRecID,           ParameterDirection.Input));

      parms.Add(Database.SqlParm("@MsgNoRec",     SqlDbType.VarChar,  Messages.EDIT_REC_NOT_FOUND, ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoEdit",    SqlDbType.VarChar,  Messages.EDIT_REC_NO_EDIT,   ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@recordID",     SqlDbType.BigInt,   null,                        ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",    SqlDbType.VarChar,  null,                        ParameterDirection.Output, 8000));

      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, vSproc, parms); 
      if ((log.hasDetails) && (vValidateRec)) {throw new Warning(Messages.VALIDATION_ISSUES);}
      so = (ReturnSaveRecord) Database.convertParameters(rd,typeof(ReturnSaveRecord));
      return so;
    }
    
    /***************************************************************************
     * recordOpMulti */
    /**
     * Performs an operation against record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @param  deleteSproc     The name of the delete sproc
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
    
    protected static ReturnSaveRecord recordOpMulti (  SqlConnection connApp
                                                     , DetailsLog    log
                                                     , UserInfo      uInfo
                                                     , string        editDelReason 
                                                     , string        validateRec 
                                                     , string        recIDMulti 
                                                     , string        opSproc
                                                     , bool          recIDsAreInts
                                                     , ref           List<SqlParameter> parms)
    {           
      
      ReturnSaveRecord so = new ReturnSaveRecord();
      
      /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters.
       * Note: We perform checks on
       * who can delete what records
       * inside the database
       *----------------------------*/

      bool     vValidateRec     = Validate.reqFlag       (validateRec,     Messages.INVALID_VALIDATE_FLAG);
      string   vRecIDMultiStr   = Validate.reqString     (recIDMulti,      Messages.INVALID_RECORD_ID);
      string   vSproc           = Validate.reqString     (opSproc,         Messages.MISSING_SPROC_OP);
      
      /* If the record ids are integers then we can check for data integrity here 
        * Otherwise data integrity checks are the responsibility of the sproc. */
      if (recIDsAreInts == true) { 
        int[] vRecIDMultiVal = Validate.reqRecIDMulti (vRecIDMultiStr, Messages.INVALID_RECORD_ID);
      }
      
      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then delete the entity
       * record.
       * 
       * Note: We do not include
       * clientID here (even though
       * it is used quite often)
       * because this is a generic
       * method and client is an
       * entity
       *----------------------------*/
            
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      
      parms.Add(Database.SqlParm("@editDelReason",  SqlDbType.VarChar,  editDelReason,    ParameterDirection.Input,7000));          
      parms.Add(Database.SqlParm("@validateRec",    SqlDbType.Bit,      vValidateRec,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recIDMulti",     SqlDbType.VarChar,  vRecIDMultiStr,   ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@MsgNoRec",       SqlDbType.VarChar,  Messages.EDIT_REC_NOT_FOUND, ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoEdit",      SqlDbType.VarChar,  Messages.EDIT_REC_NO_EDIT,   ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@recordID",       SqlDbType.BigInt,   null,                        ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",      SqlDbType.VarChar,  null,                        ParameterDirection.Output, 8000));

      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, vSproc, parms); 
      if ((log.hasDetails) && (vValidateRec)) {throw new Warning(Messages.VALIDATION_ISSUES);}
      so = (ReturnSaveRecord) Database.convertParameters(rd,typeof(ReturnSaveRecord));
      return so;
    }


    protected static ReturnSaveRecord recordOpArbitraryDataPayload (SqlConnection connApp, DetailsLog log, UserInfo uInfo, 
                                           string editDelReason, 
                                           string validateRec, 
                                           string recIDMulti, 
                                           string opSproc, 
                                           ref List<SqlParameter> parms)
    {           
      
      ReturnSaveRecord so = new ReturnSaveRecord();
      
      /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters.
       * Note: We perform checks on
       * who can delete what records
       * inside the database
       *----------------------------*/

      bool     vValidateRec     = Validate.reqFlag       (validateRec,     Messages.INVALID_VALIDATE_FLAG);
      string   vRecIDMultiStr   = Validate.reqString     (recIDMulti,      Messages.INVALID_RECORD_ID);
      //int[]    vRecIDMultiVal   = Validate.reqRecIDMulti (vRecIDMultiStr,  Messages.INVALID_RECORD_ID);
      string   vSproc           = Validate.reqString     (opSproc,         Messages.MISSING_SPROC_OP);

      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then delete the entity
       * record.
       * 
       * Note: We do not include
       * clientID here (even though
       * it is used quite often)
       * because this is a generic
       * method and client is an
       * entity
       *----------------------------*/
      
      //parms.Add(Database.SqlParm("@userID",         SqlDbType.BigInt,   uInfo.userid,     ParameterDirection.Input));
      //parms.Add(Database.SqlParm("@userGroup",      SqlDbType.Int,      uInfo.userGroup,  ParameterDirection.Input));
      //parms.Add(Database.SqlParm("@userRank",       SqlDbType.Int,      uInfo.userRank,   ParameterDirection.Input));
      
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      
      parms.Add(Database.SqlParm("@editDelReason",  SqlDbType.VarChar,  editDelReason,    ParameterDirection.Input,7000));          
      parms.Add(Database.SqlParm("@validateRec",    SqlDbType.Bit,      vValidateRec,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recIDMulti",     SqlDbType.VarChar,  vRecIDMultiStr,   ParameterDirection.Input, 8000));      
      parms.Add(Database.SqlParm("@MsgNoRec",       SqlDbType.VarChar,  Messages.EDIT_REC_NOT_FOUND, ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoEdit",      SqlDbType.VarChar,  Messages.EDIT_REC_NO_EDIT,   ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@recordID",       SqlDbType.BigInt,   null,                        ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",      SqlDbType.VarChar,  null,                        ParameterDirection.Output, 8000));

      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, vSproc, parms); 
      if ((log.hasDetails) && (vValidateRec)) {throw new Warning(Messages.VALIDATION_ISSUES);}
      so = (ReturnSaveRecord) Database.convertParameters(rd,typeof(ReturnSaveRecord));
      return so;
    }
    
    /***************************************************************************
     * activateDeactivate */
    /**
     * Toggles the entities active/deactive flag
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @param  deleteSproc     The name of the delete sproc
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    protected static ReturnSaveRecord activateDeactivate (SqlConnection connApp, DetailsLog log, UserInfo uInfo, 
                                           string editDelReason, 
                                           string validateRec, 
                                           string recID, 
                                           string active, 
                                           string effectiveDate,
                                           string activateDeactivateSproc, ref List<SqlParameter> parms)
    {           
      
      ReturnSaveRecord so = new ReturnSaveRecord();
      
      /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters.
       * Note: We perform checks on
       * who can delete what records
       * inside the database
       *----------------------------*/

      bool     vValidateRec   = Validate.reqFlag    (validateRec,             Messages.INVALID_VALIDATE_FLAG);
      long     vRecID         = Validate.reqInteger (recID,                   Messages.INVALID_RECORD_ID);
      bool     vActive        = Validate.reqFlag    (active,                  Messages.INVALID_FLAG_ACTIVE);
      DateTime vEffectiveDate = Validate.reqDate    (effectiveDate,           Messages.INVALID_EFFECTIVE_DATE);      
      string   vSproc         = Validate.reqString  (activateDeactivateSproc, Messages.MISSING_SPROC_DEL);

      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then delete the entity
       * record.
       * 
       * Note: We do not include
       * clientID here (even though
       * it is used quite often)
       * because this is a generic
       * method and client is an
       * entity
       *----------------------------*/
      
      //parms.Add(Database.SqlParm("@userID",         SqlDbType.BigInt,   uInfo.userid,     ParameterDirection.Input));
      //parms.Add(Database.SqlParm("@userGroup",      SqlDbType.Int,      uInfo.userGroup,  ParameterDirection.Input));
      //parms.Add(Database.SqlParm("@userRank",       SqlDbType.Int,      uInfo.userRank,   ParameterDirection.Input));
      
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      
      parms.Add(Database.SqlParm("@editDelReason",  SqlDbType.VarChar,  editDelReason,    ParameterDirection.Input,7000));          
      parms.Add(Database.SqlParm("@validateRec",    SqlDbType.Bit,      vValidateRec,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recID",          SqlDbType.BigInt,   vRecID,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@active",         SqlDbType.Bit,      vActive,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@effectiveDate",  SqlDbType.DateTime, vEffectiveDate,   ParameterDirection.Input));

      parms.Add(Database.SqlParm("@MsgNoRec",     SqlDbType.VarChar,  Messages.EDIT_REC_NOT_FOUND, ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoEdit",    SqlDbType.VarChar,  Messages.EDIT_REC_NO_EDIT,   ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@recordID",     SqlDbType.BigInt,   null,                        ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",    SqlDbType.VarChar,  null,                        ParameterDirection.Output, 8000));

      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, vSproc, parms); 
      if ((log.hasDetails) && (vValidateRec)) {throw new Warning(Messages.VALIDATION_ISSUES);}
      so = (ReturnSaveRecord) Database.convertParameters(rd,typeof(ReturnSaveRecord));
      return so;
    }
    
    /***************************************************************************
     * delete */
    /**
     * "Deletes" an entity record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @param  deleteSproc     The name of the delete sproc
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    protected static ReturnSaveRecord delete (SqlConnection connApp, DetailsLog log, UserInfo uInfo, 
                                           string editDelReason, string validateRec, string recID,
                                           string deleteSproc, ref List<SqlParameter> parms)
    {           
      
      ReturnSaveRecord so = new ReturnSaveRecord();
      
      /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters.
       * Note: We perform checks on
       * who can delete what records
       * inside the database
       *----------------------------*/

      bool     vValidateRec = Validate.reqFlag    (validateRec, Messages.INVALID_VALIDATE_FLAG);
      long     vRecID       = Validate.reqInteger (recID,       Messages.INVALID_RECORD_ID);
      string   vDeleteSproc = Validate.reqString  (deleteSproc, Messages.MISSING_SPROC_DEL);

      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then delete the entity
       * record.
       * 
       * Note: We do not include
       * clientID here (even though
       * it is used quite often)
       * because this is a generic
       * method and client is an
       * entity
       *----------------------------*/
      
      //parms.Add(Database.SqlParm("@userID",       SqlDbType.BigInt,   uInfo.userid,     ParameterDirection.Input));
      //parms.Add(Database.SqlParm("@userGroup",    SqlDbType.Int,      uInfo.userGroup,  ParameterDirection.Input));
      //parms.Add(Database.SqlParm("@userRank",     SqlDbType.Int,      uInfo.userRank,   ParameterDirection.Input));
      
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      
      parms.Add(Database.SqlParm("@editDelReason",SqlDbType.VarChar,  editDelReason,ParameterDirection.Input,7000));          
      parms.Add(Database.SqlParm("@validateRec",  SqlDbType.Bit,      vValidateRec, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recID",        SqlDbType.BigInt,   vRecID,       ParameterDirection.Input));

      parms.Add(Database.SqlParm("@MsgNoRec",     SqlDbType.VarChar,  Messages.EDIT_REC_NOT_FOUND, ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoEdit",    SqlDbType.VarChar,  Messages.EDIT_REC_NO_EDIT,   ParameterDirection.Input, 1000));

      parms.Add(Database.SqlParm("@recordID",     SqlDbType.BigInt,   null,                        ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",    SqlDbType.VarChar,  null,                        ParameterDirection.Output, 8000));

      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, vDeleteSproc, parms); 
      if ((log.hasDetails) && (vValidateRec)) {throw new Warning(Messages.VALIDATION_ISSUES);}
      so = (ReturnSaveRecord) Database.convertParameters(rd,typeof(ReturnSaveRecord));
      return so;
    }

    /***************************************************************************
     * deleteBatch */
    /**
     * "Deletes" one or more entity record(s)
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recIDs          CSV string containing one or more record ids
     * @param  deleteSproc     The name of the delete batch sproc
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
   
    protected static ReturnSaveRecord deleteBatch (SqlConnection connApp, DetailsLog log, UserInfo uInfo, 
                                                 string editDelReason, string validateRec, string recIDMulti,
                                                 string deleteSproc, ref List<SqlParameter> parms)
    {           
      
      ReturnSaveRecord so = new ReturnSaveRecord();
      
      /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters.
       * Note: We perform checks on
       * who can delete what records
       * inside the database
       *----------------------------*/

      bool     vValidateRec     = Validate.reqFlag       (validateRec,     Messages.INVALID_VALIDATE_FLAG);
      string   vRecIDMultiStr   = Validate.reqString     (recIDMulti,      Messages.INVALID_RECORD_ID);
      int[]    vRecIDMultiVal   = Validate.reqRecIDMulti (vRecIDMultiStr,  Messages.INVALID_RECORD_ID);
      string   vDeleteSproc     = Validate.reqString     (deleteSproc,     Messages.MISSING_SPROC_DEL);

      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then delete the entity
       * record.
       * 
       * Note: We do not include
       * clientID here (even though
       * it is used quite often)
       * because this is a generic
       * method and client is an
       * entity
       *----------------------------*/
      
      //parms.Add(Database.SqlParm("@userID",       SqlDbType.BigInt,   uInfo.userid,     ParameterDirection.Input));
      //parms.Add(Database.SqlParm("@userGroup",    SqlDbType.Int,      uInfo.userGroup,  ParameterDirection.Input));
      //parms.Add(Database.SqlParm("@userRank",     SqlDbType.Int,      uInfo.userRank,   ParameterDirection.Input));

      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      
      parms.Add(Database.SqlParm("@editDelReason",SqlDbType.VarChar,  editDelReason,    ParameterDirection.Input, 7000));          
      parms.Add(Database.SqlParm("@validateRec",  SqlDbType.Bit,      vValidateRec,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recIDMulti",   SqlDbType.VarChar,  vRecIDMultiStr,   ParameterDirection.Input, 8000));

      parms.Add(Database.SqlParm("@MsgNoRec",     SqlDbType.VarChar,  Messages.EDIT_REC_NOT_FOUND, ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoEdit",    SqlDbType.VarChar,  Messages.EDIT_REC_NO_EDIT,   ParameterDirection.Input, 1000));

      parms.Add(Database.SqlParm("@recordID",     SqlDbType.BigInt,   null,                        ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",    SqlDbType.VarChar,  null,                        ParameterDirection.Output, 8000));

      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, vDeleteSproc, parms); 
      if ((log.hasDetails) && (vValidateRec)) {throw new Warning(Messages.VALIDATION_ISSUES);}
      so = (ReturnSaveRecord) Database.convertParameters(rd,typeof(ReturnSaveRecord));     
      return so;
    }                
    
    /***************************************************************************
     * deleteAll */
    /**
     * Used in operations where you need to blanket delete multiple entity records
     * that match data passed in parameters.  The stored procedure is responsible 
     * for determining what parameters are passed and what records are deleted or 
     * deactivated.
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @param  deleteSproc     The name of the delete sproc
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    protected static ReturnSaveRecord deleteAll ( SqlConnection connApp
                                                 , DetailsLog   log
                                                 , UserInfo     uInfo
                                                 , string       editDelReason
                                                 , string       validateRec
                                                 , string       deleteAllSproc
                                                 , ref List<SqlParameter> parms)
    {           
      
      ReturnSaveRecord so = new ReturnSaveRecord();
      
      /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters.
       * Note: We perform checks on
       * who can delete what records
       * inside the database
       *----------------------------*/

      bool     vValidateRec = Validate.reqFlag    (validateRec,    Messages.INVALID_VALIDATE_FLAG);
      string   vDeleteSproc = Validate.reqString  (deleteAllSproc, Messages.MISSING_SPROC_DEL);

      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then delete the entity
       * record.
       * 
       * Note: We do not include
       * clientID here (even though
       * it is used quite often)
       * because this is a generic
       * method and client is an
       * entity
       *----------------------------*/
            
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      
      parms.Add(Database.SqlParm("@editDelReason",SqlDbType.VarChar,  editDelReason,ParameterDirection.Input,7000));          
      parms.Add(Database.SqlParm("@validateRec",  SqlDbType.Bit,      vValidateRec, ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@MsgNoRec",     SqlDbType.VarChar,  Messages.EDIT_REC_NOT_FOUND, ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoEdit",    SqlDbType.VarChar,  Messages.EDIT_REC_NO_EDIT,   ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@recordID",     SqlDbType.BigInt,   null,                        ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",    SqlDbType.VarChar,  null,                        ParameterDirection.Output, 8000));

      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, vDeleteSproc, parms); 
      if ((log.hasDetails) && (vValidateRec)) {throw new Warning(Messages.VALIDATION_ISSUES);}
      so = (ReturnSaveRecord) Database.convertParameters(rd,typeof(ReturnSaveRecord));
      return so;
    }

    /***************************************************************************
     * updateAll */
    /**
     * Used in operations where you need to blanket update multiple entity records
     * that match data passed in parameters.  The stored procedure is responsible 
     * for determining what parameters are passed and what records are updated
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @param  deleteSproc     The name of the delete sproc
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    protected static ReturnSaveRecord updateAll ( SqlConnection connApp
                                                 , DetailsLog   log
                                                 , UserInfo     uInfo
                                                 , string       editDelReason
                                                 , string       validateRec
                                                 , string       updateAllSproc
                                                 , ref List<SqlParameter> parms)
    {           
      
      ReturnSaveRecord so = new ReturnSaveRecord();
      
      /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters.
       * Note: We perform checks on
       * who can delete what records
       * inside the database
       *----------------------------*/

      bool     vValidateRec    = Validate.reqFlag    (validateRec,    Messages.INVALID_VALIDATE_FLAG);
      string   vUpdateAllSproc = Validate.reqString  (updateAllSproc, Messages.MISSING_SPROC_SAVE);

      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then delete the entity
       * record.
       * 
       * Note: We do not include
       * clientID here (even though
       * it is used quite often)
       * because this is a generic
       * method and client is an
       * entity
       *----------------------------*/
            
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      
      parms.Add(Database.SqlParm("@editDelReason",SqlDbType.VarChar,  editDelReason,ParameterDirection.Input,7000));          
      parms.Add(Database.SqlParm("@validateRec",  SqlDbType.Bit,      vValidateRec, ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@MsgNoRec",     SqlDbType.VarChar,  Messages.EDIT_REC_NOT_FOUND, ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoEdit",    SqlDbType.VarChar,  Messages.EDIT_REC_NO_EDIT,   ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@recordID",     SqlDbType.BigInt,   null,                        ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",    SqlDbType.VarChar,  null,                        ParameterDirection.Output, 8000));

      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, vUpdateAllSproc, parms); 
      if ((log.hasDetails) && (vValidateRec)) {throw new Warning(Messages.VALIDATION_ISSUES);}
      so = (ReturnSaveRecord) Database.convertParameters(rd,typeof(ReturnSaveRecord));
      return so;
    }

    /***************************************************************************
     * unDelete */
    /**
     * "Undeletes" an entity record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @param  deleteSproc     The name of the delete sproc
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    protected static ReturnSaveRecord unDelete (SqlConnection connApp, DetailsLog log, UserInfo uInfo, 
                                           string editDelReason, string validateRec, string recID,
                                           string deleteSproc, ref List<SqlParameter> parms)
    {           
      
      ReturnSaveRecord so = new ReturnSaveRecord();
      
      /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters.
       * Note: We perform checks on
       * who can delete what records
       * inside the database
       *----------------------------*/

      bool     vValidateRec = Validate.reqFlag    (validateRec, Messages.INVALID_VALIDATE_FLAG);
      long     vRecID       = Validate.reqInteger (recID,       Messages.INVALID_RECORD_ID);
      string   vDeleteSproc = Validate.reqString  (deleteSproc, Messages.MISSING_SPROC_DEL);

      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then delete the entity
       * record.
       * 
       * Note: We do not include
       * clientID here (even though
       * it is used quite often)
       * because this is a generic
       * method and client is an
       * entity
       *----------------------------*/
      
      //parms.Add(Database.SqlParm("@userID",       SqlDbType.BigInt,   uInfo.userid,     ParameterDirection.Input));
      //parms.Add(Database.SqlParm("@userGroup",    SqlDbType.Int,      uInfo.userGroup,  ParameterDirection.Input));
      //parms.Add(Database.SqlParm("@userRank",     SqlDbType.Int,      uInfo.userRank,   ParameterDirection.Input));

      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      
      parms.Add(Database.SqlParm("@editDelReason",SqlDbType.VarChar,  editDelReason,ParameterDirection.Input,7000));          
      parms.Add(Database.SqlParm("@validateRec",  SqlDbType.Bit,      vValidateRec, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recID",        SqlDbType.BigInt,   vRecID,       ParameterDirection.Input));

      parms.Add(Database.SqlParm("@MsgNoRec",     SqlDbType.VarChar,  Messages.EDIT_REC_NOT_FOUND, ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoEdit",    SqlDbType.VarChar,  Messages.EDIT_REC_NO_EDIT,   ParameterDirection.Input, 1000));

      parms.Add(Database.SqlParm("@recordID",     SqlDbType.BigInt,   null,                        ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",    SqlDbType.VarChar,  null,                        ParameterDirection.Output, 8000));

      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, vDeleteSproc, parms); 
      if ((log.hasDetails) && (vValidateRec)) {throw new Warning(Messages.VALIDATION_ISSUES);}
      so = (ReturnSaveRecord) Database.convertParameters(rd,typeof(ReturnSaveRecord));
      return so;
    }
        

    /***************************************************************************
     * merge */
    /**
     * Merge into one
     * 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @param  deleteSproc     The name of the delete sproc
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
    
    protected static ReturnSaveRecord merge (  SqlConnection connApp
                                             , DetailsLog    log
                                             , UserInfo      uInfo
                                             , string        recIDToKeep
                                             , string        recIDsToMerge
                                             , string        validateRec
                                             , string        mergeSproc
                                             , ref List<SqlParameter> parms)
    {           
      
      ReturnSaveRecord so = new ReturnSaveRecord();
      
      /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters.
       * Note: We perform checks on
       * who can delete what records
       * inside the database
       *----------------------------*/

      string   vRecIDsToMerge   = Validate.reqString     (recIDsToMerge,   Messages.INVALID_RECORD_ID);      
      
      /* Check length of recIDs*/
      
      int[]    vRecIDMultiVal   = Validate.reqRecIDMulti (vRecIDsToMerge,  Messages.INVALID_RECORD_ID);      
      bool     vValidateRec     = Validate.reqFlag       (validateRec,     Messages.INVALID_VALIDATE_FLAG);     
      string   vMergeSproc      = Validate.reqString     (mergeSproc,      Messages.MISSING_SPROC_OP); 
      Object   vRecIDToKeep     = Validate.optInteger    (recIDToKeep,     Messages.INVALID_RECORD_ID);
      
      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then merge the entity
       * records.
       *----------------------------*/
      
      //parms.Add(Database.SqlParm("@userID",         SqlDbType.BigInt,   uInfo.userid,     ParameterDirection.Input));
      //parms.Add(Database.SqlParm("@userGroup",      SqlDbType.Int,      uInfo.userGroup,  ParameterDirection.Input));
      //parms.Add(Database.SqlParm("@userRank",       SqlDbType.Int,      uInfo.userRank,   ParameterDirection.Input));
      
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);

      parms.Add(Database.SqlParm("@recIDToKeep", SqlDbType.BigInt, vRecIDToKeep, ParameterDirection.Input));

      parms.Add(Database.SqlParm("@validateRec",    SqlDbType.Bit,      vValidateRec,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recIDsToMerge",  SqlDbType.VarChar,  vRecIDsToMerge,   ParameterDirection.Input, 8000));            
      parms.Add(Database.SqlParm("@recordID",       SqlDbType.BigInt,   null,             ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",      SqlDbType.VarChar,  null,             ParameterDirection.Output, 8000));

      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, vMergeSproc, parms); 
      if ((log.hasDetails) && (vValidateRec)) {throw new Warning(Messages.VALIDATION_ISSUES);}
      so = (ReturnSaveRecord) Database.convertParameters(rd,typeof(ReturnSaveRecord));
      return so;
    }
   
    /***************************************************************************
     * save */
    /**
     * Saves an entity record
     *
     * @param  saveType        Type of save (1=new, 2=edit, 3=delete)
     * @param  validateRec     Perform validation for this record?
     * @param  editDelReason   Reason for edit/delete 
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    protected static ReturnSaveRecord save (   SqlConnection          connApp
                                             , DetailsLog             log
                                             , UserInfo               uInfo 
                                             , string                 saveType
                                             , string                 validateRec                               
                                             , string                 editDelReason 
                                             , string                 recID
                                             , string                 saveSproc
                                             , string                 dupRecordMsg
                                             , ref List<SqlParameter> parms
                                             , validateParms          vp
                                             , SqlTransaction tx = null)
    {           
      
       ReturnSaveRecord so = new ReturnSaveRecord();
      
      /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters
       *----------------------------*/

      bool     vValidateRec = Validate.reqFlag    (validateRec,  Messages.INVALID_VALIDATE_FLAG);
      int      vSaveType    = Validate.reqInteger (saveType,     Messages.INVALID_SAVE_TYPE);
      string   vSaveSproc   = Validate.reqString  (saveSproc,    Messages.MISSING_SPROC_SAVE);

      string   vDupMsg      = Validate.reqString  (dupRecordMsg, Messages.MISSING_DUP_MSG);

      /*----------------------------
       * If the save type is an edit
       * or delete we require the 
       * record id
       *----------------------------*/
      
      Object vRecID;
      if ((vSaveType == Constants.SAVE_TYPE_EDIT) || (vSaveType == Constants.SAVE_TYPE_DELETE))
        vRecID = Validate.reqInteger (recID, Messages.INVALID_RECORD_ID);
      else
        vRecID = Validate.optInteger (recID, Messages.INVALID_RECORD_ID);
      
      
      /*----------------------------
       * If the save type is a new
       * copy, or edit we perform some 
       * initial data sanity check tasks.
       * if validation is requested.
       * We perform some of these checks
       * here and some in the stored
       * procedure call.  The tasks
       * performed here are those
       * that do not require data
       * lookups.
       *----------------------------*/

      if ((vValidateRec) && (vp != null) && ((vSaveType == Constants.SAVE_TYPE_NEW) || (vSaveType == Constants.SAVE_TYPE_COPY) || (vSaveType == Constants.SAVE_TYPE_EDIT))) vp();
      
      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then save the entity
       * record.
       *----------------------------*/
     
      /*----------------------------
       * Add commonly used parameters
       *----------------------------*/

      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      validateAndAddCommonSaveEntityParameters (ref parms , editDelReason ,  vValidateRec,  vSaveType, vRecID, vDupMsg);


      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
     
      ReturnDB rd;
      if (tx == null)
        rd = Database.execSproc(connApp, log, vSaveSproc, parms); 
      else
        rd= Database.execSproc(connApp, log, vSaveSproc, parms,tx);
      
      if ((log.hasDetails) && (vValidateRec))
        /* Throw warning so we can exit... but do not add warning to log */
        throw new Warning(Messages.VALIDATION_ISSUES,true);

      so = (ReturnSaveRecord) Database.convertParameters(rd,typeof(ReturnSaveRecord));
      
      return so;
    
    }
            
    /***************************************************************************
     * saveAndReturnRecordData */
    /**
     * Saves an entity record
     *
     * @param  saveType        Type of save (1=new, 2=edit, 3=delete)
     * @param  validateRec     Perform validation for this record?
     * @param  editDelReason   Reason for edit/delete 
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    protected static ReturnSaveRecordWithRecordData saveAndReturnRecordData (   SqlConnection connApp
                                                                              , DetailsLog log
                                                                              , UserInfo uInfo
                                                                              , string saveType
                                                                              , string validateRec
                                                                              , string editDelReason
                                                                              , string recID
                                                                              , string saveSproc
                                                                              , string dupRecordMsg
                                                                              , ref List<SqlParameter> parms
                                                                              , validateParms          vp )
    {           
      
       ReturnSaveRecordWithRecordData so = new ReturnSaveRecordWithRecordData();
      
      /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters
       *----------------------------*/

      bool     vValidateRec = Validate.reqFlag    (validateRec,  Messages.INVALID_VALIDATE_FLAG);
      int      vSaveType    = Validate.reqInteger (saveType,     Messages.INVALID_SAVE_TYPE);
      string   vSaveSproc   = Validate.reqString  (saveSproc,    Messages.MISSING_SPROC_SAVE);
      string   vDupMsg      = Validate.reqString  (dupRecordMsg, Messages.MISSING_DUP_MSG);

      /*----------------------------
       * If the save type is an edit
       * or delete we require the 
       * record id
       *----------------------------*/
      
      Object vRecID;
      if ((vSaveType == Constants.SAVE_TYPE_EDIT) || (vSaveType == Constants.SAVE_TYPE_DELETE))
        vRecID = Validate.reqInteger (recID, Messages.INVALID_RECORD_ID);
      else
        vRecID = Validate.optInteger (recID, Messages.INVALID_RECORD_ID);
      
      
      /*----------------------------
       * If the save type is a new
       * copy, or edit we perform some 
       * initial data sanity check tasks.
       * if validation is requested.
       * We perform some of these checks
       * here and some in the stored
       * procedure call.  The tasks
       * performed here are those
       * that do not require data
       * lookups.
       *----------------------------*/

      if ((vValidateRec) && (vp != null) && ((vSaveType == Constants.SAVE_TYPE_NEW) || (vSaveType == Constants.SAVE_TYPE_COPY) || (vSaveType == Constants.SAVE_TYPE_EDIT))) vp();
      
      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then save the entity
       * record.
       *----------------------------*/
     
      /*----------------------------
       * Add commonly used parameters
       *----------------------------*/

      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      validateAndAddCommonSaveEntityParameters (ref parms , editDelReason ,  vValidateRec,  vSaveType, vRecID, vDupMsg);

      parms.Add(Database.SqlParm("@recData1",     SqlDbType.VarChar,  null,                        ParameterDirection.Output, 255));
      parms.Add(Database.SqlParm("@recData2",     SqlDbType.VarChar,  null,                        ParameterDirection.Output, 255));
      parms.Add(Database.SqlParm("@recData3",     SqlDbType.VarChar,  null,                        ParameterDirection.Output, 255));
      parms.Add(Database.SqlParm("@recData4",     SqlDbType.VarChar,  null,                        ParameterDirection.Output, 255));

      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, vSaveSproc, parms); 

      if ((log.hasDetails) && (vValidateRec))
        /* Throw warning so we can exit... but do not add warning to log */
        throw new Warning(Messages.VALIDATION_ISSUES,true);

      so = (ReturnSaveRecordWithRecordData) Database.convertParameters(rd,typeof(ReturnSaveRecordWithRecordData));
      
      return so;    
   }

    /***************************************************************************
     * saveAndReturnJSONData */
    /**
     * Saves an entity record
     *
     * @param  saveType        Type of save 
     * @param  validateRec     Perform validation for this record?
     * @param  editDelReason   Reason for edit/delete 
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    protected static ReturnSaveRecordWithJSONData saveAndReturnJSONData (   SqlConnection connApp
                                                                          , DetailsLog log
                                                                          , UserInfo uInfo
                                                                          , string saveType
                                                                          , string validateRec
                                                                          , string editDelReason
                                                                          , string recID
                                                                          , string saveSproc
                                                                          , string dupRecordMsg
                                                                          , ref List<SqlParameter> parms
                                                                          , validateParms          vp
                                                                          , SqlTransaction tx = null)
    {           
      
       ReturnSaveRecordWithJSONData so = new ReturnSaveRecordWithJSONData();
      
      /*----------------------------
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters
       *----------------------------*/

      bool     vValidateRec = Validate.reqFlag    (validateRec,  Messages.INVALID_VALIDATE_FLAG);
      int      vSaveType    = Validate.reqInteger (saveType,     Messages.INVALID_SAVE_TYPE);
      string   vSaveSproc   = Validate.reqString  (saveSproc,    Messages.MISSING_SPROC_SAVE);
      string   vDupMsg      = Validate.reqString  (dupRecordMsg, Messages.MISSING_DUP_MSG);

      /*----------------------------
       * If the save type is an edit
       * or delete or delete and
       * save new or close and save
       * new we require the record id
       *----------------------------*/
      
      Object vRecID;
      if ((vSaveType == Constants.SAVE_TYPE_EDIT) || (vSaveType == Constants.SAVE_TYPE_DELETE) || (vSaveType == Constants.SAVE_TYPE_CLOSE_AND_SAVE_NEW) || (vSaveType == Constants.SAVE_TYPE_DELETE_AND_SAVE_NEW))
        vRecID = Validate.reqInteger (recID, Messages.INVALID_RECORD_ID);
      else
        vRecID = Validate.optInteger (recID, Messages.INVALID_RECORD_ID);
            
      /*----------------------------
       * If the save type is a new
       * copy, edit, delete and save new
       * or close and save new
       * we perform some 
       * initial data sanity check tasks.
       * if validation is requested.
       * We perform some of these checks
       * here and some in the stored
       * procedure call.  The tasks
       * performed here are those
       * that do not require data
       * lookups.
       *----------------------------*/

      if ((vValidateRec) && (vp != null) && ((vSaveType == Constants.SAVE_TYPE_NEW) || (vSaveType == Constants.SAVE_TYPE_COPY) || (vSaveType == Constants.SAVE_TYPE_EDIT) || (vSaveType == Constants.SAVE_TYPE_CLOSE_AND_SAVE_NEW) || (vSaveType == Constants.SAVE_TYPE_DELETE_AND_SAVE_NEW))) vp();
      
      /*----------------------------
       * Setup our stored procedure
       * call to optionally validate
       * and then save the entity
       * record.
       *----------------------------*/
     
      /*----------------------------
       * Add commonly used parameters
       *----------------------------*/

      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      validateAndAddCommonSaveEntityParameters (ref parms , editDelReason ,  vValidateRec,  vSaveType, vRecID, vDupMsg);

      parms.Add(Database.SqlParm("@jsonData",  SqlDbType.VarChar,  null, ParameterDirection.Output, -1));

      /*----------------------------
       * Call our stored procedure
       * and pass back results
       *----------------------------*/
      
      ReturnDB rd;
      if (tx == null)
        rd = Database.execSproc(connApp, log, vSaveSproc, parms); 
      else
        rd= Database.execSproc(connApp, log, vSaveSproc, parms,tx);

      if ((log.hasDetails) && (vValidateRec))
        /* Throw warning so we can exit... but do not add warning to log */
        throw new Warning(Messages.VALIDATION_ISSUES,true);

      so = (ReturnSaveRecordWithJSONData) Database.convertParameters(rd,typeof(ReturnSaveRecordWithJSONData));
      
      return so;    
   }

   /***************************************************************************
     * SaveOrReplaceRecord */
    /**
     * Saves or replaces a record
     *
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
    
    protected static ReturnSaveOrReplaceRecord saveOrReplaceRecord (  SqlConnection         connApp
                                                                    , DetailsLog             log
                                                                    , UserInfo               uInfo 
                                                                    , string                 validateRec  /* For future use */                             
                                                                    , string                 saveOrReplaceSproc
                                                                    , ref List<SqlParameter> parms
                                                                    , validateParms          vp)
    {           
      
      /*----------------------------
       * Setup our output class
       *----------------------------*/
     
      ReturnSaveOrReplaceRecord so = new ReturnSaveOrReplaceRecord();
      
      /*----------------------------
       * Check for required
       * stored procedure name
       *----------------------------*/

      string vSaveOrReplaceSproc = Validate.reqString (saveOrReplaceSproc, Messages.MISSING_SPROC_SAVE);
       

      /*----------------------------
       * Perform validation tasks
       *
       * Note: The tasks
       * performed here are those
       * that do not require data
       * lookups.
       *----------------------------*/

      if (vp != null)
        vp();
           
      /*----------------------------
       * Add commonly used 
       * sproc parameters
       *----------------------------*/
     
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
  
    
      parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt,   null,             ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",     SqlDbType.VarChar,  null,             ParameterDirection.Output, 8000));
      parms.Add(Database.SqlParm("@saveType",      SqlDbType.Int,      null,             ParameterDirection.Output));

      /*----------------------------
       * Call our stored procedure
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc (connApp, log, vSaveOrReplaceSproc, parms); 
      
      /*----------------------------
       * Populate our return object
       * with the results and return
       *----------------------------*/

      so = (ReturnSaveOrReplaceRecord) Database.convertParameters(rd,typeof(ReturnSaveOrReplaceRecord));
      
      return so;
    
    }
    
    
   /***************************************************************************
    * REC_VIEW */
   /**
    * Record view types
    * 
    ***************************************************************************/
   
    public const int REC_VIEW_RAW                   = 1;
    public const int REC_VIEW_LOAD                  = 2;
    public const int REC_VIEW_SEL                   = 3;
    public const int REC_VIEW_TBL                   = 4;
    public const int REC_VIEW_RPT                   = 5;
    public const int REC_VIEW_INFO_TBL              = 6;
    public const int REC_VIEW_LOAD_N                = 7;
    public const int REC_VIEW_SEL_CUSTOM            = 8;
    public const int REC_VIEW_ALL                   = 9;
    public const int REC_VIEW_OBJECTS               = 10;  /* For API use */

    public const int REC_VIEW_OBJECT                = 11;  /* Not used, as of yet */

        
   /***************************************************************************
    * view */
   /**
    * Returns a list of entities
    * 
    * @param  recViewType     Format of records to return
    * @param  pagedOrTop      Apply paging or top if the recViewType is SEL or TBL
    * @param  idx             Page number or record id to return (comes from client)
    * @param  canEdit         Entities can be edited (comes from client)
    * @param  active          Entites are active (comes from client)
    * @param  viewUDF         The name of the udf and its parameters
    * @param  parms           SQL parameter collection to pass to the udf
    * @param  vp              Hook for caller to perform pre database call
    *                         validation
    * @param  dc              Hook for caller to perform column declaration
    * @return                 ReturnDB
    ***************************************************************************/   

   public static ReturnDB view (  SqlConnection connApp
                                    , DetailsLog log
                                    , UserInfo uInfo
                                    , int    recViewType
                                    , bool   pagedOrTop
                                    , string idx
                                    , string canEdit
                                    , string active
                                    , string viewUDF
                                    , ref List<SqlParameter> parms
                                    , validateParms          vp
                                    , defineCols             dc )
    {
      return view(connApp, log, uInfo, recViewType, pagedOrTop, null, idx, canEdit, active, viewUDF, ref parms, vp, dc);
    }
    public static ReturnDB view (  SqlConnection connApp
                                    , DetailsLog log
                                    , UserInfo uInfo
                                    , int    recViewType
                                    , bool   pagedOrTop
                                    , string pageSize
                                    , string idx
                                    , string canEdit
                                    , string active
                                    , string viewUDF
                                    , ref List<SqlParameter> parms
                                    , validateParms          vp
                                    , defineCols             dc )
    {
       
      /*-------------------------------
       * Validate common required and 
       * optional parameters
       *------------------------------*/   
      
      Object vActive   = Validate.optFlag (active,  Messages.INVALID_FLAG_ACTIVE);
      Object vCanEdit  = Validate.optFlag (canEdit, Messages.INVALID_FLAG_CAN_EDIT);
      
      /*-------------------------------
       * Check for valid page size and
       * get its value.
       * 
       * Note: At present page size is 
       * only used with viewObjects
       *------------------------------*/   
      
      int? _pageSize = null; /* Assume no page size passed.. value to use will be determined later based on view type */

      if (recViewType == REC_VIEW_OBJECTS)
      { 
        /* If a page size is passed */

        if (!String.IsNullOrWhiteSpace(pageSize))
        {
          int _pageSizeVal = Rules.MAX_PAGE_SIZE;

          /* And the size passed is a valid integer */           
          
          if (int.TryParse(pageSize, out _pageSizeVal))
          {
            /* And the value is between our rules for min and max page size */

            if (_pageSizeVal < Rules.MIN_PAGE_SIZE) throw new Warning(Messages.INVALID_PAGE_SIZE);
            if (_pageSizeVal > Rules.MAX_PAGE_SIZE) throw new Warning(Messages.INVALID_PAGE_SIZE);
            
             /* Then we use it */

            _pageSize = _pageSizeVal;
          }

          /* And the size passed is not a valid integer */

          else
          {
             throw new Warning(Messages.INVALID_PAGE_SIZE);
          }
        }
      }

      /*-------------------------------
       * Determine how idx will be used
       *------------------------------*/   
 
      Object vRecID       = null;
      int    vPageNumber  = 1;
      
      /*-------------------------------
       * idx is a record id
       *------------------------------*/   

      if (recViewType == REC_VIEW_LOAD)     vRecID = Validate.reqInteger (idx, Messages.INVALID_RECORD_ID);
      if (recViewType == REC_VIEW_INFO_TBL) vRecID = Validate.optInteger (idx, Messages.INVALID_RECORD_ID);

      else if ((recViewType == REC_VIEW_OBJECTS) && (!pagedOrTop)) vRecID  = Validate.reqInteger (idx, Messages.INVALID_RECORD_ID);
      
      /*-------------------------------
       * idx is a page number
       *------------------------------*/   
      
      else if ((recViewType == REC_VIEW_TBL)     && (pagedOrTop)) vPageNumber  = Validate.reqInteger (idx, Messages.INVALID_PAGE_NUMBER);  
      else if ((recViewType == REC_VIEW_OBJECTS) && (pagedOrTop)) vPageNumber  = Validate.reqInteger (idx, Messages.INVALID_PAGE_NUMBER);

      /*-------------------------------
       * idx is not used
       *------------------------------*/   

      else if ((recViewType == REC_VIEW_SEL) && (pagedOrTop)) vPageNumber = Rules.VIEW_SEL_PAGE_SIZE;
      
      /*----------------------------
       * Validate parameters provided
       * by caller
       *----------------------------*/

      if (vp != null) vp();

      /*----------------------------
       * Add commonly used parms
       * Note: paging and top
       * row contraints are handled
       * by execQuery
       *----------------------------*/
      
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      
      parms.Add(Database.SqlParm("@recID",      SqlDbType.BigInt,  vRecID,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@canEdit",    SqlDbType.Bit,     vCanEdit,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@active",     SqlDbType.Bit,     vActive,          ParameterDirection.Input));
      
     /*----------------------------
      * Setup our output class
      *----------------------------*/

      ReturnDB rd;
      
      /*----------------------------
       * Generate the SQL statement
       * based on the view type
       *----------------------------*/
       
      string              sql   = "";      
      SQLResultSetPurpose ssp   = new SQLResultSetPurpose();
      
      if (recViewType == REC_VIEW_RPT) 
        ssp = SQLResultSetPurpose.REPORT; 
      else 
        ssp = SQLResultSetPurpose.VIEW;
      
      SQLStatement ss           = new SQLStatement(viewUDF, ssp);      
      int          rowLimit     = Database.ROW_LIMIT_NONE;
      string       pageroworder = "";

      /*----------------------------
       * Option selection
       * for combo boxes and
       * auto completes
       *----------------------------*/
      
      if (recViewType == REC_VIEW_SEL) 
      {

        /*---------------------------------------------------------------------
         * Please note
         * 
         * The framework supplies standard values for id, label and value.
         * 
         * The user user must define (if neccessary):
         *
         * - the context column (ie ss.addDisplayColumn("groupName as context1"))
         *---------------------------------------------------------------------*/

        ss.addDisplayColumn("id");
        ss.addDisplayColumn("name as label");
        ss.addDisplayColumn("name as value");
        if (dc != null) dc(ref ss,ref pageroworder, ref parms);
        if (pagedOrTop) rowLimit = Database.ROW_LIMIT_TOP;
        sql = ss.ToString();              
      }      
      
      else if (recViewType == REC_VIEW_SEL_CUSTOM)
      {        
        /* View select custom */
        
        /* Use define columns to define viewSel columns */
        
        if (dc != null) 
        {
          dc (ref ss,ref pageroworder, ref parms);
          if (pagedOrTop) rowLimit = Database.ROW_LIMIT_TOP;
          sql = ss.ToString();
        }
        
        /* Return all columns... udf, table, view, etc must provide columns that viewSel object looks for */
        
        else  
        {
          sql = ss.ToString();
        }
      }
      
      
      /*----------------------------
       * View table for data view
       * previews, record selections
       * or data views
       *----------------------------*/

      else if (recViewType == REC_VIEW_TBL) 
      {
        /*---------------------------------------------------------------------
         * Please note
         * 
         * The user user must define:
         * 
         * - the table columns (ie ss.addDisplayColumn("FirstName as [First Name]
         * - the page row order (if any)
         * 
         * If aliases (col as [Something Else]) are used in the underlying sql
         * the aliases for the column names must be used in the page row order
         * 
         * For example:

         * Given the following sql statement:
         * 
         *   select lname as [Last Name] fname as [First Name] from tblNames
         * 
         * The page row order would be:
         *   
         *   [Last Name], [First Name]
         *---------------------------------------------------------------------*/

        if (dc != null) dc(ref ss, ref pageroworder, ref parms);
        if (pagedOrTop) rowLimit = Database.ROW_LIMIT_PAGED;
        sql = ss.ToString();              
      }
      
      /*----------------------------
       * "Raw" list of object data
       *  with paging options
       *----------------------------*/

      else if (recViewType == REC_VIEW_OBJECTS) 
      {        
        /*---------------------------------------------------------------------
         * All columns are returned (the framework returns all by default if no
         * columns are defined).
         *--------------------------------------------------------------------*/  
        if (dc != null) dc (ref ss, ref pageroworder, ref parms);
        if (pagedOrTop) rowLimit = Database.ROW_LIMIT_PAGED;       
        sql = ss.ToString();
      }

      /*----------------------------
       * View Report
       * Generates report document
       *----------------------------*/

      else if (recViewType == REC_VIEW_RPT)
      {
      
        /*---------------------------------------------------------------------
         * All columns are returned (the framework returns all by default if no
         * columns are defined).  A subset of these columns can be extracted
         * through record conversion.
         *---------------------------------------------------------------------*/ 

        if (dc != null) dc(ref ss, ref pageroworder, ref parms);
        sql = ss.ToString();
        //TODO: I did not know that the dc() delegate function is not called for each and every query; it is only called when
          // the database query is of a certain type, and not for other types of queries.  Perhaps this should be documented.
      
      }

      /*----------------------------
       * View Entity for loading
       * invididual record
       *----------------------------*/
 
      else if (recViewType == REC_VIEW_LOAD) 
      {
        /*---------------------------------------------------------------------
         * All columns are returned (the framework returns all by default if no
         * columns are defined).  A subset of these columns can be extracted
         * through record conversion.
         *---------------------------------------------------------------------*/ 

        sql = ss.ToString();

      }
      else if (recViewType == REC_VIEW_OBJECT)
      {
        /*---------------------------------------------------------------------
         * All columns are returned (the framework returns all by default if no
         * columns are defined).  A subset of these columns can be extracted
         * through record conversion.
         *---------------------------------------------------------------------*/

         sql = ss.ToString();
      }

      /*----------------------------
       * Unknown or undefined view
       * type
       *----------------------------*/
      
      else
      {
      
        /*---------------------------------------------------------------------
         * All columns are returned (the framework returns all by default if no
         * columns are defined).  A subset of these columns can be extracted
         * through record conversion.
         *---------------------------------------------------------------------*/ 
        
        sql = ss.ToString();
      
      }

      /*----------------------------
       * Execute query 
       * based on the view type
       *----------------------------*/

      if      (recViewType == REC_VIEW_LOAD)          rd = Database.execQuery(connApp, log, sql, false, parms);            
      else if (recViewType == REC_VIEW_TBL)           rd = Database.execQuery(connApp, log, sql, false, parms, null,  rowLimit, Rules.VIEW_TBL_PAGE_SIZE, vPageNumber, pageroworder);
      else if (recViewType == REC_VIEW_OBJECTS)
      {
        if (!_pageSize.HasValue) _pageSize = Rules.VIEW_OBJ_PAGE_SIZE; /* Just in case */
        rd = Database.execQuery(connApp, log, sql, false, parms, null,  rowLimit, _pageSize.Value, vPageNumber, pageroworder);
      }
      else if (recViewType == REC_VIEW_SEL)           rd = Database.execQuery(connApp, log, sql, false, parms, null,  rowLimit, Rules.VIEW_SEL_PAGE_SIZE, vPageNumber, pageroworder);      
      else if (recViewType == REC_VIEW_RPT)           rd = Database.execQuery(connApp, log, sql, false, parms);
      else if (recViewType == REC_VIEW_INFO_TBL)      rd = Database.execQuery(connApp, log, sql, false, parms); 
      else if (recViewType == REC_VIEW_OBJECT)        rd = Database.execQuery(connApp, log, sql, false, parms);
      else                                            rd = Database.execQuery(connApp, log, sql, false, parms);      

      /*----------------------------
       * Done
       *----------------------------*/
      
      return rd;
    }
        
   /***************************************************************************
    * viewSel */
   /**
    * Returns a record selection list of entities
    * 
    * @param  vc              Call to subclasses view
    * @return                 ReturnSel
    ***************************************************************************/ 

    protected static ReturnSel viewSel(SqlConnection connApp, DetailsLog log, UserInfo uInfo, bool top, string topSize, viewCall vc)
    {
      ReturnDB  rd = vc();
      ReturnSel so = Database.convertReturnDBToReturnSel(ref rd);
      return so; 
    }
    
  
   /***************************************************************************
    * viewInfoTbl */
   /**
    * Returns a info table of records.  
    * 
    * Note: This method is different that the other view mthods 
    * as it does not use the child entities view method.
    * 
    * @param  infoUDF         Info udf name and parameters
    * @return                 ReturnInfoTable
    ***************************************************************************/ 
    
    protected static ReturnInfoTable viewInfoTbl (SqlConnection connApp, DetailsLog log, UserInfo uInfo, string infoUDF, List<SqlParameter> parms)
    {
      return viewInfoTbl(connApp, log, uInfo, infoUDF, "", parms);
    }
    

    protected static ReturnInfoTable viewInfoTbl (SqlConnection connApp, DetailsLog log, UserInfo uInfo, string infoUDF, string idx, List<SqlParameter> parms)
    {
      ReturnDB        rd = view (connApp, log, uInfo, REC_VIEW_INFO_TBL, false, idx, "", "", infoUDF, ref parms, null, null);
      ReturnInfoTable so = Database.convertReturnDBToReturnInfoTable(ref rd);
      return so;
    }
            
   /***************************************************************************
    * viewObjects */
   /**
    * Returns a list of entities.  Paging is assumed.
    * 
    * @param  vc              Call to subclasses view
    * @return                 ReturnEntityList
    ***************************************************************************/ 
   public static ReturnObjects generatePartialReturnObjects (Type entityType, string pageOrder)
   {
      
     ReturnObjects so = new ReturnObjects();      
     
      /* Init */

      so.hasRecords            = false;
      so.objectFullName        = entityType.FullName;
      so.recordsPaged          = false;
      so.recordsReturned       = 0;      
      so.pageOrder             = pageOrder;
      so.pageCount             = 0;
      so.pageSize              = 0;
      so.pageNumber            = 0;      
      so.recordsTotal          = 0;
      so.recordsFiltered       = 0;
      so.header1               = "";
      so.header2               = "";
      so.header3               = "";
      so.footer1               = "";
      so.footer2               = "";
      
      so.referenceObject1         = null;
      so.referenceObject1FullName = "";
      
      so.referenceObject2         = null;
      so.referenceObject2FullName = null;
      
      so.referenceObject3         = null;
      so.referenceObject3FullName = null;
      
      return so;
   }

   /***************************************************************************
    * viewObjects */
   /**
    * Returns a list of entities.  Paging is assumed.
    * 
    * @param  vc              Call to subclasses view
    * @return                 ReturnEntityList
    ***************************************************************************/ 
   protected static ReturnObjects viewObjects (   SqlConnection connApp
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , Type          entityType
                                                 , bool          pageObjectList
                                                 , string        pageOrder
                                                 , viewCall      vc )

    {
      return viewObjects(connApp, log, uInfo, entityType, pageObjectList, pageOrder, @"", vc);
    }
    protected static ReturnObjects viewObjects (   SqlConnection connApp
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , Type          entityType
                                                 , bool          pageObjectList
                                                 , string        pageOrder
                                                 , string        pageSize
                                                 , viewCall      vc
                                                 )

    {
      ReturnObjects so = generatePartialReturnObjects(entityType,pageOrder);      
     
      /* Validate page order */
     
      if (pageObjectList)
      {           
          Validate.ValidateReqPageOrder(  entityType
                                         , pageOrder
                                         , @"Invalid paging order");
      
      }
      
      /* Call view method */

      ReturnDB rd = vc();
      
      /* Pass back has objects flag */
      
      so.hasRecords  = rd.hasRecords;
      /* If there are no objects to return exit early */

      if (!so.hasRecords) return so;
            
      long rowTotal = 0;
      
      /* Objects list is paged */

      if (pageObjectList)
      {                      
        so.recordsPaged = pageObjectList;

        /* Get data on page number and page size used in actual database call */
        
        if (rd.parameters != null)
        { 
          foreach (var p in rd.parameters)
          {
            var pname = "@" + p.name;
            if (pname == Database.SQL_PARM_NAME_PAGING_PAGE_NUM)   so.pageNumber = (int) p.value;
            if (pname == Database.SQL_PARM_NAME_PAGING_PAGE_SIZE)  so.pageSize   = (int) p.value;
          }
        }
        
        /* Get total possible objects that can be returned from 1st returned row */
        
        foreach (var f in rd.records[0].fields)
        { 
          /* This is the column we return total posible rows available */
          if (f.name == Database.SQL_COL_NAME_PAGING_ROW_TOTAL)
          {                         
            if (f.typename == "System.Int32") rowTotal = (int) f.value; else rowTotal = (long) f.value;                                       
            break;   
          }   
        }
        so.pageCount = Util.calculateNumOfPages(so.pageSize,rowTotal);  
      }
      
      /* Objects list is not paged */
      
      else
      {
        rowTotal = rd.records.LongLength;
      }
          
      /* Pass back counts */

      so.recordsTotal     = rowTotal;
      so.recordsFiltered  = rowTotal; /* https://datatables.net/manual/server-side */
      so.recordsReturned  = rd.records.LongLength;
      
      /* Pass back objects */
      
      so.data = Database.convertRecords(rd.records,entityType);      
      
      return so;
    }
   
    /***************************************************************************
     * viewObject */
    /**
     * Returns a single entity.  
     * 
     * @param  vc              Call to subclasses view
     * @return                 ReturnObject
     ***************************************************************************/ 

    protected static ReturnObject viewObject (   SqlConnection connApp
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , Type          entityType                                                 
                                                 , viewCall      vc
                                              )  // NOTE: only 1 reference to this method, as per Viz Studio

    {
      ReturnObject so = new ReturnObject();      
     
      /* Init */

      so.hasRecord            = false;
      so.objectFullName        = entityType.FullName;
      /* Call view method */

      ReturnDB rd = vc();
      
      /* Pass back has objects flag */
      
      so.hasRecord  = rd.hasRecords;
     
      /* If there are no objects to return exit early */

      if (!so.hasRecord) return so;
                  
      /* Pass back object */
      
      so.data = Database.convertRecord(rd.records,entityType);      
      
      return so;
    } 
        
   /***************************************************************************
    * viewTbl */
   /**
    * Returns a data table of entities
    * 
    * @param  vc              Call to subclasses view
    * @return                 ReturnSel
    ***************************************************************************/ 
    
    protected static ReturnDataTable viewTbl(SqlConnection connApp, DetailsLog log, UserInfo uInfo, bool paged, string pageNumber, viewCall vc)
    {
      return viewTbl(connApp, log, uInfo, paged, pageNumber, vc, "","");
    }
    
    protected static ReturnDataTable viewTbl (SqlConnection connApp, DetailsLog log, UserInfo uInfo, bool paged, string pageNumber, viewCall vc, string tableName, string tableFooter)
    {
     
      ReturnDB        rd = vc();
      ReturnDataTable so = Database.convertReturnDBToReturnDataTable(ref rd);
      
      // Default table name is Data View
      
      if (Util.IsNullOrEmpty(tableName))
        so.tableName = Messages.DATA_VIEW_NO_TITLE;
      else
        so.tableName = tableName;
      
      // Default footer is the text confidential

      if (Util.IsNullOrEmpty(tableFooter))
          so.tableFooter = Messages.DATA_VIEW_NO_FOOTER;
      else
          so.tableFooter = tableFooter;

      // Append generated on message + datetime stamp to end of footer text

      so.tableFooter = so.tableFooter + Messages.DATA_VIEW_GENERATED_ON;
      
      return so; 
    }
     
    /***************************************************************************
     * viewRpt */
    /**
     * Returns a data table of entities setup for views
     * 
     * @param  vc              Call to subclasses view
     * @return                 ReturnDataTable
     ***************************************************************************/

    protected static ReturnDataTable viewRpt(SqlConnection connApp, 
                                             DetailsLog log, 
                                             UserInfo uInfo, 
                                             bool paged, 
                                             string pageNumber, 
                                             string active, 
                                             string udf, 
                                             List<SqlParameter> parms, 
                                             validateParms vp, 
                                             defineCols dc)
    {
       return viewRpt(connApp,
                      log,
                      uInfo,
                      paged,
                      pageNumber,
                      active,
                      udf,
                      parms,
                      vp,
                      dc,
                      Messages.DATA_VIEW_NO_TITLE,
                      Messages.DATA_VIEW_NO_FOOTER);                                                  
    }
    
    // I don't understand why viewTbl and viewRpt have such similar implementations...
    // couldn't they be combined?  Couldn't one maybe call the other?
    protected static ReturnDataTable viewRpt(SqlConnection connApp, 
                                             DetailsLog log, 
                                             UserInfo uInfo, 
                                             bool paged, 
                                             string pageNumber, 
                                             string active, 
                                             string udf, 
                                             List<SqlParameter> parms, 
                                             validateParms vp, 
                                             defineCols dc,
                                             string viewtitle,
                                             string viewfooter)
    {
       ReturnDB        rd = view(connApp, log, uInfo, REC_VIEW_TBL, paged, pageNumber, null, active, udf, ref parms, vp, dc);
       ReturnDataTable so = Database.convertReturnDBToReturnDataTable(ref rd);            

       so.tableName   = viewtitle;      
       so.tableFooter = viewfooter;

       // Append generated on message + datetime stamp to end of footer text

       so.tableFooter = so.tableFooter + Messages.DATA_VIEW_GENERATED_ON;
            
       return so;
    }
  
  }
}
