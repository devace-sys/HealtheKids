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
  * RawHTML */
  /**
  * Raw html
  * 
  * @param  html            html to add
  ****************************************************************************/ 

  public class RawHTML:ControlBase
  {
    public RawHTML(){}
    public RawHTML(string html) {this._html = html;}

    private   string        _html  = "";
    public    string        html   {get{return _html;}  set{_html = value;}}
    protected override void Render (HtmlTextWriter writer) { writer.Write(_html);}  
  }

}

