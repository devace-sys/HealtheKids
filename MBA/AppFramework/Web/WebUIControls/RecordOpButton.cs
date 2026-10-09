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
   * RecordOpButton */
  /**
   * Button
   * 
   * @param  icon            jquery ui icon (ui-icon-x)
   ****************************************************************************/

  public class RecordOpButton:Button 
  {        
    protected string _opUrl          = "";
    protected string _opFn           = "";
    protected bool   _dataPrivate    = true;    
    protected string _tblIDSel       = "";
    protected string _statusIDSel    = "";
    protected int    _recIDPos       = 0;    
    protected int    _saveType       = Constants.SAVE_TYPE_EDIT;
    protected bool   _opIsMulti      = false;
    protected string _fnTableRefresh = "";
    
    public string opUrl          { get { return _opUrl;          } set { _opUrl          = value; } }
    public string opFn           { get { return _opFn;           } set { _opFn           = value; } }    
    public bool   dataPrivate    { get { return _dataPrivate;    } set { _dataPrivate    = value; } }
    public string tblIDSel       { get { return _tblIDSel;       } set { _tblIDSel       = value; } }
    public string statusIDSel    { get { return _statusIDSel;    } set { _statusIDSel    = value; } }
    public int    recIDPos       { get { return _recIDPos;       } set { _recIDPos       = value; } }
    public bool   opIsMulti      { get { return _opIsMulti;      } set { _opIsMulti      = value; } }
    public string fnTableRefresh { get { return _fnTableRefresh; } set { _fnTableRefresh = value; } }
    
    public Constants.SAVE_TYPE  saveType { get { Constants.SAVE_TYPE st = (Constants.SAVE_TYPE) _saveType;  return st;  } set { Constants.SAVE_TYPE st = value; _saveType = (int) st; } }
    
    protected new string onclick     = "";
    protected new string cssInline   = "";
    
    protected override void Render(HtmlTextWriter writer)
    {
      if (Util.IsNullOrEmpty(this.icon))       this.icon = "ui-icon-bullet";
      if (!Util.IsNullOrEmpty(_opUrl))         _opUrl    = MBA.HttpApplication.createLink(_opUrl, _dataPrivate);                  
      if (Util.IsNullOrEmpty(_fnTableRefresh)) _fnTableRefresh = "function(){}";      
      
      base.cssInline = "margin:2px;";
      

      
      if (_opIsMulti == true)
      {
        _opFn        = "function (tblIDSel, statIDSel, recIDPos, $recs, $st, $oRows, recIDs, recIDsStr, recCnt, opURL, opType, fnTableRefresh, recIDFlagged){" + _opFn + "}";
        base.onclick = "$.spedmonWebUI.recOpMulti ('" +  this._tblIDSel           + @"','"    + 
                                                         this._statusIDSel        + @"',"     + 
                                                         this._recIDPos           + @",'"     + 
                                                         this._opUrl              + @"',"     +
                                                         this._saveType           + @","      +  
                                                         this._fnTableRefresh     + @","      + 
                                                         this._opFn + ")";
      }

      else
      {
        _opFn        = "function (tblIDSel, statIDSel, recIDPos, $recs, $st, $oRows, recID, rowIdx, opURL, opType){" + _opFn + "}";
        base.onclick = "$.spedmonWebUI.recOp('" +  this._tblIDSel           + @"','"    + 
                                                   this._statusIDSel        + @"',"     + 
                                                   this._recIDPos           + @",'"     + 
                                                   this._opUrl              + @"',"     +
                                                   this._saveType           + @","      +  
                                                   this._opFn + ")";
      }
      
      base.Render(writer);
    }
  }

}

