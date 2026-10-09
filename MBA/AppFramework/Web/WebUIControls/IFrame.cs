using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
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

  /**************************************************************************
   * IFrame */
  /**
   * Inline script wrapper
   * 
   *****************************************************************************/

  public class IFrame : WebUIControlContainer
  {
    public IFrame(): base("iframe", false){}
    
    protected string  _name;
	  protected string  _src;
	  public    string   name   { get { return _name;}  set {_name  = value;}}
    public    string   src    { get { return _src; }  set {_src   = value;}}
	
	  protected override void Render(HtmlTextWriter writer)
    {
      /*-------------------------------
       * Add required attributes
       *------------------------------*/

      this.addAttribute("name", _name, ATTR_HTML_TAG);
	    this.addAttribute("src",  _src,  ATTR_HTML_TAG);
      base.Render(writer);
    }
  }

}

