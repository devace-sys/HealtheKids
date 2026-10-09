<%@ Page Language="C#" CodeBehind="user_all_rmts_healthdash_stats.aspx.cs" Inherits="Spedmon.UserAllRmtsHealthdashStats"%>



  <div class="row" id="wrapCliIDRow" >
    <div class="col-12">
      <Spedmon:DataEntryRowSelectClient
        ID                                  = "selectClient"
        rowLabel                            = "Client"
        showDataSourceSelection             = "false"
        saveDataSourceSelectedAsPreference  = "false"
        dataEntryRowRenderAs                = "FIELD"
        showClearSelection                  = "true"
        runat                               = "server">
      </Spedmon:DataEntryRowSelectClient>
    </div> <!-- col -->

  </div> <!-- row -->

  <% if ( ispreview == "1" ) { %>
    <div class="row align-items-center m-0">

      <div class="col-4"></div>
      <h3 class="mba-action-item-common mba-action-item-common-label d-flex col-4">RMTS</h3>
      <div id="colwrap-navbutton" class="col-4">

  <% if ( isPcalStaff && ( ispreview == "1" ) ) { %>
      <div class="w-90 mr-4 my-2 text-right">
        <button class="btn btn-warning mba-web-ui-link-internal mba-web-ui-link-internal-button"
         type="button"
         id="gotodetailedfigures" title="Click here to view additional statistical subtotals and the relevant links for itemized breakdown">
           <span class="mba-web-ui-link-internal mba-web-ui-link-internal-label">
           <strong>KPI Detailed Metrics</strong></span>
             <i class="fas fa-hand-point-right mba-web-ui-link-internal-icon"></i>
        </button>
      </div>
  <% } %>

      </div>
    </div>

  <% } else { %>

    <h3 class="mba-action-item-common mba-action-item-common-label flex-grow-1">RMTS KPI Detailed Metrics</h3>

  <% } %>


  <div class="mx-4 py-1 w-80">


     <% if (ispreview == "1" ) { %>


		   <div class="row justify-content-around mb-1">

		    <div class="w-20">

		       <section class="bg-light mba-action-item-common-container" >
		         <h4 class="mba-action-item-common-label">Missing Recorded Services</h3>
		         <a class="a-statlink" id="aLinkNumCountRmtsPracsNoSvcs" ><h3 id="numCountRmtsPracsNoSvcs" class="text-center text-warning num-statlink">00</h2></a>
		       </section>

		    </div>


		    <div class="w-20">

               <!-- This gets rendered both screens -->
		       <section class="bg-light mba-action-item-common-container" >
		         <h4 class="mba-action-item-common-label">Missing 2A Documentation</h3>
		         <a class="a-statlink" id="aLinkNumMissing2ADoc"><h3 id="numCountMissing2ADoc" class="text-center text-warning num-statlink">00</h2></a>
		       </section>

		    </div>

		    <div class="w-20">

		       <section class="bg-light mba-action-item-common-container" >
		         <h4 class="mba-action-item-common-label">Deferred 2A Moments</h3>
		         <a class="a-statlink" id="aLinkNumCountRmts2ADeferred"><h3 id="numCountRmts2ADeferred" class="text-center text-warning num-statlink">00</h2></a>
		       </section>

		    </div>

		    <div class="w-20">

		       <section class="bg-light mba-action-item-common-container" >
		         <h4 class="mba-action-item-common-label">Coding Appeals</h3>
		         <a class="a-statlink" id="aLinkNumPossibleAppeals"><h3 id="numCountPossibleAppeals" class="text-center text-warning num-statlink">00</h2></a>
		       </section>

		    </div>

		  </div><!--  one horizontal row of squares  -->


     <% } else { %>




		   <div class="row justify-content-around mb-1">

		    <div class="col-2">
		       <section class="bg-light mba-action-item-common-container" >
		         <h4 class="mba-action-item-common-label">Unmatched 2A Moments</h3>
		         <h3 id="numCountUnmatched2A" class="text-center text-warning num-statlink">00</h2>
		       </section>

		    </div>


		    <div class="col-2 mr-4">

               <!-- This gets rendered both screens -->
		       <section class="bg-light mba-action-item-common-container" >
		         <h4 class="mba-action-item-common-label">Missing 2A Documentation</h3>
		         <h3 id="numCountMissing2ADoc" class="text-center text-warning num-statlink">00</h2>
		       </section>

		    </div>

		    <div class="col-2 ml-4">

		       <section class="bg-light mba-action-item-common-container" >
		         <h4 class="mba-action-item-common-label">2A Moments W/ Uploads Only</h3>
		         <h3 id="numCountRmts2AUploadsOnly" class="text-center text-warning num-statlink">00</h2>
		       </section>

		    </div>

		    <div class="col-2">

		       <section class="bg-light mba-action-item-common-container" >
		         <h4 class="mba-action-item-common-label">Missing Recorded Services</h3>
		         <a class="a-statlink" id="aLinkNumCountRmtsPracsNoSvcs" ><h3 id="numCountRmtsPracsNoSvcs" class="text-center text-warning num-statlink">00</h2></a>
		       </section>

		    </div>

		  </div><!--  first horizontal row of squares (not using the row class) -->


		   <div class="d-flex w-100 justify-content-between">

		    <div class="col-2">
		       <section class="mba-action-item-common-container bg-light" >

		         <h4 class="mba-action-item-common-label">Awaiting Coord Confirm</h3>
		         <h3 id="numCountRmts2ANeedsCoordConfirm" class="text-center text-warning num-statlink">00</h2>
		       </section>

		    </div>

		    <div class="col-2">

		       <section class="bg-light mba-action-item-common-container" >
		         <h4 class="mba-action-item-common-label">2A Moments Action Required</h3>
		         <h3 id="numCountRmts2ANeedsAttn" class="text-center text-warning num-statlink">00</h2>
		       </section>

		    </div>

		    <div class="col-2">

		       <section class="bg-light mba-action-item-common-container" >
		         <h4 class="mba-action-item-common-label">Deferred 2A Moments</h3>
		         <a class="a-statlink" id="aLinkNumCountRmts2ADeferred"><h3 id="numCountRmts2ADeferred" class="text-center text-warning num-statlink">00</h2></a>
		       </section>

		    </div>


		    <div class="col-2">

		       <section class="bg-light mba-action-item-common-container" >
		         <h4 class="mba-action-item-common-label">Awaiting Code Review</h3>
		         <a class="a-statlink" id="aLinkNumAwaitingCodeReview"><h3 id="numCountAwaitingCodeReview" class="text-center text-warning num-statlink">00</h2></a>
		       </section>

		    </div>

		    <div class="col-2">

		       <section class="bg-light mba-action-item-common-container" >
		         <h4 class="mba-action-item-common-label">Coding Appeals</h3>
		         <a class="a-statlink" id="aLinkNumPossibleAppeals"><h3 id="numCountPossibleAppeals" class="text-center text-warning num-statlink">00</h2></a>
		       </section>

		    </div>


		  </div><!--  second horizontal row of squares (not using the row class) -->


     <% } %>

  </div>



<script  type="text/javascript">

    function initDashBoard2AMomentStats(clientid) {

        if (!( clientid )) {
           clientid = $('#clientid').val() ;
        }

        $('#gotodetailedfigures').off();
        $('#gotodetailedfigures').on('click',

          function() {

            $.spedmonWebUI.openNewWindowLargeWithOpts(
              '<%= Spedmon.RmtsMomentMissingOrUndocumentedStatsObjs.URL_PAGE_STATSDASH_BASE() %>' +
              '&clientid=' + clientid
            );
        });

        reqUrl = '<%= Spedmon.RmtsMomentMissingOrUndocumentedStatsObjs.URL_STATS_MISSING_FOR_CLIENT_BASE() %>';

        reqJSON = JSON.stringify({  clientid: clientid  }) ;

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqJSON, null)

            .then(responseData => {

                rrraw = responseData.rawData.data;

                $('#numCountRmts2AUploadsOnly').text(
                  rrraw.numUploadedDocumentationOnly
                );

                $('#numCountRmts2ANeedsAttn').text(
                  rrraw.numActionRequired
                );

                $('#numCountRmts2ANeedsCoordConfirm').text(
                  rrraw.numAwaitingCoord
                );


                $('#numCountMissing2ADoc').text(
                  rrraw.numNoDocsActionRequired
                );

                $('#numCountUnmatched2A').text(
                  rrraw.numUnmatchedActionRequired
                );

                $('#aLinkNumMissing2ADoc').off();
                $('#aLinkNumMissing2ADoc').on('click',
                  function() {

                    $.spedmonWebUI.openNewWindowLargeWithOpts(

                     '<%= Spedmon.RmtsMoments.URL_MANAGE_BASE() %>' +
                     '&clientid=' + clientid
                  );
                });

                $('#numCountRmts2ADeferred').text(
                  rrraw.numDeferred
                );

                $('#aLinkNumCountRmts2ADeferred').off();
                $('#aLinkNumCountRmts2ADeferred').on('click',
                  function() {

                    $.spedmonWebUI.openNewWindowLargeWithOpts(

                     '<%= Spedmon.RmtsMoments.URL_MANAGE_BASE() %>' +
                     '&clientid=' + clientid +
                     '&deferred=1'
                  );
                });

                $('#numCountRmtsPracsNoSvcs').text(
                  rrraw.numParticipantsWoSvcrecs
                );


                $('#aLinkNumCountRmtsPracsNoSvcs').off();
                $('#aLinkNumCountRmtsPracsNoSvcs').on('click',
                  function() {

                    $.spedmonWebUI.openNewWindowLargeWithOpts(
                      '<%= Spedmon.RmtsParticipantsWoSvcRecs.URL_PAGE_VIEW_BASE() %>' +
                      '&clientid=' + clientid
                  );
                });

                $('#numCountAwaitingCodeReview').text(
                  rrraw.numAwaitingCodeReview
                );

                $('#aLinkNumAwaitingCodeReview').off();
                $('#aLinkNumAwaitingCodeReview').on('click',
                  function() {

                    $.spedmonWebUI.openNewWindowLargeWithOpts(
                      '<%= Spedmon.RmtsMoments.URL_REVIEW_BASE() %>' +
                      '&clientid=' + clientid
                  );
                });

                $('#numCountPossibleAppeals').text(
                  rrraw.numPossibleAppeals
                );

                $('#aLinkNumPossibleAppeals').off();
                $('#aLinkNumPossibleAppeals').on('click',
                  function() {

                    $.spedmonWebUI.openNewWindowLargeWithOpts(
                      '<%= Spedmon.RmtsMoments.URL_REVIEW_BASE() %>' +
                      '&clientid=' + clientid + '&possible_appeal=1'
                    );
                });

            })
            .catch(responseData => {

            });

    }

    $(function() {

      $('#wrapCliIDRow').on('spedmoninputdata', function() { initDashBoard2AMomentStats() } );

      <% if (!String.IsNullOrEmpty(clientIDStr)) { %>
        initDashBoard2AMomentStats( '<%= clientIDStr %>' );
      <% } %>

    });

</script>
