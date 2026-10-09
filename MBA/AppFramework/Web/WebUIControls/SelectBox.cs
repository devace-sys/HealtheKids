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
   * SelectBox */
  /**
   * ComboBox
   ****************************************************************************/

  public class SelectBox : SelectBoxBase 
  {
    public SelectBox ()                          : base()            { }
    public SelectBox (string name, string value) : base(name, value) { }

    protected string _dataURL;
    protected string _dataParms;
    protected string _dataParmsType;
    protected string _onSelect;
    
    protected int  _delay;
    protected bool _dataPrivate = true;
    protected bool _selectAll = true;
    protected SelectType _selectType = SelectType.COMBO_BOX ;
    
    public bool   dataPrivate    { get { return _dataPrivate; }   set { _dataPrivate = value; } }
    public string dataParmsType  { get { return _dataParmsType; } set { _dataParmsType = value; } }
    public string dataParms      { get { return _dataParms; }     set { _dataParms = value; } }
    public bool   selectAll      { get { return _selectAll; }     set { _selectAll = value; } }
    public string onSelect       { get { return _onSelect; }      set { _onSelect = value; } }
    public string dataURL        { get { return _dataURL; }       set { _dataURL = MBA.HttpApplication.createLink(value, _dataPrivate); } }
    public int    delay          { get { return _delay; }         set {_delay = value;}}
    public SelectType selectType { get { return _selectType;}     set {_selectType = value;}}
    
    protected override void Render(HtmlTextWriter writer)
    {
      if (Util.IsNullOrEmpty(_onSelect))      _onSelect = "";
      if (Util.IsNullOrEmpty(_dataParmsType)) _dataParmsType = Constants.DATA_PARM_TYPE_DOM;
      if (_delay <= 0) _delay = 600;

      if (!Util.IsNullOrEmpty(this._dataURL))
      {
        if (Util.IsNullOrEmpty(this._dataParms)) this._dataParms = "{}";
        string prms = @"{" +
                      @"dataParmType:'"   + this._dataParmsType                  + "'," +
                      @"selectAll:"       + this._selectAll.ToString().ToLower() + ","  +
                      @"delay:"           + this._delay.ToString()               + ","  +
                      @"singleSelectName:'"      + this._selectName              + @"'," +
                      @"singleSelectValue:'"     + this.value                    + @"'," +
                      @"selectType:"      + ((int) this._selectType).ToString()  + ","   +
                      @"onSelect:function(event,ui){" + this._onSelect           + "},"  +
                      @"ajaxopts:{url:""" + this._dataURL + @"""," +
                      @"data:"            + this._dataParms +          
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

