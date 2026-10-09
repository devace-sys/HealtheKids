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
   * DataEntryRowSelectClient */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectClient:DataEntryRowSelectEntity
  {
    public DataEntryRowSelectClient(): base()
	  {	     
      _selectTitle                        = "Name";
      _dataPrivate                        = true;
      _dataURL                            = "clients.asmx/viewSel";
      _hasDataSource                      = false;
      _hasAddNew                          = false;
      _hasEditSelected                    = false;
      _hasViewNotes                       = true;
      _dataSourceParameterName            = null;
      _preSelectedDataSource              = null;
      _saveDataSourceSelectedAsPreference = false;
      _nounPlural                         = "Clients";
      _nounSingular                       = "Client";
      
      _entryAllowedFn = delegate (ref RequestResponse rd) {

        if (rd.wu.usr.userGroupID == Constants.USER_GROUP_SBSC)         return true;
        if (rd.wu.usr.userGroupID == Constants.USER_GROUP_PCAL_HYQUEUE) return true;

        return false;
      };
          
      _entryNotAllowedReplacementValueFn = delegate (ref RequestResponse rd) {                
        if (rd.wu.usr.userGroupID == Constants.USER_GROUP_CLIENT) {
          
          if (_applyCybhiConsortiumLeadException == true) {
            
            if (!String.IsNullOrWhiteSpace (selectValue)) {                                            
              _selectValue = Validate.reqClientID (uInfo, selectValue, false, true).ToString(); /* Note: Using cybhi consortium lead option */             
            }
            else {
              _selectValue = rd.wu.usr.clientID.ToString();
              _selectName  = rd.wu.usr.clientName;
            }
          } 
          else {
            _selectValue = rd.wu.usr.clientID.ToString();
            _selectName = rd.wu.usr.clientName;
          }
        }
        
        return true;
      };

      _hasSaveSelectionAsDefault = true;

    }
    

	protected override void Render(HtmlTextWriter writer)
    {     	    
                           
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID))              _entityControlID              = Constants.PARM_CLIENT_ID;
      if (String.IsNullOrWhiteSpace(_entityIDToUseWithManageFiles)) _entityIDToUseWithManageFiles = Constants.PARM_CLIENT_ID;
                          
      /* URL for view notes */
      
      this._viewNotesBaseUrl = MBA.HttpApplication.createLink(@"clients.asmx/viewEntity",true);
      
      /* Handler for view notes */
   
      this._viewNotesHandler = "var _viewNotesBaseUrl = '" + this._viewNotesBaseUrl + "';"
                             + "var _ecid  = $('#" + _entityControlID + "').val();"
                             + "var _data = '{clientid:' + _ecid + '}';"
                             + "$.spedmonWebUI.ajax(null, _viewNotesBaseUrl, _data, null, null, function(rd){name = 'Client notes for ' + rd.data.entity.name; notes = rd.data.entity.notes;}, null, null, 0, function(){$.spedmonWebUI.dialogMessage(name,$.spedmonWebUI.formattedTextToHTML(notes,'ui-spedmon-dialog-mono-txt'),true,800,400)});";
      base.Render(writer);
    }
  }
}
