var calcTimeMins = (function ($) {

var timeFmtStr24 = function() { return 'HH:mm'; };
var timeFmtStr12 = function() { return 'hh:mm tt';};
var calcRefDate  = function() { return new Date(2000,0,1,0,0,0,0);};

var parseTime = function(timeStr) {
  /* Uses date.js */
  var d1 = Date.parse(timeStr);
  if (d1 === null) return null;
  return d1;
};

var calcMinsDiff = function (startTimeVal, endTimeVal) {
  var diffInMS  = endTimeVal.getTime() - startTimeVal.getTime();
  var minsVal   = Math.round(diffInMS / 60000);
  return minsVal;
};

var checkTimeRange = function (startTimeVal, endTimeVal) {
  /* Uses date.js */
  /* Start time cannot be after end time */
  if ( Date.compare (startTimeVal, endTimeVal) == 1 ) return 0;
  return 1;  
};

var checkMinsRange = function (minsVal) {
  if (minsVal < 0)    return false;
  if (minsVal > 1339) return false;
  if (minsVal == 0)   return true;
  return true;
};

var calcCheckMins = function(timeVal, minsRef) {
  var t1 = calcRefDate();
  var t2 = new Date(timeVal);
  var m1 = calcMinsDiff (t1,t2) + minsRef;
  return m1;
};

var calcMinsVal = function(startTimeVal, endTimeVal) {
  var m1 = calcMinsDiff(startTimeVal, endTimeVal);
  return m1;
};

var calcStartTimeVal = function(endTimeVal, minsVal) {
  var startTimeVal = new Date(endTimeVal); 
  var minsRef      = (Math.abs(minsVal) * -1);
  var checkMins    = calcCheckMins (endTimeVal, minsRef);
  if (checkMins < 0) return null;
  startTimeVal.addMinutes(minsRef);
  return startTimeVal;
};

var calcEndTimeVal = function (startTimeVal, minsVal) {
  var endTimeVal = new Date(startTimeVal);
  var minsRef    = Math.abs(minsVal);
  var checkMins  = calcCheckMins (endTimeVal, minsRef);
  if (checkMins > 1339) return null;
  endTimeVal.addMinutes(minsRef);
  return endTimeVal;
};

var convertToTimeVal = function (timeStr) {
  var refDate = calcRefDate();
  if (!timeStr)  return null;  
  var d1 = parseTime(timeStr);
  if (d1 === null) return null;
  var d2 = new Date(refDate);
  d2.setHours        (d1.getHours());
  d2.setMinutes      (d1.getMinutes());
  d2.setSeconds      (0);
  d2.setMilliseconds (0);
  return d2;
};

var convertToTimeStr = function (timeVal,fmtStr) {
  /* Uses date.js */
  if (timeVal)
    return timeVal.toString(fmtStr);
  else
    return '';
};

var convertToMinsVal = function (minsStr) {
  if (!minsStr) return null;
  var minsVal = parseInt (minsStr, 10);
  if (isNaN(minsVal)) return null; 
  return minsVal;
};

var convertToMinsStr = function (minsVal) {
  if (minsVal)
    return minsVal.toString();
  else
    return '';
};

var determineTimeStrFmt = function (timeStr) {
  var re = new RegExp('[apmAPM]$');
  var match = timeStr.match( re );
  if ( match ) return timeFmtStr12();
  return timeFmtStr24();
};

var calcStartTimeEndTimeMinsVals = function (start, end, mins) {

  var rd = {};
  rd.retState     = 0;
  rd.startTimeVal = convertToTimeVal (start);
  rd.endTimeVal   = convertToTimeVal (end);
  rd.minsVal      = convertToMinsVal (mins);
  rd.startTimeStr = '';
  rd.endTimeStr   = '';
  rd.minsStr      = '';
  rd.startTimeFmt = timeFmtStr24();
  rd.endTimeFmt   = timeFmtStr24();

  /* Have valid startTimeVal and endTimeVal but no minsVal */
  
  if ((rd.startTimeVal) && (rd.endTimeVal) && (!rd.minsVal)) {

    /* If the range is OK */
	
	if (checkTimeRange(rd.startTimeVal, rd.endTimeVal) == 1) {  
	  rd.minsVal = calcMinsVal (rd.startTimeVal,rd.endTimeVal);
	  rd.startTimeFmt = determineTimeStrFmt(start);
	  rd.endTimeFmt   = determineTimeStrFmt(end);
	}
	else {
      rd.minsVal  = null; 
	  rd.retState = 2;
	  return rd;
	}
  }

  /* Have valid startTimeVal and minsVal but no endTimeVal */
  
  else if ((rd.startTimeVal) && (!rd.endTimeVal) && (rd.minsVal)) {
    
    rd.endTimeVal = calcEndTimeVal (rd.startTimeVal, rd.minsVal);
	rd.startTimeFmt = determineTimeStrFmt(start);
	rd.endTimeFmt   = rd.startTimeFmt;
  }

  /* Have valid endTimeVal and minsVal but no startTimeVal */
  
  else if ((!rd.startTimeVal) && (rd.endTimeVal) && (rd.minsVal)) {
    rd.startTimeVal = calcStartTimeVal (rd.endTimeVal, rd.minsVal);  
  	rd.endTimeFmt   = determineTimeStrFmt(end);
    rd.startTimeFmt = rd.endTimeFmt;
  }

  /* Have valid minsVal but no startTimeVal and endTimeVal */

  else if ((!rd.startTimeVal) && (!rd.endTimeVal) && (rd.minsVal)) {
    rd.retState = 1;
	return rd;
  }

  /* Have all */

  else if ((rd.startTimeVal) && (rd.endTimeVal) && (rd.minsVal)) {

    rd.retState = 1;
	return rd;
  } 
  
  /* Anything else exit */
  
  else {
    rd.retState = 1;
	return rd;
  }

  rd.startTimeStr = convertToTimeStr (rd.startTimeVal,rd.startTimeFmt);
  rd.endTimeStr   = convertToTimeStr (rd.endTimeVal,  rd.endTimeFmt);
  rd.minsStr      = convertToMinsStr (rd.minsVal);
  rd.retState     = 0
  return rd;
};

var calcStartTimeEndTimeMinsFlds = function (startFld,endFld,minsFld) {
  
  var start = $(startFld).val();
  var end   = $(endFld).val();
  var mins  = $(minsFld).val();
  var rd    = calcStartTimeEndTimeMinsVals (start,end, mins);
  
  if ( rd.retState == 0 ) {
    $(startFld).val(rd.startTimeStr);
    $(endFld).val(rd.endTimeStr);
    $(minsFld).val(rd.minsStr);
  }
  return;
};

return {
      calcVals : function (start, end, mins)          { return calcStartTimeEndTimeMinsVals (start, end, mins); }
	, fillFlds : function (startFld, endFld, minsFld) { return calcStartTimeEndTimeMinsFlds (startFld, endFld, minsFld);}
};

})(jQuery);
