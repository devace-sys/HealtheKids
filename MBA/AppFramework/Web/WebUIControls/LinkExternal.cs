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
   * LinkExternal */
  /**
   * LinkExternal
   *
   * @param  href            Link to external app
   * @param  openNew         Open new page
   * @param  text            Text inside   
   ****************************************************************************/

  public class LinkExternal : WebUIControlDisplay
  {
    protected string _text    = @"";
    protected string _url     = @"";    
	  protected bool   _openNew = true;
	
    public LinkExternal(): base("a", false) {    
      this.cssClass = @"mba-web-ui-link-external";
    }
    
    public LinkExternal(string text, string linkurl, bool opennew) : this()
    { 		    
	    this._text    = text;	    
		  this._url     = linkurl;
		  this._openNew = opennew;
    }    	
    
    public LinkExternal(string text, string linkurl): this(text,linkurl,true){}
  
  	public string url     { get { return _url;     } set { _url     = value; }}
    public string text    { get { return _text;    } set { _text    = value; }}
    public bool   openNew { get { return _openNew; } set { _openNew = value; }}
    
	  protected override void Render(HtmlTextWriter writer)
    {	            
      if (!Util.IsNullOrEmpty(_url)) this.addAttribute("href",   _url,     ATTR_HTML_TAG);
      if (_openNew == true)          this.addAttribute("target", "_blank", ATTR_HTML_TAG);
	    if (!Util.IsNullOrEmpty(_text)) this.Controls.Add(new RawText(_text));
      base.Render(writer);
    }
    
  }
}

