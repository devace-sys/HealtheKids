<%@ Page Language="C#" CodeBehind="user_all_transportation_patients_and_routes_manage.aspx.cs" Inherits="Spedmon.userAllTransportationPatientsAndRoutesManage"%>

<div id="dataManagementRows" class="container-fluid">  

    <Spedmon:HiddenInput id="transmgmtid" name="transmgmtid" title="Owner ID" runat="server"></Spedmon:HiddenInput>   

    <div class="row">
       
       <%-----------------------------%>
       <%-- Route and Route Options --%>
       <%-----------------------------%>

        <div class="col-8">

            <Spedmon:DataEntryRowSelectClient
                ID                   = "selectClient" 
                entityControlID      = "clientid"                
                rowLabel             = "Client"
                dataEntryRowRenderAs = "FIELD"
                runat                = "server">
            </Spedmon:DataEntryRowSelectClient>

            <Spedmon:DataEntryRowSelectRoute
                ID                   = "selectRoute" 
                entityControlID      = "routeid"                
                rowLabel             = "Route"
                dataEntryRowRenderAs = "FIELD"
                onSpedmonInputData   = "fnUpdateRouteInfo(e)"
                runat                = "server">
            </Spedmon:DataEntryRowSelectRoute>

            <%-- NOTE: css code needs to be added for every additional icon --%>

            <span class="d-inline-block">
        
                <Spedmon:Button title="Duplicate this Route" ID="dupRouteBut" runat="server">
                    <i class="route-icon fas fa-clone"></i>
                </Spedmon:Button>

                <Spedmon:Button title="Duplicate this Route with Reverse Stops" ID="dupRouteReverseBut" runat="server">
                    <i class="route-icon far fa-clone fa-stack-1x"></i>
                    <i class="route-icon fas fa-random fa-stack-1x fa-sm"></i>
                </Spedmon:Button>

                <Spedmon:Button title="Print this Route Sheet" ID="printRouteSheetSingleBut" runat="server">
                    <i class="route-icon fas fa-print"></i>
                </Spedmon:Button>

                <Spedmon:Button title="Remove this Route" ID="removeRouteBut" runat="server">
                    <i class="route-icon fas fa-trash-alt"></i>
                </Spedmon:Button>

                <Spedmon:Button title="Edit this Route" ID="editRouteBut" runat="server">
                    <i class="route-icon fas fa-pencil-alt"></i>
                </Spedmon:Button>

                <Spedmon:Button title="Change Order of Route Members" ID="sortMembersBut" runat="server">
                    <i class="route-icon fas fa-sort-alpha-down"></i>
                </Spedmon:Button>
               
            </span>

        </div>
        
        <%-----------------------------%>
        <%--    Global Options       --%>
        <%-----------------------------%>

        <div class="col-4">

            <div class="d-flex">

            <Spedmon:Button title="Add New Route" ID="addNewRouteBut" runat="server">
                <i class="route-icon fas fa-plus"></i>
            </Spedmon:Button>

            <Spedmon:Button title="Print All Route Sheets" ID="printRouteSheetsBut" runat="server">
                <i class="route-icon fas fa-print"></i>
            </Spedmon:Button>
                            
            <Spedmon:DataEntryButton id="doExportAllAuthPatsBut" title="Export All Authorized Patients" assignBsCssClasses="false" fireSpedmonInput="false" faIcon="route-icon fas fa-file-excel" onclick="downloadTransportMgmtReptAuthPats(e)" runat="server" />

            <Spedmon:Button title="Add New Site" ID="addNewSiteBut" runat="server">
                <i class="route-icon fas fa-building fa-2x fa-stack-1x"></i>
                <i class="route-icon fa fa-plus fa-2x fa-stack-1x fa-sm"></i>
            </Spedmon:Button>

            </div>

        </div>

    </div>

    <%-----------------------------%>
    <%--       Rest view         --%>
    <%-----------------------------%>

    <div class="row mt-3">
        <div class="col-12">
            <div id="restView">
            </div>
        </div>
    </div>

</div>

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    let $dataManagementRows = null;
    let $restViewCtrl = null;

    const PARM_NAME_CLIENT_ID        = '<%=MBA.Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_TRANS_MGMT_ID    = '<%=MBA.Constants.PARM_TRANS_MGMT_ID%>';
    const PARM_NAME_ROUTE_ID         = '<%=MBA.Constants.PARM_ROUTE_ID%>';
    const PARM_NAME_ACTIVE           = '<%=MBA.Constants.PARM_ACTIVE%>';
    const ADDRESS_DETAILS_REF        = 'address-details-ref';
    const CONST_FIELD_NAME           = 'data-mba-rest-view-field-name';
    const CONST_PULSE_CLASS          = 'pulse-icon-class';
    const CONST_ATTR_ENTITY_ID       = 'data-entity-id';
    const CONST_MEMBER_CLASS         = 'ui-helper-clearfix ui-state-default mba-entity-group-member';
    const CONST_MEMBER_LINE_CLASS    = 'ui-helper-clearfix mba-entity-group-member-line';
    const CONST_MEMBER_LABEL_CLASS   = 'mba-entity-group-member-label';
    const CONST_MEMBER_CONTEXT_CLASS = 'mba-entity-group-member-context';

    let   $startDateDflt           = '<%=startDateDefault%>';
    let   $ownerID                 = <%=tmr.id%>;
    let   routeInfo                = {};
    let   ADDRESS_DISPLAY_CLASS    = 'address-display-class';
    let   defaultWeekDaysJSON      = JSON.stringify({
                                        "mon": true
                                        , "tue": true
                                        , "wed": true
                                        , "thur": true
                                        , "fri": true
                                    });

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnUpdateRouteInfo(e) {
        routeInfo = e.dataitem;
        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnGetPatPlacesInfo($divPlaces, rowData) {
        let reqUrl = '<%=Spedmon.PatientPlaces.URL_VIEW_INFO_BASE()%>';
        let reqData = JSON.stringify({
            "clientid": $('#' + PARM_NAME_CLIENT_ID).val()
            , "patid": rowData.patID
        });

        let tblStr = '';

        $($divPlaces).html('');

        var fnProcRespSuccess = function (rd) {
            tblStr = $.spedmonWebUI.ReturnInfoTableRenderHTMLTableStringBase(rd, 'No patient places', 'mba-entity-group-member-info-table', false, false);
            $($divPlaces).html(tblStr);
        };

        var fnComplete = function () { };

        $.spedmonWebUI.ajax(null, reqUrl, reqData, 'json_synch', null, null, null, null, 0, fnProcRespSuccess, fnComplete, null);

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnOpenSubPagePatPlaceMgmtUrl(actionUrl, rowData, $divPlaces) {
        let reqUrl = actionUrl
            + '&clientid=' + $('#' + PARM_NAME_CLIENT_ID).val()
            + '&patid=' + rowData.patID;

        let fnEntryTest = function () { return true; };
        let fnExitTest = function () { return true; };
        let fnResume = function () {
            fnGetPatPlacesInfo($divPlaces, rowData);
            return true;
        };

        $.spedmonWebUI.popupThenResume(fnEntryTest
            , fnExitTest
            , fnResume
            , reqUrl
            , 'Popups Not Supported'
            , 'Please allow popups for SpEdCare'
            , 'Waiting'
            , 'Waiting for you to finish with patient places');
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnAddOrEditBusDrivers($row, saveType, recID) {
        $($row).show('slow').html('');

        // create elements
        let $formRowCol1 = $('<td></td>');
        let $formRowCol2 = $('<td></td>');
        let $formRowCol3 = $('<td class="d-flex"></td>');

        let $driverFirstName = $('<input placeholder="First Name" id="driverfirstname" name="driverfirstname" title="First Name" type="text"/>');
        let $driverLastName = $('<input placeholder="Last Name" id="driverlastname" name="driverlastname" title="Last Name" type="text"/>');
        let $saveDriver = $('<i class="route-icon fas fa-save" title="Save bus driver info"></i>');
        let $deleteDriver = $('<i class="route-icon fas fa-trash-alt ml-3" title="Delete this Bus Driver"></i>');
        let $cancelBut = $('<i class="route-icon fas fa-times ml-3" title="Cancel"></i>');

        $formRowCol1.append($driverFirstName);
        $formRowCol2.append($driverLastName);
        $formRowCol3.append($saveDriver);
        $formRowCol3.append($deleteDriver);
        $formRowCol3.append($cancelBut);

        $row.append($formRowCol1);
        $row.append($formRowCol2);
        $row.append($formRowCol3);

        // enhance
        $($driverFirstName).MBA_DataEntryBox({});
        $($driverLastName).MBA_DataEntryBox({});

        // add pulsating effect to save icon
        $($saveDriver).addClass(CONST_PULSE_CLASS);

        // logic based on saveType
        if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT) {

            // show delete icon if editing driver
            $($deleteDriver).show();

            // preload values
            let reqUrl = '<%=Spedmon.TransportationMgmtBusDrivers.URL_VIEW_ENTITY_BASE()%>';
            let reqData = JSON.stringify({
                "clientid": $('#' + PARM_NAME_CLIENT_ID).val()
                , "recid": recID
            });

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                .then(responseData => {
                    $($driverFirstName).val(responseData.rawData.entity.firstName);
                    $($driverLastName).val(responseData.rawData.entity.lastName);

                    return true;
                })
                .catch(responseData => {
                    $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                    return true;
                });
        }
        else {
            // hide delete icon if adding new driver
            $($deleteDriver).hide();
        }
        
        // click events
        $($saveDriver).on('click', function () {
            let reqUrl = '<%=Spedmon.TransportationMgmtBusDrivers.URL_SAVE_BASE()%>';
            let reqData = JSON.stringify({
                "clientid": $('#' + PARM_NAME_CLIENT_ID).val()
                , "firstname": $($driverFirstName).val()
                , "lastname": $($driverLastName).val()
                , "recid": recID
                , "savetype": saveType
            });
            
            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                .then(responseData => {
                    if (responseData.rawData.recordID == 0) {
                        $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                    }
                    else {
                        if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT) {

                            // update selection
                            let updatedDriverName =
                                $($driverLastName).val()
                                + (($($driverFirstName).val() && $($driverLastName).val()) ? ', ' : '')
                                + $($driverFirstName).val();

                            $('#busdriverid_selection').val(updatedDriverName);
                        }
                    }
                    
                    $($row).hide('slow');
                    return true;
                })
                .catch(responseData => {
                    $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                    return true;
                });
        });

        $($deleteDriver).on('click', function () {
            let onYes = function () {
                let reqUrl = '<%=Spedmon.TransportationMgmtBusDrivers.URL_DELETE_BASE()%>';
                let reqData = JSON.stringify({
                    "recid": recID
                });

                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                    .then(responseData => {
                        $('#busdriverid').val('');
                        $('#busdriverid_selection').val('');

                        $($row).hide('slow');
                        return true;
                    })
                    .catch(responseData => {
                        $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                        return true;
                    });
            }

            $.spedmonWebUI.dialogConfirm("Please Confirm", "Are you sure you want to remove this record?", onYes, function () { });
        });

        $($cancelBut).on('click', function () {
            $($row).hide('slow');
        });

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnSortGetMemberOrder() {
        let $sortGrpList = $('#membersList');
        let $sortGrpListItems = $($sortGrpList).children();
        let $inpMemberOrder = $('#membersDisplayOrder');
        let arrEntityIDs = [];
        $.each($sortGrpListItems, function (idx, $sortGrpListItem) {
            arrEntityIDs.push($($sortGrpListItem).attr(CONST_ATTR_ENTITY_ID));
        });
        let strEntityIDs = '';
        strEntityIDs = arrEntityIDs.join();
        $inpMemberOrder.val(strEntityIDs);
        
        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnCreateSortListItem(obj) {

        /*============================================================
         * List item
         *============================================================*/

        let $li = $('<li></li>');

        $($li).attr(CONST_ATTR_ENTITY_ID, obj.id);
        $($li).addClass(CONST_MEMBER_CLASS);
        
        /*============================================================
         * List item line 1 and 2
         *============================================================*/

        var $li1 = $('<div></div>');
        var $li2 = $('<div></div>');
        $($li1).addClass(CONST_MEMBER_LINE_CLASS);
        $($li2).addClass(CONST_MEMBER_LINE_CLASS);
        
        /*============================================================
         * Create list item label
         *============================================================*/

        var $liLabel = $('<span>' + obj.label + '</span>');
        $($liLabel).addClass(CONST_MEMBER_LABEL_CLASS);
        
        /*============================================================
         * Create list item context
         *============================================================*/

        var context1Data = '';
        if (obj.context1) context1Data = obj.context1;

        var $liContext1 = $('<span>' + context1Data + '</span>');
        $($liContext1).addClass(CONST_MEMBER_CONTEXT_CLASS);

        /*============================================================
         * Append label and controls container to list item 
         *============================================================*/

        $($li1).append($liLabel);
        $($li2).append($liContext1);
        $($li).append($li1);
        $($li).append($li2);

        $($li).css('cursor', 'move');
        return $li;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    /* Dialog launch functions */

    function fnLaunchRouteAddNewOrEditDialog(saveType, dialogTitle) {
        if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT && jQuery.isEmptyObject(routeInfo)) return;

        let recID = '';
        if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT) recID = routeInfo.id;

        // dialog element which will have form
        $dia_add_new = $('<div></div>');

        // form element
        $dia_add_new_form = $('<form></form>');
        $dia_add_new_form.append('<input name="organizationID" value="' + $('#' + PARM_NAME_CLIENT_ID).val() + '"  type="hidden" />');
        $dia_add_new_form.append('<input name="ownerID"        value="' + $ownerID + '"  type="hidden" />');

        $dia_add_new_form.append('<input name="saveType"  value="' + saveType + '" type="hidden" />');
        $dia_add_new_form.append('<input name="recID"     value="' + recID    + '" type="hidden" />');

        /* Create table to layout fields */

        let $frmTable = $('<table style="margin: 0 auto;"></table>');

        // Route Name
        let $frmRow1 = $('<tr></tr>');
        let $formRow1Col1 = $('<td></td>');
        let $formRow1Col2 = $('<td></td>');

        let $lblRouteName = $('<label>Route Name &nbsp;</label>');
        let $routeName = $('<input name="name" type="text" title="Enter new route name" />');

        $formRow1Col1.append($lblRouteName);
        $formRow1Col2.append($routeName);

        $frmRow1.append($formRow1Col1);
        $frmRow1.append($formRow1Col2);

        // Bus Number

        let $frmRow2 = $('<tr></tr>');
        let $formRow2Col1 = $('<td></td>');
        let $formRow2Col2 = $('<td></td>');

        let $lblBusNum = $('<label>Bus Number &nbsp;</label>');
        let $busNum = $('<input name="busNumber" type="text" title="Enter bus number" />');

        $formRow2Col1.append($lblBusNum);
        $formRow2Col2.append($busNum);

        $frmRow2.append($formRow2Col1);
        $frmRow2.append($formRow2Col2);

        // Route Origin

        let $frmRow3 = $('<tr></tr>');
        let $formRow3Col1 = $('<td></td>');
        let $formRow3Col2 = $('<td></td>');

        let $lblRouteOrigin = $('<label>Select Route Origination &nbsp;</label>');
        let $routeOrigin = $('<input id="origPlaceSel" name="origPlaceSel" title="Select Route Origination" class="mba-web-ui-field-simple" type="text"/>');
        let $routeOriginID = $('<input id="origPlaceID" name="origPlaceID"  type="hidden" />');

        $formRow3Col1.append($lblRouteOrigin);
        $formRow3Col2.append($routeOrigin);
        $formRow3Col2.append($routeOriginID);

        $frmRow3.append($formRow3Col1);
        $frmRow3.append($formRow3Col2);

        // Route Destination

        let $frmRow4 = $('<tr></tr>');
        let $formRow4Col1 = $('<td></td>');
        let $formRow4Col2 = $('<td></td>');

        let $lblRouteDest = $('<label>Select Route Termination &nbsp;</label>');
        let $routeDest = $('<input id="destPlaceSel" name="destPlaceSel" title="Select Route Destination" class="mba-web-ui-field-simple" type="text"/>');
        let $routeDestID = $('<input id="destPlaceID" name="destPlaceID"  type="hidden" />');

        $formRow4Col1.append($lblRouteDest);
        $formRow4Col2.append($routeDest);
        $formRow4Col2.append($routeDestID);

        $frmRow4.append($formRow4Col1);
        $frmRow4.append($formRow4Col2);

        // Bus Driver

        let $frmRow5 = $('<tr></tr>');
        let $formRow5Col1 = $('<td></td>');
        let $formRow5Col2 = $('<td></td>');
        let $formRow5Col3 = $('<td class="d-flex"></td>');

        let $lblBusDriver = $('<label>Select Bus Driver &nbsp;</label>');
        let $busDriver = $('<input id="busdriverid" name="busdriverid" title="Select Bus Driver" class="mba-web-ui-field-simple" type="text"/>');
        let $newDriver = $('<i class="route-icon fas fa-plus" title="Add New Bus Driver"></i>');
        let $editDriver = $('<i class="route-icon fas fa-pencil-alt ml-3" title="Edit or Delete this Bus Driver"></i>');
        
        $formRow5Col1.append($lblBusDriver);
        $formRow5Col2.append($busDriver);
        $formRow5Col3.append($newDriver);
        $formRow5Col3.append($editDriver);

        $frmRow5.append($formRow5Col1);
        $frmRow5.append($formRow5Col2);
        $frmRow5.append($formRow5Col3);

        // Bus driver add/edit (hidden)
        
        let $frmRow6 = $('<tr></tr>'); // content will be added to this row

        $frmTable.append($frmRow1);
        $frmTable.append($frmRow2);
        $frmTable.append($frmRow3);
        $frmTable.append($frmRow4);
        $frmTable.append($frmRow5);
        $frmTable.append($frmRow6);

        /* Append to form */

        $dia_add_new_form.append($frmTable);

        $($frmRow6).hide();

        $($routeName).spedmonTextbox({ "showOK": false });
        $($busNum).spedmonTextbox({ "showOK": false });

        /* Route Origin and Destination dropdowns */

        let sitePlacesURL = '<%=Spedmon.SitePlaces.URL_VIEW_SEL_BASE()%>';
        let sitePlacesNVP = [
            { name: "clientid", value: $('#' + PARM_NAME_CLIENT_ID).val() }
            , { name: "patid", value: "" }
        ];

        $($routeOrigin).spedmonSelectBox({
            dataParmType: "DOM"
            , selectAll: true
            , selectType: ($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX)
            , onSelect: function (event, ui) {
                $($routeOriginID).val(ui.item.recData2);
            }
            , ajaxopts: { url: (sitePlacesURL), data: "", namevalues: sitePlacesNVP, getnamevaluesfn: null }
        });
        $($routeDest).spedmonSelectBox({
            dataParmType: "DOM"
            , selectAll: true
            , selectType: ($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX)
            , onSelect: function (event, ui) {
                $($routeDestID).val(ui.item.recData2);
            }
            , ajaxopts: { url: (sitePlacesURL), data: "", namevalues: sitePlacesNVP, getnamevaluesfn: null }
        });

        /* Bus driver dropdown */

        let busDriversURL = '<%=Spedmon.TransportationMgmtBusDrivers.URL_VIEW_SEL_BASE()%>';
        let busDriversNVP = [
            { name: "clientid", value: $('#' + PARM_NAME_CLIENT_ID).val() }
        ];

        $($busDriver).spedmonSelectBox({
            dataParmType: "DOM"
            , selectAll: true
            , selectType: ($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX)
            , onSelect: function (event, ui) { }
            , ajaxopts: { url: (busDriversURL), data: "", namevalues: busDriversNVP, getnamevaluesfn: null }
        });

        // icon click events

        $($newDriver).on('click', function () {
            fnAddOrEditBusDrivers($frmRow6, $.spedmonWebUI.RECORD_SAVE_TYPE_NEW, '');
        });

        $($editDriver).on('click', function () {
            let driverID = $($busDriver).val();
            if (driverID) {
                fnAddOrEditBusDrivers($frmRow6, $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT, driverID);
            }
        });

        // append form to dialog
        $dia_add_new.append($dia_add_new_form);

        // initiate dialog
        $dia_add_new.dialog({
            width: ($(window).width() * .6)
            , height: ($(window).height() * .7)
            , resizable: true
            , modal: true
            , title: dialogTitle
            , show: {
                effect: 'slide'
                , direction: 'left'
                , complete: function () {
                    // preload values for edits
                    if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT) {
                        $($routeName).val(routeInfo.label);
                        $($busNum).val(routeInfo.context1);

                        $($routeOriginID).val(routeInfo.recData4);
                        $('#origPlaceSel_selection').val(routeInfo.recData2);

                        $($routeDestID).val(routeInfo.recData7);
                        $('#destPlaceSel_selection').val(routeInfo.recData5);

                        $($busDriver).val(routeInfo.recData9);
                        $('#busdriverid_selection').val(routeInfo.recData10);
                    }
                }
            }
            , hide: {
                effect: 'slide'
                , direction: 'left'
            }
            , close: function () {
                $dia_add_new.remove();
            }
            , buttons: {
                Cancel: function () { $($dia_add_new).dialog("close"); }
                , Save: function () {
                    // call asmx method to save data and refresh rest table
                    let data = $.spedmonWebUI.formParmsToJSON($dia_add_new_form);
                    let reqUrl = '<%=Spedmon.TransportationMgmtAuthorizedRoutes.URL_SAVE_BASE()%>';
                    let reqData = data;

                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                        .then(responseData => {
                            if (responseData.rawData.recordID == 0) {
                                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                            }

                            $dia_add_new.dialog("close");

                            if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT) {
                                // refresh rest view and update routeInfo
                                $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

                                let dataObj = JSON.parse(data);
                                routeInfo.context1 = dataObj.busNumber;
                                routeInfo.label = dataObj.name;
                                routeInfo.recData1 = dataObj.busNumber;
                                routeInfo.recData2 = $('#origPlaceSel_selection').val();
                                routeInfo.recData4 = dataObj.origPlaceID;
                                routeInfo.recData5 = $('#destPlaceSel_selection').val();
                                routeInfo.recData7 = dataObj.destPlaceID;
                                routeInfo.recData9 = dataObj.busdriverid;
                                routeInfo.recData10 = $('#busdriverid_selection').val();
                            }

                            return true;
                        })
                        .catch(responseData => {
                            $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                            return true;
                        });
                }
            }
        });

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnLaunchDupRouteDialog(reqUrl, dialogTitle) {
        if (jQuery.isEmptyObject(routeInfo)) return;

        // dialog element which will have form
        $dia_dup_route = $('<div></div>');

        // form element
        $dia_dup_route_form = $('<form></form>');
        $dia_dup_route_form.append('<input name="organizationID" value="' + $('#' + PARM_NAME_CLIENT_ID).val() + '"  type="hidden" />');
        $dia_dup_route_form.append('<input name="ownerID"        value="' + $ownerID + '"  type="hidden" />');
        $dia_dup_route_form.append('<input name="groupID"        value="' + routeInfo.id + '" type="hidden" />');

        /* Create table to layout fields */

        let $frmTable = $('<table style="margin: 0 auto;"></table>');

        // Original Route

        let $frmRow1 = $('<tr></tr>');
        let $formRow1Col1 = $('<td></td>');
        let $formRow1Col2 = $('<td></td>');

        let $lblOriginRoute = $('<label>Original Route Name &nbsp;</label>');
        let $originRoute = $('<span class="mba-entity-dia-inline-label">' + routeInfo.label + '</span>');

        $formRow1Col1.append($lblOriginRoute);
        $formRow1Col2.append($originRoute);

        $frmRow1.append($formRow1Col1);
        $frmRow1.append($formRow1Col2);

        // New route name

        let $frmRow2 = $('<tr></tr>');
        let $formRow2Col1 = $('<td></td>');
        let $formRow2Col2 = $('<td></td>');

        let $lblRouteName = $('<label>New Route Name &nbsp;</label>');
        let $routeName = $('<input name="name" type="text" title="Enter new route name" />');

        $formRow2Col1.append($lblRouteName);
        $formRow2Col2.append($routeName);

        $frmRow2.append($formRow2Col1);
        $frmRow2.append($formRow2Col2);

        $frmTable.append($frmRow1);
        $frmTable.append($frmRow2);

        /* Append to form */

        $dia_dup_route_form.append($frmTable);

        $($routeName).spedmonTextbox({ "showOK": false });

        // append form to dialog
        $dia_dup_route.append($dia_dup_route_form);

        // initiate dialog
        $dia_dup_route.dialog({
            width: ($(window).width() * .5)
            , height: ($(window).height() * .4)
            , resizable: true
            , modal: true
            , title: dialogTitle
            , show: {
                effect: 'slide'
                , direction: 'left'
                , complete: function () { }
            }
            , hide: {
                effect: 'slide'
                , direction: 'left'
            }
            , close: function () {
                $dia_dup_route.remove();
            }
            , buttons: {
                Cancel: function () { $($dia_dup_route).dialog("close"); }
                , Save: function () {
                    // call asmx method to save data and refresh rest table
                    let data = $.spedmonWebUI.formParmsToJSON($dia_dup_route_form);
                    let reqData = data;

                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                        .then(responseData => {
                            if (responseData.rawData.recordID == 0) {
                                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                            }

                            $dia_dup_route.dialog("close");
                            return true;
                        })
                        .catch(responseData => {
                            $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                            return true;
                        });
                }
            }
        });

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnLaunchPrintRouteSheetsDialog(forAllRoutes, dialogTitle) {
        if (forAllRoutes == false && jQuery.isEmptyObject(routeInfo)) return;

        let recID = '';
        if (forAllRoutes == false) recID = routeInfo.id;

        // dialog element which will have form
        $dia_print_group = $('<div></div>');

        // form element
        $dia_print_group_form = $('<form></form>');
        $dia_print_group_form.append('<input name="organizationID" value="' + $('#' + PARM_NAME_CLIENT_ID).val() + '"  type="hidden" />');
        $dia_print_group_form.append('<input name="ownerID"        value="' + $ownerID + '"  type="hidden" />');
        $dia_print_group_form.append('<input name="groupID"        value="' + recID + '" type="hidden" />');

        /* Create table to layout fields */

        let $frmTable = $('<table style="margin: 0 auto;"></table>');

        // Route Info

        let routeName = 'Authorized Routes';
        if (forAllRoutes == false) routeName = routeInfo.label;

        let $frmRow1 = $('<tr></tr>');
        let $formRow1Col1 = $('<td></td>');
        let $formRow1Col2 = $('<td></td>');

        let $lblRouteInfo = $('<label>Print Route Sheet For &nbsp;</label>');
        let $routeInfo = $('<span class="mba-entity-dia-inline-label">' + routeName + '</span>');

        $formRow1Col1.append($lblRouteInfo);
        $formRow1Col2.append($routeInfo);

        $frmRow1.append($formRow1Col1);
        $frmRow1.append($formRow1Col2);

        // Start Date

        let $frmRow2 = $('<tr></tr>');
        let $formRow2Col1 = $('<td></td>');
        let $formRow2Col2 = $('<td></td>');

        let $lblStartDate = $('<label>Starting Date for Week Of Service &nbsp;</label>');
        let $startDate = $('<input name="startdate" type="text" title="Enter start date" />');

        $formRow2Col1.append($lblStartDate);
        $formRow2Col2.append($startDate);

        $frmRow2.append($formRow2Col1);
        $frmRow2.append($formRow2Col2);

        $frmTable.append($frmRow1);
        $frmTable.append($frmRow2);

        /* Append to form */

        $dia_print_group_form.append($frmTable);

        $($startDate).spedmonDatebox({ multidate: false, showOK: false, maxDate: '', dateText: ($startDateDflt), defaultDate: ($startDateDflt), useVisibleWorkaround: false });

        // append form to dialog
        $dia_print_group.append($dia_print_group_form);

        // initiate dialog
        $dia_print_group.dialog({
            width: ($(window).width() * .5)
            , height: ($(window).height() * .4)
            , resizable: true
            , modal: true
            , title: dialogTitle
            , show: {
                effect: 'slide'
                , direction: 'left'
                , complete: function () { }
            }
            , hide: {
                effect: 'slide'
                , direction: 'left'
            }
            , close: function () {
                $dia_print_group.remove();
            }
            , buttons: {
                Cancel: function () { $($dia_print_group).dialog("close"); }
                , Print: function () {
                    // call asmx method to save data and refresh rest table
                    let data = $.spedmonWebUI.formParmsToNVPS($dia_print_group_form);
                    let reqUrl = '<%=Spedmon.TransportationMgmtRouteSheetProcessing.URL_WEB_REPORT_BASE()%>';
                    var parms = '&' + data;
                    var url = reqUrl + parms;
                    $.spedmonWebUI.downloadDynamicURL(url);

                    $($dia_print_group).dialog("close");
                }
            }
        });

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnLaunchAddMemberToRoute(uiActionObj) {
        if (jQuery.isEmptyObject(routeInfo)) return;
        
        // dialog element which will have form
        $dia_add_pat = $('<div></div>');
        
        // form element
        $dia_add_pat_form = $('<form></form>');
        $dia_add_pat_form.append('<input name="organizationID" value="' + $('#' + PARM_NAME_CLIENT_ID).val() + '"  type="hidden" />');
        $dia_add_pat_form.append('<input name="ownerID"        value="' + $ownerID + '"  type="hidden" />');
        $dia_add_pat_form.append('<input name="groupID"        value="' + routeInfo.id + '" type="hidden" />');
        $dia_add_pat_form.append('<input name="origPlaceID"    value="" type="hidden" />');
        $dia_add_pat_form.append('<input name="destPlaceID"    value="" type="hidden" />');
        $dia_add_pat_form.append('<input name="weekDaysJSON"   value="' + defaultWeekDaysJSON + '" type="hidden" />');
        $dia_add_pat_form.append('<input name="selectAmPm"     value="" type="hidden" />');
        $dia_add_pat_form.append('<input name="savetype"       value="1" type="hidden" />');
        $dia_add_pat_form.append('<input name="recid"          value="" type="hidden" />');

        /* Create table to layout fields */

        let $frmTable = $('<table style="margin: 0 auto;"></table>');

        // Patient selection

        let $frmRow1 = $('<tr></tr>');
        let $formRow1Col1 = $('<td></td>');
        let $formRow1Col2 = $('<td></td>');
        
        let $lblPatSel = $('<label>Select an Authorized Patient &nbsp;</label>');
        let $patSel = $('<input id="entityID" name="entityID" title="Select Patient" class="mba-web-ui-field-simple" type="text"/>');
        let $weekDaysJSON = $('<input name="weekDaysJSON" type="hidden" />');

        $formRow1Col1.append($lblPatSel);
        $formRow1Col2.append($patSel);
        $formRow1Col2.append($weekDaysJSON);

        $frmRow1.append($formRow1Col1);
        $frmRow1.append($formRow1Col2);

        $frmTable.append($frmRow1);

        /* Append to form */

        $dia_add_pat_form.append($frmTable);

        /* Create add new patient link */
        
        let addNewPatUrl = '<%=Spedmon.Patients.URL_USER_ALL_SAVE_NEW_BASE(true)%>'
                         + '&' + PARM_NAME_CLIENT_ID + '=' + $('#' + PARM_NAME_CLIENT_ID).val();
        
        let $addNewPatCont = $('<div class="text-center"></div>');
        let $addNewPatLnk = $('<a style="text-decoration:underline" target="_blank" href="' + addNewPatUrl +'">No patient found? Click here to add a new patient.</a>');
        $($addNewPatCont).append($addNewPatLnk);

        /* Append to dialog */

        $dia_add_pat_form.append($addNewPatCont);

        /* Enhance */

        // preload default weekdays JSON
        $($weekDaysJSON).val(defaultWeekDaysJSON);

        // Patient selection
        let patSelURL = '<%=Spedmon.Patients.URL_SVC_VIEW_SEL_TRANS_BASE()%>';
        let patSelNVP = [
            { name: "clientid", value: $('#' + PARM_NAME_CLIENT_ID).val() }
        ];

        $($patSel).spedmonSelectBox({
            dataParmType: "DOM"
            , selectAll: true
            , selectType: ($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX)
            , onSelect: function (event, ui) {}
            , ajaxopts: { url: (patSelURL), data: "", namevalues: patSelNVP, getnamevaluesfn: null }
        });

        // append form to dialog
        $dia_add_pat.append($dia_add_pat_form);

        // initiate dialog
        $dia_add_pat.dialog({
            width: ($(window).width() * .5)
            , height: ($(window).height() * .4)
            , resizable: true
            , modal: true
            , title: 'Add Patient to this Route'
            , show: {
                effect: 'slide'
                , direction: 'left'
                , complete: function () { }
            }
            , hide: {
                effect: 'slide'
                , direction: 'left'
            }
            , close: function () {
                $dia_add_pat.remove();
            }
            , buttons: {
                Cancel: function () { $($dia_add_pat).dialog("close"); }
                , Add: function () {
                    // call asmx method to save data and refresh rest table
                    let data = $.spedmonWebUI.formParmsToJSON($dia_add_pat_form);
                    let reqUrl = '<%=Spedmon.TransportationMgmtAuthorizedRouteMembers.URL_SAVE_BASE()%>';
                    let reqData = data;

                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                        .then(responseData => {
                            if (responseData.rawData.recordID == 0) {
                                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                            }

                            $dia_add_pat.dialog("close");
                            MBA.RestViewCommon.fnRefreshCurrentViewFromServer(uiActionObj.elem);
                            return true;
                        })
                        .catch(responseData => {
                            $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                            return true;
                        });
                }
            }
        });

        return;
    }

    /* Icons */

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnAddNewRoute() {
        fnLaunchRouteAddNewOrEditDialog($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, 'Add New Route');
        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnPrintRouteSheets() {
        fnLaunchPrintRouteSheetsDialog(true, 'Print All Route Sheets');

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnAddNewSite() {
        let reqUrl = '<%=addNewSiteURL%>'
            + '&savetype=' + $.spedmonWebUI.RECORD_SAVE_TYPE_NEW;

        let fnEntryTest = function () { return true; };
        let fnExitTest = function () { return true; };
        let fnResume = function () { };

        $.spedmonWebUI.popupThenResume(fnEntryTest
            , fnExitTest
            , fnResume
            , reqUrl
            , 'Popups Not Supported'
            , 'Please allow popups for SpEdCare'
            , 'Waiting'
            , 'Waiting for you to finish with sites');

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnDupRoute() {
        fnLaunchDupRouteDialog('<%=Spedmon.TransportationMgmtAuthorizedRoutes.URL_DUP_BASE()%>'
            , 'Duplicate this Route'
        );

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnDupRouteReverse() {
        fnLaunchDupRouteDialog('<%=Spedmon.TransportationMgmtAuthorizedRoutes.URL_DUP_REVERSE_BASE()%>'
            , 'Duplicate this Route with Reverse Stops'
        );

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnPrintRouteSheetSingle() {
        fnLaunchPrintRouteSheetsDialog(false, 'Print this Route Sheet');

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnRemoveRoute() {
        if (jQuery.isEmptyObject(routeInfo)) return;

        // dialog element which will have form
        $dia_remove_route = $('<div></div>');

        // form element
        $dia_remove_route_form = $('<form></form>');
        $dia_remove_route_form.append('<input name="organizationID" value="' + $('#' + PARM_NAME_CLIENT_ID).val() + '"  type="hidden" />');
        $dia_remove_route_form.append('<input name="ownerID"        value="' + $ownerID + '"  type="hidden" />');
        $dia_remove_route_form.append('<input name="groupID"        value="' + routeInfo.id + '" type="hidden" />');

        /* Layout */

        $dia_remove_route_form.append('Do you really want to remove <strong>' + routeInfo.label + '</strong> and all of its members?');

        // append form to dialog
        $dia_remove_route.append($dia_remove_route_form);

        // initiate dialog
        $dia_remove_route.dialog({
            width: ($(window).width() * .4)
            , height: ($(window).height() * .3)
            , resizable: true
            , modal: true
            , title: 'Remove this Route'
            , show: {
                effect: 'slide'
                , direction: 'left'
                , complete: function () { }
            }
            , hide: {
                effect: 'slide'
                , direction: 'left'
            }
            , close: function () {
                $dia_remove_route.remove();
            }
            , buttons: {
                Cancel: function () { $($dia_remove_route).dialog("close"); }
                , Remove: function () {
                    // call asmx method to save data and refresh rest table
                    let data = $.spedmonWebUI.formParmsToJSON($dia_remove_route_form);
                    reqUrl = '<%=Spedmon.TransportationMgmtAuthorizedRoutes.URL_DELETE_BASE()%>';
                    let reqData = data;

                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                        .then(responseData => {
                            if (responseData.rawData.recordID == 0) {
                                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                            }

                            $dia_remove_route.dialog("close");

                            // clear the route selection
                            $('#routeid').val('');
                            $('#routeid_selection').val('');

                            // refresh rest view and routeInfo
                            $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);
                            routeInfo = {};

                            return true;
                        })
                        .catch(responseData => {
                            $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                            return true;
                        });
                }
            }
        });

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnEditRoute() {
        fnLaunchRouteAddNewOrEditDialog($.spedmonWebUI.RECORD_SAVE_TYPE_EDIT, 'Edit Route');
        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnSortMembers() {
        if (jQuery.isEmptyObject(routeInfo)) return;

        // dialog element which will have form
        $dia_sort = $('<div></div>');

        // form element
        $dia_sort_form = $('<form></form>');
        $dia_sort_form.append('<input name="organizationID"      value="' + $('#' + PARM_NAME_CLIENT_ID).val() + '"  type="hidden" />');
        $dia_sort_form.append('<input name="ownerID"             value="' + $ownerID + '"  type="hidden" />');
        $dia_sort_form.append('<input name="groupID"             value="' + routeInfo.id + '" type="hidden" />');
        $dia_sort_form.append('<input name="membersDisplayOrder" id="membersDisplayOrder" type="hidden" />');

        /* layout */

        $dia_sort_form.append('<p>Drag and drop members to sort the list.</p>');
        $dia_sort_form.append('<p>Click on save when you are done.</p>');
        $dia_sort_form.append('<br/>');

        let $sortMembersList = $('<ul id="membersList"></ul>');
        $($dia_sort_form).append($sortMembersList);

        // enhance

        $($sortMembersList).sortable({
            update: function (event, ui) {
                fnSortGetMemberOrder();
            }
        });

        // append form to dialog
        $dia_sort.append($dia_sort_form);

        // initiate dialog
        $dia_sort.dialog({
            width: ($(window).width() * .4)
            , height: ($(window).height() * .7)
            , resizable: true
            , modal: true
            , title: 'Change Order of Route Members'
            , show: {
                effect: 'slide'
                , direction: 'left'
                , complete: function () {

                    // load route members for drag and drop
                    let reqUrl = '<%=Spedmon.TransportationMgmtAuthorizedRouteMembers.URL_VIEW_SEL_BASE()%>';
                    let reqData = JSON.stringify({
                        "organizationID": $('#' + PARM_NAME_CLIENT_ID).val()
                        , "ownerID": $ownerID
                        , "groupID": routeInfo.id
                        , "term": ""
                    });
                    
                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                        .then(responseData => {
                            $sortMembersList.html('');

                            let recsArr = responseData.rawData.SelRecs;
                            if (!recsArr) return true;
                            
                            $.each(recsArr, function (idx, obj) {
                                let $li = fnCreateSortListItem(obj);
                                $($sortMembersList).append($li);
                            });

                            $($sortMembersList).sortable('refresh');
                            fnSortGetMemberOrder();

                            return true;
                        })
                        .catch(responseData => {
                            $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                            return true;
                        });

                    return;
                }
            }
            , hide: {
                effect: 'slide'
                , direction: 'left'
            }
            , close: function () {
                $dia_sort.remove();
            }
            , buttons: {
                Cancel: function () { $($dia_sort).dialog("close"); }
                , Save: function () {
                    // call asmx method to save data and refresh rest table
                    let data = $.spedmonWebUI.formParmsToJSON($dia_sort_form);
                    reqUrl = '<%=Spedmon.TransportationMgmtAuthorizedRouteMembers.URL_SAVE_MEMBERS_DISPLAY_ORDER_BASE()%>';
                    let reqData = data;
                    
                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                        .then(responseData => {
                            $dia_sort.dialog("close");

                            // refresh rest view
                            $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);

                            return true;
                        })
                        .catch(responseData => {
                            $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                            return true;
                        });
                }
            }
        });

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadTransportMgmtRept(e, rptNum) {
        let rptFmt = 3;
        let elem = e.target;
        let reqUrl = '<%=Spedmon.TransportationMgmtAuthorizedPatients.URL_WEB_REPORT()%>';

        let reqData = [
            MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID,     $('#' + PARM_NAME_CLIENT_ID).val())
          , MBA.ComponentCommon.fnCreateNameValueObject(PARM_NAME_TRANS_MGMT_ID, $('#' + PARM_NAME_TRANS_MGMT_ID).val())
        ];

        MBA.ComponentCommon.fnElemDoRequestDownloadWebReportDocument(elem, reqUrl, rptFmt, rptNum, 'Transport_Mgmt_Rpt_' + rptNum + '_' + rptFmt, reqData
            , function () { return; }
            , function () { return; });
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function downloadTransportMgmtReptAuthPats(e) {
        let rptNum = <%=Spedmon.TranportMgmtAuthPatientsViw.REPT_NUM_VIEW%>;
        downloadTransportMgmtRept(e, rptNum);
    };


    /*---------------------------------------------------------------------------------------------------------------------------------*/

    /* Rest View */

    function fnUpdateAddressDisplay($addressSel, fieldName, responseData) {
        let addressSelRefObj = $($addressSel).data(ADDRESS_DETAILS_REF);
        let $addressDisplay = $($addressSel).parents('td.mba-rest-view-visible-tbl-td-or-th')
            .find('div.' + ADDRESS_DISPLAY_CLASS);

        $(addressSelRefObj.addCellValRefsMap.get(fieldName)).val(responseData.recData1);
        $($addressDisplay).html(responseData.recData1);

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnUpdateDistanceCol($addressSel) {
        let addressSelRefObj = $($addressSel).data(ADDRESS_DETAILS_REF);
        let $origPlaceID = $(addressSelRefObj.rowRef).find('td[' + CONST_FIELD_NAME + '="origPlaceID"]')
            .find('input[' + CONST_FIELD_NAME + '="origPlaceID"]');
        let $destPlaceID = $(addressSelRefObj.rowRef).find('td[' + CONST_FIELD_NAME + '="destPlaceID"]')
            .find('input[' + CONST_FIELD_NAME + '="destPlaceID"]');
        let $patID = $(addressSelRefObj.rowRef).find('td[' + CONST_FIELD_NAME + '="patID"]')
            .find('input[' + CONST_FIELD_NAME + '="patID"]');
        
        if (!$($origPlaceID).val()) return;
        if (!$($destPlaceID).val()) return;

        // send ajax request

        let tkn = $.spedmonWebUI.token;
        let reqUrl = "transport_mgmt_trip_calculations.asmx/loadRefreshOrNew?tkn=" + tkn;
        let reqData = JSON.stringify({
            "organizationid": $('#' + PARM_NAME_CLIENT_ID).val()
            , "entityid": $($patID).val()
            , "origplaceid": $($origPlaceID).val()
            , "destplaceid": $($destPlaceID).val()
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                let $distanceDisplay = $(addressSelRefObj.rowRef).find('td[' + CONST_FIELD_NAME + '="distanceMilesStr"]')
                    .find('span[' + CONST_FIELD_NAME + '="distanceMilesStr"]');
                $($distanceDisplay).html(responseData.rawData.distanceInMiles);
                return true;
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                return true;
            });

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function fnEditAuthPatData(rowData) {
        if (jQuery.isEmptyObject(routeInfo)) return;
        
        // dialog element which will have form
        $dia_edit_auth_pat = $('<div></div>');
        
        // form element
        $dia_edit_auth_pat_form = $('<form></form>');
        $dia_edit_auth_pat_form.append('<input name="organizationID" value="' + $('#' + PARM_NAME_CLIENT_ID).val() + '"  type="hidden" />');
        $dia_edit_auth_pat_form.append('<input name="ownerID"        value="' + $ownerID + '"  type="hidden" />');
        $dia_edit_auth_pat_form.append('<input name="entityID"       value="' + rowData.patID + '"  type="hidden" />');
        $dia_edit_auth_pat_form.append('<input name="recID"          value="' + $('#transmgmtid').val() + '"  type="hidden" />');
        $dia_edit_auth_pat_form.append('<input name="saveType"       value="2" type="hidden" />');

        /* Create table to layout fields */

        let $frmTable = $('<table></table>');
        
        // Patient Name

        let $frmRow1 = $('<tr></tr>');
        let $formRow1Col1 = $('<td></td>');
        let $formRow1Col2 = $('<td></td>');
        let $formRow1Col3 = $('<td><em style="font-size:.75em">Please note that changes made here to school and home place assignments are saved but not shown until the route data is reloaded.</em></td>');
        let $lblPatName = $('<label>Patient &nbsp;</label>');
        let $patName = $('<span class="mba-entity-dia-inline-label">' + rowData.patName + '</span>');

        $formRow1Col1.append($lblPatName);
        $formRow1Col2.append($patName);
        
        $frmRow1.append($formRow1Col1);
        $frmRow1.append($formRow1Col2);
        $frmRow1.append($formRow1Col3);
        // Site Place

        let $frmRow2 = $('<tr></tr>');
        let $formRow2Col1 = $('<td></td>');
        let $formRow2Col2 = $('<td></td>');
        let $formRow2Col3 = $('<td></td>');

        let $lblSitePlace = $('<label>Select School Place &nbsp;</label>');
        let $sitePlace = $('<input id="sitePlaceSel" name="sitePlaceSel" title="Select School Place" class="mba-web-ui-field-simple" type="text"/>');
        let $sitePlaceID = $('<input id="sitePlaceID" name="sitePlaceID"  type="hidden" />');
        let $siteAddress = $('<span class="mba-entity-dia-inline-label"></span>');

        $formRow2Col1.append($lblSitePlace);
        $formRow2Col2.append($sitePlace);
        $formRow2Col2.append($sitePlaceID);
        $formRow2Col3.append($siteAddress);

        $frmRow2.append($formRow2Col1);
        $frmRow2.append($formRow2Col2);
        $frmRow2.append($formRow2Col3);

        // Home Place

        let $frmRow3 = $('<tr></tr>');
        let $formRow3Col1 = $('<td></td>');
        let $formRow3Col2 = $('<td></td>');
        let $formRow3Col3 = $('<td></td>');

        let $lblHomePlace = $('<label>Select Home Place &nbsp;</label>');
        let $homePlace = $('<input id="homePlaceSel" name="homePlaceSel" title="Select Home Place" class="mba-web-ui-field-simple" type="text"/>');
        let $homePlaceID = $('<input id="homePlaceID" name="homePlaceID"  type="hidden" />');
        let $homeAddress = $('<span class="mba-entity-dia-inline-label"></span>');

        $formRow3Col1.append($lblHomePlace);
        $formRow3Col2.append($homePlace);
        $formRow3Col2.append($homePlaceID);
        $formRow3Col3.append($homeAddress);

        $frmRow3.append($formRow3Col1);
        $frmRow3.append($formRow3Col2);
        $frmRow3.append($formRow3Col3);

        // Other Places

        let $frmRow4 = $('<tr></tr>');
        let $formRow4Col1 = $('<td></td>');
        let $formRow4Col2 = $('<td></td>');

        let $lblOtherPlaces = $('<label>Other Places &nbsp;</label>');
        let $newPlace = $('<i class="route-icon fas fa-plus" title="Add New Place"></i>');
        let $editPlace = $('<i class="route-icon fas fa-pencil-alt ml-3" title="Edit or Delete Places"></i>');
        let $divPlaces = $('<div></div>');

        $formRow4Col1.append($lblOtherPlaces);
        $formRow4Col2.append($newPlace);
        $formRow4Col2.append($editPlace);

        $frmRow4.append($formRow4Col1);
        $frmRow4.append($formRow4Col2);

        $frmTable.append($frmRow1);
        $frmTable.append($frmRow2);
        $frmTable.append($frmRow3);
        $frmTable.append($frmRow4);

        /* Append to form */

        $dia_edit_auth_pat_form.append($frmTable);
        $dia_edit_auth_pat_form.append($divPlaces);

        /* Site and Home Place dropdowns */

        let sitePlacesURL = '<%=Spedmon.SitePlaces.URL_VIEW_SEL_BASE()%>';
        let sitePlacesNVP = [
            { name: "clientid", value: $('#' + PARM_NAME_CLIENT_ID).val() }
            , { name: "patid", value: rowData.patID }
        ];

        $($sitePlace).spedmonSelectBox({
            dataParmType: "DOM"
            , selectAll: true
            , selectType: ($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX)
            , onSelect: function (event, ui) {
                $($siteAddress).html(ui.item.recData1);
                $($sitePlaceID).val(ui.item.recData2);
            }
            , ajaxopts: { url: (sitePlacesURL), data: "", namevalues: sitePlacesNVP, getnamevaluesfn: null }
        });

        let homePlacesURL = '<%=Spedmon.PatientPlaces.URL_VIEW_SEL_BASE()%>';

        $($homePlace).spedmonSelectBox({
            dataParmType: "DOM"
            , selectAll: true
            , selectType: ($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX)
            , onSelect: function (event, ui) {
                $($homeAddress).html(ui.item.recData1);
                $($homePlaceID).val(ui.item.recData2);
            }
            , ajaxopts: { url: (homePlacesURL), data: "", namevalues: sitePlacesNVP, getnamevaluesfn: null }
        });

        // icon click events
        
        $($newPlace).on('click', function () {
            fnOpenSubPagePatPlaceMgmtUrl('<%=addNewPlaceURL%>', rowData, $divPlaces);
        });
        $($editPlace).on('click', function () {
            fnOpenSubPagePatPlaceMgmtUrl('<%=editPlacesURL%>', rowData, $divPlaces);
        });

        // append form to dialog
        $dia_edit_auth_pat.append($dia_edit_auth_pat_form);

        // initiate dialog
        $dia_edit_auth_pat.dialog({
            width: ($(window).width() * .8)
            , height: ($(window).height() * .8)
            , resizable: true
            , modal: true
            , title: 'Edit Authorized Patient Data'
            , show: {
                effect: 'slide'
                , direction: 'left'
                , complete: function () {
                    // preload values
                    $($sitePlaceID).val(rowData.sitePlaceID);
                    $('#sitePlaceSel_selection').val(rowData.siteName);
                    $($siteAddress).html(rowData.siteAddress);

                    $($homePlaceID).val(rowData.homePlaceID);
                    $('#homePlaceSel_selection').val(rowData.homeName);
                    $($homeAddress).html(rowData.homeAddress);

                    fnGetPatPlacesInfo($divPlaces, rowData);

                    return;
                }
            }
            , hide: {
                effect: 'slide'
                , direction: 'left'
            }
            , close: function () {
                $dia_edit_auth_pat.remove();
            }
            , buttons: {
                Cancel: function () { $($dia_edit_auth_pat).dialog("close"); }
                , Save: function () {
                    let data = $.spedmonWebUI.formParmsToJSON($dia_edit_auth_pat_form);
                    let reqUrl = '<%=Spedmon.TransportationMgmtAuthorizedPatients.URL_SAVE_BASE()%>';
                    let reqData = data;
                    
                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                        .then(responseData => {
                            if (responseData.rawData.recordID == 0) {
                                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                            }

                            $dia_edit_auth_pat.dialog("close");
                            return true;
                        })
                        .catch(responseData => {
                            $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                            return true;
                        });
                }
            }
        });

        return;
    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function updateAdditionalViewParameterValuesAndRequestViewFromServer(e) {
        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_TRANS_MGMT_ID = $('#' + PARM_NAME_TRANS_MGMT_ID).val();
        let VALUE_PARM_ROUTE_ID = $('#' + PARM_NAME_ROUTE_ID).val();
        let VALUE_ACTIVE = '1';

        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_TRANS_MGMT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_TRANS_MGMT_ID, VALUE_TRANS_MGMT_ID);
        let NV_ROUTE_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ROUTE_ID, VALUE_PARM_ROUTE_ID);
        let NV_ACTIVE = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);

        let NV_ORGANIZATION_ID_DELETE = MBA.RestViewCommon.fnCreateNameValueObject('organizationID', VALUE_CLIENT_ID);
        let NV_OWNDER_ID_DELETE = MBA.RestViewCommon.fnCreateNameValueObject('ownerID', $ownerID);
        let NV_GROUP_ID_DELETE = MBA.RestViewCommon.fnCreateNameValueObject('groupID', routeInfo.id);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_TRANS_MGMT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ROUTE_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_TRANS_MGMT_ID);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_ROUTE_ID);

        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_ORGANIZATION_ID_DELETE);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_OWNDER_ID_DELETE);
        $($restViewCtrl).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_GROUP_ID_DELETE);

        $($restViewCtrl).MBA_RestView('requestViewFromServer', 1);
    };

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    function initView() {

        let opts = {};
        opts.enableScrollView = true;
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = false;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = true;
        opts.enableRowControlRecEdit = true;
        opts.enableRowControlRecDelete = true;

        opts.saveModeAddNew = 'custom';
        opts.baseUrlAddNew = '<%=Spedmon.TransportationMgmtAuthorizedRouteMembers.URL_SAVE_BASE()%>';
        opts.baseUrlAddNewHasParameters = true;
        opts.handlerFnAddNewCustom = function (uiActionObj) {            
            fnLaunchAddMemberToRoute(uiActionObj);
        };

        opts.saveModeEdit = 'inline';
        opts.baseUrlEdit = '<%=Spedmon.TransportationMgmtAuthorizedRouteMembers.URL_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters   = true;
        opts.refreshViewAfterInlineEditProceed = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '<%=Spedmon.TransportationMgmtAuthorizedRouteMembers.URL_DELETE_BASE()%>';
        opts.baseUrlDeleteHasParameters = true;
        opts.recIDNameForDelete = 'entityID';

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.TransportationMgmtAuthorizedRouteMembers.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.TransportationMgmtAuthorizedRouteMember.DEFAULT_PAGING_ORDER%>';

        opts.enableReports = false;
        opts.enableReportHtml = false;
        opts.enableReportXls = false;
        opts.enableReportPdf = false;

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
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'organizationID'
            , sortUsing: 'clientID'
        });

        opts.fieldDefinitions.push({
            name: 'ownerID'
            , label: 'Owner ID'
            , toolTip: 'Owner ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'ownerID'
            , sortUsing: 'ownerID'
        });

        opts.fieldDefinitions.push({
            name: 'groupID'
            , label: 'Group ID'
            , toolTip: 'Group ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'groupID'
            , sortUsing: ''
        });

        opts.fieldDefinitions.push({
            name: 'patID'
            , label: 'Pat ID'
            , toolTip: 'Pat ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'entityID'
            , sortUsing: ''
        });

        opts.fieldDefinitions.push({
            name: 'selectAmPm'
            , label: 'AM PM'
            , toolTip: 'AM PM'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'selectAmPm'
            , sortUsing: ''
        });

        opts.fieldDefinitions.push({
            name: 'weekDaysJSON'
            , label: 'Days'
            , toolTip: 'Days'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'weekDaysJSON'
            , sortUsing: ''
        });

        opts.fieldDefinitions.push({
            name: 'origPlaceID'
            , label: 'Orig Place ID'
            , toolTip: 'Orig Place ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'origPlaceID'
            , sortUsing: ''
        });

        opts.fieldDefinitions.push({
            name: 'destPlaceID'
            , label: 'Dest Place ID'
            , toolTip: 'Dest Place ID'
            , visible: false
            , editable: false
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: 'destPlaceID'
            , sortUsing: ''
        });

        opts.fieldDefinitions.push({
            name: 'patName'
            , label: 'Student'
            , toolTip: 'Student'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'patName'
        });

        <%/* Setup autocomplete - Basics */%>

        let origPlaceAdditionalCellValueFieldDefinitions = [];

        origPlaceAdditionalCellValueFieldDefinitions.push({
            name: 'origAddress'
            , label: 'Orig Address'
            , toolTip: 'Orig Address'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: ''
        });

        let origPlaceIdOpts = {};
        origPlaceIdOpts.baseUrl = '<%=Spedmon.TransportationMgmtPlaces.URL_VIEW_SEL_BASE()%>';
        origPlaceIdOpts.loadMode = 'mbaviewsel';
        origPlaceIdOpts.getInitialSelectedNameFrom = 'origName';

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        origPlaceIdOpts.fnOnSelect = function (event, ui) {
            let $addressSel = $(event.target)[0];
            let addressSelRefObj = $($addressSel).data(ADDRESS_DETAILS_REF);
            let $origPlaceID = $(addressSelRefObj.rowRef).find('td[' + CONST_FIELD_NAME + '="origPlaceID"]')
                .find('input[' + CONST_FIELD_NAME + '="origPlaceID"]');
            $($origPlaceID).val(ui.item.recData2);

            fnUpdateAddressDisplay($addressSel, 'origAddress', ui.item);
            fnUpdateDistanceCol($addressSel);
        };

        <%/* Setup autocomplete - Customization Hooks  */%>

        origPlaceIdOpts.fnModifyRequestNvps = function (nvpsIn) {
            // our dropdowns need patid, currently we have it as entityID
            let patidObj = nvpsIn.find(e => e.name == 'entityID');

            if (patidObj) {
                nvpsIn.push({
                    name: 'patid'
                    , value: patidObj.value
                });
                nvpsIn.push({
                    name: 'placeid'
                    , value: ''
                });
            }

            return nvpsIn;
        };
        origPlaceIdOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
        origPlaceIdOpts.fnModifyRenderItem = function ($ul, item, $li) {            
            var ctxt1 = $('<br><sup>' + item.recData2 + '</sup>');
            $($li).children('a').append(ctxt1);
            return $li;            
        };
        origPlaceIdOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'origPlaceIDSel'
            , label: 'Pick Up<br />Location'
            , toolTip: 'Pick Up Location'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: false
            , saveUsing: ''
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: origPlaceIdOpts
            , sortUsing: 'origName'
            , showMore: false
            , additionalCellValueFieldDefinitions: origPlaceAdditionalCellValueFieldDefinitions
        });

        <%/* Setup autocomplete - Basics */%>

        let destPlaceAdditionalCellValueFieldDefinitions = [];

        destPlaceAdditionalCellValueFieldDefinitions.push({
            name: 'destAddress'
            , label: 'Dest Address'
            , toolTip: 'Dest Address'
            , visible: false
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: ''
        });

        let destPlaceIdOpts = {};
        destPlaceIdOpts.baseUrl = '<%=Spedmon.TransportationMgmtPlaces.URL_VIEW_SEL_BASE()%>';
        destPlaceIdOpts.loadMode = 'mbaviewsel';
        destPlaceIdOpts.getInitialSelectedNameFrom = 'destName';

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        destPlaceIdOpts.fnOnSelect = function (event, ui) {
            let $addressSel = $(event.target)[0];
            let addressSelRefObj = $($addressSel).data(ADDRESS_DETAILS_REF);
            let $destPlaceID = $(addressSelRefObj.rowRef).find('td[' + CONST_FIELD_NAME + '="destPlaceID"]')
                .find('input[' + CONST_FIELD_NAME + '="destPlaceID"]');
            $($destPlaceID).val(ui.item.recData2);
            
            fnUpdateAddressDisplay($addressSel, 'destAddress', ui.item);
            fnUpdateDistanceCol($addressSel);
        };

        <%/* Setup autocomplete - Customization Hooks  */%>

        destPlaceIdOpts.fnModifyRequestNvps = function (nvpsIn) {
            // our dropdowns need patid, currently we have it as entityID
            let patidObj = nvpsIn.find(e => e.name == 'entityID');

            if (patidObj) {
                nvpsIn.push({
                    name: 'patid'
                    , value: patidObj.value
                });
                nvpsIn.push({
                    name: 'placeid'
                    , value: ''
                });
            }

            return nvpsIn;
        };
        destPlaceIdOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
        destPlaceIdOpts.fnModifyRenderItem = function ($ul, item, $li) {            
            var ctxt1 = $('<br><sup>' + item.recData2 + '</sup>');
            $($li).children('a').append(ctxt1);
            return $li;            
        };
        destPlaceIdOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'destPlaceIDSel'
            , label: 'Drop Off<br />Location'
            , toolTip: 'Drop Off Location'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: false
            , saveUsing: ''
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: destPlaceIdOpts
            , sortUsing: 'destName'
            , showMore: false
            , additionalCellValueFieldDefinitions: destPlaceAdditionalCellValueFieldDefinitions
        });

        opts.fieldDefinitions.push({
            name: 'busNum'
            , label: 'Bus Number'
            , toolTip: 'Bus Number'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'busNum'
        });

        opts.fieldDefinitions.push({
            name: 'distanceMilesStr'
            , label: 'Miles'
            , toolTip: 'Miles'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: ''
            , sortUsing: 'distanceMiles'
        });

        <%/* Setup checkboxes JSON - Customization Hooks  */%>

        let weekDaysOpts = {};
        weekDaysOpts.legend = '';
        weekDaysOpts.showLegend = false;
        weekDaysOpts.selections = [
            { name: 'mon', value: true, label: 'Mon' }
            , { name: 'tue', value: true, label: 'Tue' }
            , { name: 'wed', value: true, label: 'Wed' }
            , { name: 'thur', value: true, label: 'Thur' }
            , { name: 'fri', value: true, label: 'Fri' }
        ];

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'weekDaysJSON'
            , label: 'Days'
            , toolTip: 'Days'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , saveUsing: 'weekDaysJSON'
            , isRecID: false
            , dataType: 'checkboxselectionsjson'
            , dataTypeOptions: weekDaysOpts
            , sortUsing: 'weekDaysJSON'
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Parameters for our pat dropdowns (hidden) %>
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
            name: 'patdatasource'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'patdatasource'
            , showMore: false
        });

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

        opts.fieldDefinitions.push({
            name: 'active'
            , isActiveFlag: true
            , saveable: false
            , saveUsing: 'active'
        });

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.fnCreateNewCellAfter = function ($newCell, subsection, rowType, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, $newCellValue, addCellValRefs, addCellValRefsMap) {
            if (fieldDefinition.name === PARM_NAME_CLIENT_ID) {
                let clientIDVal = $('#' + PARM_NAME_CLIENT_ID).val();
                $($newCellValue).val(clientIDVal);
            }

            if (fieldDefinition.name === 'ownerID') {
                $($newCellValue).val($ownerID);
            }

            if (fieldDefinition.name === 'groupID') {
                $($newCellValue).val(routeInfo.id);
            }
            
            if (fieldDefinition.name === 'busNum') {
                let busNumber = routeInfo.context1;
                $($newCellValue).html(busNumber);
            }

            if (fieldDefinition.name === 'origPlaceIDSel') {
                let $rowRef = $(newRow)[0];
                let $addressDisplay = $('<div class="' + ADDRESS_DISPLAY_CLASS + ' mt-2">' + rowData.origAddress + '</div>');
                $($newCell).append($addressDisplay);

                /* Create an object we can reference if there are changes made */

                let addressDisplayRefObj = {};
                addressDisplayRefObj.rowRef = $rowRef
                addressDisplayRefObj.addCellValRefs = addCellValRefs;
                addressDisplayRefObj.addCellValRefsMap = addCellValRefsMap;

                /* Save this object */

                let $addressSelFldSet = $($newCellValue);
                let $addressSel = $($addressSelFldSet).children('input')[0];

                $($addressSel).data(ADDRESS_DETAILS_REF, addressDisplayRefObj);
            }

            if (fieldDefinition.name === 'destPlaceIDSel') {
                let $rowRef = $(newRow)[0];
                let $addressDisplay = $('<div class="' + ADDRESS_DISPLAY_CLASS + ' mt-2">' + rowData.destAddress + '</div>');
                $($newCell).append($addressDisplay);

                /* Create an object we can reference if there are changes made */

                let addressDisplayRefObj = {};
                addressDisplayRefObj.rowRef = $rowRef
                addressDisplayRefObj.addCellValRefs = addCellValRefs;
                addressDisplayRefObj.addCellValRefsMap = addCellValRefsMap;

                /* Save this object */

                let $addressSelFldSet = $($newCellValue);
                let $addressSel = $($addressSelFldSet).children('input')[0];

                $($addressSel).data(ADDRESS_DETAILS_REF, addressDisplayRefObj);
            }

            if (fieldDefinition.name === 'patName') {
                $($newCellValue).append('<i class="fas fa-user-edit ml-2" title="Edit Authorized Patient Data"></i>').addClass('d-flex');
                $($newCell).find('i.fa-user-edit').on('click', function () {
                    fnEditAuthPatData(rowData);
                });
            }

            return $newCell;
        };

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    }

    /*---------------------------------------------------------------------------------------------------------------------------------*/

    $(document).ready(function () {
        $dataManagementRows = $('#dataManagementRows');
        $restViewCtrl = $('#restView');
        initView();

        $($dataManagementRows).on('spedmoninputdata', function (e) {
            updateAdditionalViewParameterValuesAndRequestViewFromServer(e);
        });

        /* Event listeners for the icons */

        // route specific icons
        $('#dupRouteBut').on('click', fnDupRoute);
        $('#dupRouteReverseBut').on('click', fnDupRouteReverse);
        $('#printRouteSheetSingleBut').on('click', fnPrintRouteSheetSingle);
        $('#removeRouteBut').on('click', fnRemoveRoute);
        $('#editRouteBut').on('click', fnEditRoute);
        $('#sortMembersBut').on('click', fnSortMembers);

        // global icons
        $('#addNewRouteBut').on('click', fnAddNewRoute);
        $('#printRouteSheetsBut').on('click', fnPrintRouteSheets);
        $('#addNewSiteBut').on('click', fnAddNewSite);

    });

</script>