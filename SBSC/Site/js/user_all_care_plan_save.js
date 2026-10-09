var SpEdCare = (SpEdCare || {});

SpEdCare.carePlanSave = (function ($) {

    'use strict';

    /*#################################################################################################
      #
      #                                  Global Data Structures
      #
      #################################################################################################*/

    var _opts = {};
    var _CarePlanRecs = new Map();
    var _initMode = true;

    /*#################################################################################################
      #
      #                                  Global Variables
      #
      #################################################################################################*/

    // used for dertermining the notesID of each row for the notes textarea
    const _notesIDPrefix                 = 'notes-for-';
    var _salt                            = 1; // used for table record id's
    const _inactiveInputCSSClass         = 'inactive-input';
    const _plusIconCSSClass              = 'plus-icon';
    const _participantsHiddenFieldsClass = 'carePlanParticipantsHiddenfieldsClass';
    const _renderDetsDialogButClass      = 'tblDetsDialogBut'; // class for render dialog buttons
    const _servicesAddRemButClass        = 'carePlanServicesAddRemIcon'; // class for plus or x icons on services tab
    const _servicesDeleteButClass        = 'carePlanServicesDeleteIcon'; // class for trash icons for deleting orders on services tab
    const _participantsAddRemButClass    = 'carePlanParticipantsRemIcon'; // class for plus or x icons on participants tab
    const _participantsSignatureButClass = 'carePlanParticipantsSignatureIcon'; // class for signature icons on participants tab
    const _servicesEditOrderButClass     = 'carePlanServicesEditRecIcon'; // class for pencil icons on services tab
    const _participantsSaveButClass      = 'carePlanParticipantsSaveRecIcon'; // class for pencil icons on services tab
    const _diagnosisRadioSelectionsName  = 'carePlanDiagnosisRadioSelectionsName'; // name for name radio input dropwdown selection of diagnosis tab
    const _diagnosisNameDisplayContID    = 'carePlanDiagnosisNameDisplayContID'; // id for name input dropwdown of diagnosis tab
    const _diagnosisNameInputID          = 'carePlanDiagnosisNameInputID'; // id for name input dropwdown of diagnosis tab
    const _diagnosisHiddenIDInputID      = 'carePlanDiagnosisHiddenIDInputID'; // id for id input dropwdown of diagnosis tab
    const _diagnosisDescInputID          = 'carePlanDiagnosisDescInputID'; // id for description input dropwdown of diagnosis tab
    const _textareaAttrHasMaxCharCounter = 'mba-textarea-has-char-counter'; // attribute for textareas that have character counters
    const _diagnosisDescCharCount        = 'carePlanDiagnosisDescCharCount'; // id for description input character counter
    const _servicesRecIDAttr             = 'carePlanServicesRecIDAttr';  // class for services table row attribute for recid
	const _servicesOrpRefDocID           = 'carePlanServicesRefDocIDAttr'; // class for services table row attribute for refid
    const _servicesOrpDocTypeAttr        = 'carePlanServicesOrpDocTypeAttr';  // class for services table row attribute for ORP document type
    const _servicesSelectedRowAttr       = 'carePlanServiceSelectedForPlan';  // class to indicate a row has been selected to be added to the plan
    const _serviceSelectionsTblID        = 'carePlanServiceSelectionsTbl';    // id for service selections table
    const _participantsRecIDAttr         = 'carePlanParticipantsRecIDAttr';  // class for participants table row attribute for recid
    const _participantsSelectedRowAttr   = 'carePlanParticipantSelectedForPlan';  // class to indicate a row has been selected to be added to the plan
    const _planParticipantsTblID         = 'carePlanParticipantsTbl';    // id for participants selections table
    const _participantsActionAttr        = 'carePlanParticipantsActionAttr'; // class for participants table row attribute for action
    const _signatureCanvasClass = 'carePlanSignatureCanvas'; // class for signature pad's canvas element
    const _pulsateAnimationClass = 'spedmon-animation-pulsate'; // used for pulsating effect
    const _diagnosisDescMaxLength = 4000;
    const _participantsHiddenParticipantFieldsJSONAttr = 'carePlanParticipantsHiddenFieldsJSONAttr'; // class for participants table row attribute for action
    const _docTypeOrders                 = 2;
    const _docTypeProfiles               = 3;
    const _defaulthiddenparticipantfieldsJSON = {
                address1: ''
                , address2: ''
                , city: ''
                , state: ''
                , zip5: ''
                , zip4: ''
                , fax: ''
                , additionalData1: ''
                , additionalData2: ''
            };
    const _parentRolesArray           = ["1000", "1001", "1002"];
    const _practitionersRolesArray    = ["5000", "5001", "5002"];
    const _otherSchoolStaffRolesArray = ["3003"];

    /*#################################################################################################
      #
      #                                  Private Methods
      #
      #################################################################################################*/

    /***************************************************************************
     * _createSvcRecKey  */
    /**
     * https://www.w3resource.com/javascript-exercises/javascript-math-exercise-23.php
     ***************************************************************************/

    function _createCarePlanRecKey() {
        var dt = new Date().getTime();
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = (dt + Math.random() * 16) % 16 | 0;
            dt = Math.floor(dt / 16);
            return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
        });
        return uuid;
    }

    // response callback for ajax
    var fnProcResp = function (rd) {
        $.spedmonWebUI.dialogMessage('Status', rd.message, null, 400, 200, null, null, null);
    };

    /***************************************************************************
     *  */
    /**
     * 
     ***************************************************************************/

    function _createCarePlanObj(patID, patName, id, planDate, diagnosisID, diagnosisName, diagnosisDesc, signedByPlanCreator, signedByPlanCreatorDate, planCreatorSignatureImg
        , orpDocSelectionsJSON, participantsJSON, createdBy, createdByLname, createdByFname, createdByEmail, createdByPhone) {
        var CarePlanObj = {};

        if (!patID                  )     patID                       = null;
        if (!patName                )     patName                     = null;
        if (!id                     )     id                          = null;
        if (!planDate               )     planDate                    = null;
        if (!diagnosisID            )     diagnosisID                 = null;
        if (!diagnosisName          )     diagnosisName               = null;
        if (!diagnosisDesc          )     diagnosisDesc               = null;
        if (!orpDocSelectionsJSON   )     orpDocSelectionsJSON        = null;
        if (!participantsJSON       )     participantsJSON            = null;
        if (!signedByPlanCreator    )     signedByPlanCreator         = null;
        if (!signedByPlanCreatorDate)     signedByPlanCreatorDate     = null;
        if (!planCreatorSignatureImg)     planCreatorSignatureImg     = null;
        if (!createdBy)                   createdBy                   = _opts.userID;
        if (!createdByLname)              createdByLname              = _opts.userLastName ;
        if (!createdByFname)              createdByFname              = _opts.userFirstName;
        if (!createdByEmail)              createdByEmail              = _opts.userEmail    ;
        if (!createdByPhone) createdByPhone = _opts.userPhone;

        // bool validation
        if (signedByPlanCreator == "0") signedByPlanCreator = false;
        else if (signedByPlanCreator == "1") signedByPlanCreator = true;

        
        // set default values
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValPatID]                       = '' + patID;
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValPatientName]                 = patName;
                                                                                      
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValSaveType]                    = (id) ? 2 : 1;
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValRecID]                       = id;
                                                                                      
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValDateOfService]               = planDate;
                                                                                       
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValDiagnosisID]                 = diagnosisID;
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValDiagnosisName]               = diagnosisName;
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValDiagnosisDesc]               = diagnosisDesc;
                                                                                      
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValServiceSelectionsJSON]       = orpDocSelectionsJSON;
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValParticipantsJSON]            = participantsJSON;
                                                                                     
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValPlanCreatorSigned]           = signedByPlanCreator;
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValPlanCreatorSignedDate]       = signedByPlanCreatorDate;
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValPlanCreatorSignatureImg]     = planCreatorSignatureImg;
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValCreatedBy]                   = createdBy;
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValCreatedByLname]              = createdByLname;
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValCreatedByFname]              = createdByFname;
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValCreatedByEmail]              = createdByEmail;
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValCreatedByPhone]              = createdByPhone;
        CarePlanObj[_opts.carePlanTableColCtrlDataAttrValHasUnsavedChanges]           = false;

        return CarePlanObj;
    }

    /***************************************************************************
     *  */
    /**
     * 
     ***************************************************************************/

    function _currentCarePlanRecsToArray() {
        let carePlanObjs = [];

        _CarePlanRecs.forEach(function (carePlanObj, _idx) {
            carePlanObjs.push(JSON.parse(JSON.stringify(carePlanObj)));
        });
        return carePlanObjs;
    }

    /***************************************************************************
     *  */
    /**
     * 
     ***************************************************************************/

    function _currentCarePlanRecsToJSON() {
        let CarePlanObjs = _currentCarePlanRecsToArray();
        return JSON.stringify(CarePlanObjs);
    }

    /***************************************************************************
     *  */
    /**
     * 
     ***************************************************************************/

    function _currentCarePlanRecsToTA() {
        let carePlanRecsJSON = _currentCarePlanRecsToJSON();
        $(_opts.carePlanRecsTextAreaSelector).val(carePlanRecsJSON);
    }

    /***************************************************************************
     *  */
    /**
     * 
     ***************************************************************************/

    function _CarePlanRecsDataToTA() {
        _currentCarePlanRecsToTA();
    };

    /***************************************************************************
     * _checkForUnsavedChanges */
    /**
     * checks an object for unsaved changes and pulsates save icon if any exist
     ***************************************************************************/
 
    function _checkForUnsavedChanges(RecKey) {
        var RecObj = _CarePlanRecs.get(RecKey);

        let hasUnsavedChanges = RecObj[_opts.carePlanTableColCtrlDataAttrValHasUnsavedChanges];
        let $saveIcon = $('tr[' + _opts.carePlanTableRowDataAttr + '="' + RecKey + '"]').find('i[' + _opts.carePlanTableColCtrlDataAttr + ' = "' + _opts.carePlanTableColCtrlDataAttrValSave + '"]');
 
        if (hasUnsavedChanges) {
            $saveIcon.addClass(_pulsateAnimationClass);
        } else {
            $saveIcon.removeClass(_pulsateAnimationClass);
        }
    }

    /***************************************************************************
     *  */
    /**
     * 
     ***************************************************************************/

    function _createCarePlanTableRowCommonMkup(carePlanObj, carePlanKey) {
        return '<tr ' + _opts.carePlanTableRowDataAttr + '="' + carePlanKey + '"></tr>';
    }

    /***************************************************************************
     * _createCarePlanTableColsCommonMkup */
    /**
     *
     ***************************************************************************/
    function _createCarePlanTableColsCommonMkup(recObj) {
        return '<td><div ' + _opts.carePlanTableColCtrlDataAttr + '=' + _opts.carePlanTableColCtrlDataAttrValPatientName + ' value="' + recObj["" + _opts.carePlanTableColCtrlDataAttrValPatientName] + '" />' + recObj["" + _opts.carePlanTableColCtrlDataAttrValPatientName] + '</td>'
            + '<td><input ' + _opts.carePlanTableColCtrlDataAttr + '=' + _opts.carePlanTableColCtrlDataAttrValDateOfService + ' value="' + recObj[_opts.carePlanTableColCtrlDataAttrValDateOfService] + '" type="date"/></td>'
            + '<td><button ' + _opts.carePlanTableColCtrlDataAttr + '=' + _opts.carePlanTableColCtrlDataAttrValDiagnosis    + ' class="' + _renderDetsDialogButClass + ' ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" type="button" title="View Details" role="button" aria-disabled="false"><i class="fas fa-edit"></i></button></td>'
            + '<td><button ' + _opts.carePlanTableColCtrlDataAttr + '=' + _opts.carePlanTableColCtrlDataAttrValServiceSelectionsJSON     + ' class="' + _renderDetsDialogButClass + ' ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" type="button" title="View Details" role="button" aria-disabled="false"><i class="fas fa-edit"></i></button></td>'
            + '<td><button ' + _opts.carePlanTableColCtrlDataAttr + '=' + _opts.carePlanTableColCtrlDataAttrValParticipantsJSON + ' class="' + _renderDetsDialogButClass + ' ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" type="button" title="View Details" role="button" aria-disabled="false"><i class="fas fa-edit"></i></button></td>';
    }

    /***************************************************************************
     * _updateCurrentCarePlansRecsForSpecificField */
    /**
     * updates an object in the json for a specific field
     ***************************************************************************/

    function _updateCurrentCarePlansRecsForSpecificField(key, val, whatField) {
        var carePlanObj = _CarePlanRecs.get(key);
        var originalVal = carePlanObj[whatField];
        carePlanObj[whatField] = val;

        // logic to pulsate save icon if the value being set is not "hasUnsavedChanges" (which means record needs to be saved)
        if (whatField != _opts.carePlanTableColCtrlDataAttrValHasUnsavedChanges && originalVal != val) {
            carePlanObj[_opts.carePlanTableColCtrlDataAttrValHasUnsavedChanges] = true;
        }
        _checkForUnsavedChanges(key);

        _CarePlanRecs.set(key, carePlanObj);
        _CarePlanRecsDataToTA();
    }

    /***************************************************************************
     *  */
    /**
     * 
     ***************************************************************************/

    function _addRecToCarePlanRecs(_CarePlanObj) {

        let _CarePlanRecKey = _createCarePlanRecKey(_CarePlanObj);

        if (_initMode === false) {
            if (_CarePlanRecs.has(_CarePlanRecKey)) return null;
        }

        _CarePlanRecs.set(_CarePlanRecKey, _CarePlanObj);

        _CarePlanRecsDataToTA();

        return _CarePlanRecKey;
    }

    /***************************************************************************
     *  */
    /**
     * 
     ***************************************************************************/

    function _removeRecFromRecs(key) {
        if (_CarePlanRecs.has(key) === false) return;
        _CarePlanRecs.delete(key);
        _CarePlanRecsDataToTA();
    }

    /***************************************************************************
     * _generateButtonElem */
    /**
     * generic function to produce a button element with an embedded icon
     ***************************************************************************/
    function _generateButtonElem(desc, classes, iconClass, callbackFunc) {
        let $okBut = $('<button class="' + classes + '" type="button" title="' + desc + '"><i class="' + iconClass + '"></i></button>');
        $okBut.on("click", callbackFunc);

        return $okBut;
    }

    /***************************************************************************
     * _generateAddRecordPlusIcon */
    /**
     * generates plus icon for dialog
     ***************************************************************************/
    function _generateAddRecordPlusIcon(callbackFunc) {
        let $plusIcon = $('<i id="addNewContact" class="fa fa-plus ' + _plusIconCSSClass + '" title="Add New Record"></i>');
        $plusIcon.on("click", callbackFunc);

        return $plusIcon;
    }

    /***************************************************************************
     *  */
    /**
     * 
     ***************************************************************************/

    function _drawCarePlanTableBodyRow(carePlanObj, carePlanKey) {
        let $_row = $(_createCarePlanTableRowCommonMkup(carePlanObj, carePlanKey));
        let $_tdRemove = $('<td></td>');
        let $_butRem = $('<i ' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValDelete + '" class="fa fa-trash-alt" title="Remove Record"></i>');
        $($_tdRemove).append($_butRem);
        $($_row).append($_tdRemove);

        let $_tdSave = $('<td></td>');
        let $_butSave = $('<i ' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValSave + '" class="fa fa-save'
            + ((carePlanObj[_opts.carePlanTableColCtrlDataAttrValHasUnsavedChanges]) ? ' ' + _pulsateAnimationClass : '')
            + '" title = "Save Record"></i>');
        $($_tdSave).append($_butSave);
       
        $($_row).append($_tdSave);
        
        let $_tdPrint = $('<td></td>');
        let $_butPrint = $('<span ' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValPrint + '" class="fa-stack" title="Download Plan PDF">'
                         + '<i ' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValPrint    + '" class="text-danger far fa-file-pdf fa-stack-1x fa-lg"></i>'
                         + '<i ' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValPrint    + '" class="text-danger fas fa-arrow-down fa-stack-1x fa-sm"></i>'
                         + '</span>');
        $($_tdPrint).append($_butPrint);
       
        $($_row).append($_tdPrint);
        
        let $_tdSend = $('<td></td>');
        let $_butSend = $('<i ' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValAuth + '" class="fas fa-user-md" title="Send Record For E-Authorization"></i>');
        $($_tdSend).append($_butSend);
       
        $($_row).append($_tdSend);

        let $_tdDup = $('<td></td>');
        let $_butDup = $('<i ' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValDup + '" class="fa fa-copy" title="Duplicate Record"></i>');
        $($_tdDup).append($_butDup);
       
        $($_row).append($_tdDup);

        $($_row).append(_createCarePlanTableColsCommonMkup(carePlanObj));

        // append by appendType
        if (carePlanObj["" + _opts.carePlanTableColCtrlDataAttrValAppendType] == 'prepend') $(_opts.carePlanTableBodySelector).prepend($_row);

        // if this is the duplicate of a row, insert it directly after its original row
        else if (carePlanObj["" + _opts.carePlanTableColCtrlDataAttrValAppendType] == 'insertafter') {
            $_row.insertAfter($('tbody tr[' + _opts.carePlanTableRowDataAttr + '='
                + carePlanObj["" + _opts.carePlanTableColCtrlDataAttrValDuppedRecKey] + ']'));
        }

        else $(_opts.carePlanTableBodySelector).append($_row);

        // set up callback functions
        let $diagnosisBut = $_row.find('[' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValDiagnosis + '"]').parent();
        $diagnosisBut.on("click", function () { _renderDiagnosisDialog(carePlanKey); });

        let $servicesBut = $_row.find('[' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValServiceSelectionsJSON + '"]').parent();
        $servicesBut.on("click", function () { _renderServicesDialog(carePlanKey); });

        let $participantsBut = $_row.find('[' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValParticipantsJSON + '"]').parent();
        $participantsBut.on("click", function () { _renderParticipantsDialog(carePlanKey); });


    }

    /***************************************************************************
     *  */
    /**
     * 
     ***************************************************************************/

    function _drawCarePlanTableBodyRows() {
        _CarePlanRecsDataToTA();

        $(_opts.carePlanTableBodySelector).children().remove();

        _CarePlanRecs.forEach(function (_carePlanObj, _carePlanKey) {
            _drawCarePlanTableBodyRow(_carePlanObj, _carePlanKey);
        })
    }

    /***************************************************************************
     *  */
    /**
     * 
     ***************************************************************************/

    function _identifyTableBodyRowAction(e, whatElement) {

        let _rowAction = {};
        _rowAction.whatInp = $(e.target).closest(whatElement);
        _rowAction.whatCol = $(_rowAction.whatInp).closest('td');
        _rowAction.whatRow = $(_rowAction.whatCol).closest('tr');
        _rowAction.doWhat = $(_rowAction.whatInp).attr(_opts.carePlanTableColCtrlDataAttr);
        _rowAction.recKey = $(_rowAction.whatRow).attr(_opts.carePlanTableRowDataAttr);
        return _rowAction;
    }

    /***************************************************************************
    * _renderDiagnosisDialog */
    /**
     * show details dialog for diagnosis
     ***************************************************************************/
    function _saveUserDiagnosisTemplate(templateType, diagnosisName, diagnosisDescription) {

        /****** set up ajax url ***********/

        var reqUrl = "plan_writer_diagnoses.asmx/saveDiagnosis?tkn=" + _opts.tkn;
        var reqData = JSON.stringify(
            {
                   "clientid"                : $('#clientid').val()
                 , "diagnosisName"           : diagnosisName
                 , "diagnosisDescription"    : diagnosisDescription
                 , "templatetype"            : templateType
                 , "groupserviceclassnameid" : ''
                 , "editDelReason"           : ''
                 , "validaterec"             : '0'
                 , "savetype"                : '1'
                 , "recid"                   : ''
            }
        );

        // success callback for ajax
        var fnProcRespSuccess = function (rd) {
            if (rd.recordID == 0) {
                $.spedmonWebUI.dialogMessage('ERROR', "Something went wrong when saving record!", null, 400, 200, null, null, null);
                return;
            }
            
            _opts.$detailsDialogCont.mbaHighlight({ color: "#bdffc7", duration: 300 });
        };

        // error callback for ajax
        var fnProcRespError = function () {
            $.spedmonWebUI.dialogMessage('ERROR', "Something went wrong when saving record!", null, 400, 200, null, null, null);
            return;
        };

        $.spedmonWebUI.ajax(null
            , reqUrl
            , reqData
            , 'json'
            , null
            , null
            , fnProcRespError
            , null
            , 0
            , fnProcRespSuccess
            , null
            , null);


    }

    /***************************************************************************
     * _deleteDiagnosis */
    /**
     * deletes a diagnosis from database
     ***************************************************************************/
    function _deleteDiagnosis(recID, fnSuccess) {
        let tkn = _opts.tkn;

        // get the reqData parameters

        let recid = recID;

        /****** set up ajax url ***********/

        var reqUrl = "plan_writer_diagnoses.asmx/delete?tkn=" + tkn;

        var rdObj = {};

        rdObj.recid = '' + recid;
        rdObj.validaterec = 0;
        rdObj.editDelReason = '';

        var reqData = JSON.stringify(rdObj);

        // success callback for ajax
        var fnProcRespSuccess = function (rd) {
            if (rd.recordID == 0) {
                $.spedmonWebUI.dialogMessage('ERROR', "Something went wrong when saving record!", null, 400, 200, null, null, null);
                return;
            }

            if (fnSuccess) fnSuccess();
        };

        // error callback for ajax
        var fnProcRespError = function (rd) {
            $.spedmonWebUI.dialogMessage('ERROR', "Something went wrong when deleting record!", null, 400, 200, null, null, null);
            return;
        };

        $.spedmonWebUI.ajax(null
            , reqUrl
            , reqData
            , 'json'
            , null
            , null
            , fnProcRespError
            , null
            , 0
            , fnProcRespSuccess
            , null
            , null);
    }

    /***************************************************************************
     * _setUpDiagnosisSelectBox */
    /**
     * set up selectbox for diagnosis based on radio selection
     ***************************************************************************/
    function _setUpDiagnosisSelectBox() {

        // callabck function to render diagnosis on selection
        function diagnosisSelected(event, ui) {
            $('#' + _diagnosisDescInputID).val(ui.item.recData1).trigger('change');
            $('#' + _diagnosisHiddenIDInputID).val(ui.item.id);
            $('#' + _diagnosisNameDisplayContID).val(ui.item.label);
        }

        var tkn = _opts.tkn;
        var templateType = $('input[name="' + _diagnosisRadioSelectionsName + '"]:checked').val();

        /****** set up ajax url ***********/

        var reqUrl = "plan_writer_diagnoses.asmx/viewSel?tkn=" + tkn;
        var reqData = [{
            name: 'clientid', value: $('#clientid').val()
        }, {
            name: 'recid', value: ''
        }, {
            name: 'templatetype', value: templateType
        }, {
            name: 'groupserviceclassnameid', value: ''
        }];

        $('#' + _diagnosisNameInputID).spedmonSelectBox({
            dataParmType: 'DOM'
            , selectAll: true
            , delay: 600
            , showSelectControlLabel: false
            , selectControlLabel: 'Select Diagnosis: '
            , selectType: 1
            , displayInline: false
            , singleSelectName: ''
            , singleSelectValue: ''
            , singleSelectClearAfterSelection: false
            , multiSelect: false
            , multiSelectShowOK: true
            , multiSelectListTitle: 'Selected Diagnoses'
            , multiSelectNames: ''
            , multiSelectValues: ''
            , multiSelectLoad: false
            , multiSelectContextLabels: 'null'
            , multiSelectDisplayContextLabels: false
            , multiSelectOnAdd: function (selObj) { }
            , multiSelectOnRemove: function (selObj) { }
            , onSelect: diagnosisSelected
            , ajaxopts: { url: reqUrl, data: '', namevalues: reqData }
        });

        // if selecting from our templates, we don't give the user the option to delete
        if (templateType == 1) return;

        // add X icon to delete a diagnosis
        var diagSelBoxData = $('#' + _diagnosisNameInputID).data('spedmonSelectBox');  

        $('#' + diagSelBoxData.inputData.meid).data("autocomplete")._renderItem = function ($ul, item) {
            var diagSelContentParentClass = "planwriter-diagnosis-sel-content-parent-cont";

            var $nli = $('<li class="' + diagSelContentParentClass + '"></li>'); // Note any classes added here are removed	
            var liLabel = '<span>' + item.label + '</span>';

            // Detail

            var $nliDetail = $('<a>' + liLabel + '</a>');

            // Remove button

            var $butRem = $('<i class="fa fa-times" type="button"></i>')
                .on('click', function () {     
                    _deleteDiagnosis(item.id, function () { $($nli).remove(); });
                });

            $($nli).append($nliDetail);
            
            $($nli).append($butRem);

            $($nli).data("item.autocomplete", item);

            return $nli.appendTo($ul);

        };
    }

    /***************************************************************************
     * _generateDiagnosisSrcRadioBox */
    /**
     * creates radio selections for diagnosis dropdown
     ***************************************************************************/
    function _generateDiagnosisSrcRadioBox() {
        let $radioCont = $('<div class="ui-spedmon-box-radio-box-container ui-buttonset modern2021 mb-2" id="diagnosisradioelections_radiobox_cont">'
	                        + '<div id="diagnosisradioelections_radiobox_ctrl" class="ui-spedmon-box-radio-box-options-container">'
	                        + 	'<input type="radio" id="diagnosisradioelections_radiobox_opt_0" name="' + _diagnosisRadioSelectionsName + '" value="1" title="Diagnosis Library" class="mba-web-ui-field-data-entry-primary mba-web-ui-field-no-submit mba-web-ui-field-no-clear ui-spedmon-box-radio-box-option-input  ui-helper-hidden-accessible" checked>'
	                        + 	'<label class="ui-spedmon-box-radio-box-option-label ui-button ui-widget ui-state-default ui-button-text-only ui-corner-left ui-state-active" for="diagnosisradioelections_radiobox_opt_0" aria-pressed="false" role="button" aria-disabled="false">'
	                        + 		'<span class="ui-button-text">Diagnosis Library</span>'
	                        + 	'</label>'
	                        + 	'<input type="radio" id="diagnosisradioelections_radiobox_opt_1" name="' + _diagnosisRadioSelectionsName + '" value="2" title="LEA Templates" class="mba-web-ui-field-no-submit mba-web-ui-field-no-clear ui-spedmon-box-radio-box-option-input  ui-helper-hidden-accessible">'
	                        + 	'<label class="ui-spedmon-box-radio-box-option-label ui-button ui-widget ui-state-default ui-button-text-only ui-corner-right" for="diagnosisradioelections_radiobox_opt_1" aria-pressed="false" role="button" aria-disabled="false">'
	                        + 		'<span class="ui-button-text">LEA Templates</span>'
	                        + 	'</label>'
                            + 	'<input type="radio" id="diagnosisradioelections_radiobox_opt_2" name="' + _diagnosisRadioSelectionsName + '" value="3" title="My Favorites" class="mba-web-ui-field-no-submit mba-web-ui-field-no-clear ui-spedmon-box-radio-box-option-input  ui-helper-hidden-accessible">'
	                        + 	'<label class="ui-spedmon-box-radio-box-option-label ui-button ui-widget ui-state-default ui-button-text-only ui-corner-right" for="diagnosisradioelections_radiobox_opt_2" aria-pressed="false" role="button" aria-disabled="false">'
	                        + 		'<span class="ui-button-text">My Favorites</span>'
	                        + 	'</label>'
	                        + '</div>'
                    + '</div>');
        
        // set up callback to re-render diagnosis selection if source changed
        $radioCont.find('input[name="' + _diagnosisRadioSelectionsName + '"]').on("click", function () {
            // add the active class
            $('#diagnosisradioelections_radiobox_ctrl label').removeClass('ui-state-active');
            $('label[for="' + $(this).attr("id") + '"]').addClass('ui-state-active');

            $('#' + _diagnosisNameInputID + '_all_cont').replaceWith($('<input id="' + _diagnosisNameInputID + '" title="Select a diagnosis" type="text"></input>'));
            _setUpDiagnosisSelectBox();
        });

        return $radioCont;
    
    }

    /***************************************************************************
     * _setTextareaCharacterCounter */
    /**
     * display system for character count of a textarea
     ***************************************************************************/
    function _setTextareaCharacterCounter($textarea, $charCounter, maxCharCount) {
        // check and add character counter attribute, otherwise return
        if ($textarea.data(_textareaAttrHasMaxCharCounter)) {
            console.log('textarea already has character counter');
            return;
        } else {
            $textarea.data(_textareaAttrHasMaxCharCounter, 'true');
        }

        // define function to calculate and render the character counter
        function fnSetCharCounterContent() {
                // trim input value to the maximum chars allowed
                if ($textarea.val().length > maxCharCount) {
                    $textarea.val($textarea.val().substring(0, _diagnosisDescMaxLength));
                }

                // set 
                var length = $textarea.val().length;
                var charactersLeft = maxCharCount - length;

                $charCounter.html('').text(((charactersLeft && charactersLeft > 0) ? charactersLeft : '0') + ' characters left');
        }

        // call fnSetCharCounterContent to set the content of the char counter initially
        fnSetCharCounterContent();

        $textarea.on('input change keyup paste propertychange click select focusout', fnSetCharCounterContent);

    }

    /***************************************************************************
     * _renderDiagnosisDialog */
    /**
     * show details dialog for diagnosis
     ***************************************************************************/
    function _renderDiagnosisDialog(carePlanKey) {
        let carePlanObj = _CarePlanRecs.get(carePlanKey);

        // callback function to save diagnosis selection
        function saveDiagnosisSelection() {
            _updateCurrentCarePlansRecsForSpecificField(carePlanKey, $('#' + _diagnosisHiddenIDInputID).val(), _opts.carePlanTableColCtrlDataAttrValDiagnosisID);
            _updateCurrentCarePlansRecsForSpecificField(carePlanKey, $('#' + _diagnosisNameDisplayContID).val(), _opts.carePlanTableColCtrlDataAttrValDiagnosisName);
            _updateCurrentCarePlansRecsForSpecificField(carePlanKey, $('#' + _diagnosisDescInputID).val(), _opts.carePlanTableColCtrlDataAttrValDiagnosisDesc);

            _opts.$detailsDialogCont.html('').dialog('close');
        }

        let diagnosisContID = "carePlanDiagnosisFieldsCont";
        let _diagnosisSelectContID = "carePlanDiagnosisSelectCont";

        let diagnosisDesc = '';

        try {
            diagnosisDesc = (carePlanObj[_opts.carePlanTableColCtrlDataAttrValDiagnosisDesc]) ? carePlanObj[_opts.carePlanTableColCtrlDataAttrValDiagnosisDesc] : '';
        } catch (e) {
            diagnosisDesc = (carePlanObj[_opts.carePlanTableColCtrlDataAttrValDiagnosisDesc]) ? carePlanObj[_opts.carePlanTableColCtrlDataAttrValDiagnosisDesc] : '';
        }

        // create content to be appended
        let $diagnosisContent = $(
            '<div id="' + diagnosisContID + '" class="ui-spedmon-data-entry-rows container">'
                + '<div class="ui-spedmon-data-entry-row row">'
                    + '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label col-xs-12 col-sm-12 col-md-3">Select Diagnosis</div>'
                    + '<div id="' + _diagnosisSelectContID + '" class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry col-xs-12 col-sm-12 col-md-9">'
                        + '<input id="' + _diagnosisNameInputID + '" title="Select a diagnosis" type="text"></input>'
                    + '</div>'
                + '</div>'

                + '<div class="ui-spedmon-data-entry-row row">'
                    + '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label col-xs-12 col-sm-12 col-md-3">Diagnosis Name</div>'
                    + '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry col-xs-12 col-sm-12 col-md-9">'
                        + '<input type="text" class="w-50" id="' + _diagnosisNameDisplayContID + '" '
                        + 'value="' + ((carePlanObj[_opts.carePlanTableColCtrlDataAttrValDiagnosisName]) ? carePlanObj[_opts.carePlanTableColCtrlDataAttrValDiagnosisName] : '') + '">'
                    + '</div>'
                + '</div>'

                + '<div class="ui-spedmon-data-entry-row row">'
                    + '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label col-xs-12 col-sm-12 col-md-3">Diagnosis Overview</div>'
                    + '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry col-xs-12 col-sm-12 col-md-9">'
                        + '<textarea id="' + _diagnosisDescInputID + '" class="mba-web-ui-field-data-text-area mba-web-ui-field-simple mba-web-ui-field-data-entry-primary ui-spedmon-box ui-widget-content ui-corner-all ui-spedmon-noteareabox" placeholder="Enter Diagnosis Overview" maxlength="' + _diagnosisDescMaxLength + '">'
                        + diagnosisDesc
                        + '</textarea>'
                        + '<div id="' + _diagnosisDescCharCount + '" class="text-secondary"></div>'
                    + '</div>'
                + '</div>'

                + '<input type="hidden" id="' + _diagnosisHiddenIDInputID + '" value="' 
                + ((carePlanObj[_opts.carePlanTableColCtrlDataAttrValDiagnosisID]) ? carePlanObj[_opts.carePlanTableColCtrlDataAttrValDiagnosisID] : '')
                + '">'

            + '</div>'
        );


        $diagnosisContent.find('#' + _diagnosisSelectContID).prepend(_generateDiagnosisSrcRadioBox());
        $diagnosisContent.append(_generateButtonElem('Add To Favorites', 'mt-2 btn btn-link', 'fas fa-heart fa-2x'       , function () { _saveUserDiagnosisTemplate(3, $('#' + _diagnosisNameDisplayContID).val(), $('#' + _diagnosisDescInputID).val()); }));
        $diagnosisContent.append(_generateButtonElem('Add to Templates', 'mt-2 btn btn-link', 'fas fa-book-medical fa-2x', function () { _saveUserDiagnosisTemplate(2, $('#' + _diagnosisNameDisplayContID).val(), $('#' + _diagnosisDescInputID).val()); }));
        $diagnosisContent.append(_generateButtonElem('Save', 'float-right mt-2 btn btn-link', 'fas fa-save fa-2x'        , saveDiagnosisSelection));

        // set up character counter for diagnosis description
        _setTextareaCharacterCounter($diagnosisContent.find('#' + _diagnosisDescInputID), $diagnosisContent.find('#' + _diagnosisDescCharCount), _diagnosisDescMaxLength);

        _opts.$detailsDialogCont.html('').append($diagnosisContent).show().dialog(
            {
                width: $(window).width() * 0.65
                , height: $(window).height()
                , title: "Diagnosis"
                , show: {
                    effect: 'slide',
                    complete: function () {
                        _setUpDiagnosisSelectBox();
                    }
                }
                , hide: {
                    effect: 'slide'
                    , direction: 'left'
                }
            }

        );
    }
    
    /***************************************************************************
     * _toggleAddServiceToPlan */
    /**
     * toggle plus icon to minus and vice versa based on current class
     ***************************************************************************/
    function _toggleAddServiceToPlan() {
        let selectedAttr = $(this).closest('tr').attr(_servicesSelectedRowAttr); // determines whether row has been selected or not

        // if record selected, unselect it
        if (typeof selectedAttr !== typeof undefined && selectedAttr !== false) {
            $(this).removeClass('fa-times').addClass('fa-plus');
            $(this).closest('tr').removeAttr(_servicesSelectedRowAttr);
        }
        // if record not selected, select it
        else {
            $(this).addClass('fa-times').removeClass('fa-plus');
            $(this).closest('tr').attr(_servicesSelectedRowAttr, "true");
        }
    }

    /***************************************************************************
     * _toggleAddParticipantToPlan */
    /**
     * toggle plus icon to minus and vice versa based on current class
     ***************************************************************************/

    function _toggleAddParticipantToPlan() {

        // if record has not been saved yet, display a warning
        if ($(this).closest('tr').attr(_opts.carePlanTableColCtrlDataAttrValSaveType) == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {
            $.spedmonWebUI.dialogMessage('WARNING', "Please make sure your record is saved before proceeding.", null, 400, 200, null, null, null);
            return;
        }

        let selectedAttr = $(this).closest('tr').attr(_participantsSelectedRowAttr); // determines whether row has been selected or not

        // if record selected, unselect it
        if (typeof selectedAttr !== typeof undefined && selectedAttr !== false) {
            $(this).removeClass('fa-times').addClass('fa-plus');
            $(this).closest('tr').removeAttr(_participantsSelectedRowAttr);
        }
        // if record not selected, select it
        else {
            $(this).addClass('fa-times').removeClass('fa-plus');
            $(this).closest('tr').attr(_participantsSelectedRowAttr, "true");
        }
    }

    /***************************************************************************
     * _saveServiceSelectionsToPlan */
    /**
     * save the service selections to the map
     ***************************************************************************/
    function _saveServiceSelectionsToPlan(carePlanKey, keepModalOpen) {
        let servicesJSONArr = [];

        $('#' + _serviceSelectionsTblID + ' tr[' + _servicesSelectedRowAttr + ']').each(function (idx, thisTd) {
            servicesJSONArr.push(
                {
                      "orpDocRefID": $(thisTd).attr(_servicesOrpRefDocID)
                    , "orpDocType" : $(thisTd).attr(_servicesOrpDocTypeAttr)
                }
            );
        });

        _updateCurrentCarePlansRecsForSpecificField(carePlanKey, servicesJSONArr, _opts.carePlanTableColCtrlDataAttrValServiceSelectionsJSON);

        if (!keepModalOpen)
            _opts.$detailsDialogCont.html('').dialog('close');
    }

    /***************************************************************************
     * _saveParticipantsToPlan */
    /**
     * save the service selections to the map
     ***************************************************************************/
    function _saveParticipantsToPlan(carePlanKey, keepModalOpen, checkForUnsavedChanges) {
        if (checkForUnsavedChanges) {
            // check if there are unsaved changes
            var numOfUnsavedRows = $('#' + _planParticipantsTblID + ' .' + _pulsateAnimationClass).length;
            if (numOfUnsavedRows != 0) {
                $.spedmonWebUI.dialogMessage('WARNING', "There are unsaved changes.", null, 400, 200, null, null, null);
                return;
            }
        }

        let partsJSONArr = [];

        $('#' + _planParticipantsTblID + ' tr[' + _participantsSelectedRowAttr + ']').each(function (idx, thisTd) {
            let partsObj = {};
            partsObj[_opts.carePlanTableColCtrlDataAttrValParticipantID]     = $(thisTd).attr(_participantsRecIDAttr);
            partsObj[_opts.carePlanTableColCtrlDataAttrValParticipantAction] = $(thisTd).find('[' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValParticipantAction + '"]').find('select').val();
            partsJSONArr.push(partsObj);
        });

        _updateCurrentCarePlansRecsForSpecificField(carePlanKey, partsJSONArr, _opts.carePlanTableColCtrlDataAttrValParticipantsJSON);

        if (!keepModalOpen)
            _opts.$detailsDialogCont.html('').dialog('close');
    }

    /***************************************************************************
     * _openOrdersOrProfilesEditScreen */
    /**
     * open the orders or profiles edit screens based on document type
     ***************************************************************************/
    function _openOrdersOrProfilesEditScreen(editIcon, carePlanKey) {
        // grab the row's id and document type
        let parentRow = $(editIcon).closest('tr');
        let recID = parentRow.attr(_servicesRecIDAttr);
        let clientID = $('#clientid').val();

        // the following are used for the popupThenResume function
        var fnEntryTest = function () { return true; };
        var fnExitTest = function () { return true; };
        var fnResume = function () { _saveServiceSelectionsToPlan(carePlanKey, true); _renderServicesDialog(carePlanKey); return true; };

        let url = _opts.ordersEditUrl + "?tkn=" + _opts.tkn + "&recid=" + recID + "&patclientid=" + clientID + "&savetype=2&amd=uidbssub";

        $.spedmonWebUI.popupThenResume(fnEntryTest
            , fnExitTest
            , fnResume
            , url
            , 'Popups Not Supported'
            , 'Please allow popups for SpEdCare'
            , 'Waiting'
            , 'Waiting for changes to be saved');
 
    }
    
    /***************************************************************************
     * _deletePatientOrderAndRefreshServicesTbl */
    /**
     * delete the patient's order and refresh participants table
     ***************************************************************************/
    function _deletePatientOrderAndRefreshServicesTbl(editIcon, carePlanKey) {
        // grab the row's id and document type
        let $parentRow = $(editIcon).closest('tr');
        let recID = $parentRow.attr(_servicesRecIDAttr);

        // function to remove refresh participants table
        var fnRefreshParticipantsTbl =
            function () {
                // remove order from plan and refresh
                $parentRow.remove();
                _saveServiceSelectionsToPlan(carePlanKey, true);
                _renderServicesDialog(carePlanKey);
                return true;
            };

        // url for order delete ajax
        let reqURL = _opts.ordersDeleteUrl;
        let reqData = JSON.stringify({ "recid" : recID });

        // confirm with user that they indeed want to delete the order for patient
        var onYes = function () {
            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqData, null)
                .then(responseData => {
                    fnRefreshParticipantsTbl();
                })
                .catch(responseData => {
                    $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                });
        };

        $.spedmonWebUI.dialogConfirm("Please Confirm", 'Are you sure you want to deactivate this order? This will remove access to this order from SpEdCare. Order will still be available for audit purposes. If you want to remove service from plan, click the "X" next to the service name.'
            , onYes, function () { });
    }

    /***************************************************************************
     * _openOrdersOrProfilesAddNewScreen */
    /**
     * open the orders or profiles add new screen
     ***************************************************************************/
    function _openOrdersOrProfilesAddNewScreen(carePlanKey) {
        // grab the row's id and document type
        let clientID = $('#clientid').val();
        let patID = _CarePlanRecs.get(carePlanKey)[_opts.carePlanTableColCtrlDataAttrValPatID];

        // the following are used for the popupThenResume function
        var fnEntryTest = function () { return true; };
        var fnExitTest = function () { return true; };
        var fnResume = function () { _saveServiceSelectionsToPlan(carePlanKey, true); _renderServicesDialog(carePlanKey); return true; };

        let url = _opts.ordersEditUrl + "?tkn=" + _opts.tkn + "&patid=" + patID + "&patclientid=" + clientID + "&savetype=1&amd=uidbssub";

        $.spedmonWebUI.popupThenResume(fnEntryTest
            , fnExitTest
            , fnResume
            , url
            , 'Popups Not Supported'
            , 'Please allow popups for SpEdCare'
            , 'Waiting'
            , 'Waiting for changes to be saved');
 
    }

    /***************************************************************************
    * _saveParticipantToTheDatabase */
    /**
     * sends ajax request to save a record to the database
     ***************************************************************************/

    function _saveParticipantToTheDatabase(saveIcon, carePlanKey) {
        
        var tkn = _opts.tkn;
        let carePlanObj = _CarePlanRecs.get(carePlanKey);
        let patientid = carePlanObj[_opts.carePlanTableColCtrlDataAttrValPatID];
        let clientid = $('#clientid').val();

        let parentRow                   = $(saveIcon).closest('tr');
        let recid                       = parentRow.attr(_participantsRecIDAttr);
        let saveType                    = parentRow.attr(_opts.carePlanTableColCtrlDataAttrValSaveType);
        let hiddenparticipantfieldsObj  = JSON.parse(parentRow.find('.' + _participantsHiddenFieldsClass).val());
        let lastname                    = parentRow.find('td[' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValParticipantLastName + '"]').find('input').val();
        let firstname                   = parentRow.find('td[' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValParticipantFirstName + '"]').find('input').val();
        let personrelationshipid        = parentRow.find('td[' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValParticipantRole + '"]').find('select').val();
        let email                       = parentRow.find('td[' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValParticipantEmail + '"]').find('input').val();
        let phone                       = parentRow.find('td[' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValParticipantPhone + '"]').find('input').val();
        
        /****** set up ajax url ***********/

        var reqUrl = "patient_persons.asmx/save?tkn=" + tkn;
        var reqData = '{'
                    + '"clientid":"' + clientid + '"'
                    + ',"patientid":"' + patientid + '"'
                    + ',"personroleid":"' + 1 + '"'
                    + ',"personrelationshipid":"' + personrelationshipid + '"'
                    + ',"lastname":"' + lastname + '"'
                    + ',"firstname":"' + firstname + '"'
                    + ',"middlename":"' + '' + '"'
                    + ',"phone":"' + phone + '"'
                    + ',"fax":"' + hiddenparticipantfieldsObj.fax + '"'
                    + ',"email":"' + email + '"'
                    + ',"address1":"' + hiddenparticipantfieldsObj.address1 + '"'
                    + ',"address2":"' + hiddenparticipantfieldsObj.address2 + '"'
                    + ',"city":"' + hiddenparticipantfieldsObj.city + '"'
                    + ',"state":"' + hiddenparticipantfieldsObj.state + '"'
                    + ',"zip5":"' + hiddenparticipantfieldsObj.zip5 + '"'
                    + ',"zip4":"' + hiddenparticipantfieldsObj.zip4 + '"'
                    + ',"additionaldata1":"' + hiddenparticipantfieldsObj.additionalData1 + '"'
                    + ',"additionaldata2":"' + hiddenparticipantfieldsObj.additionalData2 + '"'
                    + ',"editDelReason":"' + '' + '"'
                    + ',"validaterec":"' + 1 + '"'
                    + ',"savetype":"' + saveType + '"'
                    + ',"recid":"' + recid + '"}';

        // success callback for ajax
        var fnProcRespError = function (rd) {
            $.spedmonWebUI.dialogMessage('ERROR', "Something went wrong when saving record!", null, 400, 200, null, null, null);
        }

        // success callback for ajax
        var fnProcRespSuccess = function (rd) {

            // send another ajax request with the validaterec field now set to 0
            var reqData2 = '{'
                    + '"clientid":"' + clientid + '"'
                    + ',"patientid":"' + patientid + '"'
                    + ',"personroleid":"' + 1 + '"'
                    + ',"personrelationshipid":"' + personrelationshipid + '"'
                    + ',"lastname":"' + lastname + '"'
                    + ',"firstname":"' + firstname + '"'
                    + ',"middlename":"' + '' + '"'
                    + ',"phone":"' + phone + '"'
                    + ',"fax":"' + hiddenparticipantfieldsObj.fax + '"'
                    + ',"email":"' + email + '"'
                    + ',"address1":"' + hiddenparticipantfieldsObj.address1 + '"'
                    + ',"address2":"' + hiddenparticipantfieldsObj.address2 + '"'
                    + ',"city":"' + hiddenparticipantfieldsObj.city + '"'
                    + ',"state":"' + hiddenparticipantfieldsObj.state + '"'
                    + ',"zip5":"' + hiddenparticipantfieldsObj.zip5 + '"'
                    + ',"zip4":"' + hiddenparticipantfieldsObj.zip4 + '"'
                    + ',"additionaldata1":"' + hiddenparticipantfieldsObj.additionalData1 + '"'
                    + ',"additionaldata2":"' + hiddenparticipantfieldsObj.additionalData2 + '"'
                    + ',"editDelReason":"' + '' + '"'
                    + ',"validaterec":"' + 0 + '"'
                    + ',"savetype":"' + saveType + '"'
                    + ',"recid":"' + recid + '"}';

            var fnProcRespSuccess2 = function (rd) {
                if (rd.recordID == 0) {
                    $.spedmonWebUI.dialogMessage('ERROR', "Something went wrong when saving record!", null, 400, 200, null, null, null);
                    return;
                }

                if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {
                    parentRow.attr(_participantsRecIDAttr, rd.recordID);
                    parentRow.attr(_opts.carePlanTableColCtrlDataAttrValSaveType, $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT);

                    // refresh the dialog to load role specific options
                    _saveParticipantsToPlan(carePlanKey, false, false);
                    _renderParticipantsDialog(carePlanKey);
                }
                else {
                    $(saveIcon).removeClass(_pulsateAnimationClass);
                    _opts.$detailsDialogCont.mbaHighlight({ color: "#bdffc7", duration: 300 });
                }
            };

            $.spedmonWebUI.ajax(null
                , reqUrl
                , reqData2
                , 'json'
                , null
                , null
                , fnProcRespError
                , null
                , 0
                , fnProcRespSuccess2
                , null
                , null);
        };

        $.spedmonWebUI.ajax(null
            , reqUrl
            , reqData
            , 'json'
            , null
            , null
            , fnProcRespError
            , null
            , 0
            , fnProcRespSuccess
            , null
            , null);
    }

    /***************************************************************************
     * _openPatientPersonsSaveScreen */
    /**
     * open the patient persons edit screens based on patient id
     ***************************************************************************/
    //function _openPatientPersonsSaveScreen(editIcon, carePlanKey, saveType) {
    //    // grab the url parameters
    //    let carePlanObj = _CarePlanRecs.get(carePlanKey);
    //    let patientid = carePlanObj[_opts.carePlanTableColCtrlDataAttrValPatID];
    //    let clientid = $('#clientid').val();
        
    //    let url = '';

    //    // the following are used for the popupThenResume function
    //    var fnEntryTest = function () { return true; };
    //    var fnExitTest = function () { return true; };
    //    var fnResume = function () { _saveParticipantsToPlan(carePlanKey, true, true); _renderParticipantsDialog(carePlanKey); return true; };

    //    if (saveType == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {
    //        // if saveType is 1, we open the patient persons save screen

    //        url = _opts.patientPersonsSaveUrl + "?tkn=" + _opts.tkn + "&clientid=" + clientid + "&patientid=" + patientid + "&savetype=1&amd=uidbssub";
    //    }
    //    else {
    //        // if saveType is 2, we open the patient persons edit screen

    //        // grab the url parameters
    //        let parentRow = $(editIcon).closest('tr');
    //        let recid = parentRow.attr(_participantsRecIDAttr);

    //        url = _opts.patientPersonsSaveUrl + "?tkn=" + _opts.tkn + "&recid=" + recid + "&clientid=" + clientid + "&patientid=" + patientid + "&savetype=2&amd=uidbssub";
    //    }


    //    $.spedmonWebUI.popupThenResume(fnEntryTest
    //        , fnExitTest
    //        , fnResume
    //        , url
    //        , 'Popups Not Supported'
    //        , 'Please allow popups for SpEdCare'
    //        , 'Waiting'
    //        , 'Waiting for changes to be saved');
    //}

    /***************************************************************************
     * _buildServicesHtmlTblContent */
    /**
     * build html for services table
     ***************************************************************************/
    function _buildServicesHtmlTblContent(carePlanObj, orpDocObjs) {
        let tblBodyCont = '';

        if (!orpDocObjs) return '<div>No Records</div>';

        orpDocObjs.forEach(function (RecObj, _idx) {

            // set up dynamic add / remove buttons
            let selectedAttr = (carePlanObj[_opts.carePlanTableColCtrlDataAttrValServiceSelectionsJSON] && carePlanObj[_opts.carePlanTableColCtrlDataAttrValServiceSelectionsJSON].filter(item => item.orpDocRefID == RecObj.recData6).length > 0) ?
                _servicesSelectedRowAttr + '="true"' : "";                                                                                                                                                         
            let selectedIcon = (carePlanObj[_opts.carePlanTableColCtrlDataAttrValServiceSelectionsJSON] && carePlanObj[_opts.carePlanTableColCtrlDataAttrValServiceSelectionsJSON].filter(item => item.orpDocRefID == RecObj.recData6).length > 0) ?
                'fa-times' : 'fa-plus';

            // add to or remove from plan x or + icon
            let $addRemIcon = $('<i class="fas ' + selectedIcon + ' ' + _servicesAddRemButClass + '" title="Add/Remove From Plan"></i>');

            tblBodyCont += '<tr ' + _servicesRecIDAttr + '="' + RecObj.id + '" ' + _servicesOrpRefDocID + '="' + RecObj.recData6 + '" ' + _servicesOrpDocTypeAttr + '="' + RecObj.recData5 + '" ' +  selectedAttr + '>'
                            +  '<td><i class="fas fa-pencil-alt ' + _servicesEditOrderButClass + '" title="Edit This Order"></i></td>'
                            +  '<td><i class="fas fa-trash-alt '  + _servicesDeleteButClass    + '" title="Deactivate Order"></i></td>'
                            +  '<td>' + $addRemIcon.get(0).outerHTML + '</td>'
                            +  '<td>' + RecObj.label +'</td>'
                            +  '<td>' + RecObj.context1 +'</td>'
                          + '</tr>'
        });

        return '<table id="' + _serviceSelectionsTblID  + '" class="ui-spedmon-gradient-data-table col-12">'
             + '<thead><tr>'
             + '<th>Edit Order</th>'
             + '<th>Deactivate Order</th>'
             + '<th>Add/Remove From Plan</th>'
             + '<th>Service Name</th>'
             + '<th>ORP/Physician</th>'
             + '</tr></thead>'
             + '<tbody>'
             + tblBodyCont
             + '</tbody>'
             + '</table>';
    }

    /***************************************************************************
     * _createParticipantsHtmlTblPlanCreatorRowContent */
    /**
     * build html for participants table
     ***************************************************************************/
    function _createParticipantsHtmlTblPlanCreatorRowContent(carePlanObj) {
        // determine signature icon based on if the user signed the plan or not
        let signatureIconClass = (carePlanObj[_opts.carePlanTableColCtrlDataAttrValPlanCreatorSigned] && carePlanObj[_opts.carePlanTableColCtrlDataAttrValPlanCreatorSigned] == 1) ?
                "fa-check" : "fa-signature " + _participantsSignatureButClass;

		// determine if user should be able to sign as plan creator
        let includeSignatureIcon = (
               (carePlanObj[_opts.carePlanTableColCtrlDataAttrValPlanCreatorSigned] && carePlanObj[_opts.carePlanTableColCtrlDataAttrValPlanCreatorSigned] == 1) // plan has been signed by creator
            || (!carePlanObj[_opts.carePlanTableColCtrlDataAttrValCreatedBy]) // new plan
            || (carePlanObj[_opts.carePlanTableColCtrlDataAttrValCreatedBy] == _opts.userID) // user is the one who created the plan
        );
        return '<tr>'
            + '<td><i class="fas fa-times" title="Cannot add/remove from Plan"></i></td>'
            + '<td>' + (includeSignatureIcon ? ('<i class="fas ' + signatureIconClass + '" title="Sign the plan"></i>') : '<span class="text-danger font-weight-bold">Not Signed</span>') + '</td>'
            + '<td><div>' + carePlanObj[_opts.carePlanTableColCtrlDataAttrValCreatedByLname] + '</div></td>'
            + '<td><div>' + carePlanObj[_opts.carePlanTableColCtrlDataAttrValCreatedByFname] + '</div></td>'
            + '<td><div>Plan Creator</div></td>'
            + '<td><div>' + carePlanObj[_opts.carePlanTableColCtrlDataAttrValCreatedByEmail] + '</div></td>'
            + '<td><div>' + carePlanObj[_opts.carePlanTableColCtrlDataAttrValCreatedByPhone] + '</div></td>'
            + '<td><div>Not Applicable</div></td>'
            + '</tr>';
    }

    /***************************************************************************
     * _generateRoleOptions */
    /**
     * build html options for role selection
     ***************************************************************************/

    function _generateRoleOptions(role) {
        let selectOptions = '';
        
        if (_parentRolesArray.includes(role)) {
            selectOptions += '<option value="1000" ' + ((role == 1000) ? 'selected' : '') + '>Mother</option>'
                + '<option value="1001" ' + ((role == 1001) ? 'selected' : '') + '>Father</option>'
                + '<option value="1002" ' + ((role == 1002) ? 'selected' : '') + '>Guardian/Surrogate</option>';
        }

        else if (_practitionersRolesArray.includes(role)) {
            selectOptions += '<option value="5000" ' + ((role == 5000) ? 'selected' : '') + '>School Nurse</option>'
                + '<option value="5001" ' + ((role == 5001) ? 'selected' : '') + '>Mental Health Provider</option>'
                + '<option value="5002" ' + ((role == 5002) ? 'selected' : '') + '>Teacher</option>';
        }

        else if (_otherSchoolStaffRolesArray.includes(role)) {
            selectOptions += '<option value="3003" ' + ((role == 3003) ? 'selected' : '') + '>Other School Staff</option>';
        }

        else {
            selectOptions += '<option value="1000" ' + ((role == 1000) ? 'selected' : '') + '>Mother</option>'
                           + '<option value="1001" ' + ((role == 1001) ? 'selected' : '') + '>Father</option>'
                           + '<option value="1002" ' + ((role == 1002) ? 'selected' : '') + '>Guardian/Surrogate</option>'
                           + '<option value="5000" ' + ((role == 5000) ? 'selected' : '') + '>School Nurse</option>'
                           + '<option value="5001" ' + ((role == 5001) ? 'selected' : '') + '>Mental Health Provider</option>'
                           + '<option value="5002" ' + ((role == 5002) ? 'selected' : '') + '>Teacher</option>'
                           + '<option value="3003" ' + ((role == 3003) ? 'selected' : '') + '>Other School Staff</option>';
        }

        return selectOptions;
    }

    /***************************************************************************
     * _createParticipantsHtmlTblRowContent */
    /**
     * build html for participants table
     ***************************************************************************/
    function _createParticipantsHtmlTblRowContent(participantid, lastname, firstname, role, roleName, email, phone, action, selected, hiddenparticipantfieldsJSON, saveType, carePlanKey) {
        if (!participantid) participantid   = '';
        if (!lastname) lastname             = '';
        if (!firstname) firstname           = '';
        if (!role) role                     = '';
        if (!roleName) roleName             = '';
        if (!email) email                   = '';
        if (!phone) phone                   = '';
        if (!action) action                 = 0;
        if (!hiddenparticipantfieldsJSON) hiddenparticipantfieldsJSON = JSON.stringify(_defaulthiddenparticipantfieldsJSON);
        
        //let $remPartIcon = $('<i class="fas fa-times ' + _participantsAddRemButClass + '" title="Add/Remove from Plan"></i>');
        //$remPartIcon.on("click", function () { $(this).closest('tr').remove(); });
        // append remove icon with its callback attached
        //$tblRowCont.find('.' + _participantsAddRemButClass).append($remPartIcon);

        let selectedAttr = (selected) ? _participantsSelectedRowAttr + '="true"' : "";
        let selectedIcon = (selected) ? 'fa-times' : 'fa-plus';
        
        let $addRemIcon = $('<i class="fas ' + selectedIcon + ' ' + _participantsAddRemButClass + '" title="Add/Remove from Plan"></i>');
        
        let row = '<tr ' + _participantsRecIDAttr + ' = "' + participantid + '" ' + _opts.carePlanTableColCtrlDataAttrValSaveType + ' = "' + saveType + '" ' + _participantsActionAttr + ' = "' + ((action) ? action : 0) + '" ' + selectedAttr + '>'
            + '<td>' + $addRemIcon.get(0).outerHTML
            + '<textarea class="d-none ' + _participantsHiddenFieldsClass + '">' + hiddenparticipantfieldsJSON + '</textarea>'
            + '</td>'
            + '<td><i class="fas fa-save ' + _participantsSaveButClass + '" title="Save this person"></i></td>'
            + '<td ' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValParticipantLastName + '"><input value="' + lastname + '" type="text"></td>'
            + '<td ' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValParticipantFirstName + '"><input value="' + firstname + '" type="text"></td>'
            + '<td ' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValParticipantRole + '"><select>'
                + '<option disabled value > -- select an option --</option>'
                + _generateRoleOptions(role)
            + '</select></td>'
            + '<td ' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValParticipantEmail  + '"><input value="'  + email  + '" type="text"></td>'
            + '<td ' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValParticipantPhone  + '"><input  value="' + phone  + '" type="text"></td>'
            + '<td ' + _opts.carePlanTableColCtrlDataAttr + '="' + _opts.carePlanTableColCtrlDataAttrValParticipantAction + '"><select value="' + action + '">'
                + '<option disabled value > -- select an option -- </option>'
                + '<option value="0" ' + ((action == 0) ? 'selected' : '') + '>E-Authorization</option>'
                + '<option value="1" ' + ((action == 1) ? 'selected' : '') + '>Electronic Notification Only</option>'
                + '<option value="2" ' + ((action == 2) ? 'selected' : '') + '>No Notification</option>'
            + '</select></td>'
            + '</tr>';

        return row;
    }

    /***************************************************************************
     * _buildParticipantsHtmlTblContent */
    /**
     * build html for participants table
     ***************************************************************************/
    function _buildParticipantsHtmlTblContent(carePlanKey, participantObjs) {
        let tblBodyCont = '';

        let carePlanObj = _CarePlanRecs.get(carePlanKey);

        // add the first row for the logged in user
        tblBodyCont += _createParticipantsHtmlTblPlanCreatorRowContent(carePlanObj);

        if (participantObjs) {
            participantObjs.forEach(function (RecObj, _idx) {
            // used for preloading

            let participantObj = (carePlanObj[_opts.carePlanTableColCtrlDataAttrValParticipantsJSON]) ?
                carePlanObj[_opts.carePlanTableColCtrlDataAttrValParticipantsJSON].filter(item => item[_opts.carePlanTableColCtrlDataAttrValParticipantID] == RecObj.id)
                : [];
            // set up dynamic add / remove buttons
            //let selectedAttr = (carePlanObj[_opts.carePlanTableColCtrlDataAttrValParticipantsJSON] && carePlanObj[_opts.carePlanTableColCtrlDataAttrValParticipantsJSON].filter(item => item.id == RecObj.id).length > 0) ?
            //_participantsSelectedRowAttr + '="true"' : "";
            //let selectedIcon = (carePlanObj[_opts.carePlanTableColCtrlDataAttrValParticipantsJSON] && carePlanObj[_opts.carePlanTableColCtrlDataAttrValParticipantsJSON].filter(item => item.id == RecObj.id).length > 0) ?
            //'fa-times' : 'fa-plus';

            let selected = (participantObj.length > 0);
            let action = (selected) ? participantObj[0][_opts.carePlanTableColCtrlDataAttrValParticipantAction] : 0;
            let hiddenparticipantfieldsJSON = {
                address1: ((RecObj.recData7) ? RecObj.recData7 : '')
                , address2: ((RecObj.recData8) ? RecObj.recData8 : '')
                , city: ((RecObj.recData9) ? RecObj.recData9 : '')
                , state: ((RecObj.recData10) ? RecObj.recData10 : '')
                , zip5: ((RecObj.recData11) ? RecObj.recData11 : '')
                , zip4: ((RecObj.recData12) ? RecObj.recData12 : '')
                , fax: ((RecObj.recData13) ? RecObj.recData13 : '')
                , additionalData1: ((RecObj.recData14) ? RecObj.recData14 : '')
                , additionalData2: ((RecObj.recData15) ? RecObj.recData15 : '')
            };

            tblBodyCont += _createParticipantsHtmlTblRowContent(RecObj.id, RecObj.recData1, RecObj.recData2, RecObj.recData3, RecObj.recData6, RecObj.recData4, RecObj.recData5, action, selected, JSON.stringify(hiddenparticipantfieldsJSON), 2, carePlanKey);
            });
        }

        // preload previous data if exists
        //if (typeof (carePlanObj[_opts.carePlanTableColCtrlDataAttrValParticipantsJSON]) != 'undefined') {
        //    carePlanObj[_opts.carePlanTableColCtrlDataAttrValParticipantsJSON].forEach(function (partObj, index) {
        //    $tblBodyCont.append(_createParticipantsHtmlTblRowContent(
        //                                         partObj[_opts.carePlanTableColCtrlDataAttrValParticipantLastName]
        //                                       , partObj[_opts.carePlanTableColCtrlDataAttrValParticipantFirstName]
        //                                       , partObj[_opts.carePlanTableColCtrlDataAttrValParticipantRole]
        //                                       , partObj[_opts.carePlanTableColCtrlDataAttrValParticipantEmail]
        //                                       , partObj[_opts.carePlanTableColCtrlDataAttrValParticipantPhone]
        //                                       , partObj[_opts.carePlanTableColCtrlDataAttrValParticipantAction]));            
        //    });
        //}

        // build table to be rendered in the dialog
        return '<table id="' + _planParticipantsTblID  + '" class="ui-spedmon-gradient-data-table col-12">'
             + '<thead><tr>'
             + '<th>Add/Remove</th>'
             + '<th>Save/Sign</th>'
             + '<th>Last Name</th>'
             + '<th>First Name</th>'
             + '<th>Role</th>'
             + '<th>Email</th>'
             + '<th>Phone</th>'
             + '<th>Action</th>'
             + '</tr></thead>'
             + '<tbody>'
             + tblBodyCont
             + '</tbody>'
             + '</table>';
    }


    /***************************************************************************
     * _renderServicesDialog */
    /**
     * show details dialog for services
     ***************************************************************************/
    function _renderServicesDialog(carePlanKey) {
        let tkn = _opts.tkn;
        let carePlanObj = _CarePlanRecs.get(carePlanKey);

        // get the reqData parameters
        let clientid = $('#clientid').val();
        let includeonlyorpdoctypeids = '2,3';
        let patid = carePlanObj[_opts.carePlanTableColCtrlDataAttrValPatID];

        /****** set up ajax url ***********/

        var reqUrl = "plan_writer_plans.asmx/viewSelORPDocs?tkn=" + tkn;
        var reqData = "{'clientid':'" + clientid + "','pracid':'" + '' + "','patid':'" + patid + "','includeonlyorpdoctypeids':'" + includeonlyorpdoctypeids + "','term':'" + '' + "'}";


        // success callback for ajax
        var fnProcRespSuccess = function (rd) {
            // build html content for dialog
            let ServicesHtmlContent = _buildServicesHtmlTblContent(carePlanObj, rd.SelRecs);

            _opts.$detailsDialogCont.html('').html(ServicesHtmlContent).append(_generateButtonElem('Save', 'float-right mt-2 btn btn-link', 'fas fa-save fa-2x', function () { _saveServiceSelectionsToPlan(carePlanKey); } ));
            
            // attach add new icon for adding new orders for patient
            let $addNewOrderBtn = $('<button class="btn btn-link"><i class="fa fa-plus"></i></button>');
            $addNewOrderBtn.on("click", function () { _openOrdersOrProfilesAddNewScreen(carePlanKey); });
            _opts.$detailsDialogCont.prepend($addNewOrderBtn);

            // attach callback for add and remove (plus & minus) icons
            $('.' + _servicesAddRemButClass).on("click", _toggleAddServiceToPlan);

            // attach callback for edit icon
            $('.' + _servicesEditOrderButClass).on(
                  "click"
                , function () {
                    _openOrdersOrProfilesEditScreen(this, carePlanKey);
                }
            );
            
            // attach callback for delete order icon
            $('.' + _servicesDeleteButClass).on(
                  "click"
                , function () {
                    _deletePatientOrderAndRefreshServicesTbl(this, carePlanKey);
                }
            );

            _opts.$detailsDialogCont.show().dialog(
            {
                width: $(window).width() * 0.65
                , height: $(window).height()
                , title: "Services"
                , show: {
                    effect: 'slide',
                    complete: function () {

                    }
                }
                , hide: {
                    effect: 'slide'
                    , direction: 'left'
                }
            }

            );
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

    }

    /***************************************************************************
     * _getUserSignature */
    /**
     * gets the user's signature using signature pad plugin
     ***************************************************************************/
    function _getUserSignature(carePlanKey, $sigIcon) {
        let carePlanObj = _CarePlanRecs.get(carePlanKey);
        let $sigDiv = $('<div></div>');

        // define callback function for saving user signature
        function saveUserSignature(signatureBase64Data) {
            // save the logged in user's ID
            _updateCurrentCarePlansRecsForSpecificField(carePlanKey, 1, _opts.carePlanTableColCtrlDataAttrValPlanCreatorSigned);

            // source: https://stackoverflow.com/a/28149561
            var tzoffset = (new Date()).getTimezoneOffset() * 60000; //offset in milliseconds
            _updateCurrentCarePlansRecsForSpecificField(carePlanKey, (new Date(Date.now() - tzoffset)).toISOString(), _opts.carePlanTableColCtrlDataAttrValPlanCreatorSignedDate);

            _updateCurrentCarePlansRecsForSpecificField(carePlanKey, signatureBase64Data, _opts.carePlanTableColCtrlDataAttrValPlanCreatorSignatureImg);

            // change the signature icon to a check mark
            $sigIcon.removeClass('fa-signature').addClass('fa-check');

            $sigIcon.off();

            _opts.$detailsDialogCont.mbaHighlight({ color: "#bdffc7", duration: 300 });
        }

        // set up opts
        let _sigOpts = {
                             "inputInitialValue"      : _opts.userPrevSignature
                           , "fnSave"                 : saveUserSignature
                           , "includeRenderDialogBtn" : false
                       }
        $sigDiv.spedmonSignaturePad(null, _sigOpts);
    }

    /***************************************************************************
     * _setPulsatingStateForParticipants */
    /**
     * pulsate the save icon for participants
     ***************************************************************************/

    function _setPulsatingStateForParticipants($tr) {
        var $saveIcon = $tr.find('.' + _participantsSaveButClass);
        $($saveIcon).addClass(_pulsateAnimationClass);
    }

    /***************************************************************************
     * _renderParticipantsDialog */
    /**
     * show participants details for plan
     ***************************************************************************/
    function _renderParticipantsDialog(carePlanKey) {
        let tkn = _opts.tkn;
        let carePlanObj = _CarePlanRecs.get(carePlanKey);

        // get the reqData parameters
        let clientid = $('#clientid').val();
        let patid = carePlanObj[_opts.carePlanTableColCtrlDataAttrValPatID];

        /****** set up ajax url ***********/

        var reqUrl = "patient_persons.asmx/viewSel?tkn=" + tkn;
        var reqData = "{'clientid':'" + clientid + "','patientid':'" + patid + "','term':'" + '' + "'}";

        // success callback for ajax
        var fnProcRespSuccess = function (rd) {

            /*###########################################################################
            #  attach the participants content and render dialog
            ###########################################################################*/
                        
            _opts.$detailsDialogCont.html('').append(_generateAddRecordPlusIcon(function () {
                    let $partsTblRowMkUp = $(_createParticipantsHtmlTblRowContent(null, null, null, null, null, null, null, null, null, null, 1, carePlanKey));
                    $partsTblRowMkUp.find('.' + _participantsAddRemButClass).on("click", _toggleAddParticipantToPlan);
                    $partsTblRowMkUp.find('.' + _participantsSaveButClass).on("click", function () { _saveParticipantToTheDatabase(this, carePlanKey); });
                    $('#' + _planParticipantsTblID + ' tbody').append($partsTblRowMkUp);

                    _setPulsatingStateForParticipants($partsTblRowMkUp);
                }))
                .append(_buildParticipantsHtmlTblContent(carePlanKey, rd.SelRecs))
                .append(_generateButtonElem('Add Selected to Plan', 'float-right mt-2 btn btn-link', 'fas fa-save fa-2x', function () { _saveParticipantsToPlan(carePlanKey, false, true); }));
            
            // attach callback for add and remove (plus & minus) icons
            $('.' + _participantsAddRemButClass).on("click", _toggleAddParticipantToPlan);

            // attach callback for save icon
            $('.' + _participantsSaveButClass).on("click", function () { _saveParticipantToTheDatabase(this, carePlanKey); });

            // attach callback for the signature icon
            $('.' + _participantsSignatureButClass).on("click", function () {
                _getUserSignature(carePlanKey, $(this));
            });

            // attach callback for pulsating the save icon after input change
            $('#' + _planParticipantsTblID).on("change",
                _opts.SvcRecsTableColInputsSubSelector,
                function (e) {
                _setPulsatingStateForParticipants($(e.currentTarget).parents('tr'));
            });
            
            _opts.$detailsDialogCont.show().dialog(
                {
                    width: $(window).width() * 0.65
                    , height: $(window).height()
                    , title: "Participants"
                    , show: {
                        effect: 'slide',
                        complete: function () {
                        }
                    }
                    , hide: {
                        effect: 'slide'
                        , direction: 'left'
                    }
                }

            );
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

    }

    /***************************************************************************
     * _handleTableBodyRowActionForButton */
    /**
     * 
     ***************************************************************************/

    function _handleTableBodyRowActionForButton(e) {
        let _rowAction = _identifyTableBodyRowAction(e, 'i');

        // duplicate record if needed
        if (_rowAction.doWhat == _opts.carePlanTableColCtrlDataAttrValDup) {
            _dupRecRow(_rowAction.recKey, _rowAction.whatRow);
        }

        // save record if needed
        else if (_rowAction.doWhat == _opts.carePlanTableColCtrlDataAttrValSave) {
            _saveRecRow(_rowAction.recKey, _rowAction.whatRow);
        }

        // print record if needed
        else if (_rowAction.doWhat == _opts.carePlanTableColCtrlDataAttrValPrint) {
            _printRecRow(_rowAction.recKey, _rowAction.whatRow);
        }

        // delete record if needed
        else if (_rowAction.doWhat == _opts.carePlanTableColCtrlDataAttrValDelete) {
            _deleteRecRow(_rowAction.recKey, _rowAction.whatRow);
        }

        // authorize plan if needed
        else if (_rowAction.doWhat == _opts.carePlanTableColCtrlDataAttrValAuth) {
            _authorizeRecRow(_rowAction.recKey);
        }

    }

    /***************************************************************************
     * _handleSvcRecsTableBodyRowActionForInput */
    /**
     * 
     ***************************************************************************/

    function _handleSvcRecsTableBodyRowActionForInput(e) {
        let _rowAction = _identifyTableBodyRowAction(e, e.currentTarget.localName);

        // decide what value we want to set for this field
        let inputVal = _rowAction.whatInp.val();
        if (_rowAction.whatInp.attr('type') == 'checkbox') inputVal = _rowAction.whatInp.prop('checked');

        // if plan type selected, make service class dropdown interactable and get its data via AJAX
        if (_rowAction.doWhat == _opts.carePlanTableColCtrlDataAttrValPlanType) {
            // get the plan type selection dropdown for this row so we can update its options
            var $sessionTypeDropdown = _rowAction.whatCol.next('td')
                .children('select[' + _opts.carePlanTableColCtrlDataAttr + '=' + _opts.carePlanTableColCtrlDataAttrValServiceClass + ']');
            loadSessionTypes(_rowAction.recKey, inputVal, _rowAction.whatRow, $sessionTypeDropdown);
        }

        // if service type selected, show details if necessary
        if (_rowAction.doWhat == _opts.carePlanTableColCtrlDataAttrValServiceClass) {
            // get the plan type selection dropdown for this row so we can update its options
            loadServiceDetails(_rowAction.recKey, inputVal, _rowAction.whatRow, _rowAction.whatCol);
        }
        // enter input change into the hidden textarea json
        _updateCurrentCarePlansRecsForSpecificField(_rowAction.recKey, inputVal, _rowAction.doWhat);
    }


    /***************************************************************************
     * _dupRecRow */
    /**
     * duplicates a record object 
     ***************************************************************************/

    var _dupRecRow = function (key) {
        let _newRecObj = JSON.parse(JSON.stringify(_CarePlanRecs.get(key))); //https://www.samanthaming.com/tidbits/70-3-ways-to-clone-objects/
        // set append type
        _newRecObj[_opts.carePlanTableColCtrlDataAttrValAppendType] = 'insertafter';
        _newRecObj[_opts.carePlanTableColCtrlDataAttrValDuppedRecKey] = key;
        _newRecObj[_opts.carePlanTableColCtrlDataAttrValRecID] = null;
        _newRecObj[_opts.carePlanTableColCtrlDataAttrValAuthReqRecID] = null;
        _newRecObj[_opts.carePlanTableColCtrlDataAttrValSaveType] = null;
        _newRecObj[_opts.carePlanTableColCtrlDataAttrValPlanCreatorSigned] = null;
        _newRecObj[_opts.carePlanTableColCtrlDataAttrValPlanCreatorSignedDate] = null;
        _newRecObj[_opts.carePlanTableColCtrlDataAttrValPlanCreatorSignatureImg] = null;
        _newRecObj[_opts.carePlanTableColCtrlDataAttrValCreatedBy] = _opts.userID;
        _newRecObj[_opts.carePlanTableColCtrlDataAttrValCreatedByLname] = _opts.userLastName;
        _newRecObj[_opts.carePlanTableColCtrlDataAttrValCreatedByFname] = _opts.userFirstName;
        _newRecObj[_opts.carePlanTableColCtrlDataAttrValCreatedByEmail] = _opts.userEmail;
        _newRecObj[_opts.carePlanTableColCtrlDataAttrValCreatedByPhone] = _opts.userPhone;
        _newRecObj[_opts.carePlanTableColCtrlDataAttrValHasUnsavedChanges] = true;

        let _newKey = _addRecToCarePlanRecs(_newRecObj);

        if (!_newKey) return;
        _drawCarePlanTableBodyRows();
    }

    /***************************************************************************
     * _saveRecRow */
    /**
     * saves a careplan
     ***************************************************************************/

    function _saveRecRow (key, tblRow) {
        let tkn = _opts.tkn;
        let carePlanObj = _CarePlanRecs.get(key);

        // get the reqData parameters
        let clientid = $('#clientid').val();

        let isEdit   = (carePlanObj[_opts.carePlanTableColCtrlDataAttrValRecID] && carePlanObj[_opts.carePlanTableColCtrlDataAttrValRecID] > 0);
        let savetype = (isEdit) ? $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT : $.spedmonWebUI.RECORD_SAVE_TYPE_NEW;
        let recid    = (isEdit) ? carePlanObj[_opts.carePlanTableColCtrlDataAttrValRecID] : '';
        
        /****** set up ajax url ***********/

        var reqUrl = "plan_writer_plans.asmx/save?tkn=" + tkn;

        var rdObj = {};
		rdObj.clientid   = '' + clientid;
		rdObj.plantypeid = '1';
		rdObj.savetype   = '' + savetype;
		rdObj.recid      = '' + recid;
		rdObj.plandatajson = JSON.stringify(carePlanObj);
		
        var reqData = JSON.stringify(rdObj);

        // callback to send Ajax to save plan
        let fnSavePlanAjax = function () {
            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                .then(responseData => {
                    if (responseData.rawData.recordID == 0) {
                        return;
                    }
                    _updateCurrentCarePlansRecsForSpecificField(key, $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT, _opts.carePlanTableColCtrlDataAttrValSaveType);
                    _updateCurrentCarePlansRecsForSpecificField(key, responseData.rawData.recordID, _opts.carePlanTableColCtrlDataAttrValRecID);
                    _updateCurrentCarePlansRecsForSpecificField(key, false, _opts.carePlanTableColCtrlDataAttrValHasUnsavedChanges);

                    // if user has signed, store signature for plan creator
                    if (carePlanObj[_opts.carePlanTableColCtrlDataAttrValPlanCreatorSignatureImg]) {
                        _opts.userPrevSignature = carePlanObj[_opts.carePlanTableColCtrlDataAttrValPlanCreatorSignatureImg];
                    }

                    $('body').mbaHighlight({ color: "#bdffc7", duration: 300 });
                })
                .catch(responseData => {
                    $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                });
        }

        // check if plan with same start date already exists for patient
        let patHasPlanWithThisDate = false;

        _CarePlanRecs.forEach(function (val, mapKey, map) {
            if (val[_opts.carePlanTableColCtrlDataAttrValRecID]
             && val[_opts.carePlanTableColCtrlDataAttrValRecID] > 0
             && val[_opts.carePlanTableColCtrlDataAttrValSaveType] == 2
             && val[_opts.carePlanTableColCtrlDataAttrValDateOfService]
                == carePlanObj[_opts.carePlanTableColCtrlDataAttrValDateOfService]
             && mapKey != key
            ) {
                patHasPlanWithThisDate = true;
                return false; // break loop
            }
        }); 

        // if patient has plan with same date, warn user
        if (patHasPlanWithThisDate) {
            $.spedmonWebUI.dialogConfirm("Warning", "A plan with this start date already exists. Are you sure you want to continue?", fnSavePlanAjax, function () { });
        } else { // no plans with same date, then save plan with no warnings
            fnSavePlanAjax();
        }
    }
    
    /***************************************************************************
     * _deleteRecRow */
    /**
     * deletes a careplan
     ***************************************************************************/

    function _deleteRecRow (key, tblRow) {
        let tkn = _opts.tkn;
        let carePlanObj = _CarePlanRecs.get(key);

        // get the reqData parameters
        let clientid = $('#clientid').val();
        let recid = carePlanObj[_opts.carePlanTableColCtrlDataAttrValRecID];

        /****** set up ajax url ***********/
        var reqUrl = "plan_writer_plans.asmx/delete?tkn=" + tkn;   

        var reqData = "{'organizationID':'" + clientid + "','ownerID':'" + '' + "','groupID':'" + recid + "'}";

        // success callback for ajax
        var fnProcRespSuccess = function (rd) {
            _removeRecFromRecs(key);
            $(tblRow).remove();
            $('body').mbaHighlight({ color: "#bdffc7", duration: 300 });
        };

        if (!recid) {
            fnProcRespSuccess();
            return;
        }

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
    }

    /***************************************************************************
     * _authorizeRecRow */
    /**
     * requests authorization from participants for a careplan
     ***************************************************************************/

    function _authorizeRecRow(key) {
        let tkn = _opts.tkn;
        let carePlanObj = _CarePlanRecs.get(key);

        // if record hasn't been saved, warn user
        if (!carePlanObj[_opts.carePlanTableColCtrlDataAttrValRecID] || carePlanObj[_opts.carePlanTableColCtrlDataAttrValHasUnsavedChanges]) {
            $.spedmonWebUI.dialogMessage('ERROR', "Please save plan before requesting authorization!", null, 400, 200, null, null, null);
            return;
        }
        
        // if plan creator hasn't signed, warn user
        if (!carePlanObj[_opts.carePlanTableColCtrlDataAttrValPlanCreatorSigned]) {
            $.spedmonWebUI.dialogMessage('ERROR', "Could not request authorization because plan creator has not signed the plan!", null, 400, 200, null, null, null);
            return;
        }

        // get the reqData parameters
        let clientid = $('#clientid').val();
        let recid = carePlanObj[_opts.carePlanTableColCtrlDataAttrValRecID];

        if (!carePlanObj[_opts.carePlanTableColCtrlDataAttrValParticipantsJSON]) {
            $.spedmonWebUI.dialogMessage('ERROR', "There are no participants selected for authorization of plan!", null, 400, 200, null, null, null);
            return;
        }

        // get all participants who need to authorize plan
        let participantsWhoNeedToAuthorizePlan = carePlanObj[_opts.carePlanTableColCtrlDataAttrValParticipantsJSON].filter(x => x[_opts.carePlanTableColCtrlDataAttrValParticipantAction] == 0);

        if (participantsWhoNeedToAuthorizePlan.length != 1 && participantsWhoNeedToAuthorizePlan.length != 2) {
            if (participantsWhoNeedToAuthorizePlan.length < 1)
                $.spedmonWebUI.dialogMessage('ERROR', "There are no participants selected for authorization of plan!", null, 400, 200, null, null, null);
            else
                $.spedmonWebUI.dialogMessage('ERROR', "There are too many participants selected for authorization! Please select up to 2 participants.", null, 400, 200, null, null, null);
            return;
        }

        /****** set up ajax url ***********/
        var reqUrl = "plan_writer_plans.asmx/requestAuthorization?tkn=" + tkn;
        
        var rdObj = {};
        rdObj.clientid                       = clientid;
        rdObj.districtcontactuserid          = carePlanObj[_opts.carePlanTableColCtrlDataAttrValCreatedBy];
        rdObj.patid                          = carePlanObj[_opts.carePlanTableColCtrlDataAttrValPatID];
        rdObj.referencedentityid             = recid;
        rdObj.svcdescription                 = 'Careplan for ' + carePlanObj[_opts.carePlanTableColCtrlDataAttrValDiagnosisName];
        rdObj.prtgrd1personid                = participantsWhoNeedToAuthorizePlan[0][_opts.carePlanTableColCtrlDataAttrValParticipantID];
        rdObj.prtgrd2personid                = (participantsWhoNeedToAuthorizePlan.length > 1) ? participantsWhoNeedToAuthorizePlan[1][_opts.carePlanTableColCtrlDataAttrValParticipantID] : '';
        rdObj.recid                          = (carePlanObj[_opts.carePlanTableColCtrlDataAttrValAuthReqRecID]) ? carePlanObj[_opts.carePlanTableColCtrlDataAttrValAuthReqRecID] : '';

        var reqData = JSON.stringify(rdObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                if (responseData.rawData.recordID == 0) {
                    $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                    return;
                }
                _updateCurrentCarePlansRecsForSpecificField(key, responseData.rawData.recordID, _opts.carePlanTableColCtrlDataAttrValAuthReqRecID);
                _updateCurrentCarePlansRecsForSpecificField(key, false, _opts.carePlanTableColCtrlDataAttrValHasUnsavedChanges);

                $('body').mbaHighlight({ color: "#bdffc7", duration: 300 });
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
            });
    }
    
    /***************************************************************************
     * _printRecRow */
    /**
     * prints a careplan
     ***************************************************************************/

    function _printRecRow (key, tblRow) {
        let tkn = _opts.tkn;
        let carePlanObj = _CarePlanRecs.get(key);

        if (!carePlanObj[_opts.carePlanTableColCtrlDataAttrValRecID]) {
            $.spedmonWebUI.dialogMessage('ERROR', "Please save plan before printing", null, 400, 200, null, null, null);
            return;
        }

        // get the reqData parameters
        let clientid = $('#clientid').val();

        /****** set up ajax url ***********/

        var reqUrl = "plan_writer_plans_file.ashx?tkn=" + tkn +
            '&organizationid=' + clientid + '&groupid=' + carePlanObj[_opts.carePlanTableColCtrlDataAttrValRecID];

        var reqData = "{'organizationid':'" + clientid + "','ownerid':'" + '' + "','groupid':'" + carePlanObj[_opts.carePlanTableColCtrlDataAttrValRecID] + "','recid':'" + '' + "','publishplan':'" + '' + "'}";

        _opts.window.location.href = reqUrl;

        return;
    }


    /*#################################################################################################
      #
      #                                  Public Methods
      #
      #################################################################################################*/

    /***************************************************************************
     * _addCarePlanRec */
    /**
     * 
     ***************************************************************************/

    var _addCarePlanRec = function (patID, patName, id, planDate, diagnosisID, diagnosisName, diagnosisDesc, signedByPlanCreator, signedByPlanCreatorDate, planCreatorSignatureImg
                                  , orpDocSelectionsJSON, participantsJSON, createdBy
                                  , createdByLname, createdByFname, createdByEmail, createdByPhone)    
    {

        let _CarePlanObj = _createCarePlanObj(patID, patName, id, planDate, diagnosisID, diagnosisName, diagnosisDesc, signedByPlanCreator, signedByPlanCreatorDate, planCreatorSignatureImg
            , orpDocSelectionsJSON, participantsJSON, createdBy, createdByLname, createdByFname, createdByEmail, createdByPhone);
        let _CarePlanKey = _addRecToCarePlanRecs(_CarePlanObj);
        if (!_CarePlanKey) return;

        _drawCarePlanTableBodyRows();
    }


    /***************************************************************************
     * _clearCarePlanRecs */
    /**
     * removes all records
     ***************************************************************************/

    var _clearCarePlanRecs = function (warnUser) {
        // confirm with user that they actually want to delete all records
        var onYes = function () {
            // clear recs
            _CarePlanRecs.clear();

            _drawCarePlanTableBodyRows();
        };

        if (!warnUser) {
            onYes();
            return;
        }

        $.spedmonWebUI.dialogConfirm("Please Confirm", "Are you sure you want to remove all records?", onYes, function () { });
    }

    /***************************************************************************
     * _copyValForAllRows */
    /**
     * copies the nearest input's value to all rows
     ***************************************************************************/

    var _copyValForAllRows = function ($elemSelector) {
        // get nearest input's value
        const inputTypes = 'input, textarea, select';
        var $th = $elemSelector.parents('th');
        var $rowIndex = $th.index() + 1;
        var $prevRow = $elemSelector.parents('tr').prev();
        var $inputHeader = $prevRow.find('th:nth-child(' + $rowIndex + ')');
        var $inputElem = $inputHeader.find(inputTypes);
        var inputVal = $inputElem.val();

        // if the input element is 'Date of Service', then update DOS
        if ($inputElem.attr('id') == _opts.dateToCopy) {
            _opts.dos = inputVal;
            $('#dos').val(inputVal);
        }
        // if the input element is 'Plan Type', then update the services dropdown
        else if ($inputElem.attr('id') == _opts.planToCopy) {
            loadSessionTypesForCopy(inputVal);
        }

        // get the attribute name, which represents the field name for this cell
        var $td = $th.parents('table').find('td:nth-child(' + $rowIndex + ')');
        var attributeName = $td.children().attr(_opts.carePlanTableColCtrlDataAttr);

        // loop through the records and find the values
        $td.each(function (idx, $thisTd) {
            // get key of this row
            let $tr = $(this).parent('tr');
            let key = $tr.attr(_opts.carePlanTableRowDataAttr);
            let SvcRecObj = _CarePlanRecs.get(key);

            // if we are trying to change service type, make sure the chosen service is valid for this row
            if (attributeName == _opts.carePlanTableColCtrlDataAttrValServiceClass &&
                (!SvcRecObj[_opts.carePlanTableColCtrlDataAttrValServiceClasses] ||
                    !(SvcRecObj[_opts.carePlanTableColCtrlDataAttrValServiceClasses].find(o => o.id == inputVal)))
            )
                return;

            // copy the value to our object in _SvcRecs
            _updateCurrentCarePlansRecsForSpecificField(key, inputVal, attributeName);

            // instead of redrawing the whole table, just change all the fields that need to be changed
            $($thisTd).children(inputTypes).val(inputVal);

            // if type is plan type, load available services
            if (attributeName == _opts.carePlanTableColCtrlDataAttrValPlanType && inputVal) {
                let $sessionTypeDropdown = $($thisTd).next('td')
                    .children('select[' + _opts.carePlanTableColCtrlDataAttr + '=' + _opts.carePlanTableColCtrlDataAttrValServiceClass + ']');

                loadSessionTypes(key, inputVal, $tr, $sessionTypeDropdown);
            }
        });

        // clear out original input when done
        if (!$elemSelector.hasClass("noReset")) {
            $inputElem.val('');
        }
    }

    /***************************************************************************
     * _init */
    /**
     * Call once
     * 
     ***************************************************************************/

    var _init = function (opts) {

        _initMode = true;
        _opts = opts;
        _opts.carePlanTableRowDataAttr                                   = 'data-careplan-id';
        _opts.carePlanTableColCtrlDataAttr                               = 'data-SvcRec-ctrl';
        _opts.carePlanTableColCtrlDataAttrValRemove                      = 'remove';
        _opts.carePlanTableColCtrlDataAttrValDup                         = 'duplicate';
        _opts.carePlanTableColCtrlDataAttrValSave                        = 'save';
        _opts.carePlanTableColCtrlDataAttrValPrint                       = 'print';
        _opts.carePlanTableColCtrlDataAttrValDelete                      = 'delete';
        _opts.carePlanTableColCtrlDataAttrValAuth                        = 'authorize';
        _opts.carePlanTableColCtrlDataAttrValPatientName                 = 'patName';
        _opts.carePlanTableColCtrlDataAttrValPatID                       = 'patID';
        _opts.carePlanTableColCtrlDataAttrValSaveType                    = 'saveType';
        _opts.carePlanTableColCtrlDataAttrValRecID                       = 'recID';
        _opts.carePlanTableColCtrlDataAttrValDuppedRecKey                = 'duppedRecKey';
        _opts.carePlanTableColCtrlDataAttrValAppendType                  = 'appendType';
        _opts.carePlanTableColCtrlDataAttrValAuthReqRecID                = 'authReqRecID';
                                                                         
        _opts.carePlanTableColCtrlDataAttrValID                          = 'id';
        _opts.carePlanTableColCtrlDataAttrValDateOfService               = 'planDate';
        _opts.carePlanTableColCtrlDataAttrValDiagnosisID                 = 'diagnosisID';
        _opts.carePlanTableColCtrlDataAttrValDiagnosisName               = 'diagnosisName';
        _opts.carePlanTableColCtrlDataAttrValDiagnosisDesc               = 'diagnosisDesc';
        _opts.carePlanTableColCtrlDataAttrValServiceSelectionsJSON       = 'orpDocSelectionsJSON';
        _opts.carePlanTableColCtrlDataAttrValParticipantsJSON            = 'participantsJSON';
        _opts.carePlanTableColCtrlDataAttrValParticipantID               = 'participantID';
        _opts.carePlanTableColCtrlDataAttrValParticipantAction           = 'participantAction';
        _opts.carePlanTableColCtrlDataAttrValParticipantLastName         = 'participantLastName';
        _opts.carePlanTableColCtrlDataAttrValParticipantFirstName        = 'participantFirstName';
        _opts.carePlanTableColCtrlDataAttrValParticipantRole             = 'participantRole';
        _opts.carePlanTableColCtrlDataAttrValParticipantEmail            = 'participantEmail';
        _opts.carePlanTableColCtrlDataAttrValParticipantPhone            = 'participantPhone';
        _opts.carePlanTableColCtrlDataAttrValParticipantAction           = 'participantAction';
        _opts.carePlanTableColCtrlDataAttrValHiddenParticipantFieldsJSON = 'hiddenParticipantFieldsJSON';
        _opts.carePlanTableColCtrlDataAttrValPlanCreatorSigned           = 'planCreatorSigned';
        _opts.carePlanTableColCtrlDataAttrValPlanCreatorSignedDate       = 'planCreatorSignedDate';
        _opts.carePlanTableColCtrlDataAttrValPlanCreatorSignatureImg     = 'planCreatorSignatureImg';
        _opts.carePlanTableColCtrlDataAttrValCreatedBy                   = 'createdBy';
        _opts.carePlanTableColCtrlDataAttrValCreatedByLname              = 'planCreatorLname';
        _opts.carePlanTableColCtrlDataAttrValCreatedByFname              = 'planCreatorFname';
        _opts.carePlanTableColCtrlDataAttrValCreatedByEmail              = 'planCreatorEmail';
        _opts.carePlanTableColCtrlDataAttrValCreatedByPhone              = 'planCreatorPhone';
        _opts.carePlanTableColCtrlDataAttrValHasUnsavedChanges           = 'hasUnsavedChanges';

        _opts.SvcRecsTableColButsSubSelector = 'tr td i';
        _opts.SvcRecsTableColInputsSubSelector = 'tr td input, tr td select, tr td textarea';

        // append dialog container to body
        _opts.$detailsDialogCont = $('<div></div>');
        $('main').append(_opts.$detailsDialogCont);

        // probably a bad way to do this, but here we move the table to its own line
        $(_opts.carePlanTableSelector).parent().css({ "display": "contents", "padding-left": "15px" });

        // callback for inputs only
        $(_opts.carePlanTableBodySelector).on('change'
            , _opts.SvcRecsTableColInputsSubSelector
            , function (e) { _handleSvcRecsTableBodyRowActionForInput(e); });

        //callback for buttons only
        $(_opts.carePlanTableBodySelector).on('click'
            , _opts.SvcRecsTableColButsSubSelector
            , function (e) { _handleTableBodyRowActionForButton(e); });

        // clear the table (for the case where the user clicks the back button to go to this screen)
        $(_opts.carePlanTableBodySelector).children().remove();

        _CarePlanRecs = new Map();

        let _carePlanRecsJSON = $(_opts.carePlanRecsTextAreaSelector).val();

        try {
            let _carePlanObjs = JSON.parse(_carePlanRecsJSON);

            $.each(_carePlanObjs, function (_idx, _carePlanObj) {
                try {
                    _carePlanObj[_opts.carePlanTableColCtrlDataAttrValServiceSelectionsJSON] = JSON.parse(_carePlanObj[_opts.carePlanTableColCtrlDataAttrValServiceSelectionsJSON]);
                    _carePlanObj[_opts.carePlanTableColCtrlDataAttrValParticipantsJSON]      = JSON.parse(_carePlanObj[_opts.carePlanTableColCtrlDataAttrValParticipantsJSON]);
                } catch (e) {
                }

                _addRecToCarePlanRecs(_carePlanObj);
            });
        } catch (e) {

        }

        //_initialRoster = new Map(_currentRoster);
        _drawCarePlanTableBodyRows();

        _initMode = false;
    };

    /****************************************************************************/

    return {
          init: _init
        , addCarePlanRec: _addCarePlanRec
        , clearCarePlanRecs: _clearCarePlanRecs
        , copyValForAllRows: _copyValForAllRows
    };

})(jQuery);
