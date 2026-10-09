<%@Page
Language="C#"
AutoEventWireup="true"
CodeBehind="request_account.aspx.cs"
Inherits="Spedmon.request_account" 
%>

<%/*********************************************************************************/%>
<%/* Account Request Instructions                                                  */%>
<%/*********************************************************************************/%>


<div style="width:70%;margin:0 auto; text-align: center;">
<Spedmon:Button ID="newAccountFormButton" onclick="doShowNewAccountForm()" runat="server">Click HERE to submit information for a NEW account.</Spedmon:Button>
</div>


<Spedmon:Instructions ID="acctrequest" instructionWidth="70%" title="For Other Inquiries Please Contact Your Practi-Cal Representative" runat="server">

<%=contactInfo%>
</Spedmon:Instructions>


<%/****************************
  * Scripts for options
  ****************************/%>
  
<Spedmon:Script runat="server">

function doShowNewAccountForm () {window.open("https://app.smartsheet.com/b/form?EQBCT=bdd8ef47d64e4b7bb97d421a15e85245","_blank","toolbar=0,location=0,menubar=0");}

</Spedmon:Script>