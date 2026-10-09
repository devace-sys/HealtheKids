using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Dynamic;
using MBA;
using Newtonsoft.Json.Linq;

namespace Spedmon
{
    
  /***************************************************************************
   * WorkInProgressSavePoints */
  /**
   * 
   ***************************************************************************/

  public class WorkInProgressSavePoints : MBA.WorkInProgressSavePoints
  {

    /***************************************************************************
     * delete */
    /**
     * @return ReturnSaveNewRecord
     ***************************************************************************/   

    public static ReturnSaveRecord delete (    SqlConnection  connUsers
	                                         , DetailsLog    log
											 , UserInfo      uInfo											  
											 , string        editDelReason
											 , string        validateRec
                                             , string        requestResource
                                             , string        savePointName )
    {           
      string appName   = Constants.APP_NAME;   
      return delete (connUsers, log, uInfo, appName, editDelReason, validateRec, requestResource, savePointName);      
    }
    
    /***************************************************************************
     * load */
    /**
     * @return WorkInProgressSavePoint
     ***************************************************************************/ 
    
    public static WorkInProgressSavePoint load (   SqlConnection connUsers
                                                  , DetailsLog    log
                                                  , UserInfo      uInfo
                                                  , string        requestResource
                                                  , string        savePointName )
    { 
      string appName   = Constants.APP_NAME;   
      return load(connUsers, log, uInfo, appName, requestResource, savePointName);            
    }

    /***************************************************************************
     * save */
    /**
     * @return ReturnSaveOrReplaceRecord
     ***************************************************************************/ 
    
    public static ReturnSaveOrReplaceRecord saveOrReplace (   SqlConnection connUsers
                                                             , DetailsLog    log
                                                             , UserInfo      uInfo
                                                             , string        validateRec
                                                             , string        requestResource
                                                             , string        savePointName
                                                             , string        savedDataJSON )
    { 
      string appName   = Constants.APP_NAME;   
      return saveOrReplace ( connUsers, log, uInfo, appName, validateRec, requestResource, savePointName, savedDataJSON);
    }

  }
}
