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
   * RadioBox */
  /**
   * RadioBox
   * 
   * @param  name             name
   * @param  value            value
   ****************************************************************************/

  public class RadioBox : WebUIControlDataField
  {
    public RadioBox ()                          : base ("input", true)              {_valueselections = new List<ValueSelection>();}
    public RadioBox (string name)               : base ("input", true, name)        {_valueselections = new List<ValueSelection>();}
    public RadioBox (string name, string value) : base ("input", true, name, value) {_valueselections = new List<ValueSelection>();}

    protected List<ValueSelection> _valueselections           = new List<ValueSelection>();  
    protected bool                 _labelIsSpan               = true;
    protected bool                 _renderLabel               = true;
    protected bool                 _displaySelectionsVertical = false;
    protected bool                 _firedataselected          = true;
    protected string               _onSelectValue             = "function(oldval,newval){return true;}";
    protected string               _selectedLabel             = @"";
    
    /*-------------------------------
     * Provide way to disable firing
     * the data selected event
     *------------------------------*/
        
    public bool   firedataselected          {get { return _firedataselected; } set { _firedataselected = value; }}              
    public bool   renderLabel               {get { return _renderLabel;      } set { _renderLabel      = value; }}
    public bool   labelIsSpan               {get { return _labelIsSpan;      } set { _labelIsSpan      = value; }}
    public bool   displaySelectionsVertical {get { return _displaySelectionsVertical;} set { _displaySelectionsVertical = value; }}
    public string onSelectValue             {get { return _onSelectValue; } set { _onSelectValue    = value; }}
    public string selectedLabel             {get { return _selectedLabel; }}

    /*-------------------------------
     * Adds a selection
     *------------------------------*/
    public void AddSelection (Enum en)
    {
      this.AddSelection(en, false);
    }
    public void AddSelection (Enum en, bool selected)
    {
        var label = en.GetDescription();
        var value = en.GetValueAsString();            
        this.AddSelection(label, value, selected);
    }

    public void AddSelection (string label, string value)
    {
      this.AddSelection(label, value, false);
    }
    
    public void AddSelection (string label, string value, bool selected)
    {
      
      // If this selection value is equal to the control value, we want to use it as the selected value
      // Note: this can still be overidden by another selection
      
      if (this.value == value)
      {
        selected = true;       
      } 
      
      ValueSelection vs = new ValueSelection(label, value, selected);
      
      // If this is flaged as selected clear previous selection flags (we are only allowed one selection)
      // and set the selected label
      
      if (selected)
      {      
        for (int i=0;i < _valueselections.Count;i++) {
          this._valueselections[i].selected = false;
        }                
        this._selectedLabel = vs.label;
      }
      
      // Add new selection
      
      this._valueselections.Add(vs);
    }
    
    protected override void Render(HtmlTextWriter writer)
    {             
      /*-------------------------------
       * Render as a regular text input
       * We will enhance it into a 
       * radiobox in the browser
       *------------------------------*/
      
      this.addCssClass (WEB_UI_FIELD_DATA_TEXT);

      /*-------------------------------
       * Parse selections into a json
       * array so we can pass them to
       * our client side control
       *------------------------------*/
      
      string valueSelections = "[";
      
      foreach (ValueSelection vs in _valueselections)
      {
        valueSelections = valueSelections + vs.ToString() + ",";
      }
      
      // Remove last comma if neccessary
      
      if (valueSelections.EndsWith(","))
      {
        int endidx = valueSelections.Length - 1;
        valueSelections = valueSelections.Remove(endidx);
      }
      
      valueSelections = valueSelections + "]";
                       
      this._selectedLabel = @"";
      
      /*-------------------------------
       * Create our options object
       *------------------------------*/

      string options = "{"
      + "fireDataSelected:" + Util.netBoolToJSBool(_firedataselected)
      + ","      
      + "renderLabel:" + Util.netBoolToJSBool(_renderLabel)
      + ","      
      + "labelIsSpan:" + Util.netBoolToJSBool(_labelIsSpan)
      + ","
      + "additionalCssClassNameForContainer:'" + this._additionalCssClassNameForContainer + "'"
      + ","
      + "displaySelectionsVertical:" + Util.netBoolToJSBool(_displaySelectionsVertical)
      + ","
      + "onSelectValue:" + _onSelectValue
      + ","
      + "valueSelections:"
      + valueSelections
      + "}";
      
      this.addAttribute ("type",                "text",              ATTR_HTML_TAG);
      this.addAttribute ("data-selected-label", this._selectedLabel, ATTR_HTML_TAG);
      this.addAttribute ("spedmonRadioBox",     options,             ATTR_JS_PAGE_LOAD_METHOD);
      base.Render(writer);
    }
  }
}

