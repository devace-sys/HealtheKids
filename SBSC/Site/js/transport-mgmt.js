
/*#####################################################################################################################
  #
  # Trip Calculations
  #
  #####################################################################################################################*/ 

/***************************************************************************
 * fnTripCalcLoadRefreshOrNew
/**
 ***************************************************************************/   

function fnTripCalcLoadRefreshOrNew (tkn, cid, pid, opid, dpid, fnReturnData) {
  
  if (!opid) return;
  if (!dpid) return;
  
  var reqUrl     = $.spedmonWebUI.createPrivateURL(tkn,"transport_mgmt_trip_calculations.asmx/loadRefreshOrNew");
  
  var reqData = '{'
              + ' "organizationid":"'  + cid  + '"'
              + ',"entityid":"'        + pid  + '"'
              + ',"origplaceid":"'     + opid + '"'
              + ',"destplaceid":"'     + dpid + '"'
              + '}';  

      
  var fnProcRespSuccess = function (rd) {
    fnReturnData(rd);	
  };
 
  var fnComplete = function() {};
   
  $.spedmonWebUI.ajax(null, reqUrl, reqData, 'json_synch', null, null, null, null, 0, fnProcRespSuccess, fnComplete, null);
    
  return;
  
};

/*#####################################################################################################################
  #
  # Patient Places
  #
  #####################################################################################################################*/ 

 /***************************************************************************
  * fnGetPatientPlacesInfo */
 /**
  * Gets info table of patient places and renders an HTML table that is put
  * inside $placesDiv.
  ***************************************************************************/ 

function fnGetPatPlacesInfo (tkn, cid, pid, $placesDiv) {
   
  var reqUrl  = $.spedmonWebUI.createPrivateURL(tkn,"patient_places.asmx/viewinfo");
   
  var reqData = '{'
              + '"clientid":"'  + cid + '"'
              + ',"patid":"'    + pid + '"'
              + '}';  

  var tblStr = '';
   
  $($placesDiv).html('');
   
  var fnProcRespSuccess = function (rd) {
    tblStr = $.spedmonWebUI.ReturnInfoTableRenderHTMLTableStringBase(rd,'No patient places','mba-entity-group-member-info-table',false, false);
	$($placesDiv).html(tblStr); 
  };
 
  var fnComplete = function() {};
   
  $.spedmonWebUI.ajax(null, reqUrl, reqData, 'json_synch', null, null, null, null, 0, fnProcRespSuccess, fnComplete, null);

};

/***************************************************************************
 * fnOpenSubPagePatPlaceMgmtUrl */
/**
 * Shared function that opens up a sub page for adding, editing, or deleting
 * patient places depending on url.
 ***************************************************************************/ 

function fnOpenSubPagePatPlaceMgmtUrl (url, tkn, cid, pid, $placesDiv) {

  var reqUrl = $.spedmonWebUI.createPrivateURL(tkn,url)
	         + '&amd=uidbssub'
			 + '&clientid=' + cid
			 + '&patid='    + pid
			 
  var fnEntryTest = function(){ return true;};
  var fnExitTest  = function(){ return true;};
  var fnResume    = function(){ 
    fnGetPatPlacesInfo ( tkn, cid, pid, $placesDiv );	 
	return true;
  };
	 
  $.spedmonWebUI.popupThenResume (  fnEntryTest
                                  , fnExitTest
                                  , fnResume
                                  , reqUrl
                                  , 'Popups Not Supported'
                                  , 'Please allow popups for SpEdCare'
					              , 'Waiting'
                                  , 'Waiting for you  to finish with patient places'); 
};

/***************************************************************************
 * fnEditDelPatPlace */
/**
 * Opens up sub page for editing or deleting patient places
 ***************************************************************************/ 

function fnEditDelPatPlace (tkn, cid, pid, $placesDiv) {
  fnOpenSubPagePatPlaceMgmtUrl ('user_all_patient_places_edit_delete.aspx', tkn, cid, pid, $placesDiv);
};

/***************************************************************************
 * fnAddNewPatPlacePlace */
/**
 * Opens up sub page for adding new patient places
 ***************************************************************************/ 

function fnAddNewPatPlace (tkn, cid, pid, $placesDiv) {
  fnOpenSubPagePatPlaceMgmtUrl ('user_all_patient_places_save.aspx', tkn, cid, pid, $placesDiv);
};

/*#####################################################################################################################
  #
  # Authorized Patients
  #
  #####################################################################################################################*/ 


/***************************************************************************
 * fnGetMembersAuthPatientsRequestData */
/**
 * Used for requesting list of authorized patients
 ***************************************************************************/ 
 
function getMembersAuthPatientsRequestData (wgt) {
  var reqData  =  '{'
               +' "organizationID":"' + wgt.options.organizationID + '"'
			   +',"ownerID":"'        + wgt.options.ownerID        + '"'
			   +',"groupID":"'        + wgt.options.ownerID        + '"'
			   +',"term":""}';
   
  return reqData;  
};
     
/***************************************************************************
 * fnAddMemberAuthPatientsDiaContent */
/**
 * 
 ***************************************************************************/ 

function addMemberAuthPatientsDiaContent (wgt, dia, frm ) {
    
  /*============================================================
   * Fields that we will be just submitting
   *============================================================*/ 

  $(frm).append('<input name="saveType"    value="1" type="hidden" />');
  $(frm).append('<input name="recID"       value=""  type="hidden" />');  
  $(frm).append('<input name="sitePlaceID" value=""  type="hidden" />');  
  $(frm).append('<input name="homePlaceID" value=""  type="hidden" />');

  /*============================================================
   * Create unique ids for fields we will be enhancing or
   * interacting with
   *============================================================*/ 
  
  var me_id  = $(wgt.element).attr('id');
  var frm_id = $(frm).attr('id');    
	
  /*============================================================
   * Patient id
   *============================================================*/ 
  
  var $patSel = $('<input name="entityID" id="' + wgt.options.add_mbr_form_entity_id  +'" title="Last Name, First Name" class="mba-web-ui-field-simple" type="text"/>');	  
  
  var $l1 = wgt._generateFormGridColLabel('Select A Patient');  
  var $r1 = wgt._generateFormGridRow ($l1, $patSel);
  var $fg = wgt._generateFormGridContainer ($r1);
  $(frm).append($fg);  

 	
  /*============================================================
   * Enhance patient id into patient selection
   *============================================================*/ 
  
  var $patSelUrl = $.spedmonWebUI.createPrivateURL(wgt.options.tkn,"patients.asmx/viewSelForTransMgmt");
  var $patSelNVP = [   { name:"clientid",       value:(wgt.options.organizationID) } ];
  $($patSel).spedmonSelectBox({dataParmType:"DOM", selectAll:true, selectType:($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),onSelect:function(event,ui){ /* */},ajaxopts:{url:($patSelUrl),data:"",namevalues:($patSelNVP),getnamevaluesfn:null}});	
	
};

/***************************************************************************
 * fnEditMemberAuthPatientsFormPopulate */
/**
 * 
 ***************************************************************************/   

function fnEditMemberAuthPatientsFormPopulate (wgt, $frm, mbrObj) {
  
  $('#' + wgt.options.edit_mbr_form_place_site + '_selection').val(mbrObj.recData1);  
  $('#' + wgt.options.edit_mbr_form_place_site_address).html(mbrObj.recData2);  
  $('#' + wgt.options.edit_mbr_form_place_site_id).val(mbrObj.recData3); 
  
  $('#' + wgt.options.edit_mbr_form_place_home + '_selection').val(mbrObj.recData4);
  $('#' + wgt.options.edit_mbr_form_place_home_address).html(mbrObj.recData5);
  $('#' + wgt.options.edit_mbr_form_place_home_id).val(mbrObj.recData6);
  
  var $divPlaces = $('#' + wgt.options.edit_mbr_form_places);
  
  fnGetPatPlacesInfo (   wgt.options.tkn
	                   , wgt.options.organizationID
					   , mbrObj.entityID
					   , $divPlaces
					  );
};

/***************************************************************************
 * editMemberAuthPatientsDiaContent */
/**
 * 
 ***************************************************************************/   

function editMemberAuthPatientsDiaContent (wgt, dia, frm) {
    
  /*============================================================
   * Fields that we will be just submitting
   *============================================================*/ 
  
  $(frm).append('<input name="saveType"  value="2" type="hidden" />');
  $(frm).append('<input name="recID"     value="' + wgt.options.id +'"  type="hidden" />');
     
  /*============================================================
   * Create unique ids for fields we will be enhancing or
   * interacting with
   *============================================================*/ 
  
  var me_id  = $(wgt.element).attr('id');
  var frm_id = $(frm).attr('id');
    
  wgt.options.edit_mbr_form_place_site             = me_id + '-' + frm_id + '-edit-place-site';
  wgt.options.edit_mbr_form_place_site_address     = me_id + '-' + frm_id + '-edit-place-site-address';
  wgt.options.edit_mbr_form_place_site_id          = me_id + '-' + frm_id + '-edit-place-site-place-id';  
  wgt.options.edit_mbr_form_place_home             = me_id + '-' + frm_id + '-edit-place-home';
  wgt.options.edit_mbr_form_place_home_address     = me_id + '-' + frm_id + '-edit-place-home-address';
  wgt.options.edit_mbr_form_place_home_id          = me_id + '-' + frm_id + '-edit-place-home-place-id';    
  wgt.options.edit_mbr_form_places                 = me_id + '-' + frm_id + '-places';
	
  /*============================================================
   * Patient 
   *============================================================*/ 
  
  var $patSel          = $('<input name="entityID" id="' + wgt.options.edit_mbr_form_entity_id +'" value="" type="hidden"/>');
  var $patName         = $('<input class="mba-entity-group-member-field-read-only" name="lbl" id="' + wgt.options.edit_mbr_form_lbl +'" value="" type="text" readonly/>');
  
  /*============================================================
   * Site
   *============================================================*/ 

  var $siteSel          = $('<input name="site"           id="'  +  wgt.options.edit_mbr_form_place_site            + '" title="Select Site" class="mba-web-ui-field-simple" type="text"/>');
  var $siteAddressInp   = $('<span id="' + wgt.options.edit_mbr_form_place_site_address  + '" class="mba-entity-group-member-extra-data"></span>');    
  var $sitePlaceIdInp   = $('<input name="sitePlaceID"    id="'  +  wgt.options.edit_mbr_form_place_site_id  + '" type="hidden"/>');

  /*============================================================
   * Home
   *============================================================*/ 

  var $homeSel          = $('<input name="home"           id="'  +  wgt.options.edit_mbr_form_place_home            + '" title="Select Site" class="mba-web-ui-field-simple" type="text"/>');
  var $homeAddressInp   = $('<span id="'  +  wgt.options.edit_mbr_form_place_home_address  + '" class="mba-entity-group-member-extra-data"></span>');    
  var $homePlaceIdInp   = $('<input name="homePlaceID"    id="'  +  wgt.options.edit_mbr_form_place_home_id  + '" type="hidden"/>');

  /*============================================================
   * Patient Places
   *============================================================*/ 
    
  var $butAddNewPlace  = $('<button type="button">Add New Place</button>');
  var $butEditDelPlace = $('<button type="button">Edit or Delete Places</button>');
  var $divPlaces       = $('<div id="' + wgt.options.edit_mbr_form_places + '"></div>');
   
   
  $(frm).append($patSel);  
  $(frm).append($sitePlaceIdInp);  
  $(frm).append($homePlaceIdInp);

  var $l1 = wgt._generateFormGridColLabel('Patient');
  var $f1 = $('<span></span>');
  var $r1 = wgt._generateFormGridRow ($l1, $patName,$f1);
  
  var $l2 = wgt._generateFormGridColLabel('Select School Place');
  var $r2 = wgt._generateFormGridRow ($l2, $siteSel, $siteAddressInp);
  
  var $l3 = wgt._generateFormGridColLabel('Select Home Place');
  var $r3 = wgt._generateFormGridRow ($l3, $homeSel, $homeAddressInp);
  
  var $l4 = wgt._generateFormGridColLabel('Other Places');
  var $r4 = wgt._generateFormGridRow ($l4, $butAddNewPlace, $butEditDelPlace);
  
  var $fg = wgt._generateFormGridContainer ($r1,$r2,$r3,$r4);  
  
  $(frm).append ($fg);
  $(frm).append ($divPlaces);

 
  /* Enhance */
  
  $($butAddNewPlace).button().click (function(e) {
    var tkn = wgt.options.tkn;
    var cid = wgt.options.organizationID;
	var pid = $($patSel).val();
	fnAddNewPatPlace (tkn, cid, pid, $divPlaces)
  });
  
  $($butEditDelPlace).button().click(function(e) {
    var tkn = wgt.options.tkn;
    var cid = wgt.options.organizationID;
	var pid = $($patSel).val();
    fnEditDelPatPlace (tkn, cid, pid, $divPlaces)
  });
  
  var $sitePlacesSelUrl = $.spedmonWebUI.createPrivateURL(wgt.options.tkn,"site_places.asmx/viewSel");    
  var $patPlacesSelUrl  = $.spedmonWebUI.createPrivateURL(wgt.options.tkn,"patient_places.asmx/viewSel");  
  
  var fnGetPatID        = function() { return $($patSel).val(); };    
  var fnGetPlacesSelNVP = function() {
  
    var nvpData = [   { name:"clientid",   value:(wgt.options.organizationID) }
                    , { name:"patid",      value:(fnGetPatID())               } 					
				  ];
    
	return nvpData;
  };
  
  $($siteSel).spedmonSelectBox({dataParmType:"DOM", selectAll:true, selectType:($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),onSelect:function(event,ui){ $($siteAddressInp).html(ui.item.recData1);$($sitePlaceIdInp).val(ui.item.recData2); },ajaxopts:{url:($sitePlacesSelUrl),data:"",namevalues:null,getnamevaluesfn:(fnGetPlacesSelNVP)}});
  $($homeSel).spedmonSelectBox({dataParmType:"DOM", selectAll:true, selectType:($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),onSelect:function(event,ui){ $($homeAddressInp).html(ui.item.recData1);$($homePlaceIdInp).val(ui.item.recData2);},ajaxopts:{url:($patPlacesSelUrl),data:"",namevalues:null,getnamevaluesfn:(fnGetPlacesSelNVP)}});
 
  
};

/*#####################################################################################################################
  #
  # Authorized Routes
  #
  #####################################################################################################################*/ 

/***************************************************************************
 * getAuthRoutesRequestData */
/**
 * 
 ***************************************************************************/   

function getAuthRoutesRequestData (wgt) {

  var reqData    = '{'
                 + '"organizationID":"' + wgt.options.organizationID + '"'
                 + ',"ownerID":"'       + wgt.options.ownerID        + '"'
                 + ',"term":""}';
   
  return reqData;
};

/***************************************************************************
 * setupAuthRouteOrigDestSels */
/**
 * Note: Called by both entitygroups and entitygroup
 ***************************************************************************/   

function setupAuthRouteOrigDestSels (wgt, dia, frm, $origDestSel, $placeIdInp) {
    
  var $sitePlacesSelUrl = $.spedmonWebUI.createPrivateURL(wgt.options.tkn,"site_places.asmx/viewSel");
  
  var fnGetPatID        = function() { return $($patSel).val(); };    
  var fnGetPlacesSelNVP = function() {
  
  var nvpData = [   { name:"clientid", value:(wgt.options.organizationID) }
                  , { name:"patid",    value:""                           } 					
				];
    
	return nvpData;
  };
  
  $($origDestSel).spedmonSelectBox({dataParmType:"DOM", selectAll:true, selectType:($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),onSelect:function(event,ui){ $($placeIdInp).val(ui.item.recData2); },ajaxopts:{url:($sitePlacesSelUrl),data:"",namevalues:null,getnamevaluesfn:(fnGetPlacesSelNVP)}});    
};

/***************************************************************************
 * addNewAuthRouteDiaContent */
/**
 * Note: Called by entitygroups
 ***************************************************************************/   
 
function addNewAuthRouteDiaContent (wgt, dia, frm) {
  
  /*============================================================
   * Create unique ids for fields we will be enhancing or
   * interacting with
   *============================================================*/ 
  
  var me_id  = $(wgt.element).attr('id');
  var frm_id = $(frm).attr('id');    
  
  /* Note a group name unique id is already provided by the widget */
  
  wgt.options.add_new_grp_form_group_bus_num_id         = me_id + '-' + frm_id + '-add-new-auth-route-bus-num';   
  wgt.options.add_new_grp_form_group_orig               = me_id + '-' + frm_id + '-add-new-auth-route-orig';
  wgt.options.add_new_grp_form_group_orig_placeid_id    = me_id + '-' + frm_id + '-add-new-auth-route-orig-placeid';
  wgt.options.add_new_grp_form_group_dest               = me_id + '-' + frm_id + '-add-new-auth-route-dest';
  wgt.options.add_new_grp_form_group_dest_placeid_id    = me_id + '-' + frm_id + '-add-new-auth-route-dest-placeid';

  var $inpGroupName = $('<input name="name"          id="' + wgt.options.add_new_grp_form_group_name_id         + '" type="text" placeholder="Enter new route name"/>');  
  var $inpBusNum    = $('<input name="busNumber"     id="' + wgt.options.add_new_grp_form_group_bus_num_id      + '" type="text" placeholder="Enter bus number"/>');  
  var $origSel      = $('<input name="orig"          id="' + wgt.options.add_new_grp_form_group_orig            + '" title="Select Route Origination"      class="mba-web-ui-field-simple" type="text"/>');
  var $origPlaceID  = $('<input name="origPlaceID"   id="' + wgt.options.add_new_grp_form_group_orig_placeid_id + '" value=""  type="hidden"/>');    
  var $destSel      = $('<input name="dest"          id="' + wgt.options.add_new_grp_form_group_dest            + '" title="Select Route Termination"      class="mba-web-ui-field-simple" type="text"/>'); 
  var $destPlaceID  = $('<input name="destPlaceID"   id="' + wgt.options.add_new_grp_form_group_dest_placeid_id + '" value=""  type="hidden"/>');
  
  $(frm).append($origPlaceID);      
  $(frm).append($destPlaceID);  
  

  var $l1 = wgt._generateFormGridColLabel('Route Name');  
  var $r1 = wgt._generateFormGridRow ($l1, $inpGroupName);
  var $l2 = wgt._generateFormGridColLabel('Bus Number');  
  var $r2 = wgt._generateFormGridRow ($l2, $inpBusNum);
  
  var $l3 = wgt._generateFormGridColLabel('Select Route Origination');  
  var $r3 = wgt._generateFormGridRow ($l3, $origSel);

  var $l4 = wgt._generateFormGridColLabel('Select Route Termination');  
  var $r4 = wgt._generateFormGridRow ($l4, $destSel);
  
  var $fg = wgt._generateFormGridContainer ($r1,$r2,$r3,$r4);
  
  $(frm).append($fg);  
  
  $($inpGroupName).spedmonTextbox({"showOK":false});
  $($inpBusNum).spedmonTextbox({"showOK":false});
  setupAuthRouteOrigDestSels (wgt, dia, frm, $origSel, $origPlaceID);
  setupAuthRouteOrigDestSels (wgt, dia, frm, $destSel, $destPlaceID);

};
  
/***************************************************************************
 * fnChangeExistingAuthRouteFormPopulate
/**
 ***************************************************************************/   

function fnChangeExistingAuthRouteFormPopulate (wgt, $frm ) {
    
  $('#' + wgt.options.chg_grp_form_group_name_id).val(wgt.options.name);
  $('#' + wgt.options.chg_grp_form_group_bus_num_id).val(wgt.options.recData1);
  
  $('#' + wgt.options.chg_grp_form_group_orig + '_selection').val(wgt.options.recData2); 
  $('#' + wgt.options.chg_grp_form_group_orig_placeid_id).val(wgt.options.recData4);

  $('#' + wgt.options.chg_grp_form_group_dest + '_selection').val(wgt.options.recData5);  
  $('#' + wgt.options.chg_grp_form_group_dest_placeid_id).val(wgt.options.recData7); 

}

/***************************************************************************
 * changeExistingAuthRouteDiaContent */
/**
 * Note: Called by entitygroup
 ***************************************************************************/   
 
function changeExistingAuthRouteDiaContent (wgt, dia, frm) {
  
   /* TOD0: Add these fields to the widget code */
   
   $(frm).append('<input name="organizationID" value="' + wgt.options.organizationID +'"  type="hidden" />');
   $(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID        +'"  type="hidden" />');
   $(frm).append('<input name="saveType" value="2" type="hidden" />');
   $(frm).append('<input name="recID"          value="' + wgt.options.id             +'"  type="hidden" />');
  
   
  /*============================================================
   * Create unique ids for fields we will be enhancing or
   * interacting with
   *============================================================*/ 
  
  var me_id  = $(wgt.element).attr('id');
  var frm_id = $(frm).attr('id');    
  
  /* Note a group name unique id is already provided by the widget */
  
  wgt.options.chg_grp_form_group_bus_num_id  = me_id + '-' + frm_id + '-chg-auth-route-bus-num';
  
  wgt.options.chg_grp_form_group_orig               = me_id + '-' + frm_id + '-chg-auth-route-orig';
  wgt.options.chg_grp_form_group_orig_placeid_id    = me_id + '-' + frm_id + '-chg-auth-route-orig-placeid';
  
  wgt.options.chg_grp_form_group_dest               = me_id + '-' + frm_id + '-chg-auth-route-dest';
  wgt.options.chg_grp_form_group_dest_placeid_id    = me_id + '-' + frm_id + '-chg-auth-route-dest-placeid';


  var $inpGroupName = $('<input name="name"          id="' + wgt.options.chg_grp_form_group_name_id         + '" type="text" placeholder="Enter new route name"/>');  
  var $inpBusNum    = $('<input name="busNumber"     id="' + wgt.options.chg_grp_form_group_bus_num_id      + '" type="text" placeholder="Enter bus number"/>');

  var $origSel      = $('<input name="orig"          id="' + wgt.options.chg_grp_form_group_orig            + '" title="Select Route Origination"   class="mba-web-ui-field-simple" type="text"/>');
  var $origPlaceID  = $('<input name="origPlaceID"   id="' + wgt.options.chg_grp_form_group_orig_placeid_id + '" type="hidden"/>');  

  var $destSel      = $('<input name="dest"          id="' + wgt.options.chg_grp_form_group_dest            + '" title="Select Route Termination"   class="mba-web-ui-field-simple" type="text"/>'); 
  var $destPlaceID  = $('<input name="destPlaceID"   id="' + wgt.options.chg_grp_form_group_dest_placeid_id + '" type="hidden"/>');  
    
  $(frm).append($origPlaceID);      
  $(frm).append($destPlaceID);  
  
  
  var $l1 = wgt._generateFormGridColLabel('Route Name');  
  var $r1 = wgt._generateFormGridRow ($l1, $inpGroupName);
  
  var $l2 = wgt._generateFormGridColLabel('Bus Number');  
  var $r2 = wgt._generateFormGridRow ($l2, $inpBusNum);
  
  var $l3 = wgt._generateFormGridColLabel('Select Route Origination');  
  var $r3 = wgt._generateFormGridRow ($l3, $origSel);

  var $l4 = wgt._generateFormGridColLabel('Select Route Termination');  
  var $r4 = wgt._generateFormGridRow ($l4, $destSel);
  
  var $fg = wgt._generateFormGridContainer ($r1,$r2,$r3,$r4);
    
  
  $(frm).append($fg);  

  /* Enhance */
       
  $($inpGroupName).spedmonTextbox({"showOK":false});
  $($inpBusNum).spedmonTextbox({"showOK":false});
  setupAuthRouteOrigDestSels (wgt, dia, frm, $origSel, $origPlaceID);
  setupAuthRouteOrigDestSels (wgt, dia, frm, $destSel, $destPlaceID);

};

/***************************************************************************
 * fnPrintGroupFormPopulate */
/**
 * Note: Called by entitygroup
 ***************************************************************************/   

function fnPrintGroupFormPopulate (wgt,$frm) {
  $('#' + wgt.options.print_grp_form_start_date_id).val(wgt.options.startDateDflt);
};

/***************************************************************************
 * fnPrintGroupDiaContent */
/**
 * Note: Called by entitygroup
 ***************************************************************************/   
 
function fnPrintGroupDiaContent (wgt,dia,frm) {
       
  $(frm).append('<input name="organizationID" value="' + wgt.options.organizationID +'"  type="hidden" />');
  $(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID        +'"  type="hidden" />');
  $(frm).append('<input name="groupID"        value="' + wgt.options.id             +'"  type="hidden" />');
    
  /*============================================================
   * Create unique ids for fields we will be enhancing or
   * interacting with
   *============================================================*/ 
  
  var me_id  = $(wgt.element).attr('id');
  var frm_id = $(frm).attr('id');    
  
  wgt.options.print_grp_form_start_date_id  = me_id + '-' + frm_id + '-start-date';
  
  var $routeName = $('<span class="mba-entity-dia-inline-label">' + wgt.options.name + '</span>');
  var $startDate = $('<input id="' + wgt.options.print_grp_form_start_date_id + '" name="startdate"  type="text" placeholder="Enter start date"/>'); 
  
  /*============================================================
   * Build grid
   *============================================================*/ 
  
  var $l1 = wgt._generateFormGridColLabel('Print Route Sheet For');  
  var $r1 = wgt._generateFormGridRow ($l1, $routeName);
  
  var $l2 = wgt._generateFormGridColLabel('Starting Date for Week Of Service');
  var $r2 = wgt._generateFormGridRow($l2, $startDate);								 
  
  var $fg = wgt._generateFormGridContainer ($r1, $r2);  
  $(frm).append($fg);       
  $($startDate).spedmonDatebox({multidate:false,showOK:false,maxDate:'',dateText:(wgt.options.startDateDflt),defaultDate:(wgt.options.startDateDflt),useVisibleWorkaround:false});

};   
  
/***************************************************************************
 * fnPrintGroupsFormPopulate */
/**
 * Note: Called by entitygroups
 ***************************************************************************/   

function fnPrintGroupsFormPopulate (wgt,$frm){
  $('#' + wgt.options.print_grps_form_start_date_id).val(wgt.options.startDateDflt);
};

/***************************************************************************
 * fnPrintGroupsDiaContent */
/**
 * Note: Called by entitygroups
 ***************************************************************************/   
 
function fnPrintGroupsDiaContent (wgt,dia,frm) {
       
  $(frm).append('<input name="organizationID" value="' + wgt.options.organizationID +'"  type="hidden" />');
  $(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID        +'"  type="hidden" />');
    
  /*============================================================
   * Create unique ids for fields we will be enhancing or
   * interacting with
   *============================================================*/ 
  
  var me_id  = $(wgt.element).attr('id');
  var frm_id = $(frm).attr('id');    
  
  wgt.options.print_grps_form_start_date_id  = me_id + '-' + frm_id + '-start-date';
  
  var $groupsName = $('<span class="mba-entity-dia-inline-label">' + wgt.options.name + '</span>');
  var $startDate  = $('<input id="' + wgt.options.print_grps_form_start_date_id + '" name="startdate"  type="text" placeholder="Enter start date"/>'); 
  
  /*============================================================
   * Build grid
   *============================================================*/ 
  
  var $l1 = wgt._generateFormGridColLabel('Print ALL Route Sheets For');
  var $r1 = wgt._generateFormGridRow ($l1, $groupsName);
  
  var $l2 = wgt._generateFormGridColLabel('Starting Date for Week Of Service');
  var $r2 = wgt._generateFormGridRow($l2, $startDate);								 
  
  var $fg = wgt._generateFormGridContainer ($r1, $r2);  
  $(frm).append($fg);   
     
  $($startDate).spedmonDatebox({multidate:false,showOK:false,maxDate:'',dateText:(wgt.options.startDateDflt),defaultDate:(wgt.options.startDateDflt),useVisibleWorkaround:false});  

  };  

/***************************************************************************
 * fnDuplicateGroupDiaOpen */
/**
 * Note: Called by entitygroup
 ***************************************************************************/

function fnDuplicateGroupDiaOpen(wgt) {
    var $frm = $('#' + wgt.options.dup_grp_form_id);
    var $dia = $('#' + wgt.options.dup_grp_dia_id);
    $.spedmonWebUI.formClear($frm);
    fnDuplicateAuthRouteFormPopulate(wgt, $frm);
    $($dia).dialog("open");

};

/***************************************************************************
 * fnDuplicateAuthRouteFormPopulate */
/**
 * Note: Called by entitygroup
 ***************************************************************************/

function fnDuplicateAuthRouteFormPopulate(wgt, $frm) {
    
};

/***************************************************************************
 * duplicateAuthRouteDiaContent */
/**
 * Note: Called by entitygroup
 ***************************************************************************/

function duplicateAuthRouteDiaContent(wgt, dia, frm) {

    $(frm).append('<input name="organizationID" value="' + wgt.options.organizationID + '"  type="hidden" />');
    $(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID + '"  type="hidden" />');
    $(frm).append('<input name="groupID"        value="' + wgt.options.id + '"  type="hidden" />');
    
    /*============================================================
     * Create unique ids for fields we will be enhancing or
     * interacting with
     *============================================================*/

    var me_id = $(wgt.element).attr('id');
    var frm_id = $(frm).attr('id');

    /* Note a group name unique id is already provided by the widget */

    wgt.options.dup_grp_form_group_new_name_id = me_id + '-' + frm_id + '-dup-auth-route-new-name';
    
    var $spanOriginalName  = $('<span class="mba-entity-dia-inline-label">' + wgt.options.name + '</span>');
    var $inpDuplicateName = $('<input name="name" id="' + wgt.options.dup_grp_form_group_new_name_id + '" type="text" placeholder="Enter new route name"/>');

  /*============================================================
   * Build grid
   *============================================================*/

    var $l1 = wgt._generateFormGridColLabel('Original Route Name');
    var $r1 = wgt._generateFormGridRow($l1, $spanOriginalName);

    var $l2 = wgt._generateFormGridColLabel('New Route Name');
    var $r2 = wgt._generateFormGridRow($l2, $inpDuplicateName);

    var $fg = wgt._generateFormGridContainer($r1, $r2);
    $(frm).append($fg);
    $($inpDuplicateName).spedmonTextbox({ "showOK": false });
};

/***************************************************************************
 * fnDuplicateAndReverseStopsGroupDiaOpen */
/**
 * Note: Called by entitygroup
 ***************************************************************************/

function fnDuplicateAndReverseStopsGroupDiaOpen(wgt) {
    var $frm = $('#' + wgt.options.dup_and_reverse_stops_grp_form_id);
    var $dia = $('#' + wgt.options.dup_and_reverse_stops_grp_dia_id);
    $.spedmonWebUI.formClear($frm);
    fnDuplicateAndReverseStopsAuthRouteFormPopulate(wgt, $frm);
    $($dia).dialog("open");

};

/***************************************************************************
 * fnDuplicateAndReverseStopsAuthRouteFormPopulate */
/**
 * Note: Called by entitygroup
 ***************************************************************************/

function fnDuplicateAndReverseStopsAuthRouteFormPopulate(wgt, $frm) {
    
};

/***************************************************************************
 * duplicateAndReverseStopsAuthRouteDiaContent */
/**
 * Note: Called by entitygroup
 ***************************************************************************/

function duplicateAndReverseStopsAuthRouteDiaContent(wgt, dia, frm) {

    $(frm).append('<input name="organizationID" value="' + wgt.options.organizationID + '"  type="hidden" />');
    $(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID + '"  type="hidden" />');
    $(frm).append('<input name="groupID"        value="' + wgt.options.id + '"  type="hidden" />');
    
    /*============================================================
     * Create unique ids for fields we will be enhancing or
     * interacting with
     *============================================================*/

    var me_id = $(wgt.element).attr('id');
    var frm_id = $(frm).attr('id');

    /* Note a group name unique id is already provided by the widget */

    wgt.options.dup_and_reverse_stops_grp_form_group_new_name_id = me_id + '-' + frm_id + '-dup-and-reverse-stops-auth-route-new-name';
    
    var $spanOriginalName  = $('<span class="mba-entity-dia-inline-label">' + wgt.options.name + '</span>');
    var $inpDuplicateName = $('<input name="name" id="' + wgt.options.dup_and_reverse_stops_grp_form_group_new_name_id + '" type="text" placeholder="Enter new route name"/>');

  /*============================================================
   * Build grid
   *============================================================*/

    var $l1 = wgt._generateFormGridColLabel('Original Route Name');
    var $r1 = wgt._generateFormGridRow($l1, $spanOriginalName);

    var $l2 = wgt._generateFormGridColLabel('New Route Name');
    var $r2 = wgt._generateFormGridRow($l2, $inpDuplicateName);

    var $fg = wgt._generateFormGridContainer($r1, $r2);
    $(frm).append($fg);
    $($inpDuplicateName).spedmonTextbox({ "showOK": false });
};

/*#####################################################################################################################
  #
  # Route Members
  #
  #####################################################################################################################*/ 

// (edit members) attribute given to the days of the week checkboxes to store the id
// of the JSON hiddentText
var hiddenTextIDForWeekDaysJSON = 'hiddenTextIDForWeekDaysJSON';
var defaultWeekDaysJSON = JSON.stringify({
                                          "mon":    true
                                          , "tue":  true
                                          , "wed":  true
                                          , "thur": true
                                          , "fri":  true
                                      });

/***************************************************************************
 * fnGetMembersGroupRequestData */
/**
 ***************************************************************************/   

function getMembersGroupRequestData (wgt) {
   
  var reqData = '{'
                 + '"organizationID":"'  + wgt.options.organizationID + '"'
                 + ',"ownerID":"'        + wgt.options.ownerID        + '"'
                 + ',"groupID":"'        + wgt.options.id             + '"'
                 + ',"term":"'           + ''                         + '"'
                 + '}';
  return reqData;
};
     
/***************************************************************************
 * fnAddMemberGroupViaDropExtraFields
/**
 ***************************************************************************/   

function fnAddMemberGroupViaDropExtraFields (wgt) {
    var newData = ''	              
				  + ',"origPlaceID":""'
		          + ',"destPlaceID":""'
		          + ',"weekDaysJSON":' + JSON.stringify(defaultWeekDaysJSON)
    return newData;
};

/***************************************************************************
 * fnAddMemberGroupDiaContent
/**
 ***************************************************************************/   

function addMemberGroupDiaContent (wgt, dia, frm ) {

  $(frm).append('<input name="saveType"      value="1" type="hidden"/>');
  $(frm).append('<input name="recID"         value=""  type="hidden"/>');
  $(frm).append('<input name="origPlaceID"   value=""  type="hidden"/>');
  $(frm).append('<input name="destPlaceID"   value=""  type="hidden"/>'); 
  $(frm).append('<input name="selectAmPm"    value=""  type="hidden"/>'); 

  // add weekDaysJSON
  var $hiddenWeekDaysJSON = $('<input name="weekDaysJSON" type="hidden"/>');
  $($hiddenWeekDaysJSON).val(defaultWeekDaysJSON);
  $(frm).append($hiddenWeekDaysJSON);

  var $patSel = $('<input name="entityID" id="' + wgt.options.add_mbr_form_entity_id  +'" title="Last Name, First Name" class="mba-web-ui-field-simple" type="text"/>');
       
  var $l1 = wgt._generateFormGridColLabel('Select an Authorized Patient');  
  var $r1 = wgt._generateFormGridRow ($l1, $patSel);
  var $fg = wgt._generateFormGridContainer ($r1);
  
  $(frm).append($fg);

  /* Enhance */
       
  var $patSelUrl = $.spedmonWebUI.createPrivateURL(wgt.options.tkn,"transport_mgmt_auth_patients.asmx/viewSel");
  
  var $patSelNVP = [   { name:"organizationID",       value:(wgt.options.organizationID) }
                     , { name:"ownerID",              value:(wgt.options.ownerID)        }
                                     
                                ];
  $($patSel).spedmonSelectBox({dataParmType:"DOM", selectAll:true, selectType:($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),onSelect:function(event,ui){ /* */},ajaxopts:{url:($patSelUrl),data:"",namevalues:($patSelNVP),getnamevaluesfn:null}});
};

/***************************************************************************
 * fnEditMemberGroupFormPopulate
/**
 ***************************************************************************/   

function fnEditMemberGroupFormPopulate (wgt,$frm,mbrObj) {
      
  $('#' + wgt.options.edit_mbr_form_address_orig + '_selection').val(mbrObj.recData1);
  $('#' + wgt.options.edit_mbr_form_address_orig_address).html(mbrObj.recData2);  
  $('#' + wgt.options.edit_mbr_form_address_orig_place_id).val(mbrObj.recData3);  
  $('#' + wgt.options.edit_mbr_form_address_dest + '_selection').val(mbrObj.recData4);
  $('#' + wgt.options.edit_mbr_form_address_dest_address).html(mbrObj.recData5)
  $('#' + wgt.options.edit_mbr_form_address_dest_place_id).val(mbrObj.recData6)    
  $('#' + wgt.options.edit_mbr_form_distance_miles).html(mbrObj.recData7);
   
  if (mbrObj.recData14) {
      $('#' + wgt.options.edit_mbr_form_week_days_json).val(mbrObj.recData14);
  }
  else {
      $('#' + wgt.options.edit_mbr_form_week_days_json).val(defaultWeekDaysJSON);
  }

  // populate the checkboxes
  var weekDaysObj = JSON.parse($('#' + wgt.options.edit_mbr_form_week_days_json).val());
  $('#'+ wgt.options.edit_mbr_form_monday_checkbox).prop('checked', weekDaysObj.mon);
  $('#'+ wgt.options.edit_mbr_form_tuesday_checkbox).prop('checked', weekDaysObj.tue);
  $('#'+ wgt.options.edit_mbr_form_wednesday_checkbox).prop('checked', weekDaysObj.wed);
  $('#'+ wgt.options.edit_mbr_form_thursday_checkbox).prop('checked', weekDaysObj.thur);
  $('#'+ wgt.options.edit_mbr_form_friday_checkbox).prop('checked', weekDaysObj.fri); 

  // populate the AM/PM controls
  if (mbrObj.recData15) {
      $('#' + wgt.options.edit_mbr_form_am_pm_radiobox_val).val(mbrObj.recData15);

      var optNum = (mbrObj.recData15 == 'AM') ? 0 : 1;
      var amPmLabelID = wgt.options.edit_mbr_form_am_pm_radiobox + '_radiobox_opt_' + optNum;
      
      $('label[for="' + amPmLabelID + '"]').addClass('ui-state-active');
  }
  else {
    // remove the active class so clear out the AM/PM selection
    var amLblID = wgt.options.edit_mbr_form_am_pm_radiobox + '_radiobox_opt_0';
    var pmLblID = wgt.options.edit_mbr_form_am_pm_radiobox + '_radiobox_opt_1';
    $('label[for="' + amLblID + '"]').removeClass('ui-state-active');
    $('label[for="' + pmLblID + '"]').removeClass('ui-state-active');
  }
};

/***************************************************************************
 * fnEditMemberGroupDiaContent
/**
 ***************************************************************************/   

function fnEditMemberGroupDiaContent (wgt, dia, frm) {
       
  $(frm).append('<input name="saveType"  value="2" type="hidden" />');
  $(frm).append('<input name="recID"     value="' + wgt.options.id +'"  type="hidden" />');
  
  /* Create unique ids */
  
  var me_id  = $(wgt.element).attr('id');
  var frm_id = $(frm).attr('id');
    
  wgt.options.edit_mbr_form_address_orig           = me_id + '-' + frm_id + '-edit-address-orig';
  wgt.options.edit_mbr_form_address_orig_address   = me_id + '-' + frm_id + '-edit-address-orig-address';
  wgt.options.edit_mbr_form_address_orig_place_id  = me_id + '-' + frm_id + '-edit-address-orig-place-id';  
  
  wgt.options.edit_mbr_form_address_dest           = me_id + '-' + frm_id + '-edit-address-dest';
  wgt.options.edit_mbr_form_address_dest_address   = me_id + '-' + frm_id + '-edit-address-dest-address';
  wgt.options.edit_mbr_form_address_dest_place_id  = me_id + '-' + frm_id + '-edit-address-dest-place-id';  
  wgt.options.edit_mbr_form_distance_miles         = me_id + '-' + frm_id + '-edit-address-distance-miles';

  wgt.options.edit_mbr_form_am_pm_radiobox         = me_id + '-' + frm_id + '-edit-am-pm-radiobox';
  wgt.options.edit_mbr_form_am_pm_radiobox_val     = me_id + '-' + frm_id + '-edit-am-pm-radiobox-val';
  
  wgt.options.edit_mbr_form_week_days_json         = me_id + '-' + frm_id + '-edit-week-days-json';
  wgt.options.edit_mbr_form_days_checkboxes        = me_id + '-' + frm_id + '-edit-days-checkboxes';
  wgt.options.edit_mbr_form_monday_checkbox        = me_id + '-' + frm_id + '-edit-monday-checkbox';
  wgt.options.edit_mbr_form_tuesday_checkbox       = me_id + '-' + frm_id + '-edit-tuesday-checkbox';
  wgt.options.edit_mbr_form_wednesday_checkbox     = me_id + '-' + frm_id + '-edit-wednesday-checkbox';
  wgt.options.edit_mbr_form_thursday_checkbox      = me_id + '-' + frm_id + '-edit-thursday-checkbox';
  wgt.options.edit_mbr_form_friday_checkbox        = me_id + '-' + frm_id + '-edit-friday-checkbox';

  // button for adding a new site (will open screen in modal)
  wgt.options.go_to_add_new_site                   = me_id + '-' + frm_id + '-go-to-add-new-site';

  var $patSel           = $('<input name="entityID"    id="'  + wgt.options.edit_mbr_form_entity_id             + '" value="" type="hidden"/>');
  var $origPlaceIdInp   = $('<input name="origPlaceID" id="'  + wgt.options.edit_mbr_form_address_orig_place_id + '" type="hidden"/>');
  var $destPlaceIdInp   = $('<input name="destPlaceID" id="'  + wgt.options.edit_mbr_form_address_dest_place_id + '" type="hidden"/>');  
  var $AmPmHiddentText  = $('<textarea ID="' + wgt.options.edit_mbr_form_am_pm_radiobox_val + '" name="selectAmPm" style="display: none;"></textarea>');
  var $AmPmRadioBox     = $('<input id="' + wgt.options.edit_mbr_form_am_pm_radiobox + '" class="ui-spedmon-box-radio-am-pm-container">');
  var $patName          = $('<input class="mba-entity-group-member-field-read-only" name="lbl" id="' + wgt.options.edit_mbr_form_lbl +'" value="" type="text" readonly/>');
  var $origSel          = $('<input name="orig"           id="'  +  wgt.options.edit_mbr_form_address_orig          + '" title="Select Pickup Place" class="mba-web-ui-field-simple" type="text"/>');
  var $origAddressInp   = $('<span id="'+  wgt.options.edit_mbr_form_address_orig_address  + '" class="mba-entity-group-member-extra-data"></span>');
  var $destSel          = $('<input name="dest"           id="'  +  wgt.options.edit_mbr_form_address_dest          + '" title="Select Drop Off Place" class="mba-web-ui-field-simple" type="text"/>');
  var $destAddressInp   = $('<span id="'  +  wgt.options.edit_mbr_form_address_dest_address  + '" class="mba-entity-group-member-extra-data"></span>');  
  var $distMilesInp     = $('<span id="' + wgt.options.edit_mbr_form_distance_miles  + '" class="mba-entity-group-member-extra-data"></span>');

  var $hiddenText       = $('<textarea ID="' + wgt.options.edit_mbr_form_week_days_json + '" name="weekDaysJSON" style="display: none;"></textarea>');
  var $daysCont         = $('<div></div>');
  var $dayslbls         = $('<div class="d-flex justify-content-around"></div>');
  var $dayslblItems     = $('<p class="m-0">Mon</p><p class="m-0">Tue</p><p class="m-0">Wed</p><p class="m-0">Thur</p><p class="m-0">Fri</p>');
  var $daysInp          = $('<div ' + hiddenTextIDForWeekDaysJSON + '="' + wgt.options.edit_mbr_form_week_days_json + '" id="' + wgt.options.edit_mbr_form_days_checkboxes + '" class="d-flex justify-content-around"></div>');
  var $monday           = $('<input id="' + wgt.options.edit_mbr_form_monday_checkbox + '" name="monday" class="checkbox-item" type="checkbox">');
  var $tuesday          = $('<input id="' + wgt.options.edit_mbr_form_tuesday_checkbox + '" name="tuesday" class="checkbox-item" type="checkbox">');
  var $wednesday        = $('<input id="' + wgt.options.edit_mbr_form_wednesday_checkbox + '" name="wednesday" class="checkbox-item" type="checkbox">');
  var $thursday         = $('<input id="' + wgt.options.edit_mbr_form_thursday_checkbox + '" name="thursday" class="checkbox-item" type="checkbox">');
  var $friday           = $('<input id="' + wgt.options.edit_mbr_form_friday_checkbox + '" name="friday" class="checkbox-item" type="checkbox">');

  // add new sites button and callback
  var $addNewSiteBtn    = $('<button id="' + wgt.options.go_to_add_new_site + '" class="btn btn-link mba-fixed-bottom left fa-stack mba-add-site-btn" title="Add New Site">'
                        + '<i class="fas fa-building fa-2x fa-stack-1x"></i>'
                        + '<i class="fa fa-plus fa-2x fa-stack-1x fa-sm"></i>'
                        + '</button>');
  $addNewSiteBtn.on("click", function () {
      let url = 'user_all_sites_save.aspx?tkn=' + $.spedmonWebUI.token
              + "&savetype=" + $.spedmonWebUI.RECORD_SAVE_TYPE_NEW
              + "&amd=uidbssub";
      $.spedmonWebUI.openURL(url, 1);
  });

  $($dayslbls).append($dayslblItems);

  $($daysInp).append($monday);
  $($daysInp).append($tuesday);
  $($daysInp).append($wednesday);
  $($daysInp).append($thursday);
  $($daysInp).append($friday);

  $($daysCont).append($dayslbls);
  $($daysCont).append($daysInp);

  $(frm).append($patSel);  
  $(frm).append($origPlaceIdInp);  
  $(frm).append($destPlaceIdInp);
  $(frm).append($hiddenText);
  $(frm).append($AmPmHiddentText);
  
  var $f1 = $('<span></span>');
  var $l1 = wgt._generateFormGridColLabel('Patient');  
  var $r1 = wgt._generateFormGridRow ($l1, $patName, $f1);

  var $l2 = wgt._generateFormGridColLabel('Quick Routes');
  var $r2 = wgt._generateFormGridRow($l2, $AmPmRadioBox);
								 
  var $l3 = wgt._generateFormGridColLabel('Pick Up Place');
  var $r3 = wgt._generateFormGridRow(  $l3, $origSel, $origAddressInp);
								 
  var $l4 = wgt._generateFormGridColLabel('Drop Off Place');
  var $r4 = wgt._generateFormGridRow ( $l4, $destSel, $destAddressInp );
  
  var $l5 = wgt._generateFormGridColLabel('Distance (Miles)');
  var $f2 = $('<span></span>');
  var $r5 = wgt._generateFormGridRow ($l5, $distMilesInp, $f2);

  var $l6 = wgt._generateFormGridColLabel('Select the Scheduled Days');
  var $r6 = wgt._generateFormGridRow ( $l6, $daysCont );

  var $fg = wgt._generateFormGridContainer ($r1, $r2, $r3, $r4, $r5, $r6);
  
  $(frm).append($fg);
    
  /* Compute distance */
  
  var fnComputeDistance = function() {
    		
	$($distMilesInp).html('');
	
	var fnReturnData  = function (returnData) {
	  $($distMilesInp).html(returnData.distanceInMiles);
	};
	
	
	var cid  = wgt.options.organizationID;
	var pid  = $($patSel).val();
	var opid = $($origPlaceIdInp).val();
	var dpid = $($destPlaceIdInp).val();
	
	fnTripCalcLoadRefreshOrNew (wgt.options.tkn, cid, pid, opid, dpid, fnReturnData);
    	
  };

  /* Enhance */
  
  var fnGetMbrObj = function () {
    var idx    = $('#' + wgt.options.edit_mbr_form_entity_id).val();
    return wgt._findMemberInInternalCollection(idx);    
  };
  
  var fnHomeToSchool = function () {
	var mbrObj = fnGetMbrObj();
	
	$('#' + wgt.options.edit_mbr_form_address_orig + '_selection').val(mbrObj.recData12);
	$('#' + wgt.options.edit_mbr_form_address_dest + '_selection').val(mbrObj.recData9);
	
	$($origPlaceIdInp).val(mbrObj.recData11);	
	$($destPlaceIdInp).val(mbrObj.recData8);

	$($origAddressInp).html(mbrObj.recData13);	
	$($destAddressInp).html(mbrObj.recData10);
	fnComputeDistance();
  };
  
  var fnSchoolToHome = function() {
    var mbrObj = fnGetMbrObj();

	$('#' + wgt.options.edit_mbr_form_address_orig + '_selection').val(mbrObj.recData9);
	$('#' + wgt.options.edit_mbr_form_address_dest + '_selection').val(mbrObj.recData12);

	$($origPlaceIdInp).val(mbrObj.recData8);
	$($destPlaceIdInp).val(mbrObj.recData11);
	
	$($origAddressInp).html(mbrObj.recData10);	
	$($destAddressInp).html(mbrObj.recData13);
	fnComputeDistance();
  };

  var fnUpdateAmPmVal = function(e) {
      var inputID = $(e.currentTarget).attr('for');
      var inputVal = $('#' + inputID).val();
      $('#' + wgt.options.edit_mbr_form_am_pm_radiobox_val).val(inputVal);
  }

  $($AmPmRadioBox).spedmonRadioBox({
    valueSelections: [
        {
            label: 'AM', value: 'AM'
        }, {
            label: 'PM', value: 'PM'
        }]
    , renderLabel: false
  });

  // add tooltips and callbacks to AM/PM controls
  var $AMlbl = $($AmPmRadioBox).next().find('.ui-corner-left');
  var $PMlbl = $($AmPmRadioBox).next().find('.ui-corner-right');
  $($AMlbl).attr('title', 'Route: Home to School');
  $($PMlbl).attr('title', 'Route: School to Home');
  $($AMlbl).click(function(e){fnHomeToSchool(); fnUpdateAmPmVal(e);});
  $($PMlbl).click(function(e){fnSchoolToHome(); fnUpdateAmPmVal(e);});
  
  var $placeSelUrl      = $.spedmonWebUI.createPrivateURL(wgt.options.tkn,"transport_mgmt_places.asmx/viewSel");  
  var fnGetPatID        = function() { return $($patSel).val(); };    
  var fnGetPlacesSelNVP = function() {
  
    var nvpData = [   { name:"clientid",   value:(wgt.options.organizationID)  }
                    , { name:"patid",      value:(fnGetPatID())                } 
					, { name:"placeid",    value:""                            }
				  ];
    
	return nvpData;
  };
  
  $($origSel).spedmonSelectBox({dataParmType:"DOM", selectAll:true, selectType:($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),onSelect:function(event,ui){ $($origAddressInp).html(ui.item.recData1);$($origPlaceIdInp).val(ui.item.recData2); fnComputeDistance();},ajaxopts:{url:($placeSelUrl),data:"",namevalues:null,getnamevaluesfn:(fnGetPlacesSelNVP)}});
  $($destSel).spedmonSelectBox({dataParmType:"DOM", selectAll:true, selectType:($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),onSelect:function(event,ui){ $($destAddressInp).html(ui.item.recData1);$($destPlaceIdInp).val(ui.item.recData2); fnComputeDistance();},ajaxopts:{url:($placeSelUrl),data:"",namevalues:null,getnamevaluesfn:(fnGetPlacesSelNVP)}});

  // event listener for the days of the week checkboxes
    $('input.checkbox-item').change(function (e) {

        var checkboxesParent = $(e.currentTarget).parent();

        var daysoftheweekJSON = JSON.stringify(
            {
                "mon":    checkboxesParent.children('input[name="monday"]').prop('checked')
                , "tue":  checkboxesParent.children('input[name="tuesday"]').prop('checked')
                , "wed":  checkboxesParent.children('input[name="wednesday"]').prop('checked')
                , "thur": checkboxesParent.children('input[name="thursday"]').prop('checked')
                , "fri":  checkboxesParent.children('input[name="friday"]').prop('checked')
            }
        );

        hiddenTextID = checkboxesParent.attr(hiddenTextIDForWeekDaysJSON);
        $('#' + hiddenTextID).val(daysoftheweekJSON);       
    });

    // append add new site button
    $(dia).append($addNewSiteBtn);

};

/***************************************************************************
 * fnRemoveMemberDiaContent
/**
 ***************************************************************************/   

function fnRemoveMemberDiaContent (wgt,dia,frm) {
     
     $(frm).append('<input name="organizationID" value="' + wgt.options.organizationID +'"  type="hidden" />');
     $(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID        +'"  type="hidden" />');
     $(frm).append('<input name="groupID"        value="' + wgt.options.id             +'"  type="hidden" />');
     $(frm).append('<input id="' + wgt.options.rem_mbr_form_entity_id +'" name="entityID"   value="" type="hidden" />');       
	 $(frm).append('<br/>');
     $(frm).append('Do you really want to remove <span id="' + wgt.options.rem_mbr_form_lbl + '" class="' + wgt.options.diaGroupOrMemberInlineLabelClass +'"></span>?');
	 $(frm).append('<br/>');	 
}

/*#####################################################################################################################
  #
  # Setup
  #
  #####################################################################################################################*/ 

/***************************************************************************
 * setupTransMgmtWidgets
/**
 ***************************************************************************/   

function setupTransMgmtWidgets ($tkn, $startDateDflt, $orgID, $ownerID, $authPatients, $authRoutes, $authPatientsCol, $authRoutesCol) {

  /*============================================================
   * Authorized patients options and delegates
   *============================================================*/   

  var $getMembersAuthPatientsActionURL      = "transport_mgmt_auth_patients.asmx/viewSel";
  var $addMemberAuthPatientsActionURL       = "transport_mgmt_auth_patients.asmx/save";
  var $editMemberAuthPatientsActionURL      = "transport_mgmt_auth_patients.asmx/save";
  var $removeMemberAuthPatientsActionURL    = "transport_mgmt_auth_patients.asmx/delete";
  
  var $fnGetMembersAuthPatientsRequestData  = getMembersAuthPatientsRequestData;
  var $fnAddMemberAuthPatientsDiaContent    = addMemberAuthPatientsDiaContent;
  var $fnEditMemberAuthPatientsFormPopulate = fnEditMemberAuthPatientsFormPopulate;
  var $fnEditMemberAuthPatientsDiaContent   = editMemberAuthPatientsDiaContent;
      
  /*============================================================
   * Create authorized patient widget
   *============================================================*/   

  $($authPatients).entitygroup ({   id: $ownerID
                                  , organizationID: $orgID
                                  , ownerID: $ownerID
                                  , name: "Authorized Patients (Special Education Only)"
                                  , tkn: $tkn	
								  , entityGroupsReference2:($authRoutes)
                                  , allowShowHideContent: false
                                  , allowRemoveGroup: false
                                  , allowAddMemberDrop: false
                                  , afterAddMemberEditMember:true
                                  , allowPrintGroup:false
								  , searchTermInpPlaceholder:"Type Text to Filter Patient List"
                                  , addMemberButLabel:"Add Patient"
                                  , addMemberDiaTitle:"Add Patient to Authorized List"
			                      , addMemberDiaWidth: 775
                                  , addMemberDiaHeight: 200
                                  , addMemberDiaResizable: true               								 
                                  , editMemberButLabel:"Edit Patient"
                                  , editMemberDiaTitle:"Edit Authorized Patient Data"
                                  , editMemberDiaWidth: 925
                                  , editMemberDiaHeight: 500
                                  , editMemberDiaResizable: true               								 
								  , fnOnSuccessEditMember:function(wgt,rd) {/* Overide dflt */ return true;}
								  , removeMemberButLabel:"Remove Patient"
                                  , removeMemberDiaTitle:"Remove Patient from Authorized List"                               
                                  , getMembersActionURL: $getMembersAuthPatientsActionURL 
                                  , addNewMemberActionURL: $addMemberAuthPatientsActionURL
                                  , editMemberActionURL: $editMemberAuthPatientsActionURL
                                  , removeMemberActionURL: $removeMemberAuthPatientsActionURL
                                  , removeGroupActionURL: ''
                                  , fnGetMembersRequestData: $fnGetMembersAuthPatientsRequestData
                                  , fnAddMemberDiaContent: $fnAddMemberAuthPatientsDiaContent
                                  , fnEditMemberFormPopulate:$fnEditMemberAuthPatientsFormPopulate
                                  , fnEditMemberDiaContent: $fnEditMemberAuthPatientsDiaContent 
								  , logToConsole:false
                                });
 
 /*============================================================
  * Authorized Routes
  *============================================================*/   

  var $getGroupsActionURL                     = "transport_mgmt_auth_routes.asmx/viewSel";
  var $addNewGroupActionURL                   = "transport_mgmt_auth_routes.asmx/save";
  var $changeGroupActionURL                   = "transport_mgmt_auth_routes.asmx/save";
  var $duplicateGroupActionURL                = "transport_mgmt_auth_routes.asmx/duplicate";
  var $duplicateAndReverseStopsGroupActionURL = "transport_mgmt_auth_routes.asmx/duplicateandreversestops";
  var $removeGroupActionURL                   = "transport_mgmt_auth_routes.asmx/delete";
  var $fnGetGroupsRequestData                 = getAuthRoutesRequestData;
  var $fnAddNewGroupDiaContent                = addNewAuthRouteDiaContent;
  
  /*============================================================
   * Route Members
   *============================================================*/   

  var $getMembersGroupActionURL     = "transport_mgmt_auth_route_members.asmx/viewSel";
  var $addMemberGroupActionURL      = "transport_mgmt_auth_route_members.asmx/save";
  var $editMemberGroupActionURL     = "transport_mgmt_auth_route_members.asmx/save";
  var $removeMemberGroupActionURL   = "transport_mgmt_auth_route_members.asmx/delete";
  var $sortGroupActionURL           = "transport_mgmt_auth_route_members.asmx/saveMembersDisplayOrder";
  var $printGroupActionURL          = "transport_mgmt_route_sheets_file.ashx";
  var $printGroupsActionURL         = "transport_mgmt_route_sheets_file.ashx";
  
  var $fnGetMembersGroupRequestData  = getMembersGroupRequestData;
  var $fnAddMemberGroupDiaContent    = addMemberGroupDiaContent;
  var $fnEditMemberGroupFormPopulate = fnEditMemberGroupFormPopulate;
  var $fnEditMemberGroupDiaContent   = fnEditMemberGroupDiaContent;
  var $fnAddMemberViaDropExtraFields = fnAddMemberGroupViaDropExtraFields;
  
  /* Note: This delegate uses vars declared above */  
  
  var $fnRenderGroupsGroupWidget = function (wgt,grpObj,grpMkup) {
    
    $(grpMkup).entitygroup( {  id: (grpObj.groupID)
                             , organizationID: $orgID
                             , ownerID: $ownerID
                             , name: (grpObj.lbl)
                             , context1:(grpObj.context1)
							 , recData1:(grpObj.recData1)
							 , recData2:(grpObj.recData2)
							 , recData3:(grpObj.recData3)
							 , recData4:(grpObj.recData4)
							 , recData5:(grpObj.recData5)
							 , recData6:(grpObj.recData6)
							 , recData7:(grpObj.recData7)
							 , recData8:(grpObj.recData8)
							 , recData9:(grpObj.recData9)
							 , recData10:(grpObj.recData10)
							 , recData11:(grpObj.recData11)
						     , recData12:(grpObj.recData12)
							 , recData13:(grpObj.recData13)
							 , recData14:(grpObj.recData14)
							 , recData15:(grpObj.recData15)
							 , recData16:(grpObj.recData16)
							 , entityGroupsReference1:($authRoutes)
							 , tkn: $tkn
				             , startDateDflt:($startDateDflt)
                             , allowChangeGroupName: true
                             , changeGroupNameButLabel:"Change Route Name and Bus Number"
                             , changeGroupNameDiaTitle:"Change Route Name and Bus Number"
							 , changeGroupNameDiaWidth: 850
                             , changeGroupNameDiaHeight: 500
                             , changeGroupNameDiaResizable: true
                             , allowShowHideContent: true
							 , showHideOnTitleClick:false
                             , allowRemoveGroup: true
                             , allowAddMemberDrop: true
                             , fnAddMemberViaDropExtraFields: $fnAddMemberViaDropExtraFields
                             , allowMemberEdit:true
                             , afterAddMemberEditMember:true
                             , allowFilterGroup:false
							 , allowPrintGroup:true
							 , allowSortGroup:true
							 , sortGroupButLabel:"Change Order of Route Members"
                             , sortGroupButTitle:"Change Order of Route Members"
                             , sortGroupDiaTitle:"Change Order of Route Members"
                             , sortGroupDiaWidth:600
                             , sortGroupDiaHeight:500
                             , allowDuplicateGroup:true
							 , duplicateGroupButLabel:"Duplicate this Route"
                             , duplicateGroupButTitle:"Duplicate this Route"
                             , duplicateGroupDiaTitle:"Duplicate this Route"
                             , duplicateGroupDiaWidth:600
                             , duplicateGroupDiaHeight:250
                             , duplicateGroupDiaResizable: true
                             , fnDuplicateGroupDiaOpen: (fnDuplicateGroupDiaOpen)
                             , allowDuplicateAndReverseStopsGroup:true
							 , duplicateAndReverseStopsGroupButLabel:"Duplicate this Route with Reverse Stops"
                             , duplicateAndReverseStopsGroupButTitle:"Duplicate this Route with Reverse Stops"
                             , duplicateAndReverseStopsGroupDiaTitle:"Duplicate this Route with Reverse Stops"
                             , duplicateAndReverseStopsGroupDiaWidth:600
                             , duplicateAndReverseStopsGroupDiaHeight:250
                             , duplicateAndReverseStopsGroupDiaResizable: true
                             , fnDuplicateAndReverseStopsGroupDiaOpen: (fnDuplicateAndReverseStopsGroupDiaOpen)
							 , showHideContentButLabel:"Show or Hide Patients"
                             , showHideContentButTitle:"Show or Hide This Routes Patients"
                             , addMemberButLabel:"Add Patient"
                             , addMemberDiaTitle:"Add Patient to this Route"
							 , addMemberDiaWidth: 775
                             , addMemberDiaHeight: 200
                             , addMemberDiaResizable: true
                             , editMemberButLabel:"Edit Patient"
                             , editMemberDiaTitle:"Edit Patient Route Data"  
							 , editMemberDiaWidth:925
                             , editMemberDiaHeight:500
                             , editMemberDiaResizable: true
                             , removeMemberButLabel:"Remove Patient"
                             , removeMemberDiaTitle:"Remove Patient from this Route" 
							 , fnRemoveMemberDiaContent:(fnRemoveMemberDiaContent)
							 , printGroupButLabel:"Print This Route"
                             , printGroupButTitle:"Print this Route Sheet"
                             , printGroupDiaTitle:"Print this Route Sheet"
							 , printGroupDiaWidth:600
                             , printGroupDiaHeight:215
                             , printGroupDiaResizable:true  
							 , fnPrintGroupFormPopulate:(fnPrintGroupFormPopulate)
                             , fnPrintGroupDiaContent: (fnPrintGroupDiaContent)                             
                             , getMembersActionURL: $getMembersGroupActionURL
                             , addNewMemberActionURL: $addMemberGroupActionURL
                             , editMemberActionURL: $editMemberGroupActionURL                          
                             , removeMemberActionURL: $removeMemberGroupActionURL
							 , changeGroupNameActionURL: $changeGroupActionURL							 
                             , duplicateGroupActionURL: $duplicateGroupActionURL							 
                             , duplicateAndReverseStopsGroupActionURL: $duplicateAndReverseStopsGroupActionURL							 
                             , removeGroupActionURL:  $removeGroupActionURL
							 , printGroupActionURL:   $printGroupActionURL
							 , sortGroupActionURL: $sortGroupActionURL
                             , fnGetMembersRequestData: $fnGetMembersGroupRequestData
                             , fnAddMemberDiaContent: $fnAddMemberGroupDiaContent                             
                             , removeGroupButLabel:"Remove Route"
                             , removeGroupDiaTitle:"Remove This Route"
                             , fnEditMemberFormPopulate:$fnEditMemberGroupFormPopulate
                             , fnEditMemberDiaContent: $fnEditMemberGroupDiaContent
							 , fnChangeGroupNameFormPopulate: (fnChangeExistingAuthRouteFormPopulate)
							 , fnChangeGroupNameDiaContent: (changeExistingAuthRouteDiaContent)
                             , fnDuplicateGroupFormPopulate: (fnDuplicateAuthRouteFormPopulate)
							 , fnDuplicateGroupDiaContent: (duplicateAuthRouteDiaContent)
                             , fnDuplicateAndReverseStopsGroupFormPopulate: (fnDuplicateAndReverseStopsAuthRouteFormPopulate)
							 , fnDuplicateAndReverseStopsGroupDiaContent: (duplicateAndReverseStopsAuthRouteDiaContent)
							 , logToConsole:false
                             });
  };
    
   /*============================================================
    * Create groups list widget
    * Note: This widget will create the group widgets
    *============================================================*/   
  
  $($authRoutes).entitygroups ({ id: $ownerID
                              , organizationID: $orgID
                              , ownerID: $ownerID
                              , name: "Authorized Routes"
                              , tkn: $tkn
							  , startDateDflt:($startDateDflt)
							  , allowPrintGroups:true
							  , allowShowHideGroupsContent:true
							  , allowFilterGroups:true
							  , searchTermInpTitle:"Filter Routes"
                              , searchTermInpPlaceholder:"Enter Text to Filter Routes By"
							  , showHideGroupsContentButLabel:"Show or Hide All Routes Patients"
                              , showHideGroupsContentButTitle:"Show or Hide All Routes Patients"
                              , addNewGroupButLabel:"Add Route"
                              , addNewGroupDiaTitle:"Add New Route"
							  , addNewGroupDiaWidth:775
							  , addNewGroupDiaHeight:500
							  , addNewGroupDiaResizable: true
							  , printGroupsButLabel:"Print Routes"
							  , printGroupsButTitle:"Print All Route Sheets"
                              , printGroupsDiaTitle:"Print All Route Sheets"
							  , printGroupsDiaWidth:600
                              , printGroupsDiaHeight:215
                              , printGroupsDiaResizable:false
							  , fnPrintGroupsFormPopulate:(fnPrintGroupsFormPopulate)
                              , fnPrintGroupsDiaContent: (fnPrintGroupsDiaContent)								  
                              , printGroupsActionURL: $printGroupsActionURL
                              , getGroupsActionURL:$getGroupsActionURL
                              , addNewGroupActionURL: $addNewGroupActionURL
                              , fnGetGroupsRequestData:$fnGetGroupsRequestData
                              , fnRenderGroupWidget:$fnRenderGroupsGroupWidget
                              , fnAddNewGroupDiaContent:$fnAddNewGroupDiaContent
							  , logToConsole:false
                            });   
};
