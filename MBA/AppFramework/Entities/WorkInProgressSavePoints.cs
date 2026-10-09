using MBA.Security;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Dynamic;
using System.Web.Script.Serialization;
using Newtonsoft.Json.Linq;

namespace MBA
{
  
  /***************************************************************************
   * WorkInProgressSavePoint */
  /**
   * 
   ***************************************************************************/

  public class WorkInProgressSavePoint
  {
    public long       id;
    public string     appName;
    public long       userID;
	public string     requestResource;
	public string     savePointName;
	public string     savedDataJSON;
	public DateTime   loggedOn;
    public bool       hasSavedData = false;
    public dynamic    savedDataObject;
   
  }

  /***************************************************************************
   * WorkInProgressSavePoints */
  /**
   * 
   ***************************************************************************/

  public class WorkInProgressSavePoints : Entities
  {
    public static string URL_WEB_SVC                 = @"workinprogresssavepoints.asmx";
    public static string URL_WEB_SVC_SAVE_OR_REPLACE = URL_WEB_SVC + @"/saveorreplace";
    public static string URL_WEB_SVC_DELETE          = URL_WEB_SVC + @"/delete";

   /***************************************************************************
    * URL_WEB_SVC_SAVE_OR_REPLACE_BASE */
   /**
    *
    ***************************************************************************/   

    public static string URL_WEB_SVC_SAVE_OR_REPLACE_BASE ()
    {
      return MBA.HttpApplication.createLink(URL_WEB_SVC_SAVE_OR_REPLACE,true);
    }

   /***************************************************************************
    * URL_WEB_SVC_DELETE_BASE */
   /**
    *
    ***************************************************************************/  
    public static string URL_WEB_SVC_DELETE_BASE ()
    {
      return MBA.HttpApplication.createLink(URL_WEB_SVC_DELETE,true);
    }

    /***************************************************************************
     * validateAndAddCommonParameters */
    /**
     *
     ***************************************************************************/   

    protected static void validateAndAddCommonParameters (string appName, string requestResource, string savePointName, ref List<SqlParameter> parms)
    {
      string vAppName           = Validate.reqString  (appName,         Messages.INVALID_APP_NAME);
      string vRequestResource   = Validate.reqString  (requestResource, @"Invalid requested resource");
      string vSavePointName     = Validate.reqString  (savePointName,   @"Invalid save point name");
                  
      parms.Add(Database.SqlParm("@appName",              SqlDbType.VarChar,  vAppName,             ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@requestResource",      SqlDbType.VarChar,  vRequestResource,     ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@savePointName",        SqlDbType.VarChar,  vSavePointName,       ParameterDirection.Input, 256));
    }

    /***************************************************************************
     * delete */
    /**
     * @return ReturnSaveNewRecord
     ***************************************************************************/   

    protected static ReturnSaveRecord delete (   SqlConnection  connUsers
	                                            , DetailsLog    log
											    , UserInfo      uInfo											  
											    , string        appName
											    , string        editDelReason
											    , string        validateRec
                                                , string        requestResource
                                                , string        savePointName )
    {           
                
      ReturnSaveRecord so = new ReturnSaveRecord();
      
      /*----------------------------
       * Load the record so we can
       * get the record id. 
       * Also please note that the 
       * load method will vet the
       * parameters for us.
       *----------------------------*/

      WorkInProgressSavePoint sp = load (connUsers,log,uInfo,appName,requestResource,savePointName);
      if (sp.hasSavedData == false) return so;
      string recID = sp.id.ToString();

      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/
      
      var parms  = new List<SqlParameter>();
      validateAndAddCommonParameters(appName,requestResource,savePointName,ref parms);
      
      /*----------------------------
       * Call base method 
       *----------------------------*/

      so =  Entities.delete (connUsers,log,uInfo, editDelReason,validateRec,recID,"WorkInProgressSavePoint_Delete",ref parms);
      return so;
    }
    
    /***************************************************************************
     * load */
    /**
     * @return WorkInProgressSavePoint
     ***************************************************************************/ 
    
    protected static WorkInProgressSavePoint load (   SqlConnection connUsers
                                                    , DetailsLog    log
                                                    , UserInfo      uInfo
                                                    , string        appName
                                                    , string        requestResource
                                                    , string        savePointName )
    { 

       WorkInProgressSavePoint sp = (WorkInProgressSavePoint) load (  connUsers
                                              , log
                                              , uInfo
                                              , typeof(WorkInProgressSavePoint)
                                              , delegate {    
                                                           return WorkInProgressSavePoints.view (  connUsers
                                                                                                 , log
                                                                                                 , uInfo
                                                                                                 , appName
                                                                                                 , Entities.REC_VIEW_RAW
                                                                                                 , false
                                                                                                 , ""
                                                                                                 , ""
                                                                                                 , requestResource
                                                                                                 , savePointName
                                                                                                 , null );
       });            
       
       if (sp is null) {
          sp = new WorkInProgressSavePoint();
          sp.hasSavedData = false;
       }
       else {
         sp.hasSavedData   = true;
         sp.savedDataObject = Newtonsoft.Json.JsonConvert.DeserializeObject<dynamic>(sp.savedDataJSON); 
       }

       return sp;
     }

    /***************************************************************************
     * save */
    /**
     * @return ReturnSaveOrReplaceRecord
     ***************************************************************************/ 
    
    protected static ReturnSaveOrReplaceRecord saveOrReplace (   SqlConnection connUsers
                                                               , DetailsLog    log
                                                               , UserInfo      uInfo
                                                               , string        appName
                                                               , string        validateRec
                                                               , string        requestResource
                                                               , string        savePointName
                                                               , string        savedDataJSON )
    { 
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      var parms = new List<SqlParameter>();
      validateAndAddCommonParameters(appName,requestResource,savePointName,ref parms);
            
      string vSavedDataJSON     = Validate.reqString  (savedDataJSON,   @"Invalid saved data");            
      parms.Add(Database.SqlParm("@savedDataJSON", SqlDbType.VarChar,  vSavedDataJSON, ParameterDirection.Input, -1));
      return saveOrReplaceRecord ( connUsers, log, uInfo, validateRec, @"WorkInProgressSavePoint_SaveOrReplace", ref parms, null);
 
    }

    /***************************************************************************
     * view */
    /**
     *
     **************************************************************************/
    protected static ReturnDB view (  SqlConnection connSpedmon
                                     , DetailsLog    log
                                     , UserInfo      uInfo
                                     , string        appName
                                     , int           recViewType
                                     , bool          pagedOrTop
                                     , string        idx
                                     , string        canEdit
                                     , string        requestResource
	                                 , string        savePointName
                                     , defineCols dc)
    {
      string viewUDF = @"dbo.WorkInProgressSavePoints_View (@userID, @userGroup, @userRank, @appName, @requestResource, @savePointName, @recID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      var parms = new List<SqlParameter>();
      validateAndAddCommonParameters(appName,requestResource,savePointName,ref parms);

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view ( connSpedmon
                            , log
                            , uInfo
                            , recViewType
                            , pagedOrTop
                            , idx
                            , canEdit
                            , "Y"
                            , viewUDF
                            , ref parms
                            , null
                            , dc );
    }

  }
}
