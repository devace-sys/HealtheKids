;(function ($) {

    'use strict';

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    const MESSAGE_NAME_START           = 100; /* This value has to be set here */
    const CSS_CLASS_MBA_PRIVACY_SCREEN = 'mba-privacy-screen';
    const SELECTOR_MBA_PRIVACY_SCREEN  = 'body';

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let workerSettingsObj = {};

    workerSettingsObj.USER_IS_CONSIDERED_IDLE_AFTER_N_SECONDS          = null;
    workerSettingsObj.USER_SESSION_EXPIRES_AFTER_N_SECONDS_IDLE_TIME   = null;
    workerSettingsObj.MESSAGE_NAME_EXECUTE_CUSTOM_TASKS                = null;
    workerSettingsObj.CHECK_FOR_SESSION_EXPIRE_INTERVAL                = null;
    workerSettingsObj.MESSAGE_NAME_PRIVACY_SCREEN_RAISE                = null;
    workerSettingsObj.MESSAGE_NAME_PRIVACY_SCREEN_LOWER                = null;
    workerSettingsObj.MESSAGE_NAME_REQUEST_KEEP_ALIVE                  = null;
    workerSettingsObj.MESSAGE_NAME_REQUEST_TIME_OUT_CHECK              = null;
    workerSettingsObj.MESSAGE_NAME_IDLE_CTR_RESET                      = null;
    

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let sessionHelperWorker = null;

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnSendSessionKeepAliveRequest = function (msgObj) {
        
        /* Create payload obj.  Have to keep it as generic as possible on this side (just sending one parm) to allow for expansion as older 
         * versions of this may be running when we push updates. */

        let reqObj = {};
        reqObj.msgName = msgObj.msgName;
        reqObj.msgDataJSON = '{}';

        /* General data will be received by server as JSON string */

        let msgDataObj = {};
        msgDataObj.msgData = {};
        msgDataObj.msgData.idleCtr           = msgObj.msgDataObj.idleCtr;
        msgDataObj.msgData.userIsIdle        = msgObj.msgDataObj.userIsIdle;
        msgDataObj.msgData.requestedResource = self.MBA.SessionHelperCommon.requestedResource;
        reqObj.msgDataJSON                   = JSON.stringify(msgDataObj);

        /* Convert overall request to JSON */

        var reqJSON = JSON.stringify(reqObj);

        /* Send the request*/

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(self.MBA.SessionHelperCommon.urlRequestKeepAlive, reqJSON, self.MBA.SessionHelperCommon.sessionExpiredUrl);
        return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnOkToUsePrivacyScreen = function () {
        if (self.MBA.SessionHelperCommon.useSessionHelperPrivacyScreen == false) return false;
        if (self.MBA.SessionHelperCommon.renderContentOnly == true)              return false; /* This page is in an iframe or dialog */
        return true;
    }

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnRaisePrivacyScreen = function () {
      if (!fnOkToUsePrivacyScreen()) return;
      $(SELECTOR_MBA_PRIVACY_SCREEN).addClass(CSS_CLASS_MBA_PRIVACY_SCREEN);
      return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnLowerPrivacyScreen = function () {
      if (!fnOkToUsePrivacyScreen()) return;
      $(SELECTOR_MBA_PRIVACY_SCREEN).removeClass(CSS_CLASS_MBA_PRIVACY_SCREEN);
      return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnPostMessage = function (msgName, msgDataObj) {
        let msgObj = {};
        msgObj.msgName = msgName;
        msgObj.msgDataObj = msgDataObj;
        sessionHelperWorker.postMessage(msgObj);
        return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnPostMessageRestartIdleTimer = function () {
        fnPostMessage(workerSettingsObj.MESSAGE_NAME_IDLE_CTR_RESET, {});
        return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnAddEventListeners = function (win, what) {
        try {
            win.addEventListener('touchstart',   (e) => { fnPostMessageRestartIdleTimer(); });
            win.addEventListener('mousemove',    (e) => { fnPostMessageRestartIdleTimer(); });
            win.addEventListener('mousedown',    (e) => { fnPostMessageRestartIdleTimer(); });
            win.addEventListener('click',        (e) => { fnPostMessageRestartIdleTimer(); });
            win.addEventListener('keydown',      (e) => { fnPostMessageRestartIdleTimer(); });
            win.addEventListener('beforeunload', (e) => { return MBA.SessionHelperCommon.fnExecuteBeforePageUnload(e); });
        }
        catch {
            console.warn('Could not add listeners for session helper', what);
        }
        return;
    }

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnInit = function () {

        workerSettingsObj.USER_IS_CONSIDERED_IDLE_AFTER_N_SECONDS             = self.MBA.SessionHelperCommon.userIsConsideredIdleAfterNSeconds;
        workerSettingsObj.USER_SESSION_EXPIRES_AFTER_N_SECONDS_IDLE_TIME      = self.MBA.SessionHelperCommon.maxIdleSessionSeconds;
        workerSettingsObj.CHECK_FOR_SESSION_EXPIRE_INTERVAL                   = (self.MBA.SessionHelperCommon.maxIdleSessionSeconds + 60);

        workerSettingsObj.MESSAGE_NAME_EXECUTE_CUSTOM_TASKS              = 999;
        workerSettingsObj.MESSAGE_NAME_PRIVACY_SCREEN_RAISE              = 600;
        workerSettingsObj.MESSAGE_NAME_PRIVACY_SCREEN_LOWER              = 500;
        workerSettingsObj.MESSAGE_NAME_REQUEST_KEEP_ALIVE                = 400;
        workerSettingsObj.MESSAGE_NAME_REQUEST_TIME_OUT_CHECK            = 300;
        workerSettingsObj.MESSAGE_NAME_IDLE_CTR_RESET                    = 200;
                
        let workerUrl = self.MBA.SessionHelperCommon.sessionHelperWorkerUrl;

        sessionHelperWorker = new Worker(workerUrl);

        sessionHelperWorker.addEventListener('message', (messageObj) => {
            let msgObj = messageObj.data;

            if (msgObj.msgName == workerSettingsObj.MESSAGE_NAME_REQUEST_KEEP_ALIVE) {
                fnSendSessionKeepAliveRequest(msgObj);
                return;
            }

            else if (msgObj.msgName == workerSettingsObj.MESSAGE_NAME_PRIVACY_SCREEN_RAISE) {
                fnRaisePrivacyScreen();
                return;
            }

            else if (msgObj.msgName == workerSettingsObj.MESSAGE_NAME_PRIVACY_SCREEN_LOWER) {
                fnLowerPrivacyScreen();
                return;
            }

            else if (msgObj.msgName == workerSettingsObj.MESSAGE_NAME_REQUEST_TIME_OUT_CHECK) {
                fnSendSessionKeepAliveRequest(msgObj);
                return;
            }
            else if (msgObj.msgName == workerSettingsObj.MESSAGE_NAME_EXECUTE_CUSTOM_TASKS)
            {
              MBA.SessionHelperCommon.fnExecuteCustomTasks();
            }
            else { return; }
        });

        fnAddEventListeners(self,'page');

        let iFrames = document.querySelectorAll('iframe');

        iFrames.forEach((iFrame) => {            
            fnAddEventListeners(iFrame.contentWindow, 'iframe');
            iFrame.addEventListener('load', (e) => { fnAddEventListeners(iFrame.contentWindow,'iframe'); });
        });

        fnPostMessage(MESSAGE_NAME_START, workerSettingsObj);

        return;
    }
   
    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    /* Start up when everything is loaded */

    $(window).load(function () {
        fnInit();
    });
        
})(jQuery);