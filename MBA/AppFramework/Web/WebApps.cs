using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text;
using System.Text.RegularExpressions;

namespace MBA
{
	
 
  /***************************************************************************
   * renderMenuPublic */
  /**
   * Delegate definition for public menu
   ***************************************************************************/   
  
  public delegate void renderMenuPublic (ref HtmlTextWriter writer);
  
  /***************************************************************************
   * renderMenuPrivate */
  /**
   * Delegate definition for private menu
   ***************************************************************************/   

  public delegate void renderMenuPrivate(ref SqlConnection dbConnUser, ref SqlConnection dbConnApp, ref DetailsLog log, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer);

  /***************************************************************************
   * renderHeaderPublic */
  /**
   * Delegate definition for private section
   ***************************************************************************/     
  
  public delegate void renderHeaderPublic (string homelink, ref HtmlTextWriter writer);

  /***************************************************************************
   * renderHeaderPrivate */
  /**
   * Delegate definition for private section
   ***************************************************************************/     
  
  public delegate void renderHeaderPrivate (string homelink, string helplink, ref SqlConnection dbConnUser, ref SqlConnection dbConnApp, ref DetailsLog log, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer);

  /***************************************************************************
   * renderFooterPublic */
  /**
   * Delegate definition for public footer 
   ***************************************************************************/   
  
  public delegate void renderFooterPublic (ref HtmlTextWriter writer);

  /***************************************************************************
   * renderFooterPrivate */
  /**
   * Delegate definition for private footer
   ***************************************************************************/   

  public delegate void renderFooterPrivate(ref HtmlTextWriter writer, string roleNameLower);
       
  /***************************************************************************
   * renderAppSpecificResponse */
  /**
   * Delegate definition for app specific content
   ***************************************************************************/  
   
  public delegate void handleAppSpecificResponse (HttpRequest req, HttpResponse rsp, ref RequestResponse rd, ref UserInfo uInfo,  ref HtmlTextWriter writer);
  

  /***************************************************************************
   * handleAppendingUserSpecificNotifications */
  /**
   * Delegate definition for user TODO messages.  These are things we require
   * the user to do that may be application specific.
   ***************************************************************************/  
   
  public delegate void handleAppendingUserSpecificNotifications (ref RequestResponse rd, ref UserInfo uInfo, ref MBA.WebUI3Controls.Notifications notificationsControl);
  
  /***************************************************************************
   * WebApp*/
  /**
   * Our base class for all web applications (.aspx pages). 
   * 
   * Each page represents an end point so all access control and other common
   * functionality is provided at the page level and its scope is the entire.
   * page.  If you need to provide limited access to portions of the page
   * for certain groups you will need to conditionally render these portions
   * of the page.
   *
   * To access parts of the framework prior to rendering place your code
   * in your pages page_load handler.
   * 
   * This inherits functionality from our HttpApplication class via global.asax 
   *
   * @param    subtitle          Subtitle for page (page title is App Name - subtitle)
   * @param    permittedRoles    If this page should be private supply all authorized
   *                             roles
   ****************************************************************************/
  
  public class WebApp: System.Web.UI.Page
	{ 
    /*-------------------------------
     * Constructors
     *------------------------------*/ 
    
    public WebApp(string subtitle)
    {
      this._subTitle = subtitle;
    }

    public WebApp(string subtitle, params string[] permittedroles)
    {
      this._subTitle       = subtitle;
      this._permittedRoles = permittedroles;
    }

    public WebApp (
      string bodyid
    , string subtitle
    , handleAppSpecificResponse  rAppBarIconsPublic
    , handleAppSpecificResponse  rAppBarIconsPrivate 
    , renderHeaderPublic rheaderPublic
    , renderHeaderPrivate rheaderPrivate
    , renderMenuPublic rmenuPublic
    , renderMenuPrivate rmenuPrivate
    , renderFooterPublic rfootPublic
    , renderFooterPrivate rfootPrivate
    , handleAppSpecificResponse rAppUserToDoMsgs
    , handleAppendingUserSpecificNotifications aUserSpecificNotifications
    , string css
    , string js
    , params string[] permittedroles)
    {
      this._subTitle      = subtitle;
      this._permittedRoles = permittedroles;
      bodyID             = bodyid;
      
      if (String.IsNullOrEmpty(js)) js = "";
      if (String.IsNullOrEmpty(css)) css = "";
      
      customCSS          = css.Split(new char[]{'|'}, StringSplitOptions.RemoveEmptyEntries);
      customJS           = js.Split (new char[]{'|'}, StringSplitOptions.RemoveEmptyEntries);
            
      /*-------------------------------
       * Rendering delegates
       *------------------------------*/ 
       
      renderAppBarIconsPublic           = rAppBarIconsPublic;
      renderAppBarIconsPrivate          = rAppBarIconsPrivate;
      renderHeaderPublic                = rheaderPublic;
      renderHeaderPrivate               = rheaderPrivate;
      renderMenuPublic                  = rmenuPublic;
      renderMenuPrivate                 = rmenuPrivate;
      renderFooterPublic                = rfootPublic;
      renderFooterPrivate               = rfootPrivate;      
      renderAppSpecificUserToDoMessages = rAppUserToDoMsgs;
      appendUserSpecificNotifications   =  aUserSpecificNotifications;
          
    }

    /*-------------------------------
     * Protected variables
     *------------------------------*/    

    protected   string                 _subTitle;        // Pages subtitle
    protected   string[]               _permittedRoles;  // Permitted roles if this is a private page
    protected   SqlConnection          dbConnUser;       // Connection to user database
    protected   SqlConnection          dbConnApp;        // Connection to this applications database
    protected   DetailsLog             log;              // Our logging object
    protected   RequestResponse        rd;               // Request/response data
    protected   UserInfo               uInfo;            // User info   
    
    protected   bool                   _publicPage                 = false;
    protected   bool                    renderOptionContentOnly    = false;
    protected   bool                  _contentOnly                 = false;
    protected   bool                  _isSubPage                   = false;

    /*-------------------------------
     * Properties
     *------------------------------*/ 

    public string   title          {get {return Constants.APP_TITLE + " - " + _subTitle;}}
    public string   subTitle       {get {return _subTitle;}       set{_subTitle       = value;}}
    public string[] permittedRoles {get {return _permittedRoles;} set{_permittedRoles = value;}}
    
    public bool     publicPage     {get { return _publicPage; }}
    
    public readonly string contactInfo  = Contact.contactStringHTML      (Constants.APP_CONTACT);
    public readonly string contactEmail = Contact.contactStringHTMLEmail (Constants.APP_CONTACT);
   
    public string                       bodyID                { get; set; }
    public string[]                     customCSS             { get; set; }
    public string[]                     customJS              { get; set; }
    public string                       loginLink             { get; set; }
    public string                       logoutLink            { get; set; }
    public string                       changeMyPasswordLink  { get; set; }
    public string                       forgotMyPasswordLink  { get; set; }
    public string                       requestAccountLink    { get; set; }
    public string                       uploadLink            { get; set; }
    public string                       downloadLink          { get; set; }
    public string                       helpLink              { get; set; }
    public string                       homeLink              { get; set; }
    public string                       manPagesLink          { get; set; }
    public string                       userName              { get; set; }
    public string                       userOrganization      { get; set; }
    public string                       userTitle             { get; set; }  
    public string                       platformInfo          { get; set; }
    public string                       initJS                { get; set; }
    public string                       appLogoMarkup         { get; set;}        
    public string                       appName               { get; set;}

    public string                       applicationName       { get; set;}
    public string                       appTitle              { get; set;}
    public string                       appVersion            { get; set;}
    public string                       appDescription        { get; set;}          
    public string                       appKeywords           { get; set;}
    public handleAppSpecificResponse    renderAppBarIconsPublic            { get; set; }
    public handleAppSpecificResponse    renderAppBarIconsPrivate           { get; set; }
    public  renderHeaderPublic          renderHeaderPublic                 { get; set; }
    public  renderHeaderPrivate         renderHeaderPrivate                { get; set; }
    public  renderMenuPublic            renderMenuPublic                   { get; set; }
    public  renderMenuPrivate           renderMenuPrivate                  { get; set; }
    public  renderFooterPublic          renderFooterPublic                 { get; set; }
    public  renderFooterPrivate         renderFooterPrivate                { get; set; }
    public  handleAppSpecificResponse   renderAppSpecificUserToDoMessages  { get; set; }   
    public  handleAppendingUserSpecificNotifications appendUserSpecificNotifications  { get; set; }
    
    public bool userHasAccessToFilesUploadDownload { get; set;}
    public bool userHasAccessToFilesUpload         { get; set;}
    public bool userHasAccessToFilesDownload       { get ;set; }
    public bool contentOnly                        {  get { return _contentOnly; } }
    public bool isSubPage                          {  get { return _isSubPage; } }

    /*-------------------------------
     * Methods
     *------------------------------*/
    
   /***************************************************************************
     * _evaluateContentFlags */
    /**
     * 
     ****************************************************************************/

    protected void _evaluateContentFlags (bool initialEval)
    {
        if (initialEval == true) { 
          _contentOnly = false;
          _isSubPage   = false;
        }

        if ((renderOptionContentOnly == true) || (rd.contentOnly != "0")) {          
          _contentOnly = true;        
        }

        if (rd.appMode == Constants.AMD_UI_DBS_SUB_PAGE) { 
          _isSubPage = true; 
        }
    }

    /***************************************************************************
     * OnLoadBase */
    /**
     * Provides a helper method for the base call used in the delegate inside
     * OnLoad.  If a helper method was not used the following compiler warning
     * would be thrown.
     * 
     * Access to member 'B.M()' through a 'base' keyword from an anonymous method
     * or iterator results in unverifiable code.  Calling virtual functions with
     * the base keyword inside the method body of an iterator or anonymous methods
     * will result in unverifiable code. Unverifiable code will fail to run
     * in a partial trust environment. One resolution for CS1911 is to move
     * the virtual function call to a helper function.
     ***************************************************************************/

    protected void OnLoadBase(EventArgs e){base.OnLoad(e);}

    /***************************************************************************
     * OnLoad */
    /**
     * Provides a wrapper for the Page_Load method in the pages code behind.
     * The wrapper used is callMethod.  We use a helper method, OnLoadBase
     * to conduct this call properly.
     ***************************************************************************/

    protected override void OnLoad(EventArgs e)
    {      
            
      rd = HttpApplication.retrieveRequestResponse();
      
      _publicPage = false;

      if (this._permittedRoles == null)
      {
        _publicPage = true;
      }
      
      else
      {
        if (this._permittedRoles.Length == 0) _publicPage = true;
      }

      _evaluateContentFlags(true);

      if (_publicPage)
      {      
        // Public page
        callMethod(typeof(Return), delegate(){Return so = new Return();OnLoadBase(e);return so;});      
      }
      else
      {      
       // Private page              
       callMethod(typeof(Return), delegate(){Return so = new Return();OnLoadBase(e);return so;},this._permittedRoles);      
      }
    }

    /***************************************************************************
     * Render */
    /**
     * Overides all dynamic web page rendering.
     * If the RESPONSE_REMOVE_WHITE_SPACE rule is true then this method also
     * removes all white space from response to reduce response size and improve
     * document parsing on the client.
     * White space removal solution courtesy of Mads Kristensen 
     * http://archive.webdevelopernews.com/2007/1026.html
     ***************************************************************************/   
    
    protected override void Render(HtmlTextWriter writer)
    { 
      if (!Rules.RESPONSE_REMOVE_WHITE_SPACE){base.Render(writer);return;}

      using (HtmlTextWriter htmlwriter = new HtmlTextWriter(new System.IO.StringWriter()))
      {
        base.Render(htmlwriter);

        string html = htmlwriter.InnerWriter.ToString();
        html = PatternMatch.REGEX_BETWEEN_TAGS.Replace (html, ">");
        html = PatternMatch.REGEX_LINE_BREAKS.Replace  (html, "<");
        writer.Write(html.Trim());
      } 
    }
        
    /***************************************************************************
     * RenderCSSInclude */
    /**
     * 
     ****************************************************************************/

    public static void RenderCSSInclude (ref HtmlTextWriter writer, string src, bool tsUrl = false)
    {      
      if (tsUrl)  
        writer.Write(@"<link rel=""stylesheet"" href=""{0}?{1}"">",src,DateTime.Now.Ticks);
      else
        writer.Write(@"<link rel=""stylesheet"" href=""{0}"">",src);          
    }

    /***************************************************************************
     * RenderCSSMinifierInclude */
    /**
     * 
     ****************************************************************************/
    public static void RenderCSSMinifierInclude (ref HtmlTextWriter writer, string src)
    {            
      writer.Write(MBA.cssMinifierHandler.generateLink(HttpContext.Current, src));
    }
    
    /***************************************************************************
     * RenderJSInclude */
    /**
     * 
     ****************************************************************************/

    public static void RenderJSInclude (ref HtmlTextWriter writer, string src, bool tsUrl = false)
    {      
      if (tsUrl)  
        writer.Write(@"<script type=""text/javascript"" src=""{0}?{1}""></script>",src,DateTime.Now.Ticks);
      else
        writer.Write(@"<script type=""text/javascript"" src=""{0}""></script>",src);          
    }
        
    /***************************************************************************
     * RenderJSMinifierInclude */
    /**
     * 
     ****************************************************************************/
    public static void RenderJSMinifierInclude (ref HtmlTextWriter writer, string src)
    {            
      writer.Write(MBA.jsMinifierHandler.generateLink(HttpContext.Current, src));
    }

    /***************************************************************************
     * RenderPageSpecificCSSMinifierIncludes */
    /**
     * 
     ****************************************************************************/
    public static void RenderPageSpecificCSSMinifierIncludes (ref HtmlTextWriter writer, string[] srcs)
    {            
      RenderPageSpecificCSSMinifierIncludes(ref writer,Constants.PATH_CSS,srcs);
    }

    public static void RenderPageSpecificCSSMinifierIncludes (ref HtmlTextWriter writer, string cssPath, string[] srcs)
    {            
      foreach (string src in srcs)
      { 
        string pathAndSrc = cssPath + src;
        writer.Write(MBA.cssMinifierHandler.generateLink(HttpContext.Current, pathAndSrc));
      }
    }

    /***************************************************************************
     * RenderPageSpecificCSS */
    /**
     * 
     ****************************************************************************/

    public static string GeneratePageSpecificCSSIncludes (String[] cssFiles)
    {
      
      return GeneratePageSpecificCSSIncludes(Constants.PATH_CSS,cssFiles);  
    }

    public static string GeneratePageSpecificCSSIncludes (string cssPath, String[] cssFiles)
    {
      
      StringBuilder sb = new StringBuilder();
      
      foreach (string cssFile in cssFiles)        
        sb.AppendFormat(@"<link rel=""stylesheet"" type=""text/css"" media=""all"" href=""{0}{1}?{2}""/>"
                        , cssPath
                        , cssFile
                        , DateTime.Now.Ticks);
    
      return sb.ToString();
    }

    /***************************************************************************
     * RenderPageSpecificJS */
    /**
     * 
     ****************************************************************************/

    public static string GeneratePageSpecificJSIncludes (String[] jsFiles)
    {      
      return GeneratePageSpecificJSIncludes(Constants.PATH_JS, jsFiles);
    }        
    
    public static string GeneratePageSpecificJSIncludes (string jsPath, String[] jsFiles)
    {      
      StringBuilder sb = new StringBuilder();
      
      foreach (string jsFile in jsFiles)        
        sb.AppendFormat(@"<script type=""text/javascript"" src=""{0}{1}?{2}""></script>"
                         , jsPath
                         , jsFile
                         , DateTime.Now.Ticks);
      
      return sb.ToString();
    }

    /***************************************************************************
     * RenderPageSpecificJSMinifierIncludes */
    /**
     * 
     ****************************************************************************/
    public static void RenderPageSpecificJSMinifierIncludes (ref HtmlTextWriter writer, string[] srcs)
    {            
      RenderPageSpecificJSMinifierIncludes(ref writer,Constants.PATH_JS,srcs);
    }

    public static void RenderPageSpecificJSMinifierIncludes (ref HtmlTextWriter writer, string jsPath, string[] srcs)
    {            
      foreach (string src in srcs)
      { 
        string pathAndSrc = jsPath + src;
        writer.Write(MBA.jsMinifierHandler.generateLink(HttpContext.Current, pathAndSrc));
      }
    }

    /***************************************************************************
     * CreatePageSubtitle */
    /**
     * Create a subtitle for a page from the given parts.
     * For example CreatePageSubTitle("Users","View") would return Users - View
     * 
     * @param  parts  One or more parts of the subtitle.
     * @returns       string
     ****************************************************************************/
               
    public static string CreatePageSubTitle (params string[] parts)
    {      
      if (parts == null) return "";              
      string pagetitle = String.Join (" - ", parts);                  
      return pagetitle;
    }
     
	//SBC Added for TimeKeeper
    public static string CreatePageSubTitleNoHyphen(params string[] parts)
    {
        if (parts == null) return "";
        string pagetitle = String.Join(" ", parts);
        return pagetitle;
    }
	
	 
   /***************************************************************************
     * createNeedMoreHelpContactContent */
    /**
     * 
     ****************************************************************************/

   public static string createNeedMoreHelpContactContent (ref RequestResponse rd, SqlConnection connUsers
                                        , DetailsLog log
                                        , UserInfo uInfo
                                        )
   {

     string appSettingForContactUserId = "";
     MBA.AppSettings.getAppSetting( connUsers
                                , log
                                , uInfo
                                , Constants.APP_NAME
                                , "help"
                                , "contact_person"
                                , "initial"
                                , "global"
                                , "user_id"
                                , out appSettingForContactUserId );
     
     var contactUObj = MBA.Users.load(connUsers, log, uInfo, Constants.APP_NAME, appSettingForContactUserId);

     StringBuilder sb = new StringBuilder();
     sb.AppendFormat(@"Need More Help with SpedCare?  Please contact {0} {1}", contactUObj.firstName, contactUObj.lastName);
     sb.AppendFormat(@" <a href=""mailto:{0};{2}"">{1}</a>", contactUObj.email, contactUObj.email, rd.wu.usr.clientRepEmail);

     if ( rd.wu.usr.userGroupID == Constants.USER_GROUP_CLIENT)
       sb.AppendFormat(@"<br/>and {3} {4} <a href=""mailto:{0};{2}"">{1}</a>",rd.wu.usr.clientRepEmail,rd.wu.usr.clientRepEmail, contactUObj.email, rd.wu.usr.clientRepFirstName, rd.wu.usr.clientRepLastName);

     if (!(Util.IsNullOrEmpty(contactUObj.phone)) )
       sb.AppendFormat(@" <a href=""tel:{0}"">{1}</a>", contactUObj.phone, contactUObj.phone);

     sb.Append(@".");
     
     if ( rd.wu.usr.userGroupID == Constants.USER_GROUP_CLIENT)
     {

       sb.Append(@"<br/>");

       sb.AppendFormat(@"Need More Help With Anything Else?  Please contact {0} {1}", rd.wu.usr.clientRepFirstName, rd.wu.usr.clientRepLastName);
       sb.AppendFormat(@" <a href=""mailto:{0}"">{1}</a>",rd.wu.usr.clientRepEmail,rd.wu.usr.clientRepEmail);
       
       sb.AppendFormat(@" <a href=""tel:{0}"">{1}</a>",rd.wu.usr.clientRepPhone,rd.wu.usr.clientRepPhone);   
       sb.Append(@".");
     }

     return sb.ToString();

   }


   /***************************************************************************
     * createNeedMoreHelpContactContentTwoStrings */
    /**
     * Creates the "Need help?" and "Need more help?" blocks as two separate strings.
     * @param  contactHelpStr    out string
     * @param  contactHelpStr2   out string
     ****************************************************************************/

   public static void createNeedMoreHelpContactContentTwoStrings (ref RequestResponse rd, SqlConnection connUsers
                                        , DetailsLog log
                                        , UserInfo uInfo
                                        , out string contactHelpStr
                                        , out string contactHelpStr2
                                        )
   {

     string appSettingForContactUserId = "";
     MBA.AppSettings.getAppSetting( connUsers
                                , log
                                , uInfo
                                , Constants.APP_NAME
                                , "help"
                                , "contact_person"
                                , "initial"
                                , "global"
                                , "user_id"
                                , out appSettingForContactUserId );
     
     var contactUObj = MBA.Users.load(connUsers, log, uInfo, Constants.APP_NAME, appSettingForContactUserId);

     StringBuilder sb = new StringBuilder();
     sb.AppendFormat(@"Need More Help with SpEdCare?  Please contact us&nbsp;" );
     sb.AppendFormat(@"<span class=""need-help-contact-us-email""><a href=""mailto:{0};{1}"">HERE</a></span>", contactUObj.email, rd.wu.usr.clientRepEmail);

     //if (!(Util.IsNullOrEmpty(contactUObj.phone)) )
       //sb.AppendFormat(@" <a href=""tel:{0}"">{1}</a>", contactUObj.phone, contactUObj.phone);

     sb.Append(@".");

     contactHelpStr  =  sb.ToString();
     sb = new StringBuilder();
     
     if ( rd.wu.usr.userGroupID == Constants.USER_GROUP_CLIENT)
     {

       //sb.Append(@"<br/>");

       sb.AppendFormat(@"<div id=""contact-consultant-txt-rows"" ><div id=""contact-consultant-txt-row1"">Need non-SpEdCare assistance?  Please contact " +
                       @"your assigned Practi-Cal consultant:</div><div id=""contact-consultant-tbl-row"">" +
                       @"<br><span class=""need-help-contact-us-name"">{0} {1}</span>", rd.wu.usr.clientRepFirstName, rd.wu.usr.clientRepLastName);
       sb.AppendFormat(@"<br><span class=""need-help-contact-us-email""><a href=""mailto:{0}"">{1}</a></span>",rd.wu.usr.clientRepEmail,rd.wu.usr.clientRepEmail);       
       sb.AppendFormat(@" <span class=""need-help-contact-us-phone""><a href=""tel:{0}"">{1}</a></span>",rd.wu.usr.clientRepPhone,rd.wu.usr.clientRepPhone);   
       sb.Append(@"</div></div>");
     }

     contactHelpStr2  =  sb.ToString();
     

   }

   /***************************************************************************
     * createTeachMeNotificationContent */
    /**
     * 
     ****************************************************************************/
   
   public static string createTeachMeNotificationContent (ref RequestResponse rd, string helpUrl)
   {
     StringBuilder sb = new StringBuilder();
     
     sb.AppendFormat(@"Need Help?  <a href=""{0}"">Teach Me</a>", helpUrl);     
     sb.AppendFormat(@" Need More Help?  Please contact {0} {1}", rd.wu.usr.clientRepFirstName, rd.wu.usr.clientRepLastName);
     sb.AppendFormat(@" <a href=""mailto:{0}"">{1}</a>",rd.wu.usr.clientRepEmail,rd.wu.usr.clientRepEmail);
     sb.AppendFormat(@" <a href=""tel:{0}"">{1}</a>",rd.wu.usr.clientRepPhone,rd.wu.usr.clientRepPhone);   
     return sb.ToString();
   }

    /***************************************************************************
     * renderAppNotification */
    /**
     * 
     ****************************************************************************/
   
   public static void renderAppNotification (ref HtmlTextWriter writer, string msg)
   {  
     renderAppNotification(ref writer, msg,WebUI3Common.ElementSemantic.light,true);
   }

   
   public static void renderAppNotification (ref HtmlTextWriter writer
                                             , string msg   
                                             , WebUI3Common.ElementSemantic es = WebUI3Common.ElementSemantic.light
                                             , bool dismissable=true)
   {  
     string level = String.Format(@"app-notification-{0}",WebUI3Common.GetElementSemanticName(es));
     writer.Write(@"<li class=""app-notification {0}"">{1}",level,msg);     
     writer.Write(@"<button type=""button"" class=""app-notification app-notification-dismiss"" aria-label=""Close""><span aria-hidden=""true"">&times;</span></button>");
     writer.Write(@"</li>");
   }


   /***************************************************************************
     * renderAppBarIcon */
    /**
     * 
     ****************************************************************************/
    
    public static void renderAppBarIcon (     ref HtmlTextWriter writer
                                            , string             title
                                            , string             iconName
                                            , string             url
                                            , string             id = ""
                                            , bool               newWindow = false)
                                             
    {
      string idAttr = @"";
      string targetAttr = @"";
      if (!String.IsNullOrEmpty(id)) idAttr = @"id=""" + id + @"""";
      if (newWindow) targetAttr = @"target=""_blank""";

      writer.Write (
          @"<a {3} {4} href=""{2}"" title=""{0}"" class=""material-icons mdc-top-app-bar__action-item"" aria-label=""{0}"">{1}</a>"
        , title
        , iconName
        , url
        , idAttr
        , targetAttr);

    }
        
  
   /***************************************************************************
     * renderAppBarIconDropMenuItem */
    /**
     * 
     ****************************************************************************/
   
   public static void renderAppBarIconDropMenuItem ( ref HtmlTextWriter writer
                                                   , string icon 
                                                   , string label
                                                   , string link
                                                   , bool openInNew)
   {
       var target = openInNew ? @" target=""blank""" : @"";
       writer.Write(@"<li class=""mdc-list-item"" role=""menuitem"">");
       writer.Write(@"<span class=""mdc-list-item__graphic material-icons"">{0}</span>",icon);
       writer.Write(@"<a href=""{0}""{1}>{2}</a>",link,target,label);
       writer.Write(@"</li>");
   }

   /***************************************************************************
     * renderMyAccountAppBarIconDropMenu */
    /**
     * 
     ****************************************************************************/
    
    public void renderFilesAppBarIconDropMenu (  ref HtmlTextWriter writer
                                               , string sendUsAFileLink 
                                               , string viewFilesSentToUsLink
                                               , bool userHasAccessToUpload
                                               , bool userHasAccessToDownload)
    {            
      writer.Write(@"<div id=""files-icon-menu"" class=""mdc-menu-surface"">");
      writer.Write(@"<ul class=""mdc-list"" role=""menu"" aria-hidden=""true"" aria-orientation=""vertical"" tabindex=""-1"">");		  
      if (userHasAccessToUpload)   renderAppBarIconDropMenuItem(ref writer,@"cloud_upload",  @"Send Us A File",        sendUsAFileLink,       true);
      if (userHasAccessToDownload) renderAppBarIconDropMenuItem(ref writer,@"cloud_download",@"View Files Sent To Us", viewFilesSentToUsLink, true);
      writer.Write(@"</ul>");
      writer.Write(@"</div>");
    }
   
    
    /***************************************************************************
     * renderMyAccountAppBarIconDropMenu */
    /**
     * 
     ****************************************************************************/
    
    public void renderMyAccountAppBarIconDropMenu (  ref HtmlTextWriter writer
                                                    , string userName
                                                    , string userTitle
                                                    , string userOrganization
                                                    , string changeMyPasswordLink
                                                    , string logoutLink
                                                    , string appTitle
                                                    , string appVersion)
    {
      writer.Write(@"<div id=""my-account-icon-menu"" class=""mdc-menu-surface"">"); 
      
      writer.Write(@"<ul id=""my-account-avatar-list-ul"" class=""mdc-list mdc-list--two-line mdc-list--avatar-list"" role=""menu"" aria-hidden=""true"" aria-orientation=""vertical"" tabindex=""-1"">");
      writer.Write(@"<li id=""my-account-avatar-list-li"" class=""mdc-list-item--disabled"" tabindex=""-1"">");
      writer.Write(@"<span class=""mdc-list-item__graphic material-icons"" aria-hidden=""true"">account_circle</span>");
      writer.Write(@"<span class=""mdc-list-item__text"">");
      writer.Write(@"<span class=""mdc-list-item__primary-text mdc-list-item-user-name"">{0}</span>",userName);
      writer.Write(@"<span class=""mdc-list-item__secondary-text mdc-list-item-user-title"">{0}</span>",userTitle);
      writer.Write(@"<span class=""mdc-list-item__secondary-text mdc-list-item-user-organization"">{0}</span>",userOrganization);

      writer.Write(@"<span class=""mdc-list-item__secondary-text mdc-list-item-app-info mdc-list-item-app-title"">{0}</span>", appTitle);
      writer.Write(@"<span class=""mdc-list-item__secondary-text mdc-list-item-app-info mdc-list-item-app-version"">Version {0}</span>", appVersion);

      writer.Write(@"</span>");
      writer.Write(@"</li>");
      writer.Write(@"</ul>");
      
      writer.Write(@"<ul class=""mdc-list"" role=""menu"" aria-hidden=""true"" aria-orientation=""vertical"" tabindex=""-1"">");		  
      renderAppBarIconDropMenuItem(ref writer,@"vpn_key",             @"Change My Password", changeMyPasswordLink, false);
      renderAppBarIconDropMenuItem(ref writer,@"power_settings_new",  @"Logout",             logoutLink,           false);
      writer.Write(@"</ul>");
      writer.Write(@"</div>");
    }
    
    /***************************************************************************
     * generateMenuListItemHtmlString */
    /**
     * 
     ****************************************************************************/
    
    public static string generateMenuListItemHtmlString (string linkID, string url, bool urlPvt, string selLabel, bool hidden)
    {
      return generateMenuListItemHtmlString(linkID, url, urlPvt, selLabel, hidden, false);
    }

    public static string generateMenuListItemHtmlString (  string linkID
                                                         , string url
                                                         , bool urlPvt
                                                         , string selLabel
                                                         , bool hidden
                                                         , bool urlExt)
    {
      string liClass = hidden ? @"menu-item menu-item-hidden" : @"menu-item menu-item-visible";
      
      if (Util.IsNullOrEmpty(linkID)) linkID = Util.createUniqueID();
            
      string href = urlExt ? url : MBA.HttpApplication.createLink(url, urlPvt);

      return String.Format( @"<li class=""{3}""><a id=""{0}"" href=""{1}"">{2}</a></li>"
                           , linkID
                           , href
                           , selLabel
                           , liClass);

    }

    /***************************************************************************
     * renderMenuStart */
    /**
     * 
     ****************************************************************************/

    protected void RenderMenuStart (string navContainerClass, ref HtmlTextWriter writer)
    {
       writer.Write(@"<nav id=""nav-container"" class=""{0}"">",navContainerClass);
       writer.Write(@"<ul id=""navigation"" class=""navigation-main"">"); 
    }

    /***************************************************************************
     * renderMenuEnd */
    /**
     * 
     ****************************************************************************/

    protected void RenderMenuEnd (ref HtmlTextWriter writer)
    {
      writer.Write(@"</ul>");
      writer.Write(@"</nav>");       
    }

    /***************************************************************************
     * renderTopMenuListStart */
    /**
     * 
     ****************************************************************************/

    public static void renderTopMenuListStart (ref HtmlTextWriter writer, string selLabel)
    {
       renderTopMenuListStart(ref writer,selLabel,false);
    }

    public static void renderTopMenuListStart (ref HtmlTextWriter writer, string selLabel, bool hidden)
    {
      string liClass = hidden ? @"menu-item menu-item-hidden" : @"menu-item menu-item-visible";
      writer.Write(@"<li title=""Click to expand/collapse options"" class=""{0} menu-drop-icon-clear-float""><a>" + selLabel + @"<span class=""menu-drop-icon menu-drop-icon-down"">▾</span></a>",liClass);
      writer.Write(@"<ul class=""navigation-sub"">"); 
    }

    /***************************************************************************
     * renderTopMenuListEnd */
    /**
     * 
     ****************************************************************************/
    
    public static void renderTopMenuListEnd (ref HtmlTextWriter writer)
    {
      writer.Write(@"</ul></li>");
    }

    /***************************************************************************
     * renderSubMenuListStart */
    /**
     * 
     ****************************************************************************/

    public static void renderSubMenuListStart (ref HtmlTextWriter writer, string selLabel)
    {
      renderSubMenuListStart(ref writer, selLabel, false);
    }
    
    public static void renderSubMenuListStart (ref HtmlTextWriter writer, string selLabel, bool hidden)
    {
      string liClass = hidden ? @"menu-item menu-item-hidden" : @"menu-item menu-item-visible";
      writer.Write(@"<li title=""Click to expand/collapse options"" class=""{0} menu-drop-icon-clear-float""><a>" + selLabel + @"<span class=""menu-drop-icon menu-drop-icon-right"">▸</span></a>", liClass);
      writer.Write(@"<ul class=""navigation-sub"">"); 
    }

    /***************************************************************************
     * renderSubMenuListStart */
    /**
     * 
     ****************************************************************************/
    
    public static void renderSubMenuListEnd (ref HtmlTextWriter writer)
    {
      writer.Write(@"</ul></li>");
    }
    
    /***************************************************************************
     * renderMenuListItem */
    /**
     * 
     ****************************************************************************/    
    public static void renderMenuListItem (   ref HtmlTextWriter writer
                                            , string             linkID
                                            , string             selLabel
                                            , string             url                                            
                                          )
                                             
    {
      renderMenuListItem(ref writer, linkID, selLabel, url, true, false);
    }

    public static void renderMenuListItem (   ref HtmlTextWriter writer
                                            , string             linkID
                                            , string             selLabel
                                            , string             url
                                            , bool               urlPvt
                                            , bool               hidden
                                           )
    {
      writer.Write( generateMenuListItemHtmlString(linkID, url, urlPvt, selLabel, hidden));
    }

                                            
    public static void renderMenuListItem (   ref HtmlTextWriter writer
                                            , string             linkID
                                            , string             selLabel
                                            , string             url
                                            , bool               urlPvt
                                            , bool               hidden
                                            , bool               useUrlAsIs
                                           )
    {
      writer.Write( generateMenuListItemHtmlString(linkID, url, urlPvt, selLabel, hidden, useUrlAsIs));
    }

    /***************************************************************************
     * RenderAppLogo */
    /**
     * 
     ****************************************************************************/

    public void RenderAppLogo (  ref HtmlTextWriter  writer                                                     
                                , ref RequestResponse rd  )
    {    
      RenderAppLogo(ref writer, ref rd, null);
    }

    public void RenderAppLogo (  ref HtmlTextWriter  writer                                                     
                                , ref RequestResponse rd                                
                                , string cssClass = "")
    {    
      writer.Write(@"<a class=""applogo {2}"" href=""{0}"">{1}</a>",homeLink, appLogoMarkup, cssClass);
    }

    /***************************************************************************
     * RenderAppLogo */
    /**
     * 
     ****************************************************************************/

    public void RenderAppLogo (  ref HtmlTextWriter  writer                                                     
                                , ref RequestResponse rd
                                , string cssClass      = ""
                                , bool disableHomeLink = false
)
    {    
      string href = homeLink;
      if (disableHomeLink) href = @"#";
      writer.Write(@"<a class=""applogo mdc-top-app-bar__title {2}"" href=""{0}"">{1}</a>",href, appLogoMarkup, cssClass);
    }

    public static string GenerateSupportedBrowserInfoHtml  ( ref RequestResponse rd )
    {     
      StringBuilder sb = new StringBuilder();
      
      if ((!rd.browserSupported) && (!rd.isBot))
      { 
        sb.Append (@"You may be using a browser that is not supported.  The use of unsupported browsers might produce unpredictable results.");
        sb.Append (@"<br/>");
      }
      sb.Append(@"SpEdCare supports the two most current versions of Chrome, Firefox, Safari, & Edge.");

      return sb.ToString();
    }


    /***************************************************************************
     * RenderSupportedBrowserInfo */
    /**
     * 
     ****************************************************************************/

    public static void RenderSupportedBrowserInfo  (   ref HtmlTextWriter writer                                                     
                                                     , ref RequestResponse rd )
    {     
      writer.Write(GenerateSupportedBrowserInfoHtml(ref rd));  
    }

    /***************************************************************************
     * RenderUserInfo  */
    /**
     * 
     ****************************************************************************/
    public void RenderUserInfo (   ref HtmlTextWriter writer
                                 , ref RequestResponse rd )
    {
      if (rd.loggedIn)
      {               
        writer.Write (@"You are logged in as {0} {1} {2}", userName, userTitle, userOrganization);        
      }
    }

    /***************************************************************************
     * RenderRobotsMetaTags */
    /**
     * 
     ****************************************************************************/

    public static void RenderRobotsMetaTags (  ref HtmlTextWriter writer
                                             , ref RequestResponse rd)
    {
      /*===============================
       * Crawler indexing of public
       * pages only if webconfig 
       * crawl setting is true (default)
       *===============================*/ 
      
      if (rd.loggedIn == false) 
      {
        if (Constants.APP_SE_CRAWL.HasValue) 
          if (Constants.APP_SE_CRAWL.Value == false)                  
            writer.Write(@"<meta name=""robots"" content=""noindex, nofollow"">");       
      }     
      else
      {
        writer.Write(@"<meta name=""robots"" content=""noindex, nofollow"">");
      }

    }

    /***************************************************************************
     * RenderDocumentStartHeadStartCommonMetaPageTitle */
    /**
     * 
     ****************************************************************************/

    
     public static void RenderDocumentStartHeadStartCommonMetaPageTitle (  ref HtmlTextWriter writer
                                                                        , ref RequestResponse rd
                                                                        , string subTitle)
     {
       RenderDocumentStartHeadStartCommonMetaPageTitle(ref writer, ref rd, null, subTitle);
     }
    
     public static void RenderDocumentStartHeadStartCommonMetaPageTitle ( ref HtmlTextWriter writer
                                                                        , ref RequestResponse rd
                                                                        , string headid
                                                                        , string subTitle)
     {
      
       if (String.IsNullOrEmpty(headid)) headid = Util.createUniqueID();

       writer.WriteLine(@"<!doctype html>");     
	   writer.Write(@"<html lang=""{0}"">", rd.language);         
       writer.Write(@"<head id=""{0}"">",headid);
    
      /*################################
        # Meta
        #
        # Note: First 3 tags must come
        #       before anything else.
        ###############################*/

      writer.Write(@"<meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"">");
      writer.Write(@"<meta name=""viewport"" content=""width=device-width, initial-scale=1, shrink-to-fit=no"">");
      writer.Write(@"<meta http-equiv=""X-UA-Compatible"" content=""IE=edge"">");
             
      /*################################
        # Crawler indexing of public
        # pages only if webconfig 
        # crawl setting is true (default)
        ###############################*/
     
      RenderRobotsMetaTags(ref writer, ref rd);

      /*################################
        # Title
        ###############################*/

      writer.Write(@"<title>" + Constants.APP_TITLE + (String.IsNullOrEmpty(subTitle) ? "" :" - " + subTitle)  + @"</title>");

      /*################################
        # Application info
        ###############################*/
      
      writer.Write(@"<meta name=""application-name"" content=""{0}"">", Constants.APPLICATION_NAME);
      writer.Write(@"<meta name=""description"" content=""{0}"">",      Constants.APP_DESCRIPTION);
      writer.Write(@"<meta name=""keywords"" content=""{0}"">",         Constants.APP_KEYWORDS);
            
      /*################################
        # Favicon
        ###############################*/

      writer.Write(@"<link rel=""apple-touch-icon"" sizes=""180x180"" href=""web-ui-3/mba/css/app-icons/apple-touch-icon.png"" />");
      writer.Write(@"<link rel=""icon"" type=""image/png"" sizes=""32x32"" href=""web-ui-3/mba/css/app-icons/favicon-32x32.png"" />");
      writer.Write(@"<link rel=""icon"" type=""image/png"" sizes=""192x192"" href=""web-ui-3/mba/css/app-icons/android-chrome-192x192.png"" />");
      writer.Write(@"<link rel=""icon"" type=""image/png"" sizes=""16x16"" href=""web-ui-3/mba/css/app-icons/favicon-16x16.png"" />");
      writer.Write(@"<link rel=""manifest"" href=""web-ui-3/mba/css/app-icons/site.webmanifest"" />");
      writer.Write(@"<link rel=""mask-icon"" href=""web-ui-3/mba/css/app-icons/safari-pinned-tab.svg"" color=""#5bbad5"" />");
      writer.Write(@"<meta name=""msapplication-TileColor"" content=""#2b5797"" />");
      writer.Write(@"<meta name=""msapplication-TileImage"" content=""/mstile-144x144.png"" />");
      writer.Write(@"<meta name=""theme-color"" content=""#ffffff"" />");
    }

    /***************************************************************************
     * RenderHeadEndBodyStart*/
    /**
     * 
     ****************************************************************************/

   public static void RenderHeadEndBodyStart (  ref HtmlTextWriter writer
                                               , ref RequestResponse rd )
   {
     RenderHeadEndBodyStart(ref writer, ref rd, null);
   }

   public static void RenderHeadEndBodyStart (  ref HtmlTextWriter writer
                                               , ref RequestResponse rd
                                               , string bodyID )
    {
      
	    writer.Write(@"</head>"); 
      if (String.IsNullOrEmpty(bodyID)) bodyID = Util.createUniqueID();
      writer.Write(@"<body id=""{0}"">", bodyID);
    }

    /***************************************************************************
     * RenderWorkInProgressSavePointsIncludes */
    /**
     * 
     ****************************************************************************/
    
    public static void RenderWorkInProgressSavePointsIncludes (   ref      HtmlTextWriter  writer
                                                                , ref      RequestResponse rd
                                                                , bool     useWorkInProgressSavePointsIncludes                                                                
                                                                , string   webSvcSaveOrReplaceUrl
                                                                , string   webSvcDeleteUrl
                                                                , string   sessionExpiredUrl )
    {
       
      if (rd.loggedIn                         == false) return;  /* Not logged in, not supported.*/
      if (useWorkInProgressSavePointsIncludes == false) return;  /* User requested this not be used */
            
      /* Generate object to pass settings values from middle to front */

      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"var MBA = (MBA || {});");
      writer.Write(@"MBA.WorkInProgressSavePointsCommon = {};");
      writer.Write(@"MBA.WorkInProgressSavePointsCommon.webSvcSaveOrReplaceUrl='"  + webSvcSaveOrReplaceUrl    + @"';");
      writer.Write(@"MBA.WorkInProgressSavePointsCommon.webSvcDeleteUrl='"         + webSvcDeleteUrl           + @"';");
      writer.Write(@"MBA.WorkInProgressSavePointsCommon.sessionExpiredUrl='"       + sessionExpiredUrl         + @"';");
      writer.Write(@"MBA.WorkInProgressSavePointsCommon.requestResource='"         + rd.requestResource        + @"';");
      writer.Write(@"MBA.WorkInProgressSavePointsCommon.parmNameRequestResource='" + Constants.PARM_WIP_SP_REQUEST_RESOURCE  + @"';");
      writer.Write(@"MBA.WorkInProgressSavePointsCommon.parmNameSavePointName='"   + Constants.PARM_WIP_SP_NAME              + @"';");
      writer.Write(@"MBA.WorkInProgressSavePointsCommon.parmNameSavedDataJSON='"   + Constants.PARM_WIP_SP_SAVED_DATA_JSON   + @"';");
      writer.Write(@"MBA.WorkInProgressSavePointsCommon.parmNameSavedDataJSON='"   + Constants.PARM_WIP_SP_SAVED_DATA_JSON   + @"';");
      writer.Write(@"MBA.WorkInProgressSavePointsCommon.saveEnabled=true;");            
      writer.Write(@"MBA.WorkInProgressSavePointsCommon.deleteEnabled=true;");            
      writer.Write(@"</script>");

      RenderJSMinifierInclude (ref writer, @"js/mba-work-in-progress-save-points.js");
      
    }
        
    /***************************************************************************
     * RenderSessionHelperIncludes */
    /**
     * 
     ****************************************************************************/

    public static void RenderSessionHelperIncludes (   ref      HtmlTextWriter  writer
                                                     , ref      RequestResponse rd
                                                     , bool     useSessionHelper
                                                     , bool     useSessionHelperPrivacyScreen
                                                     , string   webSvcUrlKeepAlive
                                                     , string   sessionExpiredUrl
                                                     , int      maxIdleSessionSeconds
                                                     , int      userIsConsideredIdleAfterNSeconds
                                                     , bool     renderContentOnly )
    {

      if (rd.loggedIn      == false) return;  /* Not logged in, not supported.*/
      if (useSessionHelper == false) return;  /* User requested this not be used */
            
      /* Generates url for worker */
                      
      var sessionHelperWorkerUrl = jsMinifierHandler.generateUrl(HttpContext.Current,@"js/mba-session-helper-worker.js");

      /* Generate object to pass settings values from middle to front */

      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"var MBA = (MBA || {});");
      writer.Write(@"MBA.SessionHelperCommon = {};");
      writer.Write(@"MBA.SessionHelperCommon.fnExecuteCustomTasks       = function() { return;};");
      writer.Write(@"MBA.SessionHelperCommon.fnExecuteBeforePageUnload  = function(e){ return;};");            
      writer.Write(@"MBA.SessionHelperCommon.maxIdleSessionSeconds="              + maxIdleSessionSeconds.ToString()                    + @";");
      writer.Write(@"MBA.SessionHelperCommon.userIsConsideredIdleAfterNSeconds="  + userIsConsideredIdleAfterNSeconds.ToString()        + @";");     
      writer.Write(@"MBA.SessionHelperCommon.sessionHelperWorkerUrl='"            + sessionHelperWorkerUrl                              + @"';");
      writer.Write(@"MBA.SessionHelperCommon.urlRequestKeepAlive='"               + webSvcUrlKeepAlive                                  + @"';");
      writer.Write(@"MBA.SessionHelperCommon.sessionExpiredUrl='"                 + sessionExpiredUrl                                   + @"';");
      writer.Write(@"MBA.SessionHelperCommon.requestedResource='"                 + rd.requestResource                                  + @"';");
      writer.Write(@"MBA.SessionHelperCommon.appMode='"                           + rd.appMode                                          + @"';");    
      writer.Write(@"MBA.SessionHelperCommon.renderContentOnly="                  + Util.netBoolToJSBool(renderContentOnly)             + @";");
      writer.Write(@"MBA.SessionHelperCommon.useSessionHelperPrivacyScreen="      + Util.netBoolToJSBool(useSessionHelperPrivacyScreen) + @";");
      writer.Write(@"</script>");

      RenderJSMinifierInclude (ref writer, @"js/mba-session-helper.js");
      
    }
    
    /***************************************************************************
     * RenderPrivateStoredFilesEndPointsAndParmNames */
    /**
     *  Only for logged in users who have access to file upload and download
     ****************************************************************************/
    
    public static void RenderPrivateStoredFilesEndPointsAndParmNames (   ref      HtmlTextWriter  writer                                                    
                                                                       , ref      RequestResponse rd
                                                                       , bool     userHasAccessToFilesUploadDownload
                                                                       , string   listHandlerPrivateUrl
                                                                       , string   downloadHandlerPrivateUrl
                                                                       , string   uploadHandlerPrivateUrl 
                                                                       , string   parmNameFileID
                                                                       , string   parmNameClientID
                                                                       , string   parmNamePracID
                                                                       , string   parmNamePatID )
    {
       
      if (rd.loggedIn == false) return;  /* Not logged in, not supported.*/

      /* Generate object to pass settings values from middle to front */

      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"var MBA = (MBA || {});");
      
      writer.Write(@"MBA.StoredFilesPrivateEndPointsAndParmNames = {};");
      writer.Write(@"MBA.StoredFilesPrivateEndPointsAndParmNames.userHasAccessToFilesUploadDownload="  + Util.netBoolToJSBool(userHasAccessToFilesUploadDownload) + @";");
      
      if (!userHasAccessToFilesUploadDownload)
      {           
        writer.Write(@"</script>");
        return;
      }

      writer.Write(@"MBA.StoredFilesPrivateEndPointsAndParmNames.listHandlerPrivateUrl='"  + listHandlerPrivateUrl         + @"';");
      writer.Write(@"MBA.StoredFilesPrivateEndPointsAndParmNames.downloadHandlerPrivateUrl='"  + downloadHandlerPrivateUrl + @"';");  
      writer.Write(@"MBA.StoredFilesPrivateEndPointsAndParmNames.uploadHandlerPrivateUrl='"  + uploadHandlerPrivateUrl + @"';");        
      writer.Write(@"MBA.StoredFilesPrivateEndPointsAndParmNames.parmNameFileID='"  + parmNameFileID + @"';");        
      writer.Write(@"MBA.StoredFilesPrivateEndPointsAndParmNames.parmNameClientID='"  + parmNameClientID + @"';");
      writer.Write(@"MBA.StoredFilesPrivateEndPointsAndParmNames.parmNamePracID='"  + parmNamePracID + @"';");
      writer.Write(@"MBA.StoredFilesPrivateEndPointsAndParmNames.parmNamePatID='"  + parmNamePatID + @"';");
      writer.Write(@"</script>");      
      return;
     }
        
     /***************************************************************************
     * RenderBodyEndDocumentEnd */
    /**
     * 
     ****************************************************************************/

    public static void RenderBodyEndDocumentEnd (  ref HtmlTextWriter writer
                                                  , ref RequestResponse rd)
    {
      
	    writer.Write(@"</body>"); 
      writer.Write(@"</html>");     
    }
    
    /***************************************************************************
     * InitLinksAndLabels */
    /**
     * 
     ****************************************************************************/

    public void InitLinksAndLabels ()
    {
    
      loginLink            = MBA.HttpApplication.createLink(MBA.Constants.HOME_PRIVATE,new NameValue(Constants.PARM_CMD,Constants.CMD_LOGIN));
      forgotMyPasswordLink = MBA.HttpApplication.createLink(MBA.Constants.FORGOT_MY_PASSWORD,false);
      requestAccountLink   = MBA.Constants.REQUEST_ACCOUNT;

      /*-------------------------------
       * Private page
       *------------------------------*/ 

      if (rd.loggedIn)
      {                
        
        /* Links */
        
        logoutLink           = MBA.HttpApplication.createLink(MBA.Constants.HOME_PRIVATE) + "?" + Constants.PARM_CMD + "=" + Constants.CMD_LOGOUT + "&" + Constants.PARM_TOKEN + "=" + HttpApplication.clientToken();
        homeLink             = HttpApplication.createLink(MBA.Constants.HOME_PRIVATE,       true);  
        changeMyPasswordLink = HttpApplication.createLink(MBA.Constants.CHANGE_MY_PASSWORD, true);
        helpLink             = HttpApplication.createLink(MBA.Constants.HELP_PRIVATE,       true);
        manPagesLink         = HttpApplication.createLink(MBA.Constants.MAN_PAGES_PRIVATE,  true, new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE));        
        
        /* Labels */

        platformInfo                       = rd.userAgent;  
        userName                           = rd.wu.usr.name;
        userHasAccessToFilesUploadDownload = false;
        userHasAccessToFilesUpload         = false;
        userHasAccessToFilesDownload       = false;

        // Populate user identification display data

        if (rd.wu.usr.userGroupID == Constants.USER_GROUP_CLIENT)
        {          
          userOrganization                   = rd.wu.usr.clientName; 
          downloadLink                       = HttpApplication.createLink(MBA.Constants.DOWNLOAD_PRIVATE_CLIENT, true, new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE));
          uploadLink                         = MBA.Constants.REQUEST_FILE_UPLOAD_PUBLIC;
          userHasAccessToFilesUploadDownload = true;
          userHasAccessToFilesUpload         = true;
          userHasAccessToFilesDownload       = true;
          if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID)
          {
            userTitle  = rd.wu.pr.groupName;
          }
          else
          {
            userTitle = rd.wu.usr.roleName;
          }
        }
        
        else if (rd.wu.usr.userGroupID == Constants.USER_GROUP_SBSC)
        {
          userOrganization                   = "Practi-Cal";
          downloadLink                       = HttpApplication.createLink(MBA.Constants.DOWNLOAD_PRIVATE_PCAL, true,new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE));
          uploadLink                         = HttpApplication.createLink(MBA.Constants.UPLOAD_PRIVATE,     true);        
          userHasAccessToFilesUploadDownload = true;
          userHasAccessToFilesUpload         = true;
          userHasAccessToFilesDownload       = true;
          userTitle                          = rd.wu.usr.roleName;          
        }
        
        else if (rd.wu.usr.userGroupID == Constants.USER_GROUP_THIRD_PARTY_PERSON)
        {          
          userOrganization                   = "";
          downloadLink                       = "";
          uploadLink                         = "";
          userTitle                          = rd.wu.usr.roleName;  
          userHasAccessToFilesUploadDownload = false;
          userHasAccessToFilesUpload         = false;
          userHasAccessToFilesDownload       = false;

            if (rd.wu.usr.roleID == Constants.ROLE_SELPA_USER_ID)
            {
                userOrganization = rd.wu.usr.selpaName;
            }
            else if (rd.wu.usr.roleID == Constants.ROLE_PARENT_GUARDIAN_ID)
            {
                homeLink = HttpApplication.createLink(MBA.Constants.PARENT_PORTAL_PRIVATE, true);
            }
            else
            {      
            }
        }        
        else
        {
          userOrganization = "";
          downloadLink     = "";
          uploadLink       = "";
          userTitle                          = rd.wu.usr.roleName;          
          userHasAccessToFilesUploadDownload = false;
          userHasAccessToFilesUpload         = false;
          userHasAccessToFilesDownload       = false;

        }


                                    
      }

      /*-------------------------------
       * Public page
       *------------------------------*/ 

      else
      {        
       
        // Generate link for public home page
        
        homeLink     = HttpApplication.createLink(MBA.Constants.HOME_PUBLIC);
        uploadLink   = MBA.Constants.REQUEST_FILE_UPLOAD_PUBLIC;
        downloadLink = "";

        // Populate user identification display data

        userName    = "";
        userOrganization  = "";
        userTitle   = "";
        
      }
    
    }
    /***************************************************************************
     * callMethod */
    /**
     * Wrapper for calling framework methods.  Used by OnLoad override
     * 
     * @param  rt              Return type of method call (use typeof() operator)
     * @param  cb              Method callback (use delegate) 
     * @param  permittedRoles  If this method should be private
     *                         supply all authorized roles
     * @return                 Object containing rt (need to cast)
     ***************************************************************************/       

    protected Object callMethod(Type rt, MethodCallback cb)
    {
      return HttpApplication.callMethod(ref this.dbConnUser,ref this.dbConnApp,ref log,ref rd, ref uInfo, rt, cb);
    }
    
    protected Object callMethod(Type rt, MethodCallback cb, params string[] permittedRoles)
    {      
        return HttpApplication.callMethod(ref this.dbConnUser,ref this.dbConnApp,ref log,ref rd, ref uInfo, rt, cb,true,permittedRoles);
    }    
	
    /***************************************************************************
     * findControlIter */
    /**
     * Replacement for FindControl that searchs through all child controls
     * This is an iterative implementation
     * Courtesey of Popa D. Steilian
     * http://forums.asp.net/p/1107107/1696269.aspx
     * 
     * @param  root            Root control
     * @param  id              ID of control you are looking for
     * @return                 Control
     ***************************************************************************/    
 
    public static Control findControlIter (Control root, string id)
    {
      Control ctl = root;
      LinkedList<Control> ctls = new LinkedList<Control>();

      while (ctl != null)
      {
        if (ctl.ID == id)
          return ctl;
        foreach (Control child in ctl.Controls)
        {
          if (child.ID == id)
            return child;
          if (child.HasControls())
            ctls.AddLast(child);
        }
        ctl = ctls.First.Value;
        ctls.Remove(ctl);
      }
      return null;
    }
  
   /***************************************************************************
    * findControlRecu */
   /**
    * Replacement for FindControl that searchs through all child controls
    * This is a recursive implementation
    * Courtesey of Rick Strahl
    * http://www.west-wind.com/WebLog/posts/5127.aspx
    * 
    * @param  root            Root control
    * @param  id              ID of control you are looking for
    * @return                 Control
    ***************************************************************************/   

   public static Control findControlRecu(Control root, string id)
   {
     if (root.ID == id) return root;
     foreach (Control Ctl in root.Controls)
     {
       Control FoundCtl = findControlRecu(Ctl, id);
       if (FoundCtl != null) return FoundCtl;
     }
     return null;
   }
   
   /***************************************************************************
    * gotoNewUrl */
   /**
    * Used to redirect to newUrl
    * 
    * @param  newUrl    Url to redirect to
    * 
    ***************************************************************************/   
   
   public void gotoNewURL(string newUrl)
   {  
     Response.Redirect(newUrl, false);
     Context.ApplicationInstance.CompleteRequest();
   } 

  }
}
