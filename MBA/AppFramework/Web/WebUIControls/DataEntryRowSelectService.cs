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
   * DataEntryRowSelectService */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectService:DataEntryRowSelectEntity
  {
    public DataEntryRowSelectService(): base()
	{	     
      _selectTitle                        = "Service";
      _dataPrivate                        = true;
      _dataURL                            = "services.asmx/viewSel2";
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
        
    public const string CSS_CLASS_SELECTION_OPTIONS_CONTAINER      = @"mba-service-selection-options-container";
    public const string CSS_CLASS_ORP_DOCUMENT_SELECTION_CONTAINER = @"mba-service-selection-orp-document-selection-container";
    public const string LABEL_SVC_DET_FLAG_1                       = @"Performed Evaluation of Speech Fluency?";
    public const string LABEL_SVC_DET_FLAG_2                       = @"Performed Evaluation of Speech Sound Production?";
    public const string LABEL_SVC_DET_FLAG_3                       = @"Performed Evaluation of Language Comprehension and Expression?";
    public const string LABEL_SVC_DET_FLAG_4                       = @"Performed Behavioral and Qualitative Analysis of Voice and Resonance?";

    protected string  _ctrlIdClientID                    = null;
    protected string  _ctrlIdPracID                      = null;
    protected string  _ctrlIdGrpID                       = null;
    protected string  _ctrlIdPatID                       = null;
    protected string  _ctrlIdDos                         = null;
    protected string  _ctrlIdIsIep                       = null;
    protected string  _ctrlIdViaTeleHealth               = null;
    protected string  _ctrlIdSvcNamesListDataSourceID    = null;
    protected string  _ctrlIdHasPatientGoalTrackingData  = null;

    protected string  _dataUrlSelectOrpDoc               = @"orp_documents.asmx/viewSel";

    /* IDs for internal controls TODO: Add public properties for these and an option to toggle internal controls off */
    
    protected string  _ctrlIdHasSvcDetFlags           = @"hasSvcDetFlags";
    protected string  _ctrlIdSvcDetFlag1              = @"svcDetFlag1";
    protected string  _ctrlIdSvcDetFlag2              = @"svcDetFlag2";
    protected string  _ctrlIdSvcDetFlag3              = @"svcDetFlag3";
    protected string  _ctrlIdSvcDetFlag4              = @"svcDetFlag4";
    protected string  _ctrlIdHasOrpDocID              = @"hasOrpDocID";
    protected string  _ctrlIdOrpDocID                 = Constants.PARM_ORP_DOC_ID; /* orpDocID */

    protected bool   _promptForAdditionalServiceDetails = true;
    
    /* For referencing external controls */
    public string   ctrlIdClientID        { get {return _ctrlIdClientID; }         set {_ctrlIdClientID = value;}}
    public string   ctrlIdPracID          { get { return _ctrlIdPracID; }          set { _ctrlIdPracID = value; } }
    public string   ctrlIdGrpID           { get { return _ctrlIdGrpID; }           set { _ctrlIdGrpID = value; } }
    public string   ctrlIdPatID           { get { return _ctrlIdPatID; }           set {_ctrlIdPatID = value;}}
    public string   ctrlIdDos             { get { return _ctrlIdDos; }             set {_ctrlIdDos = value;}}
    public string   ctrlIdIsIEP           { get { return _ctrlIdIsIep; }           set { _ctrlIdIsIep = value;}}
    public string   ctrlIdViaTeleHealth   { get { return _ctrlIdViaTeleHealth; }   set { _ctrlIdViaTeleHealth = value;}}    
    public string   ctrlIdSvcNamesListDataSourceID { get { return _ctrlIdSvcNamesListDataSourceID; }
                                                     set { _ctrlIdSvcNamesListDataSourceID = value; }}
    public string   ctrlIdHasPatientGoalTrackingData { get { return _ctrlIdHasPatientGoalTrackingData;} 
                                                       set { _ctrlIdHasPatientGoalTrackingData = value; } }        
    /* Functionality options */
	public bool promptForAdditionalServiceDetails { get { return _promptForAdditionalServiceDetails; }
                                                    set { _promptForAdditionalServiceDetails = value; } }
    protected override void Render(HtmlTextWriter writer)
    {     	    
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID))                  _entityControlID                  = Constants.PARM_NAME_ID;
      if (String.IsNullOrWhiteSpace(_entityIDToUseWithManageFiles))     _entityIDToUseWithManageFiles     = Constants.PARM_NAME_ID;      
      if (String.IsNullOrWhiteSpace(_ctrlIdClientID))                   _ctrlIdClientID                   = Constants.PARM_CLIENT_ID;
      if (String.IsNullOrWhiteSpace(_ctrlIdPracID))                     _ctrlIdPracID                     = Constants.PARM_PRACTITIONER_ID;
      if (String.IsNullOrWhiteSpace(_ctrlIdGrpID))                      _ctrlIdGrpID                      = Constants.PARM_GROUP_ID;
      if (String.IsNullOrWhiteSpace(_ctrlIdPatID))                      _ctrlIdPatID                      = Constants.PARM_PATIENT_ID;
      if (String.IsNullOrWhiteSpace(_ctrlIdDos))                        _ctrlIdDos                        = Constants.PARM_DOS;
      if (String.IsNullOrWhiteSpace(_ctrlIdIsIep))                      _ctrlIdIsIep                      = Constants.PARM_IS_IEP;
      if (String.IsNullOrWhiteSpace(_ctrlIdViaTeleHealth))              _ctrlIdViaTeleHealth              = Constants.PARM_VIA_TELEHEALTH;   
      if (String.IsNullOrWhiteSpace(_ctrlIdSvcNamesListDataSourceID))   _ctrlIdSvcNamesListDataSourceID   = Constants.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID;
      if (String.IsNullOrWhiteSpace(_ctrlIdHasPatientGoalTrackingData)) _ctrlIdHasPatientGoalTrackingData = @"hasPatientGoalTrackingData";
      
      /* Add data parm control ids (datasource is handled by base class) */

      this._dataParameterControlIDs.Add (_ctrlIdClientID);
      this._dataParameterControlIDs.Add (_ctrlIdPracID);
      this._dataParameterControlIDs.Add (_ctrlIdPatID);
      this._dataParameterControlIDs.Add (_ctrlIdDos); 
      this._dataParameterControlIDs.Add (_ctrlIdIsIep);
      this._dataParameterControlIDs.Add (_ctrlIdSvcNamesListDataSourceID);
      this._dataParameterControlIDs.Add (_ctrlIdViaTeleHealth);      

      /* Add service detail flag controls */

     var _svcDetailFlagCtrls = new List<Control>();

     var _ctrlHasSvcDetFlags = new MBA.HiddenInput();
     _ctrlHasSvcDetFlags.ID = _ctrlIdHasSvcDetFlags;
     _ctrlHasSvcDetFlags.name = _ctrlIdHasSvcDetFlags;
     _ctrlHasSvcDetFlags.title = _ctrlIdHasSvcDetFlags;
     _ctrlHasSvcDetFlags.value = @"N";
     _svcDetailFlagCtrls.Add(_ctrlHasSvcDetFlags);

     var _ctrlSvcDetFlag1 = new MBA.SelectYesOrNo();
     _ctrlSvcDetFlag1.ID = _ctrlIdSvcDetFlag1;
     _ctrlSvcDetFlag1.name = _ctrlIdSvcDetFlag1;
     _ctrlSvcDetFlag1.title = LABEL_SVC_DET_FLAG_1;
     _svcDetailFlagCtrls.Add(_ctrlSvcDetFlag1);

     var _ctrlSvcDetFlag2 = new MBA.SelectYesOrNo();
     _ctrlSvcDetFlag2.ID  = _ctrlIdSvcDetFlag2;
     _ctrlSvcDetFlag2.name = _ctrlIdSvcDetFlag2;
     _ctrlSvcDetFlag2.title = LABEL_SVC_DET_FLAG_2;
     _svcDetailFlagCtrls.Add(_ctrlSvcDetFlag2);

     var _ctrlSvcDetFlag3 = new MBA.SelectYesOrNo();
     _ctrlSvcDetFlag3.ID = _ctrlIdSvcDetFlag3;
     _ctrlSvcDetFlag3.name = _ctrlIdSvcDetFlag3;
     _ctrlSvcDetFlag3.title = LABEL_SVC_DET_FLAG_3;
     _svcDetailFlagCtrls.Add(_ctrlSvcDetFlag3);

     var _ctrlSvcDetFlag4 = new MBA.SelectYesOrNo();
     _ctrlSvcDetFlag4.ID = _ctrlIdSvcDetFlag4;
     _ctrlSvcDetFlag4.name = _ctrlIdSvcDetFlag4;
     _ctrlSvcDetFlag4.title = LABEL_SVC_DET_FLAG_4;
     _svcDetailFlagCtrls.Add(_ctrlSvcDetFlag4);
                       
     var _svcDetailFlagCtrlsContainer = new Wrapper(@"div", _svcDetailFlagCtrls.ToArray());
     _svcDetailFlagCtrlsContainer.ID  = _entityControlID + @"_svcdetailflags";
     _svcDetailFlagCtrlsContainer.cssClass = CSS_CLASS_SELECTION_OPTIONS_CONTAINER;
     this._seAdditionalDependentControls.Add(_svcDetailFlagCtrlsContainer);

     /* Add orp document selection controls */

     var _orpDocSelectionCtrls = new List<Control>();
     
     var _ctrlHasOrpDocID = new MBA.HiddenInput();
     _ctrlHasOrpDocID.ID = _ctrlIdHasOrpDocID;
     _ctrlHasOrpDocID.name  = _ctrlIdHasOrpDocID;
     _ctrlHasOrpDocID.title = _ctrlIdHasOrpDocID;
     _ctrlHasOrpDocID.value = @"N";
     _orpDocSelectionCtrls.Add(_ctrlHasOrpDocID);

     string _dataParmsSelectOrpDoc = @"[" 
                                   +  "{id:'" + _ctrlIdClientID + "'}"
                                   + ",{id:'" + _ctrlIdPracID  + "'}"
                                   + ",{id:'" + _ctrlIdPatID   + "'}"
                                   + @"]";

     var _ctrlOrpDocSelection = new MBA.ComboBox();
     _ctrlOrpDocSelection.ID        = _ctrlIdOrpDocID;
     _ctrlOrpDocSelection.name      = _ctrlIdOrpDocID;
     _ctrlOrpDocSelection.title     = @"Select order or prescription";
     _ctrlOrpDocSelection.dataURL   = _dataUrlSelectOrpDoc;
     _ctrlOrpDocSelection.dataParms = _dataParmsSelectOrpDoc;
     /* (event,ui) */
     _ctrlOrpDocSelection.onSelect  = @"$('#" + _ctrlHasOrpDocID.ID + @"').val('Y');";

     _orpDocSelectionCtrls.Add(_ctrlOrpDocSelection);
     
     var _orpDocSelectionCtrlsContainer = new Wrapper(@"div", _orpDocSelectionCtrls.ToArray());
     _orpDocSelectionCtrlsContainer.ID  = _entityControlID + @"_orpdocselections";
     _orpDocSelectionCtrlsContainer.cssClass = CSS_CLASS_ORP_DOCUMENT_SELECTION_CONTAINER;
    
    this._seAdditionalDependentControls.Add(_orpDocSelectionCtrlsContainer);

     /* Dynamically create js to handle interactions.  The functions are namespaced to this instance */

     string _fnNameClearSvcDetails                 = "fnClearSvcDetails_"               + _entityControlID;
     string _fnNameHideAndUnsetAdditionalDetails   = "fnHideAndUnsetAdditionalDetails"  + _entityControlID;
     string _fnNameClearOrpDocSelection            = "fnClearOrpDocSelection_"          + _entityControlID;
     string _fnNameShowAndSetSvcDetails            = "fnShowAndSetSvcDetails_"          + _entityControlID;
     string _fnNameHideAndUnsetSvcDetails          = "fnHideAndUnsetSvcDetails_"        + _entityControlID;
     string _fnNameShowAndSetOrpDocSelection       = "fnShowAndSetOrpDocSelection_"     + _entityControlID;
     string _fnNameHideAndUnsetOrpDocSelection     = "fnHideAndUnsetOrpDocSelection_"   + _entityControlID;
     string _fnNameShowOrHideAdditionalFields      = "fnShowOrHideAdditionalFields_"    + _entityControlID;
     string _fnNameClearSelectService              = "fnClearSelectService_"            + _entityControlID;
     string _fnNameInitSelectService               = "fnInitSelectService_"             + _entityControlID;
     
     writer.Write(@"<script type=""text/javascript"">");

     writer.Write(@"function " + _fnNameClearSvcDetails + @"(){");
     writer.Write(@"$('#" + _ctrlSvcDetFlag1.ID + @"').val('');");
     writer.Write(@"$('#" + _ctrlSvcDetFlag2.ID + @"').val('');");
     writer.Write(@"$('#" + _ctrlSvcDetFlag3.ID + @"').val('');");
     writer.Write(@"$('#" + _ctrlSvcDetFlag4.ID + @"').val('');");
     writer.Write(@"}");
     
     writer.Write(@"function " + _fnNameHideAndUnsetSvcDetails + @"(){");
     writer.Write(@"$('#" + _svcDetailFlagCtrlsContainer.ID + @"').hide();");
     writer.Write(_fnNameClearSvcDetails + @"();");
     writer.Write(@"$('#" + _ctrlHasSvcDetFlags.ID + @"').val('N');");
     writer.Write(@"}");

     writer.Write(@"function " + _fnNameShowAndSetSvcDetails + @"(){");
     writer.Write(@"$('#" + _svcDetailFlagCtrlsContainer.ID + @"').show();");
     writer.Write(_fnNameClearSvcDetails + @"();");
     writer.Write(@"$('#" + _ctrlHasSvcDetFlags.ID + @"').val('Y');");
     writer.Write(@"}");

     writer.Write(@"function " + _fnNameClearOrpDocSelection + @"(){");
     writer.Write(@"$('#" + _ctrlOrpDocSelection.ID + @"').val('');");
     writer.Write(@"$('#" + _ctrlHasOrpDocID.ID + @"').val('N');");
     writer.Write(@"}");

     writer.Write(@"function " + _fnNameHideAndUnsetOrpDocSelection + @"(){");
     writer.Write(@"$('#" + _orpDocSelectionCtrlsContainer.ID + @"').hide();");
     writer.Write(_fnNameClearOrpDocSelection + @"();");
     writer.Write(@"}");

     writer.Write(@"function " + _fnNameShowAndSetOrpDocSelection + @"(){");
     writer.Write(@"$('#" + _orpDocSelectionCtrlsContainer.ID + @"').show();");    
     writer.Write(_fnNameClearOrpDocSelection + @"();");
     writer.Write(@"}");
            
     writer.Write(@"function " + _fnNameShowOrHideAdditionalFields + @"(event,ui){"); 
        if (_promptForAdditionalServiceDetails == false) writer.Write(@"return;"); /* Add early exit if applicable */
        writer.Write(@"$('#" + _ctrlIdHasPatientGoalTrackingData + @"').val();");
        writer.Write(@"if (ui.item.showOptions2 == 'SHOW_SPEECH_ASSESS_OPTIONS') {");
        writer.Write(_fnNameHideAndUnsetOrpDocSelection + @"();"); 
        writer.Write(_fnNameShowAndSetSvcDetails + @"();");
       writer.Write(@"}");
       writer.Write(@"else if (ui.item.showOptions2 == 'SHOW_TREATMENT_ORP_DOC_SELECTION') {");
         writer.Write(_fnNameShowAndSetOrpDocSelection + @"();"); 
         writer.Write(_fnNameHideAndUnsetSvcDetails + @"();");
       writer.Write(@"}");
       writer.Write(@"else {");
         writer.Write(_fnNameHideAndUnsetOrpDocSelection + @"();");
         writer.Write(_fnNameHideAndUnsetSvcDetails + @"();");
       writer.Write(@"}"); 
     writer.Write(@"}");

     writer.Write(@"function " + _fnNameHideAndUnsetAdditionalDetails + @"(){");
     writer.Write(_fnNameHideAndUnsetSvcDetails + @"();");
     writer.Write(_fnNameHideAndUnsetOrpDocSelection + @"();");  
     writer.Write(@"}");
     
     writer.Write(@"function " + _fnNameClearSelectService + @"(){");
     writer.Write(_fnNameHideAndUnsetAdditionalDetails + @"();");     
     writer.Write(@"$('#" + _entityControlID + @"').spedmonSelectBox_clear();");
     writer.Write(@"$('#" + _entityControlID + @"').val('');");     
     writer.Write(@"}");
     
     writer.Write(@"function " + _fnNameInitSelectService + @"(){");     
     writer.Write(_fnNameHideAndUnsetAdditionalDetails + @"();");
     writer.Write(@"$('#" + _ctrlIdIsIep                    + @"').on('spedmoninput spedmoninputdata',function(){" + _fnNameClearSelectService + @"();});");
     writer.Write(@"$('#" + _ctrlIdViaTeleHealth            + @"').on('spedmoninput spedmoninputdata',function(){" + _fnNameClearSelectService + @"();});");
     writer.Write(@"$('#" + _ctrlIdSvcNamesListDataSourceID + @"').on('spedmoninput spedmoninputdata',function(){" + _fnNameClearSelectService + @"();});");
     writer.Write(@"}");     
     writer.Write(@"</script>");
     
     /* Get passed in handlers so we can append to the handlers we are dynamically adding */

     string _passedInSelectCtrlOnSelect    = this._selectCtrlOnSelect;
     string _passedInAdditionalOnDocReady  = this._additionalOnDocReady;
     
     /* Add our dynamically created handlers and any passed in handlers */

     this._selectCtrlOnSelect   = _fnNameShowOrHideAdditionalFields + @"(event,ui);" + _passedInSelectCtrlOnSelect;
     this._additionalOnDocReady = _fnNameInitSelectService          + @"();"         + _passedInAdditionalOnDocReady;

     //this._onSpedmonInputData = @"console.log(e);";
    
     base.Render(writer);
    
    }
  }
}
