// source: http://frenetic.be/tricks/simple-timer.php

// **************************************************************************
// ************** THIS IS THE VERSION THAT COUNTS DOWN **********************
// **************************************************************************

//function printTime(final_time) {
//    var diff = final_time - (new Date()).valueOf();
//    // calculate number of minutes
//    var minutes = Math.floor(diff / 1000 / 60);
//    // calculate number of seconds
//    var seconds = Math.floor(diff / 1000) - minutes * 60;

//    // return output to Web Worker
//    // if number of minutes less than 10, add a leading "0"
//    minutes = minutes.toString();
//    if (minutes.length == 1) {
//        minutes = "0" + minutes;
//    }
//    // if number of seconds less than 10, add a leading "0"
//    seconds = seconds.toString();
//    if (seconds.length == 1) {
//        seconds = "0" + seconds;
//    }

//    if (diff <= 0) {
//        postMessage("00:00");
//    }
//    else {
//        postMessage(minutes + ":" + seconds);
//    }
//}

//onmessage = function (event) {
//    var meeting_duration = event.data.meeting_duration;
//    var start_time = event.data.start_time;

//    // repeat every 1000 ms
//    setInterval(function () {
//        printTime(start_time + meeting_duration);
//    }, 1000);
//}

// **************************************************************************
// **************************************************************************
// **************************************************************************

// **************************************************************************
// ************** THIS IS THE VERSION THAT COUNTS UP ************************
// **************************************************************************
function printTime(start_time) {
    var diff = (new Date()).valueOf() - start_time;

    // calculate number of minutes
    var hours = Math.floor(diff / 1000 / 3600);
    // calculate number of minutes
    var minutes = Math.floor(((diff / 1000) - (hours * 3600)) / 60);
    // calculate number of seconds
    var seconds = Math.floor(diff / 1000) - (hours * 3600) - (minutes * 60);

    // return output to Web Worker
    // if number of minutes less than 10, add a leading "0"
    minutes = minutes.toString();
    if (minutes.length == 1) {
        minutes = "0" + minutes;
    }
    // if number of seconds less than 10, add a leading "0"
    seconds = seconds.toString();
    if (seconds.length == 1) {
        seconds = "0" + seconds;
    }

    if (diff <= 0) {
        postMessage("00:00:00");
    }
    else {
        postMessage(hours + ":" + minutes + ":" + seconds);
    }
}

onmessage = function (event) {
    var start_time = event.data.start_time;

    // repeat every 1000 ms
    setInterval(function () {
        printTime(start_time);
    }, 1000);
}