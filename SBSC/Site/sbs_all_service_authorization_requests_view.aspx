<%@ Page Language="C#" CodeBehind="sbs_all_service_authorization_requests_view.aspx.cs" Inherits="Spedmon.SBSAllServiceAuthorizationRequestsView" %>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="service_authorization_requests.ashx">
 
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step 
    ID             = "step1"
	  title          = "Who is the Client?"
    instructions   = "Start typing the client name or click on the down arrow for a list" 
    ondataselected = "" 
    runat          = "server">
    
    <Spedmon:StepSelectionOptions ID="step1options" runat="server">
      <Spedmon:Button ID="dspNotesClient" icon="ui-icon-note" onclick="doShowNotesClient()" runat="Server">Notes</Spedmon:Button>
    </Spedmon:StepSelectionOptions>
    
    <Spedmon:ComboBox ID="clientid" name="clientid" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 

    <script type="text/javascript">
     function doShowNotesClient ()
     {
       var $stp  = $('#step1');
       var tkn   = $.spedmonWebUI.token;
       var cltid = $('#clientid').val();
       var url   = "clients.asmx/viewEntity?tkn=" + tkn;
       var $data = "{'clientid':" + cltid + "}";
       var notes = "";
       var name = "";
       $.spedmonWebUI.ajax($stp, url, $data, null, null, function(rd) { name = 'Client notes for ' + rd.data.entity.name; notes = rd.data.entity.notes; }, null, null, 0, function() {$.spedmonWebUI.dialogMessage(name, $.spedmonWebUI.formattedTextToHTML(notes, 'ui-spedmon-dialog-mono-txt'), true, 800, 400) });       
       return;
     }

   </script>
  </Spedmon:Step>


  <%/*************************************[ Step 2 ]************************************/%>
     
  <Spedmon:Step 
      ID           = "step2" 
	  title        = "Status?"
      instructions = "Select status"
      runat        = "server">

    <Spedmon:SelectRequestServiceAuthorizationResponse 
    id                    = "responsecode" 
    name                  = "responsecode" 
    title                 = "Show"
    showPendingOption     = "true"
    selectionTextApproved = "Approved"
    selectionTextDeclined = "Declined"
    onSelectValue         = "function(oldval,newval) { onSelectResponseValue(oldval, newval); return true;}"
    value                 = "PENDING"
    runat                 = "server"/>
    
  </Spedmon:Step>
  
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:StepView ID="step3" runat="server">
  
  	<Spedmon:HiddenInput ID="closed" name="closed" title="closed" value="0" runat="server"/>
    <Spedmon:HiddenInput id="active" name="active" title="active" value="1" runat="server"/> 
    
  </Spedmon:StepView>
   
</Spedmon:Steps>

<script type="text/javascript" charset="utf-8">

       function onSelectResponseValue (oldval, newval) {
           $('#closed').val('0');
           if      (newval == 4000) { /* Declined */ $('#closed').val('0'); }
           else if (newval == 3000) { /* Approved */ $('#closed').val('1'); }
           else if (newval == 2000) { /* Pending */  $('#closed').val('0'); }
           else                     { $('#closed').val('0'); }
           return true;
       };
   </script>


