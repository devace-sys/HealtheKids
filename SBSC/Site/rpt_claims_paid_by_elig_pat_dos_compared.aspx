<%@ Page Language="C#" CodeBehind="rpt_claims_paid_by_elig_pat_dos_compared.aspx.cs" Inherits="Spedmon.RptClaimsPaidByEligPatDosCompared" %>

<%/****************************
   * "Chuck Report"
   ****************************/%>

 <%/*********************************************************************************/%>
 <%/* Report Instructions                                                           */%>
 <%/*********************************************************************************/%>

<Spedmon:Instructions ID="pwdresetinst" instructionWidth="70%" title="Important Information About This Report" runat="server">
This report cannot be run between 12AM and 5AM because the eligibility data is being refreshed during that time period.
</Spedmon:Instructions>
 
 
<Spedmon:Steps ID="claimsrpt" runat="server" autoHeight="false" dataURL="reports_fin.ashx">

  <%/*************************************[ Step 1 ]************************************/%>

  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list"
   optional="false"
   runat="server">
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
  </Spedmon:Step>
   
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="What Date Range?"
    instructions="Click to select a date range or type in a date or date range"
    optional="false"
    runat="server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" value="" title="Click to select a date range or type one" runat="server" />

  </Spedmon:Step>
  
  <%/*************************************[ Step 3 ]************************************/%>
    
   <Spedmon:StepSelectPatient ID="step3" 
    optional="true"
    showaddpatient="false" 
    showdatasource="false"   
    showpatientnotes="true" 
    selecttype="SEARCH_BOX" 
    selectall="false" 
    selectdelay="0" 
    selectid="patid"
    runat="server">
  </Spedmon:StepSelectPatient>
  
  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:Step ID="step4" title="Select Patients Site" 
    instructions="Start typing the site name or click on the down arrow for a list"
    optional="true"
    runat="server">
  
    <Spedmon:ComboBox ID="siteid" name="siteid" title="Select Site" dataPrivate="true" dataURL="sites.asmx/viewSel" dataParms="[{id:'clientid'}]" runat="server" />
  
  </Spedmon:Step>
  
  <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:StepSelectPractitioner 
    ID                    = "step5" 
    optional              = "false" 
    showaddpractitioner   = "false"
    showdatasource        = "false"
    savedatasource        = "false"       
    showpractionernotes   = "true" 
    selecttype            = "COMBO_BOX" 
    selectall             = "true" 
    selectdelay           = "0" 
    selectid              = "pracid"
    runat                 = "server">
  </Spedmon:StepSelectPractitioner> 

  <%/*************************************[ Step 6 ]************************************/%>
  
  <Spedmon:Step ID="step6" title="Which Discipline?"
   instructions="Start typing the group name or click on the down arrow for a list.<br/>To select all groups leave this blank."
   optional="true"
   runat="server">
    <Spedmon:ComboBox ID="groupid" name="groupid" value="" title="Select group" dataPrivate="true" dataURL="groups.asmx/viewSelDispSuper" dataParms="[{id:'clientid'}]" runat="server" />
  </Spedmon:Step>

  
  <%/*************************************[ Step 7 ]************************************/%>
    
  <Spedmon:StepReport ID="step7" reportNumber="6" runat="server"/>
    
</Spedmon:Steps>
