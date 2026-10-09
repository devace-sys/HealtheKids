<%@ Page Language="C#" CodeBehind="user_all_patients_data_manage.aspx.cs" Inherits="Spedmon.UserAllPatientsDataManage"%>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div id="dataManagementRowsForFilesImported" class="container-fluid">

<div class="row">
<div class="col-auto">

<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectClient
  ID                   = "selectClient"
  rowLabel             = "Client?"
  dataEntryRowRenderAs = "FIELD"
  showClearSelection   = "true"
  runat                = "server">
</Spedmon:DataEntryRowSelectClient>

</div> <!-- col -->

<div class="col-auto">
  <button type="button" id="butDoExportRPRRXLS" class="btn btn-info">
    <span id="lblDoExportRPRRXLS">Download Redundant Patient Records Report </span>
    <i id="iconDoExportRPRRXLS" class="fa fa-file-excel"></i>
  </button>
</div> <!-- col -->

<div class="col-auto">
  <button type="button" id="butDoExportPPMXLS" class="btn btn-info">
    <span id="lblDoExportPPMXLS">Download Possible Patient Merges Report </span>
    <i id="iconDoExportPPMXLS" class="fa fa-file-excel"></i>
  </button>
</div> <!-- col -->

</div> <!-- row -->

<%//-----------------------------------------------------------------------------%>
<%// Rest Views %>
<%//-----------------------------------------------------------------------------%>

<div class="row mt-2">

<div class="col-12">


<div id="restViewFilesImported"></div> <!-- restview -->

</div> <!-- col -->
</div> <!--row -->


</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

let $dataManagementRowsFilesImported = null;
let $restViewFilesImportedCtrl = null;
let $butDoExportRPRRXLS;
let $iconDoExportRPRRXLS;
let $butDoExportPPMXLS;
let $iconDoExportPPMXLS;

const PARM_NAME_CLIENT_ID            = '<%=Constants.PARM_CLIENT_ID%>';

function filesImportedUpdateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

  let VALUE_CLIENT_ID     = $('#' + PARM_NAME_CLIENT_ID).val();

  let NV_CLIENT_ID   = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID,             VALUE_CLIENT_ID);

  /* Note: Don't use a loop here, keep it unrolled for performance reasons */

  $($restViewFilesImportedCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);

  /* Add additional parms for add new */

  $($restViewFilesImportedCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);

  $($restViewFilesImportedCtrl).MBA_RestView('requestViewFromServer', 1);

};

function initViewFilesImported()
{

  let opts = {};
  opts.loadModeView              = 'rest';
  opts.baseUrlView               = '<%=Spedmon.StructuredDataImportFilesPatientData.URL_REST_VIEW_BASE()%>';
  opts.baseUrlViewHasParameters  = true;
  opts.defaultPageRowOrder       = '<%=Spedmon.StructuredDataImportFilePatientData.DEFAULT_PAGING_ORDER%>';
  opts.sessionTimeOutUrl         = '<%=MBA.Credential.generateSessionExpiredLink()%>';
  opts.requestViewOnLoad         = false; /*This is so we can set the initial filters */
  opts.enableSortControls        = true;
  opts.enableRowNumbers          = false;
  opts.enableRowControls         = true;
  opts.enableRowControlRecAddNew = true;
  opts.saveModeAddNew             = 'inwindow';
  opts.baseUrlAddNew              = '<%=Spedmon.StructuredDataImportFilesPatientData.URL_IMPORT_USER_ALL_BASE()%>';
  opts.baseUrlAddNewHasParameters = true;
  opts.enableRowControlRecEdit    = false;
  opts.enableRowControlRecDelete  = false;

  opts.enableReports = false;
  opts.enableReportHtml = true;
  opts.enableReportXls  = true;
  opts.enableReportPdf  = false;

  opts.fieldDefinitions = [];

  opts.fieldDefinitions.push({
      name: 'id'
      , isRecID: true
      , saveable: true
      , saveUsing:'recid'
  });

  opts.fieldDefinitions.push({
          name: 'patientDataImportID'
        , label: 'ID'
        , toolTip: 'Patient data import id'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'patientDataImportID'
        , saveUsing: ''
        , showMore: false
    });

  opts.fieldDefinitions.push({
            name: 'clientName'
            , label: 'Client'
            , toolTip: 'Clients Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'string'
            , sortUsing: 'clientName'
            , saveUsing: ''
            , showMore: false
  });

  opts.fieldDefinitions.push({
        name: 'fileName'
        , label: 'File Name'
        , toolTip: 'File Name'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'fileName'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'fileProfileName'
        , label: 'File Contains'
        , toolTip: 'What is in the file'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'fileProfileName'
        , saveUsing: ''
        , showMore: false
    });


    opts.fieldDefinitions.push({
        name: 'numOfIncomingPatDataRecords'
        , label: 'Number<br>of Rows'
        , toolTip: 'Number of incoming records'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'numOfIncomingPatDataRecords'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
          name: 'numRowsCSISMissing'
        , label: 'Number<br>of Rows<br/>w/ Missing SSID'
        , toolTip: 'Number of incoming rows with CSIS/SSID field left blank'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'numRowsCSISMissing'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'numRowsSuccessfullyImported'
        , label: 'Number<br/>Of Patients<br/>Imported'
        , toolTip: 'Number of patient records successfully matched or inserted'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'number'
        , sortUsing: 'numRowsSuccessfullyImported'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
          name: 'numRowsToBeSentInOutgoingElig'
        , label: 'Records<br/>To Be Sent<br/>For Elig'
        , toolTip: 'Number of rows to be included in the outgoing elig file'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'number'
        , sortUsing: 'numRowsToBeSentInOutgoingElig'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'importedByUserName'
        , label: 'Imported By'
        , toolTip: 'Who imported the file'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'importedByUserName'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'importedOnStr'
        , label: 'Imported On'
        , toolTip: 'What date and time was the file sent to us'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'importedOn'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'isTestMode'
        , label: 'Test Mode?'
        , toolTip: 'Indicates whether this is a test or live'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'isTestMode'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
          name: 'currentStatusStr'
        , label: 'Current Status'
        , toolTip: 'What is the current status of the file'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'currentStatusStr'
        , saveUsing: ''
        , showMore: false
    });



    opts.fieldDefinitions.push({
        name: 'importResultsStatusStr'
        , label: 'Import Results'
        , toolTip: 'What were the results of the import process'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'importResultsStatusStr'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
          name: 'rejectedValidateGradeDOBsYN'
        , label: 'Rejected Grade/DOBs ?'
        , toolTip: 'Was the file rejected due to odd or unusual DOBs for grade level'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'rejectedValidateGradeDOBsYN'
        , saveUsing: ''
        , showMore: false
    });

    opts.fieldDefinitions.push({
        name: 'unknownProblemYN'
        , label: 'Unknown Problem?'
        , toolTip: 'Did the file fail to process for an unknown or mathematically unlikely reason'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'string'
        , sortUsing: 'unknownProblemYN'
        , saveUsing: ''
        , showMore: false
    });

    /* Setup additional row controls */

    opts.additionalControlDefinitionsForBodyRows = new Map();


    /* Import Results */

    opts.additionalControlDefinitionsForBodyRows.set('importresults', {
        defType: 'userprovided'
        , name: 'importresults'
        , toolTip: 'Click here for import results report'
        , cssClass: 'fas fa-search'
        , handlerFn: function (uiActionObj) {
            let importResultsRptUrl = '<%=Spedmon.StructuredDataImportFilesPatientData.URL_IMPORT_RESULTS_USER_ALL_BASE()%>' + uiActionObj.recordID;
            let importResultsRptWindow = MBA.RestViewCommon.fnOpenWindow(uiActionObj.elem, importResultsRptUrl, null, false);
            return uiActionObj;
        }
        , initiallyHidden: false
    });

    opts.additionalControlDefinitionsForBodyRows.set('reprocessAsLive', {
        defType: 'userprovided'
        , name: 'reprocessAsLive'
        , toolTip: 'Reprocess in Live Mode'
        , cssClass: 'fa fa-lock'
        , handlerFn: function(uiActionObj) {
    			  //debugger;

             
            var fn_asmxAjax = function() {
              MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(
              'structured_data_imports_files_patient_data.asmx/sendFlaggedReprocessLive?tkn=' + 
              $.spedmonWebUI.token,  // why not have fnAjaxCallAsmxWebMethod accept a true/false parameter to append the tkn ?
              JSON.stringify( {pdiID: uiActionObj.recordID} ),
              null)
                .then(responseData => {
                    //$.spedmonWebUI.dialogMessage('Scheduled Tonight','An eligibility file is scheduled to be created tonight, for this patient data import.');

                    var $tr = $(
                      'tr[data-mba-rest-view-rec-id=' +  uiActionObj.recordID + ']'
                     );

                    $('button[data-mba-rest-view-ctrl-def-name="reprocessAsLive"]'  , $tr).toggleClass('text-success');
                    
                })

                .catch(responseData => {
                    //debugger;
                    $.spedmonWebUI.dialogMessage('Problem','Problem scheduling this item.  Try again, or reload the page.');
                });
              };

              $.spedmonWebUI.dialogConfirm(
                'Finalize Data Import?',
                'Are you sure you want to finalize the import of this data? You will not be able to undo this once it is done.',
                fn_asmxAjax,
                null);
              

    			  return uiActionObj;
    		}
       , initiallyHidden: true
    });

    <% if ( is_pcalStaff ) { %>

    opts.additionalControlDefinitionsForBodyRows.set('scheduleelig', {
        defType: 'userprovided'
        , name: 'scheduleelig'
        , toolTip: 'Schedule an eligibility match file to be generated tonight'
        , cssClass: 'fas fa-file-export'
        , handlerFn: function(uiActionObj) {
    			  //debugger;

             
            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(
              'structured_data_imports_files_patient_data.asmx/sendFlaggedScheduledTonight?tkn=' + 
              $.spedmonWebUI.token,  // why not have fnAjaxCallAsmxWebMethod accept a true/false parameter to append the tkn ?
              JSON.stringify( {pdiID: uiActionObj.recordID} ),
              null)
                .then(responseData => {
                    $.spedmonWebUI.dialogMessage('Scheduled Tonight','An eligibility file is scheduled to be created tonight, for this patient data import.');

                    var $tr = $(
                      'tr[data-mba-rest-view-rec-id=' +  uiActionObj.recordID + ']'
                     );

                    $('button[data-mba-rest-view-ctrl-def-name="scheduleelig"]'  , $tr).toggleClass('mba-rest-view-hidden');
                    $('button[data-mba-rest-view-ctrl-def-name="unscheduleelig"]', $tr).toggleClass('mba-rest-view-hidden');
                })

                .catch(responseData => {
                    //debugger;
                    $.spedmonWebUI.dialogMessage(
                      'Problem',
                      (  responseData.message ? responseData.message :
                        'Problem scheduling this item.  Try again, or reload the page.'
                      )
                    );
                });
              

    			  return uiActionObj;
    		}
        , initiallyHidden: true
    });

    opts.additionalControlDefinitionsForBodyRows.set('unscheduleelig', {
        defType: 'userprovided'
        , name: 'unscheduleelig'
        , toolTip: 'Un-schedule an eligibility match file to be generated tonight'
        , cssClass: 'fas fa-file-export text-warning'
    ,   handlerFn: function(uiActionObj) {



            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(
              'structured_data_imports_files_patient_data.asmx/sendFlaggedUnscheduled?tkn=' + 
              $.spedmonWebUI.token,  // why not have fnAjaxCallAsmxWebMethod accept a true/false parameter to append the tkn ?
              JSON.stringify( {pdiID: uiActionObj.recordID} ),
              null)
                .then(responseData => {
                    $.spedmonWebUI.dialogMessage('Item Unscheduled','An eligibility file has been manually un-scheduled for this patient data import.');

                    var $tr = $(
                      'tr[data-mba-rest-view-rec-id=' +  uiActionObj.recordID + ']'
                     );

                    $('button[data-mba-rest-view-ctrl-def-name="scheduleelig"]'  , $tr).toggleClass('mba-rest-view-hidden');
                    $('button[data-mba-rest-view-ctrl-def-name="unscheduleelig"]', $tr).toggleClass('mba-rest-view-hidden');
                })

                .catch(responseData => {
                    $.spedmonWebUI.dialogMessage('Problem','Problem un-scheduling this item.  Try again, or reload the page.');
                });
              

    			  return uiActionObj;

    }
    , initiallyHidden: true //false
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

    opts.fnCreateNewRowBefore = function(newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

  		if (rowtype != 1 && rowData) {

  	      rowCtrlDefs.length = 1;  // since the magnifying glass icon is already here, unconditionally;
                                   // if all of the icons were conditional we would be making this = 0

          if (rowData.okToCommitData == 0 && rowData.processingCompleted == 1 && rowData.processingError != 1 )
            opts.additionalControlDefinitionsForBodyRows.get('reprocessAsLive').initiallyHidden = false;
          else
            opts.additionalControlDefinitionsForBodyRows.get('reprocessAsLive').initiallyHidden =  true;


          rowCtrlDefs.push(
            opts.additionalControlDefinitionsForBodyRows.get('reprocessAsLive')
          );

          if (rowData.generateEligibilityMatchFile) {

            opts.additionalControlDefinitionsForBodyRows.get('unscheduleelig').initiallyHidden = false;
            opts.additionalControlDefinitionsForBodyRows.get('scheduleelig').initiallyHidden = true;


          }  else  {

          opts.additionalControlDefinitionsForBodyRows.get('scheduleelig').initiallyHidden = false;
            opts.additionalControlDefinitionsForBodyRows.get('unscheduleelig').initiallyHidden = true;


          }


        rowCtrlDefs.push(
          opts.additionalControlDefinitionsForBodyRows.get('scheduleelig')
        );
        rowCtrlDefs.push(
          opts.additionalControlDefinitionsForBodyRows.get('unscheduleelig')
        );


          opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').initiallyHidden = false;

          if (rowData.generateEligibilityMatchFile) {

	  	    opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').toolTip =
		      'An eligibility file is scheduled to be created tonight, for this patient data import.'

          } else if ( rowData.eligibilityMatchFileGenerated && !(rowData.eligibilityMatchReturnFileReceived)  ) {
                
	  	    opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').toolTip =
		      'An eligibility file has been created for this patient data import and is awaiting processing and return.'   
    
         

          } else if ( rowData.eligibilityMatchReturnFileReceived ) {

	  	    opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').toolTip =
		      'An eligibility file has been processed and returned for this patient data import.'

          } else if ( rowData.eligibilityMatchfileGenerationUnscheduled ) {

	  	    opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').toolTip =
		      'An eligibility file has been manually un-scheduled for this patient data import.'


          } else {

	  	    opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').toolTip =
		      'You may schedule an eligibility file to be created tonight from the data.'

          }

		  rowCtrlDefs.push(
			  opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton')
		  );




      }

      return newRow;



   }

   <%  } %>

   /* Create the rest view */

   $($restViewFilesImportedCtrl).MBA_RestView(opts);

};

function doExport ($butDoExport, $iconDoExport, rptFmt, rptCookieName, rptNum) {

        $($butDoExport).prop('disabled', true);

        let $waitingIcon = $('<i class="fa fa-spinner fa-pulse fa-fw m-auto"></i>');
        $waitingIcon.insertAfter($iconDoExport);

        let reqUrl = '<%=Spedmon.Patients.URL_WEB_REPORT_BASE()%>';

              let reqData = [
                  MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_CLIENT_ID%>", $("#<%=Constants.PARM_CLIENT_ID%>").val()),
           
          ];
            
          MBA.ComponentCommon.fnRequestDownloadWebReportDocument (
                  reqUrl
                , rptFmt
                , rptNum
                , rptCookieName
                , reqData
                , function () {
                  $($butDoExport).prop('disabled', false); $waitingIcon.remove();
                }
              , function () {
                  $($butDoExport).prop('disabled', false); $waitingIcon.remove();
              }
          );
    };

function doExportRPRRXLS() {
    doExport($butDoExportRPRRXLS, $iconDoExportRPRRXLS, <%=Constants.REPT_FORMAT_XLS%>, 'Rpt_Possible_Redundant_Pat_Recs_XLS',<%=Spedmon.PatientsRpt.REPT_REDUNDANT_RECORDS%>);
};

function doExportPPMXLS() {
    doExport($butDoExportPPMXLS, $iconDoExportPPMXLS, <%=Constants.REPT_FORMAT_XLS%>, 'Rpt_Possible_Patient_Merges_XLS',<%=Spedmon.PatientsRpt.REPT_MERGES%>);
};

$(document).ready(function () {
   $dataManagementRowsFilesImported = $('#dataManagementRowsForFilesImported');
   $restViewFilesImportedCtrl       = $('#restViewFilesImported');
   initViewFilesImported();
    $butDoExportRPRRXLS = $('#butDoExportRPRRXLS');
    $iconDoExportRPRRXLS = $('#iconDoExportRPRRXLS');
    $butDoExportPPMXLS = $('#butDoExportPPMXLS');
    $iconDoExportPPMXLS = $('#iconDoExportPPMXLS');

    $($butDoExportRPRRXLS).on('click', function (e) { doExportRPRRXLS(); });
    $($butDoExportPPMXLS).on('click', function (e) { doExportPPMXLS(); });

  $($dataManagementRowsFilesImported).on('spedmoninputdata', function (e) {
     filesImportedUpdateAdditionalViewParameterValuesAndRequestViewFromServer(e);
  });

  filesImportedUpdateAdditionalViewParameterValuesAndRequestViewFromServer(null);

});

</script>
