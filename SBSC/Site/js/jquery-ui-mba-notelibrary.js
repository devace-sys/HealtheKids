/***************************************************************************
 * jquery-ui-mba-notelibrary.js */
/**
 * Saved note widget
 *
 * Requires jquery ui, jquery.MBA.common.js and jquery.MBA.webcontrols.js
 ***************************************************************************/   
 
;(function($){

$.widget("mba.notelibrary", {

// Default options.

options: {

  ns:"mba-notelibrary",
  icon:"ui-icon-note",
  label:"My Note Library",
  useLabelInOpenButton:true,
  displayMode:"auto",
  useMenu:false,
  showPreview:false,
  notefornamespacefn:function()     { return $('#notenamespace').val(); },
  noteforsourcefn:function()        { return $('#notesource').val();   },  
  noteforclientidfn:function()      { return $('#clientid').val();    },   
  noteforpracidfn:function()        { return $('#pracid').val();      }, 
  noteforpatidfn:function()         { return $('#patid').val();       },     
  noteforrefdatefn:function()       { return $('#dos').val();         },
  noteforgroupidfn:function()            { return '';                      },
  noteforsvcnamefn:function ()           { return ''; },
  noteforgrpsvcclassnameidfn:function () { return ''; },
  noteforstarttimefn:function ()         { return ''; },
  notefornumminsfn:function ()           { return ''; },
  noteforsvcnamelistdatasourceidfn:function () { return ''; },
  noteforhaspatientgoaltrackingfn: function () { return false; },
  noteforsetpatientgoaltrackingjsonfn:function()                 { return ''; },
  noteforgetpatientgoaltrackingjsonfn:function(goalTrackingJSON) { },
  noteforhassessionratingtrackingfn: function ()                 { return false; },
  noteforattendancestatusfn: function () { return '';},
  noteforrefrecid: function () { return ''; },
  additionalcontentfn:function($div) { },  
  nte_hist_enabled:true,
  nte_hist_lbl:"Note History For Selected Patient",
  nte_hist_icon:"ui-icon-disk",
  url_nte_hist:"servicerecords.asmx/viewLastSvcNotesAsOfRefDateInfoTable",      
  nte_upload_this_patient_enabled:true,
  nte_upload_this_patient_lbl:"Upload Notes for THIS Patient",
  nte_upload_this_patient_icon:"ui-icon-arrowstop-1-n",
  nte_upload_this_patient_url:"storedfileupload.ashx",
  nte_upload_this_patient_file_class:"100",
  
  nte_upload_any_patient_enabled:true,
  nte_upload_any_patient_lbl:"Upload Notes for MULTIPLE PATIENTS",
  nte_upload_any_patient_icon:"ui-icon-arrowthickstop-1-n",
  nte_upload_any_patient_url:"storedfileupload.ashx",  
  nte_upload_any_patient_file_class:"1000",
  
  sel_tmp_enabled:true,
  sel_tmp_icon:"ui-icon-document",
  sel_tmp_lbl:"Select Note Template",
  url_sel_tmp:"note_library_templates.asmx/viewSel",
  
  sel_svd_enabled:true,
  sel_svd_icon:"ui-icon-bookmark",
  sel_svd_lbl:"Select From Favorites",
  sel_svd_cbx_lbl:"Only Show Notes for Selected Patient",
  url_sel_svd:"note_library_saved_notes.asmx/viewSel",
  
  add_svd_enabled:true,
  add_svd_icon:"ui-icon-circle-plus",
  add_svd_lbl:"Save This Note To Favorites",
  url_add_svd:"note_library_saved_notes.asmx/save",
 
  rem_svd_enabled:true,
  rem_svd_lbl:"Remove this Saved Note",
  rem_svd_icon:"ui-icon-circle-minus",
  url_rem_svd:"note_library_saved_notes.asmx/delete",
  tmpSelMkupAppendTo: 'body',
  svcSelMkupAppendTo: 'body',

  goal_progress_enabled:true,
  goal_progress_lbl:"View Current Progress For All Goals",
  url_view_all_patient_goals_progress: "",

  export_note_data_enabled: false,
  url_export_note_data: "user_all_note_library_export_note.aspx",
  exportnotedatapopulateformparmsfn: function ($form, objNoteExportCommonData) { return; },

  fillable_pdf_selections_enabled: false,
  fnNoteHasFillablePdfSelections: function () { return false; },
  fnNoteSetFillablePdfSelectionsJSON: function () { return '[]'; },		
  fnNoteGetFillablePdfAnswersJSON: function (fillablePdfAnswersJSON) { },
  fnNoteSetFillablePdfAnswersJSON: function () { return '[]'; },  
  urlNoteSvcRecFillablePdfSave: "user_all_svcrec_fillable_pdf_save.aspx"  
},
  

_create: function() {	    	

  
  /*============================================================
   * Init
   *============================================================*/ 

  var me                  = $(this.element);
  var me_id               = $(me).attr('id');
  var me_opts             = this.options;
  var meMainDiaRef        = null;

  var me_ns          = this.options.ns;
  var displayMode    = this.options.displayMode;
  var useMenu        = this.options.useMenu;
  var showPreview    = this.options.showPreview;  	
  var nteHistEnabled = this.options.nte_hist_enabled;
  var selTmpEnabled  = this.options.sel_tmp_enabled;
  var selSvdEnabled  = this.options.sel_svd_enabled;
  var addSvdEnabled  = this.options.add_svd_enabled;
  var remSvdEnabled  = this.options.rem_svd_enabled;
  
  var uploadNoteThisPatEnabled    = this.options.nte_upload_this_patient_enabled;
  var uploadNoteAnyPatientEnabled = this.options.nte_upload_any_patient_enabled;

  var goalProgressEnabled          = this.options.goal_progress_enabled;
  var exportNoteDataEnabled        = this.options.export_note_data_enabled;
  var fillablePdfSelectionsEnabled = this.options.fillable_pdf_selections_enabled;

  /*============================================================
   * Determine display mode
   *============================================================*/ 

  if (displayMode == "auto") {
    /* Determine if we use options menu and menu button or options rendered above original html */
   
    if      ($(me).is('textarea')) { useMenu = false; }
    else if ($(me).is('input'))    { useMenu = true;  }
    else                           { useMenu = true;  }  
  }

  /*============================================================
   * Create urls
   *============================================================*/ 

  if (nteHistEnabled) {
    this.options.url_nte_hist = $.spedmonWebUI.createPrivateURL (this.options.tkn,this.options.url_nte_hist);
  }
  
  
  this.options.nte_upload_this_patient_url  = $.spedmonWebUI.createPrivateURL (this.options.tkn, this.options.nte_upload_this_patient_url);
  this.options.nte_upload_any_patient_url   = $.spedmonWebUI.createPrivateURL (this.options.tkn, this.options.nte_upload_any_patient_url);
  this.options.url_sel_tmp                  = $.spedmonWebUI.createPrivateURL (this.options.tkn, this.options.url_sel_tmp);
  this.options.url_sel_svd                  = $.spedmonWebUI.createPrivateURL (this.options.tkn, this.options.url_sel_svd);
  this.options.url_add_svd                  = $.spedmonWebUI.createPrivateURL (this.options.tkn, this.options.url_add_svd); 
  this.options.url_rem_svd                  = $.spedmonWebUI.createPrivateURL (this.options.tkn, this.options.url_rem_svd); 
  this.options.urlNoteSvcRecFillablePdfSave = $.spedmonWebUI.createPrivateURL (this.options.tkn, this.options.urlNoteSvcRecFillablePdfSave);
  
  /*============================================================
   * Create fn pointers to delegates to get notenamespace,
   * notesource, client, prac and pat id
   *============================================================*/ 

  var fnNoteForNamespace                  = this.options.notefornamespacefn;
  var fnNoteForSource                     = this.options.noteforsourcefn;
  var fnNoteForClientID                   = this.options.noteforclientidfn;
  var fnNoteForPracID                     = this.options.noteforpracidfn;
  var fnNoteForPatID                      = this.options.noteforpatidfn;
  var fnNoteForRefDate                    = this.options.noteforrefdatefn;
  var fnNoteForGroupID                    = this.options.noteforgroupidfn;  /* Note: The value for group family is being passed on some screens */
  var fnNoteForGrpSvcClassNameID          = this.options.noteforgrpsvcclassnameidfn; /* Note: This is a dedicated field for group family */
  var fnNoteForSvcName                    = this.options.noteforsvcnamefn;
  var fnNoteForStartTime                  = this.options.noteforstarttimefn;
  var fnNoteForNumMins                    = this.options.notefornumminsfn;
  var fnNoteForSvcNameListDataSource      = this.options.noteforsvcnamelistdatasourceidfn;

  var fnNoteForPatientGoalTracking        = this.options.noteforhaspatientgoaltrackingfn;
  var fnNoteForSetPatientGoalTrackingJSON = this.options.noteforsetpatientgoaltrackingjsonfn;
  var fnNoteForGetPatientGoalTrackingJSON = this.options.noteforgetpatientgoaltrackingjsonfn;
  var fnNoteForHasSessionRatingTracking   = this.options.noteforhassessionratingtrackingfn;
  var fnNoteHasFillablePdfSelections      = this.options.fnNoteHasFillablePdfSelections;  
  var fnNoteSetFillablePdfSelectionsJSON  = this.options.fnNoteSetFillablePdfSelectionsJSON;
  var fnNoteSetFillablePdfAnswersJSON     = this.options.fnNoteSetFillablePdfAnswersJSON;
  var fnNoteGetFillablePdfAnswersJSON     = this.options.fnNoteGetFillablePdfAnswersJSON;
  var messageChannelForFillablePDFsName   = 'msg-channel-for-fillable-pdfs-' + me_id;
  var messageChannelForFillablePDFs       = null;
  var fillablePdfSelectionsJSON           = null;
  var fillablePdfSelectionsArr            = null;
  var fillablePdfAnswersJSON              = null;
  var fillablePdfAnswersArr               = null;
  var fnAdditionalContent                 = this.options.additionalcontentfn;

  /*============================================================
   * Create fn to get namespace, source, client, prac, pat id 
   * and check them
   *============================================================*/ 
  
  var fnGetAndCheckNamespaceSourceClientPracPat = function () {
  
    var ro = {};
    
	ro.entitiesOK = true;
	ro.messages   = [];
	
	ro.noteNamespaceOK = true;
	ro.noteSourceOK    = true;
	ro.clientOK        = true;
	ro.pracOK          = true;
	ro.patOK           = true;	
	
	ro.noteNamespace   = fnNoteForNamespace();
	ro.noteSource      = fnNoteForSource();
	ro.clientID        = fnNoteForClientID();
	ro.pracID          = fnNoteForPracID();
	ro.patID           = fnNoteForPatID();
	
	if (!ro.noteNamespace)      ro.noteNamespaceOK = false;
	if (ro.noteNamespace == '') ro.noteNamespaceOK = false;
	
	if (!ro.noteSource)         ro.noteSourceOK    = false;
	if (ro.noteSource == '')    ro.noteSourceOK    = false;
	
	if (!ro.clientID)           ro.clientOK = false;
	if (ro.clientID == '')      ro.clientOK = false;
	
	if (!ro.pracID)             ro.pracOK   = false;
	if (ro.pracID == '')        ro.pracOK   = false;
	
	if (!ro.patID)              ro.patOK    = false;
	if (ro.patID == '')         ro.patOK    = false;
    
    ro.entitiesOK = ro.noteNamespaceOK && ro.noteSourceOK && ro.clientOK && ro.pracOK && ro.patOK;
	
	if (!ro.entitiesOK) {
	
	  ro.messages = [];
	  
	  if (!ro.noteNamespaceOK) ro.messages.push("Notes library not setup properly for this page");
	  if (!ro.noteSourceOK)    ro.messages.push("Notes library not setup properly for this page");	  
	  if (!ro.clientOK)        ro.messages.push("Please select a client");
	  if (!ro.pracOK)          ro.messages.push("Please select a practitioner");
	  if (!ro.patOK)           ro.messages.push("Please select a patient");	  
	}
	
	ro.displayMessages = function () {
	  var nte_val_msgs_cls  = me_ns + '-nte-val-msgs';
	  msgHtml = '<ul class="' + nte_val_msgs_cls +'">';
	  $.each(ro.messages,function(idx,message) {
	    msgHtml = msgHtml + '<li>' + message + '</li>';
	  });
	  msgHtml = msgHtml + '</ul>';
	  
	  $.spedmonWebUI.dialogMessage (me_opts.label,msgHtml,true,300,300,null);
	};
	
	return ro;
  };

 /*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Create fn to get client, prac, pat id, and note text
   * and check them
   *============================================================*/ 
  
  var fnGetAndCheckNamespaceSourceClientPracPatNote = function (note_text) {
    var ro = {};
    ro = fnGetAndCheckNamespaceSourceClientPracPat();
    ro.noteOK = true;
    if (!note_text)      ro.noteOK    = false;
    if (note_text == '') ro.noteOK    = false;	
    ro.entitiesOK = ro.noteNamespaceOK && ro.noteSourceOK && ro.clientOK && ro.pracOK && ro.patOK && ro.noteOK;
	if (!ro.entitiesOK) {
	  if (!ro.noteOK) ro.messages.push("Please enter or select a note");
	}
	else {
	  ro.noteText = $.spedmonWebUI.jsonStringEscape(note_text);
	}
    return ro;	
  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

 /*============================================================
  * Create get note history function
  *============================================================*/ 

 var urlNteHist = this.options.url_nte_hist;
 
 var fnGetNoteHist = function() {
    fnCloseOptionsMenuIfUsed();
	var eo = fnGetAndCheckNamespaceSourceClientPracPat();
	if (eo.entitiesOK) {	

       var url            = urlNteHist;
	   var refDates       = fnNoteForRefDate();	   
	   var refDate        = $.spedmonWebUI.getEarliestOrLatestDate(refDates,'latest',',');
	   var $data          = '{' 
		 				  + '"clientid":"'   + eo.clientID      +'"'
						  + ',"pracid":"'    + eo.pracID        +'"'
						  + ',"patid":"'     + eo.patID         +'"'
	                      + ',"refdate":"'   + refDate          +'"'
					      + '}'; 

	   var nteHistLabel  = "";
	   var nteHistTblStr = "";
	   
       $.spedmonWebUI.ajax( null
	                      , url
						  , $data
						  , null
						  , null
						  , function(rd) { nteHistLabel = rd.data.caption; nteHistTblStr = $.spedmonWebUI.ReturnInfoTableRenderHTMLTableString(rd.data,'No Notes');}
						  , null
						  , null
						  , 0
						  , function() { $.spedmonWebUI.dialogMessage(nteHistLabel, nteHistTblStr, true, 800, 400);}
						  );
	}
	else {
	  eo.displayMessages();
	}
 }

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/*============================================================
  * Create upload notes for this patient function
  *============================================================*/ 

 var urlUploadNotesThisPat = this.options.nte_upload_this_patient_url;
 var lblUploadNotesThisPat = this.options.nte_upload_this_patient_lbl;
 var fcUploadNotesThisPat  = this.options.nte_upload_this_patient_file_class;
 
 var fnUploadNotesForThisPatient = function() {
    fnCloseOptionsMenuIfUsed();
	var eo = fnGetAndCheckNamespaceSourceClientPracPat();
	if (eo.entitiesOK) {	
	   var refDates       = fnNoteForRefDate();	   
	   var refDate        = $.spedmonWebUI.getEarliestOrLatestDate(refDates,'latest',',');
	   
	   var fileAdditionalDataJSONStr  = '{' 
		 				  + '"clientid":"'   + eo.clientID      +'"'
						  + ',"pracid":"'    + eo.pracID        +'"'
						  + ',"patid":"'     + eo.patID         +'"'
	                      + ',"refdate":"'   + refDate          +'"'
					      + '}'; 

	    $.spedmonWebUI.fileUpload (   lblUploadNotesThisPat
		 							, urlUploadNotesThisPat
									, fcUploadNotesThisPat
									, ''
                                    , 'noteslib'
                                    , ''									   
									, fileAdditionalDataJSONStr
									, true
			                        , null
									, true /* Confidential */
								  );
	}
	else {
	  eo.displayMessages();
	}
 };
   
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/*============================================================
  * Create upload notes for any patient function
  *============================================================*/ 

 var urlUploadNotesAnyPat = this.options.nte_upload_any_patient_url;
 var lblUploadNotesAnyPat = this.options.nte_upload_any_patient_lbl;
 var fcUploadNotesAnyPat  = this.options.nte_upload_any_patient_file_class;
 
 var fnUploadNotesForAnyPatient = function() {
     fnCloseOptionsMenuIfUsed();
	   
	 var fileAdditionalDataJSONStr = '{}'; 

	 $.spedmonWebUI.fileUpload (  lblUploadNotesAnyPat
		 						, urlUploadNotesAnyPat
								, fcUploadNotesAnyPat
								, ''
                                , 'noteslib'
                                , ''									   
								, fileAdditionalDataJSONStr
								, true
		                        , null
		                        , false /* Confidential */
							   );
  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Create add function
   *============================================================*/ 

  var urlAddSaved  = this.options.url_add_svd;
    
  var fnSaveNote   = function (note_text) {
	
	var eo = fnGetAndCheckNamespaceSourceClientPracPatNote (note_text);
	
	if (!eo.entitiesOK) {
	  eo.displayMessages();
	  return;
	}
		
	var url              = urlAddSaved;    
	var editDelReason    = ''
    var validaterec      = '0';
    var savetype         = '1';
    var recid            = ''  
    
    var $data          = '{' 
		 				  + ' "notetext":'       + eo.noteText 
			 			  + ',"notenamespace":"' + eo.noteNamespace +'"'
						  + ',"notesource":"'    + eo.noteSource    +'"'
						  + ',"clientid":"'      + eo.clientID      +'"'
						  + ',"pracid":"'        + eo.pracID        +'"'
						  + ',"patid":"'         + eo.patID         +'"'
	                      + ',"editDelReason":"' + editDelReason    +'"'
						  + ',"validaterec":"'   + validaterec      +'"'
						  + ',"savetype":"'      + savetype         +'"'
						  + ',"recid":"'         + recid            +'"'
					      + '}'; 
	
	$.spedmonWebUI.ajax(null, url, $data, null, null, null, null, null, 0, null, null, null);
    
	return;         
  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Create remove function
   *============================================================*/ 

  var urlRemSaved  = this.options.url_rem_svd;
  
  var fnDeleteNote = function (nte_id) {

    if (!nte_id)     return;
    if (nte_id <= 0) return;
  
    var url            = urlRemSaved;
    var editDelReason  = ''
    var validaterec    = '0';
    var recid          = nte_id;
	var $data = "{'editDelReason':'" + editDelReason + "','validaterec':'" + validaterec + "','recid':'" + recid + "'}";
	$.spedmonWebUI.ajax(null, url, $data, null, null, null, null, null, 0, null, null, null);    
    return;
  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Create patient goals progress function
   *============================================================*/

  var urlViewAllPatientGoalsProgress = this.options.url_view_all_patient_goals_progress;
  
  var fnOpenPatientGoalsProgress = function () {
	var clientid = fnNoteForClientID();
	var patid = fnNoteForPatID();
	var refDate = fnNoteForRefDate();

	var reqUrl = urlViewAllPatientGoalsProgress
		  + '&clientid=' + clientid
		  + '&patid='    + patid
		  + '&refdate=' + refDate;

	  MBA.ComponentCommon.fnOpenWindow(reqUrl);

    return;
  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Create note export functions
  *============================================================*/

  var urlOpenNoteExport                 = this.options.url_export_note_data;
  var fnExportNoteDataPopulateFormParms = this.options.exportnotedatapopulateformparmsfn;
  var objNoteExportCommonData           = {};

  /* Add additional "noteFor" methods as needed to this obj to match expansion of note lib options */

  objNoteExportCommonData.fnNoteForClientID        = this.options.noteforclientidfn;
  objNoteExportCommonData.fnNoteForPracID          = this.options.noteforpracidfn;
  objNoteExportCommonData.fnNoteForPatID           = this.options.noteforpatidfn;
  objNoteExportCommonData.fnNoteForRefDate         = this.options.noteforrefdatefn;
  objNoteExportCommonData.fnNoteForSvcName         = this.options.noteforsvcnamefn;
  objNoteExportCommonData.fnNoteHasPatGoalTracking = this.options.noteforhaspatientgoaltrackingfn;
	
  objNoteExportCommonData.fnNoteGetPatGoalTrackingData = function () {
	    if (fnNoteForPatientGoalTracking() === true) {
			let preloadedJSONVal = fnNoteForSetPatientGoalTrackingJSON();
			if (!preloadedJSONVal) return '[]';
			return preloadedJSONVal;
		}
		return '[]';
  };
   
  objNoteExportCommonData.fnOriginalNoteID = function () { return me_id; }

  var fnOpenNoteExport = function () {
	  let $exportNoteForm = $('<form target="_blank" rel="opener" method="post" style="display:none;height:0;"></form>');
	  $($exportNoteForm).attr('action', urlOpenNoteExport);
	  fnExportNoteDataPopulateFormParms($exportNoteForm, objNoteExportCommonData);
	  $($exportNoteForm).appendTo('body').submit().remove();
  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Create markup for Note Options (1/2)
   *============================================================*/ 
  
  var nte_opts_ns              = me_ns + '-nte-opts';
  
  /* Note options open button */
  
  var nte_opts_but_opn_ns      = nte_opts_ns + '-but-opn';
  var nte_opts_but_opn_cls     = me_ns + ' ' + nte_opts_but_opn_ns;
  var nte_opts_but_opn_id      = nte_opts_but_opn_ns + '-' + me_id;
  var nte_opts_but_opn_mkup    = '<button id="' + nte_opts_but_opn_id + '" type="button" title="' + this.options.label + '" class="' + nte_opts_but_opn_cls + '"><i class="fas fa-clipboard ' + nte_opts_but_opn_cls + '"></i></button>';
  
  /* Note options container */
  
  var nte_opts_cont_ns         = nte_opts_ns + '-cont';
  var nte_opts_cont_cls        = me_ns + ' ' + nte_opts_cont_ns;
  var nte_opts_cont_id         = nte_opts_cont_ns + '-' + me_id;
  var nte_opts_cont_mkup_start = '<div id="' + nte_opts_cont_id + '" class="' + nte_opts_cont_cls + '" title="' + this.options.label + '">';
  var nte_opts_cont_mkup_end   = '</div>';

  /* Note options form */

  var nte_opts_form_ns = nte_opts_ns + '-form';
  var nte_opts_form_cls = me_ns + ' ' + nte_opts_form_ns;
  var nte_opts_form_id = nte_opts_form_ns + '-' + me_id;
  var nte_opts_form_mkup_start_for_Preview = '<div id="' + nte_opts_form_id + '" class="' + nte_opts_form_cls + " " + nte_opts_form_cls + "-preview" + '" title="' + this.options.label + '" data-spy="scroll"  data-offset="20" data-target="#spedmon-form-builder-patient-goals-review-id-' + me_id + '">';
  var nte_opts_form_mkup_start = '<div id="' + nte_opts_form_id + '" class="' + nte_opts_form_cls + '" title="' + this.options.label + '">';
  var nte_opts_form_mkup_end = '</div>';
  
  /* Note options review */
  
  var nte_opts_review_ns = nte_opts_ns + '-review';
  var nte_opts_review_cls = me_ns + ' ' + nte_opts_review_ns;
  var nte_opts_review_id = 'spedmon-form-builder-patient-goals-review-id';
  var nte_opts_review_instance_id = nte_opts_review_id + '-' + me_id;
  var nte_opts_review_mkup_start = '<div id="' + nte_opts_review_instance_id + '" class="' + nte_opts_review_cls + '" title="' + this.options.label + '">';
  var nte_opts_review_mkup_end = '</div>';

  /* Note options label */
  
  var nte_opts_lbl_ns          = nte_opts_ns + '-lbl';
  var nte_opts_lbl_cls         = me_ns + ' ' + nte_opts_lbl_ns;
  var nte_opts_lbl_id          = nte_opts_lbl_ns + '-' + me_id;
  var nte_opts_lbl_mkup        = '<div id="' + nte_opts_lbl_id + '" class="' + nte_opts_lbl_cls + '">' + this.options.label + '</div>';
  
  /* Note options fieldset */

  var nte_opts_fset_ns         = nte_opts_ns + '-fset';
  var nte_opts_fset_cls        = me_ns + ' ' + nte_opts_fset_ns;
  var nte_opts_fset_id         = nte_opts_fset_ns + '-' + me_id;
  var nte_opts_fset_mkup_start = '<fieldset id="' + nte_opts_fset_id + '" class="' + nte_opts_fset_cls +'">';
  var nte_opts_fset_mkup_end   = '</fieldset>';

  /* Fillable PDF section */

  var nte_fillable_pdf_selections_ns = nte_opts_ns + '-fillable-pdf-selections';
  var nte_fillable_pdf_selections_section_id = nte_fillable_pdf_selections_ns + '-' + me_id;
  var nte_fillable_pdf_selections_section_mkup = '<span id="' + nte_fillable_pdf_selections_section_id + '"></span>';

  /* Note patient goal tracking */

  var nte_pat_goal_tracking_ns   = nte_opts_ns + '-patient-goal-tracking';
  var nte_pat_goal_tracking_id   = nte_pat_goal_tracking_ns + '-' + me_id;
  var nte_pat_goal_tracking_mkup = '<div id="' + nte_pat_goal_tracking_id + '" class="mt-2"></div>';

  /* Note additional content */

  var nte_add_content_ns       = nte_opts_ns + '-additional-content';
  var nte_add_content_id       = nte_add_content_ns + '-' + me_id;
  var nte_add_content_mkup     = '<div id="' + nte_add_content_id + '" class="mt-2"></div>';                               
  
  /* Note secondary text area */
  
  var nte_ta_sec_ns            = nte_opts_ns + '-ta-sec';
  var nte_ta_sec_cls           = me_ns + ' ' + nte_ta_sec_ns;
  var nte_ta_sec_id            = nte_ta_sec_ns + '-' + me_id;
  var nte_ta_sec_mkup          = '<p>Only text entered in the field below can be saved to your documentation library favorites.</p><textarea id="' + nte_ta_sec_id + '" class="' + nte_ta_sec_cls + '" placeholder="Enter new documentation here" rows="5" wrap="hard" maxlength="4000"></textarea>';                               

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Create markup for Viewing Note History
   *============================================================*/ 
  
  var nte_hist_ns               = me_ns + '-nte_hist';
  
  /* Note history open button */
  
  var nte_hist_but_opn_ns       = nte_hist_ns + '-but-opn';
  var nte_hist_but_opn_cls      = me_ns + ' ' + nte_hist_but_opn_ns;
  var nte_hist_but_opn_id       = nte_hist_but_opn_ns + '-' + me_id;
  var but_opn_nte_hist_mkup     = '<i id="' + nte_hist_but_opn_id + '" class="fas fa-book"></i>';

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

 /*============================================================
   * Create markup for Uploading Notes for This Patient
   *============================================================*/ 
  
  var nte_upload_this_pat_ns               = me_ns + '-nte_upload_this_pat';
  
  /* Note upload button this patient */
  
  var nte_upload_this_pat_but_opn_ns       = nte_upload_this_pat_ns  + '-but-opn';
  var nte_upload_this_pat_but_opn_cls      = me_ns + ' ' + nte_upload_this_pat_but_opn_ns;
  var nte_upload_this_pat_but_opn_id       = nte_upload_this_pat_but_opn_ns + '-' + me_id;
  var but_nte_upload_this_pat_mkup         = '<i id="' + nte_upload_this_pat_but_opn_id + '" class="fas fa-upload"></i>';

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Create markup for Uploading Notes for ANY Patient
   *============================================================*/ 
  
  var nte_upload_any_pat_ns               = me_ns + '-nte_upload_any_pat';
  
  /* Note upload button any patient */
  
  var nte_upload_any_pat_but_opn_ns       = nte_upload_any_pat_ns  + '-but-opn';
  var nte_upload_any_pat_but_opn_cls      = me_ns + ' ' + nte_upload_any_pat_but_opn_ns;
  var nte_upload_any_pat_but_opn_id       = nte_upload_any_pat_but_opn_ns + '-' + me_id;
  var but_nte_upload_any_pat_mkup         = '<i id="' + nte_upload_any_pat_but_opn_id + '" class="fas fa-users"></i>';
 
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

 /*============================================================
   * Create markup for Select Note Template
   *============================================================*/ 
    
  var tmp_sel_ns               = me_ns + '-tmp-sel';
    
  /* Select note template open button */
  
  var tmp_sel_but_opn_ns       = tmp_sel_ns + '-but-opn';
  var tmp_sel_but_opn_cls      = me_ns + ' ' + tmp_sel_but_opn_ns;
  var tmp_sel_but_opn_id       = tmp_sel_but_opn_ns + '-' + me_id;
  var but_opn_sel_tmp_mkup     = '<i id="' + tmp_sel_but_opn_id + '" class="fas fa-paste"></i>';
 
  /* Select note template container */
  
  var tmp_sel_cont_ns          = tmp_sel_ns + '-cont';
  var tmp_sel_cont_cls         = me_ns + ' ' + tmp_sel_cont_ns;
  var tmp_sel_cont_id          = tmp_sel_cont_ns + '-' + me_id;
  var tmp_sel_cont_mkup_start  = '<div id="' + tmp_sel_cont_id  + '" class="' + tmp_sel_cont_cls + '" title="' + this.options.sel_tmp_lbl +'">';  
  var tmp_sel_cont_mkup_end    = '</div>';

  /* Select note template selectbox input */

  var tmp_sel_inp_ns           = tmp_sel_ns + '-selectbox-inp';
  var tmp_sel_inp_cls          = 'mba-web-ui-field-simple ' + me_ns + ' ' + tmp_sel_inp_ns;
  var tmp_sel_inp_id           = tmp_sel_inp_ns + '-' + me_id;
  var tmp_sel_inp_mkup         = '<input id="' + tmp_sel_inp_id + '" class="' + tmp_sel_inp_cls + '" title="Enter all or part of name" type="text"/>';
  
  /* Select note template markup */
  
  var tmp_sel_mkup = tmp_sel_cont_mkup_start
                   + tmp_sel_inp_mkup
				   + tmp_sel_cont_mkup_end;

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Create markup for Select Saved Note 
   *============================================================*/ 
  
  var svd_sel_ns               = me_ns + '-svd-sel';
  
  /* Select saved note open button */
  
  var svd_sel_but_opn_ns       = svd_sel_ns + '-but-opn';
  var svd_sel_but_opn_cls      = me_ns + ' ' + svd_sel_but_opn_ns;
  var svd_sel_but_opn_id       = svd_sel_but_opn_ns + '-' + me_id;
  var but_opn_sel_svd_mkup     = '<i id="' + svd_sel_but_opn_id + '" class="fas fa-sticky-note"></i>';
 
  /* Select saved note container */
  
  var svd_sel_cont_ns          = svd_sel_ns + '-cont';
  var svd_sel_cont_cls         = me_ns + ' ' + svd_sel_cont_ns;
  var svd_sel_cont_id          = svd_sel_cont_ns + '-' + me_id;
  var svd_sel_cont_mkup_start  = '<div id="' + svd_sel_cont_id  + '" class="' + svd_sel_cont_cls + '" title="' + this.options.sel_svd_lbl +'">';  
  var svd_sel_cont_mkup_end    = '</div>';

  /* Select saved note filter */
  
  var svd_sel_cbx_ns           = svd_sel_ns + '-selectbox-cbx';
  var svd_sel_cbx_cls          = 'mba-web-ui-field-simple ' + me_ns + ' ' + svd_sel_cbx_ns;
  var svd_sel_cbx_id           = svd_sel_cbx_ns + '-' + me_id;
  var svd_sel_cbx_mkup         = '<label class="' + svd_sel_cbx_cls + '">' + this.options.sel_svd_cbx_lbl + '<input id="' + svd_sel_cbx_id + '" class="' + svd_sel_cbx_cls + '" checked="checked" type="checkbox"/></label>';
  
  /* Select saved note selectbox input */
  
  var svd_sel_inp_ns           = svd_sel_ns + '-selectbox-inp';
  var svd_sel_inp_cls          = 'mba-web-ui-field-simple ' + me_ns + ' ' + svd_sel_inp_ns;
  var svd_sel_inp_id           = svd_sel_inp_ns + '-' + me_id;
  var svd_sel_inp_mkup         = '<input id="' + svd_sel_inp_id + '" class="' + svd_sel_inp_cls + '" title="Enter all or part of name" type="text"/>';
  
  // Saved selection item label and context (divs)
  
  var svd_sel_item_ns            = svd_sel_ns + '-selection-item';
  
  var svd_sel_item_link_cls      = me_ns + ' ' + svd_sel_item_ns + '-link';    // Anchor
  var svd_sel_item_label_cls     = me_ns + ' ' + svd_sel_item_ns + '-label';   // Div 
  var svd_sel_item_context_cls   = me_ns + ' ' + svd_sel_item_ns + '-context'; // Div
  var svd_sel_item_remv_cls      = me_ns + ' ' + svd_sel_item_ns + '-remove';  // Button
  
  var svd_sel_mkup = svd_sel_cont_mkup_start
			       + svd_sel_cbx_mkup
	               + svd_sel_inp_mkup
				   + svd_sel_cont_mkup_end;
	
  /*============================================================
   * Create markup for Add Saved Note
   *============================================================*/ 
  
  /* Add saved note */
  
  var svd_add_ns               = me_ns      + '-svd-add';
  
  /* Add saved note open button */
  
  var svd_add_but_act_ns       = svd_add_ns + '-but-act';
  var svd_add_but_act_cls      = me_ns + ' ' + svd_add_but_act_ns;
  var svd_add_but_act_id       = svd_add_but_act_ns + '-' + me_id;
  var but_act_add_svd_mkup     = '<i id="' + svd_add_but_act_id + '" class="fas fa-save"></i>';

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Create markup for Patient Goal Progress
   *============================================================*/ 
  
  var goal_progress_ns           = me_ns      + '-goal-progress';
  
  /* Add goal progress button */
  
  var goal_progress_but_opn_ns   = goal_progress_ns + '-but-opn';
  var goal_progress_but_opn_cls  = me_ns + ' ' + goal_progress_but_opn_ns;
  var goal_progress_but_opn_id   = goal_progress_but_opn_ns + '-' + me_id;
  var but_nte_goal_progress_mkup = '<i id="' + goal_progress_but_opn_id + '" class="fas fa-chart-line"></i>';

  /*============================================================
   * Create markup for note export
   *============================================================*/

  /* Add export note data */

  var export_note_ns         = me_ns + '-note-export';
  var export_note_but_opn_ns = export_note_ns + '-but-opn';  
  var export_note_but_opn_id = export_note_but_opn_ns + '-' + me_id;
  var but_export_note_mkup = '<i id="' + export_note_but_opn_id + '" title="Export This Note" class="fas fa-file-pdf ml-1" style="color:red"></i>';

  /*============================================================
   * Note Options Part (2/2)
   *============================================================*/ 
  
	var nte_opts_cont_mkup = nte_opts_cont_mkup_start
		                 + ((showPreview) ? nte_opts_form_mkup_start_for_Preview : nte_opts_form_mkup_start)
                         + ((useMenu) ? "" : nte_opts_lbl_mkup)
                         + nte_opts_fset_mkup_start
						 + ((nteHistEnabled) ? but_opn_nte_hist_mkup : "")						
						 + ((selTmpEnabled)  ? but_opn_sel_tmp_mkup  : "")
                         + ((addSvdEnabled)  ? but_act_add_svd_mkup  : "")
						 + ((selSvdEnabled)  ? but_opn_sel_svd_mkup  : "")
						 + ((uploadNoteThisPatEnabled)    ? but_nte_upload_this_pat_mkup : "")
						 + ((uploadNoteAnyPatientEnabled) ? but_nte_upload_any_pat_mkup  : "")
						 + ((goalProgressEnabled) ? 
							// only show icon if url is passed in
							(urlViewAllPatientGoalsProgress) ? but_nte_goal_progress_mkup : ""   
							: ""
						   )
		                 + ((exportNoteDataEnabled) ? but_export_note_mkup : "")
		                 + nte_fillable_pdf_selections_section_mkup
		                 + nte_opts_fset_mkup_end		                 
		                 + nte_pat_goal_tracking_mkup
					     + nte_add_content_mkup
						 + ((useMenu) ? nte_ta_sec_mkup : "")
						 + nte_opts_form_mkup_end
						 + ((showPreview) ?
							// only show preview pane if showPreview = true
							  nte_opts_review_mkup_start
							+ nte_opts_review_mkup_end
							: ""
						   )
						 + nte_opts_cont_mkup_end;

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Generate helper functions 
   *============================================================*/   

  var fnCloseOptionsMenuIfUsed  = function() { 
    if (useMenu == true) 
	  $('#' + nte_opts_cont_id).dialog('close'); 
  };
  
  var fnOpenOptionsMenuIfUsed = function () {
    if (useMenu == true)
	  $('#' + nte_opts_cont_id).dialog('open'); 
  };
  
  var fnUpdateSecondaryTaIfUsed = function() { 
    if (useMenu == true) {
      $('#' + nte_ta_sec_id).val($('#' + me_id).val()).change();
  }};
  
  var fnFocusOnSecondaryTaIfUsed = function () {
   if (useMenu == true) {
      //$('#' + nte_ta_sec_id).focus().click();
  }};

  var fnRenderQuestionAndAnswersToHTMLObj = function (reviewId, formQuestionsJSON, formAnswersJSON, goalTrackingJSON, retryCount) {
	renderQuestionAndAnswersToHTMLObj(reviewId, formQuestionsJSON, formAnswersJSON, goalTrackingJSON, retryCount);
  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Generate patient goal tracking feature 
   *============================================================*/

  var _patGoalContCssClass							= 'mba-notelibrary-pat-goal-cont';      /* Contains all goals */
  var _patGoalClass                                 = 'mba-notelibrary-pat-goal';           /* Goal*/
  var _patGoalSelectionClass                        = 'mba-notelibrary-pat-goal-selection'; /* Needed to isolate in jquery selections used by note preview */
  var _patGoalSelectClass                           = 'mba-notelibrary-pat-goal-select' + '-' + me_id; // given to each dropdown (so we can use a foreach loop)
  var _patGoalInputsDivClass                        = 'mba-notelibrary-pat-goal-input-cont';
  var _patGoalTotalAttemptsClass					= 'mba-notelibrary-pat-goal-input-total-attempts'; // class to identify total attempts input field
  var _patGoalSuccessfulAttemptsClass				= 'mba-notelibrary-pat-goal-input-successful-attempts'; // class to identify successful attempts input field
  var _patGoalAccuracyClass							= 'mba-notelibrary-pat-goal-input-accuracy'; // class to identify accuracy % input field
  var _pracSessionRatingClass						= 'mba-notelibrary-pat-goal-input-pracSessionRating'; // class to identify accuracy % input field
  var _patSessionRatingClass						= 'mba-notelibrary-pat-goal-input-patSessionRating'; // class to identify accuracy % input field
  var _patGoalInputGoalProgressUsingWhatClass		= 'mba-notelibrary-pat-goal-input-input-goal-progress-using-what';
  var _patGoalTypeClass								= 'mba-notelibrary-pat-goal-type';
  var _patGoalAttrInputGoalProgressUsingWhat		= 'data-input-goal-progress-using-what';
  var _patGoalAttrGoalType							= 'data-input-goal-type';
  var _patGoalAttrSelectionSource					= 'data-patient-goal-selection-source';  //1 = Patient Goal Library	2 = Imported From SpEd System

  var _patGoalAttrGoalMet							= 'data-goal-met';
  var _patGoalAttrGoalMetOn							= 'data-goal-met-on';
  var _patGoalAttrHasObjectives						= 'data-has-objectives';

  var _patGoalAttrHasObjective1						= 'data-has-objective-1';
  var _patGoalAttrObjective1Text					= 'data-objective-1-text';
  var _patGoalAttrObjective1Met						= 'data-objective-1-met';
  var _patGoalAttrObjective1MetOn					= 'data-objective-1-met-on';

  var _patGoalAttrHasObjective2						= 'data-has-objective-2';
  var _patGoalAttrObjective2Text					= 'data-objective-2-text';
  var _patGoalAttrObjective2Met						= 'data-objective-2-met';
  var _patGoalAttrObjective2MetOn					= 'data-objective-2-met-on';

  var _patGoalAttrHasObjective3						= 'data-has-objective-3';
  var _patGoalAttrObjective3Text					= 'data-objective-3-text';
  var _patGoalAttrObjective3Met						= 'data-objective-3-met';
  var _patGoalAttrObjective3MetOn					= 'data-objective-3-met-on';

  var _patGoalProgressTrackingForWhatClass			= 'mba-notelibrary-pat-goal-progress-tracking-for-what';
  var _patGoalProgressTrackingForWhatContClass		= 'mba-notelibrary-pat-goal-progress-tracking-for-what-cont';
  var _patGoalOrObjectiveMetClass					= 'mba-notelibrary-pat-goal-or-objective-met';
  var _patGoalOrObjectiveMetOnClass					= 'mba-notelibrary-pat-goal-or-objective-met-on';
  var _patGoalOrObjectiveMetLabelClass				= 'mba-notelibrary-pat-goal-or-objective-met-label';
  var _patGoalOrObjectiveMetOnLabelClass			= 'mba-notelibrary-pat-goal-or-objective-met-on-label';


/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /* Update Goals JSON */

  var fnUpdateGoalsJSON = function () {
	let goalObjArray = [];
	let patientGoalsSelects = $('select.' + _patGoalSelectClass);

	  $.each(patientGoalsSelects, function (idx, goalSel) {
		let $goalTrackingDiv   = $(goalSel).parent().parent();
		let $inputsDiv         = $(goalSel).parent().siblings('div.' + _patGoalInputsDivClass);
		let $totalAttempts     = $($inputsDiv).find('input.' + _patGoalTotalAttemptsClass);
		let $sucessAttempts    = $($inputsDiv).find('input.' + _patGoalSuccessfulAttemptsClass);
		let $accuracy          = $($inputsDiv).find('input.' + _patGoalAccuracyClass);
		let $pracSessionRating = $($inputsDiv).find('input.' + _pracSessionRatingClass);
		let $patSessionRating  = $($inputsDiv).find('input.' + _patSessionRatingClass);

		let $patGoalInputGoalProgressUsingWhat = $($inputsDiv).find('input.' + _patGoalInputGoalProgressUsingWhatClass);
		let $patGoalType                       = $($inputsDiv).find('input.' + _patGoalTypeClass);
		  let $progressTrackingForWhat =
			  $goalTrackingDiv.find('select.' + _patGoalProgressTrackingForWhatClass);

		  let $goalOrObjectiveMet =
			  $goalTrackingDiv.find('select.' + _patGoalOrObjectiveMetClass);

		  let $goalOrObjectiveMetOn =
			  $goalTrackingDiv.find('input.' + _patGoalOrObjectiveMetOnClass);

		let goalid = $(goalSel).val();
		if (goalid) {
			let goalObj = {};
			goalObj.goalID                     = parseInt(goalid);
			goalObj.totalAttempts              = parseInt($($totalAttempts).val());
			goalObj.successfulAttempts         = parseInt($($sucessAttempts).val());
			goalObj.score                      = parseInt($($accuracy).val());
			goalObj.practitionerSessionRating  = parseInt($($pracSessionRating).val());
			goalObj.patientSessionRating       = parseInt($($patSessionRating).val());
			goalObj.inputGoalProgressUsingWhat = $patGoalInputGoalProgressUsingWhat.val();
			goalObj.goalType                   = $patGoalType.val();

			goalObj.progressTrackingForWhat =
				parseInt($progressTrackingForWhat.val(), 10) || 1;

			goalObj.goalOrObjectiveMet =
				$goalOrObjectiveMet.val() || 'N';

			goalObj.goalOrObjectiveMetOn =
				$goalOrObjectiveMetOn.val() || null;

			goalObjArray.push(goalObj);
        }
	});

	// update our JSON value (value placed in element/variable provided by user)

	let goalObjsJSON = JSON.stringify(goalObjArray);
	fnNoteForGetPatientGoalTrackingJSON(goalObjsJSON);

    // If we are showing a note preview

	if (showPreview) {
	  fnRenderQuestionAndAnswersToHTMLObj(me_id, null, null, goalObjsJSON);
	}
  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /* Get patient goal selections. Sends ajax request and append results to dropdown. */

	var fnGetPatGoals = function ($selectGoals, inputVal) {

		let clientid = fnNoteForClientID();
		let patid = fnNoteForPatID();
		let groupid = fnNoteForGroupID();
		let refDate = fnNoteForRefDate();
		let tkn = $.spedmonWebUI.token;

		let inputGoalID = (inputVal === null) ? '' : '' + inputVal;

		let reqUrl = "patient_goals.asmx/viewSel2?tkn=" + tkn;
		let reqData = JSON.stringify({
			"clientid": clientid
			, "patid": patid
			, "groupsvcclassnameid": groupid
			, "dos": refDate
		});

		let importedGoalsReqUrl = "import_from_patient_goal_records.asmx/viewSel?tkn=" + tkn;
		let importedGoalsReqData = JSON.stringify({
			"clientid": clientid
			, "patid": patid
			, "dos": refDate
		});

		$selectGoals
			.removeData('imported-goals-by-id')
			.attr('title', '')
			.empty()
			.append(
				$('<option></option>')
					.attr('disabled', true)
					.attr('selected', true)
					.attr('value', '')
					.text('-- select an option --')
			);

		return MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
			.then(responseData => {
				let existingGoals = (responseData.rawData.SelRecs) ? responseData.rawData.SelRecs : [];

				if (existingGoals.length > 0) {

					let $existingGoalsGroup =
						$('<optgroup></optgroup>')
							.attr(
								'label'
								, '---Patient Goal Library---'
							);

					$.each(
						existingGoals,
						function (idx, goalObj) {

							let $option = $('<option></option>')
								.attr(_patGoalAttrSelectionSource, '1')
								.attr(_patGoalAttrInputGoalProgressUsingWhat, goalObj.recData1)
								.attr(_patGoalAttrGoalType, goalObj.recData2)
								.attr(_patGoalAttrGoalMet, goalObj.recData3)
								.attr(_patGoalAttrGoalMetOn, goalObj.recData4)
								.attr(_patGoalAttrHasObjectives, goalObj.recData5)

								.attr(_patGoalAttrHasObjective1, goalObj.recData6)
								.attr(_patGoalAttrObjective1Text, goalObj.recData7)
								.attr(_patGoalAttrObjective1Met, goalObj.recData8)
								.attr(_patGoalAttrObjective1MetOn, goalObj.recData9)

								.attr(_patGoalAttrHasObjective2, goalObj.recData10)
								.attr(_patGoalAttrObjective2Text, goalObj.recData11)
								.attr(_patGoalAttrObjective2Met, goalObj.recData12)
								.attr(_patGoalAttrObjective2MetOn, goalObj.recData13)

								.attr(_patGoalAttrHasObjective3, goalObj.recData14)
								.attr(_patGoalAttrObjective3Text, goalObj.recData15)
								.attr(_patGoalAttrObjective3Met, goalObj.recData16)
								.attr(_patGoalAttrObjective3MetOn, goalObj.recData17)

								.attr('title', goalObj.label)
								.attr('value', goalObj.id)
								.text(goalObj.label);

							$existingGoalsGroup.append($option);
						}
					);

					$selectGoals.append($existingGoalsGroup);
				}

				return MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(importedGoalsReqUrl, importedGoalsReqData, null);
			})
			.then(responseData => {
				let importedGoals = (responseData.rawData.SelRecs) ? responseData.rawData.SelRecs : [];

				if (importedGoals.length > 0) {
					let $importedGoalsGroup = $('<optgroup></optgroup>')
						.attr(
							'label'
							, '---Imported Patient Goals---'
						);

					let importedGoalsByID = new Map();

					$.each(
						importedGoals,
						function (idx, goalObj) {
							importedGoalsByID.set('' + goalObj.id, goalObj);

							let $option = $('<option></option>')
								.attr(_patGoalAttrSelectionSource, '2')
								.attr('title', goalObj.label)
								.attr('value', goalObj.id)
								.text(goalObj.label);

							$importedGoalsGroup.append($option);
						}
					);

					$selectGoals.data('imported-goals-by-id', importedGoalsByID);
					$selectGoals.append($importedGoalsGroup);
				}

				if (inputGoalID !== '') {
					let $newPatientGoalOption = $selectGoals
						.find(
							'option['
							+ _patGoalAttrSelectionSource
							+ '="1"]'
						)
						.filter(function () {
							return ('' + $(this).val() === inputGoalID);
						})
						.first();

					if ($newPatientGoalOption.length > 0) {
						$newPatientGoalOption.prop('selected', true);
						$selectGoals.attr('title', $newPatientGoalOption.text());
						$selectGoals.trigger('change');
					}
				}
			})
			.catch(responseData => {
			});
	};

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /* when goal icon is clicked, open the patient goals tab and update the dropdown */

  var fnOpenPatGoalsTab = function () {
	if (fnNoteForPatID()) {

		let clientid = fnNoteForClientID();
		let patid    = fnNoteForPatID();
		let tkn      = $.spedmonWebUI.token;

		// load the goals tab in the patient screen
		var url = 'user_all_pat_save_2.aspx';
		var patScreenTabID = 'tab-goals';

		var reqUrlPatSave = $.spedmonWebUI.createPrivateURL(tkn, url)
			+ '&amd=uidbssub'
			+ '&clientid=' + clientid
			+ '&recid=' + patid
			+ '&tabtoopn=' + patScreenTabID
			+ '&savetype=' + $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT;

		var fnEntryTest = function () { return true; };
		var fnExitTest = function () { return true; };
		var fnResume = function () {

			/* resend the ajax request to update EVERY goals dropdown */

			let patientGoalsSelects = $('select.' + _patGoalSelectClass);

			$.each(patientGoalsSelects, function (idx, goalObjSel) {
				let inputVal = $(goalObjSel).val(); // we need to preload this value once the data is updated
				$(goalObjSel).empty().append('<option disabled value selected>-- select an option --</option>').val('');

				fnGetPatGoals($(goalObjSel), inputVal);
			});

			return true;
		};

		$.spedmonWebUI.popupThenResume(fnEntryTest
			, fnExitTest
			, fnResume
			, reqUrlPatSave
			, 'Popups Not Supported'
			, 'Please allow popups for SpEdCare'
			, 'Waiting'
			, 'Waiting for you to finish with patient goals');
	}
  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /* append goal dropdown, goal icon, number fields, and a plus icon */

	var fnGeneratePatGoalTracking = function ($div, goalidVal, totalattemptsVal, successattemptsVal, accuracyVal, pracSessionRatingVal, patSessionRatingVal, progressTrackingForWhatVal, goalOrObjectiveMetVal, goalOrObjectiveMetOnVal) {

		$($div).html('').append('<h6>Select a Goal</h6>');
		$($div).addClass(_patGoalClass);

		// patient goal selection control

		$($div).append('<div class="d-flex mba-notelibrary-pat-goal-selection-cont">'
			+ '<select class="' + _patGoalSelectClass + ' ' + _patGoalSelectionClass +'">'
			+ '<option disabled value selected>-- select an option --</option>'
			+ '</select>'
			+ '<i class="fas fa-university" title="Add, Edit, or Delete Patient Goals"></i>'
			+ '</div>');

		$($div).append(
			'<div class="' + _patGoalProgressTrackingForWhatContClass + '" style="display:none;">'

			+ '<div class="row align-items-end">'

			+ '<div class="col-7">'
			+ ' <h6 class="mt-2">Objectives</h6>'
			+ '<div class="d-flex mba-notelibrary-pat-goal-selection-cont">'
			+ '<select class="' + _patGoalProgressTrackingForWhatClass + '">'
			+ '<option value="1">Overall Goal</option>'
			+ '</select>'
			+ '</div>'
			+ '</div>'

			+ '<div class="col-2">'
			+ '<h6 class="mt-2 '
			+ _patGoalOrObjectiveMetLabelClass
			+ '">Goal Met</h6>'
			+ '<select class="' + _patGoalOrObjectiveMetClass + '" style="width:100%;">'
			+ '<option value="N">No</option>'
			+ '<option value="Y">Yes</option>'
			+ '</select>'
			+ '</div>'

			+ '<div class="col-3">'
			+ '<h6 class="mt-2 '
			+ _patGoalOrObjectiveMetOnLabelClass
			+ '">Goal Met On</h6>'
			+ '<input type="date" class="' + _patGoalOrObjectiveMetOnClass + '" style="width:100%;">'
			+ '</div>'

			+ '</div>'

			+ '</div>'
		);

		// number fields

		$($div).append('<div class="row ' + _patGoalInputsDivClass + '">'
			+ '<div class="col-10">'
			+ '<input type="number" placeholder="Attempts" title="Total Number of Successful and Failed Attempts" class="' + _patGoalTotalAttemptsClass + '" min="0" max="9999" step="1">'
			+ '<input type="number" placeholder="Successful Attempts" title="Number of Successful Attempts" class="' + _patGoalSuccessfulAttemptsClass + '" min="0" max="9999" step="1">'
			+ '<input type="number" placeholder="Accuracy %" title="Percentage of Successful Attempts" class="' + _patGoalAccuracyClass + '" min="0" max="100" step="1">'
			+ '<input type="number" placeholder="Practitioner Rating" title="Enter a value from 1 to 10" class="' + _pracSessionRatingClass + '" min="1" max="10" step="1">'
			+ '<input type="number" placeholder="Patient Rating" title="Enter a value from 1 to 10" class="' + _patSessionRatingClass + '" min="1" max="10" step="1">'
			+ '<input type="hidden" class="' + _patGoalInputGoalProgressUsingWhatClass + '">'
			+ '<input type="hidden" class="' + _patGoalTypeClass + '">'
			+ '</div>'
			+ '<div class="goal-tracking-icons-cont col-2 d-flex align-items-end justify-content-end">'
			+ '<i class="p-2 fas fa-trash-alt" title="Remove current goal tracking"></i>'
			+ '<i class="p-2 fas fa-plus" title="Add new goal tracking"></i>'
			+ '</div>'
			+ '</div>');

		$($div).append('<hr>');

		// grab fields and icons

		let $selectGoals		= $($div).find('select.' + _patGoalSelectClass);
		let $goalsIcon			= $($div).find('.fa-university');
		let $removeIcon			= $($div).find('.fa-trash-alt');
		let $plusIcon			= $($div).find('.fa-plus');
		let $totalAttempts		= $($div).find('input.' + _patGoalTotalAttemptsClass);
		let $sucessAttempts		= $($div).find('input.' + _patGoalSuccessfulAttemptsClass);
		let $accuracy			= $($div).find('input.' + _patGoalAccuracyClass);
		let $pracSessionRating	= $($div).find('input.' + _pracSessionRatingClass);
		let $patSessionRating	= $($div).find('input.' + _patSessionRatingClass);

		let $patGoalInputGoalProgressUsingWhat	= $($div).find('input.' + _patGoalInputGoalProgressUsingWhatClass);
		let $patGoalType						= $($div).find('input.' + _patGoalTypeClass);

		let $progressTrackingForWhatCont		= $($div).find('.' + _patGoalProgressTrackingForWhatContClass);
		let $progressTrackingForWhat			= $($div).find('select.' + _patGoalProgressTrackingForWhatClass);
		let $goalOrObjectiveMet					= $($div).find('select.' + _patGoalOrObjectiveMetClass);
		let $goalOrObjectiveMetOn				= $($div).find('input.' + _patGoalOrObjectiveMetOnClass);
		let $goalOrObjectiveMetLabel			= $($div).find('.' + _patGoalOrObjectiveMetLabelClass);
		let $goalOrObjectiveMetOnLabel			= $($div).find('.' + _patGoalOrObjectiveMetOnLabelClass);

		$($totalAttempts).MBA_DataEntryBox({});
		$($sucessAttempts).MBA_DataEntryBox({});
		$($accuracy).MBA_DataEntryBox({});
		$($pracSessionRating).MBA_DataEntryBox({});
		$($patSessionRating).MBA_DataEntryBox({});

		// load patient goals and numbers

		fnGetPatGoals($selectGoals, goalidVal);
		$($totalAttempts).val(totalattemptsVal);
		$($sucessAttempts).val(successattemptsVal);
		$($accuracy).val(accuracyVal);
		$($pracSessionRating).val(pracSessionRatingVal);
		$($patSessionRating).val(patSessionRatingVal);

		// callback for goals icon

		$($goalsIcon).on('click', function (e) {
			fnOpenPatGoalsTab();
		});

		// callback for delete icon

		$($removeIcon).on('click', function (e) {
			$($div).remove();
			fnUpdateGoalsJSON();
		});

		// callback for plus icon

		$($plusIcon).on('click', function (e) {
			// insert div after current div and call the same function
			let $newDiv = $('<div></div>');
			$($div).after($newDiv);
			fnGeneratePatGoalTracking($newDiv, null, null, null, null, null, null, null, null, null);
		});

		var _loadGoalOrObjectiveStatus = function () {
			_updateGoalOrObjectiveLabels();
			let $selectedOption = $progressTrackingForWhat.find('option:selected');
			let metYN			= $selectedOption.attr('data-met-yn') || 'N';
			let metOn			= $selectedOption.attr('data-met-on') || '';

			metYN = String(metYN).trim().toUpperCase();

			if (metYN === 'Y' || metYN === 'YES') {
				metYN = 'Y';
			}
			else {
				metYN = 'N';
			}
			$goalOrObjectiveMet.val(metYN);
			$goalOrObjectiveMetOn.val(metOn);
		};

		var _updateGoalOrObjectiveLabels = function () {
			let progressTrackingForWhat = String($progressTrackingForWhat.val() || '1');

			if (progressTrackingForWhat === '1') {
				$goalOrObjectiveMetLabel.text('Goal Met');
				$goalOrObjectiveMetOnLabel.text('Goal Met On');
			}
			else {
				$goalOrObjectiveMetLabel.text('Objective Met');
				$goalOrObjectiveMetOnLabel.text('Objective Met On');
			}
		};

		// Callback for showing/hiding inputs based on goal selection input goal progress using what attribute

		var _showOrHideInputsBasedOnInputGoalProgressUsingWhat = function (whatVal) {

			if (whatVal == "1") {
				$($totalAttempts).MBA_DataEntryBox('show');
				$($sucessAttempts).MBA_DataEntryBox('show');
				$($accuracy).MBA_DataEntryBox('show');
				$($pracSessionRating).MBA_DataEntryBox('hide');
				$($patSessionRating).MBA_DataEntryBox('hide');
			}
			else if (whatVal == "2") {
				$($totalAttempts).MBA_DataEntryBox('hide');
				$($sucessAttempts).MBA_DataEntryBox('hide');
				$($accuracy).MBA_DataEntryBox('hide');
				$($pracSessionRating).MBA_DataEntryBox('show');
				$($patSessionRating).MBA_DataEntryBox('show');
			}
			else {
				$($totalAttempts).MBA_DataEntryBox('hide');
				$($sucessAttempts).MBA_DataEntryBox('hide');
				$($accuracy).MBA_DataEntryBox('hide');
				$($pracSessionRating).MBA_DataEntryBox('hide');
				$($patSessionRating).MBA_DataEntryBox('hide');
			}
		};

		/* Init */

		_showOrHideInputsBasedOnInputGoalProgressUsingWhat("");

		$progressTrackingForWhatCont.hide();

		$goalOrObjectiveMet.val('N');
		$goalOrObjectiveMetOn.val('');

		var _loadProgressTrackingForWhat = function (goalMet, goalMetOn, hasObjectives, hasObjective1, objective1Text, objective1Met, objective1MetOn, hasObjective2, objective2Text, objective2Met, objective2MetOn, hasObjective3, objective3Text, objective3Met, objective3MetOn) {
			$progressTrackingForWhat.empty();

			$progressTrackingForWhat.append(
				$('<option></option>')
					.attr('value', '1')
					.attr('title', 'Track progress for overall goal')
					.attr('data-met-yn', goalMet || '')
					.attr('data-met-on', goalMetOn || '')
					.text('Overall Goal')
			);

			if (hasObjective1 === 'Y') {
				$progressTrackingForWhat.append(
					$('<option></option>')
						.attr('value', '10')
						.attr('title', 'Track progress for objective 1')
						.attr('data-met-yn', objective1Met || '')
						.attr('data-met-on', objective1MetOn || '')
						.text(objective1Text || 'Objective 1')
				);
			}

			if (hasObjective2 === 'Y') {
				$progressTrackingForWhat.append(
					$('<option></option>')
						.attr('value', '20')
						.attr('title', 'Track progress for objective 2')
						.attr('data-met-yn', objective2Met || '')
						.attr('data-met-on', objective2MetOn || '')
						.text(objective2Text || 'Objective 2')
				);
			}

			if (hasObjective3 === 'Y') {
				$progressTrackingForWhat.append(
					$('<option></option>')
						.attr('value', '30')
						.attr('title', 'Track progress for objective 3')
						.attr('data-met-yn', objective3Met || '')
						.attr('data-met-on', objective3MetOn || '')
						.text(objective3Text || 'Objective 3')
				);
			}

			if (hasObjectives === 'Y') {
				$progressTrackingForWhatCont.show();
			}
			else {
				$progressTrackingForWhat.val('1');
				$progressTrackingForWhatCont.hide();
			}
		};		

		let restoreSavedTrackingValues = (goalidVal !== null && goalidVal !== undefined);

		$($selectGoals).on('change', function (e) {
			let _selOpt = $($selectGoals).find('option:selected')[0];
			let selectionSource = parseInt($(_selOpt).attr(_patGoalAttrSelectionSource), 10);

			if (selectionSource === 1) {
				let _whatVal = $(_selOpt).attr(_patGoalAttrInputGoalProgressUsingWhat);
				let _goalTypeVal = $(_selOpt).attr(_patGoalAttrGoalType);

				let _goalMet = $(_selOpt).attr(_patGoalAttrGoalMet);
				let _goalMetOn = $(_selOpt).attr(_patGoalAttrGoalMetOn);
				let _hasObjectives = $(_selOpt).attr(_patGoalAttrHasObjectives);

				let _hasObjective1 = $(_selOpt).attr(_patGoalAttrHasObjective1);
				let _objective1Text = $(_selOpt).attr(_patGoalAttrObjective1Text);
				let _objective1Met = $(_selOpt).attr(_patGoalAttrObjective1Met);
				let _objective1MetOn = $(_selOpt).attr(_patGoalAttrObjective1MetOn);

				let _hasObjective2 = $(_selOpt).attr(_patGoalAttrHasObjective2);
				let _objective2Text = $(_selOpt).attr(_patGoalAttrObjective2Text);
				let _objective2Met = $(_selOpt).attr(_patGoalAttrObjective2Met);
				let _objective2MetOn = $(_selOpt).attr(_patGoalAttrObjective2MetOn);

				let _hasObjective3 = $(_selOpt).attr(_patGoalAttrHasObjective3);
				let _objective3Text = $(_selOpt).attr(_patGoalAttrObjective3Text);
				let _objective3Met = $(_selOpt).attr(_patGoalAttrObjective3Met);
				let _objective3MetOn = $(_selOpt).attr(_patGoalAttrObjective3MetOn);

				_showOrHideInputsBasedOnInputGoalProgressUsingWhat(_whatVal);
				$($patGoalInputGoalProgressUsingWhat).val(_whatVal);
				$($patGoalType).val(_goalTypeVal);
				_loadProgressTrackingForWhat(_goalMet, _goalMetOn, _hasObjectives, _hasObjective1, _objective1Text, _objective1Met, _objective1MetOn, _hasObjective2, _objective2Text, _objective2Met, _objective2MetOn, _hasObjective3, _objective3Text, _objective3Met, _objective3MetOn);

				if (restoreSavedTrackingValues) {

					$progressTrackingForWhat.val(progressTrackingForWhatVal);

					_loadGoalOrObjectiveStatus();

					if (goalOrObjectiveMetVal != null)
						$goalOrObjectiveMet.val(goalOrObjectiveMetVal);

					if (goalOrObjectiveMetOnVal != null)
						$goalOrObjectiveMetOn.val(goalOrObjectiveMetOnVal);

					restoreSavedTrackingValues = false;
				}
				else {

					$progressTrackingForWhat.val('1');
					_loadGoalOrObjectiveStatus();
				}
				return;
			}

			if (selectionSource === 2) {
				e.stopPropagation();

				let importedGoalsByID = $selectGoals.data('imported-goals-by-id');
				let importedGoalID = $(_selOpt).val();
				let importedGoalObj = null;

				if (importedGoalsByID) {
					importedGoalObj = importedGoalsByID.get(importedGoalID);
				}

				$.spedmonWebUI.dialogConfirm(
					'Add Imported Goal'
					, 'Would you like to add this goal to the student\'s goal library?'
					, function () {
						fnAddImportedPatientGoal(
							$selectGoals
							, importedGoalObj
						);
					}
					, function () {
						$($selectGoals).val('');
						_showOrHideInputsBasedOnInputGoalProgressUsingWhat('');
						$($patGoalInputGoalProgressUsingWhat).val('');
						$($patGoalType).val('');
						$progressTrackingForWhat.empty()
							.append('<option value="1">Overall Goal</option>')
							.val('1');
						$goalOrObjectiveMet.val('N');
						$goalOrObjectiveMetOn.val('');
						$progressTrackingForWhatCont.hide();
					}
				);
				return;
			}
		});

		$progressTrackingForWhat.on('change', function () {
			_loadGoalOrObjectiveStatus();
			fnUpdateGoalsJSON();
		});

		// on change event listener for our dropdown and input fields

		$($div).on('change', 'input, select', function (e) {

			let selGoalVal = $($selectGoals).val();

			if (!selGoalVal) {

				let $sgd = null;
				let $sgdButAddGoals = $('<button type="button">No Goal Selections for This Patient?  Click Here to Add Goals.</button>');
				$($sgdButAddGoals).button().on('click', function (e) {

					fnOpenPatGoalsTab();
					$($sgd).dialog('close');
				});

				let $sgdCont = $('<div style="padding:1em;text-align:center;"></div>');
				$($sgdCont).append('<p style="text-align:center;font-size:1em">Please select a goal.</p><p style="text-align:center;font-size:1em">Goal selection is <strong>required</strong> to save goal progress.</p>');
				$($sgdCont).append($sgdButAddGoals);
				$sgd = MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Goal Selection Is Required', $sgdCont);

			}

			// calculate accuracy %

			let numTotalAttempts = parseInt($($totalAttempts).val());
			let numSuccessAttempts = parseInt($($sucessAttempts).val());

			if (Number.isInteger(numTotalAttempts) && Number.isInteger(numSuccessAttempts)
				&& numTotalAttempts != 0
				&& numTotalAttempts >= numSuccessAttempts) {
				let accuracyVal = Math.round(100 * (numSuccessAttempts / numTotalAttempts));
				$($accuracy).val(accuracyVal);
			}

			// we also update our hiddenTextarea every time there is a change

			fnUpdateGoalsJSON();

		});

	};

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

	var fnAddImportedPatientGoal = function ($selectGoals, importedGoalObj) {

		let clientid = fnNoteForClientID();
		let patid = fnNoteForPatID();
		let groupsvcclassnameid = fnNoteForGroupID();
		let tkn = $.spedmonWebUI.token;

		let urlPatientGoalSaveInline = "patient_goals.asmx/save?tkn=" + tkn;

		let reqData = JSON.stringify({
			"clientid": clientid
			, "groupsvcclassnameid": groupsvcclassnameid
			, "patid": patid
			, "name": importedGoalObj.label
			, "goaltypeid": importedGoalObj.recData1
			, "baselinevalue": ""
			, "startdate": importedGoalObj.recData2
			, "enddate": importedGoalObj.recData3
			, "goalmet": importedGoalObj.recData4
			, "goalmeton": importedGoalObj.recData7
			, "backgroundtext": importedGoalObj.recData8
			, "notes": importedGoalObj.recData9
			, "objective1text": importedGoalObj.recData10
			, "objective1met": importedGoalObj.recData11
			, "objective1meton": importedGoalObj.recData12
			, "objective2text": importedGoalObj.recData13
			, "objective2met": importedGoalObj.recData14
			, "objective2meton": importedGoalObj.recData15
			, "objective3text": importedGoalObj.recData16
			, "objective3met": importedGoalObj.recData17
			, "objective3meton": importedGoalObj.recData18
			, "savetype": "1"
			, "recid": ""
		});

		MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(urlPatientGoalSaveInline, reqData, null)
			.then(responseData => {
				let newPatientGoalID = responseData.rawData.recordID;

				if (!newPatientGoalID) {
					MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Add Goal', 'The imported goal was not added to the student\'s goal library.', {});
					$selectGoals.val('').trigger('change');
					return;
				}

				$selectGoals.empty().append('<option disabled value selected>'
												+ '-- select an option --'
												+ '</option>'
											).val('');

				fnGetPatGoals($selectGoals, newPatientGoalID);
			})
			.catch(err => {
				MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Add Goal', err.message, {});
				$selectGoals.prop('selectedIndex', false);
			});
	};

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /* create goal tracking feature for each loaded record */

  var fnLoadPatGoalTrackingWithJSON = function (preloadedJSONVal, $divCont) {
	let goalTrackingArr = JSON.parse(preloadedJSONVal);
	$.each(goalTrackingArr, function (idx, goalObjSel) {
	  let $goalTrackingDiv = $('<div></div>');
	  $($divCont).append($goalTrackingDiv);
		fnGeneratePatGoalTracking($goalTrackingDiv, goalObjSel.goalID, goalObjSel.totalAttempts, goalObjSel.successfulAttempts, goalObjSel.score, goalObjSel.practitionerSessionRating, goalObjSel.patientSessionRating, goalObjSel.progressTrackingForWhat, goalObjSel.goalOrObjectiveMet, goalObjSel.goalOrObjectiveMetOn);
	});
  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /* Create new or get existing service rating goal */

  var fnPatientGoalsCreateOrGetServiceRatingGoal = function ($goalTrackingDiv) {

		let clientid          = fnNoteForClientID();
		let patid             = fnNoteForPatID();
	    let grpsvcclassnameid = fnNoteForGrpSvcClassNameID();
		let tkn               = $.spedmonWebUI.token;
	    let svcname           = fnNoteForSvcName();
		let reqUrl            = "patient_goals.asmx/createorgetserviceratinggoal?tkn=" + tkn;

   	    let reqData = JSON.stringify({
			  "clientid": clientid
			, "patid": patid
			, "groupsvcclassnameid": grpsvcclassnameid
			, "svcname": svcname
		});
	  
		MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
			.then(responseData => {
				/* Add session rating for the service as first goal */				
				if (responseData.rawData.recordID) {
					fnGeneratePatGoalTracking($goalTrackingDiv, responseData.rawData.recordID, null, null, null, null, null, null, null, null);
				}
			})
			.catch(responseData => {
				/* Fallback to adding empty goal if we could not create or get the goal*/
				fnGeneratePatGoalTracking($goalTrackingDiv, null, null, null, null, null, null, null, null, null);
			});
  };

  /*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /* generate the goal tracking feature */

  var fnInitPatGoalTracking = function ($divCont) {

	$($divCont).addClass(_patGoalContCssClass);
	  
	let preloadedJSONVal = fnNoteForSetPatientGoalTrackingJSON();

	 // If we have preloaded goals then regenerate the goal tracking features
	  
	if (preloadedJSONVal && preloadedJSONVal != '[]') {
	  // if initial JSON is provided, create goal tracking features for each object
	  fnLoadPatGoalTrackingWithJSON(preloadedJSONVal, $divCont);
     if (showPreview) {
         fnRenderQuestionAndAnswersToHTMLObj(me_id, null, null, preloadedJSONVal);		  
	  }
    }

	// if no value is preloaded for our JSON, we create an empty goal tracking feature

	else {
	
	  let $goalTrackingDiv = $('<div></div>');
	  $($divCont).append($goalTrackingDiv);

		// If this note has session rating tracking then we create or get the session rating
		// goal for this client, patient, practice family, and service name and preselect 
		// that goal in the empty goal tracking feature

		if (fnNoteForHasSessionRatingTracking() === true) {
			fnPatientGoalsCreateOrGetServiceRatingGoal($goalTrackingDiv);
		}

		// Otherwise we leave the goal blank

		else {
		  fnGeneratePatGoalTracking($goalTrackingDiv, null, null, null, null, null, null, null, null, null);
		}
    }

  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Generate fillable PDF feature
   *============================================================*/

  var urlNoteSvcRecFillablePdfSaveBase = this.options.urlNoteSvcRecFillablePdfSave;
  var $ctrlFillablePDFSelections       = null;
  
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

var fnGenerateFillablePdfSelectionOptions = function () {

	$($ctrlFillablePDFSelections).children().remove();

	let $optGroupNotCompleted = $('<optgroup></optgroup>');
	let $optGroupCompleted    = $('<optgroup></optgroup>');

	let ctrNotCompleted = 0;
	let ctrCompleted    = 0;
    
	fillablePdfAnswersArr.forEach(function (fillablePdfSelection) {
		  let $optFillablePDF = $('<option>' + fillablePdfSelection.label + '</option>');
		  $($optFillablePDF).attr('data-selection-id', fillablePdfSelection.selectionID);
		  $($optFillablePDF).attr('value', fillablePdfSelection.storedFileID);

		  if (fillablePdfSelection.hasFormData === false) {			  			  			  
			  $($optGroupNotCompleted).append($optFillablePDF);
			  ctrNotCompleted++;
		  }
		  else {			  			  
			  $($optGroupCompleted).append($optFillablePDF);
			  ctrCompleted++;
		  }
	});

	$($optGroupNotCompleted).attr('label', 'Not Completed (' + ctrNotCompleted + ')');
	$($optGroupCompleted).attr('label',    'Completed or Partially Filled Out (' + ctrCompleted + ')');
	$($ctrlFillablePDFSelections).append('<option disabled selected value="-1">Select Form To Complete</option>');
	$($ctrlFillablePDFSelections).append($optGroupNotCompleted);
	$($ctrlFillablePDFSelections).append($optGroupCompleted);

	/* Reset selected value */
	$ctrlFillablePDFSelections.val('-1');

  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /* Render fillable PDF selections (if any) */
  
  var fnRenderFillablePdfSelections = function (fillablePdfSectionID) {

		/* Get ref to containing element we are going to append selections to (if any) */

		let $fillablePDFSectionContainer = $('#' + fillablePdfSectionID);

		/* Remove all children from that element */

		$($fillablePDFSectionContainer).children().remove();

	    /* Clear message channel  */

		messageChannelForFillablePDFs = null;

		/* Exit if this note does not have fillable pdf selections */

		if (fnNoteHasFillablePdfSelections() == false) return;


	  /* Create message channel */

	  messageChannelForFillablePDFs = new BroadcastChannel(messageChannelForFillablePDFsName);

	  messageChannelForFillablePDFs.onmessage = function (message) {
		  
		  if (message.data.from == 'notelib') return;

		  /* If the message is update or close we update our answers data */

		  if ((message.data.cmd == 'update') || (message.data.cmd == 'close')) {

			  /* Find the answer object (index) for this selection */

			  let fnFindAnswerIdx = (element) => element.selectionID == message.data.selectionID;
			  let idx = fillablePdfAnswersArr.findIndex(fnFindAnswerIdx);

			  /* Determine if anything was answered */

			  let hasFormData = true;
			  if (message.data.formDataJSON === '{}') hasFormData = false;

			  /* Update answers object */

			  fillablePdfAnswersArr[idx].hasFormData = hasFormData;
			  fillablePdfAnswersArr[idx].formDataJSON = message.data.formDataJSON;
		  }

		  fillablePdfAnswersJSON = JSON.stringify(fillablePdfAnswersArr);
		  fnNoteGetFillablePdfAnswersJSON(fillablePdfAnswersJSON);

		  /* If message is close (initiated by user clicking on button or closing page) */

		  if (message.data.cmd == 'close') {
			  /* Refresh selections */
			  fnGenerateFillablePdfSelectionOptions();
		  }

	  }; /* On message */

	    /* Get the fillable PDF selections data.  Note: This is read only and used to
		 * 1. Capture WHAT pdf selections were presented at the time
		 * 2. Build and maintain an "answers" object
		 * 
		 * The storedFileID and selectionID are currently the same value
		 * But if we need to eventually futher abstract out the selection data 
		 * selectionID would be the unique value in context with this note lib instance.
		 * */

		fillablePdfSelectionsJSON = fnNoteSetFillablePdfSelectionsJSON();
		fillablePdfSelectionsArr  = JSON.parse(fillablePdfSelectionsJSON);

		/* Get the "answers object" data.  This will either be an empty array or contain
		 * previous data (ie WIP restore) */

		fillablePdfAnswersJSON = fnNoteSetFillablePdfAnswersJSON();
		fillablePdfAnswersArr = JSON.parse(fillablePdfAnswersJSON);

		/* Initial population of answers object */

		fillablePdfSelectionsArr.forEach(function (fillablePdfSelection) {

			/* Find existing answer (if any) */

			let fnFindAnswerIdx = (element) => element.selectionID == fillablePdfSelection.id;
			let idx = fillablePdfAnswersArr.findIndex(fnFindAnswerIdx);

			/* If there is no answer for the selection then create an initial answer */

			if (idx == -1) {
				let fillablePdfAnswer = {};
				fillablePdfAnswer.selectionID  = fillablePdfSelection.id;
				fillablePdfAnswer.storedFileID = fillablePdfSelection.id;
				fillablePdfAnswer.label        = fillablePdfSelection.label;
				fillablePdfAnswer.hasFormData  = false;
				fillablePdfAnswer.formDataJSON = '{}';
				fillablePdfAnswersArr.push(fillablePdfAnswer);
			}
		});

		/* Update and send the answers back to the element from the caller that contains the answers */

		fillablePdfAnswersJSON = JSON.stringify(fillablePdfAnswersArr);
		fnNoteGetFillablePdfAnswersJSON(fillablePdfAnswersJSON);

		/* Build base URL for new tab that will be used to open a fillable PDF
		 * The base url contains parms that have the same name/values regardless of selection. */

		let baseParms = [];

		baseParms.push(MBA.ComponentCommon.fnCreateNameValueObject('clientid',  fnNoteForClientID()));
		baseParms.push(MBA.ComponentCommon.fnCreateNameValueObject('pracid',    fnNoteForPracID()));
		baseParms.push(MBA.ComponentCommon.fnCreateNameValueObject('patid',     fnNoteForPatID()));
		baseParms.push(MBA.ComponentCommon.fnCreateNameValueObject('refdate',   fnNoteForRefDate()));
		baseParms.push(MBA.ComponentCommon.fnCreateNameValueObject('svcname',   fnNoteForSvcName()));
		baseParms.push(MBA.ComponentCommon.fnCreateNameValueObject('starttime', fnNoteForStartTime()));
		baseParms.push(MBA.ComponentCommon.fnCreateNameValueObject('nummins',   fnNoteForNumMins()));
		baseParms.push(MBA.ComponentCommon.fnCreateNameValueObject('svcnameslistdatasourceid', fnNoteForSvcNameListDataSource()));
		baseParms.push(MBA.ComponentCommon.fnCreateNameValueObject('msgchannel',               messageChannelForFillablePDFsName));

		let baseURL = MBA.ComponentCommon.fnBuildUrl(urlNoteSvcRecFillablePdfSaveBase, true, baseParms);

		/* Create EMPTY select control and append to containing element */

		$ctrlFillablePDFSelections = $('<select class="ml-1"></select>');
		$($fillablePDFSectionContainer).append($ctrlFillablePDFSelections);

		/* Create form that we will use to post to (form data will not all fit on query string) */

	    let $frmFillablePDFSelection = $('<form target="_blank" method="post" rel="opener" style="display:none;"></form>');

		/* Create hidden text area to hold pdf answers */

		let $taPdfAnswers = $('<textarea name="fpdffrmdata"></textarea>');
	    
		/* Append fields to form and append form to container */
		
		$($frmFillablePDFSelection).append($taPdfAnswers);
		$($fillablePDFSectionContainer).append($frmFillablePDFSelection);

		/* Generate (initial) select options */

		fnGenerateFillablePdfSelectionOptions();

		/* Add event handler for selections*/

		$($ctrlFillablePDFSelections).on('input', function (e) {

			let $ctrlSelectedOption = $($ctrlFillablePDFSelections).find('option:selected');
			let selectionID         = $($ctrlSelectedOption).attr('data-selection-id');
			let fnFindAnswerIdx     = (element) => element.selectionID == selectionID;
			let idx                 = fillablePdfAnswersArr.findIndex(fnFindAnswerIdx);

			/* Generate parms specific to this item*/

			let urlParms = [];

			urlParms.push(MBA.ComponentCommon.fnCreateNameValueObject('fpdfsid', selectionID));
			urlParms.push(MBA.ComponentCommon.fnCreateNameValueObject('sf-fid', $ctrlFillablePDFSelections.val()));
			$($taPdfAnswers).val(fillablePdfAnswersArr[idx].formDataJSON);
			
			/* Generate URL and trigger submit on form to open fillable pdf page */

			let url = MBA.ComponentCommon.fnBuildUrl(baseURL, true, urlParms);
			$($frmFillablePDFSelection).attr('action', url);
			$($frmFillablePDFSelection).submit();

			/* Disable (will be re enabled when form is closed) */

			MBA.ComponentCommon.fnDisableElement($ctrlSelectedOption);
			
			/* Reset selected */

			$ctrlFillablePDFSelections.val('-1');
		});

	
	  /* If the note lib is rendered in a dialog then we want to send close messages to any open fillable pdfs */

	  if (meMainDiaRef) {
		  $(meMainDiaRef).on("dialogclose", function (event, ui) {
			  let msg = {};
			  msg.from = 'notelib';
			  msg.cmd  = 'closeall';
			  messageChannelForFillablePDFs.postMessage(msg);
		  });
      }
	  
	};
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Add Markup and Generate Appropriate Widgets
   *============================================================*/   

  /* Place options above original html */

  if (useMenu == false) {  
    var nte_opts_inline_cls  = me_ns + '-nte-opts-inline';
	$(nte_opts_cont_mkup).insertBefore(me).addClass(nte_opts_inline_cls);

	// Generate fillable pdf section content if needed

	if (fillablePdfSelectionsEnabled === true) {
		fnRenderFillablePdfSelections(nte_fillable_pdf_selections_section_id); 
	}
	// generate goal tracking feature (if needed)

    $('#' + nte_pat_goal_tracking_id).html(''); // clear any previous goal tracking
	if (fnNoteForPatientGoalTracking() === true) {
	  fnInitPatGoalTracking($('#' + nte_pat_goal_tracking_id)); // we pass the div where the content will be placed		
	}

	fnAdditionalContent($('#' + nte_add_content_id));

  }
  
  /* Place options in menu dialog, create open button, and place open button on right */
  
  else if (useMenu == true) {
    
	var $newNoteLibDiaJqRef = $(nte_opts_cont_mkup);
    $($newNoteLibDiaJqRef).appendTo('body');
	meMainDiaRef = $($newNoteLibDiaJqRef).dialog({ width: 1150, height: 765, resizable: true, autoOpen: false, modal: true, buttons: { "OK": function () { $('#' + nte_opts_cont_id).dialog("close");}}});
	
	var $newNoteLibOpenButJqRef = $(nte_opts_but_opn_mkup);
	$($newNoteLibOpenButJqRef).insertAfter(me);
	$($newNoteLibOpenButJqRef).on('click',function(e){
	  // Generate fillable pdf section content if needed
	  if (fillablePdfSelectionsEnabled === true) {
			fnRenderFillablePdfSelections(nte_fillable_pdf_selections_section_id);
	  }
      $('#' + nte_pat_goal_tracking_id).html(''); // clear any previous goal tracking
	  // generate goal tracking feature (if needed)
	  if (fnNoteForPatientGoalTracking() === true) {
		fnInitPatGoalTracking($('#' + nte_pat_goal_tracking_id)); // we pass the div where the content will be placed
	  }

	  fnAdditionalContent($('#' + nte_add_content_id));
	  fnUpdateSecondaryTaIfUsed();
	  $('#' + nte_opts_cont_id).dialog('open');
	  fnFocusOnSecondaryTaIfUsed();
	  
	});   
  }

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Add Template Selection and Saved Note Selection Markup
   * and Generate Appropriate Widgets
   *============================================================*/

  var tmpSelMkupAppendTo = this.options.tmpSelMkupAppendTo;
  var svcSelMkupAppendTo = this.options.svcSelMkupAppendTo;

  $(tmp_sel_mkup).appendTo(tmpSelMkupAppendTo);
  $(svd_sel_mkup).appendTo(svcSelMkupAppendTo);

  $('#' + tmp_sel_cont_id).dialog({width:600,height:300,resizable:true,draggable:false,autoOpen:false,modal:true});
  $('#' + svd_sel_cont_id).dialog({width:600,height:300,resizable:true,draggable:false,autoOpen:false,modal:true});

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Define select note namespace and source namevalues for
   * both select template and select saved notes widgets
   *============================================================*/ 

  var sel_note_ns_src_nvs = [  { name:"notenamespace", value:(this.options.notefornamespacefn()) }
                             , { name:"notesource",    value:(this.options.noteforsourcefn())    }							  
							];
  
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Define getnamevaluesfn delegate for template 
   * select ajax options.  
   *============================================================*/ 
  
  var fn_sel_tmp_note_from_nvps = function() {
  
	var nvps = [  { name:"notenamespace", value:(fnNoteForNamespace()) }
	            , { name:"notesource",    value:(fnNoteForSource())    }
	            , { name:"clientid",      value:(fnNoteForClientID())  }
                , { name:"pracid",        value:(fnNoteForPracID())    }							  
				, { name:"patid",         value:(fnNoteForPatID())     }
                , { name:"referencedate", value:(fnNoteForRefDate())   }				
			   ];
    
	return nvps;

  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Select template widget
   *============================================================*/ 

  $('#' + tmp_sel_inp_id).spedmonSelectBox({dataParmType:"DOM", selectAll:true, selectType:($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),onSelect:function(event,ui){ /* */},ajaxopts:{url:(this.options.url_sel_tmp),data:"",namevalues:"",getnamevaluesfn:(fn_sel_tmp_note_from_nvps)}});

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Define getnamevaluesfn delegate for saved note 
   * select ajax options.  
   *============================================================*/ 
  
  var fn_sel_svd_note_from_nvps = function() {
      
    // Pass or dont pass patient id depending on state of checkbox
	
	var fnSelectPatID = function() {	  
	  if ($('#'+svd_sel_cbx_id).is(':checked')) return fnNoteForPatID();
	  return '';	  	 
	};
	
	var nvps = [  { name:"notenamespace", value:(fnNoteForNamespace()) }
	            , { name:"notesource",    value:(fnNoteForSource())    }
	            , { name:"clientid",      value:(fnNoteForClientID())  }
                , { name:"pracid",        value:(fnNoteForPracID())    }							  
				, { name:"patid",         value:(fnSelectPatID())      }							  
			   ];
    
	return nvps;

  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Select saved note widget
   *============================================================*/

  $('#' + svd_sel_inp_id).spedmonSelectBox({dataParmType:"DOM", selectAll:true, selectType:($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),onSelect:function(event,ui){ /* */},ajaxopts:{url:(this.options.url_sel_svd),data:"",namevalues:"",getnamevaluesfn:(fn_sel_svd_note_from_nvps)}});

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Get data for select boxes
   *============================================================*/ 

  var tmpSelBoxData = $('#' + tmp_sel_inp_id).data('spedmonSelectBox');
  var svdSelBoxData = $('#' + svd_sel_inp_id).data('spedmonSelectBox');  

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Override resize menu logic for template select box
   * This keeps the menu inside its container
   *============================================================*/ 
  
  $('#' + tmpSelBoxData.inputData.meid).data("autocomplete")._resizeMenu = function () {
    var ul = this.menu.element;
    ul.outerWidth(this.element.outerWidth());
  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Override resize menu logic for saved notes select box
   * This keeps the menu inside its container
   *============================================================*/ 
  
  $('#' + svdSelBoxData.inputData.meid).data("autocomplete")._resizeMenu = function () {
    var ul = this.menu.element;
    ul.outerWidth(this.element.outerWidth());
  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Override selection logic for saved notes select box
   *============================================================*/ 
  
  var $butSvdRemIcon = this.options.rem_svd_icon;
  var lblRemSaved    = this.options.rem_svd_lbl;
  
  $('#' + svdSelBoxData.inputData.meid).data("autocomplete")._renderItem = function( $ul, item ) {       

    var $nli        = $('<li></li>'); // Note any classes added here are removed	
	var liLabel     = '<div class="' + svd_sel_item_label_cls +'">' + item.label + '</div>';
	var liContext   = '';
	
	// Do not include context if show only selected patient is checked
	
	if ($('#'+svd_sel_cbx_id).is(':checked')) {
	  liContext   = '';
	}
    else {
	  liContext  = '<div class="' + svd_sel_item_context_cls + '">' + ((item.context1 != null) ? item.context1 : '') + '</div>';
    }	
	  
	// Detail
	
	var $nliDetail  = $(liContext + '<a class="' + svd_sel_item_link_cls + '">' + liLabel +  + '</a>');
    
	// Remove button
	
	var $butRem = $('<button class="' + svd_sel_item_remv_cls + '" type="button">' + lblRemSaved + '</button>')
	  .button({text:false,icons:{ primary:$butSvdRemIcon}})
	  .on('click',function(){ 
		$.spedmonWebUI.dialogConfirm(lblRemSaved,'Are you sure you want to delete this note?'
		  ,function(){
		    var noteid = item.id;					
			fnDeleteNote(noteid);
			$($nli).remove();}
	      ,null); 
	  });
	
	$($nli).append($nliDetail);
		
	if (remSvdEnabled == true) {
      if (item.flag1 == true)	
	    $($nli).append($butRem);	  
	}
    
	$($nli).data( "item.autocomplete", item );	 

	return $nli.appendTo( $ul );           
                 
  };

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Generate Properties for Various Note Options
   *============================================================*/ 

  $('#' + nte_upload_this_pat_but_opn_id).attr("title",this.options.nte_upload_this_patient_lbl);
  $('#' + nte_upload_this_pat_but_opn_id).addClass(nte_upload_this_pat_but_opn_cls);
  $('#' + nte_upload_this_pat_but_opn_id).click(function(){fnUploadNotesForThisPatient();});

  $('#' + nte_hist_but_opn_id).attr("title",this.options.nte_hist_lbl);
  $('#' + nte_hist_but_opn_id).addClass(nte_hist_but_opn_cls);
  $('#' + nte_hist_but_opn_id).click(function(){fnGetNoteHist();});

  $('#' + svd_add_but_act_id).attr("title",this.options.add_svd_lbl);
  $('#' + svd_add_but_act_id).addClass(svd_add_but_act_cls);
  $('#' + svd_add_but_act_id).click(function(){
	  var newnote = $('#' + me_id).val();
	  fnSaveNote(newnote);
	  fnCloseOptionsMenuIfUsed();
  });

  $('#' + svd_sel_but_opn_id).attr("title",this.options.sel_svd_lbl);
  $('#' + svd_sel_but_opn_id).addClass(svd_sel_but_opn_cls);
  $('#' + svd_sel_but_opn_id).click(function(){
	  fnCloseOptionsMenuIfUsed();
	  var eo = fnGetAndCheckNamespaceSourceClientPracPat();
	  if (eo.entitiesOK) {
	    $('#' + svd_sel_cont_id).dialog('open');
	  }
	  else {
	    eo.displayMessages();
	  }
  });

  $('#' + nte_upload_any_pat_but_opn_id).attr("title",this.options.nte_upload_any_patient_lbl);
  $('#' + nte_upload_any_pat_but_opn_id).addClass(nte_upload_any_pat_but_opn_cls);
  $('#' + nte_upload_any_pat_but_opn_id).click(function(){fnUploadNotesForAnyPatient();}); 

  $('#' + tmp_sel_but_opn_id).attr("title",this.options.sel_tmp_lbl);
  $('#' + tmp_sel_but_opn_id).addClass(tmp_sel_but_opn_cls);
  $('#' + tmp_sel_but_opn_id).click(function(){fnCloseOptionsMenuIfUsed();$('#' + tmp_sel_cont_id).dialog('open');});

  $('#' + goal_progress_but_opn_id).attr("title",this.options.goal_progress_lbl);
  $('#' + goal_progress_but_opn_id).addClass(goal_progress_but_opn_cls);
  $('#' + goal_progress_but_opn_id).click(function () { fnOpenPatientGoalsProgress(); });
  if (exportNoteDataEnabled) {
    $('#' + export_note_but_opn_id).on('click', function (e) { fnOpenNoteExport(); });
  }
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * Wire up events between various pieces
   *============================================================*/   
  
  /* Retrieve notes field and close template selection dialog if data is selected from selectbox */
 
  $('#' + tmp_sel_cont_id).on("spedmoninputdata",function(e){    
	if (e.dataitem.value){	  
	  $(me).val(e.dataitem.notes).change();
	  if (useMenu == true) $('#' + nte_ta_sec_id).val(e.dataitem.notes).change();
	   //fnUpdateSecondaryTaIfUsed();
	  $('#' + tmp_sel_cont_id).dialog('close');
	  fnOpenOptionsMenuIfUsed();
	  $(me).focus();
	}
    return false;
  });

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /* Retrieve notes field and close saved note selection dialog if data is selected from selectbox */

  $('#' + svd_sel_cont_id).on("spedmoninputdata",function(e){    
    if (e.dataitem.value){	  	  
	  $(me).val(e.dataitem.notes).change();
	  if (useMenu == true) $('#' + nte_ta_sec_id).val(e.dataitem.notes).change();
	  //fnUpdateSecondaryTaIfUsed();
	  $('#' + svd_sel_cont_id).dialog('close');
	  $(me).focus();
	}
    return false;
  });

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /* Close template selection if dialog is closed */
  
  $('#' + tmp_sel_cont_id).on( "dialogclose", function() {
    var $input = $('#' + tmpSelBoxData.inputData.meid);
    if ($input.autocomplete("widget").is(":visible")) $input.autocomplete("close");
  });

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /* Close saved note selection if dialog is closed */

  $('#' + svd_sel_cont_id).on( "dialogclose", function() {
  
    var $input = $('#' + svdSelBoxData.inputData.meid);
    if ($input.autocomplete("widget").is(":visible")) $input.autocomplete("close");
  });
 
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

  /*============================================================
   * If the options are in a menu then 
   * synch primary note text with secondary text area (ta) if 
   * secondary ta is in use.  Also auto resize.
   *============================================================*/   

  if (useMenu == true) {
  
    /* Synch keyboard updates between dialog note and original element http://stackoverflow.com/a/8803425 */
    /* Give enough time for the paste event to complete http://stackoverflow.com/a/2242485 */
	
    $('#' + nte_ta_sec_id).on("keyup paste", function(){	
	  setTimeout(function() { $('#' + me_id).val($('#' + nte_ta_sec_id).val()).change(); }, 100);	 
	});
	
    $('#' + me_id).on("keyup paste", function() {
	  setTimeout(function() { $('#' + nte_ta_sec_id).val($('#' + me_id).val()).change(); }, 100);			
	});
 
	var originalWidth = $(this.element).width();
    var parentWidth   = $(this.element).parent().width();	
	if (originalWidth) {
	  if (originalWidth <= 0) originalWidth = parentWidth - 10;
	  var buttonWidth = $( '#' + nte_opts_but_opn_id).width();
      if (buttonWidth) {	
		if (buttonWidth <= 0) {
		  if (this.options.useLabelInOpenButton == true) buttonWidth = 150; else buttonWidth = 50;
		}
		//var newWidth = originalWidth - buttonWidth - 25;
		var newWidth = originalWidth - buttonWidth - 30;
		if (newWidth > 0) {
		  $(this.element).width(newWidth);
		}
	  }
	}
  }

/*------------------------------------------------------------------------------------------------------------------------------------------------*/

 },
 
_init: function() {
  return;   
},

_destroy: function() {
  return;
}
	
});

})(jQuery);