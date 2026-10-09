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

  /***************************************************************************
   * DataViewRequestForm */
  /**
   *
   ***************************************************************************/

  public class DataViewRequestForm : WebUIControl
  {
    public DataViewRequestForm() : base("form", false) { }
    
    protected bool    _dataPrivate = true;
    protected string  _dataURL     = @"";
    protected int     _reptnum     = 1;
    protected bool    _editView    = false;
    protected string  _dataViewRecordsViewCtrlID = @"";
    protected string  _onSpedmonInputData = @"";

	  public int    reportNumber    { get { return _reptnum;   }     set { _reptnum      = value; }}
    public bool   editView        { get { return _editView;}       set { _editView = value;}}
    public bool   dataPrivate    { get { return _dataPrivate; }   set { _dataPrivate = value; } }
    public string dataURL        { get { return _dataURL; }       set { _dataURL     = value; } }
    public string dataViewRecordsViewCtrlID { get { return _dataViewRecordsViewCtrlID; }  set { _dataViewRecordsViewCtrlID = value; } }
	                
	 public string onSpedmonInputData { get { return _onSpedmonInputData;} set {_onSpedmonInputData = value;}}
    
    protected override void Render(HtmlTextWriter writer)
    {
      
    
      string _action = HttpApplication.createLink(_dataURL, _dataPrivate);

      this.addAttribute("method", "post", ATTR_HTML_TAG);
      this.addAttribute("action", _action, ATTR_HTML_TAG);     
      
      this.addChildControl(new RawHTML(@"<input id=""" + this.ID + @"-" + Constants.PARM_REP_FORM      + @""" name=""" + Constants.PARM_REP_FORM      + @""" type=""hidden"" value=""" + Constants.REPT_FORMAT_PREVIEW.ToString() + @"""/>"));
      this.addChildControl(new RawHTML(@"<input id=""" + this.ID + @"-" + Constants.PARM_REP_NUMBER    + @""" name=""" + Constants.PARM_REP_NUMBER    + @""" type=""hidden"" value=""" + _reptnum + @"""/>"));
      this.addChildControl(new RawHTML(@"<input id=""" + this.ID + @"-" + Constants.PARM_REP_PAGING    + @""" name=""" + Constants.PARM_REP_PAGING    + @""" type=""hidden"" value=""1""/>"));
      this.addChildControl(new RawHTML(@"<input id=""" + this.ID + @"-" + Constants.PARM_REP_COLS_ONLY + @""" name=""" + Constants.PARM_REP_COLS_ONLY + @""" type=""hidden"" value=""1""/>"));
      this.addChildControl(new RawHTML(@"<input id=""" + this.ID + @"-" + Constants.PARM_REP_EDIT_VIEW + @""" name=""" + Constants.PARM_REP_EDIT_VIEW + @""" type=""hidden"" value=""" + (_editView ? "1" : "") + @"""/>"));
                                 
      base.Render(writer);      
	  
	    string _ctrlOpts = @"{"
        + @"""dataViewRecordsViewCtrlID"":""" + _dataViewRecordsViewCtrlID + @""""
        + @",""onSpedmonInputData"":function(e){" + _onSpedmonInputData + @"}"
        + @"}";        
    
      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"$(function() {");
      writer.Write("$('#" + this.ID + @"').spedmonDataViewRequestForm (" + _ctrlOpts + @")");
      writer.Write(@"});");
      writer.Write(@"</script>");
    
     }
    
 }

}

