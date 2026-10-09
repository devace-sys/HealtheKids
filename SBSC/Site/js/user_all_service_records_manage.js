const DATA_ATTR_NOTES_LIB_CTRL_NAME          = 'data-notes-lib';
const DATA_ATTR_NOTES_LIB_CTRL_NAME_OPEN_DIA = 'opendia';
const CSS_CLASS_RMTS_MOMENT_TOGGLED          = 'svcrec-is-rmts-moment';
const CONST_SVC_DETAILS_REF                  = 'svc-details-ref';

/*###############################################################################################
  #
  #          Supporting functions for service details (service name column)
  #
  ################################################################################################*/

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

function clearServiceDetails (mapReference) {
    /* Note: mapReference is either svcDetailsRefObj.addCellValRefsMap or uiActionObj.saveableFieldsMap */
    $(mapReference.get('hasSvcDetFlags')).val('').attr('value', '');
    $(mapReference.get('svcDetFlag1')).MBA_input_radio('clearValue');
    $(mapReference.get('svcDetFlag2')).MBA_input_radio('clearValue');
    $(mapReference.get('svcDetFlag3')).MBA_input_radio('clearValue');
    $(mapReference.get('svcDetFlag4')).MBA_input_radio('clearValue');
}

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function clearServiceSelection(uiActionObj) {
    /* Note: Called as part of build in restView handler for user interface actions */
    if (uiActionObj.e.type === 'change') {
        clearServiceDetails(uiActionObj.saveableFieldsMap);
        let _svcSel = uiActionObj.saveableFieldsMap.get('nameid');
        $(_svcSel).attr(MBA.RestViewCommon.ATTR_NAME_ALT_VALUE, '').val('').attr('value', '');
        MBA.RestViewCommon.fnForceAutoCompleteSearch(_svcSel);
    }
}
