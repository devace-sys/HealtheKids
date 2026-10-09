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
   * DataEntryRowSelectPractitionerDisciplineGroup */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectPractitionerDisciplineGroup:DataEntryRowSelectEntity
  {
    public DataEntryRowSelectPractitionerDisciplineGroup(): base()
	  {	     
      _selectTitle                        = "Name";
      _dataPrivate                        = true;
      _dataURL                            = "groups.asmx/viewSelDisp";
      _hasDataSource                      = false;
      _hasAddNew                          = false;
      _hasEditSelected                    = false;
      _hasViewNotes                       = false;
      _dataSourceParameterName            = null;
      _preSelectedDataSource              = null;
      _saveDataSourceSelectedAsPreference = false;
      _nounPlural                         = "Allied Discipline Groups";
      _nounSingular                       = "Allied Discipline Group";
    
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
        _selectValue = rd.wu.pr.groupID.ToString();
        _selectName  = rd.wu.pr.groupName;
        return true;
      };      
    }
    

	  protected override void Render(HtmlTextWriter writer)
    {     	    
                           
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID)) _entityControlID = Constants.PARM_GROUP_ID;
                                      	         
      base.Render(writer);
    }
  }
}
