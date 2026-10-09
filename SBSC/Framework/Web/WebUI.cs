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
  
  public class WebUI: Spedmon.WebUI2
  {                 
    /*===============================
     * Constructors
     *===============================*/ 

    public WebUI(
        string bodyid
      , string subtitle
      , params string[] permittedroles):base(bodyid,subtitle,null,null,permittedroles){}   

    public WebUI(
        string bodyid
      , string subtitle
      , string css
      , string js
      , params string[] permittedroles):base(
            bodyid
          , subtitle
          , css
          , js
          , permittedroles)
    {
    }
  }
}