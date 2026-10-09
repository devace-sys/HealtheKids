var addCaseload = false;

// If practitioner selected, remove all existing rows
function emptyTableRows(resetPrac) {
    if ($('#tblSvcRecsForDOSJSONBody').children().length > 0) clearSvcRecsTable(true);
    if (resetPrac == true) {
        $('#pracid').val('');
        $('#pracid_selection').val('');
    }
}

// Add patients from caseload to the table
function doAddCaseload() {
    if (!$('#pracid').val() || $('#pracid').val() == "0") {
        $.spedmonWebUI.dialogMessage('ERROR', "No practitioner has been selected!", null, 400, 200, null, null, null);
        return;
    }
    addCaseload = true;
    addGrp();
    addCaseload = false;
}

// Adds a single patient to the table
function addPat(event, ui) {
    if (!$('#pracid').val() || $('#pracid').val() == "0") {
        $.spedmonWebUI.dialogMessage('ERROR', "No practitioner has been selected!", null, 400, 200, null, null, null);
        return;
    }

    // handle multi date if needed
    let dosMulti = $('#dossvcs').val();

    if (dosMulti) {
        let _dosArray = dosMulti.split(',');
        _dosArray.sort();
        _dosArray.reverse();

        $.each(_dosArray, function (_idx, _dosElem) {
            SpEdCare.svcrecOnDos.addSvcRec({
                  'patID'  : ui.item.id
                , 'patName': ui.item.label
                , 'dosStr' : _dosElem
            });
        });

    }
    else {
        SpEdCare.svcrecOnDos.addSvcRec({
              'patID'  : ui.item.id
            , 'patName': ui.item.label
            , 'dosStr' : $('#dos').val()
        });
    }
}

// removes all records from the table
function clearSvcRecsTable(skipDialog) {
    SpEdCare.svcrecOnDos.clearScvRecs(skipDialog);
}

// begins a live session with patients selected in the table
function beginLiveGroupSession() {
    SpEdCare.svcrecOnDos.beginLiveGroupSession();
}

// Add records based on the selected group
function addGrp(event, ui) {
    var tkn = $.spedmonWebUI.token;
    var cltid = $('#clientid').val();
    var prcid = $('#pracid').val();
    var iep = '';
    var refDate = '';
    var nameID = '';
    var grpid = (ui) ? ui.item.id : prcid;

    var entireCaseload = addCaseload;

    /****** set up ajax url ***********/

    // for caseload
    if (entireCaseload == true) {
        grpid = prcid;
        reqUrl = "practitioner_caseload_members.asmx/viewSelWithMtdYtdTots?tkn=" + tkn;
        reqData = "{'organizationID':'" + cltid + "','ownerID':'" + prcid + "','groupID':'" + grpid + "','term':'" + '' + "','iep':'" + iep + "','nameID':'" + nameID + "','refDate':'" + refDate + "'}";
    }

    // for group
    else {
        var reqUrl = "practitioner_patient_group_members.asmx/viewSelWithMtdYtdTots?tkn=" + tkn;
        var reqData = "{'organizationID':'" + cltid + "','ownerID':'" + prcid + "','groupID':'" + grpid + "','term':'" + '' + "','iep':'" + iep + "','nameID':'" + nameID + "','refDate':'" + refDate + "'}";
    }

    // objects to be returned from ajax
    var Patients = null;

    // success callback for ajax
    fnProcRespSuccess = function (rd) {
        Patients = rd.SelRecs;

        // add patient rows
        if (Patients) {
            // correct viewsel object
            $.each(Patients, function (_idx, _patObj) {
                // set up object to follow our _SvcRecs interface
                _patObj.patName  = _patObj.label;
                _patObj.dosStr   = $('#dos').val();
                _patObj.patID    = _patObj.id;
            });

            SpEdCare.svcrecOnDos.addMultipleRecs(Patients);
        };
    };

    $.spedmonWebUI.ajax(null
        , reqUrl
        , reqData
        , 'json'
        , null
        , null
        , null
        , null
        , 0
        , fnProcRespSuccess
        , null
        , null);

    return;
}

// Add records based on the selected scheduled group
function addGrpScheduled(event, ui) {

    // function to append group memebers to table
    let _appendGrpData = function () {
        let tkn = $.spedmonWebUI.token;

        /****** set up ajax url ***********/

        let reqUrl = "practitioner_caseload_members.asmx/viewListExpectedTmtSvcsOnDos?tkn=" + tkn;
        let reqData = "{ 'clientid' : " + $('#clientid').val() + ", 'pracid' : " + $('#pracid').val() + ", 'dos' : '" + $('#dos').val() + "', 'pracpatgroupid' : " + ui.item.id + "}";

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                // add patient rows
                if (responseData.rawData.data.length && responseData.rawData.data.length > 0) {
                    SpEdCare.svcrecOnDos.addMultipleRecs(responseData.rawData.data);
                };
            })
            .catch(responsedata => {
            });
    }

    // confirm with user if they want to delete all records before adding group

    var onYes = function () {
        clearSvcRecsTable(true);

        _appendGrpData();
    };   

    if ($('#tblSvcRecsForDOSJSONBody').children().length > 0) $.spedmonWebUI.dialogConfirm("Please Confirm", "Do you want to replace the current list of scheduled services with the chosen group? If no, this group will be added to the existing list.", onYes, _appendGrpData);
    else _appendGrpData();
    return;
}

// Copy the input into all rows
function copyValForAllRows(elem) {
    // get selector for selected button
    $butSelector = $(elem);

    SpEdCare.svcrecOnDos.copyValForAllRows($butSelector);
}

// Set prac groupID when practitioner is selected
function setGroupID(event, ui) {
    emptyTableRows(false);

    $('#pracgroupid').val(ui.item.recData1);
}

