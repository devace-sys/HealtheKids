<%@ Page Language="C#" CodeBehind="user_all_rpt_rmts_moment_service_records.aspx.cs" Inherits="Spedmon.UserAllRptRMTSMomentServiceRecords"%>

<h1 class="text-center text-danger">This page is currently under maintenance. We apologize for this inconvenience.</h1>

<%
// TODO: don't know, not sure how this screen is intended to be accessed... or if it will ever be made to work
%>




<%-----------------------------%>
<%--   Quarter Selection     --%>
<%-- for dialog created in JS--%>
<%-- TODO: Refactor into a   --%>
<%-- "static" dialog div to  --%>
<%--  replace JS method that --%>
<%--   uses copy of this     --%>
<%-----------------------------%>

<%--<div id = "divfyquarterid2"   style="display:none">
   <Spedmon:ComboBox
     ID            = "fyquarterid2"
     name          = "fyquarterid2"
     title         = "Select Quarter"
     displayInline = "true"
     dataPrivate   = "true"
     dataURL       = "rmts_current_quarters.asmx/viewSel"
     dataParms     = "[]"
     runat         = "server" />
</div>

<div id="dataManagementRows" class="container-fluid">--%>

 <%-----------------------------%>
 <%--    Client Selection     --%>
 <%-----------------------------%>

<%--<Spedmon:DataEntryRowSelectClient
    ID       = "selectClient"
    rowLabel = "Who is the Client?"
	dataEntryRowRenderAs = "FIELD"
    runat    = "server">
 </Spedmon:DataEntryRowSelectClient>

<div class="row">
  <div class="col-12">
  </div> <!-- col -->
</div> <!-- row --> --%>

<%-----------------------------%>
<%--    Filters              --%>
<%-----------------------------%>

<%--<div class="row">
  <div class="col">

  <Spedmon:ComboBox
     ID            = "fyquarterid"
     name          = "fyquarterid"
     title         = "Select Quarter"
     displayInline = "true"
     dataPrivate   = "true"
     dataURL       = "rmts_current_quarters.asmx/viewSel"
     dataParms     = "[]"
     runat         = "server" />

  </div> <!-- col -->

  <div class="col">
    <button id="sendDataDialogButton" class="ml-3 btn btn-primary" onclick="launchDataFileUploadScreen()">Upload Data</button>
  </div> <!-- col -->

   <div class="col">
    <Spedmon:RadioBox ID="activitycodeselection" name="activitycodeselection" title="Activity Code" renderLabel="true" additionalCssClassNameForContainer="modern2021" runat="server" />
  </div> <!-- col -->

</div> <!-- row -->--%>

<%-----------------------------%>
<%--    Matches Required     --%>
<%--      Status             --%>
<%-----------------------------%>

<%--<div class="row">
<div class="col-12">
<h4 id="countRequiringMatching" class="w-100 text-center"></h4>
</div> <!-- col -->
</div> <!-- row -->--%>

<%-----------------------------%>
<%--       Rest view         --%>
<%--      RMTS Moments       --%>
<%-----------------------------%>

<%--<div id="restViewRow" class="row mt-3 mb-3">
  <div class="col-12">
    <div id="restView" class="col-12"></div>
  </div> <!-- col -->
</div> <!-- row -->--%>

<%-----------------------------%>
<%--     Practitioner        --%>
<%--      Selection          --%>
<%-----------------------------%>

<%--<div class="row">
	<div class="col-12 col-md-4">
		<Spedmon:DataEntryRowSelectPractitioner
		      ID                                 = "selectPractitioner"
		      entityControlID                    = "pracid"
		      rowLabel                           = "Practitioner"
		      selectTitle                        = "Enter Last, First"
		      preSelectedDataSource              = "ALL_PRACTITIONERS"
			  dataEntryRowRenderAs               = "FIELD"
		      runat                              = "server">
		</Spedmon:DataEntryRowSelectPractitioner>
	</div>

	<div class="col-12 col-md-4 m-1">
		<Spedmon:DateBoxRange id="daterange" name="daterange" title="Service Date Range" showOK="false" runat="server" />
	</div>
</div>--%>

<%-----------------------------%>
<%--     Service Record      --%>
<%--       Subtitle          --%>
<%-----------------------------%>

<%--<div class="row">
  <div class="col-12">
    <h4 class="w-100 mt-3 text-center">Recorded RMTS Moments in SpEdCare</h4>
  </div> <!-- col -->
</div> <!-- row -->--%>

<%-----------------------------%>
<%--       Rest view         --%>
<%--    Service Records      --%>
<%-----------------------------%>

<%--  <div id="restViewRow_rmtsServiceRecs" class="row mt-3">
    <div class="col-12">
       <div id="restView_rmtsServiceRecs"></div>
     </div> <!-- col -->
  </div> <!-- row -->

</div> <!-- container -->--%>

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//# TODO: Rewrite how the row controls are setup on this screen for the RMTS moments rest view so export options    %>
<%//#       will work                                                                                                 %>
<%//# The report options are not working because there is code that directly manipulates the row controls array       %>
<%//# clears it out, and dynmaically rerenders sets of controls with different handlers (it seems) in the code        %>
<%//# injection handlers.                                                                                             %>
<%//##################################################################################################################%>

<script type="text/javascript">

var var_matching_rmtssvcrec;
var var_matching_audit_req;

var var_count_requiring_matching = 0;

const PARM_NAME_CLIENT_ID = 'clientid';
const PARM_NAME_ACTIVE = 'active';

const PARM_NAME_SVC_DATE_RANGE = '<%=Spedmon.Constants.PARM_DATE_RANGE%>';

const PARM_NAME_FISCAL_QUARTER_ID = '<%=MBA.Constants.PARM_FISCAL_QUARTER_ID%>';
const PARM_NAME_FY_QUARTER_ID     = '<%=MBA.Constants.PARM_FY_QUARTER_ID%>';

var initv_rmtsServiceRecs_done = false;

var opts = {};

var var_import_id;
var var_sheetdata;

let $dataManagementRows = null;
let $restViewCtrl_rmtsMomentsReq = null;
let $restViewCtrl_rmtsServiceRecs = null;

$(document).ready(function() {

	$dataManagementRows = $('#dataManagementRows');
	$restViewCtrl_rmtsMomentsReq = $('#restView');
	initViewMomentsReq();

	$($dataManagementRows).on('spedmoninputdata', function(e) {

		/* If the quarter was selected */
		if ($(e.target).attr('id') == 'fyquarterid') {

			/* Use the recDatax values returned and
			 * build the date range string used to filter by dos range
			 * for the service records view and put the range string in the appropriate hidden input */

			let startDateVal = new Date(e.dataitem.recData1);
			let modifiedStartDate = new Date(startDateVal.setMonth(startDateVal.getMonth() - 3)).toLocaleDateString();

            let endDateVal = new Date(e.dataitem.recData2);
            let modifiedEndDate = new Date(endDateVal.setMonth(endDateVal.getMonth() + 3)).toLocaleDateString();

            $('#' + PARM_NAME_SVC_DATE_RANGE).val(modifiedStartDate + ' - ' + modifiedEndDate);
		}

		updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMomentsReq(e);
		updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs(e);

	});

	updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMomentsReq(null);

});

// refresh both rest views
function refreshRestViews() {
    updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMomentsReq(null);
    updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs(null);
}

// launches the RMTS moments file upload screen
function launchDataFileUploadScreen() {
    var url = '<%=Spedmon.StructuredDataImportFilesRmtsMomentsData.URL_SAVE_NEW_SUB_PAGE_BASE()%>'
		+ '&clientid=' + $('#' + PARM_NAME_CLIENT_ID).val()
        + '&fyquarterid=' + $('#' + PARM_NAME_FY_QUARTER_ID).val();

    $.spedmonWebUI.openNewWindow(url, 'rmts-moments-file-upload', refreshRestViews);
    return;
}

function sendLaunchAutoMatch() {

	alert('This could take a while; please refresh the page after 4 minutes');

	$.get(
		'rmts_moments.asmx/launch_automatch?tkn=' + $.spedmonWebUI.token +
		'&clientid=' + $('#clientid').val()
	).done(function() {
		updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMomentsReq(e);
		updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs(e);
	});

};

function updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMomentsReq(e) {

	let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
	let VALUE_ACTIVE = '1';

	let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
	let NV_ACTIVE = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);
	let NV_QUARTER = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FISCAL_QUARTER_ID, $('#fyquarterid').val());

	/* Note: Don't use a loop here, keep it unrolled for performance reasons */

	$($restViewCtrl_rmtsMomentsReq).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
	$($restViewCtrl_rmtsMomentsReq).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);
	$($restViewCtrl_rmtsMomentsReq).MBA_RestView('additionalParameterDefinitionForViewSet', NV_QUARTER);


	//let NV_IMPORTID = MBA.RestViewCommon.fnCreateNameValueObject('importID', var_import_id);
	//$($restViewCtrl_rmtsMomentsReq).MBA_RestView('additionalParameterDefinitionForViewSet', NV_IMPORTID);

	//let NV_PAGESIZE = MBA.RestViewCommon.fnCreateNameValueObject('pagesize', 6 );
	//$($restViewCtrl_rmtsMomentsReq).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAGESIZE);

	let NV_ACTIVITYCODE = MBA.RestViewCommon.fnCreateNameValueObject('activity_code', $('#activitycodeselection').val());
	$($restViewCtrl_rmtsMomentsReq).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVITYCODE);

	$($restViewCtrl_rmtsMomentsReq).MBA_RestView('requestViewFromServer', 1);

	//debugger;

	var counterUrl = 'api/v1/rmtsmomentsreq?tkn=' + encodeURIComponent($.spedmonWebUI.token) +
		'&' + PARM_NAME_FISCAL_QUARTER_ID + '=' + $('#fyquarterid').val() + '&activity_code=2A' + '&isComplete=0' +
		'&clientid=' + $('#clientid').val()

	$.get(counterUrl).done(function(resp, status_txt) {
		var_count_requiring_matching = resp.recordsFiltered;
		$("#countRequiringMatching").text(var_count_requiring_matching + ' RMTS moments need supporting documentation');
	});

};


function sendUpdatedMatch() {

	//debugger;

	if (var_matching_rmtssvcrec != 0 && var_matching_rmtssvcrec != null && var_matching_rmtssvcrec !== undefined &&
		var_matching_audit_req != 0 && var_matching_audit_req != null && var_matching_audit_req !== undefined) {


		$.get(
			'rmts_moments.asmx/sendUpdatedMatch?tkn=' + $.spedmonWebUI.token +
			'&matching_rmtssvcrec=' + var_matching_rmtssvcrec + '&matching_audit_req=' + var_matching_audit_req
		).done(function() {
			var_count_requiring_matching--;
			updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMomentsReq();
			updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs();
		});
		var_matching_rmtssvcrec = null;
		var_matching_audit_req = null;
	}
}

function updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs(e) {

	if (!($('#pracid').val())) return;

	if (initv_rmtsServiceRecs_done == false) {
		$restViewCtrl_rmtsServiceRecs = $('#restView_rmtsServiceRecs');
		initView_rmtsServiceRecs();
		initv_rmtsServiceRecs_done = true;
	}

	let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
	let VALUE_ACTIVE = '1';

	let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
	let NV_ACTIVE = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);
	let NV_DATE_RANGE = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SVC_DATE_RANGE, $('#' + PARM_NAME_SVC_DATE_RANGE).val());

	let NV_PRAC = MBA.RestViewCommon.fnCreateNameValueObject('pracid', $('#pracid').val());

	/* Note: Don't use a loop here, keep it unrolled for performance reasons */

	$($restViewCtrl_rmtsServiceRecs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
	$($restViewCtrl_rmtsServiceRecs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

	$($restViewCtrl_rmtsServiceRecs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DATE_RANGE);

	$($restViewCtrl_rmtsServiceRecs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC);

	//debugger;

	$($restViewCtrl_rmtsServiceRecs).MBA_RestView('requestViewFromServer', 1);


};

//var updateAdditionalViewParameterValuesAndrequestViewFromServer;

/* Service records manage type view */

function initView_rmtsServiceRecs() {

	const CSS_CLASS_RMTS_MOMENT_TOGGLED = 'svcrec-is-rmts-moment';

	let opts = {};

	opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
	opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
	opts.enableSortControls = true;
	opts.enableRowNumbers = false; /* Turn off row numbers */
	opts.enableRowControls = true;
	opts.enableRowControlRecAddNew = false;
	opts.enableRowControlRecEdit = false;
	opts.enableRowControlRecDelete = false;
	opts.positionUserDefinedControlsInBodyExisting = 2; /* Puts flag rmts to right of built in controls */

	opts.loadModeView = 'rest';
	opts.baseUrlView = '<%=Spedmon.ServiceRecords.URL_REST_VIEW_BASE()%>';
	opts.baseUrlViewHasParameters = true;
	opts.defaultPageRowOrder = '<%=Spedmon.ServiceRecord.DEFAULT_PAGING_ORDER%>';

	opts.enableReports = false;  <% /* TODO: doublecheck this later; not requested in this current deliverable,
                                           but could be an issue later  */ %>
	opts.enableReportHtml = true;
	opts.enableReportXls = true;
	opts.enableReportPdf = false;
	opts.loadModeReport = 'mbawebreport';
	opts.baseUrlReport = '<%=Spedmon.ServiceRecords.URL_WEB_REPORT_BASE()%>';
	opts.baseUrlReportHasParameters = true;
	opts.defaultReportNumber = '<%=Spedmon.ServiceRecordsRpt.REPT_NUM_VIEW%>';

	opts.fieldDefinitions = [];
	opts.additionalControlDefinitionsForBodyRows = new Map();


	<% //*************************************** Field Definitions *************************************************************%>

	<% // Service Record ID %>

	opts.fieldDefinitions.push({
		name: 'id',
		isRecID: true,
		editable: false,
		saveable: true,
		saveUsing: 'recid'
	});

    opts.fieldDefinitions.push({
        name: 'id',
        label: 'ID',
        toolTip: 'ID',
        visible: true,
        editable: false,
        saveable: false,
        sortable: true,
        isRecID: false,
        dataType: 'number',
    });

	<% // Client ID %>

	opts.fieldDefinitions.push({
		name: 'clientID',
		visible: false,
		sortable: false,
		saveable: true,
		editable: false,
		isRecID: false,
		dataType: 'hidden',
		sortUsing: '',
		saveUsing: 'clientid',
		showMore: false
	});

	<% // Practitioner Disp Group ID %>

	opts.fieldDefinitions.push({
		name: 'groupID',
		visible: false,
		sortable: false,
		saveable: true,
		editable: false,
		isRecID: false,
		dataType: 'hidden',
		sortUsing: '',
		saveUsing: 'groupid',
		showMore: false
	});

	<% // Practitioner ID %>

	opts.fieldDefinitions.push({
		name: 'pracID',
		visible: false,
		sortable: false,
		saveable: true,
		editable: false,
		isRecID: false,
		dataType: 'hidden',
		sortUsing: '',
		saveUsing: 'pracid',
		showMore: false
	});

	<% // Patient ID %>

	opts.fieldDefinitions.push({
		name: 'patID',
		visible: false,
		sortable: false,
		saveable: true,
		editable: false,
		isRecID: false,
		dataType: 'hidden',
		sortUsing: '',
		saveUsing: 'patid',
		showMore: false
	});




	<% // Flagged As RMTS Moment %>



	opts.fieldDefinitions.push({
		name: 'rmtsMomentVal',
		visible: false,
		sortable: false,
		saveable: true,
		editable: false,
		isRecID: false,
		dataType: 'hidden',
		sortUsing: '',
		saveUsing: 'rmtsmoment',
		showMore: false
	});




	<% // Fiscal Quarter %>



	opts.fieldDefinitions.push({
		name: 'quarter',
		label: 'Fiscal Quarter',
		toolTip: 'Fiscal Quarter',
		visible: true,
		sortable: true,
		saveable: false,
		editable: false,
		isRecID: false,
		dataType: 'text',
		sortUsing: 'quarter',
		saveUsing: '',
		showMore: false
	});




	<% // Practitioner Name %>



	opts.fieldDefinitions.push({
		name: 'pracName',
		label: 'Practitioner<br>Last, First',
		toolTip: 'Practitioner who rendered the service',
		visible: true,
		sortable: true,
		saveable: false,
		editable: false,
		isRecID: false,
		dataType: 'lastfirst',
		sortUsing: 'pracName',
		saveUsing: '',
		showMore: false
	});




	<% // Patient Name %>



	opts.fieldDefinitions.push({
		name: 'patName',
		label: 'Patient<br>Last, First',
		toolTip: 'Patient who received the service',
		visible: true,
		sortable: true,
		saveable: false,
		editable: false,
		isRecID: false,
		dataType: 'lastfirst',
		sortUsing: 'patName',
		saveUsing: '',
		showMore: false
	});




	<% // Service Date %>



	opts.fieldDefinitions.push({
		name: 'dosStr',
		label: 'Date of<br>Service',
		toolTip: 'The date the service was provided',
		visible: true,
		sortable: true,
		saveable: true,
		editable: false,
		isRecID: false,
		dataType: 'date',
		sortUsing: 'dos',
		saveUsing: 'dos',
		showMore: false
	});

	<% // Has Service Detail Flags (Additional Cell in Service Selection) %>

	let nameIDAdditionalCellValueFieldDefinitions = [];

	nameIDAdditionalCellValueFieldDefinitions.push({
		name: 'hasSvcDetFlags',
		label: '',
		toolTip: '',
		visible: true,
		sortable: false,
		editable: true,
		saveable: true,
		isRecID: false,
		dataType: 'hidden',
		sortUsing: '',
		saveUsing: 'hasSvcDetFlags',
		showMore: false
	});





	<% // Service Selection %>



	opts.fieldDefinitions.push({
		name: 'svcName',
		label: 'Service Provided',
		toolTip: 'The service that was provided',
		visible: true,
		sortable: true,
		editable: false,
		saveable: false,
		isRecID: false,
		dataType: 'text',
		sortUsing: 'svcName',
		showMore: false
	});




	<% // Start Time %>



	opts.fieldDefinitions.push({
		name: 'startTimeStrHHMM',
		label: 'Start<br>Time',
		toolTip: 'The time that the service was provided',
		visible: true,
		sortable: true,
		saveable: true,
		editable: false,
		isRecID: false,
		dataType: 'time',
		sortUsing: 'startTimeVal',
		showMore: false,
		saveUsing: 'starttime'
	});




	<% // Minutes %>



	opts.fieldDefinitions.push({
		name: 'numMins',
		label: 'Session<br>Minutes',
		toolTip: 'How many minutes it took to provide the service',
		visible: true,
		sortable: true,
		saveable: false,
		editable: false,
		isRecID: false,
		dataType: 'number',
		sortUsing: 'numMins',
		saveUsing: 'nummin',
		showMore: false
	});




	<% // Attendance Status %>



	opts.fieldDefinitions.push({
		name: 'attendanceStatusSelectionName',
		label: 'Attendance',
		toolTip: 'The attendance status for the practitioner and patient',
		visible: false,
		sortable: true,
		editable: false,
		saveable: true,
		sortUsing: 'attendanceStatusSelectionName',
		isRecID: false,
		dataType: 'text',
		showMore: false
	});


	<% //*************************************** Additional Row Control Definitions *********************************************%>




	<% // RMTS %>



	opts.additionalControlDefinitionsForBodyRows.set('selectAsAudited', {
		defType: 'userprovided',
		name: 'selectAsAudited',
		toolTip: 'Click Here to Associate with RMTS Audit Request',
		cssClass: 'far fa-handshake',
		handlerFn: function(uiActionObj) {
			debugger;
			if (var_matching_rmtssvcrec != 0 && var_matching_rmtssvcrec != null && var_matching_rmtssvcrec !== undefined)
				var_matching_rmtssvcrec = null;
			else {
				var_matching_rmtssvcrec = uiActionObj.recordID;

				sendUpdatedMatch();
			}

			$(
				'.fa-handshake', $(uiActionObj.e.currentTarget)
			).toggleClass('far').toggleClass('fas');

			return uiActionObj;

		},
		initiallyHidden: true
	});

	opts.additionalControlDefinitionsForBodyRows.set('deselectAsAudited', {
		defType: 'userprovided',
		name: 'deselectAsAudited',
		toolTip: 'Click Here to Unmatch from RMTS Audit Request',
		cssClass: 'fas fa-handshake-slash',
		handlerFn: function(uiActionObj) {

			$.get(
				'rmts_moments.asmx/sendUndoMatch?tkn=' + $.spedmonWebUI.token +
				'&matching_audit_req=' + uiActionObj.svcRecID
			).done(function() {
				updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMomentsReq();
				updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs();
			});

			return uiActionObj;
		},
		initiallyHidden: true
	});

	opts.additionalControlDefinitionsForBodyRows.set('infoHoverButton', {
		defType: 'userprovided',
		name: 'infoHoverButton',
		toolTip: '',
		cssClass: 'fas fa-info-circle',
		handlerFn: function(uiActionObj) {
			return uiActionObj;
		},
		initiallyHidden: true

	});




	<% // Flag Service As RMTS Moment %>



	opts.additionalControlDefinitionsForBodyRows.set('flagasrmtsmoment', {
		defType: 'userprovided',
		name: 'flagasrmtsmoment',
		toolTip: 'Click Here to Flag This Service as an RMTS Moment',
		cssClass: 'far fa-clock',
		handlerFn: function(uiActionObj) {

			var uiAtarget = $(uiActionObj.e.target);
			uiAtarget.removeClass('far').removeClass('fa-clock').addClass('fas fa-hourglass-half');

			let _svcrecid = uiActionObj.recordID;
			let _clientid = uiActionObj.whatFieldCellsInputValues.get('clientID');
			let _pracid = uiActionObj.whatFieldCellsInputValues.get('pracID');
			let _isRMTSMoment = '';
			var $cIcon = $(uiActionObj.whatElement).children('i.fa-clock')[0];

			/* Set new value */

			_isRMTSMoment = 'y';
			if ($($cIcon).hasClass(CSS_CLASS_RMTS_MOMENT_TOGGLED)) {
				_isRMTSMoment = 'n';
			}

			let _reqObj = {};
			_reqObj.clientid = _clientid;
			_reqObj.pracid = _pracid;
			_reqObj.isrmtsmoment = _isRMTSMoment
			_reqObj.recid = _svcrecid;

			let _elem = uiActionObj.dataObj.me;
			let reqUrl = '<%=Spedmon.ServiceRecords.URL_FLAG_EXISTING_AS_RMTS_MOMENT_INLINE_BASE()%>';
			let reqData = JSON.stringify(_reqObj);

			MBA.RestViewCommon.fnAjaxCallAsmxWebMethod(_elem, reqUrl, reqData)
				.then(responseData => {

					updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs();


				})
				.catch(responseData => {

					if (responseData.message) alert(responseData.message);
					else alert('problem!');

					updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs();

				});

			//return uiActionObj;

			return;
		},
		initiallyHidden: false
	});



	<% //*************************************** Row Creation Hooks *************************************************************%>

	opts.fnCreateNewRowBefore = function(newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

		//rowCtrlDefs.length = 0;

		//debugger;

		if (rowData && (rowData.WhoWereYouWith || rowData.WhatWereYouDoing)) {

			opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').initiallyHidden = false;
			opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').handlerFn = function(uiActionObj) {

				$.get(
					'rmts_moments.asmx/sendUndoMatch?tkn=' + $.spedmonWebUI.token +
					'&matching_audit_req=' + rowData.RmtsAuditReqID
				).done(function() {
					updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMomentsReq();
					updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs();
				});

				return uiActionObj;
			};

			opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').initiallyHidden = false;
			opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').toolTip =
				'I was with - ' + rowData.WhoWereYouWith + ' - ' + rowData.WhatWereYouDoing;
			rowCtrlDefs.push(
				opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton')
			);

		} else if (rowtype != 1) {

			opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited').initiallyHidden = false;

			opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').initiallyHidden = true;
			rowCtrlDefs.push(
				opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton')
			);

		}

		return newRow;

	}

	opts.fnCreateNewRowAfter = function($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {


		opts.additionalControlDefinitionsForBodyRows.set('infoHoverButton', {
			defType: 'userprovided',
			name: 'infoHoverButton',
			toolTip: '',
			cssClass: 'fas fa-info-circle',
			handlerFn: function(uiActionObj) {
				return uiActionObj;
			},
			initiallyHidden: true
		});

		opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited').initiallyHidden = true;
		opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').initiallyHidden = true;

		//rowCtrlDefs.pop();
		if (rowData && (rowData.WhoWereYouWith || rowData.WhatWereYouDoing)) {

			rowCtrlDefs.pop();

		}


		if (!rowData) return $newRow




			<% // Remove svc journal icon if not needed otherwise remove edit/del icons       %>



			if (rowData.svcJournalRelated === false) {
				let _svcJournalViewBut = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="svcjournalview"]')[0];
				let _svcJournalMgmtBut = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="svcjournalmanage"]')[0];
				if (_svcJournalViewBut) {
					$(_svcJournalViewBut).remove();
				}
				if (_svcJournalMgmtBut) {
					$(_svcJournalMgmtBut).remove();
				}
			}
		else {
			let _recEdtInlineStartBut = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="receditinlinestart"]')[0];
			let _recDelInlineStartBut = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="recdeleteinlinestart"]')[0];
			if (_recEdtInlineStartBut) {
				$(_recEdtInlineStartBut).remove();
			}
			if (_recDelInlineStartBut) {
				$(_recDelInlineStartBut).remove();
			}
		}




		<% // Set initial state for RMTS icon %>



		let _rmtsButIcon = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="flagasrmtsmoment"] > i.fa-clock')[0];

		if (_rmtsButIcon) {
			if (rowData.rmtsMomentVal === true) $(_rmtsButIcon).addClass(CSS_CLASS_RMTS_MOMENT_TOGGLED);
		}


		if ($newRow && rowData && rowData.svcrecIsAutoMatched)
			$('td.mba-rest-view-row-controls button[data-mba-rest-view-ctrl-def-name="deselectAsAudited"]', $newRow).css('color', '#10ab63');


		return $newRow;

	};


	<% //*************************************** Cell (Column) Creation Hooks ***************************************************%>

	opts.fnCreateNewCellAfter = function(newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) {



		return newCell;
	};


	$($restViewCtrl_rmtsServiceRecs).MBA_RestView(opts);

}

function handleFile(e) {
	var files = e.target.files;
	var f = files[0];

	var reader = new FileReader();

	reader.onload = function(e) {

		$('#formSheetData').val('');

		var workbook = XLSX.read(e.target.result);
		// var workbookData = {};
		var roa;

		workbook.SheetNames.forEach(function(sheetName) {

			var sss = workbook.Sheets[sheetName];
			var cell_n1 = sss['N1'];
			//var roa;

			if (cell_n1 && cell_n1.v)
				roa = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], {
					raw: false,
					header: 2
				});
			else
				roa = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], {
					raw: false,
					range: sss['!ref'].replace('A1:', 'A3:')
				});

			//if(roa.length > 0) workbookData[sheetName] = roa;

		});


		$("#formClientID").val($('#clientid').val());
		$("#formSheetData").val(JSON.stringify(
			roa //workbookData['Sheet1']
		));
	};
	reader.readAsArrayBuffer(f);

	$('#form1').attr('action',
		$('#form1').attr('action') + '?tkn=' + $.spedmonWebUI.token
	);

}


function initViewMomentsReq() {


	opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
	opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
	opts.enableSortControls = true;
	opts.enableRowNumbers = true;
	opts.enableRowControls = true;
	opts.enableRowControlRecAddNew = false;
	opts.enableRowControlRecEdit = false;
	opts.enableRowControlRecDelete = false;

	opts.saveModeAddNew = 'inwindow';
	opts.baseUrlAddNew = '';
	opts.baseUrlAddNewHasParameters = true;

	opts.saveModeEdit = 'inwindow';
	opts.baseUrlEdit = '';
	opts.baseUrlEditHasParameters = true;

	opts.saveModeDelete = 'inline';
	opts.baseUrlDelete = '';
	opts.baseUrlDeleteHasParameters = true;

	opts.loadModeView = 'rest';
	opts.baseUrlView = '<%=Spedmon.RmtsMoments.URL_REST_VIEW_RMTS_REQS()%>';
	opts.baseUrlViewHasParameters = true;


	//opts.defaultPageRowOrder      = 'ID asc';

	opts.enableReports    = true;
	opts.enableReportHtml = true;
	opts.enableReportXls  = true;
	opts.enableReportPdf  = false;

	opts.loadModeReport = 'mbawebreport';
	opts.baseUrlReport  = '<%=Spedmon.RmtsMoments.URL_WEB_REPORT_BASE()%>';
	opts.baseUrlReportHasParameters = true;
	opts.defaultReportNumber = '1';   // enters the ELSE of the first (outermost) IF in the .ashx file

	opts.fieldDefinitions = [];

	opts.fieldDefinitions.push({
		name: 'id',
		isRecID: true,
		saveable: false,
		saveUsing: 'recid'
	});

	opts.fieldDefinitions.push({
		name: 'id',
		label: 'ID',
		toolTip: 'ID',
		visible: true,
		editable: false,
		saveable: false,
		sortable: true,
        isRecID: false,
		dataType: 'number',
	});

	opts.fieldDefinitions.push({
		name: 'Quarter',
		label: 'Quarter',
		toolTip: 'Quarter',
		visible: true,
		editable: false,
		saveable: false,
		sortable: true,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'Quarter'
	});

	opts.fieldDefinitions.push({
		name: 'LastName',
		label: 'Last<br/>Name',
		toolTip: 'Last Name',
		visible: true,
		editable: false,
		saveable: false,
		sortable: true,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'LastName'
	});

	opts.fieldDefinitions.push({
		name: 'FirstName',
		label: 'First<br/>Name',
		toolTip: 'First Name',
		visible: true,
		editable: false,
		saveable: false,
		sortable: true,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'FirstName'
	});

	opts.fieldDefinitions.push({
		name: 'JobTitle',
		label: 'Job<br/>Title',
		toolTip: 'Job Title',
		visible: true,
		editable: false,
		saveable: false,
		sortable: true,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'JobTitle'
	});

	opts.fieldDefinitions.push({
		name: 'JobClassification',
		label: 'Job</br>Classification',
		toolTip: 'Job Classification',
		visible: true,
		editable: false,
		saveable: false,
		sortable: true,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'JobClassification'
	});

	opts.fieldDefinitions.push({
		name: 'momentDatetime',
		label: 'Sampled</br>Moment',
		toolTip: 'Sampled Moment',
		visible: true,
		editable: false,
		saveable: false,
		sortable: true,
		isRecID: false,
		dataType: 'date',
		saveUsing: '',
		sortUsing: 'momentDatetime'
	});

	opts.fieldDefinitions.push({
		name: 'ActivityCode',
		label: 'Activity<br/>Code',
		toolTip: 'Activity Code',
		visible: true,
		editable: false,
		saveable: false,
		sortable: false,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'ActivityCode'
	});

	opts.fieldDefinitions.push({
		name: 'SMAACode16AuditRequired',
		label: 'SMAA Code16</br>Audit Required?',
		toolTip: 'SMAA Code16 Audi tRequired?',
		visible: false,
		editable: false,
		saveable: false,
		sortable: false,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'SMAACode16AuditRequired'
	});

	opts.fieldDefinitions.push({
		name: 'LEABOPCode2AAuditRequired',
		label: 'LEA BOP</br>Code2A</br>Audit Required?',
		toolTip: 'LEA BOP Code2A Audit Required?',
		visible: true,
		editable: false,
		saveable: false,
		sortable: false,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'LEABOPCode2AAuditRequired'
	});

	opts.fieldDefinitions.push({
		name: 'RelatedToStudentAssessmentIEP_IFSP_CarePlan',
		label: 'Related To<br/>StudentAssessment<br/>IEP IFSP<br/>Care Plan?',
		toolTip: 'Related To StudentAssessment IEP IFSP Care Plan?',
		visible: true,
		editable: false,
		saveable: false,
		sortable: false,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'RelatedToStudentAssessmentIEP_IFSP_CarePlan'
	});

	opts.fieldDefinitions.push({
		name: 'WhoWereYouWith',
		label: 'Who Were</br>You With?',
		toolTip: 'Who Were You With?',
		visible: true,
		editable: false,
		saveable: false,
		sortable: false,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'WhoWereYouWith'
	});

	opts.fieldDefinitions.push({
		name: 'WhatWereYouDoing',
		label: 'What Were</br>You Doing?',
		toolTip: 'What Were You Doing?',
		visible: true,
		editable: false,
		saveable: false,
		sortable: false,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'WhatWereYouDoing'
	});

	opts.fieldDefinitions.push({
		name: 'WhyWereYouPerformingThisActivity',
		label: 'Why Were You</br>Performing This</br>Activity?',
		toolTip: 'Why Were You Performing This Activity?',
		visible: true,
		editable: false,
		saveable: false,
		sortable: false,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'WhyWereYouPerformingThisActivity'
	});

	opts.fieldDefinitions.push({
		name: 'ClarifyingQuestion1',
		label: 'Clarifying<br/>Question 1',
		toolTip: 'Clarifying Question 1',
		visible: true,
		editable: false,
		saveable: false,
		sortable: false,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'ClarifyingQuestion1'
	});

	opts.fieldDefinitions.push({
		name: 'ClarifyingQuestionAnswer1',
		label: 'Answer',
		toolTip: 'Clarifying Answer 1',
		visible: true,
		editable: false,
		saveable: false,
		sortable: false,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'ClarifyingQuestionAnswer1'
	});

	opts.fieldDefinitions.push({
		name: 'ClarifyingQuestion2',
		label: 'Clarifying<br/>Question 2',
		toolTip: 'Clarifying Question 2',
		visible: true,
		editable: false,
		saveable: false,
		sortable: false,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'ClarifyingQuestion2'
	});

	opts.fieldDefinitions.push({
		name: 'ClarifyingQuestionAnswer2',
		label: 'Answer',
		toolTip: 'Clarifying Answer 2',
		visible: true,
		editable: false,
		saveable: false,
		sortable: false,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'ClarifyingQuestionAnswer2'
	});

	opts.fieldDefinitions.push({
		name: 'CodingComments',
		label: 'Coding<br/>Comments',
		toolTip: 'Coding Comments',
		visible: true,
		editable: false,
		saveable: false,
		sortable: false,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: 'CodingComments'
	});

	opts.fieldDefinitions.push({
		name: 'pracID',
		label: 'pracID',
		toolTip: '',
		visible: true,
		editable: false,
		saveable: false,
		sortable: false,
		isRecID: false,
		dataType: 'text',
		saveUsing: '',
		sortUsing: ''
	});

	opts.additionalControlDefinitionsForBodyRows = new Map();
	opts.rowCtrlDefs = [];

	opts.additionalControlDefinitionsForBodyRows.set('handshakePlaceholder', {
		defType: 'userprovided',
		name: 'handshakePlaceholder',
		toolTip: '',
		cssClass: 'far fa-handshake',
		handlerFn: function(uiActionObj) {

			var next_step = $(uiActionObj.whatRow).data('rmts-next-step');
			debugger;
			if (next_step == 0)
				return opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').handlerFn(uiActionObj);

			if (next_step == 1)
				return opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited').handlerFn(uiActionObj);

			if (next_step == 2)
				return opts.additionalControlDefinitionsForBodyRows.get('flagCompleteBtn').handlerFn(uiActionObj);

			if (next_step == 3)
				return opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').handlerFn(uiActionObj);


			return uiActionObj;
		},
		initiallyHidden: false
	});

	opts.additionalControlDefinitionsForBodyRows.set('selectAsAudited', {
		defType: 'userprovided',
		name: 'selectAsAudited',
		toolTip: 'Click Here to Associate with Recorded RMTS Moment',
		cssClass: 'far fa-handshake',
		handlerFn: function(uiActionObj) {

			//debugger;
			var has_files = $(uiActionObj.whatRow).hasClass('hasFiles');

			if (var_matching_audit_req != 0 && var_matching_audit_req != null && var_matching_audit_req !== undefined &&
				(!(has_files))
			) {
				var_matching_audit_req = null;

			} else {
				var_matching_audit_req = uiActionObj.recordID;
				//debugger;

				if ($('.fas.fa-handshake', $(uiActionObj.e.currentTarget)).length > 0)
					$.get(
						'rmts_moments.asmx/sendFlaggedComplete?tkn=' + $.spedmonWebUI.token +
						'&matching_audit_req=' + uiActionObj.recordID
					).done(function() {
						updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMomentsReq();
						updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs();
					});
				else
					sendUpdatedMatch();

			}

			$(
				'.fa-handshake', $(uiActionObj.e.currentTarget)
			).toggleClass('far').toggleClass('fas');


			return uiActionObj;
		},
		initiallyHidden: true
	});

	opts.additionalControlDefinitionsForBodyRows.set('deselectAsAudited', {
		defType: 'userprovided',
		name: 'deselectAsAudited',
		toolTip: 'Click Here to Unmatch from Recorded RMTS Moment',
		cssClass: 'fas fa-handshake-slash',
		handlerFn: function(uiActionObj) {

                        //debugger;
                        $.spedmonWebUI.dialogConfirm(
                          'Unmatch Moment From Service Record?',
                          'Are you sure you wish to unmatch this RMTS moment from the matched service record?',
                          function() {
		        	  $.get(
			        	'rmts_moments.asmx/sendUndoMatch?tkn=' + $.spedmonWebUI.token +
				        '&matching_audit_req=' + uiActionObj.recordID
			          ).done(function() {
				var_count_requiring_matching++;
				updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMomentsReq();
				updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs();
			        });
                          },
                          function() {}
                        );

			return uiActionObj;
		},
		initiallyHidden: true

	});

	opts.additionalControlDefinitionsForBodyRows.set('infoHoverButton', {
		defType: 'userprovided',
		name: 'infoHoverButton',
		toolTip: '',
		cssClass: 'fas fa-info-circle',
		handlerFn: function(uiActionObj) {
			return uiActionObj;
		},
		initiallyHidden: true
	});

	opts.additionalControlDefinitionsForBodyRows.set('fileUpButton', {
		defType: 'userprovided',
		name: 'fileUpButton',
		toolTip: '',
		cssClass: 'fas fa-file-upload',
		handlerFn: function(uiActionObj) {

			var fileAdditionalDataJSON = {
				clientid: $('#clientid').val(),
				referencedentityid: uiActionObj.recordID
			};

			$.spedmonWebUI.fileList('RMTS Supporting Documentation', '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>', '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>', '<%=MBA.StoredFiles.PARAM_FILE_ID%>', 3 /* Record id position */ , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>', 625, '' //uiActionObj.recordID
				, '', '', JSON.stringify(fileAdditionalDataJSON), true, true);

			return uiActionObj;
		},
		initiallyHidden: false
	});

	opts.additionalControlDefinitionsForBodyRows.set('flagCompleteBtn', {
		defType: 'userprovided',
		name: 'flagCompleteBtn',
		toolTip: 'Click Here to Mark as Complete',
		cssClass: 'far fa-handshake' //'far fa-check-square'
			,
		handlerFn: function(uiActionObj) {
			debugger;
			$.get(
				'rmts_moments.asmx/sendFlaggedComplete?tkn=' + $.spedmonWebUI.token +
				'&matching_audit_req=' + uiActionObj.recordID
			).done(function() {
				updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMomentsReq();
				updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs();
			});

			return uiActionObj;
		},
		initiallyHidden: true // false
	});

	opts.additionalControlDefinitionsForBodyRows.set('flagIncompleteBtn', {
		defType: 'userprovided',
		name: 'flagIncompleteBtn',
		toolTip: 'Click Here to Unmark as Complete',
		cssClass: 'fas fa-handshake' //'fas fa-check-square'
			,
		handlerFn: function(uiActionObj) {
			//debugger;
			$.get(
				'rmts_moments.asmx/sendFlaggedIncomplete?tkn=' + $.spedmonWebUI.token +
				'&matching_audit_req=' + uiActionObj.recordID

        /// TODO !!!  // will need the clientID
			).done(function() {
				updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMomentsReq();
				updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs();
			});

			return uiActionObj;
		},
		initiallyHidden: true //false
	});

	opts.fnCreateNewRowBefore = function(newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

		opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited').rowDataJSON =
			JSON.stringify(rowData);

		//opts.additionalControlDefinitionsForBodyRows.set('selectAsAudited').rowDataJSON

		rowCtrlDefs.length = 0;

		if (rowtype != 1 && rowData) {
			if (rowData.rmtsReqState == 0)
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip =
				'No match found.  ';
			else if (rowData.rmtsReqState == 1)
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip =
				'Matching service record automatically found.  ';
			else if (rowData.rmtsReqState == 2)
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip =
				'The auto-matched service record has been rejected by an administrative end user.  ';
			else if (rowData.rmtsReqState == 3)
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip =
				'An administrative end user has found a matching service record for this RMTS moment.  ';
			else if (rowData.rmtsReqState == 4)
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip =
				'The practitioner has been prompted for information regarding this RMTS moment.  ';
			else if (rowData.rmtsReqState == 5)
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip =
				'The practitioner has found a matching service record for this RMTS moment.  ';
			else
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip =
				'A matching service record has been found, and the match has been deemed erroneous by an administrative end user.  Please correct this mistake.  ';

			if (rowData.hasFiles)
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip += 'Supporting documentation has been uploaded.  ';

			if (rowData.rmtsReqNextStep == 0) {

				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip += 'No action required; you can click here to reject this automatic match as erroneous.';
				//opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').handlerFn = opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').handlerFn

			} else if (rowData.rmtsReqNextStep == 1) {
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip += 'You may find a matching service record manually, upload ';
				if (rowData.hasFiles)
					opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip += 'additional ';
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip += 'supporting documentation, or prompt the practitioner for info.';
				if (rowData.hasFiles)
					opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip += '  Click twice to mark this row as complete.';

				//opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').handlerFn = opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited').handlerFn
			} else if (rowData.rmtsReqNextStep == 2) {

				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip += 'Please click to confirm this moment as complete and correct.';
				//opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').handlerFn = opts.additionalControlDefinitionsForBodyRows.get('flagCompleteBtn').handlerFn

			} else {
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').toolTip += 'No action required; you can click here to reject this match as erroneous.';
				//opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').handlerFn = opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').handlerFn
			}

			if (rowData.rmtsReqNextStep == 1)

				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').cssClass =
				opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited').cssClass

            else if (rowData.rmtsReqNextStep == 3)

                opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').cssClass =
				opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').cssClass

			else if (!((rowData.rmtsReqState == 1) || (rowData.rmtsReqState == 3) || (rowData.rmtsReqState == 5)))
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').cssClass =
				opts.additionalControlDefinitionsForBodyRows.get('flagIncompleteBtn').cssClass

			else {

				if (rowData.isComplete)

					opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').cssClass =
					opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').cssClass

				else

					opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').cssClass =
					opts.additionalControlDefinitionsForBodyRows.get('flagCompleteBtn').cssClass

			}

			if (rowData.mustCorrectThisMistake)
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').cssClass += ' text-danger';
			else if (rowData.isMatchedGreen)
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder').cssClass += ' text-success';


			rowCtrlDefs.push(
				opts.additionalControlDefinitionsForBodyRows.get('handshakePlaceholder')
			);

			if (rowData && rowData.svcRecID) {

				//opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').initiallyHidden = false;
				//rowCtrlDefs.push(
				//  opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited')
				//);

				opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').initiallyHidden = false;
				opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').toolTip =
					rowData.Patient + ' - ' + rowData.svcRecNotes;
				rowCtrlDefs.push(
					opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton')
				);

			} else if (rowtype != 1) {

				//opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited').initiallyHidden = false;
				//rowCtrlDefs.push(
				//  opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited')
				//);

				if (rowData && rowData.hasFiles) {

					opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').initiallyHidden = false;
					opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').toolTip =
						'see uploaded files attached';
					rowCtrlDefs.push(
						opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton')
					);
				} else {

					opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').initiallyHidden = true;
					rowCtrlDefs.push(
						opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton')
					);
				}

			}
		}

		if (rowData && (rowtype != 1)) {

			opts.additionalControlDefinitionsForBodyRows.get('fileUpButton').initiallyHidden = false;
			rowCtrlDefs.push(
				opts.additionalControlDefinitionsForBodyRows.get('fileUpButton')
			);

		}

		if (rowData && rowData.LEABOPCode2AAuditRequired && rowData.LEABOPCode2AAuditRequired.length > 55) {
			opts.fieldDefinitions[9].toolTip = rowData.LEABOPCode2AAuditRequired;
			rowData.LEABOPCode2AAuditRequired = rowData.LEABOPCode2AAuditRequired.substr(0, 55) + '... <i class="fa fa-info-circle"/>'
		}

		if (rowData && rowData.WhatWereYouDoing) rowData['WhatWereYouDoingORIG'] = rowData.WhatWereYouDoing;
		if (rowData && rowData.WhatWereYouDoing && rowData.WhatWereYouDoing.length > 55) {
			opts.fieldDefinitions[12].toolTip = rowData.WhatWereYouDoing;
			rowData.WhatWereYouDoing = rowData.WhatWereYouDoing.substr(0, 55) + '... <i class="fa fa-info-circle"/>'
		}

		if (rowData && rowData.WhyWereYouPerformingThisActivity) rowData['WhyWereYouPerformingThisActivityORIG'] = rowData.WhyWereYouPerformingThisActivity;
		if (rowData && rowData.WhyWereYouPerformingThisActivity && rowData.WhyWereYouPerformingThisActivity.length > 55) {
			opts.fieldDefinitions[13].toolTip = rowData.WhyWereYouPerformingThisActivity;
			rowData.WhyWereYouPerformingThisActivity = rowData.WhyWereYouPerformingThisActivity.substr(0, 55) + '... <i class="fa fa-info-circle"/>'
		}

		if (rowData && rowData.ClarifyingQuestion1) rowData['ClarifyingQuestion1ORIG'] = rowData.ClarifyingQuestion1;
		if (rowData && rowData.ClarifyingQuestion1 && rowData.ClarifyingQuestion1.length > 55) {
			opts.fieldDefinitions[14].toolTip = rowData.ClarifyingQuestion1;
			rowData.ClarifyingQuestion1 = rowData.ClarifyingQuestion1.substr(0, 55) + '... <i class="fa fa-info-circle"/>'
		}

		if (rowData && rowData.ClarifyingQuestionAnswer1) rowData['ClarifyingQuestionAnswer1ORIG'] = rowData.ClarifyingQuestionAnswer1;
		if (rowData && rowData.ClarifyingQuestionAnswer1 && rowData.ClarifyingQuestionAnswer1.length > 55) {
			opts.fieldDefinitions[15].toolTip = rowData.ClarifyingQuestionAnswer1;
			rowData.ClarifyingQuestionAnswer1 = rowData.ClarifyingQuestionAnswer1.substr(0, 55) + '... <i class="fa fa-info-circle"/>'
		}

		if (rowData && rowData.ClarifyingQuestion2) rowData['ClarifyingQuestion2ORIG'] = rowData.ClarifyingQuestion2;
		if (rowData && rowData.ClarifyingQuestion2 && rowData.ClarifyingQuestion2.length > 55) {
			opts.fieldDefinitions[16].toolTip = rowData.ClarifyingQuestion2;
			rowData.ClarifyingQuestion2 = rowData.ClarifyingQuestion2.substr(0, 55) + '... <i class="fa fa-info-circle"/>'
		}

		if (rowData && rowData.ClarifyingQuestionAnswer2) rowData['ClarifyingQuestionAnswer2ORIG'] = rowData.ClarifyingQuestionAnswer2;
		if (rowData && rowData.ClarifyingQuestionAnswer2 && rowData.ClarifyingQuestionAnswer2.length > 55) {
			opts.fieldDefinitions[17].toolTip = rowData.ClarifyingQuestionAnswer2;
			rowData.ClarifyingQuestionAnswer2 = rowData.ClarifyingQuestionAnswer2.substr(0, 55) + '... <i class="fa fa-info-circle"/>'
		}

		if (rowData && rowData.CodingComments) rowData['CodingCommentsORIG'] = rowData.CodingComments;
		if (rowData && rowData.CodingComments && rowData.CodingComments.length > 55) {
			opts.fieldDefinitions[18].toolTip = rowData.CodingComments;
			rowData.CodingComments = rowData.CodingComments.substr(0, 55) + '... <i class="fa fa-info-circle"/>'
		}


		return newRow;

	}

	opts.fnCreateNewRowAfter = function(newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

		//debugger;
		if (rowtype == 1) return newRow;

		var $msgIcon = $('<i style="font-size: 1.2em;" class="fas fa-comment fa-mba-messages-widget-class ml-2"></i>');

		//debugger;

		var messagesWidget_opts = {

			'clientID': '<%=rd.wu.usr.clientID%>',
			'sendMessageAjaxURL': '<%= Spedmon.RmtsMoments.URL_USERMSG_RMTS_REQ_INLINE_BASE() %>' +
				'&respPromptOptions=' +
				<%= Spedmon.Constants.RMTS_NOTIF_PROMPT_INCL_MANAGE_SVCRECS + Spedmon.Constants.RMTS_NOTIF_PROMPT_INCL_ADD_SVCREC + Spedmon.Constants.RMTS_NOTIF_PROMPT_INCL_FILEUPBOX_RMTSMOMNT %> +
				'&respPromptOptionsJSON=' +
				encodeURI(
					JSON.stringify({
						clientid: $('#clientid').val(),
						referencedentityid: rowData.id,
						matchrmtsdate: Date.parse(rowData.momentDatetime).toString('MM/dd/yyyy'),
                        rmtsAddNewServiceURL:
                           '<%= Spedmon.ServiceRecords.generateSharebleUrlRmtsMomentMatchAndSvcRecSave() %>'
					})
				),
			'deleteMessageAjaxURL': '',
			'recipientSrcURL': '<%=MBA.HttpApplication.createLink(Spedmon.Users.URL_ASMX_VIEWSEL, true)%>'
				//,  recipientIDs   :  rowData.PracUid
				,
			'replyModeOn': false,
			'allowDelete': false,
			'viewModeSubject': ('Please provide documentation for RMTS Moment - ' + Date.parse(rowData.momentDatetime).toString('MM/dd/yyyy'))

				,
			'textAreaPrefill': `You recently had an RMTS moment that requires supporting documentation.  Our reports do not show a a record for this moment.  For audit purposes, please either mark an existing service record (in SpEdCare) as an RMTS moment (check the clock next your record) or enter a service record in SpEdCare for this moment.  The date and time of the moment are in the subject line of this message and your RMTS Moment questions and responses are below.  Please contact me if you have any further questions.` +
				"\r\n -------------------- \r\n  " +
				Date.parse(rowData.momentDatetime).toString('MM/dd/yyyy @ hh:mm tt') +
				"\r\n -------------------- \r\n" +
				(
					rowData.WhoWereYouWithORIG ? ("Who Were You With?\r\n -------------------- \r\n" + rowData.WhoWereYouWithORIG + "\r\n -------------------- \r\n") : ''
				) + (
					rowData.WhatWereYouDoingORIG ? ("What Were You Doing?\r\n -------------------- \r\n" + rowData.WhatWereYouDoingORIG + "\r\n -------------------- \r\n") : ''
				) + (
					rowData.WhyWereYouPerformingThisActivityORIG ? ("Why Were You Performing This Activity?\r\n -------------------- \r\n" + rowData.WhyWereYouPerformingThisActivityORIG + "\r\n -------------------- \r\n") : ''
				) + (
					rowData.ClarifyingQuestion1ORIG ? ("Clarifying Question 1\r\n -------------------- \r\n" + rowData.ClarifyingQuestion1ORIG + "\r\n -------------------- \r\n") : ''
				) + (
					rowData.ClarifyingQuestionAnswer1ORIG ? ("Answer\r\n -------------------- \r\n" + rowData.ClarifyingQuestionAnswer1ORIG + "\r\n -------------------- \r\n") : ''
				) + (
					rowData.ClarifyingQuestion2ORIG ? ("Clarifying Question 2\r\n -------------------- \r\n" + rowData.ClarifyingQuestion2ORIG + "\r\n -------------------- \r\n") : ''
				) + (
					rowData.ClarifyingQuestionAnswer2ORIG ? ("Answer\r\n -------------------- \r\n" + rowData.ClarifyingQuestionAnswer2ORIG + "\r\n -------------------- \r\n") : ''
				) + (
					rowData.WhoWereYouWithORIG ? ("Coding Comments\r\n -------------------- \r\n" + rowData.WhoWereYouWithORIG + "\r\n -------------------- \r\n") : ''
				)

				,
			'isSendOnly': true,
			'senderUserID': '',
			'senderName': '',
			'messageID': ''
		}; //debugger;


		$msgIcon.messagesWidget(messagesWidget_opts);
		$('td.mba-rest-view-row-controls', newRow).append($msgIcon);

		$msgIcon.click(function() {
			$(this).css('color', '#c7c703');
		})

		if (rowData.respReqNotifSent)
			$msgIcon.css('color', '#c7c703');

		if (newRow && rowData && rowData.isMatchedGreen) {
			$('td.mba-rest-view-row-controls button[data-mba-rest-view-ctrl-def-name="deselectAsAudited"]', newRow).css('color', '#10ab63');
			$('td.mba-rest-view-row-controls button[data-mba-rest-view-ctrl-def-name="selectAsAudited"]', newRow).css('color', '#10ab63');
		}

		if (newRow && rowData && rowData.hasFiles)
			newRow.addClass('hasFiles');

		if (newRow && rowData)
			newRow.data('rmts-next-step', rowData.rmtsReqNextStep);


		return newRow;
	}


	$($restViewCtrl_rmtsMomentsReq).MBA_RestView(opts);

}


</script>
