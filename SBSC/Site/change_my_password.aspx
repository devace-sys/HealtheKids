<%@Page Language="C#" CodeBehind="change_my_password.aspx.cs" Inherits="Spedmon.changemypassword"%>


<%/************************/%>
<%/* Change My Password   */%>
<%/* Users changing their */%>
<%/* own password         */%>
<%/************************/%>
<div class="container-fluid">
<div class="row">
    <div class="col-12 col-md-6">

        <%/*********************************************************************************/%>
        <%/* Password Change Instructions                                                  */%>
        <%/*********************************************************************************/%>
        
        <Spedmon:Instructions ID="strongpwd" title="All New Passwords Must Be Strong Passwords" instructionWidth="80%" runat="server">
            We require a strong password to help protect our Patient's HIPAA and FERPA information.
            <br />
            <br /> 
            A strong password:<br /><br />
            <ul class="ui-instruction-list">
              <li class="ui-instruction-list">Contains at least one letter</li>
              <li class="ui-instruction-list">Contains at least one number</li>
              <li class="ui-instruction-list">Is at least 8 characters in length</li>
            </ul>    
            <br />
            For example:<br /><br />
            <ul class="ui-instruction-list">
              <li class="ui-instruction-list">'letmein' is NOT a strong password</li>
              <li class="ui-instruction-list">'letMein2day IS a strong password</li>
            </ul>
        </Spedmon:Instructions>
    </div>

    <div class="col-12 col-md-6">

        <%/*********************************************************************************/%>
        <%/* Password Change Fields                                                        */%>
        <%/*********************************************************************************/%>
        
        <Spedmon:DataEntryRows ID="save" runat="server" dataURL="users.asmx/changemypassword" useBootstrapFluid="true">

            <div class="row mb-2">
                <div class="col-12 col-xl-4 mb-2">
                    <span>Current or temporary password</span>
                </div>
                <div class="col-12 col-xl-8 mb-2">
                    <Spedmon:PasswordBox id="oldpwd" name="oldpwd" maxlen="50" title="Enter your current password" privateEntry="true" privateLabel="Current Password Entered" showOK="false" runat="server"></Spedmon:PasswordBox>
                </div>
            </div>

            <div class="row mb-2">
                <div class="col-12 col-xl-4 mb-2">
                    <span>New password</span>
                </div>
                <div class="col-12 col-xl-8 mb-2">
                    <Spedmon:PasswordBox id="newpwd1" name="newpwd1" maxlen="50" title="Enter your new password" privateEntry="true" privateLabel="New Password Entered" showOK="false" runat="server"></Spedmon:PasswordBox>
                </div>
            </div>

            <div class="row mb-2">
                <div class="col-12 col-xl-4 mb-2">
                    <span>Re-enter new password</span>
                </div>
                <div class="col-12 col-xl-8 mb-2">
                    <Spedmon:PasswordBox id="newpwd2" name="newpwd2" maxlen="50" title="Enter your new password again" privateEntry="true" privateLabel="New Password Entered" showOK="false" runat="server"></Spedmon:PasswordBox>
                </div>
            </div>

            <Spedmon:DataEntryRowSaveOrEdit 
                ID                               = "saveOrEdit"
                editDelManageLink                = ""
                includeSaveAndProceedButton      = "false"
                includeSecondarySaveButton       = "true"
                secondarySaveButtonLabel         = "Save & Proceed"
                secondarySaveButtonOnClick       = "saveNewPwdAndProceedToNext(e)"
                runat                            = "server">

            </Spedmon:DataEntryRowSaveOrEdit>

        </Spedmon:DataEntryRows>

    </div>
</div> <!-- row -->
</div> <!-- container -->

<%/****************************
  * Scripts for options
  ****************************/%>

<script type="text/javascript">


/***************************************************************************
 * saveAndProceedToNext */
/**
 *
 ***************************************************************************/

function saveNewPwdAndProceedToNext(e) {
  var fnProceedToNext = function (rd) {
    var nextPage = '<%=urlNextPage%>';
    $.spedmonWebUI.gotoURL(nextPage)
  };
  $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', fnProceedToNext, true);
}
</script>
