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
   * SelectPlanType */
  /**
   * 
   ****************************************************************************/ 
 
  public class SelectPlanType : RadioBox
  {
    
    public SelectPlanType() 
    {    
      this.firedataselected = true;      
      this.labelIsSpan      = false;
      this.noClear          = false;
      this._onSelectValue   = @"function(oldval,newval){return true;}";
    }             
   
    protected bool _showSelectAnyOption   = false;
    protected bool _showFullLabelForOther = true;

    public bool showSelectAnyOption   { get { return _showSelectAnyOption;}   set { _showSelectAnyOption  = value;}  }
    public bool showFullLabelForOther { get { return _showFullLabelForOther;} set { _showFullLabelForOther = value;} }
    protected override void OnPreRender(EventArgs e)
    {
      
      this.addCssClass("ui-spedmon-box-radio-yes-no-container");
      this.additionalCssClassNameForContainer = "modern2021";
      var _labelOther = (_showFullLabelForOther ? "Other (IHP, 504, Counseling, etc.)" : "Other Plan");

      if (_showSelectAnyOption) this.AddSelection(@"Any" , @"");

	  this.AddSelection(@"IFSP"         , Constants.PLAN_IFSP.ToString());
      this.AddSelection(@"IEP"          , Constants.PLAN_IEP.ToString());
      this.AddSelection(_labelOther     , Constants.PLAN_NONE.ToString());
	  this.AddSelection(@"CYBHI"        , Constants.PLAN_CYBHI.ToString());
      this.AddSelection(@"RU Health"    , Constants.PLAN_RU_HEALTH.ToString());
      base.OnPreRender(e);
    }
 
  }
}