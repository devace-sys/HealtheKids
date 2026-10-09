<%@ Page Language="C#" CodeBehind="user_all_rmts_moment_service_records_manage.aspx.cs" Inherits="Spedmon.UserAllRmtsMomentServiceRecordsManage" %>



<% if (showNavBackToAllWO == "1") { %>

         <div class="d-flex justify-content-end px-4">

          <Spedmon:LinkInternal
          ID        = "gotoViewWoSvcrecs"
          title     = "Nav back to all participants without service records"
          label     = "Nav Back - Participants W/O Service Records - View All"
          faClass   = "fas fa-hand-point-right"
          openNew   = "false"
          subWindow = "false"
          runat     = "server" />

         </div> <!-- col -->

<% /// Possible Easter egg??
   /// This is intended to render a link back to noncompliant RMTS prac page, if that's where we got here from.
   ///  Otherwise render a link to the "All RMTS Participant Rosters" page.

   /// Two ways to get here, and the link rendered here switches depending on this or that.
   /// It's my opinion that this is more intuitive than confusing for somebody who is aimlessly wandering the app, as one does.
%>

<% } else { %>

         <div class="d-flex justify-content-end px-4">

          <Spedmon:LinkInternal
          ID        = "gotoViewAllRosters"

          title     = "View All RMTS Participant Rosters"
          label     = "View All RMTS Participant Rosters"

          faClass   = "fas fa-hand-point-right"
          openNew   = "false"
          subWindow = "false"
          runat     = "server" />

         </div> <!-- col -->



<% } %>

<div id="dataManagementRows" class="container-fluid">

    <div class="row">

        <div class="col-8">

            <%//-----------------------------------------------------------------------------%>
            <%// Select Client %>
            <%// (Practi-Cal staff only) %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryRowSelectClient
                ID                   = "selectClient"
                entityControlID      = "clientid"
                rowLabel             = "Client"
                dataEntryRowRenderAs = "FIELD"
                runat                = "server">
            </Spedmon:DataEntryRowSelectClient>

            <%//-----------------------------------------------------------------------------%>
            <%// Select Quarter %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:DataEntryRowSelectRmtsFiscalQuarter
                ID                   = "selectQuarter"
                entityControlID      = "fyquarterid"
                rowLabel             = "Quarter"
                dataEntryRowRenderAs = "FIELD"

                showClearSelection   = "true"

                onSpedmonInputData   = "populateDateRangeFromQtrSelectionCallbackData(e);"

                runat                = "server">
            </Spedmon:DataEntryRowSelectRmtsFiscalQuarter>

            <button id="sendDataDialogButton" class="ml-3 btn btn-primary" onclick="launchDataFileUploadScreen()">Upload RMTS Coding Report</button>
        </div>

        <div class="col-4 text-right pr-3">

        </div>
    </div>

     <% //  TODO: I don't remember the reasoning behind the 2A filter here.
        //  I'm assuming this is correct, as it passed code review a long time ago
        //  and I've received no complaints since
     %>

     <div class="col p-0">
      <Spedmon:HiddenInput ID="activitycodeselection" name="activitycodeselection" title="activitycodeselection" value="2A" runat="server" />
    </div> <!-- col -->

    <%-----------------------------%>
    <%--     Practitioner        --%>
    <%--      Selection          --%>
    <%-----------------------------%>

    <div class="row">
	    <div class="col-12 col-md-4">
		    <Spedmon:DataEntryRowSelectPractitioner
		            ID                                 = "selectPractitioner"
		            entityControlID                    = "pracid"
		            rowLabel                           = "Practitioner"
		            selectTitle                        = "Enter Last, First"
		            preSelectedDataSource              = "ALL_PRACTITIONERS"
			        dataEntryRowRenderAs               = "FIELD"
                    showClearSelection                 = "true"
		            runat                              = "server">
		    </Spedmon:DataEntryRowSelectPractitioner>
	    </div>

	    <div class="col-12 col-md-4 m-1">
		    <Spedmon:DateBoxRange id="daterange" name="daterange" title="Service Date Range" showOK="false" runat="server" />
	    </div>
    </div>


    <%-----------------------------%>
    <%--    Matches Required     --%>
    <%--      Status             --%>
    <%-----------------------------%>

    <% if (showNavBackToAllWO != "1") { %>

      <div class="row">

        <div class="col-12">
            <h4 id="countRequiringMatching" class="w-100 text-center"></h4>
        </div>

      </div>

    <% } %>


    <%-----------------------------%>
    <%--       Rest view         --%>
    <%--      RMTS Moments       --%>
    <%-----------------------------%>



    <div id="restViewRowRmtsMomentsFilters" class="row mt-3 mb-3">

        <div class="col-6 text-left">
        </div>

        <div class="col-6 text-right">

          <Spedmon:RadioBox ID="deferredcomplete" name="deferredcomplete" title="deferralstatus" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />
        </div>

    </div>

    <div id="restViewRowRmtsMoments" class="row">

        <div class="col-12">
          <div id="restViewRmtsMoments" class="w-100"></div>
        </div> <!-- col -->

    </div> <!-- row -->

    <%-----------------------------%>
    <%--     Service Record      --%>
    <%--       Subtitle          --%>
    <%-----------------------------%>
    <hr />
    <div class="row">
        <div class="col-12">
        <h4 class="w-100 mt-3">Recorded Services in SpEdCare</h4>
        </div> <!-- col -->
    </div> <!-- row -->



    <%-----------------------------%>
    <%--       Rest view         --%>
    <%--    Service Records      --%>
    <%-----------------------------%>

    <div id="restViewRowServiceRecs" class="row mt-3">
    <div class="col-12">
        <div id="restViewServiceRecs"></div>
        </div> <!-- col -->
    </div> <!-- row -->
</div>


<div class="d-none">

  <div id="diaAddException" title="Defer These">
    <div class="alert alert-warning text-center">Are you sure?  Deferring 2A Documentation may lead to a future audit finding.</div>
    <table class="table table-sm">
    <tbody id="exceptionaddreasonsummary">
    </tbody>
    </table>
    <Spedmon:DataEntryBoxSelect id="deferralreason"          name="deferralreason"      label="Reason"  required="true" runat="server" />
    <Spedmon:DataEntryBoxTextArea ID="deferralreasonnotes"   name="deferralreasonnotes" label="Notes" size="20" runat="server"/>
  </div>

</div>


<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    /************************************************************************************************************************* */
    let $dataManagementRows = null;
    let $restViewCtrl = null;

    $diaAddException = $('#diaAddException');


    function createElementFromHTML(htmlString) {
      var div = document.createElement('div');
      div.innerHTML = htmlString.trim();

      // Change this to div.childNodes to support multiple top-level nodes.
      return div.firstChild;
    }


    function fn_diaSelUpdatedPract() {
       return createElementFromHTML(
         '<div id="diaBulkSetDate" title="Update The Matched Practitioner">' +
           '<div class="ui-spedmon-data-entry-row row" tabindex="-1">' +
             '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label ' +
                     ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-2">' +

               '<h5>Select the practitioner for this RMTS moment</h5>' +
             '</div>' +

             '<div id="data-entry-123" class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry ' +
                                         ' col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-4">' +

                '<div class="data-entry-row-input w-90">' +
                  '<input ID="dialog-pracs-selection' +
                         '" name="dialog_pracs_selection" title="Select Names" />' +
                '</div>' +

             '</div>' +
           '</div>' +

         '</div>');
    };
    let $diaSelUpdatedPract = null;


    function initDiaSelUpdatedPract() {

        if (!( $diaSelUpdatedPract ))  return;

        $('input',     $diaSelUpdatedPract).val('');

        $($diaSelUpdatedPract).dialog('destroy');
        $($diaSelUpdatedPract).hide();

        $($diaSelUpdatedPract).remove();
    };

    function openSelUpdatedPractDialog(uiActionObj, opts ) {

        //debugger;

        initDiaSelUpdatedPract();

///

        $diaSelUpdatedPract = fn_diaSelUpdatedPract();

        var dialog = $diaSelUpdatedPract ;
        $(dialog).show();

        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(50);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(80);

        let diaOpts = {
            position: { my: 'center', at: 'center', of: window }
            , show: { effect: 'slide', direction: 'left' }
            , modal: true
            , closeOnEscape: false
            , width: (vw)
            , height: (vh)
            , open: function (event, ui) {          
                
            }
            , close: function (event, ui) {
                initDiaSelUpdatedPract();
            }
            , buttons: [
                { text: "Cancel", click: function () { $(dialog).dialog('close'); } }
                , {
                    text: "Proceed", click: function () {



				        let reqUrl = '<%= Spedmon.RmtsMoments.URL_SEND_UPDATED_PRACID_BASE() %>';
				        let reqData = JSON.stringify({

				            'rmts_mmt_id': uiActionObj.recordID ,
				            'clientid': uiActionObj.whatFieldNameValues.clientID ,
                                            'pracid': $('#dialog-pracs-selection').val()

				        });

				        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
				            .then(responseData => {
				                MOMENT_MATCHING_PROCESSOR.clearAllSelections();

				                refreshRestViews();

                                initDiaSelUpdatedPract();
				            })
				            .catch(responseData => {

				                //debugger;

				                if (responseData.message) {
				                  $.spedmonWebUI.dialogMessage("Problem!", responseData.message);
				                }

				                MOMENT_MATCHING_PROCESSOR.clearAllSelections();
				                refreshRestViews();

                                initDiaSelUpdatedPract();
				            });


                    }
                }
            ]
        };

        $(dialog).dialog(diaOpts);

        //debugger;

        $(dialog).find('#dialog-pracs-selection' ).spedmonSelectBox({
                                "dataParmType"                   : "DOM"
                              , "selectAll"                      : true
                              , "delay"                          : 600
                              , "showSelectControlLabel"         : false
                              , "selectControlLabel"             : "To: "
                              , "selectType"                     : $.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX
                              , "displayInline"                  : false

                              , "singleSelectName"               : uiActionObj.whatFieldNameValues.matchedPracName
                              , "singleSelectValue"              : uiActionObj.whatFieldNameValues.PracID

                              , "singleSelectClearAfterSelection": false

                              , "onSelect"                       : function(event,ui) { }
                              , "ajaxopts"                       : {
                                                                      url : opts.pracsSrcURL
                                                                    , data:""
                                                                    , namevalues : [
                                                                         { name: "clientid",
                                                                           value: uiActionObj.whatFieldNameValues.clientID
                                                                         },
                                                                         { name: "pracdatasource",
                                                                           value: "0"
                                                                         },

                                                                         { name: "patid",
                                                                           value: ""
                                                                         },
                                                                         { name: "dos",
                                                                           value: ""
                                                                         },
                                                                         { name: "groupserviceclassnameid",
                                                                           value: ""
                                                                         }
                                                                       ]
                                                                   }
                            });

                            <%   //  TODO!!!  NOTE!!!  
                                 //  The singleSelectValue param (above) is not prefilling as expected.
                                 //  Maybe possibly be a long-standing bug in the JS component, or a recent browser-version regression.
                                 //  Needs to be manually filled with .val().
                                 //  The singleSelectName is rendering visibly with the prefilled value, as intended.
                            %>

                            $('#dialog-pracs-selection').val( uiActionObj.whatFieldNameValues.PracID );
    };

    var VALUE_DEFERRED_COMPLETE;
    var VALUE_CLIENT_ID;


    const PARM_NAME_CLIENT_ID         = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_ACTIVE            = '<%=Constants.PARM_ACTIVE%>';
    const PARM_NAME_SVC_DATE_RANGE    = '<%=Spedmon.Constants.PARM_DATE_RANGE%>';
    const PARM_NAME_FISCAL_QUARTER_ID = '<%=MBA.Constants.PARM_FISCAL_QUARTER_ID%>';
    const PARM_NAME_FY_QUARTER_ID     = '<%=MBA.Constants.PARM_FY_QUARTER_ID%>';
    const PARM_NAME_PRAC_ID           = '<%=MBA.Constants.PARM_PRACTITIONER_ID%>';
    const MOMENT_MATCHING_PROCESSOR = {
        '$selectedRmtsMoment': null,
        'selectedRmtsMomentID': null,
        '$selectedServiceRec': null,
        'selectedServiceRecID': null,
        'clearRmtsMomentSelection': function () {
            if (this.$selectedRmtsMoment) {
                $(this.$selectedRmtsMoment).removeClass('fas');
            }

            this.$selectedRmtsMoment = this.selectedRmtsMomentID = null;
        },
        'clearRmtsSvcRecSelection': function () {
            if (this.$selectedServiceRec) {
                $(this.$selectedServiceRec).removeClass('fas');
            }
            this.$selectedServiceRec = this.selectedServiceRecID = null;
        },
        'clearAllSelections': function () {
            this.clearRmtsMomentSelection();
            this.clearRmtsSvcRecSelection();
        },
        'matchSelectionsIfNeeded': function () {
            if (!this.selectedRmtsMomentID || !this.selectedServiceRecID) {
                return;
            }

            var reqUrl = '<%=Spedmon.RmtsMoments.URL_FLAG_UPDATED_RMTS_MATCH_INLINE_BASE()%>';
            var reqData = JSON.stringify({
                'matching_rmtssvcrec': this.selectedServiceRecID , 
                'matching_audit_req' : this.selectedRmtsMomentID ,

                <% // NOTE:
                   // not familiar with this <script>ed OOP syntax, which is a refactor of my original implementation.
                   // grabbing the clientID from the filter widget, rather than the row.

                   // TODO!! this func will BREAK if we attempt to support a RestView result set not filtered by client.
                 %>

                 'clientid': VALUE_CLIENT_ID
            });

            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                .then(responseData => {
                    this.clearAllSelections();
                    refreshRestViews();
                })
                .catch(responseData => {
                    this.clearAllSelections();
                    refreshRestViews();
                });
        },
        'selectRmtsMoment': function (id, $elem) {
            if (!id || !$elem) return;

            let sameAsPreviousSelection = (id == this.selectedRmtsMomentID);

            // clear previous selection
            this.clearRmtsMomentSelection();

            // if selecting what was already selected, then we exit
            // because the previous selection has already been cleared in this function
            // also if 2 record selections were matched, then we exit as well
            if (sameAsPreviousSelection) {
                return;
            }

            this.selectedRmtsMomentID = id;
            this.$selectedRmtsMoment = $elem;

            // display selected icon as selected
            $(this.$selectedRmtsMoment).removeClass('fas').addClass('fas');

            // match if needed
            this.matchSelectionsIfNeeded();
        },
        'selectRmtsServiceRec': function (id, $elem) {
            if (!id || !$elem) return;

            let sameAsPreviousSelection = (id == this.selectedServiceRecID);

            // clear previous selection
            this.clearRmtsSvcRecSelection();

            // if selecting what was already selected, then we exit
            // because the previous selection has already been cleared in this function
            // also if 2 record selections were matched, then we exit as well
            if (sameAsPreviousSelection) {
                return;
            }

            this.selectedServiceRecID = id;
            this.$selectedServiceRec = $elem;

            // display selected icon as selected
            $(this.$selectedServiceRec).removeClass('fas').addClass('fas');

            // match if needed
            this.matchSelectionsIfNeeded();
        },
        // use for debugging
        'printCurrentData': function () {
            console.log(
                'RmtsMomentID: ' + this.selectedRmtsMomentID + '\n' +
                'RmtsSvcRecID: ' + this.selectedServiceRecID + '\n'
            );
        }
    }

    function resetAddExceptionDialog () {
      $('#deferralreasonnotes').val('');
      //$($diaAddException).hide();
      $($diaAddException).parent().remove();
    }

    function openAddExceptionDialog (uiActionObj) {
    //function openAddExceptionDialog ( uiObject, flagval ) {

        //initDiaAddExceptionPromisedService();



        let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(80);
        let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(80);

        let diaOpts = {
            position: { my: 'center', at: 'center', of: window }
            , show:{ effect: 'slide', direction: 'left' }
            , modal: true
            , closeOnEscape: false
            , width: (vw)
            , height: (vh)
            , close: function (event, ui) {
                //initDiaAddExceptionPromisedService();
                resetAddExceptionDialog();
            }
            , buttons: [
                { text: "Cancel", click: function () { resetAddExceptionDialog(); } }
                , {
                    text: "Proceed", click: function () {
                        //saveAddExceptionPromisedService(uiActionObj);
                        flagAsmxAsDeferred( uiActionObj, 1 );
                        resetAddExceptionDialog();
                    }
                }
            ]
        };

        $($diaAddException).show();
        $($diaAddException).dialog(diaOpts);

    }



    /* Use the recData values returned and
    * build the date range string used to filter by dos range
    * for the service records view and put the range string in the appropriate hidden input */
    function populateDateRangeFromQtrSelectionCallbackData(e) {
      try {


        //debugger ;

        //console.log("populateDateRangeFromQtrSelectionCallbackData");
        // NOTE: NOT CALLED WHEN QUARTERID DROPDOWN PREFILLED VIA URL

        <% // bad arithmetic was breaking stuff %>
        let startDateVal = new Date(e.dataitem.recData1);
        let modifiedStartDate = new Date(startDateVal.setMonth(startDateVal.getMonth() )).toLocaleDateString();

        let endDateVal = new Date(e.dataitem.recData2);
        let modifiedEndDate = new Date(endDateVal.setMonth(endDateVal.getMonth() )).toLocaleDateString();

        $('#' + PARM_NAME_SVC_DATE_RANGE).val(modifiedStartDate + ' - ' + modifiedEndDate);
      }
      catch (e)
      {
        <%

        // empty/null values still breaking stuff

        //$('#' + PARM_NAME_SVC_DATE_RANGE).val( '' )
        //$('#' + PARM_NAME_SVC_DATE_RANGE).daterangepicker( "setDate", null );

        // NOTE: this plugin does not appear to support clearing/resetting
        // as empty, even though the underlying plugin .datepicker() supports the following:
        // $('#input').datepicker( "setDate", null );
        %>

        return true;

      }


      return true;  //return true is necessary, because otherwise the spedmon data input won't be fired


    }


    // refresh both rest views
    function refreshRestViews() {

        // debugger ;

        updateCountOfMatchesRequired();
        updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMoments(null);
        updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs(null);
    }

    // launches the RMTS moments file upload screen
    function launchDataFileUploadScreen() {
        var url = '<%=Spedmon.StructuredDataImportFilesRmtsMomentsData.URL_SAVE_NEW_SUB_PAGE_BASE()%>'
        + '&clientid='    + $('#' + PARM_NAME_CLIENT_ID).val()
        + '&fyquarterid=' + $('#' + PARM_NAME_FY_QUARTER_ID).val();

        $.spedmonWebUI.openNewWindow(url, 'rmts-moments-file-upload', refreshRestViews);
        return;
    }

    function updateCountOfMatchesRequired() {
        var counterUrl = '<%=Spedmon.RmtsMoments.URL_REST_VIEW_RMTS_REQS()%>' +
            '&' + PARM_NAME_FISCAL_QUARTER_ID + '=' + $('#fyquarterid').val() + '&activity_code=2A' + '&isComplete=0' +
            '&clientid=' + $('#' + PARM_NAME_CLIENT_ID).val()

        $.get(counterUrl).done(function (resp, status_txt) {
            var_count_requiring_matching = resp.recordsFiltered;
            $("#countRequiringMatching").text(var_count_requiring_matching + ' RMTS moments need supporting documentation');
        });
    }

    ////
    function unMatchAuditRecs(uiActionObj, rmtsAuditRecID) {

        // debugger  ;
        $.spedmonWebUI.dialogConfirm(
            'Unmatch Moment From Service Record?',
            'Are you sure you wish to unmatch this RMTS moment from the matched service record?',
            function () {

                // debugger;

                let reqUrl = '<%=Spedmon.RmtsMoments.URL_SEND_UNDO_MATCH_BASE()%>';
                let reqData = JSON.stringify({
                    'matching_audit_req': rmtsAuditRecID  ,
                    'clientid': uiActionObj.whatFieldNameValues.clientID
                });

                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                    .then(responseData => {
                        MOMENT_MATCHING_PROCESSOR.clearAllSelections();
                        refreshRestViews();
                    })
                    .catch(responseData => {
                        MOMENT_MATCHING_PROCESSOR.clearAllSelections();
                        refreshRestViews();
                    });
            },
            function () { }
        );
    }


    function flagRowAsComplete(rmtsAuditRecID, clientid) {

        let reqUrl = '<%=Spedmon.RmtsMoments.URL_FLAG_COMPLETE_BASE()%>';
        let reqData = JSON.stringify({
            'matching_audit_req': rmtsAuditRecID ,
            'clientid': clientid
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                MOMENT_MATCHING_PROCESSOR.clearAllSelections();
                refreshRestViews();
            })
            .catch(responseData => {

                //debugger;

                if (responseData.message) {
                  $.spedmonWebUI.dialogMessage("Problem!", responseData.message);
                }

                MOMENT_MATCHING_PROCESSOR.clearAllSelections();
                refreshRestViews();
            });

    }


   ///
    var flagAsmxAsDeferred = function( uiObject, flagval ) {

        // debugger;

        var rowvals  =  uiObject.whatFieldNameValues ;
        var  reqURL  =  '<%=Spedmon.RmtsMoments.URL_FLAG_DEFERRAL_REASON_BASE()%>';



        var reqDataObj;
        if ( flagval )
          reqDataObj = {

              recid         : uiObject.recordID

             , deferralreason  : $('#deferralreason').val()
             , deferralreasonnotes  : $('#deferralreasonnotes').val()

             , clientid        : rowvals.clientID

             , isdeferred      : flagval

        } ;
        else

          reqDataObj = {

              recid         : uiObject.recordID

             , deferralreason  : ''
             , deferralreasonnotes  : ''

             , clientid        : rowvals.clientID

             , isdeferred      : flagval

        } ;

        let reqDataJSON = JSON.stringify(reqDataObj);


        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqURL, reqDataJSON, null)
            .then(responseData => {

                $($restViewCtrlRmtsMoments).MBA_RestView('refreshCurrentViewFromServer');

                return;
            })
            .catch(responseData => {
                $($restViewCtrlRmtsMoments).MBA_RestView('hideOverlayMessage');
                //alert('problem!');
                var problem_txt = "problem!";

                // debugger;

                try {
                  problem_txt = responseData.message ;
                } catch(e) {}

                $.spedmonWebUI.dialogMessage('Action required', problem_txt );

                return;
            });
        // }; /* _fnacceptRowRowsProceed*/


    } ;

    /*********************************************************** RMTS MOMENTS REST VIEW **************************************************************************************/
    function updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMoments(e) {
        // clear match selection in case anything is selected
        MOMENT_MATCHING_PROCESSOR.clearRmtsMomentSelection();

        // debugger;

        VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_ACTIVE = '1';

        // $diaAddException = $('#diaAddException');

        VALUE_DEFERRED_COMPLETE = $('#deferredcomplete' ).val();

        let VALUE_PRAC_ID = $('#pracid' ).val();


		if ( VALUE_DEFERRED_COMPLETE == "3" ) {

		    $($restViewCtrlRmtsMoments).MBA_RestView('showColumn', 'deferralDateStrYMD');
		    $($restViewCtrlRmtsMoments).MBA_RestView('showColumn', 'deferredByStr');
		    $($restViewCtrlRmtsMoments).MBA_RestView('showColumn', 'deferralReason');
		    $($restViewCtrlRmtsMoments).MBA_RestView('showColumn', 'deferralReasonNotes');

		    $($restViewCtrlRmtsMoments).MBA_RestView('hideColumn', 'lastModifiedByStr');

                    //$('button[data-mba-rest-view-ctrl-def-name="selectAsAudited"]'.hide();

		}

                //else  if ( VALUE_DEFERRED_COMPLETE == "1" )
                    //$('button[data-mba-rest-view-ctrl-def-name="selectAsAudited"]'.show();

		else {

		    $($restViewCtrlRmtsMoments).MBA_RestView('hideColumn', 'deferralDateStrYMD');
		    $($restViewCtrlRmtsMoments).MBA_RestView('hideColumn', 'deferredByStr');
		    $($restViewCtrlRmtsMoments).MBA_RestView('hideColumn', 'deferralReason');
		    $($restViewCtrlRmtsMoments).MBA_RestView('hideColumn', 'deferralReasonNotes');
		    $($restViewCtrlRmtsMoments).MBA_RestView('showColumn', 'lastModifiedByStr');
                   // $('button[data-mba-rest-view-ctrl-def-name="selectAsAudited"]'.hide();

		}

                //if ( VALUE_DEFERRED_COMPLETE == "1" )
                //    $('button[data-mba-rest-view-ctrl-def-name="selectAsAudited"]'.show();
                //else
                //    $('button[data-mba-rest-view-ctrl-def-name="selectAsAudited"]'.hide();

        if (!VALUE_CLIENT_ID) return;

        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_ACTIVE    = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);
        let NV_QUARTER   = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_FISCAL_QUARTER_ID, $('#fyquarterid').val());





        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrlRmtsMoments).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrlRmtsMoments).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);
        $($restViewCtrlRmtsMoments).MBA_RestView('additionalParameterDefinitionForViewSet', NV_QUARTER);

        let NV_ACTIVITYCODE = MBA.RestViewCommon.fnCreateNameValueObject('activity_code', $('#activitycodeselection').val());
        $($restViewCtrlRmtsMoments).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVITYCODE);

        let NV_DEFERRED = MBA.RestViewCommon.fnCreateNameValueObject('deferredcomplete', VALUE_DEFERRED_COMPLETE );
        $($restViewCtrlRmtsMoments).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DEFERRED );

        //
        let NV_PRAC = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID, VALUE_PRAC_ID);
        $($restViewCtrlRmtsMoments).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC);
        //


        // debugger;


        $($restViewCtrlRmtsMoments).MBA_RestView('requestViewFromServer', 1);

        updateCountOfMatchesRequired();

    };

    function initViewMomentsReq() {

        let opts = {};

       //
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
       //


        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = false;

        opts.enableRowControlRecDelete = false;

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inwindow';
        opts.baseUrlEdit = '';
        opts.baseUrlEditHasParameters = true;

        opts.enableRowControlRecEdit = false;

        opts.saveModeEdit = 'inline';
        opts.baseUrlEdit = '';


        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = '';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.RmtsMoments.URL_REST_VIEW_RMTS_REQS()%>';
	    opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.RmtsMoment.DEFAULT_PAGING_ORDER%>';
        opts.enableReports = true;
        opts.enableReportHtml = true;
        opts.enableReportXls = true;
        opts.enableReportPdf = false;
        opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport = '<%=Spedmon.RmtsMoments.URL_WEB_REPORT_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = <%= Spedmon.RmtsMoments.REPT_NUM_REVIEWS_FOR_MATCH %>;    // enters the ELSE of the first (outermost) IF in the ashx file


        opts.pracsSrcURL  = '<%= Spedmon.Practitioners.URL_VIEW_SEL2_BASE() %>';


        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id',
            isRecID: true,
            saveable: false,
            saveUsing: 'recid'
        });

        //opts.fieldDefinitions.push({
        //    name: 'id',
        //    label: 'ID',
        //    toolTip: 'ID',
        //    visible: true,
        //    editable: false,
        //    saveable: false,
        //    sortable: true,
        //    isRecID: false,
        //    dataType: 'number',
        //});

        opts.fieldDefinitions.push({
            name: 'Quarter',
            label: 'Quarter',
            toolTip: 'Quarter',
            visible: true,
            editable: false,
            saveable: false,
            sortable: true,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'QTR_DEFINITION'
        });

        opts.fieldDefinitions.push({
            name: 'LastName',
            label: 'Last<br/>Name',
            toolTip: 'Last Name',
            visible: true,
            editable: false,
            saveable: false,
            sortable: true,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'LastName'
        });


       <% // TODO!
          // Next time I have the misfortune of working on a significant deliverable or refactor of this page,
          // I want to implement drilldown links in these table cells, similar to what was done on the W/O-Compliance,
          // naughty naughty pracs page.

          // Clicking on the LastName (or FirstName) of the prac will populate the pracID dropdown with that prac,
          // as well as the fyQ dropdown, with search criteria matching the clicked row.

          // This will refresh BOTH restviews on the page with the appropriately narrowed-down result set.
       %>

        opts.fieldDefinitions.push({
            name: 'FirstName',
            label: 'First<br/>Name',
            toolTip: 'First Name',
            visible: true,
            editable: false,
            saveable: false,
            sortable: true,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'FirstName'
        });

        opts.fieldDefinitions.push({
            name: 'JobTitle',
            label: 'Job<br/>Title',
            toolTip: 'Job Title',
            visible: true,
            editable: false,
            saveable: false,
            sortable: true,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'JobTitle'
        });

        opts.fieldDefinitions.push({
            name: 'JobClassification',
            label: 'Job</br>Classification',
            toolTip: 'Job Classification',
            visible: true,
            editable: false,
            saveable: false,
            sortable: true,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'JobClassification'
        });

        opts.fieldDefinitions.push({
            name: 'momentDatetime',
            label: 'Sampled</br>Moment',
            toolTip: 'Sampled Moment',
            visible: true,
            editable: false,
            saveable: false,
            sortable: true,
            isRecID: false,
            dataType: 'date',
            saveUsing: '',
            sortUsing: 'momentDatetime'
        });

        opts.fieldDefinitions.push({
            name: 'ActivityCode',
            label: 'Activity<br/>Code',
            toolTip: 'Activity Code',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'ActivityCode'
        });


        opts.fieldDefinitions.push({
            name: 'deferralDateStrYMD'
            , label: 'Deferred On'
            , toolTip: 'Deferred On'
            , visible: true

            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'deferralDate'
            , saveUsing: 'deferraldate'
        });

        opts.fieldDefinitions.push({
            name: 'deferredByStr'
            , label: 'Deferred By'
            , toolTip: 'Deferred By'

            , visible: true

            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'deferredByStr'
            , saveUsing: 'deferredByStr'
        });


        opts.fieldDefinitions.push({
	          name: 'deferralReason'
	        , label: 'Deferral Reason'
	        , toolTip: 'Deferral Reason'
	        , visible: true
	        , editable: false
	        , saveable: true
	        , sortable: true
	     , isRecID: false
	        , dataType: 'text'
	        , sortUsing: 'deferralReason'
	        , saveUsing: 'deferralreason'

        });

        opts.fieldDefinitions.push({
	          name: 'deferralReasonNotes'
	        , label: 'Deferral Notes'
	        , toolTip: 'Deferral Reason Notes'
	        , visible: true
	        , editable: false
	        , saveable: true
	        , sortable: true
	     , isRecID: false
	        , dataType: 'textarea'
	        , sortUsing: 'deferralReasonNotes'
	        , saveUsing: 'deferralreasonnotes'
	        , styleAttrValueForCellValue: 'height:3.6em;'
	        , showMore: true
        });

        opts.fieldDefinitions.push({
            name: 'SMAACode16AuditRequired',
            label: 'SMAA Code16</br>Audit Required?',
            toolTip: 'SMAA Code16 Audi tRequired?',
            visible: false,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'SMAACode16AuditRequired'
        });

        opts.fieldDefinitions.push({
            name: 'LEABOPCode2AAuditRequired',
            label: 'LEA BOP</br>Code2A</br>Audit Required?',
            toolTip: 'LEA BOP Code2A Audit Required?',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'LEABOPCode2AAuditRequired'
        });

        opts.fieldDefinitions.push({
            name: 'RelatedToStudentAssessmentIEP_IFSP_CarePlan',
            label: 'Related To<br/>StudentAssessment<br/>IEP IFSP<br/>Care Plan?',
            toolTip: 'Related To StudentAssessment IEP IFSP Care Plan?',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'RelatedToStudentAssessmentIEP_IFSP_CarePlan'
        });

        opts.fieldDefinitions.push({
            name: 'WhoWereYouWith',
            label: 'Who Were</br>You With?',
            toolTip: 'Who Were You With?',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'WhoWereYouWith'
        });

        opts.fieldDefinitions.push({
            name: 'WhatWereYouDoing',
            label: 'What Were</br>You Doing?',
            toolTip: 'What Were You Doing?',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'WhatWereYouDoing'
        });

        opts.fieldDefinitions.push({
            name: 'WhyWereYouPerformingThisActivity',
            label: 'Why Were You</br>Performing This</br>Activity?',
            toolTip: 'Why Were You Performing This Activity?',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'WhyWereYouPerformingThisActivity'
        });

        opts.fieldDefinitions.push({
            name: 'ClarifyingQuestion1',
            label: 'Clarifying<br/>Question 1',
            toolTip: 'Clarifying Question 1',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'ClarifyingQuestion1'
        });

        opts.fieldDefinitions.push({
            name: 'ClarifyingQuestionAnswer1',
            label: 'Answer',
            toolTip: 'Clarifying Answer 1',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'ClarifyingQuestionAnswer1'
        });

        opts.fieldDefinitions.push({
            name: 'ClarifyingQuestion2',
            label: 'Clarifying<br/>Question 2',
            toolTip: 'Clarifying Question 2',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'ClarifyingQuestion2'
        });

        opts.fieldDefinitions.push({
            name: 'ClarifyingQuestionAnswer2',
            label: 'Answer',
            toolTip: 'Clarifying Answer 2',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'ClarifyingQuestionAnswer2'
        });

        opts.fieldDefinitions.push({
            name: 'CodingComments',
            label: 'Coding<br/>Comments',
            toolTip: 'Coding Comments',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: 'CodingComments'
        });

        opts.fieldDefinitions.push({
            name: 'PracID',
            label: 'pracID',
            toolTip: '',
            visible: true,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: ''
        });

        opts.fieldDefinitions.push({
            name: 'matchedPracName',
            label: 'matchedPracName',
            toolTip: '',
            visible: false,
            editable: false,
            saveable: false,
            sortable: false,
            isRecID: false,
            dataType: 'text',
            saveUsing: '',
            sortUsing: ''
        });

	    <% // Client ID %>

        opts.fieldDefinitions.push({
            name: 'clientID',
            visible: false,
            sortable: false,
            saveable: true,
            editable: false,
            isRecID: false,
            dataType: 'hidden',
            sortUsing: '',
            saveUsing: 'clientid',
            showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'lastModifiedByStr'

            , label: 'Last Modified By'
            , toolTip: 'Last Modified By'

            , visible: true

            , editable: false
            , saveable: false
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'lastModifiedByStr'
            , saveUsing: 'lastModifiedByStr'
        });

        opts.additionalControlDefinitionsForBodyRows = new Map();
        opts.rowCtrlDefs = [];

        opts.additionalControlDefinitionsForBodyRows.set('selectAsAudited', {
            defType: 'userprovided',
            name: 'selectAsAudited',
            toolTip: 'Click Here to Associate with Recorded RMTS Moment',
            cssClass: 'fa fa-thumbs-up',
            handlerFn: function (uiActionObj) {

                //#069433 !important;

                $('.seld-for-thumbsup').removeClass('seld-for-thumbsup');

                $( uiActionObj.whatElement ).addClass('seld-for-thumbsup');
                //debugger;

                let hasFiles = $(uiActionObj.whatRow).hasClass('hasFiles');
                let mustCorrectThisMistake = $(uiActionObj.whatRow).hasClass('mustCorrectThisMistake');


                // debugger;

                if (hasFiles && !mustCorrectThisMistake) {
                    flagRowAsComplete(
                        uiActionObj.recordID
                      , uiActionObj.whatFieldCellsInputValues.get("clientID")
                    );
                <%
                    // NOTE: we are now auto-flagging and auto-refreshing on upload.
                    // THIS CLICK OPTION SHOULD NO LONGER BE VISIBLE TO THE USER.
                    // Possible edge cases - if the user clicks to "close" the browser
                    // before closing the fileUp dialog, etc.
                %>
                } else {
                    MOMENT_MATCHING_PROCESSOR.selectRmtsMoment(uiActionObj.recordID, $(uiActionObj.whatElement).find('i')[0]);
                }

                return uiActionObj;
            },
            initiallyHidden: true
        });

        opts.additionalControlDefinitionsForBodyRows.set('deselectAsAudited', {
            defType: 'userprovided',
            name: 'deselectAsAudited',
            toolTip: 'Click Here to Unmatch from Recorded RMTS Moment',
            cssClass: 'fa fa-thumbs-up',
            handlerFn: function (uiActionObj) {

                unMatchAuditRecs(uiActionObj, uiActionObj.recordID);

                return uiActionObj;
            },
            initiallyHidden: true

        });

        opts.additionalControlDefinitionsForBodyRows.set('infoHoverButton', {
            defType: 'userprovided',
            name: 'infoHoverButton',
            toolTip: '',
            cssClass: 'fas fa-info-circle',
            handlerFn: function (uiActionObj) {
                return uiActionObj;
            },
            initiallyHidden: false
        });

        opts.additionalControlDefinitionsForBodyRows.set('fileUpButton', {
            defType: 'userprovided',
            name: 'fileUpButton',
            toolTip: 'upload documents',
            cssClass: 'fas fa-file-upload',
            handlerFn: function (uiActionObj) {

                // debugger;

                var clientid = $('#clientid').val() ;

                var fileAdditionalDataJSON = {
                    clientid: clientid ,
                    referencedentityid: uiActionObj.recordID
                };

                $.spedmonWebUI.fileList('RMTS Supporting Documentation', '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>', '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>', '<%=MBA.StoredFiles.PARAM_FILE_ID%>', 3 /* Record id position */, '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>', 625, '' //uiActionObj.recordID
                , '', '', JSON.stringify(fileAdditionalDataJSON), true, true,

                function() {
                  //try {

                    if ( VALUE_DEFERRED_COMPLETE == "1" )
                        flagRowAsComplete(uiActionObj.recordID, clientid);

                  //}
                } // fnOnClose param

                );

                return uiActionObj;
            },
            initiallyHidden: false
        });

        opts.additionalControlDefinitionsForBodyRows.set('flagDefer', {
            defType: 'userprovided',
            name: 'flagDefer',
            toolTip: 'mark as deferred',
            cssClass: 'fa fa-thumbs-down',
            handlerFn: openAddExceptionDialog,
                                   ///  NOTE: this function name (and the other similarly-named functions it calls,
                                   //         and the global var $diaAddException) seem to be counter-intuitively misnamed.
            initiallyHidden: false
        });

        opts.additionalControlDefinitionsForBodyRows.set('flagUndefer', {
            defType: 'userprovided',
            name: 'flagUndefer',
            toolTip: 'unmark as deferred',
            cssClass: 'fa fa-thumbs-up',
            handlerFn: function(uiObject){
                         flagAsmxAsDeferred( uiObject, 0 ) ;
                       },
            initiallyHidden: false
        });

       opts.additionalControlDefinitionsForBodyRows.set('editPracForUnmatched', {
		    defType: 'userprovided',
		    name: 'editPracForUnmatched',
		    toolTip: 'Click Here to Flag This Service as an RMTS Moment',
		    cssClass: 'fa fa-user-md',
	 	    handlerFn: function (uiActionObj) {

                // alert('hi');

	            // debugger; 

                openSelUpdatedPractDialog( uiActionObj, opts );

                return uiActionObj;
	        },
            initiallyHidden: false
       });

        opts.fnCreateNewRowBefore = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            if (!rowData) return $newRow;

            // based on next step, decide which handshake button must show up
            var nextStep = rowData.rmtsReqNextStep;

            switch (nextStep) {
                case 0:
                case 3:
                    opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').initiallyHidden = false;
                    break;
                case 1:
                default:
                    opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited').initiallyHidden = false;
                    break;
            }

            // handle special case: if files have been uploaded and record is complete, show deselectAsAudited
            //                      if files have been uploaded and record is NOT complete, show selectAsAudited to mark as complete
            if (rowData.hasFiles) {

                if (rowData.isComplete) {
                    opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').initiallyHidden = false;
                    opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited').initiallyHidden = true;

                } else {
                    opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').initiallyHidden = true;
                    opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited').initiallyHidden = false;
                }

            }

            // create tooltip for handshake icon based on states returned from the database

            if (rowtype != 1 && rowData) {
                let matchingTooltip = rowData.matchingTooltipAction ;


                opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited').toolTip =
                opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').toolTip =
                matchingTooltip;
            }

            // set tooltip for info button
            if (rowData && rowData.svcRecID) {

                opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').initiallyHidden = false;
                opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').toolTip = rowData.Patient;

            } else if (rowtype != 1) {

                if (rowData && rowData.hasFiles) {

                    opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').initiallyHidden = false;
                    opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').toolTip =
                        'see uploaded files attached';
                } else {

                    opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').initiallyHidden = true;
                }

            }

            // file upload show/hide logic
            if (rowData && (rowtype != 1)) {
                opts.additionalControlDefinitionsForBodyRows.get('fileUpButton').initiallyHidden = false;
            }

            // define a function to set values for opts.fieldDefinitions so we don't repeat code
            function setTrimmedFieldDefValues(fieldName, fieldValueTrimmed) {
                let chosenField = opts.fieldDefinitions.find(x => x.name === fieldName);

                if (chosenField) {
                    chosenField.toolTip = rowData[fieldName];
                    rowData[fieldName] = fieldValueTrimmed;
                }
            }

            if (rowData && rowData.LEABOPCode2AAuditRequired && rowData.LEABOPCode2AAuditRequired.length > 55) {
                setTrimmedFieldDefValues('LEABOPCode2AAuditRequired', rowData.LEABOPCode2AAuditRequired.substr(0, 55) + '... <i class="fa fa-info-circle"/>');
            }

            if (rowData && rowData.WhatWereYouDoing) rowData['WhatWereYouDoingORIG'] = rowData.WhatWereYouDoing;
            if (rowData && rowData.WhatWereYouDoing && rowData.WhatWereYouDoing.length > 55) {
                setTrimmedFieldDefValues('WhatWereYouDoing', rowData.WhatWereYouDoing.substr(0, 55) + '... <i class="fa fa-info-circle"/>');
            }

            if (rowData && rowData.WhyWereYouPerformingThisActivity) rowData['WhyWereYouPerformingThisActivityORIG'] = rowData.WhyWereYouPerformingThisActivity;
            if (rowData && rowData.WhyWereYouPerformingThisActivity && rowData.WhyWereYouPerformingThisActivity.length > 55) {
                setTrimmedFieldDefValues('WhyWereYouPerformingThisActivity', rowData.WhyWereYouPerformingThisActivity.substr(0, 55) + '... <i class="fa fa-info-circle"/>');
            }

            if (rowData && rowData.ClarifyingQuestion1) rowData['ClarifyingQuestion1ORIG'] = rowData.ClarifyingQuestion1;
            if (rowData && rowData.ClarifyingQuestion1 && rowData.ClarifyingQuestion1.length > 55) {
                setTrimmedFieldDefValues('ClarifyingQuestion1', rowData.ClarifyingQuestion1.substr(0, 55) + '... <i class="fa fa-info-circle"/>');
            }

            if (rowData && rowData.ClarifyingQuestionAnswer1) rowData['ClarifyingQuestionAnswer1ORIG'] = rowData.ClarifyingQuestionAnswer1;
            if (rowData && rowData.ClarifyingQuestionAnswer1 && rowData.ClarifyingQuestionAnswer1.length > 55) {
                setTrimmedFieldDefValues('ClarifyingQuestionAnswer1', rowData.ClarifyingQuestionAnswer1.substr(0, 55) + '... <i class="fa fa-info-circle"/>');
            }

            if (rowData && rowData.ClarifyingQuestion2) rowData['ClarifyingQuestion2ORIG'] = rowData.ClarifyingQuestion2;
            if (rowData && rowData.ClarifyingQuestion2 && rowData.ClarifyingQuestion2.length > 55) {
                setTrimmedFieldDefValues('ClarifyingQuestion2', rowData.ClarifyingQuestion2.substr(0, 55) + '... <i class="fa fa-info-circle"/>');
            }

            if (rowData && rowData.ClarifyingQuestionAnswer2) rowData['ClarifyingQuestionAnswer2ORIG'] = rowData.ClarifyingQuestionAnswer2;
            if (rowData && rowData.ClarifyingQuestionAnswer2 && rowData.ClarifyingQuestionAnswer2.length > 55) {
                setTrimmedFieldDefValues('ClarifyingQuestionAnswer2', rowData.ClarifyingQuestionAnswer2.substr(0, 55) + '... <i class="fa fa-info-circle"/>');
            }

            if (rowData && rowData.CodingComments) rowData['CodingCommentsORIG'] = rowData.CodingComments;
            if (rowData && rowData.CodingComments && rowData.CodingComments.length > 55) {
                setTrimmedFieldDefValues('CodingComments', rowData.CodingComments.substr(0, 55) + '... <i class="fa fa-info-circle"/>');
            }

            return $newRow;
        }

        opts.fnCreateNewRowAfter = function (newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

            if (rowtype == 1 || !rowData) return newRow;

            // for some reason, without this piece of code, all icons appear at the same time
            opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited').initiallyHidden = true;
            opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').initiallyHidden = true;

            //debugger;
            if (!(rowData.PracID > 0))
              $( '.mba-rest-view-ctrl-button i.fa-user-md', newRow).addClass('text-danger'); 
            else
              $( '.mba-rest-view-ctrl-button i.fa-user-md', newRow).addClass('text-secondary'); 

            /******************************************************************************************************************************/
            // set up messaging
            /******************************************************************************************************************************/
            var $msgIcon = $('<i style="font-size: 1.2em;" class="fas fa-comment fa-mba-messages-widget-class ml-2" title="send messages"></i>');


            //debugger;

            var messagesWidget_opts = {



                'clientID': '<%=rd.wu.usr.clientID%>',
                'sendMessageAjaxURL': '<%= Spedmon.RmtsMoments.URL_USERMSG_RMTS_REQ_INLINE_BASE() %>' +
                '&respPromptOptions=' +
				<%= Spedmon.Constants.RMTS_NOTIF_PROMPT_INCL_MANAGE_SVCRECS + Spedmon.Constants.RMTS_NOTIF_PROMPT_INCL_ADD_SVCREC + Spedmon.Constants.RMTS_NOTIF_PROMPT_INCL_FILEUPBOX_RMTSMOMNT %> +
				'&respPromptOptionsJSON=' +
				encodeURI(
					JSON.stringify({
						clientid: $('#clientid').val(),
						referencedentityid: rowData.id,
						matchrmtsdate: Date.parse(rowData.momentDatetime).toString('MM/dd/yyyy'),
                        rmtsAddNewServiceURL:
                           '<%= Spedmon.ServiceRecords.generateSharebleUrlRmtsMomentMatchAndSvcRecSave() %>'
					})
				),
			    'deleteMessageAjaxURL': '',
                'recipientSrcURL': '<%=MBA.HttpApplication.createLink(Spedmon.Users.URL_ASMX_VIEWSEL, true)%>' ,


                       recipientIDs   :  '' + rowData.pracUserID  //string
                    ,  recipientNames:   rowData.pracUserName ,


                'replyModeOn': false,
                'allowDelete': false,
                'viewModeSubject': ('Please log in to your SpEdCare account and provide documentation for RMTS Moment - ' + Date.parse(rowData.momentDatetime).toString('MM/dd/yyyy'))

                ,
                'textAreaPrefill': "Please log in to your SpEdCare account and click on the request from your coordinator in the Messages & Notifications widget in order to provide documentation for the RMTS Moment.\r\n\r\n" +

  'Click the video link below to watch a brief video regarding how to respond to this request or ' +
  '<a href="https://drive.google.com/file/d/1_SbdQ-PlXPxogHyYMtrXvSHgMI9QLJ6B/view">click HERE</a>' +
  " to view a PDF resource that will walk you through the steps to complete this request.\r\n\r\n"  +
  '<a href="https://vimeo.com/945911756/a779c1c7ae">https://vimeo.com/945911756/a779c1c7ae</a>' +
                    "\r\n -------------------- \r\n  " +
                    Date.parse(rowData.momentDatetime).toString('MM/dd/yyyy @ hh:mm tt') +
                    "\r\n -------------------- \r\n" +
                    (
                        rowData.WhoWereYouWithORIG ? ("Who Were You With?\r\n -------------------- \r\n" + rowData.WhoWereYouWithORIG + "\r\n -------------------- \r\n") : ''
                    ) + (
                        rowData.WhatWereYouDoingORIG ? ("What Were You Doing?\r\n -------------------- \r\n" + rowData.WhatWereYouDoingORIG + "\r\n -------------------- \r\n") : ''
                    ) + (
                        rowData.WhyWereYouPerformingThisActivityORIG ? ("Why Were You Performing This Activity?\r\n -------------------- \r\n" + rowData.WhyWereYouPerformingThisActivityORIG + "\r\n -------------------- \r\n") : ''
                    ) + (
                        rowData.ClarifyingQuestion1ORIG ? ("Clarifying Question 1\r\n -------------------- \r\n" + rowData.ClarifyingQuestion1ORIG + "\r\n -------------------- \r\n") : ''
                    ) + (
                        rowData.ClarifyingQuestionAnswer1ORIG ? ("Answer\r\n -------------------- \r\n" + rowData.ClarifyingQuestionAnswer1ORIG + "\r\n -------------------- \r\n") : ''
                    ) + (
                        rowData.ClarifyingQuestion2ORIG ? ("Clarifying Question 2\r\n -------------------- \r\n" + rowData.ClarifyingQuestion2ORIG + "\r\n -------------------- \r\n") : ''
                    ) + (
                        rowData.ClarifyingQuestionAnswer2ORIG ? ("Answer\r\n -------------------- \r\n" + rowData.ClarifyingQuestionAnswer2ORIG + "\r\n -------------------- \r\n") : ''
                    ) + (
                        rowData.WhoWereYouWithORIG ? ("Coding Comments\r\n -------------------- \r\n" + rowData.WhoWereYouWithORIG + "\r\n -------------------- \r\n") : ''
                    )

                ,
                'isSendOnly': true,
                'senderUserID': '',
                'senderName': '',
                'messageID': ''
            };


            if (rowData.PracID > 0)
              $msgIcon.messagesWidget(messagesWidget_opts);
            else
              $msgIcon.click( function() { $.spedmonWebUI.dialogMessage('Practitioner Not Found For this Entry', 'The practitioner was not automatched for this requested moment.  You should click the red user-md icon to manually find the practitioner for this RMTS moment.') });

            $('td.mba-rest-view-row-controls', newRow).append($msgIcon);

            <%
            //  TODO: not sure why the msgIcon widget is implemented in auch a nonstandard, roundabout way, rather than using opts.additionalControlDefinitionsForBodyRows
            %>

            $msgIcon.click(function () {
                $(this).css('color', '#c7c703');
            });

            /******************************************************************************************************************************/
            // done with setting up messaging
            /******************************************************************************************************************************/

            // add color classes based on what is coming back from the database
            if (rowData.respReqNotifSent) {
                $msgIcon.css('color', '#c7c703');
            }


            if (newRow && rowData && rowData.isComplete) {
                $('td.mba-rest-view-row-controls button[data-mba-rest-view-ctrl-def-name="deselectAsAudited"]', newRow).addClass('text-success');
                $('td.mba-rest-view-row-controls button[data-mba-rest-view-ctrl-def-name="selectAsAudited"]', newRow).addClass('text-success');
                <% /* NOTE: baffled at the moment as to why we would be setting both the select and deselect buttons as green.
                            Shouldn't it be one or the other? */ %>
            }

            if (newRow && rowData && rowData.mustCorrectThisMistake) {
                $('td.mba-rest-view-row-controls button[data-mba-rest-view-ctrl-def-name="selectAsAudited"]', newRow).addClass('text-danger');
            }

            if (newRow && rowData && rowData.hasFiles) {
                newRow.addClass('hasFiles');  //
            }

            if (newRow && rowData && rowData.mustCorrectThisMistake) {
                newRow.addClass('mustCorrectThisMistake');  //
            }

            if (newRow && rowData) {
                newRow.data('rmts-next-step', rowData.rmtsReqNextStep);
                <% /* NOTE: this .data() blob set here doesn't seem to be referenced anywhere else on this page.  Maybe consider removing it next time we work on this page */ %>
            }

            if ( VALUE_DEFERRED_COMPLETE == "3" ) {



            $('button[data-mba-rest-view-ctrl-def-name="flagDefer"]',   newRow).hide();
            $('button[data-mba-rest-view-ctrl-def-name="flagUndefer"]', newRow).show();

            $('button[data-mba-rest-view-ctrl-def-name="fileUpButton"]', newRow).hide();

            }
            else {


            // debugger ;
            $('button[data-mba-rest-view-ctrl-def-name="flagUndefer"]', newRow).hide();
            $('button[data-mba-rest-view-ctrl-def-name="flagDefer"]',   newRow).show();

            $('button[data-mba-rest-view-ctrl-def-name="fileUpButton"]', newRow).show();

	}

    if ( VALUE_DEFERRED_COMPLETE == "1" ) {
          $('button[data-mba-rest-view-ctrl-def-name="selectAsAudited"]', newRow).show();
          $('button[data-mba-rest-view-ctrl-def-name="flagDefer"]', newRow).show();

          //$('button[data-mba-rest-view-ctrl-def-name="fileUpButton"]', newRow).show();
    }
    else  {
          $('button[data-mba-rest-view-ctrl-def-name="selectAsAudited"]', newRow).hide();
          $('button[data-mba-rest-view-ctrl-def-name="flagDefer"]', newRow).hide();

          //$('button[data-mba-rest-view-ctrl-def-name="fileUpButton"]', newRow).hide();
    }

            return newRow;
        }


        $($restViewCtrlRmtsMoments).MBA_RestView(opts);

    }

    /*********************************************************** RMTS Service Records REST VIEW **************************************************************************************/
    function updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs(e) {
        // clear match selection in case anything is selected
        MOMENT_MATCHING_PROCESSOR.clearRmtsSvcRecSelection();

        //if (!($('#pracid').val())) return;

        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        if (!VALUE_CLIENT_ID) return;
        let VALUE_PRAC_ID = $('#' + PARM_NAME_PRAC_ID).val();
        if (!VALUE_PRAC_ID) return;

        let VALUE_ACTIVE = '1';

        let NV_CLIENT_ID  = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_ACTIVE     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);
        let NV_DATE_RANGE = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_SVC_DATE_RANGE, $('#' + PARM_NAME_SVC_DATE_RANGE).val());
        let NV_PRAC = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PRAC_ID, VALUE_PRAC_ID);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrlSvcRecs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrlSvcRecs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        $($restViewCtrlSvcRecs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_DATE_RANGE);

        $($restViewCtrlSvcRecs).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PRAC);

        $($restViewCtrlSvcRecs).MBA_RestView('requestViewFromServer', 1);

    };

    function initViewRmtsServiceRecs() {

        const CSS_CLASS_RMTS_MOMENT_TOGGLED = 'svcrec-is-rmts-moment';

        let opts = {};

        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = false; /* Turn off row numbers */
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = false;
        opts.enableRowControlRecEdit = false;
        opts.enableRowControlRecDelete = false;
        opts.positionUserDefinedControlsInBodyExisting = 2; /* Puts flag rmts to right of built in controls */



        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.ServiceRecords.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.ServiceRecord.DEFAULT_PAGING_ORDER%>';

        opts.enableReports = true;
        opts.enableReportHtml = true;
        opts.enableReportXls = true;
        opts.enableReportPdf = false;
        opts.loadModeReport = 'mbawebreport';
        opts.baseUrlReport = '<%=Spedmon.ServiceRecords.URL_WEB_REPORT_BASE()%>';
        opts.baseUrlReportHasParameters = true;
        opts.defaultReportNumber = '<%=Spedmon.ServiceRecordsRpt.REPT_NUM_VIEW_FOR_RMTS %>';

        opts.fieldDefinitions = [];
        opts.additionalControlDefinitionsForBodyRows = new Map();


	    <% //*************************************** Field Definitions *************************************************************%>

        <% // Service Record ID %>

        opts.fieldDefinitions.push({
            name: 'id',
            isRecID: true,
            editable: false,
            saveable: true,
            saveUsing: 'recid'
        });

        //opts.fieldDefinitions.push({
        //    name: 'id',
        //    label: 'ID',
        //    toolTip: 'ID',
        //    visible: true,
        //    editable: false,
        //    saveable: false,
        //    sortable: true,
        //    isRecID: false,
        //    dataType: 'number',
        //});

	    <% // Client ID %>

        opts.fieldDefinitions.push({
            name: 'clientID',
            visible: false,
            sortable: false,
            saveable: true,
            editable: false,
            isRecID: false,
            dataType: 'hidden',
            sortUsing: '',
            saveUsing: 'clientid',
            showMore: false
        });

	    <% // Practitioner Disp Group ID %>

        opts.fieldDefinitions.push({
            name: 'groupID',
            visible: false,
            sortable: false,
            saveable: true,
            editable: false,
            isRecID: false,
            dataType: 'hidden',
            sortUsing: '',
            saveUsing: 'groupid',
            showMore: false
        });

	    <% // Practitioner ID %>

        opts.fieldDefinitions.push({
            name: 'pracID',
            visible: false,
            sortable: false,
            saveable: true,
            editable: false,
            isRecID: false,
            dataType: 'hidden',
            sortUsing: '',
            saveUsing: 'pracid',
            showMore: false
        });

	    <% // Patient ID %>

        opts.fieldDefinitions.push({
            name: 'patID',
            visible: false,
            sortable: false,
            saveable: true,
            editable: false,
            isRecID: false,
            dataType: 'hidden',
            sortUsing: '',
            saveUsing: 'patid',
            showMore: false
        });

	    <% // Flagged As RMTS Moment %>

        opts.fieldDefinitions.push({
            name: 'rmtsMomentVal',
            visible: false,
            sortable: false,
            saveable: true,
            editable: false,
            isRecID: false,
            dataType: 'hidden',
            sortUsing: '',
            saveUsing: 'rmtsmoment',
            showMore: false
        });

	    <% // Fiscal Quarter %>

        opts.fieldDefinitions.push({
            name: 'quarter',
            label: 'Fiscal Quarter',
            toolTip: 'Fiscal Quarter',
            visible: true,
            sortable: true,
            saveable: false,
            editable: false,
            isRecID: false,
            dataType: 'text',
            sortUsing: 'quarter',
            saveUsing: '',
            showMore: false
        });

	    <% // Practitioner Name %>

        opts.fieldDefinitions.push({
            name: 'pracName',
            label: 'Practitioner<br>Last, First',
            toolTip: 'Practitioner who rendered the service',
            visible: true,
            sortable: true,
            saveable: false,
            editable: false,
            isRecID: false,
            dataType: 'lastfirst',
            sortUsing: 'pracName',
            saveUsing: '',
            showMore: false
        });

        //

	    <% // Patient Name %>

        opts.fieldDefinitions.push({
            name: 'patName',
            label: 'Patient<br>Last, First',
            toolTip: 'Patient who received the service',
            visible: true,
            sortable: true,
            saveable: false,
            editable: false,
            isRecID: false,
            dataType: 'lastfirst',
            sortUsing: 'patName',
            saveUsing: '',
            showMore: false
        });

	    <% // Service Date %>

        opts.fieldDefinitions.push({
            name: 'dosStr',
            label: 'Date of<br>Service',
            toolTip: 'The date the service was provided',
            visible: true,
            sortable: true,
            saveable: true,
            editable: false,
            isRecID: false,
            dataType: 'date',
            sortUsing: 'dos',
            saveUsing: 'dos',
            showMore: false
        });

	    <% // Has Service Detail Flags (Additional Cell in Service Selection) %>

        let nameIDAdditionalCellValueFieldDefinitions = [];

        nameIDAdditionalCellValueFieldDefinitions.push({
            name: 'hasSvcDetFlags',
            label: '',
            toolTip: '',
            visible: true,
            sortable: false,
            editable: true,
            saveable: true,
            isRecID: false,
            dataType: 'hidden',
            sortUsing: '',
            saveUsing: 'hasSvcDetFlags',
            showMore: false
        });

	    <% // Service Selection %>

        opts.fieldDefinitions.push({
            name: 'svcName',
            label: 'Service Provided',
            toolTip: 'The service that was provided',
            visible: true,
            sortable: true,
            editable: false,
            saveable: false,
            isRecID: false,
            dataType: 'text',
            sortUsing: 'svcName',
            showMore: false
        });

	    <% // Start Time %>

        opts.fieldDefinitions.push({
            name: 'startTimeStrHHMM',
            label: 'Start<br>Time',
            toolTip: 'The time that the service was provided',
            visible: true,
            sortable: true,
            saveable: true,
            editable: false,
            isRecID: false,
            dataType: 'time',
            sortUsing: 'startTimeVal',
            showMore: false,
            saveUsing: 'starttime'
        });

	    <% // Minutes %>

        opts.fieldDefinitions.push({
            name: 'numMins',
            label: 'Session<br>Minutes',
            toolTip: 'How many minutes it took to provide the service',
            visible: true,
            sortable: true,
            saveable: false,
            editable: false,
            isRecID: false,
            dataType: 'number',
            sortUsing: 'numMins',
            saveUsing: 'nummin',
            showMore: false
        });

	    <% // Attendance Status %>

        opts.fieldDefinitions.push({
            name: 'attendanceStatusSelectionName',
            label: 'Attendance',
            toolTip: 'The attendance status for the practitioner and patient',
            visible: false,
            sortable: true,
            editable: false,
            saveable: true,
            sortUsing: 'attendanceStatusSelectionName',
            isRecID: false,
            dataType: 'text',
            showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'RmtsAuditReqID',
            label: 'RmtsAuditReqID',
            visible: false,
            sortable: false,
            editable: false,
            saveable: false,
            sortUsing: 'RmtsAuditReqID',
            isRecID: false,
            dataType: 'number',
        });

        opts.additionalControlDefinitionsForBodyRows.set('selectAsAudited', {
            defType: 'userprovided',
            name: 'selectAsAudited',
            toolTip: 'Click Here to Associate with RMTS Audit Request',
            cssClass: 'fa fa-thumbs-up',
            handlerFn: function (uiActionObj) {
                MOMENT_MATCHING_PROCESSOR.selectRmtsServiceRec(uiActionObj.recordID, $(uiActionObj.whatElement).find('i')[0]);

                return uiActionObj;

            },
            initiallyHidden: true //
        });

        opts.additionalControlDefinitionsForBodyRows.set('deselectAsAudited', {
            defType: 'userprovided',
            name: 'deselectAsAudited',
            toolTip: 'Click Here to Unmatch from RMTS Audit Request',
            cssClass: 'fa fa-thumbs-up text-success',
            handlerFn: function (uiActionObj) {

                let auditRecID = $(uiActionObj.whatRow).find('[data-mba-rest-view-field-name="RmtsAuditReqID"][data-mba-rest-view-ui-element-type="fieldvalue"]').text();
                if (auditRecID) {

                    unMatchAuditRecs(uiActionObj, auditRecID);

                } else {
                    $.spedmonWebUI.dialogMessage('ERROR', 'This record is not matched with an RMTS moment', null, 400, 200, null, null, null);
                }

                return uiActionObj;
            },
            initiallyHidden: true //
        });

        opts.additionalControlDefinitionsForBodyRows.set('infoHoverButton', {
            defType: 'userprovided',
            name: 'infoHoverButton',
            toolTip: '',
            cssClass: 'fas fa-info-circle',
            handlerFn: function (uiActionObj) {
                return uiActionObj;
            },
            initiallyHidden: true
        });

        <% // Flag Service As RMTS Moment %>



	    opts.additionalControlDefinitionsForBodyRows.set('flagasrmtsmoment', {
		    defType: 'userprovided',
		    name: 'flagasrmtsmoment',
		    toolTip: 'Click Here to Flag This Service as an RMTS Moment',
		    cssClass: 'far fa-clock',
		    handlerFn: function(uiActionObj) {

			    var uiAtarget = $(uiActionObj.e.target);
			    uiAtarget.removeClass('far').removeClass('fa-clock').addClass('fas fa-hourglass-half');

			    let _svcrecid = uiActionObj.recordID;
			    let _clientid = uiActionObj.whatFieldCellsInputValues.get('clientID');
			    let _pracid = uiActionObj.whatFieldCellsInputValues.get('pracID');
			    let _isRMTSMoment = '';
			    var $cIcon = $(uiActionObj.whatElement).children('i.fa-clock')[0];

			    /* Set new value */

			    _isRMTSMoment = 'y';
			    if ($($cIcon).hasClass(CSS_CLASS_RMTS_MOMENT_TOGGLED)) {
				    _isRMTSMoment = 'n';
			    }

			    let _reqObj = {};
			    _reqObj.clientid = _clientid;
			    _reqObj.pracid = _pracid;
			    _reqObj.isrmtsmoment = _isRMTSMoment
			    _reqObj.recid = _svcrecid;

			    let _elem = uiActionObj.dataObj.me;
                let reqUrl = '<%=Spedmon.ServiceRecords.URL_FLAG_EXISTING_AS_RMTS_MOMENT_INLINE_BASE()%>';
                let reqData = JSON.stringify(_reqObj);

                MBA.RestViewCommon.fnAjaxCallAsmxWebMethod(_elem, reqUrl, reqData)
                    .then(responseData => {
                        updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs();
                    })
                    .catch(responseData => {

                        if (responseData.message) {
                            $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                        }
                        else {
                            $('body').mbaHighlight({ color: "#bdffc7", duration: 500 });
                        }

                        updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs();

                    });

                //return uiActionObj;

                return;
            },
            initiallyHidden: false
        });



        <% //*************************************** Row Creation Hooks *************************************************************%>

        opts.fnCreateNewRowBefore = function (newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {
            if (!rowData) return newRow;

            if (rowData && (rowData.WhoWereYouWith || rowData.WhatWereYouDoing)) {

                opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').initiallyHidden = false;

                opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').initiallyHidden = false;
                opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').toolTip =
                    'I was with - ' + rowData.WhoWereYouWith + ' - ' + rowData.WhatWereYouDoing;

            } else if (rowtype != 1) {

                opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited').initiallyHidden = false;

                opts.additionalControlDefinitionsForBodyRows.get('infoHoverButton').initiallyHidden = true;

            }

            return newRow;
        }

        opts.fnCreateNewRowAfter = function ($newRow, section, subsection, rowtype, opts, thTemplate, rowCtrVal, rowCtrlDefs, rowData) {

            // for some reason, without this piece of code, both icons appear at the same time
            opts.additionalControlDefinitionsForBodyRows.get('selectAsAudited').initiallyHidden = true;
            opts.additionalControlDefinitionsForBodyRows.get('deselectAsAudited').initiallyHidden = true;

              <%
              // TODO!  The logic here seemes to conflict with the show/hide logic in the hook function fnCreateNewRowBefore().
              //        Consider reverse-engineering and simplifying, next time we are forced to do a major bugfix or reimplementation pertaining to these pages.
              %>

            if (!rowData) return $newRow;

            //debugger;

            <% // Set initial state for RMTS icon %>

            let _rmtsButIcon = $($newRow).find('button[data-mba-rest-view-ctrl-def-name="flagasrmtsmoment"] > i.fa-clock')[0];

            if (_rmtsButIcon && rowData.rmtsMomentVal === true) {
                $(_rmtsButIcon).addClass(CSS_CLASS_RMTS_MOMENT_TOGGLED);
            }

            return $newRow;
        }


        $($restViewCtrlSvcRecs).MBA_RestView(opts);
    }



    $(document).ready(function () {
        $dataManagementRows      = $('#dataManagementRows');
        $restViewCtrlRmtsMoments = $('#restViewRmtsMoments');
        $restViewCtrlSvcRecs     = $('#restViewServiceRecs');


          $('#deferredcomplete').val('<%= deferredValIn %>');

        ///
        $('#daterange').val('<%= dateRangePrefill %>');

        initViewMomentsReq();
        initViewRmtsServiceRecs();



        $($dataManagementRows).on('spedmoninputdata', function (e) {

            updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMoments(e);
            updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs(e);

        });

        <%if (okToPreload == true) {%>
          updateAdditionalViewParameterValuesAndRequestViewFromServer_rmtsMoments(null);
          updateAdditionalViewParameterValuesAndrequestViewFromServer_rmtsServiceRecs(null);
        <%}%>

    });
</script>
