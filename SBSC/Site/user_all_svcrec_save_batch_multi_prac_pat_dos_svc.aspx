<%@ Page Language="C#" CodeBehind="user_all_svcrec_save_batch_multi_prac_pat_dos_svc.aspx.cs" Inherits="Spedmon.userAllSvcRecMultiPracPatSaveAll"%>

<%//##################################################################################################################%>
<%//#                                                Notices   %>
<%//##################################################################################################################%>


<%if(hasRecsToPreload == true){%>
<div id="recs-to-preload-loading-msg" class="alert alert-info text-center">
Loading please wait
</div>
<%}%>

<%if(hasWipData == true){%>
<div id="wip-data-msg" class="alert alert-warning text-center" style="display:none;">
You have unfinalized records from <strong title="<%=wipDataLastSavedOnDateTimeStr%>"><%=wipDataLastSavedOnRelDateStr%></strong>. These records have been preloaded below. If you do not need to finalize these records <Spedmon:DataEntryButton ID="butDelWipSp" label="click here" onclick="doDeleteSvcRecsWipSavePoint()" fireSpedmonInput="false" size="SMALL" runat="server"></Spedmon:DataEntryButton> to delete them. 
</div>
<%}%>

<%//##################################################################################################################%>
<%//#                                            Data Entry Rows   %>
<%//##################################################################################################################%>

<Spedmon:DataEntryRows ID="save" purpose="SAVE" dataURL="servicerecords.asmx/savesvcrecsbatchmultipracpatdossvc" useBootstrapFluid="true" runat="server">

    <Spedmon:HiddenInput id="pracName" title="Practitioner Name" runat="server"></Spedmon:HiddenInput>
    <Spedmon:HiddenInput id="groupID" title="Practitioner Group" runat="server"></Spedmon:HiddenInput>
    <Spedmon:HiddenInput ID="groupSvcClassNameID" title="groupSvcClassNameID" runat="server"></Spedmon:HiddenInput>
    <Spedmon:HiddenInput id="patName" title="Patient Name" runat="server"></Spedmon:HiddenInput>
    <Spedmon:HiddenInput id="dosHidden" title="DOS" runat="server"></Spedmon:HiddenInput>
    <Spedmon:HiddenInput id="svcetrmde" name="svcetrmde" title="svcetrmde" runat="server"></Spedmon:HiddenInput>
        
    <div class="row d-flex justify-content-center flex-nowrap">
    <Spedmon:DataEntryRow ID="dataEntryRowSelectReferenceFile" rowLabel="" dataEntryRowRenderAs="FIELD" runat="server">         
      <span class="d-inline-block">
        <Spedmon:DataEntryBoxText ID="reference" name="reference" label="Enter Filename" title="Enter Filename" size="25" fireSpedmonInput="true" runat="server"/>
      </span>
      <span class="d-inline-block">
        <a id="referencefile" target="_blank" href=""><i class="fa fa-eye mr-2" title="View Batch File"></i></a>
      </span>
    </Spedmon:DataEntryRow>
    </div> <!-- row -->
    
    <div class="row mt-2">
        <div class="col-12">

           <%//-----------------------------------------------------------------------------%>
           <%// Select Client %>
           <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryRowSelectClient
                ID                   = "selectClient" 
                entityControlID      = "clientid"                
                rowLabel             = "Client"
                dataEntryRowRenderAs = "FIELD"
                runat                = "server">
            </Spedmon:DataEntryRowSelectClient>

           <%//-----------------------------------------------------------------------------%>
           <%// Select Practitioner %>
           <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryRowSelectPractitioner
                ID                                 = "selectPractitioner" 
                rowLabel                           = "Practitioner?" 
                dataEntryRowRenderAs               = "FIELD"
                showDataSourceSelection            = "true"            
                preSelectedDataSource              = "ALL_PRACTITIONERS"
                saveDataSourceSelectedAsPreference = "false"                  
                onSpedmonInputData                 = "$('#pracName').val(e.dataitem.label); $('#groupID').val(e.dataitem.recData1); $('#groupSvcClassNameID').val(e.dataitem.recData5); "
                runat                              = "server">
            </Spedmon:DataEntryRowSelectPractitioner>          
        </div> <!-- col -->

    </div> <!-- row -->
    
    <%//-----------------------------------------------------------------------------%>
    <%// Upcoming or Missing Assessement Options  %>
    <%// Note: These are only shown for the applicable screen modes %>
    <%//-----------------------------------------------------------------------------%>

    <div class="row">
    <div class="col-12">
      <div class="d-flex justify-content-end">
    
      <Spedmon:DataEntryRow ID="otherRecordAssmtLinks" dataEntryRowRenderAs="FIELD" runat="server">
           
      <Spedmon:LinkInternal 
         ID         = "gotorecordassmtsforupcomingiepsallpats" 
         title      = "Click here to record assessements for upcoming IEPS for all possible students and missing assessements for just my caseload"
         label      = "Click here to show all possible students"
         faClass    = "fa fa-link"               
         openNew    = "false"  
         subWindow  = "false"         
         runat      = "server" />
      
      <Spedmon:LinkInternal 
         ID         = "gotorecordassmtsforupcomingiepsmycaseload" 
         title      = "Click here to record assessements for upcoming IEPS and missing assessements for just my caseload" 
         label      = "Click here to show students on my caseload only"
         faClass    = "fa fa-link"
         openNew    = "false"  
         subWindow  = "false"
         runat      = "server" />

      </Spedmon:DataEntryRow>

      </div> <!-- containing element -->    

    </div> <!-- col -->
    </div> <!-- row -->

    <%//-----------------------------------------------------------------------------%>
    <%// Select Service Dates %>
    <%// Note: Row label defined in code behind %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRow ID="DataEntryRowSelectDate" runat="server">    
        
        <%// Select dates of service%>
        <%// Note: showOK and onMultiDateSelect set in code behind%>

        <Spedmon:DateBox 
            ID="dossvcs"  
            name="dossvcs"  
            title="Select or Enter dates" 
            numMonths="2"  
            monthsOffset="1"  
            multiDate="true" 
            multiDateAltFieldUseFirstOrLastSelected="last"
            dateFormat="yyyy-mm-dd" 
            runat="server"/>
    
    </Spedmon:DataEntryRow>       

    <div class="row mt-2">

        <%//-----------------------------------------------------------------------------%>
        <%// Select Patient %>
        <%//-----------------------------------------------------------------------------%>

        <div class="col-12 col-md-6">
            <Spedmon:DataEntryRowSelectPatient
                ID                                 = "selectPatient" 
                rowLabel                           = "Student?" 
                dataEntryRowRenderAs               = "FIELD"
                preSelectedDataSource              = "ALL_PATIENTS"
                showDataSourceSelection            = "true"    
                saveDataSourceSelectedAsPreference = "false"
                showAddNew                         = "true"
                onSpedmonInputData                 = "addPat(e);"
                runat                              = "server">
            </Spedmon:DataEntryRowSelectPatient>
         </div>

         <div class="col-12 col-md-6">
             
             <%//-----------------------------------------------------------------------------%>
             <%// Select Caseload or Group %>
             <%//-----------------------------------------------------------------------------%>

             <Spedmon:DataEntryRow ID="dataEntryRowSelectCaseload" rowLabel="Add Another Group to the List" dataEntryRowRenderAs="FIELD" runat="server">
                                  
                 <span class="d-inline-block">
                   <Spedmon:ComboBox 
                     ID                              = "selectGrp" 
                     name                            = "selectedgroupid" 
                     title                           = "Select Group" 
                     dataPrivate                     = "true" 
                     dataParms                       = "[{id:'clientid'},{id:'pracid'}]" 
                     dataURL                         = "practitioner_patient_groups.asmx/viewSelByClientPrac"
                     onSelect                        = "addGrp(event,ui, false);"
                     singleSelectClearAfterSelection = "true"
                     runat                           = "server" />
                 </span>

                 <span class="d-inline-block">
                   <i id="butCaseload" class="fa fa-address-book mr-3" title="My Caseload"></i>
                 </span>

             </Spedmon:DataEntryRow>
             

             <%//-----------------------------------------------------------------------------%>
             <%// Select Scheduled Group (Only used for record for scheduled services)        %>
             <%//-----------------------------------------------------------------------------%>

             <Spedmon:DataEntryRow ID="dataEntryRowSelectScheduledGroup" rowLabel="Add Another Group to the List" dataEntryRowRenderAs="FIELD" runat="server">                              
                 <span class="d-inline-block">
                   <Spedmon:ComboBox 
                        ID                              = "selectGrpScheduled" 
                        name                            = "groupidscheduled" 
                        title                           = "Select Group" 
                        dataPrivate                     = "true" 
                        dataParms                       = "[{id:'clientid'},{id:'pracid'}]" 
                        dataURL                         = "practitioner_patient_groups.asmx/viewSelByClientPrac"
                        onSelect                        = "addGrpScheduled(event,ui);"
                        singleSelectClearAfterSelection = "true"
                        runat                           = "server" />
                 </span>
             </Spedmon:DataEntryRow>
                        
        </div> <!-- col -->
    </div> <!--row -->

    <%//-----------------------------------------------------------------------------%>
    <%// Service Entry %>
    <%//-----------------------------------------------------------------------------%>

    <div class="row mt-3">
        <div class="col-12">
            <div id="dataGrid"></div>
        </div>
    </div>

    <%//-----------------------------------------------------------------------------%>
    <%// Save or Cancel %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSaveOrEdit  
        ID                = "saveOrEdit" 
        editDelManageLink = ""
        runat             = "server">  
    </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let $SVC_RECS_DATAGRID = null;
    let $DOS_HIDDEN        = null;
    let hasRecsToPreload   = 0;
    let hasWipData         = 0;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const PARM_NAME_CLIENT_ID                = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_PRAC_ID                  = '<%=Constants.PARM_PRACTITIONER_ID%>';
    const PARM_NAME_PAT_ID                   = '<%=Constants.PARM_PATIENT_ID%>';
    const PARM_NAME_DOS                      = '<%=Constants.PARM_DOS%>';
    
    const PARM_NAME_RECS_TO_PRELOAD          = 'recsToPreloadJSON';
    const CONST_FIELD_NAME                   = 'data-mba-rest-view-field-name';
    const CONST_ATTR_SVC_NAME_ID             = 'nameid';
    const CONST_ATTR_SVC_NAME                = 'svcName';
    const CONST_ATTR_ALT_MODALALITY_NAME_ID  = "altModalityNameID";
    const CONST_ATTR_PRAC_NAME               = 'pracName';
    const CONST_ATTR_GROUP_ID                = 'groupID';
    const CONST_ATTR_PAT_NAME                = 'patName';
    const DATAGRID_PLUS_ICON_IDENTIFIER      = 'i.mba-rest-view.mba-rest-view-ctrl-icon.fa-plus';
    const CSS_CLASS_ICON_TOGGLED             = 'pulsating-icon-toggled';
    const CSS_CLASS_HIDDEN                   = 'hidden-element';
    const CONST_SVC_DETAILS_REF              = 'svc-details-ref';
    const CONST_ELEM_REF_ICON_FB_HAS_NOTES   = 'fb-has-notes-ref';

    <%//#########################################################%>
    <%//#  Misc Handlers %>
    <%//#########################################################%>

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function doDeleteSvcRecsWipSavePoint() {
        let diaDoDeleteSvcRecsWipSavePoint = null;
        let content = '<p class="text-center">If you click proceed you will <strong>permanently</strong> delete all unfinalized records on this screen.</p>';
        
        let fnDoRequestDeleteSavePoint = function () {

            MBA.ComponentCommon.fnDisableElement($('#butDelWipSp'));

            $SVC_RECS_DATAGRID.MBA_DataGrid('showOverlayMessage', 'Clearing data');

            MBA.WorkInProgressSavePoints.fnDeleteFromForm('<%=Constants.PARM_SAVE_FORM%>')
                .then(responseData => { $(diaDoDeleteSvcRecsWipSavePoint).dialog('close'); MBA.ComponentCommon.fnGotoURL('<%=reloadUrl%>'); });
        };
        diaDoDeleteSvcRecsWipSavePoint = MBA.ComponentCommon.fnCreateOneTimeProceedOrCancelDialog('Are You Sure?', content, {}, fnDoRequestDeleteSavePoint, null, false, true);
        $(diaDoDeleteSvcRecsWipSavePoint).dialog('open');
        return;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function updateBatchFileLink() {
        let fileReference = $('#reference').val();
        let reqUrl = '<%=Spedmon.ServiceRecords.URL_GET_STORED_FILE_WORK_FLOW()%>';
        let reqObj = {};
        reqObj['<%=Spedmon.Constants.PARM_BATCH_ID%>']             = '';
        reqObj['<%=Spedmon.Constants.PARM_BATCH_FILE_REFERENCE%>'] = fileReference;
        let reqJSON = JSON.stringify(reqObj);
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, '<%=MBA.Credential.generateSessionExpiredLink()%>')
            .then(returnDataObj => {
                $('#referencefile').show('slow');
                $('#referencefile').attr('href', returnDataObj.rawData.value);
            });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    <%//#########################################################%>
    <%//#  Service Entry Notifications %>
    <%//#########################################################%>

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const CONST_DATA_ATTR_NAME_SERVICE_ENTRY_NOTIFICATIONS = 'service-entry-notifications';

    const _notificationNoExitScreenMsg = '<br><br>You can manage the order and service authorization data for this patient without closing the record service records screen by clicking on the button below.';

    const _notificationTypeOrderExpiration = 1;
    const _notificationMsgOrderExpiration = "<i class=\"fas fa-calendar-times mr-1\"></i> The order for this service needs authorization.<br><br>The current authorization for this service is either expired, expiring in the next 30 days, or pending authorization.  Please update this order with a new authorization date (when available) or request new authorization. " + _notificationNoExitScreenMsg;

    const _notificationTypeNoOrdersForDos = 2;
    const _notificationMsgNoOrdersForDos = "<i class=\"fas fa-prescription mr-1\"></i> This service requires an order.<br><br>No order for this service is currently in SpEdCare.  Please add a new order." + _notificationNoExitScreenMsg;
    
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function displayServiceEntryNotifications($rowRef) {

        let notificationsArr = getServiceEntryNotificationsArr($rowRef)
        let notificationsContent = notificationsArr.map(o => o.message).join('<br/>');
        MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Please Note', notificationsContent, null);
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function getServiceEntryNotificationsArr($rowRef) {
        let notificationsArr = $($rowRef).data(CONST_DATA_ATTR_NAME_SERVICE_ENTRY_NOTIFICATIONS);
        return notificationsArr;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function setServiceEntryNotificationsArr($rowRef, notificationsArr) {
        return $($rowRef).data(CONST_DATA_ATTR_NAME_SERVICE_ENTRY_NOTIFICATIONS, notificationsArr);
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function initServiceEntryNotificationsArr($rowRef) {
        let notificationsArr = [];
        let $bell = $($rowRef).find('button[data-mba-rest-view-ctrl-def-name="setNotifications"] > i.fa-bell')[0];
        $($bell).addClass(CSS_CLASS_HIDDEN);
        setNotificationToolTip($bell, notificationsArr.map(o => o.message).join('<br />'));
        return setServiceEntryNotificationsArr($rowRef, notificationsArr);
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function setNotificationToolTip($bell, content) {

        $($bell).tipso('destroy').tipso({
            speed: 400
            , background: '#ffc57d'
            , titleBackground: '#333333'
            , color: 'black'
            , titleColor: '#ffffff'
            , titleContent: ''
            , showArrow: true
            , position: 'top-right'
            , width: 600
            , maxWidth: ''
            , delay: 200
            , hideDelay: 0
            , animationIn: ''
            , animationOut: ''
            , offsetX: 0
            , offsetY: 0
            , tooltipHover: true
            , content: content
            , ajaxContentUrl: null
            , contentElementId: null
            , useTitle: false
            , templateEngineFunc: null
            , onBeforeShow: null
            , onShow: null
            , onHide: null
        });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function findNotificationBellControl($rowRef) {
        let $bell = $($rowRef).find('button[data-mba-rest-view-ctrl-def-name="setNotifications"] > i.fa-bell')[0];
        return $bell;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function addNotification($row, message, type) {

        // if no service type, remove notification for service type

        let $orpDocID = $($row).find('input[' + CONST_FIELD_NAME + '="orpDocumentID"]');
        if (!$($orpDocID).val()) {
            removeNotification($row, _notificationTypeOrderExpiration);
        }

        let $bell = findNotificationBellControl($row);
        $($bell).removeClass(CSS_CLASS_HIDDEN);

        let notificationsArr = getServiceEntryNotificationsArr($row);

        // create notification object

        let notificationObj = {
            "type": type
            , "message": message
        }

        // update notifications in object
        
        notificationsArr.push(notificationObj);
        setServiceEntryNotificationsArr($row, notificationsArr);

        setNotificationToolTip($bell, notificationsArr.map(o => o.message).join('<br />'));
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function removeNotification($row, type) {

        let $bell = findNotificationBellControl($row);

        let notificationsArr = getServiceEntryNotificationsArr($row);

        // update notifications in object

        notificationsArr = notificationsArr.filter(item => item.type != type);
        setServiceEntryNotificationsArr($row, notificationsArr);

        setNotificationToolTip($bell, notificationsArr.map(o => o.message).join('<br/><br/>'));

        // deactivate bell if no more notifications
        if (notificationsArr.length == 0) {
            $($bell).addClass(CSS_CLASS_HIDDEN);
        }
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function buildNotificationMessage($row, notificationMsgBase, actionUrlTitle, actionUrlBase) {
        let ccpdDataObj = getClientPracPatDosDataFromRow($row);
        let _actionUrl = MBA.ComponentCommon.fnBuildUrl(actionUrlBase, true, ccpdDataObj.nameValuesObj);
        let _notificationMsg = notificationMsgBase + '<br><br><a class="btn btn-primary" style="color:#fff" role="button" href="' + _actionUrl + '" target="_blank">' + actionUrlTitle + '</a>';
        return _notificationMsg;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    <%//#########################################################%>
    <%//#  Add Rows %>
    <%//#########################################################%>

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function addNewRow(rowData) {
        let uiActionObj = $SVC_RECS_DATAGRID.MBA_DataGrid('addNewInlineUnlockedRow', rowData);
        return uiActionObj;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function addNewRowsFromSvcDateSelections() {

        /* Assumes a patient is selected and all hidden fields are setup */

        let dosMulti = $('#dossvcs').val();

        if (dosMulti) {
            let _dosArray = dosMulti.split(',');
            _dosArray.sort();
            _dosArray.reverse();

            // for each date selected, modify the default date and add a row to dataGrid
            $.each(_dosArray, function (_idx, _dosElemVal) {
                $DOS_HIDDEN.val(_dosElemVal);
                let rowData = {};                
                addNewRow(rowData);
                /*$(DATAGRID_PLUS_ICON_IDENTIFIER).trigger('click');*/
            });
        }
        $('#dossvcs').val('');
        return;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function addPat(e) {
        $('#patName').val(e.dataitem.label); // needed for dataGrid

        // validation
        let clientID = $('#' + PARM_NAME_CLIENT_ID).val();
        let pracID   = $('#' + PARM_NAME_PRAC_ID).val();
        let patID    = $('#' + PARM_NAME_PAT_ID).val();

        if (!clientID || !pracID || !patID) {
            $('#clientid_all_cont, #pracid_all_cont, #patid_all_cont').effect("shake", { distance: 7, times: 4 }, 50);
            return;
        }

        // handle multi date (if needed)
        let dosMulti = $('#dossvcs').val();
        
        if (dosMulti) {
            let _dosArray = dosMulti.split(',');
            _dosArray.sort();
            _dosArray.reverse();

            // for each date selected, modify the default date and add a row to dataGrid
            $.each(_dosArray, function (_idx, _dosElemVal) {
                $DOS_HIDDEN.val(_dosElemVal);
                let rowData = {};
                addNewRow(rowData);

                /*$(DATAGRID_PLUS_ICON_IDENTIFIER).trigger('click');*/
            });

        }
        else {
            // if no date selected, we use the default value (set from the code behind)
            $DOS_HIDDEN.val('<%=dos%>');
            let rowData = {};
            addNewRow(rowData);
            /*$(DATAGRID_PLUS_ICON_IDENTIFIER).trigger('click');*/
        }

        return;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function addCaseload() {

        let tkn        = $.spedmonWebUI.token;
        let reqUrl     = "patients.asmx/viewSel?tkn=" + tkn;
        let reqDataObj = {};
        let clientid   = $('#' + PARM_NAME_CLIENT_ID).val();
        let pracid     = $('#' + PARM_NAME_PRAC_ID).val();

        if (!pracid) {
            $('#pracid_all_cont').effect("shake", { distance: 7, times: 4 }, 50);
            return;
        }

        reqDataObj.patdatasource = 2;
        reqDataObj.clientid      = clientid;
        reqDataObj.pracid        = pracid;
        reqDataObj.term          = '';
        reqDataObj.dos           = '';

        let reqDataJSON = JSON.stringify(reqDataObj);

        $SVC_RECS_DATAGRID.MBA_DataGrid('showOverlayMessage', 'Getting Caseload');

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqDataJSON, null)
            .then(responseData => {
                let patients = responseData.rawData.SelRecs;
                if (patients) {
                    let rowsDataIn = [];
                    $.each(patients, function (idx, pat) {
                        let rowData = {};
                        rowData.patid       = pat.id;
                        rowData.patName     = pat.label;
                        rowData.pracid      = pracid;
                        rowData.clientid    = clientid;
                        rowData.svcclientid = clientid;
                        rowData.svcpracid   = pracid;
                        rowData.svcpatid    = pat.id;
                        rowsDataIn.push(rowData);
                    });

                    $SVC_RECS_DATAGRID.MBA_DataGrid('preloadInlineUnlockedRows', rowsDataIn);
                }
                $SVC_RECS_DATAGRID.MBA_DataGrid('hideOverlayMessage');
            })
            .catch(responsedata => {
                $SVC_RECS_DATAGRID.MBA_DataGrid('hideOverlayMessage');
            });

        return;

    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function loadOnlyGroup(grpId) {
        grpId = Number(grpId || 0);
        if (!grpId) return;

        $SVC_RECS_DATAGRID.MBA_DataGrid('deleteAllInlineUnlockedRows');

        let grpui = { item: { id: grpId } };

        addGrpScheduled(null, grpui, function () {
            triggerBeginLiveSession(grpId);
        });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function triggerBeginLiveSession() {
        let $btn = $SVC_RECS_DATAGRID
            .find('button[data-mba-rest-view-ctrl-def-name="beginLiveGrpSession"]')
            .first();

        if ($btn.length) {
            $btn.trigger('click');
        }
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function addGrp(event, ui, entireCaseload) {
        let tkn = $.spedmonWebUI.token;
        let grpid = '';
        let reqUrl = '';
        if (!entireCaseload && ui) {
            grpid = ui.item.id;
            reqUrl = "practitioner_patient_group_members.asmx/viewSelWithMtdYtdTots?tkn=" + tkn;
        }
        else {            
            grpid = $('#' + PARM_NAME_PRAC_ID).val();
            reqUrl = "practitioner_caseload_members.asmx/viewSelWithMtdYtdTots?tkn=" + tkn;

            // make sure practitioner is selected
            if (!grpid) {
                $('#pracid_all_cont').effect("shake", { distance: 7, times: 4 }, 50);
                return;
            }
        }

        /****** set up ajax url ***********/

        let reqData = JSON.stringify({
            "organizationID": $('#' + PARM_NAME_CLIENT_ID).val()
            , "ownerID": $('#' + PARM_NAME_PRAC_ID).val()
            , "groupID": grpid
            , "term": ""
            , "iep": ""
            , "nameID": ""
            , "refDate": ""
        });

        $SVC_RECS_DATAGRID.MBA_DataGrid('showOverlayMessage', 'Loading Group');

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                let patients = responseData.rawData.SelRecs;
                if (patients) {

                    // since we prepend rows to table, we need to reverse the returned array
                    let patientsSorted = patients.reverse();

                    $.each(patientsSorted, function (_idx, _patObj) {
                        // set patid and patName, then add a row to table
                        $('#' + PARM_NAME_PAT_ID).val(_patObj.id);
                        $('#' + CONST_ATTR_PAT_NAME).val(_patObj.label);
                        let rowData = {};
                        addNewRow(rowData);                       
                    });
                }
                $SVC_RECS_DATAGRID.MBA_DataGrid('hideOverlayMessage');
            })
            .catch(responsedata => {
                $SVC_RECS_DATAGRID.MBA_DataGrid('hideOverlayMessage');
            });
        
        return;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function addGrpScheduled(event, ui, afterLoadFn) {
        let tbody = $SVC_RECS_DATAGRID.find('table.mba-rest-view-table').find('tbody.mba-rest-view-table-body')[0];

        // function to append group memebers to the dataGrid
        let _appendGrpData = function () {

            /****** set up ajax url ***********/

            let reqUrl = '<%=Spedmon.ServiceRecordsExpectedEntryRows.URL_ASMX_VIEW_LIST_EXP_TMT_SVCS_ON_DOS_BASE()%>';
            let reqData = JSON.stringify({
                "clientid": $('#' + PARM_NAME_CLIENT_ID).val()
                , "pracid": $('#' + PARM_NAME_PRAC_ID).val()
                , "dos": $DOS_HIDDEN.val()
                , "pracpatgroupid": ui.item.id
            });

            $SVC_RECS_DATAGRID.MBA_DataGrid('showOverlayMessage', 'Loading Scheduled Group');

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                .then(responseData => {
                    let patients = responseData.rawData.data;
                    if (patients.length > 0) {
                        $SVC_RECS_DATAGRID.MBA_DataGrid('preloadInlineUnlockedRows', patients);
                    }
                    $SVC_RECS_DATAGRID.MBA_DataGrid('hideOverlayMessage');

                    if (typeof afterLoadFn === 'function') {
                        afterLoadFn();
                    }
                })
                .catch(responsedata => {
                    $SVC_RECS_DATAGRID.MBA_DataGrid('hideOverlayMessage');
                });
        };

        // confirm with user if they want to delete all records before adding group
        
        let onYes = function () {
            $($SVC_RECS_DATAGRID).MBA_DataGrid('deleteAllInlineUnlockedRows');
            _appendGrpData();
        };

        if ($(tbody).children().length > 0) {
            $.spedmonWebUI.dialogConfirm("Please Confirm", "Do you want to replace the current list of scheduled services with the chosen group? If no, this group will be added to the existing list.", onYes, _appendGrpData);
        }
        else {
            _appendGrpData();
        }

        return;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    <%//#########################################################%>
    <%//#  Callbacks for before/after row/cells add %>
    <%//#########################################################%>

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/


    let fnSvcRecsEntryAddNewRowAndCellsAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

        let $rowRef = $newRow[0];

        <%//-----------------------------------------------------------------------------%>
        <%// Init notifications %>
        <%//-----------------------------------------------------------------------------%>

        initServiceEntryNotificationsArr($rowRef);

        <%//-----------------------------------------------------------------------------%>
        <%// No data, we are done %>
        <%//-----------------------------------------------------------------------------%>

        let $btnLiveSession = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="beginLiveGrpSession"]');
        if (!$btnLiveSession.length) return $newRow;

        // default: hide
        $btnLiveSession.hide();

        if (!rowData) return $newRow

        let grpId = (rowData.caseloadGrpId == null) ? 0 : rowData.caseloadGrpId;
        if (grpId > 0) {
            $btnLiveSession.show();
        }

        <%//-----------------------------------------------------------------------------%>
        <%// Check order status %>
        <%//-----------------------------------------------------------------------------%>

        if (rowData.hasOrpSel == 'true') {            
            checkPatOrdersForDos($rowRef);
        }

        <%//-----------------------------------------------------------------------------%>
        <%// Set initial state for question form icon %>
        <%//-----------------------------------------------------------------------------%>

        let _qButIcon = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="setQuestionFormFlag"] > i.fa-question-circle')[0];

        if (_qButIcon) {
            if (rowData.createQuestionForm === 'true') $(_qButIcon).addClass(CSS_CLASS_ICON_TOGGLED);
        }

  
        return $newRow
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnModifyRowDataBeforeAddNew = function (uiActionObj, rowData) {

        let clientIDVal  = $('#' + PARM_NAME_CLIENT_ID).val();
        let pracIDVal    = $('#' + PARM_NAME_PRAC_ID).val();
        let pracNameVal  = $('#' + CONST_ATTR_PRAC_NAME).val();
        let pracGrpIDVal = $('#' + CONST_ATTR_GROUP_ID).val();
        let patIDVal     = $('#' + PARM_NAME_PAT_ID).val();
        let patNameVal   = $('#' + CONST_ATTR_PAT_NAME).val();
        let dosVal       = $DOS_HIDDEN.val();

        if (!MBA.ComponentCommon.fnHasValue((rowData.clientid)))                    rowData.clientid                    = clientIDVal;
        if (!MBA.ComponentCommon.fnHasValue((rowData.pracid)))                      rowData.pracid                      = pracIDVal;
        if (!MBA.ComponentCommon.fnHasValue((rowData.pracName)))                    rowData.pracName                    = pracNameVal;
        if (!MBA.ComponentCommon.fnHasValue((rowData.groupID)))                     rowData.groupID                     = pracGrpIDVal;
        if (!MBA.ComponentCommon.fnHasValue((rowData.patid)))                       rowData.patid                       = patIDVal;
        if (!MBA.ComponentCommon.fnHasValue((rowData.patName)))                     rowData.patName                     = patNameVal;
        if (!MBA.ComponentCommon.fnHasValue((rowData.dos)))                         rowData.dos                         = dosVal;
        if (!MBA.ComponentCommon.fnHasValue((rowData.attendanceStatusSelectionID))) rowData.attendanceStatusSelectionID = '0'; 
        if (!MBA.ComponentCommon.fnHasValue((rowData.createQuestionForm)))          rowData.createQuestionForm          = 'false';
        if (!MBA.ComponentCommon.fnHasValue((rowData.RMTSMoment)))                  rowData.RMTSMoment                  = 'false';  /* TODO: Remove when we can refactor back end code */

        if (!MBA.ComponentCommon.fnHasValue((rowData.hasOrpSel)))       rowData.hasOrpSel       = 'false';
        if (!MBA.ComponentCommon.fnHasValue((rowData.hasSvcDetFlags)))  rowData.hasSvcDetFlags  = 'false';
        if (!MBA.ComponentCommon.fnHasValue((rowData.orpDocumentID)))   rowData.orpDocumentID   = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.orpDocumentName))) rowData.orpDocumentName = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcDetFlag1)))     rowData.svcDetFlag1     = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcDetFlag2)))     rowData.svcDetFlag2     = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcDetFlag3)))     rowData.svcDetFlag3     = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcDetFlag4)))     rowData.svcDetFlag4     = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcclientid)))     rowData.svcclientid     = rowData.clientid;
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcpracid)))       rowData.svcpracid       = rowData.pracid;
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcpatid)))        rowData.svcpatid        = rowData.patid;

        if (!MBA.ComponentCommon.fnHasValue((rowData.svcTypeId)))           rowData.svcTypeId           = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcSubType1Id)))       rowData.svcSubType1Id       = '';
        if (!MBA.ComponentCommon.fnHasValue((rowData.orpDocSelectionAuto))) rowData.orpDocSelectionAuto = 'false';

        
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcNotesFormBuilderQuestionsJSON))) rowData.svcNotesFormBuilderQuestionsJSON = '{}';
        if (!MBA.ComponentCommon.fnHasValue((rowData.svcNotesFormBuilderAnswersJSON)))   rowData.svcNotesFormBuilderAnswersJSON   = '{}';
        if (!MBA.ComponentCommon.fnHasValue((rowData.patientGoalProgressJSON)))          rowData.patientGoalProgressJSON          = '{}';
        if (!MBA.ComponentCommon.fnHasValue((rowData.hasPatientGoalTrackingData)))       rowData.hasPatientGoalTrackingData       = 'false';
        if (!MBA.ComponentCommon.fnHasValue((rowData.hasSessionRatingTracking)))         rowData.hasSessionRatingTracking         = 'false';
        if (!MBA.ComponentCommon.fnHasValue((rowData.hasFillablePdfSelections)))         rowData.hasFillablePdfSelections         = 'false';
        if (!MBA.ComponentCommon.fnHasValue((rowData.fillablePdfSelectionsJSON)))        rowData.fillablePdfSelectionsJSON        = '[]';
        if (!MBA.ComponentCommon.fnHasValue((rowData.fillablePdfAnswersJSON)))           rowData.fillablePdfAnswersJSON           = '[]';
        let forcedGrpId = '<%=caseloadGrpId%>';
        if (!MBA.ComponentCommon.fnHasValue(rowData.caseloadGrpId) && forcedGrpId) {
            rowData.caseloadGrpId = forcedGrpId;
        }
    
        return rowData;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnSvcRecsEntryCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) {  
        
        <%//-----------------------------------------------------------------------------%>
        <%// Date of Service %>
        <%//-----------------------------------------------------------------------------%>

        if (fieldDefinition.name === 'dos' && rowtype == 2) {

            // add change event for notifications

            $(newCellValueElem).on('change', function (e) {
                if ($(newRow).find('input[' + CONST_FIELD_NAME + '="hasOrpSel"]').val() == 'true') {
                    checkPatOrdersForDos($(newRow)[0]);
                }
            });
        }

       <%//-----------------------------------------------------------------------------%>
       <%// Patient name %>
       <%//-----------------------------------------------------------------------------%>

        if (fieldDefinition.name === 'patName') {
            $(newCellValueElem).attr('title', 'Edit Patient Profile');
            $(newCellValueElem).wrap('<a href="#" class="mba-rest-view-drill-down"></a>');
            $(newCellValueElem).append($('<i class="fa fa-pencil-alt fa-sm ml-1"></i>'));
            $(newCellValueElem).closest('a').on('click', function () {
              let reqUrl = '<%=urlEditPatient%>' + rowData.patid;
              return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
            });
            
            if (MBA.ComponentCommon.fnHasValue((rowData.expectedEntryContext))) {
              $(newCell).append('<br><sup>' + rowData.expectedEntryContext + '</sup>');
            }
       }

       <%//-----------------------------------------------------------------------------%>
       <%// Service Selection Column %>
       <%//-----------------------------------------------------------------------------%>

       else if (fieldDefinition.name === CONST_ATTR_SVC_NAME_ID) {
                

                let $rowRef = $(newRow)[0];
                let $svcSelFldSet = $(newCellValueElem);
                let $svcSel = $($svcSelFldSet).children('input')[0];
                let $dsDetailsFlags = $('<details class="service-details-flags" title="This Service Requires More Information"></details>');
                $dsDetailsFlags.append('<summary class="service-details-flags">Show Details</summary>');                            
                
                let $dsDetailsOrpSel = $('<details class="service-details-orp" title="This Service Requires More Information"></details>');
                $dsDetailsOrpSel.append('<summary class="service-details-orp">Show Details</summary>');

                $(newCell).append($dsDetailsFlags);
                $(newCell).append($dsDetailsOrpSel);               
                
                /* Define standard radio options for service details */
                
                let stdSvcDetRadioOpts = {
                    legend: ''
                    , additionalCssClasses: {
                        fieldset: 'service-detail-container'
                        , legend: 'service-detail-question'
                    }
                    , appendTo: ($dsDetailsFlags)
                    , additionalChangeEventForHiddenInput: 'restvieweditcancel'
                    , selections: [
                        {
                            name: 'Yes', value: 'true', cssClasses: { radioLabel: 'service-detail-answer service-detail-answer-yes', radioInput: 'service-detail-answer' }, additionalAttributes: [
                                { name: 'data-mba-rest-view-field-edit-state', value: 'locked' }]
                        }
                        , {
                            name: 'No', value: 'false', cssClasses: { radioLabel: 'service-detail-answer service-detail-answer-no', radioInput: 'service-detail-answer' }, additionalAttributes: [
                                { name: 'data-mba-rest-view-field-edit-state', value: 'locked' }]
                        }
                    ]
                };

                /* Define standard selection options for service details */
                
                let stdSvcDetSelOpts = {
                    dataParmType: 'DOM',
                    selectAll: true,
                    delay: 600,
                    showSelectControlLabel: false,
                    selectControlLabel: 'Select : ',
                    selectType: 1,
                    displayInline: true,
                    singleSelectName: addCellValRefsMap.get('orpDocumentName').val(),
                    singleSelectValue: '',
                    singleSelectClearAfterSelection: false,
                    multiSelect: false,
                    multiSelectShowOK: true,
                    multiSelectListTitle: 'Selected records',
                    multiSelectNames: '',
                    multiSelectValues: '',
                    multiSelectLoad: false,
                    multiSelectContextLabels: 'null',
                    multiSelectDisplayContextLabels: false,
                    multiSelectOnAdd: function (selObj) { },
                    multiSelectOnRemove: function (selObj) { },
                    onSelect: function (event, ui) {
                        let orpDocNameCellRef = addCellValRefsMap.get('orpDocumentName');
                        $(orpDocNameCellRef).val(ui.item.label);
                        checkPatOrdersForExpiration($rowRef, ui.item.recData4);
                    },
                    ajaxopts: { 
                        url: "orp_documents.asmx/viewSel?tkn=" + $.spedmonWebUI.token,
                        data: "",
                        getnamevaluesfn: function () {                            var _nvporpobj =                                [{                                    name: 'clientid', value: addCellValRefsMap.get('svcclientid').val()                                }, {                                    name: 'pracid', value: addCellValRefsMap.get('svcpracid').val()                                }, {                                    name: 'patid', value: addCellValRefsMap.get('svcpatid').val()                                }];                            return _nvporpobj;                        }

                    }
                };
                
                /* Setup hasSvcDetFlags */

                let hasSvcDetFlagsCellRef = addCellValRefsMap.get('hasSvcDetFlags');
                $(hasSvcDetFlagsCellRef).on(MBA.RestViewCommon.EVENT_NAME_EDIT_CANCEL + ' ' + MBA.RestViewCommon.EVENT_NAME_EDIT_PROCEED, function (e) {
                    showOrHideServiceDetails($(hasSvcDetFlagsCellRef).val(), $dsDetailsFlags, false);
                });

                /* Setup radio for svcDetFlag1 */

                let svcDetFlag1CellRef = addCellValRefsMap.get('svcDetFlag1');
                let svcDetRadioOpts1 = $.extend({}, stdSvcDetRadioOpts);
                svcDetRadioOpts1.legend = 'Performed Evaluation of Speech Fluency?';
                $(svcDetFlag1CellRef).MBA_input_radio(svcDetRadioOpts1);
                
                /* Setup radio for svcDetFlag2 */

                let svcDetFlag2CellRef = addCellValRefsMap.get('svcDetFlag2');
                let svcDetRadioOpts2 = $.extend({}, stdSvcDetRadioOpts);
                svcDetRadioOpts2.legend = 'Performed Evaluation of Speech Sound Production?';
                $(svcDetFlag2CellRef).MBA_input_radio(svcDetRadioOpts2);

                /* Setup radio for svcDetFlag3 */

                let svcDetFlag3CellRef = addCellValRefsMap.get('svcDetFlag3');
                let svcDetRadioOpts3 = $.extend({}, stdSvcDetRadioOpts);
                svcDetRadioOpts3.legend = 'Performed Evaluation of Language Comprehension and Expression?';
                $(svcDetFlag3CellRef).MBA_input_radio(svcDetRadioOpts3);

                /* Setup radio for svcDetFlag4 */

                let svcDetFlag4CellRef = addCellValRefsMap.get('svcDetFlag4');
                let svcDetRadioOpts4 = $.extend({}, stdSvcDetRadioOpts);
                svcDetRadioOpts4.legend = 'Performed Behavioral and Qualitative Analysis of Voice and Resonance?';
                $(svcDetFlag4CellRef).MBA_input_radio(svcDetRadioOpts4);

                /* Setup hasOrpSel */

                let hasOrpSelCellRef = addCellValRefsMap.get('hasOrpSel');
                $(hasOrpSelCellRef).on(MBA.RestViewCommon.EVENT_NAME_EDIT_CANCEL + ' ' + MBA.RestViewCommon.EVENT_NAME_EDIT_PROCEED, function (e) {
                    showOrHideServiceDetails($(hasOrpSelCellRef).val(), $dsDetailsOrpSel, false);
                });

                /* Setup orp selection */

                let orpDocumentIDCellRef = addCellValRefsMap.get('orpDocumentID');
                $(orpDocumentIDCellRef).attr('title', 'Select Order or Prescription');                
                let $orpDocSelDiv = $('<div class="mt-3"></div>');
                $($orpDocSelDiv).append($(orpDocumentIDCellRef));                
                $(orpDocumentIDCellRef).spedmonSelectBox(stdSvcDetSelOpts);
                $(orpDocumentIDCellRef).on('spedmoninputdata', function (e) {
                    $(orpDocumentIDCellRef).trigger('change');
                });

                $($dsDetailsOrpSel).append($orpDocSelDiv);                

                /* Setup add new order/prescription */

                let $addNewOrderDiv = $('<div class="mt-2 mb-3"></div>');
                let $newOrderText = $('<span>New order/prescription: </span>');
                let $newOrderBut = $('<i class="fas fa-plus" title="Add new order or prescription"></i>');
                $($addNewOrderDiv).append($newOrderText).append($newOrderBut);

                $($dsDetailsOrpSel).append($addNewOrderDiv);

                $($newOrderBut).off().on('click', function () {
                    $.spedmonWebUI.openAddNewServiceJournalsPrescribedOrderForm(null
                        , null
                        , addCellValRefsMap.get('svcclientid').val()
                        , addCellValRefsMap.get('svcpatid').val()
                        , addCellValRefsMap.get('svcpracid').val()
                        , null);
                });

                /* Create an object we can reference if there are changes made to the nameID (autocomplete) */

                let hasSvcDetailsVal = 'false';
                if (rowData.hasSvcDetFlags === 'true' || rowData.hasOrpSel === 'true') hasSvcDetailsVal = 'true';
                
                let svcDetailsRefObj = {};
                svcDetailsRefObj.rowRef            = $rowRef;
                svcDetailsRefObj.hasSvcDetails     = hasSvcDetailsVal;
                svcDetailsRefObj.dsDetailsFlags    = $dsDetailsFlags;
                svcDetailsRefObj.dsDetailsOrpSel   = $dsDetailsOrpSel;
                svcDetailsRefObj.addCellValRefs    = addCellValRefs;
                svcDetailsRefObj.addCellValRefsMap = addCellValRefsMap;

                /* Save this object */

                $($svcSel).data(CONST_SVC_DETAILS_REF, svcDetailsRefObj);

                /* Show or hide service details based on initial data loaded from server */
                
                if (rowData.hasSvcDetFlags === 'true') {
                    showOrHideServiceDetails('' + rowData.hasSvcDetFlags, $dsDetailsFlags, false);
                    showOrHideServiceDetails('false', $dsDetailsOrpSel, false);
                }
                else if (rowData.hasOrpSel === 'true') {
                    if (rowData.orpDocSelectionAuto === 'false') {
                        showOrHideServiceDetails('true', $dsDetailsOrpSel, false);
                    }
                    else {
                      showOrHideServiceDetails('false', $dsDetailsOrpSel, false);
                    }
                    showOrHideServiceDetails('false', $dsDetailsFlags, false);
                }
                else {
                    showOrHideServiceDetails('false', $dsDetailsFlags, false);
                    showOrHideServiceDetails('false', $dsDetailsOrpSel, false);
                }
            }

            <%//-----------------------------------------------------------------------------%>
            <%// Service Notes  %>
            <%//-----------------------------------------------------------------------------%>

            else if (fieldDefinition.name === 'notes') {


                <%if (isPrac == true) { %>

                /* Create references to form builder questions and answer hidden text area fields so we can access them
                * inside fnRenderNoteLibAddContent through the magic of closures and scope */

                let formBuilderQuestionsCellRef       = addCellValRefsMap.get('svcNotesFormBuilderQuestionsJSON');
                let formBuilderAnswersCellRef         = addCellValRefsMap.get('svcNotesFormBuilderAnswersJSON');
                let patientGoalProgressCellRef        = addCellValRefsMap.get('patientGoalProgressJSON');
                let hasPatientGoalTrackingDataCellRef = addCellValRefsMap.get('hasPatientGoalTrackingData');                
                
                let $rowRef = $(newRow)[0];
                let clientidCellRef                   = $($rowRef).find('input[' + CONST_FIELD_NAME + '="' + PARM_NAME_CLIENT_ID + '"]');
                let pracidCellRef                     = $($rowRef).find('input[' + CONST_FIELD_NAME + '="' + PARM_NAME_PRAC_ID + '"]');
                let groupidCellRef                    = $($rowRef).find('input[' + CONST_FIELD_NAME + '="' + CONST_ATTR_GROUP_ID + '"]');
                let patidCellRef                      = $($rowRef).find('input[' + CONST_FIELD_NAME + '="' + PARM_NAME_PAT_ID + '"]');
                let dosCellRef                        = $($rowRef).find('input[' + CONST_FIELD_NAME + '="dos"]');                
                let hasSessionRatingTrackingCellRef   = addCellValRefsMap.get('hasSessionRatingTracking');
                let svcNameCellRef                    = $($rowRef).find('input[' + CONST_FIELD_NAME + '="nameid"]');
                let startTimeCellRef                  = $($rowRef).find('input[' + CONST_FIELD_NAME + '="startTime"]');
                let numMinsCellRef                    = $($rowRef).find('input[' + CONST_FIELD_NAME + '="numMins"]');
                let $svcNameListDataSourceID          = $($rowRef).find('select[' + CONST_FIELD_NAME + '="svcnameslistdatasourceid"]');
                let hasFillablePDFSelectionsCellRef   = addCellValRefsMap.get('hasFillablePdfSelections');
                let fillablePDFSelectionsJSONCellRef  = addCellValRefsMap.get('fillablePdfSelectionsJSON');
                let fillablePDFAnswersJSONCellRef     = addCellValRefsMap.get('fillablePdfAnswersJSON');

                /* Create callback function for note library additional content div */
                
                let fnRenderNoteLibAddContent = function ($div) {
                    $($div).html('');

                    renderFormInDiv($div
                        , '' + $(formBuilderQuestionsCellRef).val()
                        , '' + $(formBuilderAnswersCellRef).val()
                        , '' + $(clientidCellRef).val()
                        , '' + $(patidCellRef).val()
                        , '' + $(groupidCellRef).val()
                        , function (fbNoteAnswersJSON) {
                            let $iconHasFbNotes = $($rowRef).data(CONST_ELEM_REF_ICON_FB_HAS_NOTES);
                            $($iconHasFbNotes).removeClass(CSS_CLASS_HIDDEN);
                            $(formBuilderAnswersCellRef).val(fbNoteAnswersJSON).trigger('change');
                        });

                };

                /* fnRenderNoteLibAddContent */


           $(newCellValueElem).wrap('<fieldset class="mba-rest-view-fieldset"></fieldset>');
           let $newCellValueParent = $(newCellValueElem).parent();
           let $iconHasFbNotes = $('<i class="fas fa-check-square" title="Details or patient goals were entered in My Note Library"></i>');
           $($iconHasFbNotes).addClass(CSS_CLASS_HIDDEN);
           $($newCellValueParent).append($iconHasFbNotes);

           /* If there are form builder answers already entered (this would happen if we were reloading WIP) show icon */

           if ($(formBuilderAnswersCellRef).val() != '{}') {           
             $($iconHasFbNotes).removeClass(CSS_CLASS_HIDDEN);
           }

           /* If there are goals entered (this would happen if we were reloading WIP) show icon */

           let pgpVal = $(patientGoalProgressCellRef).val();
           if ((pgpVal != '[]') && (pgpVal != '{}')) $($iconHasFbNotes).removeClass(CSS_CLASS_HIDDEN);
                       
           /* Save reference for later use */

           $($rowRef).data(CONST_ELEM_REF_ICON_FB_HAS_NOTES, $iconHasFbNotes);

           $(newCellValueElem).notelibrary({
                    displayMode: ''
                    , sel_tmp_enabled: true
                    , useMenu: true
                    , showPreview : true
                    , notefornamespacefn: function () { return 'service_records'; }
                    , noteforsourcefn: function () { return 'record_single_or_multiple'; }
                    , noteforclientidfn: function () { return '' + $(clientidCellRef).val(); }
                    , noteforpracidfn: function () { return '' + $(pracidCellRef).val(); }
                    , noteforpatidfn: function () { return '' + $(patidCellRef).val(); }
                    , noteforrefdatefn: function () { return '' + $(dosCellRef).val(); }
                    , noteforgroupidfn: function () { return '' + $(groupidCellRef).val(); }
                    , noteforstarttimefn: function () { return '' + $(startTimeCellRef).val(); }
                    , notefornumminsfn: function () { return '' + $(numMinsCellRef).val(); }
                    , noteforsvcnamelistdatasourceidfn: function () { return '' + $($svcNameListDataSourceID).val(); }
                    , noteforsvcnamefn: function () { return '' + $(svcNameCellRef).val();}
                    , noteforgrpsvcclassnameidfn: function () { return '' + $('#groupSvcClassNameID').val();}
                    , tkn: '<%=this.rd.wu.usr.token%>'
                    , additionalcontentfn: (fnRenderNoteLibAddContent)
                    , fillable_pdf_selections_enabled: true
                    , fnNoteHasFillablePdfSelections: function () {
                        return MBA.ComponentCommon.fnFlagValueToTrueFalse($(hasFillablePDFSelectionsCellRef).val());
                     }
                    , fnNoteSetFillablePdfSelectionsJSON: function () {
                        return $(fillablePDFSelectionsJSONCellRef).val();
                    }
                    , fnNoteSetFillablePdfAnswersJSON: function () {
                        return $(fillablePDFAnswersJSONCellRef).val();                        
                     }
                    , fnNoteGetFillablePdfAnswersJSON: function (fillablePdfAnswersJSON) {                      
                      $(fillablePDFAnswersJSONCellRef).val(fillablePdfAnswersJSON).trigger('change');
                    }
                   , noteforhaspatientgoaltrackingfn: function () {
                        return MBA.ComponentCommon.fnFlagValueToTrueFalse($(hasPatientGoalTrackingDataCellRef).val());               
                    }
                    , noteforsetpatientgoaltrackingjsonfn: function () {
                        return ($(patientGoalProgressCellRef).val()) ? $(patientGoalProgressCellRef).val() : null;
                    }
                    , noteforgetpatientgoaltrackingjsonfn: function (goalTrackingJSON) {
                   if ((goalTrackingJSON) != '[]') {
                       let $iconHasFbNotes = $($rowRef).data(CONST_ELEM_REF_ICON_FB_HAS_NOTES);
                       $($iconHasFbNotes).removeClass(CSS_CLASS_HIDDEN);
                   } 
                   $(patientGoalProgressCellRef).val(goalTrackingJSON).trigger('change');                    
                    return;
                  }
                  , noteforhassessionratingtrackingfn: function () {                   
                     return MBA.ComponentCommon.fnFlagValueToTrueFalse($(hasSessionRatingTrackingCellRef).val());
                  }
                  , url_view_all_patient_goals_progress: '<%=urlViewAllPatientGoalsProgress%>'
                  , export_note_data_enabled: true
                  , url_export_note_data:'<%=Spedmon.NoteLibrarySavedNotes.URL_EXPORT_NOTE_BASE()%>'
                  , exportnotedatapopulateformparmsfn: function ($form, objNoteExportCommonData) {

                    let $exportNoteDataInpClientID = $('<input name="<%=Constants.PARM_CLIENT_ID%>" type="hidden"></input>');
                    let $exportNoteDataInpPracID = $('<input name="<%=Constants.PARM_PRACTITIONER_ID%>" type="hidden"></input>');
                    let $exportNoteDataInpPatID = $('<input name="<%=Constants.PARM_PATIENT_ID%>" type="hidden"></input>');
                    let $exportNoteDataTaFBQ = $('<textarea name="<%=Constants.PARM_SVC_NOTES_FB_QUESTIONS%>"></textarea>');
                    let $exportNoteDataTaFBA = $('<textarea name="<%=Constants.PARM_SVC_NOTES_FB_ANSWERS%>"></textarea>');
                    let $exportNoteDataInpRefDate  = $('<input name="<%=Constants.PARM_REF_DATE%>" type="hidden"></input>');
                    let $exportNoteDataInpSvcName  = $('<input name="<%=Constants.PARM_SVC_NAME%>" type="hidden"></input>');
                    let $exportNoteDataTaNotes     = $('<textarea name="<%=Constants.PARM_NOTES%>"></textarea>');
                    let $exportNoteDataInpHasPatGoalTrackData = $('<input name="<%=Constants.PARM_HAS_PAT_GOAL_TRACKING_DATA%>" type="hidden"></input>');
                    let $exportNoteDataPatGoalProg = $('<textarea name="<%=Constants.PARM_PAT_GOAL_PROGRESS%>"></textarea>');

                    $($exportNoteDataInpClientID).val(objNoteExportCommonData.fnNoteForClientID());
                    $($exportNoteDataInpPracID).val(objNoteExportCommonData.fnNoteForPracID());
                    $($exportNoteDataInpPatID).val(objNoteExportCommonData.fnNoteForPatID());
                    $($exportNoteDataTaFBQ).val($(formBuilderQuestionsCellRef).val());
                    $($exportNoteDataTaFBA).val($(formBuilderAnswersCellRef).val());
                    $($exportNoteDataInpRefDate).val(objNoteExportCommonData.fnNoteForRefDate());
                    $($exportNoteDataInpSvcName).val(objNoteExportCommonData.fnNoteForSvcName());
                    let addNoteVal = $('#' + objNoteExportCommonData.fnOriginalNoteID()).val();

                    $($exportNoteDataTaNotes).val(addNoteVal);
                    $($exportNoteDataInpHasPatGoalTrackData).val(objNoteExportCommonData.fnNoteHasPatGoalTracking());
                    $($exportNoteDataPatGoalProg).val(objNoteExportCommonData.fnNoteGetPatGoalTrackingData());

                    $($form).append($exportNoteDataInpClientID);
                    $($form).append($exportNoteDataInpPracID);
                    $($form).append($exportNoteDataInpPatID);
                    $($form).append($exportNoteDataTaFBQ);
                    $($form).append($exportNoteDataTaFBA);
                    $($form).append($exportNoteDataTaNotes);
                    $($form).append($exportNoteDataInpRefDate);
                    $($form).append($exportNoteDataInpSvcName);
                    $($form).append($exportNoteDataInpHasPatGoalTrackData);
                    $($form).append($exportNoteDataPatGoalProg);
                }
                });         
                
                <%}%>

        }

        return newCell;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function showOrHideServiceDetails(hasSvcDetails, dsDetailsRef, openDetails) {

        if (hasSvcDetails === 'true') {
            $(dsDetailsRef).show();
        }
        else if (hasSvcDetails === 'false') {
            $(dsDetailsRef).hide();
        }
        else {
            $(dsDetailsRef).hide();
        }

        if (openDetails === true) {
            $(dsDetailsRef).attr('open', true).prop('open', true);
        }
        else {
            $(dsDetailsRef).attr('open', false).prop('open', false);
        }
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function clearServiceDetails(mapReference) {
        /* Note: mapReference is either svcDetailsRefObj.addCellValRefsMap or uiActionObj.saveableFieldsMap */
        $(mapReference.get('hasSvcDetFlags')).val('').attr('value', '');
        $(mapReference.get('svcDetFlag1')).MBA_input_radio('clearValue');
        $(mapReference.get('svcDetFlag2')).MBA_input_radio('clearValue');
        $(mapReference.get('svcDetFlag3')).MBA_input_radio('clearValue');
        $(mapReference.get('svcDetFlag4')).MBA_input_radio('clearValue');
        
        $(mapReference.get('hasOrpSel')).val('').attr('value', '');
        $(mapReference.get('orpDocumentID')).val('').attr('value', '');
        $(mapReference.get('orpDocumentName')).val('').attr('value', '');        
        $(mapReference.get('orpDocumentID')).siblings('span.ui-spedmon-box-container').find('input').val('');

        $(mapReference.get('svcTypeId')).val('').attr('value', '');
        $(mapReference.get('svcSubType1Id')).val('').attr('value', '');

        let $rowRef = $(mapReference.get('hasSvcDetFlags')).parents('tr');
        initServiceEntryNotificationsArr($rowRef);
        
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function clearServiceSelection(uiActionObj) {            
      clearServiceDetails(uiActionObj.saveableFieldsMap);  
      let _svcSel = uiActionObj.saveableFieldsMap.get(CONST_ATTR_SVC_NAME_ID);
      $(_svcSel).attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE, '').val('').attr('value', '');
      let flagDetails = $(uiActionObj.whatRow).find('td[' + CONST_FIELD_NAME + '="' + CONST_ATTR_SVC_NAME_ID +'"]').find('details.service-details-flags');
      let orpDetails = $(uiActionObj.whatRow).find('td[' + CONST_FIELD_NAME + '="' + CONST_ATTR_SVC_NAME_ID +'"]').find('details.service-details-orp');
      showOrHideServiceDetails('false', $(flagDetails), false);
      showOrHideServiceDetails('false', $(orpDetails), false);
      $(_svcSel).trigger('change');           
      return uiActionObj;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function handleChangeInServicePlan(uiActionObj) {
        if (uiActionObj.e.type === 'change') {
            return clearServiceSelection(uiActionObj);
        };
        return uiActionObj;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function handleChangeInServiceModality (uiActionObj) {
        if (uiActionObj.e.type === 'change') {

            /* Get service selection data.  Label does not change.  NameID may change. */

            let _svcSelInp       = uiActionObj.saveableFieldsMap.get(CONST_ATTR_SVC_NAME_ID); 
            let _altModNameIdInp = uiActionObj.saveableFieldsMap.get(CONST_ATTR_ALT_MODALALITY_NAME_ID);
            let _nameIDValOld    = $(_svcSelInp).attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE);  /* id is in data-attribute */
            let _nameIDValNew    = $(_altModNameIdInp).val();
            $(_svcSelInp).attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE, _nameIDValNew);            
            $(_altModNameIdInp).val(_nameIDValOld);
            $(_altModNameIdInp).trigger('change'); /*Updates hidden text area */
        };
        return uiActionObj;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function loadSessionTypesForCopy($select, $planType, $viaTelehealth) {

        let svcNamesListDataSourceID = $($planType).val();
        // remove all options from the service type dropdown
        $select.children('option').remove();

        // append default unselected value
        $select.append(
            '<option disabled value selected > -- select an option -- </option>'
        );

        let reqUrl = "services.asmx/viewSelTmtTcmTrans?tkn=" + $.spedmonWebUI.token;
        // svcnameslistdatasourceid
        let reqData = JSON.stringify({
            "clientid": $('#' + PARM_NAME_CLIENT_ID).val()
            , "pracid": $('#' + PARM_NAME_PRAC_ID).val()
            , "dos": '<%=dos%>'
            , "svcnameslistdatasourceid": svcNamesListDataSourceID
            , "term": ""
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                let isViaTeleHealth = $($viaTelehealth).prop("checked");                
                
                // get the returned services
                services = responseData.rawData.SelRecs;
                if (services) {
                    $.each(services, function (idx, serviceObj) {
                        if (isViaTeleHealth) {
                            if (serviceObj.recData5.includes("TELEHEALTH")) {
                                serviceObj.label = serviceObj.label.replace("(via TeleHealth)", "").replace("(via Telehealth)", "");

                                $select.append(
                                    '<option value="' + serviceObj.recData4 + '">' + serviceObj.label + '</option>'
                                );
                            }
                        }
                        else {
                            if (serviceObj.recData5.includes("IN_PERSON")) {
                                serviceObj.label = serviceObj.label.replace("(In Person)", "");

                                $select.append(
                                    '<option value="' + serviceObj.recData4 + '">' + serviceObj.label + '</option>'
                                );
                            }
                        }
                    });
                }
            })
            .catch(responseData => {

            });

        return;
    }
   
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function getClientPracPatDosDataFromRow($row) {

        let ccpdDataOutObj = {};

        let $clientID = $($row).find('input[' + CONST_FIELD_NAME + '="' + PARM_NAME_CLIENT_ID + '"]');
        let $pracID   = $($row).find('input[' + CONST_FIELD_NAME + '="' + PARM_NAME_PRAC_ID   + '"]');
        let $patID    = $($row).find('input[' + CONST_FIELD_NAME + '="' + PARM_NAME_PAT_ID    + '"]');
        let $dos      = $($row).find('input[' + CONST_FIELD_NAME + '="' + PARM_NAME_DOS       + '"]');

        let cppdObj = {};

        cppdObj[PARM_NAME_CLIENT_ID] = $($clientID).val();
        cppdObj[PARM_NAME_PRAC_ID]   = $($pracID).val();
        cppdObj[PARM_NAME_PAT_ID]    = $($patID).val();
        cppdObj[PARM_NAME_DOS] = $($dos).val();

        ccpdDataOutObj.dataObj = cppdObj;
        ccpdDataOutObj.nameValuesObj = MBA.ComponentCommon.fnObjToNameValuesObj(cppdObj);

        return ccpdDataOutObj;
    }
 
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function checkPatOrdersForExpiration($row, expirationState) {

        removeNotification($row, _notificationTypeOrderExpiration);
        removeNotification($row, _notificationTypeNoOrdersForDos);
        expirationState = '' + expirationState;
        if ((expirationState == '2') || (expirationState == '3') || (expirationState == '0')) {           
            let _notificationMsg = buildNotificationMessage($row, _notificationMsgOrderExpiration, 'Manage Orders and Prescriptions', '<%=urlOrdersPrescriptionsManage%>');
            addNotification($row, _notificationMsg, _notificationTypeOrderExpiration);
        }
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function checkPatOrdersForDos($row) {

        let ccpdDataObj = getClientPracPatDosDataFromRow($row);

        /* remove any old notifications */

        removeNotification($row, _notificationTypeNoOrdersForDos);
        removeNotification($row, _notificationTypeOrderExpiration);

        let reqUrl = "orp_documents.asmx/viewSelPatOrdersForDos?tkn=" + $.spedmonWebUI.token;

        ccpdDataObj.dataObj['recid'] = null;
        let reqData = JSON.stringify(ccpdDataObj.dataObj);


        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                /* If there are no orders */

                if (!responseData.rawData.SelRecs) {

                    /* remove any old notifications */

                    removeNotification($row, _notificationTypeNoOrdersForDos);
                    removeNotification($row, _notificationTypeOrderExpiration);

                    /* Let user know */

                    let _notificationMsg = buildNotificationMessage($row, _notificationMsgNoOrdersForDos, 'Manage Orders and Prescriptions', '<%=urlOrdersPrescriptionsManage%>');
                    addNotification($row, _notificationMsg, _notificationTypeNoOrdersForDos);
                }

                /* Check for expiration if order is auto selected. Otherwise it gets checked when user chooses an order */

                else {
                    
                    let isAutoSelect = $($row).find('input[' + CONST_FIELD_NAME + '="orpDocSelectionAuto"]').val();                   
                    if (isAutoSelect == 'true')
                    {
                        $.each(responseData.rawData.SelRecs, function (idx, obj) {                            
                            checkPatOrdersForExpiration($row, obj.recData4);
                        });
                    }
                }
            })
            .catch(responseData => {
        
            });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    function initDataGrid() {

        <%//#########################################%>
        <%//# Basics  %>
        <%//#########################################%>

        let opts = {};

        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = false;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = true;
        opts.saveModeAddNew = 'inlineunlockedfields';
        opts.enableRowControlRecEdit = false;
        opts.saveModeEdit = 'inline';
        opts.enableRowControlDeleteAll = true;
        opts.enableRowControlRecDelete = true;
        opts.saveModeDelete = 'inlineunlockedfields';
        opts.jsonInputHtml  = '<textarea id="<%=Constants.PARM_SVC_REC_FOR_DOS_JSON%>" name="<%=Constants.PARM_SVC_REC_FOR_DOS_JSON%>" class="d-none" ></textarea>';
        opts.hasCopyForAll = true;
        opts.enableRowControlRecClone = true;
        opts.saveModeClone = 'inlineunlockedfields';
        opts.fieldDefinitions = [];
        opts.fnSaveDataAfter = function (dataAsMap, dataAsArr, dataAsJSON, okToWorkWithData) { return; };

        opts.fnModifyRowDataBeforeAddNew = fnModifyRowDataBeforeAddNew;
        
       <%//#########################################%>
       <%//# Define creation complete handler       %>
       <%//#########################################%>

        opts.fnCreateComplete = function () {

            /*we hide the dataGrid plus icon and instead use a custom cntrol*/

            $(DATAGRID_PLUS_ICON_IDENTIFIER).hide();
            $(DATAGRID_PLUS_ICON_IDENTIFIER).parents('button').css('pointer-events', 'none');

            <%if (    (svcetrmdeInt == Spedmon.Constants.SVCETRMDE_RECORD_MISSING_ASSMTS_ALL_PATS)
                   || (svcetrmdeInt == Spedmon.Constants.SVCETRMDE_RECORD_MISSING_ASSMTS_CASELOAD_ONLY)
            ){%>
            /* hide copy for all feature */
            let dataObj = MBA.DataGridCommon.fnGetDataObj($SVC_RECS_DATAGRID);

            $(dataObj.copyForAllColumns).hide();
            $(dataObj.copyForAllIconColumns).hide();
            <%}%>            

            if (hasRecsToPreload == 1) {
                let rowsDataIn = <%=expectedSvcRecsJSON%>;
                $SVC_RECS_DATAGRID.MBA_DataGrid('preloadInlineUnlockedRows', rowsDataIn);
                $('#recs-to-preload-loading-msg').hide();
            }

            let wipSpOpts = {};
            wipSpOpts.fieldNamesToIgnore = [];
            wipSpOpts.fieldNamesToIgnore.push('<%=Constants.PARM_SAVE_TYPE%>');
            wipSpOpts.fieldNamesToIgnore.push('<%=Constants.PARM_REC_ID%>');
            wipSpOpts.fieldNamesToIgnore.push('<%=Constants.PARM_VALIDATE_REC%>');
            wipSpOpts.fieldNamesToIgnore.push('<%=Constants.PARM_EDIT_DEL_REASON%>');
            wipSpOpts.fieldNamesToIgnore.push('<%=Constants.PARM_EDIT_DEL_MANAGE_LINK%>');

            wipSpOpts.fnIsFormEmpty = function (formDataObj) {
                let srEntries = formDataObj.<%=Constants.PARM_SVC_REC_FOR_DOS_JSON%>;
                if (srEntries == '[]') return true;
                return false;                
            };

            MBA.WorkInProgressSavePoints.fnInit('<%=Constants.PARM_SAVE_FORM%>', wipSpOpts);
            if (hasWipData == 1) $('#wip-data-msg').show();

        };

        <%//#########################################%>
        <%//# Field Definitions %>
        <%//#########################################%>

        <%//-----------------------------------------------------------------------------%>
        <%// Practitioner Name %>
        <%//-----------------------------------------------------------------------------%>

        <%if (isPrac == false) {%>
        opts.fieldDefinitions.push({
              name: 'pracName'
            , label: 'Practitioner<br>Last, First'
            , toolTip:'Practitioner who rendered the service'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: ''
            , saveUsing: 'pracName'
            , showMore: false
        });
        <%}else{%> 
          opts.fieldDefinitions.push({
            name: 'pracName'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'pracName'
            , showMore: false
        });
        <%}%>

        <%//-----------------------------------------------------------------------------%>
        <%// Caseload Grp ID %>
        <%//-----------------------------------------------------------------------------%>
        opts.fieldDefinitions.push({
            name: 'caseloadGrpId'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'caseloadGrpId'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Patient Name %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'patName'
            , label: 'Student<br>Last, First'
            , toolTip: 'Student (Patient) who received the service'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'patName'
            , saveUsing: 'patName'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Date of Service %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'dos'
            , label: 'Date<br />of<br />Service'
            , toolTip: 'Date of Service'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , saveUsing: 'dos'
            , sortUsing: 'dos'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Via Telehealth %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'viatelehealth'
            , label: 'Via<br>Tele<br>health'
            , toolTip: 'Via Telehealth'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'checkbox'
            , saveUsing: 'viatelehealth'
            , sortUsing: ''
            , showMore: false
            , handlerFn: function (uiActionObj) {
                return handleChangeInServiceModality (uiActionObj);
            }
            , styleAttrValueForCellValue: 'width:2em'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Plan Selection %>
        <%// Note: This was isiep.  It is now svcnameslistdatasourceid %>
        <%//-----------------------------------------------------------------------------%>

        let planTypeFieldOptions = {};
        
        planTypeFieldOptions.selections = <%=serviceNamesListDataSourcesJSON%>;

          
        opts.fieldDefinitions.push({
              name: 'svcnameslistdatasourceid'
            , label: 'Plan Type'
            , toolTip: 'The written plan that services were provided under'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: planTypeFieldOptions
            , sortUsing: 'svcnameslistdatasourceid'
            , saveUsing: 'svcnameslistdatasourceid'
            , showMore: false
            , handlerFn: function (uiActionObj) {
                return handleChangeInServicePlan(uiActionObj);
            }
            , styleAttrValueForCellValue:'width:6em'
        });


        <%//-----------------------------------------------------------------------------%>
        <%// Service Name (hidden... used by service selection) %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
             name: 'svcName'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcName'
            , showMore: false
        });

       <%//-----------------------------------------------------------------------------%>
       <%// altModalityNameID (hidden... used by service selection) %>
       <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
              name:'altModalityNameID'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing:'altModalityNameID'
            , showMore: false
        })

        <%//-----------------------------------------------------------------------------%>
        <%// Service Selection  %>
        <%//-----------------------------------------------------------------------------%>

        
        let nameIDAdditionalCellValueFieldDefinitions = [];
         
        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'hasSvcDetFlags'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'hasSvcDetFlags'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'hasOrpSel'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'hasOrpSel'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'orpDocSelectionAuto'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'orpDocSelectionAuto'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcDetFlag1'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcDetFlag1'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcDetFlag2'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcDetFlag2'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcDetFlag3'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcDetFlag3'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcDetFlag4'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcDetFlag4'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'orpDocumentID'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'orpDocumentID'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'orpDocumentName'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'orpDocumentName'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcclientid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcclientid'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcpracid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcpracid'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcpatid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcpatid'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcTypeId'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcTypeId'
            , showMore: false
        });

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'svcSubType1Id'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'svcSubType1Id'
            , showMore: false
        });

        <%/* Setup autocomplete - Basics */%>

        let nameIdOpts                        = {};
        nameIdOpts.asyncReq                   = true;
        nameIdOpts.baseUrl                    = '<%=Spedmon.Services.URL_VIEW_SEL2_BASE()%>';
        nameIdOpts.loadMode                   = 'mbaviewsel';
        nameIdOpts.getInitialSelectedNameFrom = 'svcName'

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        nameIdOpts.doNotTriggerChangeEventOnSelect = true;
        nameIdOpts.fnOnSelect = function (event, ui) {

            let $svcSel = $(event.target)[0];
            let svcDetailsRefObj = $($svcSel).data(CONST_SVC_DETAILS_REF);
            clearServiceDetails(svcDetailsRefObj.addCellValRefsMap);

            /* Assessement */

            if (ui.item.flag1 == 1) {            
                $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('false');
                $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpSel')).val('false');

                if (ui.item.showOptions2 === 'SHOW_SPEECH_ASSESS_OPTIONS') {
                  svcDetailsRefObj.hasSvcDetails = 'true';
                  $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('true');
                  showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsFlags, true);
                }
                else {
                  svcDetailsRefObj.hasSvcDetails = 'false';
                  $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
                  showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsFlags, false);
                }

            }

            /* Treatment */

            else if (ui.item.flag1 == 2)
            {
                /* If orp document is required for this treatment (billing program requirement)*/
                
                if (ui.item.recData14 == '1')
                {
                    /* If the order selection would normally be shown and autoselection is not possible */

                    if ((ui.item.showOptions2 === 'SHOW_TREATMENT_ORP_DOC_SELECTION') && (ui.item.recData3 == 0)) {
                        svcDetailsRefObj.hasSvcDetails = 'true';
                        $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpSel')).val('true');
                        $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
                        $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('false');
                        showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsOrpSel, true);
                    }
                    else {
                        svcDetailsRefObj.hasSvcDetails = 'false';
                        $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpSel')).val('true');
                        $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
                        $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('true');
                        showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsOrpSel, false);
                    }
                }

                /* If orp document is not required for this treatment (billing program requirement)*/

                else {

                    svcDetailsRefObj.hasSvcDetails = 'false';
                    $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
                    $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpSel')).val('false');
                    $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('false');
                    showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsFlags, false);
                    showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsOrpSel, false);
                }
            }
            /* Other service */
            else {
                svcDetailsRefObj.hasSvcDetails = 'false';
                $(svcDetailsRefObj.addCellValRefsMap.get('hasSvcDetFlags')).val('false');
                $(svcDetailsRefObj.addCellValRefsMap.get('hasOrpSel')).val('false');
                $(svcDetailsRefObj.addCellValRefsMap.get('orpDocSelectionAuto')).val('false');
                showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsFlags, false);
                showOrHideServiceDetails(svcDetailsRefObj.hasSvcDetails, svcDetailsRefObj.dsDetailsOrpSel, false);
            }

            $($svcSel).data(CONST_SVC_DETAILS_REF, svcDetailsRefObj);            
            
            // save service name
            let $svcNameTd = $($svcSel).parents('td').siblings('td[' + CONST_FIELD_NAME + '="' + CONST_ATTR_SVC_NAME + '"]');
            let $svcNameInput = $($svcNameTd).find('input[' + CONST_FIELD_NAME + '="' + CONST_ATTR_SVC_NAME + '"]');
            $($svcNameInput).val(ui.item.label);

            // save alt modality nameid

            let $svcAltModNameIdTd = $($svcSel).parents('td').siblings('td[' + CONST_FIELD_NAME + '="' + CONST_ATTR_ALT_MODALALITY_NAME_ID + '"]');
            let $svcAltModNameIdInput = $($svcAltModNameIdTd).find('input[' + CONST_FIELD_NAME + '="' + CONST_ATTR_ALT_MODALALITY_NAME_ID + '"]');
            $($svcAltModNameIdInput).val(ui.item.recData13);

            // send ajax to get form data and patient goal tracking

            let planTypeSel = $(svcDetailsRefObj.rowRef).find('select[' + CONST_FIELD_NAME + '="svcnameslistdatasourceid"]');
            let planTypeSelVal = $(planTypeSel).val();

            /* Convert svc name data source id to equiv plan type */

            let planTypeID = '100';
            if      (planTypeSelVal == '100') { planTypeID = '2'; }
            else if (planTypeSelVal == '200') { planTypeID = '3'; }
            else if (planTypeSelVal == '300') { planTypeID = '4'; }
            else if (planTypeSelVal == '400') { planTypeID = '5'; }
            else { planTypeSelVal = '100'; }
                        
            let groupid = $(svcDetailsRefObj.rowRef).find('input[' + CONST_FIELD_NAME + '="' + CONST_ATTR_GROUP_ID + '"]').val();

            let reqUrl  = "claim_service_name_xref_and_form_data_records.asmx/loadN?tkn=" + $.spedmonWebUI.token;
            let reqData = JSON.stringify({
                "clientid": svcDetailsRefObj.addCellValRefsMap.get('svcclientid').val()
                , "plantypeid": planTypeID
                , "groupid": groupid
                , "nameid": '' + ui.item.id
            });

            <%if (isPrac == true) { %>
              let $butNoteLib = $(svcDetailsRefObj.rowRef).find('button.mba-notelibrary-nte-opts-but-opn')[0];
              let $butNoteLibWaitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner($butNoteLib);
              let $iconHasFbNotes = $(svcDetailsRefObj.rowRef).data(CONST_ELEM_REF_ICON_FB_HAS_NOTES);
              $($iconHasFbNotes).addClass(CSS_CLASS_HIDDEN);
            <%}%>

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                .then(responseData => {
                    let $questionsJSONTA = $(svcDetailsRefObj.rowRef).find('textarea[' + CONST_FIELD_NAME + '="svcNotesFormBuilderQuestionsJSON"]');
                    let $answersJSONTA = $(svcDetailsRefObj.rowRef).find('textarea[' + CONST_FIELD_NAME + '="svcNotesFormBuilderAnswersJSON"]');

                    $($answersJSONTA).val('{}'); // default val

                    if (responseData.rawData.entity.hasFormData) {
                        $($questionsJSONTA).val(responseData.rawData.entity.formDataJson);
                    }
                    else {
                        $($questionsJSONTA).val('{}');
                    }

                    // goal tracking

                    let $hasGoalInput = $(svcDetailsRefObj.rowRef).find('input[' + CONST_FIELD_NAME + '="hasPatientGoalTrackingData"]');
                    let $hasSessionRatingTrackingInput = $(svcDetailsRefObj.rowRef).find('input[' + CONST_FIELD_NAME + '="hasSessionRatingTracking"]');
                    let $goalsJSONTA = $(svcDetailsRefObj.rowRef).find('textarea[' + CONST_FIELD_NAME + '="patientGoalProgressJSON"]');
                    $($hasGoalInput).val(responseData.rawData.entity.hasPatientGoalTracking);
                    $($hasSessionRatingTrackingInput).val(responseData.rawData.entity.hasSessionRatingTracking);
                    $($goalsJSONTA).val('[]');                    

                    // Fillable pdfs
                    
                    let $hasFillablePDFSelections  = $(svcDetailsRefObj.rowRef).find('input[' + CONST_FIELD_NAME + '="hasFillablePdfSelections"]');
                    let $fillablePDFSelectionsJSON = $(svcDetailsRefObj.rowRef).find('textarea[' + CONST_FIELD_NAME + '="fillablePdfSelectionsJSON"]');
                    let $fillablePDFAnswersJSON    = $(svcDetailsRefObj.rowRef).find('textarea[' + CONST_FIELD_NAME + '="fillablePdfAnswersJSON"]');
                    
                    $($hasFillablePDFSelections).val(responseData.rawData.entity.hasFillablePdfSelections);
                    $($fillablePDFSelectionsJSON).val(responseData.rawData.entity.fillablePdfSelectionsJSON);
                    $($fillablePDFAnswersJSON).val('[]');

                    // svc type and subtype

                    $(svcDetailsRefObj.addCellValRefsMap.get('svcTypeId')).val(responseData.rawData.entity.svcTypeId);
                    $(svcDetailsRefObj.addCellValRefsMap.get('svcSubType1Id')).val(responseData.rawData.entity.svcSubType1Id).trigger('change');

                    <%if (isPrac == true) { %>
                      MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butNoteLib, $butNoteLibWaitingIcon);                    
                    <%}%>
                })
                .catch(responseData => {
                    <%if (isPrac == true) { %>
                      MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butNoteLib, $butNoteLibWaitingIcon);
                    <%}%>
                });

            // trigger change event to update map

            $($svcNameInput).trigger('change');

            // check for notifications
            if ($(svcDetailsRefObj.addCellValRefsMap.get('hasOrpSel')).val() == 'true') {
                checkPatOrdersForDos(svcDetailsRefObj.rowRef);
            }          
        };

        <%/* Setup autocomplete - Customization Hooks for Service Selection */%>

        nameIdOpts.fnOnOpen = function (event, ui, $acObj) {
            $($acObj).css('width', '40em');
            return;
        };

        nameIdOpts.fnModifyRequestNvps = function (nvpsIn) {                       
            /* Add required flag to control if only copy down compatible selections are shown*/
            nvpsIn.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_SHOW_ONLY_COPY_DOWN_SELECTIONS%>', 'N'));
            return nvpsIn;
        };
        nameIdOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
        nameIdOpts.fnModifyRenderItem = function ($ul, item, $li) {return $li;};
        nameIdOpts.fnHandleCellValueAction = function (uiActionObj)          { return uiActionObj;};

        <%/* Setup autocomplete - Custom copy for all logic */%>

        let nameIDCopyForAllOptions = {};

        nameIDCopyForAllOptions.fnRenderField = function () {
            let $inputField = $('<select></select>');
            return $inputField
        };

        nameIDCopyForAllOptions.fnAfterRender = function ($elem, dataObj) {
            let $thIepElem = $(dataObj.copyForAllColumns).find('th[' + CONST_FIELD_NAME + '="svcnameslistdatasourceid"]');
            let $iepElem = $($thIepElem).find('select');

            let $thTelehealthElem = $(dataObj.copyForAllColumns).find('th[' + CONST_FIELD_NAME + '="viatelehealth"]');
            let $telehealthElem = $($thTelehealthElem).find('input');

            loadSessionTypesForCopy($elem, $iepElem, $telehealthElem);

            // load new data every time a new practitioner is selected
            $('#' + PARM_NAME_PRAC_ID).on('spedmoninputdata', function (e) {
                loadSessionTypesForCopy($elem, $iepElem, $telehealthElem);
            });

            // load new data every time the via telehealth or plan type change
            $($iepElem).add($telehealthElem).on('change', function (e) {
                loadSessionTypesForCopy($elem, $iepElem, $telehealthElem);
            });
        };

        nameIDCopyForAllOptions.fnCustomCopyHandler = function ($inputCopyAll, colIdx, fieldName, dataObj) {
            let tbodyRows = $(dataObj.tbodyNew).find('tr');
            $.each(tbodyRows, function (idx, obj) {
                // grab the input field in the row
                let $tdCol = $(obj).find('td[data-mba-rest-view-col-idx=' + colIdx + ']');
                let $colInput = $($tdCol).find('input[' + CONST_FIELD_NAME + '=' + fieldName + ']');

                // skip if service already selected
                if ($colInput.val()) return true;

                // get value and text to be copied
                let $selectedOption = $($inputCopyAll).find('option:selected');
                let copyVal = $($selectedOption).val();
                let copyText = $($selectedOption).text();

                $($colInput).data("autocomplete").source({ "term": "" }, function (data) {                    
                    let matchedValue = data.find(elem => elem.id == copyVal);

                    // only copy the service if it is available for the row
                    if (matchedValue) {                        
                        $colInput.attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE, copyVal);
                        $colInput.val(copyText);

                        // save service name
                        let $svcNameTd = $($tdCol).siblings('td[' + CONST_FIELD_NAME + '="' + CONST_ATTR_SVC_NAME + '"]');
                        let $svcNameInput = $($svcNameTd).find('input[' + CONST_FIELD_NAME + '="' + CONST_ATTR_SVC_NAME + '"]');
                        $($svcNameInput).val(copyText).trigger('change');
                        
                        // trigger autocomplete select event to automatically load service details (if any)
                        $($colInput).data("autocomplete")._trigger('select', 'autocompleteselect', { item: matchedValue });
                    }
                });
            });
        };
    
        opts.fieldDefinitions.push({
            name: 'nameid'
            , label: 'Service Provided'
            , toolTip: 'The service that was provided'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , saveUsing: 'nameid'
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: nameIdOpts
            , sortUsing: 'svcName'
            , showMore: false
            , additionalCellValueFieldDefinitions: nameIDAdditionalCellValueFieldDefinitions
            , hasCustomCopyForAll: true
            , copyForAllOptions: nameIDCopyForAllOptions
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Client ID  %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'clientid'
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

        <%//-----------------------------------------------------------------------------%>
        <%// Practitioner ID  %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'pracid'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'pracid'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Group ID  %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'groupID'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'groupID'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Patient ID  %>
        <%//-----------------------------------------------------------------------------%>

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

        <%//-----------------------------------------------------------------------------%>
        <%// Start Time %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'startTime'
            , label: 'Start<br />Time'
            , toolTip: 'Start Time'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'time'
            , saveUsing: 'startTime'
            , sortUsing: 'startTime'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Minutes %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'numMins'
            , label: 'Session<br />Minutes'
            , toolTip: 'Session Minutes'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'number'
            , saveUsing: 'numMins'
            , sortUsing: 'numMins'
            , styleAttrValueForCellValue: 'width:4em'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Attendance Status %>
        <%//-----------------------------------------------------------------------------%>

        <%if (!isPcalStaff) {%>
          let attendanceStatusOptions = {};
          attendanceStatusOptions.selections = <%=attendanceSelectionsJSON%>;
          
          opts.fieldDefinitions.push({
              name: 'attendanceStatusSelectionID'
              , label: 'Attendance'
              , toolTip: 'The attendance status for the practitioner and patient'
              , visible: true
              , sortable: true
              , editable: true
              , saveable: true
              , sortUsing: 'attendanceStatusSelectionName'
              , saveUsing: 'attendanceStatusSelectionID'
              , isRecID: false
              , dataType: 'selectoption'
              , dataTypeOptions: attendanceStatusOptions
              , showMore: false
          });
        <%} else {%>
          opts.fieldDefinitions.push({
              name: 'attendanceStatusSelectionID'
              , visible: false
              , sortable: false
              , saveable: true
              , editable: false
              , isRecID: false
              , dataType: 'hidden'
              , sortUsing: ''
              , saveUsing: 'attendanceStatusSelectionID'
              , showMore: false
          });
        <%}%>

        <%//-----------------------------------------------------------------------------%>
        <%// Service Notes Form Builder Questions (Additional Cell in Service Notes)     %>
        <%// and Patient Goal Tracking                                                   %>
        <%//-----------------------------------------------------------------------------%>

        let notesAdditionalCellValueFieldDefinitions = [];

        notesAdditionalCellValueFieldDefinitions.push({
            name: 'svcNotesFormBuilderQuestionsJSON'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'jsondata'
            , sortUsing: ''
            , saveUsing: 'svcNotesFormBuilderQuestionsJSON'
            , showMore: false
        });

        notesAdditionalCellValueFieldDefinitions.push({
              name: 'svcNotesFormBuilderAnswersJSON'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'jsondata'
            , sortUsing: ''
            , saveUsing: 'svcNotesFormBuilderAnswersJSON'
            , showMore: false
        });
          
        notesAdditionalCellValueFieldDefinitions.push({
                name: 'patientGoalProgressJSON'
              , label: ''
              , toolTip: ''
              , visible: false
              , sortable: false
              , editable: true
              , saveable: true
              , isRecID: false
              , dataType: 'jsondata'
              , sortUsing: ''
              , saveUsing: 'patientGoalProgressJSON'
              , showMore: false
          });
          
          notesAdditionalCellValueFieldDefinitions.push({
            name: 'hasPatientGoalTrackingData'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'hasPatientGoalTrackingData'
            , showMore: false
         });

        notesAdditionalCellValueFieldDefinitions.push({
            name: 'hasSessionRatingTracking'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'hasSessionRatingTracking'
            , showMore: false
        });

        notesAdditionalCellValueFieldDefinitions.push({
            name: 'hasFillablePdfSelections'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'hasFillablePdfSelections'
            , showMore: false
        });

        notesAdditionalCellValueFieldDefinitions.push({
            name: 'fillablePdfSelectionsJSON'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'jsondata'
            , sortUsing: ''
            , saveUsing: 'fillablePdfSelectionsJSON'
            , showMore: false
        });

        notesAdditionalCellValueFieldDefinitions.push({
            name: 'fillablePdfAnswersJSON'
            , label: ''
            , toolTip: ''
            , visible: false
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'jsondata'
            , sortUsing: ''
            , saveUsing: 'fillablePdfAnswersJSON'
            , showMore: false
        });
        

         <%if (!isPcalStaff) {%>          
          
          <%//-----------------------------------------------------------------------------%>
          <%// Service Notes %>
          <%//-----------------------------------------------------------------------------%>
          
          opts.fieldDefinitions.push({
                name: 'notes'
              , label: 'Notes'
              , toolTip: 'Professional notes regarding this service'
              , visible: true
              , sortable: false
              , editable: true
              , saveable: true
              , isRecID: false
              , dataType: 'notes'
              , showMore: false
              , saveUsing: 'notes'
              , additionalCellValueFieldDefinitions: notesAdditionalCellValueFieldDefinitions
          });
        <%} else {%>
          opts.fieldDefinitions.push({
              name: 'notes'
              , visible: false
              , sortable: false
              , saveable: true
              , editable: false
              , isRecID: false
              , dataType: 'hidden'
              , sortUsing: ''
              , saveUsing: 'notes'
              , additionalCellValueFieldDefinitions: notesAdditionalCellValueFieldDefinitions
              , showMore: false
          });
        <%}%>

        opts.fieldDefinitions.push({
              name: 'createQuestionForm'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'createQuestionForm'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'RMTSMoment'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'RMTSMoment'
            , showMore: false
        });        
        
        opts.fieldDefinitions.push({
            name: 'expectedEntryContext'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'string'
            , sortUsing: ''
            , saveUsing: 'expectedEntryContext'
            , showMore: false
        });

        <%//#########################################%>
        <%//# Additional Header Controls %>
        <%//#########################################%>
        
        opts.additionalControlDefinitionsForHeadRows = new Map();

        <%//#########################################%>
        <%//# Additional Row Controls  %>
        <%//#########################################%>

        opts.additionalControlDefinitionsForBodyRows = new Map();

        <%if (isPcalStaff == true) {%>
        opts.additionalControlDefinitionsForBodyRows.set('setQuestionFormFlag', {
            defType: 'userprovided'
            , name: 'setQuestionFormFlag'
            , toolTip: 'Click here to create question forms'
            , cssClass: 'fas fa-question-circle'
            , handlerFn: function (uiActionObj) {
                let $row = uiActionObj.whatRow;
                let $qIcon = $(uiActionObj.whatElement).children('i.fa-question-circle')[0];
                
                /* Set new value */

                if ($($qIcon).hasClass(CSS_CLASS_ICON_TOGGLED)) {
                    $($row).find('input[' + CONST_FIELD_NAME + '="createQuestionForm"]').val('false').trigger('change');                    
                    $($qIcon).removeClass(CSS_CLASS_ICON_TOGGLED);
                    
                }
                else {                    
                    $($row).find('input[' + CONST_FIELD_NAME + '="createQuestionForm"]').val('true').trigger('change');                    
                    $($qIcon).addClass(CSS_CLASS_ICON_TOGGLED);
                }

                return uiActionObj;
            }
            , initiallyHidden: false
        });
        <%}%>

        <%//-----------------------------------------------------------------------------%>
        <%// Live Session %>
        <%//-----------------------------------------------------------------------------%>
        <%if (isPrac == true) { %>
        <%if (isAssessmentsOnlyMode == false) {%>
            opts.additionalControlDefinitionsForBodyRows.set('beginLiveGrpSession', {
                defType: 'userprovided'
                , name: 'beginLiveGrpSession'
                , toolTip: 'Click Here to Begin Live Session'
                , cssClass: 'fa fa-users text-success'
                , handlerFn: function (uiActionObj) {

                    let clickedGrpId = Number($(uiActionObj.whatRow).find('input[data-mba-rest-view-field-name="caseloadGrpId"]').val());

                    if (!clickedGrpId || isNaN(clickedGrpId) || clickedGrpId === 0) {
                        $.spedmonWebUI.dialogMessage('Live Session', "This row does not belong to a scheduled group.", null, 420, 200, null, null, null);
                        return uiActionObj;
                    }

                    // create dialog div for the live session to render inside 
                    let $liveSession = $('<div></div>');

                    // build array of patients objects according to live notes plug in that are selected for group therapy
                    let grpTherapyPatObjsArr = [];

                    /* If there are no rows in the grid get out */

                    if (uiActionObj.dataObj.dataMap.size == 0) {
                        $.spedmonWebUI.dialogMessage('Live Session', "Please select some patients.", null, 400, 200, null, null, null);
                        return uiActionObj;
                    }

                    uiActionObj.dataObj.dataMap.forEach(function (obj, idx) {
                        try {

                            let rowGrpId = (obj && obj.caseloadGrpId != null) ? Number(obj.caseloadGrpId) : 0;
                            if (rowGrpId !== clickedGrpId) return;

                            if ((obj.nameid) && (obj.dos)) {
                                grpTherapyPatObjsArr.push($.extend(true, {}, obj, {
                                    patID: obj.patid,
                                    associationKey: idx,
                                    urlViewAllPatientGoalsProgress: '<%=urlViewAllPatientGoalsProgress%>',
                                    showPreview: true,
                                    isNew: false,
                                    formBuilderQuestionsJSON: obj.svcNotesFormBuilderQuestionsJSON || '{}',
                                    formBuilderAnswersJSON: obj.svcNotesFormBuilderAnswersJSON || '{}',
                                    hasPatientGoalTracking: MBA.ComponentCommon.fnFlagValueToTrueFalse(obj.hasPatientGoalTrackingData),
                                    patientGoalProgressJSON: obj.patientGoalProgressJSON || '[]'
                                }));
                            }
                        } catch (error) {

                        }
                    });

                    /* if no patients with services */
                    if (grpTherapyPatObjsArr.length < 1) {
                        $.spedmonWebUI.dialogMessage('Live Session', "Please make sure all patients have a service selected and a date of service entered.", null, 400, 200, null, null, null);
                        return uiActionObj;
                    }
                
                    $liveSession.dialog(
                        {
                            width: $(window).width() / 1.5
                            , height: $(window).height()
                            , title: '<strong>Live Session</strong>'
                            , closeOnEscape: true
                            , modal: true
                            , show: {
                                effect: 'slide'
                                , direction: 'left'

                                // When dialog renders, call the live session plug-in to render live session
                                , complete: function () {

                                    $liveSession.parent().find('.ui-dialog-titlebar-close').html('×');

                                    // render live session
                                    $liveSession.liveSessionNotes({
                                        patObjsArr: grpTherapyPatObjsArr
                                        , patLoadURL: 'patients.asmx/viewEntity?tkn=' + $.spedmonWebUI.token
                                        , patLoadData: { 'clientid': $('#' + PARM_NAME_CLIENT_ID).val() }
                                        , serviceNamesListDataSources: <%=serviceNamesListDataSourcesJSON%>
                                        , clientid: $('#' + PARM_NAME_CLIENT_ID).val()
                                        , pracid: $('#' + PARM_NAME_PRAC_ID).val()
                                        , groupID: $('#' + CONST_ATTR_GROUP_ID).val()
                                        , fnSaveCallback: function (patNotesMap) {

                                            function _fnFindGridRowByAssocKey(key) {
                                                return $(uiActionObj.dataObj.tbodyNew)
                                                    .find('tr[data-mba-data-grid-data-map-key="' + key + '"]').first();
                                            }

                                            function _fnTagNewGridRow($newRow, assocKey, value) {
                                                if (!$newRow || !$newRow.length) return;
                                                $newRow.attr('data-mba-data-grid-data-map-key', assocKey);
                                            
                                                $newRow.find('input[' + CONST_FIELD_NAME + '="patid"]').val(value.patID);
                                            }

                                            function _fnUpdateGridRowFields($row, value) {
                                                if (!$row || !$row.length) return;

                                                function setIf(defVal, selector, opts) {
                                                    opts = opts || {};
                                                    if (defVal === undefined || defVal === null) return;

                                                    const $el = $row.find(selector);
                                                    if (!$el.length) return;

                                                    if (opts.isCheckbox) {
                                                        const currentVal = $el.prop('checked');
                                                        const newVal = (('' + defVal) === '1' || defVal === true);

                                                        if (currentVal === newVal) return;

                                                        $el.prop('checked', newVal).trigger('change');
                                                        return;
                                                    }

                                                    const currentVal = '' + ($el.val() || '');
                                                    const newVal = '' + defVal;

                                                    if (currentVal === newVal) return;

                                                    $el.val(defVal);

                                                    if ($el.is('textarea,input,select')) {
                                                        $el.trigger('input');
                                                    }
                                                    $el.trigger('change');
                                                }

                                                // notes / form builder / goals
                                                setIf(value.formBuilderQuestionsJSON, 'textarea[' + CONST_FIELD_NAME + '="svcNotesFormBuilderQuestionsJSON"]');
                                                setIf(value.formBuilderAnswersJSON, 'textarea[' + CONST_FIELD_NAME + '="svcNotesFormBuilderAnswersJSON"]');
                                                setIf(value.patientGoalProgressJSON, 'textarea[' + CONST_FIELD_NAME + '="patientGoalProgressJSON"]');
                                                setIf(value.notes, 'textarea[' + CONST_FIELD_NAME + '="notes"]');

                                                // service section
                                                setIf(value.startTime, 'input[' + CONST_FIELD_NAME + '="startTime"]');
                                                setIf(value.numMins, 'input[' + CONST_FIELD_NAME + '="numMins"]');

                                                // icon state
                                                var $icon = $($row).find('i.fas.fa-check-square').last();
                                                if (value.formBuilderAnswersJSON && value.formBuilderAnswersJSON != '{}') {
                                                    $($icon).removeClass(CSS_CLASS_HIDDEN);
                                                }

                                                let pgpVal = value.patientGoalProgressJSON;
                                                if ((pgpVal != '[]') && (pgpVal != '{}')) {
                                                    $($icon).removeClass(CSS_CLASS_HIDDEN);
                                                }
                                            }

                                            function _fnFindGridRowByPatIDAndDOS(patID, dos) {
                                                const $rows = $(uiActionObj.dataObj.tbodyNew).find('tr');

                                                return $rows.filter(function () {
                                                    const pid = $(this).find('input[' + CONST_FIELD_NAME + '="patid"]').val();
                                                    const rowDos = $(this).find('input[' + CONST_FIELD_NAME + '="dos"]').val();

                                                    return ('' + pid === '' + patID) && ('' + rowDos === '' + dos);
                                                }).first();
                                            }

                                            patNotesMap.forEach(function (value, key) {
                                                let $row = _fnFindGridRowByAssocKey(key);

                                                if (!$row.length) {
                                                    $row = _fnFindGridRowByPatIDAndDOS(value.patID, value.dos);
                                                }

                                                /* New patient added via live notes */
                                                if (value.isNew && !$row.length) {

                                                    $('#' + CONST_ATTR_PAT_NAME).val(value.patName);
                                                    $('#' + PARM_NAME_PAT_ID).val(value.patID);
                                                    var $objRow;

                                                    // handle multi date (if needed)
                                                    let dosMulti = $('#dossvcs').val();

                                                    if (dosMulti) {
                                                        let _dosArray = dosMulti.split(',');
                                                        _dosArray.sort();
                                                        _dosArray.reverse();

                                                        // for each date selected, modify the default date and add a row to dataGrid
                                                        $.each(_dosArray, function (_idx, _dosElemVal) {
                                                            $DOS_HIDDEN.val(_dosElemVal);
                                                            $objRow = addNewRow(value);
                                                            if ($objRow && $objRow.newRow) {
                                                                _fnTagNewGridRow($objRow.newRow, key, value); // NEW
                                                            }
                                                        });
                                                    }
                                                    else {
                                                        // if no date selected, we use the default value (set from the code behind)
                                                        $DOS_HIDDEN.val('<%=dos%>');
                                                        $objRow = addNewRow(value);
                                                        if ($objRow && $objRow.newRow) {
                                                            _fnTagNewGridRow($objRow.newRow, key, value); // NEW
                                                        }
                                                    }

                                                    var $icon = $objRow.newRow.find('i.fas.fa-check-square').last();
                                                    let planTypeSelVal = $objRow.newRow.find('select[' + CONST_FIELD_NAME + ' = "svcnameslistdatasourceid"]').val();
                                                    let planTypeID = '100';

                                                    if (planTypeSelVal == '100') { planTypeID = '2'; }
                                                    else if (planTypeSelVal == '200') { planTypeID = '3'; }
                                                    else if (planTypeSelVal == '300') { planTypeID = '4'; }
                                                    else if (planTypeSelVal == '400') { planTypeID = '5'; }
                                                    else { planTypeSelVal = '100'; }                                                    

                                                    $objRow.newRow.find('textarea[' + CONST_FIELD_NAME + '="svcNotesFormBuilderQuestionsJSON"]')
                                                        .val(value.formBuilderQuestionsJSON || '{}');

                                                    $objRow.newRow.find('textarea[' + CONST_FIELD_NAME + '="svcNotesFormBuilderAnswersJSON"]')
                                                        .val(value.formBuilderAnswersJSON || '{}');

                                                    $objRow.newRow.find('textarea[' + CONST_FIELD_NAME + '="patientGoalProgressJSON"]')
                                                        .val(value.patientGoalProgressJSON || '[]');

                                                    $objRow.newRow.find('textarea[' + CONST_FIELD_NAME + '="notes"]')
                                                        .val(value.notes || '')
                                                        .trigger('change');

                                                    $objRow.newRow.find('input[' + CONST_FIELD_NAME + '="startTime"]');
                                                    $objRow.newRow.find('input[' + CONST_FIELD_NAME + '="numMins"]');

                                                    if (value.formBuilderAnswersJSON != '{}') {
                                                        $($icon).removeClass(CSS_CLASS_HIDDEN);
                                                    }

                                                    let pgpVal = value.patientGoalProgressJSON;
                                                    if ((pgpVal != '[]') && (pgpVal != '{}')) $($icon).removeClass(CSS_CLASS_HIDDEN);
                                                    value.isNew = false;

                                                    $row = _fnFindGridRowByAssocKey(key);
                                                    if (!$row.length) {
                                                        $row = _fnFindGridRowByPatIDAndDOS(value.patID, value.dos);
                                                    }

                                                    _fnUpdateGridRowFields($row, value); // NEW
                                                }
                                                /* Existing patient row */
                                                else {

                                                    var $icon = $($row).find('i.fas.fa-check-square').last();
                                                    if (value.formBuilderAnswersJSON != '{}') {
                                                        $($icon).removeClass(CSS_CLASS_HIDDEN);
                                                    }
                                                    let pgpVal = value.patientGoalProgressJSON;
                                                    if ((pgpVal != '[]') && (pgpVal != '{}')) $($icon).removeClass(CSS_CLASS_HIDDEN);
                                                }

                                                _fnUpdateGridRowFields($row, value);

                                            });
                                        }
                                        , fnExitCallback: function () {
                                            $liveSession.dialog('close');
                                        }
                                        , tkn: $.spedmonWebUI.token
                                    });
                                }
                            }
                            , hide: {
                                effect: 'slide'
                                , direction: 'left'
                            }
                            , close: function (event, ui) { $liveSession.remove(); }
                        });
                    $liveSession.parent().addClass("ui-dialog-pat");
                    return uiActionObj;
                }
                , initiallyHidden: false
            });

            <%}%>
        <%}%>

        opts.additionalControlDefinitionsForBodyRows.set('setNotifications', {
            defType: 'userprovided'
            , name: 'setNotifications'
            , toolTip: 'Notifications'
            , cssClass: 'fas fa-bell'
            , handlerFn: function (uiActionObj) {
                let $row = uiActionObj.whatRow;
                displayServiceEntryNotifications($row);
                return uiActionObj;
            }
            , initiallyHidden: false
        });

        <%//#########################################%>
        <%//# Row Creation Hooks %>
        <%//#########################################%>
                
        opts.fnAddNewRowAndCellsAfter = fnSvcRecsEntryAddNewRowAndCellsAfter;
            
        <%//#########################################%>
        <%//# Cell creation hooks %>
        <%//#########################################%>
        
        opts.fnCreateNewCellAfter = fnSvcRecsEntryCreateNewCellAfter;
       
        <%//#########################################%>
        <%//# Create Grid %>
        <%//#########################################%>

        $SVC_RECS_DATAGRID.MBA_DataGrid(opts);

    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    $(window).on('load', function () {        

        <%if (hasWipData == true) {%>
        hasWipData = 1;        
        <%}%>

        <%if (hasRecsToPreload == true) {%>
        hasRecsToPreload = 1;
        <%}%>
        
        $SVC_RECS_DATAGRID = $('#dataGrid');
        $DOS_HIDDEN        = $('#dosHidden');

        initDataGrid();

        $('#butCaseload').on('click', function (e) {
            addCaseload();            
        });

        $('#reference').on('spedmoninput', function (e) {
            updateBatchFileLink();
        });

        let forcedGrpId = '<%=caseloadGrpId%>';
        let autoLoad = <%= (autoLoadData ? "true" : "false") %>;

        if (autoLoad && forcedGrpId) {
            loadOnlyGroup(forcedGrpId);
        }
        
    });

</script>