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
   * TeleCommFormEnterPIN */
  /**
   * 
   * 
   ****************************************************************************/ 

  public class TeleCommFormEnterPIN:ControlBase
  {
    public TeleCommFormEnterPIN(){}    

    protected string _cssClasses     = @"form-control";	
    protected string _value          = @"";	
    public string cssClasses         { get { return _cssClasses;}    set { _cssClasses = value;}}
    public string value              { get { return _value;     }    set { _value = value;     }} 
    protected override void Render (HtmlTextWriter writer) 
	  {       
	    writer.Write(@"<input id=""{0}"" type=""password"" placeholder=""Enter PIN"" class=""{1}"" autocomplete=""off"" value=""{2}"" required/>",this.ID, this._cssClasses, this._value);
	  }  
  }
}

