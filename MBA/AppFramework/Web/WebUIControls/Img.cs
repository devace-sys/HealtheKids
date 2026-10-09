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
    * Img */
  /**
  * Image
  * 
  * @param  src             url of image
  * @param  alt             alternate text
  ****************************************************************************/

  public class Img : WebUIControlDisplay
  {
    public Img() : base("img", true) { }
    public Img(string _src, string _alt) : this() { this.src = _src; this.alt = _alt; }
    public string src { get { return (string)this.findAttribute("src"); } set { this.addAttribute("src", value, ATTR_HTML_TAG); } }
    public string alt { get { return (string)this.findAttribute("alt"); } set { this.addAttribute("alt", value, ATTR_HTML_TAG); ;} }
  }

}

