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
  /****************************************************************************
   * PhoneLink */
  /**
   * Phone number in an anchor
   * https://www.w3schools.com/tags/tag_a.asp
   ****************************************************************************/   
  
  public class PhoneLink : WebUIControlDisplay
  {
    public PhoneLink() : base("a", false) { }    
    
    protected string _value = @"";

    public string value { get { return _value; } set { _value = value;}}

    protected override void Render(HtmlTextWriter writer)
    {
      if (!String.IsNullOrEmpty(_value))
      { 
        string _tel = String.Format(@"tel:{0}",_value);  
        this.addAttribute(@"href",_tel, ATTR_HTML_TAG);  
        this.Controls.Add(new RawText(_value));
      }
      else
      {
        /* Placeholder */
        this.addAttribute(@"href", @"#", ATTR_HTML_TAG);  
      }
                        
      base.Render(writer);
    }
  }

}

