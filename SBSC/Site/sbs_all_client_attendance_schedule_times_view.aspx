<%@ Page Language="C#" CodeBehind="sbs_all_client_attendance_schedule_times_view.aspx.cs" Inherits="Spedmon.SBSAllClientAttendanceScheduleTimesView" %>

<Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="clientattendancescheduletimes.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list" 
   runat="server">
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
  </Spedmon:Step>  
  
   <%/*************************************[ Step 2]************************************/%>
  
  <Spedmon:Step ID="step2" title="Select Fiscal Year" 
    instructions="Select the fiscal year"
    runat="server">
    
    <Spedmon:ComboBox ID="fiscalyearid" name="fiscalyearid" title="Select Fiscal Year" dataPrivate="true" dataURL="clientattendanceyears.asmx/viewSel" runat="server" /> 
   
  </Spedmon:Step>  

  <%/*************************************[ Step 3 ]************************************/%>
      
 <Spedmon:Step ID="step3" title="Select Bell Schedule" 
    instructions="Select the Bell Schedule"
    runat="server">
    
    <Spedmon:ComboBox ID="scheduleid" name="scheduleid" title="Select Bell Schedule" dataPrivate="true" dataURL="clientattendanceschedules.asmx/viewSel" dataParms="[{id:'clientid'},{id:'fiscalyearid'}]" runat="server"/>
    
  </Spedmon:Step>  
  
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:StepView ID="step4" runat="server">
  
      <Spedmon:HiddenInput id="active" name="active" value="1" title="active" runat="server"></Spedmon:HiddenInput>
  
  </Spedmon:StepView>
    
</Spedmon:Steps>