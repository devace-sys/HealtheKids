<%@ Page Language="C#" CodeBehind="user_all_service_journals_journal_entry_save.aspx.cs"
  Inherits="Spedmon.user_all_service_journals_journal_entry_save" %>

<%-- dialog that contains the additional orp questions (displayed when an orp service is selected) --%>

<div id="orpDocCont" class="text-center" title="This Service Requires The Selection of an Order Or Prescription">
    <div class="ui-spedmon-step-instructions">Please select the order or prescription that is associated with this service from the drop-down below then click OK.</div>
    <div id="orpInputFieldPlaceHolder"></div>
    <Spedmon:Button title = "OK" ID = "selORPDocIDOK" runat = "server">
      OK
    </Spedmon:Button>
    <div class="additional-info-below-select-entity">
        If you do not see any applicable orders or prescriptions in the drop-down above, click &nbsp;
		
        <Spedmon:Button title = "Click here to add a new order or prescription" ID = "addOrdPres" runat = "server"
            onclick="$.spedmonWebUI.openAddNewServiceJournalsPrescribedOrderForm(null, null, null, null, null, null);">
            Add A New Order or Prescription
        </Spedmon:Button>
        &nbsp; then try your selection again.
    </div>
</div>

 <%if (journalIsReopened == true) { %>    
   <div style="margin-top:1em;margin-bottom:1em;">
   <Spedmon:Instructions ID="closeJournalNotice" renderBrs="false" instructionWidth="50%" title="Please Close This Journal When You Are Done Making Changes" instructionState="" runat="server">
     This journal has been reopened so changes can be made. <Spedmon:Button ID="closeJournalBut" onclick="doGoClose()" runat= "server">Close This Journal</Spedmon:Button> 
   </Spedmon:Instructions>
   </div>
  <%}%>
   
 <%if (!String.IsNullOrEmpty(svcrectocorrectid)) { %>    
   <div style="margin-top:1em;margin-bottom:1em;">
   <Spedmon:Instructions ID="holdReasonText" renderBrs="false" instructionWidth="50%" title="Notes From Your Supervisor" instructionState="" runat="server">
     <%=holdReason %>
   </Spedmon:Instructions>
   </div>
  <%}%>

<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>

<Spedmon:DataEntryRows purpose="SAVE" dataURL="servicejournalsjournalentries.asmx/save" useBootstrapFluid="true" runat="server">

    <%//##################################################################################################################%>
    <%//#                                         Journal Edit Fields                                                     %>
    <%//##################################################################################################################%>     

    <div class="row">

    
    <div class="col-12">
    <div id="svc_journal_edit_fields" class="d-flex flex-wrap align-items-center">
            
        <%//-----------------------------------------------------------------------------%>
        <%// Hidden patients field%>
        <%//-----------------------------------------------------------------------------%>

        <Spedmon:DataEntryRowSelectPatient
            ID                                  = "selectPatient" 
            rowLabel                            = "Patient?" 
            entityControlID                     = "patid"
            dataEntryRowRenderAs                = "FIELD"
            preSelectedDataSource               = "ALL_PATIENTS"
            showDataSourceSelection             = "false"
            showAddNew                          = "true" 
            showEditSelected                    = "false"
            singleSelectClearAfterSelection     = "false"
            selectCtrlNoSubmit                  = "false"
            selectCtrlNoClear                   = "false"
            entryAllowed                        = "true"
            entryNotAllowedUseReplacementValue  = "false"
            runat                               = "server">
        </Spedmon:DataEntryRowSelectPatient>

        <span class="font-weight-bold mr-3">
            <%=patName%>
        </span>
       
        <Spedmon:DateBoxHTML5 ID="dos" name="dos" title="dos" cssClass="mr-3" runat="server" /> 

        <i class="fas fa-save"></i>

    </div> 
    </div> <!-- col -->
    </div> <!-- row -->
    
    <div class="row">
    <div class="col-12">
    <%//-----------------------------------------------------------------------------%>
    <%// Plus icon to add a row to table %>
    <%//-----------------------------------------------------------------------------%>
   
    <%if (uInfo.userRole.ToLower() == Constants.ROLE_LEA_PROVIDER || this.pracID != null || this.pracID != "0" ) { %>
        <i id="addNewService" class="fa fa-plus" title="Add New Record"></i>
    <%} %>
    </div> <!-- col -->
    <div class="col-12">
    <%//-----------------------------------------------------------------------------%>
    <%// Enter Details %>
    <%//-----------------------------------------------------------------------------%>
            
   <Spedmon:HiddenTextArea ID="svcjournalForDOSJSON" name="svcjournalForDOSJSON" title="svcjournalForDOSJSON" runat="server" />
   
   <table id="tblsvcjournalForDOSJSON" class="ui-spedmon-gradient-data-table">
       <thead>
         <tr>
           <th></th>
           <th></th>
           <th></th>
           <th>Plan Type</th>
           <th>Service Provided</th>
           <th>Start Time</th>
           <th>End Time</th>
           <th>Notes</th>
         </tr>
       </thead>
       <tbody id="tblsvcjournalForDOSJSONBody">
       </tbody>
    </table>

    <%//-----------------------------------------------------------------------------%>
    <%// Required Hidden Params %>
    <%//-----------------------------------------------------------------------------%>
    
    <Spedmon:HiddenInput ID="clientid"            name="clientid"      title = "Client id"          noClear ="true" runat="server"/>
    <Spedmon:HiddenInput ID="patname"             name="patname"       title = "Patient name"       noClear ="true" runat="server"/>
    <Spedmon:HiddenInput ID="pracid"              name="pracid"        title = "Practitioner id"    noClear ="true" runat="server"/>
    <Spedmon:HiddenInput ID="journalid"           name="journalid"     title = "Journal id"         noClear ="true" runat="server"/>
    <Spedmon:HiddenInput ID="notesource"          name="notesource"    title = "notesource"         noClear ="true" value="record_single_or_multiple" runat="server"/>
    <Spedmon:HiddenInput ID="notenamespace"       name="notenamespace" title = "notenamespace"      noClear ="true" value="service_records"           runat="server"/>
    <Spedmon:HiddenInput ID="pracgroupid"         name="pracgroupid"   title = "pracgroupid"        noClear ="true" runat="server"/>
    
    </div> <!-- col -->
    </div> <!-- row -->
    
    <%//-----------------------------------------------------------------------------%>
    <%// Save or Edit %>
    <%//-----------------------------------------------------------------------------%>
    
    <Spedmon:DataEntryRowSaveOrEdit  
        ID                                      = "saveOrEdit" 
        editDelManageLink                       = ""
        includeSaveAndProceedButton             = "false"
        cancelButtonLabel                       = "Go Home"            
        runat                                   = "server">
    
    </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>

<%/*************************************************
  * Scripts for form builder (used in services tab)
  **************************************************/%>

<%/* <script src="web-ui-3/openvidu/js/mba-util.js"></script> */%>

<%/****************************
   * Scripts for options
   ****************************/%>

<script type="text/javascript">
    function doGoClose() {

        var url = '<%=closeJournalURL%>'
            + '&<%=Constants.PARM_CLIENT_ID%>'       + '=' + $('#<%=Constants.PARM_CLIENT_ID%>').val()
            + '&<%=Constants.PARM_PRACTITIONER_ID%>' + '=' + $('#<%=Constants.PARM_PRACTITIONER_ID%>').val()
            <% if(!String.IsNullOrEmpty(MBA.HttpApplication.getParameter(Constants.PARM_APP_MODE))) { %>
                + '&<%=Constants.PARM_APP_MODE%>' + '=' + '<%=MBA.HttpApplication.getParameter(Constants.PARM_APP_MODE)%>'
            <%}%>
        ;
        $.spedmonWebUI.gotoURL(url);
    }

  // pulsates the journal edit section's save icon
  function pulsateJournalEditSaveIcon() {
      $('#svc_journal_edit_fields i.fa-save').removeClass('spedmon-animation-pulsate').addClass('spedmon-animation-pulsate');
  }

  // un-pulsates the journal edit section's save icon
  function unPulsateJournalEditSaveIcon() {
      $('#svc_journal_edit_fields i.fa-save').removeClass('spedmon-animation-pulsate');
  }

  // redirect to another journal entry screen
  function redirectToJournalEntryScreen(journalID) {
      // build redirect URL with parameters
      var journalEntryURL = '<%=Spedmon.ServiceJournals.URL_USER_ALL_GO_TO_JOURNAL_BASE()%>'
          + '&dos=' + $('#dos').val()
          + '&patid=' + $('#patid').val()
          + '&pracid=' + $('#pracid').val()
          + '&recid=' + journalID
      $.spedmonWebUI.gotoURL(journalEntryURL);
  }
    

  // function to launch journal add new journal asmx web method
  function addNewJournal(fnCallback = function () { }) {
      let reqUrl = '<%=MBA.HttpApplication.createLink(Spedmon.ServiceJournalsJournals.URL_ASMX_SAVE, true)%>';
      let reqData = JSON.stringify({
            clientid      : $('#clientid').val()
          , pracid        : $('#pracid').val()
          , patid         : $('#patid').val()
          , dos           : $('#dos').val()
          , patabsent     : <%=MBA.Util.netBoolToJSBool(patAbsent)%>
          , editDelReason : ''
          , validaterec   : 0
          , savetype      : $.spedmonWebUI.RECORD_SAVE_TYPE_NEW
          , recid         : <%=journalrecid%>
      });

      MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
          .then(responseData => {
              redirectToJournalEntryScreen(responseData.rawData.recordID);
              fnCallback();
          })
          .catch(responseData => {
              $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
              fnCallback();
              return;
          });
  }
  
  // function to launch journal edit asmx web method
  function editJournal(fnCallback = function () { }) {
      let reqUrl = '<%=MBA.HttpApplication.createLink(Spedmon.ServiceJournalsJournals.URL_ASMX_SAVE, true)%>';
      let reqData = JSON.stringify({
            clientid      : $('#clientid').val()
          , pracid        : $('#pracid').val()
          , patid         : $('#patid').val()
          , dos           : $('#dos').val()
          , patabsent     : <%=MBA.Util.netBoolToJSBool(patAbsent)%>
          , editDelReason : ''
          , validaterec   : 0
          , savetype      : $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT
          , recid         : <%=journalrecid%>
      });

      MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
          .then(responseData => {
              // unpulsate save icon
              unPulsateJournalEditSaveIcon();

              // if the journal web method's returned record ID is the same as current journal ID being edited, indicate success
              // otherwise, open the journal indicated by web method return value
              if (responseData.rawData.recordID == <%=journalrecid%>) {
                  $('body').mbaHighlight({ color: "#bdffc7", duration: 500 });
              } else {
                  redirectToJournalEntryScreen(responseData.rawData.recordID);
              }

              // custom callback function passed in as a parameter
              fnCallback();
          })
          .catch(responseData => {
              $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
              fnCallback();
              return;
          });
  }

  function $generateAddNewOrEditJournalDialogDiv(fnAddNewCallback, fnEditCallback) {
      // define our elements
      let $containerDiv = $('<div></div>');
      let $prompt       = $(`<p>Choose from the options below whether you would like to start a new journal for this patient and your selected date OR change the date of service for this journal to your selected date:</p>
                             <p>(Note: if a journal already exists for the date you have selected, you will be redirected to that journal)</p>`);
      let $addNewBtn    = $('<button type="button" class="btn btn-primary mr-2">Create a new journal for the selected date</button>').on("click", function () { addNewJournal(fnAddNewCallback); });
      let $editBtn      = $('<button type="button" class="btn btn-info">Update this journal\'s date of service to the selected date</button>').on("click", function () { editJournal(fnEditCallback); });

      // append our elements
      $containerDiv.append($prompt);
      $containerDiv.append($addNewBtn);
      $containerDiv.append($editBtn);

      return $containerDiv;      
  }

  function launchAddNewOrEditJournalDialog() {
      let fnRemoveDialog = function () { $dialogDiv.remove(); }
      
      let $dialogDiv = $generateAddNewOrEditJournalDialogDiv(fnRemoveDialog, fnRemoveDialog);
      
      
      $dialogDiv.dialog(
          {
              width: $(window).width() / 2
              , height: $(window).height() / 2
              , title: '<strong>Please Confirm</strong>'
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
              , close: function (event, ui) { fnRemoveDialog(); }
          }
      );
  }

  // replaces the "go home" button to an icon that sends the user to the journal management screen
  function replaceGoHomeBtn() {
      let $goHomeBtn = $('#butcancel');
      let $goToJournalsManagementScreenBtn = $('<button title="go to journals management screen" class="mba-rest-view mba-rest-view-ctrl-button" type="button"><i class="mba-rest-view mba-rest-view-ctrl-icon fas fa-door-open"></i></button>')

      $goToJournalsManagementScreenBtn.on("click", function () { window.location = '<%=Spedmon.ServiceJournals.URL_USER_ALL_OPEN_NEW_BASE()%>'; });

      $goHomeBtn.replaceWith($goToJournalsManagementScreenBtn);
  }

  // Init
  $(function () {
      // Event listener for adding a new Contact record
      $('#addNewService').click(function () {
          SpEdCare.svcjournalOnDos.addRec();
      });

      // pulsate journal edit save icon if dos changes
      $('#dos').on("change", pulsateJournalEditSaveIcon);

      // if user clicks to save new dos, launch journal edit asmx method
      $('#svc_journal_edit_fields i.fa-save').on("click" , launchAddNewOrEditJournalDialog);

      // replace "go home button" with a custom button that goes to journals management screen
      // We need an icon for this, which is why this wasn't done through the DataEntryRowSaveOrEdit
      // control
      replaceGoHomeBtn();

      var opts = {};

      opts.SvcRecsTextAreaSelector      = '#svcjournalForDOSJSON';
      opts.SvcRecsTableSelector         = '#tblsvcjournalForDOSJSON';
      opts.SvcRecsTableBodySelector     = '#tblsvcjournalForDOSJSONBody';
                                        
      opts.tkn                          = '<%=((this.rd.loggedIn) ? this.rd.wu.usr.token : "")%>';
                                        
      opts.clientIDSel                  = '#clientid';
      opts.patIDSel                     = '#patid';
      opts.patNameSel                   = '#patname';
      opts.pracIDSel                    = '#pracid';
      opts.journalIDSel                 = '#journalid';
      opts.orpDocContSel                = '#orpDocCont';
      opts.orpDocsOKSel                 = '#selORPDocIDOK';
      opts.orpInputFieldPlaceHolderSel  = '#orpInputFieldPlaceHolder';
      opts.pracGroupID                  = '#pracgroupid';
      
      SpEdCare.svcjournalOnDos.init(opts);
  
  });
</script>
