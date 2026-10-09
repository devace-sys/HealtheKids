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
   * Wrapper */
  /**
   **************************************************************************/

  public class Wrapper : WebUIControlContainer
  {
    public Wrapper(string tag) : base(tag, false) { }
    
    public Wrapper(string tag, params Control[] args) : base(tag, false) {
      foreach (Control arg in args) {
        this.Controls.Add(arg);
      }    
    }
    
    protected override void Render(HtmlTextWriter writer)
    {	      
      base.Render(writer);
    }
  }
}