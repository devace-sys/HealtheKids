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
   * SelectIEPOrOther */
  /**
   * 
   ****************************************************************************/ 
 
  public class SelectIEPOrOther : RadioBox
  {
    
    public SelectIEPOrOther() 
    {    
      this.firedataselected = true;      
      this.labelIsSpan      = false;
      this.noClear          = false;
      this._onSelectValue   = @"function(oldval,newval){return true;}";
    }             
   
    protected override void OnPreRender(EventArgs e)
    {
      this.addCssClass("ui-spedmon-box-radio-yes-no-container");
      this.additionalCssClassNameForContainer = "modern2021";
      this.AddSelection(@"IEP / IFSP"                         , @"Y");
      this.AddSelection(@"Other (IHP, 504, Counseling, etc.)" , @"N");
      base.OnPreRender(e);
    }
 
  }
}