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
   * SelectOrpServiceName */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectOrpServiceName:DataEntryRowSelectEntity
  {
    public DataEntryRowSelectOrpServiceName(): base()
	  {	     
      _selectTitle                        = "Service Name";
      _dataPrivate                        = true;
      _dataURL                            = "orp_documents_standard_selection_names.asmx/viewSelForGroupServiceClassNameID";
      _hasDataSource                      = false;
      _hasAddNew                          = true;
      _showAddNew                         = true;
      _hasEditSelected                    = false;
      _hasViewNotes                       = false;
      _dataSourceParameterName            = null;
      _preSelectedDataSource              = null;
      _saveDataSourceSelectedAsPreference = false;
      _nounPlural                         = "Services";
      _nounSingular                       = "Service";
      _addNewTitleText = @"Click here to request a new service name";
      _addNewHandler   = @"$.spedmonWebUI.openRequestNewOrpDocStdSvcNameForm()";
      
    }
    
    protected string _ctrlIdClientID = null;
    public string ctrlIdClientID { get {return _ctrlIdClientID; } set { _ctrlIdClientID = value;}}    

    protected string  _ctrlIdGroupServiceClassNameID             = null;
    public string   ctrlIdGroupServiceClassNameID               { get {return _ctrlIdGroupServiceClassNameID; } set {_ctrlIdGroupServiceClassNameID = value;}}

	  protected override void Render(HtmlTextWriter writer)
    {     	    
                           
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID))               _entityControlID                = @"orpdocstdnameselid";
      if (String.IsNullOrWhiteSpace(_ctrlIdGroupServiceClassNameID)) _ctrlIdGroupServiceClassNameID  = @"groupserviceclassnameid";
      if (String.IsNullOrWhiteSpace(_ctrlIdClientID)) _ctrlIdClientID = @"clientid";
      
      
      /* Add data parm control ids (datasource is handled by base class) */

      this._dataParameterControlIDs.Add (_ctrlIdClientID);
      this._dataParameterControlIDs.Add (_ctrlIdGroupServiceClassNameID);
       
                    	          
      base.Render(writer);
    }
  }
}
