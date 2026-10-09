<%@ Page Language="C#" CodeBehind="sbs_all_client_pbs_documentation_edit_delete.aspx.cs" Inherits="Spedmon.SBSAllClientPBSDocumentationEditDelete" %>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="client_pbs_documentation.ashx">
 
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
    
  <Spedmon:StepRecordsEditDelete 
    ID                = "step2" 
    editURL           = "sbs_all_client_pbs_documentation_save.aspx" 
    deleteURL         = "client_pbs_documentation.asmx/delete"
    title             = "Select PBS documentation to Edit or Delete"
    instructions      = "Select the PBS documentation you wish to edit or remove from list"
    recIDPos          = "2" 
    runat             = "server">
    
    <Spedmon:HiddenInput id="active"    name="active"   title="active" value="1" runat="server"/>       
    <Spedmon:HiddenInput ID="groupServiceClassNameID" name="groupServiceClassNameID" title="groupServiceClassNameID" value="" noClear="true" runat="server"/>
        
  </Spedmon:StepRecordsEditDelete>
  
</Spedmon:Steps>

