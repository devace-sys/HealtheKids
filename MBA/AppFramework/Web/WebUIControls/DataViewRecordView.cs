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
   * DataViewRecordsView */
  /**
   *
   ***************************************************************************/

  public class DataViewRecordsView : WebUIControl
  {
    public DataViewRecordsView() : base("div", false) { }
    
    protected  string   _dataViewRequestFormCtrlID = @"";
    protected  string   _onSelect                 = @"";	
	  protected  int      _recIDPos                 = 2; /* Assuming return datatable. Position 2 is record id */
    protected  string   _sScrollX    = @"100%";
    protected  string   _sScrollY    = @"100%";
    protected  bool     _bJQueryUI   = false;

    public string dataViewRequestFormCtrlID { get { return _dataViewRequestFormCtrlID; }  set { _dataViewRequestFormCtrlID = value; } }
    public string onSelect                  { get { return _onSelect;}                    set { _onSelect = value; } }
    public int    recIDPos                  { get { return _recIDPos;  }                  set { _recIDPos = value; } }
    public string sScrollX                  { get { return _sScrollX;  }                  set { _sScrollX = value; } }
    public string sScrollY                  { get { return _sScrollY;  }                  set { _sScrollY = value; } }
    public bool   bJQueryUI                 { get { return _bJQueryUI;  }                  set { _bJQueryUI = value; } }
    
    protected override void Render(HtmlTextWriter writer)
    {
      	                            
      string _ctrlOpts = @"{"
        +        @"""dataViewRequestFormCtrlID"":"""          + _dataViewRequestFormCtrlID + @""""
        + @"," + @"""recIDPos"":"""       + _recIDPos.ToString()       + @""""
        + @"," + @"""iDisplayLength"":""" + Rules.VIEW_TBL_PAGE_SIZE.ToString() + @""""
        + @"," + @"""sScrollX"":"""       + _sScrollX       + @""""
        + @"," + @"""sScrollY"":"""       + _sScrollY       + @""""
        + @"," + @"""bJQueryUI"":"       + Util.netBoolToJSBool(_bJQueryUI)        
        + @"," + @"""onSelect"":function(oSelRowData){" + _onSelect + @"}"
        + @"}";        

      base.Render(writer);
      
      
      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"$(function() {");
      writer.Write("$('#" + this.ID + @"').spedmonDataViewRecordsView (" + _ctrlOpts + @")");
      writer.Write(@"});");
      writer.Write(@"</script>");

     }
    
 }

}

