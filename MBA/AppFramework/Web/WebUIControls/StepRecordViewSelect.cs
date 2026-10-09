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

  public enum RecordViewSelectPurpose
  {
     RECORD_EDIT_DELETE
    ,RECORD_VIEW
    ,RECORD_REPORT
    ,RECORD_EDIT_DELETE_MULTIPLE
    ,RECORD_OP
    ,RECORD_OP_MULTIPLE
    ,RECORD_VIEW_WITH_RECORD_OP
    ,RECORD_VIEW_NO_PREVIEW
    ,RECORD_ADD_NEW_EDIT_DELETE_VIEW    
    ,RECORD_OPS_MULTI_WITH_SINGLE_REC_FLAG
  }

  /**************************************************************************
   * StepRecordViewSelect */
  /**
   * This is our base class for all steps that deal with the display and 
   * selection of records.
   ****************************************************************************/

  public abstract class StepRecordViewSelect : StepBase
  {
    public StepRecordViewSelect(string title, string instructions, RecordViewSelectPurpose purpose)
      : base()
    {
      _title                  = title;
      _instr                  = instructions;
      _optional               = false;
      _recSelect              = false;
      _editView               = false;
      _generateTable          = true;
      _generateDetail         = false;
      _generateDetailCallback = "";
      _generateDetailURL      = "";
      _recFlagSelected                = false;
      
      /*-------------------------------
       * Generic single record op
       *------------------------------*/

      if (purpose == RecordViewSelectPurpose.RECORD_OP)
      {
        _recSelect     = true;
        _recSelectMax  = 1;
        _editView      = true;
        _generateTable = true;
        _generateDetail   = false;
       _recFlagSelected           = false;
      }

      /*-------------------------------
       * Generic multi record op
       *------------------------------*/
    
      if (purpose == RecordViewSelectPurpose.RECORD_OP_MULTIPLE)
      {
        _recSelect      = true;
        _recSelectMax   = Rules.VIEW_TBL_PAGE_SIZE;
        _editView       = true;
        _generateTable  = true;
        _generateDetail = false;
        _recFlagSelected         = false;
      }    
      
      /*-------------------------------
       * If this is an edit/delete
       * view set the editview and
       * record selection flags to true
       *------------------------------*/

      if (purpose == RecordViewSelectPurpose.RECORD_EDIT_DELETE)
      {
        _recSelect       = true;
        _recSelectMax    = 1;
        _editView        = true;
        _generateTable   = true;
        _generateDetail  = false;
       _recFlagSelected          = false;
      }
      
      if (purpose == RecordViewSelectPurpose.RECORD_EDIT_DELETE_MULTIPLE)
      {
        _recSelect       = true;
        _recSelectMax    = Rules.VIEW_TBL_PAGE_SIZE;
        _editView        = true;
        _generateTable   = true;
        _generateDetail  = false;
       _recFlagSelected          = false;
      }

    
      /*-------------------------------
       * If this is a view
       *------------------------------*/

      if (purpose == RecordViewSelectPurpose.RECORD_VIEW)
      {
        _recSelect      = false;
        _recSelectMax   = 0;
        _editView       = false;
        _generateTable  = true;
        _generateDetail = false;
        _recFlagSelected           = false;
      }

      /*-------------------------------
       * If this is a view without
       * preview
       *------------------------------*/

      if (purpose == RecordViewSelectPurpose.RECORD_VIEW_NO_PREVIEW)
      {
        _recSelect      = false;
        _recSelectMax   = 0;
        _editView       = false;
        _generateTable  = false;
        _generateDetail = false;
        _recFlagSelected           = false;
      }

      /*-------------------------------
       * If this is a report     
       *------------------------------*/

      if (purpose == RecordViewSelectPurpose.RECORD_REPORT)
      {
        _recSelect          = false;
        _recSelectMax       = 0;
        _editView           = false;
        _generateTable      = false;
        _generateDetail     = false;
        _recFlagSelected           = false;
      }


      /*-------------------------------
       * If this is a view with record
       * select operations
       *------------------------------*/

      if (purpose == RecordViewSelectPurpose.RECORD_VIEW_WITH_RECORD_OP)
      {
        _recSelect      = true;
        _recSelectMax   = 1;
        _editView       = false;
        _generateTable  = true;
        _generateDetail = false;        
        _recFlagSelected           = false;
      }
      
      if (purpose == RecordViewSelectPurpose.RECORD_ADD_NEW_EDIT_DELETE_VIEW)
      {
        _recSelect       = true;
        _recSelectMax    = 1;
        _editView        = false;
        _generateTable   = true;
        _generateDetail  = false;      
        _recFlagSelected           = false;
      }
      
      if (purpose == RecordViewSelectPurpose.RECORD_OPS_MULTI_WITH_SINGLE_REC_FLAG)
      {
        _recSelect      = true;
        _recSelectMax   = Rules.VIEW_TBL_PAGE_SIZE;
        _editView       = true;
        _generateTable  = true;
        _generateDetail = false;
        _recFlagSelected        = true;
      }
    }

    protected bool   _generateTable;
    protected bool   _generateDetail;
    protected string _generateDetailCallback;
    protected string _generateDetailURL;
    protected string _recordDetailID;
    protected bool   _editView;
    protected string _frmID;
    protected string _opts;
    protected string _statusID;
    protected string _statusIDSel;
    protected string _tblID;
    protected string _tblIDSel;
    protected string _dataTableInitJsCmds = @"";
    protected string _dataTableInitJsFn   = @"";
    protected int    _reptnum      = 1;
    protected bool   _recSelect;
    protected int    _recSelectMax = 1;
    protected int    _recIDPos     = 0;
    protected bool   _recFlagSelected;
    /*-------------------------------
     * Control properties
     *------------------------------*/
   
    public int    reportNumber            { get { return _reptnum;   }     set { _reptnum      = value; }}
    public bool   recordSelection         { get { return _recSelect; }     set { _recSelect    = value; }}
    public int    recordSelectionMax      { get { return _recSelectMax; }  set { _recSelectMax = value; }}
    public int    recIDPos                { get { return _recIDPos;  }     set { _recIDPos     = value; }}
    public bool   generateDetail          { get { return _generateDetail;} set { _generateDetail = false;
                                                                              if (_generateTable) {
                                                                                if (_recSelect) {
                                                                                  if (_recSelectMax == 1) {                                                                                    
                                                                                    _generateDetail = value;}}} }}
    
    public string generateDetailCallback  { get { return _generateDetailCallback; } 
                                            set {_generateDetailCallback = value; }}
    
    public string generateDetailURL       { get { return _generateDetailURL; }
                                            set { _generateDetailURL = value; }}
                                            

    public bool   recordFlagSelected         { get { return _recFlagSelected; }     set { _recFlagSelected    = value; }}

    protected override void render(ref HtmlTextWriter writer)
    {
      /*-------------------------------
       * Report output parameters
       * 
       * Note: Edit View needs to be
       * either Y or ""
       *------------------------------*/

      writer.Write(@"<input id=""" + Constants.PARM_REP_FORM      + @""" name=""" + Constants.PARM_REP_FORM      + @""" type=""text"" value=""" + Constants.REPT_FORMAT_PREVIEW.ToString() + @""" style=""display:none""/>");
      writer.Write(@"<input id=""" + Constants.PARM_REP_NUMBER    + @""" name=""" + Constants.PARM_REP_NUMBER    + @""" type=""text"" value=""" + _reptnum + @""" style=""display:none""/>");

      writer.Write(@"<input id=""" + Constants.PARM_REP_PAGING    + @""" name=""" + Constants.PARM_REP_PAGING    + @""" type=""text"" value=""0"" style=""display:none""/>");
      writer.Write(@"<input id=""" + Constants.PARM_REP_COLS_ONLY + @""" name=""" + Constants.PARM_REP_COLS_ONLY + @""" type=""text"" value=""1"" style=""display:none""/>");
      writer.Write(@"<input id=""" + Constants.PARM_REP_EDIT_VIEW + @""" name=""" + Constants.PARM_REP_EDIT_VIEW + @""" type=""text"" value=""" + (_editView ? "1" : "") + @""" style=""display:none""/>");

      /*-------------------------------
       * Record preview/selection table
       *------------------------------*/

      _frmID          = @"'#" + this._form_id + @"'";
      _statusID       = @"validatelist";
      _statusIDSel    = @"#" + _statusID;
      _tblID          = @"recs";
      _tblIDSel       = @"#" + _tblID;
      _recordDetailID = "recorddetail";
      
      /*-------------------------------
       * Generate detail div
       *------------------------------*/
      
      if (!Util.IsNullOrEmpty(_generateDetailURL)) 
        _generateDetailURL = MBA.HttpApplication.createLink(_generateDetailURL, _dataPrivate);

      /*-------------------------------
       * Generate table
       *------------------------------*/

      if (_generateTable)
      {
        
        RecordPreview rp = new RecordPreview();
        rp.ID = "recordscont";
                
        /* If we are retrieving details for selected recs, make record preview container a column */
        
        if (_generateDetail) {
          
        }
        
        /* Remder record preview container */
        
        rp.RenderControl(writer);
        
        /* If we are generating details pass the retrieve details record op delegate parms to the data table constructor */
        
        string _fnRecSelected = "";
        
        if (_generateDetail)
        {
          _fnRecSelected = "$.spedmonWebUI.recOp('" +  _tblIDSel           + @"','"    + 
                                                       _statusIDSel        + @"',"     + 
                                                       _recIDPos           + @",'"     +
                                                       _generateDetailURL  + @"','"     +
                                                       _recordDetailID     + @"',"     +                                                
                                                       _generateDetailCallback + ")";
                                                   
        }
        
        // Note: _frmID already has single quotes.  TODO: Fix this

        _opts = @"{""fnRecordSelected"":function(){" + _fnRecSelected + @"},""iDisplayLength"":" + Rules.VIEW_TBL_PAGE_SIZE + @",""sFormID"":" + _frmID + @",""sTblID"":'" + _tblID + @"',""sStatusIDSel"":'" + _statusIDSel + @"',""bRecordSelect"":" + Util.netBoolToJSBool(_recSelect) + @",""iRecordSelectMax"":" + _recSelectMax + @",""bRecordFlagSelected"":" + Util.netBoolToJSBool(_recFlagSelected) + @"}";        
        
        /* Call data table constructor (client side) */
                
        _dataTableInitJsCmds = "$('#" + rp.ID + @"').spedmonDataTable(" + _opts + @")";        
        _dataTableInitJsFn   = @"function(){" + _dataTableInitJsCmds + @";}";
        _onactive = _onactive + ";" + _dataTableInitJsCmds;
        
        /* If we are generating details render the details container as a column*/

        if (_generateDetail) {          
          RecordDetail rd = new RecordDetail();
          rd.ID = _recordDetailID;
          rd.RenderControl(writer);
        }

      /*-------------------------------
       * Status control
       *------------------------------*/

      MBA.DetailList dl = new MBA.DetailList();
      dl.ID = "validatelist";

      /* If we are generating details make sure we fix the float */

      if (_generateDetail) { 
        dl.cssClass  = @" ui-widget ui-widget-content ui-corner-all ";
        dl.cssInline = @"clear:both;";
      }
      
      dl.RenderControl(writer);

      }
    }
  }
}