<%@ Page Language="C#" CodeBehind="client_coor_user_edit_delete.aspx.cs" Inherits="Spedmon.clientcooruserseditdelete" %>

<%/****************************
  * Select User
  * for sbs (all)
  ****************************/%>

 <Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="users.ashx">
 
 

  <%/*************************************[ Step 1 ]************************************/%>
  
  <Spedmon:Step ID="step1" title="Name"
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

<%/*************************************[ Step 2 ]************************************/%>
    
<Spedmon:StepRecordsEditDelete ID="step2" 
                               editURL   = "client_coor_user_save.aspx" 
                               deleteURL = "users.asmx/delete"
                               recIDPos  = "2"
                               runat="server">
							   
 <Spedmon:HiddenInput id="clientid" name="clientid" value="1" title="clientid" runat="server"></Spedmon:HiddenInput>							   
    
</Spedmon:StepRecordsEditDelete>

</Spedmon:Steps>