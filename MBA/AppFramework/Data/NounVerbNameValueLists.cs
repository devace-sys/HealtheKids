using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace MBA
{
  /***************************************************************************
   * NounVerbNameValueLists */
  /**
   * Used to persist lists of noun/verb, name/value pairs
   ***************************************************************************/
     
  public abstract class NounVerbNameValueLists
  {        

    public const string SELECTOR_TYPE_CSS           = "CSS";
    public const string SELECTOR_TYPE_END_POINT     = "END_POINT";
    public const string SELECTOR_CSS_ALL            = "*";    
    public const string SELECTOR_TYPE_CONSTANT_NAME = @"CONSTANT_NAME";

    /***************************************************************************
     * SaveOrReplaceRecord */
    /**
     * Saves or replaces a list record
     *
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
    
    protected static ReturnSaveOrReplaceRecord saveOrReplaceRecord (SqlConnection connApp, 
                                                                    DetailsLog log, 
                                                                    UserInfo uInfo, 
                                                                    string appdomain,
                                                                    string appname,
                                                                    string selector,
                                                                    string selectortype,
                                                                    string noun,
                                                                    string verb,
                                                                    string name,
                                                                    string value,
                                                                    string saveOrReplaceSproc,
                                                                    ref List<SqlParameter> parms,
                                                                    validateParms vp)
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
       * Check for required
       * parameters and validate
       * data integrity of all
       * supplied parameters
       *----------------------------*/
       
      string   vAppDomain     = Validate.reqString  (appdomain,    Messages.INVALID_DOMAIN);
      string   vAppName       = Validate.reqString  (appname,      Messages.INVALID_APP_NAME); 
      string   vSelector      = Validate.reqString  (selector,     Messages.INVALID_SELECTOR);
      string   vSelectorType  = Validate.reqString  (selectortype, Messages.INVALID_SELECTOR_TYPE);        
      string   vNoun          = Validate.reqString  (noun,         Messages.INVALID_NOUN);
      string   vVerb          = Validate.reqString  (verb,         Messages.INVALID_VERB);
      string   vName          = Validate.reqString  (name,         Messages.INVALID_NVP_NAME);
      string   vValue         = Validate.reqString  (value,        Messages.INVALID_NVP_VALUE);

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

      parms.Add(Database.SqlParm("@userID",        SqlDbType.BigInt,   uInfo.userid,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",     SqlDbType.Int,      uInfo.userGroup,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",      SqlDbType.Int,      uInfo.userRank,   ParameterDirection.Input));      

      parms.Add(Database.SqlParm("@appDomain",     SqlDbType.VarChar,  vAppDomain,       ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@appName",       SqlDbType.VarChar,  vAppName,         ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@selector",      SqlDbType.VarChar,  vSelector,        ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@selectorType",  SqlDbType.VarChar,  vSelectorType,    ParameterDirection.Input, 50));
  
      parms.Add(Database.SqlParm("@noun",          SqlDbType.VarChar,  vNoun,            ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@verb",          SqlDbType.VarChar,  vVerb,            ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@name",          SqlDbType.VarChar,  vName,            ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@value",         SqlDbType.VarChar,  vValue,           ParameterDirection.Input, -1));

      parms.Add(Database.SqlParm("@recordID",      SqlDbType.BigInt,   null,             ParameterDirection.Output));
      parms.Add(Database.SqlParm("@spDetails",     SqlDbType.VarChar,  null,             ParameterDirection.Output, 8000));
      parms.Add(Database.SqlParm("@saveType",      SqlDbType.Int,      null,             ParameterDirection.Output));

      /*----------------------------
       * Call our stored procedure
       *----------------------------*/
      
      ReturnDB rd = Database.execSproc(connApp, log, vSaveOrReplaceSproc, parms); 
      
      /*----------------------------
       * Populate our return object
       * with the results and return
       *----------------------------*/

      so = (ReturnSaveOrReplaceRecord) Database.convertParameters(rd,typeof(ReturnSaveOrReplaceRecord));
      
      return so;
    
    }
    
   /***************************************************************************
    * viewRecords */
   /**
    * Returns a list from the database
    * 
    * @param  vc              Call to subclasses view
    * @return                 List
    ***************************************************************************/ 

    protected static ReturnDB viewRecords (SqlConnection connApp, 
                                           DetailsLog log, 
                                           UserInfo uInfo,
                                           string appdomain,
                                           string appname, 
                                           string viewUDF,
                                           ref List<SqlParameter> parms,
                                           validateParms          vp)
    {
      
      /*----------------------------
       * Setup our output class
       *----------------------------*/

      ReturnDB rd;
      
      /*----------------------------
       * Validate parameters provided
       * by caller
       *----------------------------*/

      string   vAppDomain  = Validate.reqString  (appdomain, Messages.INVALID_DOMAIN);
      string   vAppName    = Validate.reqString  (appname,   Messages.INVALID_APP_NAME); 

      if (vp != null) vp();

      /*----------------------------
       * Add commonly used parms
       *----------------------------*/
      
      parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt,  uInfo.userid,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",  SqlDbType.Int,     uInfo.userGroup,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",   SqlDbType.Int,     uInfo.userRank,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@appDomain",  SqlDbType.VarChar,  vAppDomain,       ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@appName",    SqlDbType.VarChar,  vAppName,         ParameterDirection.Input, 50));

      /*----------------------------
       * Generate the SQL statement
       *----------------------------*/
                  
      SQLStatement ss  = new SQLStatement(viewUDF, SQLResultSetPurpose.VIEW);      
      string       sql = ss.ToString();
      
      rd = Database.execQuery(connApp, log, sql, false, parms);
      return rd;  
    }
   
   /***************************************************************************
    * viewList */
   /**
    * Returns a list from the database and converts it
    * 
    * @param  vc              Call to subclasses view
    * @return                 List
    ***************************************************************************/ 
    
    protected static List<Object> viewList (SqlConnection connApp, 
                                            DetailsLog log, 
                                            UserInfo uInfo, 
                                            Type rowType,
                                            viewCall vc)
    {
                  
      ReturnDB     rd = vc();      
      List<Object> so = Database.convertRecordsToList(ref rd.records, rowType);      
      return so;                  
    }                        

  }
}
