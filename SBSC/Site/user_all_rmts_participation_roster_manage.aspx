<%@ Page Language="C#" CodeBehind="user_all_rmts_participation_roster_manage.aspx.cs" Inherits="Spedmon.UserAllRmtsParticipationManage" %>


         <div class="d-flex justify-content-end px-4">

          <Spedmon:LinkInternal 
          ID        = "gotoViewWoSvcrecs" 
          title     = "Click here view all participants without service records" 
          label     = "Participants W/O Service Records - View All"
          faClass   = "fas fa-hand-point-right"
          openNew   = "false"
          subWindow = "false"
          runat     = "server" />

         </div> <!-- col -->




<div id="dataManagementRows" class="container-fluid">  
    

    <div class="row">
        <div class="col-12">

            <%//-----------------------------------------------------------------------------%>
            <%// Select Client %>
            <%// (Practi-Cal staff only) %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryRowSelectClient
                ID                   = "selectClient" 
                entityControlID      = "clientid"                
                rowLabel             = "Client"
                dataEntryRowRenderAs = "FIELD"
                onSpedmonInputData   = "onClientSelect();"
                runat                = "server">
            </Spedmon:DataEntryRowSelectClient>

            <%//-----------------------------------------------------------------------------%>
            <%// Select Year %>
            <%//-----------------------------------------------------------------------------%>
            <Spedmon:DataEntryRowSelectFiscalYear
                ID                   = "selectFiscalYear" 
                entityControlID      = "fiscalyearid"                
                rowLabel             = "Fiscal Year"
                dataEntryRowRenderAs = "FIELD"
                runat                = "server">
            </Spedmon:DataEntryRowSelectFiscalYear>
   
            <%-----------------------------  
            <Spedmon:DataEntryRowStaticSelectFourQuarters
                ID                   = "selectFiscalQuarter_2" 
                runat                = "server">

            </Spedmon:DataEntryRowStaticSelectFourQuarters>
             -----------------------------%>


                <%-----------------------------%>
                <%--       TODO:             --%>
                <%--   ... does not have public property named entityControlID  --%>
                <%--   ... does not have public property named rowLabel  --%>
                <%-----------------------------%>
            
	 
        </div>        
    </div>

    <div class="row">

      <div class="col-4">
        <Spedmon:RadioBox
           ID="fiscalquarterselection"
           name="fiscalquarterselection"
           title="Quarter"
           renderLabel="true"
           additionalCssClassNameForContainer="modern2021"
           runat="server" />
      </div> <!-- col -->

    </div> 

    <div class="row" >
      <div id="fyQuarterDateRangeDisplay" class="pl-3 text-left"></div>
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

    <%-----------------------------%>
    <%--    Unprocessed Pracs    --%>
    <%-----------------------------%>
    <div class="row mt-3">
        <div class="col-12"> 
            Unprocessed Practitioners (LAST, FIRST): <span id="unprocessedPracs" class="font-weight-bold"></span>
        </div>
    </div>
    <%-----------------------------%>
    <%--       Audit history     --%>
    <%-----------------------------%>
    <div class="row mt-3">
        <div id="rmtsRosterHist" class="col-12">            
        </div>
    </div>
</div>

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">
    /************************************************************************************************************************* */
    let $dataManagementRows = null;
    let $restViewCtrl = null;

    const $HIST_TBL          = $('#rmtsRosterHist');
    const $UNPROCESSED_PRACS = $('#unprocessedPracs');

    const PARM_NAME_CLIENT_ID   = '<%=Constants.PARM_CLIENT_ID%>';
    const CONST_ATTR_CLIENT_ID  = 'clientID';

    //
    const PARM_NAME_QTR_ID      = 'fyquarterid';
    const CONST_ATTR_QTR_ID     = 'fyQuarterID';

    const PARM_NAME_ROSTER_ID   = 'rosterid';
    const PARM_NAME_RECORD_ID   = 'recordid'; // needed for excel report
    const CONST_ATTR_ROSTER_ID  = 'rosterID';
    const CONST_ATTR_START_DATE = 'startDateStrYMD';
    const CONST_ATTR_END_DATE   = 'endDateStrYMD';
    let GLOBAL_ROSTER_START_DATE;
    let GLOBAL_ROSTER_END_DATE;
    const GLOBAL_ROSTER_DATA = {

        //'fyID':   0,
        'fqID':   <%= quarterID %> ,
        //'qtrNum': 0,

        'id': 0,
        'startDateStr': null,
        'endDateStr': null,
        'startDateStrYMD': null,
        'endDateStrYMD': null,

        // this is the ajax callback for the asmx call inside of setQtrStartAndEnd() ;
        // not called anywhere else
        'setStartAndEndDates': function (qtrStartStr, qtrEndStr, qtrStartStrYMD, qtrEndStrYMD) {
            this.startDateStrYMD = qtrStartStrYMD;
            this.endDateStrYMD   = qtrEndStrYMD;
            this.startDateStr    = qtrStartStr;
            this.endDateStr      = qtrEndStr;

            // change display on the page
            $('#fyQuarterDateRangeDisplay').text(this.startDateStr + ' - ' + this.endDateStr);
               
        },
        'clear': function () {
            this.id   = 0;
            this.fqID = 0;
            this.startDateStr = this.endDateStr = this.startDateStrYMD = this.endDateStrYMD = null;
        },

        //  ...
        'setRosterHistory': function () {

            let histReqUrl = '<%=Spedmon.RmtsParticipationRosters.URL_VIEW_HTML_HIST_TBL_BASE()%>';
            let histReqData = JSON.stringify(
                {
                      '<%=Spedmon.Constants.PARM_CLIENT_ID%>': $('#' + '<%=Spedmon.Constants.PARM_CLIENT_ID%>').val()
                    , '<%=Spedmon.Constants.PARM_ROSTER_ID%>': this.id
                });

            // fnAjaxCallAsmxWebMethod()

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(histReqUrl, histReqData, null)
                .then(responseData => {
                    $HIST_TBL.html('').html('<div class="ui-spedmon-data-entry-audit-content-container">' + responseData.rawData.htmlText + '</div>');
                    $.fn.setupDataEntryRowSaveEditAuditTable();

                    
                })
                .catch(responseData => {});
        },
        
        // ...
        'setQtrStartAndEnd': function () {
            let reqUrl = '<%=Spedmon.RmtsParticipationRosters.URL_LOAD_BASE()%>';
            let reqData = JSON.stringify(
                {
                    '<%=Spedmon.Constants.PARM_CLIENT_ID%>': $('#' + '<%=Spedmon.Constants.PARM_CLIENT_ID%>').val()
                    , '<%=Spedmon.Constants.PARM_REC_ID%>': this.id
                });

            // fnAjaxCallAsmxWebMethod()

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                .then(responseData => {
                    this.setStartAndEndDates(responseData.rawData.roster.quarterStartDateStr, responseData.rawData.roster.quarterEndDateStr,
                        responseData.rawData.roster.quarterStartDateStrYMD, responseData.rawData.roster.quarterEndDateStrYMD);
                })
                //.catch(responseData => {

                    // clearQtrAndRosterSelection();

                //});

        },

        // is the asmx callback for findRosterForQuarter(); not used anyplace else
        'setRosterIDAndQuarterID': function (val1, val2) {

            /*
            if (!val1) return;
            if (!val2) return;
            */

            this.id   = val1;
            this.fqID = val2;

            if ($('#' + PARM_NAME_CLIENT_ID).val())  {

              if ( this.id )
                updateAdditionalViewParameterValuesAndRequestViewFromServer(null);

            }

            // set quarter start and end date
            this.setQtrStartAndEnd();

            // set history table
            this.setRosterHistory();

        }
    }

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_ROSTER_ID = GLOBAL_ROSTER_DATA.id;



        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_ROSTER_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ROSTER_ID, VALUE_ROSTER_ID);
        let NV_RECORD_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_RECORD_ID, VALUE_ROSTER_ID); // needed for excel report

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ROSTER_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_RECORD_ID);



        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForEditSet', NV_CLIENT_ID);

        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);
    };

    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = true;
        opts.enableRowControlRecEdit = true;
        opts.enableRowControlRecDelete = false;

        opts.saveModeAddNew = 'inline';
        opts.baseUrlAddNew = '<%=Spedmon.RmtsParticipants.URL_SAVE_BASE()%>';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inline';
        opts.baseUrlEdit = '<%=Spedmon.RmtsParticipants.URL_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters = true;

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.RmtsParticipants.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.RmtsParticipant.DEFAULT_PAGING_ORDER%>';

        opts.enableReports = true;
        opts.enableReportHtml = false;
        opts.enableReportXls = true;
        opts.enableReportPdf = false;

        opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport = '<%=Spedmon.RmtsParticipationRosters.URL_ASHX_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '1';

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
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
            , dataType: 'hidden'
            , saveUsing: 'rosterid'
            , sortUsing: 'rosterID'
        });

        // don't know if this still needs to be here
        opts.fieldDefinitions.push({
            name: 'fyQuarterID'
            , label: 'Quarter ID'
            , toolTip: 'Quarter ID'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'fyquarterid'
            , sortUsing: 'fyQuarterID'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Practitioner Name                                                           %>
        <%//-----------------------------------------------------------------------------%>

        <%/* Setup autocomplete - Basics */%>

        let pracIdOpts = {};
        pracIdOpts.baseUrl                    = '<%=Spedmon.Practitioners.URL_VIEW_SEL2_BASE()%>';
        pracIdOpts.loadMode                   = 'mbaviewsel';
        pracIdOpts.getInitialSelectedNameFrom = 'pracName';

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        pracIdOpts.fnOnSelect = function (event, ui) { };

        <%/* Setup autocomplete - Customization Hooks  */%>

        pracIdOpts.fnModifyRequestNvps     = function (nvpsIn) {return nvpsIn;};
        pracIdOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
        pracIdOpts.fnModifyRenderItem = function ($ul, item, $li) {            
            var ctxt1 = $('<br><sup>' + item.recData2 + '</sup>');
            $($li).children('a').append(ctxt1);
            return $li;            
        };
        pracIdOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'pracID'
            , label: 'Practitioner Name'
            , toolTip: 'Practitioner Name'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , saveUsing: 'pracid'
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: pracIdOpts
            , sortUsing: 'pracName'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'pracTitle'
            , label: 'Job Title / Practitioner type'
            , toolTip: 'Job Title / Practitioner type'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'pracTitle'
            , sortUsing: 'pracTitle'
        });        
                                                  
        opts.fieldDefinitions.push({
            name: 'startDateStrYMD'
            , label: 'Start Date'
            , toolTip: 'Start Date'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'startdate'
            , sortUsing: 'startDateStrYMD'
        });

        let startChangeReasonsFieldOptions = {};
        startChangeReasonsFieldOptions.selections = <%=startDateChangeReasonsNvpString%>;

        opts.fieldDefinitions.push({
            name: 'reasonForStartDateChangeCode'
            , label: 'Reason For<br/>Start Date<br/>Change'
            , toolTip: 'Reason the start date was changed'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: startChangeReasonsFieldOptions
            , sortUsing: ''
            , saveUsing: 'reasonforstartdatechangecode'
            , showMore: false
        });
                    
        opts.fieldDefinitions.push({
            name: 'endDateStrYMD'
            , label: 'End Date'
            , toolTip: 'End Date'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'enddate'
            , sortUsing: 'endDateStrYMD'
        });

        let endChangeReasonsFieldOptions = {};
        endChangeReasonsFieldOptions.selections = <%=endDateChangeReasonsNvpString%>;

        opts.fieldDefinitions.push({
            name: 'reasonForEndDateChangeCode'
            , label: 'Reason For<br/>End Date<br/> Change'
            , toolTip: 'Reason the end date was changed'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: endChangeReasonsFieldOptions
            , sortUsing: ''
            , saveUsing: 'reasonforenddatechangecode'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Employee Status %>
        <%//-----------------------------------------------------------------------------%>

        let employeeStatusFieldOptions = {};

        employeeStatusFieldOptions.selections = [
              { name: 'Employee'  , value: '10' }
            , { name: 'Contractor', value: '20' }];

        opts.fieldDefinitions.push({
            name: 'employeeRelationshipID'
            , label: 'Employee Status'
            , toolTip: 'Employee Status'
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: employeeStatusFieldOptions
            , sortUsing: 'employeeRelationshipID'
            , saveUsing: 'employeerelationshipid'
            , showMore: false
            , handlerFn: function (uiActionObj) {
                return uiActionObj;
            }
        });
        
        opts.fieldDefinitions.push({
            name: 'hasServiceRecords'
            , label: 'Has Service<br/>Records'
            , toolTip: 'Practitioner has service records in SpEdCare'
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'checkbox'
            , sortUsing: ''
            , saveUsing: 'hasservicerecords'
            , showMore: false            
        });
   
<%--        <%if (uInfo.pcalStaff) { %>
            opts.fieldDefinitions.push({
                name: 'hasReimbursement'
                , label: 'Has Reimbursement'
                , toolTip: 'Practitioner has Reimbursements for this quarter'
                , visible: true
                , sortable: false
                , editable: true
                , saveable: true
                , isRecID: false
                , dataType: 'checkbox'
                , sortUsing: ''
                , saveUsing: 'hasreimbursement'
                , showMore: false            
            });
        <%} else { %>  --%>    
            opts.fieldDefinitions.push({
                name: 'hasReimbursement'
                , label: 'Has Reimbursement'
                , toolTip: 'Practitioner has Reimbursements for this quarter'
                , visible: false
                , sortable: false
                , editable: true
                , saveable: true
                , isRecID: false
                , dataType: 'checkbox'
                , sortUsing: ''
                , saveUsing: 'hasreimbursement'
                , showMore: false            
            });
<%--        <% } %>--%>

        <%//-----------------------------------------------------------------------------%>
        <%// Parameters for our prac dropdowns (hidden) %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'clientID'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'clientid'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'patid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'patid'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'dos'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'dos'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'groupserviceclassnameid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'groupserviceclassnameid'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'pracdatasource'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'pracdatasource'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'active'
            , isActiveFlag: true
            , saveable: false
            , saveUsing: 'active'
        });

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.additionalControlDefinitionsForBodyRows.set('participationStatusMsg', {
            defType: 'userprovided'
            , name: 'participationStatusMsg'
            , toolTip: ''
            , cssClass: 'mba-rest-view fas fa-exclamation-circle'
            , handlerFn: function (uiActionObj) {
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            if (!rowData) return $newRow;

            // set status and remove participation status as needed
            let ctrlPartsStatusMsg = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="participationStatusMsg"]');
            let partsStatusMsgContent = 
                  ((rowData.needsReasonForStartDateChange) ? 'Please enter reason for start date change<br/>': '')
                + ((rowData.needsReasonForEndDateChange)   ? 'Please enter reason for end date change<br/>'  : '');

            $(ctrlPartsStatusMsg).tipso({
                speed: 400
                , background: '#ffd60d'
                , titleBackground: '#333333'
                , color: 'black'
                , titleColor: '#ffffff'
                , titleContent: ''
                , showArrow: true
                , position: 'bottom'
                , width: $(window).width() / 2
                , maxWidth: ''
                , delay: 200
                , hideDelay: 0
                , animationIn: ''
                , animationOut: ''
                , offsetX: 0
                , offsetY: 0
                , tooltipHover: true
                , content: partsStatusMsgContent
                , ajaxContentUrl: null
                , contentElementId: null
                , useTitle: false
                , templateEngineFunc: null
                , onBeforeShow: null
                , onShow: null
                , onHide: null
            });

            $(ctrlPartsStatusMsg).on('click', function () { $.spedmonWebUI.dialogMessage('Message', partsStatusMsgContent, null, $(window).width() / 1.5, $(window).height() / 1.5, null, null, null);; });

            if (!rowData.needsReasonForStartDateChange && !rowData.needsReasonForEndDateChange) { $(ctrlPartsStatusMsg).remove(); }

            return $newRow
        }

        opts.fnCreateNewCellAfter = function ($newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
            if ((subsection === 102) && (rowtype === 2)) {
                if (fieldDefinition.name === CONST_ATTR_CLIENT_ID) {
                    var clientIDVal = $('#' + PARM_NAME_CLIENT_ID).val();
                    $($newCellValue).val(clientIDVal);
                }
                if (fieldDefinition.name === CONST_ATTR_QTR_ID) {

                    //
                    var qtrIDVal = GLOBAL_ROSTER_DATA.fqID ;
                    $($newCellValue).val(qtrIDVal);
                }
                if (fieldDefinition.name === CONST_ATTR_ROSTER_ID) {
                    $($newCellValue).val(GLOBAL_ROSTER_DATA.id);
                }
                if (fieldDefinition.name === CONST_ATTR_START_DATE) {
                    $($newCellValue).val(GLOBAL_ROSTER_DATA.startDateStrYMD);
                }
                if (fieldDefinition.name === CONST_ATTR_END_DATE) {
                    $($newCellValue).val(GLOBAL_ROSTER_DATA.endDateStrYMD);
                }
            }
            return $newCell;
        };

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    function clearQtrAndRosterSelection() {
        GLOBAL_ROSTER_DATA.clear()

        updateAdditionalViewParameterValuesAndRequestViewFromServer(null);
    }

    function launchRosterTSPFileUploadScreenAndClearRestView() {
      $.when(launchRosterTSPFileUploadScreen())
          .then(function () {
              clearQtrAndRosterSelection();                           
          });
    }
      
    function findQtrIdThenLaunchRosterTSPFileUploadScreenAndClearRestView() {

        //console.log( 'findQtrIdThenLaunchRosterTSPFileUploadScreenAndClearRestView' );

        var fyID       = $('#fiscalyearid').val() ;
        var quarterNum = $('#fiscalquarterselection_radiobox_cont :checked').val();

        let reqUrl = '<%=Spedmon.RmtsParticipationRosters.URL_GET_QUARTER_ID_BASE() %>';
        let reqData = JSON.stringify(
            {
                  'fyearID'                     : fyID //quarterID
                , 'quarterNumber'               : quarterNum
            });

        // fnAjaxCallAsmxWebMethod()

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                if (responseData.message == "Success") {

                    //debugger;
                    GLOBAL_ROSTER_DATA.setRosterIDAndQuarterID(
                        0 , // GLOBAL_ROSTER_DATA.id , 
                        responseData.rawData.value
                    );

                    //debugger;

                    launchRosterTSPFileUploadScreenAndClearRestView();

                } else {
                    $.spedmonWebUI.dialogMessage(
                      'Problem',
                      (  responseData.message ? responseData.message :
                        'Problem loading this data.  Try again, or reload the page.'
                      )
                    );
                }
            })

            .catch(responseData => {

                //debugger;
                
                clearQtrAndRosterSelection();

                $.spedmonWebUI.dialogMessage(
                      'Problem',
                      (  responseData.message ? responseData.message :
                        'Problem loading this data.  Try again, or reload the page.'
                      )
                );


           });

    }
    //function createRosterIfNotExistsForQuarter(quarterID) {
    function findRosterForQuarter() {

        //alert('hi');

        var fyID       = $('#fiscalyearid').val() ;
        var quarterNum = $('#fiscalquarterselection_radiobox_cont :checked').val();

        if ( ! fyID ) return ;
        if ( ! quarterNum ) return ;

        GLOBAL_ROSTER_DATA.setRosterIDAndQuarterID(  0, 0  );
 
        let reqUrl = '<%=Spedmon.RmtsParticipationRosters.URL_LOAD_BY_QUARTER_BASE()%>';
        let reqData = JSON.stringify(
            {
                  '<%=Spedmon.Constants.PARM_CLIENT_ID%>': $('#' + '<%=Spedmon.Constants.PARM_CLIENT_ID%>').val()
                , '<%=Spedmon.Constants.PARM_ACTIVE%>'   : 1
                , '<%=Spedmon.Constants.PARM_REC_ID%>'   : fyID //quarterID
                , 'quarternum'                           : quarterNum
            });

        // fnAjaxCallAsmxWebMethod()

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                if (responseData.rawData.hasRecord) {

                    //debugger;
                    GLOBAL_ROSTER_DATA.setRosterIDAndQuarterID(
                        responseData.rawData.roster.id
                      , responseData.rawData.roster.quarterID
                    );

                } else {
                    findQtrIdThenLaunchRosterTSPFileUploadScreenAndClearRestView(); 
                    //launchRosterTSPFileUploadScreenAndClearRestView();
                }
            })
            .catch(responseData => {

                //debugger;
                
                clearQtrAndRosterSelection();


                /*
                if ( GLOBAL_ROSTER_DATA.id != 0 )
                  $.spedmonWebUI.dialogMessage(
                      'Problem',
                      (  responseData.message ? responseData.message :
                        'Problem loading this data.  Try again, or reload the page.'
                      )
                    );   */

                 //else 
                    findQtrIdThenLaunchRosterTSPFileUploadScreenAndClearRestView(); 
                    //launchRosterTSPFileUploadScreenAndClearRestView();
           });                
    }

    function onClientSelect() {
        clearQtrAndRosterSelection();
    }
    
    function populateListOfPracsNotProcessed() {
        let clientID = $('#' + '<%=Spedmon.Constants.PARM_CLIENT_ID%>').val();

        if (!clientID) {
            return;
        }

        let reqUrl = '<%=Spedmon.StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.URL_VIEW_ALL_BASE()%>';
        let reqData = JSON.stringify(
            {
                  '<%=Spedmon.Constants.PARM_CLIENT_ID%>'     : clientID

                  //
                , '<%=Spedmon.Constants.PARM_FY_QUARTER_ID%>' : GLOBAL_ROSTER_DATA.fqID

                , 'rmtsdataimportid'                          : null
            });

        // fnAjaxCallAsmxWebMethod()

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                if (responseData.rawData.hasRecord) {
                    $UNPROCESSED_PRACS.text(responseData.rawData.pracsListCommaSeperated);
                } else {
                    $UNPROCESSED_PRACS.text('');
                }
            })
            .catch(responseData => {
                $UNPROCESSED_PRACS.text('');
            });
    }
    
    function fyQuarterSelectionCallback() {

        //
        findRosterForQuarter( GLOBAL_ROSTER_DATA.fqID );

        populateListOfPracsNotProcessed();
    }

    function refreshRestViewAndPracsNotProcessedList() {
        updateAdditionalViewParameterValuesAndRequestViewFromServer();
        populateListOfPracsNotProcessed();
    }

    // TSP document file upload
    function manageTSPDocuments() {

        let cid = $('#' + PARM_NAME_CLIENT_ID).val();

        var fileAdditionalDataJSONStr = '{clientid:' + cid + '}';
        if (cid != '') {
            $.spedmonWebUI.fileList('TSP Documents'
                , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>'
                , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
                , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
                , 3 /* Record id position */
                , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
              , '<%=MBA.StoredFiles.FILE_CLASS_RMTS_SUPPORTING_DOCS%>'
              , '' /* File subclass */
              , '<%=Spedmon.RmtsParticipationRosters.VAL_FILE_NAMESPACE%>'
                , '<%=Spedmon.RmtsParticipationRosters.VAL_FILE_SOURCE%>'
                , fileAdditionalDataJSONStr
                , true
                , true);
        }
        else {
            $('#clientid_all_cont').effect("shake", { distance: 7, times: 4 }, 50);
        }
    };

    function $createTSPFileUploadElem() {
        let $uploadBtn = $('<i class="fas fa-folder-open ml-1" title="manage TSP documents" onclick="manageTSPDocuments()"></i>');

        $uploadBtn.on("click", manageTSPDocuments);

        return $uploadBtn;
    }

    // launches the TSP file upload screen
    function launchRosterTSPFileUploadScreen() {

        //debugger;

        var url = '<%=Spedmon.StructuredDataImportFilesRmtsParticipantsData.URL_SAVE_NEW_SUB_PAGE_BASE()%>'
            + '&clientid='    + $('#' + PARM_NAME_CLIENT_ID).val()

              //
            + '&fyquarterid=' + GLOBAL_ROSTER_DATA.fqID // $('#' + PARM_NAME_QTR_ID).val();

        $.spedmonWebUI.openNewWindow(url, 'rmts-tsp-file-upload', refreshRestViewAndPracsNotProcessedList);
        return;
    }

    // launch screen for uploading TSP files
    function $createTspFileUploadScreenElem() {
        let $uploadBtn = $('<i class="fas fa-upload ml-1" title="upload TSP file"></i>');

        $uploadBtn.on("click", function () { launchRosterTSPFileUploadScreen() });

        return $uploadBtn;
    }
    
    function $createInstructionsElem() {
        // append instructions icon
        $instructionsIcon = $('<i style="font-size: 1.2em;" class="mba-rest-view fas fa-question-circle ml-2"></i>');
        instructionsText = `<p>Important: This RMTS Roster must match your certified TSP list provided to your LEC or LGA.</p>

                            <p>Instructions:</p>
                            <ul style="list-style-type: disc;" class="ml-3">
                                <li>To remove a practitioner that is not on your certified TSP list for the entire quarter, click edit, and choose "Not on TSP", from the "Reason For End Date Change" drop-down.</li>
                                <li>To add a practitioner click the "+" and select the practitioner. If adding after the quarter starts, modify the Start Date and select a reason for adding this practitioner, from the "Reason for Start Date Change" drop-down. </li>
                                <li>To remove a practitioner after the quarter has started, click edit, enter a modified End Date and select a reason for removing this practitioner, from the "Reason For End Date Change" drop-down</li>
                            </ul>

                            <p>Reasons for adding a practitioner after the quarter starts:</p>
                            <ul style="list-style-type: disc;" class="ml-3">
                                <li>Filled vacancy on certified TSP list.</li>
                                <li>Direct replacement on certified TSP list.</li>
                            </ul>

                            <p>Reason for removing a practitioner after the quarter starts:</p>
                            <ul style="list-style-type: disc;" class="ml-3">
                                <li>Vacancy opened on certified TSP list.</li>
                                <li>Not on certified TSP list.</li>
                            </ul>

                            <p>When "Not on TSP" is selected from the drop-down, the practitioner will be removed from the entire quarter, regardless of the dates listed. Future rosters will not include these practitioners.</p>
        `
        $instructionsIcon.tipso({
            speed: 400
            , background: '#ffd60d'
            , titleBackground: '#333333'
            , color: 'black'
            , titleColor: '#ffffff'
            , titleContent: ''
            , showArrow: true
            , position: 'top'
            , width: $(window).width() / 2
            , maxWidth: ''
            , delay: 200
            , hideDelay: 0
            , animationIn: ''
            , animationOut: ''
            , offsetX: 0
            , offsetY: 0
            , tooltipHover: true
            , content: instructionsText
            , ajaxContentUrl: null
            , contentElementId: null
            , useTitle: false
            , templateEngineFunc: null
            , onBeforeShow: null
            , onShow: null
            , onHide: null
        });

        $instructionsIcon.on('click', function () { $.spedmonWebUI.dialogMessage('Instructions', instructionsText, null, $(window).width() / 1.5, $(window).height() / 1.5, null, null, null);; });

        return $instructionsIcon;
    }

    function appendRestViewTopBtns() {
        $('th.mba-rest-view.mba-rest-view-row-controls').append($createTSPFileUploadElem()).append($createInstructionsElem()).append($createTspFileUploadScreenElem());
    }

    function launchRestViewIfParamsArePassed() {
        let clientID  = $('#' + PARM_NAME_CLIENT_ID).val();

        //
        let quarterID = GLOBAL_ROSTER_DATA.fqID ;

        if (clientID  && clientID != 0 &&
            quarterID && quarterID != 0
        ) {
            fyQuarterSelectionCallback();
        }
    }

    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restView');
        initView();

        appendRestViewTopBtns();

        launchRestViewIfParamsArePassed();

        $('#fiscalyearid_selection')
          .on('spedmoninput'
              ,
              function(){ 
                setTimeout(
                  fyQuarterSelectionCallback, 990

                );
              }
           );

        $('input[name=fiscalquarterselection_radiobox_name]')
          .on('change'
              ,
              function(){ 
                setTimeout(
                  fyQuarterSelectionCallback, 990
                );
              }
           );

    });
</script>
