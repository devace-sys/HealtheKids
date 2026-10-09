/*============================================================
 * Caseload Delegates
 *============================================================*/ 

// global variables used for the 5 days of the week checkbox values
var mondayCheckBoxValueInd    = false;
var tuesdayCheckBoxValueInd   = false;
var wednesdayCheckBoxValueInd = false;
var thursdayCheckBoxValueInd  = false;
var fridayCheckBoxValueInd = false;

var mondayCheckBoxValueGrp = false;
var tuesdayCheckBoxValueGrp = false;
var wednesdayCheckBoxValueGrp = false;
var thursdayCheckBoxValueGrp = false;
var fridayCheckBoxValueGrp = false;

var mondayCheckBoxValueEditInd    = false;
var tuesdayCheckBoxValueEditInd   = false;
var wednesdayCheckBoxValueEditInd = false;
var thursdayCheckBoxValueEditInd  = false;
var fridayCheckBoxValueEditInd = false;

var mondayCheckBoxValueEditGrp = false;
var tuesdayCheckBoxValueEditGrp = false;
var wednesdayCheckBoxValueEditGrp = false;
var thursdayCheckBoxValueEditGrp = false;
var fridayCheckBoxValueEditGrp = false;

// global variables used to pass the checkbox id's to functions
var gblWgt;

// default checkbox JSON object (used to set our checkbox JSON when 'null' is loaded)
var defCheckboxJSON = '{ "monInd": false, "tueInd": false, "wedInd": false, "thurInd": false, "friInd": false, "monGrp": false, "tueGrp": false, "wedGrp": false, "thurGrp": false, "friGrp": false}';

// TEMPORARY hardcoded assessment date (TO BE CHANGED LATER)
//var temporaryDate = "4/18/2019";

 /***************************************************************************
  * getMembersCaseloadRequestData */
 /**
  * Delegate for loading group members for caseload
  ***************************************************************************/ 
  
function getMembersCaseloadRequestData (wgt){

   var reqData    =  '{'
                      +'"organizationID":"' + wgt.options.organizationID + '"'
					  +',"ownerID":"'       + wgt.options.ownerID        + '"'
					  +',"groupID":"'       + wgt.options.ownerID        + '"'
					  +',"term":""}';
   
   return reqData;
};

/***************************************************************************
 * preloadPaientData */
/**
 * Load a patient's data when selected
 ***************************************************************************/

function preloadPaientData(wgt, ui) {

    // set default values
    $('#' + wgt.options.add_mbr_form_minutes_ind).val('');
    $('#' + wgt.options.add_mbr_form_minutes_grp).val('');
    $('#' + wgt.options.add_mbr_form_minutes_ann).val('');
    $('#' + wgt.options.add_mbr_form_start_date).val('');

    $('#' + wgt.options.add_mbr_form_monday_checkbox_ind).prop('checked', false);
    $('#' + wgt.options.add_mbr_form_tuesday_checkbox_ind).prop('checked', false);
    $('#' + wgt.options.add_mbr_form_wednesday_checkbox_ind).prop('checked', false);
    $('#' + wgt.options.add_mbr_form_thursday_checkbox_ind).prop('checked', false);
    $('#' + wgt.options.add_mbr_form_friday_checkbox_ind).prop('checked', false);

    $('#' + wgt.options.add_mbr_form_monday_checkbox_grp).prop('checked', false);
    $('#' + wgt.options.add_mbr_form_tuesday_checkbox_grp).prop('checked', false);
    $('#' + wgt.options.add_mbr_form_wednesday_checkbox_grp).prop('checked', false);
    $('#' + wgt.options.add_mbr_form_thursday_checkbox_grp).prop('checked', false);
    $('#' + wgt.options.add_mbr_form_friday_checkbox_grp).prop('checked', false);

    $('#' + wgt.options.add_mbr_form_week_days_json).val(defCheckboxJSON);


    // set up ajax request params
    let clientID = wgt.options.organizationID;
    let pracID   = wgt.options.ownerID;
    let patID    = ui.item.id;
    
    var reqUrl = $.spedmonWebUI.createPrivateURL(wgt.options.tkn, wgt.options.preloadPatExpectedSvcsURL);
    var reqData = "{'clientID':'" + clientID + "','pracID':'" + pracID + "','patID':'" + patID + "'}";

    // success callback for ajax
    var fnProcRespSuccess = function (rd) {
        
        // get the latest returned patient info
        patExpectedService = rd.entity;

        var indMins = (patExpectedService.minsInd == '0') ? '' : patExpectedService.minsInd;
        var grpMins = (patExpectedService.minsGrp == '0') ? '' : patExpectedService.minsGrp;
        var annMins = (patExpectedService.minsAnn == '0') ? '' : patExpectedService.minsAnn;
        var startDate = patExpectedService.startDateStr;
        var planType = patExpectedService.planType;
        var checkboxJSON = (patExpectedService.weekDaysJSON == null) ? defCheckboxJSON : JSON.parse(patExpectedService.weekDaysJSON);

        // load the data into the fields
        $('#' + wgt.options.add_mbr_form_minutes_ind).val(indMins);
        $('#' + wgt.options.add_mbr_form_minutes_grp).val(grpMins);
        $('#' + wgt.options.add_mbr_form_minutes_ann).val(annMins);
        $('#' + wgt.options.add_mbr_form_start_date).val(startDate);
        $('#' + wgt.options.add_mbr_form_plan_type).val(planType);

        $('#' + wgt.options.add_mbr_form_monday_checkbox_ind).prop('checked', checkboxJSON.monInd);
        $('#' + wgt.options.add_mbr_form_tuesday_checkbox_ind).prop('checked', checkboxJSON.tueInd);
        $('#' + wgt.options.add_mbr_form_wednesday_checkbox_ind).prop('checked', checkboxJSON.wedInd);
        $('#' + wgt.options.add_mbr_form_thursday_checkbox_ind).prop('checked', checkboxJSON.thurInd);
        $('#' + wgt.options.add_mbr_form_friday_checkbox_ind).prop('checked', checkboxJSON.friInd);

        $('#' + wgt.options.add_mbr_form_monday_checkbox_grp).prop('checked', checkboxJSON.monGrp);
        $('#' + wgt.options.add_mbr_form_tuesday_checkbox_grp).prop('checked', checkboxJSON.tueGrp);
        $('#' + wgt.options.add_mbr_form_wednesday_checkbox_grp).prop('checked', checkboxJSON.wedGrp);
        $('#' + wgt.options.add_mbr_form_thursday_checkbox_grp).prop('checked', checkboxJSON.thurGrp);
        $('#' + wgt.options.add_mbr_form_friday_checkbox_grp).prop('checked', checkboxJSON.friGrp);

        // update the edit checkbox variables and our json
        mondayCheckBoxValueInd    = checkboxJSON.monInd;
        tuesdayCheckBoxValueInd   = checkboxJSON.tueInd;
        wednesdayCheckBoxValueInd = checkboxJSON.wedInd;
        thursdayCheckBoxValueInd  = checkboxJSON.thurInd;
        fridayCheckBoxValueInd    = checkboxJSON.friInd;

        mondayCheckBoxValueGrp    = checkboxJSON.monGrp;
        tuesdayCheckBoxValueGrp   = checkboxJSON.tueGrp;
        wednesdayCheckBoxValueGrp = checkboxJSON.wedGrp;
        thursdayCheckBoxValueGrp  = checkboxJSON.thurGrp;
        fridayCheckBoxValueGrp    = checkboxJSON.friGrp;

        $('#' + wgt.options.add_mbr_form_week_days_json).val("{\"monInd\":" + mondayCheckBoxValueInd + ",\"tueInd\":" + tuesdayCheckBoxValueInd + ",\"wedInd\":" + wednesdayCheckBoxValueInd + ",\"thurInd\":" + thursdayCheckBoxValueInd + ",\"friInd\":" + fridayCheckBoxValueInd + ",\"monGrp\":" + mondayCheckBoxValueGrp + ",\"tueGrp\":" + tuesdayCheckBoxValueGrp + ",\"wedGrp\":" + wednesdayCheckBoxValueGrp + ",\"thurGrp\":" + thursdayCheckBoxValueGrp + ",\"friGrp\":" + fridayCheckBoxValueGrp + "}");
    };

    // send ajax request
    $.spedmonWebUI.ajax(null
        , reqUrl
        , reqData
        , 'json'
        , null
        , null
        , null
        , null
        , 0
        , fnProcRespSuccess
        , null
        , null);


}
     
/***************************************************************************
 * addMemberCaseloadDiaContent */
/**
 * Delegate for generating add new member to caseload form content
 ***************************************************************************/ 
  
function addMemberCaseloadDiaContent (wgt, dia, frm ) {
    
   $(frm).append('<input name="saveType"  value="1" type="hidden" />');
   $(frm).append('<input name="recID"     value=""  type="hidden" />');

  /* Create unique ids for group and individual minutes */
    
  var me_id  = $(wgt.element).attr('id');
  var frm_id = $(frm).attr('id');    
  wgt.options.add_mbr_form_minutes_ind        = me_id + '-' + frm_id + '-add-mbr-minutes-ind';
  wgt.options.add_mbr_form_minutes_grp        = me_id + '-' + frm_id + '-add-mbr-minutes-grp';
  wgt.options.add_mbr_form_minutes_ann        = me_id + '-' + frm_id + '-add-mbr-minutes-ann';
  wgt.options.add_mbr_form_start_date         = me_id + '-' + frm_id + '-add-mbr-start-date';
  wgt.options.add_mbr_form_week_days_json     = me_id + '-' + frm_id + '-add-mbr-week-days-json';
  wgt.options.add_mbr_form_plan_type          = me_id + '-' + frm_id + '-add-mbr-plan-type';

  wgt.options.add_mbr_form_days_checkboxes_ind    = me_id + '-' + frm_id + '-add-mbr-days-checkboxes-ind';
  wgt.options.add_mbr_form_monday_checkbox_ind    = me_id + '-' + frm_id + '-add-mbr-monday-checkbox-ind';
  wgt.options.add_mbr_form_tuesday_checkbox_ind   = me_id + '-' + frm_id + '-add-mbr-tuesday-checkbox-ind';
  wgt.options.add_mbr_form_wednesday_checkbox_ind = me_id + '-' + frm_id + '-add-mbr-wednesday-checkbox-ind';
  wgt.options.add_mbr_form_thursday_checkbox_ind  = me_id + '-' + frm_id + '-add-mbr-thursday-checkbox-ind';
  wgt.options.add_mbr_form_friday_checkbox_ind    = me_id + '-' + frm_id + '-add-mbr-friday-checkbox-ind';

  wgt.options.add_mbr_form_days_checkboxes_grp    = me_id + '-' + frm_id + '-add-mbr-days-checkboxes-grp';
  wgt.options.add_mbr_form_monday_checkbox_grp    = me_id + '-' + frm_id + '-add-mbr-monday-checkbox-grp';
  wgt.options.add_mbr_form_tuesday_checkbox_grp   = me_id + '-' + frm_id + '-add-mbr-tuesday-checkbox-grp';
  wgt.options.add_mbr_form_wednesday_checkbox_grp = me_id + '-' + frm_id + '-add-mbr-wednesday-checkbox-grp';
  wgt.options.add_mbr_form_thursday_checkbox_grp  = me_id + '-' + frm_id + '-add-mbr-thursday-checkbox-grp';
  wgt.options.add_mbr_form_friday_checkbox_grp    = me_id + '-' + frm_id + '-add-mbr-friday-checkbox-grp';
	
  /* Create table to layout fields */

  var $frmTable = $('<table></table>');
	
  /* Select patient */

  var $frmRow1       = $('<tr></tr>');
  var $formRow1Col1  = $('<td></td>');
  var $formRow1Col2  = $('<td></td>');
  var $lblPatSel     = $('<label for="' + wgt.options.add_mbr_form_entity_id + '">Select a Patient</label>');
  var $patSel        = $('<input name="entityID" id="' + wgt.options.add_mbr_form_entity_id  +'" title="Last Name, First Name" class="mba-web-ui-field-simple" type="text"/>');
	
  $($formRow1Col1).append($lblPatSel);
  $($formRow1Col2).append($patSel);	
	
  $($frmRow1).append($formRow1Col1);
  $($frmRow1).append($formRow1Col2);
    
  $($frmTable).append($frmRow1);

  /* Session minutes and days of the week prompts */

  var $hiddenText     = $('<textarea ID="' + wgt.options.add_mbr_form_week_days_json + '" name="weekdaysjson" style="display: none;"></textarea>');

  var $frmRow2        = $('<tr></tr>');
  var $formRow2Col1   = $('<td class="d-flex justify-content-end"></td>');
  var $formRow2Col2   = $('<td></td>');
  var $minsPrompt     = $('<p style="width: 57%; margin: 0;">Enter Expected Number of Minutes Per Session</p>');
  var $daysPrompt     = $('<div></div>');
  var $daysPromptText = $('<p class="m-0 text-center">Select the Days Sessions Are Scheduled</p>');
  var $daysPromptlbls = $('<div class="d-flex justify-content-around"></div>');
  var $daysItems      = $('<p class="m-0">Mon</p><p class="m-0">Tue</p><p class="m-0">Wed</p><p class="m-0">Thur</p><p class="m-0">Fri</p>');

  $($daysPromptlbls).append($daysItems);
  $($daysPrompt).append($daysPromptText);
  $($daysPrompt).append($daysPromptlbls);

  $($formRow2Col1).append($minsPrompt);
  $($formRow2Col2).append($daysPrompt);	
  $($frmRow2).append($formRow2Col1);
  $($frmRow2).append($formRow2Col2);
  $($frmTable).append($frmRow2);

  /* Individual minutes and days of the week inputs */
	
  var $frmRow3       = $('<tr></tr>');
  var $formRow3Col1  = $('<td></td>');
  var $formRow3Col2  = $('<td></td>');
  var $lblMinsInd    = $('<label class="w-50" for="' + wgt.options.add_mbr_form_minutes_ind + '">Individual Sessions</label>');
  var $minsInd       = $('<input name="numMinsInd" id="' + wgt.options.add_mbr_form_minutes_ind +'" type="number" title="Enter minutes" min="0" max="1440" style="width: 6em;"/>');
  var $checkboxesInd = $('<div id="' + wgt.options.add_mbr_form_days_checkboxes_ind + '" class=\"d-flex justify-content-around\"></div>');
  var $mondayInd     = $('<input id="' + wgt.options.add_mbr_form_monday_checkbox_ind + '" name="mondayCheckboxInd" class="checkbox-item new-input" type="checkbox" value="monday">');
  var $tuesdayInd    = $('<input id="' + wgt.options.add_mbr_form_tuesday_checkbox_ind + '" name="tuesdayCheckboxInd" class="checkbox-item new-input" type="checkbox" value="tuesday">');
  var $wednesdayInd  = $('<input id="' + wgt.options.add_mbr_form_wednesday_checkbox_ind + '" name="wednesdayCheckboxInd" class="checkbox-item new-input" type="checkbox" value="wednesday">');
  var $thursdayInd   = $('<input id="' + wgt.options.add_mbr_form_thursday_checkbox_ind + '" name="thursdayCheckboxInd" class="checkbox-item new-input" type="checkbox" value="thursday">');
  var $fridayInd     = $('<input id="' + wgt.options.add_mbr_form_friday_checkbox_ind + '" name="fridayCheckboxInd" class="checkbox-item new-input" type="checkbox" value="friday">');

  $($checkboxesInd).append($mondayInd);
  $($checkboxesInd).append($tuesdayInd);
  $($checkboxesInd).append($wednesdayInd);
  $($checkboxesInd).append($thursdayInd);
  $($checkboxesInd).append($fridayInd);

  $($formRow3Col1).append($lblMinsInd);
  $($formRow3Col1).append($minsInd);
  $($formRow3Col2).append($checkboxesInd);
    
  $($frmRow3).append($formRow3Col1);
  $($frmRow3).append($formRow3Col2);   
  $($frmTable).append($frmRow3);

  /* Group minutes and days of the week inputs */
	
  var $frmRow4       = $('<tr></tr>');
  var $formRow4Col1  = $('<td></td>');
  var $formRow4Col2  = $('<td></td>');
  var $lblMinsGrp    = $('<label class="w-50" for="' + wgt.options.add_mbr_form_minutes_grp + '">Group Sessions</label>');
  var $minsGrp       = $('<input name="numMinsGrp" id="' + wgt.options.add_mbr_form_minutes_grp +'" type="number" title="Enter minutes" min="0" max="1440" style="width: 6em;"/>');
  var $checkboxesGrp = $('<div id="' + wgt.options.add_mbr_form_days_checkboxes_grp + '" class=\"d-flex justify-content-around\"></div>');
  var $mondayGrp     = $('<input id="' + wgt.options.add_mbr_form_monday_checkbox_grp + '" name="mondayCheckboxGrp" class="checkbox-item new-input" type="checkbox" value="monday">');
  var $tuesdayGrp    = $('<input id="' + wgt.options.add_mbr_form_tuesday_checkbox_grp + '" name="tuesdayCheckboxGrp" class="checkbox-item new-input" type="checkbox" value="tuesday">');
  var $wednesdayGrp  = $('<input id="' + wgt.options.add_mbr_form_wednesday_checkbox_grp + '" name="wednesdayCheckboxGrp" class="checkbox-item new-input" type="checkbox" value="wednesday">');
  var $thursdayGrp   = $('<input id="' + wgt.options.add_mbr_form_thursday_checkbox_grp + '" name="thursdayCheckboxGrp" class="checkbox-item new-input" type="checkbox" value="thursday">');
  var $fridayGrp     = $('<input id="' + wgt.options.add_mbr_form_friday_checkbox_grp + '" name="fridayCheckboxGrp" class="checkbox-item new-input" type="checkbox" value="friday">');

  $($checkboxesGrp).append($mondayGrp);
  $($checkboxesGrp).append($tuesdayGrp);
  $($checkboxesGrp).append($wednesdayGrp);
  $($checkboxesGrp).append($thursdayGrp);
  $($checkboxesGrp).append($fridayGrp);

  $($formRow4Col1).append($lblMinsGrp);
  $($formRow4Col1).append($minsGrp);
  $($formRow4Col2).append($checkboxesGrp);
    
  $($frmRow4).append($formRow4Col1);
  $($frmRow4).append($formRow4Col2);   
  $($frmTable).append($frmRow4);

  /* Annual minutes and Service start date */

  var $frmRow5       = $('<tr></tr>');
  var $formRow5Col1  = $('<td></td>');
  var $formRow5Col2  = $('<td></td>');
  var $lblMinsAnn    = $('<label class="w-50" for="' + wgt.options.add_mbr_form_minutes_ann + '">Total Annual Minutes</label>');
  var $minsAnn       = $('<input name="numMinsAnn" id="' + wgt.options.add_mbr_form_minutes_ann +'" type="number" title="Enter minutes" min="0" max="525600" style="width: 6em;"/>');
  var $lblStartDate  = $('<label for="' + wgt.options.add_mbr_form_start_date + '">Date Service was Authorized &nbsp;</label>');
    var $startDate = $('<input name="startDateTmtSvcs" id="' + wgt.options.add_mbr_form_start_date +'" type="date" title="Enter Date" style="width: 9em;"/>');

  $($formRow5Col1).append($lblMinsAnn);
  $($formRow5Col1).append($minsAnn);
  $($formRow5Col2).append($lblStartDate);
  $($formRow5Col2).append($startDate);
  $($frmRow5).append($formRow5Col1);
  $($frmRow5).append($formRow5Col2);   
  $($frmTable).append($frmRow5);

  /* Plan type */

  var $frmRow6       = $('<tr></tr>');
  var $formRow6Col1  = $('<td></td>');
  var $formRow6Col2  = $('<td style="display: flex;justify-content: space-between;"></td>');
  var $lblPlanType   = $('<label for="' + wgt.options.add_mbr_form_plan_type + '">Select a Plan Type</label>');
  var $planType      = $('<select id="' + wgt.options.add_mbr_form_plan_type +  '" name="planType" style="height: 2em; width: 9em;">'
                          + '<option value="1" selected> IEP / IFSP</option>'
                          + '<option value="2">Other (IHP, 504, Counseling, etc.)</option>'
                       + '</select>');

  $($formRow6Col2).append($lblPlanType);
  $($formRow6Col2).append($planType);
  $($frmRow6).append($formRow6Col1);
  $($frmRow6).append($formRow6Col2);
  $($frmTable).append($frmRow6);

  /* Record Assessments */
	
  //var $assessmentContainer  = $('<div class="d-flex justify-content-between align-items-center" style="margin-top: 0.5em;"><p>Date of Last Recorded Assessment</p></div>');
  //var $assessmentDate       = $('<p style="padding: 0.25em 4em; border: 1px solid;">' + temporaryDate + '</p>');
  //var $assessmentRecordLink = $('<a href="" style="text-decoration: underline; color: #0000EE; margin-bottom: 1em;">Record Assessment</a>');
  
  //$($assessmentContainer).append($assessmentDate);
  //$($assessmentContainer).append($assessmentRecordLink);

  /* Append to form */

  $(frm).append($frmTable);
  $(frm).append($hiddenText);
  //$(frm).append($assessmentContainer);
  
  var $lnksCont    = $('<div style="margin-top:1em; text-align:center;"></div>');
  var newPatLnkUrl = 'user_all_pat_save_2.aspx?tkn=' + wgt.options.tkn + '&amd=uidbssub';
  var $newPatLnk   = $('<a style="font-weight:bold;color:blue;" href="">Cannot Find a Patient?  Click here to add a new patient to SpEdCare.</a>');
  $($newPatLnk).on('click',function(e){e.preventDefault();$.spedmonWebUI.openURL(newPatLnkUrl,1);return false;});  
  $($lnksCont).append($newPatLnk);
  $(dia).append($lnksCont);

  /* Enhance */
	
  var $patSelUrl = $.spedmonWebUI.createPrivateURL(wgt.options.tkn,"patients.asmx/viewSel");
  var $patSelNVP = [   { name:"clientid",       value:(wgt.options.organizationID) }
                     , { name:"pracid",         value:(wgt.options.ownerID)  }	
					 , { name:"dos",            value:""}							  
				     , { name:"patdatasource",  value:"0"  }							  
			        ];

  $($patSel).spedmonSelectBox({dataParmType:"DOM", selectAll:true, selectType:($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),onSelect:function(event,ui){preloadPaientData(wgt, ui);},ajaxopts:{url:($patSelUrl),data:"",namevalues:($patSelNVP),getnamevaluesfn:null}});
  //$($minsAnn).spedmonNumberbox({"showOK":false});
	
};
  
function fnEditMemberCaseloadFormPopulate (wgt,$frm,mbrObj){
  
  var indMins   = (mbrObj.recData1  == '0') ? '' : mbrObj.recData1;
  var grpMins   = (mbrObj.recData2  == '0') ? '' : mbrObj.recData2;
  var annMins   = (mbrObj.recData11 == '0') ? '' : mbrObj.recData11;
  var startDate = mbrObj.recData13;
  var planType   = (mbrObj.recData14 == null) ? 1 : mbrObj.recData14;
  var checkboxJSON = (mbrObj.recData12 == null) ? JSON.parse(defCheckboxJSON) : JSON.parse(mbrObj.recData12);

  $('#' + wgt.options.edit_mbr_form_patient_name).text(mbrObj.lbl);

  $('#' + wgt.options.edit_mbr_form_minutes_ind).val(indMins);
  $('#' + wgt.options.edit_mbr_form_minutes_grp).val(grpMins);
  $('#' + wgt.options.edit_mbr_form_minutes_ann).val(annMins);
  $('#' + wgt.options.edit_mbr_form_start_date).val(startDate);
  $('#' + wgt.options.edit_mbr_form_plan_type).val(planType);

  $('#' + wgt.options.edit_mbr_form_monday_checkbox_ind).prop('checked', checkboxJSON.monInd);
  $('#' + wgt.options.edit_mbr_form_tuesday_checkbox_ind).prop('checked', checkboxJSON.tueInd);
  $('#' + wgt.options.edit_mbr_form_wednesday_checkbox_ind).prop('checked', checkboxJSON.wedInd);
  $('#' + wgt.options.edit_mbr_form_thursday_checkbox_ind).prop('checked', checkboxJSON.thurInd);
  $('#' + wgt.options.edit_mbr_form_friday_checkbox_ind).prop('checked', checkboxJSON.friInd);

  $('#' + wgt.options.edit_mbr_form_monday_checkbox_grp).prop('checked', checkboxJSON.monGrp);
  $('#' + wgt.options.edit_mbr_form_tuesday_checkbox_grp).prop('checked', checkboxJSON.tueGrp);
  $('#' + wgt.options.edit_mbr_form_wednesday_checkbox_grp).prop('checked', checkboxJSON.wedGrp);
  $('#' + wgt.options.edit_mbr_form_thursday_checkbox_grp).prop('checked', checkboxJSON.thurGrp);
  $('#' + wgt.options.edit_mbr_form_friday_checkbox_grp).prop('checked', checkboxJSON.friGrp);

  // update the edit checkbox variables and our json
  mondayCheckBoxValueEditInd    = checkboxJSON.monInd;
  tuesdayCheckBoxValueEditInd   = checkboxJSON.tueInd;
  wednesdayCheckBoxValueEditInd = checkboxJSON.wedInd;
  thursdayCheckBoxValueEditInd  = checkboxJSON.thurInd;
  fridayCheckBoxValueEditInd    = checkboxJSON.friInd;

  mondayCheckBoxValueEditGrp    = checkboxJSON.monGrp;
  tuesdayCheckBoxValueEditGrp   = checkboxJSON.tueGrp;
  wednesdayCheckBoxValueEditGrp = checkboxJSON.wedGrp;
  thursdayCheckBoxValueEditGrp  = checkboxJSON.thurGrp;
  fridayCheckBoxValueEditGrp    = checkboxJSON.friGrp;

  $('#' + wgt.options.edit_mbr_form_week_days_json).val("{\"monInd\":" + mondayCheckBoxValueEditInd + ",\"tueInd\":" + tuesdayCheckBoxValueEditInd + ",\"wedInd\":" + wednesdayCheckBoxValueEditInd + ",\"thurInd\":" + thursdayCheckBoxValueEditInd + ",\"friInd\":" + fridayCheckBoxValueEditInd + ",\"monGrp\":" + mondayCheckBoxValueEditGrp + ",\"tueGrp\":" + tuesdayCheckBoxValueEditGrp + ",\"wedGrp\":" + wednesdayCheckBoxValueEditGrp + ",\"thurGrp\":" + thursdayCheckBoxValueEditGrp + ",\"friGrp\":" + fridayCheckBoxValueEditGrp + "}");

};

/***************************************************************************
 * editMemberCaseloadDiaContent */
/**
 * Delegate for generating edit existing member in caseload form content
 ***************************************************************************/ 

function editMemberCaseloadDiaContent (wgt, dia, frm) {
    
   $(frm).append('<input name="saveType"  value="2" type="hidden" />');
   $(frm).append('<input name="recID"     value="' + wgt.options.id +'"  type="hidden" />');
  
  /* Create unique ids for group, individual and annual minutes */
  
  var me_id  = $(wgt.element).attr('id');
  var frm_id = $(frm).attr('id');
    
  wgt.options.edit_mbr_form_patient_name       = me_id + '-' + frm_id + '-edit-mbr-patient-name';
  wgt.options.edit_mbr_form_minutes_ind        = me_id + '-' + frm_id + '-edit-mbr-minutes-ind';
  wgt.options.edit_mbr_form_minutes_grp        = me_id + '-' + frm_id + '-edit-mbr-minutes-grp';
  wgt.options.edit_mbr_form_minutes_ann        = me_id + '-' + frm_id + '-edit-mbr-minutes-ann';
  wgt.options.edit_mbr_form_start_date         = me_id + '-' + frm_id + '-edit-mbr-start-date';
  wgt.options.edit_mbr_form_week_days_json     = me_id + '-' + frm_id + '-edit-mbr-week-days-json';

  wgt.options.edit_mbr_form_days_checkboxes_ind    = me_id + '-' + frm_id + '-edit-mbr-days-checkboxes-ind';
  wgt.options.edit_mbr_form_monday_checkbox_ind    = me_id + '-' + frm_id + '-edit-mbr-monday-checkbox-ind';
  wgt.options.edit_mbr_form_tuesday_checkbox_ind   = me_id + '-' + frm_id + '-edit-mbr-tuesday-checkbox-ind';
  wgt.options.edit_mbr_form_wednesday_checkbox_ind = me_id + '-' + frm_id + '-edit-mbr-wednesday-checkbox-ind';
  wgt.options.edit_mbr_form_thursday_checkbox_ind  = me_id + '-' + frm_id + '-edit-mbr-thursday-checkbox-ind';
  wgt.options.edit_mbr_form_friday_checkbox_ind    = me_id + '-' + frm_id + '-edit-mbr-friday-checkbox-ind';
  wgt.options.edit_mbr_form_plan_type              = me_id + '-' + frm_id + '-edit-mbr-plan-type';

  wgt.options.edit_mbr_form_days_checkboxes_grp    = me_id + '-' + frm_id + '-edit-mbr-days-checkboxes-grp';
  wgt.options.edit_mbr_form_monday_checkbox_grp    = me_id + '-' + frm_id + '-edit-mbr-monday-checkbox-grp';
  wgt.options.edit_mbr_form_tuesday_checkbox_grp   = me_id + '-' + frm_id + '-edit-mbr-tuesday-checkbox-grp';
  wgt.options.edit_mbr_form_wednesday_checkbox_grp = me_id + '-' + frm_id + '-edit-mbr-wednesday-checkbox-grp';
  wgt.options.edit_mbr_form_thursday_checkbox_grp  = me_id + '-' + frm_id + '-edit-mbr-thursday-checkbox-grp';
  wgt.options.edit_mbr_form_friday_checkbox_grp    = me_id + '-' + frm_id + '-edit-mbr-friday-checkbox-grp';
	
  var $patSel = $('<input name="entityID" id="' + wgt.options.edit_mbr_form_entity_id +'" value="" type="hidden"/>');
  $(frm).append($patSel);
	
  var $frmTable = $('<table></table>');

  /* Patient Name */

  var $frmRow1       = $('<tr></tr>');
  var $formRow1Col1  = $('<td class="d-flex"></td>');
  var $patNamelbl    = $('<div class="w-50">Patient</div>');
  var $patName       = $('<div id="' + wgt.options.edit_mbr_form_patient_name +'" class="font-weight-bold"></div>');

  $($formRow1Col1).append($patNamelbl);
  $($formRow1Col1).append($patName);
  $($frmRow1).append($formRow1Col1);   
  $($frmTable).append($frmRow1);

  /* Session minutes and days of the week prompts */

  var $hiddenText     = $('<textarea ID="' + wgt.options.edit_mbr_form_week_days_json + '" name="weekdaysjson" style="display: none;"></textarea>');

  var $frmRow2        = $('<tr></tr>');
  var $formRow2Col1   = $('<td class="d-flex justify-content-end"></td>');
  var $formRow2Col2   = $('<td></td>');
  var $minsPrompt     = $('<p style="width: 57%; margin: 0;">Enter Expected Number of Minutes Per Session</p>');
  var $daysPrompt     = $('<div></div>');
  var $daysPromptText = $('<p class="m-0 text-center">Select the Days Sessions Are Scheduled</p>');
  var $daysPromptlbls = $('<div class="d-flex justify-content-around"></div>');
  var $daysItems      = $('<p class="m-0">Mon</p><p class="m-0">Tue</p><p class="m-0">Wed</p><p class="m-0">Thur</p><p class="m-0">Fri</p>');

  $($daysPromptlbls).append($daysItems);
  $($daysPrompt).append($daysPromptText);
  $($daysPrompt).append($daysPromptlbls);

  $($formRow2Col1).append($minsPrompt);
  $($formRow2Col2).append($daysPrompt);	
  $($frmRow2).append($formRow2Col1);
  $($frmRow2).append($formRow2Col2);
  $($frmTable).append($frmRow2);

  /* Individual minutes and days of the week inputs */
	
  var $frmRow3       = $('<tr></tr>');
  var $formRow3Col1  = $('<td></td>');
  var $formRow3Col2  = $('<td></td>');
  var $lblMinsInd    = $('<label class="w-50" for="' + wgt.options.edit_mbr_form_minutes_ind + '">Individual Sessions</label>');
  var $minsInd       = $('<input name="numMinsInd" id="' + wgt.options.edit_mbr_form_minutes_ind +'" type="number" title="Enter minutes" min="0" max="1440" style="width: 6em;"/>');
  var $checkboxesInd = $('<div id="' + wgt.options.edit_mbr_form_days_checkboxes_ind + '" class=\"d-flex justify-content-around\"></div>');
  var $mondayInd     = $('<input id="' + wgt.options.edit_mbr_form_monday_checkbox_ind + '" name="mondayCheckboxInd" class="checkbox-item edit-input" type="checkbox" value="monday">');
  var $tuesdayInd    = $('<input id="' + wgt.options.edit_mbr_form_tuesday_checkbox_ind + '" name="tuesdayCheckboxInd" class="checkbox-item edit-input" type="checkbox" value="tuesday">');
  var $wednesdayInd  = $('<input id="' + wgt.options.edit_mbr_form_wednesday_checkbox_ind + '" name="wednesdayCheckboxInd" class="checkbox-item edit-input" type="checkbox" value="wednesday">');
  var $thursdayInd   = $('<input id="' + wgt.options.edit_mbr_form_thursday_checkbox_ind + '" name="thursdayCheckboxInd" class="checkbox-item edit-input" type="checkbox" value="thursday">');
  var $fridayInd     = $('<input id="' + wgt.options.edit_mbr_form_friday_checkbox_ind + '" name="fridayCheckboxInd" class="checkbox-item edit-input" type="checkbox" value="friday">');

  $($checkboxesInd).append($mondayInd);
  $($checkboxesInd).append($tuesdayInd);
  $($checkboxesInd).append($wednesdayInd);
  $($checkboxesInd).append($thursdayInd);
  $($checkboxesInd).append($fridayInd);

  $($formRow3Col1).append($lblMinsInd);
  $($formRow3Col1).append($minsInd);
  $($formRow3Col2).append($checkboxesInd);
    
  $($frmRow3).append($formRow3Col1);
  $($frmRow3).append($formRow3Col2);   
  $($frmTable).append($frmRow3);

  /* Group minutes and days of the week inputs */
	
  var $frmRow4       = $('<tr></tr>');
  var $formRow4Col1  = $('<td></td>');
  var $formRow4Col2  = $('<td></td>');
  var $lblMinsGrp    = $('<label class="w-50" for="' + wgt.options.edit_mbr_form_minutes_grp + '">Group Sessions</label>');
  var $minsGrp       = $('<input name="numMinsGrp" id="' + wgt.options.edit_mbr_form_minutes_grp +'" type="number" title="Enter minutes" min="0" max="1440" style="width: 6em;"/>');
  var $checkboxesGrp = $('<div id="' + wgt.options.edit_mbr_form_days_checkboxes_grp + '" class=\"d-flex justify-content-around\"></div>');
  var $mondayGrp     = $('<input id="' + wgt.options.edit_mbr_form_monday_checkbox_grp + '" name="mondayCheckboxGrp" class="checkbox-item edit-input" type="checkbox" value="monday">');
  var $tuesdayGrp    = $('<input id="' + wgt.options.edit_mbr_form_tuesday_checkbox_grp + '" name="tuesdayCheckboxGrp" class="checkbox-item edit-input" type="checkbox" value="tuesday">');
  var $wednesdayGrp  = $('<input id="' + wgt.options.edit_mbr_form_wednesday_checkbox_grp + '" name="wednesdayCheckboxGrp" class="checkbox-item edit-input" type="checkbox" value="wednesday">');
  var $thursdayGrp   = $('<input id="' + wgt.options.edit_mbr_form_thursday_checkbox_grp + '" name="thursdayCheckboxGrp" class="checkbox-item edit-input" type="checkbox" value="thursday">');
  var $fridayGrp     = $('<input id="' + wgt.options.edit_mbr_form_friday_checkbox_grp + '" name="fridayCheckboxGrp" class="checkbox-item edit-input" type="checkbox" value="friday">');

  $($checkboxesGrp).append($mondayGrp);
  $($checkboxesGrp).append($tuesdayGrp);
  $($checkboxesGrp).append($wednesdayGrp);
  $($checkboxesGrp).append($thursdayGrp);
  $($checkboxesGrp).append($fridayGrp);

  $($formRow4Col1).append($lblMinsGrp);
  $($formRow4Col1).append($minsGrp);
  $($formRow4Col2).append($checkboxesGrp);
    
  $($frmRow4).append($formRow4Col1);
  $($frmRow4).append($formRow4Col2);   
  $($frmTable).append($frmRow4);

  /* Annual minutes and Service start date */

  var $frmRow5       = $('<tr></tr>');
  var $formRow5Col1  = $('<td></td>');
  var $formRow5Col2  = $('<td></td>');
  var $lblMinsAnn    = $('<label class="w-50" for="' + wgt.options.edit_mbr_form_minutes_ann + '">Total Annual Minutes</label>');
  var $minsAnn       = $('<input name="numMinsAnn" id="' + wgt.options.edit_mbr_form_minutes_ann +'" type="number" title="Enter minutes" min="0" max="525600" style="width: 6em;"/>');
  var $lblStartDate  = $('<label for="' + wgt.options.edit_mbr_form_start_date + '">Date Service was Authorized &nbsp;</label>');
  var $startDate     = $('<input name="startDateTmtSvcs" id="' + wgt.options.edit_mbr_form_start_date +'" type="date" title="Enter Date" style="width: 9em;"/>');

  $($formRow5Col1).append($lblMinsAnn);
  $($formRow5Col1).append($minsAnn);
  $($formRow5Col2).append($lblStartDate);
  $($formRow5Col2).append($startDate);
  $($frmRow5).append($formRow5Col1);
  $($frmRow5).append($formRow5Col2);   
  $($frmTable).append($frmRow5);

  /* Plan type */

  var $frmRow6       = $('<tr></tr>');
  var $formRow6Col1  = $('<td></td>');
  var $formRow6Col2  = $('<td style="display: flex;justify-content: space-between;"></td>');
  var $lblPlanType   = $('<label for="' + wgt.options.edit_mbr_form_plan_type + '">Select a Plan Type</label>');
  var $planType      = $('<select id="' + wgt.options.edit_mbr_form_plan_type +  '" name="planType" style="height: 2em; width: 9em;">'
                          + '<option value="1" selected> IEP / IFSP</option>'
                          + '<option value="2">Other (IHP, 504, Counseling, etc.)</option>'
                       + '</select>');

  $($formRow6Col2).append($lblPlanType);
  $($formRow6Col2).append($planType);
  $($frmRow6).append($formRow6Col1);
  $($frmRow6).append($formRow6Col2);
  $($frmTable).append($frmRow6);

  /* Record Assessments */
	
  //var $assessmentContainer  = $('<div class="d-flex justify-content-between align-items-center" style="margin-top: 0.5em;"><p>Date of Last Recorded Assessment</p></div>');
  //var $assessmentDate       = $('<p style="padding: 0.25em 4em; border: 1px solid;">' + temporaryDate + '</p>');
  //var $assessmentRecordLink = $('<a href="" style="text-decoration: underline; color: #0000EE; margin-bottom: 1em;">Record Assessment</a>');
  
  //$($assessmentContainer).append($assessmentDate);
  //$($assessmentContainer).append($assessmentRecordLink);

	
  /* Append to form */

  $(frm).append($frmTable);
  $(frm).append($hiddenText);
  //$(frm).append($assessmentContainer);

};

/***************************************************************************
* Functions related to the behavior of the 'days of the week' checkboxes   *
 ***************************************************************************/

function updateCheckboxJSON(wgt) {
    // update JSON based on the checkboxes (called every time one of the checkboxes changes)
    $('#' + wgt.options.add_mbr_form_week_days_json).val("{\"monInd\":" + mondayCheckBoxValueInd + ",\"tueInd\":" + tuesdayCheckBoxValueInd + ",\"wedInd\":" + wednesdayCheckBoxValueInd + ",\"thurInd\":" + thursdayCheckBoxValueInd + ",\"friInd\":" + fridayCheckBoxValueInd + ",\"monGrp\":" + mondayCheckBoxValueGrp + ",\"tueGrp\":" + tuesdayCheckBoxValueGrp + ",\"wedGrp\":" + wednesdayCheckBoxValueGrp + ",\"thurGrp\":" + thursdayCheckBoxValueGrp + ",\"friGrp\":" + fridayCheckBoxValueGrp + "}");
}

function updateCheckboxJSONEdit(wgt) {
    // update JSON based on the checkboxes (called every time one of the checkboxes changes)
    $('#' + wgt.options.edit_mbr_form_week_days_json).val("{\"monInd\":" + mondayCheckBoxValueEditInd + ",\"tueInd\":" + tuesdayCheckBoxValueEditInd + ",\"wedInd\":" + wednesdayCheckBoxValueEditInd + ",\"thurInd\":" + thursdayCheckBoxValueEditInd + ",\"friInd\":" + fridayCheckBoxValueEditInd + ",\"monGrp\":" + mondayCheckBoxValueEditGrp + ",\"tueGrp\":" + tuesdayCheckBoxValueEditGrp + ",\"wedGrp\":" + wednesdayCheckBoxValueEditGrp + ",\"thurGrp\":" + thursdayCheckBoxValueEditGrp + ",\"friGrp\":" + fridayCheckBoxValueEditGrp + "}");
}


 /***************************************************************************
  * caseloadAddMemberCustomClearFields */
 /**
  * Handles clearing fields that the standard form clear cannot
  ***************************************************************************/ 

var $fnCaseloadAddMemberCustomClearFields = function (wgt,$frm){ 
  $('#' + wgt.options.add_mbr_form_minutes_ind).val('');
  $('#' + wgt.options.add_mbr_form_minutes_grp).val('');
  $('#' + wgt.options.add_mbr_form_minutes_ann).val('');
  $('#' + wgt.options.add_mbr_form_start_date).val('');

  $('#' + wgt.options.add_mbr_form_monday_checkbox_ind).val('');
  $('#' + wgt.options.add_mbr_form_tuesday_checkbox_ind).val('');
  $('#' + wgt.options.add_mbr_form_wednesday_checkbox_ind).val('');
  $('#' + wgt.options.add_mbr_form_thursday_checkbox_ind).val('');
  $('#' + wgt.options.add_mbr_form_friday_checkbox_ind).val('');

  $('#' + wgt.options.add_mbr_form_monday_checkbox_grp).val('');
  $('#' + wgt.options.add_mbr_form_tuesday_checkbox_grp).val('');
  $('#' + wgt.options.add_mbr_form_wednesday_checkbox_grp).val('');
  $('#' + wgt.options.add_mbr_form_thursday_checkbox_grp).val('');
  $('#' + wgt.options.add_mbr_form_friday_checkbox_grp).val('');
}
 
 /*============================================================
  * Group Delegates
  *============================================================*/ 
 
 /***************************************************************************
  * getMembersGroupRequestData */
 /**
  * Delegate for loading group members for caseload
  ***************************************************************************/ 
  
 function getMembersGroupRequestData (wgt){
   
   var reqData = '{'
				  + '"organizationID":"'  + wgt.options.organizationID + '"'
	              + ',"ownerID":"'        + wgt.options.ownerID        + '"'
			      + ',"groupID":"'        + wgt.options.id             + '"'
				  + ',"term":"'           + ''                         + '"'
                  + '}';

   return reqData;
};
     
/***************************************************************************
 * addMemberGroupDiaContent */
/**
 * Delegate for generating add new member to caseload form content
 ***************************************************************************/ 
  
function addMemberGroupDiaContent (wgt, dia, frm ) {
    
   $(frm).append('<input name="saveType"  value="1" type="hidden" />');
   $(frm).append('<input name="recID"     value=""  type="hidden" />');

  /* Create table to layout fields */

  var $frmTable = $('<table></table>');
	
  /* Select patient */

  var $frmRow1       = $('<tr></tr>');
  var $formRow1Col1  = $('<td></td>');
  var $formRow1Col2  = $('<td></td>');
  var $lblPatSel     = $('<label for="' + wgt.options.add_mbr_form_entity_id + '">Select a Patient</label>');
  var $patSel        = $('<input name="entityID" id="' + wgt.options.add_mbr_form_entity_id  +'" title="Last Name, First Name" class="mba-web-ui-field-simple" type="text"/>');
	
  $($formRow1Col1).append($lblPatSel);
  $($formRow1Col2).append($patSel);	
	
  $($frmRow1).append($formRow1Col1);
  $($frmRow1).append($formRow1Col2);
    
  $($frmTable).append($frmRow1);

  /* Append to form */

  $(frm).append($frmTable);

  /* Enhance */
	
  var $patSelUrl = $.spedmonWebUI.createPrivateURL(wgt.options.tkn,"practitioner_caseload_members.asmx/viewSel");
  var $patSelNVP = [   { name:"organizationID",       value:(wgt.options.organizationID) }
                     , { name:"ownerID",              value:(wgt.options.ownerID)        }	
					 , { name:"groupID",              value:(wgt.options.ownerID)        }							  
				     
			        ];

  $($patSel).spedmonSelectBox({dataParmType:"DOM", selectAll:true, selectType:($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),onSelect:function(event,ui){ /* */},ajaxopts:{url:($patSelUrl),data:"",namevalues:($patSelNVP),getnamevaluesfn:null}});	
	
};
  

/*============================================================
 * Groups List Delegates
 *============================================================*/   

 function getGroupsRequestData (wgt) {
   var reqData    =  '{'
                      +'"organizationID":"' + wgt.options.organizationID + '"'
					  +',"ownerID":"'       + wgt.options.ownerID        + '"'
					  +',"term":""}';
   
   return reqData;
 };
 
 /*#####################################################################################################################
   #
   # Setup
   #
   #####################################################################################################################*/ 

/***************************************************************************
 * setupCaseloadAndGroupMgmtWidgets
/**
 ***************************************************************************/   

function setupCaseloadAndGroupMgmtWidgets ($tkn, $orgID, $ownerID, $caseload, $groups, $caseloadCol, $groupsCol) {

  /*============================================================
   * Caseload options and delegates
   *============================================================*/   

  var $getMembersCaseloadActionURL      = "practitioner_caseload_members.asmx/viewSel";
  var $addMemberCaseloadActionURL       = "practitioner_caseload_members.asmx/save";
  var $editMemberCaseloadActionURL      = "practitioner_caseload_members.asmx/save";
  var $removeMemberCaseloadActionURL    = "practitioner_caseload_members.asmx/delete";
  var $removeGroupCaseloadActionURL     = "";
  var $preloadPatExpectedSvcsURL        = "pat_expected_services.asmx/loadLatestPatData";
  var $fnGetMembersCaseloadRequestData  = getMembersCaseloadRequestData;
  var $fnAddMemberCaseloadDiaContent    = addMemberCaseloadDiaContent;
  var $fnEditMemberCaseloadFormPopulate = fnEditMemberCaseloadFormPopulate;
  var $fnEditMemberCaseloadDiaContent   = editMemberCaseloadDiaContent;
    
  /*============================================================
   * Practitioner Patient Group Options and Delegates
   * Note: These are used in $fnRenderGroupsGroupWidget
   *============================================================*/   
  
  var $getMembersGroupActionURL     = "practitioner_patient_group_members.asmx/viewSel";
  var $addMemberGroupActionURL      = "practitioner_patient_group_members.asmx/save";
  var $removeMemberGroupActionURL   = "practitioner_patient_group_members.asmx/delete";
  var $removeGroupGroupActionURL    = "practitioner_patient_groups.asmx/delete";
  
  var $fnGetMembersGroupRequestData = getMembersGroupRequestData;
  var $fnAddMemberGroupDiaContent   = addMemberGroupDiaContent;

  /*============================================================
   * Practitioner Patient Group List Options and Delegates
   *============================================================*/   

  var $addNewGroupActionURL      = "practitioner_patient_groups.asmx/save";
  var $changeGroupNameActionURL  = "practitioner_patient_groups.asmx/save";
  var $getGroupsActionURL        = "practitioner_patient_groups.asmx/viewSel";
  var $fnGetGroupsRequestData    = getGroupsRequestData;
  
  /* Note: This delegate uses vars declared above */  
  
  var $fnRenderGroupsGroupWidget = function (wgt,grpObj,grpMkup) {
    
    $(grpMkup).entitygroup({  id: (grpObj.groupID)
                             , organizationID: $orgID
                             , ownerID: $ownerID
                             , name: (grpObj.lbl)
                             , tkn: $tkn
							 , entityGroupsReference1:($groups)
							 , allowChangeGroupName: true
                             , allowShowHideContent: true
                             , allowRemoveGroup: true
                             , allowAddMemberDrop: true
                             , allowMemberEdit:false
                             , searchTermInpPlaceholder:"Type Text to Filter this Group"
                             , addMemberButLabel:"Add Patient"
                             , addMemberDiaTitle:"Add Patient to this Group"  
                             , removeMemberButLabel:"Remove Patient"
                             , removeMemberDiaTitle:"Remove Patient from this Group"                               
                             , getMembersActionURL: $getMembersGroupActionURL
                             , addNewMemberActionURL: $addMemberGroupActionURL                          
                             , removeMemberActionURL: $removeMemberGroupActionURL
                             , changeGroupNameActionURL: $changeGroupNameActionURL
                             , removeGroupActionURL: $removeGroupGroupActionURL
                             , fnGetMembersRequestData: $fnGetMembersGroupRequestData
                             , fnAddMemberDiaContent: $fnAddMemberGroupDiaContent                             
                          });
  };
  
  
  /*============================================================
   * Create caseload entity group widget
   *============================================================*/   
   
  $($caseload).entitygroup ({   id: $ownerID
                                , organizationID: $orgID
                                , ownerID: $ownerID
                                , name: "My Caseload"
                                , tkn: $tkn
								, entityGroupsReference2:($groups)
                                , allowChangeGroupName: false
                                , allowShowHideContent: false
                                , allowRemoveGroup: false
                                , allowAddMemberDrop: false
                                , searchTermInpPlaceholder:"Type Text to Filter Caseload List"
                                , addMemberButLabel:"Add Patient"
                                , addMemberDiaTitle:"Add Patient to Caseload" 
								, addMemberDiaWidth:820
                                , addMemberDiaHeight:450
                                , addMemberDiaResizable:false
								, fnAddMemberCustomClearFields:$fnCaseloadAddMemberCustomClearFields
                                , editMemberButLabel:"Edit Patient"
                                , editMemberDiaTitle:"Edit Patient Caseload Data"
								, editMemberDiaWidth:790
                                , editMemberDiaHeight:400
                                , editMemberDiaResizable:false
                                , removeMemberButLabel:"Remove Patient"
                                , removeMemberDiaTitle:"Remove Patient from Caseload"                               
                                , getMembersActionURL: $getMembersCaseloadActionURL
                                , addNewMemberActionURL: $addMemberCaseloadActionURL
                                , editMemberActionURL: $editMemberCaseloadActionURL
                                , removeMemberActionURL: $removeMemberCaseloadActionURL
                                , removeGroupActionURL: $removeGroupCaseloadActionURL
                                , preloadPatExpectedSvcsURL: $preloadPatExpectedSvcsURL
                                , fnGetMembersRequestData: $fnGetMembersCaseloadRequestData
                                , fnAddMemberDiaContent: $fnAddMemberCaseloadDiaContent
                                , fnEditMemberFormPopulate:$fnEditMemberCaseloadFormPopulate
                                , fnEditMemberDiaContent: $fnEditMemberCaseloadDiaContent 
                           });

  /*============================================================
   * Get global reference to caseload 
   *============================================================*/

   var fnSetExtRefToThis = function ($refToThis) {
     gblWgt = $refToThis;
   };

   $($caseload).entitygroup("getExternalRefToWgt", fnSetExtRefToThis);

  /*============================================================
   * Create groups list widget
   * Note: This widget will create the group widgets
   *============================================================*/   
  
  $($groups).entitygroups ({ id: $ownerID
                              , organizationID: $orgID
                              , ownerID: $ownerID
                              , name: "My Groups"
                              , tkn: $tkn
						      , allowShowHideGroupsContent:true
							  , allowFilterGroups:true
                              , getGroupsActionURL:$getGroupsActionURL
                              , addNewGroupActionURL: $addNewGroupActionURL
                              , fnGetGroupsRequestData:$fnGetGroupsRequestData
                              , fnRenderGroupWidget:$fnRenderGroupsGroupWidget                                 
                            });
  
};

// event listeners for the checkboxes

$(function () {
    $(document).on('change', 'input.new-input', function () {
        mondayCheckBoxValueInd = $('#' + gblWgt.options.add_mbr_form_monday_checkbox_ind).prop('checked');
        tuesdayCheckBoxValueInd = $('#' + gblWgt.options.add_mbr_form_tuesday_checkbox_ind).prop('checked');
        wednesdayCheckBoxValueInd = $('#' + gblWgt.options.add_mbr_form_wednesday_checkbox_ind).prop('checked');
        thursdayCheckBoxValueInd = $('#' + gblWgt.options.add_mbr_form_thursday_checkbox_ind).prop('checked');
        fridayCheckBoxValueInd = $('#' + gblWgt.options.add_mbr_form_friday_checkbox_ind).prop('checked');

        mondayCheckBoxValueGrp = $('#' + gblWgt.options.add_mbr_form_monday_checkbox_grp).prop('checked');
        tuesdayCheckBoxValueGrp = $('#' + gblWgt.options.add_mbr_form_tuesday_checkbox_grp).prop('checked');
        wednesdayCheckBoxValueGrp = $('#' + gblWgt.options.add_mbr_form_wednesday_checkbox_grp).prop('checked');
        thursdayCheckBoxValueGrp = $('#' + gblWgt.options.add_mbr_form_thursday_checkbox_grp).prop('checked');
        fridayCheckBoxValueGrp = $('#' + gblWgt.options.add_mbr_form_friday_checkbox_grp).prop('checked');

        updateCheckboxJSON(gblWgt);
    });

    $(document).on('change', 'input.edit-input', function () {
        mondayCheckBoxValueEditInd = $('#' + gblWgt.options.edit_mbr_form_monday_checkbox_ind).prop('checked');
        tuesdayCheckBoxValueEditInd = $('#' + gblWgt.options.edit_mbr_form_tuesday_checkbox_ind).prop('checked');
        wednesdayCheckBoxValueEditInd = $('#' + gblWgt.options.edit_mbr_form_wednesday_checkbox_ind).prop('checked');
        thursdayCheckBoxValueEditInd = $('#' + gblWgt.options.edit_mbr_form_thursday_checkbox_ind).prop('checked');
        fridayCheckBoxValueEditInd = $('#' + gblWgt.options.edit_mbr_form_friday_checkbox_ind).prop('checked');

        mondayCheckBoxValueEditGrp = $('#' + gblWgt.options.edit_mbr_form_monday_checkbox_grp).prop('checked');
        tuesdayCheckBoxValueEditGrp = $('#' + gblWgt.options.edit_mbr_form_tuesday_checkbox_grp).prop('checked');
        wednesdayCheckBoxValueEditGrp = $('#' + gblWgt.options.edit_mbr_form_wednesday_checkbox_grp).prop('checked');
        thursdayCheckBoxValueEditGrp = $('#' + gblWgt.options.edit_mbr_form_thursday_checkbox_grp).prop('checked');
        fridayCheckBoxValueEditGrp = $('#' + gblWgt.options.edit_mbr_form_friday_checkbox_grp).prop('checked');

        updateCheckboxJSONEdit(gblWgt);
    });
});

