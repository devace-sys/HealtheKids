<%@ Page Language="C#" CodeBehind="client_coor_users_view.aspx.cs" Inherits="Spedmon.clientcoorusersview" %>

<%/****************************
  * View Users
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="users.ashx">

   
  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Select the Role?"
   instructions="Start typing the role name or click on the down arrow for a list."
   runat="server">
          
    <Spedmon:ComboBox ID="roleid" name="roleid" title="Select Role" dataPrivate="true" dataURL="roles.asmx/viewSel" runat="server" /> 
  
  </Spedmon:Step>

   
  <%/*************************************[ Step 2 ]************************************/%>
  
  <Spedmon:Step ID="step2" title="Name"
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


<%/*************************************[ Step 3 ]************************************/%>

<Spedmon:HiddenInput ID="clientid"    name="clientid"    title="client id" runat="server"/>  
<Spedmon:StepView ID="step3" runat="server"/>
    
</Spedmon:Steps>