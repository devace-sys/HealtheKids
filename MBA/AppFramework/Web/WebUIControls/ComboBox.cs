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
   * ComboBox */
  /**
   * ComboBox
   ****************************************************************************/

  public class ComboBox : SelectBoxBase 
  {
    public ComboBox ()                          : base()            { }
    public ComboBox (string name, string value) : base(name, value) { }

    protected string _dataURL;
    protected string _dataParms;
    protected string _dataParmsType;
    protected string _onSelect;
    
    protected int  _delay;
    protected bool _dataPrivate = true;
    protected bool _selectAll   = true;

    public bool   dataPrivate   { get { return _dataPrivate; }   set { _dataPrivate = value; } }
    public string dataParmsType { get { return _dataParmsType; } set { _dataParmsType = value; } }
    public string dataParms     { get { return _dataParms; }     set { _dataParms = value; } }
    public bool   selectAll     { get { return _selectAll; }     set { _selectAll = value; } }
    public string onSelect      { get { return _onSelect; }      set { _onSelect = value; } }
    public string dataURL       { get { return _dataURL; }       set { _dataURL = MBA.HttpApplication.createLink(value, _dataPrivate); } }
    public int    delay         { get { return _delay; }         set {_delay = value;}}

    protected override void Render(HtmlTextWriter writer)
    {
      if (Util.IsNullOrEmpty(_onSelect))      _onSelect = "";
      if (Util.IsNullOrEmpty(_dataParmsType)) _dataParmsType = Constants.DATA_PARM_TYPE_DOM;
      if (_delay <= 0) _delay = 600;

      if (!Util.IsNullOrEmpty(this._dataURL))
      {
        if (Util.IsNullOrEmpty(this._dataParms)) this._dataParms = "{}";
        string prms = @"{" +                  
                      @"dataParmType:'" + this._dataParmsType                     + "'," +
                      @"selectAll:"     + this._selectAll.ToString().ToLower()    + ","  +
                      @"delay:"         + this._delay.ToString()                                 + ","  +      
                      @"showSelectControlLabel:" + Util.netBoolToJSBool(_showSelectControlLabel) + ","  +
                      @"selectControlLabel:'"    + _selectControlLabel                           + @"'," +
                      @"selectType:"    + ((int) SelectType.COMBO_BOX).ToString()                + ","  +
                      @"displayInline:"          + Util.netBoolToJSBool(_displayInline)          + ","  +
                      @"singleSelectName:'"      + this._selectName                         + @"'," +
                      @"singleSelectValue:'"     + this.value                               + @"'," +
                      @"singleSelectClearAfterSelection:" + Util.netBoolToJSBool(_singleSelectClearAfterSelection) + @"," + 
                      @"multiSelect:"            + Util.netBoolToJSBool(_multiSelect)       + ","  +
                      @"multiSelectShowOK:"      + Util.netBoolToJSBool(_multiSelectShowOK) + "," +
                      @"multiSelectListTitle:'"  + this._multiSelectListTitle               + "'," + 
                      @"multiSelectNames:'"      + this._multiselectnames                   + "'," +
                      @"multiSelectValues:'"     + this._multiselectvalues                  + "'," +                      
                      @"multiSelectLoad:"        + Util.netBoolToJSBool(_multiselectload)   + ","  +                      
                      @"multiSelectContextLabels:'"       + this._multiSelectContextLabels                         + "'," +
                      @"multiSelectDisplayContextLabels:" + Util.netBoolToJSBool(_multiSelectDisplayContextLabels) + "," +
                      @"multiSelectOnAdd:function(selObj){"    + this._multiSelectOnAdd    + "}," +
                      @"multiSelectOnRemove:function(selObj){" + this._multiSelectOnRemove + "}," +                      
                      @"onSelect:function(event,ui){" + this._onSelect + "},"  +      
                      @"afterRenderItem:function(item, $renderedli){" + this._afterRenderItem + "}," + /* Note: Handler MUST return $renderedli */
                      @"ajaxopts:{url:""" + this._dataURL + @"""," +
                      @"data:" + this._dataParms +
                      @"}}";
                
        this.addAttribute("spedmonSelectBox", prms, ATTR_JS_PAGE_LOAD_METHOD);
      }
      else
      {
      }
      base.Render(writer);
    }

    /*
    public void RenderComboBox(HtmlTextWriter writer) // needs public method 
    {
      this.Render(writer);
    }
    */


  }

}

