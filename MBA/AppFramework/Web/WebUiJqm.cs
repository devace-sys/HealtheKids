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

namespace MBA
{

  /***************************************************************************
   * WebUIJqm */
  /**
   * Base class for web user interface (UI) pages.  This class generates a
   * standard framework of HTML markup, CSS includes, and Javascript includes
   * for every page that inherits from it.  The user must provide everything
   * between the body tags.
   *
   * @param  bodyid            The id you wish to give to the body tag.
   * @param  subtitle          The subtitle you wish to give to the page.  The page 
   *                           title will be Application Name - Subtitle
   * @param  permittedRoles    User roles that are allowed to access the page
   *
   ****************************************************************************/

  public abstract class WebUiJqm : WebApp
  {

    /*###########################################################################
      #
      # Constructors
      #
      ###########################################################################*/	
        
    public WebUiJqm (string subtitle, 
                     renderMenuPublic rmenuPublic, 
                     renderMenuPrivate rmenuPrivate, 
                     renderFooterPublic rfootPublic, 
                     renderFooterPrivate rfootPrivate, 
                     params string[] permittedroles)
      : base(subtitle, permittedroles)
    {
    
      this.subTitle = subtitle;
            
      /*-------------------------------
       * Menu delegates
       *------------------------------*/ 
    
       _renderMenuPrivate   = rmenuPrivate;
       _renderMenuPublic    = rmenuPublic;
       _renderFooterPublic  = rfootPublic;
       _renderFooterPrivate = rfootPrivate;
    }
        
    /*###########################################################################
      #
      # Properties
      #
      ###########################################################################*/
    
    protected  renderMenuPublic     _renderMenuPublic;
    protected  renderMenuPrivate    _renderMenuPrivate;
    protected  renderFooterPublic   _renderFooterPublic;
    protected  renderFooterPrivate  _renderFooterPrivate;
                   
    public string homeLink;
    public string helpLink;
    public string userName;
    public string userTitle;
    public string userClient;
    public string loginLink;
    public string logoutLink;
    

      
    /*###########################################################################
      #
      # Methods
      #
      ###########################################################################*/

       
     /***************************************************************************
      * Render */
     /**
      * Overrides base class render.  Renders page using contents of writer.
      ****************************************************************************/

     protected override void Render(HtmlTextWriter writer)
     {
     
     if (rd.loggedIn)
     {                
       // Generate link for private home page        
            
       homeLink   = HttpApplication.createLink(MBA.Constants.HOME_PRIVATE, true);
       helpLink   = HttpApplication.createLink(MBA.Constants.HELP_PRIVATE, true);
       logoutLink = HttpApplication.createLink(MBA.Constants.HOME_PRIVATE) + "?" + Constants.PARM_CMD + "=" + Constants.CMD_LOGOUT + "&" + Constants.PARM_TOKEN + "=" + HttpApplication.clientToken();
       userName   = rd.wu.usr.name;

        if (rd.wu.usr.userGroupID == Constants.USER_GROUP_CLIENT)
        {
          
          userClient   = rd.wu.usr.clientName; 
         
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
          userClient   = "Practi-Cal";
          userTitle    = rd.wu.usr.roleName;          
        }
        
        else if (rd.wu.usr.userGroupID == Constants.USER_GROUP_THIRD_PARTY_PERSON)
        {
          userClient   = "";
          userTitle    = rd.wu.usr.roleName;          
        }
        
        else
        {
          userClient   = "";
          userTitle    = rd.wu.usr.roleName;          
        }
       
     }  
     else
     {
       // Generate link for public home page
       homeLink = HttpApplication.createLink(MBA.Constants.HOME_PUBLIC);
     }
                    
     writer.WriteLine(@"<!doctype html>");
     writer.WriteLine(@"<!-- Copyright (c) " + Messages.COPYRIGHT_DATE_ORG + @" -->");
     writer.Write(@"<html lang=""en"">");            
     writer.Write(@"<head>");

          /*============================================================
           * Meta and title
           *============================================================*/

          writer.Write(@"<meta http-equiv=""content-type"" content=""text/html; charset=UTF-8"">");
          writer.Write(@"<meta name=""viewport"" content=""width=device-width, initial-scale=1, maximum-scale=1"">");

          /*--------------------------------------
           * Crawler indexing of public
           * pages only if webconfig 
           * crawl setting is true (default)
           *-------------------------------------*/                    

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
          
          writer.Write(@"<title>" + Constants.APP_TITLE + (String.IsNullOrEmpty(subTitle) ? "" : " - " + subTitle) + @"</title>");

          /*============================================================
           * CSS includes - Static 
           * Note: The YuiCompressor does not appear to be able to handle
           * these.
           *============================================================*/
          
          writer.Write(@"<link rel=""stylesheet"" href=""css/themes/south-street/south-street.min.css""/>");
          writer.Write(@"<link rel=""stylesheet"" href=""css/themes/south-street/jquery.mobile.icons.min.css""/>");
          writer.Write(@"<link rel=""stylesheet"" href=""css/themes/south-street/jquery.mobile.structure-1.4.5.min.css""/>");

          /*============================================================
           * CSS includes - Dynamic
           *============================================================*/
           
          writer.Write(YuiCompressor.Generators.cssLink("themes/screen"));
          writer.Write(YuiCompressor.Generators.cssLink("themes/jquery.mobile-1.4.5-eaw.widgets"));
                                                               
          /*============================================================
           * JS includes - Dynamic
           *============================================================*/

          writer.Write(YuiCompressor.Generators.jsLink(""
                                                       , "jquery-1.11.1.min"
                                                       , "jquery.mobile-1.4.5.min"
                                                       , "jquery.eaw.common"
                                                       , "jquery.mobile-1.4.5-eaw.common"
                                                       , "jquery.mobile-1.4.5-eaw.widgets"
                                                       , "jquery.mobile-1.4.5-mba.svc-notes"));

          /*============================================================
           * Page init tasks
           *============================================================*/

          writer.Write(@"<script type=""text/javascript"">");
          writer.Write(@"$( document ).on( ""pagebeforecreate"", function() {");
          writer.Write(@"$.spedmonWebUiJqm = {};");
          writer.Write(@"$.spedmonWebUiJqm.token = '" + MBA.HttpApplication.clientToken() + @"';");
          
          /* Keeps jqm from changing page title */
          
          writer.Write(@"$("":jqmData(role='page')"").attr(""data-title"", document.title);");
          writer.Write(@"});");
          writer.Write(@"</script>");

          writer.Write(@"</head>");
          writer.Write(@"<body>");
                   

          writer.Write(@"<div id=""page"" data-role=""page"" class=""ui-responsive-panel"">");

          /*============================================================
           * Header
           *============================================================*/
          
          writer.Write(@"<div data-role=""header"" data-position=""fixed"">");
          
          /*--------------------------------------
           * App logo
           *-------------------------------------*/                    

          writer.Write(@"<a class=""page-app-logo"" data-ajax=""false"" href=""" + homeLink + @"""><img class=""page-app-logo"" data-ajax=""false"" alt=""Practi-Cal"" src=""web-ui-3/mba/css/app-icons/branding.svg""/></a>");
          
          
          /*--------------------------------------
           * Page sub title
           *-------------------------------------*/                    

          writer.Write(@"<h1 class=""page-app-sub-title"">");
          writer.Write(subTitle);          
          writer.Write(@"</h1>");      
                   
          /*--------------------------------------
           * Private
           *-------------------------------------*/                    

          if (rd.loggedIn)
          {                        

           /*--------------------------------------
            * Common menu items
            *-------------------------------------*/                    

            writer.Write(@"<div data-role=""controlgroup"" data-type=""horizontal"" class=""ui-mini ui-btn-right"">");
            writer.Write(@"<a href=""" + homeLink + @""" class=""mba-ui-form-options-control ui-btn ui-btn-icon-left ui-icon-home"" data-ajax=""false"">Home</a>");
            writer.Write(@"<a href=""" + helpLink + @""" target=""_blank"" class=""mba-ui-form-options-control ui-btn ui-btn-icon-left ui-icon-info"" data-ajax=""false"">Help</a>");
            writer.Write(@"<a href=""" + logoutLink + @""" class=""mba-ui-form-options-control ui-btn ui-btn-icon-left ui-icon-action"" data-ajax=""false"">Logout</a>");             
            writer.Write(@"</div>");

            /*--------------------------------------
             * User data
             *-------------------------------------*/                    
                             
            writer.Write(@"<div class=""page-app-user-data"">");
            writer.Write(@"You are logged in as " + userName + @" " + (Util.IsNullOrEmpty(userClient) ? @"" : @"with " + userClient));
            writer.Write(@"<br/>");
            writer.Write(userTitle);
            writer.Write(@"</div>");
          }

          /*--------------------------------------
           * Public
           *-------------------------------------*/                    

          else
          {
          
            _renderMenuPublic(ref writer);

            
           /*--------------------------------------
            * User data
            *-------------------------------------*/                    
           
           writer.Write(@"<br/>");                  
           writer.Write(@"<div class=""page-app-user-data"">");
           //writer.Write(@"You are not logged in");
           writer.Write(@"<br/>");
           //writer.Write(@"Click <a href=""" + homeLink + @""" data-ajax=""false"">here</a> to login");
           writer.Write(@"</div>");

          }

          /*--------------------------------------
           * App notice
           *-------------------------------------*/                    
           
          if (!Util.IsNullOrEmpty(Constants.APP_NOTICE))
          {
            writer.Write(@"<div class=""app-notice site-notice"">");
            writer.Write(Constants.APP_NOTICE);
            writer.Write(@"</div>");
          } 

          
          writer.Write(@"</div>");

          /*============================================================
           * Content
           *============================================================*/

          writer.Write(@"<div role=""main"" class=""ui-content"">");                          

          /*--------------------------------------
           * Status messages
           *-------------------------------------*/   

          DetailList dl = new DetailList();
          dl.ID         = "pagedetails";
          dl.RenderControl(writer);
                                    
          if (rd.status == Return.RET_SUCCESS)
          {
            base.Render(writer);
          }
          else 
          {                        
            // TODO: See if we want to render if we have warnings or errors.  Get these from the details list
            // if (rd.status == Return.RET_WARNING)              
          }
                                      
          writer.Write(@"</div>");
          
          /*============================================================
           * Footer           
           *============================================================*/

          writer.Write(@"<div data-role=""footer"" data-position=""fixed"">");
          
          if (!rd.loggedIn)
          {
            _renderFooterPublic(ref writer);
          }
      
          // Private footer (based on user role)

         else
         {
           _renderFooterPrivate(ref writer,this.rd.wu.usr.roleName.ToLower()); 
         }
         

         
         writer.Write(@"</div>");         
         writer.Write(@"</div>");

         /*============================================================
          * End of document
          *============================================================*/
         
         writer.Write(@"</body>");
         writer.Write(@"</html>");

        }
    }
}