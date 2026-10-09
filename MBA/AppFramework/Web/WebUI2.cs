using System;
using System.Web.UI;

namespace MBA
{

    /***************************************************************************
     * WebUI2 */
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

    public abstract class WebUI2: WebApp
	{

    /*-------------------------------
     * Constructors
     *------------------------------*/ 

    public WebUI2 (
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
    public WebUI2(
        string              bodyid
      , string              subtitle
      , handleAppSpecificResponse rAppBarIconsPublic
      , handleAppSpecificResponse rAppBarIconsPrivate  
      , renderHeaderPublic  rheaderPublic
      , renderHeaderPrivate rheaderPrivate
      , renderMenuPublic    rmenuPublic
      , renderMenuPrivate   rmenuPrivate
      , renderFooterPublic  rfootPublic
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

    protected bool _useSessionHelper              = true;
    protected bool _useSessionHelperPrivacyScreen = true;
    protected bool _useWorkInProgressSavePoints   = false;
    protected bool _animateCloseIcon              = false;
    protected bool _useCssReset                   = true;
    protected bool _includeBackgroundLayer        = false;

    public bool useSessionHelper              { get { return _useSessionHelper;}
                                                set { _useSessionHelper = value; }}
    public bool useSessionHelperPrivacyScreen { get { return _useSessionHelperPrivacyScreen ;} 
                                                set { _useSessionHelperPrivacyScreen = value; }}
    public bool useWorkInProgressSavePoints   { get { return _useWorkInProgressSavePoints ;}   
                                                set { _useWorkInProgressSavePoints = value; }}
    public bool useCssReset                   { get { return _useCssReset;}                    
                                                set { _useCssReset = value; }}

    /* Determine if close icon should be animated to draw attention to it*/
    public bool animateCloseIcon              { get { return _animateCloseIcon; }
                                                set { _animateCloseIcon = value; }} 
    
    public bool includeBackgroundLayer        { get { return _includeBackgroundLayer; } 
                                                set { _includeBackgroundLayer = value;} }   
    /*
     * RenderReqPageUtilities
     */
    private void RenderReqPageUtilities(ref HtmlTextWriter writer)
    {
     /*======================================================================================================
      |
      |                                          App Dialogs
      |
      *=====================================================================================================*/
      
      
      // Message dialog

      Dialog dMsg = new Dialog("dialogMessage","Message For You");
      dMsg.RenderControl(writer);
      
      // Confirm dialog
      
      Dialog dCfm = new Dialog("dialogConfirm","Are You Sure");
      dCfm.RenderControl(writer);
      
      // Wait dialog
      
      Dialog dWait = new Dialog("dialogWait","Please Wait");     
      dWait.RenderControl(writer);
      
      // Confirm with reason dialog
      // TODO: Clean up into a control

      writer.Write(@"<div id=""dialogConfirmReason"" title=""Are You Sure?"" class=""ui-spedmon-dialog"">");       
      writer.Write(@"<br/><br/>");      
      writer.Write(@"<p id=""dialogConfirmReasonMessage"" style=""font-weight:bold;font-size:1.3em;text-align:center;padding-top:20px;"">");
      writer.Write(@"Are you sure?");
      writer.Write(@"</p>");
      writer.Write(@"<br/><br/>");
      writer.Write(@"<div style=""text-align:center;"">");
      MBA.Input rson = new MBA.Input("dialogConfirmReasonText","");
      rson.ID          = "dialogConfirmReasonText";
      rson.title       = "Type your reason here";
      rson.inlineLabel = "Enter a reason (optional)";
      rson.RenderControl(writer);
      writer.Write(@"</div>");      
      writer.Write(@"</div>");

     /*======================================================================================================
      |
      |                                          App Init
      |
      *=====================================================================================================*/

      // Page init script

      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"$(function() {");
      writer.Write(initJS);                 
      writer.Write(@"});");
      writer.Write(@"</script>");

      // MD components init

      RenderJSInclude (ref writer,  @"web-ui-3/md/js/setup.js", true);

      // Handle frame message propagation

      RenderJSInclude (ref writer,  @"js/req-rsp-client-message-window-handling.js", true);

    }
     

    /***************************************************************************
     * RenderMenu */
    /**
     * 
     ****************************************************************************/

    protected void RenderMenu (string navContainerClass, ref HtmlTextWriter writer)
    {
        RenderMenuStart(navContainerClass, ref writer); 
       
        /*-------------------------------
         * Public menu
         *------------------------------*/

        if (!rd.loggedIn)
        {
          writer.Write(@"<li class=""menu-item-common""><a id=""homePageLink"" href=""" + homeLink + @""">Home</a></li>");
          renderMenuPublic(ref writer);
        }
      
        /*-------------------------------
         * Private menu
         *------------------------------*/

        else
        {

          /*-------------------------------
           * Common private menu items
           *------------------------------*/

          
          /*------------------------ 
           * Home -- Render hidden
           * to preserve compatiblility
           * Option has moved to app
           * bar
           *------------------------*/
                     
          writer.Write(@"<li class=""menu-item menu-item-hidden""><a id=""homePageLink"" href=""" + homeLink + @""">Home</a></li>");

          /*-------------------------------
           * If no password change required
           * show following items
           *------------------------------*/

          if (rd.wu.usr.passwordMustBeChanged == false)
          { 
                             
            /*-------------------------------
             * Role based private menu items
             *------------------------------*/
         
           renderMenuPrivate(    ref this.dbConnUser
                                , ref this.dbConnApp
                                , ref this.log
                                , ref this.rd
                                , ref this.uInfo
                                , ref writer); 
                
          
            /*-------------------------------
             * More common private menu items
             *------------------------------*/
            
            /*------------------------ 
             * Files -- Render hidden
             * to preserve compatiblility
             * Option has moved to app
             * bar
             *------------------------*/

            if (userHasAccessToFilesUploadDownload)
            {                         
              renderTopMenuListStart(ref writer, @"Files",true);    
              if (userHasAccessToFilesUpload)   writer.Write(@"<li class=""menu-item menu-item-hidden""><a id=""uploadlink"" href=""" + uploadLink + @""" target=""_blank"">Send Us A File</a></li>");
              if (userHasAccessToFilesDownload) writer.Write(@"<li class=""menu-item menu-item-hidden""><a id=""downloadlink"" href=""" + downloadLink + @""">View Files Sent To Us</a></li>");
              renderTopMenuListEnd(ref writer);
            } 
                               
            /*------------------------ 
             * My Account -- Render hidden
             * to preserve compatiblility
             * Option has moved to app
             * bar
             *------------------------*/
           
            renderTopMenuListStart(ref writer, @"My Account",true);    
			      writer.Write(@"<li class=""menu-item menu-item-hidden""><a id=""changemypasslink"" href=""" + changeMyPasswordLink + @""">Change My Password</a></li>");
            renderTopMenuListEnd(ref writer);

            /*------------------------ 
             * Help -- Render hidden
             * to preserve compatiblility
             * Option has moved to app
             * bar
             *------------------------*/
                              
            writer.Write(@"<li class=""menu-item menu-item-hidden""><a id=""manpageslink"" href=""" + manPagesLink + @""">Help</a></li>");
          
          }

          /*------------------------ 
           * Logout -- Render hidden
           * to preserve compatiblility
           * Option has moved to app
           * bar
           *------------------------*/
          
          writer.Write(@"<li class=""menu-item menu-item-hidden""><a id=""logoutlink"" href=""" + logoutLink + @""">Logout</a></li>");

        }      

        RenderMenuEnd(ref writer);

    }
    
           
    /***************************************************************************
     * Render */
    /**
     * Overrides base class render.  Renders page using contents of writer.
     ****************************************************************************/    
    
    protected override void Render(HtmlTextWriter writer)
    {
      
      _evaluateContentFlags(false);

     /*======================================================================================================
       |
       |                                        Init
       |
       =======================================================================================================*/
      
      InitLinksAndLabels();
                                       
      /*======================================================================================================
       |                                     Document - Start
       |                                     Head - Start
       |                                     Common - META
       |                                     Page - Title
       =======================================================================================================*/
            
      RenderDocumentStartHeadStartCommonMetaPageTitle (ref writer, ref rd, @"pagehead", subTitle);    
      
            
      /*===============================
       * CSS
       *===============================*/ 

      // Common CSS for screen and print
      
      if (_useCssReset == true) { 
        writer.Write(YuiCompressor.Generators.cssLink( "all", "", Constants.FILE_CSS_RESET));
      }
      
      writer.Write(YuiCompressor.Generators.cssLink( "all", ""
                                                     , "all"));
      
      RenderCSSInclude (ref writer, @"web-ui-3/md/fonts/material-icons.css",               false);
      RenderCSSInclude (ref writer, @"web-ui-3/md/css/material-components-web.min.css",    false);                
            
      RenderCSSInclude (ref writer, @"css/jquery-ui-1-8-24/vfc/jquery-ui.css",             false);
      RenderCSSInclude (ref writer, @"css/jquery-ui-1-8-24/vfc/jquery.ui.theme.css",       false);

      RenderCSSInclude (ref writer, @"css/jquery.datatables.css",                          false);
      RenderCSSInclude (ref writer, @"css/jquery.dataTables_themeroller.css",              false);
      RenderCSSInclude (ref writer, @"web-ui-3/bootstrap/css/bootstrap.min.css",           false);
                                                                                                                                                                                      
      RenderCSSInclude (ref writer, @"web-ui-3/openvidu/css/fa/all.min.css",               false);
      RenderCSSInclude (ref writer, @"web-ui-3/openvidu/css/animate.min.css",              false);  
      RenderCSSInclude (ref writer, @"css/tipso.min.css",                                  false);
      RenderCSSInclude (ref writer, @"css/slick.css",                                      false);
      RenderCSSInclude (ref writer, @"css/jquery.simple-calendar.css",                     false);
                                                                                              
      RenderCSSMinifierInclude (ref writer, @"web-ui-3/mba/css/screen.css");
      RenderCSSMinifierInclude (ref writer, @"web-ui-3/mba/css/menu.css");
      RenderCSSMinifierInclude (ref writer, @"web-ui-3/mba/css/app-notifications.css");
      RenderCSSMinifierInclude (ref writer, @"web-ui-3/mba/css/app-help.css");           
      
      if (_includeBackgroundLayer) { 
        RenderCSSMinifierInclude (ref writer, @"web-ui-3/mba/css/screen-background-layer.css");
      }

      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-component-common.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-data-entry-box.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-disclosure.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-input-radio.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-checkbox-selections-json.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-autocomplete-multiple.css");            
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-rest-view.css");                                                                                           
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-action-item.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-action-item-total-num-amt.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-action-item-gauge.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-reimbursement-history-widget.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-user-quick-links.css");      
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-announcements-widget.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-calendar-widget.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-messages-widget.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-data-entry-row-iframe-content.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-form-builder.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-live-session-notes.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-structured-data-files-import.css");
      RenderCSSMinifierInclude (ref writer, @"css/jquery-ui-mba-notelibrary.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-pcal-performance-widget.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-action-item-common.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-action-item-pie-chart.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-action-item-bar-chart.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-dept-head-widget.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-action-item-progress-bar-chart.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-pdf-common.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-action-item-cde-compliance-buckets.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-action-dial-gauge.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/mba-cmd-tbar.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/mba-action-cards.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-action-item-percentage-banner.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-tabs.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-multiselect.css");
      RenderCSSMinifierInclude (ref writer, @"css/components/jquery-mba-grid.css");                         
      RenderCSSMinifierInclude (ref writer, @"css/components/mba-calendar-widget.css");
                       
      writer.Write(YuiCompressor.Generators.cssLink( "screen", ""                                      
                                                    , "controls"
                                                    , "ui.daterangepicker"
                                                    , "jquery.datepick"
                                                    , "ui.datepick.mod"
                                                    , "seafoam.datepick"
                                                    , "jquery-ui-timepicker-addon"
                                                    , "media-file/media-file"                                                       
                                                    , "jquery-ui-mba-data-entry"
                                                    , "jquery-ui-mba-notelibrary"
                                                    , "jquery-ui-mba-entity-record-manage"
                                                    , "jquery-ui-mba-entitygroup"
                                                    , "jquery-ui-mba-entitygroups"
                                                    , "jquery-ui-mba-content-selection"
                                                    ));
      
      writer.Write(YuiCompressor.Generators.cssLink("print",  "", "print"));
            
      
      /* Include custom css files passed in from constructor */
      
      //writer.Write(GeneratePageSpecificCSSIncludes(customCSS));
      RenderPageSpecificCSSMinifierIncludes(ref writer, customCSS);

      /*===============================
       * JS
       *===============================*/ 
     
      /*
       * TODO: jQuery Upgrade 
       * Goal to migrate jQuery and jQuery UI to the newest/latest versions available
       * To faciliate this we are using the jQuery 1.4 migrate plugin to migrate from jQuery 1.8 -> 2.2.4
       * then we will need to use the jQuery 3.3 migrate plugin to migrate from 2.2.4 -> 3.x
       * Jquery UI will require migrating and converting our custom CSS to the latest and testing the 
       * various plugins (like the daterange plugin and datepicker) 
       * to make sure they work.
       */
      
      RenderJSInclude (ref writer, @"third-party/sheetjs/xlsx.full.min.js",    false);
      RenderJSInclude (ref writer, @"third-party/plotly-2.8.3.min.js",         false);
      RenderJSInclude (ref writer, @"js/jquery-2.2.4.min.js",                  false);
      RenderJSInclude (ref writer, @"js/jquery-migrate-1.4.1.min.js",          false);
      RenderJSInclude (ref writer, @"js/jquery-ui-1.8.23.custom.min.js",       false);
      
      writer.Write(YuiCompressor.Generators.jsLink(""
                                                   ,"jquery.ui.touch-punch.min"                                                   
                                                   ,"date2"
                                                   ,"calctimemins"
                                                   ,"jquery.ui.autocomplete.selectFirst"
                                                   ,"jquery.form"
                                                   ,"daterangepicker.jquery"
                                                   ,"jquery.timers-1.2"
                                                   ,"jquery.defaultvalue"
                                                   ,"jquery.dataTables.min"
                                                   ,"jquery.mousewheel"
                                                   ,"jquery.mousehold"
                                                   ,"jquery.scrollTo-min"
                                                   ,"jquery.datepick.min"
                                                   ,"jquery.datepick.ext.mod"
                                                   ,"jquery.jeditable.mini"
                                                   ,"jquery.filedownload"
                                                   ,"jquery-ui-timepicker-addon"
                                                   ,"jquery.autosize.min"
                                                   ,"jquery.jplayer.min"
                                                   ,"bigscreen.min"
                                                   )); 

      RenderJSInclude (ref writer,  @"third-party/tipso.min.js", false);
      RenderJSInclude (ref writer,  @"third-party/signature-pad.min.js", false);
      RenderJSInclude (ref writer,  @"third-party/formbuilder/form-builder.min.js", false);
      RenderJSInclude (ref writer,  @"third-party/formbuilder/form-render.min.js", false);
      RenderJSMinifierInclude (ref writer,  @"third-party/formbuilder/form-builder-load-dialog.js");
      RenderJSInclude (ref writer,  @"third-party/jquery.simple-calendar.min.js", false);
            
      RenderJSInclude (ref writer,  @"third-party/pdf-generation/purify.min.js",      false);
      RenderJSInclude (ref writer,  @"third-party/pdf-generation/html2canvas.min.js", false);
      RenderJSInclude (ref writer,  @"third-party/pdf-generation/jspdf.min.js",       false);
      RenderJSInclude (ref writer,  @"third-party/pdf-generation/fontkit.umd.min.js", false);
      RenderJSInclude (ref writer,  @"third-party/pdf-generation/pdf-lib.min.js",     false);

      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-pdf-common.js");
      RenderJSMinifierInclude (ref writer,  @"js/mba-jspdf-common.js"); 
            
      RenderJSInclude (ref writer,  @"js/slick.min.js", false);
      
      RenderJSMinifierInclude (ref writer,  @"web-ui-3/mba/js/app-notifications.js");
      RenderJSMinifierInclude (ref writer,  @"web-ui-3/mba/js/menu.js");
      RenderJSInclude (ref writer,  @"web-ui-3/md/js/material-components-web.min.js", false);           
      
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-component-common.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-data-entry-box.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-disclosure.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-spedmon-signature-pad.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-spedmon-password-box.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-input-radio.js");      
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-checkbox-selections-json.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-autocomplete-multiple.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-rest-view.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-action-item-total-num-amt.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-action-item-common.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-action-item-gauge.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-action-item-pie-chart.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-action-item-bar-chart.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-action-item-progress-bar-chart.js");            
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-user-quick-links.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-announcements-widget.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-reimbursement-history-widget.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-calendar-widget.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-messages-widget.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-parent-portal-messages-widget.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-data-entry-row-iframe-content.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-live-session-notes.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-structured-data-files-import.js");
      RenderJSMinifierInclude (ref writer,  @"js/jquery-ui-mba-notelibrary.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-pcal-performance-widget.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-data-grid.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-dept-head-widget.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-action-item-cde-compliance-buckets.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-link.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-action-dial-gauge.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-action-item-cde-compliance-buckets-pcal-ratings.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-action-item-percentage-banner.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-tabs.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-multiselect.js");
      RenderJSMinifierInclude (ref writer,  @"js/components/jquery-mba-grid.js");

            /*===============================
             * Third Party CSS + JS combo
             *===============================*/

            writer.Write(@"<script type=""text/javascript"" src=""third-party/tinymce/tinymce.min.js""></script>");
      writer.Write(@"<script type=""text/javascript"" src=""third-party/tinymce/jquery.tinymce.min.js""></script>");
     
      /*===============================
       * Our static JS
       *===============================*/ 
      
      writer.Write(YuiCompressor.Generators.jsLink( ""
                                                   ,"common"
                                                   ,"jquery.MBA.common"
                                                   ,"jquery.MBA.webuicontrols"
                                                   ,"jquery-ui-mba-data-entry"
                                                   ,"jquery-ui-mba-entity-record-manage"
                                                   ,"jquery-ui-mba-entitygrouping-base"
                                                   ,"jquery-ui-mba-entitygroup"
                                                   ,"jquery-ui-mba-entitygroups"
                                                   ,"jquery-ui-mba-content-selection"
                                                   ,"jquery-ui-mba-content-selections"                                                   
                                                   )); 


      /*===============================
       * Our dynamic JS
       *===============================*/ 

      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"$(function(){");
      
      // Public home page link
      
      writer.Write(@"$.spedmonWebUI.token = '"       + MBA.HttpApplication.clientToken() + @"';");
      writer.Write(@"$.spedmonWebUI.home_public = '" + MBA.HttpApplication.createLink(MBA.Constants.HOME_PUBLIC,false) + @"';");
      
      // Contact info (HTML)

      writer.Write(@"$.spedmonWebUI.contact_info = '" + contactInfo + @"';");   
      writer.Write(@"$.spedmonWebUI.platform_info = '<p class=""platform-info-title"">Your platform</p><p class=""platform-info-data"">" + rd.userAgent + @"</p>';");
      
      // Messages passed

      writer.Write(@"$.spedmonWebUI.clientMessageCode = {0};",rd.clientMessageCode);
      writer.Write(@"$.spedmonWebUI.clientMessageText = '{0}';",rd.clientMessageText);

      writer.Write(@"});");
      writer.Write(@"</script>");

     /*===============================
      * PrivateStoredFiles
      * End Points and Parameter Names 
      * Renders if user is logged in
      *===============================*/ 
     
     RenderPrivateStoredFilesEndPointsAndParmNames (  ref writer
                                                    , ref rd
                                                    , this.userHasAccessToFilesUploadDownload                                                    
                                                    , MBA.StoredFiles.LIST_HANDLER_PRIVATE()
                                                    , MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()
                                                    , MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()
                                                    , MBA.StoredFiles.PARAM_FILE_ID
                                                    , MBA.Constants.PARM_CLIENT_ID
                                                    , MBA.Constants.PARM_PRACTITIONER_ID
                                                    , MBA.Constants.PARM_PATIENT_ID
                                                   );
      /*===============================
       * Work In Progress Save Points 
       * Renders if user is logged in
       *===============================*/ 

      RenderWorkInProgressSavePointsIncludes (  ref writer
                                              , ref rd
                                              , _useWorkInProgressSavePoints
                                              , WorkInProgressSavePoints.URL_WEB_SVC_SAVE_OR_REPLACE_BASE()
                                              , WorkInProgressSavePoints.URL_WEB_SVC_DELETE_BASE()
                                              , MBA.Credential.generateSessionExpiredLink()          
                                             );
      /*===============================
       * Session Helper 
       * Renders if user is logged in
       *===============================*/ 
      
      RenderSessionHelperIncludes (  ref writer
                                   , ref rd
                                   , _useSessionHelper
                                   , _useSessionHelperPrivacyScreen
                                   , MBA.Sessions.WEB_SVC_CDE_REQUEST_KEEP_ALIVE()
                                   , MBA.Credential.generateSessionExpiredLink()
                                   , MBA.Rules.MAX_IDLE_SESSION_SECS
                                   , MBA.Rules.USER_IS_CONSIDERED_IDLE_AFTER_N_SECONDS
                                   , _contentOnly);

      
      /*===============================
       * Page specific JS
       *===============================*/ 
                 
      RenderPageSpecificJSMinifierIncludes(ref writer, customJS);

      /*
      if (_contentOnly == false) { 

          /*===============================
           * tawk.to widget
           *=============================== 

          RenderJSMinifierInclude(ref writer, @"js/components/tawkwidget.js");

      }
      */

    

     /*======================================================================================================
      |                                          Head - End
      |                                          Body - Start
      *=====================================================================================================*/
    
      RenderHeadEndBodyStart (ref writer, ref rd, bodyID);
            
      if (_contentOnly == true) {
          // I want to be able to trigger this, either by the URL param, or via the .aspx.cs constructor
          base.Render(writer);
          RenderReqPageUtilities(ref writer);
          RenderBodyEndDocumentEnd(ref writer, ref rd);
          return;
      }
        
      
     /*======================================================================================================
      |
      |                                          App Drawer
      |
      *=====================================================================================================*/

      writer.Write(@"<aside id=""app-drawer"" class=""mdc-drawer mdc-drawer--dismissible"">");      
      writer.Write(@"<div class=""mdc-drawer__content"">");
     
      /*===============================
       * Menu
       *===============================*/ 

      RenderMenu ( @"", ref writer);

      writer.Write(@"</div>");
      writer.Write(@"</aside>");

     /*======================================================================================================
      |
      |                                          App Content
      |
      *=====================================================================================================*/
      
      writer.Write(@"<div id=""app-content"" class=""mdc-drawer-app-content"">");
   
     /*======================================================================================================
      |                                            Header
      *=====================================================================================================*/

      writer.Write(@"<header id=""page-header"">");
    
      /*===============================
       * App bar 
       *===============================*/ 
     
      writer.Write(@"<div id=""app-bar"" class=""mdc-top-app-bar mdc-top-app-bar--fixed"">");     
      
      
      /******** App bar row 1 ********/

      writer.Write(@"<div class=""mdc-top-app-bar__row"">");          
      
      /******** App bar row 1 - Left ********/
      
      writer.Write(@"<section class=""mdc-top-app-bar__section mdc-top-app-bar__section--align-start"">");
      
      /**** Full page *****/

      if (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE)
      {                 
        /* Menu */

        writer.Write(@"<a title=""Click to show/hide menu"" id=""app-bar-nav-toggle"" href=""#"" class=""material-icons mdc-top-app-bar__navigation-icon"">menu</a>");

        /* Home Icon */

        renderAppBarIcon(ref writer,@"Home",@"home",homeLink);  

        /* App Logo */

        RenderAppLogo(ref writer,ref rd);
      }

      /**** Sub page *****/

      else
      {
        /* App Logo - Disabled Click to Home */

        RenderAppLogo(ref writer,ref rd, @"",true);
      }
                 
      writer.Write(@"</section>");

     /******** App bar row 1 - Middle ********/

      writer.Write(@"<section class=""mdc-top-app-bar__section"">");                   
      
      /*===============================
       * Page Title
       *===============================*/ 

      writer.Write(@"<span id=""page-title"" title=""{0}"" class=""mdc-top-app-bar__title"">{0}</span>",this.subTitle);
      writer.Write(@"</section>");

      /******** App bar row 1 - Right ********/

      writer.Write(@"<section class=""mdc-top-app-bar__section mdc-top-app-bar__section--align-end"" role=""toolbar"">");
                   
      
      /**** Full page *****/

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
            renderFilesAppBarIconDropMenu(ref writer,this.uploadLink, this.downloadLink, userHasAccessToFilesUpload,userHasAccessToFilesDownload);
          }

          /* My Account */
          
          renderAppBarIcon(ref writer,@"My Account",@"account_circle","#","my-account-icon");  
          renderMyAccountAppBarIconDropMenu(ref writer,userName,userTitle,userOrganization, changeMyPasswordLink,logoutLink,applicationName, appVersion);
        }
      }
      
      /**** Sub page *****/

      else
      {
        /* Render close icon*/
        writer.Write(@"<a id=""ctrl-close-icon-this-page"" href=""javascript:window.open('','_self').close();"" title=""Close"" class=""material-icons mdc-top-app-bar__action-item"" aria-label=""Close"" {0}=""{1}"">cancel</a>"
                     , Constants.DATA_ATTR_ANIMATE_CONTROL
                     , Util.netBoolToJSBool(_animateCloseIcon));
      }

      writer.Write(@"</section>");
     
      writer.Write(@"</div>");  /* App bar row*/     
             
      writer.Write(@"</div>");  /* App bar */    

      writer.Write(@"</header>");

     /*======================================================================================================
      |                                            Main
      *=====================================================================================================*/
      
      writer.Write(@"<main id=""page-content"" class=""mdc-top-app-bar--fixed-adjust main-content"" role=""main"">");
                            
       /*===============================
        * App notifications
        *===============================*/ 
       
     writer.Write(@"<ul id=""page-notifications"" class=""app-notifications mdc-top-app-bar--fixed-adjust main-content"">");
      
     /* App Notice */

     if (!Util.IsNullOrEmpty(Constants.APP_NOTICE))
     {
        renderAppNotification(ref writer,Constants.APP_NOTICE,WebUI3Common.ElementSemantic.dark,true);
     } 
      
     /* Browser */

     if ((!rd.browserSupported) && (!rd.isBot))     
     {               
        renderAppNotification(ref writer, GenerateSupportedBrowserInfoHtml(ref rd), WebUI3Common.ElementSemantic.danger,true);
     };  

     /* Page message */
     
     string status = rd.clientMessage;

      if (!String.IsNullOrEmpty(status))
      {
        string statusmsg   = rd.clientMessageText;
        int statuscode     = rd.clientMessageCode;
        renderAppNotification(ref writer, statusmsg, WebUI3Common.ReturnStatusToElementSemantic(statuscode), true);
      }
      
     if ((rd.loggedIn) && (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE))
     { 
      
      /* Password expiration */

       if ((Rules.PASSWORDS_EXPIRE) && (rd.wu.usr.passwordExpiresIn <= Rules.PASSWORD_CHANGE_WARN))
       {
         
          string msg  = String.Format(@"Your password will be expiring in {0} days", rd.wu.usr.passwordExpiresIn)
                      + String.Format(@" <a href=""{0}"">{1}</a>"
                      , MBA.HttpApplication.createLink (   MBA.Constants.CHANGE_MY_PASSWORD, true)           
                      , @"Click here to change your password");
          
         renderAppNotification(ref writer, msg, WebUI3Common.ElementSemantic.warning, true);
       }

       if (rd.doNotShowUserToDoNotices == false)            
       {                 

        renderAppSpecificUserToDoMessages (  this.Request
                                           , this.Response
                                           , ref this.rd
                                           , ref this.uInfo
                                           , ref writer);
       
     
      }               
    }
     writer.Write(@"</ul>"); /* App notifications*/
                                               
      /*===============================
       * Page Content
       *===============================*/ 
       
       if (rd.privateResource == true)
       { 
         /* If its a private page (requiring user to be logged in) and the user is not logged in, skip rendering content */
         if (rd.loggedIn == true) base.Render(writer);       
       }
       else
       {
         /* If its a public page, render content */
         base.Render(writer);
       }
        
       writer.Write(@"</main>");

       
    /*======================================================================================================
      |                                           Footer
      *=====================================================================================================*/

      /* Terrence Emerson Rohl
       * January 11, 1947 — June 5, 2023
       * https://obits.eastlawn.com/terrence-rohl
       */

    if ((Constants.SHOW_TER_MESSAGE.Value == true) || (Util.isTodayAnAnniversary(6,5) == true)) {      
        writer.Write(@"<div class=""text-center mt-1""><small>&nbsp;</small><small id=""termsg"" class=""text-muted""><a class=""text-muted"" href=""https://obits.eastlawn.com/terrence-rohl"" target=""_blank"">Terry Rohl (1947-2023)</a></small></div>");
        writer.Write(@"<script>");      
        writer.Write(@"$(function() {");            
        writer.Write(@"let _fnRmTerMsg = function(){$('#termsg').fadeOut();};");
        writer.Write(@"setTimeout(_fnRmTerMsg, 5000);");           
        writer.Write(@"});");
        writer.Write(@"</script>");      
    }
     
      /*
	  writer.Write(@"<footer id=""page-footer"">");   */  
	      
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
    /* else
    {
      renderFooterPrivate(ref writer,this.rd.wu.usr.roleName.ToLower()); 
    }
	 */ 
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
              
    writer.Write(@"</div>"); // End app content

    RenderReqPageUtilities(ref writer);

      /*======================================================================================================
       |                                          Body - End
       |                                        Document - End
       *=====================================================================================================*/
    
      RenderBodyEndDocumentEnd(ref writer, ref rd);
    }		
	}
}
