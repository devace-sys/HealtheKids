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
   * DataEntryRowSelectRoute */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectRoute:DataEntryRowSelectEntity
  {
    public DataEntryRowSelectRoute(): base()
	  {	     
      _selectTitle                        = "Route";
      _dataPrivate                        = true;
      _dataURL                            = "transport_mgmt_auth_routes.asmx/viewSel";
      _hasDataSource                      = false;
      _hasAddNew                          = false;
      _hasEditSelected                    = false;
      _hasViewNotes                       = false;
      _dataSourceParameterName            = null;
      _preSelectedDataSource              = null;
      _saveDataSourceSelectedAsPreference = false;
      _nounPlural                         = "Routes";
      _nounSingular                       = "Route";
      
      _entryAllowedFn                     = null;

      _entryNotAllowedReplacementValueFn  = null;

    }

    protected string  _ctrlIdClientID     = null;
    protected string  _ctrlIdTransmgmtID  = null;
    public string     ctrlIdClientID      { get {return _ctrlIdClientID;    } set {_ctrlIdClientID = value;}}
    public string     ctrlIdTransmgmtID   { get {return _ctrlIdTransmgmtID; } set { _ctrlIdTransmgmtID = value;}}
    
	  protected override void Render(HtmlTextWriter writer)
    {     	    
                           
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID))              _entityControlID              = Constants.PARM_ROUTE_ID;
      if (String.IsNullOrWhiteSpace(_entityIDToUseWithManageFiles)) _entityIDToUseWithManageFiles = Constants.PARM_ROUTE_ID;
      if (String.IsNullOrWhiteSpace(_ctrlIdClientID))               _ctrlIdClientID               = Constants.PARM_CLIENT_ID;
      if (String.IsNullOrWhiteSpace(_ctrlIdTransmgmtID))            _ctrlIdTransmgmtID            = Constants.PARM_TRANS_MGMT_ID;
         
      /* Add data parm control ids (datasource is handled by base class) */

      this._dataParameterControlIDs.Add (_ctrlIdClientID);
      this._dataParameterControlIDs.Add (_ctrlIdTransmgmtID);

      base.Render(writer);
    }
  }
}
