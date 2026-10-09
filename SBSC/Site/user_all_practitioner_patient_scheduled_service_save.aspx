<%@ Page Language="C#" CodeBehind="user_all_practitioner_patient_scheduled_service_save.aspx.cs" Inherits="Spedmon.UserAllPractitionerPatientScheduledServiceSave" %>

<%if (clientAndPracAreOK == true){%>

<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>

<Spedmon:DataEntryRows ID="save" purpose="SAVE" dataURL="practitioner_patient_scheduled_services.asmx/save" useBootstrapFluid="true" runat="server">
 
<%//-----------------------------------------------------------------------------%>
<%// Select Patient (limited to caseload) %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPatient
     ID                     = "selectPatient" 
     rowLabel               = "Student" 
          
     showEditSelected       = "false"
     showAddNew             = "false"      
     runat                  = "server">
</Spedmon:DataEntryRowSelectPatient>

<%//-----------------------------------------------------------------------------%>
<%// Caseload Row %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow id="selectRelatedToCaseloadRow" rowLabel="Related Expected Service<br>(Optional)" runat="server">
  <Spedmon:ComboBox ID="practitionerpatientcaseloadexpectedserviceid" name="practitionerpatientcaseloadexpectedserviceid" title="Caseload Row" dataPrivate="true" dataParms="[{id:'clientid'},{id:'pracid'},{id:'patid'}]" dataURL="practitioner_patient_caseload_expected_services.asmx/viewSel" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Caseload Group ID Row %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow id="selectRelatedCaseloadGroupRow" rowLabel="Related Caseload Group<br>(Optional)" runat="server">
  <Spedmon:ComboBox ID="caseloadgrpid" name="caseloadgrpid" title="Caseload Group" dataPrivate="true" dataParms="[{id:'clientid'},{id:'pracid'}]" dataURL="practitioner_patient_groups.asmx/viewSelByClientPrac" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Select Dates of Service %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow rowLabel="Select Date(s) Of Service" runat="server">
    <Spedmon:SelectYesOrNo ID="recurring" name="recurring" title="Recurring Service?" firedataselected="true" runat="server" />   
    <br />
    <Spedmon:DataEntryBoxDate ID="startdate" name="startdate" label="Start Date" title="Enter start date" runat="server" />
    <Spedmon:DataEntryBoxDate ID="enddate"   name="enddate"   label="End Date"   title="Enter end date" runat="server" />        
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Select Plan Type %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow rowLabel="Select Service Plan Type" runat="server">
  <Spedmon:DataEntryBoxSelect ID="svcnameslistdatasourceid" name="svcnameslistdatasourceid" label="Plan Type" title="Select what type of plan this service is part of" fireSpedmonInput="true" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Select Service %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow rowLabel="Select Service" runat="server">
    <Spedmon:SelectYesOrNo ID="viatelehealth" name="viatelehealth" title="Telehealth Service?" runat="server" />
    <br />
    <Spedmon:HiddenInput ID="dos"               name ="dos"               title="dos"               runat ="server" />
    <Spedmon:HiddenInput ID="isiep"             name ="isiep"             title="isiep"             runat ="server" />
    <Spedmon:HiddenInput ID="altmodalitynameid" name ="altmodalitynameid" title="altmodalitynameid" runat ="server" />
    
    <!-- TODO: Add support to select service for altmodality name id (same as what we do for add new and edit) -->
    
    <Spedmon:DataEntryRowSelectService 
      ID                                = "selectService" 
      rowLabel                          = "Service?" 
      dataEntryRowRenderAs              = "FIELD"            
      promptForAdditionalServiceDetails = "false"      
      runat                             = "server">  
    </Spedmon:DataEntryRowSelectService>

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Start Time and Minutes %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow rowLabel="Service Minutes, Days (if applicable) and Times (times are optional)" runat="server">
    <Spedmon:DataEntryBoxNumber size="12" ID="nummins" name="nummins" min="0" label="Number of Minutes" title="Enter minutes" runat="server" />
    <Spedmon:DataEntryBoxTime size="8" ID="starttime" name="starttime" title="What time does the service start?" label="Start Time" runat="server"/>
    <br>
<%//-----------------------------------------------------------------------------%>
<%// Recurring Schedule %>
<%//-----------------------------------------------------------------------------%>

<table id="recurring-options" class="table table-borderless table-sm">
    <thead>
    <tr>
    <th class="text-center">Mon</th> <!-- col -->
    <th class="text-center">Tue</th> <!-- col -->
    <th class="text-center">Wed</th> <!-- col -->
    <th class="text-center">Thu</th> <!-- col -->
    <th class="text-center">Fri</th> <!-- col -->
    </tr>
    </thead>
    <tbody>
    <tr>
    <td class="text-center"><Spedmon:CheckBox ID="mon" name="mon" title="Service Provided?" runat="server" /></td> <!-- col -->
    <td class="text-center"><Spedmon:CheckBox ID="tue" name="tue" title="Service Provided?" runat="server" /></td> <!-- col -->
    <td class="text-center"><Spedmon:CheckBox ID="wed" name="wed" title="Service Provided?" runat="server" /></td> <!-- col -->
    <td class="text-center"><Spedmon:CheckBox ID="thu" name="thu" title="Service Provided?" runat="server" /></td> <!-- col -->
    <td class="text-center"><Spedmon:CheckBox ID="fri" name="fri" title="Service Provided?" runat="server" /></td> <!-- col -->
    </tr>
    <tr>
    <td class="text-center"><Spedmon:DataEntryBoxTime size="8" ID="monstarttime" name="monstarttime" label="Time" runat="server"/></td> <!-- col -->
    <td class="text-center"><Spedmon:DataEntryBoxTime size="8" ID="tuestarttime" name="tuestarttime" label="Time" runat="server"/></td> <!-- col -->
    <td class="text-center"><Spedmon:DataEntryBoxTime size="8" ID="wedstarttime" name="wedstarttime" label="Time" runat="server"/></td> <!-- col -->
    <td class="text-center"><Spedmon:DataEntryBoxTime size="8" ID="thustarttime" name="thustarttime" label="Time" runat="server"/></td> <!-- col -->
    <td class="text-center"><Spedmon:DataEntryBoxTime size="8" ID="fristarttime" name="fristarttime" label="Time" runat="server"/></td> <!-- col -->
    </tr>
    </tbody>
</table> 


</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Notes %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow rowLabel="Schedule Entry Notes" runat="server">
  <Spedmon:DataEntryBoxTextArea ID="notes" name="notes" label="Notes" floatingLabel="true" size="25" runat="server" showCharCountMeter="false" />
</Spedmon:DataEntryRow>
 
<%//-----------------------------------------------------------------------------%>
<%// Save or Edit %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSaveOrEdit 
    ID                               = "saveOrEdit" 
    editDelManageLink                = "pracpatscheduledsvcsmanagelink"
    runat                            = "server"> 
  
  <Spedmon:HiddenInput ID="clientid" name ="clientid" title="clientid" runat="server" />
  <Spedmon:HiddenInput ID="pracid"   name ="pracid"   title="pracid"   runat="server" />
  <Spedmon:HiddenInput ID="groupid"  name ="groupid"  title="groupid"  runat="server" />

</Spedmon:DataEntryRowSaveOrEdit> <!-- row -->

</Spedmon:DataEntryRows> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Entry Scripts  %>
<%//##################################################################################################################%>

<script type="text/javascript">

let $ctrlSaveForm      = null;
let $ctrlPatID         = null;
let $ctrlRecurring     = null;
let $ctrlStartDate     = null;
let $ctrlEndDate       = null;
let $ctrlStartTime     = null;
let $ctrlNumMins       = null;
let $recurringOptions  = null;

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

function getCtrlRefs() {    
  $ctrlSaveForm      = $('#save');
  $ctrlPatID         = $('#<%=Constants.PARM_PATIENT_ID%>');
  $ctrlRecurring     = $('#recurring');
  $ctrlStartTime     = $('#starttime');
  $ctrlStartDate     = $('#startdate');
  $ctrlEndDate       = $('#enddate');
  $ctrlNumMins       = $('#nummins');
  $recurringOptions  = $('#recurring-options');
};

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

function toggleRecurringOptions() {

    let _rv = $($ctrlRecurring).val();
    
    if (_rv == 'Yes') {
      $($ctrlStartDate).MBA_DataEntryBox('setLabel','Date Services Start');
      $($ctrlEndDate).MBA_DataEntryBox('setLabel','Date Services End');
      $($ctrlEndDate).MBA_DataEntryBox('show');
      $($ctrlStartTime).MBA_DataEntryBox('hide');
      $($ctrlNumMins).MBA_DataEntryBox('setLabel', 'Number of Minutes Per Day');
      $recurringOptions.show();      
    }
    else {
      $($ctrlStartDate).MBA_DataEntryBox('setLabel', 'Date Of Service');
      $($ctrlEndDate).MBA_DataEntryBox('hide');
      $($ctrlStartTime).MBA_DataEntryBox('show');
      $($ctrlNumMins).MBA_DataEntryBox('setLabel', 'Number of Minutes');
      $recurringOptions.hide();
    }
};

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>

$(window).on('load', function () {

  getCtrlRefs();

  <%if (lockSelectPatient == true) {%>$($ctrlPatID).spedmonSelectBox_disable();<%}%>

  toggleRecurringOptions();

  $($ctrlSaveForm).on('spedmoninput spedmoninputdata', function (e) {
            
      let _whatCtrlID = $(e.target).attr('id');
      let _dataItem = e.dataitem;

      if (_whatCtrlID == 'recurring') {
        toggleRecurringOptions();
      }
      else if (_whatCtrlID == 'nameid') {
        let _spedSvcCode = _dataItem.recData10;         
      }
      else {

      }
      return true;
  });
  
});

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    

</script>

<%} /* client and prac are ok */ else {%>
<div class="alert alert-danger text-center">Please select a practitioner</div>
<%}%>

