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
   * SelectServiceType */
  /**
   * 
   ****************************************************************************/ 
 
  public class SelectServiceType : RadioBox
  {
    
    public SelectServiceType() 
    {    
      this.firedataselected = true;      
      this.labelIsSpan      = false;
      this.noClear          = false;
      this._onSelectValue   = @"function(oldval,newval){return true;}";
    }             
   
    protected bool _showSelectAnyOption   = true;

    public bool showSelectAnyOption   { get { return _showSelectAnyOption;}   set { _showSelectAnyOption  = value;}  }

    protected override void OnPreRender(EventArgs e)
    {      
      this.addCssClass("ui-spedmon-box-radio-yes-no-container");
      this.additionalCssClassNameForContainer = "modern2021";
	  if (_showSelectAnyOption) this.AddSelection(@"Any Type", "");
      this.AddSelection(@"Assessments/Screenings", "1");
      this.AddSelection(@"Treatments/Therapy",     "2");
      this.AddSelection(@"Transportation",         "3");
      this.AddSelection(@"TCM",                    "4");
      this.AddSelection(@"Notes/Other",            "5");
      this.AddSelection(@"Supervision",            "6");
      base.OnPreRender(e);
    }
 
  }
}