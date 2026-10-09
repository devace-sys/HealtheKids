<%//##################################################################################################################%>
<%//# %>
<%//# %>
<%//#                NOTE: This page is depracated and is no longer supported. It was replaced with %>
<%//#                          user_all_svcrec_save_batch_multi_prac_pat_dos_svc.aspx  %>
<%//# %>
<%//# %>
<%//##################################################################################################################%>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_svcrec_save_batch_multi_pat_multi_svc.aspx.cs" Inherits="Spedmon.UserAllSvcRecSaveAll" %>

<%//##################################################################################################################%>
<%//#                                         Dialogs   %>
<%//##################################################################################################################%>

<%-- dialog that contains the additional speech questions (displayed when a speech service is selected --%>

<div id="svcDetCont" title="This Service Requires More Information">
	<div id="svcDetInstructions">Important Instructions: Before selecting NO read guidance from ASHA and CSHA.
		<a title="Click here" href="client_prov_slp_assmt_instructions_2017_02_17.html" target="_blank" class="ui-spedmon-button ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" id="slpAssmtInstrID" role="button" aria-disabled="false"> <span class="ui-button-text">Click Here</span> </a>
	</div>
	<div class="ui-spedmon-step-instructions">Please answer <strong class="boldText">ALL</strong> of the following questions regarding this assessement then click the OK button below. </div>
	<table id="svcDetFlagsCont">
		<tbody>
			<tr>
				<td class="ui-state-default">
					<label for="svcDetFlag1" class="svcDetFlagLbl">Performed Evaluation of Speech Fluency?</label>
				</td>
				<td> 
                    <input type="radio" id="svcDetFlag1-yes" name="svcDetFlag1" value="true"  class="radio-button">
                    <label for="svcDetFlag1-yes" class="radio-button-label radio-button-label-green">Yes</label>
                    <input type="radio" id="svcDetFlag1-no"  name="svcDetFlag1" value="false" class="radio-button">
                    <label for="svcDetFlag1-no" class="radio-button-label radio-button-label-red">No</label>
				</td>
			</tr>
			<tr>
				<td class="ui-state-default">
					<label for="svcDetFlag2" class="svcDetFlagLbl">Performed Evaluation of Speech Sound Production?</label>
				</td>
				<td> 
                    <input type="radio" id="svcDetFlag2-yes" name="svcDetFlag2" value="true"  class="radio-button">
                    <label for="svcDetFlag2-yes" class="radio-button-label radio-button-label-green">Yes</label>
                    <input type="radio" id="svcDetFlag2-no"  name="svcDetFlag2" value="false" class="radio-button">
                    <label for="svcDetFlag2-no" class="radio-button-label radio-button-label-red">No</label>
				</td>
			</tr>
			<tr>
				<td class="ui-state-default">
					<label for="svcDetFlag3" class="svcDetFlagLbl">Performed Evaluation of Language Comprehension and Expression?</label>
				</td>
				<td> 
                    <input type="radio" id="svcDetFlag3-yes" name="svcDetFlag3" value="true"  class="radio-button">
                    <label for="svcDetFlag3-yes" class="radio-button-label radio-button-label-green">Yes</label>
                    <input type="radio" id="svcDetFlag3-no"  name="svcDetFlag3" value="false" class="radio-button">
                    <label for="svcDetFlag3-no" class="radio-button-label radio-button-label-red">No</label>
				</td>
			</tr>
			<tr>
				<td class="ui-state-default">
					<label for="svcDetFlag4" class="svcDetFlagLbl">Performed Behavioral and Qualitative Analysis of Voice and Resonance?</label>
				</td>
				<td> 
                    <input type="radio" id="svcDetFlag4-yes" name="svcDetFlag4" value="true"  class="radio-button">
                    <label for="svcDetFlag4-yes" class="radio-button-label radio-button-label-green">Yes</label>
                    <input type="radio" id="svcDetFlag4-no"  name="svcDetFlag4" value="false" class="radio-button">
                    <label for="svcDetFlag4-no" class="radio-button-label radio-button-label-red">No</label>                   
				</td>
			</tr>
		</tbody>
	</table>
	<div class="ui-spedmon-step-instructions"><div>Click the OK button below when you are done answering the questions above.</div>
      <Spedmon:Button title = "OK" ID = "svcDetFlagsOK" runat = "server">
        OK
      </Spedmon:Button>
    </div>
</div>

<%-- dialog that contains the additional orp questions (displayed when an orp service is selected --%>

<div id="orpDocCont" title="This Service Requires The Selection of an Order Or Prescription">
    <div class="ui-spedmon-step-instructions">Please select the order or prescription that is associated with this service from the drop-down below then click OK.</div>
    <div id="orpInputFieldPlaceHolder"></div>
    <Spedmon:Button title = "OK" ID = "selORPDocIDOK" runat = "server">
      OK
    </Spedmon:Button>
    <div class="additional-info-below-select-entity">
        If you do not see any applicable orders or prescriptions in the drop-down above, click &nbsp;
		
        <Spedmon:Button title = "Click here to add a new order or prescription" ID = "addOrdPres" runat = "server">
            Add A New Order or Prescription
        </Spedmon:Button>
        &nbsp; then try your selection again.
    </div>
</div>

<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>

<Spedmon:DataEntryRows purpose="SAVE" dataURL="servicerecords.asmx/savesvcrecsondos" runat="server">

    <%//-----------------------------------------------------------------------------%>
    <%// Select Client %>
    <%//-----------------------------------------------------------------------------%>
 
    <Spedmon:DataEntryRowSelectClient
            ID                 = "selectClient" 
            entityControlID    = "clientid"                
            rowLabel           = "Who is the Client?"
            selectCtrlOnSelect = "emptyTableRows(true)"
            runat              = "server">
    </Spedmon:DataEntryRowSelectClient>

    <%//-----------------------------------------------------------------------------%>
    <%// Select Practitioner %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectPractitioner 
       ID                              = "selectPractitioner"  
       rowLabel                        = "Practitioner"
       entityControlID                 = "pracid"  
       selectCtrlOnSelect              = "setGroupID(event, ui)"
       preSelectedDataSource           = "ALL_PRACTITIONERS"            
       runat                           = "server">
    </Spedmon:DataEntryRowSelectPractitioner>

    <%if (svcetrmdeInt == Spedmon.Constants.SVCETRMDE_RECORD_SCHEDULED_SERVICES) { %>

        <Spedmon:DataEntryRow   
           ID                              = "selectGroupScheduled"  
           rowLabel                        = "Select a group you would like to record for:"
           runat                           = "server">

          <span class="d-inline-block">
            <Spedmon:ComboBox 
              ID          = "selectGrpScheduled" 
              name        = "groupidscheduled" 
              title       = "Select Group" 
              dataPrivate = "true" 
              dataParms   = "[{id:'clientid'},{id:'pracid'}]" 
              dataURL     = "practitioner_patient_groups.asmx/viewSelByClientPrac"
              onSelect    = "addGrpScheduled (event,ui);"
              singleSelectClearAfterSelection     = "true"
              runat       = "server" />
          </span>  
        </Spedmon:DataEntryRow>

    <% } %>

    <Spedmon:DataEntryRow   
       ID                              = "selectGroup"  
       rowLabel                        = "Select a group you would like to record for:"
       runat                           = "server">

    <div id="grpSelectionCont">
      
      <span class="d-inline-block">
        <Spedmon:Button ID = "selEntireCaseload" onclick = "doAddCaseload(e);" runat = "server">
          My Caseload
        </Spedmon:Button>
      </span>
      
      <span class="d-inline-block bold-text">or</span>
      
      <span class="d-inline-block">
        <Spedmon:ComboBox 
          ID          = "groupid" 
          name        = "groupid" 
          title       = "Select Group" 
          dataPrivate = "true" 
          dataParms   = "[{id:'clientid'},{id:'pracid'}]" 
          dataURL     = "practitioner_patient_groups.asmx/viewSelByClientPrac"
          onSelect    = "addGrp (event,ui);"
          singleSelectClearAfterSelection     = "true"
          runat       = "server" />
      </span>       
    
    </div> 

    </Spedmon:DataEntryRow>

    <%//-----------------------------------------------------------------------------%>
    <%// Multi-date selection %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRow ID="selectDates" rowLabel="(Optional): Multiple Date Selection" runat="server">
        <Spedmon:DateBox     ID="dossvcs"  name="dossvcs"  title="(Optional): Multiple Date Selection" numMonths="2"  monthsOffset="1"  multiDate="true" multiDateAltFieldUseFirstOrLastSelected="last" showOK="false" dateFormat="yyyy-mm-dd" runat="server"/>
    </Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Select a Patient to Record services for %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPatient
    ID                                  = "selectPatient" 
    rowLabel                            = "Select a Patient to Record Services For" 
    entityControlID                     = "patid"  
    preSelectedDataSource               = "ALL_PATIENTS"
    showDataSourceSelection             = "false"
    showAddNew                          = "true" 
    showEditSelected                    = "false"
    onSpedmonInputData                  = ""
    selectCtrlOnSelect                  = "addPat(event,ui);"
    singleSelectClearAfterSelection     = "true"
    selectCtrlNoSubmit                  = "true"
    selectCtrlNoClear                   = "false"
    entryAllowed                        = "true"
    entryNotAllowedUseReplacementValue  = "false"
    runat                               = "server">
</Spedmon:DataEntryRowSelectPatient>

<%//-----------------------------------------------------------------------------%>
<%// Enter Details %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow
   ID                              = "SvcrecForDOS"  
   rowLabel                        = "Patients to Record Services For"
   runat                           = "server">
    
  <Spedmon:HiddenTextArea ID="svcrecForDOSJSON" name="svcrecForDOSJSON" title="svcrecForDOSJSON" runat="server" />
  

  <table id="tblSvcRecsForDOSJSON">
      <thead>
        <tr>
          <th><i class="fa fa-trash-alt" id="clearTblBut" onclick="clearSvcRecsTable(false)" title="Remove All Records"></i></th>
          <th><i class="fa fa-users" id="svcRecsBeginLiveGroupSessionBtn" onclick="beginLiveGroupSession()" title="Begin Live Group Session"></i></th>
          <th></th>
          <th></th>
          <th>Patient Name</th>
          <th>Date of Service</th>
          <th>Via TeleHealth</th>
          <th>Plan Type</th>
          <th>Service Provided</th>
          <th>Start Time</th>
          <th>Session Minutes</th>
          <th>Attendance</th>
          <th>Notes</th>
        </tr>
        <tr class="headerRowCopyAll">
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th>
              <input type="date" id="date-to-copy" value="<%=dos.value%>" />
          </th>
          <th>
              <input type="checkbox" id="telehealth-flag-to-copy" class="form-checkbox-input" />
          </th>
          <th>
              <div>
                <select id="plan-to-copy" class="table-header-data">
                    <option disabled="" value="" selected=""> -- select an option --</option>
                    <option value="1">IEP / IFSP</option>
                    <option value="2">Other (IHP, 504, Counseling, etc.)</option>
                </select>
              </div>
          </th>
          <th>
              <div>
                  <select id="services-to-copy" class="inactive-input table-header-data" value="null">
                      <option disabled="" value="" selected=""> -- select an option -- </option>
                  </select>
              </div>
          </th>
          <th>
              <div>
                <input type="time" id="time-to-copy"/>
              </div>
          </th>
          <th>
              <div>
                <input type="number" id="minutes-to-copy" min="0" />
              </div>
          </th>
          <th>
              <div>
                <select value="0">
                    <option value="0" selected>Regular Session</option>
                    <option value="1">Student Absent</option>
                    <option value="2">Practitioner Absent</option>
                    <option value="4">Make-up Session</option>
                </select>
              </div>
          </th>
          <th>              
              <div>
                <textarea id="notes-to-copy"></textarea>
              </div>
          </th>
        </tr>
        <tr class="headerRowCopyAll">
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th>
              <div>
                <i id="copyDOS" class="fa fa-copy noReset" title="Copy For All Rows" onclick="copyValForAllRows(this);"></i> 
              </div>
          </th>
          <th>
              <div>
                <i id="copyTelehealth" class="fa fa-copy noReset" title="Copy For All Rows" onclick="copyValForAllRows(this);"></i> 
              </div>
          </th>
          <th>
              <div>
                <i id="copyPlanType" class="fa fa-copy noReset" title="Copy For All Rows" onclick="copyValForAllRows(this);"></i> 
              </div>
          </th>
          <th>
              <div>
                <i id="copyServiceType" class="fa fa-copy" title="Copy For All Rows" onclick="copyValForAllRows(this);"></i> 
              </div>
          </th>
          <th>
              <div>
                <i id="copyStartTime" class="fa fa-copy" title="Copy For All Rows" onclick="copyValForAllRows(this);"></i> 
              </div>
          </th>
          <th>
              <div>
                <i id="copyMinutes" class="fa fa-copy" title="Copy For All Rows" onclick="copyValForAllRows(this);"></i> 
              </div>
          </th>
          <th>
              <div>
                <i id="copyAttendance" class="fa fa-copy" title="Copy For All Rows" onclick="copyValForAllRows(this);"></i> 
              </div>
          </th>
          <th>              
              <div>
                <i id="copyNotes" class="fa fa-copy" title="Copy For All Rows" onclick="copyValForAllRows(this);"></i> 
              </div>
          </th>
        </tr>
      </thead>
      <tbody id="tblSvcRecsForDOSJSONBody">
      </tbody>
   </table>

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Required Hidden Params %>
<%//-----------------------------------------------------------------------------%>

<%--<Spedmon:HiddenInput ID="clientid"            name="clientid"      title = "Client id"          noClear ="true" runat="server"/>
<Spedmon:HiddenInput ID="pracid"              name="pracid"        title = "Prac id"            noClear ="true" runat="server"/>--%>
<Spedmon:HiddenInput ID="dos"                 name="dos"           title = "Date of Service"    noClear ="true" runat="server"/>      
<Spedmon:HiddenInput ID="svcetrmde"           name="svcetrmde"     title = "Service Mode"       noClear ="true" runat="server"/>      
<Spedmon:HiddenInput ID="notenamespace"       name="notenamespace" title = "notenamespace"      noClear ="true" value="service_records"           runat="server"/>
<Spedmon:HiddenInput ID="notesource"          name="notesource"    title = "notesource"         noClear ="true" value="record_single_or_multiple" runat="server"/>
<Spedmon:HiddenInput ID="pracgroupid"         name="pracgroupid"   title = "pracgroupid"         noClear ="true" runat="server"/>

<%//-----------------------------------------------------------------------------%>
<%// Save or Edit %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSaveOrEdit  
    ID                                      = "saveOrEdit" 
    editDelManageLink                       = "pracdirectsupmanagelink"
    runat                                   = "server">

</Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>

<%//##################################################################################################################%>
<%//#                                         Data Entry Scripts  %>
<%//##################################################################################################################%>

<%/*************************************************
  * Scripts for form builder (used in services tab)
  **************************************************/%>

<script src="web-ui-3/openvidu/js/mba-util.js"></script>

<script type="text/javascript">

  $(document).ready(function () {
    // hide the "copy for all" functionality if in Missing Assessments mode
    if ($('#svcetrmde').val() == <%=Spedmon.Constants.SVCETRMDE_RECORD_MISSING_ASSMTS%>) {
      $('.headerRowCopyAll').hide();
    }

  });

  // Init
  $(function () {
      var opts = {};

      opts.SvcRecsTextAreaSelector   = '#svcrecForDOSJSON';
      opts.SvcRecsTableSelector      = '#tblSvcRecsForDOSJSON';
      opts.SvcRecsTableBodySelector  = '#tblSvcRecsForDOSJSONBody';
      opts.tkn                       = '<%=((this.rd.loggedIn) ? this.rd.wu.usr.token : "")%>';
      opts.dos                       = $('#dos').val();
      opts.$svcDetailsCont           = $('#svcDetCont');
      opts.svcDetFlag1               = 'svcDetFlag1';
      opts.svcDetFlag2               = 'svcDetFlag2';
      opts.svcDetFlag3               = 'svcDetFlag3';
      opts.svcDetFlag4               = 'svcDetFlag4';
      opts.$svcDetFlagsOK            = $('#svcDetFlagsOK');
      opts.$orpDocumentsCont         = $('#orpDocCont');
      opts.$orpDocsOK                = $('#selORPDocIDOK');
      opts.$orpInputFieldPlaceHolder = $('#orpInputFieldPlaceHolder');
      //opts.clientID                  = $('#clientid').val();
      //opts.pracID                    = $('#pracid').val();
      opts.servicesToCopy            = 'services-to-copy';
      opts.planToCopy                = 'plan-to-copy';
      opts.dateToCopy                = 'date-to-copy';
      opts.telehealthFlagToCopy      = 'telehealth-flag-to-copy';
      opts.addNewOrderButSel         = '#addOrdPres'
      opts.pracGroupID               = '#pracgroupid'
      opts.urlViewAllPatientGoalsProgress = '<%=urlViewAllPatientGoalsProgress%>';
      
      // initial set-ups
      opts.$svcDetailsCont.hide();
      opts.$orpDocumentsCont.hide();
      opts.$orpInputFieldPlaceHolder.hide();

      // link to the SLP instructions
      $('#slpAssmtInstrID').button({});
	  $('#slpAssmtInstrID').spedmonLink({
	  	linkmode: 1,
	  	beforeOpen: function() {}
	  });

      SpEdCare.svcrecOnDos.init(opts);
  
  });
</script>