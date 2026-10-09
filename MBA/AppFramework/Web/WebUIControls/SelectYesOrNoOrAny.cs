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
   * SelectYesOrNoOrAny*/
  /**
   * <Spedmon:SelectYesOrNoOrAny ID="testyn" name="testyn" title="Select One" runat="server" />
   * 
   ****************************************************************************/ 
 
  public class SelectYesOrNoOrAny : RadioBox
  {
    public const string YES     = "Yes";
    public const string NO      = "No";
   
    protected string _anyLabel = @"Any";
	protected string _anyValue = @"";
	
    public string anyLabel { 
            get { return _anyLabel;}
            set { _anyLabel = value;}
    }
    public string anyValue
    {
      get { return _anyValue;}
      set { _anyValue = value;}
    }

    public SelectYesOrNoOrAny() 
    {    
      this.firedataselected = true;      
      this.labelIsSpan      = false;
      this.noClear          = false;
      this._onSelectValue   = @"function(oldval,newval){return true;}";
    }             
   
    protected override void OnPreRender(EventArgs e)
    {
      this.addCssClass("ui-spedmon-box-radio-yes-no-any-container");
      this.additionalCssClassNameForContainer = "modern2021";
      this.AddSelection(YES,YES);
      this.AddSelection(NO,NO);
      this.AddSelection(_anyLabel,_anyValue);
      base.OnPreRender(e);
    }

    public void setValueFromFlag (string flagvalue)
    {
        bool? _flagValue = Util.evaluateFlag(flagvalue,false);
        setValueFromFlag(_flagValue);
    }
    public void setValueFromFlag (bool? flagvalue)
    {
      if (flagvalue.HasValue == false)
      {           
         this.value          = this._anyValue;
         this._selectedLabel = this._anyLabel;
      }
      else
      {
        if (flagvalue.Value == true)
        {             
          this.value          = YES; 
          this._selectedLabel = YES;
        }
        else {                   
          this.value          = NO;
          this._selectedLabel = NO;
        }
      }
    }
 
  }
}