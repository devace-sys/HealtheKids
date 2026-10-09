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
   * SelectPatient */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectPatient: DataEntryRowSelectPerson
    {
    public DataEntryRowSelectPatient(): base()
	  {	     
      _selectTitle                        = "Last Name, First Name, DOB";
      _dataPrivate                        = true;
      _dataURL                            = "patients.asmx/viewSel2";
      _hasDataSource                      = true;
      _hasAddNew                          = true;
      _hasEditSelected                    = true;
      _hasViewNotes                       = true;
      _dataSourceParameterName            = "patdatasource";
      _preSelectedDataSource              = PatientDataSource.ALL_PATIENTS;
      _saveDataSourceSelectedAsPreference = true;
      _nounPlural                         = "Patients";
      _nounSingular                       = "Patient";
      
    }
    
    protected string  _ctrlIdClientID             = null;
    protected string  _ctrlIdPracID               = null;
    protected string  _ctrlIdDos                  = null;
    protected string  _ctrlIdSiteID               = null;
    
    public string   ctrlIdClientID                         { get {return _ctrlIdClientID; } set {_ctrlIdClientID = value;}}
    public string   ctrlIdPracID                           { get { return _ctrlIdPracID; }  set {_ctrlIdPracID   = value;}}
    public string   ctrlIdDos                              { get { return _ctrlIdDos; }     set {_ctrlIdDos   = value;}}
    public string   ctrlIdSiteID                           { get { return _ctrlIdSiteID; }  set {_ctrlIdSiteID   = value;}}
    public PatientDataSource preSelectedDataSource    { get { return (PatientDataSource)_preSelectedDataSource;} set {_preSelectedDataSource = value;}}

	protected override void Render(HtmlTextWriter writer)
    {     	    
                           
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID))              _entityControlID                = @"patid";
      if (String.IsNullOrWhiteSpace(_entityIDToUseWithManageFiles)) _entityIDToUseWithManageFiles   = @"patid";
      if (String.IsNullOrWhiteSpace(_ctrlIdClientID))               _ctrlIdClientID                 = @"clientid";
      if (String.IsNullOrWhiteSpace(_ctrlIdPracID))                 _ctrlIdPracID                   = @"pracid";
      if (String.IsNullOrWhiteSpace(_ctrlIdDos))                    _ctrlIdDos                      = @"dos";
      if (String.IsNullOrWhiteSpace(_ctrlIdSiteID))                 _ctrlIdSiteID                   = Constants.PARM_SITE_ID;
            
      /* Add data parm control ids (datasource is handled by base class) */

      this._dataParameterControlIDs.Add (_ctrlIdClientID);
      this._dataParameterControlIDs.Add (_ctrlIdPracID);
      this._dataParameterControlIDs.Add (_ctrlIdDos);      
      this._dataParameterControlIDs.Add (_ctrlIdSiteID);
       
      /* Add datasources */
            
      this._dataSources.Add(PatientDataSource.ALL_PATIENTS);
      this._dataSources.Add(PatientDataSource.CASE_LOAD);
      this._dataSources.Add(PatientDataSource.INACTIVE_PATIENTS);
     
      /* URL for add new/edit */

      if      (_userGroup == Constants.USER_GROUP_SBSC)   this._saveBaseUrlByRole = "user_all_pat_save_2.aspx";
      else if (_userGroup == Constants.USER_GROUP_CLIENT) this._saveBaseUrlByRole = "user_all_pat_save_2.aspx";
      else                                               this._saveBaseUrlByRole  = "";
      
      /* URL for view notes */
      
      this._viewNotesBaseUrl = MBA.HttpApplication.createLink(@"patients.asmx/viewEntity",true);

      this._viewNotesHandler = "var _viewNotesBaseUrl = '" + this._viewNotesBaseUrl + "';"
                             + "var _clid = $('#" + _ctrlIdClientID + "').val();"
                             + "var _ecid  = $('#" + _entityControlID + "').val();"
                             + "var _data = '{clientid:'+ _clid + ',patid:' + _ecid + '}';"
                             + "$.spedmonWebUI.ajax(null, _viewNotesBaseUrl, _data, null, null, function(rd){name = 'Patient notes for ' + rd.data.entity.name; notes = rd.data.entity.notes;}, null, null, 0, function(){$.spedmonWebUI.dialogMessage(name,$.spedmonWebUI.formattedTextToHTML(notes,'ui-spedmon-dialog-mono-txt'),true,800,400)});";

      base.Render(writer);
    }
  }
}
