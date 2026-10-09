<%@ Page Language="C#" CodeBehind="user_all_timekeeper_panel.aspx.cs" Inherits="Spedmon.UserAllTimekeeperPanel" %>


<div class="row"><div class="col-12 col-lg-2">


  <div id="man_page_selections-container" class="ui-mba-content-selection-container">

  <div id="viewModalAddEntryHtml" style="display: none;">

      <form id="addentry-form" data-action="timekeeper_taskentrycalendarevents.asmx/saveTimeEntry" >

        <input id="addentry-tkn" name="tkn" type="hidden" />

        <input id="addentry-ted-id" name="addentry_ted_id" type="hidden" />

        <input id="addentry-date-val" name="addentry_date_val" type="hidden" />

        <div class="container-jumbo my-5">
  <div class="row">
    <div class="col-md-8 mx-auto">
      <div class="form-group">
        <select class="form-control" name="DropDownListEmployer" id="DropDownListEmployer"></select>
        <label class="form-control-placeholder" >Employer</label>
      </div>
      <div class="form-group">
        <select class="form-control" name="ListBoxFavoriteTaskTimeEntry" id="ListBoxFavoriteTaskTimeEntry"></select>

        <label class="form-control-placeholder" >Task</label>
      </div>
      <div class="form-group">
        <select class="form-control" name="ListBoxFavoriteClientTimeEntry" id="ListBoxFavoriteClientTimeEntry"></select>

        <label class="form-control-placeholder" >Client</label>
      </div>
      <div class="row">
        <div class="form-group col-6">
          <input placeholder=" " type="text" id="TextBoxStartTime" name="TextBoxStartTime" class="form-control">
          <label class="form-control-placeholder">Start Time</label>
        </div>
        <div class="form-group col-6">
          <input placeholder=" " class="form-control" name="TextBoxStopTime" type="text" id="TextBoxStopTime">
          <label class="form-control-placeholder">Stop Time</label>
        </div>
      </div>
      <div class="row">
        <div class="form-group col-6">
          <input placeholder=" " name="TextBoxHours" type="number" value="0" id="TextBoxHours" class="form-control">
          <label class="form-control-placeholder">Hours</label>
        </div>
        <div class="form-group col-6">
          <input placeholder=" " class="form-control" name="TextBoxMinutes" type="number" value="0" id="TextBoxMinutes">
          <label class="form-control-placeholder">Minutes</label>
        </div>
      </div>
<div class="row">
        <div class="form-group col-6">
          <input placeholder=" " name="TextBoxSmartSheetID" type="text" id="TextBoxSmartSheetID" class="form-control">
          <label class="form-control-placeholder">Smartsheet ID</label>
        </div>
        <div class="form-group col-6">
          <input placeholder=" " class="form-control" name="TextBoxReferenceDocumentFileName" type="text" id="TextBoxReferenceDocumentFileName">
          <label class="form-control-placeholder">Reference Document File Name</label>
        </div>
      </div>
<div class="form-group">
        <textarea placeholder=" " name="TextBoxNotes" rows="2" class="form-control" id="TextBoxNotes"></textarea>

        <label class="form-control-placeholder" >Note</label>
      </div>
      
<div class="form-group">
        <input name="TextBoxFile" type="text" id="TextBoxFile" placeholder=" " class="form-control">

        <label class="form-control-placeholder" >File</label>
      </div>
<div class="form-group">
        <label class="col-2" >Complete? </label>
  <input id="CheckboxComplete" type="checkbox" name="CheckboxComplete">
      </div>  
    </div>
  </div>
</div>

<div class="" ><div class="ui-dialog-buttonset">

<button type="button" id="ButtonSave" class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" style="font-weight:bold;height:30px;width:106px;">Submit</button>

<button type="button" id="ButtonCancel" class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" style="font-weight:bold;height:30px;width:106px;">Cancel</button>

</div></div>

</form>

  </div>

      <div id="man_page_selections-header" class="ui-mba-content-selection-header">
          <div class="ui-mba-content-selection-header-r1">
              <span id="man_page_selections-title" class="ui-mba-content-selection-header-r1-title"></span>
              <span class="ui-mba-content-selection-header-r1-controls mb-3">
                  <button title="Toggle Open" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only ui-mba-content-selection-header-r1-control header-r1-controls-btn-toggle-open d-lg-none"
                      role="button" aria-disabled="false">
                      <span class="ui-button-icon-primary ui-icon ui-icon-arrow"></span>
                      <span class="ui-button-text">Toggle Open</span>

                  </button>

              </span>

          </div>

      </div>

      <div id="man_page_selections-content" class="ui-mba-content-selection-content">
          <div id="man_page_selections" class="ui-mba-content-selection-content-list slick-slider slick-vertical">    
              <% if (r_db_1 != null)
                   foreach (MBA.Record r in r_db_1.records) { %>
              
                  <div class="ui-mba-content-selection-content-list-item slick-slide slick-current slick-active" data-slick-index="0" aria-hidden="false" tabindex="0" style="width: 240px;">
                      <a
                          href="#"
                          data-emp-id="<%= r.fields[0].value %>"
                          class="ui-mba-content-selection-content-list-item ui-button ui-widget ui-corner-all ui-button-text-only<%= ( preselected_empid_scrollmenu == true && (long) r.fields[0].value ==  Int64.Parse(e_id) ? " tab-selected" : "" ) %>"
                          role="button" aria-disabled="false" tabindex="0">
                          <span class="ui-button-text"><p><%= r.fields[1].value %></p></span>

                      </a>

                  </div>
              <% } %>   

          </div></div>

</div></div>


<div id="div-col-lg-10" class="<%= divcollg10_classes %>" >

  <div class="my-3 d-flex flex-row align-items-center justify-content-between mx-1"><h3><span id="h-content-disp-date-weekentries" class="h-content-disp-date"></span></h3><span>

<Spedmon:DetailList ID="validatelist" runat="server"></Spedmon:DetailList>

<button id="h-btn-hvest-prev-weekentries" class="ml-2 ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" type="button" role="button" aria-disabled="false"><span class="ui-button-text">&lt;</span></button><button id="h-btn-hvest-next-weekentries" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" type="button" role="button" aria-disabled="false"><span class="ui-button-text">&gt;</span></button></span></div>

<div id="top-tabswitch-wrap">
</div>

    <div id="clienttabs" class="h-100 mx-3" style="overflow-y:hidden" >

        <ul style="visibility:hidden">

            <li><a href = "#tab-demographics">Scheduled &amp; Recorded Time</a></li>

            <li><a href = "#tab-contact">Manage Favorites</a></li>

        </ul>

        <%/****************************
         * Demographics tab
         ****************************/%>

        <div id="tab-demographics" class="ui-tabs-panel ui-widget-content ui-corner-bottom">

            <div class="d-flex flex-column">
                <div id="weekentries-h-toolbar-one" class="my-3 d-flex flex-row align-items-center justify-content-between">

                    <h3><button id="main-new-addbutton" class="mr-4 my-2 btn ui-button addbutton ui-widget ui-corner-all ui-button-text-only bg-white" style="border: solid 1px #eee;font-size:28px"><i class="fas fa-plus text-dark"></i></button></h3>

                    <span>

                        <button id="h-btn-disp-mode-week-weekentries" class="btn bg-light ui-button ui-widget ui-corner-all ui-button-text-only" type="button" role="button" aria-disabled="false" style="border: solid 1px #eee;">
                            <span class="ui-button-text">Week</span>

                        </button>

                        <button class="btn bg-white ui-button ui-widget ui-corner-all ui-button-text-only" type="button" id="h-btn-disp-mode-day-weekentries" role="button" aria-disabled="false" style="border: solid 1px #eee;">
                            <span class="ui-button-text">Day</span>

                        </button>

                    </span>

                </div>

                <table id="hvest-table">

                    <thead><tr>

                        

                        <th data-weekday="0" class="day-selection-button px-4 py-3 bg-light ui-button-text-only text-center" id="day-selection-button-0" style="border-radius:6px 0 0 0">
                                <span>S</span>
                         </th>

                        <th data-weekday="1" class="day-selection-button px-4 py-3 bg-light ui-button-text-only text-center" id="day-selection-button-1">
                                <span>M</span>
                         </th>

                        <th data-weekday="2" class="day-selection-button px-4 py-3 bg-light ui-button-text-only text-center" id="day-selection-button-2">
                                <span>T</span>
                         </th>

                        <th data-weekday="3" class="day-selection-button px-4 py-3 bg-light ui-button-text-only text-center" id="day-selection-button-3">
                                <span>W</span>
                        </th>

                        <th data-weekday="4" class="day-selection-button px-4 py-3 bg-light ui-button-text-only text-center" id="day-selection-button-4">
                                <span>T</span>
                         </th>

                        <th data-weekday="5" class="day-selection-button px-4 py-3 bg-light ui-button-text-only text-center" id="day-selection-button-5">
                                <span>F</span>
                         </th>

                        <th data-weekday="6" class="day-selection-button px-4 py-3 bg-light ui-button-text-only text-center" id="day-selection-button-6" >
                                <span>S</span>
                         </th>

                         <th class="bg-light text-center px-4 py-3" style="border-radius:0 6px 0 0"></th>
                        

                    </tr></thead>
                    <tbody id="hvest-tbody-weekentries"></tbody> 

                    <tfoot><tr>

                        

                        <th data-weekday="0" class="px-4 bg-light ui-button-text-only text-center" style="border-radius:6px 0 0 0">
                                <span class="h-day-total-weekentries" id="h-su-total-weekentries" class="ui-button-text">0:00</span>
                         </th>

                        <th data-weekday="1" class="px-4 bg-light ui-button-text-only text-center" >
                                <span class="h-day-total-weekentries" id="h-m-total-weekentries" class="ui-button-text">0:00</span>
                         </th>

                        <th data-weekday="2" class="px-4 bg-light ui-button-text-only text-center" >
                                <span class="h-day-total-weekentries" id="h-t-total-weekentries" class="ui-button-text">0:00</span>
                         </th>

                        <th data-weekday="3" class="px-4 bg-light ui-button-text-only text-center" >
                                <span class="h-day-total-weekentries" id="h-w-total-weekentries" class="ui-button-text">0:00</span>
                        </th>

                        <th data-weekday="4" class="px-4 bg-light ui-button-text-only text-center" >
                                <span class="h-day-total-weekentries" id="h-th-total-weekentries" class="ui-button-text">0:00</span>
                         </th>

                        <th data-weekday="5" class="px-4 bg-light ui-button-text-only text-center" >
                                <span class="h-day-total-weekentries" id="h-fr-total-weekentries" class="ui-button-text">0:00</span>
                         </th>

                        <th data-weekday="6" class="px-4 bg-light ui-button-text-only text-center" >
                                <span class="h-day-total-weekentries" id="h-sa-total-weekentries" class="ui-button-text">0:00</span>
                         </th>

                         <th class="bg-light text-center px-4" style="border-radius:0 0 6px 0"><span id="h-week-hrs-total-weekentries" class="ui-button-text px-1">Total: 0:00</span></th>
                        

                    </tr></tfoot>

                </table>

            </div>

        </div>




        <%/****************************
         * Contact tab
         ****************************/%>
<div id="tab-contact" class="ui-tabs-panel ui-widget-content ui-corner-bottom h-100">

 <div id="iframe-container" class="col-12 col-lg-10 h-100">
     <iframe style="display:none"></iframe>
<span style="width:100%;display:inline-block;text-align:end;padding-right:12px;">
<button class="btn bg-white ui-spedmon-box-inline-ctrl ui-button ui-state-default ui-corner-all ui-button-text-only" id="toggle_manage_tasks" type="button" role="button" aria-disabled="false"><span class="ui-button-text">Tasks</span></button>
<button class="btn bg-white ui-spedmon-box-inline-ctrl ui-button ui-state-default ui-corner-all ui-button-text-only" id="toggle_manage_clients" type="button" role="button" aria-disabled="false"><span class="ui-button-text">Clients</span></button>

<script type="text/javascript">

  $('#toggle_manage_tasks').click(function() {
        $('iframe').remove();
        $('#iframe-container').append('<iframe style="margin: 4px; height:100%; width:100%" ' +
          'src="partial_timekeeper_admin_manage_favorite_tasks_for_employees_dragdrop.aspx?tkn=<%=tkn%>" />'
        );
  });

  $('#toggle_manage_clients').click(function() {
        $('iframe').remove();
        $('#iframe-container').append('<iframe style="margin: 4px; height:100%; width:100%" ' +
          'src="partial_timekeeper_admin_manage_favorite_clients_for_employees_dragdrop.aspx?tkn=<%=tkn%>" />'
        );
  });

</script>
</span>
  
 </div>


</div>


        </div>


</div></div>



<%/****************************
  * Scripts for options
  ****************************/%>
<script type="text/javascript">


$(function () {

  var $tkn             = '<%=tkn%>';

  var $orgID           = '';
  var $ownerID         = '';
  var $caseload        = $('#caseload');  //todo: refactor, get rid of this
  var $groups          = $('#groups');
  var $caseloadCol     = $('#caseloadcolumn');
  var $groupsCol       = $('#groupscolumn');

  // hide the modal
    $('#viewExpectedTreatmentsCont').hide();

    document.timekeeperSelectedEmpId = '<%= e_id %>';


    document.viewWeekStarting = $.datepicker.formatDate("yy/mm/dd", Date.today().moveToDayOfWeek(1).addDays(-8));
    document.viewEntriesDispMode = 'week';

    var fnSetDispModeDateAndUpdateRenderEntries = function () {
        document.viewEntriesDispMode = 'date';
        $("#h-btn-disp-mode-week-weekentries,#h-btn-disp-mode-day-weekentries").removeClass('bg-light').removeClass('bg-white');
        $("#h-btn-disp-mode-day-weekentries").addClass('bg-light');
        $("#h-btn-disp-mode-week-weekentries").addClass('bg-white');
        fnUpdateAndRenderHvDayViewEntries(null, null, 1 /* monday */);
    };

    $("#h-btn-disp-mode-day-weekentries").click(fnSetDispModeDateAndUpdateRenderEntries);

    var fnSetDispModeWeekAndUpdateRenderEntries = function () {
        document.viewEntriesDispMode = 'week';
        $("#h-btn-disp-mode-week-weekentries,#h-btn-disp-mode-day-weekentries").removeClass('bg-light').removeClass('bg-white');
        $("#h-btn-disp-mode-week-weekentries").addClass('bg-light');
        $("#h-btn-disp-mode-day-weekentries").addClass('bg-white');
        fnUpdateAndRenderHvDayViewEntries(null, null, 1 /* monday */);
    };

    $("#h-btn-disp-mode-week-weekentries").click(fnSetDispModeWeekAndUpdateRenderEntries);

    var timeFieldStore;

    document.submitUpdatedTimefields = function( rownum ) {
      //console.log( rownum );
      //console.log( timeFieldStore[ 'row' + rownum ] );
      var vvv = [];
      var iter_o = 0;
      //debugger;
      $.each( timeFieldStore[ 'row' + rownum ] , function(iter, obj) {

         var obj_2 = obj;
         obj_2.day = iter_o;
         obj_2.entry =  $('#weekview-time-field-' + 
                     ( obj.day + 1 ), $('#hvest-table tbody tr')[rownum] 
                     ).val();
         obj_2.week_starting_monday = $('#addentry-date-val').val();
         obj_2.taskID = obj.taskID_orgID.match('[0-9]*')[0];
         obj_2.orgID = obj.taskID_orgID.match('[0-9]*')[1];
         obj_2.emp_id = document.timekeeperSelectedEmpId;
         vvv.push(
           obj_2
         );

         iter_o++;
        
      });

      $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,"Saving...",2);
      $.get('timekeeper_taskentrycalendarevents.asmx/saveTaskWeekHours?tkn=' + $.spedmonWebUI.token +
            '&daysHoursInfo=' + encodeURI( JSON.stringify (vvv) ) +
            '&emp_id=' + document.timekeeperSelectedEmpId
      ).done(function(response_content, str_status) {

          if (str_status == 'success')
            $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.SUCCESS, "ok", 2);
          else
            $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.CRITICAL, "error!", 2);

          fnSetDispModeWeekAndUpdateRenderEntries();

        });;
      
    };




    var timeEntryStore;

    document.editTimeEntryViaSaveform = function( te_id ) {   //debugger;

      var hhh = $('#viewModalAddEntryHtml').html();
      var $hhh = $(hhh);

      $hhh =
        $hhh.attr(
          'id', 'viewModalEditEntry'
          ).attr(
          'data-action', 'timekeeper_taskentrycalendarevents.asmx/updateTimeEntry'
          );

      //debugger;
      $hhh.show().dialog(
            {
                width: ($(window).width() * 0.6)
                , height: ($(window).height() * 0.8)
                , title: '<h3>Edit Time Entry</h3>'
                , modal: true
                , show: {
                    effect: 'slide',
                    // attach callback to "ok" button to save entered service details answers
                    complete: function () {
                        //$modalCont.html(rd.content);
                    }
                }
                , hide: {
                    effect: 'slide'
                    , direction: 'left'
                }
            });

      var t_e = timeEntryStore[ te_id ];

      $('#viewModalEditEntry').append('<input type="hidden" name="te_id" value="' + te_id + '" />');

      $('#viewModalEditEntry #TextBoxNotes').val( t_e.note );

      $('#viewModalEditEntry #TextBoxMinutes').val( t_e.minutes );

      //var  obj.taskID_orgID.match('[0-9]*')[0]

      var taskID = t_e.taskID_orgID.match('[0-9]*')[0];
      var orgID = t_e.taskID_orgID.match(/[0-9]*/g)[2];

      //debugger;

      $('#viewModalEditEntry #saveform-option-task-' + taskID).attr( 'selected','selected' );

      $('#viewModalEditEntry #saveform-option-client-' + orgID).attr( 'selected','selected' );

      $('#viewModalEditEntry .ui-dialog-buttonset button').removeAttr('disabled');

      $('#viewModalEditEntry #ButtonCancel').click(function() { 
        $('#viewModalEditEntry').dialog('close');
        setTimeout(function() {
          $('#viewModalEditEntry').remove();
          //$('#viewModalAddEntry').remove();
        }, 1100); 
      });

      $('#viewModalEditEntry #ButtonSave').click(function() {

        $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,"Saving",2);

        $.get(
          $('form#viewModalEditEntry').attr('data-action') +
          '?' +
          $('form#viewModalEditEntry').serialize()
        ).done(function(response_content, str_status) {

          if (str_status == 'success')  {

 
            $('#viewModalEditEntry').dialog('close');
            setTimeout(function() {
            $('#viewModalEditEntry').remove();
            //$('#viewModalAddEntry').remove();

            $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.SUCCESS, "ok", 2);

            if ( document.viewEntriesDispMode == 'date' )
              fnUpdateAndRenderHvDayViewEntries(null, null, document.weekday_selected);
            else
              fnSetDispModeWeekAndUpdateRenderEntries();

            }, 1100);

            
          }
          else {
            $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.CRITICAL, "error!", 2);
            alert('unknown error');
          }

        });
 
      });

    };

    document.delTimeEntry = function( te_id ) {

      $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,"Deleting",2);

      var t_e = timeEntryStore[ te_id ];

      $.get(
          
          'timekeeper_taskentrycalendarevents.asmx/deleteTimeEntry?te_id=' + te_id + '&tkn=' + $.spedmonWebUI.token
      ).done(function(response_content, str_status) {  //debugger;

          if (str_status == 'success')  {

 
            $('#viewModalEditEntry').dialog('close');
            setTimeout(function() {
            $('#viewModalEditEntry').remove();
            //$('#viewModalAddEntry').remove();

            $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.SUCCESS, "ok", 2);

            fnUpdateAndRenderHvDayViewEntries(null, null, document.weekday_selected);

            }, 1100);

            
          }
          else {
            $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.CRITICAL, "error!", 2);
            alert('unknown error');
          }

        });

    };


    var viewModalAddEntryOpen = function( ) {
      var hhh = $('#viewModalAddEntryHtml').html();
      var $hhh = $(hhh);

      $hhh =
        $hhh.attr(
          'id', 'viewModalAddEntry'
          );

      $hhh.show().dialog(
            {
                width: ($(window).width() * 0.6)
                , height: ($(window).height() * 0.8)
                , title: '<h3>Add Time Entry</h3>'
                , modal: true
                , show: {
                    effect: 'slide',
                    // attach callback to "ok" button to save entered service details answers
                    complete: function () {
                        //$modalCont.html(rd.content);
                    }
                }
                , hide: {
                    effect: 'slide'
                    , direction: 'left'
                }
            });

      $('#viewModalAddEntry .ui-dialog-buttonset button').removeAttr('disabled');

      $('#viewModalAddEntry #ButtonCancel').click(function() { 
        $('#viewModalAddEntry').dialog('close');
        setTimeout(function() {
          $('#viewModalEditEntry').remove();
          //$('#viewModalAddEntry').remove();
        }, 1100); 
      });

      $('#viewModalAddEntry #ButtonSave').click(function() {

        $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,"Saving",2);

        $.get(
          $('form#viewModalAddEntry').attr('data-action') +
          '?' +
          $('form#viewModalAddEntry').serialize()
        ).done(function(response_content, str_status) {

          if (str_status == 'success')  {

 
            $('#viewModalAddEntry').dialog('close');
            setTimeout(function() {
            $('#viewModalAddEntry').remove();

            $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.SUCCESS, "ok", 2);

            if ( document.viewEntriesDispMode == 'date' )
              fnUpdateAndRenderHvDayViewEntries(null, null, document.weekday_selected);
            else
              fnSetDispModeWeekAndUpdateRenderEntries();
              

            }, 1100);

            
          }
          else {
            $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.CRITICAL, "error!", 2);
            alert('unknown error');
          }

        });
 
      });

    };


    $('#main-new-addbutton').click(viewModalAddEntryOpen);

    var fnUpdateAndRenderHvDayViewEntries = function (e, el, weekday_selected) {

      $('.tipso, .tipso_bubble').remove();

      if ( typeof(weekday_selected) == 'undefined' ) {
        weekday_selected = JSON.parse($(this).attr('data-weekday')  );
      }

      document.weekday_selected = weekday_selected;

      var get_url = 'timekeeper_taskentrycalendarevents.asmx/fetchScheduledAndRecordedObjs' + '?tkn=' + $.spedmonWebUI.token +
        '&empid=' + document.timekeeperSelectedEmpId + '&dispmode=' + document.viewEntriesDispMode + '&inclFormInfo=1' +
                            '&date=' +
                            $.datepicker.formatDate(
                              "yy/M/d", (new Date(document.viewWeekStarting)
                              ).addDays( weekday_selected )
            );

      $("#addentry-ted-id").val('');

      $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,"Retrieving...",2);

      $.get( get_url ).done(function(response_content, str_status){


                        $(".day-selection-button").removeClass('weekday-selected');

                        //var dd = JSON.parse(response_content.message)[0];
                        var dd = response_content[0];


                        if ( ( typeof(dd.all_totals) !== 'undefined' && dd.all_totals[0]) || ( typeof(dd.all_totals_recorded) !== 'undefined' && dd.all_totals_recorded[0]) )
                          $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.SUCCESS, "ok", 2);

                        else {
                          $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.CRITICAL, "error!", 2);
                          return;
                        }


                        $('#DropDownListEmployer').empty();
                        $('#ListBoxFavoriteTaskTimeEntry').empty();
                        $('#ListBoxFavoriteClientTimeEntry').empty();

                        //debugger;
                        if ( dd.te_saveform_render_info[0].employers )
                          $.each( dd.te_saveform_render_info[0].employers, function(iter, obj) {
                            $('#DropDownListEmployer').append( '<option value="' + obj.org_id + '" >' + obj.org_name + '</option>' );
                          });
                        if ( dd.te_saveform_render_info[0].employers && ( dd.te_saveform_render_info[0].employers.length > 1) )
                          $('#DropDownListEmployer').parent().css('display', 'inline-block');
                        else
                          $('#DropDownListEmployer').parent().css('display', 'none');

                        if ( dd.te_saveform_render_info[0].tasks )
                          $.each( dd.te_saveform_render_info[0].tasks, function(iter, obj) {
                            $('#ListBoxFavoriteTaskTimeEntry').append( '<option id="saveform-option-task-' + obj.id + '" value="' + obj.id + '" >' + obj.name + '</option>' );
                          });


                        if ( dd.te_saveform_render_info[0].clients )
                          $.each( dd.te_saveform_render_info[0].clients, function(iter, obj) {
                            $('#ListBoxFavoriteClientTimeEntry').append( '<option id="saveform-option-client-' + obj.id + '" value="' + obj.id + '" >' + obj.name + '</option>' );
                          });
                        $('#ListBoxFavoriteClientTimeEntry').prepend('<option value="">No client</option>');

                        //if ( dd.te_saveform_render_info[0].clients && ( dd.te_saveform_render_info[0].clients.length > 1) )
                          //$('#ListBoxFavoriteClientTimeEntry').parent().css('display', 'inline-block');
                        //else
                        //  $('#ListBoxFavoriteClientTimeEntry').parent().css('display', 'none');


                        if ( dd.all_totals_recorded && dd.all_totals_recorded[0].ted_id_dispdate )
                          $("#addentry-ted-id").val( dd.all_totals_recorded[0].ted_id_dispdate );

                        if ( dd.all_totals && dd.all_totals[0].ted_id_dispdate )
                          $("#addentry-ted-id").val( dd.all_totals[0].ted_id_dispdate );

                        $('#addentry-tkn').val( $.spedmonWebUI.token );

                        if (document.viewEntriesDispMode == 'date')
                          $("#day-selection-button-" + weekday_selected).addClass('weekday-selected');

                        if (document.viewEntriesDispMode == 'week') {

                              if ($('#hvest-table thead th').length == 8) {
                                $('#hvest-table thead th').first().css('border-radius', 'none');
                                $('#hvest-table tfoot th').first().css('border-radius', 'none');
                                $('#hvest-table thead tr').prepend('<th class="bg-light"></th>');
                                $('#hvest-table tfoot tr').prepend('<th class="bg-light"></th>');
                                $('#hvest-table thead th').first().css('border-radius', '6px 0 0 0');
                                $('#hvest-table tfoot th').first().css('border-radius', '0px 0 0 6px');

                              } 

                            $('#hvest-table thead').removeClass('dayview');

                            //var dd = response_content[0];

                            $('#h-week-hrs-total-weekentries').html(
                              ( dd.all_totals_recorded[0].hoursMinutesRecordedThisWeek ? dd.all_totals_recorded[0].hoursMinutesRecordedThisWeek : '00:00'  ) + ' - recorded<br/>' +
                              ( dd.all_totals_recorded[0].hoursMinutesScheduledThisWeek ? dd.all_totals_recorded[0].hoursMinutesScheduledThisWeek : '00:00' ) + ' - scheduled'
                            );
                            $('.h-content-disp-date').html(
                              $.datepicker.formatDate("DD", (new Date(dd.all_totals_recorded[0].dispdate))) + ' &#8226; ' +
                              $.datepicker.formatDate("MM d, yy", (new Date(dd.all_totals_recorded[0].dispdate)))
                            );

                            $('#addentry-date-val').val(
                              $.datepicker.formatDate(
                                "yy-MM-dd",
                                 (new Date(dd.all_totals_recorded[0].dispdate))
                              )
                            );

                            $('.h-day-total-weekentries').text('0:00');


                            $.each(dd.all_totals_recorded[0].scheduled_and_recorded_totals_by_day, function (iter, obj) {
                                switch (obj.daynum) {
                                    case 2:
                                        $('#h-m-total-weekentries').html(
                                          ( obj.hoursMinutesRecorded ? obj.hoursMinutesRecorded : '00:00' ) + ' - recorded<br/>' +

                                          ( obj.hoursMinutesScheduled ? obj.hoursMinutesScheduled : '00:00' ) + ' - scheduled'

                                        ); break;
                                    case 3:
                                        $('#h-t-total-weekentries').html(
                                          ( obj.hoursMinutesRecorded ? obj.hoursMinutesRecorded : '00:00' ) + ' - recorded<br/>' +

                                          ( obj.hoursMinutesScheduled ? obj.hoursMinutesScheduled : '00:00' ) + ' - scheduled'

                                        ); break;
                                    case 4:
                                        $('#h-w-total-weekentries').html(
                                          ( obj.hoursMinutesRecorded ? obj.hoursMinutesRecorded : '00:00' ) + ' - recorded<br/>' +

                                          ( obj.hoursMinutesScheduled ? obj.hoursMinutesScheduled : '00:00' ) + ' - scheduled'

                                        ); break;
                                    case 5:
                                        $('#h-th-total-weekentries').html(
                                          ( obj.hoursMinutesRecorded ? obj.hoursMinutesRecorded : '00:00' ) + ' - recorded<br/>' +

                                          ( obj.hoursMinutesScheduled ? obj.hoursMinutesScheduled : '00:00' ) + ' - scheduled'

                                        ); break;
                                    case 6:
                                        $('#h-fr-total-weekentries').html(
                                          ( obj.hoursMinutesRecorded ? obj.hoursMinutesRecorded : '00:00' ) + ' - recorded<br/>' +

                                          ( obj.hoursMinutesScheduled ? obj.hoursMinutesScheduled : '00:00' ) + ' - scheduled'

                                        ); break;
                                    case 7:
                                        $('#h-sa-total-weekentries').html(
                                          ( obj.hoursMinutesRecorded ? obj.hoursMinutesRecorded : '00:00' ) + ' - recorded<br/>' +

                                          ( obj.hoursMinutesScheduled ? obj.hoursMinutesScheduled : '00:00' ) + ' - scheduled'

                                        ); break;
                                    case 1:
                                        $('#h-su-total-weekentries').html(
                                          ( obj.hoursMinutesRecorded ? obj.hoursMinutesRecorded : '00:00' ) + ' - recorded<br/>' +

                                          ( obj.hoursMinutesScheduled ? obj.hoursMinutesScheduled : '00:00' ) + ' - scheduled'

                                        ); break;
                                }

                            });

                            $('#hvest-tbody-weekentries').empty();

                            timeFieldStore = {};
               
                            $.each(dd.recorded_week_glance, function (iter, obj) {

                                //var tr = '<tr style="border:1px solid #efefef;">';

                                //debugger;

                                var tr = '<tr' + (
                                                    obj.organizationName ? (' class="indented-row indented-row-taskID-' + obj.taskID_orgID.match('[0-9]*')[0] + '"' ) : ''
                                                  ) +
                                         ' style="border-bottom:1px solid #efefef;">';

                                tr += '<td ' + (obj.organizationName ? (' class="first-cell-indented-row text-right pl-3 pr-5"' ) : '') + '>' +

                                obj.taskName + (obj.organizationName ? ('  &#8212;<br/>' + obj.organizationName) : '') +

/*
                                '<br/><span class="item-description-subtitle">Lorem Ipsum - <i>Text description</i></span>' +
*/

                                '</td>';

                                var timeFieldStoreRow = {};
                                
                                for (var iter_b=0, iter_b_ii=0; iter_b<7 /* && typeof(obj.blob[iter_b_ii]) !== 'undefined' */; iter_b++ ) {
                                    /* https://stackoverflow.com/questions/2703102/typeof-undefined-vs-null */
                                  // TODO; this iter_b and iter_b_ii stuff is just getting worse and worse.
                              
                                    var blob_i = obj.blob[iter_b_ii];
                                  
if (typeof(obj.blob[iter_b_ii]) !== 'undefined' && typeof(blob_i.daynum) !== 'undefined' && blob_i.daynum - 1 == iter_b && blob_i.breakdown.day_entries[0].te_id ) {


    tr += '<td class="py-4 text-center' + ( ( iter_b == 0 || iter_b == 6 ) ? ' weekend-cell' : ''  ) + '"><div class="weekview-day-cell">';

    if (blob_i.breakdown.day_entries.length < 2 && ! (blob_i.SpecifyStartStopTime) )
      var editable_hours = true;
    else
      var editable_hours = false;

    if (!(editable_hours))
      tr += '<a href="#" onclick="document.fnSwitchToDayViewForDaynumEntries(' +
            ( blob_i.daynum - 1 ) + ',' + "'" + obj.taskID_orgID + "'" + ')">';

    if (blob_i.breakdown.day_entries.length) {
 
        tr += '<span class="text-primary td-a-tipso" data-tipso="<ul>';


        $.each(blob_i.breakdown.day_entries, function(d_e_i, d_e_o) {
            tr += '<li>' + d_e_o.title + ' - ' + d_e_o.hoursMinutes + '</li>';
        });

        tr += '</ul>" data-tipso-title="' + blob_i.countRecorded + ' events recorded"  ' + 
            '>';
    }

    tr += '<input ' + (editable_hours == false ? 'readonly="readonly"' : '' ) + ' id="weekview-time-field-' + blob_i.daynum + '" class="weekview-time-field" type="text" value="' + blob_i.hoursMinutesRecorded + '" />';

    if (blob_i.breakdown.day_entries.length)
      tr += '</span>';

    if (!(editable_hours))
      tr += '</a>';

    if ((blob_i.hoursMinutesScheduled) && (blob_i.hoursMinutesRecorded))
        tr += '<br/>';

    if (blob_i.breakdown.day_scheduled.length) {
        tr += '<a href="#" class="text-primary td-a-tipso" data-tipso="<ul>';

        $.each(blob_i.breakdown.day_scheduled, function(d_e_i, d_e_o) {
            tr += '<li>' + d_e_o.taskName + ' - ' + d_e_o.minutes + ' minutes</li>';
        });

        tr += '</ul>" data-tipso-title="' + blob_i.countScheduled + ' events scheduled" onclick="document.fnSwitchToDayViewForDaynumEntries(' +
            ( blob_i.daynum - 1 ) + ',' + "'" + obj.taskID_orgID + "'" + ')">';
    }

    if (blob_i.hoursMinutesScheduled) tr += blob_i.hoursMinutesScheduled ;

    if (blob_i.breakdown.day_scheduled.length)
        tr += '</a>';


    tr += '</div></td>';

    iter_b_ii++;

    timeFieldStoreRow[ 'day' + iter_b /* blob_i.daynum */ ] =
      {
        day: blob_i.daynum,
        te_id: blob_i.breakdown.day_entries[0].te_id,
        taskID_orgID: obj.taskID_orgID,
        ted_id: blob_i.ted_id
      };

    //debugger;

}  else {

    //tr += '<td class="py-4 text-center">0</td>';
    tr += '<td class="py-4 text-center' + ( ( iter_b == 0 || iter_b == 6 ) ? ' weekend-cell' : ''  ) + '"><div class="weekview-day-cell">';
    tr += '<span><input ' + ' id="weekview-time-field-' + ( iter_b + 1 )  + '" class="weekview-time-field" type="text" value="0:00" /></span>';
    tr += '<br/>';
    tr += '<span>0:00</span>';
    tr += '</div></td>';

    //debugger;


    //if (blob_i && blob_i.ted_id)

    timeFieldStoreRow[ 'day' + iter_b ] =
      {
        day: iter_b,
        taskID_orgID: obj.taskID_orgID,
    };

    //iter_b_ii++;

    //debugger;

  }

                                }

                                 tr += '<td class="text-center" colspan="2"><button class="mx-1 btn ui-button ui-widget ui-corner-all ui-button-text-only bg-white  btn-timeentry-save" onclick="document.submitUpdatedTimefields(' + iter + ')" ><i class="fas fa-save text-dark"></i></button></td>';


                                timeFieldStore[ 'row' + iter ] = timeFieldStoreRow;

                                $('#hvest-tbody-weekentries').append(tr + '</tr>');

                                $('.td-a-tipso').tipso({hideDelay:0, background: '#fff', color:'#333'});



                            });

                            $('.indented-row').each(function(){
                              var p = $(this).prev();
                              if ( !(p.hasClass('indented-row') ) ) {
                                p.addClass('w-expander-button');
                                var cell = p.children().first();
                                cell.append(
                                  '<span class="weekview-expander-button toggle-click ui-spedmon-gradient-rounded-but-md"><i class="fas fa-angle-down"></i></span>'
                                );

                                var rowsSelector = $(this).attr('class').match('indented-row-taskID-[0-9]*')[0];
                                
                                $('.weekview-expander-button', cell).click(function(){
                                  var p_s = p;
                                  //debugger;
                                  $('.indented-row.' + rowsSelector).toggleClass('d-none');
                                  
                                });
                              }

                            });


                        } else {

                            //$('#hvest-table th').first().css('display','none');
                            //$('#hvest-table th').first().css('border-radius', '6px 0 0 0');

                            if ($('#hvest-table thead th').length == 9) {
                                $('#hvest-table thead th').first().remove();
                                $('#hvest-table tfoot th').first().remove();
                                $('#hvest-table thead th').first().css('border-radius', '6px 0 0 0');
                                $('#hvest-table tfoot th').first().css('border-radius', '0px 0 0 6px');

                            } 

                            $('#hvest-table thead').addClass('dayview');

                            //var dd = response_content[0];

                            $('#h-week-hrs-total-weekentries').html(
                              ( dd.all_totals[0].hoursMinutesScheduled ? dd.all_totals[0].hoursMinutesScheduled : '00:00' ) + ' - scheduled<br/>' +
                              ( dd.all_totals[0].hoursMinutesRecorded  ? dd.all_totals[0].hoursMinutesRecorded  : '00:00' ) + ' - recorded'
                            );
                            $('.h-content-disp-date').html(
                              $.datepicker.formatDate("DD", (new Date(dd.all_totals[0].dispdate))) + ' &#8226; ' +
                              $.datepicker.formatDate("MM d, yy", (new Date(dd.all_totals[0].dispdate)))
                            );

                            $('#addentry-date-val').val(
                              $.datepicker.formatDate(
                                "yy-MM-dd",
                                 (new Date(dd.all_totals[0].dispdate))
                              )
                            );

                            $('.h-day-total-weekentries').text('0:00');

                            timeEntryStore = {};

                            $.each(dd.all_totals[0].totals_by_day, function (iter, obj) {
                                switch (obj.daynum) {
                                    case 2:
                                        $('#h-m-total-weekentries').html(
                                          ( obj.hoursMinutesRecorded ? obj.hoursMinutesRecorded : '00:00' ) + ' - recorded<br/>' +

                                          ( obj.hoursMinutesScheduled ? obj.hoursMinutesScheduled : '00:00' ) + ' - scheduled'

                                        ); break;
                                    case 3:
                                        $('#h-t-total-weekentries').html(
                                          ( obj.hoursMinutesRecorded ? obj.hoursMinutesRecorded : '00:00' ) + ' - recorded<br/>' +

                                          ( obj.hoursMinutesScheduled ? obj.hoursMinutesScheduled : '00:00' ) + ' - scheduled'

                                        ); break;
                                    case 4:
                                        $('#h-w-total-weekentries').html(
                                          ( obj.hoursMinutesRecorded ? obj.hoursMinutesRecorded : '00:00' ) + ' - recorded<br/>' +

                                          ( obj.hoursMinutesScheduled ? obj.hoursMinutesScheduled : '00:00' ) + ' - scheduled'

                                        ); break;
                                    case 5:
                                        $('#h-th-total-weekentries').html(
                                          ( obj.hoursMinutesRecorded ? obj.hoursMinutesRecorded : '00:00' ) + ' - recorded<br/>' +

                                          ( obj.hoursMinutesScheduled ? obj.hoursMinutesScheduled : '00:00' ) + ' - scheduled'

                                        ); break;
                                    case 6:
                                        $('#h-fr-total-weekentries').html(
                                          ( obj.hoursMinutesRecorded ? obj.hoursMinutesRecorded : '00:00' ) + ' - recorded<br/>' +

                                          ( obj.hoursMinutesScheduled ? obj.hoursMinutesScheduled : '00:00' ) + ' - scheduled'

                                        ); break;
                                    case 7:
                                        $('#h-sa-total-weekentries').html(
                                          ( obj.hoursMinutesRecorded ? obj.hoursMinutesRecorded : '00:00' ) + ' - recorded<br/>' +

                                          ( obj.hoursMinutesScheduled ? obj.hoursMinutesScheduled : '00:00' ) + ' - scheduled'

                                        ); break;
                                    case 1:
                                        $('#h-su-total-weekentries').html(
                                          ( obj.hoursMinutesRecorded ? obj.hoursMinutesRecorded : '00:00' ) + ' - recorded<br/>' +

                                          ( obj.hoursMinutesScheduled ? obj.hoursMinutesScheduled : '00:00' ) + ' - scheduled'

                                        ); break;
                                }

                            });

                            $('#hvest-tbody-weekentries').empty();


                            $.each(dd.listings_selected_day[0].l_s_d, function (iter, obj) {

                                  //debugger;
                                  if ( typeof( obj.taskRecordedInfo ) === 'undefined' )
                                    return true;

                                  $.each(obj.taskRecordedInfo, function(iter_tri, obj_tri) {
                                    timeEntryStore[ obj_tri.te_id ] = obj_tri;
                                  });


                                  $('#hvest-tbody-weekentries').append('<tr class="tr-title-' + obj.taskID +
                                    (obj.recordedTaskTitle ? ' indented-row indented-row-tr-title-' + obj.taskID : '' ) +

                                    '" style="border-bottom:1px solid #efefef;" ><td colspan=3  class="' +
                                     
                                    (obj.recordedTaskTitle ? 'first-cell-indented-row text-right pl-3 pr-5 ' : '' ) + 'py-3"' +
                                    '>' +

                                    (obj.recordedTaskTitle ? obj.recordedTaskTitle : obj.taskName /* ('<b>' +obj.taskName + '</b>') */ )  + (obj.organizationName ? ( '  &#8212;  ' +  obj.organizationName ) : '' ) +
/*
                                    '<br/><span class="item-description-subtitle">Lorem Ipsum - <i>Text description</i></span>' +
*/
                                    '</td><td colspan="2"></td><td class="text-center">' + (obj.recordedMinutesTotal ? obj.hoursMinutesRecordedTotal + ' - recorded' : '' ) +
                                ( obj.scheduledMinutesTotal && obj.recordedMinutesTotal ? '<br/>' : '' ) +
                                (obj.scheduledMinutesTotal ? obj.hoursMinutesScheduledTotal + ' - scheduled' : '' ) +
                                    '<!--' + obj.id + '--> ' + '</td>' +
                                '<td class="text-center" colspan="2">' + 
                                  //'<button class="mx-1 btn ui-button ui-widget ui-corner-all ui-button-text-only bg-white">' +
                                  //'<i class="fas fa-clock text-dark"></i> Start</button>' +

                                  ( obj.taskRecordedInfo.length > 1 ? '' : // TODO: rm this conditional, implement fa-plus below
                                  
                                  '<button class="mx-1 btn ui-button ui-widget ui-corner-all ui-button-text-only bg-white  btn-timeentry-edit"' +
                                  ( obj.taskRecordedInfo.length == 1 ? ' onclick="document.editTimeEntryViaSaveform(' + obj.taskRecordedInfo[0].te_id + ')" ' : '' ) +
                                  '><i class="fas ' + ( obj.taskRecordedInfo.length > 1 ? 'fa-plus' /* TODO */ : 'fa-edit' ) + ' text-dark"></i></button>' +

                                  '<button class="mx-1 btn ui-button ui-widget ui-corner-all ui-button-text-only bg-white  btn-timeentry-edit"' +
                                  ( obj.taskRecordedInfo.length == 1 ? ' onclick="document.delTimeEntry(' + obj.taskRecordedInfo[0].te_id + ')" ' : '' ) +
                                  '><i class="fas ' + 'fa-trash'  + ' text-dark"></i></button>'

                                  ) +

                                  

                                  '</td>' +
                                      '</tr>');

                                if ( obj.taskRecordedInfo.length > 1 )
                                  $.each(obj.taskRecordedInfo, function(iter_tri, obj_tri) {
                                    if ( obj_tri.minutes !== "0")
                                      $('#hvest-tbody-weekentries').append(
                                        '<tr class="tr-title-' + obj.taskID +
                                        ' indented-row indented-row-tr-title-' + obj.taskID +
                                        '" style="border-bottom:1px solid #efefef;" ><td colspan=3  class="' +
                                        'first-cell-indented-row text-right pl-3 pr-5 py-3">' +

                                      (obj_tri.recordedTaskTitle ? obj_tri.recordedTaskTitle : obj.taskName /* ('<b>' +obj.taskName + '</b>') */ )  + (obj.organizationName ? ( '  &#8212;  ' +  obj.organizationName ) : '' ) +

                                      '</td><td colspan="2"></td><td class="text-center">' + obj_tri.hourMinutes + ' - recorded' +

                                      '</td>' +
                                '<td class="text-center" colspan="2">' +

                                  // '<button class="mx-1 btn ui-button ui-widget ui-corner-all ui-button-text-only bg-white"' +
                                  // '><i class="fas fa-clock text-dark"></i> Start</button>' +

                                  '<button class="mx-1 btn ui-button ui-widget ui-corner-all ui-button-text-only bg-white  btn-timeentry-edit"' +
                                  ' onclick="document.editTimeEntryViaSaveform(' + obj_tri.te_id + ')" ' +
                                  '><i class="fas fa-edit text-dark"></i></button>' +

                                  '<button class="mx-1 btn ui-button ui-widget ui-corner-all ui-button-text-only bg-white  btn-timeentry-edit"' +
                                  ' onclick="document.delTimeEntry(' + obj_tri.te_id + ')" '  +
                                  '><i class="fas ' + 'fa-trash'  + ' text-dark"></i></button>' +

                                  '</td>' +
                                      '</tr>'

                                    );
                                  
                                });

                            });

                            //$('.btn-timeentry-edit').click(viewModalAddEntryOpen);

                            $('.indented-row').each(function(){
                              var p = $(this).prev();
                              if ( !(p.hasClass('indented-row') ) ) {
                                p.addClass('w-expander-button');
                                var cell = p.children().first();
                                cell.append(
                                  '<span class="dayview-expander-button toggle-click ui-spedmon-gradient-rounded-but-md"><i class="fas fa-angle-down"></i></span>'
                                );

                                var rowsSelector = p.attr('class').match('tr-title-[0-9]*')[0];
                                
                                $('.dayview-expander-button', cell).click(function(){
                                  var p_s = p;
                                  //debugger;
                                  $('.indented-row.' + rowsSelector).toggleClass('d-none');
                                  
                                });
                              }

                            }); 


                        }

                        });
    };


    $('.day-selection-button').click(function (arg1, arg2) {

        var tttt = this;

        document.viewEntriesDispMode = 'date';
        $("#h-btn-disp-mode-week-weekentries,#h-btn-disp-mode-day-weekentries").removeClass('bg-light').removeClass('bg-white');
        $("#h-btn-disp-mode-day-weekentries").addClass('bg-light');
        $("#h-btn-disp-mode-week-weekentries").addClass('bg-white');

        fnUpdateAndRenderHvDayViewEntries.call(tttt, arg1, arg2);  // lol
    });

    document.fnSwitchToDayViewForDaynumEntries = function(daynum, highlighted_rows) {

        document.viewEntriesDispMode = 'date';
        $("#h-btn-disp-mode-week-weekentries,#h-btn-disp-mode-day-weekentries").removeClass('bg-light').removeClass('bg-white');
        $("#h-btn-disp-mode-day-weekentries").addClass('bg-light');
        $("#h-btn-disp-mode-week-weekentries").addClass('bg-white');

        //debugger;

        fnUpdateAndRenderHvDayViewEntries(null, null, daynum);

        setTimeout(function () {
          $(".tr-title-" + highlighted_rows).addClass('alert-warning');
        }, 750);
    }

  $('#h-btn-hvest-prev-weekentries').click(function() {
    document.viewWeekStarting = $.datepicker.formatDate("yy/M/d", (new Date(document.viewWeekStarting)).addDays( -7 ) );
    fnUpdateAndRenderHvDayViewEntries(null, null, 1 /* monday */);
  });

  $('#h-btn-hvest-next-weekentries').click(function() {

    document.viewWeekStarting = $.datepicker.formatDate("yy/M/d", (new Date(document.viewWeekStarting)).addDays( 7 ) );
    fnUpdateAndRenderHvDayViewEntries( null, null, 1 /* monday */);
  });


  $('#man_page_selections').slick(
        {
            vertical: true, slidesToShow: 9.5, slidesToScroll: 9,
            infinite: false, draggable: false, touchMove: false, swipe: false, swipeToSlide: false,
            cssEase: 'linear', useTransform: false,
            prevArrow: '<button class="slick-prev slick-arrow rounded-circle slick-disabled" type="button"' +
                'style = "display: inline-block;" >^</button>',
            nextArrow: '<button class="slick-next slick-arrow rounded-circle slick-disabled" type="button"' +
                'style = "display: inline-block;transform: rotate(180deg);" >^</button>'
        }
  );

  $('.ui-mba-content-selection-content-list-item a').click(function () {
        //$('iframe')[0].contentWindow.$('#groups-search-term').val($('.ui-button-text', $(this)).text()).trigger('keyup');
        document.timekeeperSelectedEmpId = $(this).attr('data-emp-id');
        $('.ui-mba-content-selection-content-list-item a').removeClass('tab-selected');
        $(this).addClass('tab-selected');
        fnUpdateAndRenderHvDayViewEntries(null, null, 1 /* monday */);
        let cw = $('#iframe-container iframe')[0].contentWindow;
        let gst = $(cw).find('#groups-search-term') 
        if (typeof gst == 'undefined') return;
        $(gst).val( $('.ui-button-text', $(this)).text()).trigger('keyup');
        //$('#iframe-container iframe')[0].contentWindow.$('#groups-search-term').val($('.ui-button-text', $(this)).text()).trigger('keyup');

  });


    $("ul.ui-tabs-nav").detach().attr('id', 'top-tabswitch').addClass('top-tabswitch').prependTo('#top-tabswitch-wrap').removeAttr('style');

    

    <% if (preselected_empid_scrollmenu) { %>

    setTimeout(
        fnSetDispModeWeekAndUpdateRenderEntries,
        1100
    );

    <% } %>

   <%
    if (this.isDelinquentDTKUser) {
    %>

    var warning_out_hidden = "<%=this.warning_out_hidden %>";
    var lastDayOfSchedule = "<%=this._lastDayOfSchedule %>";
    var e_id = "<%=this.e_id %>";
    var $msgWarningOut = ' <%=this.warning_out %>';

    //var warning_out = '<input type="checkbox" id="VerifyTimesheetCheckbox" /> <%=this.warning_out %>';

    var buildAndInitDelinquentDTKModal = function () {

        /* TODO: Replace this with a purpose build dialog call (https://api.jqueryui.com/1.8/dialog/)*/
        var $diaVerifyHours = $('<div id="diaVerifHours" ></div>');

        $($diaVerifyHours).attr('title', 'Please Confirm Hours');

        var $labelTimePeriod = $('<label style="display:inline"></label>');

        var $ctrlInputVerified = $('<input type="checkbox" />');

        $($diaVerifyHours).append($ctrlInputVerified);

        //var $msgWarningOut = ' <%=this.warning_out %>';

        $($labelTimePeriod).append($msgWarningOut);

        $($diaVerifyHours).append($labelTimePeriod);

        $($diaVerifyHours).dialog({
            draggable: true
            , resizable: true
            , modal: false
            , width: 550
            , height: 340
            , closeOnEscape: false
            , show: 'bounce'
            , buttons: [{
                text: 'OK'
                , click: function (event) {
                    $($diaVerifyHours).dialog('close');
                }
            }]
            , beforeClose: function (event, ui) {
                var isChecked = $($ctrlInputVerified).is(':checked');
                if (isChecked === false) {
                    /* Optional : Animate the checkbox control*/
                    return false;
                }

                /* Otherwise save */
                var get_url = 'timekeeper_taskentrycalendarevents.asmx/updateTimeVerification' + '?tkn=' +
                    $.spedmonWebUI.token +
                    '&etv_id=' +
                    warning_out_hidden +
                    '&lastDayOfSchedule=' +
                    lastDayOfSchedule +
                    '&e_id=' +
                    e_id

                $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,"Saving",2);

                $.get(get_url).done(function (response_content, str_status) {
                    //debugger;
                    if (str_status == 'success')  {

                            $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.SUCCESS, "ok", 2)

                            if (response_content.message == "MORE_VERIFICATIONS_REQUIRED") {
                              var parsed_r = JSON.parse(response_content.details[0])
                              warning_out_hidden = parsed_r.warning_out_hidden;
                              lastDayOfSchedule = parsed_r.lastDayOfSchedule;
                              $msgWarningOut = parsed_r.warning_out;

                              setTimeout(buildAndInitDelinquentDTKModal, 1000);
                            }

                    }
                    else {
                        //alert('unknown error!');
                        $('#validatelist').spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.CRITICAL, "error!", 2);
                    }
                });
            }
        });

        setTimeout(function () {
            $('.ui-dialog-titlebar-close', $('#diaVerifHours').prev()).remove();
        }, 100);


        //TODO: we need a selector that only selects the OK button for this particular
        //modal, not every modal -- this may cause problems later, who knows
        //$('.ui-dialog-buttonset button').attr('disabled','disabled');





    };

    setTimeout(buildAndInitDelinquentDTKModal, 2000);

    <%
    }
    %>

    fnSetDispModeWeekAndUpdateRenderEntries();

});

</script>