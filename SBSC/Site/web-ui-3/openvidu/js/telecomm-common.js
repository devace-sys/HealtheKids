/* Requires jquery, jqueryui, mba-util.js, mba-ajax.js, mba.responsize-dialog.js */

var MBA = (MBA || {});

MBA.telecomm = (function ($) {

'use strict';

/*#################################################################################################
  #
  #                                       Constants
  #
  #################################################################################################*/

const clsStreamElementContRespHeight = 'stream-element-container-resp-height';
const clsMultiStreamContTweaks = 'h-100 d-inline-flex flex-column justify-content-between m-0 p-0';
const clsMultiStreamSlotTweaks = 'h-100 col-3 d-inline-flex flex-column justify-content-between m-0 p-1';
const clsAlignStreamVidCtrls = 'd-flex justify-content-between align-items-center flex-wrap';
const galleryViewClass = "gallery-view";

const DATA_ATTR_FORM_REMOTE_UPDATE        = 'data-telecomm-remote-update';

/*#################################################################################################
  #
  #                                   Element IDs and Selectors
  #
  #################################################################################################*/

var systemStatusElementID;
var browserNotSupportedElementID;
var participantPublicationControlsElementID;
var participantStreamsElementID;
var sessionFilesElementID;
var roomIdElementId;
var roomPartUidElementId;
var roomPartPinElementId;

var systemStatusSelector;
var browserNotSupportedSelector;
var participantPublicationControlsSelector;
var participantStreamsSelector;
var participantStreamsContainerSelector;
var toggleParticipantsViewBtnSelector;
var whatIsMyPinBtnSelector;
var sendMeetingInvitesBtnSelector;
var appendSharedFilesSelector;
var sessionFilesSelector;
var roomIdSelector;
var roomPartUidSelector;
var roomPartPinSelector;

/*#################################################################################################
  #
  #                                  Server Specific URLs 
  #
  #################################################################################################*/

var baseLink;
var urlGetSharedFileHtmlList;
var urlSvcSaveFormWipData;
var urlSvcSignForm;
var urlGetFormSignaturesHtmlTable;
var urlBanUser;
var urlSendMeetingInvites;
var urlAppendFileShares;

/*#################################################################################################
  #
  #                                        OpenVIDU
  #
  #################################################################################################*/

var OV;
var localSession;
var localSessionData;
var localSessionToken;
var pubControls;
var currentPublisher = null;
var initHasBeenCalled = false;
var streamIDToParticipantSlotID = {}; // key value pairs where key is stream id and value is the uniqueue participant slot id

/*#################################################################################################
  #
  #                              Current State References and Flags
  #
  #################################################################################################*/

var currentPublisherPubVidState = false;
var currentPublisherPubAudState = false;
var currentPublisherIsScreensharing = false;
var currentPublisherMuteVideoBeforePublishing = !(currentPublisherPubVidState);
var currentParticipantsViewIsGallery = false;
var currentPublisherVideoStream = null;

/*#################################################################################################
  #
  #                              Various Waiting Room Flags 
  #
  #################################################################################################*/

var facilitatorRequiredInRoom   = false; 
var participantIsFacilitator    = false;
var facilitatorIsPresent        = false;

/*#################################################################################################
  #
  #                                         System Functions
  #
  #################################################################################################*/

/***************************************************************************
 * setSystemStatusContent */
/**
 * Updates overall system status content
 * primary
 * info
 * success
 * warning
 * danger
 ***************************************************************************/

function setSystemStatusContent(systemStatusSelector, statusMessage, additionalInfo, messageClass) {

    if (!additionalInfo) additionalInfo = ''; else additionalInfo = '<sup>' + additionalInfo + '</sup>';
    if (!messageClass) messageClass = 'info';

    let statusMkup = '<div class="alert alert-' + messageClass + ' alert-dismissible fade show" role="alert">'
        + '<p>' + statusMessage + '</p>'
        + additionalInfo
        + '<button type="button" class="close" data-dismiss="alert" aria-label="Close">'
        + '<span aria-hidden="true">&times;</span>'
        + '</button>'
        + '</div>';

    $(systemStatusSelector).html(statusMkup);

}

/***************************************************************************
 * updateSystemStatus */
/**
 * Updates overall system status content
 * 
 * primary
 * info
 * success
 * warning
 * danger
 * 
 * Note: Keep this as the top function
 ***************************************************************************/

function updateSystemStatus(statusMessage, additionalInfo, messageClass) {
   
  return setSystemStatusContent(systemStatusSelector, statusMessage, additionalInfo, messageClass);
}

/***************************************************************************
 * setupFileShares */
/**
 * 
 * 
 ***************************************************************************/

function setupFileShares() {

  $(sessionFilesSelector).children('ul.telecomm-meeting-files').children('li.telecomm-meeting-file').each(function (liIdx, liElem) {
    let aFileToShow = $(liElem).children('span.telecomm-meeting-file-name').first().children('a.telecomm-meeting-file-view').first();
    let butShareFile = $(liElem).children('button.telecomm-meeting-file-share').first();
    let fileToShowID = $(aFileToShow).attr('id');

    $(aFileToShow).on('click', function (viewFileClickEvent) {
      viewFileClickEvent.preventDefault();
      doViewFile(fileToShowID);
    });

    $(butShareFile).on('click', function (butShareFileClickEvent) {
      sendSignalShowFile(fileToShowID);
    });
  });
}

/***************************************************************************
 * scrollParticipantsDiv */
/**
 * callback function for arrows to scroll the video container by an amount in pixels
 * 
 ***************************************************************************/

function scrollParticipantsDiv (amount) {
    var position = $(participantStreamsSelector).scrollLeft(); // get current scroll position
    $(participantStreamsSelector).animate({
        scrollLeft: position + amount
    }, 500);
}

/*#################################################################################################
  #
  #                    Local User/Publisher Permissions and Capabilities
  #
  #################################################################################################*/

/**************************************************************************
 * canRequestMuteOfParticipant */
/**
 * Note: You cannot disconnect yourself
 * 
 ***************************************************************************/

function canRequestMuteOfParticipant(localStream) {
    return ((localSession.capabilities.forceUnpublish === true) && (localStream === false));
}

/**************************************************************************
 * canShareScreen */
/**
 * If the users device is capable of screen sharing 
 ***************************************************************************/

function canShareScreen() {

  if (localSession.capabilities.forceUnpublish === true) {
    if (OV.checkScreenSharingCapabilities() === true) {
	  return true;
    }
  }
  return false;
}

/**************************************************************************
 * canShareFile */
/**
 *
 * 
 ***************************************************************************/

function canShareFile() {
    return (localSession.capabilities.forceUnpublish === true);
}

/**************************************************************************
 * canRequestDisconnectOfParticipant */
/**
 * Note: You cannot disconnect yourself
 * 
 ***************************************************************************/

function canRequestDisconnectOfParticipant(localStream) {
    return ((localSession.capabilities.forceDisconnect === true) && (localStream === false));
}


/**************************************************************************
 * canRemoteUpdateForm */
/**
 * Can the user send or process a signal for this given formID
 ***************************************************************************/

function canRemoteUpdateForm(formID) {    
    let v = $('#' + formID).attr(DATA_ATTR_FORM_REMOTE_UPDATE);
    if (!v) return false;
    if (v === '2') return true;
    return false;
}

/**************************************************************************
 * canSaveFormWipData */
/**
 * We want to save wip data if we are just saving or we intend to share
 ***************************************************************************/

function canSaveFormWipData (formID) {
    let v = $('#' + formID).attr(DATA_ATTR_FORM_REMOTE_UPDATE);
    if (!v) return false;
    if ((v == '1') || (v == '2')) return true;
    return false;
}

/*#################################################################################################
  #
  #                    Helper Functions and Handlers For Streams
  #
  #################################################################################################*/

/***************************************************************************
 * warnUserAboutCamOrMicAvailability */
/**
 * Warns user if cam or mic or both are not available
 * 
 * srouce: https://docs.openvidu.io/en/2.11.0/advanced-features/switch-camera/
 ***************************************************************************/

function warnUserAboutCamOrMicAvailability() {

    OV.getDevices().then(devices => {
        var videoDevices = devices.filter(device => device.kind === 'videoinput');
        var audioDevices = devices.filter(device => device.kind === 'audioinput');

        // if both cam and mic are unavailable
        if ((!videoDevices || videoDevices.length < 1) && (!audioDevices || audioDevices.length < 1)) {
            MBA.actionDialogs.alert("Warning", "No camera or microphone inputs were found or browser does not have permission to them! You will see and hear everyone, but they won't see or hear you.");
            return;
        }
        // if cam but no mic
        if ((videoDevices && videoDevices.length > 1) && (!audioDevices || audioDevices.length < 1)) {
            MBA.actionDialogs.alert("Warning", "No microphone inputs were found or browser does not have permission to them! You will see and hear everyone, and they will see but not hear you.");
            return;
        }
        // if mic but no cam
        if ((!videoDevices || videoDevices.length < 1) && (audioDevices && audioDevices.length > 1)) {
            MBA.actionDialogs.alert("Warning", "No camera inputs were found or browser does not have permission to them! You will see and hear everyone, and they will hear but not see you.");
            return;
        }
    });
}

/***************************************************************************
 * createAndInsertStreamContainerElements */
/**
 * Creates the stream container and controls for subscriptions and publications
 * Note: DO NOT PLACE ANY HANDLERS IN THIS FUNCTION
 ***************************************************************************/

function createAndInsertStreamContainerElements(streamID, typeOfVideo, localStream) {

    var scm = {};

    scm.participantSlotID = MBA.util.createNewUUID();
    streamIDToParticipantSlotID[streamID] = scm.participantSlotID; // this is so we can full screen a screenshare...refer to screenshare signal callback
    scm.streamContID = streamID + 'streamcontainer';
    scm.mediaElementContID = streamID + 'mediaelementcontainer';

    scm.audioMeterID = streamID + 'audiometer';
    scm.audioMutedID = streamID + 'audiomuted';
    scm.videoMutedID = streamID + 'videomuted';
    scm.fullScreenEnterID = streamID + 'fullscreenenter';
    scm.disconnectUserID = streamID + 'disconnectuser';
    scm.participantInfoID = streamID + 'participantinfo';

    scm.participantSlotSelector = '#' + scm.participantSlotID;
    scm.streamContSelector = '#' + scm.streamContID;
    scm.audioMeterSelector = '#' + scm.audioMeterID;
    scm.audioMutedSelector = '#' + scm.audioMutedID;
    scm.videoMutedSelector = '#' + scm.videoMutedID;
    scm.fullScreenEnterSelector = '#' + scm.fullScreenEnterID;
    scm.disconnectUserSelector = '#' + scm.disconnectUserID;
    scm.participantInfoSelector = '#' + scm.participantInfoID;

    scm.disconnectUserAllowed = canRequestDisconnectOfParticipant(localStream);
    scm.muteUserAllowed       = canRequestMuteOfParticipant(localStream);

    scm.isScreenShare = (typeOfVideo === 'SCREEN') ? true : false;
    scm.isCamera      = (typeOfVideo === 'CAMERA') ? true : false;
    scm.isOtherStream = (typeOfVideo === 'OTHER')  ? true : false;
    
    let disconnectUserMkup = '';

    if (scm.disconnectUserAllowed) {
        disconnectUserMkup = '<i id="' + scm.disconnectUserID + '" class="stream-control disconnect-user fas fa-user-slash"></i>';
    }

    let streamContMkup = ''
        + '<div id="' + scm.participantSlotID + '" class="participant-slot ' + clsMultiStreamSlotTweaks + '">'
        + '<div id="' + scm.streamContID + '" class="stream-container container-fluid col-12 ' + clsMultiStreamContTweaks + '">'
        + '<div class="row">'
        + '<div id="' + scm.mediaElementContID + '" class="stream-element-container col-12 ' + clsStreamElementContRespHeight + '">' /* OpenVidu manages the video element inside me*/
        + '<span id="' + scm.participantInfoID + '" class="stream-participant-info"></span>'
        + '<meter id="' + scm.audioMeterID + '" class="stream-indicator current-audio-level" min="-100" max="0" low="-90" optimum="-50" high="-10" value="-100"></meter>'
        + '</div>'
        + '</div>'
        + '<div class="row">'
        + '<div class="video-controls col-12 ' + clsAlignStreamVidCtrls + '">'
        + '<i id="' + scm.audioMutedID + '" class="stream-indicator is-audio-muted fas fa-microphone"></i>'
        + '<i id="' + scm.videoMutedID + '" class="stream-indicator is-video-muted fas fa-video"></i>'
        + '<i id="' + scm.fullScreenEnterID + '" class="stream-control toggle-full-screen fas fa-expand"></i>'
        + disconnectUserMkup
        + '</div>'
        + '</div>'
        + '</div>'
        + '</div>';

    var scElems = $(streamContMkup);

    /* If not local then append otherwise prepend */

    if (localStream === false) {
        $(participantStreamsSelector).append(scElems);
    }
    else {
        $(participantStreamsSelector).prepend(scElems);
    }

    return scm;
}

/***************************************************************************
 * updateAudioVolumeMeter */
/**
 * event.value.newValue :  -100 (silence) and 0 (max volume)
 ***************************************************************************/

function updateAudioVolumeMeter(audioMeterSelector, event) {
  if (!audioMeterSelector) return;
  if (event.value.newValue === Number.NEGATIVE_INFINITY) return;
  $(audioMeterSelector).val(event.value.newValue);
}

/***************************************************************************
 * updateParticipantInfo */
/**
 * 
 ***************************************************************************/

function updateParticipantInfo(participantInfoSelector, partInfo) {
    $(participantInfoSelector).html(partInfo).attr("title", partInfo);
}

/***************************************************************************
 * updateAudioStateIndicator */
/**
 * 
 ***************************************************************************/

function updateAudioStateIndicator(audioMutedSelector, stream) {

    $(audioMutedSelector).removeClass('fa-microphone');
    $(audioMutedSelector).removeClass('fa-microphone-slash');

    if (stream.hasAudio === true) {
        if (stream.audioActive === true) {
            $(audioMutedSelector).addClass('fa-microphone');
        }
        else {
            $(audioMutedSelector).addClass('fa-microphone-slash');
        }
    }
    else {
        $(audioMutedSelector).addClass('fa-microphone-slash');
    }
}

/***************************************************************************
 * updateVideoStateIndicator */
/**
 * 
 ***************************************************************************/

function updateVideoStateIndicator(videoMutedSelector, stream) {

    $(videoMutedSelector).removeClass('fa-video');
    $(videoMutedSelector).removeClass('fa-video-slash');

    if (stream.hasVideo === true) {
        if (stream.videoActive === true) {
            $(videoMutedSelector).addClass('fa-video');
        }
        else {
            $(videoMutedSelector).addClass('fa-video-slash');
        }
    }
    else {
        $(videoMutedSelector).addClass('fa-video-slash');
    }
}
/*#################################################################################################
  #
  #                                Save/Restore WIP Data
  #
  #################################################################################################*/

function doCreateFormSaveRequestData (formID, formData, validateRec) {
    let validateRecStr = 'N';
    if (validateRec === true) validateRecStr = 'Y';
    return new Promise((resolve, reject) => {

        if (!formID)                     reject(new Error('Form ID required'));
        if (!canSaveFormWipData(formID)) reject(new Error('Cannot save wip data'));

        let requestDataObj = {};
        requestDataObj.rmid         = $(roomIdSelector).val();
        requestDataObj.rmpartuid    = $(roomPartUidSelector).val();
        requestDataObj.rmpartpin    = $(roomPartPinSelector).val();
        requestDataObj.formid       = formID;
        requestDataObj.validaterec  = validateRecStr;
        requestDataObj.formdata     = formData;
        let requestData = JSON.stringify(requestDataObj); 
        resolve(requestData);
    });
}

/***************************************************************************
 * doSaveFormWipData */
/**
 * 
 * 
 ***************************************************************************/

function doSaveFormWipData(formID) {

    return new Promise((resolve, reject) => {

        if (!formID)                     reject(new Error('Form ID required'));
        if (!canSaveFormWipData(formID)) resolve('NoSave');

        MBA.util.formToJSON(formID)
            .then(formData     => doCreateFormSaveRequestData(formID, formData, false))
            .then(requestData => MBA.ajax.callAsmxWebMethodBase(urlSvcSaveFormWipData, requestData))
            .then(responseData => resolve(responseData));
                                                                         
        });
}

/***************************************************************************
 * doSaveFormFinalData */
/**
 * 
 * 
 ***************************************************************************/

 var doSaveFormFinalData = function (formID, saveType, validateRec) {

    return new Promise((resolve, reject) => {

        if (!formID) reject(new Error('Form ID required'));
        let urlToPostTo = $('#' + formID).attr('action');
        if (!urlToPostTo) reject(new Error('Form action is required'));

        MBA.util.formToJSON(formID)
            .then(formData => doCreateFormSaveRequestData(formID, formData, validateRec))
            .then(requestData => MBA.ajax.callAsmxWebMethodBase(urlToPostTo, requestData))
            .then(responseData => resolve(responseData));
    });
}

/***************************************************************************
 * doRequestBanUser */
/**
 * 
 * 
 ***************************************************************************/

function doRequestBanUser (partUidToBan) {
   let requestDataObj = {};
   requestDataObj.rmid                 = $(roomIdSelector).val();
   requestDataObj.rmpartuid            = $(roomPartUidSelector).val();
   requestDataObj.rmpartpin            = $(roomPartPinSelector).val();
   requestDataObj.rmpartuidtoban       = partUidToBan;
   let requestData = JSON.stringify(requestDataObj);
   MBA.ajax.callAsmxWebMethodBase(urlBanUser, requestData).then(responsedata => {
   });
}

/***************************************************************************
 * doUpdateSharedFileContent */
/**
 * 
 * 
 ***************************************************************************/

 function doReplaceSharedFileContent(responseData) {
    updateSystemStatus('Meeting files have been updated.','', 'success');
    $(sessionFilesSelector).children('ul.telecomm-meeting-files').remove();
    $(sessionFilesSelector).append(responseData.rawData.content);
    setupFileShares();
}

/***************************************************************************
 * doGetAndReplaceSharedFileContent */
/**
 * 
 * 
 ***************************************************************************/

function doGetAndReplaceSharedFileContent () {
  
  let requestDataObj = {};
  requestDataObj.rmid      = $(roomIdSelector).val();
  requestDataObj.rmpartuid = $(roomPartUidSelector).val();
  requestDataObj.rmpartpin = $(roomPartPinSelector).val();  
  let requestData = JSON.stringify(requestDataObj); 

    MBA.ajax.callAsmxWebMethodBase(urlGetSharedFileHtmlList, requestData)
        .then(responseData => doReplaceSharedFileContent(responseData));        
  return;
}

/***************************************************************************
 * doSignForm */
/**
 * Use with server side control
 * 
 ***************************************************************************/

var _doSignForm = function (sigForFormID, sigControlID, sigClassName, ctrlInpUidID, ctrlInpPinID, ctrlButSignID, fieldNameSign, ctrlAdditionalDataID, shareDataWhenSigned, sigFormTitle)
{
                                       
  var _ctrlIDSigFormSel = '#' + sigControlID;
  
  var _ctrlSignSel   = '#' + ctrlButSignID;
  var _ctrlUidSel    = '#' + ctrlInpUidID;
  var _ctrlPinSel    = '#' + ctrlInpPinID;  	    
  var _rmpartuid     = $(_ctrlUidSel).val();
  var _rmpartpin     = $(_ctrlPinSel).val();
    
  var _fnResetFormOKToNo = function () {
    $(_ctrlSignSel).children('label').removeClass('active');	 	     	 
  };
  
  var _fnPopSignFormRequestData = function (formDataJSON) {
    return new Promise((resolve, reject) => {  
       
      $(_ctrlSignSel).hide();
        
      let requestDataObj = {};
      requestDataObj.rmid                 = $(roomIdSelector).val(); /* From global */
      requestDataObj.rmpartuid            = _rmpartuid
      requestDataObj.rmpartpin            = _rmpartpin
      requestDataObj.sigforformid         = sigForFormID;   
      requestDataObj.sigcontrolid         = sigControlID; /* Signature form */
      requestDataObj.sigclassname         = sigClassName;
	  requestDataObj.fieldnamesign        = fieldNameSign;
	  requestDataObj.ctrladditionaldataid = ctrlAdditionalDataID;
      requestDataObj.sigadditionaldata    = formDataJSON;
      requestDataObj.sharedatawhensigned  = shareDataWhenSigned;	  
      let requestData = JSON.stringify(requestDataObj); 
      resolve(requestData);
	});
  };

  var _fnProcSignFormResp = function(responseData) {
    if (responseData.status != 0) 
	{
	  _fnResetFormOKToNo();  
      MBA.actionDialogs.alert(sigFormTitle,responseData.message);	 
	}
	$(_ctrlSignSel).show();
  };

  MBA.util.formToJSON(ctrlAdditionalDataID).then(json => _fnPopSignFormRequestData(json))
                                           .then(requestData => MBA.ajax.callAsmxWebMethodBase(urlSvcSignForm, requestData))
                                           .then(responseData => _fnProcSignFormResp(responseData));
  
};

/***************************************************************************
 * doViewFormSignatures */
/**
 * Use with server side control
 * 
 ***************************************************************************/

var _doViewFormSignatures = function (sigClassName, sigFormTitle) {

  let _requestDataObj = {};
  _requestDataObj.rmid      = $(roomIdSelector).val();
  _requestDataObj.rmpartuid = $(roomPartUidSelector).val();
  _requestDataObj.rmpartpin = $(roomPartPinSelector).val();
  _requestDataObj.signatureclassname = sigClassName;

  let _requestData = JSON.stringify(_requestDataObj); 

  
  var _fnViewFormSignaturesProcessResponseData = function (responseData) {
    let _content = '';

    if (responseData.status != 0) {
      _content = responseData.message;
    }
    else {
      _content = responseData.rawData.content;
    }
    MBA.actionDialogs.openViewHtmlContent(sigFormTitle, _content);
  };

  MBA.ajax.callAsmxWebMethodBase(urlGetFormSignaturesHtmlTable, _requestData).then(responseData => _fnViewFormSignaturesProcessResponseData(responseData));

};

/*#################################################################################################
  #
  #                                   Send Signals
  #
  #################################################################################################*/

/**************************************************************************
 * createSignalObjBase */
/**
 * 
 * 
 ***************************************************************************/

function createSignalObjBase(sigData, sigTo, sigType) {
    let signalObj = {};
    signalObj.data = sigData;
    signalObj.to = sigTo;
    signalObj.type = sigType;
    return signalObj;
}

/**************************************************************************
 * createSignalObjForOneParticipant */
/**
 * 
 * 
 ***************************************************************************/

function createSignalObjForOneParticipant(sigData, partConn, sigType) {
    let arrToConn = [];
    arrToConn.push(partConn);
    return createSignalObjBase(sigData, arrToConn, sigType);
}

/**************************************************************************
 * createSignalObjForAllParticipants */
/**
 * 
 * 
 ***************************************************************************/

function createSignalObjForAllParticipants(sigData, sigType) {
    let arrToConn = [];
    return createSignalObjBase(sigData, arrToConn, sigType);
}

/**************************************************************************
 * createSignalObjForAllParticipantsExceptSender */
/**
 * 
 * 
 ***************************************************************************/

function createSignalObjForAllParticipantsExceptSender (sigData, sigType) {

    let arrToConn = [];
    
    localSession.streamManagers.forEach(streamManager => {
        if (streamManager.stream.connection.connectionId != localSession.connection.connectionId)
           arrToConn.push(streamManager.stream.connection);
    });
    return createSignalObjBase(sigData, arrToConn, sigType);
}

/***************************************************************************
 * sendSignalBase */
/**
 * Sends signalObj via OVs signal plane
 ***************************************************************************/

function sendSignalBase(signalObj) {
    if (localSession) {
        localSession.signal(signalObj).then(() => {
            /* TODO: Add optional callback */
        }).catch(sigError => {
            updateSystemStatus('Error sending signal', sigError.message, 'warning');
        });
    }
}

/***************************************************************************
 * sendSignalUpdateFormWithNewValues */
/**
 * 
 * 
 ***************************************************************************/

function sendSignalUpdateFormWithNewValues(formID) {

    if (!canRemoteUpdateForm(formID)) return;

    MBA.util.formToObj(formID).then((formObj) => {
        var sigDataObj = {};
        sigDataObj.formID = formID;
        sigDataObj.formNameValues = formObj;
        let sigDataStr = JSON.stringify(sigDataObj);
        let sigObj = createSignalObjForAllParticipantsExceptSender(sigDataStr, 'update_form_with_new_values');
        sendSignalBase(sigObj);
    }).catch(sigCreateIssue => {
    });  
}

/***************************************************************************
 * sendSignalHideFile */
/**
 * 
 * 
 ***************************************************************************/

function sendSignalHideFile(fileID) {
    if (canShareFile() === false) return;
    let sigObj = createSignalObjForAllParticipants(fileID, 'hide_file');
    return sendSignalBase(sigObj);
}

/***************************************************************************
 * sendSignalShowFile */
/**
 * 
 * 
 ***************************************************************************/

function sendSignalShowFile (fileID) {
    if (canShareFile() === false) return;
    let sigObj = createSignalObjForAllParticipants(fileID, 'show_file');
    return sendSignalBase(sigObj);
}

/***************************************************************************
 * sendSignalMuteBase */
/**
 * 
 * 
 ***************************************************************************/

function sendSignalMuteBase(subToMute, muteSignal, muteRequestReason) {

    if (!muteRequestReason) muteRequestReason = "";
    let sigObj = createSignalObjForOneParticipant(muteRequestReason, subToMute.stream.connection, muteSignal);
    sendSignalBase(sigObj);
}

/***************************************************************************
 * sendSignalMuteUserAudio */
/**
 * 
 * 
 ***************************************************************************/

function sendSignalMuteUserAudio(subToMute) {
    return sendSignalMuteBase(subToMute, 'mute_audio', '');
}

/***************************************************************************
 * sendSignalMuteUserVideo */
/**
 * 
 * 
 ***************************************************************************/

function sendSignalMuteUserVideo(subToMute) {
    return sendSignalMuteBase(subToMute, 'mute_video', '');
    }

/***************************************************************************
 * sendSignalBanUser */
/**
 * 
 * 
 ***************************************************************************/

function sendSignalBanUser(subToBan) {
    let sigDataObj = {};
    sigDataObj.actingParticipantEmail = $(roomPartUidSelector).val(); // uid of acting participant
    sigDataObj.actingParticipantPin = $(roomPartPinSelector).val();   // pin of acting participant

    let sigData = JSON.stringify(sigDataObj);
    let sigObj = createSignalObjForOneParticipant(sigData, subToBan, 'ban_user');

    return sendSignalBase(sigObj);
}

/***************************************************************************
 * sendSignalScreenshareStarted */
/**
 * 
 * 
 ***************************************************************************/

function sendSignalScreenshareStarted(connectionToScreenshare) {
    let sigObj = createSignalObjForAllParticipantsExceptSender(connectionToScreenshare, 'participant_started_screenshare');
    sendSignalBase(sigObj);
}

/***************************************************************************
 * sendSignalScreenshareEnded */
/**
 * 
 * 
 ***************************************************************************/

function sendSignalScreenshareEnded(connectionToScreenshare) {
    let sigObj = createSignalObjForAllParticipantsExceptSender(connectionToScreenshare, 'participant_ended_screenshare');
    sendSignalBase(sigObj);
}

/***************************************************************************
 * sendSignalMutePermissionDenied */
/**
 * 
 * 
 ***************************************************************************/

function sendSignalMutePermissionDenied(facilitatorConnObj, audOrVidStr) {
    let sigDataObj = {};
    sigDataObj.receiverName = localSession.connection.data; /* Connection data (participants name) of user denying request */
    sigDataObj.audOrVid = audOrVidStr;

    let sigData = JSON.stringify(sigDataObj);
    let sigObj = createSignalObjForOneParticipant(sigData, facilitatorConnObj, 'mute_permission_denied');

    return sendSignalBase(sigObj);
}

/*#################################################################################################
  #
  #                      Common Handlers for User Initiated Events
  #
  #################################################################################################*/

/***************************************************************************
 * disconnectParticipant */
/**
 * 
 ***************************************************************************/

function disconnectParticipant(participantConnectionObj) {
  let partsName = participantConnectionObj.data;
    
  let fnOnYes = function () {
    
      /* Call web method to disconnect */
	  // doRequestBanUser (partUidToBan)
	  
  	  localSession.forceDisconnect(participantConnectionObj).catch((disConnUserErr) => {
          updateSystemStatus('Error banning user', disConnUserErr.message, 'danger');
      });

	}; // callback for when user clicks yes
    let fnOnNo = function () { } // callback for when user clicks no
	
    MBA.actionDialogs.confirm("Please Confirm", "Are you sure you want to log out " + partsName + "?", "Cancel", "Proceed", fnOnNo, fnOnYes);
}

/***************************************************************************
 * disconnectParticipantUsingSubscription */
/**
 * 
 ***************************************************************************/

function disconnectParticipantUsingSubscription(sub) {
    var participantConnObj = sub.stream.connection;
    disconnectParticipant(participantConnObj);
}

/***************************************************************************
 * togglePublishAudio */
/**
 * Toggle publishers current audio stream on/off
 * 
 ***************************************************************************/

function togglePublishAudio() {
    if (currentPublisher != null) {
        if (currentPublisherPubAudState === false) currentPublisherPubAudState = true; else currentPublisherPubAudState = false;
        currentPublisher.publishAudio(currentPublisherPubAudState);
    }
}

/***************************************************************************
 * togglePublishVideo */
/**
 * Toggle publishers current video stream on/off
 * 
 ***************************************************************************/

function togglePublishVideo() {
    if (currentPublisher != null) {
        if (currentPublisherPubVidState === false) {
            currentPublisherPubVidState = true;
            if (currentPublisherIsScreensharing === false) currentPublisherMuteVideoBeforePublishing = !(currentPublisherPubVidState);
        }
        else {
            currentPublisherPubVidState = false;
            if (currentPublisherIsScreensharing === false) currentPublisherMuteVideoBeforePublishing = !(currentPublisherPubVidState);
        }
    
      currentPublisher.publishVideo(currentPublisherPubVidState);
    }
}

/***************************************************************************
 * closeParticipantStreamInDialog */
/**
 * 
 ***************************************************************************/

function closeParticipantStreamInDialog (participantSlotID) {
    MBA.responsizeDialog.findAndCloseUsingReferenceId(participantSlotID);
}

/***************************************************************************
 * openParticipantStreamInDialog */
/**
 * 
 ***************************************************************************/

function openParticipantStreamInDialog (fullScreenEnterCtrlSelector, streamContSelector, streamSlotSelector, participantSlotID) {

    let diaVideoContId = MBA.util.createNewUUID();
    let diaVideoContMkup = '<div id="' + diaVideoContId + '"></div>';

    var fnBeforeClose = function () {
        let whatToMoveBack = $(streamContSelector);
        $(streamContSelector + ' div.stream-element-container').addClass(clsStreamElementContRespHeight);
        $(streamContSelector + ' div.video-controls').addClass(clsAlignStreamVidCtrls);
        $(whatToMoveBack).removeClass('full-screen-stream-container');
        $(whatToMoveBack).addClass(clsMultiStreamContTweaks);
        $(streamSlotSelector).append(whatToMoveBack);
        $(fullScreenEnterCtrlSelector).show();
    };

    var fnBeforeOpen = function () {
        $(fullScreenEnterCtrlSelector).hide();
        let whatToMove = $(streamContSelector);
        $(whatToMove).addClass('full-screen-stream-container');

        /* Strip this container down to a generic bs grid by temporarily remove classes added to when this container was created  */

        $(whatToMove).removeClass(clsMultiStreamContTweaks);
        $(streamContSelector + ' div.stream-element-container').removeClass(clsStreamElementContRespHeight);
        $(streamContSelector + ' div.video-controls').removeClass(clsAlignStreamVidCtrls);
        $('#' + diaVideoContId).append(whatToMove);
    };

    MBA.responsizeDialog.createNew (
          null
        , ''
        , diaVideoContMkup
        , 95
        , 85
        , false
        , true
        , true
        , participantSlotID
        , fnBeforeOpen
        , fnBeforeClose
        , null);
}

/***************************************************************************
 *  doRequestMuteVideo */
/**
 * 
 * 
 ***************************************************************************/

function doRequestMuteVideo(signalObj) {

    // if user is muted, make them confirm if they want to allow to be unmuted
    if (currentPublisherPubVidState === false) {
        let fnOnYes = function () { togglePublishVideo(); }; // callback for when user clicks yes
        let fnOnNo  = function () { sendSignalMutePermissionDenied(signalObj.from, 'video'); } // callback for when user clicks no

        MBA.actionDialogs.confirm("Please Confirm", "A moderator is trying to show your video! Is this okay?", "No", "Yes", fnOnNo, fnOnYes);     
    }
    else {
        togglePublishVideo();
    }
}

/***************************************************************************
 * doRequestMuteAudio */
/**
 * 
 * 
 ***************************************************************************/

function doRequestMuteAudio(signalObj) {

    // if user is muted, make them confirm if they want to allow to be unmuted
    if (currentPublisherPubAudState === false) {
        let fnOnYes = function () { togglePublishAudio(); }; // callback for when user clicks yes
        let fnOnNo = function () { sendSignalMutePermissionDenied(signalObj.from, 'audio'); } // callback for when user clicks no

        MBA.actionDialogs.confirm("Please Confirm", "A moderator is trying to unmute your audio! Is this okay?", "No", "Yes", fnOnNo, fnOnYes);
    }
    else {
        togglePublishAudio();
    }
}

/***************************************************************************
 * doNotifyMutePermissionDenied */
/**
 * 
 * 
 ***************************************************************************/

function doNotifyMutePermissionDenied(signalMutePermissionDeniedEvent) {
    let signalObjData = JSON.parse(signalMutePermissionDeniedEvent.data);
    MBA.actionDialogs.alert("Request Denied", signalObjData.receiverName + " denied your request to unmute their " + signalObjData.audOrVid);
}

/***************************************************************************
 * doHideFile */
/**
 * 
 ***************************************************************************/

function doHideFile(signalHideFileEvent) {

  /* If this is the local user, no need to continue because this signal was issued as their local dialog
     was closing */

  if (signalHideFileEvent.from.connectionId == localSession.connection.connectionId) return;

  /* Otherwise find THIS users instance of the dialog and close it */

  let crossReferenceId = signalHideFileEvent.data;
    MBA.responsizeDialog.findAndCloseUsingReferenceId(crossReferenceId);

}

/**************************************************************************
 * doShowFile */
/**
 * 
 ***************************************************************************/

function doViewFile (fileToShowID) {

  let fileToShowSel = '#' + fileToShowID;
  let diaTitle = $(fileToShowSel).text();
  let srcHref = $(fileToShowSel).attr('href');
  var fileFrameMkup = '<div class="view-file"><iframe class="view-file" src="' + srcHref + '"></iframe></div>';

  var fnBeforeClose = function () { };

  return MBA.responsizeDialog.createNew (
            null
            , diaTitle
            , fileFrameMkup
            , 95
            , 85
            , false
            , true
            , true
            , fileToShowID
            , null
            , fnBeforeClose
            , null);

}

/**************************************************************************
 * doShowFile */
/**
 * 
 ***************************************************************************/

function doShowFile(signalShowFileEvent) {

    let fileToShowID  = signalShowFileEvent.data;
    let fileToShowSel = '#' + fileToShowID;
    let diaTitle      = $(fileToShowSel).text();
    let srcHref       = $(fileToShowSel).attr('href');
    var fileFrameMkup = '<div class="show-present-file"><iframe class="show-present-file" src="' + srcHref + '"></iframe></div>';

    var fnBeforeClose = function () { };

    /* If this is the local user who sent the signal then when their local dialog is closed, the signal needs to
       be sent to close everyone elses.*/

    if (signalShowFileEvent.from.connectionId == localSession.connection.connectionId) {
        fnBeforeClose = function () { sendSignalHideFile(fileToShowID); };
    }
    
    return MBA.responsizeDialog.createNew (
          null
        , diaTitle
        , fileFrameMkup
        , 95
        , 85
        , false
        , true
        , true
        , fileToShowID
        , null
        , fnBeforeClose
        , null);

}

/***************************************************************************
 * doUpdateFormWithNewValues */
/**
 * 
 ***************************************************************************/

function doUpdateFormWithNewValues (signalFormUpdated) {

   /* Skip if the signal originated from the local user */

    if (signalFormUpdated.from.connectionId == localSession.connection.connectionId) {
        return;
    }
           
    let sigDataStr = signalFormUpdated.data;
    let sigDataObj = JSON.parse(sigDataStr);
    let formID     = sigDataObj.formID;
    let formObj    = sigDataObj.formNameValues;
	
    /* Skip if the proper attribute value is not set */

    if (!canRemoteUpdateForm(formID)) return;          /* Skip if updating is not allowed */   

	/* Update data */

	MBA.util.objToForm(formID, formObj, true);

}

 /***************************************************************************
  * doRefreshFileShares */
 /**
  * 
  ***************************************************************************/

 function doRefreshFileShares(signalRefreshFileShares) {
   doGetAndReplaceSharedFileContent();
 }
 
 /***************************************************************************
  * doUpdateFormSignedStatus */
 /**
  * 
  ***************************************************************************/

 function doUpdateFormSignedStatus(signalFormSigned) {
  let sigDataStr     = signalFormSigned.data;
  let sigDataObj     = JSON.parse(sigDataStr);
  let formID         = sigDataObj.ctrlAdditionalDataID;
  let additionalData = sigDataObj.sigAdditionalData;
  let formObj        = JSON.parse(additionalData);
  MBA.util.objToForm(formID, formObj, true);   
}
 
 /***************************************************************************
  * doScreenshareStartedByParticipant */
 /**
  ***************************************************************************/
  
 function doScreenshareStarted(signalObj) {
     let targetConnectionId     = signalObj.data;
     localSession.streamManagers.forEach(streamManager => {
         if (streamManager.stream.connection.connectionId == targetConnectionId) {
             // we need to build the proper variables for fullscreening the screenshare
             // this code imitates the code for the scm object
             let subStream               = streamManager.stream;
             let streamID                = subStream.streamId;             
             let fullScreenEnterSelector = '#' + streamID + 'fullscreenenter';
             let audioMutedSelector      = '#' + streamID + 'audiomuted';
             let videoMutedSelector      = '#' + streamID + 'videomuted';

             // update video and audio state indicators
             updateAudioStateIndicator(audioMutedSelector, subStream);
             updateVideoStateIndicator(videoMutedSelector, subStream);

             // enter full screen because we are screensharing
             $(fullScreenEnterSelector).click();
         }
     });
 }

 /***************************************************************************
  * doScreenshareEnded */
 /**
  ***************************************************************************/

 function doScreenshareEnded(signalObj) {
 
     let targetConnectionId     = signalObj.data;
     localSession.streamManagers.forEach(streamManager => {
         if (streamManager.stream.connection.connectionId == targetConnectionId) {
             // we need to build the proper variables for fullscreening the screenshare
             // this code imitates the code for the scm object
             let subStream               = streamManager.stream;
             let streamID                = subStream.streamId;             
             let participantSlotID       = streamIDToParticipantSlotID[streamID];
             let audioMutedSelector      = '#' + streamID + 'audiomuted';
             let videoMutedSelector      = '#' + streamID + 'videomuted';

             // update video and audio state indicators
             updateAudioStateIndicator(audioMutedSelector, subStream);
             updateVideoStateIndicator(videoMutedSelector, subStream);

             // exit full screen because we are done screensharing
             closeParticipantStreamInDialog(participantSlotID);
         }
     });
 }

 /***************************************************************************
  * doBanUser */
 /**
  ***************************************************************************/

function doBanUser(signalObj) {
  // Put close browser here
}

/***************************************************************************
  * doesWaitingRoomRuleCurrentlyApplyToParticipant */
 /**
  ***************************************************************************/

function doesWaitingRoomRuleCurrentlyApplyToParticipant() { 
   if (facilitatorRequiredInRoom == false)  return false;
   if (participantIsFacilitator  == true)   return false;
   if (facilitatorIsPresent      == true)   return false;
   return true;
}

/***************************************************************************
 * doUpdateFacilitatorIsPresentFlag */
/**
 ***************************************************************************/
 
function doUpdateFacilitatorIsPresentFlag (signalObj) {
  if (doesWaitingRoomRuleCurrentlyApplyToParticipant() == true) {
    facilitatorIsPresent = true; /* Set so publish will be allowed */
	publishCamOrMic();
  }
  facilitatorIsPresent = true;
}
    
/***************************************************************************
 * doNotifyInvitesSentOut */
/**
 ***************************************************************************/
 
function doNotifyInvitesSentOut (signalObj) {
  updateSystemStatus('Meeting invites have been resent.', '', 'success');
}

/*#################################################################################################
  #
  #                                      Subscriptions
  #
  #################################################################################################*/

/***************************************************************************
 * subscribeToStream */
/**
 * 
 * 
 ***************************************************************************/

function subscribeToStream (subscribeEvent) {


  let remoteStream = subscribeEvent.stream;

  /* Insert element for video to be injected into and its containing elements */

  let scm = createAndInsertStreamContainerElements(remoteStream.streamId, remoteStream.typeOfVideo, false);
  $(scm.participantSlotSelector).hide();

  /* We now want to subscribe to the stream passing the element id we want the video element to be appended to */

  localSession.subscribeAsync(remoteStream, scm.mediaElementContID).then(sub => {

      /*----------------------------
       * One time post subscribe tasks
       * after subscription is 
       * complete.
       *----------------------------*/

      $(scm.participantSlotSelector).show();

      /* Update participant info */

      updateParticipantInfo(scm.participantInfoSelector, remoteStream.connection.data);

      /* Update audio video state indicators */

      updateAudioStateIndicator(scm.audioMutedSelector, sub.stream);
      updateVideoStateIndicator(scm.videoMutedSelector, sub.stream);

      /* if user is a moderator, add mute subscriber audio and video capabilities and add hand classses */

      if (scm.disconnectUserAllowed === true) {
          $(scm.disconnectUserSelector).click(function () { disconnectParticipantUsingSubscription(sub); });
      }

      if (scm.muteUserAllowed === true) {
          $(scm.audioMutedSelector).click(function () { sendSignalMuteUserAudio(sub); });
          $(scm.videoMutedSelector).click(function () { sendSignalMuteUserVideo(sub); });
      }

      /* Wire up full screen enter */

      $(scm.fullScreenEnterSelector).click(function () {          
          openParticipantStreamInDialog(scm.fullScreenEnterSelector, scm.streamContSelector, scm.participantSlotSelector, scm.participantSlotID);
      });

     /*----------------------------
      * Setup recurring event tasks
      * for the life of this 
      * subscription
      *----------------------------*/

      sub.on('streamAudioVolumeChange', (audioVolumeChangedEvent) => {
          updateAudioVolumeMeter(scm.audioMeterSelector, audioVolumeChangedEvent);
      });

      sub.on('streamPropertyChanged', (propChangedEvent) => {
          if (propChangedEvent.changedProperty === 'audioActive') {
              sub.subscribeToAudio(propChangedEvent.newValue);
              updateAudioStateIndicator(scm.audioMutedSelector, propChangedEvent.stream);
          }
          else if (propChangedEvent.changedProperty === 'videoActive') {
              sub.subscribeToVideo(propChangedEvent.newValue);
              updateVideoStateIndicator(scm.videoMutedSelector, propChangedEvent.stream);
          }
          else {

          }

      });

      //sub.on('videoElementCreated', (vidCreatedEvent) => {});
      //sub.on('streamPlaying', (streamPlayingEvent) => {});

      /*----------------------------
       * Setup one time event tasks
       * for this death of this
       * subscription
       *----------------------------*/

      sub.on('videoElementDestroyed', (vidDestroyedEvent) => {                
        closeParticipantStreamInDialog(scm.participantSlotID); /* Close dialog if one is open */
        $(scm.participantSlotSelector).remove();
      });

     /*----------------------------
       * One time EXPENSIVE post 
       * subscribe tasks
       * after subscription is 
       * complete.
       *----------------------------*/

      /* Automatically open screen share in dialog.  This is left for last */

      if (scm.isScreenShare === true) {    
        openParticipantStreamInDialog(scm.fullScreenEnterSelector, scm.streamContSelector, scm.participantSlotSelector, scm.participantSlotID);
      }

    }).catch(subError => {
        $(scm.participantSlotSelector).remove();
        updateSystemStatus('Error subscribing to a stream', subError.message, 'warning');
    });
}

/*#################################################################################################
  #
  #                                    Publications
  #
  #################################################################################################*/

/***************************************************************************
 * indicateScreenShareIsOn */
/**
 * 
 ***************************************************************************/

function indicateScreenShareIsOn() {
  $(pubControls.ctrlShareScreenSelector).removeClass("color-red").addClass("color-green");
  currentPublisherIsScreensharing = true;
}

/***************************************************************************
 * indicateScreenShareIsOff */
/**
 * 
 ***************************************************************************/

function indicateScreenShareIsOff() {
  $(pubControls.ctrlShareScreenSelector).removeClass("color-green").addClass("color-red");
  currentPublisherIsScreensharing = false;
}

/***************************************************************************
 * setNotPublishingState */
/**
 * Reset all flags and indicators to show that local user is not publishing 
 * 
 ***************************************************************************/

function setNotPublishingState() {
    currentPublisherPubVidState = false;
    currentPublisherPubAudState = false;
    $(pubControls.ctrlToggleAudioSelector).hide();
    $(pubControls.ctrlToggleVideoSelector).hide();     
}

/***************************************************************************
 * publishStream */
/**
 * 
 * 
 ***************************************************************************/

function publishStream(typeOfVideo, publishingOptions, publishingErrorMessage) {

	/*----------------------------
     * If the waiting room rule
	 * currently applies
     * do not allow the user to
	 * publish any stream
     *----------------------------*/
    if (doesWaitingRoomRuleCurrentlyApplyToParticipant() == true) {
	  MBA.actionDialogs.alert("Facilitator Not Present", "No facilitator is present. You will automatically connect once a facilitator enters the room.")
      return;
	}
	
	/*----------------------------
     * One time pre publish
     * pre init tasks
     *----------------------------*/

    // if publisher has already published their stream, we don't republish but rather switch the video input
	
	if (currentPublisher != null) {
	
	  if (typeOfVideo == 'SCREEN') {

        // Switch to screen share
        // https://openvidu.discourse.group/t/replacetrack-and-invalidmodificationerror/72/3
        OV.getUserMedia({ audioSource: false, videoSource: 'screen' })
            .then(function (media) {
                // keep track of what camera the user is using so we can go back to it when screensharing is done, and begin screensharing
                OV.getUserMedia({ audioSource: false, video: true })
                    .then(function (videoMedia) {
                        currentPublisherIsScreensharing = true;
                        // the below line is so when screensharing is done, we can return to the same video input as before
                        currentPublisherVideoStream = videoMedia.getVideoTracks().find(x => x.active === true);
                        //currentPublisher.stream.typeofvideo = 'SCREEN';
                        var track = media.getVideoTracks()[0]; // at this point, track is the screen feed
                        currentPublisher.replaceTrack(track); // https://docs.openvidu.io/en/2.13.0/api/openvidu-browser/classes/publisher.html#replacetrack

                        // screenshare is shown in "on" state so we need to adjust the mic icon if it is off
                        if (!currentPublisherPubVidState) $(pubControls.ctrlToggleVideoSelector).click();                

                        // set up callback to switch to camera when user exits screenshare
                        track.addEventListener('ended', () => {
                            toggleCamOrScreen();
                        });

                        indicateScreenShareIsOn();
                    }).then(sendSignalScreenshareStarted(currentPublisher.stream.connection.connectionId));                     
            });

        return;
      }

      // Switch back to camera in the case when user exits screenshare
      // https://openvidu.discourse.group/t/replacetrack-and-invalidmodificationerror/72/3
      else if (typeOfVideo == 'CAMERA') {
        OV.getUserMedia({ audio: false, video: true })
            .then(function (media) {

                // set track to original video input before screenshare started and if undefined for whatever reason, resort to first video input available
                var track = (typeof (currentPublisherVideoStream) === 'undefined') ? media.getVideoTracks()[0] : currentPublisherVideoStream;

                /*
                    If video is off during screenshare, we turn it on right before switching the feed to the camera.
                    Not sure why, but if we don't do the following if statement, when the user tries to switch to camera when
                    their video (which at this point is the screen) is off, the video icon stays red but the video feed is actually on.
                    Doing this resolves that issue.
                */
                if (!currentPublisherPubVidState) {
                    $(pubControls.ctrlToggleVideoSelector).click();
                }

                // switch the video input and turn video off if it was off before screensharing
                currentPublisher.replaceTrack(track)
                    .then(function () {
                        indicateScreenShareIsOff();

                        // return video state to what it was before screensharing started
                        if (currentPublisherMuteVideoBeforePublishing) {
                            $(pubControls.ctrlToggleVideoSelector).click();
                        }
                    }).then(currentPublisherIsScreensharing = false);
            }).then(sendSignalScreenshareEnded(currentPublisher.stream.connection.connectionId));
        return;
      }
	  else {
	    // Not supported
	  }
	
	}

    // Warn user about cam or mic availability
	
    warnUserAboutCamOrMicAvailability();
    setNotPublishingState();

    if (currentPublisher != null) {
        localSession.unpublish(currentPublisher);  /* TODO: Put in try catch*/
        currentPublisher = null;
    }

    let pcm = createAndInsertStreamContainerElements('mystream', typeOfVideo, true);

    /* If this is a screen share */

    if (pcm.isScreenShare === true) {
        indicateScreenShareIsOn();
    }
    else {
        indicateScreenShareIsOff();
    }

    /*----------------------------
     * Init publication
     *----------------------------*/

    OV.initPublisherAsync(pcm.mediaElementContID, publishingOptions).then(pub => {

        /*----------------------------
         * Peform all one-time post init
         * tasks for this publication 
         * prior to publication
         *----------------------------*/

        /* Hide the container */

        $(pcm.participantSlotSelector).hide();

        /* Set participant (local user) name */

        updateParticipantInfo(pcm.participantInfoSelector, localSession.connection.data);

        /* Set globals */

        currentPublisher = pub;      
        currentPublisherPubVidState = true;
        currentPublisherPubAudState = true;
        
        /* Show publisher audio/video mute controls */

        $(pubControls.ctrlToggleAudioSelector).show();
        $(pubControls.ctrlToggleVideoSelector).show();

        /* Add handlers for audio/video controls for publication itself*/

        $(pcm.audioMutedSelector).click(function () { togglePublishAudio(); });
        $(pcm.videoMutedSelector).click(function () { togglePublishVideo(); });

        /* If this stream is from the camera add handler for publication full screen enter control */

        if (pcm.isCamera === true) {          
            $(pcm.fullScreenEnterSelector).click(function () {
              openParticipantStreamInDialog(pcm.fullScreenEnterSelector, pcm.streamContSelector, pcm.participantSlotSelector, pcm.participantSlotID);              
            });
        }
                                  
        /*----------------------------
         * Setup all recurring event
         * driven tasks for the life of 
         * this publication 
         *----------------------------*/

        pub.on('streamPropertyChanged', (propChangedEvent) => {

            if (propChangedEvent.changedProperty === 'audioActive') {
                updateAudioStateIndicator(pcm.audioMutedSelector, propChangedEvent.stream);
                updateAudioStateIndicator(pubControls.ctrlToggleAudioSelector, propChangedEvent.stream);
            }
            else if (propChangedEvent.changedProperty === 'videoActive') {
                updateVideoStateIndicator(pcm.videoMutedSelector, propChangedEvent.stream);
                updateVideoStateIndicator(pubControls.ctrlToggleVideoSelector, propChangedEvent.stream);
            }
            else {

            }
        });

        pub.on('streamAudioVolumeChange', (audioVolumeChangedEvent) => {
            /* Update the audio meter with the new level */
            updateAudioVolumeMeter(pcm.audioMeterSelector, audioVolumeChangedEvent);
        });

        /*----------------------------
         * Setup all one time event
         * driven tasks for this 
         * publication that occur during
         * creation and destruction
         *----------------------------*/

        pub.on('videoElementCreated', (vidCreatedEvent) => {

        });

        pub.on('streamPlaying', (streamPlayingEvent) => {
            /* If this is a camera stream update video state to indicate video is off.  Note: This is a workaround for iOS */
            if (pcm.isCamera === true) {
                if (currentPublisherMuteVideoBeforePublishing) {
                    $(pcm.videoMutedSelector).click();
                }
                updateVideoStateIndicator (pcm.videoMutedSelector, pub.stream);
                updateVideoStateIndicator (pubControls.ctrlToggleVideoSelector, pub.stream);
            }
        });

        pub.on('videoElementDestroyed', (vidDestroyedEvent) => {
          
          closeParticipantStreamInDialog(pcm.participantSlotID) /* Close if dialog is open */
          $(pcm.participantSlotSelector).remove(); /* Get rid of our containing element */
          setNotPublishingState();
                
        });

        /*----------------------------
         * Publish
         *----------------------------*/

        localSession.publish(pub).then(() => {

          /*----------------------------
           * Post publication tasks
           *----------------------------*/

          currentPublisher = pub;
          $(pcm.participantSlotSelector).show();
            
          /* If this is a screen share */

         if (pcm.isScreenShare === true) {
             /* Handle if user ends stream outside of full screen close button */
             pub.stream.getMediaStream().getVideoTracks()[0].addEventListener('ended', () => {
               indicateScreenShareIsOff();
               closeParticipantStreamInDialog(pcm.participantSlotID);
               publishCamOrMic();
           });
           openParticipantStreamInDialog(pcm.fullScreenEnterSelector, pcm.streamContSelector, pcm.participantSlotSelector, pcm.participantSlotID);
         }

        }).catch(sesPubError => {
            currentPublisher = null;
            updateSystemStatus('Session could not publish your stream', sesPubError.message, 'danger');
        });

        /*----------------------------
         * These tasks are performed 
         * concurrently with publish
         *----------------------------*/

        updateAudioStateIndicator(pcm.audioMutedSelector, pub.stream);
        updateAudioStateIndicator(pubControls.ctrlToggleAudioSelector, pub.stream);
        updateVideoStateIndicator(pcm.videoMutedSelector, pub.stream);
        updateVideoStateIndicator(pubControls.ctrlToggleVideoSelector, pub.stream);

      }).catch(pubError => {

        closeParticipantStreamInDialog(pcm.participantSlotID);
        $(pcm.participantSlotSelector).remove();
        
        /* If this a screen capture deny */

        if (pcm.isScreenShare === true) {
            
            if (pubError.name == "SCREEN_CAPTURE_DENIED") {
              indicateScreenShareIsOff();
              currentPublisher = null;              
              publishCamOrMic(); /* Resume camera share */
              return;
            }
        }

        // if user denied access to devices
        if (pubError.name == "DEVICE_ACCESS_DENIED") {
            MBA.actionDialogs.alert("Permission Denied", "You have denied permission for your browser to access your video and/or audio inputs! People in this meeting will not see or hear you. Please enable device permissions on your browser.");
        }

        setNotPublishingState();
        updateSystemStatus(publishingErrorMessage, pubError.message, 'danger');
    });   
}

/***************************************************************************
 * toggleCamOrScreen */
/**
 * toggles the camera or screen based on which one is active
 * 
 ***************************************************************************/
 
function toggleCamOrScreen() {
  if (currentPublisherIsScreensharing) {
      publishCamOrMic();
  }
  else {
      publishScreen();
  }
}

/***************************************************************************
 * publishCamOrMic */
/**
 * 
 * 
 ***************************************************************************/

function publishCamOrMic() {

  publishStream('CAMERA', { resolution: "320x240" }, 'Could not stream camera or mic') 

}

/***************************************************************************
 * publishScreen */
/**
 * 
 * 
 ***************************************************************************/

function publishScreen() {

  publishStream('SCREEN', { videoSource: "screen" }, 'Could not share screen');   

}


/*#################################################################################################
  #
  #                                         Sessions 
  #
  #################################################################################################*/

/***************************************************************************
 * disconnectSession */
/**
 * 
 * 
 ***************************************************************************/

function disconnectSession() {

    if (localSession) {
        MBA.responsizeDialog.closeAll();

        localSession.disconnect();

    }
}

/***************************************************************************
 * connectSession */
/**
 * 
 * 
 ***************************************************************************/

function connectSession() {

  /*============================================================
   * Connect to conference server using localSessionToken
   *============================================================*/

  localSession.connect(localSessionToken).then(() => {
  
    /*----------------------------
     * Show or remove screen share
     * based on rules 
     *----------------------------*/
	 
    if (canShareScreen() === true) {
      $(pubControls.ctrlShareScreenSelector).show(); 
    }
    else {
      $(pubControls.ctrlShareScreenSelector).remove(); 
    }
      
   /*----------------------------
     * Initially publish cam
     *----------------------------*/
   
    publishCamOrMic();
  
  }).catch(connError => {
      updateSystemStatus('Error connecting to conference server', connError.message, 'danger');
  });
  return;
}

/*#################################################################################################
  #
  #                                         Init
  #
  #################################################################################################*/

/***************************************************************************
 * initPubControls */
/**
 * Note: Must only be run once
 * 
 ***************************************************************************/

function initPubControls() {

  pubControls = {};

  /*============================================================
   * Control ids and selectors
   *============================================================*/

  /*----------------------------
   * Create control ids
   *----------------------------*/

  pubControls.ctrlShareScreenID    = 'strmscreen'
  pubControls.ctrlToggleAudioID    = 'strmtoglaud';
  pubControls.ctrlToggleVideoID    = 'strmtoglvid';
  pubControls.ctrlRefreshConnnectionID = 'refreshconnect';

  /*----------------------------
   * Create control selectors
   *----------------------------*/

  pubControls.ctrlShareScreenSelector = '#' + pubControls.ctrlShareScreenID;
  pubControls.ctrlToggleAudioSelector = '#' + pubControls.ctrlToggleAudioID;
  pubControls.ctrlToggleVideoSelector = '#' + pubControls.ctrlToggleVideoID;
  pubControls.ctrlRefreshConnectionSelector = '#' + pubControls.ctrlRefreshConnnectionID

  /*============================================================
   * Controls
   *============================================================*/

  /*----------------------------
   * Refresh connection
   *----------------------------*/

  let ctrlRefreshConnnection = $('<i id="' + pubControls.ctrlRefreshConnnectionID + '" class="session-control refresh-conn fas fa-sync" title="Refresh my connection to the conference server"></i>');
    $(ctrlRefreshConnnection).click(function () { location.reload(); });
  $(participantPublicationControlsSelector).append(ctrlRefreshConnnection);

  /*----------------------------
   * Screen sharing
   *----------------------------*/
  
  let ctrlShareScreen = $('<i id="' + pubControls.ctrlShareScreenID + '" class="stream-control stream-screen fas fa-tv color-red" title="Share my screen"></i>');
  $(ctrlShareScreen).click(function () { toggleCamOrScreen(); });
  $(participantPublicationControlsSelector).append(ctrlShareScreen);
  $(pubControls.ctrlShareScreenSelector).hide(); /* Hide until we can determine if participant can share */
  
  /*----------------------------
   * Mute audio
   *----------------------------*/

  let ctrlToggleAudio = $('<i id="' + pubControls.ctrlToggleAudioID + '" class="stream-control toggle-mic fas fa-microphone" title="Turn microphone on/off"></i>');
  $(ctrlToggleAudio).click(function () { togglePublishAudio(); });
  $(participantPublicationControlsSelector).append(ctrlToggleAudio);

  /*----------------------------
   * Mute video
   *----------------------------*/

  let ctrlToggleVideo = $('<i id="' + pubControls.ctrlToggleVideoID + '" class="stream-control toggle-vid fas fa-video" title="Turn camera/screen on/off"></i>');
  $(ctrlToggleVideo).click(function () { togglePublishVideo(); });
  $(participantPublicationControlsSelector).append(ctrlToggleVideo);

}


/***************************************************************************
 * initVideoArrows */
/**
 * Must only be run from initTelecomm and only run once
 * 
 * appends arrows to the participants video container for sliding videos left and right
 * 
 ***************************************************************************/

function initVideoArrows() {
        
  /* Generate left arrow controls */

  var lArrowIco = $('<i class="fas fa-chevron-left"></i>');
  $(lArrowIco).on('click',function() {scrollParticipantsDiv (-300);});  
  var lArrowDiv = $('<div id="left-video-arrow" class="left-right-video-arrow d-flex justify-content-center align-items-center position-absolute"></div>');  
  $(lArrowDiv).append(lArrowIco);
  
  /* Generate right arrow controls */

  var rArrowDiv = $('<div id="right-video-arrow" class="left-right-video-arrow d-flex justify-content-center align-items-center position-absolute"></div>');
  var rArrowIco = $('<i class="fas fa-chevron-right"></i>');
  $(rArrowIco).on('click',function() {scrollParticipantsDiv (300);});
  $(rArrowDiv).append(rArrowIco);
  
  /* Insert arrow controls as siblings */

  $(participantStreamsSelector).before(lArrowDiv);  
  $(participantStreamsSelector).after(rArrowDiv);

}

/***************************************************************************
 * initToggleParticipantStreamsView */
/**
 * Must only be run from initTelecomm and only run once
 * 
 * sets up the callback function for switching the participants container view
 * 
 ***************************************************************************/

function initToggleParticipantStreamsView() {
    currentParticipantsViewIsGallery = false; // this is to make sure that initially, we are not in gallery mode

    // set up the callback function when the button is clicked,
    // we basically add a class to the streams container which has the proper css rules 
    // and set the global variable 'currentParticipantsViewIsGallery' accordingly
    $(toggleParticipantsViewBtnSelector).click(function () {
        if (currentParticipantsViewIsGallery) {
            currentParticipantsViewIsGallery = false;
            $(participantStreamsContainerSelector).removeClass(galleryViewClass);
        } else {
            currentParticipantsViewIsGallery = true;
            $(participantStreamsContainerSelector).addClass(galleryViewClass);
        }
    });

}

/***********************************************************************************
 * initWhatIsMyPin */
/**
 * Must only be run from initTelecomm and only run once
 * 
 * sets up the callback function for when user clicks the "what is my pin?" button
 * 
 ***********************************************************************************/

function initWhatIsMyPin() {
    // set up the callback function when the button is clicked,
    $(whatIsMyPinBtnSelector).click(function () {
        MBA.actionDialogs.alert("What Is My Pin", "Your pin is: <strong>"
            + $(roomPartPinSelector).val() + "</strong>");
    });
}
    
/***********************************************************************************
 * initSendMeetingInvites */
/**
 * Must only be run from initTelecomm and only run once
 * 
 * sets up the callback function for when user clicks the "Resend Meeting Invites" button
 * 
 ***********************************************************************************/

function initSendMeetingInvites() {
    // create callback function to send the ajax request
    let _callSendInvitesWebMethod = function () {
        let requestDataObj = {};
        requestDataObj.rmid = $(roomIdSelector).val();
        requestDataObj.rmpartuid = $(roomPartUidSelector).val();
        requestDataObj.rmpartpin = $(roomPartPinSelector).val();
        let requestData = JSON.stringify(requestDataObj);
        updateSystemStatus('Requesting meeting invites be resent.', '', 'info');
        MBA.ajax.callAsmxWebMethodBase(urlSendMeetingInvites, requestData);
    }
    // set up the callback function when the button is clicked,
    $(sendMeetingInvitesBtnSelector).click(_callSendInvitesWebMethod);
}

/***********************************************************************************
 * initAppendFileShare */
/**
 * Must only be run from initTelecomm and only run once
 *
 * sets up the callback function for when user clicks the "Upload File" button
 *
 ***********************************************************************************/

 function initAppendFileShare() {
    
    let  _callAppendFileShare = function() {
        
      let storedFileUploadUrlAndValidationParms = urlAppendFileShares
            + '?rmid=' + encodeURIComponent($(roomIdSelector).val())
            + '&rmprtuid=' + encodeURIComponent($(roomPartUidSelector).val())
            + '&rmprtpin=' + encodeURIComponent($(roomPartPinSelector).val());
        
        MBA.storedFile.upload(storedFileUploadUrlAndValidationParms
            , 'Upload A File For This Meeting (PDF only please)'
            , '.pdf'
            , function () { updateSystemStatus('Uploading file', '', 'info'); }
            , function () { }
            , function (rd) {
                if (rd.status == 0) {
                  updateSystemStatus('File upload complete.  The file will be added to the meeting files shortly.', '', 'info');
                }
                else {
                  updateSystemStatus('File upload failed.', rd.message, 'danger');
                }
            }
            , function () { updateSystemStatus('File upload request could not be completed at this time.  Please try again.', '', 'alert'); }
            
        );
    }
    // set up the callback function when the button is clicked,
    $(appendSharedFilesSelector).click(_callAppendFileShare);    
}

/***************************************************************************
 * initSession */
/**
 * Must only be run from initTelecomm and only run once
 ***************************************************************************/

function initSession() {

    /*============================================================
     * Creates a new session
     *============================================================*/

    localSession = OV.initSession();

    /*============================================================
     * Connection listeners
     *============================================================*/

    /*
    localSession.on('connectionCreated', (connectionCreatedEvent) => {

    });

    localSession.on('connectionDestroyed', (connectionDestroyedEvent) => {
        //This is for all users except you 
    });
   */

    localSession.on('reconnecting', (reconnectingEvent) => {
        updateSystemStatus('Connection lost attempting to reconnect', '', 'info');
    });

    localSession.on('reconnected', (reconnectedEvent) => {
        updateSystemStatus('Connection recovered', '', 'success');
    });

    localSession.on('sessionDisconnected', (sessionDisconnectedEvent) => {
        if (sessionDisconnectedEvent.reason === 'networkDisconnect') {
            updateSystemStatus('Connection lost attempting to refresh connection', '', 'warning');
            refreshConnection();
        }
        else if (sessionDisconnectedEvent.reason === 'disconnect') {
            updateSystemStatus('You have disconnected');
        }
        else if (sessionDisconnectedEvent.reason === 'forceDisconnectByUser') {
            updateSystemStatus('You have been disconnected by a moderator');
            // these lines are temporary! we should send the user back to the login page at this point

            $("main").remove();
            $("footer").remove();
        }
        else {
            // Should redirect to login if the reason was not you disconnected
        }
    });

    /*============================================================
     * Stream listeners 
     *============================================================*/

    localSession.on('streamCreated', (streamCreatedEvent) => { subscribeToStream(streamCreatedEvent); });
    //localSession.on('streamDestroyed', (streamDestroyedEvent) => { unSubscribeFromStream(streamDestroyedEvent); });

   /*============================================================
    * Signal listeners
    *============================================================*/

    localSession.on('signal:show_file', (signalShowFileEvent) => { doShowFile(signalShowFileEvent); });
    localSession.on('signal:hide_file', (signalHideFileEvent) => { doHideFile(signalHideFileEvent); });
    localSession.on('signal:mute_audio', (signalMuteAudioEvent) => { doRequestMuteAudio(signalMuteAudioEvent); });
    localSession.on('signal:mute_video', (signalMuteVideoEvent) => { doRequestMuteVideo(signalMuteVideoEvent); });
    localSession.on('signal:mute_permission_denied', (signalMutePermissionDeniedEvent) => { doNotifyMutePermissionDenied(signalMutePermissionDeniedEvent); });
    localSession.on('signal:update_form_with_new_values', (signalFormUpdated) => { doUpdateFormWithNewValues(signalFormUpdated); });
    localSession.on('signal:refresh_file_shares', (signalRefreshFileShares) => { doRefreshFileShares(signalRefreshFileShares); });
    localSession.on('signal:form_signed', (signalFormSigned) => { doUpdateFormSignedStatus(signalFormSigned); });
    localSession.on('signal:participant_started_screenshare', (signalScreenshareEvent) => { doScreenshareStarted(signalScreenshareEvent); });
    localSession.on('signal:participant_ended_screenshare',   (signalScreenshareEvent) => { doScreenshareEnded(signalScreenshareEvent); });
    localSession.on('signal:ban_user', (signalBanUserEvent) => { doBanUser(signalBanUserEvent); });
    localSession.on('signal:facilitator_entered_room', (signalFacilitatorEnteredRoomEvent) => { doUpdateFacilitatorIsPresentFlag(signalFacilitatorEnteredRoomEvent); });
    localSession.on('signal:meeting_invites_sent_out', (signalMeetingInvitesSentOutEvent)  => { doNotifyInvitesSentOut(signalMeetingInvitesSentOutEvent); });
}

/***************************************************************************
 * setupRemoteUpdateForms */
/**
 * 
 * 
 ***************************************************************************/

function setupRemoteUpdateForms () {
  let frmsSelector = 'form[' + DATA_ATTR_FORM_REMOTE_UPDATE + '] :input';
  $(frmsSelector).on('click change select focusout', function (dataChangedEvent) {
     let updatedFormID = $(this).closest('form').attr('id');  
     doSaveFormWipData(updatedFormID).then(responseData => {
        sendSignalUpdateFormWithNewValues(updatedFormID);
     });      
  });
}
 
/***************************************************************************
 * doSubmitFinalForm */
/**
 * 
 * 
 ***************************************************************************/

var _doSubmitFinalForm = function (formID, submitButtonID, diaTitle, fnStart, fnOnGoBack, fnOnProceedWithSave, fnOnGoBackAndFix) {
  return MBA.actionDialogs.openSaveFormDataDialog(formID, submitButtonID, diaTitle, 1, doSaveFormFinalData, fnStart, fnOnGoBack, fnOnProceedWithSave, fnOnGoBackAndFix);
}

/***************************************************************************
 * initTelecomm */
/**
 * Sets up and tests overall system and system requirements
 * This must be run first after the DOM is ready
 ***************************************************************************/
     
var _initTelecomm = function (
      systemstatuselementid
    , browsernotsupportedelementid
    , participantpublicationcontrolselementid
    , participantstreamselementid
    , participantstreamscontainerid
    , toggleparticipantsviewbtnid
    , whatismypinbtnid
    , sendmeetinginvitesbtnid
    , appendsharedfilesbtnid
    , sessionfileselementid
    , baselink
    , urlgetsharedfilehtmllist
    , urlsaveformwip
	, urlsignform
    , urlgetformsignatureshtmltable
    , urlbanuser
    , urlsendmeetinginvites
    , urlappendfileshares
    , roomidelementid
    , roompartuidelementid
    , roompartpinelementid
    , facilitatorrequiredinroom
    , participantisfacilitator
    , facilitatorispresent	
    , sessiondata
    , latestroomformdatarecordedjson) 
{
    
 /*============================================================
   * Prevent second call
   *============================================================*/

  if (initHasBeenCalled === true) return;
  initHasBeenCalled = true;

  /*============================================================
   * Get various element ids passed in
   *============================================================*/
  
  systemStatusElementID                   = systemstatuselementid;
  browserNotSupportedElementID            = browsernotsupportedelementid;
  participantPublicationControlsElementID = participantpublicationcontrolselementid;
  participantStreamsElementID = participantstreamselementid;
  sessionFilesElementID = sessionfileselementid;
  roomIdElementId = roomidelementid;
  roomPartUidElementId = roompartuidelementid;
  roomPartPinElementId = roompartpinelementid;

  /*============================================================
   * Get various uris passed in 
   *============================================================*/

  baseLink                      = baselink;
  urlGetSharedFileHtmlList      = urlgetsharedfilehtmllist;
  urlSvcSaveFormWipData         = urlsaveformwip;
  urlSvcSignForm                = urlsignform;
  urlGetFormSignaturesHtmlTable = urlgetformsignatureshtmltable;
  urlBanUser                    = urlbanuser;
  urlSendMeetingInvites         = urlsendmeetinginvites;
  urlAppendFileShares           = urlappendfileshares;

  /*============================================================
   * Get session and token data passed in
   *============================================================*/

  localSessionData  = sessiondata;
  localSessionToken = localSessionData.token;
  
  /*============================================================
   * Waiting room flags
   *============================================================*/

  facilitatorRequiredInRoom  = (facilitatorrequiredinroom === 'true');
  participantIsFacilitator   = (participantisfacilitator  === 'true');
  facilitatorIsPresent       = (facilitatorispresent      === 'true');
  
  /*============================================================
   * Restore form and signature data (if any)
   * Note: It is important to do this before any of the form
   * data sharing events are setup
   *============================================================*/
  
  let _latestRoomFormDataRecordedObj = JSON.parse(latestroomformdatarecordedjson);
  if (_latestRoomFormDataRecordedObj.forms) {
    $.each(_latestRoomFormDataRecordedObj.forms, function (_formIdx, _formObj) {
        let _formID      = _formObj.formID
        let _formDataObj = JSON.parse(_formObj.formDataJSON);
        MBA.util.objToForm(_formID, _formDataObj, true);
    });  
  }
  
  /*============================================================
   * Create selectors for global elements
   *============================================================*/

  systemStatusSelector                   = '#' + systemStatusElementID;
  browserNotSupportedSelector            = '#' + browserNotSupportedElementID;
  participantPublicationControlsSelector = '#' + participantPublicationControlsElementID;
  participantStreamsSelector             = '#' + participantStreamsElementID;
  participantStreamsContainerSelector    = '#' + participantstreamscontainerid;
  toggleParticipantsViewBtnSelector      = '#' + toggleparticipantsviewbtnid;
  whatIsMyPinBtnSelector                 = '#' + whatismypinbtnid;
  sendMeetingInvitesBtnSelector          = '#' + sendmeetinginvitesbtnid;
  appendSharedFilesSelector              = '#' + appendsharedfilesbtnid;
  sessionFilesSelector                   = '#' + sessionFilesElementID;
  roomIdSelector                         = '#' + roomIdElementId;
  roomPartUidSelector                    = '#' + roomPartUidElementId;
  roomPartPinSelector                    = '#' + roomPartPinElementId;

  /*============================================================
   * Create new instance of conference server browser lib 
   *============================================================*/
	
  OV = new OpenVidu();
  OV.enableProdMode();  
      	
  /*============================================================
   * Check system requirements
   *============================================================*/

  if (OV.checkSystemRequirements() === 0) {
    MBA.actionDialogs.alert('Warning', 'Your web browser is not supported.');
    return;
  }
    
  /*============================================================
   * Disconnect user from a session if they close the window
   *============================================================*/

  window.onbeforeunload = function () { disconnectSession(); };

  /*============================================================
   * One time init tasks
   *============================================================*/

  initSession();
  initPubControls();
  initVideoArrows();
  initToggleParticipantStreamsView();
  initWhatIsMyPin();
  initSendMeetingInvites();
  setupRemoteUpdateForms();
  setupFileShares();  
  initAppendFileShare();
  connectSession();
 
}

return {        
    initTelecomm : _initTelecomm             
  , doSubmitFinalForm :_doSubmitFinalForm
  , doSignForm: _doSignForm
  , doViewFormSignatures: _doViewFormSignatures
};

})(jQuery);