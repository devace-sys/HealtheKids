<%@ Page Language="C#" CodeBehind="sbs_all_client_attendance_day_types_view.aspx.cs" Inherits="Spedmon.SBSAllClientAttendanceDayTypesView" %>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="clientattendancedaytypes.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list" 
   runat="server">
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
  </Spedmon:Step>  
      
<%/*************************************[ Step 2 ]************************************/%>
  
<Spedmon:StepView ID="step2" runat="server"/>

  <Spedmon:HiddenInput id="active" name="active" value="1" title="active" runat="server"></Spedmon:HiddenInput>
      
</Spedmon:Steps>
