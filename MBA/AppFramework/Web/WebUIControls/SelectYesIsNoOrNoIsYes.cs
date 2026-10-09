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
   * SelectYesIsNoOrNoIsYes */
  /**
   * A yes answer submits a No and a No answer submits a yes
   * 
   ****************************************************************************/ 
 
  public class SelectYesIsNoOrNoIsYes : RadioBox
  {
    public const string YES     = "Yes";
    public const string NO      = "No";

    public SelectYesIsNoOrNoIsYes() 
    {    
      this.firedataselected = true;      
      this.labelIsSpan      = false;
      this.noClear          = false;
      this._onSelectValue   = @"function(oldval,newval){return true;}";
    }             
   
    public void setValue (bool value)
    {        	
	  this.value = Util.boolToYesNo(value);
    }

    protected override void OnPreRender(EventArgs e)
    {
      this.addCssClass("ui-spedmon-box-radio-yes-no-container");
      this.additionalCssClassNameForContainer = "modern2021";
      this.AddSelection(YES,NO);
      this.AddSelection(NO,YES);
      base.OnPreRender(e);
    }
 
  }
}