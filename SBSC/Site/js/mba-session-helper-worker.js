(function () {

    'use strict';

    const MESSAGE_NAME_START = 100; /* This value has to be set here */

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let workerSettingsObj = {};

    workerSettingsObj.USER_IS_CONSIDERED_IDLE_AFTER_N_SECONDS        = null;
    workerSettingsObj.USER_SESSION_EXPIRES_AFTER_N_SECONDS_IDLE_TIME = null;
    workerSettingsObj.CHECK_FOR_SESSION_EXPIRE_INTERVAL              = null;
    workerSettingsObj.MESSAGE_NAME_EXECUTE_CUSTOM_TASKS              = null;
    workerSettingsObj.MESSAGE_NAME_PRIVACY_SCREEN_RAISE              = null;
    workerSettingsObj.MESSAGE_NAME_PRIVACY_SCREEN_LOWER              = null;
    workerSettingsObj.MESSAGE_NAME_REQUEST_KEEP_ALIVE                = null;
    workerSettingsObj.MESSAGE_NAME_REQUEST_TIME_OUT_CHECK            = null;
    workerSettingsObj.MESSAGE_NAME_IDLE_CTR_RESET                    = null;

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let masterTimer           = null;
    let userIsIdle            = false;
    let idleCtr               = 0;
    let keepAliveCheckCtr     = 0;
    let sessionExpireCheckCtr = 0;
    
    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnPostMessage = function (msgName) {
        let msgObj            = {};
        let msgDataObj        = {};
        msgDataObj.idleCtr    = idleCtr;
        msgDataObj.userIsIdle = userIsIdle;
        msgObj.msgName        = msgName;
        msgObj.msgDataObj     = msgDataObj;
        postMessage(msgObj);
        return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnUpdateIdleCtr = function () {
        idleCtr++;

        /* If NO activity has been detected the then consider the user idle and request the privacy screen be raised */

        if (idleCtr >= workerSettingsObj.USER_IS_CONSIDERED_IDLE_AFTER_N_SECONDS) {
          userIsIdle = true
          fnPostMessage(workerSettingsObj.MESSAGE_NAME_PRIVACY_SCREEN_RAISE);
        }

        /* If activity has been detected then consider the user active and request the privacy screen be lowered */

        else
        { 
          userIsIdle = false;
          fnPostMessage(workerSettingsObj.MESSAGE_NAME_PRIVACY_SCREEN_LOWER);
        }
        return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnResetIdleCtr = function () {

        /* This is called in response to user activity. */

        fnPostMessage(workerSettingsObj.MESSAGE_NAME_PRIVACY_SCREEN_LOWER);                        /* Request that privacy screen be lowered */
        if (userIsIdle == true) fnPostMessage(workerSettingsObj.MESSAGE_NAME_REQUEST_KEEP_ALIVE);  /* If user has been idle we want to immediately request a keep alive */
        idleCtr    = 0;                                                                            /* Reset idle counter */
        userIsIdle = false;                                                                        /* User is now considered active*/
        return;
    }

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnUpdateKeepAliveCheckCtr = function () {

        keepAliveCheckCtr++; /* Advance keep alive check counter */

        /* If its time to peform a keep alive.  We do this every 60 seconds  */

        if (keepAliveCheckCtr >= 60) {
            keepAliveCheckCtr = 0;                  /* Restart the keep alive check counter */
            if (userIsIdle == false) {
                fnPostMessage(workerSettingsObj.MESSAGE_NAME_REQUEST_KEEP_ALIVE);    /* If the user is considered active then request a keep alive*/
            } 
        };
        return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnUpdateSessionExpireCheckCtr = function () {
 
        sessionExpireCheckCtr++; /* Advance session expire check counter */        

        /* A little bit of time after the expected session timeout/expired duration we want to see if the session has indeed expired */

        if (sessionExpireCheckCtr >= workerSettingsObj.CHECK_FOR_SESSION_EXPIRE_INTERVAL) {
            sessionExpireCheckCtr = 0;                                                                       /* Restart the session expire check counter*/
            if (userIsIdle == true) fnPostMessage(workerSettingsObj.MESSAGE_NAME_REQUEST_TIME_OUT_CHECK);    /* If the user is considered idle then request a timeout check */
        };
        return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnUpdateCustomCtr = function () {
        return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnUpdateCtrs = function () {
        fnUpdateIdleCtr();
        fnUpdateKeepAliveCheckCtr();
        fnUpdateSessionExpireCheckCtr();
        return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnExecuteMasterTimerTasks = function () {
        fnUpdateCtrs();
        fnPostMessage(workerSettingsObj.MESSAGE_NAME_EXECUTE_CUSTOM_TASKS);
        return;
    }

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    let fnStart = function (workerSessingsObjIn) {
        workerSettingsObj = workerSessingsObjIn;                                /* Get settings shared between parent script and worker */
        fnPostMessage(workerSettingsObj.MESSAGE_NAME_PRIVACY_SCREEN_LOWER);     /* Request lower privacy screen */    
        masterTimer = setInterval(fnExecuteMasterTimerTasks, 1000);             /* Start our master timer.  Every second it will update these counters and check for actions to take. */
        return;
    };

    /*------------------------------------------------------------------------------------------------------------------------------------------*/

    onmessage = (messageObj) => {
        let msgObj = messageObj.data;

        if (msgObj.msgName == MESSAGE_NAME_START) {
            fnStart(msgObj.msgDataObj);
            return;
        }
        else if (msgObj.msgName == workerSettingsObj.MESSAGE_NAME_IDLE_CTR_RESET) {
            fnResetIdleCtr();
            return;
        }
        else {
            return;
        }
        return;
    };
    /*------------------------------------------------------------------------------------------------------------------------------------------*/

})();