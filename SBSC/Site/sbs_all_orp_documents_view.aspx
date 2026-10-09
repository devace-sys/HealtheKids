<%@ Page Language="C#" CodeBehind="sbs_all_orp_documents_view.aspx.cs" Inherits="Spedmon.SBSAllOrpDocumentsView" %>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="orp_documents.ashx">
 
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
  
  <Spedmon:StepSelectPatient 
    ID               = "step2" 
    showaddpatient   = "false" 
    showdatasource   = "false"   
    selecttype       = "SEARCH_BOX" 
    selectall        = "true" 
    selectdelay      = "0" 
    selectid         = "patid"  
    runat            = "server">
  </Spedmon:StepSelectPatient>    

  <%/*************************************[ Step 3 ]************************************/%>
     
  <Spedmon:Step 
    ID           = "step3" 
	  title        = "Effective Date?"
    instructions = "Select or enter the effective date.  Records on or after this date will be shown."
    runat        = "server">

    <Spedmon:DateBox ID="dos" name="dos" title="Select Effective Date" runat="server" />
    
  </Spedmon:Step>
  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepView ID="step4" runat="server">
  	
    <Spedmon:HiddenInput id="active" name="active" title="active" value="1" runat="server"/> 
    
  </Spedmon:StepView>
   
</Spedmon:Steps>

