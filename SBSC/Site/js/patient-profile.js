;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PatientProfileCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, common
 */

MBA.PatientProfileCommon = (function ($)
{
    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME      = 'Patient Profile Common Methods';
    const _THIS_NS        = 'mba-patient-profile';
    const _JQ_DATA_NAME   = 'jq-' + _THIS_NS;
    const _DATA_ATTR_BASE = 'data-' + _THIS_NS;
    const _SAVE_TYPE_NEW  = '1';
    const _SAVE_TYPE_EDIT = '2';

    const _CLASS_NAME_PROFILE_SHRINK      = 'mba-profile-shrink-size';
    const _CLASS_NAME_CONTAINER           = 'mba-profile-container';
    const _CLASS_NAME_PROFILE_HEADER      = 'mba-profile-header';

    const _CLASS_NAME_PROFILE_HEADER_ROW_0                 = 'mba-profile-header-row-0';
    const _CLASS_NAME_PROFILE_HEADER_ROW_1                 = 'mba-profile-header-row-1';
    const _CLASS_NAME_PROFILE_HEADER_ROW_2                 = 'mba-profile-header-row-2';

    const _CLASS_NAME_PROFILE_HEADER_ROW_0_CONTROLS        = 'mba-profile-header-row-0-controls';
    const _CLASS_NAME_PROFILE_HEADER_ROW_0_PERSON          = 'mba-profile-header-row-0-person';

    const _CLASS_NAME_PROFILE_BUTTON_SHRINK                = 'mba-profile-button-shrink';
    const _CLASS_NAME_PROFILE_BUTTON_ICON_SHRINK           = 'mba-profile-button-icon-shrink';

    const _CLASS_NAME_PROFILE_BUTTON_RESTORE               = 'mba-profile-button-restore';
    const _CLASS_NAME_PROFILE_BUTTON_ICON_RESTORE          = 'mba-profile-button-icon-restore'
    const _CLASS_NAME_PROFILE_HEADER_PERSON_IMG_CONT       = 'mba-profile-header-person-image-cont';
    const _CLASS_NAME_PROFILE_HEADER_PERSON_IMG            = 'mba-profile-header-person-image';

    const _CLASS_NAME_PROFILE_HEADER_PERSON                = 'mba-profile-header-person';
    const _CLASS_NAME_PROFILE_HEADER_PERSON_NAME           = 'mba-profile-header-person-name';
    
    const _CLASS_NAME_PROFILE_HEADER_PERSON_NAME_AGE       = 'mba-profile-header-person-age';
    const _CLASS_NAME_PROFILE_HEADER_PERSON_NAME_AGE_LABEL = 'mba-profile-header-person-age-label';
    const _CLASS_NAME_PROFILE_HEADER_PERSON_NAME_AGE_VALUE = 'mba-profile-header-person-age-value';

    const _CLASS_NAME_PROFILE_HEADER_PERSON_NAME_EMAIL_PHONE = 'mba-profile-header-person-email-phone';
    const _CLASS_NAME_PROFILE_HEADER_PERSON_NAME_EMAIL       = 'mba-profile-header-person-email';
    const _CLASS_NAME_PROFILE_HEADER_PERSON_NAME_PHONE       = 'mba-profile-header-person-phone';

    const _CLASS_NAME_PROFILE_CTRLS                       = 'mba-profile-ctrls';
    const _CLASS_NAME_PROFILE_CTRL_HIDDEN                 = 'mba-profile-ctrl-hidden';
    const _CLASS_NAME_PROFILE_CTRL_NOTICE_CONTAINER       = 'mba-profile-ctrl-notice-container';
    const _CLASS_NAME_PROFILE_CTRL_NOTICE_MESSAGE         = 'mba-profile-ctrl-notice-message';
    const _CLASS_NAME_PROFILE_CTRL_NOTICE_ICON            = 'mba-profile-ctrl-notice-icon';
    const _CLASS_NAME_PROFILE_CTRL_BUTTON                 = 'mba-profile-ctrl-button';
    const _CLASS_NAME_PROFILE_CTRL_BUTTON_LABEL           = 'mba-profile-ctrl-button-label';
    const _CLASS_NAME_PROFILE_CTRL_BUTTON_ICON            = 'mba-profile-ctrl-button-icon';
    const _CLASS_NAME_PROFILE_CTRL_REQUIRED_FIELD_NOTICE  = 'mba-profile-ctrl-notice-required-field-notice';

    const _CLASS_NAME_FORM                        = 'mba-profile-form';
    const _CLASS_NAME_FORM_FIELD_SET              = 'mba-profile-form-field-set';
    const _CLASS_NAME_FORM_FIELD_SET_LEGEND       = 'mba-profile-form-field-set-legend';
    const _CLASS_NAME_FORM_FIELD_SET_CONTENT      = 'mba-profile-form-field-set-content';
    const _CLASS_NAME_FORM_FIELD_SET_CONTENT_LINE = 'mba-profile-form-field-set-content-line'
	const _CLASS_NAME_FORM_FIELD_CONTAINER        = 'mba-profile-form-field-container';
    const _CLASS_NAME_FORM_FIELD_CONTAINER_HIDDEN = 'mba-profile-form-field-container-hidden';
    const _CLASS_NAME_FORM_FIELD_LABEL            = 'mba-profile-form-field-label';
    const _CLASS_NAME_FORM_FIELD                  = 'mba-profile-form-field';

    const _CLASS_NAME_FORM_FIELD_AUTO_COMPLETE_CONT      = 'mba-profile-form-field-auto-complete-container';
    const _CLASS_NAME_FORM_FIELD_AUTO_COMPLETE_BUT       = 'mba-profile-form-field-auto-complete-button';
    const _CLASS_NAME_FORM_FIELD_AUTO_COMPLETE_MENU      = 'mba-profile-form-field-auto-complete-menu';
    const _CLASS_NAME_FORM_FIELD_AUTO_COMPLETE_MENU_ITEM = 'mba-profile-form-field-auto-complete-menu-item';
    const _CLASS_NAME_FORM_FIELD_AUTO_COMPLETE_SPINNER   = 'mba-profile-form-field-auto-complete-spinner';

    const _CLASS_NAME_FORM_FIELD_FILES_MANAGE_HIDDEN = 'mba-profile-form-field-files-manage-hidden';
    const _CLASS_NAME_FORM_FIELD_FILES_MANAGE_BUTTON = 'mba-profile-form-field-files-manage-button';
    const _CLASS_NAME_FORM_FIELD_FILES_MANAGE_ICON   = 'mba-profile-form-field-files-manage-icon';

    const _DATA_ATTR_FORM_FIELD_REQUIRED = _DATA_ATTR_BASE + '-required';
    const _DATA_ATTR_AUTO_COMPLETE                  = _DATA_ATTR_BASE + '-autocomplete';
    const _DATA_ATTR_AUTO_COMPLETE_FOR_SAVE_AS_NAME = _DATA_ATTR_BASE + '-autocomplete-for-save-as-name';
    const _DATA_ATTR_FORM_FIELD_USER_REFERENCE_NAME = _DATA_ATTR_BASE + '-user-ref-name';
    //const _DEFAULT_AVATAR_BASE64 = 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MTIgNTEyIj4KICA8Y2lyY2xlIGN4PSIyNTYiIGN5PSIyNTYiIHI9IjI1NiIgZmlsbD0iIzNiODJmNiIvPgogIDxwYXRoIGQ9Ik0yNTYgMjg4YzM5LjggMCA3Mi0zMi4yIDcyLTcycy0zMi4yLTcyLTcyLTcyLTcyIDMyLjItNzIgNzIgMzIuMiA3MiA3MiA3MnptODAgMjRoLTEzLjZjLTguOCA0LjEtMTguNiA2LjQtMjguOCA3LjItMS41LjEtMyAuMi00LjUgLjJzLTMtLjEtNC41LS4yYy0xMC4yLS44LTIwLTMuMS0yOC44LTcuMkgxNzZjLTQ0LjIgMC04MCAzNS44LTgwIDgwdjI0YzAgMTMuMyAxMC43IDI0IDI0IDI0aDI3MmMxMy4zIDAgMjQtMTAuNyAyNC0yNHYtMjRjMC00NC4yLTM1LjgtODAtODAtODB6IiBmaWxsPSIjZmZmIi8+Cjwvc3ZnPg==';    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _CLASS_NAME_SSID_SEARCH_CONTAINER = 'mba-profile-ssid-search-container';
    const _CLASS_NAME_SSID_SEARCH_LABEL     = 'mba-profile-ssid-search-label';
    const _CLASS_NAME_SSID_SEARCH_INPUT     = 'mba-profile-ssid-search-input';
    const _CLASS_NAME_SSID_SEARCH_BUTTON    = 'mba-profile-ssid-search-button';

	const _CLASS_NAME_PROFILE_HEADER_MINOR_CONSENT_ACTIVE   = 'mba-profile-header-minor-consent-active';
    const _CLASS_NAME_PROFILE_MINOR_CONSENT_NOTICE          = 'mba-profile-minor-consent-notice';
    const _CLASS_NAME_PROFILE_MINOR_CONSENT_NOTICE_HIDDEN   = 'mba-profile-minor-consent-notice-hidden';
    const _CLASS_NAME_PROFILE_MINOR_CONSENT_NOTICE_ICON     = 'mba-profile-minor-consent-notice-icon';
    const _CLASS_NAME_PROFILE_MINOR_CONSENT_NOTICE_TEXT     = 'mba-profile-minor-consent-notice-text';

    const _CLASS_NAME_PROFILE_PORTAL_INVITE_BUTTON          = 'mba-profile-portal-invite-button';
    const _CLASS_NAME_PROFILE_PORTAL_MESSAGE_BUTTON         = 'mba-profile-message-button';

    const _CLASS_NAME_PROFILE_PORTAL_STATUS_RED             = 'mba-profile-portal-status-red';
    const _CLASS_NAME_PROFILE_PORTAL_STATUS_YELLOW          = 'mba-profile-portal-status-yellow';
    const _CLASS_NAME_PROFILE_PORTAL_STATUS_GREEN           = 'mba-profile-portal-status-green';

    const _CLASS_NAME_PROFILE_EMAIL_REQUIRED_MISSING        = 'mba-profile-email-required-missing';
    
    const _PAGE_CONTEXT_PATIENT_PROFILE     = 1;

    const _DEFAULT_OPTIONS = {
          PARM_NAME_CLIENT_ID : ''
        , PARM_NAME_REC_ID  : ''
        , PARM_NAME_SAVE_TYPE : ''
        , PARM_NAME_VALIDATE_REC : ''
        , PARM_NAME_EDIT_DEL_REASON : ''
        , PARM_NAME_SEARCH_TERM: ''
        , VALUE_SAVE_TYPE: '1'
        , VALUE_PAT_ID:''
        , sessionTimeOutUrl : ''
        , baseUrlSaveProfile : ''
        , baseUrlGetProfile : ''
        , baseUrlSiteIDSel: ''
        , baseUrlPreferredContactMethodIDSel: ''
        , reloadProfileAfterSaveNew: false
        , showSaveProfileLabelInSaveButton:true
        , fnAfterSaveNew: function (patid) { return; }
        , fnAfterSaveEdit: function (patid) { return; }
        , fnAfterLoad: function (patRecordObj) { return; }
        , fnBeforeShrink: function () { return; }
        , fnAfterShrink: function () { return; }
        , fnBeforeRestore: function () { return; }
        , fnAfterRestore: function () { return; }
        , baseUrlSaveProfilePicture: ''     /* Profile picture save URL */
        , baseUrlGetProfilePicture: ''      /* Profile picture get URL */
        , baseUrlDeleteProfilePicture: ''   /* Profile picture delete URL */
        , enableProfilePictureUpload: true  /* Enable profile picture upload */
        , baseUrlFindStudentsWithSSID:''
        , relatedRestViewStoredFilesRef: null
        , baseUrlInvitePatientPortal: ''
        , baseUrlSaveMessage: ''
        , baseUrlurlRecipientSrc: ''
        , currentPage: ''
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnGetMe
     * @private
     * @summary      Gets reference to original elemementid
     * @description  Gets reference to original elemementid
     * @param  {Object}  elem  Element reference
     */

    let _fnGetMe = function (elementid) {
        return $('#' + elementid);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnGetDataObj
     * @private
     * @summary      Gets reference to data object
     * @description  Gets reference to the jQuery data object associated with this element
     * @param  {Object}  $me  Element reference
     */

    let _fnGetDataObj = function ($me) {
        let dataObj = $($me).data(_JQ_DATA_NAME);
        if (!dataObj) throw new Error('An instance of ' + _THIS_NAME + ' is required');
        return dataObj;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnSetDataObj
     * @private
     * @summary      Sets value of data object
     * @description  Sets value of data object
     * @param  {Object}  $me      Element reference
     * @param  {Object}  dataObj  Data obj for this lib
     */

    let _fnSetDataObj = function ($me, dataObj) {
        $($me).data(_JQ_DATA_NAME, dataObj);
        return;
    };

    /*###########################################################################################
     *#
     *#                           Shrink and Restore Methods
     *#
     *##########################################################################################*/
    
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnDoShrink
     * @private
     * @summary      Shrinks to a minimal size
     * @description  Shrinks to a minimal size
     * @param  {Object}  $me      Element reference     
     */

    let _fnDoShrink = function ($me) {
        let dataObj = _fnGetDataObj($me);

        dataObj.opts.fnBeforeShrink();
        $(dataObj.butProfileShrink).hide();
        $(dataObj.butProfileRestore).show();

        $(dataObj.me).addClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeader).addClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderRow0).addClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderRow1).addClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderRow2).addClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderPersonImageContainer).addClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderPersonImage).addClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderPerson).addClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderPersonsName).addClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderPersonsAge).addClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.requiredFieldNotice).addClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileForm).addClass(_CLASS_NAME_PROFILE_SHRINK);

        dataObj.opts.fnAfterShrink();
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnDoRestore
     * @private
     * @summary      Restores to original size
     * @description  Restores to original size
     * @param  {Object}  $me      Element reference     
     */

    let _fnDoRestore = function ($me) {

        let dataObj = _fnGetDataObj($me);
        dataObj.opts.fnBeforeRestore();

        $(dataObj.butProfileShrink).show();
        $(dataObj.butProfileRestore).hide();

        $(dataObj.me).removeClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeader).removeClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderRow0).removeClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderRow1).removeClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderRow2).removeClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderPersonImageContainer).removeClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderPersonImage).removeClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderPerson).removeClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderPersonsName).removeClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileHeaderPersonsAge).removeClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.requiredFieldNotice).removeClass(_CLASS_NAME_PROFILE_SHRINK);
        $(dataObj.profileForm).removeClass(_CLASS_NAME_PROFILE_SHRINK);

        dataObj.opts.fnAfterRestore();
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /*###########################################################################################
     *#
     *#                           Loading and Saving Data Methods 
     *#
     *##########################################################################################*/
    
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnClearFields
     * @private
     * @summary      Loads default values
     * @description  Loads default values
     * @param  {Object}  $me      Element reference     
     */

    let _fnClearFields = function ($me) {

        let dataObj = _fnGetDataObj($me);        

        let _fnPopulateField = function (fieldDef, key, map) {
            if (fieldDef.supportsDefault === true) {
              $('#' + fieldDef.ctrlID).val(fieldDef.defaultValue);
            }
        };
        dataObj.fieldDefinitions.forEach(_fnPopulateField);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnLoadFields
     * @private
     * @summary      Loads profile data then populates fields
     * @description  Loads profile data then populates fields
     * @param  {Object}  $me      Element reference     
     */

    let _fnLoadFields = function ($me) {

        let dataObj = _fnGetDataObj($me);
        let requestObj = {};

        let _fnPopulateFields = function (patRecordObj, fieldDefs) {
            let _fnPopulateField = function (fieldDef, key, map) {              
              let fldValue = patRecordObj[key] + '';
              $('#' + fieldDef.ctrlID).val(fldValue);
              if (fieldDef.hasSupportingField === true) {
                  let supFldVal = patRecordObj[fieldDef.supportingFieldName] + '';
                  $('#' + fieldDef.supportingCtrlID).val(supFldVal);
              }              
            };
            fieldDefs.forEach(_fnPopulateField);
        };

        requestObj[dataObj.opts.PARM_NAME_REC_ID] = dataObj.opts.VALUE_PAT_ID;
        let requestJSON = JSON.stringify(requestObj);

        $(dataObj.waitNotice).removeClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
        $(dataObj.saveButton).addClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlGetProfile, requestJSON, dataObj.opts.sessionTimeOutUrl)
            .then(responseData => {
                let patRecordObj = responseData.rawData.data;
                
                $(dataObj.profileHeaderPersonsName).html(patRecordObj.name);
                $(dataObj.profileHeaderPersonsAgeVal).html('' + patRecordObj.ageCurrent);

                $(dataObj.profileHeaderPersonsEmail).html(patRecordObj.email);
                $(dataObj.profileHeaderPersonsEmail).attr('title', 'Click to send email');
                $(dataObj.profileHeaderPersonsEmail).attr('href', 'mailto:' + patRecordObj.email);

                $(dataObj.profileHeaderPersonsPhone).html(patRecordObj.phone);
                $(dataObj.profileHeaderPersonsPhone).attr('title', 'Click to call (if your device supports this)');
                $(dataObj.profileHeaderPersonsPhone).attr('href', 'tel:' + patRecordObj.phone);

                _fnPopulateFields(patRecordObj, dataObj.fieldDefinitions);
                _fnMissingEmail($me);
				_fnToggleMinorConsentFieldsVisibility($me);
                _fnLoadProfilePicture($me, dataObj);
                _fnSetPortalInviteButtonState($me, patRecordObj);
                
                $(dataObj.waitNotice).addClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
                $(dataObj.saveButton).removeClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
                dataObj.opts.fnAfterLoad(patRecordObj);
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem Loading The Profile', err.message, {});
                $(dataObj.waitNotice).addClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
                $(dataObj.saveButton).removeClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
            });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
    * @function     _fnSaveFields
    * @private
    * @summary      Saves profile data 
    * @description  Saves profile data
    * @param  {Object}  $me      Element reference
    */

    let _fnSaveFields = function ($me) {

        let dataObj  = _fnGetDataObj($me);
        let _pfd = MBA.ComponentCommon.fnFormToObjIncludingDisabled(dataObj.profileForm);
        let _arrNvps = MBA.ComponentCommon.fnObjToNameValuesObj(_pfd);

        let _valClientID = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        let _valRecID    = dataObj.opts.VALUE_PAT_ID;
        let _valSaveType = dataObj.opts.VALUE_SAVE_TYPE;

        _arrNvps.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_CLIENT_ID, _valClientID));
        _arrNvps.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_REC_ID, _valRecID));
        _arrNvps.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_SAVE_TYPE, _valSaveType));
        _arrNvps.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_EDIT_DEL_REASON, ''));
        _arrNvps.push(MBA.ComponentCommon.fnCreateNameValueObject(dataObj.opts.PARM_NAME_VALIDATE_REC, 'N'));

        let requestJSON = MBA.ComponentCommon.fnJSONFromArrNameValues(_arrNvps);

        $(dataObj.waitNotice).removeClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
        $(dataObj.saveButton).addClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlSaveProfile, requestJSON, dataObj.opts.sessionTimeOutUrl)
            .then(responseData => {
                $(dataObj.waitNotice).addClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
                $(dataObj.saveButton).removeClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);                
                if (_valSaveType == _SAVE_TYPE_NEW) {
                    let _newPatID = responseData.rawData.recordID;;
                    dataObj.opts.VALUE_PAT_ID = '' + _newPatID;
                    dataObj.opts.VALUE_SAVE_TYPE = _SAVE_TYPE_EDIT;
                    _fnSetDataObj($me, dataObj);
                    if (dataObj.opts.reloadProfileAfterSaveNew === true) {
                        $(dataObj.profileHeaderRow1).show();
                        _fnLoadFields($me);
                    }
                    if (dataObj.opts.enableProfilePictureUpload) {
                        _fnInitializeProfilePictureUploader($me, dataObj);
                    }
                    dataObj.opts.fnAfterSaveNew(_newPatID);
                } else if (_valSaveType == _SAVE_TYPE_EDIT) {
                    _fnLoadFields($me);
                    dataObj.opts.fnAfterSaveEdit(_valRecID);
                }
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
                $(dataObj.waitNotice).addClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
                $(dataObj.saveButton).removeClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
            });
    };

    /*###########################################################################################
     *#
     *#                       Find Existing Student By SSID Methods
     *#
     *##########################################################################################*/

    /**
     * @function     _fnDoOpenDiaWithFindStudentsBySSIDResults
     * @private
     * @summary      Parses results and opens dialog to display options
     * @param  {Object}  responseData Results
     */

    let _fnDoOpenDiaWithFindStudentsBySSIDResults = function (responseData) {
       

        if (!responseData || !responseData.rawData || !responseData.rawData.SelRecs || responseData.rawData.SelRecs.length === 0) {
            let $noResults = $(`
            <div style="text-align: center; padding: 40px;">
                <i class="fas fa-search" style="font-size: 48px; color: #d1d5db; display: block; margin-bottom: 16px;"></i>
                <h3 style="color: #6b7280; margin-bottom: 8px;">No Students Found</h3>
                <p style="color: #9ca3af;">No students were found with that SSID</p>
            </div>
        `);

            $noResults.dialog({
                modal: true
                , width: 400
                , title: 'Search Results'
                , buttons: [{
                    text: "OK"
                    , click: function () { $(this).dialog("close"); }
                }]
            });
            return;
        }

        let $dialogContent = $('<div class="ssid-search-results"></div>');
        let selRecs = responseData.rawData.SelRecs;

        selRecs.forEach(function (rec) {
            let recExistsForCallingClient = (rec.recData9 === 'Y');

            let statusBadge = recExistsForCallingClient
                ? '<span class="ssid-status-badge badge-existing">Your Student</span>'
                : '';

            let $recContainer = $(`
            <div class="ssid-result-item">
                <div class="ssid-result-header">
                    <h3 class="ssid-student-name">${rec.recData1}, ${rec.recData2}</h3>
                    ${statusBadge}
                </div>
                
                <div class="ssid-student-details">
                    <div class="detail-item">
                        <span class="detail-label">Date of Birth</span>
                        <span class="detail-value">${rec.recData5 || 'N/A'}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Gender</span>
                        <span class="detail-value">${rec.recData6 || 'N/A'}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">SSID</span>
                        <span class="detail-value">${rec.recData7}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Age</span>
                        <span class="detail-value">${rec.recData8 || 'N/A'} years</span>
                    </div>
                </div>
            </div>
        `);

            $recContainer.css({
                'background': 'linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%)'
                , 'border': '1px solid #e0e6ed'
                , 'border-radius': '12px'
                , 'padding': '20px'
                , 'margin-bottom': '16px'
                , 'transition': 'all 0.3s ease'
                , 'box-shadow': '0 2px 4px rgba(0,0,0,0.05)'
            });

            $('.ssid-student-name', $recContainer).css({
                'font-size': '18px'
                , 'font-weight': '600'
                , 'color': '#1f2937'
                , 'margin': '0 0 4px 0'
            });

            $('.ssid-result-header', $recContainer).css({
                'display': 'flex'
                , 'justify-content': 'space-between'
                , 'align-items': 'flex-start'
                , 'margin-bottom': '12px'
            });

            $('.ssid-status-badge', $recContainer).css({
                'display': 'inline-block'
                , 'padding': '4px 12px'
                , 'border-radius': '20px'
                , 'font-size': '12px'
                , 'font-weight': '500'
                , 'text-transform': 'uppercase'
                , 'letter-spacing': '0.5px'
            });

            $('.badge-existing', $recContainer).css({
                'background': '#d1fae5'
                , 'color': '#065f46'
            });

            $('.badge-cross-client', $recContainer).css({
                'background': '#dbeafe'
                , 'color': '#1e40af'
            });

            $('.ssid-student-details', $recContainer).css({
                'display': 'grid'
                , 'grid-template-columns': 'repeat(auto-fit, minmax(150px, 1fr))'
                , 'gap': '12px'
                , 'margin-bottom': '16px'
            });

            $('.detail-item', $recContainer).css({
                'display': 'flex'
                , 'flex-direction': 'column'
            });

            $('.detail-label', $recContainer).css({
                'font-size': '11px'
                , 'color': '#6b7280'
                , 'text-transform': 'uppercase'
                , 'letter-spacing': '0.5px'
                , 'margin-bottom': '2px'
            });

            $('.detail-value', $recContainer).css({
                'font-size': '14px'
                , 'color': '#1f2937'
                , 'font-weight': '500'
            });

            let $actionButton = $('<button type="button" class="ssid-action-button"></button>');

            $actionButton.css({
                'width': '100%'
                , 'padding': '10px 20px'
                , 'border': 'none'
                , 'border-radius': '8px'
                , 'font-size': '14px'
                , 'font-weight': '600'
                , 'cursor': 'pointer'
                , 'transition': 'all 0.2s ease'
                , 'display': 'flex'
                , 'align-items': 'center'
                , 'justify-content': 'center'
                , 'gap': '8px'
            });

            if (recExistsForCallingClient) {
                if (rec.recData10 && rec.recData11 && rec.recData10 !== '-1' && rec.recData11 !== '-1') {
                    $actionButton.html('<i class="fas fa-user-circle"></i> View Profile');
                    $actionButton.addClass('btn-view-profile');
                    $actionButton.css({
                        'background': 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                        'color': 'white'
                    });

                    $actionButton.on('click', function () {
                        $dialogContent.dialog('close');

                        let currentUrl = window.location.href;
                        let tknMatch = currentUrl.match(/tkn=([^&]*)/);
                        let amdMatch = currentUrl.match(/amd=([^&]*)/);

                        let params = [];
                        if (tknMatch) params.push('tkn=' + tknMatch[1]);
                        if (amdMatch) params.push('amd=' + amdMatch[1]);
                        params.push('savetype=2');
                        params.push('recid=' + rec.recData11);
                        params.push('clientid=' + rec.recData10);

                        let url = 'user_all_pat_save_2.aspx?' + params.join('&');
                        window.location.href = url;
                    });
                }
            } else {
                $actionButton.html('<i class="fas fa-copy"></i> Use This Record');
                $actionButton.addClass('btn-copy-record');
                $actionButton.css({
                    'background': 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)',
                    'color': 'white'
                });

                $actionButton.on('click', function () {
                    $dialogContent.dialog('close');

                    let elementid = $('.mba-profile-container').attr('id');
                    _fnPrepopulateFields(
                        elementid
                        , rec.recData1  // lastName
                        , rec.recData2  // firstName
                        , rec.recData3  // middleName
                        , rec.recData4  // preferredNickname
                        , rec.recData5  // dobStrYMD
                        , rec.recData6  // gender
                        , rec.recData7   // CSIS
                    );
                });
            }

            $recContainer.append($actionButton);
            $dialogContent.append($recContainer);
        });

        let dialogOpts = {
            modal: true
            , width: 600
            , maxHeight: 600
            , title: 'Students Found with SSID'
            , buttons: [{
                text: "Close",
                click: function () { $(this).dialog("close"); }
            }],
            close: function () { $(this).dialog("destroy"); }
        };

        $dialogContent.dialog(dialogOpts);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnDoFindStudentsBySSID
     * @private
     * @summary      Takes value from SSID field and contacts server for matches
     * @param  {Object}  $me      Element reference
     */

    let _fnDoFindStudentsBySSID = function ($me) {
        let dataObj = _fnGetDataObj($me);
        let ssid = $(dataObj.ssidSearchInput).val();
        if (!ssid) return;

        let requestObj = {};
        requestObj['clientid'] = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        requestObj['ssid'] = ssid;
        let requestJSON = JSON.stringify(requestObj);

        $(dataObj.ssidSearchInput).closest('.' + _CLASS_NAME_SSID_SEARCH_CONTAINER).addClass('scanning');

        let originalButtonHtml = $(dataObj.ssidSearchButton).html();
        $(dataObj.ssidSearchButton).html('<i class="fas fa-spinner fa-spin"></i> SCANNING...');

        $(dataObj.waitNotice).removeClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
        $(dataObj.saveButton).addClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
        $(dataObj.ssidSearchButton).addClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlFindStudentsWithSSID, requestJSON, dataObj.opts.sessionTimeOutUrl)
            .then(responseData => {
                $(dataObj.ssidSearchInput).closest('.' + _CLASS_NAME_SSID_SEARCH_CONTAINER).removeClass('scanning');
                $(dataObj.ssidSearchButton).html(originalButtonHtml);

                $(dataObj.waitNotice).addClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
                $(dataObj.saveButton).removeClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
                $(dataObj.ssidSearchButton).removeClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
                _fnDoOpenDiaWithFindStudentsBySSIDResults(responseData);
            })
            .catch(err => {
                $(dataObj.ssidSearchInput).closest('.' + _CLASS_NAME_SSID_SEARCH_CONTAINER).removeClass('scanning');
                $(dataObj.ssidSearchButton).html(originalButtonHtml);

                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
                $(dataObj.waitNotice).addClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
                $(dataObj.saveButton).removeClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
                $(dataObj.ssidSearchButton).removeClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN);
            });
    };
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /*###########################################################################################
     *#
     *#                           Profile Picture Methods
     *#
     *##########################################################################################*/

    /**
     * @function     _fnInitializeProfilePictureUploader
     * @private
     * @summary      Initializes the profile picture upload functionality
     * @param  {Object}  $me      Element reference
     * @param  {Object}  dataObj  Data object
     */
    let _fnInitializeProfilePictureUploader = function ($me, dataObj) {
        if (!dataObj.opts.enableProfilePictureUpload) return;
        if (!MBA.ImageUploaderCommon) {
            
            return;
        }

        let $imageContainer = $(dataObj.profileHeaderPersonImageContainer);

        /* Create hidden file inputs */
        let $fileInput = $('<input type="file" accept="image/jpeg,image/jpg,image/png,image/webp" style="display: none;" class="mba-profile-picture-file-input">');
        let $cameraInput = $('<input type="file" accept="image/jpeg,image/jpg,image/png,image/webp" capture="user" style="display: none;" class="mba-profile-picture-camera-input">');

        $imageContainer.append($fileInput);
        $imageContainer.append($cameraInput);

        /* Prevent clicks on file inputs from bubbling up to container */
        $fileInput.on('click', function (e) {
            e.stopPropagation();
        });

        $cameraInput.on('click', function (e) {
            e.stopPropagation();
        });


        /* Make container clickable */
        $imageContainer.css('cursor', 'pointer');

        /* Function to show the selection popup */
        let showSelectionPopup = function () {
            /* Remove any existing uploader */
            $('.mba-profile-picture-popup-overlay').remove();

            /* Create popup overlay */
            let $popupOverlay = $('<div class="mba-profile-picture-popup-overlay"></div>');
            $popupOverlay.css({
                'position': 'fixed'
                , 'top': '0'
                , 'left': '0'
                , 'width': '100%'
                , 'height': '100%'
                , 'background': 'rgba(0, 0, 0, 0.6)'
                , 'display': 'flex'
                , 'align-items': 'center'
                , 'justify-content': 'center'
                , 'z-index': '9999'
                , 'animation': 'fadeIn 0.2s ease'
            });

            /* Create popup content */
            let $popup = $(`
                <div class="mba-profile-picture-popup">
                    <div class="mba-profile-picture-popup-header">
                        <h3>Update Profile Picture</h3>
                        <button type="button" class="mba-profile-picture-popup-close">
                            <i class="fa fa-times"></i>
                        </button>
                    </div>
                    <div class="mba-profile-picture-popup-body">
                        <button type="button" class="mba-profile-picture-popup-option mba-profile-picture-camera">
                            <div class="mba-profile-picture-popup-icon">
                                <i class="fa fa-camera fa-2x"></i>
                            </div>
                            <div class="mba-profile-picture-popup-label">Take Photo</div>
                            <div class="mba-profile-picture-popup-desc">Use your device camera</div>
                        </button>
                        <button type="button" class="mba-profile-picture-popup-option mba-profile-picture-file">
                            <div class="mba-profile-picture-popup-icon">
                                <i class="fa fa-upload fa-2x"></i>
                            </div>
                            <div class="mba-profile-picture-popup-label">Upload Photo</div>
                            <div class="mba-profile-picture-popup-desc">Choose from your device</div>
                        </button>
                    </div>
                </div>
            `);

            /* Style the popup */
            $('.mba-profile-picture-popup', $popup).css({
                'background': 'white'
                , 'border-radius': '16px'
                , 'width': '90%'
                , 'max-width': '400px'
                , 'box-shadow': '0 20px 60px rgba(0, 0, 0, 0.3)'
                , 'overflow': 'hidden'
                , 'animation': 'slideUp 0.3s ease'
            });

            /* Style popup header */
            $('.mba-profile-picture-popup-header', $popup).css({
                'display': 'flex'
                , 'justify-content': 'space-between'
                , 'align-items': 'center'
                , 'padding': '20px 24px'
                , 'border-bottom': '1px solid #e5e7eb'
                , 'background': 'linear-gradient(135deg, #f9fafb 0%, #f3f4f6 100%)'
            });

            $('.mba-profile-picture-popup-header h3', $popup).css({
                'margin': '0'
                , 'font-size': '18px'
                , 'font-weight': '600'
                , 'color': '#1f2937'
            });

            $('.mba-profile-picture-popup-close', $popup).css({
                'background': 'transparent'
                , 'border': 'none'
                , 'color': '#6b7280'
                , 'cursor': 'pointer'
                , 'padding': '4px'
                , 'font-size': '20px'
                , 'transition': 'color 0.2s ease'
            });

            /* Style popup body */
            $('.mba-profile-picture-popup-body', $popup).css({
                'display': 'flex'
                , 'gap': '16px'
                , 'padding': '24px'
                , 'justify-content': 'center'
            });

            /* Style option buttons */
            $('.mba-profile-picture-popup-option', $popup).css({
                'background': 'white'
                , 'border': '2px solid #e5e7eb'
                , 'border-radius': '12px'
                , 'padding': '24px 20px'
                , 'cursor': 'pointer'
                , 'transition': 'all 0.3s ease'
                , 'flex': '1'
                , 'max-width': '160px'
                , 'text-align': 'center'
            });

            /* Style icons */
            $('.mba-profile-picture-popup-icon', $popup).css({
                'margin-bottom': '12px'
                , 'color': '#6b7280'
                , 'transition': 'all 0.3s ease'
            });

            $('.mba-profile-picture-camera .mba-profile-picture-popup-icon', $popup).css({
                'color': '#10b981'
            });

            $('.mba-profile-picture-file .mba-profile-picture-popup-icon', $popup).css({
                'color': '#3b82f6'
            });

            /* Style labels */
            $('.mba-profile-picture-popup-label', $popup).css({
                'font-size': '16px'
                , 'font-weight': '600'
                , 'color': '#1f2937'
                , 'margin-bottom': '4px'
            });

            $('.mba-profile-picture-popup-desc', $popup).css({
                'font-size': '12px'
                , 'color': '#9ca3af'
            });

            /* Add hover effects */
            $('.mba-profile-picture-popup-option', $popup).hover(
                function () {
                    $(this).css({
                        'border-color': '#3b82f6'
                        , 'transform': 'translateY(-2px)'
                        , 'box-shadow': '0 4px 12px rgba(0, 0, 0, 0.1)'
                    });
                },
                function () {
                    $(this).css({
                        'border-color': '#e5e7eb'
                        , 'transform': 'translateY(0)'
                        , 'box-shadow': 'none'
                    });
                }
            );

            /* Append popup to overlay */
            $popupOverlay.append($popup);
            $('body').append($popupOverlay);

            /* Function to close popup */
            let closePopup = function () {
                $popupOverlay.fadeOut(200, function () {
                    $(this).remove();
                });
            };

            /* Handle close button */
            $('.mba-profile-picture-popup-close', $popupOverlay).on('click', closePopup);

            /* Handle clicking outside popup */
            $popupOverlay.on('click', function (e) {
                if ($(e.target).hasClass('mba-profile-picture-popup-overlay')) {
                    closePopup();
                }
            });

            /* TODO: Remove this line once camera function is working */
/*            $('.mba-profile-picture-camera').hide();
*/
            /* Handle camera option */
            $('.mba-profile-picture-camera', $popupOverlay).on('click', function (e) {
                e.stopPropagation();

                /* Check if device has camera capability */
                if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                    
                    $popupOverlay.fadeOut(200).promise().then(function () {
                        $popupOverlay.remove();
                        return Promise.resolve();
                    }).then(function () {
                        
                        _fnCreateCameraInterface($me, dataObj);
                    });
                } else {
                    /* Device doesn't support camera, use file upload */
                    $popupOverlay.fadeOut(200).promise().then(function () {
                        $popupOverlay.remove();
                        MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                            'Camera Not Supported'
                            , 'This device does not support camera access. Please use upload option.'
                            , { modal: true }
                        );
                        $fileInput.trigger('click');
                    });
                }
            });

            /* Handle upload option */
            $('.mba-profile-picture-file', $popupOverlay).on('click', function (e) {
                e.stopPropagation();
                $popupOverlay.fadeOut(200).promise().then(function () {
                    $popupOverlay.remove();
                    return Promise.resolve();
                }).then(function () {
                    $fileInput.trigger('click');
                });
            });
        };

        /* Handle container click - show popup */
        $imageContainer.on('click', function (e) {
            e.stopPropagation();
            showSelectionPopup();
        });

        /* Handle file selection from either input */
        let handleFileSelection = function (e) {
            let files = e.target.files;
            if (files && files.length > 0) {
                let file = files[0];

                /* Validate file type - no GIF allowed */
                let validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
                if (!validTypes.includes(file.type)) {
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                        'Invalid File Type'
                        , 'Please select a valid image file (JPEG, PNG, or WebP only).'
                        , { modal: true }
                    );
                    /* Reset file inputs */
                    $fileInput.val('');
                    $cameraInput.val('');
                    return;
                }

                /* Initialize cropper with selected file */
                if (MBA.ImageUploaderCommon && MBA.ImageUploaderCommon.fnCreateImageCropper) {
                    /* Determine output format based on input to prevent bloat */
                    let outputFormat = 'image/jpeg';
                    let outputQuality = 0.85;

                    if (file.type === 'image/png') {
                        outputFormat = 'image/png';
                        outputQuality = 1.0;
                    }

                    Promise.resolve().then(function () {
                        return MBA.ImageUploaderCommon.fnCreateImageCropper(file, {
                            cropperSettings: {
                                cropSize: 500
                                , showGrid: true
                                , outputFormat: outputFormat
                                , outputQuality: outputQuality
                            }
                            , cssClasses: MBA.ImageUploaderCommon._CSS_CLASSES || {
                                cropperModal: 'mba-image-uploader-cropper-modal'
                                , cropperContainer: 'mba-image-uploader-cropper-container'
                                , cropperCanvas: 'mba-image-uploader-cropper-canvas'
                                , cropperPreview: 'mba-image-uploader-cropper-preview'
                                , cropperGrid: 'mba-image-uploader-cropper-grid'
                                , cropperCircle: 'mba-image-uploader-cropper-circle'
                                , cropperControls: 'mba-image-uploader-cropper-controls'
                                , cropperBtn: 'mba-image-uploader-cropper-btn'
                            }
                            , messages: {
                                cropImage: 'Adjust Profile Picture'
                            }
                            , fnOnCropCancel: function () {
                                /* Reset file inputs */
                                $fileInput.val('');
                                $cameraInput.val('');
                            }
                        });
                    })
                        .then(function (croppedBlob) {
                            _fnUploadProfilePicture($me, dataObj, croppedBlob);
                            /* Reset file inputs */
                            $fileInput.val('');
                            $cameraInput.val('');
                        })
                        .catch(function (err) {
                            /* Reset file inputs */
                            $fileInput.val('');
                            $cameraInput.val('');
                        });
                } else {
                    /* Fallback if cropper not available */
                    _fnProcessFileWithoutCropper(file, $me, dataObj);
                }
            }
        };

        $fileInput.on('change', handleFileSelection);
        $cameraInput.on('change', handleFileSelection);
    };
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    /**
 * @function     _fnCreateCameraInterface
 * @private
 * @summary      Creates camera interface for taking photos
 * @param  {Object}  $me      Element reference
 * @param  {Object}  dataObj  Data object
 */
    let _fnCreateCameraInterface = function ($me, dataObj) {
        let currentStream = null;

        /* Create camera modal */
        let $cameraModal = $('<div class="mba-camera-modal"></div>');
        $cameraModal.css({
            'display': 'none'
            , 'position': 'fixed'
            , 'top': '0'
            , 'left': '0'
            , 'width': '100%'
            , 'height': '100%'
            , 'background': 'rgba(0,0,0,0.9)'
            , 'z-index': '10000'
        });

        let cameraHtml = `
        <div class="mba-camera-container" style="position: relative; width: 100%; height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center;">
            <video id="mba-camera-video" autoplay playsinline style="width: 100%; max-width: 600px; height: auto; border-radius: 8px;"></video>
            <canvas id="mba-camera-canvas" style="display: none;"></canvas>
            <div class="mba-camera-controls" style="position: absolute; bottom: 30px; display: flex; gap: 20px;">
                <button type="button" class="mba-camera-btn-cancel" style="width: 60px; height: 60px; border-radius: 50%; border: none; cursor: pointer; background: rgba(255,255,255,0.2); color: white;">
                    <i class="fas fa-times fa-2x"></i>
                </button>
                <button type="button" class="mba-camera-btn-capture" style="width: 60px; height: 60px; border-radius: 50%; border: 4px solid #fff; cursor: pointer; background: white; box-shadow: 0 4px 12px rgba(0,0,0,0.3);">
                    <i class="fas fa-camera"></i>
                </button>
            </div>
        </div>
        `;

        $cameraModal.html(cameraHtml);
        $('body').append($cameraModal);

        /* Request camera permission */
        const constraints = {
            video: {
                facingMode: 'user'
                , width: { ideal: 1280 }
                , height: { ideal: 720 }
            }
            , audio: false
        };
        const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
        if (isIOS) {
            constraints.video = true;
        }
        navigator.mediaDevices.getUserMedia(constraints)
            .then(function (stream) {
                currentStream = stream;

                /* Show camera modal */
                $cameraModal.fadeIn(200);

                /* Attach stream to video */
                const video = document.getElementById('mba-camera-video');
                video.srcObject = stream;
            })
            .catch(function (error) {
                $cameraModal.remove();

                if (error.name === 'NotAllowedError') {
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                        'Camera Permission Denied'
                        , 'Please allow camera access and try again.'
                        , { modal: true }
                    );
                } else if (error.name === 'NotFoundError') {
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                        'No Camera Found'
                        , 'No camera found on this device.'
                        , { modal: true }
                    );
                } else {
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                        'Camera Error'
                        , 'Unable to access camera: ' + error.message
                        , { modal: true }
                    );
                }
            });

        /* Capture photo handler */
        $('.mba-camera-btn-capture', $cameraModal).on('click', function () {
            const video = document.getElementById('mba-camera-video');
            const canvas = document.getElementById('mba-camera-canvas');
            const context = canvas.getContext('2d');

            /* Set canvas size to video size */
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;

            /* Draw video frame to canvas */
            context.drawImage(video, 0, 0);

            /* Convert to blob */
            canvas.toBlob(function (blob) {
                /* Create file from blob */
                const file = new File([blob], 'camera_photo.jpg', { type: 'image/jpeg' });

                /* Stop camera stream */
                if (currentStream) {
                    currentStream.getTracks().forEach(track => track.stop());
                }

                /* Remove camera modal */
                $cameraModal.fadeOut(200, function () {
                    $(this).remove();
                });

                /* Process with cropper if available, otherwise direct upload */
                if (MBA.ImageUploaderCommon && MBA.ImageUploaderCommon.fnCreateImageCropper) {
                    Promise.resolve().then(function () {
                        return MBA.ImageUploaderCommon.fnCreateImageCropper(file, {
                            cropperSettings: {
                                cropSize: 500
                                , showGrid: true
                                , outputFormat: 'image/jpeg'
                                , outputQuality: 0.85
                            }
                            , cssClasses: MBA.ImageUploaderCommon._CSS_CLASSES || {
                                cropperModal: 'mba-image-uploader-cropper-modal'
                                , cropperContainer: 'mba-image-uploader-cropper-container'
                                , cropperCanvas: 'mba-image-uploader-cropper-canvas'
                                , cropperPreview: 'mba-image-uploader-cropper-preview'
                                , cropperGrid: 'mba-image-uploader-cropper-grid'
                                , cropperCircle: 'mba-image-uploader-cropper-circle'
                                , cropperControls: 'mba-image-uploader-cropper-controls'
                                , cropperBtn: 'mba-image-uploader-cropper-btn'
                            }
                            , messages: {
                                cropImage: 'Adjust Profile Picture'
                            }
                            , fnOnCropCancel: function () {
                                /* Do nothing on cancel */
                            }
                        });
                    })
                        .then(function (croppedBlob) {
                            _fnUploadProfilePicture($me, dataObj, croppedBlob);
                        })
                        .catch(function (err) {
                            /* User cancelled cropping */
                        });
                } else {
                    /* Fallback if cropper not available */
                    _fnProcessFileWithoutCropper(file, $me, dataObj);
                }

            }, 'image/jpeg', 0.9);
        });

        /* Cancel button handler */
        $('.mba-camera-btn-cancel', $cameraModal).on('click', function () {
            if (currentStream) {
                currentStream.getTracks().forEach(track => track.stop());
            }
            $cameraModal.fadeOut(200, function () {
                $(this).remove();
            });
        });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnProcessFileWithoutCropper
     * @private
     * @summary      Fallback to process file without cropper
     * @param  {File}    file     The selected file
     * @param  {Object}  $me      Element reference
     * @param  {Object}  dataObj  Data object
     */
    let _fnProcessFileWithoutCropper = function(file, $me, dataObj) {
        /* Convert file to blob and upload directly */
        let reader = new FileReader();
        reader.onloadend = function() {
            fetch(reader.result)
                .then(res => res.blob())
                .then(blob => {
                    _fnUploadProfilePicture($me, dataObj, blob);
                });
        };
        reader.readAsDataURL(file);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnUploadProfilePicture
     * @private
     * @summary      Uploads the profile picture to server
     * @param  {Object}  $me      Element reference
     * @param  {Object}  dataObj  Data object
     * @param  {Blob}    imageBlob The cropped image blob
     */
    let _fnUploadProfilePicture = function ($me, dataObj, imageBlob) {
        /* Convert blob to base64 */
        const reader = new FileReader();
        reader.onloadend = function () {
            let base64String = reader.result.split(',')[1]; /* Remove data:image/png;base64, prefix */
            let fileExtension = '.jpg';
            if (imageBlob.type === 'image/png') {
                fileExtension = '.png';
            } else if (imageBlob.type === 'image/webp') {
                fileExtension = '.webp';
            }

            let requestObj = {};
            requestObj['clientid'] = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
            requestObj['patid'] = dataObj.opts.VALUE_PAT_ID;
            requestObj['filename'] = 'profile_' + Date.now() + fileExtension;
            requestObj['profilepicturebase64'] = base64String;
            requestObj['savetype'] = dataObj.opts.VALUE_SAVE_TYPE;
            requestObj['recid'] = '';

            let requestJSON = JSON.stringify(requestObj);

            /* Show loading indicator on container since element might be replaced */
            $(dataObj.profileHeaderPersonImageContainer).css('opacity', '0.5');
            $(dataObj.profileHeaderPersonImageContainer).addClass('loading');

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(
                dataObj.opts.baseUrlSaveProfilePicture,
                requestJSON,
                dataObj.opts.sessionTimeOutUrl
            )
                .then(responseData => {
                    /* Replace icon/existing image with new image */
                    $(dataObj.profileHeaderPersonImageContainer).find('.' + _CLASS_NAME_PROFILE_HEADER_PERSON_IMG).remove();

                    let $img = $('<img>');
                    $img.attr('src', 'data:image/png;base64,' + base64String);
                    $img.addClass(_CLASS_NAME_PROFILE_HEADER_PERSON_IMG);

                    /* Replace whatever is currently there (icon or old image) */
                    $(dataObj.profileHeaderPersonImageContainer).prepend($img);
                    dataObj.profileHeaderPersonImage = $img;

                    /* Remove loading states */
                    $(dataObj.profileHeaderPersonImageContainer).css('opacity', '1');
                    $(dataObj.profileHeaderPersonImageContainer).removeClass('loading');
                    //$(dataObj.profileHeaderPersonImageContainer).addClass('success');

                    /*setTimeout(function () {
                        $(dataObj.profileHeaderPersonImageContainer).removeClass('success');
                    }, 500);*/

                })
                .catch(err => {
                    $(dataObj.profileHeaderPersonImageContainer).css('opacity', '1');
                    $(dataObj.profileHeaderPersonImageContainer).removeClass('loading');
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                        'Error',
                        'Failed to update profile picture: ' + err.message,
                        { modal: true }
                    );
                });
        };

        reader.readAsDataURL(imageBlob);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnLoadProfilePicture
     * @private
     * @summary      Loads the existing profile picture
     * @param  {Object}  $me      Element reference
     * @param  {Object}  dataObj  Data object
     */
    let _fnLoadProfilePicture = function ($me, dataObj) {
        if (!dataObj.opts.VALUE_PAT_ID || dataObj.opts.VALUE_SAVE_TYPE === _SAVE_TYPE_NEW) {
            /* Set default icon for new patients */
            $(dataObj.profileHeaderPersonImageContainer).find('.' + _CLASS_NAME_PROFILE_HEADER_PERSON_IMG).remove();
            let $icon = $('<i class="fas fa-user"></i>');
            $icon.addClass(_CLASS_NAME_PROFILE_HEADER_PERSON_IMG);
            $(dataObj.profileHeaderPersonImageContainer).prepend($icon);
            dataObj.profileHeaderPersonImage = $icon;
            return;
        }

        let requestObj = {};
        requestObj['clientid'] = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
        requestObj['patid'] = dataObj.opts.VALUE_PAT_ID;
        requestObj['recid'] = '';

        let requestJSON = JSON.stringify(requestObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(
            dataObj.opts.baseUrlGetProfilePicture,
            requestJSON,
            dataObj.opts.sessionTimeOutUrl
        )
            .then(responseData => {
                if (responseData.rawData && responseData.rawData.dataobj && responseData.rawData.dataobj.profilePictureBase64) {
                   
                    /* Replace with actual image */
                    $(dataObj.profileHeaderPersonImageContainer).find('.' + _CLASS_NAME_PROFILE_HEADER_PERSON_IMG).remove();

                    let $img = $('<img>');
                    $img.attr('src', 'data:image/png;base64,' + responseData.rawData.dataobj.profilePictureBase64);
                    $img.addClass(_CLASS_NAME_PROFILE_HEADER_PERSON_IMG);
                    $(dataObj.profileHeaderPersonImageContainer).prepend($img);
                    dataObj.profileHeaderPersonImage = $img;
                } else {
                    $(dataObj.profileHeaderPersonImageContainer).find('.' + _CLASS_NAME_PROFILE_HEADER_PERSON_IMG).remove();

                    /* Use default icon */
                    let $icon = $('<i class="fas fa-user"></i>');
                    $icon.addClass(_CLASS_NAME_PROFILE_HEADER_PERSON_IMG);
                    $(dataObj.profileHeaderPersonImageContainer).prepend($icon);
                    dataObj.profileHeaderPersonImage = $icon;
                }
            })
            .catch(err => {
                $(dataObj.profileHeaderPersonImageContainer).find('.' + _CLASS_NAME_PROFILE_HEADER_PERSON_IMG).remove();

                let $icon = $('<i class="fas fa-user"></i>');
                $icon.addClass(_CLASS_NAME_PROFILE_HEADER_PERSON_IMG);
                $(dataObj.profileHeaderPersonImageContainer).prepend($icon);
                dataObj.profileHeaderPersonImage = $icon;
            });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /*###########################################################################################
     *#
     *#                                     Related File Management
     *#
     *##########################################################################################*/

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnRelatedFileUpload
     * @private
     * @summary      Opens dialog to upload related files
     * @param  {Object}  $me          Element reference
     * @param  {Object}  dataObj      Data object
     * @param  {String}  dialogTitle  Title of dialog
     * @param  {Number}  fileClassVal Value of file class
     */

    let _fnRelatedFileUpload = function ($me, dialogTitle, fileClassVal) {

       if (MBA.StoredFilesPrivateEndPointsAndParmNames.userHasAccessToFilesUploadDownload === false) return;

       let dataObj = _fnGetDataObj($me);
       let $relatedRestViewStoredFilesRef = dataObj.opts.relatedRestViewStoredFilesRef;
       let fnOnStoredFileUploadClose = function () { };
       if ($relatedRestViewStoredFilesRef) {
           fnOnStoredFileUploadClose = function () {
               MBA.StoredFilesCommon.fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer(dataObj.opts.relatedRestViewStoredFilesRef);
           };
       }

       let _fileAdditionalDataObj = {};
       _fileAdditionalDataObj[MBA.StoredFilesPrivateEndPointsAndParmNames.parmNameClientID] = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();
       _fileAdditionalDataObj[MBA.StoredFilesPrivateEndPointsAndParmNames.parmNamePatID] = dataObj.opts.VALUE_PAT_ID;

       let _fileAdditionalDataJSONStr = JSON.stringify(_fileAdditionalDataObj);

       $.spedmonWebUI.fileUpload (
             dialogTitle
            , MBA.StoredFilesPrivateEndPointsAndParmNames.uploadHandlerPrivateUrl
            , fileClassVal /* file class value */
            , '' /*fileSubClass*/
            , 'patientprofile' /* namespace*/
            , '' /*fileSource*/
            , _fileAdditionalDataJSONStr
            , true /*showSuccessMsg*/
            , fnOnStoredFileUploadClose /*fnCloseSuccess*/
            , false /*showIsConfidentialPracticeFileOption*/
        );
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /*###########################################################################################
     *#
     *#                                Field Creation Methods
     *#
     *##########################################################################################*/
    
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnCreateFieldSetMap = function (meID, fieldDefinitions) {

        let fs = new Map();

        let _fnProcessMapEntry = function (fieldDef, key, map) {

            if (fs.has(fieldDef.fieldSet) === false) {

                let _fsNameWithoutSpaces = fieldDef.fieldSet.split(' ').join('-');
                let _fsID = meID + '-' + _fsNameWithoutSpaces

                let fieldSetDef = {};
               
                fieldSetDef.id = _fsID;
                fieldSetDef.label = fieldDef.fieldSet;
                fieldSetDef.numChildren = 1;
                fieldSetDef.numChildrenPcalOnly = 0;                

                if (fieldDef.pcalOnly === true) {
                    fieldSetDef.numChildrenPcalOnly = 1;
                }

                /* Add initial field set line */
                fieldSetDef.fieldSetLines = new Map();
                let _fsLineID = fieldSetDef.id + '-line-' + fieldDef.fieldSetLine;
                fieldSetDef.fieldSetLines.set(fieldDef.fieldSetLine, _fsLineID);


                fs.set(fieldDef.fieldSet, fieldSetDef);
            }
            else {
                let fieldSetDef = fs.get(fieldDef.fieldSet);
                fieldSetDef.numChildren = fieldSetDef.numChildren + 1;
                if (fieldDef.pcalOnly === true) {
                    fieldSetDef.numChildrenPcalOnly = fieldSetDef.numChildrenPcalOnly + 1;                    
                }

                /* Add field set line */

                if (!fieldSetDef.fieldSetLines.has(fieldDef.fieldSetLine)) {
                    let _fsLineID = fieldSetDef.id + '-line-' + fieldDef.fieldSetLine;
                    fieldSetDef.fieldSetLines.set(fieldDef.fieldSetLine, _fsLineID);
                }

                fs.set(fieldDef.fieldSet, fieldSetDef);
            }
        };

        fieldDefinitions.forEach(_fnProcessMapEntry);
        
        return fs;
    };
    
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnCreateFieldDefinitionsMap = function (meID, opts) {

      let fd = new Map();

      /* Keep _fnAdd local */
      let _fnAdd = function (
              meID
            , required
            , pcalOnly
            , fieldName
            , saveAsName
            , fieldType
            , defaultValue
            , label
            , placeholder
            , tooltip
            , fieldSet
            , fieldSetLine
            , manageFiles
            , manageFilesOptions
            , fieldOptions) {

            let def = {};

            def.required     = required;      /* The value of the field control required attribute */
            def.pcalOnly     = pcalOnly;      /* Should this control only be seen by practi-cal staff */
            def.fieldName    = fieldName;     /* The name of the field in the Patients C# Class */
            def.saveAsName   = saveAsName;    /* The parameter name for the patients.asmx save method */
            def.fieldType    = fieldType;     /* what type of field control text, date, textarea, yesno, yesnounknown, malefemale, autocomplete */
            def.defaultValue = defaultValue;
            def.label        = label;         /* the content of the <label> tag that is a sibling of the field control */
            def.placeholder  = placeholder;   /* the value of the field controls placeholder attribute (if any) */
            def.tooltip      = tooltip;       /* the value of the title attribute for the container element for the label + field control*/
            def.fieldSet     = fieldSet;      /* the field set to put this control in */
            def.fieldSetLine = fieldSetLine;

            def.manageFiles        = manageFiles;   /* Render manage files button inline with control */
            def.manageFilesOptions = manageFilesOptions;          
            def.fieldOptions       = fieldOptions;  /* specific options for a field type */

            def.supportsPlaceholder = true;
            def.supportsDefault     = true;            
            def.hasSupportingField  = false;
            def.supportingFieldName = null;
            def.ctrlID              = meID + '-' + saveAsName; /* Generates a unique id for the field control.  Used with label. */            
            def.supportingCtrlID    = null;
                        
            if (   (def.fieldType == 'yesno')
                || (def.fieldType == 'yesnounknown')
                || (def.fieldType == 'malefemale')                
                || (def.fieldType == 'readonly')
            )
            {
                def.supportsPlaceholder = false;
                def.supportsDefault     = false;
            }

            if ((def.fieldType == 'readonly')
            )
            {
                def.supportsDefault = false;
            }
            
            if (def.fieldType === 'autocomplete') {
              def.hasSupportingField  = true;
              def.supportingFieldName = fieldOptions.selectNameFromFieldName;
              def.supportingCtrlID    = meID + '-' + def.supportingFieldName;
            }

            fd.set(fieldName, def);
      };
       
        _fnAdd(meID, true, false, 'lastName', 'lname', 'text', '', 'Last', 'Enter Last', 'Last Name', 'Student', 1, false, {},{});
        _fnAdd(meID, true, false, 'firstName', 'fname', 'text', '', 'First', 'Enter First', 'First Name', 'Student', 1, false, {}, {});
        _fnAdd(meID, false, false, 'middleName', 'mname', 'text', '', 'Middle', 'Enter Middle', 'Middle Name', 'Student', 2, false, {}, {});
        _fnAdd(meID, false, false, 'preferredNickname', 'p_nickname', 'text', '', 'Preferred', 'Enter Preferred', 'Preferred or Nick Name', 'Student', 2, false, {}, {});
        _fnAdd(meID, true, false, 'dobStrYMD', 'dob', 'date', '', 'DOB', '', '', 'Student', 3, false, {}, {});
        _fnAdd(meID, true, false, 'gender', 'sex', 'malefemale', '', 'Gender', '', '', 'Student', 3, false, {}, {});

        _fnAdd(meID, false, false, 'email', 'email', 'email', '', 'Email', 'Enter email', 'Primary email address', 'Student', 4, false, {}, {});
        _fnAdd(meID, false, false, 'phone', 'phone', 'tel', '', 'Phone', 'Enter phone #', 'Primary phone number', 'Student', 4, false, {}, {});

        _fnAdd(meID, false, false, 'CSIS', 'csis', 'text', '', 'SSID', 'Enter SSID', 'Statewide Student Identifier', 'Student', 5, false, {}, {});

        _fnAdd(meID, false, false, 'siteRefID', 'studentid', 'text', '', 'Student ID', 'Enter ID', 'Districts Student ID', 'Student', 5, false, {}, {});
        _fnAdd(meID, false, false, 'siteRank', 'grade', 'text', '', 'Grade', '', '', 'Student', 6, false, {}, {});
        _fnAdd(meID, true, false, 'siteID', 'siteid', 'autocomplete', '', 'School Site', '', '', 'Student', 6, false, {}, { selectNameFromFieldName: 'siteName', viewSelBaseURL: opts.baseUrlSiteIDSel });
        _fnAdd(meID, false, false, 'teacherOrCounselorName', 'teacherorcounselorname', 'text', '', 'Teacher or Counselor', 'Enter name', '', 'Student', 7, false, {}, {});
        _fnAdd(meID, false, false, 'preferredContactMethodCode', 'preferredContactMethodCode', 'autocomplete', '', 'Preferred Contact Method', '', '', 'Student', 7, false, {}, { selectNameFromFieldName: 'preferredContactMethodName', viewSelBaseURL: opts.baseUrlPreferredContactMethodIDSel});

        _fnAdd(meID, false, false, 'medicalParentConsentYN', 'parentConsentMCAL', 'yesnounknown', '', 'Medi-Cal Billing', '', '', 'Consent', 1, false, {}, {});
        _fnAdd(meID, false, false, 'parentConsentMCALEffectiveDateYMD', 'parentConsentMCALEffectiveDate', 'date', '', 'Medi-Cal Billing Effective', '', '', 'Consent', 1, true, { dialogTitle: 'Medi-Cal Billing Consent', fileClassVal: 900 }, {});
        
        _fnAdd(meID, false, false, 'ferpaConsentYNU', 'ferpaconsent', 'yesnounknown', '', 'FERPA', '', '', 'Consent', 2, false, {}, {});
        _fnAdd(meID, false, false, 'ferpaConsentEffectiveDateYMD', 'ferpaconsenteffectivedate', 'date', '', 'FERPA Effective', '', '', 'Consent', 2, true, { dialogTitle: 'FERPA and Billing Consent', fileClassVal: 910 }, {});
        
        _fnAdd(meID, false, false, 'treatmentConsentYNU', 'treatmentconsent', 'yesnounknown', '', 'Treatment', '', '', 'Consent', 3, false, {}, {});
        _fnAdd(meID, false, false, 'treatmentConsentEffectiveDateYMD', 'treatmentconsenteffectivedate', 'date', '', 'Treatment Effective', '', '', 'Consent', 3, true, { dialogTitle: 'Treatment Consent', fileClassVal: 920 }, {});
        
		_fnAdd(meID, false, false, 'minorConsentYN', 'minorconsent', 'yesno', '', 'CA Minor Consent', '', '', 'Consent', 4, false, {}, {});
        _fnAdd(meID, false, false, 'minorConsentEffectiveDateYMD', 'minorconsenteffectivedate', 'date', '', 'Minor Consent Effective', '', '', 'Consent', 4, false, {}, {});
        _fnAdd(meID, false, true, 'submitClaimsYN', 'submitclaims', 'yesno', '', 'Submit Claims', '', '', 'LEA BOP', 1, false, {}, {});
        _fnAdd(meID, false, true, 'submitClaimsEffectiveDateYMD', 'submitClaimsEffectiveDate', 'date', '', 'Submit Claims Effective', '', '', 'LEA BOP', 1, false, {}, {});
        _fnAdd(meID, false, true, 'bic', 'bic', 'text', '', 'BIC', '', '', 'LEA BOP', 2, false, {}, {});
   
        _fnAdd(meID, false, false, 'cybhiTpaApprovedYN', 'cybhitpaapproved', 'yesno', '', 'TPA Approved', '', '', 'CYBHI', 1, false, {}, {});
        _fnAdd(meID, false, false, 'cybhiTpaApprovedOnYMD', 'cybhitpaapprovedon', 'date', '', 'TPA Approved On', '', '', 'CYBHI', 1, false, {}, {});
        _fnAdd(meID, false, false, 'cybhiTpaID', 'cybhitpaid', 'text', '', 'TPA ID', '', '', 'CYBHI', 2, false, {}, {});
        _fnAdd(meID, false, false, 'cybhiSubmitClaimsYN', 'cybhisubmitclaims', 'yesno', '', 'Submit Claims', '', '', 'CYBHI', 2, false, {}, {});

        _fnAdd(meID, false, false, 'street1', 'street1', 'text', '', 'Street Address Line 1', '', '', 'Primary Home Address', 1, false, {}, {});
        _fnAdd(meID, false, false, 'street2', 'street2', 'text', '', 'Street Address Line 2', '', '', 'Primary Home Address', 1, false, {}, {});
        _fnAdd(meID, false, false, 'city', 'city', 'text', '', 'City', '', '', 'Primary Home Address', 2, false, {}, {});
        _fnAdd(meID, false, false, 'state', 'state', 'text', '', 'State', '', '', 'Primary Home Address', 2, false, {}, {});
        _fnAdd(meID, false, false, 'zip5', 'zip5', 'text', '', 'Zip Code (First 5)', '', '', 'Primary Home Address', 3, false, {}, {});
        _fnAdd(meID, false, false, 'zip4', 'zip4', 'text', '', 'Zip Code (Last 4)', '', '', 'Primary Home Address', 3, false, {}, {});
        _fnAdd(meID, false, false, 'patientHomePlaceID', 'patienthomeplaceid', 'hidden', '', '', '', '', 'Primary Home Address', 4, false, {}, {});

        _fnAdd(meID, false, false, 'inTransitionalHousingStatusYN', 'intransitionalhousingstatus', 'yesnounknown', '', 'In Transitional Housing', '', '', 'Additional Info', 1, false, {}, {});
        _fnAdd(meID, false, false, 'hasIEPYN', 'hasplan', 'yesno', '', 'Has IEP', '', '', 'Additional Info', 1, false, {}, {});

     
        _fnAdd(meID, false, false, 'deceasedYN', 'deceased', 'yesno', '', 'Deceased', '', '', 'Additional Info', 2, false, {}, {});
        _fnAdd(meID, false, false, 'ssn', 'ssn', 'text', '', 'SSN', 'Enter SSN', 'Social Security Number.  Enter 9 digits no dashes.', 'Additional Info', 2, false, {}, {});
        _fnAdd(meID, false, false, 'speciallyAdaptedVehicleForTransportationYN', 'speciallyAdaptedVehicleForTransportation', 'yesno', '', 'Receives medically necessary transport via specially adapted vehicle?', '', '', 'Additional Info', 3, false, {}, {});
        _fnAdd(meID, false, true, 'notes', 'notes', 'textarea', '', 'Notes', '', '', 'Additional Info', 4, false, {}, {});

      return fd;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnCreateFieldAndLabel = function (isPcalStaff, fieldDefinition) {

        let $cont = $('<div></div>');
        $($cont).addClass(_CLASS_NAME_FORM_FIELD_CONTAINER);

        if ((isPcalStaff === false) && (fieldDefinition.pcalOnly === true)) {
            $($cont).addClass(_CLASS_NAME_FORM_FIELD_CONTAINER_HIDDEN);
        }

        let $label = $('<label>' + fieldDefinition.label + '</label>');
        $($label).addClass(_CLASS_NAME_FORM_FIELD_LABEL);
        if (fieldDefinition.required === true) $($label).attr(_DATA_ATTR_FORM_FIELD_REQUIRED, _DATA_ATTR_FORM_FIELD_REQUIRED);

        let $field        = null;
        let $supportField = null;
    
        if (fieldDefinition.fieldType == 'text') {
            $field = $('<input type="text"></input>');
        }
        else if (fieldDefinition.fieldType == 'email') {
            $field = $('<input type="email"></input>');
        }
        else if (fieldDefinition.fieldType == 'tel') {
            $field = $('<input type="tel"></input>');
        }
        else if (fieldDefinition.fieldType == 'date') {
            $field = $('<input type="date"></input>');
            $($field).attr('min', '1900-01-01');
        }
        else if (fieldDefinition.fieldType == 'textarea') {
            $field = $('<textarea></textarea>');
        }
        else if (fieldDefinition.fieldType == 'yesno') {
            $field = $('<select></select>');
            $($field).append($('<option selected disabled value="">Select One</option>'));
            $($field).append($('<option value="Yes">Yes</option>'));
            $($field).append($('<option value="No">No</option>'));

        }
        else if (fieldDefinition.fieldType == 'yesnounknown') {
            $field = $('<select></select>');
            $($field).append($('<option selected disabled value="">Select One</option>'));
            $($field).append($('<option value="Yes">Yes</option>'));
            $($field).append($('<option value="No">No</option>'));
            $($field).append($('<option value="Unknown">Unknown</option>'));
        }
        else if (fieldDefinition.fieldType == 'malefemale') {
            $field = $('<select></select>');
            $($field).append($('<option selected disabled value="">Select One</option>'));
            $($field).append($('<option value="M">Male</option>'));
            $($field).append($('<option value="F">Female</option>'));
            $($field).append($('<option value="U">Unspecified</option>'));
        }
        else if (fieldDefinition.fieldType == 'autocomplete') {
            $supportField = $('<input type="text"></input>');
            $field = $('<input type="hidden"></input>');
            $($supportField).attr(_DATA_ATTR_AUTO_COMPLETE, 'supportfield');
            $($supportField).attr(_DATA_ATTR_AUTO_COMPLETE_FOR_SAVE_AS_NAME, fieldDefinition.saveAsName);
            $($field).attr(_DATA_ATTR_AUTO_COMPLETE, 'hiddenvalue');
        }
        else if (fieldDefinition.fieldType == 'readonly') {
            $field = $('<input type="text"></input>');
            $($field).attr('readonly', 'readonly');
        }
        else if (fieldDefinition.fieldType == 'hidden') {
            $field = $('<input type="hidden"></input>');            
        }
        else {
            $field = $('<input type="text"></input>');
        }

        $($field).attr('id', fieldDefinition.ctrlID);
        $($field).attr('name', fieldDefinition.saveAsName);
        $($field).addClass(_CLASS_NAME_FORM_FIELD);

        if (fieldDefinition.hasSupportingField === true) {
            $($label).attr('for', fieldDefinition.supportingCtrlID);
            $($supportField).attr('id', fieldDefinition.supportingCtrlID);
            $($supportField).addClass(_CLASS_NAME_FORM_FIELD);
            $($supportField).attr(_DATA_ATTR_FORM_FIELD_USER_REFERENCE_NAME, fieldDefinition.saveAsName);
            if (fieldDefinition.supportsPlaceholder === true) {
                $($supportField).attr('placeholder', fieldDefinition.placeholder);
            }

            if (fieldDefinition.required === true) {
                $($supportField).attr('required', 'required');
                $($field).attr('required', 'required');
            }
        }
        else {
            $($label).attr('for', fieldDefinition.ctrlID);
            $($field).attr(_DATA_ATTR_FORM_FIELD_USER_REFERENCE_NAME, fieldDefinition.saveAsName);

            if (fieldDefinition.supportsPlaceholder === true) {
                $($field).attr('placeholder', fieldDefinition.placeholder);
            }

            if (fieldDefinition.required === true) {
                $($field).attr('required', 'required');
            }
        }                        

        $($cont).append($label);
        
        if (fieldDefinition.hasSupportingField === true) {
            $($cont).append($supportField);
        }    
       
        $($cont).append($field);


        return $cont;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnRenderFieldSets = function ($profileForm, fieldSets, opts) {

        let _fsCount = 1;

        let _fnProcessMapEntry = function (fieldSet, key, map) {
            
            let _fnProcessMapEntryFieldSetLine = function (fieldSetLineID, key, map) {
                let $fieldSetLine = $('<div></div>');
                $($fieldSetLine).attr('id', fieldSetLineID);
                $($fieldSetLine).addClass(_CLASS_NAME_FORM_FIELD_SET_CONTENT_LINE);
                $($content).append($fieldSetLine);
            };

            let $fieldSet = $('<details></details>');
            if (_fsCount === 1) $($fieldSet).attr('open', 'open');
            $($fieldSet).addClass(_CLASS_NAME_FORM_FIELD_SET);
            let $legend = $('<summary title="Click to show or hide">' + fieldSet.label + '</summary>');
            $($legend).addClass(_CLASS_NAME_FORM_FIELD_SET_LEGEND);
            $($fieldSet).append($legend);
            let $content = $('<div></div>');
            $($content).attr('id', fieldSet.id);
            $($content).addClass(_CLASS_NAME_FORM_FIELD_SET_CONTENT);

            fieldSet.fieldSetLines.forEach(_fnProcessMapEntryFieldSetLine);

            $($fieldSet).append($content);
            if (opts.isPcalStaff === false) {
                if (fieldSet.numChildren === fieldSet.numChildrenPcalOnly) {
                    $($fieldSet).hide();
                }
            }
            /* Append to profile form */

            $($profileForm).append($fieldSet);

            _fsCount = _fsCount + 1;
        };
        fieldSets.forEach(_fnProcessMapEntry);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnRenderAutoComplete = function ($fieldCont, fieldDef, opts) {
        let $acInput     = $('#' + fieldDef.supportingCtrlID);
        let $acContainer = $('<span></span>');
        $($acContainer).addClass(_CLASS_NAME_FORM_FIELD_AUTO_COMPLETE_CONT);

        let $acbutSelect = $('<button type="button"></button>');
        $($acbutSelect).addClass(_CLASS_NAME_FORM_FIELD_AUTO_COMPLETE_BUT);

        let $acbutSelectIcon = $('<i></i>');
        $($acbutSelectIcon).addClass(_CLASS_NAME_FORM_FIELD_AUTO_COMPLETE_BUT);
        $($acbutSelectIcon).addClass('fas');
        $($acbutSelectIcon).addClass('fa-chevron-down');

        let $acLoadingIcon = $('<i></i>');
        $($acLoadingIcon).addClass(_CLASS_NAME_FORM_FIELD_AUTO_COMPLETE_SPINNER)
        $($acLoadingIcon).addClass('fa');
        $($acLoadingIcon).addClass('fa-spinner');
        $($acLoadingIcon).addClass('fa-spin');
        
        $($acbutSelect).append($acbutSelectIcon);

        $($acInput).wrap($acContainer);
        $acContainer = $('#' + fieldDef.supportingCtrlID).parent();

        $($acContainer).append($acbutSelect);
        $($acContainer).append($acLoadingIcon);
        $($acLoadingIcon).hide();

        $($acInput).autocomplete({
            appendTo: $fieldCont
            , open: function (event, ui) {
                /* Hook for open */
                $($acLoadingIcon).hide();
                $($acbutSelect).hide();
            }
            , select: function (event, ui) {
                $('#' + fieldDef.ctrlID).val(ui.item.id);
                $($acLoadingIcon).hide();
                $($acbutSelect).show();
            }
            , close: function (event, ui) {
                $($acLoadingIcon).hide();
                $($acbutSelect).show();
            }
            , source: function (acReqCb, acRspCb) {

                let requestNvps = [];

                requestNvps.push(MBA.ComponentCommon.fnCreateNameValueObject(opts.PARM_NAME_CLIENT_ID, $('#' + opts.PARM_NAME_CLIENT_ID).val()));

                /* Add the search term from the autocomplete plugin to this arr (Note: only do this here) */

                requestNvps.push(MBA.ComponentCommon.fnCreateNameValueObject(opts.PARM_NAME_SEARCH_TERM, acReqCb.term));

                /* Create request data JSON string */

                let reqJSON = MBA.ComponentCommon.fnJSONFromArrNameValues(requestNvps);

                $($acLoadingIcon).show();
                $($acbutSelect).hide();
                
                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(fieldDef.fieldOptions.viewSelBaseURL, reqJSON, opts.sessionTimeOutUrl)
                    .then(responseData => {
                        $($acLoadingIcon).hide();
                        
                        let SelRecs = responseData.rawData.SelRecs;

                        if (!SelRecs) {
                            $($acbutSelect).show();
                            acRspCb([]);
                            return;
                        }
                        acRspCb(SelRecs);

                    })
                    .catch(responseData => {
                        $($acLoadingIcon).hide();
                        $($acbutSelect).show();
                        acRspCb({});
                    });
            }
        }).data("autocomplete")._renderItem = function ($ul, item) {
            let $li = $('<li></li>');
            
            $($li).addClass(_CLASS_NAME_FORM_FIELD_AUTO_COMPLETE_MENU);
            let $liContent = $('<a></a>');
            $($liContent).addClass(_CLASS_NAME_FORM_FIELD_AUTO_COMPLETE_MENU_ITEM);
            $($liContent).append(item.label);
            $li.append($liContent);
            $li.data('item.autocomplete', item);
            return $li.appendTo($ul);
        };

        let $acWidget = $('#' + fieldDef.supportingCtrlID).autocomplete("widget");
        $($acWidget).addClass(_CLASS_NAME_FORM_FIELD_AUTO_COMPLETE_MENU);
        
        $($acbutSelect).on('click', function () {            
            $($acInput).autocomplete('option', 'minLength', 0);
            $($acInput).autocomplete('close');
            $($acInput).autocomplete('search');
            $($acInput).autocomplete('option', 'minLength', 1);
        });

        $($acInput).on('click', function () {
            $($acInput).autocomplete('close');
        });


    };

    
    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnRenderFields = function ($me, fieldSets, fieldDefinitions, opts) {

        let _fnProcessMapEntry = function (fieldDef, key, map) {

            let fieldSet = fieldSets.get(fieldDef.fieldSet);
            let fieldSetLineID = fieldSet.fieldSetLines.get(fieldDef.fieldSetLine);
            let $fieldSetLine  = $('#' + fieldSetLineID);

            let $fieldCont = _fnCreateFieldAndLabel(opts.isPcalStaff, fieldDef);

            $($fieldSetLine).append($fieldCont);

            if (fieldDef.fieldType === 'autocomplete') {
                _fnRenderAutoComplete($fieldCont,fieldDef, opts);              
            }

             
            /* If manage files option is enabled for this field */

            if (fieldDef.manageFiles === true) {

              /* If user can upload/download */

              if (MBA.StoredFilesPrivateEndPointsAndParmNames.userHasAccessToFilesUploadDownload === true) {

                  /* If this is an existing patient record (not new) */

                  if (opts.VALUE_SAVE_TYPE === _SAVE_TYPE_EDIT) {

                       /* Create and render the manage files
                        * control as a sibling of the $fieldCont 
                        * on the same $fieldSetLine
                        */

                      let manageFilesTitle = 'Upload Files Related to ' + fieldDef.manageFilesOptions.dialogTitle;

                      let $manageFilesCtrl = $('<button type="button"></button>');
                      $($manageFilesCtrl).addClass(_CLASS_NAME_FORM_FIELD_FILES_MANAGE_BUTTON);
                      $($manageFilesCtrl).attr('title', 'Click to ' + manageFilesTitle);

                      let $manageFilesIcon = $('<i></i>');
                      $($manageFilesIcon).addClass('fa fa-paperclip');
                      $($manageFilesIcon).addClass(_CLASS_NAME_FORM_FIELD_FILES_MANAGE_ICON);

                      $($manageFilesCtrl).append($manageFilesIcon);
                      $($manageFilesCtrl).on('click', function () { _fnRelatedFileUpload ($me, manageFilesTitle, fieldDef.manageFilesOptions.fileClassVal); });

                      /* If PCAL only hide */

                      if ((opts.isPcalStaff === false) && (fieldDef.pcalOnly === true)) {
                          $($manageFilesCtrl).addClass(_CLASS_NAME_FORM_FIELD_FILES_MANAGE_HIDDEN);
                      }

                      $($fieldSetLine).append($manageFilesCtrl);
                  }
               }
             }

        };

        fieldDefinitions.forEach(_fnProcessMapEntry);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnFindFormFieldByName = function (elementid, formFieldSaveAsName) {
        let $me = _fnGetMe(elementid);
        let dataObj = _fnGetDataObj($me);
        let findSelector = '[' + _DATA_ATTR_FORM_FIELD_USER_REFERENCE_NAME + '=' + formFieldSaveAsName + ']';
        return $(dataObj.profileForm).find(findSelector)[0];
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnPrepopulateFields = function (elementid, lastName, firstName, middleName, preferredNickName, dobStrYMD, gender, CSIS) {

        $(_fnFindFormFieldByName(elementid, 'lname')).val(lastName);
        $(_fnFindFormFieldByName(elementid, 'fname')).val(firstName);
        $(_fnFindFormFieldByName(elementid, 'mname')).val(middleName);
        $(_fnFindFormFieldByName(elementid, 'p_nickname')).val(preferredNickName);
        $(_fnFindFormFieldByName(elementid, 'dob')).val(dobStrYMD);
        $(_fnFindFormFieldByName(elementid, 'sex')).val(gender);
        $(_fnFindFormFieldByName(elementid, 'csis')).val(CSIS);

        let $me = _fnGetMe(elementid);
        _fnToggleMinorConsentFieldsVisibility($me);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnUpdateMinorConsentHeaderState = function ($me) {
        let dataObj = _fnGetDataObj($me);

        let minorConsentField = _fnFindFormFieldByName(dataObj.meID, 'minorconsent');
        if (!minorConsentField) return;

        let minorConsentValue = $(minorConsentField).val();
        let isActive = (minorConsentValue === 'Yes');

        if (isActive) {
            $(dataObj.profileHeader).addClass(_CLASS_NAME_PROFILE_HEADER_MINOR_CONSENT_ACTIVE);
            $(dataObj.minorConsentNotice).removeClass(_CLASS_NAME_PROFILE_MINOR_CONSENT_NOTICE_HIDDEN);
        } else {
            $(dataObj.profileHeader).removeClass(_CLASS_NAME_PROFILE_HEADER_MINOR_CONSENT_ACTIVE);
            $(dataObj.minorConsentNotice).addClass(_CLASS_NAME_PROFILE_MINOR_CONSENT_NOTICE_HIDDEN);
        }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetAgeFromYMD = function (dobStrYMD) {
        if (!dobStrYMD) return null;

        let dob = new Date(dobStrYMD + 'T00:00:00');
        if (isNaN(dob.getTime())) return null;

        let today = new Date();
        let age = today.getFullYear() - dob.getFullYear();
        let monthDiff = today.getMonth() - dob.getMonth();

        if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < dob.getDate())) {
            age--;
        }

        return age;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnToggleMinorConsentFieldsVisibility = function ($me) {
        let dataObj = _fnGetDataObj($me);

        let dobField = _fnFindFormFieldByName(dataObj.meID, 'dob');
        let minorConsentField = _fnFindFormFieldByName(dataObj.meID, 'minorconsent');
        let minorConsentEffectiveDateField = _fnFindFormFieldByName(dataObj.meID, 'minorconsenteffectivedate');

        if (!dobField || !minorConsentField || !minorConsentEffectiveDateField) return;

        let dobValue = $(dobField).val();
        let age = _fnGetAgeFromYMD(dobValue);
        let showFields = (age !== null && age >= 12);

        let $minorConsentContainer = $(minorConsentField).closest('.' + _CLASS_NAME_FORM_FIELD_CONTAINER);
        let $minorConsentEffectiveDateContainer = $(minorConsentEffectiveDateField).closest('.' + _CLASS_NAME_FORM_FIELD_CONTAINER);

        if (showFields) {
            $minorConsentContainer.show();
            $minorConsentEffectiveDateContainer.show();
        } else {
            $(minorConsentField).val('No');
            $(minorConsentEffectiveDateField).val('');

            $minorConsentContainer.hide();
            $minorConsentEffectiveDateContainer.hide();
        }

        _fnUpdateMinorConsentHeaderState($me);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnMissingEmail = function ($me) {

        let dataObj = _fnGetDataObj($me);
        let emailField = _fnFindFormFieldByName(dataObj.meID, 'email');

        if (!emailField) {
            return false;
        }

        let $emailField = $(emailField);

        if ($emailField.length === 0) {
            return false;
        }

        let _fnRefreshEmailMissingState = function () {

            let val = $.trim($emailField.val() || '');

            if (val === '') {
                $emailField.addClass(_CLASS_NAME_PROFILE_EMAIL_REQUIRED_MISSING);
                return true;
            }

            $emailField.removeClass(_CLASS_NAME_PROFILE_EMAIL_REQUIRED_MISSING);
            return false;
        };

        $emailField.off('input.mbaEmailRequired change.mbaEmailRequired blur.mbaEmailRequired');

        $emailField.on('input.mbaEmailRequired change.mbaEmailRequired blur.mbaEmailRequired', function () {
            _fnRefreshEmailMissingState();
        });

        return _fnRefreshEmailMissingState();
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnHasPortalAccount = function (patRecordObj) {
        let userIDInt = parseInt(patRecordObj.patientUserIDInt || 0, 10);
        return userIDInt > 0;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnResolvePortalStatus = function (patRecordObj) {

        if (!patRecordObj) {
            return 'inactive';
        }

        if (_fnHasPortalAccount(patRecordObj)) {
            return 'active';
        }

        return 'inactive';
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetPortalInviteButtonState = function ($me, patRecordObj) {

        let dataObj = _fnGetDataObj($me);

        if (!dataObj.profilePortalInviteBtn) {
            return;
        }

        let portalStatus = _fnResolvePortalStatus(patRecordObj);

        let $btn = $(dataObj.profilePortalInviteBtn);

        $btn
            .removeClass(_CLASS_NAME_PROFILE_PORTAL_STATUS_RED)
            .removeClass(_CLASS_NAME_PROFILE_PORTAL_STATUS_YELLOW)
            .removeClass(_CLASS_NAME_PROFILE_PORTAL_STATUS_GREEN)
            .prop('disabled', false);

        if (portalStatus === 'active') {
            $btn
                .addClass(_CLASS_NAME_PROFILE_PORTAL_STATUS_GREEN)
                .attr('title', 'Portal account is active');
        } else if (portalStatus === 'sent') {
            $btn
                .addClass(_CLASS_NAME_PROFILE_PORTAL_STATUS_YELLOW)
                .attr('title', 'Portal invite sent');
        } else {
            $btn
                .addClass(_CLASS_NAME_PROFILE_PORTAL_STATUS_RED)
                .attr('title', 'Portal account is not active');
        }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnHandlePortalInviteClick = function ($me) {

        let fnOnProceed = function () {

            let dataObj = _fnGetDataObj($me);

            if (!dataObj.profilePortalInviteBtn) {
                return;
            }

            let $btn = $(dataObj.profilePortalInviteBtn);

            let requestObj = {};

            requestObj[dataObj.opts.PARM_NAME_REC_ID] = dataObj.opts.VALUE_PAT_ID;
            requestObj[dataObj.opts.PARM_NAME_CLIENT_ID] = $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val();

            let requestJSON = JSON.stringify(requestObj);

            $btn
                .prop('disabled', true)
                .attr('title', 'Sending portal invitation...');

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlInvitePatientPortal, requestJSON, dataObj.opts.sessionTimeOutUrl)
                .then(responseData => {

                    let msg = 'Patient portal invitation processed successfully.';

                    try {
                        if (responseData.rawData && responseData.rawData.jsonData) {

                            let result = JSON.parse(responseData.rawData.jsonData);

                            if (result && result.message) {
                                msg = result.message;
                            }
                            else if (result && result.accountAlreadyExists === true) {
                                msg = 'This patient already has a portal account.';
                            }
                            else if (result && result.inviteEmailSent === true) {
                                msg = 'Patient portal invitation email sent successfully.';
                            }
                        }
                    }
                    catch (ex) {
                        msg = 'The portal invitation was processed, but the response could not be read.';
                    }

                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Portal Invitation', msg, {});
                    _fnLoadFields($me);
                })
                .catch(err => {

                    let errMsg = err && err.message
                        ? err.message
                        : 'An error occurred while sending the patient portal invitation.';

                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Portal Invitation Error', errMsg, {});

                    $btn.prop('disabled', false);
                });
        }
        let content = '<div style="text-align:center; padding:10px 5px;">' +
                        '<div style="font-size:20px; font-weight:600; margin-bottom:8px;">' +
                        'Are you sure you want to send an invitation to this patient?' +
                        '</div>' +
                        '<div style="font-size:16px; color:#666;">' +
                        'This will send a portal invitation email to the patient.' +
                        '</div>' +
                        '</div>';
        let dia = MBA.ComponentCommon.fnCreateOneTimeProceedOrCancelDialog('Confirm Portal Invitation', content, {}, fnOnProceed, null, true, true);
        $(dia).dialog('open');
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnHandlePortalMessageClick = function ($me) {

        let dataObj = _fnGetDataObj($me);

        var msgOpts = {
            clientID: $('#' + dataObj.opts.PARM_NAME_CLIENT_ID).val(),
            sendMessageAjaxURL: dataObj.opts.baseUrlSaveMessage,
            deleteMessageAjaxURL: '',
            recipientSrcURL: dataObj.opts.baseUrlurlRecipientSrc,
            isSendOnly: true,
            replyModeOn: false,
            allowCloseWidget: true,
            viewModeSubject: '',
            textAreaPrefill: ''
        };

        MBA.messagesWidget.fnRenderMessages($me, { opts: msgOpts });
        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetup = function (elementid, optsIn) {

        let $me = _fnGetMe(elementid);

        /* See if we have created an instance of this plugin already for this element.  If so get out. */

        let dataObj = $($me).data(_JQ_DATA_NAME);
        if (dataObj) return;

        /* Define the data object we will save later */

        dataObj = {};

        /* Merge default options and options passed in. */

        let opts = $.extend({}, _DEFAULT_OPTIONS, optsIn);

        /* Save reference to opts */

        dataObj.opts = opts;

        /* Setup $me */

        $($me).addClass(_CLASS_NAME_CONTAINER);
        let meID = $($me).attr('id');
        dataObj.meID = meID;
        dataObj.me = $me;

        /* Create fields definitions map */

        let fieldDefinitions = _fnCreateFieldDefinitionsMap(meID, opts);
        dataObj.fieldDefinitions = fieldDefinitions;

        /* Create field set map */

        let fieldSets = _fnCreateFieldSetMap(meID, fieldDefinitions);
        dataObj.fieldSets = fieldSets;
        
        /*############################## PROFILE HEADER  ##############################*/

        let $profileHeader = $('<header></header>');
        $($profileHeader).addClass(_CLASS_NAME_PROFILE_HEADER);

        /*#################### PROFILE HEADER ROW 0  ####################*/

        let $profileHeaderRow0 = $('<div></div>');
        $($profileHeaderRow0).addClass(_CLASS_NAME_PROFILE_HEADER_ROW_0);
        
        let $profileHeaderRow0Controls = $('<div></div>');
        $($profileHeaderRow0Controls).addClass(_CLASS_NAME_PROFILE_HEADER_ROW_0_CONTROLS);

        let $profileHeaderRow0Person = $('<div></div>');
        $($profileHeaderRow0Person).addClass(_CLASS_NAME_PROFILE_HEADER_ROW_0_PERSON);

        /* Shrink Button and Icon */

        let $butProfileShrink = $('<button type="button" title="Hide Profile"></button>');
        $($butProfileShrink).addClass(_CLASS_NAME_PROFILE_BUTTON_SHRINK)

        let $iconProfileShrink = $('<i></i>');
        $($iconProfileShrink).addClass(_CLASS_NAME_PROFILE_BUTTON_ICON_SHRINK);
        $($iconProfileShrink).addClass('fas fa-window-minimize');
        $($butProfileShrink).append($iconProfileShrink);

        $($profileHeaderRow0Controls).append($butProfileShrink);

        /* Restore Button and Icon */

        let $butProfileRestore = $('<button type="button" title="Show Profile"></button>');
        $($butProfileRestore).addClass(_CLASS_NAME_PROFILE_BUTTON_RESTORE);

        let $iconProfileRestore = $('<i></i>');
        $($iconProfileRestore).addClass(_CLASS_NAME_PROFILE_BUTTON_ICON_RESTORE);
        $($iconProfileRestore).addClass('fas fa-window-restore');
        $($butProfileRestore).append($iconProfileRestore);

        $($profileHeaderRow0Controls).append($butProfileRestore);

        $($profileHeaderRow0).append($profileHeaderRow0Controls);


        let $profileHeaderPersonName = $('<h1></h1>');
        $($profileHeaderPersonName).addClass(_CLASS_NAME_PROFILE_HEADER_PERSON_NAME);

        $($profileHeaderRow0Person).append($profileHeaderPersonName);
        $($profileHeaderRow0).append($profileHeaderRow0Person);

        $($profileHeader).append($profileHeaderRow0);
        
        /*-----------------------------------------------------------------------------------------------*/

        /*#################### PROFILE HEADER ROW 1  ####################*/

        let $profileHeaderRow1 = $('<div></div>');
        $($profileHeaderRow1).addClass(_CLASS_NAME_PROFILE_HEADER_ROW_1);

        /* Profile image container and profile image */

        let $profileHeaderPersonImageContainer = $('<div></div>');
        $($profileHeaderPersonImageContainer).addClass(_CLASS_NAME_PROFILE_HEADER_PERSON_IMG_CONT);

        let $profileHeaderPersonImage = $('<i class="fas fa-user"></i>');
        $($profileHeaderPersonImage).addClass(_CLASS_NAME_PROFILE_HEADER_PERSON_IMG);
        $($profileHeaderPersonImageContainer).append($profileHeaderPersonImage);


        $($profileHeaderRow1).append($profileHeaderPersonImageContainer);

        /* Profile person container, person name, and person age */

        let $profileHeaderPerson = $('<div></div>');
        $($profileHeaderPerson).addClass(_CLASS_NAME_PROFILE_HEADER_PERSON);

        /* Age */ 
        let $profileHeaderPersonsAge = $('<h2 title="Current Age"></h2>');
        $($profileHeaderPersonsAge).addClass(_CLASS_NAME_PROFILE_HEADER_PERSON_NAME_AGE);

        let $profileHeaderPersonsAgeLabel = $('<span>Age</span>');
        $($profileHeaderPersonsAgeLabel).addClass(_CLASS_NAME_PROFILE_HEADER_PERSON_NAME_AGE_LABEL);
        $($profileHeaderPersonsAge).append($profileHeaderPersonsAgeLabel);

        let $profileHeaderPersonsAgeVal = $('<span></span>');
        $($profileHeaderPersonsAgeVal).addClass(_CLASS_NAME_PROFILE_HEADER_PERSON_NAME_AGE_VALUE);        
        $($profileHeaderPersonsAge).append($profileHeaderPersonsAgeVal);

        $($profileHeaderPerson).append($profileHeaderPersonsAge);

        /* Email phone */

        let $profileHeaderPersonsEmailPhone = $('<h2 title="Current Email and Phone"></h2>');
        $($profileHeaderPersonsEmailPhone).addClass(_CLASS_NAME_PROFILE_HEADER_PERSON_NAME_EMAIL_PHONE);

        let $profileHeaderPersonsEmail = $('<a>Email</a>');
        $($profileHeaderPersonsEmail).addClass(_CLASS_NAME_PROFILE_HEADER_PERSON_NAME_EMAIL);
        $($profileHeaderPersonsEmailPhone).append($profileHeaderPersonsEmail);

        let $profileHeaderPersonsPhone = $('<a>Phone</a>');
        $($profileHeaderPersonsPhone).addClass(_CLASS_NAME_PROFILE_HEADER_PERSON_NAME_PHONE);
        $($profileHeaderPersonsEmailPhone).append($profileHeaderPersonsPhone);

        $($profileHeaderPerson).append($profileHeaderPersonsEmailPhone);


        $($profileHeaderRow1).append($profileHeaderPerson);

        $($profileHeader).append($profileHeaderRow1);

        /*-----------------------------------------------------------------------------------------------*/

        /*#################### PROFILE HEADER ROW 2  ####################*/

        let $profileHeaderRow2 = $('<div></div>');
        $($profileHeaderRow2).addClass(_CLASS_NAME_PROFILE_HEADER_ROW_2);

        /* SSID Search (new records only)*/

        let ssidSearchInputID = null;
        let $ssidSearchInput  = null;
        let $ssidSearchButton = null;

        if (opts.VALUE_SAVE_TYPE === _SAVE_TYPE_NEW) {
            ssidSearchInputID    = meID + '-ssid-search';
            let $ssidSearchContainer = $('<span></span>');
            $($ssidSearchContainer).addClass('d-flex');
            let $ssidSearchLabel = $('<label  style="margin-top: 10px;">Search <span style="color: #ff9500; font-weight: 800; letter-spacing: 0.5px;">Health e Kids </span> network by SSID</label>');
            $($ssidSearchLabel).attr('for', ssidSearchInputID);
            $ssidSearchInput = $('<input type="search" placeholder="Enter SSID"/>');
            $($ssidSearchInput).attr('id', ssidSearchInputID);
            $ssidSearchButton = $('<button type="button">SCAN NETWORK</button>');
            $($ssidSearchContainer).append($ssidSearchLabel);
            $($ssidSearchContainer).append($ssidSearchInput);
            $($ssidSearchContainer).append($ssidSearchButton);

            $($profileHeaderRow2).append($ssidSearchContainer);

            $($ssidSearchContainer).addClass(_CLASS_NAME_SSID_SEARCH_CONTAINER);
            $($ssidSearchLabel).addClass(_CLASS_NAME_SSID_SEARCH_LABEL);
            $($ssidSearchInput).addClass(_CLASS_NAME_SSID_SEARCH_INPUT);
            $($ssidSearchButton).addClass(_CLASS_NAME_SSID_SEARCH_BUTTON);

           dataObj.ssidSearchInputID = ssidSearchInputID;
           dataObj.ssidSearchInput = $ssidSearchInput;
           dataObj.ssidSearchButton = $ssidSearchButton;
        }
       
        /* Wait notice */

        let $waitNotice = $('<div></div>');
        $($waitNotice).addClass(_CLASS_NAME_PROFILE_CTRL_NOTICE_CONTAINER);

        let $waitNoticeLabel = $('<span>Please Wait</span>');
        $($waitNoticeLabel).addClass(_CLASS_NAME_PROFILE_CTRL_NOTICE_MESSAGE);
        $($waitNotice).append($waitNoticeLabel);

        let $waitNoticeIcon = $('<i class="fa fa-spinner fa-spin"></i>');
        $($waitNoticeIcon).addClass(_CLASS_NAME_PROFILE_CTRL_NOTICE_ICON);
        $($waitNotice).append($waitNoticeIcon);

        $($profileHeaderRow2).append($waitNotice);

        /* Profile controls  */

        let $profileCtrls = $('<div></div>');
        $($profileCtrls).addClass(_CLASS_NAME_PROFILE_CTRLS);

        /*############################## MESSAGE & INVITE  ##############################*/
        
        let $profilePortalInviteBtn = $('<button type="button" title="Portal invite"></button>');
        $profilePortalInviteBtn
            .addClass(_CLASS_NAME_PROFILE_CTRL_BUTTON)
            .addClass(_CLASS_NAME_PROFILE_PORTAL_INVITE_BUTTON);

        let $portalInviteIcon = $('<i class="fas fa-envelope-open-text fa-2x"></i>');
        $portalInviteIcon.addClass(_CLASS_NAME_PROFILE_CTRL_BUTTON_ICON);

        $profilePortalInviteBtn.append($portalInviteIcon);
        $profileCtrls.append($profilePortalInviteBtn);

        /* Message button */

        let $profileMessageBtn = $('<button type="button" title="Click to send messages"></button>');
        $profileMessageBtn
            .addClass(_CLASS_NAME_PROFILE_CTRL_BUTTON)
            .addClass(_CLASS_NAME_PROFILE_PORTAL_MESSAGE_BUTTON);

        let $messageButtonIcon = $('<i class="fas fa-comment fa-2x"></i>');
        $messageButtonIcon.addClass(_CLASS_NAME_PROFILE_CTRL_BUTTON_ICON);

        $profileMessageBtn.append($messageButtonIcon);
        $profileCtrls.append($profileMessageBtn);

        /* Save button and icon */

        let $saveButton = $('<button type="button" title="Click to Save Profile"></button>');
        $($saveButton).addClass(_CLASS_NAME_PROFILE_CTRL_BUTTON);
        if (opts.showSaveProfileLabelInSaveButton === true) {
            let $saveButtonLabel = $('<span>Save Profile</span>');
            $($saveButtonLabel).addClass(_CLASS_NAME_PROFILE_CTRL_BUTTON_LABEL);
            $($saveButton).append($saveButtonLabel);
        }
        let $saveButtonIcon = $('<i class="fa fa-save"></i>');
        $($saveButtonIcon).addClass(_CLASS_NAME_PROFILE_CTRL_BUTTON_ICON);
        $($saveButton).append($saveButtonIcon);

        $($profileCtrls).append($saveButton);

        $($profileHeaderRow2).append($profileCtrls);


        $($profileHeader).append($profileHeaderRow2);

        /*-----------------------------------------------------------------------------------------------*/

        $($me).append($profileHeader);

        /*############################## MINOR CONSENT  ##############################*/

        let $minorConsentNotice = $('<div></div>');
        $($minorConsentNotice).addClass(_CLASS_NAME_PROFILE_MINOR_CONSENT_NOTICE);
        $($minorConsentNotice).addClass(_CLASS_NAME_PROFILE_MINOR_CONSENT_NOTICE_HIDDEN);

        let $minorConsentNoticeIcon = $('<i class="fa fa-exclamation-triangle"></i>');
        $($minorConsentNoticeIcon).addClass(_CLASS_NAME_PROFILE_MINOR_CONSENT_NOTICE_ICON);

        let $minorConsentNoticeText = $('<span>CA Minor Consent Active</span>');
        $($minorConsentNoticeText).addClass(_CLASS_NAME_PROFILE_MINOR_CONSENT_NOTICE_TEXT);

        $($minorConsentNotice).append($minorConsentNoticeIcon);
        $($minorConsentNotice).append($minorConsentNoticeText);

        $($profileHeader).append($minorConsentNotice);

        /*-----------------------------------------------------------------------------------------------*/

        $($waitNotice).addClass(_CLASS_NAME_PROFILE_CTRL_HIDDEN); /* Initially hidden */
        $($butProfileRestore).hide();                             /* Initially hidden*/

        if (opts.VALUE_SAVE_TYPE === _SAVE_TYPE_NEW) {
            $($profileHeaderRow0).hide();
            $($profileHeaderRow1).hide();
        }
        /*-----------------------------------------------------------------------------------------------*/

        let $requiredFieldNotice = $('<div>* Required Field</div>');
        $($requiredFieldNotice).addClass(_CLASS_NAME_PROFILE_CTRL_REQUIRED_FIELD_NOTICE);
        $($me).append($requiredFieldNotice);

        /*-----------------------------------------------------------------------------------------------*/

        /*############################## PROFILE FORM  ##############################*/

        let profileFormID = meID + '-profile-form';
        let $profileForm = $('<form></form>');
        $($profileForm).addClass(_CLASS_NAME_FORM);
        $($profileForm).attr('id', profileFormID);

        $($me).append($profileForm);

        /*-----------------------------------------------------------------------------------------------*/

        /*############################## REFERENCES  ##############################*/

        /* Save references */

        dataObj.profileHeader                     = $profileHeader;
        dataObj.profileHeaderRow0                 = $profileHeaderRow0;
        dataObj.profileHeaderRow1                 = $profileHeaderRow1;
        dataObj.profileHeaderRow2                 = $profileHeaderRow2;
        dataObj.butProfileShrink                  = $butProfileShrink;
        dataObj.butProfileRestore                 = $butProfileRestore;

        dataObj.profileHeaderPersonImageContainer = $profileHeaderPersonImageContainer;
        dataObj.profileHeaderPersonImage          = $profileHeaderPersonImage;
        
        dataObj.profileHeaderPerson        = $profileHeaderPerson;
        dataObj.profileHeaderPersonsName   = $profileHeaderPersonName;
        dataObj.profileHeaderPersonsAge    = $profileHeaderPersonsAge;
        dataObj.profileHeaderPersonsAgeVal = $profileHeaderPersonsAgeVal;
        dataObj.profileHeaderPersonsEmail  = $profileHeaderPersonsEmail;
        dataObj.profileHeaderPersonsPhone  = $profileHeaderPersonsPhone;

        dataObj.ssidSearchInputID = ssidSearchInputID;
        dataObj.ssidSearchInput   = $ssidSearchInput;
        dataObj.ssidSearchButton  = $ssidSearchButton;

        dataObj.waitNotice                 = $waitNotice;
        dataObj.saveButton                 = $saveButton;
        dataObj.requiredFieldNotice        = $requiredFieldNotice;
        dataObj.profileFormID              = profileFormID;
        dataObj.profileForm                = $profileForm;

		dataObj.minorConsentNotice          = $minorConsentNotice;
        dataObj.profilePortalInviteBtn      = $profilePortalInviteBtn;
        dataObj.profileMessageBtn           = $profileMessageBtn;
		
		
        /* Save our data object.  This will be used for option calls */

        $($me).data(_JQ_DATA_NAME, dataObj);

        /*-----------------------------------------------------------------------------------------------*/

        /* Render field sets */

        _fnRenderFieldSets($profileForm, fieldSets, opts);

        /* Render fields */

        _fnRenderFields($me, fieldSets, fieldDefinitions, opts);
		
        /*-----------------------------------------------------------------------------------------------*/

        /* New record */

        if (opts.VALUE_SAVE_TYPE === _SAVE_TYPE_NEW) {
            $($profileHeaderRow0).hide();
            $($profileHeaderRow1).hide();

            $($profilePortalInviteBtn).hide();
            $($profileMessageBtn).hide();

            _fnClearFields($me);
            _fnToggleMinorConsentFieldsVisibility($me);
        }

        /* Existing Record */

        else if (opts.VALUE_SAVE_TYPE === _SAVE_TYPE_EDIT) {            
            _fnLoadFields($me);
            if (opts.enableProfilePictureUpload) {
                _fnInitializeProfilePictureUploader($me, dataObj);
            }
        };

        /*-----------------------------------------------------------------------------------------------*/

        /* Wire up events */

        if (opts.VALUE_SAVE_TYPE === _SAVE_TYPE_NEW) {
            $($ssidSearchButton).on('click', function (e) { _fnDoFindStudentsBySSID($me); });
        };

        $($saveButton).on('click', function (e) { _fnSaveFields($me); });
        $($butProfileShrink).on('click', function (e) {_fnDoShrink($me);});
        $($butProfileRestore).on('click', function (e) {_fnDoRestore($me);});


        let $dobField = $(_fnFindFormFieldByName(meID, 'dob'));
        $dobField.on('change', function () {
            _fnToggleMinorConsentFieldsVisibility($me);
        });

        let $minorConsentField = $(_fnFindFormFieldByName(meID, 'minorconsent'));
        $minorConsentField.on('change', function () {
            _fnUpdateMinorConsentHeaderState($me);
        });

        $($profilePortalInviteBtn).on('click', function () {
            _fnHandlePortalInviteClick($me);
        });

        $($profileMessageBtn).on('click', function () {
            _fnHandlePortalMessageClick($me);
        });

    }; /*_fnSetup */

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
          fnSetup : _fnSetup
        , fnFindFormFieldByName: _fnFindFormFieldByName
        , fnPrepopulateFields: _fnPrepopulateFields
    };

})(jQuery);