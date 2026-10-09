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
   * SearchBox */
  /**
   * Search box control
   ****************************************************************************/

  public class SearchBox : SelectBoxBase
  {
    public SearchBox ()                          : base()            { }
    public SearchBox (string name, string value) : base(name, value) { }

    protected string _dataURL;
    protected string _dataParms;
    protected string _dataParmsType;
    protected string _onSelect;

    protected bool _dataPrivate = true;

    public bool   dataPrivate   { get { return _dataPrivate; }   set { _dataPrivate = value; } }
    public string dataParmsType { get { return _dataParmsType; } set { _dataParmsType = value; } }
    public string dataParms     { get { return _dataParms; }     set { _dataParms = value; } }
    public string onSelect      { get { return _onSelect; }      set { _onSelect = value; } }
    public string dataURL       { get { return _dataURL; }       set { _dataURL = MBA.HttpApplication.createLink(value, _dataPrivate); } }

    protected override void Render(HtmlTextWriter writer)
    {
      if (Util.IsNullOrEmpty(_onSelect))      _onSelect      = "";
      if (Util.IsNullOrEmpty(_dataParmsType)) _dataParmsType = Constants.DATA_PARM_TYPE_DOM;

      if (!Util.IsNullOrEmpty(this._dataURL))
      {
        if (Util.IsNullOrEmpty(this._dataParms)) this._dataParms = "{}";
        string prms = @"{" +
             
                      @"dataParmType:'"    + this._dataParmsType + "'," +
                      @"selectAll:false,"  +
                      @"delay:0,"          +
                      @"showSelectControlLabel:" + Util.netBoolToJSBool(_showSelectControlLabel) + ","  +
                      @"selectControlLabel:'"    + _selectControlLabel                           + @"'," +
                      @"selectType:"             + ((int) SelectType.SEARCH_BOX).ToString() + "," +
                      @"displayInline:"          + Util.netBoolToJSBool(_displayInline) + ","  +
                      @"singleSelectName:'"      + this._selectName                   + @"'," +
                      @"singleSelectValue:'"     + this.value                         + @"'," +
                      @"singleSelectClearAfterSelection:" + Util.netBoolToJSBool(_singleSelectClearAfterSelection) + @"," +          
                      @"multiSelect:"            + Util.netBoolToJSBool(_multiSelect) + "," +
                      @"multiSelectListTitle:'"  + this._multiSelectListTitle         + "'," +
                      @"multiSelectNames:'"      + this._multiselectnames             + "'," +
                      @"multiSelectValues:'"     + this._multiselectvalues            + "'," +   
                      @"multiSelectLoad:"        + Util.netBoolToJSBool(_multiselectload) + ","  +   
                      @"multiSelectContextLabels:'"       + this._multiSelectContextLabels                         + "'," +
                      @"multiSelectDisplayContextLabels:" + Util.netBoolToJSBool(_multiSelectDisplayContextLabels) + "," +
                      @"multiSelectOnAdd:function(selObj){"    + this._multiSelectOnAdd    + "}," +
                      @"multiSelectOnRemove:function(selObj){" + this._multiSelectOnRemove + "}," + 
                      @"onSelect:function(event,ui){" + this._onSelect + "}," +

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
  }

}

