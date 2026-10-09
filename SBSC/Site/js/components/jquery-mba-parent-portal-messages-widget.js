; var MBA = (MBA || {});


/*#############################################################################################################################################################*/


/**
 * @namespace    MBA.parentPortalMessagesWidget
 * @memberof     MBA
 * @summary      Static methods
 * @description  Static methods
 * @requires     jQuery
 */

MBA.parentPortalMessagesWidget = (function ($) {

    'use strict';
    const CONST_DATA_NAME = "mba-messages-widget-data";
    const CONTENT_WRAPPER_CSS_CLASS = "mba-messages-widget-class";
    const CONST_MESSAGES_CONTAINER = "mba-messages-widget-message-container-class";
    const CONST_MESSAGES_SUBJECT_NAME_ATTR = "mba-messages-widget-message-subject-name";
    const CONST_MESSAGES_BODY_NAME_ATTR = "mba-messages-widget-message-body-name";
    const CONST_MESSAGES_RECIPIENTS_ATTR = "mba-messages-widget-message-recipients-name";
    const CONST_CSS_CLASS_DIALOG_MINIMIZE_BTN = "mba-messages-widget-message-dialog-minimize-btn";
    const CONST_CSS_CLASS_DIALOG_MAXIMIZE_BTN = "mba-messages-widget-message-dialog-maximize-btn";

    var salt = 1;

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    const CONST_DEFAULT_OPTIONS = {
        sendMessageAjaxURL: "user_messages.asmx/save"
        , deleteMessageAjaxURL: "user_messages.asmx/delete"
        , recipientSrcURL: "users.asmx/viewSel"
        , clientID: ""
        , replyModeOn: false    // if this is true, it means we are rendering a reply preview
        , allowDelete: false
        , allowCancel: false
        , viewModeSubject: ""
        , viewModeBody: ""
        , textAreaPrefill: ""
        , messageID: ''
        , isSendOnly: true     // if this is true, then we are rendering a send message window, otherwise a reply to message window
        , recipientIDs: ''       // used for preloading recipients
        , recipientNames: ''       // used for preloading recipients
        , senderUserID: ''
        , senderName: ''
        , allowCloseWidget: true
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

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _sendMessageAjaxURL
     * @private
     * @summary      save message
     * @description  save message
     * @param  {Object}  elem  Element reference
     */

    let _sendMessageAjax = function (dataObj) {
        // send ajax to send message
        var $dialogDiv = $('#' + dataObj.opts.dialogDivID);
        var reqUrl = dataObj.opts.sendMessageAjaxURL;
        var reqData = JSON.stringify({
            'recipientuseridsstr': $dialogDiv.find('[name="' + "recipientuseridsstr" + '"]').val()
            , 'subject': $dialogDiv.find('[name="' + CONST_MESSAGES_SUBJECT_NAME_ATTR + '"]').val()
            , 'body': $dialogDiv.find('[name="' + CONST_MESSAGES_BODY_NAME_ATTR + '"]').val()

            , 'sendEmail': ($dialogDiv.find('input#checkboxSendEmail').prop('checked') ? 1 : 0)

            , 'isreply': !dataObj.opts.isSendOnly // if not send, then it's a reply
            , 'previousmsgid': (!dataObj.opts.isSendOnly) ? dataObj.opts.messageID : ''
            , 'oktoshow': ''
            , 'hasread': ''
            , 'active': 1
            , 'savetype': $.spedmonWebUI.RECORD_SAVE_TYPE_NEW
            , 'recid': ''
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                $dialogDiv.dialog('close');
            })
            .catch(responseData => {
                alert(responseData.rawData.message);
            });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _deleteMessageAjax
     * @private
     * @summary      delete message
     * @description  delete message
     * @param  {Object}  elem  Element reference
     */

    let _deleteMessageAjax = function ($me, recid, reqUrl) {
        // send ajax to delete messsage
        var reqData = JSON.stringify({
            'recid': recid
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                $me.effect('blind', 'normal', function () { $me.remove(); });
            })
            .catch(responseData => {
                alert(responseData.rawData.message);
            });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _toggleReplyMode
     * @private
     * @summary      toggles dialog to reply or view mode
     * @description  toggles dialog to reply or view mode
     * @param  {Object}  elem  Element reference
     */

    let _toggleReplyMode = function ($me, dataObj) {
        // toggle reply mode booleans
        dataObj.opts.replyModeOn = !dataObj.opts.replyModeOn;
        dataObj.opts.allowCancel = !dataObj.opts.allowCancel;

        // close dialog, because a new one will be opened
        $('#' + dataObj.opts.dialogDivID).dialog('close');

        _fnRenderMessages($me, dataObj);

    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnSetMessage
     * @private
     * @summary
     * @description
     * @param  {Object}  elem  Element reference
     */

    let _fnSetMessage = function (dataObj, $me, hasRead, okToShow) {

        var reqUrl = dataObj.opts.sendMessageAjaxURL;
        var reqData = JSON.stringify({
            'recipientuseridsstr': ''
            , 'subject': dataObj.opts.viewModeSubject
            , 'body': dataObj.opts.viewModeBody
            , 'isreply': ''
            , 'previousmsgid': ''
            , 'oktoshow': okToShow
            , 'hasread': hasRead
            , 'active': ''
            , 'savetype': $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT
            , 'recid': dataObj.opts.messageID
            , 'sendEmail': false
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {

                //eval('debugger');

                try {

                    // this code block causes problems because it is trying
                    // to manipulate the notification widget on the homepage,
                    // which is impossible to do when the message widget
                    // is rendered on a different page (not the homepage)

                    if (okToShow != null && okToShow == false) {
                        var $dialogDiv = $('#' + dataObj.opts.dialogDivID)

                        $dialogDiv.dialog('close');

                        // subtract one from the messages count badge
                        let $countBadge = $('#mba-user-messages-count-badge-pill');
                        try {
                            let msgCount = parseInt($countBadge.html());
                            $countBadge.html(msgCount - 1);
                        } catch (e) {

                        }

                        $me.remove();
                    }
                } catch (e) {
                    throw { catchE: e, responseData: responseData }
                    // the raised error needs to contain both the exception from .then()
                    // as well as the original AJAX response
                }
            })
            .catch(errExcWrapObj => {  // this var was called responseData,
                // but it did not actually contain the AJAX response
                // when an error was raised from the .then() callback;
                // renaming this to be less confusing
                //eval('debugger');



                try {

                    if (errExcWrapObj.responseData
                        &&
                        errExcWrapObj.responseData.rawData.message == "Success"
                        &&
                        errExcWrapObj.responseData.type == "MBA.ReturnSaveRecord"
                    )
                        return;

                    alert(responseData.rawData.message);
                } catch (e) {
                    //debugger;
                    alert("Something went wrong!");
                }
            });
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnRemoveCloseIconFromDialog
     * @private
     * @summary      Removes close icon ("x" icon) from a dialog div
     * @description  Removes close icon ("x" icon) from a dialog div
     * @param  {Object}  elem  Element reference
     */

    let _fnRemoveCloseIconFromDialog = function ($dialogDiv) {
        $dialogDiv.parent().find('span.ui-icon-closethick').parent('.ui-dialog-titlebar-close').remove();
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnAppendMinimizeBtnToDialog
     * @private
     * @summary      Appends minimize icon to the dialog window
     * @description  Appends minimize icon to the dialog window
     * @param  {Object}  elem  Element reference
     */

    let _fnAppendMinimizeBtnToDialog = function ($dialogDiv) {

        // create minimize and maximize buttons
        let $minimizeBtn = $('<a href="#" class="ui-dialog-titlebar-close ui-corner-all ' + CONST_CSS_CLASS_DIALOG_MINIMIZE_BTN + '" role="button"><span class="ui-icon ui-icon-minusthick">minimize</span></a>');
        let $maximizeBtn = $('<a href="#" class="ui-dialog-titlebar-close ui-corner-all ' + CONST_CSS_CLASS_DIALOG_MAXIMIZE_BTN + '" role="button"><span class="ui-icon ui-icon-arrowthick-2-se-nw">maximize</span></a>');
        $minimizeBtn.on("click", function () {
            $dialogDiv.parents('.ui-dialog').animate({
                height: '40px',
                top: $(window).height() - 40
            }, 200);
            $minimizeBtn.hide();
            $maximizeBtn.show();
        });

        // source for minimize and maximize functions: https://stackoverflow.com/a/11561470
        $maximizeBtn.on("click", function () {
            $dialogDiv.parents('.ui-dialog').animate({
                //set the positioning to center the dialog - 200 is equal to height of dialog
                top: ($(window).height() - 200) / 2,
                //set the height again
                height: 500
            }, 200);

            $minimizeBtn.show();
            $maximizeBtn.hide();
        });

        $minimizeBtn.hover(
            function () {
                $(this).addClass("ui-state-hover");
            }, function () {
                $(this).removeClass("ui-state-hover");
            }
        );

        $maximizeBtn.hover(
            function () {
                $(this).addClass("ui-state-hover");
            }, function () {
                $(this).removeClass("ui-state-hover");
            }
        );

        ($maximizeBtn).insertBefore($dialogDiv.parent().find('.ui-dialog-titlebar-close'));
        ($minimizeBtn).insertBefore($maximizeBtn.hide());
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnRenderMessages
     * @private
     * @summary      Render user messages in view, send, or reply mode
     * @description  Render user messages in view, send, or reply mode
     * @param  {Object}  elem  Element reference
     */

    let _fnRenderMessages = function ($me, dataObj) {
        // destroy previous dialog
        $('#' + dataObj.opts.dialogDivID).dialog('close').remove();

        // send ajax to set this message as read (if existing message)
        if ($me && dataObj)
            if (dataObj.opts.messageID) _fnSetMessage(dataObj, $me, true, null);

        let $dialogDiv = $('<div id="' + dataObj.opts.dialogDivID + '" class="' + CONST_MESSAGES_CONTAINER + '"></div>');

        // subject
        let subject = dataObj.opts.viewModeSubject;
        let subjectMaxLength = 50;

        // build subject for replies
        if (!dataObj.opts.replyModeOn && !dataObj.opts.isSendOnly && !subject.trim().startsWith('RE: ')) {
            subject = 'RE: ' + subject;
            subjectMaxLength += 5;
        }

        let $subjectDiv =
            (dataObj.opts.replyModeOn) ?
                $('<div class="form-row">'
                    + '<label for="' + CONST_MESSAGES_SUBJECT_NAME_ATTR + '" class="col-2 col-form-label font-weight-bold">Subject:</label>'
                    + '<div class="col-10">'
                    + '<input type="text" maxlength="' + subjectMaxLength + '" class="form-control-static ui-spedmon-box ui-widget-content ui-corner-all ui-spedmon-box-focus" name="' + CONST_MESSAGES_SUBJECT_NAME_ATTR
                    + '" placeholder="Subject" value="' + subject + '" readonly>'
                    + '</div>'
                    + '</div>'
                )
                :
                $(
                    '<div class="form-row">'
                    + '<label for="' + CONST_MESSAGES_SUBJECT_NAME_ATTR + '" class="col-2 col-form-label font-weight-bold">Subject:</label>'
                    + '<div class="col-10">'
                    + '<input type="text" maxlength="' + subjectMaxLength + '" class="form-control-static ui-spedmon-box ui-widget-content ui-corner-all ui-spedmon-box-focus" name="' + CONST_MESSAGES_SUBJECT_NAME_ATTR
                    + '" value="' + subject + '" placeholder="Subject">'
                    + '</div>'
                    + '</div>'
                );

        // messages diaplayed when previewing
        let $messageBody = $(
            '<div class="form-group  mt-2 ' + ((dataObj.opts.replyModeOn) ? 'd-none' : '') + '">'
            + '<label class="font-weight-bold" for="' + CONST_MESSAGES_BODY_NAME_ATTR + '">Body:</label>'
            + '<textarea class="form-control" name="' + CONST_MESSAGES_BODY_NAME_ATTR + '" rows="3">' + dataObj.opts.textAreaPrefill + '</textarea>'
            + '</div>');

        let $message = $('<div class="row col-12 mt-2 mb-2 ' + ((dataObj.opts.replyModeOn) ? '' : 'd-none') + '">'
            + dataObj.opts.viewModeBody + '</div>');

        // user selection for recipient, displayed when sending
        let $recipientSelect = $(
            '<div class="form-row  mt-2 ' + ((dataObj.opts.replyModeOn) ? 'd-none' : '') + '">'
            + '<label class="col-2 col-form-label font-weight-bold">To:</label>'
            + '<div class="col-10">'
            + ((dataObj.opts.isSendOnly && $me)  // if this is not a reply
                ?
                '<input ID="' + ($me.attr('id') + '_msg-dialog-recipients_' + salt++) + '" name="recipientuseridsstr" title="Select Names" class="'
                + CONST_MESSAGES_RECIPIENTS_ATTR + '" />'
                : // if it is a reply
                '<input name="recipientuseridsstr" title="Select Names" value="' + dataObj.opts.senderUserID + '" class="d-none ' + CONST_MESSAGES_RECIPIENTS_ATTR + '" />'
                + dataObj.opts.senderName
            )
            + '</div>'
            + '</div>'
        );

        // buttons
        let $buttonsDiv = $('<div class="row d-flex flex-wrap"></div>');

        let $buttonsLeft = $('<div class="col-6"></div>');
        let $buttonsRight = $('<div class="col-6 text-right pr-4"></div>');

        // reply button(s)
        let $replyBtn = $('<i class="fas fa-reply fa-2x m-2" title="Reply"></i>');
        $replyBtn.on("click", function () { _toggleReplyMode($me, dataObj); });

        let $replyAllBtn = $('<button type="button" class="btn btn-light">Reply All</button>');

        // delete button
        let $delBtn = $('<i class="fas fa-trash-alt fa-2x m-2" title="Delete"></i>');
        $delBtn.on("click", function () { _fnSetMessage(dataObj, $me, null, false); });

        // send button
        let $sendBtn = $('<i class="fas fa-paper-plane fa-2x m-2" title="Send"></i>');
        $sendBtn.on("click", function () { _sendMessageAjax(dataObj); });

        // cancel button
        let $cancelBtn = $('<i class="fas fa-window-close fa-2x m-2" title="Cancel"></i>');
        $cancelBtn.on("click", function () { _toggleReplyMode($me, dataObj); });

        // in reply mode, we only need reply and delete buttons
        if (dataObj.opts.replyModeOn) {

            $buttonsLeft.append($replyBtn);
            if (dataObj.opts.allowDelete) {
                $buttonsLeft.append($delBtn);
            }

            /*https://www.w3schools.com/js/js_bitwise.asp*/

            if (typeof (dataObj.opts.respPromptOptions) != 'undefined' && (dataObj.opts.respPromptOptions & 4)) {
                let $newSvcRecBtn = $('<a href="' + JSON.parse(dataObj.opts.respPromptOptionsJSON).rmtsAddNewServiceURL +

                    //  NOTE: baking-in the the URL as part of the message data is kinda undesirable
                    //  because the site path differs between dev and live.
                    //  if accounts and messages are transfered from here to there
                    //  then links stop working as intended.

                    '&rmtsmomentid=' + JSON.parse(dataObj.opts.respPromptOptionsJSON).referencedentityid +
                    '&tkn=' + $.spedmonWebUI.token +
                    '"> ' +
                    '<i class="fas fa-notes-medical fa-2x m-2" title="Record Service"></i></a>');
                //$rmtsFileUpboxBtn.on("click",
                //  dataObj.opts.FnRmtsRespPromptFileupbox
                //);
                $buttonsLeft.append($newSvcRecBtn);
            }


            if (typeof (dataObj.opts.respPromptOptions) != 'undefined' && (dataObj.opts.respPromptOptions & 8)) {
                let $rmtsFileUpboxBtn = $('<i class="fas fa-file-upload fa-2x m-2" title="RMTS Upload Supporting Documents"></i>');
                $rmtsFileUpboxBtn.on("click",
                    function () {
                        dataObj.opts.FnRmtsRespPromptFileupbox($)
                    }
                );
                $buttonsLeft.append($rmtsFileUpboxBtn);
            }

            if (
                (typeof (dataObj.opts.respPromptOptions) != 'undefined') &&
                ((dataObj.opts.respPromptOptions & 8)
                    || (dataObj.opts.respPromptOptions & 4)
                )
            ) {


                let $rmtsCompleteBtn = $('<span class="btn btn-success"><i class="fas fa-check m-2" title="Finish and Send to LEA Coordinator"></i>Finish & Notify Coordinator</span>');
                $rmtsCompleteBtn.on("click",
                    function () {

                        //alert('hi');
                        //debugger;

                        let reqUrl = dataObj.opts.siteBaseUrl +
                            'rmts_moments.asmx/sendpracrsvpcomplete' +
                            '?tkn=' + $.spedmonWebUI.token;

                        let reqDataObj = {};
                        reqDataObj['recid'] = JSON.parse(dataObj.opts.respPromptOptionsJSON).referencedentityid;

                        let reqDataJSON = JSON.stringify(reqDataObj);

                        $.spedmonWebUI.dialogWaitShow('Sending...');


                        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqDataJSON, null)
                            .then(responseData => {
                                // $($restViewCtrl).MBA_RestView('refreshCurrentViewFromServer');
                                alert('Sent!');
                                window.close();
                                //debugger;         
                            })
                            .catch(errExcWrapObj => {

                                if (errExcWrapObj.responseData
                                    &&
                                    errExcWrapObj.responseData.rawData.message == "Success"
                                    &&
                                    errExcWrapObj.responseData.type == "MBA.ReturnSaveRecord"
                                )
                                    return;
                                try {
                                    alert(responseData.rawData.message);
                                } catch (e) {
                                    //debugger;
                                    alert("Something went wrong!");

                                }
                            })
                    }

                    //});

                    //return uiActionObj;
                    //}
                );
                $buttonsRight.append($rmtsCompleteBtn);

            }

            if (dataObj.opts.promptUserToGotoURL) {

                let $gotoURLNavBtn = $(
                    '<a href="' +
                    dataObj.opts.gotoURL +
                    '"><i class="fas fa-hand-point-right fa-2x m-2" title="Navigate to URL">' +
                    '</i></a>'
                );

                $buttonsLeft.append($gotoURLNavBtn);

            }

        } // in send mode, we only need send and cancel button
        else {
            $buttonsLeft.append($sendBtn);
            if (dataObj.opts.allowCancel) {
                $buttonsLeft.append($cancelBtn);
            }
        }

        let $sendEmailCheckbox = $(
            '<div class="form-group">' +
            '<input id="checkboxSendEmail" type="checkbox" name="sendEmail">' +
            '<label class="px-2">Send email?</label></div>'
        );

        let $hippaComplianceNotice = $('<div class="mba-messages-widget-hippa-compliance-notice"><strong>Do not disclose</strong> <a href="https://www.hhs.gov/answers/hipaa/what-is-phi/index.html" target="_blank">Protected Health Information (PHI)</a> in this message.</div>');

        // append appropriate content and show message as dialog
        $dialogDiv.append($hippaComplianceNotice).append($subjectDiv).append($recipientSelect).append($message).append($messageBody);

        if (!(dataObj.opts.replyModeOn))
            $dialogDiv.append($sendEmailCheckbox)

        $buttonsDiv.append($buttonsLeft);
        $buttonsDiv.append($buttonsRight);
        $dialogDiv.append($buttonsDiv);

        // call dialog
        $dialogDiv.dialog(
            {
                width: 600
                , height: 575
                , title: "Messages"
                , resizable: false
                // SE APLICA ESTILO ANTES DE QUE EL DIALOG SE VEA
                ,create: function () {
                    _fnApplyParentPortalDialogStyles($dialogDiv);
                }
                // por si se reabre o cambia el tamaño
                ,open: function () {
                    _fnApplyParentPortalDialogStyles($dialogDiv);
                }
                , show: {
                    effect: 'slide'
                    , complete: function () {
                        _fnAppendMinimizeBtnToDialog($dialogDiv);

                        _fnApplyParentPortalDialogStyles($dialogDiv);

                        // if dialog is not closable, remove 'x' icon which closes the dialog
                        if (!dataObj.opts.allowCloseWidget) {
                            _fnRemoveCloseIconFromDialog($dialogDiv);
                        }

                        let needToLoadRecipients = (dataObj.opts.recipientIDs && dataObj.opts.recipientNames);
                        
                        // only render recipient selection in send mode
                        if (!dataObj.opts.replyModeOn && dataObj.opts.isSendOnly) {
                            // call combobox on user selection
                            $dialogDiv.find('.' + CONST_MESSAGES_RECIPIENTS_ATTR).spedmonSelectBox({
                                "dataParmType": "DOM"
                                , "selectAll": true
                                , "delay": 600
                                , "showSelectControlLabel": false
                                , "selectControlLabel": "To: "
                                , "selectType": $.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX
                                , "displayInline": false
                                , "singleSelectName": null
                                , "singleSelectValue": null
                                , "singleSelectClearAfterSelection": false
                                , "multiSelect": true
                                , "multiSelectShowOK": false
                                , "multiSelectListTitle": "Selected"
                                , "multiSelectNames": ((needToLoadRecipients) ? dataObj.opts.recipientNames : null)
                                , "multiSelectValues": ((needToLoadRecipients) ? dataObj.opts.recipientIDs : null)
                                , "multiSelectLoad": ((needToLoadRecipients) ? true : false)
                                , "multiSelectContextLabels": ''
                                , "multiSelectDisplayContextLabels": false
                                , "multiSelectOnAdd": function (selObj) {}
                                , "multiSelectOnRemove": function (selObj) { }
                                , "onSelect": function (event, ui) {}
                                , "ajaxopts": {
                                    url: dataObj.opts.recipientSrcURL
                                    , data: ""
                                    , namevalues: [{ name: "clientid", value: dataObj.opts.clientID }]
                                }
                            });
                        }
                    }
                }
                , hide: {
                    effect: 'slide'
                    , direction: 'left'
                }
                , close: function () {
                    $dialogDiv.remove();
                }
            }
        );
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnRenderDeletedMessages
     * @private
     * @summary      renders user's deleted messages window
     * @description  renders user's deleted messages window
     * @param  {Object}  elem    Element reference
     * @param  {Object}  optsIn  Options reference
     */

    let _fnRenderDeletedMessages = function (elem, deletedMessagesAjaxURL, deletedMessagesAjaxData, deleteMessageAjaxURL) {
        let $me = _fnGetMe(elem);

        // function to render deleted messages inside a modal
        function _renderDeletedMessagesDialog(deletedMessagesArr) {
            // generate list of deleted messages
            let $dialogDivContent = $('<div class="d-flex flex-column justify-content-center"></div>');
            if (deletedMessagesArr && Array.isArray(deletedMessagesArr) && deletedMessagesArr.length > 0) {
                $.each(deletedMessagesArr, function (key, value) {
                    let $msg = $('<div class="col-12 mt-3 rounded text-left p-1 mba-background-color-message">'
                        + '<div class="col-12 d-flex flex-row align-items-center">'
                        + '<i class="fas fa-trash-alt mr-1"></i>' // trash icon
                        + '<div class=" mr-1">' + value.createdStr + '</div>' // date
                        + '<strong class=" mr-1">' + value.subject + '</strong>' // subject
                        + '</div>'
                        + '<div class="col-12 d-flex flex-row align-items-center max-height-100-ellipsis white-space-pre">'
                        + value.body // body
                        + '</div>'
                        + '</div>');

                    // attach on click to delete record permanently
                    $msg.find('.fa-trash-alt').on("click", function () { _deleteMessageAjax($msg, value.id, deleteMessageAjaxURL); });

                    $dialogDivContent.append($msg);

                });

                return $dialogDivContent;
            }

            return $('<div>No Mesages</div>');
        }

        // render dialog
        let $dialogDiv = $('<div></div>');

        $dialogDiv.html('<div class="d-flex justify-content-center"><i class="fa fa-spinner fa-pulse fa-fw fa-2x"></i></div>').dialog({
            width: 500
            , height: 500
            , title: "Deleted Messages"
            ,create: function () {
                _fnApplyParentPortalDialogStyles($dialogDiv);
            }
            ,open: function () {
                _fnApplyParentPortalDialogStyles($dialogDiv);
            }
            ,show: {
                effect: 'slide',
                complete: function () {
                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(deletedMessagesAjaxURL, deletedMessagesAjaxData, null)
                        .then(responseData => {
                            $dialogDiv.html('')
                                .append(_renderDeletedMessagesDialog(responseData.rawData.data))
                                .addClass('mba-announcements-carousel-fade');
                        })
                        .catch(responseData => {
                            alert(responseData.rawData.message);
                        });
                }
            }
            , hide: {
                effect: 'slide'
                , direction: 'left'
            }
            , close: function () {
                $dialogDiv.remove();
            }
        });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnRenderSentMessages
     * @private
     * @summary      renders user's sent messages window
     * @description  renders user's sent messages window
     * @param  {Object}  elem    Element reference
     * @param  {Object}  optsIn  Options reference
     */

    let _fnRenderSentMessages = function (elem, sentMessagesAjaxURL, sentMessagesAjaxData, deleteMessageAjaxURL) {
        let $me = _fnGetMe(elem);

        // function to render deleted messages inside a modal
        function _renderSentMessagesDialog(sentMessagesArr) {
            // generate list of deleted messages
            let $dialogDivContent = $('<div class="d-flex flex-column justify-content-center">'
                + '<div class="col-12 d-flex flex-row align-items-center">'
                + 'Recipients’ names in <strong class="ml-1">bold</strong>, have not yet read your message'
                + '</div>'
                + '</div>');

            if (sentMessagesArr && Array.isArray(sentMessagesArr) && sentMessagesArr.length > 0) {
                $.each(sentMessagesArr, function (key, value) {
                    let $msg = $('<div class="col-12 mt-3 rounded text-left p-1 mba-background-color-message">'
                        + '<div class="col-12 d-flex flex-row align-items-center">'
                        + '<div class=" mr-1">' + value.createdStr + '</div>' // date
                        + '<strong class=" mr-1">' + value.subject + '</strong>' // subject
                        + '</div>'
                        + '<div class="col-12 d-flex flex-row align-items-center max-height-100-ellipsis white-space-pre">'
                        + value.body // body
                        + '</div>'
                        + '</div>');

                    // generate list of who has and hasn't read the message
                    let recipientsObj;
                    try {
                        recipientsObj = JSON.parse(value.recipientsJSON);
                    } catch (e) {
                        return false; // break the loop
                    }

                    // parent container for list of names
                    let $recipientsList = $('<div class="col-12 d-flex flex-wrap flex-row align-items-center max-height-100-ellipsis"></div>');

                    $.each(recipientsObj, function (key2, value2) {
                        $recipientsList.append(
                            ((value2.hasRead)
                                ?
                                $('<span  class="mr-1">' + value2.name + (((recipientsObj.length - 1) != key2) ? ',' : '') + '</span>')
                                :
                                $('<strong class="mr-1">' + value2.name + (((recipientsObj.length - 1) != key2) ? ',' : '') + '</strong>')
                            )
                        );
                    });

                    $msg.append($recipientsList);

                    $dialogDivContent.append($msg);

                });

                return $dialogDivContent;
            }

            return $('<div>No Mesages</div>');
        }

        // render dialog
        let $dialogDiv = $('<div></div>');

        $dialogDiv.html('<div class="d-flex justify-content-center"><i class="fa fa-spinner fa-pulse fa-fw fa-2x"></i></div>').dialog({
            width: 500
            , height: 500
            , title: "Sent Messages"
            ,create: function () {
                _fnApplyParentPortalDialogStyles($dialogDiv);
            }
            ,open: function () {
                _fnApplyParentPortalDialogStyles($dialogDiv);
            }
            ,show: {
                effect: 'slide',
                complete: function () {
                    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(sentMessagesAjaxURL, sentMessagesAjaxData, null)
                        .then(responseData => {
                            $dialogDiv.html('')
                                .append(_renderSentMessagesDialog(responseData.rawData.data))
                                .addClass('mba-announcements-carousel-fade');
                        })
                        .catch(responseData => {
                            alert(responseData.rawData.message);
                        });
                }
            }
            , hide: {
                effect: 'slide'
                , direction: 'left'
            }
            , close: function () {
                $dialogDiv.remove();
            }
        });
    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /**
     * @function     _fnApplyParentPortalDialogStyles
     * @private
     * @summary      Visual theme for Parent Portal dialogs
     * @description  Adjust borders, background, shadow, titlebar, etc.
     * @param  {Object}  $dialogDiv  jQuery ref div (ui-dialog-content)
     */
    let _fnApplyParentPortalDialogStyles = function ($dialogDiv) {
        
        let $shell = $dialogDiv.closest('.ui-dialog');

        // card 
        $shell.css({
            borderRadius: '0.9rem',
            overflow: 'hidden',
            border: 'none',
            boxShadow: '0 18px 45px rgba(15,23,42,.25)',
            background: 'linear-gradient(135deg,#f5f7ff,#ffffff)'
        });

        // titlebar
        let $titlebar = $shell.find('.ui-dialog-titlebar');
        $titlebar.css({
            background: 'linear-gradient(135deg,#0d6efd,#4facfe)',
            border: 'none',
            color: '#f9fafb',
            padding: '0.55rem 1.1rem'
        });

        $titlebar.find('.ui-dialog-title').css({
            fontWeight: '600',
            fontSize: '0.95rem',
            letterSpacing: '.02em'
        });

        $titlebar.find('.ui-dialog-titlebar-close').css({
            border: 'none',
            background: 'transparent'
        });

        $shell.find('.' + CONST_CSS_CLASS_DIALOG_MINIMIZE_BTN + ', .' + CONST_CSS_CLASS_DIALOG_MAXIMIZE_BTN).css({
            border: 'none',
            background: 'transparent'
        });

        $shell.find('.ui-dialog-content').css({
            background: 'transparent',
            padding: '1.25rem 1.5rem'
        });
        
        $shell.find('.mba-messages-widget-hippa-compliance-notice').css({
            fontSize: '.75rem',
            background: 'rgba(248,250,252,.95)',
            borderRadius: '999px',
            padding: '0.35rem 0.9rem',
            marginBottom: '0.75rem',
            border: '1px solid rgba(148,163,184,.35)',
            color: '#0f172a'
        });
    }


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

        /* Store reference to elem */

        dataObj.me = $me;

        /* Merge default options and options passed in. */

        let opts = $.extend({}, CONST_DEFAULT_OPTIONS, optsIn);

        // create ID for dialog
        opts.dialogDivID = $me.attr('id') + '_dialog_div';

        dataObj.opts = opts;

        $($me).data(CONST_DATA_NAME, dataObj); /* Save our data object.  This will be used for option calls */
        $($me).addClass(CONTENT_WRAPPER_CSS_CLASS); /* Give wrapper class to element */

        //alert('hi!!');
        //eval('debugger');

        $.spedmonWebUI['cbRenderMsgModalFn_' + dataObj.opts.messageID] = function () {

            /* If the user clicks on a notification take them to to service records manage*/

            if (typeof (dataObj.opts.respPromptOptions) != 'undefined' && (dataObj.opts.respPromptOptions & 2)) {

                /* Build url for  */

                let msrUrl = $('#viewsvcrecslink').attr('href')
                    + '&match_rmts_id=' + JSON.parse(dataObj.opts.respPromptOptionsJSON).referencedentityid
                    + '&matchrmtsdate=' + JSON.parse(dataObj.opts.respPromptOptionsJSON).matchrmtsdate
                    + '&amd=uidbssub';

                /* Calculate new windows width and height */

                let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(95);
                let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(95);
                let whw = 'height=' + vh + ',width=' + vw;

                /* Open window and capture reference to it so we can workaround browser permission issues?*/
                /* https://stackoverflow.com/a/68712708 */

                var www = window.open(msrUrl, '_blank', whw);

                var msg_rendered_inside = false;

                //eval('debugger');

                /* Browser permission workaround?? */

                var try_i = setInterval(function () {

                    try {

                        var otherwindow_jQ$ = www.$;  // this line fails, sometimes, we have to keep polling.
                        // if the browser is busy doing something bandwidth and memory intensive,
                        // it could take longer than 2200 ms

                        clearInterval(try_i);

                        // just in case -- we don't want to accidentally run this more than once, even if it takes more than 800ms
                        if (!(msg_rendered_inside))
                            otherwindow_jQ$(
                                function () {
                                    www.MBA.messagesWidget.fnRenderMessages(null, { opts: dataObj.opts });

                                    msg_rendered_inside = true;

                                    //otherwindow_jQ$('.mba-messages-widget-message-container-class.ui-dialog-content i.fa-file-upload').click(
                                    //   function() { www.close(); }
                                    //);
                                    // no longer doing this; we want the filebox in the new window, not the old one
                                }
                            );

                    } catch (e) { }
                }, 2200);
                //_fnRenderMessages($me, dataObj);
                return;
            } /* Service records manage */

            _fnRenderMessages($me, dataObj);

        };

        $($me).on("click", $.spedmonWebUI['cbRenderMsgModalFn_' + dataObj.opts.messageID]);


    };

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    return {
        fnCreate: _fnCreate
        , fnRenderDeletedMessages: _fnRenderDeletedMessages
        , fnRenderSentMessages: _fnRenderSentMessages
        , fnRenderMessages: _fnRenderMessages
    };

})(jQuery);

/*#############################################################################################################################################################*/

/**
 * @namespace    jQuery.fn
 * @memberof     jQuery
 * @summary      Widget plugin
 * @description  Widget plugin
 * @requires     jQuery
 */

; (function ($) {

    'use strict';

    /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

    /* Tie into jQuery namespace */

    $.fn.messagesWidget = function (methodOrOptions, optionsOrValue) {

        /* These are the supported methods and properties that can be accessed from outside after an instance is created */

        let _methods = {
        };

        let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */

        /* Method is create */

        if (typeof methodOrOptions === 'object' || !methodOrOptions) {
            /* Tie into return chain so this can be chained with other methods */
            return this.each(function () {
                let elem = this; /* this in this scope is a reference to one of elements in the set */
                return MBA.parentPortalMessagesWidget.fnCreate(elem, methodOrOptions);
            });
        }


    }; /* messagesWidget */

    $.fn.renderDeletedMessages = function (messagesViewAjaxURL, deletedMessagesAjaxData, deleteMessageAjaxURL) {

        /* These are the supported methods and properties that can be accessed from outside after an instance is created */

        let _methods = {
        };

        let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */


        /* Tie into return chain so this can be chained with other methods */
        return this.each(function () {
            let elem = this; /* this in this scope is a reference to one of elements in the set */
            return $(elem).on("click", function () {
                MBA.parentPortalMessagesWidget.fnRenderDeletedMessages(elem, messagesViewAjaxURL, deletedMessagesAjaxData, deleteMessageAjaxURL);
            });
        });


    }; /* renderDeletedMessages */

    $.fn.renderSentMessages = function (sentMessagesAjaxURL, sentMessagesAjaxData, deleteMessageAjaxURL) {

        /* These are the supported methods and properties that can be accessed from outside after an instance is created */

        let _methods = {
        };

        let numOf = $(this).length; /* this in this scope is a reference to an array of matching elements */


        /* Tie into return chain so this can be chained with other methods */
        return this.each(function () {
            let elem = this; /* this in this scope is a reference to one of elements in the set */
            return $(elem).on("click", function () {
                MBA.parentPortalMessagesWidget.fnRenderSentMessages(elem, sentMessagesAjaxURL, sentMessagesAjaxData, deleteMessageAjaxURL);
            });
        });


    }; /* renderSentMessages */

})(jQuery);
