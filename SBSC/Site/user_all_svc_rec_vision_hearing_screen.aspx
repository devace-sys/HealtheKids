<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_svc_rec_vision_hearing_screen.aspx.cs" Inherits="Spedmon.UserAllSvcRecVisionHearingScreen" %>


<Spedmon:DataEntryRows purpose="SAVE" dataURL="servicerecords.asmx/savevisionandhearingservice" runat="server">

<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%// (Practi-Cal staff only) %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectClient
    ID              = "selectClient" 
    entityControlID = "clientid"                
    rowLabel        = "Client" 
    runat           = "server">
</Spedmon:DataEntryRowSelectClient>

<%//-----------------------------------------------------------------------------%>
<%// Select reference %>
<%// (Practi-Cal staff only)%>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow   
   ID          = "selectReference"  
   rowLabel    = "Enter document reference number"
   runat       = "server">

  <Spedmon:TextBox ID="reference" name="reference" title="Reference Number" showOK="false" runat="server" />

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Select DOS %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow   
   ID                              = "selectDOS"  
   rowLabel                        = "Enter date of service"
   runat                           = "server">

  <Spedmon:DateBox ID="dos" name="dos" title="Enter date of service" numMonths="1" multiDate="false" showOK="false" runat="server" />

</Spedmon:DataEntryRow>
    
<%//-----------------------------------------------------------------------------%>
<%// Select Practitioner for Vision Screen %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPractitioner 
   ID                                 = "SelectVisionPractitioner"  
   rowLabel                           = "Select practitioner providing <strong>Vision</strong> screen"
   entityControlID                    = "visionpracid"    
   preSelectedDataSource              = "ALL_PRACTITIONERS"   
   showManageFiles                    = "false"
   entryAllowed                       = "true"
   entryNotAllowedUseReplacementValue = "false"
   runat                              = "server">
</Spedmon:DataEntryRowSelectPractitioner>

<%//-----------------------------------------------------------------------------%>
<%// Select Practitioner for Hearing Screen %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPractitioner 
   ID                                 = "selectHearingPractitioner"  
   rowLabel                           = "Select practitioner providing <strong>Hearing</strong> screen"
   entityControlID                    = "hearingpracid"    
   preSelectedDataSource              = "ALL_PRACTITIONERS"   
   showManageFiles                    = "false"
   entryAllowed                       = "true"
   entryNotAllowedUseReplacementValue = "false"
   runat                              = "server">
</Spedmon:DataEntryRowSelectPractitioner>

<%//-----------------------------------------------------------------------------%>
<%// Select a Patient %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPatient
    ID                      = "selectPatient" 
    rowLabel                = "Select patient" 
    entityControlID         = "patid"  
    preSelectedDataSource   = "ALL_PATIENTS"
    showDataSourceSelection = "false"
    showAddNew              = "false" 
    showEditSelected        = "false"
    onSpedmonInputData      = ""
    runat                   = "server">
</Spedmon:DataEntryRowSelectPatient>

<%//-----------------------------------------------------------------------------%>
<%// Select Services Provided %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow
   ID                   = "selectServiceType"  
   rowLabel             = "Check all screenings provided"
   runat                = "server">

    <Spedmon:HiddenTextArea ID="servicetypesjson" name="servicetypesjson" title="servicetypesjson" runat="server" /> 

    <div class="form-check">
      <input id="servicetypevision" name="serviceTypeVision" class="form-check-input" type="checkbox" value="vision">
      <label class="form-check-label" for="servicetypevision">
        Vision screening
      </label>
    </div> 
    
    <div class="form-check">
      <input id="servicetypehearingthreshold" name="serviceTypeHearing" class="form-check-input" type="checkbox" value="hearingthreshold">
      <label class="form-check-label" for="servicetypehearingthreshold">
        Hearing (Threshold)
      </label>
    </div>
    
    <div class="form-check">
      <input id="servicetypehearingpuretone" name="serviceTypeHearing" class="form-check-input" type="checkbox" value="hearingpuretone">
      <label class="form-check-label" for="servicetypehearingpuretone">
        Hearing (Pure Tone)
      </label>
    </div>

</Spedmon:DataEntryRow>


<%//-----------------------------------------------------------------------------%>
<%// Notes %>
<%// (Client Only) %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow ID="enterSvcNotes" rowLabel="Enter notes" runat="server">

  <Spedmon:NoteAreaBox 
    ID           = "notes" 
    name         = "notes" 
    title        = "Notes"
    showOKButton = "false"
    runat        = "server"> 
  </Spedmon:NoteAreaBox> 

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Save or Edit %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSaveOrEdit  
    ID                          = "saveOrEdit" 
    editDelManageLink           = ""
    includeSecondarySaveButton  = "true"    
    includeSaveAndProceedButton = "false"
    secondarySaveButtonLabel    = "Save & New"
    secondarySaveButtonOnClick  = "saveAndRefreshForm(e)"
    cancelButtonLabel           = "Exit to Home"
    runat                       = "server">
    
</Spedmon:DataEntryRowSaveOrEdit>
</Spedmon:DataEntryRows>

<%//##################################################################################################################%>
<%//#                                         Data Entry Scripts  %>
<%//##################################################################################################################%>

<script type="text/javascript">
</script>