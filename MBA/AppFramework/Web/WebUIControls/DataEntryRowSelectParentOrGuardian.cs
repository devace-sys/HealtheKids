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
   * SelectParentOrGuardian */
  /**
   * 
   *************************************************************************/
   
  public class DataEntryRowSelectParentOrGuardian : DataEntryRowSelectPerson
    {
    public DataEntryRowSelectParentOrGuardian(): base()
	  {	     
      _selectTitle                        = "Last Name, First Name";
      _dataPrivate                        = true;
      _dataURL                            = "patient_persons.asmx/viewSelParentsGuardiansOnly";
      _hasDataSource                      = false;
      _hasAddNew                          = true;
      _hasEditSelected                    = true;
      _hasViewNotes                       = false;
      _dataSourceParameterName            = null;
      _preSelectedDataSource              = null;
      _saveDataSourceSelectedAsPreference = false;
      _nounPlural                         = "Parent or Guardians";
      _nounSingular                       = "Parent or Guardian";
    }
    
	  protected string  _ctrlIdClientID             = null;
	  protected string  _ctrlIdPatID                = null;
      protected string  _tabIDOnPatsSaveScreen      = @"tab-contacts"; 
        
    public string   ctrlIdClientID                         { get {return _ctrlIdClientID; } set {_ctrlIdClientID = value;}}
    public string   ctrlIdPatID                            { get { return _ctrlIdPatID; } set {_ctrlIdPatID   = value;}}

	protected void createAddNewHandler()
    {
        /* We are managing the parent/guardians on the patient save screen. 
         * Parent/guardians will always be associated with an EXISTING patient record so we open the patient
         * save screen in edit mode and preselect the appropriate tab.
         */
        
        var _saveNewUrl  = MBA.HttpApplication.createLink(this._saveBaseUrlByRole
                                                         , true                                                         
                                                         , new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE)
                                                         , new NameValue(Constants.PARM_TAB_TO_OPEN, _tabIDOnPatsSaveScreen)
                                                         , new NameValue(Constants.PARM_SAVE_TYPE,Constants.SAVE_TYPE_EDIT)
                                                         );

        string _onAddNewCloseHdlr = "null";
        
        if (!String.IsNullOrWhiteSpace(_onAddNewClose)) 
          _onAddNewCloseHdlr = @"function(){" + _onAddNewClose + @"}";
        else
          _onAddNewCloseHdlr = "null";

        string _addNewWinName = _nounSingular + @"-" + @"new" + @"-" + _entityControlID;


        this._addNewHandler =  @"var cid = $('#clientid').val();"
                            +  @"var pid = $('#patid').val();"
                            +  @"var prms = '&clientid=' + cid + '&recid=' + pid;"
                            +  @"var url = '" + _saveNewUrl  + @"' + prms;"
                            +  @"$.spedmonWebUI.openNewWindow(url"
                            +  @",'" + _addNewWinName + @"'"
                            +  @","  + _onAddNewCloseHdlr
                            +  @");"
                            +  @"return;";

    }
    
    protected void createEditSelectedHandler()
    {
       var _editExistingUrl  = MBA.HttpApplication.createLink(this._saveBaseUrlByRole
                                                         , true                                                         
                                                         , new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE)
                                                         , new NameValue(Constants.PARM_TAB_TO_OPEN, _tabIDOnPatsSaveScreen)
                                                         , new NameValue(Constants.PARM_SAVE_TYPE,Constants.SAVE_TYPE_EDIT)
                                                         );
       string _onEditCloseHdlr = "null";
        
       if (!String.IsNullOrWhiteSpace(_onEditClose)) 
          _onEditCloseHdlr = @"function(){" + _onEditClose + @"}";
       else
          _onEditCloseHdlr = "null";

       string _editWinName = _nounSingular + @"-" + @"edit" + @"-" + _entityControlID;

       this._editSelectedHandler =  @"var recid = $('#" + _entityControlID  + @"').val();"
                                 +  @"if (!recid) return;"
                                 +  @"var cid = $('#clientid').val();"
                                 +  @"var pid = $('#patid').val();"
                                 +  @"var prms = '&clientid=' + cid + '&recid=' + pid;"
                                 +  @"var url = '" + _editExistingUrl  + @"' + prms;"
                                 +  @"$.spedmonWebUI.openNewWindow(url"
                                 +  @",'" + _editWinName + @"'"
                                 +  @","  + _onEditCloseHdlr
                                 +  @");"
                                 +  @"return;";
        
    }
    protected override void Render(HtmlTextWriter writer)
    {     	    
                           
      /* Use default control ids if nothing was provided */
      
	    if (String.IsNullOrWhiteSpace(_entityControlID))            _entityControlID           = @"prtgrdid";
      if (String.IsNullOrWhiteSpace(_ctrlIdClientID))             _ctrlIdClientID            = @"clientid";
      if (String.IsNullOrWhiteSpace(_ctrlIdPatID))                _ctrlIdPatID               = @"patid";
           
      /* Add data parm control ids (datasource is handled by base class) */

      this._dataParameterControlIDs.Add (_ctrlIdClientID);
      this._dataParameterControlIDs.Add (_ctrlIdPatID);
       
      /* URL for add new/edit */
      
	    this._saveBaseUrlByRole = @"user_all_pat_save_2.aspx";

      /* We cant use the default add new or edit handler generated by the base class so we override the defaults */
      
      createAddNewHandler();
      createEditSelectedHandler();

      base.Render(writer);
    }
  }
}
