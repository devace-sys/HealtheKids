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
   * SelectYesOrNoOrUnknown*/
  /**
   * <Spedmon:SelectYesOrNoOrUnknown ID="testyn" name="testyn" title="Select One" runat="server" />
   * 
   ****************************************************************************/ 
 
  public class SelectYesOrNoOrUnknown : RadioBox
  {
    public const string YES     = "Yes";
    public const string NO      = "No";
    public const string UNKNOWN = "Unknown";

    public SelectYesOrNoOrUnknown() 
    {    
      this.firedataselected = true;      
      this.labelIsSpan      = false;
      this.noClear          = false;
      this._onSelectValue   = @"function(oldval,newval){return true;}";
    }             
   
    protected override void OnPreRender(EventArgs e)
    {
      this.addCssClass("ui-spedmon-box-radio-yes-no-unknown-container");
      this.additionalCssClassNameForContainer = "modern2021";
      this.AddSelection(YES,YES);
      this.AddSelection(NO,NO);
      this.AddSelection(UNKNOWN,UNKNOWN);
      base.OnPreRender(e);
    }
 
  }
}