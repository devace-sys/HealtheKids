<%@ Page Language="C#" CodeBehind="client_coor_rpt_prac_review.aspx.cs" Inherits="Spedmon.ClientCoorRptPractitionersReview" %>

<%/****************************
  * View Practitioner Records
  * for Client
  ****************************/%>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" dataURL="practitioners.ashx">
 
 <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Select Practitioner Type" 
    instructions="Select the practitioner type"
    runat="server">
    <Spedmon:ComboBox ID="groupid" name="groupid" title="Select Type" dataPrivate="true" dataURL="groups.asmx/viewSelDisp" dataParms="[{}]" runat="server" />
  </Spedmon:Step>
 
  <%/*************************************[ Step 2 ]************************************/%>
   
   <Spedmon:Step ID="step2" title="Do you want only active practitioners or all?"
   instructions="Do you want only active practitioners?" 
   optional="true"
   ondataselected="" 
   runat="server">
     <Spedmon:YesNo ID="active" name="active" title="Do you want only active practitioners or all?" runat="server" />
 </Spedmon:Step>
 
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:StepView ID="step3" reportNumber="2" runat="server"/>

</Spedmon:Steps>   

