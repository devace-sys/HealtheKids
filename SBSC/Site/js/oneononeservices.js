/***************************************************************************
 * oneononeservices.js */
/**
 * Scripts specific to one on one services
 ***************************************************************************/

/**************************************************************************
 * Expected services object
 **************************************************************************/
       
var objExpectedSvcs = null;

/**************************************************************************
 * Control References (for method invocation)
 **************************************************************************/

var dgTmtBS         = null;
var dgTmtDS         = null;
var dgTmtAS         = null;
var tblOverviewRows = null;
var divPracNotes    = null;
var svcMonth        = null;

/**************************************************************************
 * Messages
 **************************************************************************/

function showMissingDetailMsg (errTitle,errMsg, fnOK)
{
  if (!fnOK) fnOK = function(){};
  $.spedmonWebUI.dialogMessage (errTitle, errMsg, true, 400, 300, fnOK);
}

function getSvcMonth()
{
  svcMonth = $('#dos').val();
}

/**************************************************************************
 * populateStartAndEndDates () */
/**
 * Using reference date, populate start and end dates
 **************************************************************************/
 
function populateStartAndEndDates(nextStep)
{
  getSvcMonth();
  
  if (svcMonth)
  {
    var sd    = $.spedmonWebUI.calculateStartDate (svcMonth, 2);
    var ed    = $.spedmonWebUI.calculateEndDate   (svcMonth, 2);        
    var sdStr = $.datepicker.formatDate ("mm/dd/yy", sd);
    var edStr = $.datepicker.formatDate ("mm/dd/yy", ed);

    $('#startdateds').spedmonInput_setValue(sdStr);   
    $('#enddateds').spedmonInput_setValue(edStr);

    $('#startdatebs').spedmonInput_setValue(sdStr);   
    $('#enddatebs').spedmonInput_setValue(edStr);

    $('#startdateas').spedmonInput_setValue(sdStr);   
    $('#enddateas').spedmonInput_setValue(edStr);
    
    $('#save_steps').accordion('activate', nextStep);
  }
  else
  {
    showMissingDetailMsg ('Service Month Missing','Please enter or select the first day of the month that services were provided.', null)
  }
}

/**************************************************************************
 * changeStepLabelWhatServices (stepid) */
/**
 * Handles data selected events for what services are you inputing step
 **************************************************************************/

 function changeStepLabelWhatServices (stepid)
{
  var stpid = '#' + stepid;
  $(stpid).spedmonStep_setLabel('');
}

/**************************************************************************
 * manageRowMarkedAbsent (fcr,dets) */
/**
 * Manage a grid row marked absent
 **************************************************************************/

function manageRowMarkedAbsent (fcr, dets)
{  
  if (!dets.absent)
  {    
    $(fcr.lastRow).removeClass('ui-spedmon-strike-through');
  }
  else
  {
    $(fcr.lastRow).addClass('ui-spedmon-strike-through');
  }
  return dets.absent;
}

/**************************************************************************
 * getOptionsFromRow (lastRow) */
/**
 * Get options from options section of grid row
 **************************************************************************/

 function getOptionsFromRow (lastRow)
{
  var opts              = {};
  
  var optionCells       = $(lastRow).find('td.Options span');
  var optionCheckBoxes  = $(optionCells).find('input[type=checkbox]');
  var calculateMinutes  = false;  
  var skipEntry         = false;
  
  calculateMinutes      = $(optionCheckBoxes[0]).attr('checked');
  skipEntry             = $(optionCheckBoxes[1]).attr('checked');
  
  opts.optionCells      = optionCells;  
  opts.optionCheckBoxes = optionCheckBoxes;
  opts.calculateMinutes = calculateMinutes;
  opts.skipEntry        = skipEntry;
  
  return opts;
}

/**************************************************************************
 * getDetailsFromRow (fcr) */
/**
 * Get details from detail section of grid row
 **************************************************************************/

function getDetailsFromRow (lastRow)
{

  var dets             = {};  
  var detailCells      = $(lastRow).find('td.Details span');
  
  var absentCheckBox   = $(detailCells[2]).find('input[type=checkbox]');  
  var absent           = false;
  var dos              = $(detailCells[0]).html();
  var minsBox          = $(detailCells[3]).find('input[type=text]');  
  absent               = $(absentCheckBox).attr('checked');
  
  dets.detailCells     = detailCells;
  dets.absentCheckBox  = absentCheckBox;
  dets.absent          = absent;
  dets.dos             = dos;
  dets.minsBox         = minsBox;
    
  return dets;
}

/**************************************************************************
 * getPeriodsFromRow (e) */
/**
 * Get periods from period section of grid row
 **************************************************************************/
 
function getPeriodsFromRow (lastRow)
{
  var pers             = {};
  var periodCells      = $(lastRow).find('td.Periods span');
  var periodCheckBoxes = $(periodCells).find('input[type=checkbox]');
  var absentFlags      = {};
  
  $.each(periodCheckBoxes, function (key, checkbox)
  {    
    var fv = false;    
    if ($(checkbox).attr('checked')) fv = true;    
    absentFlags[key] = fv;  
  });
  
  pers.periodCells      = periodCells;
  pers.periodCheckBoxes = periodCheckBoxes;
  pers.absentFlags      = absentFlags;
  
  return pers;
}


/**************************************************************************
 * getFldCellRowData (e) */
/**
 * Get field, cell and row data for cell clicked on in grid
 **************************************************************************/
 
function getFldCellRowData(e)
{
  var fcr = {};
  
  var lastFld  = $(e.target);
  var lastCell = $(lastFld).closest('td');  
  var lastRow  = $(lastCell).closest('tr');    
  
  fcr.lastFld  = lastFld;
  fcr.lastCell = lastCell;
  fcr.lastRow  = lastRow;
  
  return fcr;
}

/**************************************************************************
 * calculateBSMinutes() */
/**
 * Calculate BS minutes
 **************************************************************************/

function calculateBSMinutes (e)
{    
  var fcr    = getFldCellRowData     (e);
  var dets   = getDetailsFromRow     (fcr.lastRow);
  var absent = manageRowMarkedAbsent (fcr,dets);
  
  if (absent) return;
  
  var opts = getOptionsFromRow (fcr.lastRow)
  if (!opts.calculateMinutes) return; 
  var cm = objExpectedSvcs.bsData.ComputeMinutes(dets.dos);   
  $(dets.minsBox).val(cm.present);

  
  return;
}

/**************************************************************************
 * calculateASMinutes() */
/**
 * Calculate AS minutes
 **************************************************************************/

function calculateASMinutes (e)
{    
  var fcr    = getFldCellRowData     (e);
  var dets   = getDetailsFromRow     (fcr.lastRow);
  var absent = manageRowMarkedAbsent (fcr,dets);
  
  if (absent) return;
  
  var opts = getOptionsFromRow (fcr.lastRow)
  if (!opts.calculateMinutes) return; 
  var cm = objExpectedSvcs.asData.ComputeMinutes(dets.dos);   
  $(dets.minsBox).val(cm.present);

  return;
}

/**************************************************************************
 * calculateDSMinutes() */
/**
 * Populate services data grids with expected service data
 **************************************************************************/

function calculateDSMinutes(e)
{    
  var fcr    = getFldCellRowData     (e);
  var dets   = getDetailsFromRow     (fcr.lastRow);
  var absent = manageRowMarkedAbsent (fcr,dets);
  
  if (absent) return;
  
  var opts = getOptionsFromRow (fcr.lastRow)
  
  if (!opts.calculateMinutes) return; 
  
  var pers = getPeriodsFromRow (fcr.lastRow);
   
  var ap = objExpectedSvcs.dsData.ComputeAbsentPeriods(pers.absentFlags);
  var cm = objExpectedSvcs.dsData.ComputeMinutes(dets.dos,ap);
   
  $(dets.minsBox).val(cm.present);    
}

/**************************************************************************
 * addRowToDSGrid (detail) */
/**
 * Adds row to during school data grid
 **************************************************************************/
 
function addRowToDSGrid (detail)
{
    
  
  var rid = dgTmtDS.addRowNoUpdate (detail.dos, detail.pracName, false, detail.numMinsExpd, 
                          false, false, false, false, false, false, false, false, false, false, false,                        
                          detail.when, detail.inIEP, detail.pracID, detail.nameID, detail.key, objExpectedSvcs.dsData.HasPeriods,detail.skipEntry);          
  /*-------------------------------
   * If the school has periods
   *------------------------------*/     
    
  if (objExpectedSvcs.dsData.HasPeriods == true)     
  {
    /* Get reference to row we just added */
      
    var nr = $(rid);      
      
    /* Find the cells */
      
    var pcells = $(nr).find('td.Periods span');
      
    $(pcells).show();
      
    if (detail.minPeriod[0]  == 0) $(pcells[0]).hide();
    if (detail.minPeriod[1]  == 0) $(pcells[1]).hide();
    if (detail.minPeriod[2]  == 0) $(pcells[2]).hide();
    if (detail.minPeriod[3]  == 0) $(pcells[3]).hide();
    if (detail.minPeriod[4]  == 0) $(pcells[4]).hide();
    if (detail.minPeriod[5]  == 0) $(pcells[5]).hide();
    if (detail.minPeriod[6]  == 0) $(pcells[6]).hide();
    if (detail.minPeriod[7]  == 0) $(pcells[7]).hide();
    if (detail.minPeriod[8]  == 0) $(pcells[8]).hide();
    if (detail.minPeriod[9]  == 0) $(pcells[9]).hide();
    if (detail.minPeriod[10] == 0) $(pcells[10]).hide();
  }
    
}

/**************************************************************************
 * addRowToBSGrid (detail) */
/**
 * Adds row to before school data grid
 **************************************************************************/

function addRowToBSGrid (detail)
{
  dgTmtBS.addRowNoUpdate (detail.dos, detail.pracName, false, detail.numMinsExpd, 
                          false, false, false, false, false, false, false, false, false, false, false,                        
                          detail.when, detail.inIEP, detail.pracID, detail.nameID, detail.key, false, detail.skipEntry);     
}

/**************************************************************************
 * addRowToASGrid (detail) */
/**
 * Adds row to after school data grid
 **************************************************************************/

function addRowToASGrid (detail)
{
  dgTmtAS.addRowNoUpdate (detail.dos, detail.pracName, false, detail.numMinsExpd, 
                          false, false, false, false, false, false, false, false, false, false, false,                        
                          detail.when, detail.inIEP, detail.pracID, detail.nameID, detail.key, false, detail.skipEntry);         

}

/**************************************************************************
 * populateASGrid (nextStep) */
/**
 * Populates after school grid
 **************************************************************************/

function populateASGrid(nextStep)
{
 
  // Ready grid
  
  dgTmtAS = $('#detailsas').data('spedmondatagrid');
  dgTmtAS.clear();
 
  var i = 0;
  
  function doWork()
  {
   
    // Inc row ctr
     
    if (++i <= objExpectedSvcs.asData.rowCount) 
    { 
      // Get detail
      
      var detail = objExpectedSvcs.as[i];
    
      // Add row
      
      addRowToASGrid (detail);
      
      // Add more rows, yielding to browser
      
      setTimeout(doWork, 0);
    }
    else
    {
      // Tidy up
      
      dgTmtAS.updateRowData(); 
      dgTmtAS.hideSection('Periods');  
      dgTmtAS.hideSection('HiddenData');
      //dgTmtAS.hideSection('Options');  
      
      // Finish chain
      $.spedmonWebUI.dialogWaitHide();
      $('#save_steps').accordion('activate', nextStep);
      
    }
  };
  
  // Init call
  
  doWork();
  
}

/**************************************************************************
 * populateBSGrid (nextStep) */
/**
 * Populates before school grid
 **************************************************************************/

function populateBSGrid(nextStep)
{
 
  // Ready grid
  
  dgTmtBS = $('#detailsbs').data('spedmondatagrid');
  dgTmtBS.clear();
 
  var i = 0;
  
  function doWork()
  {
   
    // Inc row ctr
     
    if (++i <= objExpectedSvcs.bsData.rowCount) 
    { 
      // Get detail
      
      var detail = objExpectedSvcs.bs[i];
    
      // Add row
      
      addRowToBSGrid (detail);
      
      // Add more rows, yielding to browser
      
      setTimeout(doWork, 0);
    }
    else
    {
      // Tidy up
      dgTmtBS.updateRowData(); 
      dgTmtBS.hideSection('Periods');  
      dgTmtBS.hideSection('HiddenData');
      //dgTmtBS.hideSection('Options');  
      
      // Continue chain
      
      populateASGrid(nextStep);
      
    }
  };
  
  // Init call
  
  doWork();
  
}


/**************************************************************************
 * populateDSGrid (nextStep) */
/**
 * Populates during school grid
 **************************************************************************/

function populateDSGrid(nextStep)
{
 
  $.spedmonWebUI.dialogWaitShow("Populating grids please wait");
  
  // Ready grid
  
  dgTmtDS = $('#detailsds').data('spedmondatagrid');
  dgTmtDS.clear();
 
  var i = 0;
  
  function doWork()
  {
   
    // Inc row ctr
     
    if (++i <= objExpectedSvcs.dsData.rowCount) 
    { 
      // Get detail
      var detail = objExpectedSvcs.ds[i];
    
      // Add row
      addRowToDSGrid (detail);
      
      // Add more rows, yielding to browser
      setTimeout(doWork, 0);
    }
    else
    {
      // Tidy up
      dgTmtDS.updateRowData(); 
      if (objExpectedSvcs.dsData.HasPeriods == true) dgTmtDS.showSection('Periods'); else dgTmtDS.hideSection('Periods');
      dgTmtDS.hideSection('HiddenData');
      
      // Continue chain
      populateBSGrid(nextStep);
      
    }
  };
  
  // Init call
  
  doWork();
  
}

/**************************************************************************
 * createExpectedServicesObj () */
/**
 * Creates empty object
 **************************************************************************/
 
function createExpectedServicesObj()
{
  /*============================================================
   * Create structure
   *============================================================*/

  objExpectedSvcs = null;  
  objExpectedSvcs = {};  
  
  objExpectedSvcs.pracData     = {};
  objExpectedSvcs.svcOverviews = {};
  
  objExpectedSvcs.bs = {};
  objExpectedSvcs.ds = {};
  objExpectedSvcs.as = {};
  
  objExpectedSvcs.bsData = {};
  objExpectedSvcs.asData = {};
  objExpectedSvcs.dsData = {}; 
  
  objExpectedSvcs.bsData.rowCount = 0;
  objExpectedSvcs.dsData.rowCount = 0;
  objExpectedSvcs.asData.rowCount = 0;
  
  /*============================================================
   * During school data properties and methods
   *============================================================*/

  /**************************************************************************
   * HasPeriods () */
  /**
   * Does the site have periods
   **************************************************************************/  

  objExpectedSvcs.dsData.HasPeriods = false;   
  
  /**************************************************************************
   * computeAbsentPeriods () */
  /**
   * Takes data returned from server and extracts expected services info
   **************************************************************************/  
  
  objExpectedSvcs.dsData.ComputeAbsentPeriods = function (absentFlags) {

    var ap = {};
    
    ap.absentPeriod  = {};
    ap.absentPassing = {};
    
    /*============================================================
     * Init
     *============================================================*/

    ap.absentPeriod[0]  = false;
    ap.absentPeriod[1]  = false;
    ap.absentPeriod[2]  = false;
    ap.absentPeriod[3]  = false;
    ap.absentPeriod[4]  = false;
    ap.absentPeriod[5]  = false;
    ap.absentPeriod[6]  = false;
    ap.absentPeriod[7]  = false;
    ap.absentPeriod[8]  = false;
    ap.absentPeriod[9]  = false;
    ap.absentPeriod[10] = false;

    ap.absentPassing[0] = false;
    ap.absentPassing[1] = false;
    ap.absentPassing[2] = false;
    ap.absentPassing[3] = false;
    ap.absentPassing[4] = false;
    ap.absentPassing[5] = false;
    ap.absentPassing[6] = false;
    ap.absentPassing[7] = false;
    ap.absentPassing[8] = false;
    ap.absentPassing[9] = false;

    ap.absentPeriod[0]  = absentFlags[0];
    ap.absentPeriod[1]  = absentFlags[1];
    ap.absentPeriod[2]  = absentFlags[2];
    ap.absentPeriod[3]  = absentFlags[3];
    ap.absentPeriod[4]  = absentFlags[4];
    ap.absentPeriod[5]  = absentFlags[5];
    ap.absentPeriod[6]  = absentFlags[6];
    ap.absentPeriod[7]  = absentFlags[7];
    ap.absentPeriod[8]  = absentFlags[8];
    ap.absentPeriod[9]  = absentFlags[9];
    ap.absentPeriod[10] = absentFlags[10];
        
    /* Absent for period 0. Then absent for passing period from 0 to 1 */
  
    if (ap.absentPeriod[0] == true)  
    {
      ap.absentPassing[0] = true;
    } 

    /* Absent for period 1. Then absent for passing period from 0 to 1 and 1 to 2 */  

    if (ap.absentPeriod[1] == true) 
    {  
      ap.absentPassing[0] = true;
      ap.absentPassing[1] = true;
    } 

    /* Absent for period 2. Then absent for passing period from 1 to 2 and 2 to 3 */  

    if (ap.absentPeriod[2] == true)      
    {
      ap.absentPassing[1] = true;
      ap.absentPassing[2] = true;
    } 

    /* Absent for period 3. Then absent for passing period from 2 to 3 and 3 to 4 */  

    if (ap.absentPeriod[3] == true)  
    {
      ap.absentPassing[2] = true;
      ap.absentPassing[3] = true;
    } 

    /* Absent for period 4. Then absent for passing period from 3 to 4 and 4 to 5 */  

    if (ap.absentPeriod[4] == true)  
    {
      ap.absentPassing[3] = true;
      ap.absentPassing[4] = true;
    } 
  
    /* Absent for period 5. Then absent for passing period from 4 to 5 and 5 to 6 */  

    if (ap.absentPeriod[5] == true)  
    {
      ap.absentPassing[4] = true;
      ap.absentPassing[5] = true;
    } 

    /* Absent for period 6. Then absent for passing period from 5 to 6 and 6 to 7 */  

    if (ap.absentPeriod[6] == true)  
    {
      ap.absentPassing[5] = true;
      ap.absentPassing[6] = true;
    } 

    /* Absent for period 7. Then absent for passing period from 6 to 7 and 7 to 8 */  
  
    if (ap.absentPeriod[7] == true)  
    {
      ap.absentPassing[6] = true;
      ap.absentPassing[7] = true;
    } 

    /* Absent for period 8. Then absent for passing period from 7 to 8 and 8 to 9 */  

    if (ap.absentPeriod[8] == true)  
    {
      ap.absentPassing[7] = true;
      ap.absentPassing[8] = true;
    } 

    /* Absent for period 9. Then absent for passing period from 8 to 9 and 9 to 10 */  
  
    if (ap.absentPeriod[9] == true)   
    {
      ap.absentPassing[8] = true;
      ap.absentPassing[9] = true;
    } 

    /* Absent for period 10. Then absent for passing period from 9 to 10 */  

    if (ap.absentPeriod[10] == true)  
    {
      ap.absentPassing[9] = true;
    } 
    
    return ap;
    
  };  
  
  /**************************************************************************
   * dsData.ComputeMinutes () */
  /**
   * Compute minutes
   **************************************************************************/   
  
  objExpectedSvcs.dsData.ComputeMinutes = function (dos, ap) {
  
    /*-------------------------------   
     * Create return object
     *------------------------------*/ 
    
    var compMins = {};
    
    compMins.absent   = 0;
    compMins.expected = 0;
    compMins.present  = 0;
    
    /*-------------------------------    
     * Using given dos look up 
     * index of during school detail
     * record and retrieve it
     *------------------------------*/ 
    
    var srchDtl = $.spedmonWebUI.getObjects(objExpectedSvcs.ds,'dos',dos);
    var idx     = srchDtl[0].idx;
    var dsDtl   = objExpectedSvcs.ds[idx];
    
    /*-------------------------------    
     * Fill in total minutes expected
     * init total minutes present and
     * absent
     *------------------------------*/ 

    var totMinAbsent   = 0;
    var totMinExpected = dsDtl.numMinsExpd;
    var totMinPresent  = dsDtl.numMinsExpd;
    
    if (dsDtl.periodCount > 0)
    {    
    
      /*-------------------------------    
       * Add up absent periods
       *------------------------------*/ 
      
      for (var i=0; i<=10; i++)
      {
        if (ap.absentPeriod[i] == true) totMinAbsent = totMinAbsent + dsDtl.minPeriod[i]; 
      }

      /*-------------------------------    
       * Add up passing periods
       *------------------------------*/ 
     
      for (var j=0;j<=9;j++)
      {
        if (ap.absentPassing[j] == true) totMinAbsent = totMinAbsent + dsDtl.minPassing[j];
      }
    
    }
    
    /*-------------------------------    
     * Compute total minutes present
     *------------------------------*/ 

    totMinPresent = totMinExpected - totMinAbsent;
        
    /*-------------------------------    
     * Fill in object and return
     *------------------------------*/ 

    compMins.absent   = totMinAbsent;
    compMins.expected = totMinExpected;
    compMins.present  = totMinPresent;
    
    return compMins;
    
  };
  
  /**************************************************************************
   * bsData.ComputeMinutes () */
  /**
   * Compute minutes
   **************************************************************************/   
  
  objExpectedSvcs.bsData.ComputeMinutes = function (dos) {
  
    /*-------------------------------   
     * Create return object
     *------------------------------*/ 
    
    var compMins = {};
    
    compMins.absent   = 0;
    compMins.expected = 0;
    compMins.present  = 0;
    
    /*-------------------------------    
     * Using given dos look up 
     * index of during school detail
     * record and retrieve it
     *------------------------------*/ 
    
    var srchDtl = $.spedmonWebUI.getObjects(objExpectedSvcs.bs,'dos',dos);
    var idx     = srchDtl[0].idx;
    var dsDtl   = objExpectedSvcs.bs[idx];
    
    /*-------------------------------    
     * Fill in total minutes expected
     * init total minutes present and
     * absent
     *------------------------------*/ 

    var totMinAbsent   = 0;
    var totMinExpected = dsDtl.numMinsExpd;
    var totMinPresent  = dsDtl.numMinsExpd;
    
    /*-------------------------------    
     * Compute total minutes present
     *------------------------------*/ 

    totMinPresent = totMinExpected - totMinAbsent;
        
    /*-------------------------------    
     * Fill in object and return
     *------------------------------*/ 

    compMins.absent   = totMinAbsent;
    compMins.expected = totMinExpected;
    compMins.present  = totMinPresent;
    
    return compMins;
    
  };

  /**************************************************************************
   * asData.ComputeMinutes () */
  /**
   * Compute minutes
   **************************************************************************/   
  
  objExpectedSvcs.asData.ComputeMinutes = function (dos) {
  
    /*-------------------------------   
     * Create return object
     *------------------------------*/ 
    
    var compMins = {};
    
    compMins.absent   = 0;
    compMins.expected = 0;
    compMins.present  = 0;
    
    /*-------------------------------    
     * Using given dos look up 
     * index of during school detail
     * record and retrieve it
     *------------------------------*/ 
    
    var srchDtl = $.spedmonWebUI.getObjects(objExpectedSvcs.as,'dos',dos);
    var idx     = srchDtl[0].idx;
    var dsDtl   = objExpectedSvcs.as[idx];
    
    /*-------------------------------    
     * Fill in total minutes expected
     * init total minutes present and
     * absent
     *------------------------------*/ 

    var totMinAbsent   = 0;
    var totMinExpected = dsDtl.numMinsExpd;
    var totMinPresent  = dsDtl.numMinsExpd;
    
    /*-------------------------------    
     * Compute total minutes present
     *------------------------------*/ 

    totMinPresent = totMinExpected - totMinAbsent;
        
    /*-------------------------------    
     * Fill in object and return
     *------------------------------*/ 

    compMins.absent   = totMinAbsent;
    compMins.expected = totMinExpected;
    compMins.present  = totMinPresent;
    
    return compMins;
    
  };

   
}

/**************************************************************************
 * populateExpectedServicesObj (rd) */
/**
 * Takes data returned from server and extracts expected services info
 **************************************************************************/

function populateExpectedServicesObj (rd)
{

  /*============================================================
   * Create object
   *============================================================*/

  createExpectedServicesObj();
  
  if (rd.data.hasRecords == false) return;
 
  /*============================================================
   * Init Counters
   *============================================================*/

  var numBS = 0;
  var numDS = 0;
  var numAS = 0;
  
  /*============================================================
   * Populate details
   *============================================================*/

  $.each(rd.data.rowvalues, function (key, value)
  {
    var dtl = {};   
       
    var when = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'whenFlags'));
    
    dtl.key         = key;
    dtl.idx         = 0;
    dtl.when        = when;    
    dtl.dos         = $.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'attendanceDay'); 
    dtl.numMinsExpd = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'numMinsExpd'));
    dtl.inIEP       = $.spedmonWebUI.evaluateFlag($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'inIEP'));
    dtl.pracID      = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'pracID'));
    dtl.pracName    = $.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'pracName');
    dtl.pracNote    = $.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'pracNote');
    dtl.nameID      = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SvcNameID'));
    dtl.periodCount = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchNumPeriods'));
    
    dtl.numDailyMinsExpd     = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'numDailyMinsExpd'));
    dtl.numDailyMinsRecv     = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'numDailyMinsRecv'));
    
    dtl.numSlotClaimsWaiting = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'numSlotClaimsWaiting'));   
    dtl.numSlotClaimsSent    = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'numSlotClaimsSent'));   
    
    dtl.svcSlotProc          = $.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'svcSlotProc');
   
    dtl.skipEntry = false;
    
    //if (dtl.numDailyMinsRecv >= dtl.numDailyMinsExpd) dtl.skipEntry = true;
    if (dtl.numSlotClaimsSent > 0)                    dtl.skipEntry = true;
    
    var prac = {};
    prac.id     = dtl.pracID;
    prac.name   = dtl.pracName;   
    prac.note   = dtl.pracNote;  

    var svcOverview = objExpectedSvcs.svcOverviews[dtl.dos];
    
    if (!svcOverview)
    {
      svcOverview = {};
      svcOverview.dos      = dtl.dos;      
      svcOverview.bsPracID = 0;
      svcOverview.dsPracID = 0;
      svcOverview.asPracID = 0;
      svcOverview.bsSvcSlotProc = '';
      svcOverview.dsSvcSlotProc = '';
      svcOverview.asSvcSlotProc = '';
    }
    
    if ((when == 2) && (dtl.periodCount > 0))
    {
    
      objExpectedSvcs.dsData.HasPeriods = true;
    
      /*============================================================
       * Periods expected
       *============================================================*/
    
      dtl.periodFirst  = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPerFirst'));
      dtl.periodLast   = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPerLast'));
    
      /*============================================================
       * Minutes per period expected
       *============================================================*/
    
      dtl.minPeriod = {};
    
      dtl.minPeriod[0]  = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPer0Min'));
      dtl.minPeriod[1]  = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPer1Min'));
      dtl.minPeriod[2]  = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPer2Min'));
      dtl.minPeriod[3]  = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPer3Min'));
      dtl.minPeriod[4]  = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPer4Min'));
      dtl.minPeriod[5]  = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPer5Min'));
      dtl.minPeriod[6]  = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPer6Min'));
      dtl.minPeriod[7]  = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPer7Min'));
      dtl.minPeriod[8]  = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPer8Min'));
      dtl.minPeriod[9]  = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPer9Min'));
      dtl.minPeriod[10] = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPer10Min'));
    
      /*============================================================
       * Minutes per passing period expected
       *============================================================*/

      dtl.minPassing = {};
    
      dtl.minPassing[0] = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPas0Min'));
      dtl.minPassing[1] = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPas1Min'));
      dtl.minPassing[2] = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPas2Min'));
      dtl.minPassing[3] = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPas3Min'));
      dtl.minPassing[4] = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPas4Min'));
      dtl.minPassing[5] = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPas5Min'));
      dtl.minPassing[6] = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPas6Min'));
      dtl.minPassing[7] = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPas7Min'));
      dtl.minPassing[8] = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPas8Min'));
      dtl.minPassing[9] = parseInt($.spedmonWebUI.ReturnInfoTableGetColValue (rd.data, value.values, 'SchPas9Min'));             
          
    }
    
    

    /*============================================================
     * Store details
     *============================================================*/
        
    if (when == 1) 
    {     
      numBS++;
      dtl.idx = numBS;
      svcOverview.bsPracID = dtl.pracID;
      svcOverview.bsSvcSlotProc = dtl.svcSlotProc;      
      objExpectedSvcs.bs[numBS] = dtl;      
    }
    else if (when == 2) 
    {
      numDS++;
      dtl.idx = numDS;
      svcOverview.dsPracID = dtl.pracID;
      svcOverview.dsSvcSlotProc = dtl.svcSlotProc;
      objExpectedSvcs.ds[numDS] = dtl;
    }
    else if (when == 4) 
    {
      numAS++;
      dtl.idx = numAS;
      svcOverview.asPracID = dtl.pracID;
      svcOverview.asSvcSlotProc = dtl.svcSlotProc;
      objExpectedSvcs.as[numAS] = dtl;
    }
    else;
           
    
    objExpectedSvcs.svcOverviews[svcOverview.dos] = svcOverview;    
    objExpectedSvcs.pracData[prac.id] = prac;
    
  });
  
  objExpectedSvcs.bsData.rowCount = numBS;
  objExpectedSvcs.dsData.rowCount = numDS;
  objExpectedSvcs.asData.rowCount = numAS;
  
  return true;
  
}

/**************************************************************************
 * getOverviewDataCtrlRefs () */
/**
 * Gets references to overview data controls
 **************************************************************************/

function getOverviewDataCtrlRefs()
{
  tblOverviewRows = $('#overviewdata');
  divPracNotes    = $('#pracnotes');
}

/**************************************************************************
 * clearOverviewData() */
/**
 * Clears overview data
 **************************************************************************/

 function clearOverviewData()
{
  getOverviewDataCtrlRefs();
  $(tblOverviewRows).html('');
  $(divPracNotes).html('');
}

/**************************************************************************
 * populateOverviewData() */
/**
 * Populate practitioner data
 **************************************************************************/

function populateOverviewData ()
{
  // Clears old data if any
  
  clearOverviewData();

  if (!objExpectedSvcs) return;
  
  $.each(objExpectedSvcs.svcOverviews, function (dos, svcOverview)
  {
    var overviewRow = $('<tr></tr>');
    
    var dsPrac  = '';
    var bsPrac  = '';
    var asPrac  = '';
    
    if (svcOverview.dsPracID != 0) dsPrac = objExpectedSvcs.pracData[svcOverview.dsPracID].name;
    if (svcOverview.bsPracID != 0) bsPrac = objExpectedSvcs.pracData[svcOverview.bsPracID].name;
    if (svcOverview.asPracID != 0) asPrac = objExpectedSvcs.pracData[svcOverview.asPracID].name;
    
    $(overviewRow).append('<td style="padding:.25em">' + dos    + '</td>');
    $(overviewRow).append('<td style="padding:.25em">' + dsPrac + '</td>');
    $(overviewRow).append('<td style="padding:.25em">' + bsPrac + '</td>');
    $(overviewRow).append('<td style="padding:.25em">' + asPrac + '</td>');    
  
    $(tblOverviewRows).append(overviewRow);
  });
  
  $.each(objExpectedSvcs.pracData, function (id, prac)
  {
    var pracNote = $('<div style="margin:.25em"></div>');
    var pname = $('<h4 class = "ui-state-default" style="text-align:center;">'  + prac.name + '</h4>');
    var pnote = $('<pre style="text-align:left">' + prac.note + '</pre>');
    $(pracNote).append(pname);
    $(pracNote).append(pnote);
    $(divPracNotes).append(pracNote);
  });

}

/**************************************************************************
 * populateDetailGrids() */
/**
 * Populate services data grids with expected service data
 **************************************************************************/

function populateDetailGrids (nextStep) 
{
  
  // Clear grids
  
  if (!objExpectedSvcs) return;
  
  // Start grid population
  
  populateDSGrid(nextStep);
   
  return;
  
}

/**************************************************************************
 * getExpectedServicesData() */
/**
 * Fetches expected service data from server
 **************************************************************************/
 
 function getExpectedServicesData (thisStepID, nextStep) 
 {

   var $stp    = $(thisStepID);
   var tkn     = $.spedmonWebUI.token;
   
   var cltid   = $('#clientid').val();
   var patid   = $('#patid').val();
   var refdate = $('#dos').val();
   
   var incbs   = $('#includebs').val();
   var sdbs    = $('#startdatebs').val();
   var edbs    = $('#enddatebs').val();
   
   var incds   = $('#includeds').val();
   var sdds    = $('#startdateds').val();
   var edds    = $('#enddateds').val();

   var incas   = $('#includeas').val();
   var sdas    = $('#startdateas').val();
   var edas    = $('#enddateas').val();
   
   
   var url     = "oneononeaideassignments.asmx/viewExpectedServicesInfoTbl?tkn=" + tkn;
   
   var $data   = "{'clientid':'"     + cltid + 
                 "','patid':'"       + patid + 
                 "','refdate':'"     + refdate +
                 "','includebs':'"   + incbs +
                 "','startdatebs':'" + sdbs +
                 "','enddatebs':'"   + edbs +
                 "','includeds':'"   + incds +
                 "','startdateds':'" + sdds +
                 "','enddateds':'"   + edds +
                 "','includeas':'"   + incas +
                 "','startdateas':'" + sdas +
                 "','enddateas':'"   + edas + "'}";
     
   var esData = null;
   
   $.spedmonWebUI.ajax($stp,
                       url,
                       $data,
                       null,
                       null,
                       function (rd) {esData = rd;},
                       null,
                       null,
                       0,
                       function() {populateExpectedServicesObj(esData);populateOverviewData();$('#save_steps').accordion('activate', nextStep);});
   return;
};

/**************************************************************************
 * Standard validate and save functions
 **************************************************************************/
 
function doValidate()
{
  $('#savetype').val($.spedmonWebUI.RECORD_SAVE_TYPE_NEW);
  $('#validaterec').val('1');
  var $sn = $("#save");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,function(){$st.spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,'Your record is ready to save. Please SELECT AN OPTION BELOW.',0)});
};

function doSave(fnSuccess)
{
  $('#savetype').val($.spedmonWebUI.RECORD_SAVE_TYPE_NEW);
  $('#validaterec').val('0');
  var $sn = $("#save");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,fnSuccess);
};
  
function doSaveNewRec   () {doSave(function(){save_steps_clear(0);clearOverviewData();$('#save_steps').accordion('option','active',0);});};
function doSaveNewBat   () {doSave(function(){save_steps_clear(1);clearOverviewData();$('#save_steps').accordion('option','active',1);});};
function doSaveNewPat   () {doSave(function(){save_steps_clear(2);clearOverviewData();$('#save_steps').accordion('option','active',2);});};
function doSaveAndQuit  () {doSave(function(){doGoHome();});};
function doClear        () {save_steps_clear(0);clearOverviewData();$('#save_steps').accordion('option','active',0);};
function doGoHome       () {$.spedmonWebUI.gotoMenuLink('homePageLink');};



/**************************************************************************
 * Init when page is ready
 **************************************************************************/

$(function() {
  //setDefaultAnswers();
});



