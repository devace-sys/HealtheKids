<%@ Page Language="C#" CodeBehind="user_all_practitioner_patient_group_save.aspx.cs" Inherits="Spedmon.UserAllPractitionerPatientGroupSave" %>

<%if (clientAndPracAreOK == true) {%>
<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>
<fieldset class="m-3 border rounded p-4">
    
    <legend class="text-center font-italic txtprcpatnewgrp" ></legend>   
    <form id="frmnewGrpSave">

        <Spedmon:HiddenInput ID="clientid" name="clientid" title="clientid" runat="server" />
        <Spedmon:HiddenInput ID="pracid" name="pracid" title="pracid" runat="server" />        
        <Spedmon:HiddenInput ID="groupid" name="groupid" title="groupid" runat="server" />
        <Spedmon:HiddenInput ID="savetype" name="savetype" title="savetype" runat="server" />
        <Spedmon:HiddenInput ID="recid" name="recid" title="recid" runat="server" />
        <Spedmon:HiddenInput ID="patid" name="patid" title="patid" runat="server" />

        <%//-----------------------------------------------------------------------------%>
        <%// Group's Name %>
        <%//-----------------------------------------------------------------------------%>

        <Spedmon:DataEntryRow rowLabel="Enter Group Name" runat="server">
            <Spedmon:DataEntryBoxText ID="groupName" name="groupName" label="Name of the Group" title="Please enter the name of the group" floatingLabel="true" size="30" showCharCountMeter="false" runat="server" />
        </Spedmon:DataEntryRow>


        <%//-----------------------------------------------------------------------------%>
        <%// Select Dates of Service %>
        <%//-----------------------------------------------------------------------------%>

        <Spedmon:DataEntryRow rowLabel="Select Date(s) Of Service" runat="server">
            <Spedmon:HiddenInput ID="recurring" name="recurring" title="Recurring Service?" runat="server" />
            <br />
            <Spedmon:DataEntryBoxDate ID="startdate" name="startdate" label="Date Services Start" title="Enter start date" runat="server" />
            <Spedmon:DataEntryBoxDate ID="enddate" name="enddate" label="Date Services End" title="Enter end date" runat="server" />
        </Spedmon:DataEntryRow>

        <%//-----------------------------------------------------------------------------%>
        <%// Select Plan Type %>
        <%//-----------------------------------------------------------------------------%>

        <Spedmon:DataEntryRow rowLabel="Select Service Plan Type" runat="server">
            <Spedmon:DataEntryBoxSelect ID="svcnameslistdatasourceid" name="svcnameslistdatasourceid" label="Plan Type" title="Select what type of plan this service is part of" fireSpedmonInput="true" runat="server" />
        </Spedmon:DataEntryRow>

        
        <%//-----------------------------------------------------------------------------%>
        <%// Select Service %>
        <%//-----------------------------------------------------------------------------%>

        <Spedmon:DataEntryRow rowLabel="Select Service" runat="server">
            <Spedmon:SelectYesOrNo ID="viatelehealth" name="viatelehealth" title="Telehealth Service?" runat="server" />
            <br />
            <Spedmon:HiddenInput ID="dos" name="dos" title="dos" runat="server" />
            <Spedmon:HiddenInput ID="isiep" name="isiep" title="isiep" runat="server" />
            <Spedmon:HiddenInput ID="altmodalitynameid" name="altmodalitynameid" title="altmodalitynameid" runat="server" />           

        </Spedmon:DataEntryRow>

        <Spedmon:DataEntryRow rowLabel="Select Service" runat="server">
            <Spedmon:DataEntryBoxSelect ID="nameid" name="nameid" title="nameid" label="Service?" fireSpedmonInput="true" runat="server" />
        </Spedmon:DataEntryRow>

        <Spedmon:DataEntryRow rowLabel="Service Minutes, Days (if applicable) and Times (times are optional)" runat="server">
            <Spedmon:DataEntryBoxNumber size="12" ID="nummins" name="nummins" min="0" label="Number of Minutes Per Day" title="Enter minutes" runat="server" />
                <br>
            <%//-----------------------------------------------------------------------------%>
            <%// Recurring Schedule %>
            <%//-----------------------------------------------------------------------------%>

            <table id="recurring-options" class="table table-borderless table-sm">
                <thead>
                <tr>
                <th class="text-center">Mon</th> <!-- col -->
                <th class="text-center">Tue</th> <!-- col -->
                <th class="text-center">Wed</th> <!-- col -->
                <th class="text-center">Thu</th> <!-- col -->
                <th class="text-center">Fri</th> <!-- col -->
                </tr>
                </thead>
                <tbody>
                <tr>
                <td class="text-center"><Spedmon:CheckBox ID="mon" name="mon" title="Service Provided?" runat="server" /></td> <!-- col -->
                <td class="text-center"><Spedmon:CheckBox ID="tue" name="tue" title="Service Provided?" runat="server" /></td> <!-- col -->
                <td class="text-center"><Spedmon:CheckBox ID="wed" name="wed" title="Service Provided?" runat="server" /></td> <!-- col -->
                <td class="text-center"><Spedmon:CheckBox ID="thu" name="thu" title="Service Provided?" runat="server" /></td> <!-- col -->
                <td class="text-center"><Spedmon:CheckBox ID="fri" name="fri" title="Service Provided?" runat="server" /></td> <!-- col -->
                </tr>
                <tr>
                <td class="text-center"><Spedmon:DataEntryBoxTime size="8" ID="monstarttime" name="monstarttime" label="Time" runat="server"/></td> <!-- col -->
                <td class="text-center"><Spedmon:DataEntryBoxTime size="8" ID="tuestarttime" name="tuestarttime" label="Time" runat="server"/></td> <!-- col -->
                <td class="text-center"><Spedmon:DataEntryBoxTime size="8" ID="wedstarttime" name="wedstarttime" label="Time" runat="server"/></td> <!-- col -->
                <td class="text-center"><Spedmon:DataEntryBoxTime size="8" ID="thustarttime" name="thustarttime" label="Time" runat="server"/></td> <!-- col -->
                <td class="text-center"><Spedmon:DataEntryBoxTime size="8" ID="fristarttime" name="fristarttime" label="Time" runat="server"/></td> <!-- col -->
                </tr>
                </tbody>
            </table> 


        </Spedmon:DataEntryRow>

        <%//-----------------------------------------------------------------------------%>
        <%// Notes %>
        <%//-----------------------------------------------------------------------------%>

        <Spedmon:DataEntryRow rowLabel="Schedule Entry Notes" runat="server">
            <Spedmon:DataEntryBoxTextArea ID="notes" name="notes" label="Notes" floatingLabel="true" size="25" runat="server" showCharCountMeter="false" />
        </Spedmon:DataEntryRow>  

        <div class="col-12"> 
            <div class="mt-4 d-flex justify-content-center">
                <Spedmon:DataEntryButton ID="btnPractPatCreateNewGroup" style="PRIMARY" cssClass="w-75" fireSpedmonInput="false" title="Save New Group" onclick="doSavePracPatGrp()"  runat="server"/>
            </div>
        </div> <!-- col -->
        
    </form>
    
</fieldset>
<%//##################################################################################################################%>
<%//#                                         Data Entry Scripts  %>
<%//##################################################################################################################%>

<script type="text/javascript">   
    
    let savetype = null;

    function closeWindow(delay) {
        return new Promise((resolve) => {
            setTimeout(() => {
                window.close();
                resolve();
            }, delay);
        });
    }

    function buildNewGrpSaveFormData() {
        return {
            clientid: $('#clientid').val(),
            pracid: $('#pracid').val(),
            patselectedjson: $('#patid').val(),
            caseloadgrpid: $('#groupid').val(),
            savetype: $('#savetype').val(),
            recid: $('#recid').val(),
            groupName: $('#groupName').val(),
            recurring: $('#recurring').val(),
            startdate: $('#startdate').val(),
            starttime: "",
            enddate: $('#enddate').val(),
            svcnameslistdatasourceid: $('#svcnameslistdatasourceid').val(),
            viatelehealth: $('#viatelehealth').val(),
            dos: $('#dos').val(),
            isiep: $('#isiep').val(),
            altmodalitynameid: $('#altmodalitynameid').val(),
            nameid: $('#nameid').val(),
            nummins: $('#nummins').val(),
            mon: $('#mon').val(),
            tue: $('#tue').val(),
            wed: $('#wed').val(),
            thu: $('#thu').val(),
            fri: $('#fri').val(),
            monstarttime: $('#monstarttime').val(),
            tuestarttime: $('#tuestarttime').val(),
            wedstarttime: $('#wedstarttime').val(),
            thustarttime: $('#thustarttime').val(),
            fristarttime: $('#fristarttime').val(),
            notes: $('#notes').val()
        };
    }

    function fnAddMultiplePatientToGroup(strObj) {

        let groupID = $('#groupid').val();
        let pracID = $('#<%= Constants.PARM_PRACTITIONER_ID%>').val();
        let clientID = $('#<%=Constants.PARM_CLIENT_ID%>').val();
        let dataStr = JSON.stringify(strObj);
        let $btnSave = $('#btnPractPatCreateNewGroup');
        let $waitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner($btnSave);
        // send ajax to approve the service record
        let reqUrl = '<%=Spedmon.PractitionerPatientGroupMembers.GEN_URL_ASMX_SAVE_ALL()%>';
        let reqData = {};
        reqData["clientid"] = clientID;
        reqData["pracid"] = pracID;
        reqData["groupid"] = groupID;
        reqData["patselectedjson"] = dataStr;

        reqData = JSON.stringify(reqData);        
        // send ajax request
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($btnSave, $waitingIcon);
                $($btnSave).text('Creating Scheduled Services');
                fnManageServiceScheduled();
            })
            .catch(responseData => {
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($btnSave, $waitingIcon);
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
            });
    }

    function fnManageServiceScheduled() {
        let pracID = $('#<%= Constants.PARM_PRACTITIONER_ID%>').val();
        let clientID = $('#<%=Constants.PARM_CLIENT_ID%>').val();
        let data = buildNewGrpSaveFormData();
        let reqData = JSON.stringify(data);
        let reqUrl = '<%=Spedmon.PractitionerPatientScheduledServices.URL_SVC_SAVE_BASE_MULTIPLE()%>';
        let $btnSave = $('#btnPractPatCreateNewGroup');
        let $waitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner($btnSave);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($btnSave, $waitingIcon);
                let $newIcon = $('<i class="fas fa-check-circle fa-fw m-auto"></i>');
                $($btnSave).text('DONE!').append($newIcon);
                closeWindow(1000);
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($btnSave, $waitingIcon);
            });
    }

    function doSavePracPatGrp() {
        let data = buildNewGrpSaveFormData();
        let ids = $('#<%=Constants.PARM_PATIENT_ID%>').val();
        let savetype = $('#<%=Constants.PARM_SAVE_TYPE%>').val();
        let strPatIds = [];
        if(ids)
            strPatIds = JSON.parse(ids);

        let reqUrl = '<%= Spedmon.PractitionerPatientGroups.GEN_URL_ASMX_SAVE()%>';
        let reqData = JSON.stringify(data);
        let $btnSave = $('#btnPractPatCreateNewGroup');
        let $waitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner($btnSave);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($btnSave, $waitingIcon);
                $('#groupid').val(responseData.rawData.recordID);
                if (strPatIds.length > 0 && savetype == "1") {                    
                    $($btnSave).text('Adding Patients');
                    fnAddMultiplePatientToGroup(strPatIds);
                } else if (strPatIds.length > 0 && savetype == "2") {
                    $($btnSave).text('Updating Schedlued Services!');
                    fnManageServiceScheduled();
                } else {
                    $($btnSave).text('DONE!');
                    MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($btnSave, $waitingIcon);
                    closeWindow(1000);
                }
            })
            .catch(responseData => {
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($btnSave, $waitingIcon);
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
            });
    }

    function loadSvcNameSelect(plnType) {
        let reqDataObj = {};
        let reqURL = '<%= Spedmon.Services.URL_VIEW_SEL_TMT_BASE()%>';
        let cltid = $('#<%=Constants.PARM_CLIENT_ID%>').val();
        let prcid = $('#<%=Constants.PARM_PRACTITIONER_ID%>').val();
        let dos = $('#<%=Constants.PARM_DOS%>').val();

        reqDataObj['<%=Constants.PARM_CLIENT_ID%>'] = cltid;
        reqDataObj['<%=Constants.PARM_PRACTITIONER_ID%>'] = prcid;
        reqDataObj['<%=Constants.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID%>'] = plnType;
        reqDataObj['<%=Constants.PARM_DOS%>'] = dos;
        reqDataObj['<%=Constants.PARM_SEARCH_TERM%>'] = "";

        let reqDataJSON = JSON.stringify(reqDataObj);
        $('#nameid').empty();
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqDataJSON, null)
            .then(responseData => {
                if (responseData.rawData.SelRecs) {
                    $.each(responseData.rawData.SelRecs, function (idx, svc) {                        
                        $('#nameid').append(
                            '<option value="' + svc.recData4 + '" title="' + svc.label + '">' + svc.label + '</option>'
                        );
                    });
                }
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
            });
    }

    function fnIsNewGrpOrEditGrp() {
        let $tittle = $('.txtprcpatnewgrp');
        let saveType = $('#savetype').val();
        if (saveType === '<%= Spedmon.Constants.SAVE_TYPE_EDIT%>') {
            $tittle.text('<%= Spedmon.PractitionerPatientGroups.SEL_LABEL_EDIT%>');
        } else {
            $tittle.text('<%= Spedmon.PractitionerPatientGroups.SEL_LABEL_ADD_NEW%>');
        }
    }

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

$(document).ready(function () {

    fnIsNewGrpOrEditGrp();

    let $plnSelect = $('#<%= Constants.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID %>');
    let $service = $('#nameid').val();
    let $btnSave = $('#btnPractPatCreateNewGroup');
    savetype = $('#savetype').val();

    if ($plnSelect && $plnSelect.val() > 0 && !$service) {
        loadSvcNameSelect($plnSelect.val());
    }

    if (savetype === '2') {
        $($btnSave).text("Save Changes");
    } else {
        $($btnSave).text("Save New Group");
    }

    $plnSelect.on('change', function () {
        let plnType = $plnSelect.val();
        loadSvcNameSelect(plnType);
    });
});

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    
</script>
<%} %>
