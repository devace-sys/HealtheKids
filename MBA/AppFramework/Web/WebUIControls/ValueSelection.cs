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
   * ValueSelection */
  /**
   * Generic value selection
   * Note: This control has unsusual markup requirments for jQuery therefore
   * it has been put into its own class that inherits from control
   ****************************************************************************/

  public class ValueSelection : Control
  {
    public ValueSelection() 
    {
      this._label    = "";
      this._value    = "";
      this._selected = false;
    }
    
    public ValueSelection(string label, string value)
    {
      this._label    = label;
      this._value    = value;
      this._selected = false;
    }
    
    public ValueSelection(string label, string value, bool selected)
    {
      this._label    = label;
      this._value    = value;
      this._selected = selected;
    }
    
    protected string _label;
    protected string _value;
    protected bool   _selected;
    
    public string label    {get {return _label;}    set {_label    = value;}}
    public string value    {get {return _value;}    set {_value    = value;}}
    public bool   selected {get {return _selected;} set {_selected = value;}}
    
    public override string ToString()
    {
       return @"{""label"":""" + this.label + @""",""value"":""" + this.value + @""", selected:" + Util.netBoolToJSBool(this._selected) + @"}";
    }
    
    protected override void Render(HtmlTextWriter writer)
    {
      // Nothing to render
    }
  }

}

