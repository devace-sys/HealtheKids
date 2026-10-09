using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
  public class User:MBA.User
  {
  }

  public class Users:MBA.Users
  {
    public const string URL_ASMX_VIEWSEL            = URL_ASMX + "/viewSel";
    public const string MENU_ID_USER_ALL_SAVE       = @"userallusersavelnk";
    public const string SEL_LABEL_SAVE              = @"Users - Save (New WIP)";
    public const string URL_USER_ALL_SAVE           = @"user_all_user_save.aspx";
        
    public static string URL_ASMX_VIEW_SEL_BASE()
    {
      return MBA.HttpApplication.createLink(URL_ASMX_VIEWSEL, true);
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
    
    public static ReturnSaveRecord delete (SqlConnection connUsers, DetailsLog log, UserInfo uInfo, 
                                             string editDelReason, string validateRec, string recID)
    {           
     
      /*----------------------------
       * Check for required and 
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/

      Object vClientID = Validate.optClientID(uInfo, ""); 
      string appName   = Constants.APP_NAME;
       
     /*----------------------------
      * Call base method 
      *----------------------------*/
      
      return MBA.Users.delete(connUsers,log,uInfo,vClientID,appName,editDelReason,validateRec,recID);
    
    }
    
    /***************************************************************************
     * load */
    /**
     * Outputs data for a single user
     * 
     * @param  connUsers       Users database connection object
     * @param  log             Logging object
     * @param  recID           Record id of user
     * @return                 User
     ***************************************************************************/ 
    
    public static MBA.User load (SqlConnection connUsers, DetailsLog log, UserInfo uInfo, string recID)
    { 
            
      string appName = Constants.APP_NAME;

      return MBA.Users.load (connUsers, log, uInfo, appName, recID);
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
     * @param  clientID       Users client record id
     * @return                ReturnSaveRecord
     ***************************************************************************/                                          


    public static ReturnSaveRecord save (  SqlConnection connUsers
                                          , DetailsLog log
                                          , UserInfo uInfo
                                          , string username
                                          , string roleID
                                          , string lname 
                                          , string fname
                                          , string email
                                          , string phone
                                          , string clientID
                                          , string selpaCode
                                          , string pracID
                                          , string receiveEmailNotifications
                                          , string saveType
                                          , string validateRec
                                          , string editDelReason
                                          , string recID )
    {           
    
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * In this case we are validating
       * clientID, and pracID using
       * our Spedmon specific validators
       *---------------------------*/
      
      Object vClientID  = Validate.optClientID  (uInfo, clientID);
      Object vPracID    = Validate.optPracID    (uInfo, pracID);
      Object vSelpaCode = Validate.optSelpaCode (uInfo, selpaCode);

      string appName    = Constants.APP_NAME;
      
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/  

      return MBA.Users.save (connUsers
                            , log
                            , uInfo
                            , appName
                            , username
                            , roleID
                            , lname
                            , fname
                            , email
                            , phone
                            , vClientID
                            , vSelpaCode
                            , vPracID
                            , receiveEmailNotifications
                            , saveType
                            , validateRec
                            , editDelReason
                            , recID);      
    }
    
    /***************************************************************************
     * view */
    /**
     * View users
     * 
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnDB view(SqlConnection connUsers, DetailsLog log, UserInfo uInfo,
                                 int recViewType,     //idk what this param is for... not sure it is even necessary
                                 bool   pagedOrTop,
                                 string idx,
                                 string canEdit,
                                 string active,
                                 string clientID,
                                 string roleID,
                                 string userName,
                                 string email,
                                 string token,
                                 string lname, 
                                 string fname)
    {
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * In this case we are validating
       * clientID, and pracID using
       * our Spedmon specific validators
       *---------------------------*/
      
      string appName    = Constants.APP_NAME;
      Object vClientID  = Validate.optClientID(uInfo, clientID);
      
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/
      
      return MBA.Users.view (connUsers, log, uInfo, appName, recViewType, pagedOrTop, idx, canEdit, active, vClientID, roleID, userName, email, token, lname, fname, null);      
      
    }



   /***************************************************************************
    * viewTbl */
   /**
    * View users record data table
    * 
    * @param  clientID    Client ID record (if any)
    * @return             ReturnDataTable
    ***************************************************************************/   
    
    public static ReturnDataTable viewTbl (SqlConnection connUsers, DetailsLog log, UserInfo uInfo, bool paged, string pageNumber, string clientID,string roleID, string lname, string fname, string canEdit, string active) 
    {
      string appName   = Constants.APP_NAME;
      Object vClientID = Validate.optClientID(uInfo, clientID);
      return Users.viewTbl(connUsers, log, uInfo, paged, pageNumber, appName, vClientID, roleID, lname, fname, canEdit, active);
    }


    /**************************************************************************
     * viewSel */
    /**
     * 
     ***************************************************************************/   

    public static ReturnSel viewSel (   SqlConnection connUsers
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID
                                      , string        term )
    {
      string appName   = Constants.APP_NAME;
      Object vClientID = Validate.optClientID(uInfo, clientID);
      return MBA.Users.viewSel (connUsers,log,uInfo,appName,top,topSize,vClientID,term);
    }
    
    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of user objects
     * 
     ***************************************************************************/

    public static ReturnObjects viewObjects (  SqlConnection connUsers
                                              , DetailsLog log
                                              , UserInfo   uInfo                                                    
                                              , bool       pageObjectList
                                              , string     pageOrder
                                              , string     idx
                                              , string     active
                                              , string     clientID
                                              , string     lName
                                              , string     fName )

    {
      
      /* Default page order */  

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = User.DEFAULT_PAGING_ORDER;

      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      return Entities.viewObjects(  connUsers
                                   , log
                                   , uInfo
                                   , typeof(MBA.User)
                                   , pageObjectList
                                   , pageOrder
                                   , delegate {                                 
                                      return MBA.Users.view ( connUsers
                                                             , log
                                                             , uInfo
                                                             , Constants.APP_NAME
                                                             , Entities.REC_VIEW_OBJECTS
                                                             , pageObjectList
                                                             , idx
                                                             , "" /* Can edit */                                                              
                                                             , active
                                                             , Validate.optClientID(uInfo, clientID)
                                                             , "" /*roleID*/
                                                             , "" /*userName */
                                                             , "" /*user email */
                                                             , "" /* token */
                                                             , lName
                                                             , fName
                                                             , dc
                                                            );  
                                    });
     
    }


  }
}
