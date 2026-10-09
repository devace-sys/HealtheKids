using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using MBA.IdentifyData;

namespace MBA
{
  
  /***************************************************************************
   * UserPreference */
  /**
   * User preference
   ***************************************************************************/   
  
  public class UserPreference:NounVerbNameValue
  {
    public UserPreference():base(){}
    public long usrid;
    public bool hasPreference = false;
  }


        
  public class UserPreferences:NounVerbNameValueLists
  {
    /***************************************************************************
     * getPreferenceValue */
    /**
     * Get the value of a preference
    
     * @param  usrid   User id
     * @return         List<UserPreference>
     ***************************************************************************/         
    
    public static bool getPreferenceValue(string selector,
                                          string selectortype,
                                          string noun,
                                          string verb, 
                                          string name, 
                                          ref List<UserPreference> preferences,
                                          out string value)
    {
      UserPreference p;     
      if (findPreference(selector, selectortype, noun, verb,name,ref preferences, out p))
      {
        value = p.value.ToString();
        return true;
      }
      value = null;
      return false;
    }
       
    /***************************************************************************
     * findPreference */
    /**
     * View user preferences
     * 
     * @param  usrid   User id
     * @return         List<UserPreference>
     ***************************************************************************/     
    
    public static bool findPreference(string selector,
                                      string selectortype,
                                      string noun, 
                                      string verb, 
                                      string name, 
                                      ref List<UserPreference> preferences,
                                      out UserPreference preference)
    {      

      bool status = false;
      preference  = null;
      
      try
      {
        if (preferences.Count > 0)
        {
          var results = from p in preferences
                        where p.selector == selector && p.selectorType == selectortype && p.noun == noun && p.verb == verb && p.name == name
                        select p;
              
          preference = results.First();      
          status = true;
        }
        else
        {
          status = false;
        }
      }
      catch
      {
        status = false;
      }
      
      return status;
      
    }
    
    
    /***************************************************************************
     * saveOrReplace */
    /**
     * Creates a new or replaces an existing user preference
     * 
     * @param   appDomain       Application domain (can be same as appName)
     * @param   appName         Application name (from web.config)
     * @param   usrid           Preference is for this user id
     * @param   selector        Scope of application of this preference (* is default)
     * @param   noun            Object name
     * @param   verb            Object method
     * @param   name            Method argument name
     * @param   value           Method argument value
     * @return         ReturnSaveOrReplaceRecord
     ***************************************************************************/                                          
    
   
   public static ReturnSaveOrReplaceRecord saveOrReplaceRecord (SqlConnection connUsers, 
                                                                DetailsLog log, 
                                                                UserInfo uInfo, 
                                                                string appdomain,
                                                                string appname,
                                                                string usrid,
                                                                string selector,
                                                                string selectortype,
                                                                string noun,
                                                                string verb,
                                                                string name,
                                                                string value)
    {           
    
      /*----------------------------
       * Provide stored procedure
       * name
       *---------------------------*/

      string saveOrReplaceSproc = @"UserPreferences_SaveOrReplace";
            
      /*----------------------------
       * Validate parameters specific
       * to this method
       *---------------------------*/
      
      long  vUsrid = Validate.reqInteger (usrid, Messages.INVALID_USER_ID);
               
      /*----------------------------
       * Create db parms object
       * and add method specific
       * parameters
       *---------------------------*/
      
      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@usrid", SqlDbType.BigInt, vUsrid, ParameterDirection.Input));
        
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/  

      return MBA.NounVerbNameValueLists.saveOrReplaceRecord (connUsers, 
                                                             log, 
                                                             uInfo,
                                                             appdomain,
                                                             appname,
                                                             selector,
                                                             selectortype,
                                                             noun,
                                                             verb,
                                                             name,
                                                             value, 
                                                             saveOrReplaceSproc,                                          
                                                             ref parms,                                          
                                                             null);
      
    }
    
    /***************************************************************************
     * viewRecords */
    /**
     * View user preferences
     * 
     * @param  usrid   User id
     * @return         List<UserPreference>
     ***************************************************************************/     
    
    public static ReturnDB viewRecords (SqlConnection connUsers, 
                                        DetailsLog log, 
                                        UserInfo uInfo,
                                        string appdomain,
                                        string appname, 
                                        string usrid)
    {
      
      /*----------------------------
       * Provide udf name
       *---------------------------*/
     
      string viewUDF = "UsersPreferences_View(@userID, @userGroup, @userRank, @appDomain, @appName, @usrID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this method
       *----------------------------*/
            
      long  vUsrid  = Validate.reqInteger (usrid, Messages.INVALID_USER_ID);
      
      /*----------------------------
       * Create db parms object
       * and add method specific
       * parameters
       *---------------------------*/
          
      List<SqlParameter> parms = new List<SqlParameter>();        
      parms.Add(Database.SqlParm("@usrid", SqlDbType.BigInt, vUsrid, ParameterDirection.Input));
    
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return NounVerbNameValueLists.viewRecords(connUsers, log, uInfo, appdomain, appname, viewUDF, ref parms, null);   
    
    }
           
    /***************************************************************************
     * viewList */
    /**
     * Creates a list of UserPreference
     * 
     * @param  usrid   User id
     * @return         List<UserPreference>
     ***************************************************************************/     
    
    public static List<UserPreference> viewList (SqlConnection connUsers,
                                                 DetailsLog log,
                                                 UserInfo uInfo)
    {
      return viewList(connUsers, log, uInfo, Constants.APP_NAME, Constants.APP_NAME, uInfo.useridStr);
    }
    
    public static List<UserPreference> viewList (SqlConnection connUsers, 
                                                 DetailsLog log, 
                                                 UserInfo uInfo, 
                                                 string appdomain,
                                                 string appname,
                                                 string usrid) 
    {
      List<UserPreference> rl = new List<UserPreference>();
      viewCall             vc = delegate{return viewRecords(connUsers, log, uInfo, appdomain, appname, usrid);};
      
      List<Object> l = NounVerbNameValueLists.viewList(connUsers, log, uInfo, typeof(UserPreference), vc);
      rl = l.ConvertAll<UserPreference>(delegate(Object o){return (UserPreference) o;});
      return rl;
      
    }            
        
  }
}
