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
   * SelectYesIsTrueNoIsBlank */
  /**
   * A yes answer submits a true and a No answer submits a blank
   * 
   ****************************************************************************/ 
 
  public class SelectYesIsTrueNoIsBlank : RadioBox
  {
    public const string YES_VALUE     = "true";
    public const string NO_VALUE      = "";

    public SelectYesIsTrueNoIsBlank() 
    {    
      this.firedataselected = true;      
      this.labelIsSpan      = false;
      this.noClear          = false;
      this._onSelectValue   = @"function(oldval,newval){return true;}";
    }             
   
    public void setValue (bool value)
    {        	
	  if (value == true) this.value = YES_VALUE; else this.value = NO_VALUE;
    }
    public void setValue (string value)
    {        	
	  bool? _v = Util.evaluateFlag(value,true);
      if (_v.HasValue) { setValue(_v.Value); return; }
      this.value = NO_VALUE;            
    }

    protected override void OnPreRender(EventArgs e)
    {
      this.addCssClass("ui-spedmon-box-radio-yes-no-container");
      this.additionalCssClassNameForContainer = "modern2021";
      this.AddSelection("Yes",YES_VALUE);
      this.AddSelection("No",NO_VALUE);
      base.OnPreRender(e);
    }
 
  }
}