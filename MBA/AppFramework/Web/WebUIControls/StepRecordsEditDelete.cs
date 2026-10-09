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
   * StepRecordsEditDelete */
  /**
   * StepSelect provides commonly used record selection functions
   * Note: This control has unsusual markup requirments for jQuery therefore
   * it has been put into its own class that inherits from control
   ****************************************************************************/

  public class StepRecordsEditDelete : StepRecordViewSelect
  {
    public StepRecordsEditDelete()
      : base("Select a Record",
             "The following list shows all records that you can review/edit or delete/deactivate.  Some records may not be shown because they can no longer be changed.  Select one of the following records by clicking anywhere on it's row then click review/edit or delete/deactivate.",
              RecordViewSelectPurpose.RECORD_EDIT_DELETE)
    {
    }

    protected  string   _editURL;
    protected  string   _deleteURL;
    protected  string   _undeleteURL;
    
    protected  string   _actionFnEdit        = "null";
    protected  string   _actionFnDelete      = "null";
    protected  string   _actionFnUndelete    = "null";
    protected  bool     _editIsSubPage       = false;
    protected  bool     _hasEdit             = true;
    protected  bool     _hasDelete           = true;
    protected  bool     _hasUndelete         = false;
    protected  string   _editButtonLabel     = @"Review/Edit Selected Record";
    protected  string   _deleteButtonLabel   = @"Delete/Deactivate Selected Record";
    protected  string   _unDeleteButtonLabel = @"Undelete/Reactivate Selected Record";

    /*-------------------------------
     * Control properties
     *------------------------------*/
    
    public string editURL             { get { return _editURL;          }  set { _editURL     = value;  } }
    public string deleteURL           { get { return _deleteURL;        }  set { _deleteURL   = value;  } }
    public string unDeleteURL         { get { return _undeleteURL;      }  set { _undeleteURL = value;  } } 
       
    public string actionFnEdit        { get { return _actionFnEdit;     } set { if (!Util.IsNullOrEmpty(value)) _actionFnEdit   = "function(recID, saveType, actionURL){" + value + "}"; else _actionFnEdit   = "null";}}
    public string actionFnDelete      { get { return _actionFnDelete;   } set { if (!Util.IsNullOrEmpty(value)) _actionFnDelete = "function(recID, saveType, actionURL){" + value + "}"; else _actionFnDelete = "null";}}    
    public string actionFnUnDelete    { get { return _actionFnUndelete; } set { if (!Util.IsNullOrEmpty(value)) _actionFnUndelete = "function(recID, saveType, actionURL){" + value + "}"; else _actionFnUndelete = "null";}} 

    public bool   editIsSubPage       { get { return _editIsSubPage;    } set { _editIsSubPage = value; }}
    
    public bool   hasEdit             { get { return _hasEdit;            } set { _hasEdit       = value; } }
    public bool   hasDelete           { get { return _hasDelete;          } set { _hasDelete     = value; } }
    public bool   hasUndelete         { get { return _hasUndelete;        } set { _hasUndelete   = value; } }
    
    public string editButtonLabel     { get {return _editButtonLabel;     } set {_editButtonLabel     = value; } }
    public string deleteButtonLabel   { get {return _deleteButtonLabel;   } set {_deleteButtonLabel   = value; } }
    public string unDeleteButtonLabel { get {return _unDeleteButtonLabel; } set {_unDeleteButtonLabel = value; } }
    
    // deleteIsSubPage

    protected override void render(ref HtmlTextWriter writer)
    {
     
      /*-------------------------------
       * Setup edit url and determine
       * if edits will open up a 
       * seperate window or use
       * the current window (default)
       *------------------------------*/

      if (_hasEdit)
      {
        if (_editIsSubPage)
          _editURL = MBA.HttpApplication.createLink(_editURL, _dataPrivate, new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));
        else
          _editURL = MBA.HttpApplication.createLink(_editURL, _dataPrivate);
      }
      
      /*-------------------------------
       * Setup delete url
       *------------------------------*/
      
      if (_hasDelete)
      {
        _deleteURL = MBA.HttpApplication.createLink(_deleteURL, _dataPrivate);
      }
      
      /*-------------------------------
       * Setup undelete url
       *------------------------------*/
      
      if (_hasUndelete)
      {
        _undeleteURL = MBA.HttpApplication.createLink(_undeleteURL, _dataPrivate);
      }
      
      /*-------------------------------
       * Create preview
       *------------------------------*/

      base.render(ref writer);

      /*-------------------------------
       * Edit/Delete/Undelete Options
       *------------------------------*/
      
      if (_hasEdit)
      {
        MBA.Button getEdt = new MBA.Button();
        getEdt.ID      = "getEdt";
        getEdt.icon    = "ui-icon-wrench";
        
        getEdt.onclick = "$.spedmonWebUI.recEditDelete('" + 
                                                          this._tblIDSel           + @"','"    + 
                                                          this._statusIDSel        + @"',"     + 
                                                          Constants.SAVE_TYPE_EDIT + @","      + 
                                                          this._recIDPos           + @",'"     + 
                                                          this._editURL            + @"',"     + 
                                              Util.netBoolToJSBool(_editIsSubPage) + @","      + 
                                              _actionFnEdit + ")";
        
        getEdt.Controls.Add(new MBA.RawText(_editButtonLabel));
        getEdt.RenderControl(writer);
      }
      
      if (_hasDelete)
      {
        MBA.Button getDel = new MBA.Button();
        getDel.ID         = "getDel";
        getDel.icon       = "ui-icon-trash";
        getDel.onclick    = "$.spedmonWebUI.recEditDelete('" + 
                                                             this._tblIDSel             + @"','" + 
                                                             this._statusIDSel          + @"',"  + 
                                                             Constants.SAVE_TYPE_DELETE + @","   + 
                                                             this._recIDPos             + @",'"  + 
                                                             this._deleteURL            + @"',"  +
                                                             "null"                     + @","   +  
                                                             _actionFnDelete + ")";
        getDel.Controls.Add(new MBA.RawText(_deleteButtonLabel));
        getDel.RenderControl(writer);
      }
      
      if (_hasUndelete)
      {
        MBA.Button getUnDel = new MBA.Button();
        getUnDel.ID         = "getUnDel";
        getUnDel.icon       = "ui-icon-cart";
        getUnDel.onclick    = "$.spedmonWebUI.recEditDelete('" + 
                                                             this._tblIDSel                 + @"','" + 
                                                             this._statusIDSel              + @"',"  + 
                                                             Constants.SAVE_TYPE_REACTIVATE + @","   + 
                                                             this._recIDPos                 + @",'"  + 
                                                             this._undeleteURL              + @"',"  +
                                                             "null"                         + @","   +  
                                                             _actionFnUndelete + ")";
        getUnDel.Controls.Add(new MBA.RawText(_unDeleteButtonLabel));
        getUnDel.RenderControl(writer);
      }

      if (this.rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE)
      {
        MBA.Button canSel = new MBA.Button();
        canSel.ID         = "canSel";
        canSel.icon       = "ui-icon-arrowreturnthick-1-w";
        canSel.onclick    = "$.spedmonWebUI.gotoMenuLink('homePageLink')";
        canSel.Controls.Add(new MBA.RawText("Cancel and Exit"));
        canSel.RenderControl(writer);
      }
      else
      {
        MBA.Button canSel = new MBA.Button();
        canSel.ID         = "canSel";
        canSel.icon       = "ui-icon-arrowreturnthick-1-w";
        canSel.onclick    = "window.close();";
        canSel.Controls.Add(new MBA.RawText("Cancel and Close"));
        canSel.RenderControl(writer);      
      }
    }
  }
}

