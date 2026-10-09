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
   * DataEntryRowSaveOrEditValidateThenSaveDialog */
  /**
   * Custom dialog for use in DataEntryRowSaveOrEdit
   * 
   * Creates the required markup for the dialog control.
   ***************************************************************************/

  public class DataEntryRowSaveOrEditValidateThenSaveDialog : ControlBase
  {
    public DataEntryRowSaveOrEditValidateThenSaveDialog() : base() { }
    
    protected int _saveType  = Constants.SAVE_TYPE_NEW;
    public int    saveType { get { return _saveType; }  set { _saveType = value; }}
    public string title    { get; set;}

    protected override void Render(HtmlTextWriter writer)
    {

      if (String.IsNullOrWhiteSpace(title)) title = @"Please Review Any Messages";

      writer.Write(@"<div id=""{0}"" class=""ui-spedmon-dialog ui-spedmon-data-entry-row-dialog"" title=""{1}"">", Constants.CTRL_DIAG_SAVE_NEW_OR_EDIT, title);
	 
      writer.Write(@"<div id=""{0}"" class=""ui-spedmon-data-entry-row-dialog-instructions""></div>", Constants.CTRL_DIAG_SAVE_NEW_OR_EDIT_INSTRUCTIONS);
	    
      var status = new MBA.DetailList();
      status.ID  = Constants.PARM_VALIDATE_LIST;
      status.RenderControl(writer);	                
      
      writer.Write(@"</div>");

      /* Initially hide */

      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"$(function() {");
      writer.Write(@"$('#" + Constants.CTRL_DIAG_SAVE_NEW_OR_EDIT + @"').hide();");
      writer.Write(@"});");
      writer.Write(@"</script>");

      base.Render(writer);
    }

  }
}

