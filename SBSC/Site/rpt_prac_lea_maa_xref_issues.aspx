<%@ Page Language="C#" CodeBehind="rpt_prac_lea_maa_xref_issues.cs" Inherits="Spedmon.PractitionersLEAMAAXrefIssues" %>


<%/*********************************************************************************/%>
<%/* Report Instructions                                                           */%>
<%/*********************************************************************************/%>

<Spedmon:Instructions ID="pwdresetinst" instructionWidth="70%" title="Important Information About This Report" runat="server">

This report contains a list of LEA practitioner and MAA participants who are :
<br />
<br /> 
<ul class="ui-instruction-list">
<li class="ui-instruction-list">common between the LEA and MAA programs based on practitioner/participant emails</li>
<li class="ui-instruction-list">currently active in both programs</li>
<li class="ui-instruction-list">currently coded as "not MAA" in LEA</li>
</ul>
<br />
<br />
Please note :
<br/>
<br />
<ul class="ui-instruction-list">
  <li class="ui-instruction-list">This report cannot be run between 12AM and 5AM because the MAA data is being refreshed</li>
  <li class="ui-instruction-list">The MAA data in this report is at least 24 hours old</li>
</ul>

</Spedmon:Instructions>

<%/****************************
  * View LEA and MAA 
  * Practitioners cross reference
  * with setup issues
  ****************************/%>

 <Spedmon:Steps ID="viewxref" runat="server" autoHeight="false" autoScroll="true" dataURL="practitioners.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list.<br/>To select all clients leave this blank."
   optional="true"
   runat="server">
          
  <%/****************************
    * Do not remove the following
    * inputs.  Their values will
    * be automatically replaced
    * on the server side.
    ****************************/%>
     
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
  </Spedmon:Step>
  
<%/*************************************[ Step 3 ]************************************/%>
  
<Spedmon:StepView ID="step2" reportNumber="3" runat="server"/>
    
</Spedmon:Steps>