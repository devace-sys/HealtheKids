; var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.calendarWidget
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery
 */

MBA.calendarWidget = (function ($) {

    'use strict';

    const CONST_DATA_NAME = "mba-calendar-widget-data";
    const CONTENT_WRAPPER_CSS_CLASS = "mba-calendar-widget-wrapper-class";
    const CONST_TITLE_CSS_CLASS = "mba-calendar-widget-title";
    const CONST_CALENDAR_CSS_CLASS = "mba-calendar-widget-calendar"
    const CONST_FOOTER_CSS_CLASS = "mba-calendar-widget-footer";

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const CONST_DEFAULT_OPTIONS = {
        urlDateOnClick: ''
        , dateParmName: 'dos'
        , title: 'Calendar'
        , footerText: ''
        , tkn: ''
        , urlAgendaGet: ''
        , clientid: ''
        , pracid: ''
        , pracpatgroupid: ''
        , sessionTimeOutUrl: ''
        , defaultViewMode: ''
        , urlScheduledServiceEditBase: ''
        , urlScheduledServiceDeleteBase: ''
        , urlPatientEditBase: ''
        , urlGroupViewEntity: ''
        , urlGroupOnEdit: ''
        , urlGroupOnClick: ''
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnGetMe
     * @private
     * @summary      Gets reference to original elemement
     * @description  Gets reference to original elemement
     * @param  {Object}  elem  Element reference
     */

    let _fnGetMe = function (elem) { return $(elem); }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnDestroy
     * @private
     * @summary      Destroy existing instance
     * @description  Destroy existing instance
     * @param  {Object}  elem  Element reference
     */

    let _fnDestroy = function (elem) {
        let $me = _fnGetMe(elem);
        $me.removeData(CONST_DATA_NAME);
        return;
    }

    /* -------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    let _fnSafeHtml = function (s) {
        if (s === null || s === undefined) return '';
        return ('' + s)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnRenderCalendar
     * @private
     * @summary      renders the widget
     * @description  renders the widget
     */

    let _fnRenderCalendar = function ($me, dataObj) {

        let $header = $(
            '<div class="mba-agenda-header-wrap">' +
            '<div class="mba-agenda-titlebar">' + _fnSafeHtml(dataObj.opts.title || "Today's Appointments") + '</div>' +
            '<div class="mba-agenda-header">' +
            '<span class="mba-agenda-plus" title="Click to add new scheduled service">+</span>' +
            '<div class="mba-agenda-tabs">' +
            '<a class="mba-tab-agenda">Agenda</a>' +
            '<a class="mba-tab-calendar">Calendar</a>' +
            '</div>' +
            '</div>' +
            '</div>'
        );

        let $agendaView = $('<div class="mba-agenda-view"></div>');
        let $calendarView = $('<div class="mba-calendar-view"></div>');

        $me.append($header);
        $me.append($agendaView);
        $me.append($calendarView);

        // Month view
        let $calendarMkup = null;
        $calendarView.simpleCalendar({
            fixedStartDay: 0,
            onDateSelect: function (date, events) {
                let dateStr = date.toISOString().split('T')[0];
                let url = dataObj.opts.urlDateOnClick + '&' + dataObj.opts.dateParmName + '=' + dateStr;
                $($calendarMkup).html('<div class="text-center">Loading data for <strong>' + dateStr + '</strong> please wait<br><br><i class="fa fa-spinner fa-pulse fa-3x fa-fw"></i></div>');
                MBA.ComponentCommon.fnGotoURL(url);
            }
        });
        $calendarMkup = $($calendarView).find('div.calendar')[0];

        let _fnLoadAgenda = function (dosYMD) {

            let requestObj = {};
            requestObj["clientid"] = dataObj.opts.clientid;
            requestObj["pracid"] = dataObj.opts.pracid;
            requestObj["dos"] = dosYMD || "";
            requestObj["pracpatgroupid"] = null;

            let requestJSON = JSON.stringify(requestObj);

            $agendaView.html('<div class="text-center"><i class="fa fa-spinner fa-pulse fa-2x fa-fw"></i></div>');

            return MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(
                dataObj.opts.urlAgendaGet,
                requestJSON,
                dataObj.opts.sessionTimeOutUrl
            )
                .then(resp => {

                    let data = resp.rawData.data;

                    $agendaView.empty();

                    if (!data.length) {
                        $agendaView.html('<div class="text-center mb-3">No appointments for today.</div>');
                        return;
                    }

                    data.sort(function (a, b) {
                        let ta = (a.startTimeHMS || '').trim();
                        let tb = (b.startTimeHMS || '').trim();
                        let c = ta.localeCompare(tb);
                        if (c !== 0) return c;
                        let pa = (a.patName || '').toLowerCase();
                        let pb = (b.patName || '').toLowerCase();
                        return pa.localeCompare(pb);
                    });

                    // ------------------------------------------------------------
                    let finalList = [];
                    let groupRowsByKey = {};
                    let groupIDsToLoadSet = {};

                    for (let i = 0; i < data.length; i++) {
                        let it = data[i] || {};

                        let grpID = (it.caseloadGrpID == null) ? 0 : Number(it.caseloadGrpID);

                        if (!grpID || grpID === 0) {
                            finalList.push(it);
                            continue;
                        }

                        let key = String(grpID) + '|' + (it.dosYMD || '') + '|' + ((it.startTimeHMS || '').trim());

                        if (!groupRowsByKey[key]) {
                            let g = {};
                            for (let k in it) g[k] = it[k];

                            g._isGroupRow = true;
                            g._groupID = grpID;
                            g._groupName = null;
                            g._grpMemberCount = 0;

                            g._firstScheduledServiceID = it.scheduledServiceID;

                            groupRowsByKey[key] = g;
                        }

                        groupRowsByKey[key]._grpMemberCount++;

                        if (!dataObj.groupNameCache) dataObj.groupNameCache = {};
                        if (!dataObj.groupNameCache[grpID] && !groupIDsToLoadSet[grpID]) {
                            groupIDsToLoadSet[grpID] = true;
                        }
                    }

                    for (let k in groupRowsByKey) finalList.push(groupRowsByKey[k]);

                    finalList.sort(function (a, b) {
                        let ta = (a.startTimeHMS || '').trim();
                        let tb = (b.startTimeHMS || '').trim();
                        let c = ta.localeCompare(tb);
                        if (c !== 0) return c;

                        let na = (a._isGroupRow ? ('group ' + (a._groupID || '')) : (a.patName || '')).toLowerCase();
                        let nb = (b._isGroupRow ? ('group ' + (b._groupID || '')) : (b.patName || '')).toLowerCase();
                        return na.localeCompare(nb);
                    });

                    if (!dataObj.groupNamePromiseCache) dataObj.groupNamePromiseCache = {};

                    let _fnFetchGroupName = function (grpID) {

                        if (dataObj.groupNameCache && dataObj.groupNameCache[grpID]) {
                            return Promise.resolve(dataObj.groupNameCache[grpID]);
                        }

                        if (dataObj.groupNamePromiseCache[grpID]) {
                            return dataObj.groupNamePromiseCache[grpID];
                        }

                        let req = {};
                        req["clientid"] = dataObj.opts.clientid;
                        req["pracid"] = dataObj.opts.pracid;
                        req["recid"] = '' + grpID;

                        dataObj.groupNamePromiseCache[grpID] =
                            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(
                                dataObj.opts.urlGroupViewEntity,
                                JSON.stringify(req),
                                dataObj.opts.sessionTimeOutUrl
                            )
                                .then(r => {
                                    let ent = null;

                                    if (r && r.rawData.entity) {
                                        ent = r.rawData.entity;
                                    }

                                    let name = (ent && ent.name) ? ent.name : 'Group name missing';

                                    if (!dataObj.groupNameCache) dataObj.groupNameCache = {};
                                    dataObj.groupNameCache[grpID] = name;

                                    return name;
                                })
                                .catch(_ => {
                                    if (!dataObj.groupNameCache) dataObj.groupNameCache = {};
                                    dataObj.groupNameCache[grpID] = 'Group name missing';
                                    return 'Group name missing';
                                })
                                .finally(() => {
                                    delete dataObj.groupNamePromiseCache[grpID];
                                });

                        return dataObj.groupNamePromiseCache[grpID];
                    };

                    let loadPromises = [];
                    for (let gid in groupIDsToLoadSet) {
                        if (groupIDsToLoadSet.hasOwnProperty(gid)) {
                            loadPromises.push(_fnFetchGroupName(Number(gid)));
                        }
                    }

                    return Promise.all(loadPromises).then(function () {

                        for (let i = 0; i < finalList.length; i++) {
                            let it = finalList[i];
                            if (it && it._isGroupRow) {
                                let gid = it._groupID;
                                it._groupName = (dataObj.groupNameCache && dataObj.groupNameCache[gid])
                                    ? dataObj.groupNameCache[gid]
                                    : 'Group name missing';
                            }
                        }

                        /* ------------------------------------------------------------*
                         * render cards                                                *
                         * ------------------------------------------------------------*/

                        for (let i = 0; i < finalList.length; i++) {
                            let it = finalList[i];

                            let isGroupRow = (it && it._isGroupRow === true);

                            let title = '';
                            if (isGroupRow) {
                                title = (it._groupName && ('' + it._groupName).trim().length) ? it._groupName : 'Group name missing';
                            } else {
                                title = (it.patName || '').trim();
                                if (!title.length) title = 'Missing';
                            }

                            let timeStr = _fnGetTimeRange(it) + (it.numMins ? (' (' + it.numMins + ' mins)') : '');

                            let typeLabel = (it.svcName && ('' + it.svcName).trim().length) ? it.svcName : 'Service name missing';

                            let rightIcon = isGroupRow
                                ? '<i class="fa fa-users mba-act-group" title="Click to open Live Group Session"></i>'
                                : '<i class="fa fa-user mba-act-user" title="Click to open Patient Profile"></i>';

                            let $card = $(
                                '<div class="mba-agenda-card">' +
                                '<div class="mba-agenda-title">' + _fnSafeHtml(title) + '</div>' +
                                '<div class="mba-agenda-time">' + _fnSafeHtml(timeStr) + '</div>' +
                                '<div class="mba-agenda-type">' + _fnSafeHtml(typeLabel) + '</div>' +
                                '<div class="mba-agenda-righticon">' + rightIcon + '</div>' +
                                '<div class="mba-agenda-actions">' +
                                '<i class="fas fa-pencil-alt mba-act-edit text-warning" title="Click to edit Scheduled Service"></i>' +
                                '<i class="fas fa-calendar-times mba-act-calendar text-danger" title="Click to Cancel Session"></i>' +
                                '</div>' +
                                '</div>'
                            );

                            $card.on('click', function () {

                                if (it && it._isGroupRow === true) {
                                    let url = dataObj.opts.urlGroupOnEdit;

                                    let parms = [];
                                    parms.push(MBA.ComponentCommon.fnCreateNameValueObject("clientid", it.clientID));
                                    parms.push(MBA.ComponentCommon.fnCreateNameValueObject("pracid", it.pracID));
                                    parms.push(MBA.ComponentCommon.fnCreateNameValueObject("dos", it.dosYMD));
                                    parms.push(MBA.ComponentCommon.fnCreateNameValueObject("caseloadGrpId", it._groupID));
                                    parms.push(MBA.ComponentCommon.fnCreateNameValueObject("autoloaddata", "1"));

                                    let reqUrl = MBA.ComponentCommon.fnBuildUrl(url, true, parms);

                                    MBA.ComponentCommon.fnOpenWindowAndCallFnOnClose(reqUrl, null, "", _fnLoadAgenda);
                                    return;
                                }

                                let url = dataObj.opts.urlPatientEditBase + it.patID;

                                let parms = [];
                                parms.push(MBA.ComponentCommon.fnCreateNameValueObject("clientid", it.clientID));

                                let reqUrl = MBA.ComponentCommon.fnBuildUrl(url, true, parms);

                                MBA.ComponentCommon.fnOpenTab(reqUrl);
                            });

                            $card.find('.mba-act-edit').on('click', function (e) {
                                e.stopPropagation();

                                if (it && it._isGroupRow === true) {

                                    let url = dataObj.opts.urlGroupOnEdit;

                                    let parms = [];
                                    parms.push(MBA.ComponentCommon.fnCreateNameValueObject('clientid', it.clientID));
                                    parms.push(MBA.ComponentCommon.fnCreateNameValueObject('pracid', it.pracID));
                                    parms.push(MBA.ComponentCommon.fnCreateNameValueObject('recid', it.dosYMD));

                                    let reqUrl = MBA.ComponentCommon.fnBuildUrl(url, true, parms);

                                    MBA.ComponentCommon.fnOpenWindowAndCallFnOnClose(reqUrl, null, "", _fnLoadAgenda);
                                    return;
                                }

                                let url = dataObj.opts.urlScheduledServiceEditBase;
                                let parms = [];
                                parms.push(MBA.ComponentCommon.fnCreateNameValueObject('clientid', it.clientID));
                                parms.push(MBA.ComponentCommon.fnCreateNameValueObject('pracid', it.pracID));
                                parms.push(MBA.ComponentCommon.fnCreateNameValueObject('practitionerpatientcaseloadexpectedserviceid', ""));
                                parms.push(MBA.ComponentCommon.fnCreateNameValueObject('recid', it.scheduledServiceID));

                                let reqUrl = MBA.ComponentCommon.fnBuildUrl(url, true, parms);

                                return MBA.ComponentCommon.fnOpenWindowAndCallFnOnClose(reqUrl, null, "", _fnLoadAgenda);
                            });

                            $card.find('.mba-act-calendar').on('click', function (e) {
                                e.stopPropagation();

                                if (it && it._isGroupRow === true) {
                                    if (!it.clientID) return;
                                    if (!it.pracID) return;

                                    let url = dataObj.opts.urlEditGrpSchSvc;
                                    let parms = [];
                                    parms.push(MBA.ComponentCommon.fnCreateNameValueObject("clientid", it.clientID));
                                    parms.push(MBA.ComponentCommon.fnCreateNameValueObject("pracid", it.pracID));

                                    let reqUrl = MBA.ComponentCommon.fnBuildUrl(url, true, parms);

                                    return MBA.ComponentCommon.fnOpenWindowAndCallFnOnClose(reqUrl, null, "", _fnLoadAgenda);
                                }

                                let requestObj = {};
                                requestObj["clientid"] = it.clientID;
                                requestObj["pracid"] = it.pracID;
                                requestObj["recid"] = it.scheduledServiceID;

                                let requestJSON = JSON.stringify(requestObj);

                                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(dataObj.opts.urlScheduledServiceDeleteBase, requestJSON, dataObj.opts.sessionTimeOutUrl)
                                    .then(_ => { _fnLoadAgenda(""); })
                                    .catch(err => {
                                        MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Cancel Scheduled Service', err.message, {});
                                    });
                            });

                            $card.find('.mba-act-user').on('click', function (e) {
                                e.stopPropagation();

                                let url = dataObj.opts.urlPatientEditBase + it.patID;

                                let parms = [];
                                parms.push(MBA.ComponentCommon.fnCreateNameValueObject("clientid", it.clientID));

                                let reqUrl = MBA.ComponentCommon.fnBuildUrl(url, true, parms);

                                MBA.ComponentCommon.fnOpenTab(reqUrl);
                            });

                            $card.find('.mba-act-group').on('click', function (e) {
                                e.stopPropagation();

                                let url = dataObj.opts.urlGroupOnEdit;

                                let parms = [];
                                parms.push(MBA.ComponentCommon.fnCreateNameValueObject("clientid", it.clientID));
                                parms.push(MBA.ComponentCommon.fnCreateNameValueObject("pracid", it.pracID));
                                parms.push(MBA.ComponentCommon.fnCreateNameValueObject("dos", it.dosYMD));
                                parms.push(MBA.ComponentCommon.fnCreateNameValueObject("caseloadGrpId", it._groupID));
                                parms.push(MBA.ComponentCommon.fnCreateNameValueObject("autoloaddata", "1"));

                                let reqUrl = MBA.ComponentCommon.fnBuildUrl(url, true, parms);

                                MBA.ComponentCommon.fnOpenWindowAndCallFnOnClose(reqUrl, null, "", _fnLoadAgenda);
                            });

                            $agendaView.append($card);
                        }
                    })
                        .catch(err => {
                            $agendaView.html('<div class="text-danger text-center">Failed to load appointments.</div>');
                        });
                });
        };

        // Tabs
        let viewMode = dataObj.opts.defaultViewMode.toLowerCase();

        let $tabAgenda = $header.find('.mba-tab-agenda');
        let $tabCalendar = $header.find('.mba-tab-calendar');

        let _fnSetActiveTab = function (mode) {
            if (mode === "agenda") {
                $tabAgenda.addClass('active');
                $tabCalendar.removeClass('active');
            } else {
                $tabCalendar.addClass('active');
                $tabAgenda.removeClass('active');
            }
        };

        let _fnShowAgenda = function () {
            _fnSetActiveTab("agenda");
            $header.find('.mba-agenda-plus').show();

            $calendarView.hide();
            $agendaView.show();

            _fnLoadAgenda("");
        };

        let _fnShowCalendar = function () {
            _fnSetActiveTab("calendar");
            $header.find('.mba-agenda-plus').hide();

            $agendaView.hide();
            $calendarView.show();
        };

        $header.find('.mba-tab-agenda').on('click', function () { _fnShowAgenda(); });
        $header.find('.mba-tab-calendar').on('click', function () { _fnShowCalendar(); });

        $header.find('.mba-agenda-plus').on('click', function () {

            let url = dataObj.opts.urlScheduledServiceAddBase;

            let parms = [];
            parms.push(MBA.ComponentCommon.fnCreateNameValueObject("clientid", dataObj.opts.clientid));
            parms.push(MBA.ComponentCommon.fnCreateNameValueObject("pracid", dataObj.opts.pracid));
            parms.push(MBA.ComponentCommon.fnCreateNameValueObject("svcfromagenda", true));

            let reqUrl = MBA.ComponentCommon.fnBuildUrl(url, true, parms);

            MBA.ComponentCommon.fnOpenWindowAndCallFnOnClose(reqUrl, null, "", function () {
                _fnLoadAgenda("");
            });
        });

        if (viewMode === "agenda") _fnShowAgenda();
        else _fnShowCalendar();
    };

    let _fnParseHHMM = function (hhmm) {
        if (!hhmm) return null;
        let s = ('' + hhmm).trim();
        let p = s.split(':');
        if (p.length < 2) return null;

        let h = parseInt(p[0], 10);
        let m = parseInt(p[1], 10);

        if (isNaN(h) || isNaN(m)) return null;
        return { h: h, m: m };
    };

    let _fnTo12h = function (h, m) {
        let suffix = (h >= 12) ? 'pm' : 'am';
        let hh = h % 12; if (hh === 0) hh = 12;
        let mm = (m < 10 ? '0' : '') + m;
        return hh + ':' + mm + suffix;
    };

    let _fnAddMinutes = function (h, m, addMins) {
        let total = (h * 60) + m + (addMins || 0);
        total = ((total % (24 * 60)) + (24 * 60)) % (24 * 60);

        return { h: Math.floor(total / 60), m: total % 60 };
    };

    let _fnGetTimeRange = function (it) {
        let p = _fnParseHHMM(it.startTimeHMS);

        if (!p) return (it.startTimeStr || '').trim();

        let mins = parseInt(it.numMins, 10);
        if (isNaN(mins) || mins <= 0) mins = 0;

        let start = _fnTo12h(p.h, p.m);
        let endObj = _fnAddMinutes(p.h, p.m, mins);
        let end = _fnTo12h(endObj.h, endObj.m);

        return start + ' - ' + end;
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnCreate
     * @private
     * @summary      Create new instance
     * @description  Create new instance
     * @param  {Object}  elem    Element reference
     * @param  {Object}  optsIn  Options reference
     */

    let _fnCreate = function (elem, optsIn) {

        let $me = _fnGetMe(elem);

        /* See if we have created an instance of this plugin already for this element.  If so get out. */

        if (($me).data(CONST_DATA_NAME)) {
            ($me).removeData(CONST_DATA_NAME);
            ($me).children().remove();
        }

        /* Define the data object we will save later */

        let dataObj = {};

        dataObj.groupNameCache = {};

        /* Store reference to elem */

        dataObj.me = $me;

        /* Merge default options and options passed in. */

        let opts = $.extend({}, CONST_DEFAULT_OPTIONS, optsIn);
        dataObj.opts = opts;

        $($me).data(CONST_DATA_NAME, dataObj); /* Save our data object.  This will be used for option calls */
        $($me).addClass(CONTENT_WRAPPER_CSS_CLASS); /* Give wrapper class to element */

        _fnRenderCalendar($me, dataObj);


    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        fnCreate: _fnCreate
    };

})(jQuery);

/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Reports Widget plugin
 * @description  Reports Widget plugin
 * @requires     jQuery
 */

; (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /* Tie into jQuery namespace */

    $.fn.calendarWidget = function (methodOrOptions, optionsOrValue) {

        /* These are the supported methods and properties that can be accessed from outside after an instance is created */

        let _methods = {
        };

        let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

        /* Method is create */

        if (typeof methodOrOptions === 'object' || !methodOrOptions) {
            /* Tie into return chain so this can be chained with other methods */
            return this.each(function () {
                let elem = this; /* this in this scope is a reference to one of elements in the set */
                return MBA.calendarWidget.fnCreate(elem, methodOrOptions);
            });
        }


    }; /* calendarWidget */

})(jQuery);