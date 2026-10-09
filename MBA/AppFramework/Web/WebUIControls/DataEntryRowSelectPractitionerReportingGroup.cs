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
   * DataEntryRowSelectPractitionerReportingGroup */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectPractitionerReportingGroup:DataEntryRowSelectEntity
  {
    public DataEntryRowSelectPractitionerReportingGroup(): base()
	  {	     
      _selectTitle                        = "Name";
      _dataPrivate                        = true;
      _dataURL                            = "groups.asmx/viewSelRept";
      _hasDataSource                      = false;
      _hasAddNew                          = false;
      _hasEditSelected                    = false;
      _hasViewNotes                       = false;
      _dataSourceParameterName            = null;
      _preSelectedDataSource              = null;
      _saveDataSourceSelectedAsPreference = false;
      _nounPlural                         = "Reporting Groups";
      _nounSingular                       = "Reporting Group";
    
      _entryAllowedFn = delegate (ref RequestResponse rd) {
        if (rd.wu.usr.userGroupID == Constants.USER_GROUP_CLIENT) 
        {
          if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID)
          {
            return false;
          }
        }
        return true;        
      };
          
      _entryNotAllowedReplacementValueFn = delegate (ref RequestResponse rd) {
        _selectValue = rd.wu.pr.groupIDRept.ToString();
        _selectName  = rd.wu.pr.groupNameRept;
        return true;
      };      
    }
      protected string  _ctrlIdClientID             = null;

      public string   ctrlIdClientID                         { get {return _ctrlIdClientID; } set {_ctrlIdClientID = value;}}

	  protected override void Render(HtmlTextWriter writer)
    {     	    
                           
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID)) _entityControlID = Constants.PARM_RPT_GROUP_ID;
      if (String.IsNullOrWhiteSpace(_ctrlIdClientID))  _ctrlIdClientID  = Constants.PARM_CLIENT_ID;

      /* Add data parm control ids */

      this._dataParameterControlIDs.Add (_ctrlIdClientID);
                                    	         
      base.Render(writer);
    }
  }
}
