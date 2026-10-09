/***************************************************************************
* recurringservices.js */
/**
* Scripts specific to recurring services
***************************************************************************/

/**************************************************************************
 * Control References (for method invocation)
 **************************************************************************/
        
var sbPracSelect  = null;
var dgPracDetails = null;
var dgTmtBS       = null;
var dgTmtDS1      = null;
var dgTmtDS2      = null;
var dgTmtAS       = null;
var dgTran1       = null;
var dgTran2       = null;
var dgTran3       = null;
var dgTran4       = null;

/**************************************************************************
 * Default Answers
 **************************************************************************/

var defaultAnswersIEP       = [];
var defaultAnswersNums      = [];
var defaultAnswersNumsFlags = [];    

/**************************************************************************
 * Messages
 **************************************************************************/

function showMissingDetailMsg (errTitle,errMsg, fnOK)
{
  if (!fnOK) fnOK = function(){};
  $.spedmonWebUI.dialogMessage (errTitle, errMsg, true, 400, 300, fnOK);
}

function showMissingDetailMsgPrac()
{
  showMissingDetailMsg("You Forgot to Enter Practitioner Details", "For each practitioner row please check at least one 'Provides' box.");
}

function showMissingDetailMsgTrans()
{
  showMissingDetailMsg("You Forgot to Enter Transportation Details", "For each practitioner row please enter more than 0 miles for at least one day.");
}

function showMissingDetailMsgTmtBSAS()
{
  showMissingDetailMsg("You Forgot to Enter Treatment or TCM Details", "For each practitioner row please enter more than 0 minutes for at least one day.");
}

function showMissingDetailMsgCalBell(fnOK)
{
  showMissingDetailMsg("You Forgot to Select a Calendar and Bell Schedule", "You have at least one 'All Day' box checked but you have not selected a calendar and bell schedule.",fnOK);
}

function showMissingDetailMsgTmtDS()
{
 showMissingDetailMsg("You Forgot to Enter Treatment or TCM Details", "For each practitioner row please enter more than 0 minutes for at least one day OR check at least one 'All Day' box.");
}

function showDupMsg()
{
 showMissingDetailMsg("Overlaping Record Warning", "You have selected dates that overlap with an existing record.");
}

/**************************************************************************
 * setDefaultAnswers() */
/**
 * Set default answers
 **************************************************************************/

function setDefaultAnswers()
{
  /* Define defaults for assignments */
  
  defaultAnswersIEP = [];
  
  defaultAnswersIEP.push('1');
  defaultAnswersIEP.push('1');
  
  defaultAnswersNums = [];
  
  defaultAnswersNums.push('0');    
  defaultAnswersNums.push('0');
  defaultAnswersNums.push('0');
  defaultAnswersNums.push('0');
  defaultAnswersNums.push('0');
  defaultAnswersNums.push('0');  
  
  defaultAnswersNumsFlags = [];    
  
  defaultAnswersNumsFlags.push('0');
  defaultAnswersNumsFlags.push('0');  
  defaultAnswersNumsFlags.push('0');
  defaultAnswersNumsFlags.push('0');  
  defaultAnswersNumsFlags.push('0');
  defaultAnswersNumsFlags.push('0');
  defaultAnswersNumsFlags.push('0');
  defaultAnswersNumsFlags.push('0');  
  defaultAnswersNumsFlags.push('0');
  defaultAnswersNumsFlags.push('0');  
  defaultAnswersNumsFlags.push('0');
  defaultAnswersNumsFlags.push('0'); 

}

/**************************************************************************
 * getControlRefs() */
/**
 * Gets references to methods in controls we want to work with
 **************************************************************************/
    
function getControlRefs() 
{
  sbPracSelect  = $('#pracids').data('spedmonSelectBox');
  sbCalSelect   = $('#calendarid').data('spedmonSelectBox');
  sbSchSelect   = $('#scheduleid').data('spedmonSelectBox'); 
  dgPracDetails = $('#details_pracs_all').data('spedmondatagrid');
  dgTmtBS       = $('#details_tmt_bs').data('spedmondatagrid');
  dgTmtDS1      = $('#details_tmt_ds_ind').data('spedmondatagrid');
  dgTmtDS2      = $('#details_tmt_ds_grp').data('spedmondatagrid');
  dgTmtAS       = $('#details_tmt_as').data('spedmondatagrid');
  dgTran1       = $('#details_trans_hm_ss').data('spedmondatagrid');
  dgTran2       = $('#details_trans_ss_hm').data('spedmondatagrid');
  dgTran3       = $('#details_trans_ss_os').data('spedmondatagrid');
  dgTran4       = $('#details_trans_os_ss').data('spedmondatagrid');
}

/**************************************************************************
 * clearServiceDetailGrids() */
/**
 * Clears the service detail grids
 **************************************************************************/

function clearServiceDetailGrids()
{
  getControlRefs();
  dgTmtBS.clear();
  dgTmtDS1.clear();
  dgTmtDS2.clear();
  dgTmtAS.clear();
  dgTran1.clear();
  dgTran2.clear();
  dgTran3.clear();
  dgTran4.clear();
 }
    
/**************************************************************************
 * clearPracDetailGrid() */
/**
 * Clear the prac details grid
 **************************************************************************/

function clearPracDetailGrid()
{
  getControlRefs();
  dgPracDetails.clear();
}

/**************************************************************************
 * clearAllGrids() */
/**
 * Clears all data grids
 **************************************************************************/
  
function clearAllGrids()
{ 
  clearPracDetailGrid();
  clearServiceDetailGrids();
}

/***************************************************************************
 * checkMinutesInGrid */
/**
 * Check grid for empty minutes rows
 **************************************************************************/

function checkMinutesInGrid(e)
{
  var numbersDataGridID = e.dataitem.id;  
  var numbersDataStr    = e.dataitem.value;  
  var numbersDataObj    = jQuery.parseJSON(numbersDataStr);
  var valuesOK          = true;
  
  $.each(numbersDataObj, function(i, details) {    
    $.each(details, function(j,detail) {  
    
      if (((detail.numMinsMon == '0') || (detail.numMinsMon == '')) &&
          ((detail.numMinsTue == '0') || (detail.numMinsTue == '')) &&       
          ((detail.numMinsWed == '0') || (detail.numMinsWed == '')) &&
          ((detail.numMinsThu == '0') || (detail.numMinsThu == '')) &&
          ((detail.numMinsFri == '0') || (detail.numMinsFri == '')))
      { 
        valuesOK = false;
      }   
    });
  });
  return valuesOK;  
}

/***************************************************************************
 * checkMilesInGrid */
/**
 * Check grid for empty miles rows
 ***************************************************************************/

function checkMilesInGrid(e)
{
  var numbersDataGridID = e.dataitem.id;  
  var numbersDataStr    = e.dataitem.value;  
  var numbersDataObj    = jQuery.parseJSON(numbersDataStr);    
  var valuesOK          = true;
  
  $.each(numbersDataObj, function(i, details) {    
    $.each(details, function(j,detail) {
    
      if (((detail.numMilesMon == '0') || (detail.numMilesMon == '')) &&
          ((detail.numMilesTue == '0') || (detail.numMilesTue == '')) &&       
          ((detail.numMilesWed == '0') || (detail.numMilesWed == '')) &&
          ((detail.numMilesThu == '0') || (detail.numMilesThu == '')) &&
          ((detail.numMilesFri == '0') || (detail.numMilesFri == '')))
      {      
        valuesOK = false;
      }   
    });
  });
  
  return valuesOK;
}

/***************************************************************************
 * hasAllDayFlags() */
/**
 * See if a grid has any all day flags checked
 **************************************************************************/
   
function hasAllDayFlags(e)
{
  var flagsDataGridID = e.dataitem.id;  
  var flagsDataStr    = e.dataitem.value;  
  var flagsDataObj    = jQuery.parseJSON(flagsDataStr);  
  var hasFlags        = false;
  
  $.each(flagsDataObj, function(i, details) {    
    $.each(details, function(j,detail) {
    
      if ((detail.scheduleMon == 'true') || 
          (detail.scheduleTue == 'true') || 
          (detail.scheduleWed == 'true') || 
          (detail.scheduleThu == 'true') || 
          (detail.scheduleFri == 'true'))
          
      {
        hasFlags = true;
      }   
    });
  });
  
  return hasFlags;    
}

/***************************************************************************
 * checkFlagsAndMinutes() */
/**
 * Check grid for empty flags or minute rows
 **************************************************************************/
   
function checkFlagsAndMinutes(e)
{
  var flagsDataGridID = e.dataitem.id;  
  var flagsDataStr    = e.dataitem.value;  
  var flagsDataObj    = jQuery.parseJSON(flagsDataStr);  
  var valuesOK        = true;
  
  $.each(flagsDataObj, function(i, details) {    
    $.each(details, function(j,detail) {  
                
      if (((detail.scheduleMon == 'false') || (detail.scheduleMon == '')) &&
          ((detail.scheduleTue == 'false') || (detail.scheduleTue == '')) &&       
          ((detail.scheduleWed == 'false') || (detail.scheduleWed == '')) &&
          ((detail.scheduleThu == 'false') || (detail.scheduleThu == '')) &&
          ((detail.scheduleFri == 'false') || (detail.scheduleFri == '')) &&
          ((detail.numMinsMon  == '0')     || (detail.numMinsMon  == '')) &&
          ((detail.numMinsTue  == '0')     || (detail.numMinsTue  == '')) &&       
          ((detail.numMinsWed  == '0')     || (detail.numMinsWed  == '')) &&
          ((detail.numMinsThu  == '0')     || (detail.numMinsThu  == '')) &&
          ((detail.numMinsFri  == '0')     || (detail.numMinsFri  == '')))
      {
        valuesOK = false;
      }   
    });
  });
  
  return valuesOK;    
}

/***************************************************************************
 * validateTmtBSOrAS() */
/**
 * Validate treatment before or after school grid
 **************************************************************************/
   
function validateTmtBSOrAS(e,nextStep)
{
  var minsOK = false;
  
  minsOK = checkMinutesInGrid(e) ;
 
  if (minsOK == false)
  {
    showMissingDetailMsgTmtBSAS();
    return;
  }  
  
  $('#save_steps').accordion('activate', nextStep);
}

/***************************************************************************
 * validateTmtDS() */
/**
 * Validate treatment during school row
 ***************************************************************************/
   
function validateTmtDS(e,nextStep,calStep)
{  
  var flagsMinsOK  = checkFlagsAndMinutes(e);
  var hasFlags     = hasAllDayFlags(e);    
  
  if (flagsMinsOK == false)
  {
    showMissingDetailMsgTmtDS();
    return;
  }
  
  /* If the reason the values are OK is because the flags are OK check to make sure the calendar and bell schedule exists*/

  if (hasFlags == true)
  {  
    var hasCal     = $('#calendarid').val();
    var hasBell    = $('#scheduleid').val();    
    var hasCalBell = false;
  
    if ((hasCal) && (hasBell)) hasCalBell = true;
 
    if (hasCalBell == false)
    {
      var switchToCal = function(){$('#save_steps').accordion('activate', calStep);};
      showMissingDetailMsgCalBell(switchToCal);      
      return;
    }
  }  
  
  $('#save_steps').accordion('activate', nextStep);
  return;

}

/***************************************************************************
 * validateTrans() */
/**
 * Validate transporation
 ***************************************************************************/
   
function validateTrans(e,nextStep)
{
  var milesOK = false;
  
  milesOK = checkMilesInGrid(e) ;
 
  if (milesOK == false)
  {
    showMissingDetailMsgTrans();
    return;
  }
  
  $('#save_steps').accordion('activate', nextStep);
    
}

/**************************************************************************
 * switchBetweenFlagOrNumber() */
/**
 * Switch between a flag or number if applicable
 *************************************************************************/

function switchBetweenFlagOrNumber(e)
{
  
  var lastFld   = $(e.target);
  var lastCell  = $(lastFld).closest('td');
  var nextCell  = $(lastCell).next();
  var nextFld   = $(nextCell).find('input.mba-web-ui-field-data-number').first();
       
  if (lastFld.attr('type') == 'checkbox')
  {        
    if (nextFld.attr('type') == 'text')
    {            
      /* We are only looking at checkbox/number groups */
      
      var lastCheckVal = lastFld.attr('checked');
      var allDay = lastCell.attr('data-copy-value-right');
      
      /* Checked, set number to 0 and hide number */
      
      if (lastCheckVal)
      {
        nextFld.val(0);
        nextFld.hide();
      }
      
      /* Unchecked, show number */
      
      else
      {
        nextFld.show();
      }        
      
      /* Handle extra work for all day case */
            
      if (allDay == 'data-copy-value-right')
      {
         var nextCells = $(lastCell).nextAll();
                  
         $.each(nextCells, function(i,cell)
         {
           /* Looking for all numbers */
           
           var fld = $(cell).find('input.mba-web-ui-field-data-number').first();           
           
           if (fld)
           {
             /* Checked, set number to 0 and hide number */

             if (lastCheckVal)
             {
               fld.val(0);
               fld.hide();
             }
             else
             {
               fld.show();
             }        
           }
         });
       } /* all day */          
    } /* text */          
  } /* check */
  return;
}

/**************************************************************************
 * updateStartEndDates() */
/**
 * When the school year is changed this updates the start and end dates
 **************************************************************************/

function updateStartEndDates(e,nextStep)
{
  var di = e.dataitem;
  
  if (di)
  {
    var dr1 = di.context1;
    var dr2 = dr1.replace(/-/g, "/")
    var dra = dr2.split("to");
        
    var sd = dra[0].trim();
    var ed = dra[1].trim();

    $('#startdate').spedmonInput_setValue(sd);
    $('#step4_step_label').text(sd);

    $('#enddate').spedmonInput_setValue(ed);
    $('#step5_step_label').text(ed);

    $('#save_steps').accordion('activate', nextStep);
  }
}

/**************************************************************************
 * addRowPracDetail() */
/**
 * Practitioner details data grid add new handler
 *
 **************************************************************************/

function addRowPracDetail(dgObj,rowObj)
{
  /* Get practitioner title */
    
  var pracTitleTd  = rowObj.find('td:nth-child(4)');
  var pracTitleSp  = $(pracTitleTd).find('span');
  var pracTitleStr = $(pracTitleSp).text() + '';
  var pracTitle    = pracTitleStr.toLowerCase();
  var idxOfTrans   = pracTitle.search('bus driver');

  /* If it is a practitioner that provides treatment hide the transportation options */
  
  if (idxOfTrans == -1)
  {
    /* Hide transporation */
    for (cn = 9; cn < 13; cn++) {
      var colSel = 'td:nth-child(' + cn + ')';
      var detCell = rowObj.find(colSel);
      var detSpan = $(detCell).children('span').first();
      $(detSpan).hide();
     }
   }
   
   /* If it is a practitioner that provides transportation hide the treatment options */
  
   else 
   {
     /* Hide treatment */
     for (cn = 5; cn < 9; cn++) {
       var colSel = 'td:nth-child(' + cn + ')';
       var detCell = rowObj.find(colSel);
       var detSpan = $(detCell).children('span').first();
       $(detSpan).hide();
     }
   }
}

/**************************************************************************
 * removeRowPracDetail() */
/**
 * Practitioner details data grid remove handler
 *
 **************************************************************************/

function removeRowPracDetail(dgObj,rowObj)
{

}

/**************************************************************************
 * getSvcDetailStep() */
/**
 * Retrieves the step that the service detail grid is a child of
 *
 **************************************************************************/

function getSvcDetailStep(dgObj)
{
  var dgStepContent = dgObj.parents('div.ui-spedmon-step-content').parent();
  var dgStep        = dgStepContent.prev('h3');
  return dgStep;
}

/**************************************************************************
 * addRowSvcDetail() */
/**
 * Called when a row is added to a service detail grid
 *
 **************************************************************************/

function addRowSvcDetail(dgObj,rowObj)
{
  var dgStep = getSvcDetailStep(dgObj);
  $(dgStep).spedmonStep_highlight(true);
}

/**************************************************************************
 * removeRowSvcDetail() */
/**
 * Called when a row is removed from a service detail grid
 *
 **************************************************************************/
 
function removeRowSvcDetail(dgObj,rowObj)
{
  var dg     = $(dgObj).data('spedmondatagrid');
  var dgStep = getSvcDetailStep(dgObj);
  if (!dg.hasData())
    $(dgStep).spedmonStep_highlight(false);
}

/**************************************************************************
 * addSelPracDetail() */
/**
 * Called when a practitioner selction is made (added)
 *
 **************************************************************************/
 
function addSelPracDetail(selObj)
{  
  if (selObj)
  {
    getControlRefs();
    var newArgs  = [];
    var newKey   = selObj.value + ''; /* Create a string version of key */   
    var newName  = selObj.name;
    var newTitle = selObj.contextlabel;     
    newArgs.push(newName);
    newArgs.push(newTitle);
    dgPracDetails.addRowByKeyWithValues(newKey, newArgs);
  }
}

/**************************************************************************
 * removeSelPracDetail() */
/**
 * Called when a practitioner selction is removed
 *
 **************************************************************************/

function removeSelPracDetail(selObj)
{
  if (selObj)
  {
    getControlRefs();
    
    /* Create string version of practitioner key */
    var existingKey = selObj.value + ''; 
    
    /* Remove practitioner from each grid */
    
    dgPracDetails.removeRowByKey(existingKey);
    
    dgTmtBS.removeRowByKey(existingKey);
    dgTmtDS1.removeRowByKey(existingKey);
    dgTmtDS2.removeRowByKey(existingKey);
    dgTmtAS.removeRowByKey(existingKey);
    
    dgTran1.removeRowByKey(existingKey);
    dgTran2.removeRowByKey(existingKey);
    dgTran3.removeRowByKey(existingKey);
    dgTran4.removeRowByKey(existingKey);
  }
}

/***************************************************************************
 * updateSvcDetails */
/**
 * Add or remove practitioenr from service detail grids based on services
 * provided flags in practitioner details grid
 ***************************************************************************/

function updateSvcDetails(e)
{
  getControlRefs();
  
  var pDetailsObj = dgPracDetails.getData();
  
  $.each(pDetailsObj, function(i, details) { 
  
    $.each(details, function(j,detail){
     
      /* Get currrent prac id (key) */    
      
      var keyStr  = detail.pracID;      
    
      /* Get prac details (first values) */    
    
      var pracDetailsArr = [];
      pracDetailsArr.push(detail.pracName);
      pracDetailsArr.push(detail.pracTitle);
      
      /* Create new value array that contains prac details and common defaults */
      
      var newValsArrAll = pracDetailsArr.concat(defaultAnswersIEP);
      
      /* Contain the two values arrays we will use */
      
      var newValsArrMinsOrMiles = newValsArrAll.concat(defaultAnswersNums);
      var newValsArrFlgsOrMins  = newValsArrAll.concat(defaultAnswersNumsFlags);
                      
      if (detail.tmtBS     == 'true') {dgTmtBS.addRowByKeyWithValues  (keyStr, newValsArrMinsOrMiles); } else {dgTmtBS.removeRowByKey(keyStr);}
      if (detail.tmtDSInd  == 'true') {dgTmtDS1.addRowByKeyWithValues (keyStr, newValsArrFlgsOrMins);  } else {dgTmtDS1.removeRowByKey(keyStr);}
      if (detail.tmtDSGrp  == 'true') {dgTmtDS2.addRowByKeyWithValues (keyStr, newValsArrFlgsOrMins);  } else {dgTmtDS2.removeRowByKey(keyStr);}
      if (detail.tmtAS     == 'true') {dgTmtAS.addRowByKeyWithValues  (keyStr, newValsArrMinsOrMiles); } else {dgTmtAS.removeRowByKey(keyStr);}
      if (detail.transHmSs == 'true') {dgTran1.addRowByKeyWithValues  (keyStr, newValsArrMinsOrMiles); } else {dgTran1.removeRowByKey(keyStr);}
      if (detail.transSsHm == 'true') {dgTran2.addRowByKeyWithValues  (keyStr, newValsArrMinsOrMiles); } else {dgTran2.removeRowByKey(keyStr);}
      if (detail.transSsOs == 'true') {dgTran3.addRowByKeyWithValues  (keyStr, newValsArrMinsOrMiles); } else {dgTran3.removeRowByKey(keyStr);}
      if (detail.transOsSs == 'true') {dgTran4.addRowByKeyWithValues  (keyStr, newValsArrMinsOrMiles); } else {dgTran4.removeRowByKey(keyStr);}

    });
  });  
}

/***************************************************************************
 * validatePracDetailsAndUpdateSvcDetails */
/**
 * Validates practitioner details.
 ***************************************************************************/

function validatePracDetails(e,nextStep)
{
  /* Look at prac details and make sure they are valid */
  
  var flagsDataGridID = e.dataitem.id;  
  var flagsDataStr    = e.dataitem.value;  
  var flagsDataObj    = jQuery.parseJSON(flagsDataStr);  
  var valuesOK        = true;
  
  $.each(flagsDataObj, function(i, details) {    
    $.each(details, function(j,detail){
                 
      if (((detail.tmtBS     == 'false') || (detail.tmtBS     == '')) &&
          ((detail.tmtDSInd  == 'false') || (detail.tmtDSInd  == '')) &&   
          ((detail.tmtDSGrp  == 'false') || (detail.tmtDSGrp  == '')) &&           
          ((detail.tmtAS     == 'false') || (detail.tmtAS     == '')) &&
          ((detail.transSsOs == 'false') || (detail.transSsOs == '')) &&
          ((detail.transOsSs == 'false') || (detail.transOsSs == '')) &&
          ((detail.transHmSs == 'false') || (detail.transHmSs == '')) &&
          ((detail.transSsHm == 'false') || (detail.transSsHm == '')))
      {
        valuesOK = false;
      }         
    });
  });
  
  /* If they are not valid let the user know */
  
  if (valuesOK == false)
  {
    showMissingDetailMsgPrac();
    return;
  }
   
  $('#save_steps').accordion('activate', nextStep); 
}

/***************************************************************************
 * checkDups */
/**
 * Checks for duplicate records
 ***************************************************************************/

function checkDups (stepid)
{
  var tkn     = $.spedmonWebUI.token;
  var cltid   = $('#clientid').val();
  var patid   = $('#patid').val();
  var fyid    = $('#fiscalyearid').val();
  var sdate   = $('#startdate').val();
  var edate   = $('#enddate').val();
  var recid   = $('#recid').val();
  var stp     = '#' + stepid
  var $stp    = $(stp);
  
  var hasDups = null;
      
  if (!tkn)   return;
  if (!cltid) return;
  if (!patid) return;
  if (!fyid)  return;
  if (!sdate) return;
  if (!edate) return;
      
  var url = "recurringservices.asmx/viewPossibleDups?tkn=" + tkn;

  var $data = "{"
    + "'clientid':"      + cltid 
    + ",'patid':"        + patid
    + ",'fiscalyearid':" + fyid 
    + ",'startdate':"    + "'" + sdate + "'"
    + ",'enddate':"      + "'" + edate + "'"
    + ",'recid':"        + "'" + recid + "'"
    + "}";
          
  $.spedmonWebUI.ajax($stp, url, $data, null, null, 
     
    function(rd) {
      if (rd.data.hasRecords == true)
      {
        hasDups = true;
      }
      else
      {
        hasDups = false;
      }
    },
    null, null, 0,
    function() {
      if (hasDups == true){
        showDupMsg(); 
      }
    }      
  );
  return;
}

/**************************************************************************
 * Standard validate and save functions
 **************************************************************************/

function doValidate()
{  
  $('#validaterec').val('1');
  var $sn = $("#save");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,function(){$st.spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,'Your record is ready to save. Please SELECT AN OPTION BELOW.',0)});
}

function doSave (saveType,fnSuccess)
{
  $('#validaterec').val('0');
  $('#savetype').val(saveType);
  var $sn = $("#save");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,fnSuccess);
} 

function doEnd (saveType, fnSuccess)
{
  $('#validaterec').val('0');
  $('#savetype').val(saveType);
  var $sn = $("#save");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,fnSuccess);
}

function doCopy ()
{
  var saveType  = $.spedmonWebUI.RECORD_SAVE_TYPE_COPY;
  var recID     = $('#recid').val();
  var effDate   = $('#effectivedate').val();
  var actionURL = $('#actionurl').val();  
  var data = "&recid=" + recID + "&savetype=" + saveType + "&effdate=" + effDate;
  var url  = actionURL + data;
  $.spedmonWebUI.gotoURL(url);
}

function doEndAndCopy () {doEnd($.spedmonWebUI.RECORD_SAVE_TYPE_DEACTIVATE, function(){doCopy();});}
function doEndAndQuit () {doEnd($.spedmonWebUI.RECORD_SAVE_TYPE_DEACTIVATE, function(){doGoHome();});}

function doCopyAndQuit() {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_COPY,  function(){doGoHome();});};
function doClear      () {$.spedmonWebUI.gotoMenuLink('addnewrcrsvcloadlink');}

function doSaveNew      () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW,  function(){doClear();})}
function doSaveNewPat   () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW,  function(){save_steps_clear(5);$('#save_steps').accordion('option','active',5);});}
function doSaveAndQuit  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW,  function(){doGoHome();});}

function doGoHome       () {$.spedmonWebUI.gotoMenuLink('homePageLink');}
                             
function doGoList       () {$.spedmonWebUI.gotoMenuLink('editdelrcrsvcrecslink');}
function doEdit         () {$.spedmonWebUI.dialogConfirmReason('Edit this Record ?',
                                                               'Are you sure you want to save your changes to this record?',
                                                               function(){
                                                                 var res  = $('#dialogConfirmReasonText').val();
                                                                 $('#editDelReason').val(res);
                                                                 doSave($.spedmonWebUI.RECORD_SAVE_TYPE_EDIT,function(){doGoList()})},
                                                               function(){});}
                                
                               
/**************************************************************************
 * Init when page is ready
 **************************************************************************/

 $(function() {
  setDefaultAnswers();
});

