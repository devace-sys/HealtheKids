<%@ Page Language="C#" CodeBehind="rpt_crc_claims.aspx" Inherits="Spedmon.RptCRCsClaims" %>

<%/****************************
  * Report CRCSCalims 
  ****************************/%>

 <Spedmon:Steps ID="claimsrpt" runat="server" autoHeight="false" dataURL="claims.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list.<br/>To select all clients leave this blank."
   optional="false"
   runat="server">
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
  </Spedmon:Step>
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="What Dates?"
    instructions="Enter a date or date range.  Click to select a date range or date.<br/>Selecting or entering any date within a month or a range of months gives you the data for the full month(s).<br/>For example 9/15/2010 will give you all of September 2010.<br/>Also 9/25/2010 - 11/3/2010 will give you all of September 2010 through all of November 2010."
    optional="false"
    runat="server">

    <Spedmon:DateBoxRange ID="daterange" name="daterange" value="" title="Click to select a date range or type one" runat="server" />

  </Spedmon:Step>
  
   <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step ID="step3" title="Enter PROCEDURE_CODE" 
    instructions="Enter the PROCEDURE_CODE1 then press enter or click OK"
    optional="true"
    runat="server">
     
    <Spedmon:TextBox id="proccode" name="proccode" maxlen="50" title="Enter PROCEDURE_CODE" runat="server"></Spedmon:TextBox>

  </Spedmon:Step>
  
  
   <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:Step ID="step4" title="Enter PROCEDURE_MODIFIER_1" 
    instructions="Enter the PROCEDURE_MODIFIER_1 then press enter or click OK"
    optional="true"
    runat="server">
     
    <Spedmon:TextBox id="procmod1" name="procmod1" maxlen="50" title="Enter PROCEDURE_MODIFIER_1" runat="server"></Spedmon:TextBox>

  </Spedmon:Step>
  
  <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:Step ID="step5" title="Enter PROCEDURE_MODIFIER_2" 
    instructions="Enter the PROCEDURE_MODIFIER_2 then press enter or click OK"
    optional="true"
    runat="server">
     
    <Spedmon:TextBox id="procmod2" name="procmod2" maxlen="50" title="Enter PROCEDURE_MODIFIER_2" runat="server"></Spedmon:TextBox>

  </Spedmon:Step>
  
  <%/*************************************[ Step 6 ]************************************/%>
  
  <Spedmon:Step ID="step6" title="Enter PROCEDURE_MODIFIER_3" 
    instructions="Enter the PROCEDURE_MODIFIER_3 then press enter or click OK"
    optional="true"
    runat="server">
     
    <Spedmon:TextBox id="procmod3" name="procmod3" maxlen="50" title="Enter PROCEDURE_MODIFIER_3" runat="server"></Spedmon:TextBox>

  </Spedmon:Step>
  
  <%/*************************************[ Step 7 ]************************************/%>
    
    <Spedmon:StepView ID="step7" reportNumber="6" runat="server"/>
    
</Spedmon:Steps>
  