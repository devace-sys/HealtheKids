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
   * DataEntryRowSelectBatch */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectBatch:DataEntryRowSelectEntity
  {
    public DataEntryRowSelectBatch(): base()
	  {	     
      _selectTitle                        = "Batch Name";
      _dataPrivate                        = true;
      _dataURL                            = "input_batches_in_process.asmx/viewSel";
      _hasDataSource                      = false;
      _hasAddNew                          = false;
      _hasEditSelected                    = false;
      _hasViewNotes                       = false;
      _dataSourceParameterName            = null;
      _preSelectedDataSource              = null;
      _saveDataSourceSelectedAsPreference = false;
      _nounPlural                         = "Batch Names";
      _nounSingular                       = "Batch Name";
      
      _entryAllowedFn                     = null;

      _entryNotAllowedReplacementValueFn  = null;

    }
    
    protected string  _ctrlIdClientID     = null;
    public string     ctrlIdClientID      { get {return _ctrlIdClientID; } set {_ctrlIdClientID = value;}}

	  protected override void Render(HtmlTextWriter writer)
    {     	    
                           
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID))  _entityControlID  = Constants.PARM_BATCH_ID;
      if (String.IsNullOrWhiteSpace(_ctrlIdClientID))   _ctrlIdClientID   = Constants.PARM_CLIENT_ID;

      /* Add data parm control ids (datasource is handled by base class) */

      this._dataParameterControlIDs.Add (_ctrlIdClientID);

      base.Render(writer);
    }
  }
}
