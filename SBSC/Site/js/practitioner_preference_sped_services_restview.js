; var MBA = (MBA || {});

MBA.PractitionerSpedSvcsMgmt = (function ($) {


 var _x23_restViewCtrl_MgmSvcResponsibilities;
 var _x23_restViewCtrl_Container;

 var PractitionerSpedSvcsMgmt_PARM_NAME_CLIENT_ID;
 var PractitionerSpedSvcsMgmt_PARM_NAME_PRAC_ID;

 var _x23_cliid_ctl_id;
 var _x23_prac_ctl_id;


 let _updateParamsRestViewMgmSvcResponsibilities_andReqFromServer = function() {

          let VALUE_CLIENT_ID              = $( _x23_cliid_ctl_id ).val();
          let VALUE_PRAC_ID                = $( _x23_prac_ctl_id)  .val();

          if ( VALUE_CLIENT_ID  &&  VALUE_PRAC_ID ) {

              let NV_CLIENT_ID         = MBA.RestViewCommon.fnCreateNameValueObject( PractitionerSpedSvcsMgmt_PARM_NAME_CLIENT_ID ,  VALUE_CLIENT_ID);
              let NV_PRAC_ID           = MBA.RestViewCommon.fnCreateNameValueObject( PractitionerSpedSvcsMgmt_PARM_NAME_PRAC_ID   ,  VALUE_PRAC_ID);

              $(_x23_restViewCtrl_MgmSvcResponsibilities).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
              $(_x23_restViewCtrl_MgmSvcResponsibilities).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC_ID);

              
              $(_x23_restViewCtrl_MgmSvcResponsibilities).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
              $(_x23_restViewCtrl_MgmSvcResponsibilities).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PRAC_ID);


              $(_x23_restViewCtrl_MgmSvcResponsibilities).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_CLIENT_ID);
              $(_x23_restViewCtrl_MgmSvcResponsibilities).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_PRAC_ID);
              

              $(_x23_restViewCtrl_MgmSvcResponsibilities)
                .MBA_RestView('requestViewFromServer', 1);
          }
          /*else {
            if ( !(VALUE_CLIENT_ID ))
              $.spedmonWebUI.dialogMessage(
               '',
               'Please make sure a client and practitioner are selected'
              );
            else
              $.spedmonWebUI.dialogMessage(
               '',
               'Please make sure a practitioner is selected'
              );
          }
          */
          
        }

 function initRestViewMgmSvcResponsibilities(
            opts_in, rstview_div_id, container_div_id,
            cliid_ctl_id, prac_ctl_id, practitionerSpedSvcsMgmt_parm_name_client_id, practitionerSpedSvcsMgmt_parm_name_prac_id
  ) {

   let opts = {};

   _x23_restViewCtrl_MgmSvcResponsibilities = rstview_div_id;
   _x23_restViewCtrl_Container              = container_div_id;


    _x23_cliid_ctl_id                       = cliid_ctl_id;
    _x23_prac_ctl_id                        = prac_ctl_id;


   PractitionerSpedSvcsMgmt_PARM_NAME_CLIENT_ID           =   practitionerSpedSvcsMgmt_parm_name_client_id;
   PractitionerSpedSvcsMgmt_PARM_NAME_PRAC_ID             =   practitionerSpedSvcsMgmt_parm_name_prac_id;
 

   opts.sessionTimeOutUrl = opts_in.sessionTimeOutUrl; // =MBA.Credential.generateSessionExpiredLink()
   opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
                                  
   opts.enableSortControls = true;
   opts.enableRowNumbers = true;
   opts.enableRowControls = true;
   opts.enableRowControlRecAddNew = true;

   opts.enableRowControlRecEdit = false;

   opts.enableRowControlRecDelete = true;

   opts.enableRowControlShowAdditionalInfo = false;
   opts.additionalInfoFieldDefinitions = [];

   opts.saveModeAddNew  = 'inline';
   opts.baseUrlAddNew   = opts_in.baseUrlAddNew; //= URL_REST_SAVE_INLINE();
   opts.baseUrlAddNewHasParameters = true;

   opts.saveModeDelete = 'inline';
   opts.baseUrlDelete  = opts_in.baseUrlDelete; //= URL_REST_DELETE_INLINE();
   opts.baseUrlDeleteHasParameters = true;

   opts.loadModeView = 'rest';
   opts.baseUrlView = opts_in.baseUrlView; //= URL_REST_VIEW();
   opts.baseUrlViewHasParameters = true;

   opts.enableReports = false;  // TODO

   opts.fieldDefinitions = [];

   opts.fieldDefinitions.push({
            name: 'id',
            isRecID: true,
            saveable: false,
            saveUsing: 'recid'
   });

     /*
  opts.fieldDefinitions.push({
              name: 'clientName'
            , label: 'client Name'
            , toolTip: 'client Name'
            , visible: true
            , sortable: false

            , saveable: false
            , isRecID: false
            , dataType: 'text'

            , showMore: false
   });

  opts.fieldDefinitions.push({
              name: 'pracName'
            , label: 'prac Name'
            , toolTip: 'prac Name'
            , visible: true
            , sortable: false

            , saveable: false
            , isRecID: false
            , dataType: 'text'

            , showMore: false
   });
   */

  /*
  opts.fieldDefinitions.push({
              name: 'disciplineGroupName'
            , label: 'Discipline Group Name'
            , toolTip: 'Discipline Group Name'
            , visible: true
            , sortable: false

            , saveable: false
            , isRecID: false
            , dataType: 'text'

            , showMore: false
   });
   */


   let codeNameOpts = {};
   codeNameOpts.baseUrl                    =   opts_in.codeNameOptsBaseUrl; //= URL_REST_SAVE_INLINE(); 
   codeNameOpts.loadMode                   =  'mbaviewsel';

   codeNameOpts.getInitialSelectedNameFrom = 'codeValueAndName';
   codeNameOpts.fnOnSelect = function (event, ui) {

     $(
       'input[title="code Value"]'
       ,
       $( '#' + event.target.id ).parent().parent().parent()
       ).val(
         ui.item.id
       );


     return true;

   }

   codeNameOpts.fnModifyRequestNvps     = function (nvpsIn) {return nvpsIn;};
   codeNameOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
   codeNameOpts.fnModifyRenderItem      = function ($ul, item, $li) { return $li; };
   codeNameOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};

   opts.fieldDefinitions.push({
              name: 'codeName'
            , label: 'CALPADS Codes I Support'
            , toolTip: 'The CALPADS service that I provide to students at the district'
            , visible: true
            , sortable: false

            , editable: true

            , saveable: false
            , isRecID: false
            
            , dataType       : 'autocomplete'
            , dataTypeOptions: codeNameOpts

            , showMore: false
            , styleAttrValueForCellValue: 'width:20em'
   });

   opts.fieldDefinitions.push({
              name: 'codeValue'
            , label: 'code Value'
            , toolTip: 'code Value'
            , visible: false
            , sortable: false

            , editable: true

            , saveable: true
            , isRecID: false
            , dataType: 'text'

            , saveUsing: 'codeValue'
            , showMore: false
   });


   $( cliid_ctl_id ).on('spedmoninputdata', _updateParamsRestViewMgmSvcResponsibilities_andReqFromServer );
   $( prac_ctl_id  ).on('spedmoninputdata', _updateParamsRestViewMgmSvcResponsibilities_andReqFromServer );

   $(_x23_restViewCtrl_MgmSvcResponsibilities).MBA_RestView(opts);

 }



 function  openDialgMgmSvcResponsibilities(opts_in)  {

     let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(80);
     let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(90);

     let diaOptsObj = {
           position: { my: 'center', at: 'center', of: window }
         , show: { effect: 'slide', direction: 'left' }
         , modal:true
         , closeOnEscape: true
         , width: (vw)
         , height: (vh)
         , close: function (event, ui) {
             $(_x23_restViewCtrl_Container).addClass('d-none');
             $(this).dialog('destroy');
         }
         , buttons: [{ text: "Close", click: function () { $(this).dialog("close"); } }]
     }

     $(_x23_restViewCtrl_Container).removeClass('d-none').dialog('destroy').dialog(diaOptsObj);
    
    _updateParamsRestViewMgmSvcResponsibilities_andReqFromServer();
    
    return true ;

 }

 return {
   initWoptsIn: initRestViewMgmSvcResponsibilities,
   openDialg: openDialgMgmSvcResponsibilities,
   updateRestView: _updateParamsRestViewMgmSvcResponsibilities_andReqFromServer
 };

})(jQuery);