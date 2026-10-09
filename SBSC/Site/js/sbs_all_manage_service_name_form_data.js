
const DATA_ATTR_FORM_BUILDER_CTRL_NAME          = 'data-form-builder-ctrl-name';
const DATA_ATTR_FORM_BUILDER_CTRL_NAME_OPEN_DIA = 'opendia';
//
//

let $dataManagementRows = null;
let $restViewCtrl = null;

let dataObj;

let PARM_NAME_CLIENT_ID;
let PARM_NAME_PLAN_TYPE;
let PARM_NAME_GROUP_ID;
let PARM_NAME_NAME_ID;
let PARM_NAME_PRACTICE_FAMILY_ID;
let PARM_NAME_SVC_TYPE_ID;
let PARM_NAME_SEARCH_TERM;


let PARM_NAME_EXL_NOCLI;

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

let $restViewServiceNameFormDataCtrl;
let viewBaseUrl;

let deleteInlineUrl;
let multiDeleteInlineUrl;
let multiCloneUrl;

let rptUrl;

let saveFormJsonMultiUrl;

let elemIdWrapClientForCloningTo;


let editBaseUrl;
let cloneBaseUrl;
let clientNvps;
let spEdSvcCodeNvps;
let storedFilesViewSelUrl;
let sessionExpiredUrl;



let doDeleteMulti = function (uiActionObj) {   //
        
        // let dataObj = _fnGetDataObj(uiActionObj.me);

        let _recIDs = '';
        _recIDs = MBA.RestViewCommon.fnGetMarkedRowsRecordIDsAsCsvStr(uiActionObj.me);

        if (_recIDs == '') return;

        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID ).val();

        

        let _reqObj = {};
        _reqObj.recids   = _recIDs;
        _reqObj.clientid = VALUE_CLIENT_ID;
        
        let _requestDataJSON = JSON.stringify(_reqObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(
          multiDeleteInlineUrl,
          _requestDataJSON,
          sessionExpiredUrl)
            .then(responseData => {
                $(uiActionObj.me).MBA_RestView('refreshCurrentViewFromServer', 1);

                let $ctrlDeleteMarked = MBA.RestViewCommon.fnFindHeaderControl(uiActionObj.me, 'deleteMarked');
                MBA.RestViewCommon.fnAnimateRowControlInfinite($ctrlDeleteMarked, 'bounce', true, true);

            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Delete Record(s)', err.message, {});
            });
    };


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/


//
function doManageFormData(taElement, readOnly) {
    if (readOnly) {
        spedmonRenderFormFromJSON($(taElement), null, false, true);
    } else {
        spedmonRenderFormBuilderBox($(taElement));
    }    
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {

    let VALUE_CLIENT_ID          = $('#' + PARM_NAME_CLIENT_ID).val();
    let VALUE_PLAN_TYPE          = $('#' + PARM_NAME_PLAN_TYPE).val();
    let VALUE_GROUP_ID           = $('#' + PARM_NAME_GROUP_ID).val();
    let VALUE_PRACTICE_FAMILY_ID = $('#' + PARM_NAME_PRACTICE_FAMILY_ID).val();
    let VALUE_SVC_TYPE_ID        = $('#' + PARM_NAME_SVC_TYPE_ID).val();
    let VALUE_SEARCH_TERM        = $('#' + PARM_NAME_SEARCH_TERM).val();


    VALUE_EXL_NOCLI =  $( '#' + PARM_NAME_EXL_NOCLI ).val();
 
    let NV_CLIENT_ID          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
    let NV_PLAN_TYPE          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PLAN_TYPE, VALUE_PLAN_TYPE);
    let NV_GROUP_ID           = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_GROUP_ID, VALUE_GROUP_ID);
    let NV_PRACTICE_FAMILY_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PRACTICE_FAMILY_ID, VALUE_PRACTICE_FAMILY_ID);
    let NV_SVC_TYPE_ID        = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SVC_TYPE_ID, VALUE_SVC_TYPE_ID);
    let NV_SEARCH_TERM        = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SEARCH_TERM, VALUE_SEARCH_TERM);


    let NV_EXL_NOCLI        = MBA.RestViewCommon.fnCreateNameValueObject(
                              PARM_NAME_EXL_NOCLI, VALUE_EXL_NOCLI
                           );

    /* Note: Don't use a loop here, keep it unrolled for performance reasons */

    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PLAN_TYPE);
    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_GROUP_ID);
    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRACTICE_FAMILY_ID);
    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SVC_TYPE_ID);
    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_SEARCH_TERM);


    $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_EXL_NOCLI );

    $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

};
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function initView () {

    let optsIn = {};
    optsIn.requestViewOnLoad         = true; 
    optsIn.enableSortControls        = true;
    optsIn.enableRowNumbers          = true;
    optsIn.enableRowControls         = true;
    optsIn.enableRowControlRecEdit   = true;
    optsIn.enableRowControlRecClone  = true;

    optsIn.enableRowControlRecDelete   = true;
    
    optsIn.baseUrlView = viewBaseUrl;
    optsIn.baseUrlViewHasParameters = true;
    optsIn.defaultPageRowOrder      = 'name asc';
    optsIn.saveModeEdit = 'inline';
    optsIn.baseUrlEdit = editBaseUrl;
    optsIn.baseUrlEditHasParameters = true;
    optsIn.additionalParameterDefinitionsForEdit = new Map();

    optsIn.saveModeDelete = 'inline';
    optsIn.baseUrlDelete = deleteInlineUrl;

    optsIn.saveModeClone = 'inline';
    optsIn.baseUrlClone = cloneBaseUrl;
    optsIn.baseUrlCloneHasParameters = true;
    optsIn.additionalParameterDefinitionsForClone = new Map();


    optsIn.enableReports    = true;
    optsIn.enableReportHtml = false;

    optsIn.enableReportXls  = true;
    optsIn.enableReportPdf  = false;

    optsIn.loadModeReport             =  'mbawebreport';
    optsIn.baseUrlReport              =  rptUrl;

    optsIn.baseUrlReportHasParameters =  true;
    optsIn.defaultReportNumber        =  '1';

    optsIn.enableRowControlMarkRow = true ;

    optsIn.fieldDefinitions = [];

    optsIn.fieldDefinitions.push({
          name: 'id'
        , isRecID: true
    });

   /* Add recid to satisfy web method */
    /*
    optsIn.fieldDefinitions.push({
        name: 'id'
        , visible: false
        , editable: false
        , saveable: true
        , sortable: false
        , dataType: 'hidden'
        , dataTypeOptions: {}
        , sortUsing: ''
        , saveUsing: 'recid'
        , showMore: false
    });
    */

    let fillablePdfSelectionsOpts = {};

    fillablePdfSelectionsOpts.viewSelURL = storedFilesViewSelUrl;
    fillablePdfSelectionsOpts.sessionExpiredURL = sessionExpiredUrl;
    fillablePdfSelectionsOpts.fnGetStaticRequestNvps = function () {
        let _requestNvps = [];
        _requestNvps.push(MBA.ComponentCommon.fnCreateNameValueObject('pracid', ''));
        _requestNvps.push(MBA.ComponentCommon.fnCreateNameValueObject('patid', ''));
        _requestNvps.push(MBA.ComponentCommon.fnCreateNameValueObject('referencedentityid', ''));
        _requestNvps.push(MBA.ComponentCommon.fnCreateNameValueObject('fileclass', '60'));
        _requestNvps.push(MBA.ComponentCommon.fnCreateNameValueObject('filenamespace', ''));
        _requestNvps.push(MBA.ComponentCommon.fnCreateNameValueObject('filesource', ''));
        return _requestNvps;
    };

    optsIn.fieldDefinitions.push({
          name: 'formDataJson'
        , label: 'Manage<br>Form<br>Data'
        , toolTip: ''
        , visible: true
        , editable: true
        , saveable: true
        , sortable: false
        , isRecID: false
        , dataType: 'jsondata'
        , dataTypeOptions: {}
        , sortUsing: ''
        , saveUsing: 'formdatajson'

        , additionalCssClassesForCol: 'px-3'   //

        , showMore: false
    });

    optsIn.fieldDefinitions.push({
        name: 'groupID'
        , visible: false
        , editable: false
        , saveable: true
        , sortable: false
        , isRecID: false
        , dataType: 'hidden'
        , dataTypeOptions: {}
        , sortUsing: ''
        , saveUsing: 'groupid'
        , showMore: false
    });

    optsIn.fieldDefinitions.push({
          name: 'planTypeID'
        , visible: false
        , editable: false
        , saveable: true
        , sortable: false
        , isRecID: false
        , dataType: 'hidden'
        , dataTypeOptions: {}
        , sortUsing: ''
        , saveUsing: 'plantypeid'
        , showMore: false
    });

    optsIn.fieldDefinitions.push({
        name: 'svcNameID'
        , visible: false
        , editable: false
        , saveable: true
        , sortable: false
        , isRecID: false
        , dataType: 'hidden'
        , dataTypeOptions: {}
        , sortUsing: ''
        , saveUsing: 'nameid'
        , showMore: false
    });

    optsIn.fieldDefinitions.push({
        name: 'hasPatientGoalTracking'
        , label: 'Patient<br>Goal<br>Tracking'
        , toolTip: 'Has Patient Goal Tracking'
        , visible: true
        , editable: true
        , saveable: true
        , sortable: true
        , isRecID: false
        , dataType: 'checkbox'
        , dataTypeOptions: {}
        , sortUsing: 'hasPatientGoalTracking'
        , saveUsing: 'haspatientgoaltracking'
        , showMore: false
    });

    optsIn.fieldDefinitions.push({
        name: 'hasSessionRatingTracking'
        , label: 'Session<br>Rating<br>Tracking'
        , toolTip: 'Has Session Rating Tracking'
        , visible: true
        , editable: true
        , saveable: true
        , sortable: true
        , isRecID: false
        , dataType: 'checkbox'
        , dataTypeOptions: {}
        , sortUsing: 'hasSessionRatingTracking'
        , saveUsing: 'hassessionratingtracking'
        , showMore: false
    });

    optsIn.fieldDefinitions.push({
        name: 'groupName'
        , label: 'Discipline'
        , toolTip: 'Practitioner discipline'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , dataTypeOptions: {}
        , sortUsing: 'groupName'
        , saveUsing: ''
        , showMore: false
    });

    optsIn.fieldDefinitions.push({
        name: 'groupRequiresSupervisionStr'
        , label: 'Requires<br>Supervision'
        , toolTip: 'Does this discipline require supervision?'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'yesno'
        , dataTypeOptions: {}
        , sortUsing: 'groupRequiresSupervision'
        , saveUsing: ''
        , showMore: false
    });

    optsIn.fieldDefinitions.push({
        name: 'planTypeName'
        , label: 'Plan'
        , toolTip: 'Plan Type'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , dataTypeOptions: {}
        , sortUsing: 'planTypeName'
        , saveUsing: ''
        , showMore: false
    });

    optsIn.fieldDefinitions.push({
        name: 'svcName'
        , label: 'Service'
        , toolTip: 'Service Name'
        , visible: true
        , editable: false
        , saveable: false
        , sortable: true
        , isRecID: false
        , dataType: 'text'
        , dataTypeOptions: {}
        , sortUsing: 'svcName'
        , saveUsing: ''
        , showMore: false
    });


    let spEdSvcCodeFieldOptions = {};
    spEdSvcCodeFieldOptions.selections = spEdSvcCodeNvps;

    optsIn.fieldDefinitions.push({
        name: 'spEdSvcCodeValue'
        , label: 'CALPADS Code'
        , toolTip: 'Associated CALPADS code'
        , visible: true
        , editable: true
        , saveable: true
        , sortable: true
        , isRecID: false
        , dataType: 'selectoption'
        , dataTypeOptions: spEdSvcCodeFieldOptions
        , sortUsing: 'spEdSvcCodeName'
        , saveUsing: 'spedsvccodevalue'
        , showMore: false
    });

    let clientIDFieldOptions = {};
    clientIDFieldOptions.selections = clientNvps;

    optsIn.fieldDefinitions.push({
          name: 'clientID'
        , label: 'Client'
        , toolTip:'Associated client'
        , visible: true
        , editable: true
        , saveable: true
        , sortable: true
        , isRecID: false
        , dataType: 'selectoption'
        , dataTypeOptions: clientIDFieldOptions
        , sortUsing: 'clientName'
        , saveUsing: 'clientid'
        , showMore: false
    });

    optsIn.fieldDefinitions.push({
        name: 'fillablePdfSelectionsJSON'
        , label: 'Select<br>Fillable<br>PDFs'
        , toolTip: 'Select files'
        , visible: true
        , editable: true
        , saveable: true
        , sortable: false
        , isRecID: false
        , dataType: 'autocompletemultiple'
        , dataTypeOptions: fillablePdfSelectionsOpts
        , sortUsing: ''
        , saveUsing: 'fillablepdfselectionsjson'
        , showMore: false
    });


    /* Setup additional row controls */

    optsIn.additionalControlDefinitionsForBodyRows = new Map();

    /* Button to view form data */
    /*
    optsIn.additionalControlDefinitionsForBodyRows.set('showformdata', {
        defType: 'userprovided'
        , name: 'showformdata'
        , toolTip: 'Click Here to View Form Data (READ ONLY)'
        , cssClass: 'fa fa-book'
        , handlerFn: function (uiActionObj) {
            let $ta = $(uiActionObj.whatRow).find('td[data-mba-rest-view-field-name="formDataJson"] > textarea.mba-rest-view-data-type-json-data')[0];
            doManageFormData($ta, true);
            return uiActionObj;
        }
        , initiallyHidden: false
    });
    */
    /* Wire up code injection */



    /* Inject code to show or hide fillable pdf selections and add form builder button */

    optsIn.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem) {

        /* We are searching for a particular cell to enhance */

        if (fieldDefinition.name === 'fillablePdfSelectionsJSON') {
            /* Client specific rows only */
            if (rowData.clientID == '') {
                $(newCell).hide();
            }
        }

        if (fieldDefinition.name === 'formDataJson') {
            
            let $butManageFormData   = $('<button type="button"></button>');      
            let $iconManageFormData1 = $('<i class="mba-rest-view fa fa-book"></i>');
            let $iconManageFormData2 = $('<i class="mba-rest-view fa fa-plus-square"></i>');

            /* Use same class as the row controls */

            $($butManageFormData).addClass(MBA.RestViewCommon.CONST_CSS_CLASSES.ctrlButton);

            /* Add custom attribute so a generic handler set on the tbody can uniqely identify */

            $($butManageFormData).attr(DATA_ATTR_FORM_BUILDER_CTRL_NAME
                                       , DATA_ATTR_FORM_BUILDER_CTRL_NAME_OPEN_DIA);

            /* Add in required attributes to tie into edit row control mechanisms */

            $($butManageFormData).attr(MBA.RestViewCommon.ATTR_NAME_FIELD_EDIT_STATE, MBA.RestViewCommon.ATTR_VALUE_EDIT_STATE_LOCKED);
            $($butManageFormData).attr('disabled', '');

            /* Add common icon to button */

            $($butManageFormData).append($iconManageFormData1);

            /* Assume no form data */
            $($butManageFormData).attr('title', 'Create New Form');
            
            /* If we have form data add a second stacked icon and change title */

            if (rowData.hasFormData === true) {
                $($iconManageFormData1).addClass('text-success');
                $($iconManageFormData2).addClass('text-success');
                $($butManageFormData).append($iconManageFormData2);
                $($butManageFormData).attr('title', 'Edit Existing Form');
            }
            else {
                $($butManageFormData).attr('title', 'Create New Form');
                $($iconManageFormData1).addClass('text-secondary');
            }
            newCell.append($butManageFormData);
        }    

        /* Return cell new as required */

        return newCell;
    }

    optsIn.additionalControlDefinitionsForHeadRows = new Map();


    optsIn.additionalControlDefinitionsForHeadRows.set( 'checkmarkAll', {
        defType: 'userprovided'
        , name: 'checkmarkAll'
        , toolTip: 'Click here to mark or unmark all rows for this page.'

        , cssClass: 'far fa-check-square'   // NOTE!  No obvious way to add arbitrary bootstrap classes to the built-in XLS download icon.  Using fnCreateNewRowAfter();

        , handlerFn: function (uiActionObj) {
            
            var  _markedRows = MBA.RestViewCommon.fnGetMarkedRows(uiActionObj.me);               

	        if ($(_markedRows).length > 0) {
	            //alert('must unmark all');
                    MBA.RestViewCommon.fnUnMarkMarkedRows(uiActionObj.me);
                      // NOTE: another built-in function for fnMarkAllRenderedRows() would be really nice to have
                    
	        }
	        else {

	            //alert('must mark all');
                //debugger;

                    $( 'td.mba-rest-view-row-controls.mba-rest-view-visible-tbl-td-or-th[data-mba-rest-view-row-controls="8"]'
                       , $restViewServiceNameFormDataCtrl)
                      .each(
	                        function(iter,el) {

                            $(el).parent().attr(
                              'data-mba-rest-view-row-marked', '1'
                            );

	                        var uiActionObj_manip = uiActionObj;   // this is assigned-by-reference... doesn't really prevent changes to the uiActionObj, unfortunately.
	                        uiActionObj_manip.whatCellOrCol = el;
	                        uiActionObj_manip.whatContextElement = 'td';
	                        uiActionObj_manip.whatElement = '';

	                        //debugger;

	                        MBA.RestViewCommon.fnMarkRow(uiActionObj_manip);
	                      }
                      );
	        }
	        return uiActionObj;

	      }
        , initiallyHidden: false
    });

    optsIn.additionalControlDefinitionsForHeadRows.set('deleteMarked', {
        defType: 'userprovided'
        , name: 'deleteMarked'
        , toolTip: 'Click here to delete all highlighted rows.'
        , cssClass: 'fas fa-trash-alt text-danger'
        , handlerFn: function (uiActionObj) {
            doDeleteMulti(uiActionObj);                    
            return uiActionObj;
        }
        , initiallyHidden: false
    });


    optsIn.fnOnRowMarked = function (uiActionObj, _markedRows) {

        // debugger;

        let $ctrlDeleteMarked = MBA.RestViewCommon.fnFindHeaderControl(uiActionObj.me, 'deleteMarked');
        if ($(_markedRows).length > 0) {

            // NOTE: not sure of there is a limited, count-the-seconds animation built-in
            // in the RestViewCommon library.

            MBA.RestViewCommon.fnAnimateRowControlInfinite($ctrlDeleteMarked, 'bounce', true, false);

            setTimeout( function() {
                  MBA.RestViewCommon.fnAnimateRowControlInfinite($ctrlDeleteMarked, 'bounce', true, true);
              }, 2400);

            $ctrlDeleteMarked.removeClass('mba-rest-view-highlight');
        }
        else {
            MBA.RestViewCommon.fnAnimateRowControlInfinite($ctrlDeleteMarked, 'bounce', true, true);
        }
        return uiActionObj;
    };

    /* TODO: Tie in for showing/hiding client selection */

    optsIn.fnNewRowBeforeAppendToBodyExisting = function (newRow, rowData, opts) {
        //  debugger;  //
        //$( 'i.fa.fa-file-excel' , newRow ).addClass('btn');
        return newRow;
    } ;

   optsIn.fnCreateNewRowAfter = function (newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
      //debugger;

      
      return newRow;
   }

   optsIn.fnCreateNewColBefore = function (
      newCol, rowIdxCtr, colIdxCtr, opts, fieldDefinition
    ) {
      //debugger;  //

      return newCol;
    } ; 

   optsIn.fnCreateNewColAfter = function (
      newCol, rowIdxCtr, colIdxCtr, opts, fieldDefinition
    ) {

      //debugger;   //


       //append book icon to open blank form
      /*
      if (colIdxCtr == 1) {

            let $butManageFormData   = $('<button type="button"></button>');      
            let $iconManageFormData1 = $('<i class="mba-rest-view fa fa-book"></i>');

            // Use same class as the row controls 

            $($butManageFormData).addClass(MBA.RestViewCommon.CONST_CSS_CLASSES.ctrlButton);

            // Add custom attribute so a generic handler set on the tbody can uniqely identify

            $($butManageFormData).attr(DATA_ATTR_FORM_BUILDER_CTRL_NAME
                                       , DATA_ATTR_FORM_BUILDER_CTRL_NAME_OPEN_DIA);

            // Add common icon to button 

            $($butManageFormData).append($iconManageFormData1);

            // Assume no form data
            $($butManageFormData).attr('title', 'Start From Empty Form');

            newCol.append($butManageFormData);

            $butManageFormData.on('click',
              function() {
                debugger;
                spedmonRenderFormBuilderBox(
                  null, false   // no save button 
                );
              }
             );

      }
      */


      return newCol;
    } ; 

    /* Create the rest view */

    //debugger;

    $($restViewServiceNameFormDataCtrl).MBA_RestView(optsIn);
    
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function copyFormDataToActiveRows(e, prepend = false, append = false, replace = false) {      // rename to selected rows...  //


    try {
        // paste from clipboard
        // src: https://developer.mozilla.org/en-US/docs/Web/API/Clipboard/readText
        navigator.clipboard.readText().then(function (pastedData) {
            try {


        //debugger;

    if ( !prepend && !append && !replace ) return;

    let _recIDs = '';
    _recIDs = MBA.RestViewCommon.fnGetMarkedRowsRecordIDsAsCsvStr( $restViewCtrl );


    var make_json_blob_for_updates = function(
      recids, pastedData,
      prepend = false, append = false, replace = false
    ) {
          if ( !prepend && !append && !replace ) return;

          split_recids = recids.split(',');

          var r_updated = {};

          if ( replace ) {
            $.each( split_recids,
              function(i_iter, i_val) {
                r_updated[ i_val ] = pastedData;
              } 
            );
          }

          return  r_updated ;
    }


    let $copyBtn = $('#copyToActiveRows'); 

    //debugger;

    var json_blob_for_updates =  make_json_blob_for_updates(
			_recIDs, pastedData, prepend, append, replace );

    var _reqObj = {
      recids           :  _recIDs ,
      updatedformjson  :  JSON.stringify( json_blob_for_updates )
    };


    let _requestDataJSON = JSON.stringify( _reqObj );
      // multiple levels of nesting and multiple .stringify() calls feel spaghetti-ish,
      // but it's the simplest implementation that works.

    
			        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(

			          saveFormJsonMultiUrl,

			          _requestDataJSON,
			          sessionExpiredUrl)
			            .then(responseData => {
			                $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer', 1);
                            $('body').mbaHighlight({ color: "#bdffc7", duration: 300 });
			                //let $ctrlDeleteMarked = MBA.RestViewCommon.fnFindHeaderControl(uiActionObj.me, 'deleteMarked');
			                //A.RestViewCommon.fnAnimateRowControlInfinite($ctrlDeleteMarked, 'bounce', true, true);

			            })
			            .catch(err => {
			                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Failed', err.message, {});
			            });




            } catch (e) {
                // indicate failure
                $copyBtn.addClass('btn-danger').fadeOut(200).fadeIn(200).fadeOut(200).fadeIn(200, function () { $(this).removeClass('btn-danger'); });
                return;
            }
        });

    } catch (e) {
        // indicate failure
        $copyBtn.addClass('btn-danger').fadeOut(200).fadeIn(200).fadeOut(200).fadeIn(200, function () { $(this).removeClass('btn-danger'); });
        return;
    }
}
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/


function cloneSelectedForSpecifiedClient() {

    let $cloneBtn = $('#cloneSelectedForSpecifiedClient');

    var handle_catch = function(err_str) {

      $cloneBtn.addClass('btn-danger').fadeOut(600).fadeIn(600).fadeOut(600).fadeIn(600, function () { $(this).removeClass('btn-danger'); }); 
      if ( err_str === undefined || !(err_str) )
        err_str = 'There was a problem';
      MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err_str , {});
    }



    try {

        var _recIDs = MBA.RestViewCommon.fnGetMarkedRowsRecordIDsAsCsvStr( $restViewCtrl );
        var clientidforcloningto = $('#clientidforcloningto').val();

        requestJSON = JSON.stringify({ 
          clientidforclones : clientidforcloningto ,
          recids : _recIDs
        });

        
       // debugger;


        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(multiCloneUrl, requestJSON, null)
            .then( function(responseData) {

               // debugger;

               // alert('.then() !!');
               $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');


            })
            .catch( function(err) {

                 //alert('.catch() !!');
                 // debugger;
                 handle_catch(err.message);
                //$($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');

                //MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', 'There was a problem', {});

            });


    } catch (e) {

        //$($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');

        handle_catch();

        // indicate failure
        
        return;

    }
}



/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function init() {

    initView();

    dataObj = $($restViewServiceNameFormDataCtrl).MBA_RestView('getDataObj');

    $(dataObj.tbody).on('click', 'tr > td ' + '*[' + DATA_ATTR_FORM_BUILDER_CTRL_NAME + ']', function (e) {
        let $ta = $(this).siblings('textarea.mba-rest-view-data-type-json-data')[0];       
        doManageFormData($ta,false);
    });

    /*initView();*/

    $('input', $dataManagementRows).not(
        '#' + elemIdWrapClientForCloningTo + ' input').on('spedmoninputdata',
        function (e) {
          updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

    $('input#term').on('change',
        function (e) {
          updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        }
    );
    
}