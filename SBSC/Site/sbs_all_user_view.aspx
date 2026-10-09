<%@ Page Language="C#" CodeBehind="sbs_all_users_view.aspx.cs" Inherits="Spedmon.SBSAllUsersView" %>

<%/****************************
  * View Users
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="users.ashx">

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Who is the Client?"
   instructions="Start typing the client name or click on the down arrow for a list.<br/>To select all clients leave this blank."
   runat="server">
               
    <Spedmon:ComboBox ID="clientid" name="clientid" value="" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server" /> 
  
  </Spedmon:Step>
  
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="Select the Role?"
   instructions="Start typing the role name or click on the down arrow for a list."
   runat="server">
          
    <Spedmon:ComboBox ID="roleid" name="roleid" title="Select Role" dataPrivate="true" dataURL="roles.asmx/viewSel" runat="server" /> 
  
  </Spedmon:Step>

   
  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step ID="step3" title="Name"
   instructions="Enter user's name" 
   ondataselected="" 
   runat="server">
    <Spedmon:Group ID="username" 
                   title="User Name" 
                   fnControlValue="var vl  = $('#lname').val() + ',' + $('#fname').val(); return vl;" 
                   fnControlLabel="var lbl = $('#lname').val() + ',' + $('#fname').val(); return lbl;"
                   okButton ="true" 
                   runat="server">
      <Spedmon:Input ID="lname" name="lname" inlineLabel="Last"   cssInline="width:150px;" title="Enter Last Name"   runat="server" />
      <Spedmon:Input ID="fname" name="fname" inlineLabel="First"  cssInline="width:150px;" title="Enter First Name"  runat="server" />
    </Spedmon:Group>
 
 </Spedmon:Step>


<%/*************************************[ Step 4 ]************************************/%>
  
<Spedmon:StepView ID="step4" runat="server"/>
    
</Spedmon:Steps>