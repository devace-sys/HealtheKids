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
   * SelectAllActiveInactive*/
  /**
   * 
   * 
   ****************************************************************************/ 
 
  public class SelectAllActiveInactive : RadioBox
  {

    public SelectAllActiveInactive() 
    {    
      this.firedataselected = true;      
      this.labelIsSpan      = false;
      this.noClear          = false;
      this._onSelectValue   = @"function(oldval,newval){return true;}";
    }             
   
    protected override void OnPreRender(EventArgs e)
    {
      this.AddSelection("Active",                    "Y");
      this.AddSelection("Deactivated",               "N");
      this.AddSelection("Active and Deactivated",    "");
      base.OnPreRender(e);
    }
 
  }
}