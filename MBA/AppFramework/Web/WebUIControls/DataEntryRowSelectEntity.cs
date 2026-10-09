using System;
using System.Text;
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
   * SelectedEntity
  /**
   * 
   ****************************************************************************/  

  public class SelectedEntity
  {
    public string[] selectedNames;        
    public string[] selectedValues;
    public string[] selectedContextLabels;
  }

  /**************************************************************************
   * DataEntryRowSelectEntity
  /**
   * 
   ****************************************************************************/  
  public abstract class DataEntryRowSelectEntity:DataEntryRow
  {
    public DataEntryRowSelectEntity () : base() 
  	{   	      
      /* Init collections we need to build the control */

      _dataSources                 = new List<Enum>();    
      _dataParameterControlIDs     = new List<String>();      
      _seAdditionalDependentControls   = new List<Control>();
      _emailControlID              = Util.createUniqueID(this.ID);
      _phoneControlID              = Util.createUniqueID(this.ID);
    
    }
   
    protected bool    _selectAll                          = true;
    protected bool    _multiSelect                        = false;
    protected bool    _displayInline                      = false;
	protected bool    _dataPrivate                        = true;
    protected bool    _multiSelectLoad                    = false;
    protected bool    _multiSelectDisplayContextLabels    = false;

    protected bool    _hasClearSelection                  = true;
    protected bool    _showClearSelection                 = false;
    protected bool    _fireDataSelectedOnClear            = true;

    protected bool    _hasAddNew                          = false;
    protected bool    _showAddNew                         = false;
	  
    protected bool    _hasEditSelected                    = false;
    protected bool    _showEditSelected                   = false;    

    protected bool    _hasViewNotes                       = false;
    protected bool    _showViewNotes                      = false;
    
    protected bool    _hasManageFiles                     = false;
    protected bool    _showManageFiles                    = false;

    protected bool    _hasSaveSelectionAsDefault          = false;
    protected bool    _showSaveSelectionAsDefault         = false;

    protected bool    _hasDataSource                      = false;
    protected bool    _showDataSourceSelection            = false;       
    protected bool    _saveDataSourceSelectedAsPreference = false;    
   
    private bool     _hasEntityManagementControls         = false;

    private bool     _renderAddressControls               = false;

    protected string  _nounPlural               = null;
    protected string  _nounSingular             = null;
    protected string  _verb                     = @"viewSel";
    protected string  _prefNameDataSource       = @"source";
    protected string  _prefNameSvdSelAsDflt     = @"svcselasdflt";
    protected string  _entityControlID          = null;
    protected string  _entityParamName          = null;
    protected string  _selectValue              = null;
    protected string  _selectName               = null;
    protected string  _selectTitle              = null;
    protected bool    _selectValuePreset        = false;
    protected int     _delay;
    protected string  _dataURL                  = null;
    protected string  _dataParms                = null;
    
    protected string  _multiSelectListTitle     = null;
    protected string  _multiSelectNames         = null;
    protected string  _multiSelectValues        = null;
    protected string  _multiSelectContextlabels = null;
    protected string  _multiSelectOnAdd         = null;
    protected string  _multiSelectOnRemove      = null;
    protected bool    _multiSelectShowOK        = false;
    protected string  _dataSourceID             = null;
    protected string  _dataSourceParameterName  = null;
    protected Enum    _preSelectedDataSource    = null;    
    protected string  _saveBaseUrlByRole        = null;
    protected string  _addNewHandler            = @"";
    protected string  _editSelectedHandler      = @"";
    protected string  _viewNotesBaseUrl         = @"";
    protected string  _viewNotesHandler         = @"";
    protected string  _manageFilesHandler       = @"";
    protected string  _selectCtrlOnSelect       = @"";
    protected string  _selectCtrlLabel          = @"Select :";
    protected bool    _showSelectControlLabel   = false;    
    protected string  _addNewTitleText               = null;
    protected string  _editSelectedTitleText         = null;
    protected string  _manageFilesTitleText          = null;
    protected string  _entityIDToUseWithManageFiles  = "";
    protected string  _fileClassToUseWithManageFiles = "";
    protected string  _phoneControlID                = @"";
    protected string  _emailControlID                = @"";
    protected string  _email                         = "";
    protected string  _phone                         = "";
    protected string  _onAddNewClose                 = @"";
    protected string  _onEditClose                   = @"";
    protected string  _faIconAddNew                  = @"fa-plus";
    protected bool    _singleSelectClearAfterSelection = false;
    protected bool    _selectCtrlNoSubmit              = false;
    protected bool    _selectCtrlNoClear               = false;
    protected bool    _applyCybhiConsortiumLeadException = false;
    

    protected List<Enum>        _dataSources                   = new List<Enum>();
    protected List<String>      _dataParameterControlIDs       = new List<string>();        
    protected List<MBA.Button>  _entityManagementControls      = new List<Button>();    
    protected SelectType        _selectControlType             = SelectType.COMBO_BOX;    
    protected List<Control>     _seControls                    = new List<Control>();
    protected List<Control>     _seAdditionalDependentControls = new List<Control>();

    public string      dataURL                     { get { return _dataURL;}    set { _dataURL  = value;}}


    public string      entityControlID                     { get { return _entityControlID;}    set { _entityControlID  = value;}}
    public string      entityParamName                     { get { return _entityParamName;}    set { _entityParamName  = value;}}
    public SelectType  selectControlType                   { get { return _selectControlType; } set {_selectControlType = value;} }     
    public string      selectValue                         { get { return _selectValue; }       set { _selectValue = value; } }
    public string      selectName                          { get { return _selectName; }        set { _selectName = value;} } 
    public string      selectTitle                         { get { return _selectTitle;}        set { _selectTitle = value; }}
    public int         selectDelay                         { get { return _delay; }             set { _delay = value;} } 
    public bool        selectAll                           { get { return _selectAll; }         set { _selectAll = value;} } 
    public bool        multiSelect                         { get { return _multiSelect; }       set { _multiSelect = value;} } 
    public string      multiSelectListTitle                { get { return _multiSelectListTitle; } set { _multiSelectListTitle  = value;} } 
    public string      multiSelectNames                    { get { return _multiSelectNames; }     set { _multiSelectNames = value;} } 
    public string      multiSelectValues                   { get { return _multiSelectValues; }    set { _multiSelectValues = value;} } 
    public bool        multiSelectLoad                     { get { return _multiSelectLoad; }      set { _multiSelectLoad = value;} } 
    public string      multiSelectContextlabels            { get { return _multiSelectContextlabels; }          set { _multiSelectContextlabels = value;} } 
    public bool        multiSelectDisplayContextLabels     { get { return _multiSelectDisplayContextLabels; }   set { _multiSelectDisplayContextLabels = value;} } 
    public string      multiSelectOnAdd                    { get { return _multiSelectOnAdd; }                  set { _multiSelectOnAdd = value;} } 
    public string      multiSelectOnRemove                 { get { return _multiSelectOnRemove; }               set { _multiSelectOnRemove = value;} }     
    public bool        multiSelectShowOK                   { get { return _multiSelectShowOK;}                  set { _multiSelectShowOK = value;}}
    public string      selectCtrlOnSelect                  { get { return _selectCtrlOnSelect;}                 set {_selectCtrlOnSelect = value; }}
    public string      selectCtrlLabel                     { get { return _selectCtrlLabel;}                    set {_selectCtrlLabel = value; }}
    public bool        showSelectControlLabel              { get { return _showSelectControlLabel;}             set {_showSelectControlLabel = value; }}
    public bool        showDataSourceSelection             { get { return _showDataSourceSelection;}            set { _showDataSourceSelection = value;}}        
    public bool        saveDataSourceSelectedAsPreference  { get { return _saveDataSourceSelectedAsPreference;} set { _saveDataSourceSelectedAsPreference = value;}}
    public bool        showClearSelection                  { get { return _showClearSelection;}                 set { _showClearSelection = value; }}
    public bool        fireDataSelectedOnClear             { get { return _fireDataSelectedOnClear; }           set { _fireDataSelectedOnClear = value; }}
    public bool        showAddNew                          { get { return _showAddNew;}                         set { _showAddNew = value;} }
    public bool        showEditSelected                    { get { return _showEditSelected;}                   set { _showEditSelected = value;} }    
    public bool        showViewNotes                       { get { return _showViewNotes;}                      set { _showViewNotes = value;} }
    public bool        showManageFiles                     { get { return _showManageFiles;}                    set { _showManageFiles = value;} }
    public bool        showSaveSelectionAsDefault          { get { return _showSaveSelectionAsDefault;}         set { _showSaveSelectionAsDefault = value;} }
    public bool        renderAddressControls               { get { return _renderAddressControls;}              set { _renderAddressControls = value; }}
    public string      addNewHandler                      { get { return _addNewHandler;}          set {_addNewHandler = value;} }
    public string      editSelectedHandler                { get { return _editSelectedHandler;}    set {_editSelectedHandler = value;} }
    public string      onAddNewClose                      { get { return _onAddNewClose;}          set { _onAddNewClose = value;} }
    public string      onEditClose                        { get { return _onEditClose;}            set {_onEditClose = value;} }
    public string      saveBaseUrlByRole                  { get { return _saveBaseUrlByRole;}      set {_saveBaseUrlByRole = value;} }
    public string      addNewTitleText                    { get { return _addNewTitleText;}        set {_addNewTitleText = value;}}
    public string      editSelectedTitleText              { get { return _editSelectedTitleText;}  set {_editSelectedTitleText = value;}}
    public string      manageFilesTitleText               { get { return _manageFilesTitleText;}   set {_manageFilesTitleText = value;}}
    public string      manageFilesHandler                 { get { return _manageFilesHandler;}  set { _manageFilesHandler = value;}}   
    public string      fileClassToUseWithManageFiles      { get { return _fileClassToUseWithManageFiles;} set { _fileClassToUseWithManageFiles = value; }}

    public string email { get { return _email;} set {_email = value; }}
    public string phone { get { return _phone;} set {_phone = value; }}
    public bool singleSelectClearAfterSelection { get { return _singleSelectClearAfterSelection; } set { _singleSelectClearAfterSelection = value; }} 
    public bool selectCtrlNoSubmit              { get { return _selectCtrlNoSubmit; }              set {  _selectCtrlNoSubmit = value; }}
    public bool selectCtrlNoClear               { get { return _selectCtrlNoClear; }               set {  _selectCtrlNoClear = value; }}

    public bool applyCybhiConsortiumLeadException {  get { return _applyCybhiConsortiumLeadException; } 
                                                     set { _applyCybhiConsortiumLeadException = value; } }

    

    /***************************************************************************
     * hasValueOrValues */
    /**
     * Control has a value or values set
     * 
     ***************************************************************************/        
     
    public bool hasValueOrValues()
    {
      if (!_multiSelect) 
      {        
        if (!Util.IsNullOrEmpty(_selectValue)) {
          if (_selectValue == "0") return false;
          return true;
        }
        return false;
      }
      else 
        return (!Util.IsNullOrEmpty(_multiSelectValues));    
    }
    
    /***************************************************************************
     * okToAddSaveSelectionAsDefault */
    /**
     * 
     * 
     ***************************************************************************/           
    private bool okToAddSaveSelectionAsDefault ()
    {
      if (!_hasSaveSelectionAsDefault)       return false;  
      if (!_showSaveSelectionAsDefault)      return false;
      if (_multiSelect)                      return false;
      if (!_entryIsAllowed)                  return false;
      if (_selectValuePreset)                return false;
      return true;
    }

   /***************************************************************************
     * generateSavedPreferenceNoun */
    /**
     * 
     * 
     ***************************************************************************/           
    private string generateSavedPreferenceNoun()
    {
        return _nounPlural + _entityControlID;
    }
    
    /***************************************************************************
     * BuildDataParmsJsonCollection */
    /**
     * 
     * 
     ***************************************************************************/         
    private string BuildDataParmsJsonCollection ()
    {
      
      string _dp = @"";
      if (_dataParameterControlIDs.Count == 0) 
      { 
        _dp  = @"[]";
        return _dp;
      }
      
      List<String> _dataParmJsonObjs = new List<string>();      
      foreach(String _dataParameterControlID in _dataParameterControlIDs)
      {
        _dataParmJsonObjs.Add(String.Format(@"{{id:'{0}'}}",_dataParameterControlID));
      }
      
      _dp = @"[" + String.Join(",",_dataParmJsonObjs) + @"]";
      return _dp;
    }
    

    
    /***************************************************************************
     * createAddNewEntityControl */
    /**
     * 
     * 
     ***************************************************************************/             

    private void createAddNewEntityControl()
    {
      
      if (!_hasAddNew)  return;
      if (!_showAddNew) return;
      if (_multiSelect) return; 

      if ((String.IsNullOrWhiteSpace(this._addNewHandler)) && (!String.IsNullOrWhiteSpace(this._saveBaseUrlByRole))) 
      { 
        
       
                 
        var saveNewUrl  = MBA.HttpApplication.createLink(_saveBaseUrlByRole
                                                         ,true                                                         
                                                         ,new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE)
                                                         ,new NameValue(Constants.PARM_SAVE_TYPE,Constants.SAVE_TYPE_NEW)
                                                         );


        string _onAddNewCloseHdlr = "null";
        
        if (!String.IsNullOrWhiteSpace(_onAddNewClose)) 
          _onAddNewCloseHdlr = @"function(){" + _onAddNewClose + @"}";
        else
          _onAddNewCloseHdlr = "null";

        string _addNewWinName = _nounSingular + @"-" + @"new" + @"-" + _entityControlID;

        this._addNewHandler = @"var url = '" + saveNewUrl + @"';"
                              + @"$.spedmonWebUI.openNewWindow(url"
                              + @",'" + _addNewWinName + @"'"
                              + @","  + _onAddNewCloseHdlr
                              + @");"
                              + @"return;";


      }

      if (String.IsNullOrWhiteSpace(this._addNewHandler)) return;

      var butAddNew = new MBA.Button();

      butAddNew.ID                  = Util.createUniqueID(_entityControlID);
      butAddNew.icon                = @"ui-icon-plus";
      butAddNew.faIcon              = _faIconAddNew;
      butAddNew.showIconOnly        = true;
      butAddNew.excludeFromTabIndex = true;
      butAddNew.applyDefautStyles   = false;
      if (String.IsNullOrWhiteSpace(_addNewTitleText)) _addNewTitleText = @"Click here to add a new " + this._nounSingular;
      butAddNew.title              = _addNewTitleText;
      butAddNew.text               = "Add New";
      butAddNew.onclick            = _addNewHandler;

      _hasEntityManagementControls = true;      
      _entityManagementControls.Add(butAddNew);      
    }

    /***************************************************************************
     * createEditSelectedEntityControl */
    /**
     * 
     * 
     ***************************************************************************/         

    private void createEditSelectedEntityControl()
    {

      if (!_hasEditSelected)  return;
      if (!_showEditSelected) return;
      if (_multiSelect)       return; 

      if (String.IsNullOrWhiteSpace(this._editSelectedHandler) && (!String.IsNullOrWhiteSpace(this._saveBaseUrlByRole)))
      { 
        var _editExistingUrl = MBA.HttpApplication.createLink( _saveBaseUrlByRole
                                                              , true
                                                              , new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE)
                                                              , new NameValue(Constants.PARM_SAVE_TYPE,Constants.SAVE_TYPE_EDIT)
                                                              , new NameValue(Constants.PARM_REC_ID,""));

        string _onEditCloseHdlr = "null";
        
        if (!String.IsNullOrWhiteSpace(_onEditClose)) 
          _onEditCloseHdlr = @"function(){" + _onEditClose + @"}";
        else
          _onEditCloseHdlr = "null";
        
        string _editWinName = _nounSingular + @"-" + @"edit" + @"-" + _entityControlID;

        this._editSelectedHandler = @"var recid = $('#" + _entityControlID  + @"').val();"
                                  + @"if (!recid) return;"
                                  + @"var url = '" + _editExistingUrl + @"' + recid;"
                                  + @"$.spedmonWebUI.openNewWindow(url"
                                  + @",'" + _editWinName + @"'"
                                  + @","  + _onEditCloseHdlr
                                  + @");"
                                  + @"return;";
      }
     
      if (String.IsNullOrWhiteSpace(this._editSelectedHandler)) return;

      var butEditSelected = new MBA.Button();

      butEditSelected.ID                  = Util.createUniqueID(_entityControlID);
      butEditSelected.icon                = @"ui-icon-pencil";
      butEditSelected.faIcon              = @"fa-pencil-alt";
      butEditSelected.showIconOnly        = true;
      butEditSelected.excludeFromTabIndex = true;
      butEditSelected.applyDefautStyles   = false;

      if (String.IsNullOrWhiteSpace(_editSelectedTitleText)) _editSelectedTitleText =  @"Click here to edit the selected " + _nounSingular;

      butEditSelected.title        = _editSelectedTitleText;
      butEditSelected.text         = "Edit Selected";
      butEditSelected.onclick      = this._editSelectedHandler;
      _hasEntityManagementControls = true;

      _entityManagementControls.Add(butEditSelected);
    
    }

    /***************************************************************************
     * createViewNotesControl */
    /**
     * 
     * 
     ***************************************************************************/             
    private void createViewNotesControl()
    {
      
      if (!_hasViewNotes)  return;  
      if (!_showViewNotes) return;
      if (_multiSelect)    return; 
      if (String.IsNullOrWhiteSpace(_viewNotesBaseUrl)) return;
      if (_userGroup != Constants.USER_GROUP_SBSC)      return;  /* Ony PCAL staff can view notes*/

      var _viewNotesTitle = @"Click here to view input notes related to the selected " + _nounSingular;

      var butViewNotes = new MBA.Button();

      butViewNotes.ID                  = Util.createUniqueID(_entityControlID);
      butViewNotes.icon                = @"ui-icon-note";
      butViewNotes.faIcon              = @"fa-book";
      butViewNotes.showIconOnly        = true;
      butViewNotes.excludeFromTabIndex = true;
      butViewNotes.title               = _viewNotesTitle;
      butViewNotes.text                = "View Notes";
      butViewNotes.onclick             = _viewNotesHandler;
      butViewNotes.applyDefautStyles   = false;

      _hasEntityManagementControls = true;
      _entityManagementControls.Add(butViewNotes);
    
    }
   
   /***************************************************************************
     * createManageFilesControl */
    /**
     * 
     * 
     ***************************************************************************/             
    private void createManageFilesControl ()
    {
      
      if (!_hasManageFiles)  return;  
      if (!_showManageFiles) return;
      if (_multiSelect)      return; 
      
      if (String.IsNullOrWhiteSpace(_fileClassToUseWithManageFiles))
        _fileClassToUseWithManageFiles = MBA.StoredFiles.FILE_CLASS_MISC;

      if (String.IsNullOrWhiteSpace(this._manageFilesHandler))
      {
        
        if (!String.IsNullOrWhiteSpace(this._dataParms))
        { 
          
          _manageFilesHandler  = "var recid = $('#" + _entityControlID  + @"').val();"
                               + @"if (!recid) return;";

          _manageFilesHandler = _manageFilesHandler 
                                + @"var fileAdditionalDataJSONStr = $.spedmonWebUI.dataParameterControlIdsToAdditionalDataJSONString (" 
                                + this._dataParms 
                                + @",'" + _entityIDToUseWithManageFiles + @"'"
                                + @",recid"
                                + @");";
        
          _manageFilesHandler = _manageFilesHandler 
                               + @"$.spedmonWebUI.fileList ("
                               + @" 'Files Associated with " + _nounSingular        + @"'"
                               + @",'" + MBA.StoredFiles.LIST_HANDLER_PRIVATE()     + @"'"
                               + @",'" + MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE() + @"'"
                               + @",'" + MBA.StoredFiles.PARAM_FILE_ID              + @"'"
                               + @", 3"
                               + @",'" + MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()   + @"'"
                               + @",'" + _fileClassToUseWithManageFiles + @"'"
                               + @", ''"
                               + @", ''"
                               + @", ''"
                               + @", fileAdditionalDataJSONStr , true, true );";
          
        }
      }
      
      if (String.IsNullOrWhiteSpace(this._manageFilesHandler)) return;

      var butManageFiles = new MBA.Button();

      butManageFiles.ID                  = Util.createUniqueID(_entityControlID);
      butManageFiles.icon                = @"ui-icon-paperclip";
      butManageFiles.faIcon              = @"fa-paperclip";
      butManageFiles.showIconOnly        = true;
      butManageFiles.excludeFromTabIndex = true;
      butManageFiles.applyDefautStyles   = false;

      if (String.IsNullOrWhiteSpace(_manageFilesTitleText)) 
        _manageFilesTitleText = @"Click here to manage files related to the selected " + _nounSingular;

      butManageFiles.title        = _manageFilesTitleText;
      butManageFiles.text         = "Manage Files";
      butManageFiles.onclick      = _manageFilesHandler;

      _hasEntityManagementControls = true;
      _entityManagementControls.Add(butManageFiles);
    
    }

    /***************************************************************************
     * createSaveSelectionAsDefaultControl */
    /**
     * 
     * 
     ***************************************************************************/             
    private void createSaveSelectionAsDefaultControl()
    {
      
      if (!okToAddSaveSelectionAsDefault()) return; 

      string savedPreferenceNoun = generateSavedPreferenceNoun();

      var butSaveSelectionAsDefault = new MBA.Button();
            

      string _saveSelectionAsDefaultHandler = @"var _selBoxCtrlRef = $('#" + _entityControlID  + @"').data('spedmonSelectBox');"
                                             + @"if (!_selBoxCtrlRef) return;"
                                             + @"var _prefObj = {};"
                                             + @"_prefObj.selectedNames = _selBoxCtrlRef.names();"
                                             + @"_prefObj.selectedValues = _selBoxCtrlRef.values();"
                                             + @"_prefObj.selectedContextLabels = _selBoxCtrlRef.contextLabels();"
                                             + @"var _prefJSON = JSON.stringify(_prefObj);"
                                             + @"$.spedmonWebUI.setUserPreference('" + HttpApplication.currentEndPointName() + @"','" + UserPreferences.SELECTOR_TYPE_END_POINT + @"','" + savedPreferenceNoun + @"','" + _verb +@"','" + _prefNameSvdSelAsDflt +@"',_prefJSON);"
                                             + @"return;";

      butSaveSelectionAsDefault.ID                  = Util.createUniqueID(_entityControlID);
      butSaveSelectionAsDefault.icon                = @"ui-icon-bookmark";
      butSaveSelectionAsDefault.faIcon              = @"fa-bookmark";
      butSaveSelectionAsDefault.showIconOnly        = true;
      butSaveSelectionAsDefault.excludeFromTabIndex = true;
      butSaveSelectionAsDefault.title               = @"Click here to save this selection as your default. If you need to remove this default please clear the selection and save the empty selection as your default.";
      butSaveSelectionAsDefault.text                = "Save Selection As Default";
      butSaveSelectionAsDefault.onclick             = _saveSelectionAsDefaultHandler;
      butSaveSelectionAsDefault.applyDefautStyles   = false;

      _hasEntityManagementControls = true;
      _entityManagementControls.Add(butSaveSelectionAsDefault);
    
    }

    /***************************************************************************
     * createClearSelectionControl */
    /**
     * 
     * 
     ***************************************************************************/             
    private void createClearSelectionControl()
    {
     
      if (!_hasClearSelection)  return;
      if (!_showClearSelection) return;
      if (_multiSelect) return; 
 
      var butClearSelection = new MBA.Button();
            

      string _clearSelectionHandler = @"var _selBoxCtrlRef = $('#" + _entityControlID  + @"').data('spedmonSelectBox');"
                                             + @"if (!_selBoxCtrlRef) return;"
                                             + @"_selBoxCtrlRef.clear();";
      if (_fireDataSelectedOnClear) { 
        _clearSelectionHandler = _clearSelectionHandler 
                               + @"var _emptyItemObj = {};"
                               + @"_emptyItemObj.id ='" + _entityControlID + @"';"                               
                               + @"$.spedmonWebUI.fireDataSelected(_selBoxCtrlRef.ctrlRefMe,_emptyItemObj);";                               
      }
      _clearSelectionHandler = _clearSelectionHandler + @"return;";

      butClearSelection.ID                  = Util.createUniqueID(_entityControlID);
      butClearSelection.icon                = @"ui-icon-circle-close";
      butClearSelection.faIcon              = @"fa-times-circle";
      butClearSelection.showIconOnly        = true;
      butClearSelection.excludeFromTabIndex = true;
      butClearSelection.title               = @"Click here to clear the current selection.";
      butClearSelection.text                = "Clear This Selection";
      butClearSelection.onclick             = _clearSelectionHandler;
      butClearSelection.applyDefautStyles   = false;

      _hasEntityManagementControls = true;
      _entityManagementControls.Add(butClearSelection);
    
    }

    /***************************************************************************
     * renderEntityManagementContainerAndControls */
    /**
     * 
     * 
     ***************************************************************************/             

    private void renderEntityManagementContainerAndControls ()
    {
       /* Standard controls */
                   
       createClearSelectionControl();
       createAddNewEntityControl();
       createEditSelectedEntityControl();
       createViewNotesControl();
       createManageFilesControl();
       createSaveSelectionAsDefaultControl();

       if (_hasEntityManagementControls)
       {
         var entityMgmtControls = new Wrapper(@"div",_entityManagementControls.ToArray());
         entityMgmtControls.ID = Util.createUniqueID(_entityControlID);
         entityMgmtControls.cssClass = @"ui-spedmon-select-entity-mgmt-controls";
         _seControls.Add( entityMgmtControls);
       }
    }

    /***************************************************************************
     * RenderAddressControls */
    /**
     * 
     ***************************************************************************/             
    private void renderAddressControlsAndContainer()
    {
      if (!_renderAddressControls)  return;
      if (_multiSelect)          return; 
      
      var address = new MBA.Address();
      address.ID = Util.createUniqueID();
      address.cssClass = @"ui-spedmon-select-entity-address-container";

      var emailLink = new MBA.EmailLink();
      emailLink.ID = _emailControlID;
      emailLink.cssClass = @"ui-spedmon-select-entity-email";
      emailLink.value = _email;
      emailLink.excludeFromTabIndex = true;
      address.Controls.Add(emailLink);

      var phoneLink = new MBA.PhoneLink();
      phoneLink.ID = _phoneControlID;
      phoneLink.cssClass = @"ui-spedmon-select-entity-phone";
      phoneLink.value = _phone;          
      phoneLink.excludeFromTabIndex = true;
      address.Controls.Add(phoneLink);

      _seControls.Add(address); 

    }
    
    /***************************************************************************
     * RenderDataSourceControl */
    /**
     * 
     * 
     ***************************************************************************/             
    private void renderDataSourceControl ()
    {
      if (!_hasDataSource) return;      
      //if ( _preSelectedDataSource == null) throw new MBA.Critical(@"A preselected datasource must be defined.");

      //_dataSourceID = Util.createUniqueID(_dataSourceParameterName);
      //this._dataParameterControlIDs.Add (_dataSourceID);
       
      var okToShowDataSource = ((_showDataSourceSelection) && (!_multiSelect));

      if ((okToShowDataSource))
      { 
              
        var _preSelectedVal = _preSelectedDataSource.GetValueAsInt();
        var _dsSelectedHandler = "";   
        
        if (_saveDataSourceSelectedAsPreference) 
        {          
          string savedPreferenceNoun = generateSavedPreferenceNoun();
          string savedPreference     = @"";               
        
          if (UserPreferences.getPreferenceValue( HttpApplication.currentEndPointName(), UserPreferences.SELECTOR_TYPE_END_POINT, savedPreferenceNoun , _verb, _prefNameDataSource, ref rd.wu.preferences, out savedPreference))
          { 
            /* If the saved pref value is not valid then use the default */
            if (!int.TryParse(savedPreference,out _preSelectedVal)) _preSelectedVal = _preSelectedDataSource.GetValueAsInt();                          
          }

          _dsSelectedHandler = 
                @"function(oldval,newval){"
              + @"if (oldval != newval){"                  
              + @"$.spedmonWebUI.setUserPreference('" + HttpApplication.currentEndPointName() + @"','" + UserPreferences.SELECTOR_TYPE_END_POINT + @"','" + savedPreferenceNoun + @"','" + _verb +@"','" + _prefNameDataSource +@"',newval);"
              + @"};return true;}";                       
        }
        else
        {
          _preSelectedVal   = _preSelectedDataSource.GetValueAsInt();
         _dsSelectedHandler = @"function(oldval,newval){return true;}";
        }

        MBA.RadioBox dataSource     = new MBA.RadioBox();
        dataSource.ID               = _dataSourceID;
        dataSource.name             = _dataSourceParameterName;
        dataSource.title            = "Select From";
        dataSource.firedataselected = false;
        dataSource.noClear          = true;
        dataSource.noSubmit         = true;
        dataSource.onSelectValue    = _dsSelectedHandler;
        dataSource.labelIsSpan      = false;
        dataSource.renderLabel      = false;
        dataSource.additionalCssClassNameForContainer = "modern2021";

        foreach (Enum _dataSource in _dataSources)
        {                       
          var _preSelected = false;
          if (_dataSource.GetValueAsInt() == _preSelectedVal) _preSelected = true;
          dataSource.AddSelection ( _dataSource, _preSelected );           
        }
        _seControls.Add(dataSource); 
      }
      else
      {
        HiddenInput dataSource = new HiddenInput(_dataSourceParameterName, _preSelectedDataSource.GetValueAsString());
        dataSource.ID    = _dataSourceID;
        dataSource.title = "Select From";
        _seControls.Add(dataSource);         
      }
    }

    /***************************************************************************
     * RenderSelectControl */
    /**
     * 
     * 
     ***************************************************************************/         
    
    private void renderSelectControl ()
    {
                
      /* Default list title for multiselect options */
      
      if ((this._multiSelect) && (String.IsNullOrWhiteSpace(_multiSelectListTitle))) _multiSelectListTitle = @"Entities Selected";
       
      /* Build select control */
              
      if (_selectControlType == SelectType.SEARCH_BOX)
      {
        MBA.SearchBox selEntity = new MBA.SearchBox();
                   
        selEntity.ID                              = _entityControlID;
        selEntity.name                            = _entityParamName;
        selEntity.value                           = _selectValue;
        selEntity.selectName                      = _selectName; /* Entity name associated with the entity id */
        selEntity.title                           = _selectTitle;      
        selEntity.showSelectControlLabel          = _showSelectControlLabel;
        selEntity.selectControlLabel              = _selectCtrlLabel;
        selEntity.dataPrivate                     = _dataPrivate;
        selEntity.dataURL                         = _dataURL;
        selEntity.dataParms                       = _dataParms;        
        selEntity.multiSelect                     = _multiSelect;
        selEntity.multiSelectListTitle            = _multiSelectListTitle;
        selEntity.multiSelectNames                = _multiSelectNames;
        selEntity.multiSelectValues               = _multiSelectValues;
        selEntity.multiSelectLoad                 = _multiSelectLoad;
        selEntity.multiSelectContextLabels        = _multiSelectContextlabels;
        selEntity.multiSelectDisplayContextLabels = _multiSelectDisplayContextLabels;
        selEntity.multiSelectOnAdd                = _multiSelectOnAdd;        
        selEntity.multiSelectOnRemove             = _multiSelectOnRemove;                
        selEntity.multiSelectShowOK               = _multiSelectShowOK;
        selEntity.onSelect                        = _selectCtrlOnSelect;
        selEntity.singleSelectClearAfterSelection = _singleSelectClearAfterSelection;
        selEntity.noSubmit                        = _selectCtrlNoSubmit;
        selEntity.noClear                         = _selectCtrlNoClear;
        _seControls.Add(selEntity);       
      }

      else if (_selectControlType == SelectType.COMBO_BOX)
      {
        
        MBA.ComboBox selEntity = new MBA.ComboBox();
                   
        selEntity.ID                              = _entityControlID;
        selEntity.name                            = _entityParamName;
        selEntity.value                           = _selectValue;
        selEntity.selectName                      = _selectName; /* Entity name associated with the entity id */        
        selEntity.title                           = _selectTitle;
        selEntity.showSelectControlLabel          = _showSelectControlLabel;
        selEntity.selectControlLabel              = _selectCtrlLabel;
        selEntity.dataPrivate                     = _dataPrivate;
        selEntity.dataURL                         = _dataURL;
        selEntity.dataParms                       = _dataParms;        
        selEntity.multiSelect                     = _multiSelect;
        selEntity.multiSelectListTitle            = _multiSelectListTitle;
        selEntity.multiSelectNames                = _multiSelectNames;
        selEntity.multiSelectValues               = _multiSelectValues;
        selEntity.multiSelectLoad                 = _multiSelectLoad;
        selEntity.multiSelectContextLabels        = _multiSelectContextlabels;
        selEntity.multiSelectDisplayContextLabels = _multiSelectDisplayContextLabels;
        selEntity.multiSelectOnAdd                = _multiSelectOnAdd;
        selEntity.multiSelectOnRemove             = _multiSelectOnRemove;
        selEntity.multiSelectShowOK               = _multiSelectShowOK;
        selEntity.selectAll                       = _selectAll;
        selEntity.delay                           = _delay;
        selEntity.onSelect                        = _selectCtrlOnSelect;
        selEntity.singleSelectClearAfterSelection = _singleSelectClearAfterSelection;
        selEntity.noSubmit                        = _selectCtrlNoSubmit;
        selEntity.noClear                         = _selectCtrlNoClear;

        _seControls.Add(selEntity); 
      }
    }

    /***************************************************************************
     * Render */
    /**
     * 
     * 
     ***************************************************************************/         
    
    protected override void Render(HtmlTextWriter writer)
    {     
      /* If selecting this entity requires the user be logged in and they are not then exit */

      if ((_dataPrivate) && (rd.loggedIn == false)) return;
            
      if (String.IsNullOrWhiteSpace(this._entityControlID)) throw new MBA.Critical(@"Entity control ID must be defined.");
      if (String.IsNullOrWhiteSpace(this._nounPlural))      throw new MBA.Critical(@"A noun plural must be defined");
      if (String.IsNullOrWhiteSpace(this._nounSingular))    throw new MBA.Critical(@"A noun singular must be defined");

      if (String.IsNullOrWhiteSpace(_entityParamName))   _entityParamName   = _entityControlID;   
                                          
      /* If we are not allowing a value to be selected just put the name/value in a hidden input  */

      if (!_entryIsAllowed)
      {

        MBA.HiddenInput selEntity = new MBA.HiddenInput();

        selEntity.ID              = _entityControlID; 
        selEntity.name            = _entityParamName;        
        selEntity.title           = _selectTitle;
        selEntity.value           = _selectValue;
        _selectValuePreset        = true;
        _seControls.Add(selEntity); 
      }

     /* Otherwise render selection controls */

      else
      {
        
        /* Add a data parm reference if we have a data source*/

        if (_hasDataSource == true)
        {
            if (_preSelectedDataSource == null) throw new MBA.Critical(@"A preselected datasource must be defined.");
            _dataSourceID = Util.createUniqueID(_dataSourceParameterName);
            this._dataParameterControlIDs.Add(_dataSourceID);
        }
        
       /* Build reference list to other controls that have data this select needs */
      
       this._dataParms = BuildDataParmsJsonCollection();
      
       /* See if value might have been passed */

       _selectValuePreset  = !Util.IsNullOrEmpty(_selectValue);

       /* If this control might have a user selected default */

       if (okToAddSaveSelectionAsDefault() == true)
       {
           
         string _prefJSON;  
         if (UserPreferences.getPreferenceValue( HttpApplication.currentEndPointName(), UserPreferences.SELECTOR_TYPE_END_POINT, generateSavedPreferenceNoun() , _verb, _prefNameSvdSelAsDflt, ref rd.wu.preferences, out _prefJSON))
         { 
           try
           { 
             SelectedEntity se = (SelectedEntity) JSON.fromJSONString(_prefJSON,typeof(SelectedEntity));                 
             _selectValue  = se.selectedValues[0];
             _selectName   = se.selectedNames[0]; /* Entity name associated with the entity id */         
           }
           catch
           {
           }
         }
       } /* okToAddSavedSelectionAsDefault*/
       
        renderSelectControl();
        renderEntityManagementContainerAndControls();        
        renderAddressControlsAndContainer();
        renderDataSourceControl();
        
       }

      var seControlsCtrl      = new Wrapper(@"div",_seControls.ToArray());
      seControlsCtrl.ID       = Util.createUniqueID(_entityControlID);
      seControlsCtrl.cssClass = @"ui-spedmon-select-entity-container d-flex align-items-center";
      this.Controls.Add(seControlsCtrl);
      
      /* Add any additional dependedent control or control collections */

      foreach(var additionalDependentControl in _seAdditionalDependentControls) {
        this.Controls.Add(additionalDependentControl);
      }

      var _jsOpts = @"{"
                  + @" multiSelectIsEnabled:"       + Util.netBoolToJSBool(_multiSelect)
                  + @",addressControlsAreRendered:" + Util.netBoolToJSBool(_renderAddressControls)
                  + @",emailLinkControlID:'" + _emailControlID + @"'"
                  + @",phoneLinkControlID:'" + _phoneControlID + @"'"
                  + @",colEntryID:'"         + _colEntryID     + @"'"
                  + @",dataParms:"       + this._dataParms             
                  + @",renderedAsField:" + ((this._dataEntryRowRenderAs == DataEntryRowRenderAs.FIELD) ? "true" : "false")
                  + @",onSpedmonInputData:function(e){" + _onSpedmonInputData + @"}"
                  + @"}";
         
      this._onDocReady = @"$('#" + this.ID + @"').dataEntryRowSelectEntity(" + _jsOpts + @");";
            
      base.Render(writer);
    }
  }
}
