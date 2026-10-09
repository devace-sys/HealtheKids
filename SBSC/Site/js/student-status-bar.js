var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.StudentStatusBarCommon
 * @memberof     MBA
 * @summary      Static methods for Patient Top Banner with status indicators
 * @description  Displays status indicators for missing patient information fields
 * @requires     jQuery, MBA.ComponentCommon
 */

MBA.StudentStatusBarCommon = (function ($) {
    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _THIS_NAME    = 'Student Status Bar Common Methods';
    const _PLUGIN_NS    = 'mba-patient-top-banner';
    const _PLUGIN_NAME  = 'Student Status Bar';
    const _JQ_DATA_NAME = 'mba-patient-top-banner-data';
    const _DATA_ATTR_MISSING_INFO = 'data-mba-student-missing-info';

    const _CSS_CLASSES = {
        container: _PLUGIN_NS + ' ' + _PLUGIN_NS + '-container'
        , innerWrapper: _PLUGIN_NS + '-inner-wrapper'
        , statusDashboard: _PLUGIN_NS + '-status-dashboard'
        , statusItem: _PLUGIN_NS + '-status-item'
        , statusItemIcon: _PLUGIN_NS + '-status-item-icon'
        , statusItemLabel: _PLUGIN_NS + '-status-item-label'
        , statusItemMissing: _PLUGIN_NS + '-status-item-missing'
        , statusItemOk: _PLUGIN_NS + '-status-item-ok'
        , statusItemLoading: _PLUGIN_NS + '-status-item-loading'
        , missingInfoItem: _PLUGIN_NS + '-missing-info-item'
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const _DEFAULT_OPTIONS = {
          cssClasses: _CSS_CLASSES
        , PARM_NAME_CLIENT_ID: ''
        , PARM_NAME_PAT_ID: ''
        , sessionTimeOutUrl: ''
        , baseUrlGetMissingInfo: ''
        , VALUE_CLIENT_ID: ''
        , VALUE_PAT_ID: ''
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetMe = function (elemid) {
        return $('#' + elemid);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetDataObj = function ($me) {
        let dataObj = $($me).data(_JQ_DATA_NAME);
        if (!dataObj) throw new Error('An instance of ' + _THIS_NAME + ' is required');
        return dataObj;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetDataObj = function ($me, dataObj) {
        $($me).data(_JQ_DATA_NAME, dataObj);
        return;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnCreateStatusItemsMap = function (meID) {
        let statusItems = new Map();

        /* Keep _fnCreateStatusItemMapEntry local to this function*/

        let _fnCreateStatusItemMapEntry = function (fieldName, label, icon, tooltip) {

            let statusItemObject = {};

            statusItemObject.label = label;
            statusItemObject.icon = icon;
            statusItemObject.tooltip = tooltip;

            statusItemObject.statusItemControlID = meID + '-' + fieldName;

            statusItems.set(fieldName, statusItemObject);
        };

        /* Define the status items to monitor */

        _fnCreateStatusItemMapEntry('missingFerpaConsent', 'FERPA', 'shield-alt', 'Missing or No FERPA Consent');
        _fnCreateStatusItemMapEntry('missingInsuranceInfo', 'Insurance', 'file-medical', 'Missing or Incomplete Insurance Information');
        _fnCreateStatusItemMapEntry('missingPGEmails', 'Parent Guardian Data', 'users', 'Missing or Incomplete Parent/Guardian Data');
        _fnCreateStatusItemMapEntry('missingAddressInfo', 'Address', 'map-marker-alt', 'Missing or Incomplete Student Address');
        _fnCreateStatusItemMapEntry('missingMcalParentConsent', 'Medi-Cal Parent Consent', 'signature', 'Missing Parental Consent for Medi-Cal Billing');

        return statusItems;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnRenderStatusItems = function (dataObj) {

        let _fnRenderStatusItem = function (statusItem, key, map) {
            let $item = $('<div></div>');
            $($item).attr('id', statusItem.statusItemControlID);
            $($item).attr('title', 'Loading...');
            $($item).attr(_DATA_ATTR_MISSING_INFO, '-1');

            $($item).addClass(dataObj.opts.cssClasses.statusItem);
            $($item).addClass(dataObj.opts.cssClasses.statusItemLoading);

            let $itemIcon = $('<i class="fa"></i>');
            $($itemIcon).addClass('fa-spinner fa-spin');
            $($itemIcon).addClass(dataObj.opts.cssClasses.statusItemIcon);
            $($item).append($itemIcon);

            let $itemLabel = $('<span></span>');
            $($itemLabel).html(statusItem.label);
            $($itemLabel).addClass(dataObj.opts.cssClasses.statusItemLabel);
            $($item).append($itemLabel);

            $(dataObj.statusDashboard).append($item);
        };

        dataObj.statusItems.forEach(_fnRenderStatusItem);

    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnUpdateStatusStatesFromPatWithMissingInfoRespObj = function ($me, dataObj, patWithMissingInfoRespObj) {

        /* Patient has missing info */
        
        if (patWithMissingInfoRespObj.hasRecord === true) {

            let mio = patWithMissingInfoRespObj.data;

            let _fnUpdateStatusItem = function (statusItem, key, map) {
                let $item = $('#' + statusItem.statusItemControlID);

                let missingInfoForItem = mio[key];
                
                $($item).removeClass(dataObj.opts.cssClasses.statusItemLoading);
                let $icon = $($item).find('.' + dataObj.opts.cssClasses.statusItemIcon);
                $($icon).removeClass('fa-spinner fa-spin');
                $($icon).addClass('fa-' + statusItem.icon);

                if (missingInfoForItem === true) {
                    $($item).attr(_DATA_ATTR_MISSING_INFO, '1');
                    $($item).attr('title', statusItem.tooltip);
                    $($item).removeClass(dataObj.opts.cssClasses.statusItemOk);
                    $($item).addClass(dataObj.opts.cssClasses.statusItemMissing);
                }
                else {
                    $($item).attr(_DATA_ATTR_MISSING_INFO, '0');
                    $($item).attr('title', 'Status OK');
                    $($item).removeClass(dataObj.opts.cssClasses.statusItemMissing);
                    $($item).addClass(dataObj.opts.cssClasses.statusItemOk);
                }
            };

            dataObj.statusItems.forEach(_fnUpdateStatusItem);

        }

        /* Patient does not have any missing info.  Reset status states accordingly.*/

        else {
            let _fnClearStatusItem = function (statusItem, key, map) {
                let $item = $('#' + statusItem.statusItemControlID);

                $($item).removeClass(dataObj.opts.cssClasses.statusItemLoading);
                let $icon = $($item).find('.' + dataObj.opts.cssClasses.statusItemIcon);
                $($icon).removeClass('fa-spinner fa-spin');
                $($icon).addClass('fa-' + statusItem.icon);

                $($item).attr(_DATA_ATTR_MISSING_INFO, '0');
                $($item).attr('title', 'Status OK');
                $($item).removeClass(dataObj.opts.cssClasses.statusItemMissing);
                $($item).addClass(dataObj.opts.cssClasses.statusItemOk);
            };
            dataObj.statusItems.forEach(_fnClearStatusItem);
        }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnGetMissingInfoAndUpdateStatusStates = function (elemid, okToAttemptUpdate) {

        if (okToAttemptUpdate === false) return;

        let $me     = _fnGetMe(elemid);
        let dataObj = _fnGetDataObj($me);

        if (!dataObj) {
            return; /* Component not initialized yet */
        }

        if (dataObj.isUpdating === false) {
            dataObj.isUpdating = true;
            _fnSetDataObj($me, dataObj);
        } else {
            return; /* Already being updated */
        }

        let requestObj = {};

        requestObj[dataObj.opts.PARM_NAME_CLIENT_ID] = dataObj.opts.VALUE_CLIENT_ID;
        requestObj[dataObj.opts.PARM_NAME_PAT_ID]    = dataObj.opts.VALUE_PAT_ID;

        let requestJSON = JSON.stringify(requestObj);

        
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.baseUrlGetMissingInfo, requestJSON, dataObj.opts.sessionTimeOutUrl)
            .then(responseData => {
                let patWithMissingInfoRespObj = responseData.rawData;
                _fnUpdateStatusStatesFromPatWithMissingInfoRespObj($me, dataObj, patWithMissingInfoRespObj);
              
                dataObj.isUpdating = false;                
                _fnSetDataObj($me, dataObj);
            })
            .catch(err => {              
                dataObj.isUpdating = false;
                _fnSetDataObj($me, dataObj);
            });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnDestroy = function (elemid) {
        let $me = _fnGetMe(elemid);
        let dataObj = _fnGetDataObj($me);

        if (dataObj) {
            $($me).empty();
            $($me).removeData(_JQ_DATA_NAME);
        }
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnCreate = function (elemid, optsIn) {

        let $me = _fnGetMe(elemid);

        /* See if we have created an instance of this plugin already for this element.  If so get out. */

        let dataObj = $($me).data(_JQ_DATA_NAME);
        if (dataObj) return;

        /* Define the data object we will save later */

        dataObj = {};
        dataObj.me = $me;
        dataObj.meID = $($me).attr('id');

        if (!dataObj.meID) {
            dataObj.meID = 'patient-top-banner-' + Math.random().toString(36).substr(2, 9);
            $($me).attr('id', dataObj.meID);
        }

        /* Merge default options and options passed in. */

        let opts = $.extend(true, {}, _DEFAULT_OPTIONS, optsIn);
        dataObj.opts = opts;

        $($me).addClass(opts.cssClasses.container);

        /* Create status items map */

        dataObj.statusItems = _fnCreateStatusItemsMap(dataObj.meID);

        /* Create status dashboard container */

        let $statusDashboard = $('<div></div>');
        $($statusDashboard).addClass(opts.cssClasses.statusDashboard);
        dataObj.statusDashboard = $statusDashboard;
        $($me).append($statusDashboard);

        dataObj.isUpdating = false;

        _fnRenderStatusItems(dataObj);

        /* Save data */
        $($me).data(_JQ_DATA_NAME, dataObj);

        /* Get initial missing info status */
        _fnGetMissingInfoAndUpdateStatusStates(elemid,true);

    }; /*_fnCreate */

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSetup = function (elemid, optsIn) {
        return _fnCreate(elemid, optsIn);
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        fnSetup: _fnSetup
        , fnDestroy: _fnDestroy
        , fnGetMissingInfoAndUpdateStatusStates: _fnGetMissingInfoAndUpdateStatusStates
    };

})(jQuery);