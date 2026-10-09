<%@ Page Language="C#" CodeBehind="user_all_client_compliance_manage.aspx.cs" Inherits="Spedmon.userAllClientComplianceManage" %>


<%//-----------------------------------------------------------------------------%>
<%// Create New and Edit Existing Tasks %>
<%//-----------------------------------------------------------------------------%>

<span class="<%= wrapDataEntryRowsSpanClass %>" >

<div id="dataEntryRows" >

<div class="row justify-content-center mb-2">

<%//-----------------------------------%>
<%// Select Compliance Task            %>
<%//-----------------------------------%>

<div class="col-auto">
  <div style="display:flex">

  <Spedmon:DataEntryRowSelectClientComplianceTask
   ID                    = "selectTask"
   entityControlID       = "taskid"
   rowLabel              = "Task"
   useBootstrapGrid      = "false"
   selectTitle           = "Select a Task"
   onSpedmonInputData    = "loadClientComplianceItemIfExists(e);"
   runat                 = "server">
  </Spedmon:DataEntryRowSelectClientComplianceTask>

 <button type="button" onclick="launchSaveNewTaskDialog()" style="display:inline-block;background:transparent;border:none;">
 <i title="Add a New Task" class="mba-rest-view mba-rest-view-ctrl-icon fa fa-plus" ></i>
 </button>
 </div>

</div>

<%//-----------------------------------%>
<%// Due Date                          %>
<%//-----------------------------------%>

<div class="col-auto">
<Spedmon:DataEntryBoxDate ID="duedate" name="duedate" label="Due On" size="10" runat="server"/>
</div>

<%//-----------------------------------%>
<%// Date to Show on Dashboard         %>
<%//-----------------------------------%>

<div class="col-auto">
<Spedmon:DataEntryBoxDate id="datetoshowondashboard" name="datetoshowondashboard" label="Show On Dashboard On" size="10" runat="server" />
</div>



<%//-----------------------------------%>
<%// All clients?         %>
<%//-----------------------------------%>

<div class="col-auto">
<label>Create for all clients?</label>
<br/> <!-- might be better to do this with flex align column, or whatever -->
<input type="checkbox" id="createforallclients" name="createforallclients"  />
</div>


<%//-----------------------------------%>
<%// Status                            %>
<%//-----------------------------------%>

<div class="col-auto">
<Spedmon:DataEntryRow rowLabel="Status" useBootstrapGrid="false" runat="server">
  <select id="iscomplete" name="iscomplete">
  <option value="">--Please choose an option--</option>
  <option value="1">Complete</option>
  <option value="0">Incomplete</option>
  </select>
</Spedmon:DataEntryRow>
</div>

<%//-----------------------------------%>
<%// Save                              %>
<%//-----------------------------------%>

<div class="col-auto">
<Spedmon:DataEntryRowSaveOrEdit
        ID="saveOrEdit"
        useBootstrapGrid ="false"
        includeSecondarySaveButton="true"
        secondarySaveButtonLabel="Save & Proceed"
        secondarySaveButtonOnClick="saveClientComplianceItem(e)"
        includeSaveAndProceedButton="false"
        includeCancelButton="false"
        setRowLabelToAttestStatement = "false"
        useDefaultAdditionalRowClass = "false"
        rowLabel=""
        runat="server">
    </Spedmon:DataEntryRowSaveOrEdit>
</div>
</div>

</div>

</span>

<%//-----------------------------------------------------------------------------%>
<%// Manage Existing Task Status                                                 %>
<%//-----------------------------------------------------------------------------%>

<div id="dataManagementRows" >



     <div class="row py-2 justify-content-center">
       <div class="col-auto">

         <Spedmon:DataEntryRowSelectFiscalYear
            ID                   = "selectFiscalYear"
            entityControlID      = "fiscalyearid"
            rowLabel             = "Year"
            dataEntryRowRenderAs = "FIELD"
            runat                = "server">
         </Spedmon:DataEntryRowSelectFiscalYear>

       </div>

    </div>

      <div class="row py-2 mx-1 justify-content-between">

     <div class="col-6">
     <div class="row">

      <%//-----------------------------------%>
      <%// Select Client                     %>
      <%//-----------------------------------%>

      <div class="<%= divDataManagementRowsClass %>" >



            <Spedmon:DataEntryRowSelectClient
                ID                   = "selectClient"
                entityControlID      = "clientid"
                rowLabel             = "Client"
                dataEntryRowRenderAs = "FIELD"
                onSpedmonInputData   = ""
                runat                = "server">
            </Spedmon:DataEntryRowSelectClient>


      </div>

     </div>

     </div>




     <div class="col-12 col-lg-6">


        <div class="col-auto">
          <input type="hidden" id="<%=Constants.PARM_IS_NOT_COMPLETED%>" value="1"  />
          <input type="hidden" id="<%=Constants.PARM_IS_COMPLETED%>" />
          <input type="hidden" id="<%=Constants.PARM_IS_PENDING%>" />

           <Spedmon:RadioBox
              ID="itemstatus"
              name="itemstatus"
              title="Select Status"
              renderLabel="false"
              additionalCssClassNameForContainer="d-flex justify-content-end modern2021"
              onSelectValue="function(oldval,newval){  MBA.ClientComplianceTasks.resetItemStatusFilterFlags(oldval, newval);}"
              runat="server" />
        </div>
    </div>

    </div>

</div>
<div>

    <%//-----------------------------------%>
    <%// Rest View                         %>
    <%//-----------------------------------%>

    <div class="row mx-2">
        <div class="col-12">
            <div id="restViewComplianceMgmt">
            </div>
        </div>
        <!-- col -->
    </div>
    <!-- row -->
</div>

<% if (isRestviewPreview != "0") { %>

   <div class="row">
       <div class="col-8"></div>
       <div class="col-4 text-center">
           <a href="<%= MBA.HttpApplication.createLink( "user_all_client_compliance_manage.aspx" , true ) %>">
               View All Results<i class="fas fa-hand-point-right fa-2x m-2 text-dark"></i>
           </a>
       </div>
   </div>

<% } %>

<%/****************************
   * Scripts for options
   ****************************/%>

<script type="text/javascript">

    var $dataEntryRows      = $('#dataEntryRows');
    var $dataManagementRows = $('#dataManagementRows');

    //var $restViewCtrl       = null;
    //var $taskID             = null;
    //var $isComplete         = null;


    function resetClientComplianceItemForm() {
      $dataEntryRows.trigger("reset");
      $("#savetype").val($.spedmonWebUI.RECORD_SAVE_TYPE_NEW);
      $("#recid").val('');
    }

    function $generateSaveNewTaskDialogContent() {
        let $dialogDiv = $('<div></div>');

        let $innerContainer = $('<div class="d-flex flex-row justify-content-center align-items-center"></div>');

        // name input
        let $name = $('<input id="name" name="name" value="" title="Name" class="mr-2 mba-web-ui-field-no-submit mba-web-ui-field-data-entry-primary mba-web-ui-field-input-base ui-spedmon-box ui-widget-content ui-corner-all" type="text" placeholder="Name" />');

        // save
        let $saveBtn = $('<i title="Save" class="mba-rest-view mba-rest-view-ctrl-icon fa fa-save fa-2xl"></i>');
        $saveBtn.on("click", function () {
            saveNewTask($name.val());
            $dialogDiv.dialog('close');
        });

        // append elements to container
        $innerContainer.append($name);
        $innerContainer.append($saveBtn);

        $dialogDiv.append($innerContainer);
        return $dialogDiv;
    }

    function launchSaveNewTaskDialog() {
        let $dialogDiv = $generateSaveNewTaskDialogContent();

        $dialogDiv.dialog(
            {
                width: $(window).width() / 1.5
                , height: $(window).height() / 2
                , title: '<strong>Please Provide a Name</strong>'
                , modal: true
                , show: {
                    effect: 'slide'
                    , direction: 'left'
                    , complete: function () { }
                }
                , hide: {
                    effect: 'slide'
                    , direction: 'left'
                }
                , close: function (event, ui) { $dialogDiv.remove(); }
            });
    }



    // not used now, as removing (some of) the controls from the page
    // was part of the spec; consider removing these function definitions later                                              

    saveClientComplianceItem  =  function (e) {
		
		
		let taskID                = $('#taskid').val();
                                    // hardcoded like the others
		let dueDate               = $('#duedate').val();
		let dateToShowOnDashboard = $('#datetoshowondashboard').val();
		let isComplete            = $('#iscomplete').val();

                let forAllClients         = $('#createforallclients').val();

                let clientID              = $('#clientid').val();

		
		// validate inputs
		if (!taskID) {
		    $.spedmonWebUI.dialogMessage('ERROR', "Please select a task", null, 400, 200, null, null, null);
		    return;
		}
		if (!dueDate) {
		    $.spedmonWebUI.dialogMessage('ERROR', "Please select a due date", null, 400, 200, null, null, null);
		    return;
		}
		if (!dateToShowOnDashboard) {
		    $.spedmonWebUI.dialogMessage('ERROR', "Please select a date to show on dashboard", null, 400, 200, null, null, null);
		    return;
		}
		
		
		
		var reqUrl = '<%=Spedmon.ClientComplianceCommon.URL_SAVE_FOR_CLIENTS_BASE()%>';
		
		
		var reqData = JSON.stringify({
		      "savetype"             : $('#savetype').val()
		    , "recid"                : $('#recid').val()
		    , "taskid"               : taskID
		    , "duedate"              : dueDate
		    , "datetoshowondashboard": dateToShowOnDashboard
		    , "iscomplete"           : isComplete
                    , "forallclients"        : ( forAllClients ? "1" : "0")
                    , "clientid"             : clientID
		});
		
		MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
		    .then(responseData => {
		        resetClientComplianceItemForm();
		        $('body').mbaHighlight({ color: "#bdffc7", duration: 500 });
                MBA.ClientComplianceTasks.fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer();
		        
		    })
		    .catch(responseData => {
		        $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
		    });
    };

    loadClientComplianceItemIfExists = function (e) {
          
          var reqUrl =  '<%=Spedmon.ClientComplianceItems.URL_LOAD_N_BASE()%>';


          var reqData = JSON.stringify({
              "taskid" : e.dataitem.id
            , "recid"  : null
          });

          MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                populateClientComplianceItemForm(responseData.rawData.entity);
            })
            .catch(responseData => {
                $("#savetype").val($.spedmonWebUI.RECORD_SAVE_TYPE_NEW);
                $("#recid").val('');
                $("#duedate").val('');
                $("#datetoshowondashboard").val('');
            });
    }


    saveNewTask = function(name) {
	    
	    var reqUrl = '<%=Spedmon.ClientComplianceTasks.URL_SAVE_BASE()%>';
	
	
	    var reqData = JSON.stringify({
	          "savetype": $.spedmonWebUI.RECORD_SAVE_TYPE_NEW
	        , "name"    : name
	    });
	
	    MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
	        .then(responseData => {
	            $('body').mbaHighlight({ color: "#bdffc7", duration: 500 });
	        })
	        .catch(responseData => {
	            $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
	        });
   }



    var restView_optsIn = {};

    restView_optsIn.dataEntryRowsDivID         = 'dataEntryRows'           ;
    restView_optsIn.dataManagementDivID        = 'dataManagementRows'      ;
    restView_optsIn.restViewDivID              = 'restViewComplianceMgmt'  ;
    
    restView_optsIn.PARM_NAME_CLIENT_ID        = '<%=Constants.PARM_CLIENT_ID%>';
    restView_optsIn.PARM_NAME_TASK_ID          = '<%=Constants.PARM_TASK_ID%>';
    restView_optsIn.PARM_NAME_IS_COMPLETE      = '<%=Constants.PARM_IS_COMPLETE%>';
    restView_optsIn.PARM_NAME_IS_PENDING       = '<%=Constants.PARM_IS_PENDING%>';
    restView_optsIn.PARM_NAME_IS_NOT_COMPLETED = '<%=Constants.PARM_IS_NOT_COMPLETED%>';
    restView_optsIn.PARM_NAME_IS_COMPLETED     = '<%=Constants.PARM_IS_COMPLETED%>';

    restView_optsIn.PARM_NAME_FY_ID     = '<%=Constants.PARM_FISCAL_YEAR_ID %>';

    restView_optsIn.PARM_NAME_REP_ID     = '<%=Constants.PARM_REP_ID %>';

    restView_optsIn.generateSessionExpiredLink   =   '<%=MBA.Credential.generateSessionExpiredLink()%>';
    restView_optsIn.sessionTimeOutUrl            =   restView_optsIn.generateSessionExpiredLink;


    restView_optsIn.URL_SAVE_BASE                =   '<%=Spedmon.ClientComplianceClientItems.URL_SAVE_BASE()%>';
    restView_optsIn.baseUrlEdit                  =   restView_optsIn.URL_SAVE_BASE;


    restView_optsIn.URL_REST_VIEW_BASE           =   '<%=Spedmon.ClientComplianceClientItems.URL_REST_VIEW_BASE()%>';
    restView_optsIn.baseUrlView                    =   restView_optsIn.URL_REST_VIEW_BASE;

    restView_optsIn.defaultPageRowOrder          =   '<%=Spedmon.ClientComplianceClientItem.DEFAULT_PAGING_ORDER%>';


    restView_optsIn.reportBaseUrl                =  '<%= Spedmon.ClientComplianceClientItems.URL_WEB_REPORT_BASE() %>'


    restView_optsIn.isPcalStaff = <%= ( isPcalStaff ? 1 : 0 ) %> ;
    restView_optsIn.isRestviewPreview = <%= isRestviewPreview %> ;

    restView_optsIn.URL_DELETE_INLINE_BASE      =   '<%= Spedmon.ClientComplianceClientItems.URL_DELETE_INLINE_BASE() %>';

    restView_optsIn.enableScrollView  = false;


    $(document).ready( function(){ MBA.ClientComplianceTasks.fnSetup(restView_optsIn)  } );


    $( '#taskid' ).on('spedmoninputdata', function ( e ) {
        
       MBA.ClientComplianceTasks.fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer();

    });




</script>
