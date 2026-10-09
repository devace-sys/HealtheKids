using System;
using System.Web.UI;

namespace MBA
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
   * @param  bodyid            The id you wish to give to the body tag.
   * @param  subtitle          The subtitle you wish to give to the page.  The page
   *                           title will be Application Name - Subtitle
   * @param  rmenuPublic       Delegate to render public menu
   * @param  rmenuPrivate      Delegate to render private menu
   * @param  rfooterPublic     Delegate to render public footer
   * @param  rfooterPrivate    Delegate to render private footer
   * @param  css               Additional external css files
   * @param  js                Additional external js files
   * @param  permittedRoles    User roles that are allowed to access the page
   *
   ****************************************************************************/

  public abstract class WebUI3: WebApp
	{

    public WebUI3(
        string bodyid
      , string subtitle
      , handleAppSpecificResponse rAppBarIconsPublic
      , handleAppSpecificResponse rAppBarIconsPrivate
      , renderHeaderPublic rheaderPublic
      , renderHeaderPrivate rheaderPrivate
      , renderMenuPublic rmenuPublic
      , renderMenuPrivate rmenuPrivate
      , renderFooterPublic rfootPublic
      , renderFooterPrivate rfootPrivate
      , handleAppSpecificResponse rAppUserToDoMsgs
      , handleAppendingUserSpecificNotifications aUserSpecificNotifications
      , params string[] permittedroles):this(
          bodyid
        , subtitle
        , rAppBarIconsPublic
        , rAppBarIconsPrivate
        , rheaderPublic
        , rheaderPrivate
        , rmenuPublic
        , rmenuPrivate
        , rfootPublic
        , rfootPrivate
       , rAppUserToDoMsgs
       , aUserSpecificNotifications
       , null
       , null
       , permittedroles)
    {
    }
    public WebUI3(
      string bodyid
      , string subtitle
      , handleAppSpecificResponse rAppBarIconsPublic
      , handleAppSpecificResponse rAppBarIconsPrivate
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
      , params string[] permittedroles):base(
            bodyid
          , subtitle
          , rAppBarIconsPublic
          , rAppBarIconsPrivate
          , rheaderPublic
          , rheaderPrivate
          , rmenuPublic
          , rmenuPrivate
          , rfootPublic
          , rfootPrivate
          , rAppUserToDoMsgs
          , aUserSpecificNotifications
          , css
          , js
          , permittedroles)
    {
    }

    protected string dialogMessageID        = @"";
    protected string dialogMessageTitleID   = @"";
    protected string dialogMessageContentID = @"";

          // writer.Write(@"<a href=""{0}"" title=""Contact Us"" class=""material-icons mdc-top-app-bar__action-item"" aria-label=""Contact Us"">email</a>", Messages.CONTACT_US_LINK);

    /***************************************************************************
     * RenderDialogContainer */
    /**
     *
     ****************************************************************************/

    public static void RenderDialogContainer (  ref HtmlTextWriter  writer
                                              , ref RequestResponse rd
                                              , string              dialogID
                                              , string              titleID
                                              , string              contentID
                                              , string              title
                                              , string              content     = @""
                                              , string              buttons     = @""
                                              , bool                dismissible = false)
    {

      writer.Write(@"<div id=""{0}"" class=""modal fade"" tabindex=""-1"" role=""dialog"" aria-labelledby=""{1}"" aria-hidden=""true"">", dialogID, titleID);
      writer.Write(@"<div class=""modal-dialog modal-dialog-centered"" role=""document"">");
      writer.Write(@"<div class=""modal-content"">");

      writer.Write(@"<div class=""modal-header"">");
      writer.Write(@"<h5 id=""{0}"" class=""modal-title"">{1}</h5>",titleID,title);
      if (dismissible) {
        writer.Write(@"<button type=""button"" class=""close"" data-dismiss=""modal"" aria-label=""Close"">");
        writer.Write(@"<span aria-hidden=""true"">&times;</span>");
        writer.Write(@"</button>");
      }
      writer.Write(@"</div>"); // modal-header

      writer.Write(@"<div id=""{0}"" class=""modal-body"">", contentID);
      writer.Write(content);
      writer.Write(@"</div>"); // modal-body
      writer.Write(@"<div class=""modal-footer"">");
      writer.Write(buttons);
      writer.Write(@"</div>"); // modal-footer
      writer.Write(@"</div>"); // modal-content
      writer.Write(@"</div>"); //
      writer.Write(@"</div>"); //
    }

    private void RenderReqPageUtilities(ref HtmlTextWriter writer)
    {
    /*#############################################################################
      #                         Bottom of Document
      #############################################################################*/


	  /*=========================================================
      =  JS Includes
      =========================================================*/

    /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      +  Standard
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

    /*----------------
      - Third Party
      ----------------*/

    RenderJSInclude (ref writer,  @"web-ui-3/popper/js/popper.min.js",              false);
    RenderJSInclude (ref writer,  @"web-ui-3/bootstrap/js/bootstrap.min.js",        false);
    RenderJSInclude (ref writer,  @"web-ui-3/DataTables/datatables.min.js",         false);    
    RenderJSInclude (ref writer,  @"web-ui-3/md/js/material-components-web.min.js", false);
    RenderJSInclude (ref writer,  @"web-ui-3/md/js/setup.js",                       true);

    /*----------------
      - Our Custom
      - Dynamic
      ----------------*/

    writer.Write(@"<script type=""text/javascript"">");
    writer.Write(@";(function($){");

    /*
     |
     | Setup namespace
     |
    */

    writer.Write(@"$.spedmonWebUI3 = {};");

    /*
     |
     | Add security token (if logged in) otherwise blank
     |
    */

    if (rd.loggedIn)
    {
      writer.Write(@"$.spedmonWebUI3.token = '{0}'",rd.wu.usr.token);
    }
    else
    {
      writer.Write(@"$.spedmonWebUI3.token = '';");
    }

    /*
     |
     | Public Home Page
     |
    */

    writer.Write(@"$.spedmonWebUI3.home_public = '" + MBA.HttpApplication.createLink(MBA.Constants.HOME_PUBLIC,false) + @"';");
    writer.Write(@"$.spedmonWebUI3.dialogMessageID        = '" + dialogMessageID + @"';");
    writer.Write(@"$.spedmonWebUI3.dialogMessageTitleID   = '" + dialogMessageTitleID + @"';");
    writer.Write(@"$.spedmonWebUI3.dialogMessageContentID = '" + dialogMessageContentID + @"';");
    
    // Messages passed

    writer.Write(@"$.spedmonWebUI3.clientMessageCode = {0};",rd.clientMessageCode);
    writer.Write(@"$.spedmonWebUI3.clientMessageText = '{0}';",rd.clientMessageText);

    writer.Write(@"})(jQuery);");
    writer.Write(@"</script>");

    /*----------------
     - Our Custom
     - Static
     ----------------*/

    RenderJSMinifierInclude (ref writer,  @"web-ui-3/mba/js/menu.js");
    RenderJSMinifierInclude (ref writer,  @"web-ui-3/mba/js/jquery.mba.web-ui-global.js");
    RenderJSMinifierInclude (ref writer,  @"web-ui-3/mba/js/jquery-mba-web-ui-detail-lists.js");
    RenderJSMinifierInclude (ref writer,  @"web-ui-3/mba/js/jquery-mba-web-ui-dialogs.js");
    RenderJSMinifierInclude (ref writer,  @"web-ui-3/mba/js/jquery.mba.web-ui-common.js");
    RenderJSMinifierInclude (ref writer,  @"web-ui-3/mba/js/jquery.mba.web-ui-controls-forms.js");    
    //RenderJSInclude (ref writer,  @"web-ui-3/mba/js/jquery-mba-web-ui-return-info-table.js", true);

    RenderJSMinifierInclude (ref writer,  @"web-ui-3/mba/js/req-rsp-client-message-window-handling.js");


    }
    

   /***************************************************************************
    * Render */
   /**
    * Overrides base class render.  Renders page using contents of writer.
    ****************************************************************************/
    protected override void Render(HtmlTextWriter writer)
    {      
      InitLinksAndLabels();

      /*#############################################################################
        #                              Top of document
        #############################################################################*/

      RenderDocumentStartHeadStartCommonMetaPageTitle (ref writer, ref rd, subTitle);

      /*=========================================================
        =  CSS
        =========================================================*/

	    /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        +  Standard
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

      /*----------------
        - Third Party
        ----------------*/

      RenderCSSInclude (ref writer, @"web-ui-3/bootstrap/css/bootstrap.min.css",        false);
      RenderCSSInclude (ref writer, @"web-ui-3/md/fonts/material-icons.css",            false);
      RenderCSSInclude (ref writer, @"web-ui-3/md/css/material-components-web.min.css", false);
      RenderCSSInclude (ref writer, @"web-ui-3/DataTables/datatables.min.css",          false);

      /*----------------
       - Our Custom
       ----------------*/

      RenderCSSMinifierInclude (ref writer, @"web-ui-3/mba/css/screen.css");
	  RenderCSSMinifierInclude (ref writer, @"web-ui-3/mba/css/menu.css");
      RenderCSSMinifierInclude (ref writer, @"web-ui-3/mba/css/controls.css");
      RenderCSSMinifierInclude (ref writer, @"web-ui-3/mba/css/theme.css");

	    /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        +  Page Specific (if any)
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

      writer.Write(GeneratePageSpecificCSSIncludes(@"web-ui-3/custom/css/",customCSS));


      /*=========================================================
        =  JS Includes
        =
        = Note: Only include libraries required for inline
         = scripting in body here.  Include all other libraries
        = at the JS Includes section provided at the end.
        =========================================================*/

      RenderJSInclude (ref writer,  @"web-ui-3/jquery/js/jquery-3.4.0.min.js", false);

      RenderHeadEndBodyStart(ref writer, ref rd);

      if (this.renderOptionContentOnly || rd.contentOnly != "0")
      {
          base.Render(writer);
          RenderReqPageUtilities(ref writer);
          RenderBodyEndDocumentEnd(ref writer, ref rd);
          return;
      }

      /*=========================================================
        = Prerendered dialog containers
        =========================================================*/

      /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        + Message dialog
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

      dialogMessageID        = @"dialogMessage";
      dialogMessageTitleID   = dialogMessageID + @"Title";
      dialogMessageContentID = dialogMessageID + @"Content";

      RenderDialogContainer (  ref writer
                             , ref rd
                             , dialogMessageID
                             , dialogMessageTitleID
                             , dialogMessageContentID
                             , @"Message For You"
                             , @""
                             , @"<button type=""button"" class=""btn btn-primary"" data-dismiss=""modal"">OK</button>"
                             , true);

      /*=========================================================
        = App Drawer
        =========================================================*/

      writer.Write(@"<aside id=""app-drawer"" class=""mdc-drawer mdc-drawer--dismissible"">");
      writer.Write(@"<div class=""mdc-drawer__content"">");

      /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        +  Nav
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

      RenderMenuStart(@"", ref writer);

      /*----------------
        - Public Menu
        ----------------*/

      renderMenuListItem (ref writer, "homelink", @"Home", homeLink, false,false,true);

      if (!rd.loggedIn)
      {
        renderMenuPublic(ref writer);
      }

      /*----------------
        - Private Menu
        ----------------*/

      else
      {
        renderMenuPrivate  (ref dbConnUser, ref dbConnApp, ref log,  ref rd, ref uInfo, ref writer);
      }


      RenderMenuEnd(ref writer);

      writer.Write(@"</div>");
      writer.Write(@"</aside>");

      /*=========================================================
        = App Content
        =========================================================*/

      writer.Write(@"<div id=""app-content"" class=""mdc-drawer-app-content"">");

      writer.Write(@"<header id=""page-header"">");

      /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        + App Bar
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

      //writer.Write(@"<div id=""app-bar"" class=""mdc-top-app-bar"">");
      writer.Write(@"<div id=""app-bar"" class=""mdc-top-app-bar mdc-top-app-bar--fixed"">");

      writer.Write(@"<div class=""mdc-top-app-bar__row"">");

      /*--------------------
        - App bar
        - start section
        --------------------*/

      writer.Write(@"<section class=""mdc-top-app-bar__section mdc-top-app-bar__section--align-start"">");

      /*
       |
       | Full size page icons
       |
       */

      if (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE)
      {
        /* Menu Icon */


        writer.Write(@"<a title=""Click to show/hide menu"" id=""app-bar-nav-toggle"" href=""#"" class=""material-icons mdc-top-app-bar__navigation-icon"">menu</a>");

        /* Home Icon */

        renderAppBarIcon(ref writer,@"Home",@"home",homeLink);

        /* App Logo */

        RenderAppLogo(ref writer,ref rd);
      }
      else
      {
        /* App Logo - Disabled Click to Home */

        RenderAppLogo(ref writer,ref rd, @"",true);
      }

      writer.Write(@"</section>");

      /*--------------------
        - App bar
        - Middle section
        --------------------*/

      writer.Write(@"<section class=""mdc-top-app-bar__section"">");
      writer.Write(@"<span id=""page-title"" title=""{0}"" class=""mdc-top-app-bar__title"">{0}</span>",this.subTitle);
      writer.Write(@"</section>");


      /*--------------------
        - App bar
        - End section
        --------------------*/

      writer.Write(@"<section class=""mdc-top-app-bar__section mdc-top-app-bar__section--align-end"" role=""toolbar"">");

      /*----------------
        - If this is not
        - a sub page
        ----------------*/

      if (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE)
      {

        if (!rd.loggedIn)
        {

          renderAppBarIconsPublic (   this.Request
                                    , this.Response
                                    , ref this.rd
                                    , ref this.uInfo
                                    , ref writer);

          /* Contact Us */

          renderAppBarIcon(ref writer,@"Contact Us",@"message",Messages.CONTACT_US_LINK);


          /* About Us */

          renderAppBarIcon(ref writer,@"About Us",@"info",Messages.ABOUT_US_LINK);

          /* TODO: Add delegate for app specific rendering */
        }

        else
        {

          renderAppBarIconsPrivate (     this.Request
                                       , this.Response
                                       , ref this.rd
                                       , ref this.uInfo
                                       , ref writer);

          /* Help */

          renderAppBarIcon(ref writer,@"Help",@"help",manPagesLink,null,true);  
          
          /* Files */          

          if (userHasAccessToFilesUploadDownload)
          { 
            renderAppBarIcon(ref writer,@"Files",@"folder","#","files-icon");              
            renderFilesAppBarIconDropMenu(ref writer,this.uploadLink, this.downloadLink, userHasAccessToFilesUpload, userHasAccessToFilesDownload);
          }

          /* My Account */
          
          renderAppBarIcon(ref writer,@"My Account",@"account_circle","#","my-account-icon");  
          renderMyAccountAppBarIconDropMenu(ref writer,userName,userTitle,userOrganization, changeMyPasswordLink,logoutLink,applicationName, appVersion);

        }
      }
      else
      {
        /* Render close icon*/
        writer.Write(@"<a href=""javascript:window.open('','_self').close();"" title=""Close"" class=""material-icons mdc-top-app-bar__action-item"" aria-label=""Close"">cancel</a>");
      }

      writer.Write(@"</section>");

      writer.Write(@"</div>");
	    writer.Write(@"</div>");

      writer.Write(@"</header>");

     /*#############################################################################
       #                          Middle of Document
       #############################################################################*/

	   writer.Write(@"<main id=""page-content"" class=""main-content mdc-top-app-bar--fixed-adjust"" role=""main"">");

     /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       + Notifications
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

     WebUI3Controls.Notifications notifications = new WebUI3Controls.Notifications(@"page-notifications");

      /*
       |
       | App wide notice
       |
       */


     if (!String.IsNullOrEmpty(Constants.APP_NOTICE))
	   {
         var anes = WebUI3Common.ElementSemantic.danger;

         if (!rd.loggedIn) 
         {        
           anes = WebUI3Common.GetElementSemanticByName(Constants.APP_NOTICE_STYLE_PUBLIC);
         }
         else
         {
           anes =  WebUI3Common.ElementSemantic.dark;
         }
      
         notifications.AppendNotification(anes, Constants.APP_NOTICE);
       }
       /*
       |
       | Browser not supported
       |
       */

     if ((!rd.browserSupported) && (!rd.isBot))
     {
       notifications.AppendNotification(WebUI3Common.ElementSemantic.danger, GenerateSupportedBrowserInfoHtml(ref rd));
     }

     /*
      |
      | Page message
      |
      */

     string status = rd.clientMessage;

     if (!String.IsNullOrEmpty(status))
     {
       notifications.AppendNotification(rd.clientMessageCode, rd.clientMessageText);
     }

     /*
      |
      | User specific notifications
      |
      */

     if ((rd.loggedIn) && (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE))
     {

       /* Password expiration */

       if ((Rules.PASSWORDS_EXPIRE) && (rd.wu.usr.passwordExpiresIn <= Rules.PASSWORD_CHANGE_WARN))
       {

          string msg       = String.Format(@"Your password will be expiring in {0} days", rd.wu.usr.passwordExpiresIn);
          string actionMsg = @"Click here to change your password";
          string actionURL = MBA.HttpApplication.createLink (   MBA.Constants.CHANGE_MY_PASSWORD, true);
          notifications.AppendNotification(WebUI3Common.ElementSemantic.warning, msg, actionMsg, actionURL);
       }


       if (rd.doNotShowUserToDoNotices == false)
       {

         /* Other (Application specific) */

         appendUserSpecificNotifications(ref rd,ref uInfo, ref notifications);


       }
     }

     notifications.RenderControl(writer);


     /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       + Page Title
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

     // writer.Write (@"<h1 id=""page-title"">{0}</h1>",subTitle);

     /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       + Page Specific Content
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

     base.Render(writer);

     writer.Write(@"</main>");

	  /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      + Footer
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

	  //writer.Write(@"<footer id=""page-footer"">");


     /*----------------
       - Public footer
       - content
       ----------------*/
/*
    if (!rd.loggedIn)
    {
      renderFooterPublic(ref writer);
    } */

     /*----------------
       - Private footer
       - content
       ----------------*/
    /*
    else
    {
      renderFooterPrivate(ref writer,this.rd.wu.usr.roleName.ToLower());
    } */

    /*----------------
      - Footer content
      - public and
      - private
      ----------------*/

    /* Version */
    /*
    writer.Write(@"<div class=""mba-footer-row"">");
    RenderAppVersionInfo(ref writer, ref rd);
    writer.Write(@"</div>"); */

    /* Supported Browser */
    /*
    writer.Write(@"<div class=""mba-footer-row"">");
    RenderSupportedBrowserInfo(ref writer, ref rd);
    writer.Write(@"</div>");

    writer.Write(@"</footer>"); */

 	  writer.Write(@"</div>");

    /*+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      + Page Specific
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/

      /* TODO: Include */

    RenderReqPageUtilities(ref writer);

    RenderBodyEndDocumentEnd(ref writer, ref rd);

    }
	}
}
