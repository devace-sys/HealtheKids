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

  /************************************************************************
   * Label */
  /**
   * LabelBox
   * 
   * @param  for     for what control   
   ****************************************************************************/

  public class LabelBox : WebUIControlDisplay
  {
    protected string _text = @"";
      
    public LabelBox() : base("label", false) {
      this.cssClass = @"mba-web-ui mba-web-ui-inline";
    }
    
    public LabelBox(string forid, string text) : this() 
    { 	
	    this.forid = forid;
	    this._text = text;	    	    	    
	  }
    	
	  public string forid { get { return (string)this.findAttribute("for"); } set { this.addAttribute("for", value, ATTR_HTML_TAG); } }
    public string text  { get { return _text;                             } set { _text = value; }}
    
    protected override void Render(HtmlTextWriter writer)
    {	            
      if (!Util.IsNullOrEmpty(_text)) this.Controls.Add(new RawText(_text));
      base.Render(writer);
    }
    
  }
}

