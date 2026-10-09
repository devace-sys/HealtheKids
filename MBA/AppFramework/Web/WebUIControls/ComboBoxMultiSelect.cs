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
   * ComboBoxMultiSelect */
  /**
   * multi-select combobox with inline tags
   ****************************************************************************/

  public class ComboBoxMultiSelect : SelectBoxBaseMultiSelect 
  {
    public ComboBoxMultiSelect () : base() { _multiSelect = true; }
    public ComboBoxMultiSelect (string name, string value) : base(name, value) { _multiSelect = true; }

    protected string _dataURL;
    protected string _dataParms;
    protected string _dataParmsType;
    protected string _onSelect;
    
    protected int  _delay       = 600;
    protected bool _dataPrivate = true;
    protected bool _selectAll   = true;

    public bool   dataPrivate   { get { return _dataPrivate;   } set { _dataPrivate   = value; } }
    public string dataParmsType { get { return _dataParmsType; } set { _dataParmsType = value; } }
    public string dataParms     { get { return _dataParms;     } set { _dataParms     = value; } }
    public bool   selectAll     { get { return _selectAll;     } set { _selectAll     = value; } }
    public string onSelect      { get { return _onSelect;      } set { _onSelect      = value; } }
    public int    delay         { get { return _delay;         } set { _delay         = value; } }
    public string dataURL       { get { return _dataURL; }       set { _dataURL = MBA.HttpApplication.createLink(value, _dataPrivate); } }

    protected override void Render(HtmlTextWriter writer)
    {
      if (Util.IsNullOrEmpty(_onSelect))      _onSelect = "";
      if (Util.IsNullOrEmpty(_dataParmsType)) _dataParmsType = Constants.DATA_PARM_TYPE_DOM;
      if (_delay <= 0) _delay = 600;

      if (!Util.IsNullOrEmpty(this._dataURL))
      {
        if (Util.IsNullOrEmpty(this._dataParms)) this._dataParms = "{}";

        string prms = @"{" +
          @"dataParmType:'"       + this._dataParmsType                                + @"'," +
          @"selectAll:"           + this._selectAll.ToString().ToLower()               + ","   +
          @"delay:"               + this._delay.ToString()                             + ","   +
          @"selectType:"          + ((int) SelectTypeMultiSelect.COMBO_BOX).ToString() + ","   +
          @"displayInline:"       + Util.netBoolToJSBool(_displayInline)               + ","   +
          @"showSelectControlLabel:" + Util.netBoolToJSBool(_showSelectControlLabel)   + ","   +
          @"selectControlLabel:'" + _selectControlLabel                                + @"'," +
          @"singleSelectName:'"   + this._selectName                                   + @"'," +
          @"singleSelectValue:'"  + this.value                                         + @"'," +
          @"singleSelectClearAfterSelection:" + Util.netBoolToJSBool(_singleSelectClearAfterSelection) + "," + 
          @"multiSelect:"                + Util.netBoolToJSBool(_multiSelect)                 + ","   +
          @"multiSelectLoad:"            + Util.netBoolToJSBool(_multiselectload)             + ","   +
          @"multiSelectNames:'"          + this._multiselectnames                             + @"'," +
          @"multiSelectValues:'"         + this._multiselectvalues                            + @"'," +
          @"multiSelectContextLabels:'"  + this._multiSelectContextLabels                     + @"'," +
          @"multiSelectDisplayContextLabels:" + Util.netBoolToJSBool(_multiSelectDisplayContextLabels) + "," +
          @"multiSelectShowOK:"          + Util.netBoolToJSBool(_multiSelectShowOK)           + ","   +
          @"multiSelectListTitle:'"      + this._multiSelectListTitle                         + @"'," +
          @"multiSelectShowTags:"        + Util.netBoolToJSBool(_multiSelectShowTags)         + ","   +
          @"multiSelectShowClearAll:"    + Util.netBoolToJSBool(_multiSelectShowClearAll)     + ","   +
          @"multiSelectShowCount:"       + Util.netBoolToJSBool(_multiSelectShowCount)        + ","   +
          @"multiSelectMaxSelections:"   + this._multiSelectMaxSelections.ToString()          + ","   +
          @"multiSelectEmptyText:'"      + this._multiSelectEmptyText                         + @"'," +
          @"multiSelectTagRemoveTitle:'" + this._multiSelectTagRemoveTitle                    + @"'," +
          @"multiSelectAllowKeyboardNav:" + Util.netBoolToJSBool(_multiSelectAllowKeyboardNav) + "," +
          @"multiSelectScroll:"          + Util.netBoolToJSBool(_multiSelectScroll)           + ","   +
          @"multiSelectScrollAfter:"     + this._multiSelectScrollAfter.ToString()            + ","   +
          @"multiSelectOnAdd:function(selObj){"    + this._multiSelectOnAdd    + @"}," +
          @"multiSelectOnRemove:function(selObj){" + this._multiSelectOnRemove + @"}," +
          @"multiSelectOnChange:function(values,names){" + this._multiSelectOnChange + @"}," +
          @"onSelect:function(event,ui){" + this._onSelect + @"}," +
          @"afterRenderItem:function(item,$li){" + this._afterRenderItem + @"}," +
          @"ajaxopts:{url:'" + this._dataURL + @"',data:" + this._dataParms + @"}}";
                
        this.addAttribute("spedmonSelectBoxMultiSelect", prms, ATTR_JS_PAGE_LOAD_METHOD);
      }

      base.Render(writer);
    }

  }

}