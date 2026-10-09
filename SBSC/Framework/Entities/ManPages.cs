using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
using System.Text;

namespace Spedmon
{
  
  /***************************************************************************
   * ManPages */
  /**
   * 
   **************************************************************************/
  
  public class ManPages:MBA.ManPages
  {
    /***************************************************************************
     * SEL_LABEL */
    /**
     * Selection labels for menus and screens
     ***************************************************************************/       
    
    // SBC Added for TimeKeeper
	  public const string SEL_TIMEKEEPER                    = "Time Keeper";
    public const string SEL_LABEL                         = "Help Library";
    public const string SEL_LABEL_ADD                     = "Add New Content";
    public const string SEL_LABEL_VIEW                    = "View List of Content";
    public const string SEL_LABEL_EDIT_DELETE             = "Edit or Delete Content";
    public const string SEL_LABEL_EDIT                    = "Edit Content";   
    public const string SEL_LABEL_DELETE                  = "Delete Content";
    public const string SEL_LABEL_RPT_USER_RESP_REVIEW    = "Review User Responses";
    public const string SEL_LABEL_MANAGE                  = "Manage Content";
    public const string SEL_LABEL_REVIEW_CONTENT          = "Review All Content";    
    
    public const string URL_MAN_PAGE_SAVE                 = @"sbs_mgmt_man_page_save.aspx";
    public const string URL_MAN_PAGE_EDIT_DEL             = @"sbs_mgmt_man_page_edit_delete.aspx";
    public const string URL_MAN_PAGE_VIEW                 = @"sbs_mgmt_man_page_view.aspx";

    public const string URL_MAN_PAGE_MANAGE               = @"sbs_mgmt_manpage_manage.aspx";

    public const string MENU_LNK_MAN_PAGE_MANAGE          = @"admineditdeletemanpagelink"; /* Uses edit delete menu link id for compatibility*/

    public const string URL_MAN_PAGE_RPT_USER_RESP_REVIEW = @"sbs_mgmt_man_page_rpt_user_resp_review.aspx";
    public const string URL_MAN_PAGE_REVIEW_CONTENT       = @"sbs_mgmt_man_pages_content_review.aspx";
    public const string URL_MAN_PAGE_ASMX                 = @"man_pages.asmx";


    public const string SEL_LABEL_CONTENT                 = "Help & Announcements";

    public const string URL_SVC_BASE                 = @"man_pages.asmx";
    public const string URL_SVC_DELETE_INLINE_BASE   = URL_SVC_BASE + @"/deleteinline";
    public const string URL_REST_VIEW_BASE           = @"api/v1/manpages";

    public const string URL_RESEND_BASE = @"man_pages.asmx/resetandrepublish";

    public const string URL_PIN_TO_TOP_BASE = @"man_pages.asmx/pintop";

    //public const string MENU_ID_MANAGE = @"multimediaoutcampmgmtlnk";

    public const string URL_WEB_REPORT_BASE = @"man_pages.ashx";
    public const string URL_SAVE = "sbs_mgmt_man_page_save.aspx";


    public static string URL_REST_VIEW()
    {
        return MBA.HttpApplication.createLink(ManPages.URL_REST_VIEW_BASE, true);
    }

    /***************************************************************************
        * URL_WEB_REPORT */
    /**
        * 
        **************************************************************************/
    public static string URL_WEB_REPORT()
    {
        return MBA.HttpApplication.createLink(ManPages.URL_WEB_REPORT_BASE, true);
    }


    /***************************************************************************
        * URL_ADD_NEW */
    /**
        * 
        **************************************************************************/
    public static string URL_ADD_NEW()
    {
        return MBA.HttpApplication.createLink(ManPages.URL_SAVE
                                                , true
                                                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)
                                                );
    }

    /***************************************************************************
        * URL_EDIT */
    /**
        * 
        **************************************************************************/
    public static string URL_EDIT()
    {
        return MBA.HttpApplication.createLink(ManPages.URL_SAVE
                                                , true
                                                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                                , new NameValue(Constants.PARM_REC_ID, @"")
                                                );
    }

    /***************************************************************************
        * URL_DELETE_BASE */
    /**
        * 
        **************************************************************************/
    public static string URL_DELETE_INLINE()
    {
        return MBA.HttpApplication.createLink(ManPages.URL_SVC_DELETE_INLINE_BASE
                                                , true
                                                );
    }


    public static string URL_RESEND()
    {
        return MBA.HttpApplication.createLink(ManPages.URL_RESEND_BASE
                                                , true
                                                );
    }

    public static string URL_PIN_TO_TOP()
    {
        return MBA.HttpApplication.createLink(ManPages.URL_PIN_TO_TOP_BASE
                                                , true
                                                );
    }

        /***************************************************************************
            * delete */
        /**
            * "Deletes" a man page
            * 
            * @param  editDelReason   Reason for edit/delete 
            * @param  validateRec     Perform validation for this record?
            * @param  recID           Record id reference for edit and delete
            * @return                 ReturnSaveNewRecord
            ***************************************************************************/

        public static ReturnSaveRecord delete (   SqlConnection connUsers
	                                        , DetailsLog    log
											                    , UserInfo      uInfo											  
											                    , string        editDelReason
											                    , string        validateRec
											                    , string        recID )
    {                          
      string appName   = Constants.APP_NAME;   
             
      return MBA.ManPages.delete (  connUsers
                                       , log
                                       , uInfo
                                       , appName
                                       , editDelReason
                                       , validateRec
                                       , recID );
    }

    /***************************************************************************
     * load */
    /**
     * Outputs data for a single announcmeent
     * 
     * @param  connUsers       Users database connection object
     * @param  log             Logging object
     * @param  recID           Record id of announcement
     * @return                 User
     ***************************************************************************/ 
    
    public static ManPage load ( SqlConnection connUsers
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , string        recID )
    {             
      string appName = Constants.APP_NAME;      
      
      return ManPages.load (  connUsers
                                                            , log
                  
                                                            , uInfo
                                                            , appName
                                                            , recID
                                                             );
    } 

    /***************************************************************************
     * resetAndRepublish */
    /**
     * resets all log statistics for this man page and republishes it
     * 
     * @param  connUsers       Users database connection object
     * @param  log             Logging object
     * @param  recID           Record id of announcement
     * @return                 User
     ***************************************************************************/ 
    public static ReturnSaveRecord resetAndRepublish (   SqlConnection connUsers
                                                        , DetailsLog    log
                                                        , UserInfo      uInfo
                                                        , string        recID )
    {
      string appName = Constants.APP_NAME;
      return ManPages.resetAndRepublish(connUsers,log,uInfo,appName,recID);
    }


    public static ReturnSaveRecord pinToTop (   SqlConnection connUsers
                                                        , DetailsLog    log
                                                        , UserInfo      uInfo
                                                        , string        recID )
    {
      string appName = Constants.APP_NAME;
      return ManPages.pinToTop(connUsers,log,uInfo,appName,recID);
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
     * @param  personID       Entitiy ID of person to attach to this account
     * @return                ReturnSaveRecord
     ***************************************************************************/               
    

    public static ReturnSaveRecord save (  SqlConnection connUsers
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , string        startDate
                                            , string        forUserRoleIds
                                            , string        forClientIds
                                            , string        title
                                            , string        featuredimgfiledata
                                            , string        descriptioncontent
                                            , string        content											
                                            , string        includeondashboard											
											, string        okToDisplay

                                            , string        include_in_welcome_package
                                            , string        display_order

                                            , string        saveType
                                            , string        validateRec
                                            , string        editDelReason
                                            , string        recID )
      {           
    

   

      string appName = Constants.APP_NAME;

	  
      return MBA.ManPages.save (  connUsers
                                      , log
                                      , uInfo
                                      , appName                                            
                                      , startDate
                                      , "" /*enddate*/
                                      , forUserRoleIds
                                      , forClientIds
                                      , title
                                      , featuredimgfiledata
                                      , descriptioncontent                                     
                                      , content											
                                      , includeondashboard
                                      , okToDisplay

                                      , include_in_welcome_package
                                      , display_order

                                      , saveType
                                      , validateRec
                                      , editDelReason
                                      , recID );
    
    }

    /***************************************************************************
     * view */
    /**
     * View man pages (admin view)
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnDB view  ( SqlConnection connUsers
                                   , DetailsLog  log
                                   , UserInfo    uInfo
                                   , int         recViewType
                                   , bool        pagedOrTop
                                   , string      idx
                                   , string      canEdit
                                   , string      active
                                   , string      includeContent  
                                   , string      term
                                   , defineCols  dc )
    {
      
      string appName = Constants.APP_NAME;
      
      return MBA.ManPages.view ( connUsers
                                    , log
                                    , uInfo
                                    , appName
                                    , recViewType
                                    , pagedOrTop
                                    , idx
                                    , canEdit
                                    , active
                                    , includeContent 
                                    , term 
                                    , dc);
    }
    
   /***************************************************************************
    * viewTbl */
   /**
    * View announcements record table for admin purposes
    * 
    * @param  appName     Application name (from web.config or app.config) 
    * @param  clientID    Client ID record (if any)
    * @return             ReturnDataTable
    ***************************************************************************/   
    
    public static ReturnDataTable viewTbl (SqlConnection connUsers, DetailsLog log, UserInfo uInfo, bool paged, string pageNumber, string canEdit, string active) 
    {
      string appName = Constants.APP_NAME;      
      
      ReturnDataTable rdt = MBA.ManPages.viewTbl (   connUsers
                                    , log
                                    , uInfo
                                    , paged
                                    , pageNumber
                                    , appName
                                    , canEdit
                                    , active );
       return rdt;
    }

    public static ReturnObjects viewObjects(SqlConnection connUsers
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , bool pageObjectList
                                                , string pageOrder
                                                , string idx
                                                , string canEdit
                                                , string active)
    {

            return MBA.ManPages.viewObjects(   connUsers
                                    , log
                                    , uInfo
                                    , pageObjectList
                                    , pageOrder
                                    , idx
                                    , Constants.APP_NAME
                                    , canEdit
                                    , active);


    }



        /***************************************************************************
         * viewSel */
        /**
          select list of man pages
         * 
         * @param  appName    Application name (from web.config or app.config)
         * @param  clientID   Client record id (if any)
         * @param  userName   Username
         * @param  email      User's email
         * @param  token      Security token (if any)
         * @return            ReturnDB
         ***************************************************************************/

        public static ReturnSel viewSel (  SqlConnection connUsers
                                        , DetailsLog    log
                                        , UserInfo      uInfo
                                        , bool          top
                                        , string        topSize
                                        , string        term )
    {           
      string appName = Constants.APP_NAME;      
      return MBA.ManPages.viewSel(connUsers,log,uInfo,appName,top,topSize,term);                                                  
    }
 
    /***************************************************************************
     * viewList */
    /**
     * View a list
     * 
     * @param  connUsers       Users database connection object
     * @param  log             Logging object
     * @param  userID          User record id
     * @return                 User
     ***************************************************************************/ 
    
    public static List<ManPage> viewList (
        SqlConnection connUsers
      , DetailsLog    log
      , UserInfo      uInfo
      , string        includeContent )
    
    { 
      string appName = Constants.APP_NAME;      
      return viewList(connUsers,log,uInfo,appName,includeContent);
    } 
   
    /***************************************************************************
     * viewContentList */
    /**
     * Content user can see
     ***************************************************************************/ 
    
    public static List<ManPage> viewContentList (
        SqlConnection connUsers
      , DetailsLog    log
      , UserInfo      uInfo
      , string        includeContent )
    
    { 
      string appName = Constants.APP_NAME;      
      return viewContentList(connUsers,log,uInfo,appName,includeContent);
    }

    /***************************************************************************
     * logUserResponse */
    /**
     * Logs has read response
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   

    public static ReturnSaveRecord logUserResponse (   SqlConnection connUsers
	                                                    , DetailsLog    log
											                                , UserInfo      uInfo								
											                                , string        responseTypeID			  
											                                , string        recID )
    {                           
      string appName = Constants.APP_NAME;        
      return MBA.ManPages.logUserResponse (connUsers, log, uInfo, appName, responseTypeID, recID);      
    }

    /***************************************************************************
     * logUserResponses */
    /**
     * 
     ***************************************************************************/
    
    public static ReturnSaveRecord logUserResponses ( 
        SqlConnection connUsers
      , DetailsLog    log
      , UserInfo      uInfo
      , string        responseTypeID      			
      , string        recIDMulti )
    {
      string appName = Constants.APP_NAME;        
      return MBA.ManPages.logUserResponses (connUsers, log, uInfo, appName, responseTypeID, recIDMulti);   
    }

    /***************************************************************************
     * userHasUnreadAnnouncements */
    /**
     * Returns true if there are unread announcments
     * 
     ***************************************************************************/   

    public static bool userHasUnreadManPages ( ref RequestResponse rd) 
    {
      
      string appName = Constants.APP_NAME;        
      return MBA.ManPages.userHasUnreadManPages (ref rd, appName);            
    }
    
    /***************************************************************************
     * viewSelUserRoles */
    /**
     * View list of user roles
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnSel viewSelUserRoles (   SqlConnection connUsers
                                               , DetailsLog    log
                                               , UserInfo      uInfo
                                               , bool          top
                                               , string        topSize
                                               , string        term )
    {
      
      string appName = Constants.APP_NAME;
      
      return MBA.ManPages.viewSelUserRoles (  connUsers
                                                 , log
                                                 , uInfo
                                                 , top
                                                 , topSize
                                                 , appName
                                                 , term );
    }
    
    /***************************************************************************
     * viewSelDashboard */
    /**
     * View content record list
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/     
     
    public static ReturnSel viewSelDashboard(   SqlConnection connUsers
                                               , DetailsLog    log
                                               , UserInfo      uInfo
                                               , bool          top
                                               , string        topSize)
    {     
      string appName = Constants.APP_NAME;
      ReturnSel rs = viewSelDashboard(connUsers,log,uInfo,appName,top,topSize);  // return data
      List<SelRec> dataList = new List<SelRec>(); // list to be populated with announcements data
      if (rs.SelRecs != null)
      { 
        // return only announcements that are supposed to show up on the dashboard
        foreach(var announcement in rs.SelRecs)
        {
            if (announcement.recData5 == "1")
            {
                dataList.Add(announcement);
            }
        }
      }
      rs.SelRecs = dataList.ToArray();
      return rs;
    }
        
    /***************************************************************************
     * viewContentSel */
    /**
     * View content record list
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/     

     
    public static ReturnSel viewContentSel (   SqlConnection connUsers
                                               , DetailsLog    log
                                               , UserInfo      uInfo
                                               , bool          top
                                               , string        topSize
                                               , string        term
                                               , string        userHasRead
                                               , string        welcome_new_user)
    {     
      string appName = Constants.APP_NAME;
      return viewContentSel(connUsers,log,uInfo,appName,top,topSize,term,userHasRead, welcome_new_user);      
    }

    
    /***************************************************************************
     * returnContentSelection */
    /**
     * View content data.  Used for content display.
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnManPage returnContentSelection (  SqlConnection connUsers
                                                        , DetailsLog    log
                                                        , UserInfo      uInfo                                          
                                                        , string        recID )
    {
      string appName = Constants.APP_NAME;
      return returnContentSelection(connUsers, log, uInfo, appName, recID);
    }
   
    /***************************************************************************
     * viewContentUserResponses */
    /**
     * View content
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   
     
    public static ReturnDB viewContentUserResponses (  SqlConnection connUsers
                                                      , DetailsLog    log
                                                      , UserInfo      uInfo
                                                      , int           recViewType
                                                      , bool          pagedOrTop
                                                      , string        idx
                                                      , string        canEdit
                                                      , string        active  
                                                      , string        clientID
                                                      , string        userNotifiedByEmail
                                                      , string        userHasSeen
                                                      , string        userWillReadLater
                                                      , string        userHasRead                                                                                     
                                                      , defineCols    dc )
  {

    string appName     = Constants.APP_NAME;
    Object  vClientID  = Validate.optClientID(uInfo,clientID);
    
    return viewContentUserResponses (connUsers
                                     ,log
                                     ,uInfo
                                     ,recViewType
                                     ,pagedOrTop
                                     ,idx
                                     ,canEdit
                                     ,active
                                     ,appName
                                     ,vClientID
                                     ,userNotifiedByEmail
                                     ,userHasSeen
                                     ,userWillReadLater
                                     ,userHasRead
                                     ,dc);
    }
    
    /***************************************************************************
     * viewContentUserResponsesList */
    /**
     * Generates list
     * 
     ***************************************************************************/  
    
    public static List<ManPageContentUserResponse> viewContentUserResponsesList  (  SqlConnection connUsers
                                                                                  , DetailsLog    log
                                                                                  , UserInfo      uInfo
                                                                                  , string        clientID )
    {
    
      List<ManPageContentUserResponse> Responses = new List<ManPageContentUserResponse>();
           
      ReturnDB sdo = viewContentUserResponses (   connUsers
                                                , log
                                                , uInfo
                                                , Entities.REC_VIEW_RAW
                                                , false
                                                , null
                                                , null
                                                , null
                                                , clientID
                                                , "N"
                                                , "N"
                                                , null
                                                , null
                                                , null );
                                                         
      List<Object> slo = Database.convertRecordsToList(ref sdo.records, typeof(ManPageContentUserResponse));
      
      foreach (Object o in slo)
        Responses.Add((ManPageContentUserResponse) o);
      
      return Responses;
    }

    /***************************************************************************
     * viewManPageContentUserResponsePendingEmailNotificationList */
    /**
     * View email notifications
     ***************************************************************************/   
    
    public static List<ManPageContentUserResponsePendingEmailNotification> viewManPageContentUserResponsePendingEmailNotificationList (
       SqlConnection connUsers
     , DetailsLog    log
     , UserInfo      uInfo     
    )
    
    {
      string appName = Constants.APP_NAME;
      return viewManPageContentUserResponsePendingEmailNotificationList(connUsers,log,uInfo,appName);
    }
    
    
    /***************************************************************************
     * rptReviewUserResponses */
    /**
     *
     *****************************************************************************/

    public static ReturnDataTable rptReviewUserResponses (
        SqlConnection connUsers
      , DetailsLog    log
      , UserInfo      uInfo
      , bool          paged
      , string        pageNumber
      , string        canEdit
      , string        active
      , string        clientID
      , string        pageID
      , string        userHasBeenEmailedNoticeOfContent
      , string        userHasSeenContent
      , string        userWillReadContentLater
      , string        userHasReadContent )
    
    {
      string appName = Constants.APP_NAME;
      
      Object vClientID = Validate.optClientID (uInfo,clientID);
      
      return rptReviewUserResponses (
          connUsers
        , log
        , uInfo
        , paged
        , pageNumber
        , appName
        , canEdit
        , active
        , vClientID
        , pageID
        , userHasBeenEmailedNoticeOfContent
        , userHasSeenContent
        , userWillReadContentLater
        , userHasReadContent
      );
        
    }
  }
 }
