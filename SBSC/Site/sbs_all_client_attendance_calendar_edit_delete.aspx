<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="sbs_all_client_attendance_calendar_edit_delete.aspx.cs" Inherits="Spedmon.SBSAllClientAttendanceCalendarEditDelete" %>

<%/****************************
  * Select Client attendance day type
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="clientattendancecalendars.ashx">
 
  <%/*************************************[ Step 1 ]************************************/%>
  
   <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list.<br/>To select all clients leave this blank."
   runat="server">
          
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
    
  </Spedmon:Step>
  
  <%/*************************************[ Step 2]************************************/%>
  
  <Spedmon:Step ID="step2" title="Select Fiscal Year" 
    instructions="Select the fiscal year"
    runat="server">
    
    <Spedmon:ComboBox ID="fiscalyearid" name="fiscalyearid" value="" title="Select Fiscal Year" dataPrivate="true" dataURL="clientattendanceyears.asmx/viewSel" runat="server" /> 
   
  </Spedmon:Step>   

  <%/*************************************[ Step 3 ]************************************/%>
  
 
<Spedmon:StepRecordsEditDelete ID="step3" 
                               editURL   = "sbs_all_client_attendance_calendar_save.aspx" 
                               deleteURL = "clientattendancecalendars.asmx/delete"
                               recIDPos  = "2"
                               runat="server">
    
  <Spedmon:HiddenInput id="active" name="active" value="1" title="active" runat="server"></Spedmon:HiddenInput>

</Spedmon:StepRecordsEditDelete>

</Spedmon:Steps>