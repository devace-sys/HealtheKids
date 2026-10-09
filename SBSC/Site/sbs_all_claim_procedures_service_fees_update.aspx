<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="sbs_all_claim_procedures_service_fees_update.aspx.cs" Inherits="Spedmon.SbsAllClaimProceduresServiceFeesUpdate" %>

<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>

<div class="container-fluid">

<div class="row">

<div class="col-6">
  <div class="alert alert-danger" role="alert">
  This screen is for use by authorized Practi-Cal staff only.
  </div>
</div>

<div class="col-3">
    <a href="https://www.dhcs.ca.gov/provgovpart/Pages/LEA.aspx" target="_blank" class="btn btn-info btn-sm">Open DHCS LEA BOP Program Page</a>
</div> <!--col-->

<div class="col-1">
    <button id="butclearchanges" type="button" class="btn btn-warning btn-sm">Clear Changes</button>
</div> <!-- col -->

<div class="col-1">
    <button id="butverifychanges" type="button" class="btn btn-secondary btn-sm">Verify Changes</button>
</div> <!-- col -->

<div class="col-1">
    <button id="butsavechanges" type="button" class="btn btn-primary btn-sm">Save Changes</button>
</div> <!-- col -->


</div> <!--row -->

<div class="row mt-2">
<div class="col-8">
<form id="frmservicefeedata">
<select id="billingprogramid" name="billingprogramid">
    <option value="-1" disabled selected>Select A Billing Program</option>
    <option value="1">LEA BOP</option>
    <option value="2">CYBHI</option>
</select>
<Spedmon:DataEntryBoxTextArea ID="procmodcombosstr" name="procmodcombosstr" value="" minLen="0" maxLen="8000" showCharCountMeter="true" label="Proc Mod Combo(s)" title="Enter proc mod combos seperating multiple with commas" runat="server" />
<Spedmon:DataEntryBoxNumber ID="servicefee" min="0.00" step="0.01" value="0.00" name="servicefee" label="Max Allowable Rate" title= "Enter new max allowable rate or if applicable the average rate for under 18 and 18+" runat="server" />
<Spedmon:DataEntryBoxNumber ID="under18fee" min="0.00" step="0.01" value="0.00" name="under18fee" label="Max Under 18 Rate" title= "Enter new max allowable rate for those procedures that have a dedicated rate for under 18 or 0.00 if not applicable" runat="server" />
<Spedmon:DataEntryBoxNumber ID="over17fee"  min="0.00" step="0.01" value="0.00" name="over17fee"  label="Max 18+ Rate"      title= "Enter new max allowable rate for those procedures that have a dedicated rate for 18+ or 0.00 if not applicable" runat="server" />
<input id="validate" name="validate" type="hidden" value="Y" />
</form>
</div> <!-- col -->

<div class="col-4">
    <table class="table table-sm">
        <thead class="thead-light">
        <tr><th scope="col" colspan="2"><h5 style="text-align:center">Group</h5></th></tr>
        <tr><th scope="col">ID</th><th scope="col">Name</th></tr>
        </thead>
        <tbody id="tbltbodygroups">
        </tbody>
    </table>
</div> <!-- col -->

</div> <!-- row -->

<div class="row">
<div class="col-12">
<table class="table table-sm">
<thead class="thead-light">
    <tr>
    <th scope="col" colspan="7"><h5 style="text-align:center">Procedure</h5></th>
    <th scope="col" style="border-left:1px solid" colspan="6"><h5 style="text-align:center">Current or Previous Rates</h5></th>
    <th scope="col" style="border-left:1px solid" colspan="6"><h5 style="text-align:center">New Rates</h5></th>
    </tr>

    <tr>
    <th scope="col">Changes<br />Saved</th>
    <th scope="col">ID</th>
    <th scope="col">Name</th>
    <th scope="col">Proc Mod Combo</th>
    <th scope="col">Effective</th>
    <th scope="col">Expires</th>
    <th scope="col">Last<br />Updated</th>
    
    <th scope="col" style="border-left:1px solid">Standard</th>
    <th scope="col">Under<br />18</th>
    <th scope="col">18+</th>
    <th scope="col">TCM<br/>Low</th>
    <th scope="col">TCM<br/>Med</th>
    <th scope="col">TCM<br/>High</th>
    
    <th scope="col" style="border-left:1px solid">Standard</th>
    <th scope="col">Under<br />18</th>
    <th scope="col">18+</th>
    <th scope="col">TCM<br/>Low</th>
    <th scope="col">TCM<br/>Med</th>
    <th scope="col">TCM<br/>High</th>
    </tr>

</thead>
<tbody id="tbltbodyprocs">
</tbody>
</table>
</div> <!-- col-->

</div> <!-- row -->

</div> <!-- container -->


<%//##################################################################################################################%>
<%//#                                         Data Entry Scripts  %>
<%//##################################################################################################################%>

<script type="text/javascript">

const URL_SVC_FEE_UPDATE  = '<%=Spedmon.ClaimProcedureFees.URL_WEB_SVC_SERVICE_FEES_UPDATE()%>';
const URL_SESSION_EXPIRED = '<%=MBA.Credential.generateSessionExpiredLink()%>';

let frmSvcFeeDataRef    = null;
let butClearChangesRef  = null;
let butVerifyChangesRef = null;
let butSaveChangesRef   = null;
let inpValidateRef      = null;
let tbltbodygroupsref   = null;
let tbltbodyprocsref    = null;
let procAndGroupDataObj = {};

function updateGroupDataRpt() {
    $(tbltbodygroupsref).html('');

    $.each(procAndGroupDataObj.groups, function (idx, group) {
        let $tr = $('<tr></tr>');
        $($tr).append($('<td>' + group.GROUP_ID + '</td>'));
        $($tr).append($('<td>' + group.GROUP_NAME + '</td>'));
        $(tbltbodygroupsref).append($tr);
    });
}

function updateProcedureDataRpt() {
    $(tbltbodyprocsref).html('');
    $.each(procAndGroupDataObj.procs, function (idx, proc) {
        let $tr = $('<tr></tr>');

        $($tr).append($('<td>' + ((proc.DATA_HAS_BEEN_UPDATED == 1) ? 'Yes':'No') + '</td>'));
        $($tr).append($('<td>' + proc.PROCEDURE_ID + '</td>'));
        $($tr).append($('<td>' + proc.PROCEDURE_NAME  + '</td>'));
        $($tr).append($('<td>' + proc.PROC_MOD_COMBO  + '</td>'));
        $($tr).append($('<td>' + proc.EFFECTIVE_DATE_STR + '</td>'));
        $($tr).append($('<td>' + proc.EXPIRATION_DATE_STR + '</td>'));
        $($tr).append($('<td>' + proc.DATE_MODIFIED_STR   + '</td>'));

        $($tr).append($('<td style="border-left:1px solid">' + proc.SERVICE_FEE     + '</td>'));
        $($tr).append($('<td>' + proc.UNDER_18_FEE + '</td>'));
        $($tr).append($('<td>' + proc.OVER_17_FEE + '</td>'));
        $($tr).append($('<td>' + proc.TCM_LOW_RATE    + '</td>'));
        $($tr).append($('<td>' + proc.TCM_MEDIUM_RATE + '</td>'));
        $($tr).append($('<td>' + proc.TCM_HIGH_RATE   + '</td>'));

        $($tr).append($('<td style="border-left:1px solid">' + proc.NEW_SERVICE_FEE     + '</td>'));
        $($tr).append($('<td>' + proc.NEW_UNDER_18_FEE    + '</td>'));
        $($tr).append($('<td>' + proc.NEW_OVER_17_FEE + '</td>'));
        $($tr).append($('<td>' + proc.NEW_TCM_LOW_RATE + '</td>'));
        $($tr).append($('<td>' + proc.NEW_TCM_MEDIUM_RATE + '</td>'));
        $($tr).append($('<td>' + proc.NEW_TCM_HIGH_RATE   + '</td>'));
      
        $(tbltbodyprocsref).append($tr);
    });
};

function enableChangeButtons() {
   $(butClearChangesRef).prop('disabled', false);
   $(butVerifyChangesRef).prop('disabled', false);
   $(butSaveChangesRef).prop('disabled', false);
};

function disableChangeButtons() {
  $(butClearChangesRef).prop('disabled', true);
  $(butVerifyChangesRef).prop('disabled', true);
  $(butSaveChangesRef).prop('disabled', true);
};

function doRequestSvcFeeUpdate(validate) {
    disableChangeButtons();

    $(inpValidateRef).val(validate);
    MBA.ComponentCommon.fnFormToJSONAsynch(frmSvcFeeDataRef)
        .then(reqDataJSON => {
          MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(URL_SVC_FEE_UPDATE, reqDataJSON, URL_SESSION_EXPIRED)
            .then(respDataObj => {
                procAndGroupDataObj = null;
                procAndGroupDataObj = JSON.parse(respDataObj.rawData.jsonData);
                updateGroupDataRpt();
                updateProcedureDataRpt();
                enableChangeButtons();
            })
            .catch(respDataObj => {                
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Please Check Your Entry', respDataObj.message, {})
                enableChangeButtons();
            });
    });
};

function doClearChanges() {
  procAndGroupDataObj = {};
  $(tbltbodygroupsref).html('');
  $(tbltbodyprocsref).html('');
  $(frmSvcFeeDataRef).trigger('reset');
};

function doVerifyChanges() {
  doRequestSvcFeeUpdate('Y');
};

function doSaveChanges() {
  doRequestSvcFeeUpdate('N');
};

function init() {
  frmSvcFeeDataRef    = $('#frmservicefeedata');
  inpValidateRef      = $('#validate');
  butClearChangesRef  = $('#butclearchanges');
  butVerifyChangesRef = $('#butverifychanges');
  butSaveChangesRef   = $('#butsavechanges')
  tbltbodygroupsref   = $('#tbltbodygroups');
  tbltbodyprocsref    = $('#tbltbodyprocs');

  procAndGroupDataObj = {};
    $(butClearChangesRef).on('click', function (e) { doClearChanges();});
    $(butVerifyChangesRef).on('click', function (e) { doVerifyChanges(); });
    $(butSaveChangesRef).on('click', function (e) { doSaveChanges(); });
};

$(document).ready(function () {
    init();
    doClearChanges();
});

</script>