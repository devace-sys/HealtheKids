<%@ Page Language="C#" CodeBehind="sbs_all_svcrec_edit_delete.aspx.cs" Inherits="Spedmon.SBSAllServiceRecordsEditDelete" %>

<%/****************************
  * Select Service Record
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="servicerecords.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list"
   runat="server">
              
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
  </Spedmon:Step>

      
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="What is the Reference Document Filename?"
   instructions="Enter the filename for the reference document"
   runat="server">
   
     <Spedmon:TextBox id="reference" name="reference" value="" maxlen="255" title="Enter Filename" cssInline="width:40em;margin-right:.6em" runat="server"></Spedmon:TextBox>

  </Spedmon:Step>

  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:StepSelectPractitioner 
    ID                    = "step3" 
    optional              = "true" 
    showaddpractitioner   = "false"
    showdatasource        = "true"
    savedatasource        = "false"       
    showpractionernotes   = "true" 
    selecttype            = "COMBO_BOX" 
    selectall             = "true" 
    selectdelay           = "0" 
    selectid              = "pracid"
    runat                 = "server">
  </Spedmon:StepSelectPractitioner> 
  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepSelectPatient ID="step4" 
    optional="true"
    showdatasource="true"   
    showaddpatient="false" 
    showpatientnotes="true" 
    selecttype="SEARCH_BOX" 
    selectall="false" 
    selectdelay="0" 
    selectid="patid" 
    runat="server">             
  </Spedmon:StepSelectPatient>
  
  
  <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:Step 
    ID           = "step5" 
    title        = "What Service Dates?"
    instructions = "Click to select a date range or type in a date or date range"
    optional     = "false"
    runat        = "server">

    <Spedmon:DateBoxRange 
      ID               = "daterange" 
      name             = "daterange" 
      title            = "Click to select a date range or type one" 
      runat            = "server" />
  </Spedmon:Step>
  
  <%/*************************************[ Step 6 ]************************************/%>
  
    <Spedmon:StepRecordsEditDelete ID="step6" 
                               editURL       = "sbs_all_svcrec_save.aspx" 
                               editIsSubPage = "true"
                               deleteURL     = "servicerecords.asmx/delete"
                               recIDPos      = "2"
                               runat="server">
    
    </Spedmon:StepRecordsEditDelete>
    
</Spedmon:Steps>