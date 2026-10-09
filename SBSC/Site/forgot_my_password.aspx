<%@Page Language="C#" AutoEventWireup="true"
CodeBehind="forgot_my_password.aspx.cs"
Inherits="Spedmon.forgot_my_password" 
subTitle="Request Password Reset"
%>

<MBAWU3:Script runat="server">
    var $frm = $('#resetpassword');
    var $statusCtrl = ('#resetpassword-status-list')
    var fnSuccess = function(respData) {
    $('#but-request-password-reset').hide();
    var msg = 'We just sent you a TEMPORARY password and instructions on what to do next to the email account we have on record for you. It should arrive very soon.<br/><br/>Please check your email in a couple minutes.<br/><br/>If it is NOT there, please look in your “junk” folder.<br/><br/>If it is NOT there, please call your district representative.';            
    $($statusCtrl).mbaNotificationsListAddRemoveItem ($.spedmonWebUI3.ret.SUCCESS, msg, 0, null);
  };
</MBAWU3:Script>

<div class="mba-top-center-responsive-form-container">

  <MBAWU3:Form 
    ID                        = "resetpassword" 
    Action                    = "users.asmx/forgotpassword" 
    Method                    = "post" 
    StatusList                = "true"
    StatusListID              = "resetpassword-status-list"
    
    SubmitButton              = "true"
    SubmitButtonID            = "but-request-password-reset"
    SubmitButtonClass         = "btn btn-block btn-primary btn-lg"
    SubmitButtonContentMarkup = "Submit Reset Request"
    ProgressiveEnhance        = "true"
    ProgressiveEnhanceMarkup  = "$(window).on('load',function () {var $frm = $('#resetpassword'); var $statusCtrl = ('#resetpassword-status-list'); $.spedmonWebUI3.setupForm($frm, $statusCtrl, fnSuccess);});"
    runat                     = "server">
  
    <MBAWU3:TextBox ID="email" Name="email" Title="Enter your user name" LabelText="User Name" Required="true" Autofocus="true" Autocomplete="off" runat="server"/>
    <MBAWU3:HiddenValue ID="validaterec" name="validaterec" value="0" runat="server" />    

  </MBAWU3:Form>

</div>