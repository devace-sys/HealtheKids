

;var MBA = (MBA || {});


/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.ClientComplianceTasks
 * @memberof     MBA
 * @summary      Static methods used on a screen
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */



MBA.ClientComplianceTasks = (function ($)
{

    //const CONST_ATTR_NAME_FIELD_NAME = 'data-mba-rest-view-field-name';
    //const CONST_ATTR_VALUE = 'data-mba-rest-view-alt-value';

    var $dataEntryRows      = null;
    var $dataManagementRows = null;
    var $restViewCtrl       = null;
    var $taskID             = null;
    var $isComplete         = null;


    function populateClientComplianceItemForm(item) {
        $("#duedate").val(item.dueDateStrYMD);
        $("#datetoshowondashboard").val(item.dateToShowOnDashboardStrYMD);
        $("#savetype").val($.spedmonWebUI.RECORD_SAVE_TYPE_EDIT);
        $("#recid").val(item.id);
    }


    function updateAdditionalViewParameterValuesAndRequestViewFromServer(opts, e) {

        if ( typeof(opts ) == 'undefined')
          return;

        if (typeof (opts.PARM_NAME_CLIENT_ID) == 'undefined')
          return;


           let VALUE_CLIENT_ID        = $('#' + opts.PARM_NAME_CLIENT_ID).val();

        if (opts.isRestviewPreview == true) {
            if (!(VALUE_CLIENT_ID)) return;
            if (!(VALUE_CLIENT_ID > 0)) return;
        }

           let VALUE_TASK_ID = $('#' + opts.PARM_NAME_TASK_ID).val();
           let VALUE_IS_PENDING       = $('#' + opts.PARM_NAME_IS_PENDING).val();
           let VALUE_IS_NOT_COMPLETED = $('#' + opts.PARM_NAME_IS_NOT_COMPLETED).val();
           let VALUE_IS_COMPLETED     = $('#' + opts.PARM_NAME_IS_COMPLETED).val();

           let VALUE_FY_ID            = $('#' + opts.PARM_NAME_FY_ID).val();


       if ( !( opts.isPcalStaff ) ) {

           VALUE_TASK_ID          = "";

       }


        let NV_CLIENT_ID        = MBA.RestViewCommon.fnCreateNameValueObject(opts.PARM_NAME_CLIENT_ID,        VALUE_CLIENT_ID);
        let NV_TASK_ID          = MBA.RestViewCommon.fnCreateNameValueObject(opts.PARM_NAME_TASK_ID,          VALUE_TASK_ID);
        let NV_IS_PENDING       = MBA.RestViewCommon.fnCreateNameValueObject(opts.PARM_NAME_IS_PENDING,       VALUE_IS_PENDING);
        let NV_IS_NOT_COMPLETED = MBA.RestViewCommon.fnCreateNameValueObject(opts.PARM_NAME_IS_NOT_COMPLETED, VALUE_IS_NOT_COMPLETED);
        let NV_IS_COMPLETED     = MBA.RestViewCommon.fnCreateNameValueObject(opts.PARM_NAME_IS_COMPLETED,     VALUE_IS_COMPLETED);

        let NV_FY_ID     = MBA.RestViewCommon.fnCreateNameValueObject(opts.PARM_NAME_FY_ID,     VALUE_FY_ID);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_TASK_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_IS_PENDING);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_IS_NOT_COMPLETED);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_IS_COMPLETED);

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_FY_ID );

        //if ( opts.isRestviewPreview )

          // TODO: trying to implement a reduced result set in preview mode;
          //       not working

          //$($restViewCtrl).MBA_RestView(
          //    'additionalParameterDefinitionForViewSet',
          //     MBA.RestViewCommon.fnCreateNameValueObject('pagesize', 3 )
          //);



        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

    };


    var  __resetItemStatusFilterFlags = function(a,b){};
      // need to define a placeholder function; we
      // re-define this function point when the init runs

    function resetItemStatusFilterFlags(a,b) {
      return __resetItemStatusFilterFlags(a,b);
    }
    // wrapper function; attaches to the control.
    // the underlying handler isn't implemented until the init runs



    function doDeleteForOneClient(a,b,c) {
      return __doDeleteForOneClient(a,b,c);
    }
    // wrapper function; attaches to the restview row.
    // the underlying handler isn't implemented until the init runs.
    // we want and need this function name to be defined in a global (ish)
    // scope, so we don't have to "dig" for it (using a bunch of dot operators)
    // to invoke.

    function doDeleteForAllClients(a,b,c) {
      return __doDeleteForAllClients(a,b,c);
    }

    function initView( opts ) {


        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */

        opts.enableSortControls = true;
        opts.enableRowNumbers = true;

        //opts.isRestviewPreview = false;


        if ( opts.isRestviewPreview )    {

          opts.enableRowControlRecAddNew = false;
          opts.enableRowControlRecEdit = false;
          opts.enableRowControlRecDelete = false;
          opts.autoHidePageControls = true;
          opts.enableScrollView = true;
          opts.scrollViewUseCustomHeight = true;
          opts.scrollViewCustomHeight = '9em';

          opts.enableRowControls = true;

        } else {

          opts.enableRowControls = true;
          opts.enableRowControlRecAddNew = false;
          opts.enableRowControlRecEdit = true;
          opts.enableRowControlRecDelete = false;

        }

        opts.saveModeAddNew = 'inline';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inline';


        opts.baseUrlEditHasParameters = true;
        opts.refreshViewAfterInlineEditProceed = true;

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView = 'rest';

        opts.baseUrlViewHasParameters = true;

        opts.enableReports      = true;
        opts.enableReportHtml   = false;
        opts.enableReportXls    = true;
        opts.enableReportPdf    = false;

        opts.loadModeReport               =  'mbawebreport';
        opts.baseUrlReport                =  opts.reportBaseUrl;
        opts.baseUrlReportHasParameters   =  true;
        opts.defaultReportNumber          =  '1';

        //debugger;

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
            name: 'clientID'
            , label: 'Client ID'
            , toolTip: 'Client ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'clientid'
            , sortUsing: 'clientID'
        });

        if ( opts.isPcalStaff ) {
          opts.fieldDefinitions.push({
            name: 'clientName'
            , label: 'Client'
            , toolTip: 'Client Name'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'clientName'
          });


       }
       else {

          opts.fieldDefinitions.push({
            name: 'isComplete'
            , label: 'Completed'
            , toolTip: 'Status'
            , visible: true
            , editable: (  opts.isRestviewPreview ? false : true )
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType:  (  opts.isRestviewPreview ? 'text' : 'checkbox' )
            , saveUsing: 'iscomplete'
            , sortUsing: 'isComplete'
          });

        if (  opts.isRestviewPreview )
          // NOTE: this callback is called once per-table, rather than per row;
          // Observe how I'm using the jQuery $.each function below.
          // I could have used a different callback for this
          opts.fnBeforeDrawTableBodyRows = function (elem, returnData, $me, dataObj) {

            if (dataObj.hasRecords === false)
                return returnData

             //debugger;

           $.each( returnData.data , function( iter, val) {
              if (val.isComplete > 0) {
                returnData.data[iter].isComplete = '<i class="fas fa-check-circle text-success"></i>';
              }
              else {
                returnData.data[iter].isComplete = '<i class="fas fa-exclamation-circle text-danger"></i>';
              }
            });

            return returnData;
        }

       }

        opts.fieldDefinitions.push({
            name: 'clientComplianceItemID'
            , label: 'Task ID'
            , toolTip: 'Task ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'clientcomplianceitemid'
            , sortUsing: 'clientComplianceItemID'
        });

        opts.fieldDefinitions.push({
            name: 'taskID'
            , label: 'Task ID'
            , toolTip: 'Task ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'taskid'
            , sortUsing: 'taskID'
        });

        opts.fieldDefinitions.push({
            name: 'taskName'
            , label: 'Task'
            , toolTip: 'Task Name'
            , visible: true

            , editable: ! opts.isRestviewPreview
            , saveable: ! opts.isRestviewPreview

            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'taskname'
            , sortUsing: 'taskName'
        });

        if ( !( opts.isRestviewPreview ) )   {

          opts.fieldDefinitions.push({
            name: 'descriptiveRankingPerClientFyTask'

            , label: 'Item Count'
            , toolTip: 'Item count for this task, this fiscal year'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'descriptiveRankingPerClientFyTask'
          });

        }

        if (  opts.isPcalStaff ) {

          opts.fieldDefinitions.push({
            name: 'isComplete'
            , label: 'Completed'
            , toolTip: 'Completed'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false

            , dataType: 'checkbox'

            , saveUsing: 'iscomplete'
            , sortUsing: 'isComplete'
          });
       }

        opts.fieldDefinitions.push({
            name: 'dueDateStrYMD'
            , label: 'Due Date'
            , toolTip: 'Due Date'
            , visible: true

            , editable: true
            , saveable: true

            , sortable: true
            , isRecID: false
            , dataType: 'date'

            , saveUsing: 'duedate'
            , sortUsing: 'dueDate'

        });

        // if (  opts.isPcalStaff )

          opts.fieldDefinitions.push({
            name: 'editduedateallclients'
            , label: 'Edit Due Date<br/>All Clients?'
            , toolTip: 'Edit Due Date<br/>All Clients?'


            , visible: (  opts.isPcalStaff ? true : false )
            , editable: true
            , saveable: true

            , sortable: true
            , isRecID: false

            , dataType: (  opts.isPcalStaff ? 'checkbox' : 'hidden' )
            , saveUsing: 'editduedateallclients'
            , sortUsing: ''
          });

        // if (  opts.isPcalStaff )

          opts.fieldDefinitions.push({
            name: 'dateToShowOnDashboardStrYMD'
            , label: 'Dashboard Date'
            , toolTip: 'Dashboard Date'

            , visible: ( opts.isPcalStaff ? true : false )

            , editable: ( opts.isPcalStaff ? true : false )

            , saveable: true

            , sortable: true
            , isRecID: false
            , dataType: 'date'

            , saveUsing: 'datetoshowondashboard'
            , sortUsing: 'dateToShowOnDashboard'
          });

        //if (  opts.isPcalStaff )

          opts.fieldDefinitions.push({
            name: 'editdashboarddateallclients'
            , label: 'Edit Dashboard Date<br/>All Clients?'
            , toolTip: 'Edit Dashboard Date<br/>All Clients?'

            , visible: (  opts.isPcalStaff ? true : false )

            , editable: true
            , saveable: true

            , sortable: true
            , isRecID: false

            , dataType: (  opts.isPcalStaff ? 'checkbox' : 'hidden' )

            , saveUsing: 'editdashboarddateallclients'
            , sortUsing: ''
          });


        if ( !( opts.isRestviewPreview ) )   {


          opts.fieldDefinitions.push({
            name: 'dateCompletedStrYMD'
            , label: 'Date Completed'
            , toolTip: 'Date Completed'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'datecompleted'
            , sortUsing: 'dateCompleted'
          });

        opts.fieldDefinitions.push({
            name: 'notes'
            , label: 'Notes'
            , toolTip: 'Notes'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'textarea'
            , saveUsing: 'notes'
            , sortUsing: 'notes'
        });

        }

          opts.fieldDefinitions.push({
            name: 'lastModifiedByNameStr'
            , label: 'Last Edit By'
            , toolTip: 'Last Edit By'
            , visible: true
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'lastModifiedByNameStr'
            , sortUsing: 'lastModifiedByNameStr'
          });

         if ( !( opts.isRestviewPreview ) )
            opts.fieldDefinitions.push({
            name: 'lastModifiedStr'
            , label: 'Last Edit'
            , toolTip: 'Last Edit'
            , visible: true
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'lastModified'
            , sortUsing: 'lastModified'
          });

          if (  opts.isPcalStaff ) {

            opts.additionalControlDefinitionsForBodyRows.set('deleteforonecli', {
               defType: 'userprovided'
             , name: 'deleteforonecli'
             , toolTip: 'Delete for 1 client'
             , cssClass: 'fa fa-trash-alt'
             , handlerFn: function (uiActionObj) {
               doDeleteForOneClient( uiActionObj.recordID );
               return uiActionObj;
               }
             , initiallyHidden: false
            });

            opts.additionalControlDefinitionsForBodyRows.set('deleteforallcli', {
               defType: 'userprovided'
             , name: 'deleteforallcli'
             , toolTip: 'Delete for all clients'
             , cssClass: 'fa fa-dumpster text-danger'
             , handlerFn: function (uiActionObj) {
                 doDeleteForAllClients( uiActionObj.recordID );
                 return uiActionObj;
               }
             , initiallyHidden: false
            });

            opts.fnOnEditInlineStart = function (uiActionObj) {

              $('table', $restViewCtrl).addClass(
                "mba-rest-view-tbl-is-editing"
              );

              return uiActionObj;
            };

            var done_with_edit = function (uiActionObj) {


              $('table', $restViewCtrl).removeClass(
                "mba-rest-view-tbl-is-editing"
              );


              return uiActionObj;
            };

            opts.fnOnEditInlineCancel = done_with_edit;

            opts.fnEditInlineProceedAfter = function (uiActionObj, responseData, success) {
              if (success)
                done_with_edit();
            }

            /* apply special classes for dynamic hide-show behavior */
            opts.fnNewRowBeforeAppendToBodyExisting = function (newRow ) {


              $('td[data-mba-rest-view-field-name="editdashboarddateallclients"]' , newRow ).addClass(
                 "mba-rest-view-col-show-for-edit"
              );

              $('td[data-mba-rest-view-field-name="editduedateallclients"]' , newRow ).addClass(
                  "mba-rest-view-col-show-for-edit"
              );


              return newRow;
           }


        }

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

        /* apply special classes for dynamic hide-show behavior */


        $('th[data-mba-rest-view-save-using="editduedateallclients"]' , $restViewCtrl).addClass(
           "mba-rest-view-col-show-for-edit"
        );


        $('th[data-mba-rest-view-save-using="editdashboarddateallclients"]' , $restViewCtrl).addClass(
           "mba-rest-view-col-show-for-edit"
        );



    }

    function replaceSaveBtnWithIcon() {
        let $saveBtn = $('button[title="Save & Proceed"]');
        $saveBtn.attr("class", "").addClass('spedmon-btn-no-style');
        $saveBtn.html('<i class="fa fa-save fa-2x mr-2" title="Save & Proceed"></i>');
    }

    return {

      fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer: function(){
        updateAdditionalViewParameterValuesAndRequestViewFromServer( MBA.ClientComplianceTasks.optsIn ) ;
      }
      ,
      resetItemStatusFilterFlags: resetItemStatusFilterFlags ,
      fnSetup: function( optsIn ) {



        MBA.ClientComplianceTasks.optsIn = optsIn;
        //
        $dataEntryRows      = $('#' + optsIn.dataEntryRowsDivID  );
        $dataManagementRows = $('#' + optsIn.dataManagementDivID );
        $restViewCtrl       = $('#' + optsIn.restViewDivID       );

        $taskID             = $('#' + optsIn.PARM_NAME_TASK_ID);
        $isComplete         = $('#' + optsIn.PARM_NAME_IS_COMPLETE);

        __resetItemStatusFilterFlags = function(oldval, newval) {

          // Not Completed

          if (newval == "2") {
            $('#' + optsIn.PARM_NAME_IS_PENDING).val('');
            $('#' + optsIn.PARM_NAME_IS_NOT_COMPLETED).val('1');
            $('#' + optsIn.PARM_NAME_IS_COMPLETED).val('');
          }

          // Completed

          else if (newval == "3") {
            $('#' + optsIn.PARM_NAME_IS_PENDING).val('');
            $('#' + optsIn.PARM_NAME_IS_NOT_COMPLETED).val('');
            $('#' + optsIn.PARM_NAME_IS_COMPLETED).val('1');
          }

          // Pending

          else if (newval == "1") {
            $('#' + optsIn.PARM_NAME_IS_PENDING).val('1');
            $('#' + optsIn.PARM_NAME_IS_NOT_COMPLETED).val('');
            $('#' + optsIn.PARM_NAME_IS_COMPLETED).val('');
          }

          // Any status

          else if (newval == "0") {
            $('#' + optsIn.PARM_NAME_IS_PENDING).val('');
            $('#' + optsIn.PARM_NAME_IS_NOT_COMPLETED).val('');
            $('#' + optsIn.PARM_NAME_IS_COMPLETED).val('');
          }

      };



      //  NOTE: observe how we are calling this function immediately after defining it;
      //  this isn't just function definitions, there are also calls here.
      __resetItemStatusFilterFlags( null, "0");


        // not used now, as removing (some of) the controls from the page
        // was part of the spec; consider removing these function definitions later

        __loadClientComplianceItemIfExists = function (e) {



          var reqUrl = optsIn.URL_LOAD_N_BASE;


          var reqData = JSON.stringify({
              "taskid" : e.dataitem.id
            , "recid"  : null
          });

          MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                populateClientComplianceItemForm(responseData.rawData.entity);
            })
            .catch(responseData => {
                $("#savetype").val($.spedmonWebUI.RECORD_SAVE_TYPE_NEW);
                $("#recid").val('');
                $("#duedate").val('');
                $("#datetoshowondashboard").val('');
            });
        }


        __doDeleteForOneClient = //function(opURL, recID, $st) {
        function( recID ) {

             opURL = optsIn.URL_DELETE_INLINE_BASE;

             var fnDoYes = function () {
               $.spedmonWebUI.ajax(null, opURL, '{recid: ' + recID + ', deleteforallclients: 0 }', null, null, null, null, null , 1, function () {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                  'Deleting for this client',
                  'Task has been deleted for the selected fiscal year, for this client only.',
                   {}
                );


                updateAdditionalViewParameterValuesAndRequestViewFromServer( optsIn ) ;

               });
             } ;

             //debugger;


             $.spedmonWebUI.dialogConfirm('Delete for this client?'
               , 'Task will be deleted for the selected fiscal year, for this client only.'
               , fnDoYes
               , null);


        }

        __doDeleteForAllClients = //function(opURL, recID, $st) {
        function( recID ) {

             opURL = optsIn.URL_DELETE_INLINE_BASE;

             var fnDoYes = function () {
               $.spedmonWebUI.ajax(null, opURL, '{recid: ' + recID + ', deleteforallclients: 1 }', null, null, null, null, null , 1, function () {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                  'Deleting for all clients',
                  'Task has been deleted for the selected fiscal year, for all clients.',
                   {}
                );

                updateAdditionalViewParameterValuesAndRequestViewFromServer( optsIn ) ;

               });
             } ;

             //debugger;


             $.spedmonWebUI.dialogConfirm('Delete for all clients?'
               , 'Task will be deleted for the selected fiscal year, for all clients.'
               , fnDoYes
               , null);


        }

        initView(optsIn);

        $($dataManagementRows).on('spedmoninputdata', function ( e ) {


            updateAdditionalViewParameterValuesAndRequestViewFromServer(optsIn);
            if (optsIn.isRestviewPreview == true) {
                e.stopImmediatePropagation();
                e.stopPropagation();
            }
        });

        updateAdditionalViewParameterValuesAndRequestViewFromServer(optsIn);

        replaceSaveBtnWithIcon();

    }

  };


})(jQuery);
