using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.ComponentModel;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * UsersSvc */
  /*
   * Web services end point for account management methods.
   *
   * Unless indicated, each of these methods require that the caller is 
   * logged in.
   * 
   * Each end point method provides a wrapper for a coresponding framework
   * method that is not accessible from the outside.
   * 
   * These wrappers handle access control and parameter replacement.
   * 
   * The method is restricted to calls for given user groups
   * 
   * Parameter replacement is used to enforce additional access control within
   * the user group but this is limited.
   *
   * The final line of defense for access control are the database udfs or 
   * sprocs that return or save data
   ***************************************************************************/

  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]
  
  public class UsersSvc : MBA.WebSvc
  {
                                                        
      /***************************************************************************
       * changeMyPassword */
    /**
     * Allows a user to change their own password.
     * 
     * @param  oldpwd         Required, users old password
     * @param  newpwd1        Required, 1st entry of users new password
     * @param  newpwd2        Required, 2nd entry of users new password
     * @param  validaterec    Required, True=Yes, False=No
     * @return                ReturnSaveRecord
     ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

      public ReturnActionRequest changemypassword(string oldpwd,
                                                string newpwd1,
                                                string newpwd2,
                                                string validaterec)
      {
          return (ReturnActionRequest)
          callMethod(typeof(ReturnActionRequest),
          delegate()
          {
              return Users.changeMyPassword(dbConnUser,
                                          log,
                                          Constants.APP_NAME,
                                          rd.wu.usr.token,
                                          oldpwd,
                                          newpwd1,
                                          newpwd2,
                                          validaterec);
          },
            Constants.ROLE_ALL);  // Who can call this method           
      }
    
    /***************************************************************************
     * delete */
    /**
     * "Deletes" a user record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/  

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete (string editDelReason,
                                    string validaterec,
                                    string recid)
    {
    return (ReturnSaveRecord)
    callMethod(typeof(ReturnSaveRecord),    
    delegate()
    {    
      return Users.delete(dbConnUser, log, uInfo,editDelReason,validaterec,recid);
      },
      Constants.ROLE_SVC_PRAC);  // Who can call this method           
    }
    

    /***************************************************************************
     * forgotPassword */
    /**
     * Allows a user to publicly request a new password if they forgot their password
     * Note: This is a PUBLIC method.
     * 
     * @param  oldpwd         Required, users old password
     * @param  newpwd1        Required, 1st entry of users new password
     * @param  newpwd2        Required, 2nd entry of users new password
     * @param  validaterec    Required, True=Yes, False=No
     * @return                ReturnSaveRecord
     ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnActionRequest forgotpassword (string email,
                                              string validaterec)
    {
    return (ReturnActionRequest)
      // Note: This is a public method
      callMethod(typeof(ReturnActionRequest),    
        delegate()
        {    
          return Users.forgotPassword(dbConnUser,log,Constants.APP_NAME,email,validaterec);
        });
    }
    
    /***************************************************************************
     * save */
    /**
     * Creates a new or edits an existing user account
     * 
     * @param  username       User name
     * @param  password1      Password entered
     * @param  password2      Password entered again
     * @param  roleID         Users role
     * @param  lname          Users last name
     * @param  fname          Users first name
     * @param  email          Users email
     * @param  phone          Users phone number
     * @param  clientID       Client ID of practitioner to attach to this account
     * @param  pracID         Entitiy ID of practitioner to attach to this account
     * @return                ReturnSaveRecord
     ***************************************************************************/   
    
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (string username,
                                  string roleid,
                                  string lname,
                                  string fname,
                                  string phone,
                                  string email,
                                  string clientid,
                                  string selpacode,
                                  string pracid,
                                  string receiveEmailNotifications,
                                  string editDelReason,
                                  string validaterec,
                                  string savetype,
                                  string recid)
    {
    return (ReturnSaveRecord)
    callMethod(typeof(ReturnSaveRecord),    
    delegate()
    {    
      
      return Users.save (dbConnUser,
                         log,
                         uInfo,
                         username,
                         roleid,
                         lname,
                         fname,
                         email,
                         phone,
                         clientid,
                         selpacode,
                         pracid,
                         receiveEmailNotifications,
                         savetype,
                         validaterec,
                         editDelReason,
                         recid);
      },
      Constants.ROLE_SVC_PRAC);  // Who can call this method           
    }
    
   /***************************************************************************
    * viewSel */
    /**
    * Selection view of users
    *
    * @param  clientID     Client ID (forced set for client users)
    * @param  term         Required, search term string (blank for all)
    ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSel (string clientid, string term)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.Users.viewSel (  this.dbConnUser
                                      , this.log
                                      , this.uInfo
                                      , true
                                      , ""
                                      , clientid
                                      , term);
      },
      Constants.ROLE_SVC_SUP_PRAC); // Who can call this method    
    }
    
    /***************************************************************************
     * setPreference */
    /**
     * Allows a user to change their preference
     * 
     * @param  noun         Required
     * @param  verb         Required
     * @param  name         Required
     * @param  value        Required
     * @return              ReturnSaveOrReplaceRecord
     ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveOrReplaceRecord setPreference (string selector,
                                                    string selectortype,
                                                    string noun,
                                                    string verb,
                                                    string name,
                                                    string value)
    {
    return (ReturnSaveOrReplaceRecord)
    callMethod(typeof(ReturnSaveOrReplaceRecord),    
    delegate()
    {    
      return UserPreferences.saveOrReplaceRecord(dbConnUser, log, uInfo, Constants.APP_NAME, Constants.APP_NAME, uInfo.useridStr, selector, selectortype, noun, verb, name, value);
    },
    Constants.ROLE_ALL);  // Who can call this method           
    } 
        
    /***************************************************************************
     * getPreference */
    /**
     * Allows a user to get their preference
     ***************************************************************************/ 
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnValue getPreference(string selector,
                                     string selectortype,
                                     string noun,
                                     string verb,
                                     string name)
    {
      return (ReturnValue)
      callMethod(typeof(ReturnValue), 
      delegate()
      {
        string v;
        ReturnValue val = new ReturnValue();
        if (UserPreferences.getPreferenceValue(selector,
                                          selectortype,
                                          noun,
                                          verb,
                                          name,
                                          ref rd.wu.preferences,
                                          out v))
        {
            val.value = v;
        }

        return val;
      },
      Constants.ROLE_ALL); // Who can call this method    
    }

  }
}
