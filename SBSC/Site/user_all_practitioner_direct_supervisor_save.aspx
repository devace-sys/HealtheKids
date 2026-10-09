<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_practitioner_direct_supervisor_save.aspx.cs" Inherits="Spedmon.UserAllPractitionerDirectSupervisorSave" %>

<ul class="container" id="supervisionInstructions">
    <li>
        The supervision relationships below are to comply with LEA Billing Option Program requirements. Some supervision relationships require that a responsibility statement be submitted to the state. If available, you can upload a copy of the statement below, for audit purposes.
    </li>
    <li>
        Supervising speech-pathologists may only supervised two (2) SLPA's at any given time.
        <br />
        Supervising Occupational Therapists may only supervised three (3) COTA's at any given time.
        <br />
        Supervising Physical Therapists may only supervised two (2) PTA's at any given time.

    </li>
    <li>
        Use the grid below to manage; who is supervising, and the start/end dates of supervision. Practi-Cal will use this information to determine services eligible for program reimbursement.
    </li>
</ul>
 
<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>

<Spedmon:DataEntryRows purpose="SAVE" dataURL="practitioner_direct_supervisors.asmx/save" runat="server">

<%//-----------------------------------------------------------------------------%>
<%// Select Client %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectClient
    ID              = "selectClient" 
    entityControlID = "clientid"                
    rowLabel        = "Client" 
    runat           = "server">
</Spedmon:DataEntryRowSelectClient>

<%//-----------------------------------------------------------------------------%>
<%// Select Practitioner %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPractitioner 
   ID                                  = "selectSupervisedPractitioner"  
   rowLabel                            = "Select the Practitioner Being Supervised"
   entityControlID                     = "pracid"    
   preSelectedDataSource               = "ALL_PRACTITIONERS"   
   entryAllowed                        = "true"
   entryNotAllowedUseReplacementValue  = "false"
   runat                               = "server">
</Spedmon:DataEntryRowSelectPractitioner>

<%//-----------------------------------------------------------------------------%>
<%// Select Supervising Practitioners %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSelectPractitioner 
   ID                                  = "selectSupervisingPractioners"  
   rowLabel                            = "Select a New Supervising Practitoner to Add To The List Below"
   entityControlID                     = "supervisingpracid"    
   preSelectedDataSource               = "ALL_PRACTITIONERS"      
   selectCtrlOnSelect                  = "addSupervisingPrac(event,ui);"
   singleSelectClearAfterSelection     = "true"
   selectCtrlNoSubmit                  = "true"
   selectCtrlNoClear                   = "false"
   entryAllowed                        = "true"
   entryNotAllowedUseReplacementValue  = "false"
   runat                               = "server">
</Spedmon:DataEntryRowSelectPractitioner>

<%//-----------------------------------------------------------------------------%>
<%// Enter Details %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRow
   ID                              = "editSupervisingPractionersDetails"  
   rowLabel                        = "Supervising Practitioners"
   runat                           = "server">
    
  <Spedmon:HiddenTextArea ID="supervisingpracsdetails" name="supervisingpracsdetails" title="supervisingpracsdetails" runat="server" /> 
  
  <table id="tbldirectsupervisors">
      <thead>
        <tr>
          <th></th>
          <th>Supervisor Name</th>
          <th>Start Date</th>
          <th>End Date</th>
          <th>Share Notes ONLY</th>
        </tr>
      </thead>
      <tbody id="tbldirectsupervisorsbody">
      </tbody>
   </table>

</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Save or Edit %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSaveOrEdit  
    ID                                      = "saveOrEdit" 
    editDelManageLink                       = "pracdirectsupmanagelink"
    includeButtonManageSupportingDocuments  = "true"
    manageSupportingDocumentsLabel          = "Responsibility Statements"
    manageSupportingDocumentsOnClick        = "manageSupportingDocuments()"
    runat                                   = "server">

</Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>


<%//##################################################################################################################%>
<%//#                                         Data Entry Scripts  %>
<%//##################################################################################################################%>

<script type="text/javascript">
  
  function manageSupportingDocuments () {

    let cid = $('#clientid').val();
    let pid = $('#pracid').val();

    if ((cid != '') && (pid != ''))
    {    
      var fileAdditionalDataJSONStr = '{clientid:' + cid + ', pracid:' + pid + '}';
      $.spedmonWebUI.fileList (   'Responsibility Statements'
                                , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>'
                                , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
                                , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
                                , 3 /* Record id position */
                                , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
                                , '<%=MBA.StoredFiles.FILE_CLASS_MISC%>'
                                , '' /* File subclass */
                                , '<%=Spedmon.PractitionerDirectSupervisors.VAL_FILE_NAMESPACE%>'
                                , '<%=Spedmon.PractitionerDirectSupervisors.VAL_FILE_SOURCE%>'
                                , fileAdditionalDataJSONStr
                                , true
                                , true);
    }
    else
    {      
        $.spedmonWebUI.dialogMessage('Please Select a Supervised Practitioner'
                                    , 'You must select a practitioner in order to work with any supporting documents.'
                                    , true
                                    , 300
                                    , 300
                                    , null );
    }
  };

  function addSupervisingPrac(event, ui) {
    SpEdCare.directSupervisonSave.addParticipant(ui.item.id, ui.item.label, '', '', false);
  }

  $(function () {
      var opts = {};

      opts.supervisingPracsTextAreaSelector  = '#supervisingpracsdetails';
      opts.supervisingPracsTableSelector     = '#tbldirectsupervisors';
      opts.supervisingPracsTableBodySelector = '#tbldirectsupervisorsbody';

      SpEdCare.directSupervisonSave.init(opts);
  
  });
</script>

