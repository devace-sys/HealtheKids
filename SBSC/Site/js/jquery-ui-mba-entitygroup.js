/***************************************************************************
 * jquery-ui-mba-entitygroup.js */
/**
 ***************************************************************************/   
 
;(function($){

/***************************************************************************
 * mba.entityGroup */
/**
 * Entity group widget
 *
 * Requires: jquery.MBA.common.js
*            jquery.MBA.webuicontrols.js
 * 
 * Note: This class requires delegates to be defined in the options
 * in order to work.
 ***************************************************************************/ 

$.widget("mba.entitygroup", $.mba.entitygroupingbase, {

/***************************************************************************
 * options */
/**
 * Default options and instance specific data
 ***************************************************************************/ 

options: {

  /*============================================================
   * Group wide data
   *============================================================*/ 
   name:""
  ,organizationID:null
  ,ownerID:null
  ,context1:""
  ,recData1:""
  ,recData2:""
  ,recData3:""
  ,recData4:""
  ,recData5:""
  ,recData6:""
  ,recData7:""
  ,recData8:""
  ,recData9:""
  ,recData10:""
  ,recData11:""
  ,recData12:""
  ,recData13:""
  ,recData14:""
  ,recData15:""
  ,recData16:""
  ,entitiesAreExternal:true  
  ,entityGroupsReference1:null
  ,entityGroupsReference2:null
  
  /*============================================================
   * Group members
   *============================================================*/ 
  
  ,members:[]

  /*============================================================
   * Search placeholders and titles
   *============================================================*/ 

  ,searchTermInpPlaceholder:"Find Member"
  ,searchTermInpTitle:"Type in all or part of a name to filter list"

  /*============================================================
   * Flags
   *============================================================*/ 

  ,allowChangeGroupName:false
  ,allowRemoveGroup:true
  ,allowRefreshMembers:true
  ,allowAddMember:true
  ,allowShowHideContent:true
  ,allowAddMemberDrop:true
  ,allowMemberEdit:true
  ,allowMemberRemove:true
  ,allowMemberDrag:true
  ,allowFilterGroup:true
  ,afterAddMemberEditMember:false
  ,allowPrintGroup:false
  ,allowSortGroup:false
  ,allowDuplicateGroup:false
  ,allowDuplicateAndReverseStopsGroup:false
  ,allowUploadFileForGroup:false
  ,showHideOnTitleClick:true
  ,contentInitiallyShownOrHidden:"shown"
  
  /*============================================================
   * CSS
   *============================================================*/ 
  
  ,containerClass:"ui-helper-clearfix ui-widget ui-widget-content ui-corner-all mba-entity-group"
  ,headerClass:"ui-helper-clearfix ui-widget-header ui-corner-all mba-entity-group-header"
  ,contentClass:"ui-helper-clearfix mba-entity-group-content"
  ,statusClass:"mba-entity-group-status"
  ,headerTitleClass:"mba-entity-group-header-title"
  ,headerControlsClass:"mba-entity-group-header-controls"
  ,headerControlClass:"mba-entity-group-header-control"
  ,showHideContentClass:"mba-entity-group-show-hide-members-span"
  ,removeGroupClass:"mba-entity-group-remove-span"
  ,contentControlsClass:"mba-entity-group-content-controls"
  ,contentControlClass:"mba-entity-group-content-control"
  ,contentClass:"mba-entity-group-content"
  ,statsClass:"mba-entity-group-stats"
  ,membersClass:"ui-helper-reset mba-entity-group-members"
  ,memberClass:"ui-helper-clearfix ui-state-default mba-entity-group-member"
  ,memberLineClass:"ui-helper-clearfix mba-entity-group-member-line"
  ,memberLabelClass:"mba-entity-group-member-label"
  ,memberContextClass:"mba-entity-group-member-context"
  ,memberControlsClass:"mba-entity-group-member-controls"
  ,memberControlClass:"mba-entity-group-member-control"
  ,dropAcceptClass:"mba-entity-group-member"
  
  /*============================================================
   * Attributes
   *============================================================*/ 
  
  ,entityIDAttr:"data-entity-id"
  
  /*============================================================
   * Action URLs
   *============================================================*/ 
  
  ,getMembersActionURL:""
  ,addNewMemberActionURL:""
  ,editMemberActionURL:""
  ,removeMemberActionURL:""
  ,changeGroupNameActionURL:""
  ,duplicateGroupActionURL:""
  ,duplicateAndReverseStopsGroupActionURL:""
  ,removeGroupActionURL:""                                    
  ,printGroupActionURL:""
  ,sortGroupActionURL:""
  
  /*============================================================
   * Action parameter generators
   *============================================================*/ 
  
  ,fnActionCommonFields:function (wgt,data) {

    var newData = data 
	              + '"organizationID":"'  + wgt.options.organizationID + '"'
	              + ',"ownerID":"'        + wgt.options.ownerID        + '"'
		          + ',"groupID":"'        + wgt.options.id             + '"';
								 
    return newData;
  }
  
  ,fnAddMemberViaDropExtraFields:function (wgt) {    
	var newData = ''; 								 
    return newData;
  }
  
  ,fnGetMembersRequestData:function(wgt){}
  ,fnEditMemberAction:function(wgt,entityID,memberObj){}
  ,fnRemoveMemberAction:function(wgt,entityID){}
  
  ,fnRemoveGroupAction:function(wgt){}
  
  ,fnDiaFormCommonFields:function (wgt,dia,frm){
  	$(frm).append('<input name="organizationID" value="' + wgt.options.organizationID +'"  type="hidden" />');
	$(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID        +'"  type="hidden" />');
	$(frm).append('<input name="groupID"        value="' + wgt.options.id             +'"  type="hidden" />');
    return true;
  }
  
  /*============================================================
   * Add member
   *============================================================*/ 
  
  ,addMemberButLabel:"Add Member"
  ,addMemberDiaTitle:"Add New Member to List"
  ,addMemberDiaWidth:775
  ,addMemberDiaHeight:400
  ,addMemberDiaResizable: false
  ,fnAddMemberCustomClearFields:function(wgt,$frm){}
  ,fnAddMemberDiaOpen:function(wgt){
    var $frm = $('#' + wgt.options.add_mbr_form_id);
    var $dia = $('#' + wgt.options.add_new_dia_id);
    $.spedmonWebUI.formClear($frm);
    wgt.options.fnAddMemberCustomClearFields(wgt,$frm);	
	$($dia).dialog("open");   
  }
  
  ,fnAddMemberDiaContent:function(wgt,dia,frm){}
  
  ,fnAddMemberDiaAdd:function(wgt,dia,frm){
	var data = $.spedmonWebUI.formParmsToJSON(frm);	
	wgt.addMember(data);
	$(dia).dialog("close");
    return true;
  }  
  
  /*============================================================
   * Edit member
   *============================================================*/ 
  
  ,editMemberButLabel:"Edit Member"
  ,editMemberDiaTitle:"Edit Existing Member on List"
  ,editMemberDiaWidth:775
  ,editMemberDiaHeight:400
  ,editMemberDiaResizable: false
  ,fnEditMemberCustomClearFields:function(wgt,$frm){}
  ,fnEditMemberFormPopulate:function(wgt,$frm,mbrObj){}
  ,fnEditMemberDiaOpen:function(wgt,mbrObj){   
    var $frm = $('#' + wgt.options.edit_mbr_form_id);
    var $dia = $('#' + wgt.options.edit_dia_id);
	var $ent = $('#' + wgt.options.edit_mbr_form_entity_id);
	var $lbl = $('#' + wgt.options.edit_mbr_form_lbl);
	$.spedmonWebUI.formClear($frm);
	wgt.options.fnEditMemberCustomClearFields(wgt,$frm);	
	$($ent).val(mbrObj.entityID);
	$($lbl).val(mbrObj.lbl);
	wgt.options.fnEditMemberFormPopulate(wgt,$frm,mbrObj);
	$($dia).dialog("open");
  }
  ,fnEditMemberDiaContent:function(wgt,dia,frm){}
  ,fnEditMemberDiaSave:function(wgt,dia,frm){
  	var data = $.spedmonWebUI.formParmsToJSON(frm);	
	wgt.editMember(data);
	$(dia).dialog("close");
    return true;
   }  
  
  ,fnOnSuccessEditMember:function(wgt,rd) {  
    
	/* Default to work with master group keeping sub groups inside groups list synched 
	 * If the master group opens edit immediately after add, it is best to override this
	 * as performance will be slow.
	*/
	
	if (wgt.options.entityGroupsReference2)
	{
	  var $grps = wgt.options.entityGroupsReference2;
      $($grps).entitygroups('getGroups','editMember');
    }
    return true;
  }
  
  /*============================================================
   * Remove member
   *============================================================*/ 
  
  ,removeMemberButLabel:"Remove"
  ,removeMemberDiaTitle:"Remove This Member from This List"
  ,removeMemberDiaClass:'ui-state-error'
  ,removeMemberDiaWidth:500
  ,removeMemberDiaHeight:200
  ,removeMemberDiaResizable: false
  
  ,fnRemoveMemberFormPopulate:function(wgt,$frm,mbrObj){
  
  }
  
  ,fnRemoveMemberDiaOpen:function(wgt,mbrObj) {
     
     var $frm = $('#' + wgt.options.rem_mbr_form_id);
     var $dia = $('#' + wgt.options.rem_dia_id);
	 var $ent = $('#' + wgt.options.rem_mbr_form_entity_id);
	 var $lbl = $('#' + wgt.options.rem_mbr_form_lbl);	 
	 
	 $.spedmonWebUI.formClear($frm); 
	 $($ent).val(mbrObj.entityID);
	 $($lbl).html(mbrObj.lbl);
	 wgt.options.fnRemoveMemberFormPopulate(wgt,$frm,mbrObj);
	 $($dia).dialog("open");
  }
  
  ,fnRemoveMemberDiaContent:function(wgt,dia,frm) {
     $(frm).append('<input name="organizationID" value="' + wgt.options.organizationID +'"  type="hidden" />');
     $(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID        +'"  type="hidden" />');
     $(frm).append('<input name="groupID"        value="' + wgt.options.id             +'"  type="hidden" />');
     $(frm).append('<input id="' + wgt.options.rem_mbr_form_entity_id +'" name="entityID"   value="" type="hidden" />');
	  
	 $(dia).append('<br/>');
     $(dia).append('Do you really want to remove <span id="' + wgt.options.rem_mbr_form_lbl + '" class="' + wgt.options.diaGroupOrMemberInlineLabelClass +'"></span>?');
  }
  
  ,fnRemoveMemberDiaRemove:function(wgt,dia,frm){
     var data = $.spedmonWebUI.formParmsToJSON(frm);	 	 
	 wgt.removeMember(data);
	 $(dia).dialog("close");
	 return true;
  }
  
  ,fnOnSuccessRemoveMember:function(wgt,rd) {  
    /* Default to work with master group keeping sub groups inside groups list synched */
	if (wgt.options.entityGroupsReference2)
	{
	  var $grps = wgt.options.entityGroupsReference2;
      $($grps).entitygroups('getGroups','removeMember');
    }
    return true;
  }
    
  /*============================================================
   * Change group name (and other group data)
   *============================================================*/ 
   
  ,changeGroupNameButLabel:"Change Group Name"
  ,changeGroupNameDiaTitle:"Change this Group Name"
  ,changeGroupNameDiaWidth: 500
  ,changeGroupNameDiaHeight: 200
  ,changeGroupNameDiaResizable: false
  
  ,fnChangeGroupNameFormPopulate:function(wgt,$frm){
	$('#' + wgt.options.chg_grp_form_group_name_id).val(wgt.options.name);
  }
  
  ,fnChangeGroupNameDiaOpen:function(wgt) {
    var $frm = $('#' + wgt.options.chg_grp_form_id);
	var $dia = $('#' + wgt.options.chg_grp_dia_id);	
    $.spedmonWebUI.formClear($frm); 
	wgt.options.fnChangeGroupNameFormPopulate(wgt,$frm);
	$($dia).dialog("open");
  }
  
  ,fnChangeGroupNameDiaContent:function(wgt,dia,frm) {

    $(frm).append('<input name="organizationID" value="' + wgt.options.organizationID +'"  type="hidden" />');
	$(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID        +'"  type="hidden" />');
    $(frm).append('<input name="saveType" value="2" type="hidden" />');
    $(frm).append('<input name="recID"          value="' + wgt.options.id             +'"  type="hidden" />');
    
	var $lblGroupName = $('<label for="' + wgt.options.chg_grp_form_group_name_id + '">New Group Name</label>');
	var $txtGroupName = $('<input name="groupName" id="' + wgt.options.chg_grp_form_group_name_id +'" type="text" placeholder="Enter new group name"/>');
    
	/* Create table to layout fields */

    var $frmTable = $('<table></table>');
	
    /* Group name */

    var $frmRow1       = $('<tr></tr>');
    var $formRow1Col1  = $('<td></td>');
    var $formRow1Col2  = $('<td></td>');
    
	$($formRow1Col1).append($lblGroupName);
    $($formRow1Col2).append($txtGroupName);	
	
    $($frmRow1).append($formRow1Col1);
    $($frmRow1).append($formRow1Col2);
    
    $($frmTable).append($frmRow1);

    /* Append to form */

    $(frm).append($frmTable);
    
	/* Enhance */
	
	$($txtGroupName).spedmonTextbox({"showOK":false});
  
  }
  
  ,fnChangeGroupNameDiaSave:function(wgt,dia,frm){
  	var data = $.spedmonWebUI.formParmsToJSON(frm);	
	wgt.changeGroupName(data);
	$(dia).dialog("close");
    return true;       
  }
  
  ,fnOnSuccessChangeGroupName:function(wgt,rd) {  
    /* Default to work with sub group inside groups list */
	if (wgt.options.entityGroupsReference1)
	{
	  var $grps = wgt.options.entityGroupsReference1;
      $($grps).entitygroups('getGroups','changeGroupName');
    }
    return true;
  }
  
  /*============================================================
   * Remove group 
   *============================================================*/ 
  
  ,removeGroupButLabel:"Remove Group"
  ,removeGroupDiaTitle:"Remove This Group"
  ,removeGroupDiaClass:'ui-state-error'
  ,removeGroupDiaWidth: 500
  ,removeGroupDiaHeight: 200
  ,removeGroupDiaResizable: false
  
  ,fnRemoveGroupFormPopulate:function(wgt,$frm){}
  
  ,fnRemoveGroupDiaOpen:function(wgt) {
    var $frm = $('#' + wgt.options.rem_grp_form_id);
	var $dia = $('#' + wgt.options.rem_grp_dia_id);		
    $.spedmonWebUI.formClear($frm); 
	wgt.options.fnRemoveGroupFormPopulate(wgt,$frm);
	$($dia).dialog("open");
  }
  
  ,fnRemoveGroupDiaContent:function(wgt,dia,frm) {     
     $(frm).append('<input name="organizationID" value="' + wgt.options.organizationID +'"  type="hidden" />');
     $(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID        +'"  type="hidden" />');
     $(frm).append('<input name="groupID"        value="' + wgt.options.id             +'"  type="hidden" />');

     $(dia).append('<br/>');
     $(dia).append('Do you really want to remove <span class="mba-entity-dia-inline-label">' + wgt.options.name + ' </span> and all of its members?');
  }
  
  ,fnRemoveGroupDiaRemove:function(wgt,dia,frm){
    
     var data = $.spedmonWebUI.formParmsToJSON(frm);	
	 $(dia).dialog("close");
	 wgt.removeGroup(data);	 
  }

  ,fnOnSuccessRemoveGroup:function(wgt,rd) {  
    /* Default to work with sub group inside groups list */
	if (wgt.options.entityGroupsReference1)
	{
	  var $grps = wgt.options.entityGroupsReference1;
      $($grps).entitygroups('getGroups','removeGroup');
    }
    return true;
  }

  /*============================================================
   * Show or hide members
   *============================================================*/ 

  ,showHideContentButLabel:"Show or Hide Members"
  ,showHideContentButTitle:"Show or Hide This Groups Members"
  
  /*============================================================
   * Sort Group
   *============================================================*/ 

  ,sortGroupButLabel:"Sort Group"
  ,sortGroupButTitle:"Sort Group"
  ,sortGroupDiaTitle:"Sort Group"
  ,sortGroupDiaWidth:300
  ,sortGroupDiaHeight:500
  ,sortGroupDiaResizable:true  
  
  ,fnSortGroupGetMemberOrder:function (wgt) {
	var $sortGrpList      = $('#' + wgt.options.sort_grp_list_id);
	var $sortGrpListItems = $($sortGrpList).children();
	var $inpMemberOrder   = $('#' + wgt.options.sort_grp_member_order_inp);
	var arrEntityIDs      = [];
	$.each($sortGrpListItems, function (idx, $sortGrpListItem) {
	  arrEntityIDs.push($($sortGrpListItem).attr(wgt.options.entityIDAttr));	  
	});
	var strEntityIDs = '';
	strEntityIDs = arrEntityIDs.join();
	$inpMemberOrder.val(strEntityIDs);
  }

  ,fnSortGroupFormPopulate:function(wgt,$frm) { 
	var $sortGrpList = $('#' + wgt.options.sort_grp_list_id);
	$($sortGrpList).html('')
    $.each(wgt.options.members, function (idx, mbrObj) {
      var $li = wgt._createSortListItem(mbrObj);
	  $($sortGrpList).append($li);
    });    
	$($sortGrpList).sortable('refresh');
	wgt.options.fnSortGroupGetMemberOrder(wgt);	
  }
  
  ,fnSortGroupDiaOpen:function(wgt){
    var $dia = $('#' + wgt.options.sort_grp_dia_id);
	var $frm = $('#' + wgt.options.sort_grp_form_id);
    $.spedmonWebUI.formClear($frm); 
	wgt.options.fnSortGroupFormPopulate(wgt,$frm);
	$($dia).dialog("open");
  }
    
  ,fnSortGroupDiaContent:function(wgt,dia,frm) {    
	 $(dia).append('<p>Drag and drop members to sort the list.</p>');
	 $(dia).append('<p>Click on save when you are done.</p>');
	 $(dia).append('<br/>');
	 var $sortGrpList = $('<ul id="' + wgt.options.sort_grp_list_id + '"></ul>');	 
	 $(dia).append($sortGrpList);
	 $(frm).append('<input name="organizationID" value="' + wgt.options.organizationID            +'" type="hidden"/>');
     $(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID                   +'" type="hidden"/>');
     $(frm).append('<input name="groupID"        value="' + wgt.options.id                        +'" type="hidden"/>');
     $(frm).append('<input name="membersDisplayOrder" id="'       + wgt.options.sort_grp_member_order_inp +'" type="hidden"/>');	 
	 
	 $($sortGrpList).sortable({update: function( event, ui ) {
	   wgt.options.fnSortGroupGetMemberOrder(wgt);
	 }});
  }  
  
  ,fnSortGroupDiaSaveOrder: function(wgt,dia,frm) {         
		
	wgt.options.fnSortGroupGetMemberOrder(wgt);	
	
	var data = $.spedmonWebUI.formParmsToJSON(frm);	
	 $(dia).dialog("close");
	 wgt.sortGroup(data);
  }

  /*============================================================
   * Print group
   *============================================================*/ 

  ,printGroupButLabel:"Print Group"
  ,printGroupButTitle:"Print this Group"
  ,printGroupDiaTitle:"Print this Group"
  ,printGroupDiaWidth:300
  ,printGroupDiaHeight:300
  ,printGroupDiaResizable:false
  
  ,fnPrintGroupFormPopulate:function(wgt,$frm){}
  
  ,fnPrintGroupDiaOpen:function(wgt){
    var $dia = $('#' + wgt.options.print_grp_dia_id);
	var $frm = $('#' + wgt.options.print_grp_form_id);	
    $.spedmonWebUI.formClear($frm); 
	wgt.options.fnPrintGroupFormPopulate(wgt,$frm);	
	$($dia).dialog("open");
  }
  
  ,fnPrintGroupDiaContent:function(wgt,dia,frm){
     
	 $(frm).append('<input name="organizationID" value="' + wgt.options.organizationID +'"  type="hidden" />');
     $(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID        +'"  type="hidden" />');
     $(frm).append('<input name="groupID"        value="' + wgt.options.id             +'"  type="hidden" />');     	 	
     $(dia).append('Print <span style="font-weight:bold">' + wgt.options.name + ' </span>?');
  }  
  
  ,fnPrintGroupDiaPrint:function(wgt,dia,frm){     
     var data = $.spedmonWebUI.formParmsToNVPS(frm);	 
	 $(dia).dialog("close");
	 wgt.printGroup(data);
  }

  /*============================================================
   * Duplicate Group
   *============================================================*/ 
  
  , duplicateGroupButLabel:"Duplicate this Route"
  , duplicateGroupButTitle:"Duplicate this Route"
  , duplicateGroupDiaTitle:"Duplicate this Route"
  , duplicateGroupDiaWidth:600
  , duplicateGroupDiaHeight:250
  , duplicateGroupDiaResizable: true
  ,fnDuplicateGroupFormPopulate:function(wgt,$frm,mbrObj){}
  ,fnDuplicateGroupDiaOpen:function(wgt,mbrObj){}
  ,fnDuplicateGroupDiaContent:function(wgt,dia,frm){}
  ,fnDuplicateGroupDiaSave:function(wgt,dia,frm){
  	var data = $.spedmonWebUI.formParmsToJSON(frm);
	wgt.duplicateGroup(data);
	$(dia).dialog("close");
    return true;
   }  
  
  ,fnOnSuccessDuplicateGroup:function(wgt,rd) {  
    
	/* Default to work with sub group inside groups list */
	
	if (wgt.options.entityGroupsReference1)
	{
	  var $grps = wgt.options.entityGroupsReference1;
      $($grps).entitygroups('getGroups','duplicateGroup');
    }
    return true;
  }

  /*============================================================
   * Duplicate And Reverse Stops Group
   *============================================================*/ 
  
  , duplicateAndReverseStopsGroupButLabel:"Duplicate this Route with Reverse Stops"
  , duplicateAndReverseStopsGroupButTitle:"Duplicate this Route with Reverse Stops"
  , duplicateAndReverseStopsGroupDiaTitle:"Duplicate this Route with Reverse Stops"
  , duplicateAndReverseStopsGroupDiaWidth:600
  , duplicateAndReverseStopsGroupDiaHeight:250
  , duplicateAndReverseStopsGroupDiaResizable: true
  ,fnDuplicateAndReverseStopsGroupFormPopulate:function(wgt,$frm,mbrObj){}
  ,fnDuplicateAndReverseStopsGroupDiaOpen:function(wgt,mbrObj){}
  ,fnDuplicateAndReverseStopsGroupDiaContent:function(wgt,dia,frm){}
  ,fnDuplicateAndReverseStopsGroupDiaSave:function(wgt,dia,frm){
  	var data = $.spedmonWebUI.formParmsToJSON(frm);
	wgt.duplicateAndReverseStopsGroup(data);
	$(dia).dialog("close");
    return true;
   }  
  
  ,fnOnSuccessDuplicateAndReverseStopsGroup:function(wgt,rd) {  
    
	/* Default to work with sub group inside groups list */
	
	if (wgt.options.entityGroupsReference1)
	{
	  var $grps = wgt.options.entityGroupsReference1;
      $($grps).entitygroups('getGroups','duplicateAndReverseStopsGroup');
    }
    return true;
  }

  /*============================================================
   * File Upload
   *============================================================*/ 
   
  , uploadFileForGroupButLabel:"Upload File"
  , uploadFileForGroupButTitle:"Upload File For This Group"
  , uploadFileForGroupFnDoFileUpload:function(wgt) {}  
  	   	    
},

/***************************************************************************
 * _create */
/**
 * Called once on initial creation
 ***************************************************************************/ 
 
_create: function() {	    	
  
  this._logMessageToConsole ('_create','',1);
  
  /*============================================================
   * References to this widget, original element, widget options
   * and original element id.
   *============================================================*/ 

  var $this    = this;
  var $me      = this.element;
  var $options = this.options;
  var me_id    = $(this.element).attr('id');
      
  /*============================================================
   * Create ids for some of the new markup.  Ids are based on the
   * original element id.
   *============================================================*/ 
  
  this.options.container_id               = me_id + '-container';
  this.options.header_id                  = me_id + '-header';
  this.options.header_title_id            = me_id + '-header-title';
  this.options.header_controls_id         = me_id + '-header-controls';
  this.options.search_term_id             = me_id + '-search-term';
  this.options.content_id                 = me_id + '-content';
  this.options.content_controls_id        = me_id + '-content-controls';
  
  this.options.show_hide_members_but_id   = me_id + '-but-show-hide-members';    
    
  this.options.upload_file_for_grp_but_opn_id = me_id + '-dia-upload-file-for-group-but';

  this.options.dup_grp_but_opn_id         = me_id + '-dia-dup-grp-opn-but';
  this.options.dup_grp_dia_id             = me_id + '-dia-dup-grp';
  this.options.dup_grp_form_id            = me_id + '-dia-dup-grp-form';

  this.options.dup_and_reverse_stops_grp_but_opn_id = me_id + '-dia-dup-and-reverse-stops-grp-opn-but';
  this.options.dup_and_reverse_stops_grp_dia_id     = me_id + '-dia-dup-and-reverse-stops-grp';
  this.options.dup_and_reverse_stops_grp_form_id    = me_id + '-dia-dup-and-reverse-stops-grp-form';
  
  this.options.print_grp_but_opn_id       = me_id + '-dia-print-grp-opn-but';
  this.options.print_grp_dia_id           = me_id + '-dia-print-grp';
  this.options.print_grp_form_id          = me_id + '-dia-print-grp-form';  
  
  this.options.sort_grp_but_opn_id        = me_id + '-dia-sort-grp-opn-but';
  this.options.sort_grp_dia_id            = me_id + '-dia-sort-grp';
  this.options.sort_grp_form_id           = me_id + '-dia-sort-grp-form';
  this.options.sort_grp_list_id           = me_id + '-dia-sort-grp-list';
  this.options.sort_grp_member_order_inp  = me_id + '-dia-sort-grp-member-order-inp';  
  this.options.refresh_grp_members_but_id = me_id + '-but-refresh-grp-members';
  
  this.options.chg_grp_but_opn_id         = me_id + '-dia-chg-grp-opn-but';
  this.options.chg_grp_dia_id             = me_id + '-dia-chg-grp';
  this.options.chg_grp_form_id            = me_id + '-dia-chg-grp-form';
  this.options.chg_grp_form_group_name_id = me_id + '-dia-chg-grp-form-group-name';  
  this.options.rem_grp_but_opn_id         = me_id + '-dia-rem-grp-opn-but';
  this.options.rem_grp_dia_id             = me_id + '-dia-rem-grp';  
  this.options.rem_grp_form_id            = me_id + '-dia-rem-grp-form';    
  
  this.options.add_new_but_opn_id         = me_id + '-dia-add-new-opn-but';
  this.options.add_new_dia_id             = me_id + '-dia-add-new';
  this.options.add_mbr_form_id            = me_id + '-add-new-form';
  this.options.add_mbr_form_entity_id     = me_id + '-add-new-form-member-entity-id';  
  this.options.edit_dia_id                = me_id + '-dia-edit';  
  this.options.edit_mbr_form_id           = me_id + '-edit-form';
  this.options.edit_mbr_form_entity_id    = me_id + '-edit-form-member-entity-id';
  this.options.edit_mbr_form_lbl          = me_id + '-edit-form-member-lbl';
  this.options.rem_dia_id                 = me_id + '-dia-rem';  
  this.options.rem_mbr_form_id            = me_id + '-rem-form';
  this.options.rem_mbr_form_entity_id     = me_id + '-rem-form-member-entity-id';
  this.options.rem_mbr_form_lbl           = me_id + '-rem-form-member-lbl';
                 
  this._tearDown();

  /*============================================================
   * References to existing and new markup
   *============================================================*/ 
  
  var $me_status           = this._setupStatus();
  var $me_container        = null;
  var $me_header           = null;
  var $me_header_title     = null;
  var $me_search_term      = null;
  var $me_content          = null;  
  var $me_content_controls = null;
  var $but_rem_grp         = null;
  var $but_edit_group_name = null;
  var $but_refresh_members = null;
  var $but_add             = null;
  var $but_show_hide       = null;
  var $but_print           = null;
  var $but_upload          = null;
  var $but_sort            = null;
  var $inp_filter_txt      = null;
  var $dia_print_grp       = null;
  var $dia_print_grp_form  = null;  
  var $dia_sort_grp        = null;
  var $dia_sort_grp_form   = null;
  var $dia_add_new         = null;
  var $dia_add_new_form    = null;   
  var $dia_edit            = null;
  var $dia_edit_form       = null;
  var $dia_rem             = null;
  var $dia_rem_form        = null;  
  var $dia_chg_grp         = null;
  var $dia_chg_grp_form    = null;  
  var $dia_rem_grp         = null;
  var $dia_rem_grp_form    = null;
  var $dia_dup_grp         = null;
  var $dia_dup_grp_form    = null;
  var $dia_dup_and_reverse_stops_grp      = null;
  var $dia_dup_and_reverse_stops_grp_form = null;
  
  /*============================================================
   * Add css clases
   *============================================================*/ 

  $($me).addClass(this.options.membersClass);
    
  /*============================================================
   * Wrap original element in a containing div.  
   * This wrap is the widget content container.
   *============================================================*/ 

  $($me).wrap('<div id="' + this.options.content_id + '"></div>');
  $me_content = $('#' + this.options.content_id);
  $($me_content).addClass(this.options.contentClass);
    
  /*============================================================
   * Wrap widget content container in a containing div.  
   * This wrap is the widget container.
   *============================================================*/ 

  $($me_content).wrap('<div id="' + this.options.container_id + '"></div>');
  $me_container = $('#' + this.options.container_id);
  $($me_container).addClass(this.options.containerClass);

  /*============================================================
   * Create new div and prepend to widget container.
   * This div is the widget header.
   *============================================================*/ 
  
  
  /*#####################################################################################################################
    # Header 
    #####################################################################################################################*/ 

  $me_header = $('<div id="' + this.options.header_id +'"></div>');
  $($me_header).addClass(this.options.headerClass);
  
  /*============================================================
   * Header title
   *============================================================*/ 
  
  $me_header_title = $('<span id="' + this.options.header_title_id + '">' + this.options.name + '</span>');
  $($me_header_title).addClass(this.options.headerTitleClass);
  $($me_header).append($me_header_title);
  
  /*============================================================
   * If show hide content is allowed and the showHideOnTitleClick
   * options is set then wire up show hide if the user clicks the
   * title
   *============================================================*/ 
  
  if ((this.options.allowShowHideContent == true) && (this.options.showHideOnTitleClick == true)) {
    $($me_header_title).click(function(){$($but_show_hide).click();});
  };
  
  /*#####################################################################################################################
    # Header Controls
    #####################################################################################################################*/ 

  /*============================================================
   * Header controls container
   *============================================================*/ 
  
  $me_header_controls = $('<span id="' + this.options.header_controls_id + '"></span>');

  /*============================================================
   * Duplicate Group
   *============================================================*/ 
   
  if (this.options.allowDuplicateGroup == true) {
	
	$but_duplicate_group = $('<i id="' + this.options.dup_grp_but_opn_id  +'" class="fas fa-clone"></i>');
    $($but_duplicate_group).attr("title",this.options.duplicateGroupDiaTitle);
    $($but_duplicate_group).addClass(this.options.headerControlClass);
    $($but_duplicate_group).click(function(){$this.options.fnDuplicateGroupDiaOpen($this);});
    $($me_header_controls).append($but_duplicate_group);

    $dia_dup_grp      = $('<div id="' + this.options.dup_grp_dia_id +'" title="' + this.options.duplicateGroupDiaTitle + '"></div>');
	$dia_dup_grp_form = $('<form id="' + this.options.dup_grp_form_id +'" method="post" action="' + this.options.duplicateGroupActionURL +'"></form>');	

	this._disableFormSubmitOnEnter($dia_dup_grp_form);  	

	$($dia_dup_grp).append($dia_dup_grp_form);
	
    this.options.fnDuplicateGroupDiaContent (this,$dia_dup_grp, $dia_dup_grp_form);
    
	$($dia_dup_grp).appendTo($me_container);

    $('#' + this.options.dup_grp_dia_id).dialog({ width:($this.options.duplicateGroupDiaWidth)
                                                 ,height:($this.options.duplicateGroupDiaHeight)
                                                 ,resizable:($this.options.duplicateGroupDiaResizable)
                                                 ,autoOpen:false
                                                 ,modal:true
                                                 ,buttons:{ Cancel:function(){$('#' + $this.options.dup_grp_dia_id).dialog("close");}
                                                     , Save: function () { $this.options.fnDuplicateGroupDiaSave($this, $dia_dup_grp, $dia_dup_grp_form); }
                                                          }});  


  };

  /*============================================================
   * Duplicate And Reverse Stops Group
   *============================================================*/ 
   
  if (this.options.allowDuplicateAndReverseStopsGroup == true) {
	
      $but_duplicate_and_reverse_stops_group = $('<span id="' + this.options.dup_and_reverse_stops_grp_but_opn_id + '" class="fa-stack">'
                                               + '<i class="far fa-clone fa-stack-1x"></i>'
                                               + '<i class="fas fa-random fa-stack-1x fa-sm"></i>'
                                               + '</span>');
    $($but_duplicate_and_reverse_stops_group).attr("title",this.options.duplicateAndReverseStopsGroupDiaTitle);
    $($but_duplicate_and_reverse_stops_group).addClass(this.options.headerControlClass);
    $($but_duplicate_and_reverse_stops_group).click(function(){$this.options.fnDuplicateAndReverseStopsGroupDiaOpen($this);});
    $($me_header_controls).append($but_duplicate_and_reverse_stops_group);

    $dia_dup_and_reverse_stops_grp      = $('<div id="' + this.options.dup_and_reverse_stops_grp_dia_id +'" title="' + this.options.duplicateAndReverseStopsGroupDiaTitle + '"></div>');
	$dia_dup_and_reverse_stops_grp_form = $('<form id="' + this.options.dup_and_reverse_stops_grp_form_id +'" method="post" action="' + this.options.duplicateAndReverseStopsGroupActionURL +'"></form>');	

	this._disableFormSubmitOnEnter($dia_dup_and_reverse_stops_grp_form);  	

	$($dia_dup_and_reverse_stops_grp).append($dia_dup_and_reverse_stops_grp_form);
	
    this.options.fnDuplicateAndReverseStopsGroupDiaContent (this,$dia_dup_and_reverse_stops_grp, $dia_dup_and_reverse_stops_grp_form);
    
	$($dia_dup_and_reverse_stops_grp).appendTo($me_container);

    $('#' + this.options.dup_and_reverse_stops_grp_dia_id).dialog({ width:($this.options.duplicateAndReverseStopsGroupDiaWidth)
                                                 ,height:($this.options.duplicateAndReverseStopsGroupDiaHeight)
                                                 ,resizable:($this.options.duplicateAndReverseStopsGroupDiaResizable)
                                                 ,autoOpen:false
                                                 ,modal:true
                                                 ,buttons:{ Cancel:function(){$('#' + $this.options.dup_and_reverse_stops_grp_dia_id).dialog("close");}
                                                     , Save: function () { $this.options.fnDuplicateAndReverseStopsGroupDiaSave($this, $dia_dup_and_reverse_stops_grp, $dia_dup_and_reverse_stops_grp_form); }
                                                          }});  


  };

  /*============================================================
   * Upload File for group
   *============================================================*/ 

    if (this.options.allowUploadFileForGroup == true) {
    
	  $but_upload = $('<i id="' + this.options.upload_file_for_grp_but_opn_id +'" class="fas fa-upload"></i>');
	  $($but_upload).attr("title",this.options.uploadFileForGroupButTitle);
      $($but_upload).addClass(this.options.headerControlClass);
      $($but_upload).click(function(){
	    $this.options.uploadFileForGroupFnDoFileUpload($this);
	  });	
	
      $($me_header_controls).append($but_upload);    
  };
  
  /*============================================================
   * Print Group
   *============================================================*/ 

  if (this.options.allowPrintGroup == true) { 
      
	$but_print = $('<i id="' + this.options.print_grp_but_opn_id +'" class="fas fa-print"></i>');
	$($but_print).attr("title",this.options.printGroupButTitle);
    $($but_print).addClass(this.options.headerControlClass);
    $($but_print).click(function(){$this.options.fnPrintGroupDiaOpen($this);});
    $($me_header_controls).append($but_print);
    	
  	$dia_print_grp      = $('<div id="'  + this.options.print_grp_dia_id  +'" title="' + this.options.printGroupDiaTitle + '"></div>');
    $dia_print_grp_form = $('<form id="' + this.options.print_grp_form_id +'" method="post" action="' + this.options.printGroupActionURL +'"></form>');	

    this._disableFormSubmitOnEnter($dia_print_grp_form);    
	$($dia_print_grp).append($dia_print_grp_form);	
	this.options.fnPrintGroupDiaContent(this, $dia_print_grp, $dia_print_grp_form);	
    $($dia_print_grp).appendTo($me_container);
	
    $('#' + this.options.print_grp_dia_id).dialog({ width:($this.options.printGroupDiaWidth)
                                                   ,height:($this.options.printGroupDiaHeight)                                                 
					  							   ,resizable:($this.options.printGroupDiaResizable)
                                                   ,autoOpen:false
                                                   ,modal:true
                                                   ,buttons:{  Cancel:function(){$('#' + $this.options.print_grp_dia_id).dialog("close");}
                                                             , Print:function(){$this.options.fnPrintGroupDiaPrint($this,$dia_print_grp,$dia_print_grp_form);}
                                                          }});  
  };
   

  /*============================================================
   * Sort Group
   *============================================================*/ 
 
  if (this.options.allowSortGroup == true) {   
    
	
    $but_sort = $('<i id="' + this.options.sort_grp_but_opn_id +'" class="fas fa-sort"></i>');	    
	$($but_sort).attr("title",this.options.sortGroupButTitle);
    $($but_sort).addClass(this.options.headerControlClass);
    $($but_sort).click(function(){$this.options.fnSortGroupDiaOpen($this);});
    $($me_header_controls).append($but_sort);

  	$dia_sort_grp      = $('<div id="'  + this.options.sort_grp_dia_id  +'" title="' + this.options.sortGroupDiaTitle + '"></div>');
    $dia_sort_grp_form = $('<form id="' + this.options.sort_grp_form_id +'" method="post" action="' + this.options.sortGroupActionURL +'"></form>');
    this._disableFormSubmitOnEnter($dia_sort_grp_form);     

	$($dia_sort_grp).append($dia_sort_grp_form);
	this.options.fnSortGroupDiaContent(this, $dia_sort_grp, $dia_sort_grp_form);	
    $($dia_sort_grp).appendTo($me_container);
    $('#' + this.options.sort_grp_dia_id).dialog({ width:($this.options.sortGroupDiaWidth)
                                                   ,height:($this.options.sortGroupDiaHeight)                                                 
					  							   ,resizable:($this.options.sortGroupDiaResizable)
                                                   ,autoOpen:false
                                                   ,modal:true
                                                   ,buttons:{  Cancel:function(){$('#' + $this.options.sort_grp_dia_id).dialog("close");}
                                                             , Save:function(){$this.options.fnSortGroupDiaSaveOrder ($this,$dia_sort_grp,$dia_sort_grp_form);}
                                                          }});  


  };
    
  /*============================================================
   * Refresh members
   *============================================================*/ 

  if (this.options.allowRefreshMembers == true) {
	
	$but_refresh_members = $('<i id="' + this.options.refresh_grp_members_but_id + '" class="fas fa-sync"></i>');
    $($but_refresh_members).attr("title","Refresh This List");
    $($but_refresh_members).addClass(this.options.headerControlClass);
    $($but_refresh_members).click(function(){$this.refresh();});
    $($me_header_controls).append($but_refresh_members);
  };

  /*============================================================
   * Remove Group
   *============================================================*/ 

  if (this.options.allowRemoveGroup == true) {
    
	
	$but_rem_grp = $('<i id="' + this.options.rem_grp_but_opn_id + '" class="fas fa-trash-alt"></i>');
    $($but_rem_grp).attr("title",this.options.removeGroupDiaTitle);
    $($but_rem_grp).addClass(this.options.headerControlClass);
    $($but_rem_grp).click(function(){$this.options.fnRemoveGroupDiaOpen($this);});
    $($me_header_controls).append($but_rem_grp);
	
	$dia_rem_grp      = $('<div id="'  + this.options.rem_grp_dia_id  +'" title="' + this.options.removeGroupDiaTitle + '"></div>');
	$dia_rem_grp_form = $('<form id="' + this.options.rem_grp_form_id +'" method="post" action="' + this.options.removeGroupActionURL +'"></form>');
	this._disableFormSubmitOnEnter($dia_rem_grp_form);  
	
	$($dia_rem_grp).append($dia_rem_grp_form);
	
    this.options.fnRemoveGroupDiaContent(this,$dia_rem_grp, $dia_rem_grp_form);		
    $($dia_rem_grp).appendTo($me_container);
    $('#' + this.options.rem_grp_dia_id).dialog({ width:($this.options.removeGroupDiaWidth)
                                                 ,height:($this.options.removeGroupDiaHeight)
                                                 ,dialogClass:($this.options.removeGroupDiaClass)
												 ,resizable:($this.options.removeGroupDiaResizable)
                                                 ,autoOpen:false
                                                 ,modal:true
                                                 ,buttons:{ Cancel:function(){$('#' + $this.options.rem_grp_dia_id).dialog("close");}
                                                           ,Remove:function(){$this.options.fnRemoveGroupDiaRemove($this,$dia_rem_grp,$dia_rem_grp_form);}
                                                          }});  

  };

  /*============================================================
   * Edit Group Name
   *============================================================*/ 

  if (this.options.allowChangeGroupName == true) {
    
	
	$but_change_group_name = $('<i id="' + this.options.chg_grp_but_opn_id  +'" class="fas fa-pencil-alt"></i>');
    $($but_change_group_name).attr("title",this.options.changeGroupNameDiaTitle);
    $($but_change_group_name).addClass(this.options.headerControlClass);
    $($but_change_group_name).click(function(){$this.options.fnChangeGroupNameDiaOpen($this);});
    $($me_header_controls).append($but_change_group_name);

    $dia_chg_grp      = $('<div id="' + this.options.chg_grp_dia_id +'" title="' + this.options.changeGroupNameDiaTitle + '"></div>');
	$dia_chg_grp_form = $('<form id="' + this.options.chg_grp_form_id +'" method="post" action="' + this.options.changeGroupNameActionURL +'"></form>');	
    
	this._disableFormSubmitOnEnter($dia_chg_grp_form);  	

	$($dia_chg_grp).append($dia_chg_grp_form);
	
    this.options.fnChangeGroupNameDiaContent (this,$dia_chg_grp, $dia_chg_grp_form);
    
	$($dia_chg_grp).appendTo($me_container);
    $('#' + this.options.chg_grp_dia_id).dialog({ width:($this.options.changeGroupNameDiaWidth)
                                                 ,height:($this.options.changeGroupNameDiaHeight)
                                                 ,resizable:($this.options.changeGroupNameDiaResizable)
                                                 ,autoOpen:false
                                                 ,modal:true
                                                 ,buttons:{ Cancel:function(){$('#' + $this.options.chg_grp_dia_id).dialog("close");}
												           , Save:function(){$this.options.fnChangeGroupNameDiaSave($this, $dia_chg_grp, $dia_chg_grp_form);}
                                                          }});  


  };
  
  /*============================================================
   * Add Group Member
   *============================================================*/ 

  if (this.options.allowAddMember == true) {
    

    $but_add = $('<i id="' + this.options.add_new_but_opn_id + '" class="fas fa-plus"></i>');
    $($but_add).attr("title",this.options.addMemberDiaTitle);
    $($but_add).addClass(this.options.headerControlClass);
    $($but_add).click(function(){$this.options.fnAddMemberDiaOpen($this);});
    $($me_header_controls).append($but_add);
	
    $dia_add_new      = $('<div id="' + this.options.add_new_dia_id +'" title="' + this.options.addMemberDiaTitle + '"></div>');
    $dia_add_new_form = $('<form id="' + this.options.add_mbr_form_id +'" method="post" action="' + this.options.addNewMemberActionURL +'"></form>');	
    this._disableFormSubmitOnEnter($dia_add_new_form);    	
	this.options.fnDiaFormCommonFields (this,$dia_add_new,$dia_add_new_form);
    $($dia_add_new).append($dia_add_new_form);
	this.options.fnAddMemberDiaContent(this, $dia_add_new, $dia_add_new_form);    
	$($dia_add_new).appendTo($me_container);
    $('#' + this.options.add_new_dia_id).dialog({ width:($this.options.addMemberDiaWidth)
                                                 ,height:($this.options.addMemberDiaHeight)
                                                 ,resizable:($this.options.addMemberDiaResizable)
                                                 ,autoOpen:false
                                                 ,modal:true
                                                 ,buttons:{ Cancel:function(){$($dia_add_new).dialog("close");}
                                                           ,Add:function(){$this.options.fnAddMemberDiaAdd($this, $dia_add_new, $dia_add_new_form);}
                                                          }});  

  };

  /*============================================================
   * Show/Hide Group Members (Content)
   *============================================================*/ 
  
  if (this.options.allowShowHideContent == true) {
    
	$but_show_hide = $('<i id="' + this.options.show_hide_members_but_id +'" class="fa"></i>');
	$($but_show_hide).attr("title",this.options.showHideContentButTitle);
                     
	if (this.options.contentInitiallyShownOrHidden == "shown") {
      $($but_show_hide).addClass("fa-caret-up");
      $($me_content).show();
	}
	else if (this.options.contentInitiallyShownOrHidden == "hidden") {
      $($but_show_hide).addClass("fa-caret-down");
      $($me_content).hide();
	}
	else {
      $($but_show_hide).addClass("fa-caret-up");
      $($me_content).show();
	}
	
    $($but_show_hide).addClass(this.options.headerControlClass);
    $($but_show_hide).click(function(){$this.showHideContent();});
    $($me_header_controls).append($but_show_hide);
	
  };
    
  /*============================================================
   * Header controls buttonset
   *============================================================*/ 

  $($me_header_controls).buttonset();
  $($me_header_controls).addClass(this.options.headerControlsClass);
  $($me_header).append($me_header_controls);
   
  /*============================================================
   * Add header 
   *============================================================*/ 

  $($me_container).prepend($me_header);
  

  /*#####################################################################################################################
    # Content Controls
    #####################################################################################################################*/ 

   /*============================================================
    * Content controls container
    *============================================================*/ 

  $('#' + this.options.content_controls_id).remove();
  $me_content_controls = $('<div id="' + this.options.content_controls_id +'"></div>');
  $($me_content_controls).addClass(this.options.contentControlsClass);    

  /*============================================================
   * Search box
   *============================================================*/ 

  if (this.options.allowFilterGroup == true) {
  
    $me_search_term = $('<input id="' + this.options.search_term_id +'" type="search"/>');
  
    $($me_search_term).addClass(this.options.contentControlClass);
    $($me_search_term).attr('title',this.options.searchTermInpTitle);
    $($me_search_term).attr('placeholder',this.options.searchTermInpPlaceholder);

    $($me_search_term).on('keyup paste',function(){
      var term = $($me_search_term).val();
      $this.filterList(term);
    });
  
    $($me_content_controls).append($me_search_term);
  };
  
  
  /*============================================================
   * Create status
   *============================================================*/ 

  $($me_content).prepend($me_status);
  $($me_content).prepend($me_content_controls);

  /*#####################################################################################################################
    # Member dialogs and interactions
    #####################################################################################################################*/ 

  /*============================================================
   * Edit member dialog
   *============================================================*/ 
     
  if (this.options.allowMemberEdit == true) {
    
	$dia_edit      = $('<div id="' + this.options.edit_dia_id +'" title="' + this.options.editMemberDiaTitle + '"></div>');
    $dia_edit_form = $('<form id="' + this.options.edit_mbr_form_id +'" method="post" action="' + this.options.editMemberActionURL +'"></form>');	
    this._disableFormSubmitOnEnter($dia_edit_form);       
	this.options.fnDiaFormCommonFields (this,$dia_edit,$dia_edit_form);
    $($dia_edit).append($dia_edit_form);
	this.options.fnEditMemberDiaContent(this, $dia_edit, $dia_edit_form);
	$($dia_edit).appendTo($me_container);
    $('#' + this.options.edit_dia_id).dialog({  width:($this.options.editMemberDiaWidth)
                                              , height:($this.options.editMemberDiaHeight)
                                              , resizable:($this.options.editMemberDiaResizable)
                                              , autoOpen:false
                                              , modal:true
                                              , buttons:{  Cancel:function(){$($dia_edit).dialog("close");}
                                                         , Save:function(){$this.options.fnEditMemberDiaSave($this, $dia_edit, $dia_edit_form);}
                                                }});  
  };
    
  /*============================================================
   * Remove member dialog 
   *============================================================*/ 
  
  if (this.options.allowMemberRemove == true) {
  
    
	$dia_rem      = $('<div id="'  + this.options.rem_dia_id      +'" title="' + this.options.removeMemberDiaTitle + '"></div>');
    $dia_rem_form = $('<form id="' + this.options.rem_mbr_form_id +'" method="post" action="' + this.options.removeMemberActionURL +'"></form>');   
	this._disableFormSubmitOnEnter($dia_rem_form);       	   
	this.options.fnDiaFormCommonFields (this,$dia_rem,$dia_rem_form);
    $($dia_rem).append($dia_rem_form);
	this.options.fnRemoveMemberDiaContent(this, $dia_rem, $dia_rem_form);    
	$($dia_rem).appendTo($me_container);
    $('#' + this.options.rem_dia_id).dialog({   width:($this.options.removeMemberDiaWidth)
                                              , height:($this.options.removeMemberDiaHeight)
                                              , resizable:($this.options.removeMemberDiaResizable)
											  , dialogClass:($this.options.removeMemberDiaClass)
                                              , autoOpen:false
                                              , modal:true
                                              , buttons:{  Cancel:function(){$($dia_rem).dialog("close");}
                                                         , Remove:function(){$this.options.fnRemoveMemberDiaRemove($this, $dia_rem, $dia_rem_form);}
                                                }});  
  };
  
  /*============================================================
   * Create add new members drop interaction if the option 
   * to do so is set to true
   *============================================================*/  

  if (this.options.allowAddMemberDrop == true) {
  
    var $dropAccept = 'li.' + this.options.dropAcceptClass;

    $('#' + this.options.container_id).droppable({ accept:$dropAccept
                                
                                ,over: function(event,ui) {

                                  var entityID = $(ui.draggable).attr($this.options.entityIDAttr);
                                  if ($this._findMemberInInternalCollection(entityID)) return;
                                  $($me_header).addClass('ui-state-highlight');
                                  $($me_container).addClass('ui-state-highlight');
                                }

                                ,out:function(event,ui) {

                                  $($me_header).removeClass('ui-state-highlight');
                                  $($me_container).removeClass('ui-state-highlight');

                                }

                                ,drop: function( event, ui ) {         
                                  var entityID = $(ui.draggable).attr($this.options.entityIDAttr);
                                  if ($this._findMemberInInternalCollection(entityID)) return;
                                  $($me_header).removeClass('ui-state-highlight');
                                  $($me_container).removeClass('ui-state-highlight');
                                  var lbl = $(ui.draggable).children('.' + $this.options.memberLabelClass).text();

								  var formData = '{';

								  formData = $this.options.fnActionCommonFields ($this, formData)								    
									+ ',"entityID":"'       + entityID                     + '"'
								    + ',"saveType":"'       + '1'                          + '"'
								    + ',"recID":"'          + $this.options.ownerID        + '"'
                                    + $this.options.fnAddMemberViaDropExtraFields ($this)
									+ '}';
                                  								 	  							 
								  $this.addMember(formData);								 

                               }});
  };
  
    
},
 
/***************************************************************************
 * _init */
/**
 * Called once after _create and called once after ever subsequent call
 * to widget.
 ***************************************************************************/ 

_init: function() {  
   /* TODO: Add get group header data) */
   this.getMembers('init',null,null);
   return true;   
},

/***************************************************************************
 * _tearDown */
/**
 * Tear down enhancements
 ***************************************************************************/ 

_tearDown: function() {

  this._logMessageToConsole ('_tearDown','',1);

  $('#' + this.options.header_controls_id).buttonset('destroy').remove();
  $('#' + this.options.print_grp_but_opn_id).button('destroy').remove();	
  $('#' + this.options.print_grp_dia_id).dialog('destroy').remove();
  $('#' + this.options.sort_grp_but_opn_id).button('destroy').remove();	
  $('#' + this.options.sort_grp_dia_id).dialog('destroy').remove();
  $('#' + this.options.refresh_grp_members_but_id).button('destroy').remove();
  $('#' + this.options.rem_grp_but_opn_id).button('destroy').remove();
  $('#' + this.options.rem_grp_dia_id).dialog('destroy').remove();
  $('#' + this.options.chg_grp_but_opn_id).button('destroy').remove();
  $('#' + this.options.chg_grp_dia_id).dialog('destroy').remove();
  $('#' + this.options.add_new_but_opn_id).button('destroy').remove();
  $('#' + this.options.add_new_dia_id).dialog('destroy').remove();
  $('#' + this.options.show_hide_members_but_id).button('destroy').remove();
  $('#' + this.options.edit_dia_id).dialog('destroy').remove();	
  $('#' + this.options.rem_dia_id).dialog('destroy').remove();
  $('#' + this.options.container_id).droppable('destroy');
},

/***************************************************************************
 * destroy */
/**
 * 
 ***************************************************************************/ 

destroy:function() {
  this._logMessageToConsole ('destroy','',1);  
  this._tearDown();
  $('#' + this.options.content_id).unwrap();
  $(this.element).unwrap();
  this._super();  
},

/***************************************************************************
 * refresh */
/**
 * 
 ***************************************************************************/ 

refresh: function() {  
   this._init();
   return true;   
},

/***************************************************************************
 * getExternalRefToWgt */
/**
 * Allows getting external reference to widget (this)
 * fnSetExtRefToThis takes one argument, $refToThis
 * Use external variable inside fnSetExtRefToThis to set
 ***************************************************************************/

 getExternalRefToWgt: function (fnSetExtRefToThis) {
   var $refToThis = this;
   fnSetExtRefToThis($refToThis);
   return;
},

/***************************************************************************
 * renderList */
/**
 * Renders list of members
 ***************************************************************************/ 

renderList:function (calledFromWhat) {
  
  this._logMessageToConsole ('renderList',calledFromWhat,1);

  var $this   = this;
  var mbrObjs = null;
  
  /*============================================================
   * Clear all existing list items
   *============================================================*/ 
  this._setStatusMessage('Rendering');
  $(this.element).html('');
    
  mbrObjs = this.options.members;
  
  /*============================================================
   * Render list items 
   *============================================================*/ 
  var $ul = $('<ul></ul>');
  $.each(mbrObjs, function(idx,mbrObj){    
	var $li = $this._createMemberListItem(mbrObj);	
    $ul.append($li);
  });
  
  this.element.append($ul.children());
  this._setStatusMessage('');    
  return true;  

},

/***************************************************************************
 * getMembers */
/**
 * Get members from server
 ***************************************************************************/ 

getMembers:function (calledFromWhat, data, data2) {    
  
  this._logMessageToConsole ('getMembers',calledFromWhat,1);
  
  this.clearFilter();
  
  var $this    = this;
  var reqUrl   = $.spedmonWebUI.createPrivateURL(this.options.tkn,this.options.getMembersActionURL);
  var reqData  = this.options.fnGetMembersRequestData(this);
  
  this._setStatusMessage('Loading');
  $(this.element).html('');
  this.options.members = null;    
  this.options.members = [];
  
  
  var fnProcRespSuccess = function (rd) {
    $this._setStatusMessage('');  
	$this.options.members = [];
	var Members = rd.SelRecs;
	
	if (Members){
	  
	  $.each( Members, function (idx, Member) {
	   
	     var entityID  = Member.id;
	     var label     = Member.label;
	     var context1  = Member.context1;
	     var recData1  = Member.recData1;
		 var recData2  = Member.recData2;
		 var recData3  = Member.recData3;
		 var recData4  = Member.recData4;
		 var recData5  = Member.recData5;
		 var recData6  = Member.recData6;
		 var recData7  = Member.recData7;
		 var recData8  = Member.recData8;
		 var recData9  = Member.recData9;
		 var recData10 = Member.recData10;
		 var recData11 = Member.recData11;
		 var recData12 = Member.recData12;
		 var recData13 = Member.recData13;
		 var recData14 = Member.recData14;
		 var recData15 = Member.recData15;
		 var recData16 = Member.recData16;
		 
	     $this._addMemberToInternalCollection (  false
		                                       , entityID
		                                       , label
											   , context1
											   , recData1
											   , recData2
											   , recData3
											   , recData4
											   , recData5
											   , recData6
											   , recData7
											   , recData8
											   , recData9
											   , recData10
											   , recData11
											   , recData12
											   , recData13
											   , recData14
											   , recData15
											   , recData16
											   );
      });
	
	
    }
		
	/* Handle editing member immediately after add */
	
	if ($this.options.afterAddMemberEditMember == true) 
	{
	   
	  if (calledFromWhat == 'add') {
	    
		var entityID = null;
		
		/* Entity id is assigned by user from external list (default) so its in the request object */
		
		if ($this.options.entitiesAreExternal == true)
		{
		  if (data)
		  {
		    var dataObj = null;
		    try
		    {
		      dataObj = $.parseJSON(data);
		    }
		    catch(pje)
		    {
		      dataObj = null;
	  	    }
		
		    if (dataObj)
		    {
		      entityID = (dataObj.entityID);								 
		    };
		  };
		}
		
		/* Entity id is the record id of the saved record so its in the response object */
		
		else if ($this.options.entitiesAreExternal == false)
		{
		  if (data2)
		  {
		    if (data2.recordID)
			{
		      entityID = data2.recordID;
			}
		  }
		}
        else
		{
		  entityID = null;
		};
		
		if (entityID)
		{
		  var mbrObj = $this._findMemberInInternalCollection(entityID);
	      if (mbrObj)
	      {
		    $this.options.fnEditMemberDiaOpen($this,mbrObj);
  		  };
		};
		
	  };
	};	
        
	$this.renderList(calledFromWhat);
  };
    	  
  /*============================================================
   * Call server to get members
   *============================================================*/ 

  this._ajaxCall (reqUrl, reqData, fnProcRespSuccess, null, 'getMembers'); 
  
  return true;
},

/***************************************************************************
 * filterList */
/**
 * Renders list of members
 ***************************************************************************/ 

filterList:function(term) {

  /*============================================================
   * If nothing passed in term show everyone and get out
   *============================================================*/ 
  
  if (!term) {
    $(this.element).children('li').show();
    return true;
  }
  
  /*============================================================
   * Force term to be a string
   *============================================================*/ 

  term = '' + term + '';
  term = term.trim(term);
  
  /*============================================================
   * If empty space passed in term show everyone and get out
   *============================================================*/ 

  if (term == '') {
    $(this.element).children('li').show();
    return true;
  }

  /*============================================================
   * Hide everyone
   *============================================================*/ 
  
  $(this.element).children('li').hide();
  
  /*============================================================
   * Only show members that contain term
   *============================================================*/ 
  
  $(this.element).children('li:ContainsText("' + term +'")').show();
  return true;

},

/***************************************************************************
 * clearFilter */
/**
 * Clear filter
 ***************************************************************************/ 

clearFilter:function() {

  $('#' + this.options.search_term_id).val('');
  this.filterList('');
  return true;
},

/***************************************************************************
 * showContent */
/**
 * Show content
 ***************************************************************************/ 

showContent:function() {
   
  var $this             = this;  
  var $showHideMbrsBut  = $('#' + this.options.show_hide_members_but_id);
  var $content          = $('#' + this.options.content_id);
  
  $($showHideMbrsBut).removeClass("fa-caret-up");
  $($showHideMbrsBut).removeClass("fa-caret-down");
  $($showHideMbrsBut).addClass("fa-caret-up");  
  $($content).show("drop down");
  
  /*============================================================
   * Fire event
   *============================================================*/   

  var eventObj  = {};
  var eventData = {};
  this._trigger("showcontent",eventObj,eventData);
  return true;

},

/***************************************************************************
 * hideContent */
/**
 * Hide content
 ***************************************************************************/ 

hideContent:function() {
  
  var $this             = this;  
  var $showHideMbrsBut  = $('#' + this.options.show_hide_members_but_id);
  var $content          = $('#' + this.options.content_id);

  $($showHideMbrsBut).removeClass("fa-caret-up");
  $($showHideMbrsBut).removeClass("fa-caret-down");  
  $($showHideMbrsBut).addClass("fa-caret-down");  
  $($content).hide("drop up");
  
  /*============================================================
   * Fire event
   *============================================================*/   

  var eventObj  = {};
  var eventData = {};
  this._trigger("hidecontent",eventObj,eventData);
  return true;

},

/***************************************************************************
 * showHideContent */
/**
 * Shows content if hidden and hides content if visible.
 ***************************************************************************/ 

showHideContent:function() {
    
  var $this       = this;  
  var $content    = $('#' + this.options.content_id);

  if ($($content).is(':visible')) 
  {  
    $this.hideContent();
  }
  else 
  {
    $this.showContent();
  };
  
  /*============================================================
   * Fire event
   *============================================================*/   

  var eventObj  = {};
  var eventData = {};
  this._trigger("showhidecontent",eventObj,eventData);
  return true;

},

/***************************************************************************
 * changeGroupName */
/**
 * Change group name and other data
 ***************************************************************************/ 

changeGroupName:function (data) {
  
  this._logMessageToConsole ('changeGroupName','',1);

  var $this       = this;
  var reqUrl      = $.spedmonWebUI.createPrivateURL(this.options.tkn,this.options.changeGroupNameActionURL);
  var reqData     = data;

  var fnProcRespSuccess = function (rd) {    
    $this.options.fnOnSuccessChangeGroupName($this,rd);
    var eventObj  = {};
    var eventData = {};	
    $this._trigger("changegroupname");	 
  };
  	
  /*============================================================
   * Call server to change group name
   *============================================================*/   
  	  
  this._ajaxCall(reqUrl, reqData, fnProcRespSuccess, null, 'changeGroupName'); 
  
  return true;
  
},

/***************************************************************************
 * removeGroup */
/**
 * Remove this group
 ***************************************************************************/ 

removeGroup:function(data) {

  this._logMessageToConsole ('removeGroup','',1);
  
  var $this      = this;
  var reqUrl     = $.spedmonWebUI.createPrivateURL(this.options.tkn,this.options.removeGroupActionURL);
  var reqData     = data;
  
  var fnProcRespSuccess = function (rd) {
    $this.options.fnOnSuccessRemoveGroup($this,rd);
    var eventObj  = {};
    var eventData = {};
    $this._trigger("removegroup",eventObj,eventData);
  };
  	
  /*============================================================
   * Call server to remove group
   *============================================================*/   
    
  this._ajaxCall(reqUrl, reqData, fnProcRespSuccess, null, 'removeGroup'); 
  
  return true;

},

/***************************************************************************
 * printGroup */
/**
 * Print this group
 ***************************************************************************/ 

printGroup: function (data) {
  this._downloadFile(this.options.tkn,this.options.printGroupActionURL,data);  
  return true;
},

/***************************************************************************
 * sortGroup */
/**
 * Saves display order
 ***************************************************************************/ 

sortGroup:function (data) {  
  
  this._logMessageToConsole ('saveDisplayOrder','',1);
  
  var $this       = this;
  var reqUrl      = $.spedmonWebUI.createPrivateURL(this.options.tkn,this.options.sortGroupActionURL);
  var reqData     = data;
	
  var fnProcRespSuccess = function (rd) {    
	$this.getMembers('sort',data);
	var eventObj  = {};
    var eventData = {};
    $this._trigger("sortgroup",eventObj,eventData);		
  };
  	
  /*============================================================
   * Call server to save display order
   *============================================================*/   
  	  
  this._ajaxCall(reqUrl, reqData, fnProcRespSuccess, null, 'saveDisplayOrder'); 
  
  return true;
  
},

/***************************************************************************
 * addMember */
/**
 * Add new member
 ***************************************************************************/ 

addMember:function (data) {  
  
  this._logMessageToConsole ('addMember','',1);
  
  var $this       = this;
  var reqUrl      = $.spedmonWebUI.createPrivateURL(this.options.tkn,this.options.addNewMemberActionURL);
  var reqData     = data;
	
  var fnProcRespSuccess = function (rd) {
    $this.getMembers('add',data,rd);
	var eventObj  = {};
    var eventData = {};
    $this._trigger("addmember",eventObj,eventData);	
  };
  
  /*============================================================
   * Call server to add member
   *============================================================*/   
  	  
  this._ajaxCall(reqUrl, reqData, fnProcRespSuccess, null, 'addMember'); 
  
  return true;
  
},

/***************************************************************************
 * editMember */
/**
 * Edit existing member
 ***************************************************************************/ 

editMember:function (data) {  
  
  this._logMessageToConsole ('editMember','',1);
  
  var $this       = this;
  var reqUrl      = $.spedmonWebUI.createPrivateURL(this.options.tkn,this.options.editMemberActionURL);
  var reqData     = data;

  var fnProcRespSuccess = function (rd) {    
    $this.getMembers('edit',reqData,rd);
    $this.options.fnOnSuccessEditMember($this,rd);
    var eventObj  = {};
    var eventData = {};
    $this._trigger("editmember",eventObj,eventData);
  };
  
  /*============================================================
   * Call server to edit member
   *============================================================*/   

  this._ajaxCall(reqUrl, reqData, fnProcRespSuccess, null, 'editMember');
  
  return true;
  
},

/***************************************************************************
 * removeMember */
/**
 * Remove member
 ***************************************************************************/ 

removeMember:function(data) {
  
  this._logMessageToConsole ('removeMember','',1);

  var $this      = this;
  var reqUrl     = $.spedmonWebUI.createPrivateURL(this.options.tkn,this.options.removeMemberActionURL);
  var reqData    = data;
  
  var fnProcRespSuccess = function (rd) {    
	$this.getMembers('remove',reqData,rd);
	$this.options.fnOnSuccessRemoveMember($this,rd);
    var eventObj  = {};
    var eventData = {};
    $this._trigger("removemember",eventObj,eventData);
  };
  	
  /*============================================================
   * Call server to remove member
   *============================================================*/   
  
  this._ajaxCall(reqUrl, reqData, fnProcRespSuccess, null, 'removeMember'); 
  
  return true;
},
	
/***************************************************************************
 * _createMemberObj */
/**
 * Creates member object that is appended to internal collection
 ***************************************************************************/ 

_createMemberObj: function (  entityID
                            , lbl
							, context1
							, recData1
							, recData2
							, recData3
							, recData4
							, recData5
							, recData6
							, recData7
							, recData8
							, recData9
							, recData10
							, recData11
							, recData12
                            , recData13
                            , recData14
                            , recData15
                            , recData16	) {

  this._logMessageToConsole ('_createMemberObj', '', 1);
  
  var mbrObj = {};

  mbrObj.entityID  = entityID;
  mbrObj.lbl       = lbl;
  mbrObj.context1  = context1;
  mbrObj.recData1  = recData1;
  mbrObj.recData2  = recData2;
  mbrObj.recData3  = recData3;
  mbrObj.recData4  = recData4;
  mbrObj.recData5  = recData5;
  mbrObj.recData6  = recData6;
  mbrObj.recData7  = recData7;
  mbrObj.recData8  = recData8;
  mbrObj.recData9  = recData9;
  mbrObj.recData10 = recData10;
  mbrObj.recData11 = recData11;
  mbrObj.recData12 = recData12;
  mbrObj.recData13 = recData13;
  mbrObj.recData14 = recData14;
  mbrObj.recData15 = recData15;
  mbrObj.recData16 = recData16;
  
  return mbrObj;

},

/***************************************************************************
 * _addMemberToInternalCollection */
/**
 * Adds member to internal collection of members
 ***************************************************************************/ 

_addMemberToInternalCollection:function (  findExistingTest
                                         , entityID
                                         , lbl
										 , context1
										 , recData1
										 , recData2
										 , recData3
										 , recData4
										 , recData5
										 , recData6
										 , recData7
										 , recData8
										 , recData9
										 , recData10
										 , recData11
										 , recData12 
										 , recData13 
										 , recData14 
										 , recData15 
										 , recData16 ) {

  
  this._logMessageToConsole ('_addMemberToInternalCollection', entityID, 1);
  
  /*============================================================
   * Look for existing member if applicable
   *============================================================*/ 

  var mbrObj = null;
  if (findExistingTest == true) {
    mbrObj = this._findMemberInInternalCollection(entityID);
    if (mbrObj) return false;
  };
  
  /*============================================================
   * Add a member to the internal collection
   *============================================================*/ 

  mbrObj = this._createMemberObj ( entityID
                                 , lbl
								 , context1
								 , recData1
								 , recData2
								 , recData3
								 , recData4
								 , recData5
								 , recData6
								 , recData7
								 , recData8
								 , recData9
								 , recData10
								 , recData11
								 , recData12 
								 , recData13 
								 , recData14 
								 , recData15 
								 , recData16 );
								 
  this.options.members.push(mbrObj);
  return true;
},

/***************************************************************************
 * _removeMemberFromInternalCollection */
/**
 * Removes member from internal collection of members
 ***************************************************************************/ 

_removeMemberFromInternalCollection:function(entityID) {

  this._logMessageToConsole ('_removeMemberFromInternalCollection', entityID, 1);
  
  /*============================================================
   * Look for existing member
   *============================================================*/ 

  var mbrObj = this._findMemberInInternalCollection(entityID);

  /*============================================================
   * If member is found we can remove it
   *============================================================*/ 

  if (mbrObj) {
    var idx = this.options.members.indexOf(mbrObj);
    if (idx > -1) {
      this.options.members.splice(idx,1);
      return true;
     }
  };
  
  return false;
},

/***************************************************************************
 * _findMemberInInternalCollection */
/**
 * Find member in internal collection
 ***************************************************************************/ 

_findMemberInInternalCollection:function (entityID) {

  this._logMessageToConsole ('_findMemberInInternalCollection', entityID, 1);
  
  /*============================================================
   * Find a member by entityID in the internal collection
   * Note: Only one member per unique entityID is allowed
   *============================================================*/ 
  
  var $this = this;
 
  var mbr = null;
  var id1 = '' + entityID + ''; /* Force id1 to be a string */
  $.each($this.options.members,function(idx,member){
    var id2 = '' + member.entityID + ''; /* Force id2 to be a string */
    if (id1 == id2) {
      mbr = member;
      return false; /* Break out of $.each */
    }
  });
  return mbr;
},

/***************************************************************************
 * _createListItem */
/**
 * Creates list item for member and sort list
 ***************************************************************************/ 

_createListItem:function(mbrObj, $ctrlBut1, $ctrlBut2) {

  var $this = this;
   
  /*============================================================
   * List item
   *============================================================*/ 

  var $li = $('<li></li>');
  
  $($li).attr(this.options.entityIDAttr,mbrObj.entityID);  
  $($li).addClass(this.options.memberClass);
  
  /*============================================================
   * List item line 1 and 2
   *============================================================*/ 
  
  var $li1 = $('<div></div>');
  var $li2 = $('<div></div>');
  $($li1).addClass(this.options.memberLineClass);
  $($li2).addClass(this.options.memberLineClass);
  
  /*============================================================
   * Create list item label
   *============================================================*/ 

  var $liLabel = $('<span>' + mbrObj.lbl + '</span>');
  $($liLabel).addClass(this.options.memberLabelClass);

  /*============================================================
   * Create list item context
   *============================================================*/ 
   
  var context1Data = '';  
  if (mbrObj.context1) context1Data = mbrObj.context1;
  
  var $liContext1 = $('<span>' + context1Data  + '</span>');
  $($liContext1).addClass(this.options.memberContextClass);
  
  /*===========================================================
   * Create list item controls container
   *============================================================*/ 
   
  var hasControls = false;
  var $liControls = $('<span></span>');
  $($liControls).addClass(this.options.memberControlsClass);

  /*===========================================================
   * Control 1
   *============================================================*/ 

  if ($ctrlBut1) {
    $($liControls).append($ctrlBut1);
    hasControls = true;
  };
  
  /*===========================================================
   * Control 2
   *============================================================*/ 

  if ($ctrlBut2) {
    $($liControls).append($ctrlBut2);
    hasControls = true;
  };

  /*============================================================
   * If the list item has controls enhance the controls container
   * into a buttonset
   *============================================================*/ 

  if (hasControls == true) {
    $($liControls).buttonset();
  }

  /*============================================================
   * Append label and controls container to list item 
   *============================================================*/ 

  $($li1).append($liLabel);
  $($li1).append($liControls);
  $($li2).append($liContext1);  
  $($li).append($li1);
  $($li).append($li2);
  
  return $li;
},

/***************************************************************************
 * _createSortListItem */
/**
 * Create HTML for sort list item
 ***************************************************************************/ 

_createSortListItem:function(mbrObj) {

  var $li = this._createListItem(mbrObj,null,null);
  $($li).css('cursor','move');
  return $li;
},

/***************************************************************************
 * _createMemberListItem */
/**
 * Create HTML for member list item
 ***************************************************************************/ 

_createMemberListItem:function(mbrObj) {

  var $this    = this;
  var $li      = null;
  var $butEdit = null;
  var $butRem  = null;
  
  /*============================================================
   * Create edit list item control and append to controls
   * container if the option to do so is set to true
   *============================================================*/ 

  if (this.options.allowMemberEdit == true) { 
    $butEdit = $('<i title="' + this.options.editMemberDiaTitle +'" class="fas fa-pencil-alt"></i>');
    $($butEdit).addClass(this.options.memberControlClass);
    $($butEdit).click(function(){$this.options.fnEditMemberDiaOpen($this,mbrObj);});
  };

  /*============================================================
   * Create remove item control and append to controls container
   * if the option to do so is set to true
   *============================================================*/ 

  if (this.options.allowMemberRemove == true) {  
    $butRem = $('<i title="' + this.options.removeMemberDiaTitle +'" class="fas fa-minus-circle"></i>');
    $($butRem).addClass(this.options.memberControlClass);
    $($butRem).click(function(){$this.options.fnRemoveMemberDiaOpen($this,mbrObj);});
  };

  /*============================================================
   * Create list item 
   *============================================================*/ 

  $li = this._createListItem(mbrObj,$butEdit,$butRem);
  
  /*============================================================
   * Create list item draggable interaction if the option to 
   * do so is set to true
   *============================================================*/ 

  if (this.options.allowMemberDrag == true) {

    $($li).draggable('destroy').draggable({ revert:"invalid"
                     , helper:"clone"
                     , zIndex:9000
                     , cursor:"move"
                     , start: function() { $(this).addClass('ui-state-highlight')}
                     , stop: function() { $(this).removeClass('ui-state-highlight');}
                   });
  
    $($li).css('cursor','move');
  };
  
  return $li;
},

/***************************************************************************
 * duplicateGroup */
/**
 * Create a duplicate of the route
 ***************************************************************************/ 

duplicateGroup:function (data) {  
  
  this._logMessageToConsole ('duplicateGroup','',1);
  
  var $this       = this;
  var reqUrl      = $.spedmonWebUI.createPrivateURL(this.options.tkn,this.options.duplicateGroupActionURL);
  var reqData     = data;

  var fnProcRespSuccess = function (rd) {    
    $this.options.fnOnSuccessDuplicateGroup($this,rd);
    var eventObj  = {};
    var eventData = {};
    $this._trigger("duplicateGroup",eventObj,eventData);
  };
  
  /*============================================================
   * Call server to edit member
   *============================================================*/   

  this._ajaxCall(reqUrl, reqData, fnProcRespSuccess, null, 'duplicateGroup');
  
  return true;
  
},

/***************************************************************************
 * duplicateAndReverseStopsGroup */
/**
 * Create a duplicate of the route with the stops reversed
 ***************************************************************************/ 

duplicateAndReverseStopsGroup:function (data) {  
  
  this._logMessageToConsole ('duplicateAndReverseStopsGroup','',1);
  
  var $this       = this;
  var reqUrl      = $.spedmonWebUI.createPrivateURL(this.options.tkn,this.options.duplicateAndReverseStopsGroupActionURL);
  var reqData     = data;

  var fnProcRespSuccess = function (rd) {    
    $this.options.fnOnSuccessDuplicateAndReverseStopsGroup($this,rd);
    var eventObj  = {};
    var eventData = {};
    $this._trigger("duplicateAndReverseStopsGroup",eventObj,eventData);
  };
  
  /*============================================================
   * Call server to edit member
   *============================================================*/   

  this._ajaxCall(reqUrl, reqData, fnProcRespSuccess, null, 'duplicateAndReverseStopsGroup');
  
  return true;
  
}

});

})(jQuery);
