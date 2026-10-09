/***************************************************************************
 * jquery-ui-mba-entitygroups.js */
/**
 ***************************************************************************/   
 
;(function($){

/***************************************************************************
 * mba.entityGroups */
/**
 * Entity groups widget
 *
 * Requires: jquery.ui.mba.entitygrouping-base.js
 *           jquery.ui-mba-entitygroup.js
 *           jquery.MBA.common.js 
 *           jquery.MBA.webuicontrols.js
 * 
 * Note: This class requires delegates to be defined in the options
 * in order to work.
 ***************************************************************************/ 

$.widget("mba.entitygroups", $.mba.entitygroupingbase, {

/***************************************************************************
 * options */
/**
 * Default options and instance specific data
 ***************************************************************************/ 

options: { 
   name:"My Groups"
  ,organizationID:null
  ,ownerID:null
  ,groups:[]
  ,allowAddGroup:true
  ,allowRefreshGroups:true
  ,allowSortGroups:true
  ,allowPrintGroups:false
  ,allowFilterGroups:false
  ,allowShowHideGroupsContent:false
  ,statusClass:"mba-entity-groups-status"
  ,containerClass:"ui-helper-clearfix ui-widget ui-widget-content ui-corner-all mba-entity-groups"
  ,headerClass:"ui-helper-clearfix ui-widget-header ui-corner-all mba-entity-groups-header"
  ,contentClass:"mba-entity-groups-content"
  ,contentControlsClass:"mba-entity-groups-content-controls"
  ,contentControlClass:"mba-entity-groups-content-control"
  ,headerTitleClass:"mba-entity-groups-header-title"
  ,headerControlsClass:"mba-entity-groups-header-controls"
  ,headerControlClass:"mba-entity-groups-header-control"
  ,groupsClass:"ui-helper-reset mba-entity-groups"
  ,groupPlaceholderClass:"mba-entity-group-placeholder ui-corner-all ui-state-highlight"
  ,groupPlaceholderHandleSelector:".mba-entity-group-header"
  ,groupPlaceholderCancelSelector:".mba-entity-group-control"
  ,groupSelector:"div.mba-entity-group"
  ,searchTermInpTitle:"Filter Groups"
  ,searchTermInpPlaceholder:"Enter Text to Filter Groups By"
  ,addNewGroupButLabel:"Add Group"
  ,addNewGroupDiaTitle:"Add New Group"
  ,addNewGroupDiaWidth: 500
  ,addNewGroupDiaHeight: 200
  ,addNewGroupDiaResizable: false
  ,getGroupsActionURL:""
  ,addNewGroupActionURL:""
  
  ,showHideGroupsContentButLabel:"Show or Hide Groups Content"
  ,showHideGroupsContentButTitle:"Show or Hide Groups Content"
  
  /*============================================================
   * Print groups
   *============================================================*/
   
  ,printGroupsButLabel:"Print Groups"
  ,printGroupsButTitle:"Print All Groups"
  ,printGroupsDiaTitle:"Print All Groups"
  ,printGroupsDiaWidth:300
  ,printGroupsDiaHeight:300
  ,printGroupsDiaResizable:true
  ,fnPrintGroupsFormPopulate:function(wgt,$frm){}
  ,fnPrintGroupsDiaOpen:function(wgt){
    var $dia = $('#' + wgt.options.print_grps_dia_id);
	var $frm = $('#' + wgt.options.print_grps_form_id);
	$.spedmonWebUI.formClear($frm); 
	wgt.options.fnPrintGroupsFormPopulate(wgt,$frm);	    
	$($dia).dialog("open");
  }
  ,fnPrintGroupsDiaContent:function(wgt,dia,frm){   
	$(frm).append('<input name="organizationID" value="' + wgt.options.organizationID +'"  type="hidden" />');
    $(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID        +'"  type="hidden" />');
  }    
  ,fnPrintGroupsDiaPrint:function(wgt,dia,frm){
     var data = $.spedmonWebUI.formParmsToNVPS(frm);	  
     $(dia).dialog("close");
     wgt.printGroups(data);
  }  
  ,fnGetGroupsRequestData:function(wgt){}
  ,fnRenderGroupWidget:function(wgt,grpObj,grpMkup){}
  
  ,fnAddNewGroupDiaContent:function(wgt,dia,frm){
  
    var $lblGroupName = $('<label for="' + wgt.options.add_new_grp_form_group_name_id + '">New Group Name</label>');
	var $txtGroupName = $('<input name="groupName" id="' + wgt.options.add_new_grp_form_group_name_id +'" type="text" placeholder="Enter new group name"/>');
    
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

  ,fnAddNewGroupDiaAdd:function(wgt,dia,frm){
	var data = $.spedmonWebUI.formParmsToJSON(frm);	
	wgt.addNewGroup(data);
	$(dia).dialog("close");
    return true;
  }  

  ,container_id:null
  ,header_id:null
  ,content_id:null
  ,add_new_dia_id:null
  ,add_new_grp_form_id:null
  ,add_new_grp_form_group_name_id:null
 

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

  this.options.container_id                    = me_id + '-container';
  this.options.header_id                       = me_id + '-header';
  this.options.header_title_id                 = me_id + '-header-title';
  this.options.content_id                      = me_id + '-content';
  this.options.content_controls_id             = me_id + '-content-controls';    
  this.options.add_new_dia_id                  = me_id + '-dia-add-new';
  this.options.add_new_grp_form_id             = me_id + '-add-new-form';
  this.options.add_new_grp_form_group_name_id  = me_id + '-group-name';
  this.options.print_grps_dia_id               = me_id + '-dia-print-groups';
  this.options.print_grps_form_id              = me_id + '-dia-print-groups-form';
  this.options.show_hide_groups_content_but_id = me_id + '-show-hide-groups-content-but';
  this.options.search_term_id                  = me_id + '-search-term';
  
  /*============================================================
   * References to existing and new markup
   *============================================================*/ 

  var $me_status                   = this._setupStatus();
  var $me_style                     = '';  
  var $me_container                 = null;
  var $me_header                    = null;
  var $me_header_title              = null;
  var $me_header_controls           = null;
  var $me_search_term               = null;
  var $me_content                   = null;
  var $me_content_controls          = null;
  var $but_print                    = null;
  var $but_add                      = null;
  var $but_show_hide_groups_content = null;
  var $but_refresh_groups           = null;
  var $dia_add_new                  = null;
  var $dia_add_new_form             = null;  
  var $dia_print_groups             = null;
  var $dia_print_groups_form        = null;

  /*============================================================
   * Remove style rules from original and add css clases
   *============================================================*/ 

  $me_style = $($me).attr('style');
  $($me).attr('style','');
  $($me).addClass(this.options.groupsClass);
    
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
  
  $me_header = $('<div id="' + this.options.header_id +'"></div>');
  $($me_header).addClass(this.options.headerClass);
  $($me_container).prepend($me_header);

  /*============================================================
   * Create new span and append to widget header.
   * This is the title
   *============================================================*/ 

  $me_header_title = $('<span id="' + this.options.header_title_id  +'">' + this.options.name + '</span>');
  $($me_header_title).addClass(this.options.headerTitleClass);
  $($me_header).append($me_header_title);

  /*============================================================
   * Create new span and append to widget header.
   * This is the header controls container
   *============================================================*/ 

  $me_header_controls = $('<span></span>');
  $($me_header_controls).addClass(this.options.headerControlsClass);
  $($me_header).append($me_header_controls);

  /*============================================================
   * Attach status
   *============================================================*/ 

  $($me_content).prepend($me_status);
  
  /*============================================================
   * Create content controls and prepend to content
   *============================================================*/ 

  $me_content_controls = $('<div id="' + this.options.content_controls_id +'"></div>');
  $($me_content_controls).addClass(this.options.contentControlsClass);
  $($me_content).prepend($me_content_controls);
  
  /*============================================================
   * Create print groups control if the option to do so 
   * is set to true
   *============================================================*/ 

  if (this.options.allowPrintGroups == true) { 
    
	$('#' + this.options.print_grps_dia_id).dialog('destroy').remove();
	
    $but_print = $('<i class="fas fa-print"></i>');
	$($but_print).attr("title",this.options.printGroupsButTitle);
    $($but_print).addClass(this.options.headerControlClass);
    
	$($but_print).click(function(){
	  $this.options.fnPrintGroupsDiaOpen($this);	  
	});
	
	$dia_print_groups      = $('<div id="' + this.options.print_grps_dia_id +'" title="' + this.options.printGroupsDiaTitle + '"></div>');
	$dia_print_groups_form = $('<form id="' + this.options.print_grps_form_id +'" method="post" action="' + this.options.printGroupsActionURL +'"></form>');
  
	this._disableFormSubmitOnEnter($dia_print_groups_form);
	
    $($dia_print_groups).append($dia_print_groups_form);
	
	this.options.fnPrintGroupsDiaContent(this, $dia_print_groups, $dia_print_groups_form);
    
	$($dia_print_groups).appendTo($me_container);
	
    $('#' + this.options.print_grps_dia_id).dialog({  width:($this.options.printGroupsDiaWidth)
                                                    , height:($this.options.printGroupsDiaHeight)
                                                    , resizable:($this.options.printGroupsDiaResizable)
                                                    , autoOpen:false
                                                    , modal:true
                                                    , buttons:{  Cancel:function(){$($dia_print_groups).dialog("close");}
                                                               , Print: function(){$this.options.fnPrintGroupsDiaPrint($this, $dia_print_groups, $dia_print_groups_form);}
                                                     }});  
    
	$($me_header_controls).append($but_print);
  }
  
  /*============================================================
   * Create refresh groups control if the option to do so 
   * is set to true
   *============================================================*/ 

  if (this.options.allowRefreshGroups == true) {
    $but_refresh_groups = $('<i class="fas fa-sync"></i>');
    $($but_refresh_groups).attr("title","Refresh List of Groups");
    $($but_refresh_groups).addClass(this.options.headerControlClass);
    $($but_refresh_groups).click(function(){$this._init();});
    $($me_header_controls).append($but_refresh_groups);
  };

  /*============================================================
   * Create add group control and add group dialog 
   * if the option to do so is set to true
   *============================================================*/ 

  if (this.options.allowAddGroup == true) {

    $('#' + this.options.add_new_dia_id).dialog('destroy').remove();
	
	$but_add = $('<i class="fas fa-plus"></i>');
    $($but_add).attr("title",this.options.addNewGroupDiaTitle);
    $($but_add).addClass(this.options.headerControlClass);
    $($but_add).click(function(){
	  var $addGrpFrm = $('#' + $this.options.add_new_grp_form_id );
	  $.spedmonWebUI.formClear($addGrpFrm); 
	  $('#' + $this.options.add_new_dia_id).dialog("open");
	});
	
    $($me_header_controls).append($but_add);

    $dia_add_new = $('<div id="' + this.options.add_new_dia_id +'" title="' + this.options.addNewGroupDiaTitle + '"></div>');
	
	$dia_add_new_form = $('<form id="' + this.options.add_new_grp_form_id +'" method="post" action="' + this.options.addNewGroupActionURL +'"></form>');	
	
	$($dia_add_new_form).append('<input name="organizationID" value="' + this.options.organizationID +'"  type="hidden" />');
	$($dia_add_new_form).append('<input name="ownerID"        value="' + this.options.ownerID        +'"  type="hidden" />');
    $($dia_add_new_form).append('<input name="saveType"       value="1" type="hidden" />');
    $($dia_add_new_form).append('<input name="recID"          value=""  type="hidden" />');
    
	this._disableFormSubmitOnEnter($dia_add_new_form);
	
    $($dia_add_new).append($dia_add_new_form);

	this.options.fnAddNewGroupDiaContent(this, $dia_add_new, $dia_add_new_form);

    $($dia_add_new).appendTo($me_container);
    $('#' + this.options.add_new_dia_id).dialog({ width:($this.options.addNewGroupDiaWidth)
                                                 ,height:($this.options.addNewGroupDiaHeight)
                                                 ,resizable:($this.options.addNewGroupDiaResizable)
                                                 ,autoOpen:false
                                                 ,modal:true
                                                 ,buttons:{ Cancel:function(){$($dia_add_new).dialog("close");}
                                                           ,Add:function(){$this.options.fnAddNewGroupDiaAdd($this, $dia_add_new, $dia_add_new_form);}
                                                          }});  
  };
  
  
  /*============================================================
   * Show/hide groups content
   *============================================================*/ 

  if (this.options.allowShowHideGroupsContent == true) {
    
	$but_show_hide_groups_content = $('<i class="fas fa-caret-up"></i>');
    
	$($but_show_hide_groups_content).attr("id",this.options.show_hide_groups_content_but_id);
	$($but_show_hide_groups_content).attr("title",this.options.showHideGroupsContentButTitle);
	$($but_show_hide_groups_content).addClass(this.options.headerControlClass);
	
	$($but_show_hide_groups_content).click(function(){
        $this.showHideGroupsContent();
    });    
	
    $($me_header_controls).append($but_show_hide_groups_content);
  };
  
  /*============================================================
   * Create search box if allowed
   *============================================================*/ 

  if (this.options.allowFilterGroups == true) {
  
    $me_search_term = $('<input id="' + this.options.search_term_id +'" type="search"/>');  
    $($me_search_term).addClass(this.options.contentControlClass);
    $($me_search_term).attr('title',this.options.searchTermInpTitle);
    $($me_search_term).attr('placeholder',this.options.searchTermInpPlaceholder);

    $($me_search_term).on('keyup paste',function(){
      var term = $($me_search_term).val();
      $this.filterGroups(term);
    });
  
    $($me_content_controls).append($me_search_term);
	
  };
  
  /*============================================================
   * Header controls buttonset
   *============================================================*/ 

  $($me_header_controls).buttonset();

  /*============================================================
   * Create sortable interaction if the option to do so is set
   * to true
   *============================================================*/ 

  
  if (this.options.allowSortGroups == true) {

    $( this.element).sortable('destroy').sortable({
        handle: $this.options.groupPlaceholderHandleSelector,
        cancel: $this.options.groupPlaceholderCancelSelector,
        placeholder: $this.options.groupPlaceholderClass,
        items:$this.options.groupSelector
    });
        
    $($me_content).on("entitygroupshowhidecontent", function(event, ui){
      $($this.element).sortable("refresh");
    });
	 
  };
  
},
 
/***************************************************************************
 * _init */
/**
 * Called once after _create and called once after ever subsequent call
 * to widget.
 ***************************************************************************/ 

_init: function() {  
  this.getGroups('init');
  return true;   
},

/***************************************************************************
 * destroy */
/**
 * 
 ***************************************************************************/ 

destroy:function() {
  this._logMessageToConsole ('destroy','',1);  
  this._super();  
},

/***************************************************************************
 * findGroupElements */
/**
 * 
 ***************************************************************************/ 

findGroupElements:function() {
  return $(this.element).find('.mba-entity-group-members');
},

/***************************************************************************
 * getGroups */
/**
 * Get groups from server
 ***************************************************************************/ 

getGroups:function(calledFromWhat) {

  this._logMessageToConsole ('getGroups',calledFromWhat,1);
  var $this = this;
  
  this.clearFilter();
  
  var reqUrl   = $.spedmonWebUI.createPrivateURL(this.options.tkn,this.options.getGroupsActionURL);
  var reqData  = $this.options.fnGetGroupsRequestData(this);
  
  this.element.html('');
  this._setStatusMessage('Loading');
  
  var fnProcRespSuccess = function (rd) {	
    $this.options.groups = null;
    $this.options.groups = [];
	var Groups = rd.SelRecs;	
	
	if (Groups) {      
	  $.each( Groups, function (idx, Group) {
	     var groupID   = Group.id;
	     var label     = Group.label;
	     var context1  = Group.context1;
	     var recData1  = Group.recData1;
         var recData2  = Group.recData2;
         var recData3  = Group.recData3;
         var recData4  = Group.recData4;
         var recData5  = Group.recData5;
         var recData6  = Group.recData6;
         var recData7  = Group.recData7;
         var recData8  = Group.recData8;
         var recData9  = Group.recData9;
         var recData10 = Group.recData10;
         var recData11 = Group.recData11;
         var recData12 = Group.recData12;		 
		 var recData13 = Group.recData13;
		 var recData14 = Group.recData14;
		 var recData15 = Group.recData15;
		 var recData16 = Group.recData16;
		 
	     $this._addGroupToInternalCollection (  groupID
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
    };
    
	$this.renderGroups(calledFromWhat);
    $this._setStatusMessage('');  
	
	var eventObj  = {};
    var eventData = {};
    $this._trigger("getgroups",eventObj,eventData);	
  
  
  };
  	
  /*============================================================
   * Call server to get groups
   *============================================================*/   
  
  this._ajaxCall (reqUrl, reqData, fnProcRespSuccess, null, 'getGroups'); 
  
  return true;
},

/***************************************************************************
 * renderGroups */
/**
 * Renders entity groups
 ***************************************************************************/ 

renderGroups:function(calledFromWhat) {

  this._logMessageToConsole ('renderGroups',calledFromWhat,1);
  
  var $this = this;
  
  /*============================================================
   * Clear out existing groups
   *============================================================*/ 
     
  $(this.findGroupElements).entitygroup('destroy');  
  this.element.html('');
  
  /*============================================================
   * Render groups 
   *============================================================*/ 
    
  $.each($this.options.groups,function(idx,grpObj){      
	var $group = $('<ul id="grp-' + grpObj.groupID +'"></ul>');	
	$this.element.append($group);
	$this.options.fnRenderGroupWidget($this,grpObj,$group);	
  });
    
  return true;  

},

/***************************************************************************
 * addNewGroup */
/**
 * Add new group
 ***************************************************************************/ 

addNewGroup: function (data) {
  
  this._logMessageToConsole ('addNewGroup','',1);
  
  var $this       = this;
  var reqUrl      = $.spedmonWebUI.createPrivateURL(this.options.tkn,this.options.addNewGroupActionURL);
  var reqData     = data;
	
  var fnProcRespSuccess = function (rd) {
    $this.getGroups('addNewGroup');
    var eventObj  = {};
    var eventData = {};
    $this._trigger("addgroup",eventObj,eventData);
  };
    
  /*============================================================
   * Call server to add group
   *============================================================*/   
  	
  this._ajaxCall(reqUrl, reqData, fnProcRespSuccess, null, 'addNewGroup'); 
  
  return true;
  
},

/***************************************************************************
 * printGroups */
/**
 * 
 ***************************************************************************/ 

printGroups: function (data) {  
  this._downloadFile(this.options.tkn,this.options.printGroupsActionURL,data)  
  return true;
},

/***************************************************************************
 * showAllGroups */
/**
 ***************************************************************************/ 

showAllGroups:function(){
  var $this = this; 
  $(this.element).children($this.options.groupSelector).show();
  return true;
},

/***************************************************************************
 * hideAllGroups */
/**
 ***************************************************************************/ 

hideAllGroups:function(){
  var $this = this; 
  $(this.element).children($this.options.groupSelector).hide();
  return true;
},

/***************************************************************************
 * filterGroups */
/**
 * Filters groups by term
 ***************************************************************************/ 

filterGroups:function(term) {

  var $this = this; 
  
  /*============================================================
   * If nothing passed in term show all groups and get out
   *============================================================*/ 
  
  if (!term) {
    this.showAllGroups();	
    return true;
  };
  
  /*============================================================
   * Force term to be a string
   *============================================================*/ 

  term = '' + term + '';
  term = term.trim(term).toUpperCase();
  term = term.toUpperCase();
  
  /*============================================================
   * If empty space passed in show all groups and get out
   *============================================================*/ 
  
  if (term == '') {
    this.showAllGroups();
    return true;
  };
    
  /*============================================================
   * Hide all groups
   *============================================================*/ 
  
  this.hideAllGroups();
  
  /*============================================================
   * Only show groups that contain term
   *============================================================*/ 
  
  $(this.element).children($this.options.groupSelector + ':ContainsText("' + term +'")').show();
  
  return true; 
},

/***************************************************************************
 * clearFilter */
/**
 * Clear filter
 ***************************************************************************/ 

clearFilter:function() {

  $('#' + this.options.search_term_id).val('');
  this.filterGroups('');
  return true;

},

/***************************************************************************
 * showHideGroupsContent */
/**
 * Bulk show or hide groups content
 ***************************************************************************/ 

showHideGroupsContent:function() {

  var $this                    = this; 
  var $showHideGrpsContentBut  = $('#' + this.options.show_hide_groups_content_but_id);

  $($showHideGrpsContentBut).toggleClass( "fa-caret-up fa-caret-down");  

  if ( $($showHideGrpsContentBut).hasClass("fa-caret-up")) {
    $.each($this.options.groups,function(idx,grpObj){
      var $grp = $('#grp-' + grpObj.groupID);
      $($grp).entitygroup('showContent');
    });
  }
  
  else if ( $($showHideGrpsContentBut).hasClass("fa-caret-down")) {
    $.each($this.options.groups,function(idx,grpObj){
      var $grp = $('#grp-' + grpObj.groupID);
      $($grp).entitygroup('hideContent');
    });
  }
  else {
    $.each($this.options.groups,function(idx,grpObj){
      var $grp = $('#grp-' + grpObj.groupID);
      $($grp).entitygroup('showHideContent');
    });
  }
  
  return true;  
},

/***************************************************************************
 * _createGroupObj */
/**
 * Creates member object that is appended to internal collection
 ***************************************************************************/ 

_createGroupObj: function (  groupID
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
						   , recData16 ) 
{

  this._logMessageToConsole ('_createGroupObj',groupID,1);
  
  var grpObj = {};

  grpObj.groupID   = groupID;
  grpObj.lbl       = lbl;
  grpObj.context1  = context1;
  grpObj.recData1  = recData1;
  grpObj.recData2  = recData2;
  grpObj.recData3  = recData3;
  grpObj.recData4  = recData4;
  grpObj.recData5  = recData5;
  grpObj.recData6  = recData6;
  grpObj.recData7  = recData7;
  grpObj.recData8  = recData8;
  grpObj.recData9  = recData9;
  grpObj.recData10 = recData10;
  grpObj.recData11 = recData11;
  grpObj.recData12 = recData12;  
  grpObj.recData13 = recData13;
  grpObj.recData14 = recData14;
  grpObj.recData15 = recData15;
  grpObj.recData16 = recData16;
  
  return grpObj;

},

/***************************************************************************
 * _addGroupToInternalCollection */
/**
 * Adds group to internal collection of groups
 ***************************************************************************/ 

_addGroupToInternalCollection:function (  groupID
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
								        , recData16) {

  this._logMessageToConsole ('_addGroupToInternalCollection',groupID,1);
  
  /*============================================================
   * Add a member to the internal collection
   *============================================================*/ 

  var grpObj = this._createGroupObj(  groupID
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
								    , recData16
								   );
								 
  this.options.groups.push(grpObj);
  
  return true;
}


});

})(jQuery);
