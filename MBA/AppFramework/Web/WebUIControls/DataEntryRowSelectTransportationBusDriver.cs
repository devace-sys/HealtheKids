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
   * DataEntryRowSelectTransportationBusDriver */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectTransportationBusDriver:DataEntryRowSelectEntity
  {
    public DataEntryRowSelectTransportationBusDriver(): base()
	  {	     
      _selectTitle                        = "Bus Driver";
      _dataPrivate                        = true;
      _dataURL                            = "transportation_mgmt_bus_drivers.asmx/viewSel";
      _hasDataSource                      = false;
      _hasAddNew                          = false;
      _hasEditSelected                    = false;
      _hasViewNotes                       = false;
      _dataSourceParameterName            = null;
      _preSelectedDataSource              = null;
      _saveDataSourceSelectedAsPreference = false;
      _nounPlural                         = "Bus Drivers";
      _nounSingular                       = "Bus Driver";
      
      _entryAllowedFn                     = null;

      _entryNotAllowedReplacementValueFn  = null;

    }

    protected string  _ctrlIdClientID     = null;
    public string     ctrlIdClientID      { get {return _ctrlIdClientID; } set {_ctrlIdClientID = value;}}
    
	  protected override void Render(HtmlTextWriter writer)
    {     	    
                           
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID))              _entityControlID              = Constants.PARM_TRANS_BUS_DRIVER_ID;
      if (String.IsNullOrWhiteSpace(_entityIDToUseWithManageFiles)) _entityIDToUseWithManageFiles = Constants.PARM_TRANS_BUS_DRIVER_ID;
      if (String.IsNullOrWhiteSpace(_ctrlIdClientID))               _ctrlIdClientID               = Constants.PARM_CLIENT_ID;
         
      /* Add data parm control ids (datasource is handled by base class) */

      this._dataParameterControlIDs.Add (_ctrlIdClientID);

      base.Render(writer);
    }
  }
}
