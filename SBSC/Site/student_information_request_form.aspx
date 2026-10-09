<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="student_information_request_form.aspx.cs" Inherits="Spedmon.StudentInformationRequestForm" subTitle="Student Information Request"%>

<%/*================================== Page Init Is OK  ==================================*/%>

<%if (pageInitIsOK == true) {%>

<%/*========== Common Header  ==========*/%>

<div class="container">
   <div class="row">
      <div class="col-4">
         <img src="<%=clientLogoDataURL%>"
            alt="<%=clientName%>"
            style="width:80%;height:80%;object-fit:contain;display:block;">
      </div> <!-- col -->
      <div class="col-8">
         <h1 class="text-center"><%=clientName%></h1>         
         <%if(commonHeaderShowRequestTitle   == true){%><h2 class="text-center"><%=GetLocalResourceObject("Common_Header_Request_Title")%></h2><%}%>
         <%if(commonHeaderShowRequestIDLabel == true){%><h2 class="text-center"><%=GetLocalResourceObject("Common_Header_Request_ID_Label")%> <span class="badge badge-info"><%=requestIDStr%></span></h2><%}%>
      </div> <!-- col -->      
   </div> <!-- row -->
</div> <!-- container -->

<hr/>            

<%/*========== Info Request ==========*/%>

<%if (responseMode == false){%>

<%/*========== Need A Language Selection ==========*/%>

<%if (promptForWhat == 1){%>

<div class="d-flex flex-column justify-content-center align-items-center">
<a class="btn btn-info m-1" href="<%=requestURL_EN%>">Continue in english</a>
<a class="btn btn-info m-1" href="<%=requestURL_ES%>">Continuar en español</a>
</div>

<%/*========== Need A DOB ==========*/%>

<%}else if (promptForWhat == 2) {%>

<form id="info-request-response-frm" method="post" action="student_information_request_form.aspx">

<div class="container">
<div class="row">
<div class="col-12">
<p><%=GetLocalResourceObject("Request_Greeting")%> <%=person.firstName%>,</p>
<p><%=GetLocalResourceObject("Request_For_Student_ID_Label")%> <%=studentIDLast2Chars%>.</p>
<div>
<%=requestMessageContent%>
</div> 
<p>            
<%=requesterName%>
<br />
<%=GetLocalResourceObject("On_Behalf_Of")%> <%=clientName%>
<br />
<a style="color:#000;" href="mailto:<%=requesterEmail%>"><%=requesterEmail%></a>
</p>
<p class="text-center font-weight-bold"><%=GetLocalResourceObject("Common_Header_Text_Note")%></p>
<hr />
</div> <!-- col -->
</div> <!-- row -->

<div class="row">        
<div class="col-12">
<h3 class="text-center"><%=GetLocalResourceObject("Form_Title")%></h3>

<input id="<%=Spedmon.Constants.PARM_PUBLIC_TOKEN%>" 
                   name="<%=Spedmon.Constants.PARM_PUBLIC_TOKEN%>" 
                   type="hidden" 
                   value="<%=ptkn%>" />

<input id="<%=Spedmon.Constants.PARM_PAT_PER_ID%>" name="<%=Spedmon.Constants.PARM_PAT_PER_ID%>" value="<%=patPerID%>" type="hidden" />

<input id="<%= Spedmon.Constants.PARM_FORM_REQUEST_OR_RESPONSE %>" 
                   name="<%= Spedmon.Constants.PARM_FORM_REQUEST_OR_RESPONSE %>" 
                   type="hidden" 
                   value="<%= Spedmon.Constants.FRM_RSP %>" />
  
<input id    = "<%=Spedmon.Constants.PARM_LANGUAGE%>"                    
       name  = "<%=Spedmon.Constants.PARM_LANGUAGE%>" 
       type  = "hidden" 
       value = "<%=rd.language%>" />


<input id    = "<%=Spedmon.Constants.PARM_DOB%>"                    
       name  = "<%=Spedmon.Constants.PARM_DOB%>" 
       type  = "hidden" 
       value = "<%=patDOB%>" />

</div> <!-- col -->
</div> <!-- row -->
    
 <div class="row g-2">
 <div class="col-12 col-md-2">
                <label for="<%=PARM_INSURANCE_CARRIER_POLICY_HOLDER_FIRST_NAME%>" class="custom-label">
                    <%=GetLocalResourceObject("INSURANCE_CARRIER_POLICY_HOLDER_FIRST_NAME_LABEL")%>
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_INSURANCE_CARRIER_POLICY_HOLDER_FIRST_NAME%>" 
                       name="<%=PARM_INSURANCE_CARRIER_POLICY_HOLDER_FIRST_NAME%>"                       
                       placeholder="<%=GetLocalResourceObject("INSURANCE_CARRIER_POLICY_HOLDER_FIRST_NAME_PLACEHOLDER")%>" 
                       type="text" required="required" />
</div> <!-- col -->

<div class="col-12 col-md-2">
                <label for="<%=PARM_INSURANCE_CARRIER_POLICY_HOLDER_LAST_NAME%>" class="custom-label">
                    <%=GetLocalResourceObject("INSURANCE_CARRIER_POLICY_HOLDER_LAST_NAME_LABEL")%>
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_INSURANCE_CARRIER_POLICY_HOLDER_LAST_NAME%>" 
                       name="<%=PARM_INSURANCE_CARRIER_POLICY_HOLDER_LAST_NAME%>" 
                       placeholder="<%=GetLocalResourceObject("INSURANCE_CARRIER_POLICY_HOLDER_LAST_NAME_PLACEHOLDER")%>" 
                       type="text" required="required" />
</div> <!-- col -->

<div class="col-12 col-md-2">
                <label for="<%=PARM_INSURANCE_CARRIER_CODE%>" class="custom-label">
                    <%=GetLocalResourceObject("INSURANCE_CARRIER_CODE_LABEL")%>                   
                </label>
                <select class="form-control form-control-sm custom-input" 
                        id="<%=PARM_INSURANCE_CARRIER_CODE%>" 
                        name="<%=PARM_INSURANCE_CARRIER_CODE%>" required="required">
                        
                    <%=insuranceCarrierOptions%>
                </select>
</div> <!-- col -->

<div id="carrier-other-cont" class="col-12 col-md-2">
                <label for="<%=PARM_INSURANCE_CARRIER_OTHER_NAME%>" class="custom-label">                    
                    <%=GetLocalResourceObject("INSURANCE_CARRIER_OTHER_NAME_LABEL")%>                    
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_INSURANCE_CARRIER_OTHER_NAME%>" 
                       name="<%=PARM_INSURANCE_CARRIER_OTHER_NAME%>" 
                       placeholder="<%=GetLocalResourceObject("INSURANCE_CARRIER_OTHER_NAME_PLACEHOLDER")%>" 
                       type="text" />
</div> <!-- col -->

<div class="col-12 col-md-2">
                <label for="<%=PARM_POLICY_NUMBER%>" class="custom-label">
                    <%=GetLocalResourceObject("POLICY_NUMBER_LABEL")%>                    
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_POLICY_NUMBER%>" 
                       name="<%=PARM_POLICY_NUMBER%>" 
                       placeholder="<%=GetLocalResourceObject("POLICY_NUMBER_PLACEHOLDER")%>" 
                       type="text" 
                    required />
</div> <!-- col -->

<div class="col-12 col-md-2">
                <label for="<%= PARM_INSURANCE_GROUP_NUMBER_ID %>" class="custom-label">                    
                    <%=GetLocalResourceObject("INSURANCE_GROUP_NUMBER_ID_LABEL")%>
                </label>

                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_INSURANCE_GROUP_NUMBER_ID%>" 
                       name="<%=PARM_INSURANCE_GROUP_NUMBER_ID%>" 
                       placeholder="<%=GetLocalResourceObject("INSURANCE_GROUP_NUMBER_ID_PLACEHOLDER")%>" 
                       type="text" 
                       />
</div> <!-- col -->
</div> <!-- row -->

<div class="row mb-0 py-1">

<div class="col-12 col-md-8">
                <div class="d-flex mt-2 align-items-start ">
                    <div class="checkbox-wrapper-19 mr-2">
                        <input type="radio" id="consent_yes" 
                               name="<%=PARM_CONSENT%>" 
                               value="1" required="required"  />
                        <label class="check-box" for="consent_yes"></label>
                    </div>
                    <label for="consent_yes" class="mr-4" style="font-weight: 200; font-size: 0.75em;">
                    <span style="font-weight: bold;  text-decoration: underline;"><%=GetLocalResourceObject("CONSENT_YES")%></span> <%=GetLocalResourceObject("CONSENT_YES_NO_COMMON")%>
                    </label>
                    
                    <div class="checkbox-wrapper-19 mr-2">
                        <input type="radio" id="consent_no" 
                               name="<%=PARM_CONSENT%>" 
                               value="0" required="required" />
                        <label class="check-box" for="consent_no"></label>
                    </div>
                    <label for="consent_no" style="font-weight: 200; font-size: 0.75em;">
                       <span style="font-weight: bold; text-decoration: underline;"><%=GetLocalResourceObject("CONSENT_NO")%></span> <%=GetLocalResourceObject("CONSENT_YES_NO_COMMON")%>
                    </label>
                </div>
</div> <!-- col -->

<div class="col-12 col-md-4">            
              <label style="font-weight: bold; font-size: 0.8rem" class="custom-label"><%=GetLocalResourceObject("SIGNATURE_LABEL")%></label>
              <br />
              <canvas id="responder-signature-img" style="border:1px solid"></canvas>
              <textarea id="<%=PARM_RESPONDER_SIGNATURE_IMG_DATA%>" name="<%=PARM_RESPONDER_SIGNATURE_IMG_DATA%>" style="display:none;"></textarea>
</div> <!-- col -->

</div> <!-- row -->

<!-- Submit and Clear Buttons -->

<div class="row mb-2 py-2">
            <div class="col-6">
                <button type="reset"
                        id="btn-clear-form"
                        class="btn btn-secondary btn-block">
                    <span><%=GetLocalResourceObject("CLEAR_LABEL")%></span>
                </button>
            </div> <!-- col -->
            <div class="col-6 d-flex justify-content-end">
                <button type="submit"
                        id="btn-submit-form"
                        class="btn btn-primary btn-block">
                    <span><%=GetLocalResourceObject("SUBMIT_LABEL")%></span>
                </button>
            </div> <!-- col -->
        </div> <!-- row -->
    </div> <!-- container -->
</form>

<script type="text/javascript" src="third-party/signature-pad.min.js"></script>

<script type="text/javascript">

    let $policyHolderFirstName = null;
    let $policyHolderLastName  = null;
    let $policyNumber          = null;
    let $insuranceCarrierSel   = null;
    let $otherCarrierCont      = null;
    let responderSigPad        = null;
    let $responderSigTA        = null;

    $(document).ready(function () {

        let responderSigCanvas = document.getElementById('responder-signature-img');

        responderSigPad = new SignaturePad(responderSigCanvas);

        $responderSigTA        = $('#<%=PARM_RESPONDER_SIGNATURE_IMG_DATA%>');
        $policyHolderFirstName = $('#<%=PARM_INSURANCE_CARRIER_POLICY_HOLDER_FIRST_NAME%>');
        $policyHolderLastName  = $('#<%=PARM_INSURANCE_CARRIER_POLICY_HOLDER_LAST_NAME%>');
        $policyNumber          = $('#<%=PARM_POLICY_NUMBER%>');
        $insuranceCarrierSel   = $('#<%=PARM_INSURANCE_CARRIER_CODE%>');
        $otherCarrierCont      = $('#carrier-other-cont');

        $($otherCarrierCont).hide();

        $($insuranceCarrierSel).on('change', function () {
            let carrierSel = $($insuranceCarrierSel).val();
           
            if (carrierSel == '<%=Spedmon.InsuranceCarriers.OPTION_VALUE_OTHER%>') {
                $($otherCarrierCont).show();
            }
            else if (carrierSel == '<%=Spedmon.InsuranceCarriers.OPTION_VALUE_NO_INSURANCE%>') {
                $($policyHolderFirstName).val('None');
                $($policyHolderLastName).val('None');
                $($policyNumber).val('None');
                $($otherCarrierCont).hide();
            }
            else {
                $($otherCarrierCont).hide();
            }
        });

        $('#info-request-response-frm').on('submit', function () {
            if (!responderSigPad.isEmpty()) {
                $($responderSigTA).val(responderSigPad.toDataURL());
            } else {
                $($responderSigTA).val('');
            }
            
        });

        $('#info-request-response-frm').on('reset', function () {
            responderSigPad.clear();
            $($responderSigTA).val('');
            $($otherCarrierCont).hide();
        });

    });
</script>

<%} /* Prompt for requested data */%>

<%/*========== Info Response ==========*/%>

<%} else {%>

<div class="container">
<div class="row">
<div class="col-12">
<div class="alert alert-success">
<h3 class="text-center">
<%=GetLocalResourceObject("Response_Title")%>
</h3>
<h4 class="text-center">            
<%=GetLocalResourceObject("Response_Questions_Label")%> : <%=requesterName%> <a style="color:#000;" href="mailto:<%=requesterEmail%>"><%=requesterEmail%></a>
</h4>
</div> <!-- alert -->
</div> <!-- col -->
</div> <!-- row -->
                
<%if(responseShowNoInsuranceOptions == true){%>
<div class="row mt-2">
<div class="col-12">
<div class="alert alert-info">
<h3 class="text-center"><%=GetLocalResourceObject("Covered_CA_Message_Top")%></h3>
<h4 class="text-center"><%=GetLocalResourceObject("Covered_CA_Message_Bottom_Left")%> <a style="color:#000;" href="https://www.coveredca.com/">Covered California</a> <%=GetLocalResourceObject("Covered_CA_Message_Bottom_Right")%></h4>
</div> <!-- alert -->
</div> <!-- col -->
</div> <!-- row -->
<%}%>
</div> <!-- container -->
<%}%>

<%} else {%>

<%/*================================== Page Init Is NOT OK  ==================================*/%>

<%/*========== Not or no longer a Valid Request  ==========*/%>

<div class="alert alert-info">
<p class="text-center"><%=GetLocalResourceObject("Page_Init_Not_OK")%></p>
</div>

<%}%>