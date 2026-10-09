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
   * StepRecordsEditDeleteMulti */
  /**
   * StepSelect provides commonly used record selection functions
   * Note: This control has unsusual markup requirments for jQuery therefore
   * it has been put into its own class that inherits from control
   ****************************************************************************/

  public class StepRecordsEditDeleteMulti : StepRecordViewSelect
  {
    public StepRecordsEditDeleteMulti()
      : base("Select a Record",
             "The following list shows all records that you can delete/deactivate.  Some records may not be shown because they can no longer be changed.  Select one or more of the following records by clicking anywhere on it's row.  Unselect a record by clicking on the row again.  Once you have made your record selection click delete/deactivate.",
              RecordViewSelectPurpose.RECORD_EDIT_DELETE_MULTIPLE)
    {
    }

    protected  string  _editURL;
    protected  string  _deleteURL;
    protected  bool    _editIsSubPage = false;
    
    /*-------------------------------
     * Control properties
     *------------------------------*/
    
    //public string editURL         { get { return _editURL;       }  set { _editURL   = value; }}
    public string deleteURL       { get { return _deleteURL;     }  set { _deleteURL = MBA.HttpApplication.createLink(value, _dataPrivate); }}
    //public bool   editIsSubPage   { get { return _editIsSubPage; }  set { _editIsSubPage = value; }}


    protected override void render(ref HtmlTextWriter writer)
    {

      /*-------------------------------
       * Determine if edits will open
       * up a seperate window or use
       * the current window (default)
       *------------------------------*/

      if (_editIsSubPage)
        _editURL = MBA.HttpApplication.createLink(_editURL, _dataPrivate, new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));
      else
        _editURL = MBA.HttpApplication.createLink(_editURL, _dataPrivate);


      /*-------------------------------
       * Create preview
       *------------------------------*/

      base.render(ref writer);
      
      /*-------------------------------
       * Select/unselect all
       *------------------------------*/
      
      MBA.Button butSelAll = new MBA.Button();
      butSelAll.ID         = "butSelAll";
      butSelAll.icon       = "ui-icon-circle-plus";
      butSelAll.onclick    = "$.spedmonWebUI.recMultiSelectUnselectAll ('" + this._tblIDSel + @"',1);";
      butSelAll.Controls.Add(new MBA.RawText("Select All"));
      butSelAll.RenderControl(writer);

      MBA.Button butClearAll = new MBA.Button();
      butClearAll.ID         = "butClearAll";
      butClearAll.icon       = "ui-icon-circle-minus";
      butClearAll.onclick    = "$.spedmonWebUI.recMultiSelectUnselectAll ('" + this._tblIDSel + @"',0);";
      butClearAll.Controls.Add(new MBA.RawText("Clear All Selections"));
      butClearAll.RenderControl(writer);

      /*-------------------------------
       * Edit/Delete Options
       *------------------------------*/

      /*MBA.Button getEdt = new MBA.Button();
      getEdt.ID      = "getEdt";
      getEdt.icon    = "ui-icon-wrench";
      getEdt.onclick = "$.spedmonWebUI.recEditDeleteMulti('" + this._tblIDSel + @"','" + this._statusIDSel + @"'," + Constants.SAVE_TYPE_EDIT + "," + this._recIDPos + ",'" + this._editURL + "'," + Util.netBoolToJSBool(_editIsSubPage) + ", function(){})";
      getEdt.Controls.Add(new MBA.RawText("Review/Edit Selected Record"));
      getEdt.RenderControl(writer);
      */
      
      // Note: onClick ties into the isactive method for refreshing the database when delete is complete
      
      MBA.Button getDel = new MBA.Button();
      getDel.ID         = "getDel";
      getDel.icon       = "ui-icon-trash";
      getDel.onclick    = "$.spedmonWebUI.recEditDeleteMulti('" + this._tblIDSel + @"','" + this._statusIDSel + @"'," + Constants.SAVE_TYPE_DELETE + "," + this._recIDPos + ",'" + this._deleteURL + "', null, function(){" + _onactive + "})";
      getDel.Controls.Add(new MBA.RawText("Delete/Deactive Selected Record(s)"));
      getDel.RenderControl(writer);

      MBA.Button canSel = new MBA.Button();
      canSel.ID         = "canSel";
      canSel.icon       = "ui-icon-arrowreturnthick-1-w";
      canSel.onclick    = "$.spedmonWebUI.gotoMenuLink('homePageLink')";
      canSel.Controls.Add(new MBA.RawText("Cancel and Exit"));
      canSel.RenderControl(writer);
      
      
    }
  }
}

