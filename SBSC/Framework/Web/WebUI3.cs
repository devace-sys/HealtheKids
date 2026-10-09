using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;
using MBA;

namespace Spedmon
{

 /***************************************************************************
  * WebUI3 */
 /**
  * Base class for all web user interface (UI) pages.  This class generates a
  * standard framework of HTML markup, CSS includes, and Javascript includes
  * for every page that inherits from it.  It also renders any content that
  * the subclasses provide.  This provides a uniform "look and feel" for
  * all UI pages. 
  *
  * @param bodyid         The id you wish to give to the body tag.  If none is
  * @param subtitle       The subtitle you wish to give to the page.  The page 
  *                       title will be Application Name - Subtitle
  * @param css            Additional external css files
  * @param js             Additional external js files
  * @param permittedRoles User roles that are allowed to access the page
   *
  ****************************************************************************/
  
  public class WebUI3: MBA.WebUI3
	{                 
        
    /*===============================
     * Delegates
     *===============================*/ 

    /*-------------------------------
     * App bar icons public
     *
     *------------------------------*/ 

    static handleAppSpecificResponse rAppBarIconsPublic= new handleAppSpecificResponse ( delegate ( HttpRequest req, HttpResponse rsp, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer) {
                            
    });
    
    /*-------------------------------
     * App bar icons private
     *
     *------------------------------*/ 

    static handleAppSpecificResponse rAppBarIconsPrivate= new handleAppSpecificResponse ( delegate ( HttpRequest req, HttpResponse rsp, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer) {
                            
    });

    /*-------------------------------
     * Header public
     *------------------------------*/ 

    static renderHeaderPublic rheaderPublic = new renderHeaderPublic(delegate(string homelink, ref HtmlTextWriter writer)
    {          
    
    });
    
    
    static renderHeaderPrivate rheaderPrivate = new renderHeaderPrivate (delegate (string homelink, string helplink, ref SqlConnection dbConnUser, ref SqlConnection dbConnApp, ref DetailsLog log, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer) {    
            
    
    });
    
    /*-------------------------------
     * Public menu
     *------------------------------*/ 

    static renderMenuPublic rmenuPublic  = new renderMenuPublic(delegate(ref HtmlTextWriter writer) {                   
      
      WebUI2.rmenuPublic(ref writer);
      /*
      renderMenuListItem (  ref writer, null, @"Request Account",        Constants.REQUEST_ACCOUNT, false, false, true);  
      renderMenuListItem (  ref writer, null, @"Request Password Reset", Constants.FORGOT_MY_PASSWORD, false, false, false);  
      renderMenuListItem (  ref writer, null, @"Contact Us",         Messages.CONTACT_US_LINK, false, false, true);   
      renderMenuListItem (  ref writer, null, @"About Us",           Messages.ABOUT_US_LINK,  false, false, true);   
      renderMenuListItem (  ref writer, null, @"Send Us A File",     Constants.REQUEST_FILE_UPLOAD_PUBLIC, false, false, false);   
      return;    
     */
    });

    /*-------------------------------
     * Private menu
     *------------------------------*/ 

    static renderMenuPrivate rmenuPrivate = new renderMenuPrivate(delegate(ref SqlConnection dbConnUser, ref SqlConnection dbConnApp, ref DetailsLog log, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer){
      WebUI2.rmenuPrivate(ref dbConnUser, ref dbConnApp, ref log, ref rd, ref uInfo, ref writer);
    });
    
    
    /*-------------------------------
     * Public footer
     *------------------------------*/ 

    static renderFooterPublic rfooterPublic = new renderFooterPublic(delegate(ref HtmlTextWriter writer) {           

    });

    /*-------------------------------
     * Private footer
     *------------------------------*/ 

    static renderFooterPrivate rfooterPrivate = new renderFooterPrivate(delegate(ref HtmlTextWriter writer, string roleNameLower){
      
    });
        
    
    /*-------------------------------
     * To Do Messages for User
     *
     * Note: Not used here
     * Included for refactoring
     * purposes
     *------------------------------*/ 

    static handleAppSpecificResponse rAppUserToDoMsgs = new handleAppSpecificResponse ( delegate ( HttpRequest req, HttpResponse rsp, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer) {
                            
    });
    
    /*-------------------------------
     * Notifications for user
     *------------------------------*/ 

    static handleAppendingUserSpecificNotifications aUserSpecificNotifications = new handleAppendingUserSpecificNotifications(delegate (ref RequestResponse rd, ref UserInfo uInfo, ref MBA.WebUI3Controls.Notifications notificationsControl) {  
    
       // Is a prac and client uses approval system
      
      if (ServiceRecordsApproval.isPracWithClientThatUsesApprovalSystem(ref rd)) 
      {
              
       // Supervised with no assigned supervisor
       
       //if (ServiceRecordsApproval.isSupervisedPracWithNoAssignedSupervisor(ref rd)) {
       //  writer.Write(@"<div>");
       //  writer.Write (@"As a part of the LBO program your services require supervision. ");
       //  writer.Write (@"<a href=""" + MBA.HttpApplication.createLink(ServiceRecordsApproval.PAGE_CLIENT_PROV_SVC_REC_SUPERVISED_SUPERVISOR_PREF, true) + @""">Click here to select a supervisor</a>");
       //  writer.Write (@"</div>");
      // }
               
      
       // Supervised with held services
       
       if (ServiceRecordsApproval.isSupervisedPracWithHeldServices (ref rd)) {
         string msg      = @"Your supervisor has returned some records for correction";
         string actionMsg = @"Click here to make the changes";
         string actionURL     = MBA.HttpApplication.createLink(ServiceRecordsApproval.PAGE_CLIENT_PROV_SVC_REC_HELD_FOR_CHANGE_DETAILS, true);
         notificationsControl.AppendNotification(WebUI3Common.ElementSemantic.primary,msg,actionMsg,actionURL);
       }
              
       // Supervisor with services to review
     
       if (ServiceRecordsApproval.isSupervisorPracWithServicesToReviewFromAssigned (ref rd)) {
      
         string msg        = @"You are qualified to supervise health care services for other practitioners.";
         string actionMsg  = @"Click here to review pending services";
         string actionURL  = MBA.HttpApplication.createLink(ServiceRecordsApproval.PAGE_USER_ALL_SVC_REC_APPROVAL_SUMMARY, true);
         notificationsControl.AppendNotification(WebUI3Common.ElementSemantic.primary,msg,actionMsg,actionURL);
       }

     
     }

     // If is a practitioner with service requests to review

     if (ServiceAuthorizationCommon.doesPracHaveServiceAuthorizationRequestsPending(ref rd))
     {
        string msg = @"You have service authorization requests that require your review.";
        string actionMsg  = @"Click here to review pending requests";
        string actionURL  = MBA.HttpApplication.createLink(ServiceAuthorizationRequestResponses.URL_MANAGE_RESPONSES, true);
        notificationsControl.AppendNotification(WebUI3Common.ElementSemantic.success,msg,actionMsg,actionURL);          
     }

     
   
    });

    /*===============================
     * Constructors
     *===============================*/ 

    public WebUI3(
      string bodyid
    , string subtitle
    , params string[] permittedroles):this(
          bodyid
        , subtitle
        , null
        , null
        , permittedroles){}
    public WebUI3(
        string bodyid
      , string subtitle
      , string css
      , string js,
      params string[] permittedroles):base(
          bodyid
        , subtitle
        , rAppBarIconsPublic
        , rAppBarIconsPrivate     
        , rheaderPublic
        , rheaderPrivate
        , rmenuPublic
        , rmenuPrivate
        , rfooterPublic
        , rfooterPrivate
        , rAppUserToDoMsgs
        , aUserSpecificNotifications
        , css
        , js
        , permittedroles)
    {
      this.appName       = Constants.APP_NAME;
      this.appTitle      = Constants.APP_TITLE;
      this.applicationName = Constants.APPLICATION_NAME;
      this.appVersion     = Constants.APP_VERSION;
      this.appDescription = Constants.APP_DESCRIPTION;
      this.appKeywords    = Constants.APP_KEYWORDS;
      this.appLogoMarkup = Messages.APP_LOGO_MKUP;
    }
  }
}
