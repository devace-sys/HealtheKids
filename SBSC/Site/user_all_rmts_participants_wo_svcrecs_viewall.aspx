<%@ Page Language="C#" CodeBehind="user_all_rmts_participants_wo_svcrecs_viewall.aspx.cs" Inherits="Spedmon.UserAllRmtsParticipantsWoSvcRecs" %>



         <div class="d-flex justify-content-end">

          <Spedmon:LinkInternal 
          ID        = "fingernavGotomanagerosters" 
          title     = "" 
          label     = ""
          faClass   = "fas fa-hand-point-left"               
          openNew   = "false"  
          subWindow = "false"
          runat     = "server" />

          <Spedmon:LinkInternal 
          ID        = "Gotomanagerosters" 
          title     = "Click here to manage all rosters" 
          label     = "Manage All RMTS Rosters"
          faClass   = ""               
          openNew   = "false"  
          subWindow = "false"
          runat     = "server" />

         </div> <!-- col -->

<div id="dataManagementRows" class="container-fluid">  

    <div class="row">

        <div class="col-6 text-left">

            <%//-----------------------------------------------------------------------------%>
            <%// Select Client %>
            <%// (Practi-Cal staff only) %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryRowSelectClient
                ID                   = "selectClient" 
                entityControlID      = "clientid"                
                rowLabel             = "Client"
                dataEntryRowRenderAs = "FIELD"
                onSpedmonInputData   = "updateAdditionalViewParameterValuesAndRequestViewFromServer()"
                runat                = "server">
            </Spedmon:DataEntryRowSelectClient>

        </div>

        <div class="col-6 text-right">

          <Spedmon:RadioBox ID="deferralstatus" name="deferralstatus" title="deferralstatus" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />
        </div>

     </div>

    <%-----------------------------%>
    <%--       Rest view         --%>
    <%-----------------------------%>
    <div id="restViewRow" class="row mt-3">
        <div class="col-12">
            <div id="restView">
            </div>
        </div>
    </div>

</div>


<div class="d-none">
  <!--  -->
  <div id="diaAddException" title="Defer These">
    <div class="alert alert-warning text-center">Deferrals should only be recorded if necessary.</div>
    <table class="table table-sm">
    <tbody id="exceptionaddreasonsummary">
    </tbody>
    </table>
    <Spedmon:DataEntryBoxSelect id="deferralreason"          name="deferralreason"      label="Reason"  required="true" runat="server" />
    <Spedmon:DataEntryBoxTextArea ID="deferralreasonnotes"   name="deferralreasonnotes" label="Notes" size="20" runat="server"/>
  </div>

</div>


<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">
    /************************************************************************************************************************* */
    let $dataManagementRows = null;
    let $restViewCtrl = null;

    var VALUE_FILTER_DEFERRED;

    const PARM_NAME_CLIENT_ID   = '<%=Constants.PARM_CLIENT_ID%>';


    var  $diaAddException = $('#diaAddException');

    function resetAddExceptionDialog () {
      $('#deferralreasonnotes').val('');
      //$($diaAddException).hide();
      $($diaAddException).parent().remove();
    }

    function openAddExceptionDialog (uiActionObj) {
    //function openAddExceptionDialog ( uiObject, flagval ) {

        //initDiaAddExceptionPromisedService();

        

        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(80);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(80);

        let diaOpts = {
            position: { my: 'center', at: 'center', of: window }
            , show:{ effect: 'slide', direction: 'left' }
            , modal: true
            , closeOnEscape: false
            , width: (vw)
            , height: (vh)
            , close: function (event, ui) {
                //initDiaAddExceptionPromisedService();
                resetAddExceptionDialog();
            }
            , buttons: [
                { text: "Cancel", click: function () { resetAddExceptionDialog(); } }
                , {
                    text: "Proceed", click: function () {
                        //saveAddExceptionPromisedService(uiActionObj);
                        flagAsmxAsDeferred( uiActionObj, 1 );
                        resetAddExceptionDialog();
                    }
                }
            ]
        };

        $($diaAddException).show();
        $($diaAddException).dialog(diaOpts);

    }


    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();

        VALUE_FILTER_DEFERRED = $('#deferralstatus' ).val();

        if (!( VALUE_CLIENT_ID ))  return;

        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);


        /* Note: Don't use a loop here, keep it unrolled for performance reasons */
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);

        let NV_DEFERRED = MBA.RestViewCommon.fnCreateNameValueObject('deferralstatus', VALUE_FILTER_DEFERRED );
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DEFERRED );
  
		if ( VALUE_FILTER_DEFERRED == "1" ) {

		    $($restViewCtrl).MBA_RestView('showColumn', 'deferralDateStrYMD');
		    $($restViewCtrl).MBA_RestView('showColumn', 'deferredByStr');
		    $($restViewCtrl).MBA_RestView('showColumn', 'deferralReason');
		    $($restViewCtrl).MBA_RestView('showColumn', 'deferralReasonNotes');

		    //$($restViewCtrlRmtsMoments).MBA_RestView('hideColumn', 'lastModifiedByStr');

            //$('button[data-mba-rest-view-ctrl-def-name="flagDefer"]').hide();
            //$('button[data-mba-rest-view-ctrl-def-name="flagUndefer"]').show();

		}
		else {

		    $($restViewCtrl).MBA_RestView('hideColumn', 'deferralDateStrYMD');

		    $($restViewCtrl).MBA_RestView('hideColumn', 'deferredByStr');

		    $($restViewCtrl).MBA_RestView('hideColumn', 'deferralReason');
		    $($restViewCtrl).MBA_RestView('hideColumn', 'deferralReasonNotes');

		    //$($restViewCtrlRmtsMoments).MBA_RestView('showColumn', 'lastModifiedByStr');

            //$('button[data-mba-rest-view-ctrl-def-name="flagUndefer"]').hide();
            //$('button[data-mba-rest-view-ctrl-def-name="flagDefer"]').show();

		}

        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);
    };

    //
    var flagAsmxAsDeferred = function( uiObject, flagval ) {
 
        //debugger;

        var rowvals  =  uiObject.whatFieldNameValues ;
        var  reqURL  =  '<%=Spedmon.RmtsParticipantsWoSvcRecs.URL_FLAG_DEFERRAL_REASON_BASE() %>';

        var reqDataObj = {

              recid         : uiObject.recordID
          
             , deferralreason        : $('#deferralreason').val()
             , deferralreasonnotes   : $('#deferralreasonnotes').val()

             , clientid        : rowvals.clientID 

             , isdeferred      : flagval

        } ;
        
        let reqDataJSON = JSON.stringify(reqDataObj);

 
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqDataJSON, null)
            .then(responseData => {
                
                $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');
                
                return;
            })
            .catch(responseData => {
                $($restViewCtrl).MBA_RestView('hideOverlayMessage');

                var problem_txt = "problem!";
 
                // debugger;
 
                try {
                  problem_txt = responseData.message ;
                } catch(e) {}
 
                $.spedmonWebUI.dialogMessage('Action required', problem_txt );      
              
                return;
            });                                 
        // }; /* _fnacceptRowRowsProceed*/
 
 
    } ;

    /*
    function promptEditDeferralReason( uiObject ) {
        $.spedmonWebUI.dialogConfirmReason(

          'Defer This Required Moment ?',
           'Are you sure you want to defer documentation requirements for this moment?',

           function(){
             flagAsmxAsDeferred( uiObject, 1 ) ;
           },
           function(){});
     }
    */

    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = false;
        opts.enableRowControlRecDelete = false;

        opts.saveModeAddNew = 'inline';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.RmtsParticipantsWoSvcRecs.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        // opts.defaultPageRowOrder = '<%=Spedmon.RmtsParticipant.DEFAULT_PAGING_ORDER%>';

        opts.enableReports = true;
        opts.enableReportHtml = false;
        opts.enableReportXls = true;
        opts.enableReportPdf = false;

        opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport = '<%=Spedmon.RmtsParticipantsWoSvcRecs.URL_ASHX_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '1';

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'rp_id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
            name: 'pracNameLink'
            , label: 'Practitioner Name'
            , toolTip: "Nav to this practitioner's RMTS moments this quarter"
            , visible: true
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'pracNameLink'
        });


        opts.fieldDefinitions.push({
            name: 'pracEmailLink'
            , label: 'Email'
            , toolTip: 'Nav to practitioner edit'
            , visible: true
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'pracEmailLink'
        });

        opts.fieldDefinitions.push({
            name: 'pracTitle'
            , label: 'Title' 
            , toolTip: 'Practitioner Title'
            , visible: true
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'pracTitle'
        });

        opts.fieldDefinitions.push({
            name: 'deferralDateStrYMD'
            , label: 'Deferred On'
            , toolTip: 'Deferred On'
            , visible: true

            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'deferralDate'
            , saveUsing: 'deferraldate'
        });

        opts.fieldDefinitions.push({
            name: 'deferredByStr'
            , label: 'Deferred By'
            , toolTip: 'Deferred By'

            , visible: true

            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'deferredByStr'
            , saveUsing: 'deferredByStr'
        });


        opts.fieldDefinitions.push({
	          name: 'deferralReason'
	        , label: 'Deferral Reason'
	        , toolTip: 'Deferral Reason'
	        , visible: true
	        , editable: true
	        , saveable: true
	        , sortable: true
	     , isRecID: false
	        , dataType: 'textarea'
	        , sortUsing: 'deferralReason'
	        , saveUsing: 'deferralreason'
	        , styleAttrValueForCellValue: 'height:3.6em;'
	        , showMore: true
        });

        opts.fieldDefinitions.push({
	          name: 'deferralReasonNotes'
	        , label: 'Deferral Reason'
	        , toolTip: 'Deferral Reason'
	        , visible: true
	        , editable: true
	        , saveable: true
	        , sortable: true
	     , isRecID: false
	        , dataType: 'textarea'
	        , sortUsing: 'deferralReason'
	        , saveUsing: 'deferralreason'
	        , styleAttrValueForCellValue: 'height:3.6em;'
	        , showMore: true
        });

        opts.fieldDefinitions.push({
            name: 'reportingGroup'
            , label: 'Reporting Group'
            , toolTip: 'Reporting Group' 
            , visible: true
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'reportingGroup'
        });

        opts.fieldDefinitions.push({
            name: 'FY'
            , label: 'Fiscal Year'
            , toolTip: 'FY'
            , visible: true
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'FY_ID'
        }); 

        opts.fieldDefinitions.push({
            name: 'FY_ID'
            , label: 'FY_ID'
            , toolTip: 'FY_ID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: ''
        }); 

        opts.fieldDefinitions.push({
            name: 'FY_DEFINITION'
            , label: 'FY_DEFINITION'
            , toolTip: 'Nav to roster'   ///
            , visible: false
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'FY_DEFINITION'
        });

        opts.fieldDefinitions.push({
            name: 'pracID',
            label: 'pracID',
            toolTip: 'pracID',
            visible: false,
            sortable: true,
            saveable: false,
            editable: false,
            isRecID: false,
            dataType: 'text',
            sortUsing: 'pracID',
            saveUsing: '',
            showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'FYQ_ID',
            label: 'FYQ_ID',
            toolTip: 'FYQ_ID',
            visible: false,
            sortable: true,
            saveable: false,
            editable: false,
            isRecID: false,
            dataType: 'text',
            sortUsing: 'FYQ_ID',
            saveUsing: '',
            showMore: false
        });
 

        opts.fieldDefinitions.push({
            name: 'QtrNum'
            , label: 'QtrNum'
            , toolTip: 'QtrNum'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'QtrNum'
        }); 
 
        opts.fieldDefinitions.push({
            name: 'clientID'
            , label: 'clientID'
            , toolTip: 'clientID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'clientID'
        }); 

        opts.fieldDefinitions.push({
            name: 'numSvcsLt3'
            , label: '# of Svcs'
            , toolTip: 'Number of Services (less than 3)'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'numSvcsLt3'
        }); 
 
        opts.fieldDefinitions.push({
            name: 'QTR'
            , label: 'QTR'
            , toolTip: 'QTR'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'QTR'
        }); 
 
      opts.fieldDefinitions.push({
            name: 'rosterID'
            , label: 'Roster ID'
            , toolTip: 'Roster ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'rosterid'
            , sortUsing: 'rosterID'
        });

        opts.fieldDefinitions.push({
            name: 'submitClaimsStr'
            , label: 'Submit Claims'
            , toolTip: 'Submit Claims'
            , visible: true
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'submitClaimsStr'
        });

                                     
        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

       opts.additionalControlDefinitionsForBodyRows.set('flagDefer', {
            defType: 'userprovided',
            name: 'flagDefer',
            toolTip: 'mark as deferred',
            cssClass: 'fa fa-thumbs-down',

            //handlerFn: promptEditDeferralReason,
            handlerFn: openAddExceptionDialog, 

            initiallyHidden: false

        });

        opts.additionalControlDefinitionsForBodyRows.set('flagUndefer', {
            defType: 'userprovided',
            name: 'flagUndefer',
            toolTip: 'unmark as deferred',
            cssClass: 'fa fa-thumbs-up',
            handlerFn: function(uiObject){
                         flagAsmxAsDeferred( uiObject, 0 ) ;
                       },
            initiallyHidden: false
        });

        /*
        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
          rowData.QTR = '<a href="' +
          '" class="QtrNumAtag">' +  rowData.QTR_DEFINITION +
          '</a>';

        }
        */

        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
          if (! (rowData)) return $newRow;
          //debugger;

          rowData.FY = '<a href="' +
            '<%= MBA.HttpApplication.createLink("user_all_rmts_participation_roster_manage.aspx", true) %>' +
            '&clientid=' + rowData.clientID +
            '&fiscalyearid=' + rowData.FY_ID +
            '&quarternumber=1' +
            '" class="QtrNumAtag">' +  rowData.FY_DEFINITION +
            '</a>';

          rowData.pracNameLink = '<a href="' +
            '<%= Spedmon.RmtsMoments.URL_MANAGE_BASE() %>' +
            '&clientid=' + rowData.clientID +
            '&quarterid=' + rowData.q1_quarterID +
            '&pracid=' + rowData.pracID +
            '&showNavBackToAllWO=1' +
            '" class="pracNameAtag">' +  rowData.pracName +
            '</a>';

          rowData.pracEmailLink = '<a href="' +
            '<%= Spedmon.Practitioners.URL_MANAGE_BASE() %>' +
            '&clientid=' + rowData.clientID +
            '&pracid=' + rowData.pracID +
            '" class="emailAtag">' +  rowData.pracEmail +
            '</a>';
 

            /******************************************************************************************************************************/
            // set up messaging
            /******************************************************************************************************************************/
            var $msgIcon = $('<i style="font-size: 1.2em;" class="fas fa-comment fa-mba-messages-widget-class ml-2" title="send messages"></i>');


            //debugger; 
            var messagesWidget_opts = {

                'clientID': '<%=rd.wu.usr.clientID%>',
                'sendMessageAjaxURL':  '<%=MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_SAVE, true)%>' 

		     ,  'deleteMessageAjaxURL': ''

             , 'recipientSrcURL': '<%=MBA.HttpApplication.createLink(MBA.UserMessages.URL_ASMX_VIEW_SEL_CONTACTS, true)%>'

             ,  recipientIDs   :  '' + rowData.pracUid  //string
             ,  recipientNames:   rowData.pracName


                 <%
                 // todo: not sure why I didn't pre-fill the prac userID and name for this
                 %>

                ,
                'replyModeOn': false,
                'allowDelete': false,
                'viewModeSubject': 'Please log in to your SpEdCare account and provide documentation for - ' + rowData.QTR_DEFINITION

                ,
                
                'isSendOnly': true,
                'senderUserID': '',
                'senderName': '',
                'messageID': ''
            };



            $('td.mba-rest-view-row-controls', $newRow).append($msgIcon); 
            $msgIcon.messagesWidget(messagesWidget_opts);

            $msgIcon.click(function () {
                $(this).css('color', '#c7c703');
            });

       if ( VALUE_FILTER_DEFERRED == "1" ) {



            $('button[data-mba-rest-view-ctrl-def-name="flagDefer"]', $newRow).hide();
            $('button[data-mba-rest-view-ctrl-def-name="flagUndefer"]', $newRow).show();

		}
		else {


            // debugger ; 
            $('button[data-mba-rest-view-ctrl-def-name="flagUndefer"]', $newRow).hide();
            $('button[data-mba-rest-view-ctrl-def-name="flagDefer"]', $newRow).show();

		}


          return $newRow;

        }

        //opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            //if (!rowData) return $newRow;

            //debugger;



            //return $newRow;
        //};
     
        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    
    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restView');
        initView(); 


        $('#deferralstatus').val('<%= deferredValIn %>');

        <% // TODO!!
           // I can't help but feel this syntax is non-standard.  Need to find a relevant code snippet from
           // somewhere, or else bug Andy
        %>
        $('.ui-spedmon-box-radio-box-container input').change( updateAdditionalViewParameterValuesAndRequestViewFromServer );

        updateAdditionalViewParameterValuesAndRequestViewFromServer();


    });
</script>
