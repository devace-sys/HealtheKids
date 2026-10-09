/***************************************************************************
 * startTimer */
/**
 * 
 * 
 ***************************************************************************/
var timer_worker = null; // initialize worker variable

function startTimer(start_time, worker_script, container_selector) {
    // First check whether Web Workers are supported
    if (typeof (Worker) !== "undefined") {
        // Check whether Web Worker has been created. If not, create a new Web Worker based on the Javascript file simple-timer.js
        if (timer_worker == null) {
            timer_worker = new Worker(worker_script);
        }
        timer_worker.postMessage({ "start_time": start_time });

        timer_worker.onmessage = function (event) {
          $(container_selector).text(event.data);
        };

        timer_worker.onerror = function (err) {
            console.log(err);
        };
    }
    else {
        // Web workers are not supported by your browser
        //TODO
    }
}

// function to stop the timer

function stopTimer() {
  timer_worker.terminate();
  timerStart = true;
  timer_worker = null;
}
