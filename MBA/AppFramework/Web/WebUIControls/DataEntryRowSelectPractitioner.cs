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
   * SelectPractitioner */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectPractitioner : DataEntryRowSelectPerson
    {
    public DataEntryRowSelectPractitioner(): base()
	  {	     
      _selectTitle                        = "Last Name, First Name";
      _dataPrivate                        = true;
      _dataURL                            = "practitioners.asmx/viewSel2";
      _hasDataSource                      = true;
      _hasAddNew                          = true;
      _hasEditSelected                    = true;
      _hasViewNotes                       = true;
      _hasManageFiles                     = true;
      _dataSourceParameterName            = Constants.PARM_PRAC_DATA_SOURCE;
      _preSelectedDataSource              = PractitionerDataSource.ALL_PRACTITIONERS;
      _saveDataSourceSelectedAsPreference = true;
      _nounPlural                         = "Practitioners";
      _nounSingular                       = "Practitioner";


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
        _selectValue = rd.wu.pr.id.ToString();
        _selectName  = rd.wu.pr.name;
        return true;
      };      

    
    }
    
    protected string  _ctrlIdClientID             = null;
    protected string  _ctrlIdPatID                = null;
    protected string  _ctrlIdDos                  = null;
    protected string  _ctrlIdGroupSvcClassNameID  = null;
    public string   ctrlIdClientID                         { get {return _ctrlIdClientID; } set {_ctrlIdClientID = value;}}
    public string   ctrlIdPatID                            { get { return _ctrlIdPatID; } set {_ctrlIdPatID   = value;}}
    public string   ctrlIdDos                              { get { return _ctrlIdDos; }                 set {_ctrlIdDos   = value;}}
    public string   ctrlIdGroupSvcClassNameID              { get { return _ctrlIdGroupSvcClassNameID; } set { _ctrlIdGroupSvcClassNameID   = value;}}
    public PractitionerDataSource preSelectedDataSource    { get { return (PractitionerDataSource)_preSelectedDataSource;} set {_preSelectedDataSource = value;}}

	  protected override void Render(HtmlTextWriter writer)
    {     	    
                           
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID))              _entityControlID              = Constants.PARM_PRACTITIONER_ID;
      if (String.IsNullOrWhiteSpace(_entityIDToUseWithManageFiles)) _entityIDToUseWithManageFiles = Constants.PARM_PRACTITIONER_ID;
      if (String.IsNullOrWhiteSpace(_ctrlIdClientID))               _ctrlIdClientID               = Constants.PARM_CLIENT_ID;
      if (String.IsNullOrWhiteSpace(_ctrlIdPatID))                  _ctrlIdPatID                  = Constants.PARM_PATIENT_ID;
      if (String.IsNullOrWhiteSpace(_ctrlIdDos))                    _ctrlIdDos                    = Constants.PARM_DOS;
      if (String.IsNullOrWhiteSpace(_ctrlIdGroupSvcClassNameID ))   _ctrlIdGroupSvcClassNameID    = Constants.PARM_GRP_SVC_CLS_NME_ID; // @"groupserviceclassnameid";
      
      /* Add data parm control ids (datasource is handled by base class) */

      this._dataParameterControlIDs.Add (_ctrlIdClientID);
      this._dataParameterControlIDs.Add (_ctrlIdPatID);
      this._dataParameterControlIDs.Add (_ctrlIdDos);      
      this._dataParameterControlIDs.Add (_ctrlIdGroupSvcClassNameID);                                
       
      /* Add datasources */
            
      this._dataSources.Add(PractitionerDataSource.ALL_PRACTITIONERS);
      this._dataSources.Add(PractitionerDataSource.INACTIVE_PRACTITIONERS);               
      
      /* URL for add new/edit */

      this._saveBaseUrlByRole = MBA.Practitioner.getSaveUrlForUserGroupUserRole(this._userGroup, this._userRole); 
      
      /* URL for view notes */
      
      this._viewNotesBaseUrl = MBA.HttpApplication.createLink(@"practitioners.asmx/viewEntity",true);
      
      /* Handler for view notes */

      this._viewNotesHandler = "var _viewNotesBaseUrl = '" + this._viewNotesBaseUrl + "';"
                             + "var _clid = $('#" + _ctrlIdClientID + "').val();"
                             + "var _ecid  = $('#" + _entityControlID + "').val();"
                             + "var _data = '{clientid:'+ _clid + ',pracid:' + _ecid + '}';"
                             + "$.spedmonWebUI.ajax(null, _viewNotesBaseUrl, _data, null, null, function(rd){name = 'Practitioner notes for ' + rd.data.entity.name; notes = rd.data.entity.notes;}, null, null, 0, function(){$.spedmonWebUI.dialogMessage(name,$.spedmonWebUI.formattedTextToHTML(notes,'ui-spedmon-dialog-mono-txt'),true,800,400)});";
      base.Render(writer);
    

    }
  }
}
