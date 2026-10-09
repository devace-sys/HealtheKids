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
   * AnnouncementsSvc */
  /*
   * Web services end point for man pages
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
  
  public class ManPagesSvc : MBA.WebSvc
  {
    /***************************************************************************
     * delete */
    /**
     * "delete" a record
     * 
     * @param  validaterec   Required, True=Yes, False=No
     * @param  editDelReason Reason for delete
     * @param  recid         Record id to delete
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete(
                                  string editDelReason,
                                  string validaterec,
                                  string recid)
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      {
        return ManPages.delete(this.dbConnUser,this.log,this.uInfo,editDelReason,validaterec,recid);                                           
      },
        Constants.ROLE_ANNOUNCEMENT_ADMIN);  // Who can call this method           
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord deleteinline(
                                  string recid)
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      {
        return ManPages.delete(this.dbConnUser,this.log,this.uInfo,"","N",recid);                                           
      },
        Constants.ROLE_ANNOUNCEMENT_ADMIN);  // Who can call this method           
    }

    /***************************************************************************
     * resetandrepublish */
    /**
     * Save man pages
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord resetandrepublish ( string recid )
    {
      return (ReturnSaveRecord) 
     
      callMethod(
        typeof(ReturnSaveRecord)
      , delegate()
      {    

        return ManPages.resetAndRepublish(   dbConnUser
                               , log
                               , uInfo                              
                               , recid );
      }
      , Constants.ROLE_ANNOUNCEMENT_ADMIN);  // Who can call this method           
    }



    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord pintop(string recid)
    {
        return (ReturnSaveRecord)

        callMethod(
            typeof(ReturnSaveRecord)
        , delegate ()
        {

            return ManPages.pinToTop(dbConnUser
                                , log
                                , uInfo
                                , recid);
        }
        , Constants.ROLE_ANNOUNCEMENT_ADMIN);  // Who can call this method           
    }


        /***************************************************************************
         * save */
        /**
         * Save man pages
         ***************************************************************************/


        [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (  string startdate
								  , string foruserroleids
                                  , string forclientids
                                  , string announcementtitle
                                  , string featuredimgfiledata
                                  , string announcementcontent
                                  , string descriptioncontent
                                  , string includeondashboard
                                  , string oktodisplay

                                  , string include_in_welcome_package
                                  , string display_order

                                  , string editDelReason
                                  , string validaterec
                                  , string savetype
                                  , string recid )
    {

      return (ReturnSaveRecord) 
     
      callMethod(
        typeof(ReturnSaveRecord)
      , delegate()
      {    

        return ManPages.save (   dbConnUser
                               , log
                               , uInfo                              
                               , startdate
							   , foruserroleids
                               , forclientids
                               , announcementtitle
                               , featuredimgfiledata
                               , descriptioncontent
                               , announcementcontent
                               , includeondashboard
                               , oktodisplay

                               , include_in_welcome_package
                               , display_order

                               , savetype
                               , validaterec
                               , editDelReason
                               , recid );
      }
      , Constants.ROLE_ANNOUNCEMENT_ADMIN);  // Who can call this method           
    }
    
    /***************************************************************************
     * viewSel */
    /**
     * View selection list 
     ***************************************************************************/    
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSel ( string term )
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel),
      delegate(){return ManPages.viewSel (dbConnUser, log, uInfo, false, "", term);},
      Constants.ROLE_ANNOUNCEMENT_ADMIN);  // Who can call this method 
    }    
        
    /***************************************************************************
     * viewSelDashboard */
    /**
     * View selection list 
     ***************************************************************************/    
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSelDashboard(string term)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel),
      delegate() { return ManPages.viewSelDashboard(dbConnUser, log, uInfo, false, ""); },
      Constants.ROLE_ALL);  // Who can call this method 
    }    
    
    /***************************************************************************
     * viewSelUserRoles */
    /**
     * View selection list of user roles
     ***************************************************************************/    
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSelUserRoles ( string term )
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel),
      delegate(){return ManPages.viewSelUserRoles (dbConnUser, log, uInfo, false, "", term);},
      Constants.ROLE_ANNOUNCEMENT_ADMIN);  // Who can call this method 
    }    


    /***************************************************************************
     * viewContentSel */
    /**
     * View content selection 
     ***************************************************************************/    
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewContentSel ( string term, string userhasread, string welcome_new_user)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel),    
      delegate(){
      return ManPages.viewContentSel (dbConnUser, log, uInfo, false, "", term, userhasread, welcome_new_user);},
      Constants.ROLE_ALL);  // Who can call this method           
    }    


   /***************************************************************************
    * logUserResponse */
    /**
    * Log user response
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord logUserResponse ( string recid , string responsetype )
    {
      return (ReturnSaveRecord) 
     
      callMethod(
        typeof(ReturnSaveRecord)
      , delegate()
      {    

        return ManPages.logUserResponse( dbConnUser
                                   , log
                                   , uInfo
                                   , responsetype
                                   , recid);                              
      }
      , Constants.ROLE_ALL);  // Who can call this method           
    }

  }
}
