<%@ Page Language="C#" CodeBehind="rpt_possible_pat_merges_needed.aspx.cs" Inherits="Spedmon.RptPossibleMergesNeeded" %>


 <Spedmon:Steps ID="viewxref" runat="server" autoHeight="false" autoScroll="true" dataURL="patients.ashx">

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
  
<Spedmon:StepView ID="step2" reportNumber="33" runat="server"/>
    
</Spedmon:Steps>


