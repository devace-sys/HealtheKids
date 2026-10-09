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
   * DataEntryRowSelectServiceName */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectServiceName:DataEntryRowSelectEntity
  {
    public DataEntryRowSelectServiceName(): base()
	{	     
      _selectTitle                        = "Service";
      _dataPrivate                        = true;
      _dataURL                            = "services.asmx/viewSelForPlanTypeGroupID";
      _hasDataSource                      = false;
      _hasAddNew                          = false;
      _hasEditSelected                    = false;
      _hasViewNotes                       = false;
      _dataSourceParameterName            = null;
      _preSelectedDataSource              = null;
      _saveDataSourceSelectedAsPreference = false;
      _nounPlural                         = "Services";
      _nounSingular                       = "Service";
    }
        
    protected string  _ctrlIdPlan                    = null;
    protected string  _ctrlIdGrpID                   = null;    

    /* For referencing external controls */

    public string   ctrlIdPlan            { get { return _ctrlIdPlan; }            set { _ctrlIdPlan = value; } }
    public string   ctrlIdGrpID           { get { return _ctrlIdGrpID; }           set { _ctrlIdGrpID = value; } }
    
	protected override void Render(HtmlTextWriter writer)
    {     	    
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID))    _entityControlID    = Constants.PARM_NAME_ID;
	  if (String.IsNullOrWhiteSpace(_ctrlIdPlan))         _ctrlIdPlan         = Constants.PARM_PLAN_TYPE;
      if (String.IsNullOrWhiteSpace(_ctrlIdGrpID))        _ctrlIdGrpID        = Constants.PARM_GROUP_ID;
      
      /* Add data parm control ids */

      this._dataParameterControlIDs.Add (_ctrlIdPlan);
      this._dataParameterControlIDs.Add (_ctrlIdGrpID);

      base.Render(writer);
    
    }
  }
}
