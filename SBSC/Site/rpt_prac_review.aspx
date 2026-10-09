<%@ Page Language="C#" CodeBehind="rpt_prac_review.aspx.cs" Inherits="Spedmon.PractitionersReview" %>

<%/****************************
  * View Service Record
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="practitioners.ashx">

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
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="Select Practitioner Type" 
    instructions="Select the practitioner type"
    runat="server">
    <Spedmon:ComboBox ID="groupid" name="groupid" title="Select Type" dataPrivate="true" dataURL="groups.asmx/viewSelDisp" dataParms="[{}]" runat="server" />
  </Spedmon:Step>  
  
  <%/*************************************[ Step 3 ]************************************/%>
   
   <Spedmon:Step ID="step3" title="Do you want only active practitioners or all?"
   instructions="Do you want only active practitioners?" 
   optional="true"
   ondataselected="" 
   runat="server">
     <Spedmon:YesNo ID="active" name="active" title="Do you want only active practitioners or all?" runat="server" />
 </Spedmon:Step>
   
<%/*************************************[ Step 4 ]************************************/%>
  
<Spedmon:StepView ID="step4" reportNumber="2" runat="server"/>
    
</Spedmon:Steps>