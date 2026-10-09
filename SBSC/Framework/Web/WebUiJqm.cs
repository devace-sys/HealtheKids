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
  * WebUI */
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
  
  public class WebUiJqm: MBA.WebUiJqm
  {                 
        

    /*===============================
     * Delegates
     *===============================*/ 
    
    /*-------------------------------
     * Public menu
     *------------------------------*/ 

    static renderMenuPublic rmenuPublic  = new renderMenuPublic(delegate(ref HtmlTextWriter writer){ 
   
   
      writer.Write(@"<div data-role=""controlgroup"" data-type=""horizontal"" class=""ui-mini ui-btn-right"">");                  
      writer.Write(@"<a href=""" + Constants.HOME_PUBLIC + @""" class=""mba-ui-form-options-control ui-btn ui-btn-icon-left ui-icon-home"" data-ajax=""false"">Home</a>");
      writer.Write(@"<a id=""requestAccountLink"" href=""" + Constants.REQUEST_ACCOUNT +@""" class=""mba-ui-form-options-control ui-btn ui-btn-icon-left ui-icon-user"" data-ajax=""false"">Request Account</a>");
      writer.Write(@"<a id=""forgotPasswordLink"" href=""" + Constants.FORGOT_MY_PASSWORD +@""" class=""mba-ui-form-options-control ui-btn ui-btn-icon-left ui-icon-lock"" data-ajax=""false"">Reset Password</a>");      
      writer.Write(@"<a id=""requestUploadLink"" href="""  + Constants.REQUEST_FILE_UPLOAD_PUBLIC +@""" class=""mba-ui-form-options-control ui-btn ui-btn-icon-left ui-icon-action"" data-ajax=""false"">Send Us A File</a>");
      writer.Write(@"</div>");

      return;
    });

    /*-------------------------------
     * Private menu
     *------------------------------*/ 
    
    static renderMenuPrivate rmenuPrivate = new renderMenuPrivate(delegate(ref SqlConnection dbConnUser, ref SqlConnection dbConnApp, ref DetailsLog log, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer){
      return;
    });
    
    /*-------------------------------
     * Public footer
     *------------------------------*/ 

    static renderFooterPublic rfooterPublic = new renderFooterPublic(delegate(ref HtmlTextWriter writer){
      writer.Write(@"<p class=""ui-footer-app-data"">Version " + Constants.APP_VERSION + ". " + Messages.COPYRIGHT + "</p>");      
      writer.Write(@"<p class=""ui-footer-contact-data"">" + Constants.APP_CONTACT.name + @" | " + Constants.APP_CONTACT.mail + @" | <a href=""mailto:" + Constants.APP_CONTACT.email + @""" title=""Email us!"">" + Constants.APP_CONTACT.email + @"</a></p>");
    });

    /*-------------------------------
     * Private footer
     *------------------------------*/ 

    static renderFooterPrivate rfooterPrivate = new renderFooterPrivate(delegate(ref HtmlTextWriter writer, string roleNameLower){
      
      // TODO: District rep contact
      writer.Write(@"<p class=""ui-footer-app-data"">Version " + Constants.APP_VERSION + ". " + Messages.COPYRIGHT + "</p>");      
      writer.Write(@"<p class=""ui-footer-contact-data"">" + Constants.APP_CONTACT.name + @" | " + Constants.APP_CONTACT.mail + @" | <a href=""mailto:" + Constants.APP_CONTACT.email + @""" title=""Email us!"">" + Constants.APP_CONTACT.email + @"</a></p>");
    });


    
    /*===============================
     * Constructors
     *===============================*/ 

    public WebUiJqm (string subtitle, params string[] permittedroles): base(subtitle, rmenuPublic,rmenuPrivate,rfooterPublic, rfooterPrivate, permittedroles)
    {
    }
  }
}
